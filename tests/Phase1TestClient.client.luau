-- Included only by test.project.json. Never executes in a published server.
if not game:GetService("RunService"):IsStudio() then return end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local control = ReplicatedStorage:WaitForChild("Phase1TestControl")
local attack = ReplicatedStorage:WaitForChild("KarateSmash"):WaitForChild("Attack")
control.OnClientEvent:Connect(function(id, command, value)
    local ok, message = pcall(function()
        if command == "Presentation" then
            local player = game.Players.LocalPlayer
            local hud = player.PlayerGui:WaitForChild("KarateHUD", 10)
            local controls = player.PlayerGui:WaitForChild("KarateControls", 10)
            assert(hud and hud:FindFirstChild("ProgressCard") and hud:FindFirstChild("Wallet"), "HUD did not initialize")
            assert(controls and controls:FindFirstChild("Actions"), "Combat buttons did not initialize")
            assert(player.Character:WaitForChild("KarateUniform", 10), "Missing uniform")
            for _, name in { "Punch", "Kick" } do
                local button = controls.Actions:FindFirstChild(name)
                assert(button and button:IsA("TextButton"), "Missing action button")
                assert(button.AbsoluteSize.X >= 64 and button.AbsoluteSize.Y >= 64, "Touch target too small")
                local endPoint = button.AbsolutePosition + button.AbsoluteSize
                local viewport = workspace.CurrentCamera.ViewportSize
                assert(button.AbsolutePosition.X >= 0 and button.AbsolutePosition.Y >= 0 and endPoint.X <= viewport.X and endPoint.Y <= viewport.Y, "Action button off screen")
            end
        elseif command == "Invalid" then
            attack:FireServer("Invalid", 999999)
            attack:FireServer({ Damage = 999999 })
        elseif command == "Spam" then
            for _ = 1, 50 do attack:FireServer("Punch", 999999, workspace) end
        elseif command == "Attack" then
            attack:FireServer(value)
        elseif command == "Collect" then
            local root = game.Players.LocalPlayer.Character.HumanoidRootPart
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            workspace.CurrentCamera.CFrame = CFrame.lookAt(root.Position + Vector3.new(0, 3, 6), value.Position)
            task.wait(0.2)
            local prompt = value:FindFirstChildOfClass("ProximityPrompt")
            assert(prompt, "Missing prompt")
            prompt:InputHoldBegin()
            task.wait(0.15)
            prompt:InputHoldEnd()
        end
    end)
    control:FireServer(id, ok, tostring(message))
end)
control:FireServer("Ready", true)
