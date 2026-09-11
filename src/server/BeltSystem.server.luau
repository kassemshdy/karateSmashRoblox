local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BeltConfig = require(ReplicatedStorage.Shared.BeltConfig)

local function watchPlayer(player)
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
