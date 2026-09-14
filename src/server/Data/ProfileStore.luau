-- Storage adapter is injected so locking/failure paths can be tested offline.
local Catalog = require(game.ReplicatedStorage.Shared.CreatureCatalog)
local ProfileStore = {}
ProfileStore.__index = ProfileStore

local function validNumber(value)
    return type(value) == "number" and value == value and value >= 0
        and value <= 9007199254740991 and value % 1 == 0
end

function ProfileStore.decode(value)
    if value == nil then return { Version = 2, Points = 0, Coins = 0, Trophies = 0, Creatures = Catalog.empty(), Carried = false } end
    if type(value) ~= "table" or (value.Version ~= 1 and value.Version ~= 2) then return nil end
    for _, key in { "Points", "Coins", "Trophies" } do
        if not validNumber(value[key]) then return nil end
    end
    if value.Session ~= nil then
        if type(value.Session) ~= "table" or type(value.Session.Token) ~= "string"
            or not validNumber(value.Session.Expires) then return nil end
    end
    local counts, carried = Catalog.empty(), false
    if value.Version == 2 then
        if type(value.Creatures) ~= "table" then return nil end
        for id, count in value.Creatures do
            if not Catalog.Species[id] or not validNumber(count) or count > Catalog.MaxPerSpecies then return nil end
            counts[id] = count
        end
        for _, id in Catalog.Order do if value.Creatures[id] == nil then return nil end end
        if value.Carried ~= false and not Catalog.Species[value.Carried] then return nil end
        carried = value.Carried
    end
    -- Legacy trophies retain their value and income. Never reroll saved creatures.
    return { Version = 2, Points = value.Points, Coins = value.Coins, Trophies = value.Trophies,
        Creatures = counts, Carried = carried }
end

function ProfileStore.new(adapter, config, clock, pause)
    return setmetatable({ adapter = adapter, config = config, clock = clock or os.time, pause = pause or task.wait }, ProfileStore)
end

function ProfileStore:update(key, transform)
    for attempt = 1, self.config.RetryAttempts do
        local ok, result = pcall(function() return self.adapter:UpdateAsync(key, transform) end)
        if ok then
            if result then return result end
            return nil, "Rejected"
        end
        if attempt < self.config.RetryAttempts then self.pause(attempt) end
    end
    return nil, "Unavailable"
end

function ProfileStore:load(key, token)
    local reason
    local result, failure = self:update(key, function(old)
        local data = ProfileStore.decode(old)
        if not data then reason = "InvalidData"; return nil end
        local session = old and old.Session
        if session and session.Token ~= token and session.Expires > self.clock() then
            reason = "SessionLocked"
            return nil
        end
        data.Session = { Token = token, Expires = self.clock() + self.config.LeaseSeconds }
        return data
    end)
    if result then return result end
    return nil, reason or failure
end

function ProfileStore:save(key, token, snapshot, release)
    local data = ProfileStore.decode(snapshot)
    if not data then return nil, "InvalidData" end
    return self:update(key, function(old)
        if not ProfileStore.decode(old) or not old or not old.Session
            or old.Session.Token ~= token or old.Session.Expires <= self.clock() then return nil end
        local nextData = table.clone(data)
        if not release then
            nextData.Session = { Token = token, Expires = self.clock() + self.config.LeaseSeconds }
        end
        return nextData
    end)
end

return ProfileStore
