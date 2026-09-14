local Config = require(game.ReplicatedStorage.Shared.SmashConfig)
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local S = require(script.Parent.Parent.World.Scenery)
local Parts = require(script.Parent.Parts)
local Dummy = {}
local body, label, health
local wood = Color3.fromRGB(172, 119, 66)
local function update()
    body:SetAttribute("HP", health)
    label.Text = health > 0 and string.format("TRAINING DUMMY\n%d / %d HP", health, Config.DummyHP)
        or "GREAT PRACTICE!\nResetting…"
    body.Color = health > 0 and wood or Theme.Muted
end
function Dummy.start(world)
    local model = Instance.new("Model")
    model.Name = "TrainingDummy"
    model.Parent = world
    local origin = Vector3.new(28, 0.5, 17)
    S.part(model, "Stand", Vector3.new(6, 0.3, 5), origin, Theme.Navy)
    body = S.part(model, "Target", Vector3.new(3, 5, 2), origin + Vector3.new(0, 2.5, 0), wood, Enum.Material.Wood, true)
    local head = S.part(model, "Head", Vector3.new(2, 2, 2), origin + Vector3.new(0, 6, 0), wood, Enum.Material.Wood)
    head.Shape = Enum.PartType.Ball
    for _, side in { -1, 1 } do
        S.part(model, "PracticeArm", Vector3.new(2, 0.8, 0.8), origin + Vector3.new(side * 2.3, 3, 0), wood, Enum.Material.Wood)
    end
    S.part(model, "Belt", Vector3.new(3.1, 0.35, 2.1), origin + Vector3.new(0, 1.5, 0), Theme.Red)
    local target = S.part(model, "TargetMarker", Vector3.new(1.4, 1.4, 0.1), origin + Vector3.new(0, 3, 1.06), Theme.Gold)
    target.Shape = Enum.PartType.Ball
    health = Config.DummyHP
    body:SetAttribute("MaxHP", health)
    label = Parts.label(body, "")
    label.Parent.StudsOffset = Vector3.new(0, 5, 0)
    update()
end
function Dummy.hit(player, attack, result)
    if not result or result.Instance ~= body or health <= 0 or not Parts.root(player) then return nil end
    local damage = math.min(health, attack.Damage)
    health = math.max(0, health - damage)
    update()
    local defeated = health == 0
    if defeated then
        -- Health reaches zero before paying; simultaneous final hits cannot pay twice.
        player.leaderstats.KaratePoints.Value += Config.DummyPoints
        task.delay(Config.DummyResetSeconds, function()
            if not body.Parent then return end
            health = Config.DummyHP
            update()
        end)
    else
        body.Color = Theme.Gold
        task.delay(0.12, function()
            if body.Parent and health > 0 then body.Color = wood end
        end)
    end
    return { Position = result.Position, Damage = damage, HP = health, Broken = defeated, TargetType = "Dummy" }
end
return Dummy
