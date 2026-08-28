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

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local ItemDatabase = require(Shared:WaitForChild("ItemDatabase"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlotService = require(script.Parent:WaitForChild("PlotService"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

local HouseService = {}

local rng = Random.new()

type SpotState = { hasLoot: boolean, searched: boolean }

local spots: { BasePart } = {}
local spotState: { [BasePart]: SpotState } = {}

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
	if not PlotService.AddToBag(player, item.id) then
		notify(player, "Your bag is full — come back for it.", "bad")
		return
	end

	state.searched = true
	local prompt = promptOf(spot)
	if prompt then
		prompt.Enabled = false
	end
	notify(player, ("Found: %s"):format(item.name), "good")
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

	print(("[HouseService] house ready — %d search spots"):format(#spots))
end

return HouseService
