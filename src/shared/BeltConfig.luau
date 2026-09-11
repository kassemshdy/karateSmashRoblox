local BeltConfig = {}

BeltConfig.Belts = {
    { name = "White", points = 0 },
    { name = "Yellow", points = 20 },
    { name = "Green", points = 50 },
    { name = "Brown", points = 75 },
    { name = "Black", points = 100 },
}

function BeltConfig.getBeltForPoints(points)
    local current = BeltConfig.Belts[1]

    for _, belt in ipairs(BeltConfig.Belts) do
        if points >= belt.points then
            current = belt
        else
            break
        end
    end

    return current.name
end

function BeltConfig.getNextBelt(points)
    for _, belt in ipairs(BeltConfig.Belts) do
        if points < belt.points then
            return belt
        end
    end

    return nil
end

return BeltConfig
