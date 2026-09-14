local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Parts = require(script.Parent.Smash.Parts)
local Progress = require(script.Parent.Tutorial.Progress)
local Config = require(ReplicatedStorage.Shared.TutorialConfig)
local world = workspace:WaitForChild("JawadKarateWorld")
world:WaitForChild("DojoSign")
local model, head, prompt = require(script.Parent.Tutorial.Sensei)(world)
local talk = Instance.new("RemoteEvent")
talk.Name = "KarateTutorial"
talk.Parent = ReplicatedStorage
local lastTalk = {}
prompt.Triggered:Connect(function(player)
    local root = Parts.root(player)
    if not root or (root.Position - head.Position).Magnitude > Config.TalkDistance then return end
    local now = os.clock()
    if now < (lastTalk[player] or 0) then return end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { player.Character, model }
    if workspace:Raycast(root.Position, head.Position - root.Position, params) then return end
    lastTalk[player] = now + 1
    talk:FireClient(player)
end)
local function add(player)
    while player.Parent == Players and not player:GetAttribute("DataReady") do task.wait(0.1) end
    if player.Parent ~= Players then return end
    local stats = player:WaitForChild("leaderstats")
    local function update()
        player:SetAttribute("TutorialStage", Progress.stage(stats.KaratePoints.Value,
            player:GetAttribute("WallsBrokenSession") or 0,
            player:GetAttribute("Trophies") or 0, stats.Coins.Value))
    end
    local connections = {
        stats.KaratePoints.Changed:Connect(update), stats.Coins.Changed:Connect(update),
        player:GetAttributeChangedSignal("Trophies"):Connect(update),
        player:GetAttributeChangedSignal("WallsBrokenSession"):Connect(update),
    }
    player.AncestryChanged:Once(function()
        for _, connection in connections do connection:Disconnect() end
    end)
    update()
end
Players.PlayerAdded:Connect(add)
Players.PlayerRemoving:Connect(function(player) lastTalk[player] = nil end)
for _, player in Players:GetPlayers() do task.spawn(add, player) end
