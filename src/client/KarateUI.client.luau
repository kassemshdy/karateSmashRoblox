local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local BeltConfig = require(ReplicatedStorage.Shared.BeltConfig)
local SmashConfig = require(ReplicatedStorage.Shared.SmashConfig)

local gui = Instance.new("ScreenGui")
gui.Name = "KarateHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Status"
frame.Size = UDim2.fromOffset(260, 164)
frame.Position = UDim2.fromOffset(12, 12)
frame.BackgroundColor3 = Color3.fromRGB(22, 30, 48)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local function label(name, y, height, size, color)
    local text = Instance.new("TextLabel")
    text.Name = name
    text.Position = UDim2.fromOffset(12, y)
    text.Size = UDim2.new(1, -24, 0, height)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamMedium
    text.TextSize = size
    text.TextColor3 = color
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextWrapped = true
    text.Parent = frame
    return text
end
local title = label("Title", 10, 24, 18, Color3.fromRGB(255, 213, 85))
title.Font = Enum.Font.GothamBold
title.Text = "KARATE SMASH"
local status = label("Progress", 38, 66, 14, Color3.fromRGB(245, 248, 255))
local hint = label("Hint", 110, 44, 12, Color3.fromRGB(183, 202, 225))

local stats = player:WaitForChild("leaderstats")
local points = stats:WaitForChild("KaratePoints")
local belt = player:WaitForChild("Belt")
local coins = stats:WaitForChild("Coins")

local function refresh()
    local nextBelt = BeltConfig.getNextBelt(points.Value)
    local progress = nextBelt and string.format("Next: %s at %d points", nextBelt.name, nextBelt.points) or "Black Belt achieved!"
    status.Text = string.format("%s Belt  •  %d points\n%s\n%d coins  •  +%d every %ds", belt.Value, points.Value, progress, coins.Value, player:GetAttribute("CoinsPerTick") or 0, SmashConfig.CoinInterval)
    local controls = UserInputService.TouchEnabled and "Tap Punch / Kick while facing a wall." or "Click / F: Punch   •   Q: Kick"
    local trophies = player:GetAttribute("Trophies") or 0
    hint.Text = controls .. "\n" .. (trophies == 0 and "Break → Collect → Earn coins at your base" or string.format("%d trophies • Your base is outside the dojo", trophies))
end
points:GetPropertyChangedSignal("Value"):Connect(refresh)
belt:GetPropertyChangedSignal("Value"):Connect(refresh)
coins:GetPropertyChangedSignal("Value"):Connect(refresh)
player:GetAttributeChangedSignal("Trophies"):Connect(refresh)
player:GetAttributeChangedSignal("CoinsPerTick"):Connect(refresh)
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(refresh)
refresh()
