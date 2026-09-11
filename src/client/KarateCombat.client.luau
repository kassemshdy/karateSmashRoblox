local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local Config = require(ReplicatedStorage.Shared.SmashConfig)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("KarateSmash")
local attackEvent = remotes:WaitForChild("Attack")
local feedback = remotes:WaitForChild("Feedback")
local nextAttack = 0

local function attack(name, state)
    if UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
    if state == Enum.UserInputState.Begin and os.clock() >= nextAttack then
        nextAttack = os.clock() + Config.Attacks[name].Cooldown
        attackEvent:FireServer(name)
    end
    return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("Punch", attack, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.F)
ContextActionService:BindAction("Kick", attack, true, Enum.KeyCode.Q)
ContextActionService:SetTitle("Punch", "Punch")
ContextActionService:SetTitle("Kick", "Kick")
ContextActionService:SetPosition("Punch", UDim2.new(1, -160, 1, -190))
ContextActionService:SetPosition("Kick", UDim2.new(1, -80, 1, -250))

-- Lightweight strike visuals work with both R6 and R15, without animation assets.
feedback.OnClientEvent:Connect(function(name, result)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local strike = Instance.new("Part")
    strike.Name = "KarateStrikeEffect"
    strike.Shape = Enum.PartType.Ball
    strike.Size = name == "Kick" and Vector3.new(1.4, 1.4, 2.4) or Vector3.new(1, 1, 1)
    strike.Anchored = true
    strike.CanCollide = false
    strike.CanTouch = false
    strike.CanQuery = false
    strike.Material = Enum.Material.Neon
    strike.Color = name == "Kick" and Color3.fromRGB(100, 190, 255) or Color3.fromRGB(255, 215, 80)
    strike.CFrame = root.CFrame * CFrame.new(0.8, name == "Kick" and -1.2 or 0.5, -2)
    strike.Parent = workspace
    TweenService:Create(strike, TweenInfo.new(0.2), {
        CFrame = strike.CFrame * CFrame.new(0, 0, -3), Transparency = 1,
    }):Play()
    Debris:AddItem(strike, 0.25)
    if result then
        local burst = strike:Clone()
        burst.Position = result.Position
        burst.Size = Vector3.new(1, 1, 1)
        burst.Transparency = 0.2
        burst.Parent = workspace
        local size = result.Broken and 7 or 3
        TweenService:Create(burst, TweenInfo.new(0.35), {
            Size = Vector3.new(size, size, size), Transparency = 1,
        }):Play()
        Debris:AddItem(burst, 0.4)
    end
end)
