local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local Pose = require(script.Parent.CombatPose)
local Effects = {}
local function effectPart(position, size, color)
    local part = Instance.new("Part")
    part.Name = "KarateVisualEffect"
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Size = size
    part.Position = position
    part.Color = color
    part.Parent = workspace
    Debris:AddItem(part, 1)
    return part
end
function Effects.play(player, action, result)
    local character = player and player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Pose.play(character, action)
    local strike = effectPart(root.Position, Vector3.new(0.6, 0.6, 1.7), action == "Kick" and Theme.Cyan or Theme.Gold)
    strike.CFrame = root.CFrame * CFrame.new(0.7, action == "Kick" and -0.9 or 0.4, -2)
    strike.Material = Enum.Material.Neon
    strike.Shape = Enum.PartType.Ball
    TweenService:Create(strike, TweenInfo.new(0.22), { CFrame = strike.CFrame * CFrame.new(0, 0, -3), Transparency = 1 }):Play()
    if not result then return end
    local burst = effectPart(result.Position, Vector3.new(0.5, 0.5, 0.5), Theme.Gold)
    burst.Shape = Enum.PartType.Ball
    burst.Material = Enum.Material.Neon
    local size = result.Broken and 5 or 2
    TweenService:Create(burst, TweenInfo.new(0.25), { Size = Vector3.new(size, size, size), Transparency = 1 }):Play()
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(150, 60)
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0, 2, 0)
    gui.Parent = burst
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextColor3 = result.Broken and Theme.Gold or Theme.White
    text.TextStrokeTransparency = 0.2
    text.TextSize = result.Broken and 24 or 30
    text.Text = result.Broken and (result.TargetType == "Dummy" and "GREAT FORM!" or "SMASH!") or ("−" .. result.Damage)
    text.Parent = gui
    TweenService:Create(gui, TweenInfo.new(0.7), { StudsOffset = Vector3.new(0, 4, 0) }):Play()
    TweenService:Create(text, TweenInfo.new(0.7), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
    if result.Broken and result.TargetType ~= "Dummy" then
        for index = 1, 10 do
            local angle = index * math.pi * 2 / 10
            local chip = effectPart(result.Position, Vector3.new(0.7, 0.45, 0.5), Color3.fromRGB(194, 85, 57))
            local offset = Vector3.new(math.cos(angle) * 4, 2 + index % 3, math.sin(angle) * 3)
            TweenService:Create(chip, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = CFrame.new(result.Position + offset) * CFrame.Angles(angle, angle, 0) }):Play()
            task.delay(0.22, function()
                if chip.Parent then
                    TweenService:Create(chip, TweenInfo.new(0.45), { Position = chip.Position - Vector3.new(0, 5, 0), Transparency = 1 }):Play()
                end
            end)
        end
    end
end
return Effects
