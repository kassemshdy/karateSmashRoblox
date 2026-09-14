local Progress = {}
-- Derive the guide from authoritative progress; returning players keep credit
-- for trophies/coins already saved without introducing a second save schema.
function Progress.stage(points, wallsBroken, trophies, coins)
    if points < 1 and trophies < 1 then return 1 end
    if wallsBroken < 1 and trophies < 1 then return 2 end
    if trophies < 1 then return 3 end
    if coins < 1 then return 4 end
    if points < 20 then return 5 end
    return 6
end
return Progress
