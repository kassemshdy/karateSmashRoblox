local player = game:GetService("Players").LocalPlayer
local shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(shared:WaitForChild("UpgradeConfig"))
local Theme = require(shared:WaitForChild("Theme"))
local UI = require(script.Parent:WaitForChild("Presentation"):WaitForChild("UI"))
local gui = Instance.new("ScreenGui")
gui.Name = "KarateUpgrades"
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
local open = button(gui, "Open", "UPGRADES", UDim2.fromOffset(124, 44), UDim2.new(0, 12, 0.5, 28))
local panel = UI.panel(gui, "Collection", UDim2.fromOffset(380, 360), UDim2.fromScale(0.5, 0.5))
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Visible = false
UI.text(panel, "Title", "TRAINING", UDim2.fromOffset(16, 12), UDim2.new(1, -80, 0, 32), 20, Theme.Gold, true)
local close = button(panel, "Close", "X", UDim2.fromOffset(44, 44), UDim2.new(1, -52, 0, 6))
local list = Instance.new("ScrollingFrame")
list.Name = "List"
list.Position = UDim2.fromOffset(12, 58)
list.Size = UDim2.new(1, -24, 1, -70)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.fromOffset(0, 245)
list.Parent = panel
local remote = game.ReplicatedStorage:WaitForChild("KarateUpgrades")
local stats = player:WaitForChild("leaderstats")
local coins = stats:WaitForChild("Coins")
local rows, buys = {}, {}
local message = UI.text(list, "Message", "", UDim2.fromOffset(6, 194), UDim2.new(1, -18, 0, 45), 13, Theme.Gold, false)
message.TextWrapped = true
for index, id in Config.Order do
    rows[id] = UI.text(list, id, "", UDim2.fromOffset(6, (index - 1) * 94), UDim2.new(1, -18, 0, 38), 14, Theme.White, false)
    buys[id] = button(list, "Buy" .. id, "", UDim2.new(1, -18, 0, 44), UDim2.fromOffset(6, (index - 1) * 94 + 40))
    buys[id].Activated:Connect(function()
        remote:FireServer(id, player:GetAttribute("Upgrade_" .. id) or 0)
    end)
end
local function refresh()
    for _, id in Config.Order do
        local level = player:GetAttribute("Upgrade_" .. id) or 0
        local capped = level >= Config.MaxLevel
        rows[id].Text = string.format("%s • Level %d/%d • +%d damage", Config.Types[id].Name, level, Config.MaxLevel, level * Config.Types[id].Bonus)
        buys[id].Text = capped and "MAX LEVEL" or string.format("BUY • %d coins (+%d damage)", Config.cost(level), Config.Types[id].Bonus)
        buys[id].Interactable = not capped and coins.Value >= Config.cost(level) and player:GetAttribute("DataReady") == true
        buys[id].TextTransparency = buys[id].Interactable and 0 or 0.5
    end
end
remote.OnClientEvent:Connect(function(_, text) message.Text = text end)
open.Activated:Connect(function()
    panel.Visible = not panel.Visible
    local medals = player.PlayerGui:FindFirstChild("KarateMedals")
    if panel.Visible and medals then medals.Collection.Visible = false end
end)
close.Activated:Connect(function() panel.Visible = false end)
for _, id in Config.Order do player:GetAttributeChangedSignal("Upgrade_" .. id):Connect(refresh) end
player:GetAttributeChangedSignal("DataReady"):Connect(refresh)
coins.Changed:Connect(refresh)
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
