local Config = require(game.ReplicatedStorage.Shared.ObbyConfig)
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local S = require(script.Parent.Parent.World.Scenery)
local Parts = require(script.Parent.Parent.Smash.Parts)
return function(world)
    local model = Instance.new("Model")
    model.Name = "YellowBeltObby"
    model.Parent = world
    for index, node in Config.Nodes do
        local platform = S.part(model, "Stage" .. index, node.Size, node.Position,
            node.Safe and Theme.Gold or Theme.Red, Enum.Material.WoodPlanks, true)
        if node.Label then Parts.label(platform, node.Label) end
    end
    for index = 1, 3 do
        S.part(model, "EntryStep", Vector3.new(9, index, 2), Vector3.new(0, index / 2 + 0.5, -25 - index * 2), Theme.Wood, Enum.Material.WoodPlanks, true)
    end
    S.part(model, "SoftLanding", Vector3.new(32, 1, 64), Vector3.new(0, -0.5, -57), Theme.Grass, Enum.Material.Grass, true)
    S.sign(model, "CourseSign", Vector3.new(0, 9, -29), Vector3.new(12, 2, 0.3), "SENSEI'S BALANCE TRIAL", Theme.Navy)
    return model
end
