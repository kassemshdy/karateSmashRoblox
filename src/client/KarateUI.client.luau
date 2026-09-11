local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local BeltConfig = require(ReplicatedStorage.Shared.BeltConfig)

local gui = Instance.new("ScreenGui")
gui.Name = "KarateHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Status"
frame.Size = UDim2.fromOffset(280, 110)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundTransparency = 0.2
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "JAWAD KARATE 🥋"
title.TextScaled = true
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 54)
status.Position = UDim2.fromOffset(10, 42)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.TextScaled = true
status.Parent = frame

local leaderstats = player:WaitForChild("leaderstats")
local points = leaderstats:WaitForChild("KaratePoints")
local belt = player:WaitForChild("Belt")

local function refresh()
    local nextBelt = BeltConfig.getNextBelt(points.Value)
    local progressText

    if nextBelt then
        progressText = string.format("Next: %s Belt at %d points", nextBelt.name, nextBelt.points)
    else
        progressText = "Black Belt achieved!"
    end

    status.Text = string.format("%s Belt | %d Karate Points\n%s", belt.Value, points.Value, progressText)
end

points:GetPropertyChangedSignal("Value"):Connect(refresh)
belt:GetPropertyChangedSignal("Value"):Connect(refresh)
refresh()
