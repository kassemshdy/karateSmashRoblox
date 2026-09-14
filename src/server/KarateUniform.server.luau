local Players = game:GetService("Players")
local Uniform = require(script.Parent.World.Uniform)
local function add(player)
    local function dress(character)
        -- RigType can still be its default while Roblox assembles the avatar.
        -- Detect the actual torso instead of waiting for parts of the wrong rig.
        local deadline = os.clock() + 15
        while not (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")) do
            if os.clock() >= deadline then return end
            task.wait(0.1)
        end
        local r15 = character:FindFirstChild("UpperTorso") ~= nil
        local bodyNames = r15 and { "UpperTorso", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg" }
            or { "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg" }
        for _, name in bodyNames do
            if not character:WaitForChild(name, 10) then return end
        end
        -- Finish avatar assembly before attaching the outfit; Studio and live
        -- avatars can fire both character events before entering Workspace.
        while not character:IsDescendantOf(workspace) do
            if os.clock() >= deadline or player.Parent ~= Players then return end
            task.wait(0.1)
        end
        local belt = player:FindFirstChild("Belt")
        Uniform.dress(character, belt and belt.Value or "White")
    end
    player.CharacterAdded:Connect(dress)
    player.CharacterAppearanceLoaded:Connect(dress)
    if player.Character then task.spawn(dress, player.Character) end
    while player.Parent == Players and not player:GetAttribute("DataReady") do task.wait(0.1) end
    if player.Parent ~= Players then return end
    local belt = player:WaitForChild("Belt")
    Uniform.color(player.Character, belt.Value)
    belt.Changed:Connect(function() Uniform.color(player.Character, belt.Value) end)
end
Players.PlayerAdded:Connect(add)
for _, player in Players:GetPlayers() do task.spawn(add, player) end
