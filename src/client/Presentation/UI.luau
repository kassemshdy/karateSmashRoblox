local Theme = require(game.ReplicatedStorage.Shared.Theme)
local UI = {}
function UI.panel(parent, name, size, position)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Theme.Navy
    frame.BackgroundTransparency = 0.06
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(81, 107, 137)
    stroke.Transparency = 0.3
    stroke.Thickness = 1.5
    stroke.Parent = frame
    return frame
end
function UI.text(parent, name, text, position, size, fontSize, color, bold)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Text = text
    label.Position = position
    label.Size = size
    label.BackgroundTransparency = 1
    label.Font = bold and Enum.Font.GothamBlack or Enum.Font.GothamMedium
    label.TextSize = fontSize
    label.TextColor3 = color or Theme.White
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end
return UI
