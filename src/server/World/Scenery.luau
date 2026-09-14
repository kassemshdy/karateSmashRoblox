local Theme = require(game.ReplicatedStorage.Shared.Theme)
local Parts = require(script.Parent.Parent.Smash.Parts)
local Scenery = {}
function Scenery.part(parent, name, size, position, color, material, solid)
    local part = Parts.make(parent, name, size, position, color)
    part.Material = material or Enum.Material.SmoothPlastic
    part.CanCollide = solid == true
    part.CanTouch = false
    part.CanQuery = solid == true
    return part
end
local function part(...) return Scenery.part(...) end

function Scenery.roof(parent, center, width, depth)
    for _, side in { -1, 1 } do
        local roof = part(parent, "SlopedRoof", Vector3.new(width, 0.8, depth / 2 + 1), center + Vector3.new(0, -0.9, side * depth / 4), Theme.Roof)
        roof.CFrame *= CFrame.Angles(math.rad(15 * side), 0, 0)
        part(parent, "GoldEave", Vector3.new(width + 1, 0.25, 0.4), center + Vector3.new(0, -2, side * depth / 2), Theme.Gold)
    end
    part(parent, "RoofRidge", Vector3.new(width + 2, 0.65, 0.7), center + Vector3.new(0, 0.2, 0), Theme.Navy)
end

function Scenery.torii(parent, center, width, height)
    for _, side in { -1, 1 } do
        part(parent, "ToriiPillar", Vector3.new(1.7, height, 1.7), center + Vector3.new(side * width / 2, height / 2, 0), Theme.Red, Enum.Material.Wood, true)
        part(parent, "PillarFoot", Vector3.new(2.4, 1, 2.4), center + Vector3.new(side * width / 2, 0.5, 0), Theme.Navy)
    end
    part(parent, "ToriiCrossbar", Vector3.new(width + 5, 1.4, 2), center + Vector3.new(0, height - 2, 0), Theme.Red)
    part(parent, "ToriiCrown", Vector3.new(width + 8, 1.1, 3), center + Vector3.new(0, height + 0.4, 0), Theme.Navy)
    part(parent, "ToriiGoldTrim", Vector3.new(width + 8, 0.2, 3.1), center + Vector3.new(0, height - 0.1, 0), Theme.Gold)
end

function Scenery.tree(parent, position, blossom)
    part(parent, "TreeTrunk", Vector3.new(1.6, 8, 1.6), position + Vector3.new(0, 3, 0), Theme.Wood, Enum.Material.Wood)
    for i = 1, 3 do
        local crown = part(parent, "TreeCrown", Vector3.new(9 - i, 6, 8 - i), position + Vector3.new((i - 2) * 2.4, 7 + i, (i % 2) * 2), blossom and Color3.fromRGB(244, 155 + i * 12, 182 + i * 10) or Color3.fromRGB(55 + i * 12, 130 + i * 15, 76))
        crown.Shape = Enum.PartType.Ball
    end
end

function Scenery.lantern(parent, position)
    part(parent, "LanternPost", Vector3.new(0.5, 6, 0.5), position + Vector3.new(0, 3, 0), Theme.Wood)
    local glow = part(parent, "LanternGlow", Vector3.new(1.6, 2, 1.6), position + Vector3.new(0, 6, 0), Theme.Gold, Enum.Material.Neon)
    part(parent, "LanternCap", Vector3.new(2.2, 0.35, 2.2), position + Vector3.new(0, 7.2, 0), Theme.Roof)
    local light = Instance.new("PointLight")
    light.Color = Theme.Gold
    light.Brightness = 0.6
    light.Range = 12
    light.Parent = glow
end

function Scenery.sign(parent, name, position, size, text, color)
    local board = part(parent, name, size, position, color or Theme.Navy)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Back
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 45
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBlack
    label.TextColor3 = Theme.White
    label.TextScaled = true
    label.Text = text
    label.Parent = gui
    return board
end

function Scenery.base(model, position)
    for _, x in { -6.7, 6.7 } do
        for _, z in { -6.7, 6.7 } do
            part(model, "BaseColumn", Vector3.new(0.7, 8, 0.7), position + Vector3.new(x, 4.5, z), Theme.Red, Enum.Material.Wood)
        end
    end
    part(model, "BaseBack", Vector3.new(14, 6, 0.5), position + Vector3.new(0, 3.5, 7), Theme.Cream)
    local pedestals = {}
    for index, x in { -4.5, 0, 4.5 } do
        local pedestal = part(model, "CreaturePedestal" .. index, Vector3.new(3.4, 1, 3.4), position + Vector3.new(x, 1, 2), Theme.Navy)
        table.insert(pedestals, pedestal)
        part(model, "PedestalRim", Vector3.new(3.6, 0.2, 3.6), position + Vector3.new(x, 1.55, 2), Theme.Gold)
    end
    Scenery.roof(model, position + Vector3.new(0, 10, 0), 17, 16)
    local trophy = part(model, "TrophyDisplay", Vector3.new(1.4, 1.7, 1.4), position + Vector3.new(0, 3.4, 2), Theme.Gold, Enum.Material.Metal)
    trophy.Shape = Enum.PartType.Ball
    part(trophy, "CupStem", Vector3.new(0.35, 1, 0.35), position + Vector3.new(0, 2.3, 2), Theme.Gold, Enum.Material.Metal)
    part(trophy, "CupFoot", Vector3.new(1.5, 0.2, 1.2), position + Vector3.new(0, 1.9, 2), Theme.Gold, Enum.Material.Metal)
    for _, side in { -1, 1 } do
        local handle = part(trophy, "CupHandle", Vector3.new(0.35, 1, 0.5), position + Vector3.new(side * 0.95, 3.45, 2), Theme.Gold, Enum.Material.Metal)
        handle.CFrame *= CFrame.Angles(0, 0, math.rad(side * 25))
    end
    return trophy, pedestals
end

function Scenery.showTrophy(trophy, visible)
    trophy.Transparency = visible and 0 or 1
    for _, piece in trophy:GetChildren() do
        if piece:IsA("BasePart") then piece.Transparency = trophy.Transparency end
    end
end
return Scenery
