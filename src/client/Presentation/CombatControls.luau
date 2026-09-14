local UserInputService = game:GetService("UserInputService")
local Theme = require(game.ReplicatedStorage.Shared.Theme)
return function(player, attack)
    local gui = Instance.new("ScreenGui")
    gui.Name = "KarateControls"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    local group = Instance.new("Frame")
    group.Name = "Actions"
    group.Size = UDim2.fromOffset(184, 72)
    group.AnchorPoint = Vector2.new(1, 1)
    group.Position = UDim2.new(1, -18, 1, -145)
    group.BackgroundTransparency = 1
    group.Parent = gui
    for index, name in { "Punch", "Kick" } do
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.fromOffset(86, 72)
        button.Position = UDim2.fromOffset((index - 1) * 98, 0)
        button.BackgroundColor3 = index == 1 and Theme.Red or Theme.Navy
        button.TextColor3 = Theme.White
        button.Font = Enum.Font.GothamBlack
        button.TextSize = 17
        button.Text = name:upper()
        button.Parent = group
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 14)
        corner.Parent = button
        local stroke = Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = index == 1 and Theme.Gold or Theme.Cyan
        stroke.Thickness = 2
        stroke.Parent = button
        button.Activated:Connect(function() attack(name) end)
    end
    -- Reserve space below the actions for Roblox's mobile jump control.
    -- Use less vertical space on landscape phones without shrinking hit targets.
    local function layout()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local bottom = camera.ViewportSize.Y < 420 and 110 or 145
        group.Position = UDim2.new(1, -18, 1, -bottom)
    end
    local cameraConnection
    local function watchCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        if workspace.CurrentCamera then
            cameraConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
        end
        layout()
    end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
    watchCamera()
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.F then
            attack("Punch")
        elseif input.KeyCode == Enum.KeyCode.Q then
            attack("Kick")
        end
    end)
end
