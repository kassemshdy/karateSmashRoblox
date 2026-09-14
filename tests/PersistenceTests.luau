-- Deterministic storage tests use the same UpdateAsync transforms as production.
return function()
    local ProfileStore = require(game.ServerScriptService.Data.ProfileStore)
    local MemoryStore = require(game.ServerScriptService.Data.MemoryStore)
    local Config = { RetryAttempts = 3, LeaseSeconds = 180 }
    local time = 1000
    local memory = MemoryStore.new()
    local store = ProfileStore.new(memory, Config, function() return time end, function() end)
    local function progress(points, coins, trophies)
        return { Version = 1, Points = points, Coins = coins, Trophies = trophies }
    end
    local loaded, failure = store:load("new", "server-A")
    assert(loaded.Points == 0 and loaded.Coins == 0 and loaded.Trophies == 0 and failure == nil)
    local duplicate, reason = store:load("new", "server-B")
    assert(not duplicate and reason == "SessionLocked", "Concurrent load was allowed")
    assert(store:save("new", "server-A", progress(50, 100, 3), false))
    assert(not store:save("new", "server-B", progress(999, 999, 999), true), "Non-owner wrote profile")
    assert(store:save("new", "server-A", progress(75, 120, 4), true))
    local rejoined = store:load("new", "server-B")
    assert(rejoined.Points == 75 and rejoined.Coins == 120 and rejoined.Trophies == 4, "Rejoin lost progress")
    assert(not store:save("new", "server-A", progress(0, 0, 0), false), "Stale server overwrote rejoin")
    print("PERSISTENCE_PASS: defaults, exclusive session, save/release/rejoin, stale write rejection")

    time += 181
    assert(not store:save("new", "server-B", progress(100, 200, 5), false), "Expired session saved")
    local recovered = store:load("new", "server-C")
    assert(recovered.Points == 75 and recovered.Trophies == 4, "Crash recovery lost last save")
    assert(store:save("new", "server-C", progress(100, 200, 5), false))
    time += 100
    assert(store:save("new", "server-C", progress(100, 205, 5), false))
    time += 100
    assert(not store:load("new", "server-D"), "Autosave failed to renew lease")
    print("PERSISTENCE_PASS: expired lease, crash recovery, autosave renewal")

    for _, invalid in { progress(-1, 0, 0), progress(0, math.huge, 0), progress(0/0, 0, 0),
        progress(0, 1.5, 0), { Version = 99, Points = 0, Coins = 0, Trophies = 0 }, "invalid" } do
        memory:UpdateAsync("bad", function() return invalid end)
        local result, why = store:load("bad", "server-A")
        assert(not result and why == "InvalidData", "Corrupt/unknown data replaced with defaults")
        assert(memory:UpdateAsync("bad", function(old) assert(old == invalid); return old end) == invalid)
    end
    assert(not store:save("new", "server-C", progress(0, -1, 0), false))
    print("PERSISTENCE_PASS: corrupt data and unsupported versions remain untouched")

    local calls = 0
    local flaky = { UpdateAsync = function(_, key, transform)
        calls += 1
        if calls < 3 then error("simulated outage") end
        return memory:UpdateAsync(key, transform)
    end }
    local retryStore = ProfileStore.new(flaky, Config, function() return time end, function() end)
    assert(retryStore:load("retry", "server-A") and calls == 3, "Bounded retry failed")
    local unavailable = ProfileStore.new({ UpdateAsync = function() error("offline") end }, Config,
        function() return time end, function() end)
    local missing, why = unavailable:load("new", "server-X")
    assert(not missing and why == "Unavailable", "Failed load returned a playable default profile")
    assert(not unavailable:save("new", "server-X", progress(0, 0, 0), true))
    print("PERSISTENCE_PASS: transient retry and outage refusal")

    local ambiguousCalls = 0
    local ambiguous = ProfileStore.new({ UpdateAsync = function(_, key, transform)
        local result = memory:UpdateAsync(key, transform)
        ambiguousCalls += 1
        if ambiguousCalls == 1 then error("committed but response lost") end
        return result
    end }, Config, function() return time end, function() end)
    assert(ambiguous:load("ambiguous", "same-token"), "Load retry couldn't recognize its own lease")
    assert(ambiguous:save("ambiguous", "same-token", progress(20, 30, 2), false))
    local saved = memory:UpdateAsync("ambiguous", function(old) return old end)
    assert(saved.Points == 20 and saved.Coins == 30 and saved.Trophies == 2, "Retry duplicated rewards")
    print("PERSISTENCE_PASS: lost-response retries are idempotent")
end
