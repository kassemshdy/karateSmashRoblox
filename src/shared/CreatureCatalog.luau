local Catalog = {}
Catalog.Order = { "BudTurtle", "SkyDrake", "SunLion" }
Catalog.MaxPerSpecies = 1000000
Catalog.Species = {
    BudTurtle = { Name = "Bud Turtle", Rarity = "Common", Weight = 70, Coins = 1, Color = Color3.fromRGB(99, 187, 111), Accent = Color3.fromRGB(240, 220, 126) },
    SkyDrake = { Name = "Sky Drake", Rarity = "Rare", Weight = 25, Coins = 4, Color = Color3.fromRGB(75, 177, 242), Accent = Color3.fromRGB(223, 245, 255) },
    SunLion = { Name = "Sun Lion", Rarity = "Legendary", Weight = 5, Coins = 12, Color = Color3.fromRGB(255, 199, 63), Accent = Color3.fromRGB(242, 95, 47) },
}
function Catalog.empty()
    local counts = {}
    for _, id in Catalog.Order do counts[id] = 0 end
    return counts
end
function Catalog.roll(random)
    local total = 0
    for _, id in Catalog.Order do total += Catalog.Species[id].Weight end
    local draw = random:NextInteger(1, total)
    for _, id in Catalog.Order do
        draw -= Catalog.Species[id].Weight
        if draw <= 0 then return id end
    end
    error("Invalid random draw")
end
function Catalog.totals(counts)
    local count, income = 0, 0
    for _, id in Catalog.Order do
        count += counts[id]
        income += counts[id] * Catalog.Species[id].Coins
    end
    return count, income
end
return Catalog
