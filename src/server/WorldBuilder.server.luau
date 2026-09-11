local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local WORLD_NAME = "JawadKarateWorld"

local existing = Workspace:FindFirstChild(WORLD_NAME)
if existing then
	existing:Destroy()
end

local world = Instance.new("Folder")
world.Name = WORLD_NAME
world.Parent = Workspace

local function makePart(name, size, position, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Material = material or Enum.Material.SmoothPlastic
	part.Parent = parent or world
	return part
end

local floor = makePart("DojoFloor", Vector3.new(80, 1, 60), Vector3.new(0, 0, 0), Enum.Material.WoodPlanks)

local backWall = makePart("BackWall", Vector3.new(80, 16, 1), Vector3.new(0, 8, -30), Enum.Material.Wood)
local leftWall = makePart("LeftWall", Vector3.new(1, 16, 60), Vector3.new(-40, 8, 0), Enum.Material.Wood)
local rightWall = makePart("RightWall", Vector3.new(1, 16, 60), Vector3.new(40, 8, 0), Enum.Material.Wood)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "KarateSpawn"
spawn.Size = Vector3.new(6, 1, 6)
spawn.Position = Vector3.new(0, 1, 22)
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = world

local function makeTrainingPad(name, position, reward)
	local pad = makePart(name, Vector3.new(5, 6, 2), position, Enum.Material.SmoothPlastic)
	pad:SetAttribute("PointsReward", reward)
	pad:SetAttribute("Cooldown", 1)
	CollectionService:AddTag(pad, "KarateTrainingPad")

	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(180, 50)
	gui.StudsOffset = Vector3.new(0, 4.5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = pad

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = name .. "  +" .. tostring(reward)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Parent = gui

	return pad
end

makeTrainingPad("Punch Pad", Vector3.new(-14, 3.5, 4), 1)
makeTrainingPad("Kick Pad", Vector3.new(14, 3.5, 4), 2)

local gate = makePart("YellowBeltGate", Vector3.new(16, 12, 1), Vector3.new(0, 6, -15), Enum.Material.Metal)
gate:SetAttribute("RequiredPoints", 20)
gate.Color = Color3.fromRGB(245, 205, 60)
makePart("GateLeftWing", Vector3.new(32, 16, 1), Vector3.new(-24, 8, -15), Enum.Material.Wood)
makePart("GateRightWing", Vector3.new(32, 16, 1), Vector3.new(24, 8, -15), Enum.Material.Wood)
makePart("GateLintel", Vector3.new(16, 4, 1), Vector3.new(0, 14, -15), Enum.Material.Wood)

local gateGui = Instance.new("BillboardGui")
gateGui.Size = UDim2.fromOffset(260, 60)
gateGui.StudsOffset = Vector3.new(0, 7, 0)
gateGui.AlwaysOnTop = true
gateGui.Parent = gate

local gateLabel = Instance.new("TextLabel")
gateLabel.Size = UDim2.fromScale(1, 1)
gateLabel.BackgroundTransparency = 1
gateLabel.TextScaled = true
gateLabel.Font = Enum.Font.GothamBold
gateLabel.Text = "YELLOW BELT • 20 POINTS"
gateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
gateLabel.Parent = gateGui

local senseiPlatform = makePart("SenseiPlatform", Vector3.new(16, 1, 10), Vector3.new(0, 1, -23), Enum.Material.WoodPlanks)

local sign = makePart("DojoSign", Vector3.new(20, 5, 1), Vector3.new(0, 10, -29), Enum.Material.Wood)
local signGui = Instance.new("SurfaceGui")
signGui.Face = Enum.NormalId.Front
signGui.Parent = sign

local signText = Instance.new("TextLabel")
signText.Size = UDim2.fromScale(1, 1)
signText.BackgroundTransparency = 1
signText.TextScaled = true
signText.Font = Enum.Font.GothamBlack
signText.Text = "JAWAD KARATE"
signText.TextColor3 = Color3.fromRGB(255, 255, 255)
signText.Parent = signGui

print("Jawad Karate dojo generated")
