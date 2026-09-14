local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UI = require(script.Parent:WaitForChild("Presentation"):WaitForChild("UI"))
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local gui = Instance.new("ScreenGui")
gui.Name = "ObbyGuide"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local panel = UI.panel(gui, "Status", UDim2.fromOffset(340, 50), UDim2.new(0.5, 0, 1, -68))
panel.AnchorPoint = Vector2.new(0.5, 0)
local text = UI.text(panel, "Message", "", UDim2.fromOffset(10, 5), UDim2.new(1, -20, 1, -10), 14, Theme.Gold, true)
text.TextWrapped = true
panel.Visible = false
-- Sample locally only to choose which UI to show; rewards never depend on it.
task.spawn(function()
    while gui.Parent do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local nearby = root and root.Position.Z < -18 and math.abs(root.Position.X) < 20
        panel.Visible = nearby == true
        local camera = workspace.CurrentCamera
        if camera then panel.Size = UDim2.fromOffset(math.min(340, camera.ViewportSize.X - 24), 50) end
        text.Text = player:GetAttribute("ObbyStatus") or "Walk through the doorway to begin the balance trial"
        local hud = player.PlayerGui:FindFirstChild("KarateHUD")
        local objective = hud and hud:FindFirstChild("Objective")
        if objective and camera then
            objective.Visible = not nearby and camera.ViewportSize.X >= 500 and camera.ViewportSize.Y >= 420
        end
        task.wait(0.2)
    end
end)
