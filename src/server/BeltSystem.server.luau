local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BeltConfig = require(ReplicatedStorage.Shared.BeltConfig)

local function watchPlayer(player)
    while player.Parent == Players and not player:GetAttribute("DataReady") do task.wait(0.1) end
    if player.Parent ~= Players then return end
    local leaderstats = player:WaitForChild("leaderstats")
    local points = leaderstats:WaitForChild("KaratePoints")
    local belt = player:WaitForChild("Belt")

    local function updateBelt()
        belt.Value = BeltConfig.getBeltForPoints(points.Value)
    end

    updateBelt()
    points:GetPropertyChangedSignal("Value"):Connect(updateBelt)
end

Players.PlayerAdded:Connect(watchPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(watchPlayer, player)
end
