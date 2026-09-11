local Players = game:GetService("Players")

local function setupPlayer(player)
    if player:FindFirstChild("leaderstats") then return end
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local karatePoints = Instance.new("IntValue")
    karatePoints.Name = "KaratePoints"
    karatePoints.Value = 0
    karatePoints.Parent = leaderstats

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = leaderstats

    local belt = Instance.new("StringValue")
    belt.Name = "Belt"
    belt.Value = "White"
    belt.Parent = player
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end
