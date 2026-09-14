local SoundService = game:GetService("SoundService")
local Config = require(game.ReplicatedStorage.Shared.AudioConfig)
local Audio = {}
local group = Instance.new("SoundGroup")
group.Name = "KarateEffects"
group.Volume = Config.Volume
group.Parent = SoundService
local sounds = {}
local muted = false
local sequence = 0
for name, cue in Config.Cues do
    local sound = Instance.new("Sound")
    sound.Name = name
    sound.SoundId = cue.Id
    sound.Volume = cue.Volume
    sound.PlaybackSpeed = cue.Speed
    sound.SoundGroup = group
    sound.Parent = group
    sounds[name] = sound
end
function Audio.setMuted(value)
    muted = value == true
    group.Volume = muted and 0 or Config.Volume
    sequence += 1
    if muted then
        for _, sound in sounds do sound:Stop() end
    end
end
function Audio.isMuted() return muted end
function Audio.play(name, pitch)
    local sound = sounds[name]
    if muted or not sound then return end
    sound:Stop()
    sound.PlaybackSpeed = Config.Cues[name].Speed * (pitch or 1)
    sound:Play()
end
function Audio.strike(action, result)
    local cue = result and (result.Broken and "Break" or "Hit") or "Swing"
    Audio.play(cue, action == "Kick" and 0.9 or 1)
end
function Audio.belt()
    sequence += 1
    local current = sequence
    task.spawn(function()
        for _, pitch in { 1, 1.25, 1.5 } do
            if current ~= sequence or muted then return end
            Audio.play("Belt", pitch)
            task.wait(0.16)
        end
    end)
end
return Audio
