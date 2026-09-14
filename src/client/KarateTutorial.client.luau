local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage.Shared.TutorialConfig)
local Theme = require(ReplicatedStorage.Shared.Theme)
local UI = require(script.Parent:WaitForChild("Presentation"):WaitForChild("UI"))
local gui = Instance.new("ScreenGui")
gui.Name = "SenseiGuide"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")
local panel = UI.panel(gui, "Dialogue", UDim2.fromOffset(380, 260), UDim2.fromScale(0.5, 0.5))
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Visible = false
UI.text(panel, "Sensei", "SENSEI'S GUIDE", UDim2.fromOffset(16, 12), UDim2.new(1, -32, 0, 22), 16, Theme.Gold, true)
local title = UI.text(panel, "Title", "", UDim2.fromOffset(16, 43), UDim2.new(1, -32, 0, 25), 18, Theme.White, true)
title.TextScaled = true
local body = UI.text(panel, "Instruction", "", UDim2.fromOffset(16, 76), UDim2.new(1, -32, 0, 115), 15, Theme.White)
body.TextWrapped = true
body.TextYAlignment = Enum.TextYAlignment.Top
local close = Instance.new("TextButton")
close.Name = "Continue"
close.Text = "LET'S PRACTICE"
close.Size = UDim2.new(1, -32, 0, 44)
close.Position = UDim2.new(0, 16, 1, -56)
close.BackgroundColor3 = Theme.Red
close.TextColor3 = Theme.White
close.Font = Enum.Font.GothamBold
close.TextSize = 15
close.Parent = panel
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = close
close.Activated:Connect(function() panel.Visible = false end)
local function refresh()
    local stage = player:GetAttribute("TutorialStage")
    local step = stage and Config.Steps[stage]
    if not step then return end
    title.Text = step.Title
    body.Text = step.Text
end
local function layout()
    local camera = workspace.CurrentCamera
    if camera then panel.Size = UDim2.fromOffset(math.min(380, camera.ViewportSize.X - 24), 260) end
end
local cameraConnection
local function watchCamera()
    if cameraConnection then cameraConnection:Disconnect() end
    if workspace.CurrentCamera then cameraConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout) end
    layout()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
watchCamera()
local welcomed = false
local function progressChanged()
    refresh()
    if not welcomed and player:GetAttribute("TutorialStage") then
        welcomed = true
        panel.Visible = player:GetAttribute("TutorialStage") == 1
    end
end
player:GetAttributeChangedSignal("TutorialStage"):Connect(progressChanged)
progressChanged()
ReplicatedStorage:WaitForChild("KarateTutorial").OnClientEvent:Connect(function()
    refresh()
    panel.Visible = true
end)
