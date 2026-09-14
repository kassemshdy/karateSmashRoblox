local player = game:GetService("Players").LocalPlayer
local Catalog = require(game.ReplicatedStorage.Shared.CreatureCatalog)
local UI = require(script.Parent:WaitForChild("Presentation"):WaitForChild("UI"))
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local gui = Instance.new("ScreenGui")
gui.Name = "CreatureGuide"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2
gui.Parent = player:WaitForChild("PlayerGui")
local panel = UI.panel(gui, "Carrying", UDim2.fromOffset(340, 62), UDim2.new(0.5, 0, 1, -78))
panel.AnchorPoint = Vector2.new(0.5, 0)
local text = UI.text(panel, "Instruction", "", UDim2.fromOffset(10, 5), UDim2.new(1, -20, 1, -10), 13, Theme.Gold, true)
text.TextWrapped = true
local function refresh()
    local id = player:GetAttribute("CarryingSpecies")
    local species = id and Catalog.Species[id]
    panel.Visible = species ~= nil
    if species then
        text.Text = "CARRYING " .. species.Rarity:upper() .. " " .. species.Name:upper()
            .. "\nTake it to the " .. species.Name .. " pedestal at your base."
    end
    if workspace.CurrentCamera then panel.Size = UDim2.fromOffset(math.min(340, workspace.CurrentCamera.ViewportSize.X - 24), 62) end
end
player:GetAttributeChangedSignal("CarryingSpecies"):Connect(refresh)
-- This panel fits the safe screen width even when the device rotates.
local connection
local function camera()
    if connection then connection:Disconnect() end
    if workspace.CurrentCamera then connection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh) end
    refresh()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(camera)
camera()
