local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage").Shared.SmashConfig)
local Parts = require(script.Parent.Parts)
local Bases = {}
local records = {}
local slots = {}
local walkways = {}

function Bases.addTrophy(player)
    local record = records[player]
    if not record then return false end
    record.count += 1
    player:SetAttribute("Trophies", record.count)
    player:SetAttribute("CoinsPerTick", record.count * Config.CoinsPerTrophy)
    record.label.Text = player.DisplayName .. "'s Base\n" .. record.count .. " trophies"
    record.trophy.Transparency = 0
    return true
end

function Bases.start(world)
    local function add(player)
        if records[player] then return end
        local slot = 1
        while slots[slot] do slot += 1 end
        slots[slot] = player
        local position = Vector3.new((slot - 1) * 18, 0, 48)
        local model = Instance.new("Model")
        model.Name = "Base_" .. player.UserId
        model:SetAttribute("OwnerUserId", player.UserId)
        model.Parent = world
        -- The shared path survives departure so later bases remain reachable.
        if not walkways[slot] then
            walkways[slot] = Parts.make(world, "BaseWalkway" .. slot, Vector3.new(18, 1, 12), position + Vector3.new(0, 0, -12), Color3.fromRGB(110, 120, 130))
        end
        local floor = Parts.make(model, "Base", Vector3.new(16, 1, 16), position, Color3.fromRGB(70, 130, 180))
        local trophy = Parts.make(model, "TrophyDisplay", Vector3.new(2, 3, 2), position + Vector3.new(0, 2, 0), Color3.fromRGB(255, 210, 70))
        trophy.Transparency = 1
        trophy.CanCollide = false
        local label = Parts.label(floor, player.DisplayName .. "'s Base\nCollect a wall trophy!")
        records[player] = { model = model, label = label, trophy = trophy, count = 0, slot = slot }
        player:SetAttribute("Trophies", 0)
        player:SetAttribute("CoinsPerTick", 0)
        player:SetAttribute("BasePosition", position)
    end
    Players.PlayerAdded:Connect(add)
    Players.PlayerRemoving:Connect(function(player)
        local record = records[player]
        if record then
            slots[record.slot] = nil
            record.model:Destroy()
            records[player] = nil
        end
    end)
    for _, player in Players:GetPlayers() do add(player) end
    task.spawn(function()
        while world.Parent do
            task.wait(Config.CoinInterval)
            for player, record in pairs(records) do
                local stats = player:FindFirstChild("leaderstats")
                local coins = stats and stats:FindFirstChild("Coins")
                if coins then coins.Value += record.count * Config.CoinsPerTrophy end
            end
        end
    end)
end

return Bases
