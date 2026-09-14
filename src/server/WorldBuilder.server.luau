local CollectionService = game:GetService("CollectionService")
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local S = require(script.Parent.World.Scenery)
local Parts = require(script.Parent.Smash.Parts)
local world = workspace:FindFirstChild("JawadKarateWorld")
if world then world:Destroy() end
world = Instance.new("Folder")
world.Name = "JawadKarateWorld"
world.Parent = workspace
local function solid(name, size, pos, color, material)
    return S.part(world, name, size, pos, color, material, true)
end
solid("DojoFloor", Vector3.new(80, 1, 60), Vector3.new(0, 0, 0), Theme.Stone, Enum.Material.Slate)
solid("BackWall", Vector3.new(80, 16, 1), Vector3.new(0, 8, -30), Theme.Cream)
solid("LeftWall", Vector3.new(1, 16, 60), Vector3.new(-40, 8, 0), Theme.Stone)
solid("RightWall", Vector3.new(1, 16, 60), Vector3.new(40, 8, 0), Theme.Stone)
local spawn = Instance.new("SpawnLocation")
spawn.Name = "KarateSpawn"
spawn.Size = Vector3.new(6, 1, 6)
spawn.Position = Vector3.new(0, 1, 22)
spawn.Anchored = true
spawn.Neutral = true
spawn.Transparency = 1
spawn.CanCollide = false
spawn.Duration = 0
spawn.Parent = world

local function training(name, x, reward, color)
    local pad = solid(name, Vector3.new(3, 6, 2), Vector3.new(x, 3.5, 4), color, Enum.Material.Fabric)
    pad.CanTouch = true
    pad:SetAttribute("PointsReward", reward)
    pad:SetAttribute("Cooldown", 1)
    CollectionService:AddTag(pad, "KarateTrainingPad")
    local marker = S.part(pad, "Target", Vector3.new(0.12, 1.8, 1.8), pad.Position + Vector3.new(0, 0.6, 1.06), Theme.Gold)
    marker.Shape = Enum.PartType.Cylinder
    marker.CFrame = CFrame.new(marker.Position) * CFrame.Angles(0, math.rad(90), 0)
    Parts.label(pad, name:upper() .. "\nTRAIN  +" .. reward .. " POINTS")
end
training("Punch Pad", -14, 1, Theme.Red)
training("Kick Pad", 14, 2, Theme.Navy)
local gate = solid("YellowBeltGate", Vector3.new(16, 12, 1), Vector3.new(0, 6, -15), Theme.Gold, Enum.Material.Wood)
gate.CanTouch = true
gate:SetAttribute("RequiredPoints", 20)
for _, x in { -24, 24 } do
    solid(x < 0 and "GateLeftWing" or "GateRightWing", Vector3.new(32, 16, 1), Vector3.new(x, 8, -15), Theme.Cream)
    for offset = -12, 12, 4 do
        S.part(world, "TimberSlat", Vector3.new(0.25, 12, 0.2), Vector3.new(x + offset, 8, -14.4), Theme.Wood)
    end
end
solid("GateLintel", Vector3.new(16, 4, 1), Vector3.new(0, 14, -15), Theme.Red)
S.sign(world, "GateTitle", Vector3.new(0, 14, -14.3), Vector3.new(15, 2.4, 0.2), "YELLOW BELT • 20 POINTS", Theme.Red)
for _, x in { -7.5, 0, 7.5 } do
    S.part(gate, "GateTrim", Vector3.new(0.3, 12, 0.2), Vector3.new(x, 6, -14.4), Theme.Wood)
end
solid("SenseiPlatform", Vector3.new(16, 1, 10), Vector3.new(0, 1, -23), Theme.Wood, Enum.Material.WoodPlanks)
require(script.Parent.World.Dojo).decorate(world)
-- Published last: other systems use this name as the world-ready marker.
S.sign(world, "DojoSign", Vector3.new(0, 19, -8.5), Vector3.new(27, 3.5, 0.6), "JAWAD'S DOJO", Theme.Navy)
print("Karate Smash courtyard generated")
