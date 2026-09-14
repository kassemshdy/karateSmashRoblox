local player = game:GetService("Players").LocalPlayer
local shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(shared:WaitForChild("MedalConfig"))
local Theme = require(shared:WaitForChild("Theme"))
local UI = require(script.Parent:WaitForChild("Presentation"):WaitForChild("UI"))
local gui = Instance.new("ScreenGui")
gui.Name = "KarateMedals"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")
local function button(parent, name, text, size, position)
    local result = Instance.new("TextButton")
    result.Name, result.Text, result.Size, result.Position = name, text, size, position
    result.BackgroundColor3 = Theme.Navy
    result.TextColor3 = Theme.Gold
    result.Font = Enum.Font.GothamBold
    result.TextSize = 14
    result.Parent = parent
    Instance.new("UICorner", result).CornerRadius = UDim.new(0, 10)
    return result
end
local open = button(gui, "Open", "MEDALS 0/4", UDim2.fromOffset(124, 44), UDim2.new(0, 12, 0.5, -22))
local panel = UI.panel(gui, "Collection", UDim2.fromOffset(380, 360), UDim2.fromScale(0.5, 0.5))
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Visible = false
UI.text(panel, "Title", "YOUR MEDALS", UDim2.fromOffset(16, 12), UDim2.new(1, -80, 0, 32), 20, Theme.Gold, true)
local close = button(panel, "Close", "X", UDim2.fromOffset(44, 44), UDim2.new(1, -52, 0, 6))
local list = Instance.new("ScrollingFrame")
list.Name = "List"
list.Position = UDim2.fromOffset(12, 58)
list.Size = UDim2.new(1, -24, 1, -70)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.fromOffset(0, #Config * 70)
list.Parent = panel
local rows = {}
for index, medal in Config do
    local label = UI.text(list, medal.Id, "", UDim2.fromOffset(6, (index - 1) * 70), UDim2.new(1, -18, 0, 64), 14, Theme.White, false)
    label.TextWrapped = true
    rows[medal.Id] = label
end
local function refresh()
    open.Text = string.format("MEDALS %d/%d", player:GetAttribute("MedalsEarned") or 0, #Config)
    for _, medal in Config do
        local value = player:GetAttribute("Medal_" .. medal.Id) or 0
        local earned = value >= medal.Goal
        rows[medal.Id].Text = (earned and "EARNED • " or "LOCKED • ") .. medal.Name
            .. "\n" .. medal.Description .. string.format("  %d/%d", value, medal.Goal)
        rows[medal.Id].TextColor3 = earned and Theme.Gold or Theme.White
    end
end
open.Activated:Connect(function()
    panel.Visible = not panel.Visible
    local upgrades = player.PlayerGui:FindFirstChild("KarateUpgrades")
    if panel.Visible and upgrades then upgrades.Collection.Visible = false end
end)
close.Activated:Connect(function() panel.Visible = false end)
for _, medal in Config do player:GetAttributeChangedSignal("Medal_" .. medal.Id):Connect(refresh) end
player:GetAttributeChangedSignal("MedalsEarned"):Connect(refresh)
local viewportConnection
local function resize()
    local camera = workspace.CurrentCamera
    if camera then
        panel.Size = UDim2.fromOffset(math.min(380, math.max(180, camera.ViewportSize.X - 24)), math.min(360, math.max(160, camera.ViewportSize.Y - 24)))
    end
end
local function cameraChanged()
    if viewportConnection then viewportConnection:Disconnect() end
    if workspace.CurrentCamera then viewportConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
    resize()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cameraChanged)
cameraChanged()
refresh()
