local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.SmashConfig)
local Catalog = require(game.ReplicatedStorage.Shared.CreatureCatalog)
local Parts = require(script.Parent.Parts)
local Scenery = require(script.Parent.Parent.World.Scenery)
local Visuals = require(script.Parent.Parent.World.CreatureVisuals)
local Profiles = require(script.Parent.Parent.Data.Profiles)
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local Bases = {}
local records, slots, walkways = {}, {}, {}
local function refresh(player, record)
    local counts = Profiles.creatureState(player)
    if not counts then return end
    local count, income = Catalog.totals(counts)
    local legacy = player:GetAttribute("Trophies") or 0
    record.income = income + legacy * Config.CoinsPerTrophy
    player:SetAttribute("CoinsPerTick", record.income)
    record.label.Text = player.DisplayName .. "'s Base\n" .. count .. " creatures • +" .. record.income .. " coins / 5s"
    Scenery.showTrophy(record.trophy, legacy > 0)
    for index, id in Catalog.Order do
        local pedestal = record.pedestals[index]
        local species = Catalog.Species[id]
        local old = pedestal:FindFirstChild(id)
        if counts[id] > 0 and not old then
            Visuals.create(pedestal, id, CFrame.new(pedestal.Position + Vector3.new(0, 1.3, 0)), 0.9)
        end
        record.labels[index].Text = species.Rarity .. " " .. species.Name .. " ×" .. counts[id]
            .. "\n+" .. counts[id] * species.Coins .. " coins / 5s"
    end
end
function Bases.start(world)
    local function add(player)
        while player.Parent == Players and not player:GetAttribute("DataReady") do task.wait(0.1) end
        if player.Parent ~= Players or records[player] then return end
        local slot = 1
        while slots[slot] do slot += 1 end
        slots[slot] = player
        local position = Vector3.new((slot - 1) * 18, 0, 48)
        local model = Instance.new("Model")
        model.Name = "Base_" .. player.UserId
        model:SetAttribute("OwnerUserId", player.UserId)
        model.Parent = world
        if not walkways[slot] then
            walkways[slot] = Parts.make(world, "BaseWalkway" .. slot, Vector3.new(18, 1, 12), position + Vector3.new(0, 0, -12), Color3.fromRGB(110, 120, 130))
        end
        local floor = Parts.make(model, "Base", Vector3.new(16, 1, 16), position, Theme.Cream)
        floor.Material = Enum.Material.WoodPlanks
        local trophy, pedestals = Scenery.base(model, position)
        -- Preserve a separate display for pre-creature saves.
        trophy.Position -= Vector3.new(0, 0, 5)
        for _, part in trophy:GetChildren() do
            if part:IsA("BasePart") then part.Position -= Vector3.new(0, 0, 5) end
        end
        local label = Parts.label(floor, "")
        label.Parent.StudsOffset = Vector3.new(0, 11.5, 0)
        local record = { model = model, label = label, trophy = trophy, pedestals = pedestals, labels = {}, slot = slot, income = 0 }
        records[player] = record
        for index, id in Catalog.Order do
            local pedestal = pedestals[index]
            pedestal:SetAttribute("SpeciesId", id)
            record.labels[index] = Parts.label(pedestal, "")
            record.labels[index].Parent.StudsOffset = Vector3.new(0, 4.5, 0)
            record.labels[index].Parent.Size = UDim2.fromOffset(125, 48)
            record.labels[index].Parent.MaxDistance = 30
            local prompt = Instance.new("ProximityPrompt")
            prompt.Name = "PlaceCreature"
            prompt.ActionText = "Place creature"
            prompt.ObjectText = Catalog.Species[id].Name .. " pedestal"
            prompt.MaxActivationDistance = 10
            prompt.RequiresLineOfSight = true
            prompt.Parent = pedestal
            prompt.Triggered:Connect(function(visitor)
                local root = Parts.root(visitor)
                if visitor ~= player or not root or (root.Position - pedestal.Position).Magnitude > 10 then return end
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = { visitor.Character, model }
                if workspace:Raycast(root.Position, pedestal.Position - root.Position, params) then return end
                if Profiles.placeCarried(player, id) then refresh(player, record) end
            end)
        end
        refresh(player, record)
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
    for _, player in Players:GetPlayers() do task.spawn(add, player) end
    task.spawn(function()
        while world.Parent do
            task.wait(Config.CoinInterval)
            for player, record in records do
                local stats = player:FindFirstChild("leaderstats")
                if stats and player:GetAttribute("DataReady") then stats.Coins.Value += record.income end
            end
        end
    end)
end
return Bases
