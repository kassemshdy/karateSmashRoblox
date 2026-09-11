local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.SmashConfig)
local Bases = require(script.Parent.Smash.Bases)
local Walls = require(script.Parent.Smash.Walls)
local Parts = require(script.Parent.Smash.Parts)

local world = workspace:WaitForChild("JawadKarateWorld")
world:WaitForChild("DojoSign")
Bases.start(world)
Walls.start(world)

local remotes = Instance.new("Folder")
remotes.Name = "KarateSmash"
local attackEvent = Instance.new("RemoteEvent")
attackEvent.Name = "Attack"
attackEvent.Parent = remotes
local feedback = Instance.new("RemoteEvent")
feedback.Name = "Feedback"
feedback.Parent = remotes
remotes.Parent = ReplicatedStorage

local nextAttack = {}
attackEvent.OnServerEvent:Connect(function(player, attackName)
    if typeof(attackName) ~= "string" then return end
    local attack = Config.Attacks[attackName]
    if not attack then return end
    local now = os.clock()
    if now < (nextAttack[player] or 0) or not Parts.root(player) then return end
    -- One shared cooldown prevents alternating attacks from bypassing the limit.
    nextAttack[player] = now + attack.Cooldown
    local result = Walls.hit(player, attack)
    feedback:FireClient(player, attackName, result)
end)
Players.PlayerRemoving:Connect(function(player) nextAttack[player] = nil end)
