local S = require(script.Parent.Parent.World.Scenery)
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local Parts = require(script.Parent.Parent.Smash.Parts)
local Config = require(game.ReplicatedStorage.Shared.TutorialConfig)
return function(world)
    local model = Instance.new("Model")
    model.Name = "Sensei"
    model.Parent = world
    local origin = Vector3.new(-8, 0.5, 20)
    local function piece(name, size, offset, color)
        return S.part(model, name, size, origin + offset, color)
    end
    piece("Robe", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0), Theme.White)
    for _, side in { -1, 1 } do
        piece("Sleeve", Vector3.new(0.8, 1.8, 0.9), Vector3.new(side * 1.45, 3, 0), Theme.White)
        piece("Leg", Vector3.new(0.85, 2, 0.9), Vector3.new(side * 0.5, 1, 0), Theme.White)
    end
    piece("BlackBelt", Vector3.new(2.15, 0.3, 1.15), Vector3.new(0, 2.25, 0), Theme.Navy)
    local head = piece("Head", Vector3.new(1.4, 1.4, 1.4), Vector3.new(0, 4.7, 0), Color3.fromRGB(245, 203, 155))
    head.Shape = Enum.PartType.Ball
    piece("Headband", Vector3.new(1.45, 0.25, 1.45), Vector3.new(0, 5.05, 0), Theme.Red)
    for _, side in { -1, 1 } do
        piece("Eye", Vector3.new(0.12, 0.16, 0.08), Vector3.new(side * 0.28, 4.8, 0.68), Theme.Navy)
    end
    piece("Beard", Vector3.new(0.65, 0.55, 0.15), Vector3.new(0, 4.25, 0.65), Theme.White)
    Parts.label(head, "SENSEI\nLearn the dojo")
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Talk"
    prompt.ActionText = "Talk"
    prompt.ObjectText = "Sensei"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = Config.TalkDistance
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = true
    prompt.Parent = head
    return model, head, prompt
end
