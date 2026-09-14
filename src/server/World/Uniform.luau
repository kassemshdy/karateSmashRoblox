local Theme = require(game.ReplicatedStorage.Shared.Theme)
local Uniform = {}
local function piece(model, body, name, size, offset, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Color = color
    part.Material = Enum.Material.Fabric
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    part.CFrame = body.CFrame * offset
    part.Parent = model
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = body
    weld.Part1 = part
    weld.Parent = part
    return part
end
function Uniform.dress(character, beltName)
    if character:FindFirstChild("KarateUniform") then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local waist = character:FindFirstChild("LowerTorso") or torso
    if not torso or not waist then return end
    local model = Instance.new("Model")
    model.Name = "KarateUniform"
    model.Parent = character
    for _, name in { "UpperTorso", "LowerTorso", "Torso", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg", "Right Arm", "Left Arm", "Right Leg", "Left Leg" } do
        local body = character:FindFirstChild(name)
        if body and body:IsA("BasePart") then
            piece(model, body, "Gi", body.Size + Vector3.new(0.08, 0.05, 0.08), CFrame.new(), Theme.White)
        end
    end
    for _, side in { -1, 1 } do
        piece(model, torso, "Lapel", Vector3.new(0.18, torso.Size.Y * 0.75, 0.08), CFrame.new(side * 0.25, 0.25, -torso.Size.Z / 2 - 0.08) * CFrame.Angles(0, 0, math.rad(side * 25)), Theme.Navy)
    end
    local color = Theme.Belts[beltName] or Theme.White
    piece(model, waist, "Belt", Vector3.new(waist.Size.X + 0.15, 0.28, waist.Size.Z + 0.15), CFrame.new(0, -waist.Size.Y * 0.2, 0), color)
    for _, side in { -1, 1 } do
        piece(model, waist, "Belt", Vector3.new(0.22, 0.7, 0.12), CFrame.new(side * 0.16, -waist.Size.Y * 0.2 - 0.35, -waist.Size.Z / 2 - 0.15) * CFrame.Angles(0, 0, math.rad(side * 15)), color)
    end
end
function Uniform.color(character, beltName)
    local model = character and character:FindFirstChild("KarateUniform")
    if not model then return end
    for _, part in model:GetChildren() do
        if part.Name == "Belt" then part.Color = Theme.Belts[beltName] or Theme.White end
    end
end
return Uniform
