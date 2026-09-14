local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local BeltConfig = require(ReplicatedStorage.Shared.BeltConfig)
local SmashConfig = require(ReplicatedStorage.Shared.SmashConfig)
local Theme = require(ReplicatedStorage.Shared.Theme)
local UI = require(script.Parent:WaitForChild("Presentation"):WaitForChild("UI"))
local gui = Instance.new("ScreenGui")
gui.Name = "KarateHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
-- This HUD replaces the default leaderboard with readable personal progress.
pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)
-- Start with chat collapsed so the progress card is readable; players can
-- still open chat using Roblox's normal chat button.
task.spawn(function()
    for _ = 1, 20 do
        if pcall(function() game:GetService("StarterGui"):SetCore("ChatActive", false) end) then return end
        task.wait(0.25)
    end
end)
local card = UI.panel(gui, "ProgressCard", UDim2.fromOffset(258, 175), UDim2.fromOffset(12, 12))
UI.text(card, "Brand", "KARATE", UDim2.fromOffset(14, 8), UDim2.fromOffset(140, 30), 27, Theme.White, true)
UI.text(card, "Smash", "SMASH", UDim2.fromOffset(139, 8), UDim2.fromOffset(106, 30), 27, Theme.Red, true)
local beltText = UI.text(card, "Belt", "LOADING…", UDim2.fromOffset(14, 47), UDim2.fromOffset(228, 24), 19, Theme.Gold, true)
local pointsText = UI.text(card, "Points", "Your karate journey starts here", UDim2.fromOffset(14, 76), UDim2.fromOffset(228, 19), 13, Theme.Muted)
local track = UI.panel(card, "BeltProgress", UDim2.fromOffset(230, 9), UDim2.fromOffset(14, 104))
track.BackgroundColor3 = Color3.fromRGB(49, 65, 89)
local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.fromScale(0, 1)
fill.BorderSizePixel = 0
fill.BackgroundColor3 = Theme.Gold
fill.Parent = track
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = fill
local nextText = UI.text(card, "NextBelt", "Practice makes progress", UDim2.fromOffset(14, 120), UDim2.fromOffset(228, 18), 12, Theme.Muted)
local saveText = UI.text(card, "SaveStatus", "Loading progress…", UDim2.fromOffset(14, 148), UDim2.fromOffset(228, 16), 11, Theme.Muted)
local wallet = UI.panel(gui, "Wallet", UDim2.fromOffset(208, 110), UDim2.new(1, -220, 0, 12))
UI.text(wallet, "Caption", "YOUR DOJO EARNINGS", UDim2.fromOffset(14, 10), UDim2.fromOffset(180, 16), 11, Theme.Muted, true)
local coinsText = UI.text(wallet, "Coins", "0 COINS", UDim2.fromOffset(14, 30), UDim2.fromOffset(180, 30), 25, Theme.Gold, true)
local incomeText = UI.text(wallet, "Income", "+0 every 5s", UDim2.fromOffset(14, 65), UDim2.fromOffset(180, 17), 13, Theme.White)
local trophiesText = UI.text(wallet, "Trophies", "0 trophies at your base", UDim2.fromOffset(14, 86), UDim2.fromOffset(180, 16), 11, Theme.Muted)
local mission = UI.panel(gui, "Objective", UDim2.fromOffset(345, 55), UDim2.new(0.5, -172, 1, -68))
UI.text(mission, "Heading", "TRAIN  →  SMASH  →  COLLECT", UDim2.fromOffset(14, 8), UDim2.fromOffset(318, 20), 14, Theme.Gold, true)
local hint = UI.text(mission, "Hint", "Face a brick wall • Click / F to punch • Q to kick", UDim2.fromOffset(14, 32), UDim2.fromOffset(318, 16), 11, Theme.White)
local cardScale = Instance.new("UIScale")
cardScale.Parent = card
local walletScale = Instance.new("UIScale")
walletScale.Parent = wallet
local function layout()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local portrait = viewport.X < 500
    local short = viewport.Y < 420
    local scale = short and 0.75 or (portrait and 0.85 or 1)
    cardScale.Scale = scale
    walletScale.Scale = scale
    wallet.Position = portrait and UDim2.fromOffset(12, 20 + 175 * scale)
        or UDim2.new(1, -12 - 208 * scale, 0, 12)
    wallet.Size = UDim2.fromOffset(208, 110)
    incomeText.Visible = true
    trophiesText.Visible = true
    mission.Visible = not portrait and not short
    hint.Text = UserInputService.TouchEnabled and "Face a wall and tap Punch or Kick. Collect the gold drop!" or "Face a brick wall • Click / F to punch • Q to kick"
end
local cameraConnection
local function watchCamera()
    if cameraConnection then cameraConnection:Disconnect() end
    if workspace.CurrentCamera then cameraConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout) end
    layout()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(layout)
watchCamera()
local function saving() saveText.Text = player:GetAttribute("SaveStatus") or "Loading progress…" end
player:GetAttributeChangedSignal("SaveStatus"):Connect(saving)
saving()
local stats = player:WaitForChild("leaderstats")
local points = stats:WaitForChild("KaratePoints")
local coins = stats:WaitForChild("Coins")
local belt = player:WaitForChild("Belt")
local function refresh()
    local nextBelt = BeltConfig.getNextBelt(points.Value)
    local currentThreshold = 0
    for _, item in BeltConfig.Belts do
        if points.Value >= item.points then currentThreshold = item.points end
    end
    local ratio = nextBelt and (points.Value - currentThreshold) / (nextBelt.points - currentThreshold) or 1
    beltText.Text = belt.Value:upper() .. " BELT"
    beltText.TextColor3 = Theme.Belts[belt.Value] == Theme.Belts.Black and Theme.White or (Theme.Belts[belt.Value] or Theme.White)
    pointsText.Text = string.format("%d KARATE POINTS", points.Value)
    nextText.Text = nextBelt and string.format("%d points to %s Belt", nextBelt.points - points.Value, nextBelt.name) or "BLACK BELT • KEEP TRAINING!"
    TweenService:Create(fill, TweenInfo.new(0.25), { Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1) }):Play()
    coinsText.Text = tostring(coins.Value) .. " COINS"
    incomeText.Text = string.format("+%d coins every %ds", player:GetAttribute("CoinsPerTick") or 0, SmashConfig.CoinInterval)
    trophiesText.Text = string.format("%d trophies at your base", player:GetAttribute("Trophies") or 0)
end
points.Changed:Connect(refresh)
coins.Changed:Connect(refresh)
belt.Changed:Connect(refresh)
player:GetAttributeChangedSignal("Trophies"):Connect(refresh)
player:GetAttributeChangedSignal("CoinsPerTick"):Connect(refresh)
refresh()
