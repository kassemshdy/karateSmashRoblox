local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Audio = require(script.Parent:WaitForChild("Presentation"):WaitForChild("Audio"))
local BeltConfig = require(ReplicatedStorage.Shared.BeltConfig)
local ranks = {}
for index, belt in BeltConfig.Belts do ranks[belt.name] = index end
ReplicatedStorage:WaitForChild("KarateSmash"):WaitForChild("Feedback").OnClientEvent:Connect(function(userId, action, result)
    -- Only server-confirmed local strikes produce audio; other players stay quiet.
    if userId == player.UserId then Audio.strike(action, result) end
end)
while not player:GetAttribute("DataReady") do task.wait(0.1) end
local belt = player:WaitForChild("Belt")
local previousBelt = ranks[belt.Value] or 1
local previousTrophies = player:GetAttribute("Trophies") or 0
belt.Changed:Connect(function(value)
    local rank = ranks[value] or 1
    if rank > previousBelt then Audio.belt() end
    previousBelt = rank
end)
player:GetAttributeChangedSignal("Trophies"):Connect(function()
    local count = player:GetAttribute("Trophies") or 0
    if count > previousTrophies then Audio.play("Collect") end
    previousTrophies = count
end)

local previousCarry = player:GetAttribute("CarryingSpecies")
player:GetAttributeChangedSignal("CarryingSpecies"):Connect(function()
    local id = player:GetAttribute("CarryingSpecies")
    if id and id ~= previousCarry then Audio.play("Collect") end
    previousCarry = id
end)
