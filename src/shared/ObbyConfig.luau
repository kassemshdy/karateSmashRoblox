return {
    RequiredPoints = 20,
    RewardPoints = 5,
    RewardCoins = 10,
    ReplayCooldown = 60,
    SampleInterval = 0.1,
    -- Generous tolerance for replication/jumping; this is not full movement anti-cheat.
    MaxSpeed = 40,
    PositionTolerance = 8,
    Nodes = {
        { Position = Vector3.new(0, 3, -35), Size = Vector3.new(10, 1, 8), Safe = true, Label = "START • YELLOW BELT" },
        { Position = Vector3.new(0, 3, -43), Size = Vector3.new(3, 1, 8), Label = "BALANCE" },
        { Position = Vector3.new(0, 3, -51), Size = Vector3.new(9, 1, 6), Safe = true, Label = "CHECKPOINT" },
        { Position = Vector3.new(-3, 3, -59), Size = Vector3.new(5, 1, 5) },
        { Position = Vector3.new(3, 3, -67), Size = Vector3.new(5, 1, 5) },
        { Position = Vector3.new(-3, 3, -75), Size = Vector3.new(5, 1, 5) },
        { Position = Vector3.new(0, 3, -83), Size = Vector3.new(10, 1, 8), Safe = true, Label = "FINISH • +5 POINTS +10 COINS" },
    },
}
