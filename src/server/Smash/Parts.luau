local Parts = {}

function Parts.make(parent, name, size, position, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.Size = size
    part.Position = position
    part.Color = color
    part.Parent = parent
    return part
end

function Parts.label(part, text)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(190, 48)
    gui.MaxDistance = 55
    gui.StudsOffset = Vector3.new(0, part.Size.Y / 2 + 2, 0)
    gui.AlwaysOnTop = false
    gui.Parent = part
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.5
    label.BackgroundColor3 = Color3.fromRGB(18, 32, 58)
    label.BackgroundTransparency = 0.15
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = text
    label.Parent = gui
    return label
end

function Parts.root(player)
    if not player:GetAttribute("DataReady") then return nil end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
        return root
    end
    return nil
end

return Parts
