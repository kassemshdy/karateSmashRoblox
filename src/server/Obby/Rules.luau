local Config = require(game.ReplicatedStorage.Shared.ObbyConfig)
local Rules = {}
function Rules.new()
    return { Stage = 0, Safe = 1, Active = false, NextRun = 0, LastAdvance = 0 }
end
function Rules.advance(state, stage, points, now)
    if points < Config.RequiredPoints then return false end
    if not state.Active then
        if stage ~= 1 or now < state.NextRun then return false end
        state.Active, state.Stage, state.Safe, state.LastAdvance = true, 1, 1, now
        return "Started"
    end
    if stage ~= state.Stage + 1 or now - state.LastAdvance < 0.25 then return false end
    state.Stage, state.LastAdvance = stage, now
    if Config.Nodes[stage].Safe then state.Safe = stage end
    if stage == #Config.Nodes then
        -- Close the run before awarding so duplicate samples cannot pay twice.
        state.Active = false
        state.NextRun = now + Config.ReplayCooldown
        return "Finished"
    end
    return "Checkpoint"
end
return Rules
