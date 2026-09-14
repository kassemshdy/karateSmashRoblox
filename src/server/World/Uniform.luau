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
    if name == "Gi" then
        -- Avatar package meshes can protrude through the plain fabric shell.
        body.Transparency = 1
        part:SetAttribute("BodyPart", body.Name)
    end
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = body
    weld.Part1 = part
    weld.Parent = part
    return part
end
function Uniform.removeClothing(item)
    if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
        item:Destroy()
    elseif item:IsA("Accessory") then
        local kind = item.AccessoryType.Name
        if item:FindFirstChildWhichIsA("WrapLayer", true)
            or kind == "Front" or kind == "Back" or kind == "Waist"
            or kind == "Shoulder" or kind == "Neck" then
            item:Destroy()
        end
    end
end
function Uniform.dress(character, beltName)
    -- Appearance can finish loading after CharacterAdded. Clean it on every call.
    for _, item in character:GetChildren() do Uniform.removeClothing(item) end
    local existing = character:FindFirstChild("KarateUniform")
    if existing then
        local changed = false
        for _, garment in existing:GetChildren() do
            local name = garment:GetAttribute("BodyPart")
            local body = name and character:FindFirstChild(name)
            if body then
                body.Transparency = 1
                if garment.Size ~= body.Size + Vector3.new(0.08, 0.05, 0.08) then changed = true end
            end
        end
        if not changed then
            Uniform.color(character, beltName)
            return
        end
        -- Appearance loading may change body scales after the first outfit was built.
        existing:Destroy()
    end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local waist = character:FindFirstChild("LowerTorso") or torso
    if not torso or not waist then return end
    local model = Instance.new("Model")
    model.Name = "KarateUniform"
    model.Parent = character
    for _, name in { "UpperTorso", "LowerTorso", "Torso", "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm", "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg", "Right Arm", "Left Arm", "Right Leg", "Left Leg" } do
        local body = character:FindFirstChild(name)
        if body and body:IsA("BasePart") then
            piece(model, body, "Gi", body.Size + Vector3.new(0.08, 0.05, 0.08), CFrame.new(), Theme.White)
        end
    end
    for _, side in { -1, 1 } do
        piece(model, torso, "Lapel", Vector3.new(0.18, torso.Size.Y * 0.75, 0.08), CFrame.new(side * 0.25, 0.25, -torso.Size.Z / 2 - 0.08) * CFrame.Angles(0, 0, math.rad(side * 25)), Color3.fromRGB(220, 225, 230))
    end
    local color = Theme.Belts[beltName] or Theme.White
    piece(model, waist, "Belt", Vector3.new(waist.Size.X + 0.15, 0.28, waist.Size.Z + 0.15), CFrame.new(0, -waist.Size.Y * 0.2, 0), color)
    piece(model, waist, "Belt", Vector3.new(0.36, 0.32, 0.24), CFrame.new(0, -waist.Size.Y * 0.2, -waist.Size.Z / 2 - 0.2), color)
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
