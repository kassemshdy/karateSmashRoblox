local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Parts = require(script.Parent.Smash.Parts)
local records = {}

local function disconnectPad(pad)
    local record = records[pad]
    if record then
        record.connection:Disconnect()
        records[pad] = nil
    end
end

local function connectPad(pad)
    if not pad:IsA("BasePart") or records[pad] then return end
    local reward = pad:GetAttribute("PointsReward") or 1
    local cooldown = pad:GetAttribute("Cooldown") or 1
    if typeof(reward) ~= "number" or reward ~= reward or reward < 0 or reward == math.huge then return end
    if typeof(cooldown) ~= "number" or cooldown ~= cooldown or cooldown < 0.1 or cooldown == math.huge then return end
    local record = { nextTouch = {} }
    record.connection = pad.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        local root = player and Parts.root(player)
        if not root then return end
        -- Touched can originate from client-owned physics; verify actual proximity.
        local offset = pad.CFrame:PointToObjectSpace(root.Position)
        local half = pad.Size / 2
        if math.abs(offset.X) > half.X + 4 or math.abs(offset.Y) > half.Y + 4
            or math.abs(offset.Z) > half.Z + 4 then return end
        local now = os.clock()
        if now < (record.nextTouch[player] or 0) then return end
        local stats = player:FindFirstChild("leaderstats")
        local points = stats and stats:FindFirstChild("KaratePoints")
        if not points then return end
        record.nextTouch[player] = now + cooldown
        points.Value += math.floor(reward)
    end)
    records[pad] = record
end

CollectionService:GetInstanceAddedSignal("KarateTrainingPad"):Connect(connectPad)
CollectionService:GetInstanceRemovedSignal("KarateTrainingPad"):Connect(disconnectPad)
for _, pad in CollectionService:GetTagged("KarateTrainingPad") do connectPad(pad) end
Players.PlayerRemoving:Connect(function(player)
    for _, record in pairs(records) do record.nextTouch[player] = nil end
end)
