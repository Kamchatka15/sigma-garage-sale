--!strict
-- ScavengeService — spawns junk in the yard and puts it in players' bags.
--
-- Design note: junk is collected by walking into it, not by a ProximityPrompt.
-- Holding E on 45 separate piles is tedious; running through a field of them is
-- the good kind of mindless. The 30-second loop should never have friction in
-- its first step.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local ItemDatabase = require(Shared:WaitForChild("ItemDatabase"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlotService = require(script.Parent:WaitForChild("PlotService"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

local ScavengeService = {}

local rng = Random.new()
local junkFolder: Folder
local activeCount = 0

local function makeJunkPart(item: ItemDatabase.Item, position: Vector3): Part
	local part = Instance.new("Part")
	part.Name = "Junk_" .. item.id
	part.Size = Vector3.new(1.6, 1.6, 1.6)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, rng:NextNumber() * math.pi, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = ItemDatabase.GetRarityColor(item.rarity)
	part:SetAttribute("ItemId", item.id)

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(170, 34)
	billboard.StudsOffset = Vector3.new(0, 1.7, 0)
	billboard.MaxDistance = 45
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.TextColor3 = ItemDatabase.GetRarityColor(item.rarity)
	label.TextStrokeTransparency = 0.3
	label.Text = item.name
	label.Parent = billboard

	-- Rarer junk gets a glow so a Legendary spawn is visible across the yard.
	-- The whole point of a rare spawn is that someone sprints for it.
	if item.rarity == "Cursed" or item.rarity == "Legendary" then
		local light = Instance.new("PointLight")
		light.Color = ItemDatabase.GetRarityColor(item.rarity)
		light.Range = 18
		light.Brightness = 3
		light.Parent = part
	end

	return part
end

local function spawnOne()
	if activeCount >= Config.MaxJunkInYard then
		return
	end

	local zone = WorldBuilder.GetJunkyardZone()
	if not zone then
		return
	end

	local item = ItemDatabase.RollRandom(rng)

	local halfX = zone.Size.X / 2 - 6
	local halfZ = zone.Size.Z / 2 - 6
	local position = zone.Position
		+ Vector3.new(rng:NextNumber(-halfX, halfX), zone.Size.Y / 2 + 0.9, rng:NextNumber(-halfZ, halfZ))

	local part = makeJunkPart(item, position)
	part.Parent = junkFolder
	activeCount += 1

	local collected = false

	part.Touched:Connect(function(hit)
		if collected then
			return
		end

		local character = hit.Parent
		if not character then
			return
		end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		-- Claim the item before doing anything that yields, so two touch
		-- events in the same frame can't both collect the same part.
		collected = true

		if PlotService.AddToBag(player, item.id) then
			activeCount -= 1
			part:Destroy()
		else
			collected = false
			Remotes.Get("Notify"):FireClient(player, "Bag full — go sell something.", "bad")
			task.wait(1.5)
		end
	end)

	task.delay(Config.JunkDespawnTime, function()
		if part.Parent then
			activeCount -= 1
			part:Destroy()
		end
	end)
end

function ScavengeService.Init()
	junkFolder = Instance.new("Folder")
	junkFolder.Name = "Junk"
	junkFolder.Parent = workspace

	-- Seed the yard so the first player to arrive doesn't stand in an empty lot
	-- waiting for the spawn timer. First sale in under 60 seconds is a design
	-- target (GAME-DESIGN.md §7) and this is part of hitting it.
	for _ = 1, 20 do
		spawnOne()
	end

	task.spawn(function()
		while true do
			task.wait(Config.JunkSpawnInterval)
			spawnOne()
		end
	end)
end

return ScavengeService
