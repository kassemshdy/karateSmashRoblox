return function()
    local Store = require(game.ServerScriptService.Data.ProfileStore)
    local Memory = require(game.ServerScriptService.Data.MemoryStore)
    local Catalog = require(game.ReplicatedStorage.Shared.CreatureCatalog)
    local config = require(game.ReplicatedStorage.Shared.UpgradeConfig)
    local data = Store.decode({ Version = 2, Points = 75, Coins = 99, Trophies = 2, Creatures = Catalog.empty(), Carried = "SkyDrake" })
    assert(data.Version == 3 and data.Upgrades.Punch == 0 and data.Upgrades.Kick == 0)
    assert(data.Points == 75 and data.Coins == 99 and data.Trophies == 2 and data.Carried == "SkyDrake")
    for _, bad in { -1, 0.5, 0/0, 6, math.huge, "1" } do
        local invalid = table.clone(data)
        invalid.Upgrades = { Punch = bad, Kick = 0 }
        assert(not Store.decode(invalid), "Invalid upgrade accepted")
    end
    for _, bad in { { Punch = 0 }, { Punch = 0, Kick = 0, Unknown = 1 } } do
        local invalid = table.clone(data)
        invalid.Upgrades = bad
        assert(not Store.decode(invalid))
    end
    local store = Store.new(Memory.new(), { RetryAttempts = 3, LeaseSeconds = 180 }, function() return 100 end, function() end)
    assert(store:load("upgrades", "A"))
    data.Upgrades = { Punch = 2, Kick = 5 }
    assert(store:save("upgrades", "A", data, true))
    local loaded = store:load("upgrades", "B")
    assert(loaded.Upgrades.Punch == 2 and loaded.Upgrades.Kick == 5 and loaded.Coins == 99)
    assert(not store:save("upgrades", "A", data, false))
    assert(config.cost(0) == 25 and config.cost(4) == 400)
    print("PERSISTENCE_PASS: upgrade migration, rejoin, corrupt-level rejection, and stale-session protection")
end
