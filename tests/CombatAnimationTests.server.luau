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
    eventually(function() return #Players:GetPlayers() == 2 and ready[Players:GetPlayers()[1]] and ready[Players:GetPlayers()[2]] end, 120, "Two clients required")
    for _, player in Players:GetPlayers() do command(player, "Animation") end
    pass("punch/kick both joint types and live arm/leg rotation on two players")
end
local ok, message = xpcall(run, debug.traceback)
if not ok then warn("PHASE1_TEST_FAILED: " .. message) end

local studioTests = game:GetService("StudioTestService")
if studioTests:GetTestArgs() == "KaratePhase1" then
    studioTests:EndTest(ok and "PHASE1_ALL_TESTS_PASSED" or ("PHASE1_TEST_FAILED: " .. tostring(message)))
end
