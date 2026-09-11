local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local cooldowns = {}

local function connectPad(pad)
    if not pad:IsA("BasePart") then
        return
    end

    local pointsReward = pad:GetAttribute("PointsReward") or 1
    local cooldownSeconds = pad:GetAttribute("Cooldown") or 1

    pad.Touched:Connect(function(hit)
        local character = hit.Parent
        if not character then
            return
        end

        local player = Players:GetPlayerFromCharacter(character)
        if not player then
            return
        end

        cooldowns[pad] = cooldowns[pad] or {}
        if cooldowns[pad][player] then
            return
        end

        cooldowns[pad][player] = true

        local leaderstats = player:FindFirstChild("leaderstats")
        local points = leaderstats and leaderstats:FindFirstChild("KaratePoints")
        if points then
            points.Value += pointsReward
        end

        task.delay(cooldownSeconds, function()
            if cooldowns[pad] then
                cooldowns[pad][player] = nil
            end
        end)
    end)
end

for _, pad in ipairs(CollectionService:GetTagged("KarateTrainingPad")) do
    connectPad(pad)
end

CollectionService:GetInstanceAddedSignal("KarateTrainingPad"):Connect(connectPad)
