local Theme = require(game.ReplicatedStorage.Shared.Theme)
local S = require(script.Parent.Scenery)
local WallDisplay = {}
function WallDisplay.create(wall)
    wall.Color = Color3.fromRGB(101, 69, 61)
    wall.Material = Enum.Material.Brick
    local bricks = {}
    for row = 0, 3 do
        for column = 0, 5 do
            local left = math.max(-5, -6 + column * 2 + row % 2)
            local right = math.min(5, -4 + column * 2 + row % 2)
            if right > left then
                local brick = S.part(wall, "Brick", Vector3.new(right - left - 0.09, 1.86, 2.08), wall.Position + Vector3.new((left + right) / 2, -3 + row * 2, 0), Color3.fromRGB(186 + row * 9, 74 + column * 4, 49), Enum.Material.Brick)
                table.insert(bricks, brick)
            end
        end
    end
    local gui = Instance.new("BillboardGui")
    gui.Name = "WallHealth"
    gui.Size = UDim2.fromOffset(180, 58)
    gui.StudsOffset = Vector3.new(0, 5.2, 0)
    gui.MaxDistance = 65
    gui.AlwaysOnTop = true
    gui.Parent = wall
    local background = Instance.new("Frame")
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = Theme.Navy
    background.BackgroundTransparency = 0.08
    background.BorderSizePixel = 0
    background.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = background
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -12, 0, 25)
    title.Position = UDim2.fromOffset(6, 2)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Theme.White
    title.TextSize = 15
    title.Text = "BRICK WALL"
    title.Parent = background
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -16, 0, 20)
    track.Position = UDim2.fromOffset(8, 30)
    track.BackgroundColor3 = Color3.fromRGB(52, 64, 81)
    track.BorderSizePixel = 0
    track.Parent = background
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(1, 1)
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Theme.Red
    fill.Parent = track
    local value = title:Clone()
    value.Name = "HP"
    value.Size = UDim2.fromScale(1, 1)
    value.Position = UDim2.new()
    value.ZIndex = 2
    value.TextSize = 13
    value.Parent = track
    return { bricks = bricks, fill = fill, title = title, value = value }
end
function WallDisplay.update(display, hp, maxHP)
    display.fill.Size = UDim2.fromScale(hp / maxHP, 1)
    display.value.Text = hp > 0 and string.format("%d / %d HP", hp, maxHP) or "REBUILDING…"
    display.title.Text = hp > 0 and "BRICK WALL" or "GREAT SMASH!"
    for _, brick in display.bricks do brick.Transparency = hp > 0 and 0 or 1 end
end
return WallDisplay
