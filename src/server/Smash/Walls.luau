local Config = require(game:GetService("ReplicatedStorage").Shared.SmashConfig)
local Parts = require(script.Parent.Parts)
local Drops = require(script.Parent.Drops)
local Display = require(script.Parent.Parent.World.WallDisplay)
local Walls = {}
local records = {}

function Walls.start(world)
    for index, x in ipairs({ -25, 0, 25 }) do
        local wall = Parts.make(world, "SmashWall" .. index, Vector3.new(10, 8, 2), Vector3.new(x, 4.5, -5), Color3.fromRGB(215, 135, 80))
        wall:SetAttribute("MaxHP", Config.WallHP)
        wall:SetAttribute("HP", Config.WallHP)
        local display = Display.create(wall)
        Display.update(display, Config.WallHP, Config.WallHP)
        records[wall] = { hp = Config.WallHP, display = display }
    end
end

function Walls.hit(player, attack)
    local root = Parts.root(player)
    if not root then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { player.Character }
    -- The server chooses the first object in front of the character.
    local result = workspace:Raycast(root.Position, root.CFrame.LookVector * attack.Range, params)
    local record = result and records[result.Instance]
    if not record or record.hp <= 0 then return nil end
    local wall = result.Instance
    local damage = math.min(record.hp, attack.Damage)
    record.hp = math.max(0, record.hp - attack.Damage)
    wall:SetAttribute("HP", record.hp)
    Display.update(record.display, record.hp, Config.WallHP)
    if record.hp == 0 then
        -- Mark broken before rewarding so simultaneous attacks cannot pay twice.
        wall.CanCollide = false
        wall.CanQuery = false
        wall.Transparency = 1
        local stats = player:FindFirstChild("leaderstats")
        local points = stats and stats:FindFirstChild("KaratePoints")
        if points then points.Value += Config.WallPoints end
        Drops.spawn(wall.Parent, wall.Position + Vector3.new(0, -2, 4), player)
        task.delay(Config.WallRespawnSeconds, function()
            if not wall.Parent then return end
            record.hp = Config.WallHP
            wall:SetAttribute("HP", record.hp)
            wall.CanCollide = true
            wall.CanQuery = true
            wall.Transparency = 0
            Display.update(record.display, record.hp, Config.WallHP)
        end)
    end
    return { Position = result.Position, Broken = record.hp == 0, HP = record.hp, Damage = damage }
end

return Walls
