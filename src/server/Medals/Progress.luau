local Config = require(game.ReplicatedStorage.Shared.MedalConfig)
local Progress = {}
function Progress.evaluate(points, creatures, legendary)
    local stats = { Points = points, Creatures = creatures, Legendary = legendary }
    local result, earned = {}, 0
    for _, medal in Config do
        local value = math.clamp(stats[medal.Stat], 0, medal.Goal)
        result[medal.Id] = value
        if value >= medal.Goal then earned += 1 end
    end
    return result, earned
end
return Progress
