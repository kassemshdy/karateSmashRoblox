local Players = game:GetService("Players")

local function setupPlayer(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local karatePoints = Instance.new("IntValue")
    karatePoints.Name = "KaratePoints"
    karatePoints.Value = 0
    karatePoints.Parent = leaderstats

    local belt = Instance.new("StringValue")
    belt.Name = "Belt"
    belt.Value = "White"
    belt.Parent = player
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end
