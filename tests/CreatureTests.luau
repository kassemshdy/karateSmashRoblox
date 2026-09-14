return function()
    local Catalog = require(game.ReplicatedStorage.Shared.CreatureCatalog)
    local ProfileStore = require(game.ServerScriptService.Data.ProfileStore)
    local Memory = require(game.ServerScriptService.Data.MemoryStore)
    for _, case in { {1, "BudTurtle"}, {70, "BudTurtle"}, {71, "SkyDrake"}, {95, "SkyDrake"}, {96, "SunLion"}, {100, "SunLion"} } do
        assert(Catalog.roll({ NextInteger = function(_, low, high)
            assert(low == 1 and high == 100)
            return case[1]
        end }) == case[2], "Rarity boundary incorrect")
    end
    local count, income = Catalog.totals({ BudTurtle = 2, SkyDrake = 1, SunLion = 1 })
    assert(count == 4 and income == 18, "Species income incorrect")
    print("PHASE1_PASS: creature rarity boundaries and income rates")

    local migrated = ProfileStore.decode({ Version = 1, Points = 50, Coins = 80, Trophies = 7 })
    assert(migrated.Version == 2 and migrated.Points == 50 and migrated.Coins == 80 and migrated.Trophies == 7)
    assert(not migrated.Carried and Catalog.totals(migrated.Creatures) == 0, "Legacy migration invented creatures")
    local memory = Memory.new()
    local store = ProfileStore.new(memory, { RetryAttempts = 3, LeaseSeconds = 180 }, function() return 100 end, function() end)
    assert(store:load("creatures", "A"))
    local data = { Version = 2, Points = 25, Coins = 100, Trophies = 7,
        Creatures = { BudTurtle = 2, SkyDrake = 1, SunLion = 1 }, Carried = "SunLion" }
    assert(store:save("creatures", "A", data, true))
    local restored = store:load("creatures", "B")
    assert(restored.Carried == "SunLion" and restored.Creatures.SunLion == 1 and restored.Creatures.BudTurtle == 2 and restored.Trophies == 7, "Creature save/rejoin lost inventory")
    restored.Creatures.SunLion += 1
    restored.Carried = false
    assert(store:save("creatures", "B", restored, true))
    local placed = store:load("creatures", "C")
    assert(placed.Creatures.SunLion == 2 and not placed.Carried, "Placed carry duplicated or returned after rejoin")
    for _, bad in { -1, 0/0, 0.5, Catalog.MaxPerSpecies + 1 } do
        local invalid = table.clone(data)
        invalid.Creatures = table.clone(data.Creatures)
        invalid.Creatures.SunLion = bad
        assert(not ProfileStore.decode(invalid), "Invalid creature count accepted")
    end
    local invalid = table.clone(data)
    invalid.Carried = "UnknownCreature"
    assert(not ProfileStore.decode(invalid))
    invalid = table.clone(data)
    invalid.Creatures = { BudTurtle = 1, SkyDrake = 0, SunLion = 0, UnknownCreature = 1 }
    assert(not ProfileStore.decode(invalid), "Unknown saved species discarded")
    assert(not store:save("creatures", "A", data, false), "Stale session duplicated creatures")
    print("PERSISTENCE_PASS: v1 migration, creature/carry rejoin, corrupt species/count refusal, stale-session safety")
end
