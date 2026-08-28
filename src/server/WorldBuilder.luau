--!strict
-- WorldBuilder — generates the entire map at runtime from primitives.
--
-- WHY build the world in code instead of placing parts in Studio:
--   1. The map ends up in git. A layout change is a reviewable diff.
--   2. The game runs on a completely empty baseplate, so a fresh clone or a
--      new worktree is playable immediately with no .rbxl to sync.
--   3. Changing plot spacing is editing one number, not dragging 72 parts.
--
-- The tradeoff, stated plainly: you give up visual editing. For a game whose
-- art direction is "labeled boxes" that costs nothing. For a game with real
-- environment art it would be the wrong call.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local WorldBuilder = {}

local MAX_SHELVES = Config.StartingShelves + Config.Upgrades.shelves.maxLevel

local PALETTE = {
	ground = Color3.fromRGB(88, 128, 92),
	plotFloor = Color3.fromRGB(196, 178, 148),
	counter = Color3.fromRGB(150, 92, 60),
	shelf = Color3.fromRGB(122, 88, 62),
	sign = Color3.fromRGB(240, 226, 196),
	junkyard = Color3.fromRGB(112, 104, 96),
	houseFloor = Color3.fromRGB(150, 130, 110),
	houseWall = Color3.fromRGB(198, 186, 170),
	houseRoof = Color3.fromRGB(120, 78, 66),
	fence = Color3.fromRGB(140, 116, 92),
	searchSpot = Color3.fromRGB(168, 150, 128),
}

-- Where each search spot sits, relative to Config.HouseOrigin. Interior spots
-- first, yard spots after. Names are player-facing — they show up in the
-- "Search the Mailbox" prompt, so they carry the joke.
local HOUSE_SPOTS = {
	{ name = "Closet", offset = Vector3.new(-12, 2, -9) },
	{ name = "Under the Bed", offset = Vector3.new(10, 1, -8) },
	{ name = "Kitchen Cupboard", offset = Vector3.new(-12, 2, 6) },
	{ name = "Bookshelf", offset = Vector3.new(12, 2, 0) },
	{ name = "Laundry Basket", offset = Vector3.new(6, 1.5, 9) },
	{ name = "Fireplace", offset = Vector3.new(0, 2, -10.5) },
	{ name = "Mailbox", offset = Vector3.new(-20, 2, 18) },
	{ name = "Trash Cans", offset = Vector3.new(20, 2, 16) },
	{ name = "Doghouse", offset = Vector3.new(-20, 1.5, -8) },
	{ name = "Garden Shed", offset = Vector3.new(20, 2, -14) },
	{ name = "Kiddie Pool", offset = Vector3.new(0, 1, 18) },
	{ name = "Car Trunk", offset = Vector3.new(-20, 2, 6) },
}

local function makePart(name: string, size: Vector3, cf: CFrame, color: Color3, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Color = color
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.SmoothPlastic
	part.Parent = parent
	return part
end

--------------------------------------------------------------------
-- Ground
--------------------------------------------------------------------

local function buildGround(parent: Instance)
	if workspace:FindFirstChild("Baseplate") then
		return
	end
	makePart("Ground", Vector3.new(700, 2, 700), CFrame.new(0, -1, 40), PALETTE.ground, parent)
end

--------------------------------------------------------------------
-- One stall
--------------------------------------------------------------------

local function buildPlot(index: number, parent: Instance): Model
	local origin = Config.PlotOrigin + Vector3.new((index - 1) * Config.PlotSpacing, 0, 0)

	local model = Instance.new("Model")
	model.Name = "Plot" .. index
	model.Parent = parent

	local floor =
		makePart("Floor", Vector3.new(32, 1, 26), CFrame.new(origin + Vector3.new(0, 0.5, 0)), PALETTE.plotFloor, model)
	model.PrimaryPart = floor

	makePart("Counter", Vector3.new(24, 3, 2), CFrame.new(origin + Vector3.new(0, 2, -5)), PALETTE.counter, model)

	-- Shelves: build the maximum now, hide the ones the owner hasn't unlocked.
	-- Creating and destroying parts as upgrades are bought would be more
	-- "correct" but produces visible pop-in and more code paths to get wrong.
	local shelves = Instance.new("Folder")
	shelves.Name = "Shelves"
	shelves.Parent = model

	local spacing = 2.0
	local startX = -((MAX_SHELVES - 1) * spacing) / 2

	for i = 1, MAX_SHELVES do
		local shelf = makePart(
			"Shelf" .. i,
			Vector3.new(1.8, 0.4, 1.8),
			CFrame.new(origin + Vector3.new(startX + (i - 1) * spacing, 3.2, -9)),
			PALETTE.shelf,
			shelves
		)
		shelf:SetAttribute("ShelfIndex", i)

		-- Anchor point for the displayed item + its label
		local mount = Instance.new("Attachment")
		mount.Name = "Mount"
		mount.Position = Vector3.new(0, 0.2, 0)
		mount.Parent = shelf
	end

	-- Where a customer stands to browse, and where they walk in from.
	local stand = makePart(
		"CustomerStand",
		Vector3.new(2, 0.2, 2),
		CFrame.new(origin + Vector3.new(0, 1.1, -1)),
		PALETTE.plotFloor,
		model
	)
	stand.Transparency = 1
	stand.CanCollide = false

	local approach = makePart(
		"CustomerApproach",
		Vector3.new(2, 0.2, 2),
		CFrame.new(origin + Vector3.new(0, 1.1, 18)),
		PALETTE.plotFloor,
		model
	)
	approach.Transparency = 1
	approach.CanCollide = false

	-- Owner sign
	local signPost =
		makePart("Sign", Vector3.new(12, 3, 0.4), CFrame.new(origin + Vector3.new(0, 8, -10)), PALETTE.sign, model)

	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(600, 150)
	gui.Parent = signPost

	local label = Instance.new("TextLabel")
	label.Name = "OwnerLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(60, 45, 30)
	label.Text = "VACANT"
	label.Parent = gui

	return model
end

--------------------------------------------------------------------
-- Junkyard
--------------------------------------------------------------------

local function buildJunkyard(parent: Instance)
	local zone = makePart(
		"JunkyardZone",
		Config.JunkyardSize,
		CFrame.new(Config.JunkyardCenter + Vector3.new(0, 0.5, 0)),
		PALETTE.junkyard,
		parent
	)
	zone.Material = Enum.Material.Slate

	local sign = makePart(
		"JunkyardSign",
		Vector3.new(30, 6, 0.5),
		CFrame.new(Config.JunkyardCenter + Vector3.new(0, 10, -66)),
		PALETTE.sign,
		parent
	)

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back
	gui.CanvasSize = Vector2.new(800, 160)
	gui.Parent = sign

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(60, 45, 30)
	label.Text = "THE JUNKYARD"
	label.Parent = gui
end

--------------------------------------------------------------------
-- The first raidable house — the Condemned Fixer-Upper
--------------------------------------------------------------------

local function buildHouse(parent: Instance): Model
	local origin = Config.HouseOrigin

	local model = Instance.new("Model")
	model.Name = "House1"
	model.Parent = parent

	local floor = makePart(
		"Floor",
		Vector3.new(30, 1, 24),
		CFrame.new(origin + Vector3.new(0, 0.5, 0)),
		PALETTE.houseFloor,
		model
	)
	model.PrimaryPart = floor

	-- Walls. The front wall is two segments with a gap, which is the doorway.
	makePart(
		"WallBack",
		Vector3.new(30, 10, 1),
		CFrame.new(origin + Vector3.new(0, 5.5, -12)),
		PALETTE.houseWall,
		model
	)
	makePart(
		"WallLeft",
		Vector3.new(1, 10, 24),
		CFrame.new(origin + Vector3.new(-15, 5.5, 0)),
		PALETTE.houseWall,
		model
	)
	makePart(
		"WallRight",
		Vector3.new(1, 10, 24),
		CFrame.new(origin + Vector3.new(15, 5.5, 0)),
		PALETTE.houseWall,
		model
	)
	makePart(
		"WallFrontL",
		Vector3.new(12, 10, 1),
		CFrame.new(origin + Vector3.new(-9, 5.5, 12)),
		PALETTE.houseWall,
		model
	)
	makePart(
		"WallFrontR",
		Vector3.new(12, 10, 1),
		CFrame.new(origin + Vector3.new(9, 5.5, 12)),
		PALETTE.houseWall,
		model
	)

	-- Roof is see-through and non-colliding on purpose: a solid one reads better
	-- from outside but puts the camera inside a box the moment you walk in.
	local roof =
		makePart("Roof", Vector3.new(32, 1, 26), CFrame.new(origin + Vector3.new(0, 11, 0)), PALETTE.houseRoof, model)
	roof.Transparency = 0.7
	roof.CanCollide = false

	-- Yard fence, also with a gap — that gap is the gate you have to leave by
	-- once the extraction rules exist.
	makePart("FenceBack", Vector3.new(50, 4, 0.5), CFrame.new(origin + Vector3.new(0, 2, -22)), PALETTE.fence, model)
	makePart("FenceLeft", Vector3.new(0.5, 4, 44), CFrame.new(origin + Vector3.new(-25, 2, 0)), PALETTE.fence, model)
	makePart("FenceRight", Vector3.new(0.5, 4, 44), CFrame.new(origin + Vector3.new(25, 2, 0)), PALETTE.fence, model)
	makePart(
		"FenceFrontL",
		Vector3.new(21, 4, 0.5),
		CFrame.new(origin + Vector3.new(-14.5, 2, 22)),
		PALETTE.fence,
		model
	)
	makePart(
		"FenceFrontR",
		Vector3.new(21, 4, 0.5),
		CFrame.new(origin + Vector3.new(14.5, 2, 22)),
		PALETTE.fence,
		model
	)

	local gate =
		makePart("Gate", Vector3.new(8, 4, 0.5), CFrame.new(origin + Vector3.new(0, 2, 22)), PALETTE.fence, model)
	gate.Transparency = 1
	gate.CanCollide = false

	local spots = Instance.new("Folder")
	spots.Name = "SearchSpots"
	spots.Parent = model

	for index = 1, math.min(Config.HouseSearchSpots, #HOUSE_SPOTS) do
		local def = HOUSE_SPOTS[index]
		local spot =
			makePart("Spot" .. index, Vector3.new(2, 2, 2), CFrame.new(origin + def.offset), PALETTE.searchSpot, spots)
		spot:SetAttribute("SearchSpot", true)
		spot:SetAttribute("SpotName", def.name)

		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "SearchPrompt"
		prompt.ActionText = "Search"
		prompt.ObjectText = def.name
		prompt.HoldDuration = Config.SearchHoldDuration
		prompt.MaxActivationDistance = 8
		prompt.RequiresLineOfSight = false
		prompt.Parent = spot
	end

	local sign = makePart(
		"HouseSign",
		Vector3.new(20, 4, 0.5),
		CFrame.new(origin + Vector3.new(0, 8, 22.4)),
		PALETTE.sign,
		model
	)

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(700, 140)
	gui.Parent = sign

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(60, 45, 30)
	label.Text = "THE FIXER-UPPER"
	label.Parent = gui

	return model
end

--------------------------------------------------------------------

function WorldBuilder.Build(): Folder
	local existing = workspace:FindFirstChild("World")
	if existing then
		return existing :: Folder
	end

	local world = Instance.new("Folder")
	world.Name = "World"
	world.Parent = workspace

	buildGround(world)
	buildJunkyard(world)
	buildHouse(world)

	local plots = Instance.new("Folder")
	plots.Name = "Plots"
	plots.Parent = world

	for i = 1, Config.PlotCount do
		buildPlot(i, plots)
	end

	-- Somewhere for players to arrive that isn't the void
	if not workspace:FindFirstChildWhichIsA("SpawnLocation", true) then
		local spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Name = "PlayerSpawn"
		spawnLocation.Size = Vector3.new(12, 1, 12)
		spawnLocation.CFrame = CFrame.new(0, 1, 40)
		spawnLocation.Anchored = true
		spawnLocation.Color = Color3.fromRGB(200, 200, 210)
		spawnLocation.TopSurface = Enum.SurfaceType.Smooth
		spawnLocation.Parent = world
	end

	return world
end

function WorldBuilder.GetPlots(): { Model }
	local world = workspace:FindFirstChild("World")
	if not world then
		return {}
	end
	local plots = world:FindFirstChild("Plots")
	if not plots then
		return {}
	end

	local result: { Model } = {}
	for i = 1, Config.PlotCount do
		local plot = plots:FindFirstChild("Plot" .. i)
		if plot and plot:IsA("Model") then
			table.insert(result, plot)
		end
	end
	return result
end

function WorldBuilder.GetHouse(): Model?
	local world = workspace:FindFirstChild("World")
	if not world then
		return nil
	end
	local house = world:FindFirstChild("House1")
	return if house and house:IsA("Model") then house else nil
end

function WorldBuilder.GetSearchSpots(): { BasePart }
	local house = WorldBuilder.GetHouse()
	local folder = house and house:FindFirstChild("SearchSpots")
	if not folder then
		return {}
	end

	local result: { BasePart } = {}
	for _, child in folder:GetChildren() do
		if child:IsA("BasePart") and child:GetAttribute("SearchSpot") then
			table.insert(result, child)
		end
	end
	return result
end

function WorldBuilder.GetJunkyardZone(): Part?
	local world = workspace:FindFirstChild("World")
	if not world then
		return nil
	end
	local zone = world:FindFirstChild("JunkyardZone")
	return if zone and zone:IsA("Part") then zone else nil
end

return WorldBuilder
