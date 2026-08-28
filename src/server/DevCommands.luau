--!strict
-- DevCommands — command-bar helpers for fast playtesting in Studio.
--
-- Every command below calls the same public, validated entry points real
-- gameplay already uses (PlotService.AddToBag, PlayerDataService.AddCash,
-- CustomerService.ForceVisit, ...). A dev command can't do anything a real
-- player couldn't already trigger through the normal flow — it just skips
-- the walk to the junkyard. Inert outside Studio: Init() no-ops entirely
-- unless RunService:IsStudio() is true.
--
-- USAGE — Studio command bar, with the context dropdown set to **Server**:
--   game.ServerStorage.SMJDev:Invoke("cash", 500)
--   game.ServerStorage.SMJDev:Invoke("giveRandom", 5)
--   game.ServerStorage.SMJDev:Invoke("customer")
--   game.ServerStorage.SMJDev:Invoke("reset")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CommunityItems = require(Shared:WaitForChild("CommunityItems"))
local ItemDatabase = require(Shared:WaitForChild("ItemDatabase"))

local CommunityService = require(script.Parent:WaitForChild("CommunityService"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local PlotService = require(script.Parent:WaitForChild("PlotService"))
local CustomerService = require(script.Parent:WaitForChild("CustomerService"))

local DevCommands = {}

-- Command bar has no concept of "local player" server-side, so these target
-- the first (solo Studio testing) player in the server.
local function firstPlayer(): Player?
	return Players:GetPlayers()[1]
end

local function give(itemId: string, count: number?)
	local player = firstPlayer()
	if not player then
		print("[SMJ] give: no player in the server yet")
		return
	end

	local item = ItemDatabase.Get(itemId)
	if not item then
		print(("[SMJ] give: unknown itemId %q"):format(itemId))
		return
	end

	local wanted = math.max(1, math.floor(count or 1))
	local added = 0
	for _ = 1, wanted do
		if PlotService.AddToBag(player, itemId) then
			added += 1
		else
			break
		end
	end

	print(("[SMJ] give: added %d/%d x %s to bag"):format(added, wanted, itemId))
end

local function giveRandom(count: number?)
	local player = firstPlayer()
	if not player then
		print("[SMJ] giveRandom: no player in the server yet")
		return
	end

	local wanted = math.max(1, math.floor(count or 1))
	local added = 0
	for _ = 1, wanted do
		local item = ItemDatabase.RollRandom()
		if PlotService.AddToBag(player, item.id) then
			added += 1
		else
			break
		end
	end

	print(("[SMJ] giveRandom: added %d/%d random items to bag"):format(added, wanted))
end

local function cash(amount: number)
	local player = firstPlayer()
	if not player then
		print("[SMJ] cash: no player in the server yet")
		return
	end

	local data = PlayerDataService.Get(player)
	if not data then
		print("[SMJ] cash: player data not loaded yet")
		return
	end

	PlayerDataService.AddCash(player, amount - data.cash)
	PlotService.Sync(player)
	print(("[SMJ] cash: set to %d"):format(amount))
end

local function customer()
	local player = firstPlayer()
	if not player then
		print("[SMJ] customer: no player in the server yet")
		return
	end

	if CustomerService.ForceVisit(player) then
		print("[SMJ] customer: forcing a visit now")
	else
		print("[SMJ] customer: player has no assigned plot yet")
	end
end

local function reset()
	local player = firstPlayer()
	if not player then
		print("[SMJ] reset: no player in the server yet")
		return
	end

	if PlayerDataService.Reset(player) then
		PlotService.RenderPlot(player)
		PlotService.Sync(player)
		print("[SMJ] reset: save data wiped to defaults")
	else
		print("[SMJ] reset: player data not loaded yet")
	end
end

-- Stands in for the Robux purchase, which is deliberately unbuilt: charging
-- money means ProcessReceipt, and OPERATING-MODEL.md §4 puts monetization in
-- Tier 3. Pass nothing for a random combination.
local function createJunk(adjective: number?, noun: number?, suffix: number?, rarity: string?)
	local player = firstPlayer()
	if not player then
		print("[SMJ] createJunk: no player in the server yet")
		return
	end

	local entry = CommunityService.Create(
		player,
		adjective or math.random(1, #CommunityItems.Adjectives),
		noun or math.random(1, #CommunityItems.Nouns),
		suffix or math.random(1, #CommunityItems.Suffixes),
		rarity or "Junk"
	)

	if entry then
		print(("[SMJ] createJunk: %q (%s, worth %d)"):format(entry.name, entry.rarity, entry.baseValue))
	else
		print("[SMJ] createJunk: rejected — bad indices, bad rarity, or pool is full")
	end
end

local COMMANDS: { [string]: any } = {
	give = give,
	giveRandom = giveRandom,
	cash = cash,
	customer = customer,
	reset = reset,
	createJunk = createJunk,
}

function DevCommands.Init()
	if not RunService:IsStudio() then
		return
	end

	-- WHY A BindableFunction AND NOT `_G`:
	-- The Studio command bar runs in a *different Luau environment* from game
	-- scripts. It shares neither `_G` nor the `require` cache — a `require` from
	-- the command bar returns a second, uninitialized copy of a module. What it
	-- does share is the DataModel, which is why `workspace.Part:Destroy()` works
	-- from there. So the bridge has to be an Instance.
	--
	-- An earlier version of this file used `_G.SMJ` and asserted in a comment
	-- that it was "the only channel" available. That was wrong and `_G.SMJ` read
	-- back nil in Studio every time. Verified 2026-08-27.
	local bridge = Instance.new("BindableFunction")
	bridge.Name = "SMJDev"

	bridge.OnInvoke = function(command: any, ...)
		local fn = if type(command) == "string" then COMMANDS[command] else nil
		if not fn then
			local names = {}
			for name in COMMANDS do
				table.insert(names, name)
			end
			table.sort(names)
			print(("[SMJ] unknown command %q — available: %s"):format(tostring(command), table.concat(names, ", ")))
			return
		end
		fn(...)
	end

	bridge.Parent = ServerStorage

	print('[SMJ] dev commands ready — e.g. game.ServerStorage.SMJDev:Invoke("giveRandom", 5)')
end

return DevCommands
