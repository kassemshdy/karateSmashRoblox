local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Config = require(ReplicatedStorage.Shared.PersistenceConfig)
local BeltConfig = require(ReplicatedStorage.Shared.BeltConfig)
local Catalog = require(ReplicatedStorage.Shared.CreatureCatalog)
local Upgrades = require(ReplicatedStorage.Shared.UpgradeConfig)
local ProfileStore = require(script.Parent.ProfileStore)
local memoryOnly = RunService:IsStudio() and not Config.EnableStudioDataStore
local adapter
if memoryOnly then
    adapter = require(script.Parent.MemoryStore).new()
else
    local name = RunService:IsStudio() and Config.StudioStoreName or Config.StoreName
    adapter = game:GetService("DataStoreService"):GetDataStore(name)
end
local store = ProfileStore.new(adapter, Config)
local Profiles = {}
local records = {}
local loading = {}
local closing = false

local function snapshot(player)
    local stats = player.leaderstats
    local data = records[player].creatures
    return { Version = 3, Upgrades = table.clone(records[player].upgrades), Points = stats.KaratePoints.Value, Coins = stats.Coins.Value,
        Trophies = player:GetAttribute("Trophies") or 0,
        Creatures = table.clone(data.Creatures), Carried = data.Carried }
end

local function syncCreatures(player, data)
    local count = Catalog.totals(data.Creatures)
    player:SetAttribute("CreatureCount", count)
    player:SetAttribute("CollectionCount", count + (player:GetAttribute("Trophies") or 0))
    player:SetAttribute("CarryingSpecies", data.Carried or nil)
    for _, id in Catalog.Order do player:SetAttribute("Owned_" .. id, data.Creatures[id]) end
end
function Profiles.creatureState(player)
    local record = records[player]
    if not record then return nil end
    return table.clone(record.creatures.Creatures), record.creatures.Carried
end
function Profiles.tryCarry(player, id)
    local record = records[player]
    if not record or record.closing or not player:GetAttribute("DataReady") or not Catalog.Species[id] then return false end
    local data = record.creatures
    if data.Carried or data.Creatures[id] >= Catalog.MaxPerSpecies then return false end
    data.Carried = id
    syncCreatures(player, data)
    return true
end
function Profiles.placeCarried(player, id)
    local record = records[player]
    if not record or record.closing or not player:GetAttribute("DataReady") or not Catalog.Species[id] then return false end
    local data = record.creatures
    if data.Carried ~= id or data.Creatures[id] >= Catalog.MaxPerSpecies then return false end
    data.Creatures[id] += 1
    data.Carried = false
    syncCreatures(player, data)
    return true
end

function Profiles.attack(player, name, base)
    local record = records[player]
    if not record or record.closing or not player:GetAttribute("DataReady") then return nil end
    local attack = table.clone(base)
    attack.Damage += record.upgrades[name] * Upgrades.Types[name].Bonus
    return attack
end

function Profiles.buyUpgrade(player, id, expectedLevel)
    local record = records[player]
    if not record or record.closing or not player:GetAttribute("DataReady") then return false, "Progress is loading." end
    if type(id) ~= "string" or not Upgrades.Types[id] then return false, "Unknown upgrade." end
    local level = record.upgrades[id]
    if expectedLevel ~= level then return false, "Upgrade changed. Try again." end
    if level >= Upgrades.MaxLevel then return false, "Already at maximum level." end
    local coins = player.leaderstats.Coins
    local cost = Upgrades.cost(level)
    if coins.Value < cost then return false, "You need more coins." end
    -- No yields between checking, charging, and granting; repeated requests are stale.
    coins.Value -= cost
    record.upgrades[id] = level + 1
    player:SetAttribute("Upgrade_" .. id, level + 1)
    return true, Upgrades.Types[id].Name .. " upgraded!"
end

function Profiles.save(player, release)
    local record = records[player]
    if not record or (record.closing and not release) then return end
    if release then
        record.closing = true
        player:SetAttribute("DataReady", false)
    end
    while record.busy do task.wait(0.05) end
    if records[player] ~= record then return end
    record.busy = true
    local result, failure = store:save(record.key, record.token, snapshot(player), release)
    record.busy = false
    if result then
        record.expires = result.Session and result.Session.Expires or 0
        player:SetAttribute("SaveStatus", memoryOnly and "Studio session" or "Saved")
    else
        player:SetAttribute("SaveStatus", "Save delayed")
        warn("Player progress save failed: " .. tostring(failure))
        if not release and (failure == "Rejected" or os.time() >= record.expires) then
            player:SetAttribute("DataReady", false)
            record.closing = true
            player:Kick("Your progress session expired. Please rejoin to keep playing safely.")
        end
    end
    if release then records[player] = nil end
end

function Profiles.load(player)
    if records[player] or loading[player] or closing then return end
    loading[player] = true
    player:SetAttribute("DataReady", false)
    player:SetAttribute("SaveStatus", "Loading progress…")
    local key = "Player_" .. player.UserId
    local token = HttpService:GenerateGUID(false)
    local data, failure = store:load(key, token)
    loading[player] = nil
    if not data then
        player:SetAttribute("SaveStatus", "Load failed")
        player:Kick(failure == "SessionLocked" and "Your previous session is still saving. Please rejoin in a moment."
            or "Your progress could not be loaded. Please rejoin; your saved progress has not been reset.")
        return
    end
    if closing or player.Parent ~= Players then
        store:save(key, token, data, true)
        return
    end
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    for name, value in pairs({ KaratePoints = data.Points, Coins = data.Coins }) do
        local stat = Instance.new("IntValue")
        stat.Name = name
        stat.Value = value
        stat.Parent = stats
    end
    local belt = Instance.new("StringValue")
    belt.Name = "Belt"
    belt.Value = BeltConfig.getBeltForPoints(data.Points)
    belt.Parent = player
    player:SetAttribute("Trophies", data.Trophies)
    stats.Parent = player
    records[player] = { key = key, token = token, expires = data.Session.Expires, busy = false, upgrades = table.clone(data.Upgrades),
        creatures = { Creatures = table.clone(data.Creatures), Carried = data.Carried } }
    for _, id in Upgrades.Order do player:SetAttribute("Upgrade_" .. id, data.Upgrades[id]) end
    syncCreatures(player, records[player].creatures)
    player:SetAttribute("SaveStatus", memoryOnly and "Studio session" or "Saved")
    player:SetAttribute("DataReady", true)
end

function Profiles.start()
    Players.PlayerAdded:Connect(Profiles.load)
    Players.PlayerRemoving:Connect(function(player) Profiles.save(player, true) end)
    for _, player in Players:GetPlayers() do task.spawn(Profiles.load, player) end
    task.spawn(function()
        while not closing do
            task.wait(Config.AutosaveSeconds)
            for player, record in pairs(records) do
                if not record.closing and not record.busy then task.spawn(Profiles.save, player, false) end
            end
        end
    end)
    -- Stop earning when a lease expires even if a DataStore call is still yielding.
    task.spawn(function()
        while not closing do
            task.wait(1)
            for player, record in pairs(records) do
                if not record.closing and os.time() >= record.expires then
                    record.closing = true
                    player:SetAttribute("DataReady", false)
                    player:Kick("Saving is temporarily unavailable. Please rejoin shortly.")
                end
            end
        end
    end)
    game:BindToClose(function()
        closing = true
        local pending = 0
        for player in pairs(records) do
            pending += 1
            task.spawn(function()
                Profiles.save(player, true)
                pending -= 1
            end)
        end
        local deadline = os.clock() + 25
        while pending > 0 and os.clock() < deadline do task.wait(0.1) end
    end)
end
return Profiles
