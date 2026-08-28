--!strict
-- DevCommands — command-bar helpers for fast playtesting in Studio.
--
-- Every command below calls the same public, validated entry points real
-- gameplay already uses (PlotService.AddToBag, PlayerDataService.AddCash,
-- CustomerService.ForceVisit, ...). A dev command can't do anything a real
-- player couldn't already trigger through the normal flow — it just skips
-- the walk to the junkyard. Inert outside Studio: Init() no-ops entirely
-- unless RunService:IsStudio() is true.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ItemDatabase = require(Shared:WaitForChild("ItemDatabase"))

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

function DevCommands.Init()
	if not RunService:IsStudio() then
		return
	end

	-- selene: allow(global_usage)
	-- _G is the only channel the Studio command bar can reach into a running
	-- server script from, so this is the sanctioned exception, not a slip.
	_G.SMJ = {
		give = give,
		giveRandom = giveRandom,
		cash = cash,
		customer = customer,
		reset = reset,
	}

	print("[SMJ] dev commands ready: _G.SMJ.give/giveRandom/cash/customer/reset")
end

return DevCommands
