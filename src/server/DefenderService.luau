--!strict
-- DefenderService — the person who lives in the house, and catching you.
--
-- THE AWARENESS MODEL, which is the whole feel of a raid:
--   heat rises when you are SEEN (per second) or when you SEARCH (per spot)
--   heat falls whenever neither is happening
--   heat is per-player, so two raiders don't share a suspicion meter
--
-- The escalation ladder is deliberately legible (docs/GAME-DESIGN.md §5):
--   unaware      -> walking the patrol route
--   suspicious   -> breaks patrol, moves to where you last were
--   chasing      -> comes straight at you
--
-- Every rung is something the player caused. That is the difference between
-- "I searched one spot too many" (fun) and "the game got me" (a quit).
--
-- Movement is CFrame lerping, not Humanoid pathfinding — consistent with the
-- customer NPCs (DECISIONS.md, 2026-08-27). Valid while a house is one room
-- with a doorway; real interiors will need PathfindingService.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local ItemDatabase = require(Shared:WaitForChild("ItemDatabase"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local HouseService = require(script.Parent:WaitForChild("HouseService"))
local PlotService = require(script.Parent:WaitForChild("PlotService"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

local DefenderService = {}

type Awareness = {
	heat: number,
	lastKnown: Vector3?,
	investigateUntil: number,
	lockedOutUntil: number,
	-- Last values pushed to the client, so an unchanged dial costs no bandwidth.
	sentHeat: number,
	sentState: string,
}

local defender: Model? = nil
local route: { BasePart } = {}
local routeIndex = 1

local awareness: { [Player]: Awareness } = {}
local droppedFolder: Folder? = nil

--------------------------------------------------------------------
-- Rig
--------------------------------------------------------------------

local function buildDefender(): Model
	local model = Instance.new("Model")
	model.Name = "Defender"

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 3, 1)
	body.Anchored = true
	body.CanCollide = false
	body.Material = Enum.Material.SmoothPlastic
	body.Color = Color3.fromRGB(150, 70, 70)
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.3, 1.3, 1.3)
	head.Anchored = true
	head.CanCollide = false
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(234, 205, 170)
	head.Parent = model

	-- Reads state from across the yard without needing UI.
	local mood = Instance.new("BillboardGui")
	mood.Name = "Mood"
	mood.Size = UDim2.fromOffset(120, 40)
	mood.StudsOffset = Vector3.new(0, 3.4, 0)
	mood.AlwaysOnTop = true
	mood.MaxDistance = 90
	mood.Parent = body

	local label = Instance.new("TextLabel")
	label.Name = "MoodLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextStrokeTransparency = 0.4
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = ""
	label.Parent = mood

	model.PrimaryPart = body
	return model
end

local function place(model: Model, position: Vector3)
	local body = model.PrimaryPart
	if not body then
		return
	end
	body.CFrame = CFrame.new(position)
	local head = model:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		head.CFrame = CFrame.new(position + Vector3.new(0, 2.2, 0))
	end
end

local function setMood(text: string, color: Color3)
	local body = defender and defender.PrimaryPart
	local mood = body and body:FindFirstChild("Mood")
	local label = mood and mood:FindFirstChild("MoodLabel")
	if label and label:IsA("TextLabel") then
		label.Text = text
		label.TextColor3 = color
	end
end

--------------------------------------------------------------------
-- Perception
--------------------------------------------------------------------

local function rootOf(player: Player): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function stateFor(heat: number): string
	if heat >= Config.HeatChase then
		return "chasing"
	elseif heat >= Config.HeatSuspicious then
		return "suspicious"
	end
	return "unaware"
end

local function awarenessFor(player: Player): Awareness
	local existing = awareness[player]
	if existing then
		return existing
	end
	local created: Awareness = {
		heat = 0,
		lastKnown = nil,
		investigateUntil = 0,
		lockedOutUntil = 0,
		sentHeat = -1,
		sentState = "",
	}
	awareness[player] = created
	return created
end

-- Heartbeat runs ~60x a second and the dial only moves in whole numbers, so
-- pushing every frame would be ~60 identical remote events per player per
-- second. Send only on an actual change.
local function pushHeat(player: Player, view: Awareness)
	local heat = math.floor(view.heat)
	local heatState = stateFor(view.heat)

	if heat == view.sentHeat and heatState == view.sentState then
		return
	end

	view.sentHeat = heat
	view.sentState = heatState
	Remotes.Get("Heat"):FireClient(player, heat, Config.HeatMax, heatState)
end

-- Line of sight: within range, and nothing solid between us. The defender's own
-- model and the player's character are excluded or they would block themselves.
local function canSee(from: Vector3, root: BasePart): boolean
	local delta = root.Position - from
	if delta.Magnitude > Config.DefenderSightRange then
		return false
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { defender :: Instance, root.Parent :: Instance }

	return workspace:Raycast(from, delta, params) == nil
end

--------------------------------------------------------------------
-- Getting caught
--------------------------------------------------------------------

local function scatter(itemIds: { string }, near: Vector3)
	local folder = droppedFolder
	if not folder then
		return
	end

	for _, itemId in itemIds do
		local item = ItemDatabase.Get(itemId)
		if item then
			local part = Instance.new("Part")
			part.Name = "Dropped_" .. itemId
			part.Size = Vector3.new(1.6, 1.6, 1.6)
			part.Position = near
				+ Vector3.new(math.random(-70, 70) / 10, 2 + math.random(0, 20) / 10, math.random(-70, 70) / 10)
			part.Color = ItemDatabase.GetRarityColor(item.rarity)
			part.Material = Enum.Material.SmoothPlastic
			part.Anchored = true
			part.CanCollide = false
			part:SetAttribute("ItemId", itemId)
			part.Parent = folder

			-- Walk-into pickup, same as junkyard scavenging. Claim before any
			-- yield so two touches in one frame can't both collect it.
			local collected = false
			part.Touched:Connect(function(hit)
				if collected then
					return
				end
				local character = hit.Parent
				local finder = character and Players:GetPlayerFromCharacter(character)
				if not finder then
					return
				end

				collected = true
				if PlotService.AddToBag(finder, itemId) then
					part:Destroy()
				else
					collected = false
					Remotes.Get("Notify"):FireClient(finder, "Bag full — go sell something.", "bad")
					task.wait(1.5)
				end
			end)

			local billboard = Instance.new("BillboardGui")
			billboard.Size = UDim2.fromOffset(150, 30)
			billboard.StudsOffset = Vector3.new(0, 1.6, 0)
			billboard.MaxDistance = 45
			billboard.Parent = part

			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamMedium
			label.TextScaled = true
			label.TextStrokeTransparency = 0.5
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Text = item.name
			label.Parent = billboard
		end
	end
end

local function catch(player: Player)
	local view = awarenessFor(player)
	local root = rootOf(player)

	local lost = HouseService.ForfeitRun(player)
	if root then
		scatter(lost, root.Position)

		-- Ejected past the gate, which sits at +z of the house origin.
		root.CFrame = CFrame.new(Config.HouseOrigin + Vector3.new(0, 4, 34))
	end

	view.heat = 0
	view.lastKnown = nil
	view.investigateUntil = 0
	view.lockedOutUntil = os.clock() + Config.CatchCooldown

	Remotes.Get("Caught"):FireClient(player, #lost)
	Remotes.Get("Notify"):FireClient(
		player,
		if #lost > 0
			then ("Caught! You dropped %d item%s in the yard."):format(#lost, if #lost == 1 then "" else "s")
			else "Caught! Lucky you weren't carrying anything.",
		"bad"
	)
end

--------------------------------------------------------------------
-- The loop
--------------------------------------------------------------------

local function targetPosition(now: number): Vector3
	-- Leash. Without this, a visible player can walk the defender across the map
	-- and leave them standing in the junkyard, which looks broken and abandons
	-- the house. They give up and go home instead.
	local body = defender and defender.PrimaryPart
	if body and (body.Position - Config.HouseOrigin).Magnitude > Config.DefenderLeash then
		setMood("", Color3.fromRGB(255, 255, 255))
		return if #route > 0 then route[routeIndex].Position else Config.HouseOrigin
	end

	-- Chase the hottest player who is actually visible or recently was.
	local bestPlayer: Player? = nil
	local bestHeat = Config.HeatSuspicious

	for player, view in awareness do
		if view.heat > bestHeat and (view.lastKnown or rootOf(player)) then
			bestHeat = view.heat
			bestPlayer = player
		end
	end

	if bestPlayer then
		local view = awarenessFor(bestPlayer)
		if view.heat >= Config.HeatChase then
			local root = rootOf(bestPlayer)
			if root then
				setMood("!", Color3.fromRGB(255, 90, 90))
				return root.Position
			end
		end
		if view.lastKnown and now < view.investigateUntil then
			setMood("?", Color3.fromRGB(255, 210, 90))
			return view.lastKnown
		end
	end

	setMood("", Color3.fromRGB(255, 255, 255))
	if #route == 0 then
		return Config.HouseOrigin
	end
	return route[routeIndex].Position
end

local function step(dt: number)
	local model = defender
	local body = model and model.PrimaryPart
	if not model or not body then
		return
	end

	local now = os.clock()

	-- Perception first, so movement reacts to this frame's information.
	for _, player in Players:GetPlayers() do
		local view = awarenessFor(player)
		local root = rootOf(player)
		local seen = root ~= nil and now >= view.lockedOutUntil and canSee(body.Position, root)

		if seen and root then
			view.heat = math.min(Config.HeatMax, view.heat + Config.HeatFromSight * dt)
			view.lastKnown = root.Position
			view.investigateUntil = now + Config.DefenderInvestigateTime
		else
			view.heat = math.max(0, view.heat - Config.HeatDecay * dt)
		end

		pushHeat(player, view)

		if
			root
			and now >= view.lockedOutUntil
			and view.heat >= Config.HeatChase
			and (root.Position - body.Position).Magnitude <= Config.DefenderCatchRange
		then
			catch(player)
		end
	end

	-- Then move.
	local goal = targetPosition(now)
	local delta = goal - body.Position
	local flat = Vector3.new(delta.X, 0, delta.Z)

	local chasing = false
	for _, view in awareness do
		if view.heat >= Config.HeatChase then
			chasing = true
			break
		end
	end

	local speed = if chasing then Config.DefenderChaseSpeed else Config.DefenderPatrolSpeed

	if flat.Magnitude < 2 then
		-- Arrived. On patrol that means advance to the next waypoint.
		if not chasing and #route > 0 then
			routeIndex = (routeIndex % #route) + 1
		end
		return
	end

	place(model, body.Position + flat.Unit * math.min(speed * dt, flat.Magnitude))
end

--------------------------------------------------------------------

function DefenderService.Init()
	if not Config.DefenderOnFirstHouse then
		return
	end

	local house = WorldBuilder.GetHouse()
	if not house then
		warn("[DefenderService] no house found — was WorldBuilder.Build() called first?")
		return
	end

	route = WorldBuilder.GetWaypoints()

	local folder = Instance.new("Folder")
	folder.Name = "DroppedLoot"
	folder.Parent = house
	droppedFolder = folder

	local model = buildDefender()
	place(model, Config.HouseOrigin + Vector3.new(0, 2, 0))
	model.Parent = house
	defender = model

	-- Searching is loud even when the drawer is empty.
	HouseService.OnSearch(function(player: Player)
		local view = awarenessFor(player)
		view.heat = math.min(Config.HeatMax, view.heat + Config.HeatFromSearch)

		local root = rootOf(player)
		if root then
			view.lastKnown = root.Position
			view.investigateUntil = os.clock() + Config.DefenderInvestigateTime
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		awareness[player] = nil
	end)

	RunService.Heartbeat:Connect(step)

	print(("[DefenderService] defender patrolling %d waypoints"):format(#route))
end

return DefenderService
