local RunService = game:GetService("RunService")
local Pose = {}
local active = {}
local function restore(state)
    for _, entry in state.Joints do
        if entry.Joint.Parent and entry.Base then entry.Joint.Transform = entry.Base end
    end
end
local function find(character, name)
    for _, joint in character:GetDescendants() do
        if joint.Name:gsub(" ", "") == name and (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) then
            return joint
        end
    end
end
function Pose.play(character, action)
    if not character or (action ~= "Punch" and action ~= "Kick") then return false end
    if active[character] then restore(active[character]) end
    local kick = action == "Kick"
    local joints = {}
    local specifications = kick and { {"RightHip", 80}, {"RightKnee", -15}, {"LeftShoulder", 30} }
        or { {"RightShoulder", 95}, {"RightElbow", 12}, {"LeftShoulder", 35} }
    for _, spec in specifications do
        local joint = find(character, spec[1])
        if joint then
            local basis = joint:IsA("Motor6D") and joint.C0
                or (joint.Attachment0 and joint.Attachment0.CFrame or CFrame.identity)
            local rotation = basis.Rotation
            table.insert(joints, { Joint = joint, Target = rotation:Inverse() * CFrame.Angles(math.rad(spec[2]), 0, 0) * rotation })
        end
    end
    if #joints == 0 then active[character] = nil; return false end
    active[character] = { Joints = joints, Started = os.clock(), Duration = kick and 0.55 or 0.36 }
    return true
end
-- Restore before Animator evaluates; apply the strike after it evaluates. This
-- avoids pose accumulation and supports both legacy and upgraded avatar joints.
RunService.PreAnimation:Connect(function()
    for _, state in active do restore(state) end
end)
RunService.PreSimulation:Connect(function()
    for character, state in active do
        local elapsed = os.clock() - state.Started
        if not character.Parent or elapsed >= state.Duration then
            active[character] = nil
        else
            local amount = elapsed < 0.1 and elapsed / 0.1
                or (elapsed < state.Duration * 0.6 and 1 or (state.Duration - elapsed) / (state.Duration * 0.4))
            for _, entry in state.Joints do
                if entry.Joint.Parent then
                    entry.Base = entry.Joint.Transform
                    entry.Joint.Transform = entry.Base:Lerp(entry.Target, math.clamp(amount, 0, 1))
                end
            end
        end
    end
end)
return Pose
