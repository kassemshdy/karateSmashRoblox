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
            local guide = player.PlayerGui:WaitForChild("SenseiGuide", 10)
            assert(guide and guide:FindFirstChild("Dialogue"), "Sensei guide did not initialize")
            local creatureGuide = player.PlayerGui:WaitForChild("CreatureGuide", 10)
            assert(creatureGuide and creatureGuide:FindFirstChild("Carrying"), "Creature guide did not initialize")
            -- Keep the automated combat/prompt checks unobstructed by the welcome panel.
            guide.Dialogue.Visible = false
            assert(hud and hud:FindFirstChild("ProgressCard") and hud:FindFirstChild("Wallet"), "HUD did not initialize")
            assert(controls and controls:FindFirstChild("Actions"), "Combat buttons did not initialize")
            assert(player.Character:WaitForChild("KarateUniform", 10), "Missing uniform")
            for _, name in { "Punch", "Kick" } do
                local button = controls.Actions:FindFirstChild(name)
                assert(button and button:IsA("TextButton"), "Missing action button")
                assert(button.AbsoluteSize.X >= 64 and button.AbsoluteSize.Y >= 64, "Touch target too small")
                local function fits()
                    local endPoint = button.AbsolutePosition + button.AbsoluteSize
                    local viewport = workspace.CurrentCamera.ViewportSize
                    return button.AbsolutePosition.X >= 0 and button.AbsolutePosition.Y >= 0
                        and endPoint.X <= viewport.X and endPoint.Y <= viewport.Y
                end
                local deadline = os.clock() + 5
                while not fits() and os.clock() < deadline do task.wait(0.1) end
                assert(fits(), "Action button off screen: " .. tostring(button.AbsolutePosition) .. " / " .. tostring(workspace.CurrentCamera.ViewportSize))
            end
        elseif command == "Audio" then
            local Audio = require(game.Players.LocalPlayer.PlayerScripts.Presentation.Audio)
            local group = game:GetService("SoundService"):WaitForChild("KarateEffects", 10)
            assert(group and #group:GetChildren() == 5, "Missing bounded sound pool")
            assert(game.Players.LocalPlayer.PlayerGui.KarateControls.Actions:FindFirstChild("ToggleSound"), "Missing mute control")
            Audio.setMuted(true)
            Audio.strike("Punch", { Broken = true })
            Audio.belt()
            task.wait(0.2)
            assert(group.Volume == 0 and Audio.isMuted(), "Mute did not silence effects")
            for _, sound in group:GetChildren() do assert(not sound.IsPlaying, "Muted sound played") end
            Audio.setMuted(false)
            assert(group.Volume > 0 and not Audio.isMuted(), "Unmute failed")
            Audio.play("Collect")
            task.wait(0.2)
            assert(#group:GetChildren() == 5, "Sound instances leaked")
        elseif command == "Invalid" then
            attack:FireServer("Invalid", 999999)
            attack:FireServer({ Damage = 999999 })
        elseif command == "Spam" then
            for _ = 1, 50 do attack:FireServer("Punch", 999999, workspace) end
        elseif command == "Attack" then
            attack:FireServer(value)
        elseif command == "LeaveTrial" then
            local prompt = workspace.JawadKarateWorld.YellowBeltObby.Stage1.LeaveTrial
            local root = game.Players.LocalPlayer.Character.HumanoidRootPart
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            workspace.CurrentCamera.CFrame = CFrame.lookAt(root.Position + Vector3.new(0, 3, 6), prompt.Parent.Position)
            task.wait(0.2)
            prompt:InputHoldBegin()
            task.wait(0.15)
            prompt:InputHoldEnd()
        elseif command == "Collect" or command == "PlaceCreature" then
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
