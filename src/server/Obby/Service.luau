local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.ObbyConfig)
local Parts = require(script.Parent.Parent.Smash.Parts)
local Rules = require(script.Parent.Rules)
local Service = {}
local records = {}
local function eligible(player)
    local stats = player:FindFirstChild("leaderstats")
    return player:GetAttribute("DataReady") and stats and stats.KaratePoints.Value >= Config.RequiredPoints
end
local function spawnAt(index)
    local node = Config.Nodes[index]
    return CFrame.new(node.Position + Vector3.new(0, 4, 0))
end
function Service.respawn(player)
    local state = records[player]
    if state and state.Active and eligible(player) then
        state.Stage = state.Safe
        player:SetAttribute("ObbyStage", state.Safe)
        state.LastPosition = nil
        return spawnAt(state.Safe)
    end
end
local function inside(position, node)
    local offset = position - node.Position
    return math.abs(offset.X) <= node.Size.X / 2 + 0.5
        and math.abs(offset.Z) <= node.Size.Z / 2 + 0.5
        and offset.Y >= 1 and offset.Y <= 6
end
function Service.sample(player, now)
    local root = Parts.root(player)
    if not root then return end
    local state = records[player]
    if not state then state = Rules.new(); records[player] = state end
    if not eligible(player) then
        state.Active = false
        player:SetAttribute("ObbyStatus", "Earn Yellow Belt to try the balance trial")
        return
    end
    if state.Active then
        local movedTooFar = state.LastPosition and (root.Position - state.LastPosition).Magnitude > Config.MaxSpeed * math.min(now - state.LastSample, 0.5) + Config.PositionTolerance
        if root.Position.Y < 4.5 or root.Position.Z > -29 or root.Position.Z < -94 or math.abs(root.Position.X) > 18 or movedTooFar then
            state.Stage = state.Safe
            player:SetAttribute("ObbyStage", state.Safe)
            root.Parent:PivotTo(spawnAt(state.Safe))
            root.AssemblyLinearVelocity = Vector3.zero
            state.LastPosition = root.Position
            state.LastSample = now
            player:SetAttribute("ObbyStatus", "Try again from your checkpoint!")
            return
        end
    end
    state.LastPosition, state.LastSample = root.Position, now
    local index = state.Active and state.Stage + 1 or 1
    local node = Config.Nodes[index]
    if not node or not inside(root.Position, node) then return end
    local outcome = Rules.advance(state, index, player.leaderstats.KaratePoints.Value, now)
    if not outcome then
        if not state.Active and now < state.NextRun then
            player:SetAttribute("ObbyStatus", string.format("Next rewarded trial in %ds", math.ceil(state.NextRun - now)))
        end
        return
    end
    player:SetAttribute("ObbyStage", state.Stage)
    if outcome == "Finished" then
        player.leaderstats.KaratePoints.Value += Config.RewardPoints
        player.leaderstats.Coins.Value += Config.RewardCoins
        player:SetAttribute("ObbyStatus", "Trial complete! +5 points, +10 coins • Return to the dojo")
        local character = player.Character
        task.delay(2, function()
            if player.Character == character and character and character.Parent and not state.Active then
                character:PivotTo(CFrame.new(0, 5, -22))
            end
        end)
    else
        player:SetAttribute("ObbyStatus", string.format("Balance trial • %d / %d%s", state.Stage, #Config.Nodes, node.Safe and " • Checkpoint saved" or ""))
    end
end
function Service.start(world)
    local course = require(script.Parent.Course)(world)
    local exit = Instance.new("ProximityPrompt")
    exit.Name = "LeaveTrial"
    exit.ActionText = "Return to dojo"
    exit.ObjectText = "Balance Trial"
    exit.MaxActivationDistance = 10
    exit.RequiresLineOfSight = false
    exit.Parent = course.Stage1
    exit.Triggered:Connect(function(player)
        local root = Parts.root(player)
        if not root or (root.Position - course.Stage1.Position).Magnitude > 10 then return end
        local state = records[player]
        if state then state.Active = false end
        player:SetAttribute("ObbyStatus", "Trial left • Come back when you are ready")
        root.Parent:PivotTo(CFrame.new(0, 5, 20))
        root.AssemblyLinearVelocity = Vector3.zero
    end)
    Players.PlayerRemoving:Connect(function(player) records[player] = nil end)
    task.spawn(function()
        while world.Parent do
            for _, player in Players:GetPlayers() do Service.sample(player, os.clock()) end
            task.wait(Config.SampleInterval)
        end
    end)
end
return Service
