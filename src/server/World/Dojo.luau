local S = require(script.Parent.Scenery)
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local Dojo = {}
function Dojo.decorate(world)
    local decor = Instance.new("Folder")
    decor.Name = "CourtyardScenery"
    decor.Parent = world
    S.part(decor, "GardenGround", Vector3.new(220, 2, 190), Vector3.new(25, -1.5, 10), Theme.Grass, Enum.Material.Grass, true)
    for _, x in { -25, 0, 25 } do
        S.part(decor, "TrainingMatBorder", Vector3.new(16, 0.12, 13), Vector3.new(x, 0.57, 0), Theme.Navy)
        S.part(decor, "TrainingMat", Vector3.new(15.3, 0.14, 12.3), Vector3.new(x, 0.59, 0), Color3.fromRGB(140, 171, 152), Enum.Material.Fabric)
    end
    for z = 12, 26, 4 do
        S.part(decor, "EntryPaver", Vector3.new(10, 0.12, 3.5), Vector3.new(0, 0.6, z), Theme.Cream, Enum.Material.Slate)
    end
    S.torii(decor, Vector3.new(0, 0.5, 28), 24, 14)
    S.sign(decor, "EntranceSign", Vector3.new(0, 12.5, 29.2), Vector3.new(15, 2, 0.35), "KARATE SMASH", Theme.Red)
    S.roof(decor, Vector3.new(0, 22, -23), 88, 28)
    for _, x in { -38, -22, 22, 38 } do
        S.part(decor, "DojoBeam", Vector3.new(1.3, 18, 1.5), Vector3.new(x, 9, -14.1), Theme.Red, Enum.Material.Wood)
    end
    for _, x in { -40, 40 } do
        for z = -26, 26, 13 do
            S.part(decor, "FenceColumn", Vector3.new(1.7, 17, 1.7), Vector3.new(x, 8.5, z), Theme.Wood)
        end
        S.part(decor, "FenceTop", Vector3.new(2, 0.6, 62), Vector3.new(x, 16.3, 0), Theme.Roof)
        for z = -20, 20, 10 do
            S.part(decor, "WallPanel", Vector3.new(0.12, 6, 7.5), Vector3.new(x * 0.984, 9, z), Theme.Cream)
        end
    end
    for _, pos in { Vector3.new(-48, 0, 25), Vector3.new(48, 0, 25), Vector3.new(-50, 0, -23), Vector3.new(51, 0, -28), Vector3.new(-20, 0, 53), Vector3.new(0, 0, 70), Vector3.new(30, 0, 72), Vector3.new(63, 0, 67) } do
        S.tree(decor, pos, pos.X < 0)
    end
    for _, x in { -17, 17 } do
        S.lantern(decor, Vector3.new(x, 0, 25))
    end
    for _, x in { -60, -25, 20, 65 } do
        local mountain = S.part(decor, "DistantMountain", Vector3.new(44, 65 + math.abs(x) / 2, 35), Vector3.new(x, 16, -125), Color3.fromRGB(115, 156, 172), Enum.Material.Slate)
        mountain.Shape = Enum.PartType.Ball
    end
end
return Dojo
