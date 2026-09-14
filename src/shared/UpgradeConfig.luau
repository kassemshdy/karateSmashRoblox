local Config = {
    Order = { "Punch", "Kick" },
    MaxLevel = 5,
    Types = {
        Punch = { Name = "Hand Power", Bonus = 2 },
        Kick = { Name = "Leg Power", Bonus = 5 },
    },
}
function Config.cost(level) return 25 * 2 ^ level end
return Config
