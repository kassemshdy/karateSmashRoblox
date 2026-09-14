local Players = game:GetService("Players")
local Profiles = require(script.Parent.Data.Profiles)
local Parts = require(script.Parent.Smash.Parts)
local remote = Instance.new("RemoteEvent")
remote.Name = "KarateUpgrades"
remote.Parent = game:GetService("ReplicatedStorage")
local nextRequest = {}
remote.OnServerEvent:Connect(function(player, id, expectedLevel)
    local now = os.clock()
    if now < (nextRequest[player] or 0) then return end
    nextRequest[player] = now + 0.3
    if not Parts.root(player) then return end
    local ok, message = Profiles.buyUpgrade(player, id, expectedLevel)
    remote:FireClient(player, ok, message)
end)
Players.PlayerRemoving:Connect(function(player) nextRequest[player] = nil end)
