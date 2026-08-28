--!strict
-- HouseService — searching the raidable house.
--
-- Which spots hold loot lives ONLY in this table, on the server. It is never
-- an attribute and never replicated: an attribute would let a modified client
-- read which spots are worth searching, and "which of these twelve do I open?"
-- is the entire mechanic. See docs/GAME-DESIGN.md §5.
--
-- Searched/populated state is deliberately in memory and resets when the server
-- does. Persisting it needs schema v2 (docs/PERSISTENCE.md §3) and is a
-- separate brief.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local ItemDatabase = require(Shared:WaitForChild("ItemDatabase"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local PlotService = require(script.Parent:WaitForChild("PlotService"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

local HouseService = {}

local rng = Random.new()

type SpotState = { hasLoot: boolean, searched: boolean }

local spots: { BasePart } = {}
local spotState: { [BasePart]: SpotState } = {}

-- Loot taken during the CURRENT raid, per player. This is the only thing a
-- catch can take (docs/GAME-DESIGN.md §5) — anything banked by leaving through
-- the gate, and anything carried in from elsewhere, is untouchable.
local runLoot: { [Player]: { string } } = {}

-- DefenderService subscribes here rather than HouseService calling it directly:
-- DefenderService already requires HouseService (for ForfeitRun), so a direct
-- call back the other way would be a require cycle.
local searchCallbacks: { (player: Player) -> () } = {}

function HouseService.OnSearch(callback: (player: Player) -> ())
	table.insert(searchCallbacks, callback)
end

local function notify(player: Player, text: string, kind: string?)
	Remotes.Get("Notify"):FireClient(player, text, kind or "info")
end

local function promptOf(spot: BasePart): ProximityPrompt?
	local prompt = spot:FindFirstChild("SearchPrompt")
	return if prompt and prompt:IsA("ProximityPrompt") then prompt else nil
end

local function spotName(spot: BasePart): string
	return tostring(spot:GetAttribute("SpotName") or "Something")
end

--------------------------------------------------------------------
-- Restocking
--------------------------------------------------------------------

-- Fisher-Yates: walk the list backwards swapping each element with a random
-- earlier one. Gives a uniform shuffle in one pass, unlike sorting by a random
-- comparator, which is biased and can error on some sort implementations.
local function shuffled(list: { BasePart }): { BasePart }
	local copy = table.clone(list)
	for i = #copy, 2, -1 do
		local j = rng:NextInteger(1, i)
		copy[i], copy[j] = copy[j], copy[i]
	end
	return copy
end

local function restock()
	for _, spot in spots do
		spotState[spot] = { hasLoot = false, searched = false }
		local prompt = promptOf(spot)
		if prompt then
			prompt.Enabled = true
		end
	end

	local populated = rng:NextInteger(Config.HouseSpotsPopulatedMin, Config.HouseSpotsPopulatedMax)
	local order = shuffled(spots)

	for i = 1, math.min(populated, #order) do
		spotState[order[i]].hasLoot = true
	end
end

--------------------------------------------------------------------
-- Searching
--------------------------------------------------------------------

local function onSearched(spot: BasePart, player: Player)
	local state = spotState[spot]
	if not state or state.searched then
		return
	end

	local name = spotName(spot)

	-- Searching makes noise whether or not it paid off. Rummaging through an
	-- empty cupboard is exactly as loud as a full one.
	for _, callback in searchCallbacks do
		task.spawn(callback, player)
	end

	if not state.hasLoot then
		state.searched = true
		local prompt = promptOf(spot)
		if prompt then
			prompt.Enabled = false
		end
		notify(player, ("Nothing in the %s."):format(name))
		return
	end

	-- Check capacity BEFORE consuming the spot, so a full bag doesn't silently
	-- destroy the item the player just spent 1.5 seconds finding.
	local item = ItemDatabase.RollRandom(rng)
	local uid = PlotService.AddToBag(player, item.id)
	if not uid then
		notify(player, "Your bag is full — come back for it.", "bad")
		return
	end

	state.searched = true
	local prompt = promptOf(spot)
	if prompt then
		prompt.Enabled = false
	end

	local run = runLoot[player]
	if run then
		table.insert(run, uid :: string)
	end

	notify(player, ("Found: %s"):format(item.name), "good")
end

--------------------------------------------------------------------
-- Raid runs — what a catch can actually take
--------------------------------------------------------------------

function HouseService.StartRun(player: Player)
	if not runLoot[player] then
		runLoot[player] = {}
	end
end

-- Left through the gate: everything found this raid is now just yours.
function HouseService.BankRun(player: Player): number
	local run = runLoot[player]
	runLoot[player] = nil
	return if run then #run else 0
end

-- Caught: drop everything found this raid. Returns the items so the caller can
-- scatter them in the yard rather than deleting them.
function HouseService.ForfeitRun(player: Player): { string }
	local run = runLoot[player]
	runLoot[player] = nil
	if not run or #run == 0 then
		return {}
	end

	local data = PlayerDataService.Get(player)
	if not data then
		return {}
	end

	-- Resolve uids to item ids before removing them, so the caller knows what to
	-- put on the ground.
	local lost: { string } = {}
	local wanted: { [string]: boolean } = {}
	for _, uid in run do
		wanted[uid] = true
	end
	for _, entry in data.bag do
		if wanted[entry.uid] then
			table.insert(lost, entry.itemId)
		end
	end

	PlotService.RemoveFromBag(player, run)
	return lost
end

function HouseService.IsRaiding(player: Player): boolean
	return runLoot[player] ~= nil
end

--------------------------------------------------------------------

--------------------------------------------------------------------
-- The yard boundary — where a run starts and where it banks
--------------------------------------------------------------------

-- Matches the fence built in WorldBuilder.buildHouse. Polled rather than using
-- Touched on a zone part: Touched misses fast movement and fires repeatedly on
-- a body's many parts, which makes "am I inside?" unreliable.
local YARD_HALF_X = 25
local YARD_HALF_Z = 22

local function inYard(position: Vector3): boolean
	local delta = position - Config.HouseOrigin
	return math.abs(delta.X) <= YARD_HALF_X and math.abs(delta.Z) <= YARD_HALF_Z
end

local function watchYard()
	while true do
		task.wait(0.25)

		for _, player in Players:GetPlayers() do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and root:IsA("BasePart") then
				local inside = inYard(root.Position)
				local raiding = HouseService.IsRaiding(player)

				if inside and not raiding then
					HouseService.StartRun(player)
				elseif not inside and raiding then
					local banked = HouseService.BankRun(player)
					if banked > 0 then
						notify(
							player,
							("Out clean with %d item%s."):format(banked, if banked == 1 then "" else "s"),
							"good"
						)
					end
				end
			end
		end
	end
end

--------------------------------------------------------------------

function HouseService.Init()
	spots = WorldBuilder.GetSearchSpots()

	if #spots == 0 then
		warn("[HouseService] no search spots found — was WorldBuilder.Build() called first?")
		return
	end

	for _, spot in spots do
		local prompt = promptOf(spot)
		if prompt then
			prompt.Triggered:Connect(function(player: Player)
				onSearched(spot, player)
			end)
		end
	end

	restock()

	task.spawn(function()
		while true do
			task.wait(Config.HouseRestockInterval)
			restock()
		end
	end)

	task.spawn(watchYard)

	Players.PlayerRemoving:Connect(function(player)
		-- Leaving mid-raid keeps what you were carrying. Resolving a disconnect
		-- as a catch is the correct anti-combat-log behaviour (PERSISTENCE.md
		-- §5) but belongs with the persistence work, not here.
		runLoot[player] = nil
	end)

	print(("[HouseService] house ready — %d search spots"):format(#spots))
end

return HouseService
