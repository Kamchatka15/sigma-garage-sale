--!strict
-- PlayerDataService — owns every player's save data. Single source of truth.
--
-- Nothing else in the codebase touches DataStores. If you need player state,
-- you ask this module. That constraint is what makes a schema migration a
-- one-file change instead of an archaeology project — and it's why swapping
-- the storage backend to ProfileStore touched only this file.
--
-- WHY PROFILESTORE: the previous implementation used SetAsync with no session
-- locking, which meant two servers could hold the same player's data at once.
-- That's the standard Roblox duplication exploit (join A, drop items, rejoin
-- fast into B which loaded the pre-drop save) and a real data-loss path for
-- honest players. ProfileStore session-locks a profile to one server at a time.
-- See docs/PERSISTENCE.md §7 for the alternatives considered.
--
-- Studio note: if "Enable Studio Access to API Services" is off, ProfileStore
-- reports DataStoreState = "NoAccess". We fall back to its Mock store so the
-- game still runs, and warn loudly — a mock save that looks like it works is
-- how you ship a broken save path.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CommunityItems = require(Shared:WaitForChild("CommunityItems"))
local Config = require(Shared:WaitForChild("Config"))

local ProfileStore = require(script.Parent:WaitForChild("Packages"):WaitForChild("ProfileStore"))

local PlayerDataService = {}

export type BagItem = { uid: string, itemId: string }
export type ShelfEntry = { uid: string, itemId: string, price: number }
export type Knowledge = { sales: number, total: number, best: number, last: number }

export type SaveData = {
	schemaVersion: number,
	cash: number,
	bag: { BagItem },
	shelves: { [string]: ShelfEntry }, -- keyed by tostring(index); DataStores drop sparse arrays
	upgrades: { [string]: number },
	knowledge: { [string]: Knowledge },
	stats: { totalSales: number, totalEarned: number },
}

--------------------------------------------------------------------
-- Defaults and migration
--------------------------------------------------------------------

local function defaultData(): SaveData
	return {
		schemaVersion = Config.SchemaVersion,
		cash = Config.StartingCash,
		bag = {},
		shelves = {},
		upgrades = { shelves = 0, bagSize = 0, stallLevel = 0, customerRate = 0 },
		knowledge = {},
		stats = { totalSales = 0, totalEarned = 0 },
	}
end

-- Add a `migrate` branch here whenever SchemaVersion increases. Never silently
-- reshape saved data — a bad migration is the one bug that loses real players
-- their real progress, and it cannot be undone.
--
-- Note: purely *additive* fields are already handled by Profile:Reconcile(),
-- which fills in anything the template has and the save lacks. This function is
-- for changes Reconcile can't express — renames, type changes, recomputations.
local function migrate(data: SaveData)
	if data.schemaVersion == Config.SchemaVersion then
		return
	end

	warn(("[PlayerDataService] migrating save v%d -> v%d"):format(data.schemaVersion or 0, Config.SchemaVersion))
	data.schemaVersion = Config.SchemaVersion
end

--------------------------------------------------------------------
-- Store resolution
--------------------------------------------------------------------

local profileStore = ProfileStore.New(Config.DataStoreName, defaultData())
local resolvedStore = nil

-- DataStoreState starts as "NotReady" and settles asynchronously, so the first
-- caller waits briefly for the real answer rather than guessing.
local function getStore()
	if resolvedStore then
		return resolvedStore
	end

	local deadline = os.clock() + 5
	while ProfileStore.DataStoreState == "NotReady" and os.clock() < deadline do
		task.wait(0.1)
	end

	if ProfileStore.DataStoreState == "Access" then
		resolvedStore = profileStore
	else
		warn(
			("[PlayerDataService] DataStore unavailable (%s) — using mock store. NOTHING WILL PERSIST."):format(
				ProfileStore.DataStoreState
			)
		)
		resolvedStore = profileStore.Mock
	end

	return resolvedStore
end

--------------------------------------------------------------------
-- Load / save
--------------------------------------------------------------------

local profiles: { [Player]: any } = {}
local changedCallbacks: { (player: Player) -> () } = {}

local function keyFor(player: Player): string
	return "player_" .. tostring(player.UserId)
end

function PlayerDataService.Load(player: Player): SaveData?
	if profiles[player] then
		return profiles[player].Data
	end

	local profile = getStore():StartSessionAsync(keyFor(player), {
		-- Stop trying to claim the session if the player already gave up and left.
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if not profile then
		player:Kick("Could not load your data. Please rejoin.")
		return nil
	end

	profile:AddUserId(player.UserId) -- GDPR association
	profile:Reconcile() -- fill in anything a newer template added
	migrate(profile.Data)

	-- Fires when another server takes the session, or we end it ourselves. The
	-- player's data is no longer saveable at this point, so letting them keep
	-- playing would silently discard everything they do next.
	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		if player.Parent == Players then
			player:Kick("Your data was opened on another server. Please rejoin.")
		end
	end)

	-- The player may have left while StartSessionAsync was yielding.
	if player.Parent ~= Players then
		profile:EndSession()
		return nil
	end

	profiles[player] = profile
	return profile.Data
end

-- ProfileStore autosaves on its own schedule. This forces an immediate write for
-- the moments where losing even one autosave interval is unacceptable — house
-- and cosmetic purchases (see docs/PERSISTENCE.md §4).
function PlayerDataService.Save(player: Player): boolean
	local profile = profiles[player]
	if not profile or not profile:IsActive() then
		return false
	end
	profile:Save()
	return true
end

function PlayerDataService.Get(player: Player): SaveData?
	local profile = profiles[player]
	return if profile then profile.Data else nil
end

--------------------------------------------------------------------
-- Mutation helpers
--
-- Everything that changes player state goes through here so that exactly one
-- place is responsible for firing the "something changed" signal. Clients
-- never get pushed a partial view they then have to reconcile.
--------------------------------------------------------------------

function PlayerDataService.MarkChanged(player: Player)
	for _, callback in changedCallbacks do
		task.spawn(callback, player)
	end
end

function PlayerDataService.OnChanged(callback: (player: Player) -> ())
	table.insert(changedCallbacks, callback)
end

function PlayerDataService.AddCash(player: Player, amount: number)
	local data = PlayerDataService.Get(player)
	if not data then
		return
	end
	data.cash += amount
	PlayerDataService.MarkChanged(player)
end

-- Wipes a loaded player back to defaultData(). Same shape defaultData() always
-- produces, so this is not a schema change — just re-applying it on demand.
--
-- Clears in place rather than reassigning Profile.Data: ProfileStore's contract
-- is that changes *to that table* are saved, so swapping the reference out is
-- not obviously safe.
function PlayerDataService.Reset(player: Player): boolean
	local data = PlayerDataService.Get(player)
	if not data then
		return false
	end

	local fresh = defaultData()
	table.clear(data :: any)
	for key, value in fresh :: any do
		(data :: any)[key] = value
	end

	PlayerDataService.MarkChanged(player)
	return true
end

function PlayerDataService.NewUid(): string
	return HttpService:GenerateGUID(false)
end

function PlayerDataService.BagCount(data: SaveData): number
	return #data.bag
end

function PlayerDataService.BagCapacity(data: SaveData): number
	return Config.BagSlots(data.upgrades.bagSize or 0)
end

function PlayerDataService.ShelfCapacity(data: SaveData): number
	return Config.ShelfCount(data.upgrades.shelves or 0)
end

-- Records a sale against the player's knowledge of that item type. This is the
-- progression system: what you know is worth more than what you have.
function PlayerDataService.RecordSale(player: Player, itemId: string, price: number)
	local data = PlayerDataService.Get(player)
	if not data then
		return
	end

	-- Community junk never enters the knowledge table. The appraisal system only
	-- works on a finite, learnable set; letting an open-ended player-created pool
	-- in would mean nothing is ever fully learnable and the progression quietly
	-- dies. Stats still count — you earned the money, it just taught you nothing.
	if CommunityItems.IsCommunity(itemId) then
		data.stats.totalSales += 1
		data.stats.totalEarned += price
		return
	end

	local entry = data.knowledge[itemId]
	if not entry then
		entry = { sales = 0, total = 0, best = 0, last = 0 }
		data.knowledge[itemId] = entry
	end

	entry.sales += 1
	entry.total += price
	entry.last = price
	if price > entry.best then
		entry.best = price
	end

	data.stats.totalSales += 1
	data.stats.totalEarned += price
end

-- How much the player has learned about an item: "none" | "last" | "average"
-- | "range" | "appraised"
function PlayerDataService.KnowledgeTier(data: SaveData, itemId: string): string
	local entry = data.knowledge[itemId]
	if not entry then
		return "none"
	end

	local tier = "none"
	for _, threshold in Config.KnowledgeTiers do
		if entry.sales >= threshold.sales then
			tier = threshold.reveal
		end
	end
	return tier
end

--------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------

function PlayerDataService.Init()
	Players.PlayerRemoving:Connect(function(player)
		local profile = profiles[player]
		if profile then
			profile:EndSession() -- flushes and releases the session lock
		end
	end)

	-- No autosave loop and no BindToClose here on purpose: ProfileStore owns
	-- both. Duplicating them was also the source of the double-save-on-shutdown
	-- noted in BACKLOG.md, which this removes.
end

return PlayerDataService
