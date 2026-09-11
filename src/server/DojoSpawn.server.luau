local Players = game:GetService("Players")
local spawn = workspace:WaitForChild("JawadKarateWorld"):WaitForChild("KarateSpawn")

local function setup(player)
    player.RespawnLocation = spawn
    local function placeCharacter(character)
        local root = character:WaitForChild("HumanoidRootPart", 10)
        if root and player.Character == character then
            character:PivotTo(spawn.CFrame + Vector3.new(0, 4, 0))
        end
    end
    player.CharacterAdded:Connect(placeCharacter)
    if player.Character then task.spawn(placeCharacter, player.Character) end
end

Players.PlayerAdded:Connect(setup)
for _, player in Players:GetPlayers() do setup(player) end
