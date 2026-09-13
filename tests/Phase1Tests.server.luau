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
    eventually(function() return replies[player] and replies[player][1] == id end, 10, "Client did not respond: " .. name)
    assert(replies[player][2], replies[player][3])
    task.wait(0.3)
end
local function pass(message) print("PHASE1_PASS: " .. message) end

local function run()
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
    local drop = world:FindFirstChild("TrophyDrop")
    assert(drop and drop:GetAttribute("OwnerUserId") == second.UserId)
    command(first, "Collect", drop)
    assert(drop.Parent and first:GetAttribute("Trophies") == 0, "Other player stole drop")
    command(second, "Collect", drop)
    assert(not drop.Parent and second:GetAttribute("Trophies") == 1, "Owner collection failed")
    pass("owner-only prompt collection updates only the owner's base")
    local extra = Drops.spawn(world, Vector3.new(25, 2.5, 2), second)
    task.wait(0.3)
    command(second, "Collect", extra)
    assert(second:GetAttribute("Trophies") == 1, "Distant collection succeeded")
    place(second, Vector3.new(25, 4, 7))
    local blocker = Instance.new("Part")
    blocker.Anchored = true
    blocker.Size = Vector3.new(5, 8, 1)
    blocker.Position = Vector3.new(25, 4, 4)
    blocker.Parent = world
    task.wait(0.3)
    command(second, "Collect", extra)
    assert(second:GetAttribute("Trophies") == 1, "Collection through wall succeeded")
    blocker:Destroy()
    task.wait(0.3)
    command(second, "Collect", extra)
    assert(second:GetAttribute("Trophies") == 2 and second:GetAttribute("CoinsPerTick") == 2)
    local coins = second.leaderstats.Coins.Value
    task.wait(Config.CoinInterval + 0.2)
    assert(second.leaderstats.Coins.Value >= coins + 2 and first.leaderstats.Coins.Value == 0, "Passive income incorrect")
    pass("distance/obstruction collection checks and isolated passive income")
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
    place(second, Vector3.new(25, 4, 2))
    second.Character.Humanoid.Health = 0
    command(second, "Attack", "Kick")
    assert(world.SmashWall3:GetAttribute("HP") == Config.WallHP, "Dead player attacked")
    second:LoadCharacterAsync()
    task.wait(1)
    assert((second.Character:GetPivot().Position - world.KarateSpawn.Position).Magnitude < 10, "Respawn outside dojo")
    assert(second:GetAttribute("Trophies") == 2, "Death reset collection")
    pass("dead attack rejected; respawn retains base and trophies")
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
