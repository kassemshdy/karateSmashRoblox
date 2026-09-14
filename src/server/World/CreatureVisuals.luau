local Catalog = require(game.ReplicatedStorage.Shared.CreatureCatalog)
local Visuals = {}
function Visuals.create(parent, id, origin, scale)
    local species = assert(Catalog.Species[id], "Unknown creature")
    scale = scale or 1
    local model = Instance.new("Model")
    model.Name = id
    model.Parent = parent
    local function part(name, size, offset, color, ball)
        local p = Instance.new("Part")
        p.Name, p.Size, p.Color = name, size * scale, color
        p.CFrame = origin * CFrame.new(offset * scale)
        p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
        p.Material = Enum.Material.SmoothPlastic
        if ball then p.Shape = Enum.PartType.Ball end
        p.Parent = model
        return p
    end
    part("Body", Vector3.new(1.8, 1.5, 1.7), Vector3.new(0, 0, 0), species.Color, true)
    local head = part("Head", Vector3.new(1.6, 1.5, 1.4), Vector3.new(0, 0.75, -0.55), species.Color, true)
    model.PrimaryPart = head
    part("Muzzle", Vector3.new(1.05, 0.55, 0.3), Vector3.new(0, 0.5, -1.2), species.Accent, true)
    for _, side in { -1, 1 } do
        part("Eye", Vector3.new(0.34, 0.43, 0.13), Vector3.new(side * 0.4, 0.97, -1.22), Color3.new(1, 1, 1), true)
        part("Pupil", Vector3.new(0.15, 0.23, 0.08), Vector3.new(side * 0.4, 0.97, -1.3), Color3.fromRGB(20, 33, 50), true)
        for _, z in { -0.4, 0.5 } do
            part("Foot", Vector3.new(0.55, 0.5, 0.65), Vector3.new(side * 0.65, -0.65, z), species.Accent, true)
        end
        if id == "SkyDrake" then
            local wing = part("Wing", Vector3.new(1.1, 0.15, 1.1), Vector3.new(side * 1.15, 0.3, 0.2), species.Accent)
            wing.CFrame *= CFrame.Angles(0, 0, math.rad(side * 25))
        else
            part("Ear", Vector3.new(0.55, 0.65, 0.5), Vector3.new(side * 0.55, 1.5, -0.4), species.Accent, true)
        end
    end
    if id == "BudTurtle" then
        part("Shell", Vector3.new(1.8, 1.1, 1.4), Vector3.new(0, 0.35, 0.45), Color3.fromRGB(44, 127, 76), true)
    elseif id == "SunLion" then
        for index = 1, 8 do
            local angle = index * math.pi / 4
            part("Mane", Vector3.new(0.65, 0.65, 0.55), Vector3.new(math.cos(angle), 0.75 + math.sin(angle), -0.2), species.Accent, true)
        end
    else
        part("Horn", Vector3.new(0.3, 0.8, 0.3), Vector3.new(0, 1.6, -0.35), species.Accent)
    end
    return model
end
function Visuals.attach(model, root)
    for _, p in model:GetChildren() do
        if p:IsA("BasePart") then
            p.Anchored, p.Massless = false, true
            local weld = Instance.new("WeldConstraint")
            weld.Part0, weld.Part1, weld.Parent = root, p, p
        end
    end
end
return Visuals
