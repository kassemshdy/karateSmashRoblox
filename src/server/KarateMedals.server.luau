local Players = game:GetService("Players")
local Profiles = require(script.Parent.Data.Profiles)
local Catalog = require(game.ReplicatedStorage.Shared.CreatureCatalog)
local Progress = require(script.Parent.Medals.Progress)
local function add(player)
    while player.Parent == Players and not player:GetAttribute("DataReady") do task.wait(0.1) end
    if player.Parent ~= Players then return end
    local points = player.leaderstats.KaratePoints
    local function update()
        local creatures = Profiles.creatureState(player)
        if not creatures then return end
        local count = Catalog.totals(creatures)
        local values, earned = Progress.evaluate(points.Value, count, creatures.SunLion)
        for id, value in values do player:SetAttribute("Medal_" .. id, value) end
        player:SetAttribute("MedalsEarned", earned)
    end
    local connections = { points.Changed:Connect(update), player:GetAttributeChangedSignal("CreatureCount"):Connect(update) }
    player.AncestryChanged:Once(function()
        for _, connection in connections do connection:Disconnect() end
    end)
    update()
end
Players.PlayerAdded:Connect(add)
for _, player in Players:GetPlayers() do task.spawn(add, player) end
