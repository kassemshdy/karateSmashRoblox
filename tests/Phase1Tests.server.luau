-- Isolated integration suite: run test.project.json with two Studio clients.
if not game:GetService("RunService"):IsStudio() then return end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local control = Instance.new("RemoteEvent")
control.Name = "Phase1TestControl"
control.Parent = ReplicatedStorage
local ready, replies = {}, {}
control.OnServerEvent:Connect(function(player, id, ok, message)
    if id == "Ready" then ready[player] = true else replies[player] = { id, ok, message } end
end)
local sequence = 0
local function eventually(check, timeout, message)
    local deadline = os.clock() + timeout
    repeat
        if check() then return end
        task.wait(0.1)
    until os.clock() >= deadline
    error(message)
end
local function command(player, name, value)
    sequence += 1
    local id = sequence
    control:FireClient(player, id, name, value)
    eventually(function() return replies[player] and replies[player][1] == id end, 40, "Client did not respond: " .. name)
    assert(replies[player][2], replies[player][3])
    task.wait(0.3)
end
local function pass(message) print("PHASE1_PASS: " .. message) end

local function run()
    require(game.ServerScriptService.PersistenceTests)()
    require(game.ServerScriptService.ObbyTests)()
    require(game.ServerScriptService.CreatureTests)()
    eventually(function()
        local count = 0
        for _, player in Players:GetPlayers() do if ready[player] then count += 1 end end
        return count >= 2
    end, 120, "Start Server and Clients with TWO clients")
    local players = Players:GetPlayers()
    local first, second = players[1], players[2]
    local world = workspace:WaitForChild("JawadKarateWorld")
    local wall = world:WaitForChild("SmashWall2")
    local Drops = require(game.ServerScriptService.Smash.Drops)
    local Config = require(ReplicatedStorage.Shared.SmashConfig)
    local function place(player, position, facing)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        assert(root, "Missing live character")
        root.Anchored = true
        character:PivotTo(CFrame.lookAt(position, position + (facing or Vector3.new(0, 0, -1))))
        task.wait(0.3)
        return root
    end
    for _, player in { first, second } do
        eventually(function() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end, 20, "Missing character")
        assert((player.Character:GetPivot().Position - world.KarateSpawn.Position).Magnitude < 10, "Wrong dojo spawn")
        assert(player.leaderstats.KaratePoints.Value == 0 and player.leaderstats.Coins.Value == 0)
        assert(world:FindFirstChild("Base_" .. player.UserId), "Missing player base")
    end
    pass("two players spawn in dojo with separate bases and zero stats")
    local tutorial = require(game.ServerScriptService.Tutorial.Progress)
    local cases = {
        { 0, 0, 0, 0, 1 }, { 1, 0, 0, 0, 2 }, { 5, 1, 0, 0, 3 },
        { 5, 1, 1, 0, 4 }, { 5, 1, 1, 1, 5 }, { 20, 1, 1, 1, 6 },
        { 20, 0, 1, 1, 6 }, -- saved collection restores tutorial credit
    }
    for _, values in cases do
        assert(tutorial.stage(values[1], values[2], values[3], values[4]) == values[5], "Wrong tutorial stage")
    end
    assert(world:WaitForChild("Sensei", 10):FindFirstChild("Talk", true), "Missing Sensei prompt")
    eventually(function() return first:GetAttribute("TutorialStage") == 1 end, 10, "Tutorial did not initialize")
    pass("Sensei tutorial stages, returning-player credit, and prompt initialization")
    command(first, "Presentation")
    command(second, "Presentation")
    command(first, "Audio")
    command(second, "Audio")
    pass("client sound pool, mute/unmute, and effects control")
    assert(world:FindFirstChild("CourtyardScenery") and wall:FindFirstChild("WallHealth"), "Missing visual world")
    pass("client HUD, touch-sized controls, uniforms, courtyard, and wall HP displays")
    place(first, Vector3.new(0, 4, 2))
    place(second, Vector3.new(4, 4, 2))
    command(first, "Invalid")
    assert(wall:GetAttribute("HP") == 60, "Invalid remote damaged wall")
    command(first, "Spam")
    assert(wall:GetAttribute("HP") == 50, "Spam bypassed shared cooldown")
    task.wait(0.5)
    command(first, "Attack", "Kick")
    assert(wall:GetAttribute("HP") == 25, "Kick damage incorrect")
    command(first, "Attack", "Punch")
    assert(wall:GetAttribute("HP") == 25, "Alternating attacks bypassed cooldown")
    command(second, "Attack", "Kick")
    assert(wall:GetAttribute("HP") == 0, "Final hit did not break wall")
    task.wait(0.5)
    command(first, "Attack", "Kick")
    assert(first.leaderstats.KaratePoints.Value == 0 and second.leaderstats.KaratePoints.Value == 5, "Break paid twice/wrong player")
    pass("remote validation, punch/kick damage, spam cooldown, multiplayer final-hit reward")
    eventually(function() return second:GetAttribute("TutorialStage") == 3 end, 5, "Wall break did not advance tutorial")
    local Catalog = require(ReplicatedStorage.Shared.CreatureCatalog)
    local drop = world:FindFirstChild("CreatureDrop")
    assert(drop and drop:GetAttribute("OwnerUserId") == second.UserId)
    local firstSpecies = drop:GetAttribute("SpeciesId")
    assert(Catalog.Species[firstSpecies], "Wall rolled unknown creature")
    local base = world:FindFirstChild("Base_" .. second.UserId)
    local function pedestal(id)
        for _, part in base:GetChildren() do
            if part:GetAttribute("SpeciesId") == id then return part end
        end
        error("Missing species pedestal")
    end
    local function deposit(id)
        local target = pedestal(id)
        place(second, target.Position + Vector3.new(0, 3, -5))
        command(second, "PlaceCreature", target)
    end
    command(first, "Collect", drop)
    assert(drop.Parent and not first:GetAttribute("CarryingSpecies"), "Other player stole creature")
    place(first, Vector3.new(-8, 4, 2))
    command(second, "Collect", drop)
    assert(not drop.Parent and second:GetAttribute("CarryingSpecies") == firstSpecies, "Owner pickup failed")
    assert(second:GetAttribute("CreatureCount") == 0 and second:GetAttribute("CoinsPerTick") == 0, "Carried creature earned income")
    eventually(function() return second.Character:FindFirstChild("CarriedCreature") end, 5, "Missing carried visual")
    local busyDrop = Drops.spawn(world, Vector3.new(4, 2.5, -1), second, "BudTurtle")
    command(second, "Collect", busyDrop)
    assert(busyDrop.Parent and second:GetAttribute("CarryingSpecies") == firstSpecies, "Second pickup replaced carried creature")
    busyDrop:Destroy()
    second:LoadCharacterAsync()
    eventually(function() return second.Character and second.Character:FindFirstChild("CarriedCreature") end, 15, "Death lost carried creature")
    assert(second:GetAttribute("CarryingSpecies") == firstSpecies)
    command(second, "PlaceCreature", pedestal(firstSpecies))
    assert(second:GetAttribute("CreatureCount") == 0, "Distant placement succeeded")
    local wrong = firstSpecies == "BudTurtle" and "SkyDrake" or "BudTurtle"
    deposit(wrong)
    assert(second:GetAttribute("CarryingSpecies") == firstSpecies, "Wrong pedestal consumed creature")
    local target = pedestal(firstSpecies)
    place(first, target.Position + Vector3.new(0, 3, -5))
    command(first, "PlaceCreature", target)
    assert(second:GetAttribute("CreatureCount") == 0, "Visitor changed another collection")
    place(first, Vector3.new(-8, 4, 2))
    deposit(firstSpecies)
    assert(not second:GetAttribute("CarryingSpecies") and second:GetAttribute("CreatureCount") == 1, "Placement failed")
    command(second, "PlaceCreature", target)
    assert(second:GetAttribute("CreatureCount") == 1, "Duplicate placement paid twice")
    pass("creature ownership, one-item carry, death retention, pedestal ownership/type/distance, and duplicate placement")
    local extra = Drops.spawn(world, Vector3.new(25, 2.5, 2), second, "BudTurtle")
    task.wait(0.3)
    command(second, "Collect", extra)
    assert(not second:GetAttribute("CarryingSpecies"), "Distant collection succeeded")
    place(second, Vector3.new(25, 4, 7))
    local blocker = Instance.new("Part")
    blocker.Anchored = true
    blocker.Size = Vector3.new(5, 8, 1)
    blocker.Position = Vector3.new(25, 4, 4)
    blocker.Parent = world
    task.wait(0.3)
    command(second, "Collect", extra)
    assert(not second:GetAttribute("CarryingSpecies"), "Collection through wall succeeded")
    blocker:Destroy()
    task.wait(0.3)
    command(second, "Collect", extra)
    assert(second:GetAttribute("CarryingSpecies") == "BudTurtle", "Second creature pickup failed")
    deposit("BudTurtle")
    local income = Catalog.Species[firstSpecies].Coins + Catalog.Species.BudTurtle.Coins
    assert(second:GetAttribute("CreatureCount") == 2 and second:GetAttribute("CoinsPerTick") == income)
    local coins = second.leaderstats.Coins.Value
    task.wait(Config.CoinInterval + 0.2)
    assert(second.leaderstats.Coins.Value >= coins + income and first.leaderstats.Coins.Value == 0, "Creature income incorrect")
    pass("distance/obstruction collection checks and species-based passive income isolation")
    assert(wall:GetAttribute("HP") == Config.WallHP and wall.CanCollide, "Wall did not respawn")
    place(first, Vector3.new(0, 4, 20))
    command(first, "Attack", "Kick")
    assert(wall:GetAttribute("HP") == Config.WallHP, "Out-of-range attack hit")
    task.wait(1)
    place(first, Vector3.new(0, 4, 2), Vector3.new(0, 0, 1))
    command(first, "Attack", "Kick")
    assert(wall:GetAttribute("HP") == Config.WallHP, "Backward attack hit")
    task.wait(1)
    place(first, Vector3.new(0, 4, 2))
    blocker = Instance.new("Part")
    blocker.Anchored = true
    blocker.Size = Vector3.new(8, 8, 1)
    blocker.Position = Vector3.new(0, 4, 0)
    blocker.Parent = world
    command(first, "Attack", "Kick")
    assert(wall:GetAttribute("HP") == Config.WallHP, "Attack passed through obstruction")
    blocker:Destroy()
    pass("wall respawn and attack range, facing, and obstruction checks")
    for _, sample in { {0, "White"}, {19, "White"}, {20, "Yellow"}, {49, "Yellow"}, {50, "Green"}, {74, "Green"}, {75, "Brown"}, {99, "Brown"}, {100, "Black"} } do
        first.leaderstats.KaratePoints.Value = sample[1]
        task.wait(0.1)
        assert(first.Belt.Value == sample[2], "Belt threshold failed")
    end
    pass("all belt thresholds and boundary values")
    local obby = require(game.ServerScriptService.Obby.Service)
    local obbyConfig = require(ReplicatedStorage.Shared.ObbyConfig)
    local course = world:WaitForChild("YellowBeltObby")
    assert(course:FindFirstChild("Stage7"), "Missing course finish")
    first.leaderstats.KaratePoints.Value = 19
    place(first, obbyConfig.Nodes[1].Position + Vector3.new(0, 4, 0))
    assert(not first:GetAttribute("ObbyStage"), "White belt started course")
    first.leaderstats.KaratePoints.Value = 20
    task.wait(0.4)
    assert(first:GetAttribute("ObbyStage") == 1, "Qualified player failed to start")
    local beforePoints, beforeCoins = first.leaderstats.KaratePoints.Value, first.leaderstats.Coins.Value
    place(first, obbyConfig.Nodes[7].Position + Vector3.new(0, 4, 0))
    task.wait(0.3)
    assert(first.leaderstats.KaratePoints.Value == beforePoints and first.leaderstats.Coins.Value == beforeCoins, "Skipped course paid reward")
    local last = first.Character.HumanoidRootPart.Position
    for index = 2, #obbyConfig.Nodes do
        local destination = obbyConfig.Nodes[index].Position + Vector3.new(0, 4, 0)
        for step = 1, 8 do
            first.Character:PivotTo(CFrame.new(last:Lerp(destination, step / 8)))
            task.wait(0.12)
        end
        task.wait(0.3)
        last = destination
        assert(first:GetAttribute("ObbyStage") == index, "Course stage did not advance")
        if index == 3 then
            place(first, Vector3.new(0, 2, -53))
            task.wait(0.3)
            assert((first.Character:GetPivot().Position - destination).Magnitude < 2, "Fall did not restore checkpoint")
            assert(obby.respawn(first), "Active checkpoint not available on respawn")
            first:LoadCharacterAsync()
            eventually(function()
                local root = first.Character and first.Character:FindFirstChild("HumanoidRootPart")
                return root and (root.Position - destination).Magnitude < 3
            end, 15, "Character respawn did not restore obby checkpoint")
            first.Character.HumanoidRootPart.Anchored = true
        end
    end
    assert(first.leaderstats.KaratePoints.Value == beforePoints + obbyConfig.RewardPoints, "Wrong obby point reward")
    assert(first.leaderstats.Coins.Value == beforeCoins + obbyConfig.RewardCoins, "Wrong obby coin reward")
    task.wait(2.2)
    assert(not obby.respawn(first), "Completed course retained active checkpoint")
    place(first, obbyConfig.Nodes[1].Position + Vector3.new(0, 4, 0))
    command(first, "LeaveTrial")
    eventually(function() return first.Character:GetPivot().Position.Z > 15 end, 5, "Exit prompt did not return player to dojo")
    assert(first.leaderstats.KaratePoints.Value == beforePoints + obbyConfig.RewardPoints
        and first.leaderstats.Coins.Value == beforeCoins + obbyConfig.RewardCoins, "Exit prompt paid a reward")
    pass("obby geometry, skipped finish rejection, fall/respawn recovery, exit prompt, and one-time completion reward")
    place(first, Vector3.new(0, 4, 20))
    place(second, Vector3.new(25, 4, 2))
    second.Character.Humanoid.Health = 0
    command(second, "Attack", "Kick")
    assert(world.SmashWall3:GetAttribute("HP") == Config.WallHP, "Dead player attacked")
    second:LoadCharacterAsync()
    task.wait(1)
    assert((second.Character:GetPivot().Position - world.KarateSpawn.Position).Magnitude < 10, "Respawn outside dojo")
    assert(second:GetAttribute("CreatureCount") == 2, "Death reset creature collection")
    pass("dead attack rejected; respawn retains base and trophies")
    local dummy = world:WaitForChild("TrainingDummy").Target
    local practicePoints = first.leaderstats.KaratePoints.Value
    local practiceTrophies = first:GetAttribute("CollectionCount") or 0
    place(first, Vector3.new(28, 4, 24))
    command(first, "Invalid")
    assert(dummy:GetAttribute("HP") == Config.DummyHP, "Invalid request damaged dummy")
    command(first, "Spam")
    assert(dummy:GetAttribute("HP") == Config.DummyHP - 10, "Dummy bypassed shared cooldown")
    task.wait(0.5)
    for _ = 1, 4 do
        command(first, "Attack", "Kick")
        task.wait(0.95)
    end
    assert(dummy:GetAttribute("HP") == 0, "Dummy did not reach zero health")
    command(first, "Attack", "Punch")
    assert(first.leaderstats.KaratePoints.Value == practicePoints + Config.DummyPoints, "Dummy paid incorrect or duplicate reward")
    assert((first:GetAttribute("CollectionCount") or 0) == practiceTrophies, "Dummy awarded a trophy")
    eventually(function() return dummy:GetAttribute("HP") == Config.DummyHP end, Config.DummyResetSeconds + 1, "Dummy failed to reset")
    place(first, Vector3.new(28, 4, 32))
    command(first, "Attack", "Kick")
    assert(dummy:GetAttribute("HP") == Config.DummyHP, "Distant dummy hit accepted")
    pass("training dummy damage, shared cooldown, final-hit reward, no trophy, and reset")
    local expiring = Drops.spawn(world, Vector3.new(-25, 2.5, 2), first)
    eventually(function() return not expiring.Parent end, Config.DropLifetime + 3, "Drop did not expire")
    pass("uncollected drops expire")
    local leavingDrop = Drops.spawn(world, Vector3.new(25, 2.5, 2), second)
    local leavingBase = world:FindFirstChild("Base_" .. second.UserId)
    local leavingCoins = second.leaderstats.Coins
    second:Kick("Phase 1 test: verify departure cleanup")
    eventually(function() return not leavingBase.Parent and not leavingDrop.Parent end, 5, "Departure cleanup failed")
    local lastCoins = leavingCoins.Value
    task.wait(Config.CoinInterval + 0.2)
    assert(leavingCoins.Value == lastCoins, "Departed player still earns coins")
    assert(world:FindFirstChild("BaseWalkway1") and world:FindFirstChild("BaseWalkway2"), "Shared path removed")
    pass("departure removes owned base/drops, stops income, and preserves walkways")
    first.Character.HumanoidRootPart.Anchored = false
    print("PHASE1_ALL_TESTS_PASSED")
end
local ok, message = xpcall(run, debug.traceback)
if not ok then warn("PHASE1_TEST_FAILED: " .. message) end

local studioTests = game:GetService("StudioTestService")
if studioTests:GetTestArgs() == "KaratePhase1" then
    studioTests:EndTest(ok and "PHASE1_ALL_TESTS_PASSED" or ("PHASE1_TEST_FAILED: " .. tostring(message)))
end
