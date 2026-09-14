local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.SmashConfig)
local Bases = require(script.Parent.Smash.Bases)
local Walls = require(script.Parent.Smash.Walls)
local Parts = require(script.Parent.Smash.Parts)
local Targeting = require(script.Parent.Smash.Targeting)
local Dummy = require(script.Parent.Smash.TrainingDummy)

local world = workspace:WaitForChild("JawadKarateWorld")
world:WaitForChild("DojoSign")
Bases.start(world)
Walls.start(world)
Dummy.start(world)

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
    local target = Targeting(player, attack)
    local result = Walls.hit(player, attack, target) or Dummy.hit(player, attack, target)
    for _, viewer in Players:GetPlayers() do
        local viewerRoot = Parts.root(viewer)
        local actorRoot = Parts.root(player)
        if viewerRoot and actorRoot and (viewerRoot.Position - actorRoot.Position).Magnitude <= 100 then
            feedback:FireClient(viewer, player.UserId, attackName, result)
        end
    end
end)
Players.PlayerRemoving:Connect(function(player) nextAttack[player] = nil end)
