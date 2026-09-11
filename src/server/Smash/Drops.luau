local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Config = require(game:GetService("ReplicatedStorage").Shared.SmashConfig)
local Parts = require(script.Parent.Parts)
local Bases = require(script.Parent.Bases)
local Drops = {}

function Drops.spawn(world, position, owner)
    local drop = Parts.make(world, "TrophyDrop", Vector3.new(2, 2, 2), position, Color3.fromRGB(255, 210, 70))
    drop.CanCollide = false
    drop.CanQuery = false
    drop.CanTouch = false
    drop.Material = Enum.Material.Neon
    drop:SetAttribute("OwnerUserId", owner.UserId)
    Parts.label(drop, owner.DisplayName .. "'s trophy\nCollect to earn passive coins")
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Collect"
    prompt.ObjectText = "Karate Trophy"
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
        if Bases.addTrophy(player) then drop:Destroy() else claimed = false end
    end)
    Debris:AddItem(drop, Config.DropLifetime)
    return drop
end

return Drops
