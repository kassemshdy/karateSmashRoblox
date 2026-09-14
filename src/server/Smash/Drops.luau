local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Config = require(game:GetService("ReplicatedStorage").Shared.SmashConfig)
local Parts = require(script.Parent.Parts)
local Profiles = require(script.Parent.Parent.Data.Profiles)
local Catalog = require(game.ReplicatedStorage.Shared.CreatureCatalog)
local Visuals = require(script.Parent.Parent.World.CreatureVisuals)
local random = Random.new()
local Drops = {}

function Drops.spawn(world, position, owner, speciesId)
    speciesId = speciesId or Catalog.roll(random)
    local species = assert(Catalog.Species[speciesId], "Unknown creature")
    local drop = Parts.make(world, "CreatureDrop", Vector3.new(2, 2, 2), position, Color3.fromRGB(255, 210, 70))
    drop.CanCollide = false
    drop.CanQuery = false
    drop.CanTouch = false
    drop.Transparency = 1
    drop:SetAttribute("SpeciesId", speciesId)
    drop:SetAttribute("Rarity", species.Rarity)
    Visuals.create(drop, speciesId, CFrame.new(position) * CFrame.Angles(0, math.pi, 0))
    drop:SetAttribute("OwnerUserId", owner.UserId)
    Parts.label(drop, species.Rarity .. " " .. species.Name .. "\n" .. owner.DisplayName .. " • Carry home")
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Collect"
    prompt.ObjectText = species.Name
    prompt.MaxActivationDistance = Config.CollectRange
    prompt.RequiresLineOfSight = true
    prompt.Parent = drop
    local claimed = false
    local expires = os.clock() + Config.DropLifetime
    local connection
    connection = Players.PlayerRemoving:Connect(function(player)
        if player == owner then drop:Destroy() end
    end)
    drop.Destroying:Connect(function() connection:Disconnect() end)
    prompt.Triggered:Connect(function(player)
        local root = Parts.root(player)
        if claimed or os.clock() >= expires or player ~= owner or not root then return end
        if (root.Position - drop.Position).Magnitude > Config.CollectRange then return end
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = { player.Character }
        params.FilterType = Enum.RaycastFilterType.Exclude
        local hit = workspace:Raycast(root.Position, drop.Position - root.Position, params)
        if hit and hit.Instance ~= drop then return end
        claimed = true
        if Profiles.tryCarry(player, speciesId) then drop:Destroy() else claimed = false end
    end)
    Debris:AddItem(drop, Config.DropLifetime)
    return drop
end

return Drops
