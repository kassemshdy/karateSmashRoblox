local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Config = require(ReplicatedStorage.Shared.SmashConfig)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("KarateSmash")
local nextAttack = 0
local Presentation = script.Parent:WaitForChild("Presentation")
require(Presentation:WaitForChild("Lighting"))()
require(Presentation:WaitForChild("CombatControls"))(player, function(name)
    if UserInputService:GetFocusedTextBox() or not player:GetAttribute("DataReady") then return end
    if os.clock() < nextAttack then return end
    nextAttack = os.clock() + Config.Attacks[name].Cooldown
    remotes.Attack:FireServer(name)
end)
local Effects = require(Presentation:WaitForChild("CombatEffects"))
remotes.Feedback.OnClientEvent:Connect(function(userId, action, result)
    Effects.play(Players:GetPlayerByUserId(userId), action, result)
end)
