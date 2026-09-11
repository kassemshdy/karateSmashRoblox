local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("JawadKarateWorld")
local gate = world:WaitForChild("YellowBeltGate")
local requiredPoints = gate:GetAttribute("RequiredPoints") or 20

local cooldown = {}

gate.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player or cooldown[player] then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local points = leaderstats and leaderstats:FindFirstChild("KaratePoints")
	if not points then
		return
	end

	if points.Value >= requiredPoints then
		cooldown[player] = true
		gate.CanCollide = false
		gate.Transparency = 0.75
		task.wait(2)
		gate.CanCollide = true
		gate.Transparency = 0
		cooldown[player] = nil
	end
end)
