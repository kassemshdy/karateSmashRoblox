local Players = game:GetService("Players")
local Parts = require(script.Parent.Smash.Parts)
local world = workspace:WaitForChild("JawadKarateWorld")
local gate = world:WaitForChild("YellowBeltGate")
local cooldown = {}

-- Keep the gate solid: a qualified player never opens it for other players.
gate.Touched:Connect(function(hit)
    local character = hit:FindFirstAncestorOfClass("Model")
    local player = character and Players:GetPlayerFromCharacter(character)
    if not player then return end
    local now = os.clock()
    if now < (cooldown[player] or 0) then return end
    local root = Parts.root(player)
    local stats = player:FindFirstChild("leaderstats")
    local points = stats and stats:FindFirstChild("KaratePoints")
    if not root or not points or points.Value < (gate:GetAttribute("RequiredPoints") or 20) then return end
    local localPosition = gate.CFrame:PointToObjectSpace(root.Position)
    if math.abs(localPosition.X) > gate.Size.X / 2 + 3
        or math.abs(localPosition.Y) > gate.Size.Y / 2 + 3
        or math.abs(localPosition.Z) > gate.Size.Z / 2 + 4 then return end
    cooldown[player] = now + 1
    local destinationZ = localPosition.Z >= 0 and -(gate.Size.Z / 2 + 4) or (gate.Size.Z / 2 + 4)
    local destination = gate.CFrame:PointToWorldSpace(Vector3.new(localPosition.X, localPosition.Y, destinationZ))
    character:PivotTo(character:GetPivot() + (destination - root.Position))
end)

Players.PlayerRemoving:Connect(function(player) cooldown[player] = nil end)
