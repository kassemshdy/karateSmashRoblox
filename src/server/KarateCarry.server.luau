local Players = game:GetService("Players")
local Visuals = require(script.Parent.World.CreatureVisuals)
local function add(player)
    local function refresh()
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local old = character:FindFirstChild("CarriedCreature")
        if old then old:Destroy() end
        local id = player:GetAttribute("CarryingSpecies")
        if not id then return end
        local model = Visuals.create(character, id, root.CFrame * CFrame.new(0, 0, -2), 0.75)
        model.Name = "CarriedCreature"
        Visuals.attach(model, root)
    end
    player:GetAttributeChangedSignal("CarryingSpecies"):Connect(refresh)
    player.CharacterAdded:Connect(function(character)
        local root = character:WaitForChild("HumanoidRootPart", 15)
        if not root then return end
        local deadline = os.clock() + 15
        while not character:IsDescendantOf(workspace) and os.clock() < deadline do task.wait(0.1) end
        if player.Character == character then refresh() end
    end)
    refresh()
end
Players.PlayerAdded:Connect(add)
for _, player in Players:GetPlayers() do task.spawn(add, player) end
