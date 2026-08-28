--!strict
-- CommunityService — owns player-created junk: creation, expiry, replication.
--
-- STORAGE IS IN MEMORY FOR NOW. A real deployment needs a shared DataStore so
-- creations exist on every server and survive restarts — that is its own brief
-- alongside schema v2 (docs/PERSISTENCE.md §3). Prototyping the *feel* of
-- finding another player's junk doesn't need it, and pretending otherwise would
-- mean shipping a cross-server DataStore nobody has reviewed.
--
-- THERE IS NO PURCHASE PATH HERE ON PURPOSE. Creation is called by a dev
-- command. Charging Robux means MarketplaceService.ProcessReceipt, which must be
-- idempotent or it double-grants / takes money without delivering — and
-- OPERATING-MODEL.md §4 puts monetization in Tier 3, never unattended.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CommunityItems = require(Shared:WaitForChild("CommunityItems"))
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local CommunityService = {}

local nextSerial = 0

local function replicate(player: Player?)
	local payload = CommunityItems.All()
	if player then
		Remotes.Get("CommunitySync"):FireClient(player, payload)
	else
		Remotes.Get("CommunitySync"):FireAllClients(payload)
	end
end

--------------------------------------------------------------------
-- Creation
--------------------------------------------------------------------

-- Takes word-list INDICES, never strings. Nothing a player typed reaches this
-- function, so there is no text to filter and no way to smuggle a slur through.
function CommunityService.Create(
	player: Player,
	adjective: number,
	noun: number,
	suffix: number,
	rarity: string
): CommunityItems.CommunityItem?
	if type(adjective) ~= "number" or type(noun) ~= "number" or type(suffix) ~= "number" then
		return nil
	end

	local allowed = false
	for _, candidate in CommunityItems.AllowedRarities do
		if candidate == rarity then
			allowed = true
			break
		end
	end
	if not allowed then
		return nil
	end

	local name = CommunityItems.BuildName(math.floor(adjective), math.floor(noun), math.floor(suffix))
	if not name then
		return nil
	end

	if CommunityItems.Count() >= Config.CommunityMaxLive then
		return nil
	end

	nextSerial += 1
	local now = os.time()

	local entry: CommunityItems.CommunityItem = {
		id = ("%s%d_%d"):format(CommunityItems.PREFIX, player.UserId, nextSerial),
		name = name,
		desc = CommunityItems.Descriptions[math.random(1, #CommunityItems.Descriptions)],
		rarity = rarity,
		-- Server-derived. The creator never sees a value field.
		baseValue = CommunityItems.RarityValue[rarity] or 12,
		creatorName = player.DisplayName,
		creatorUserId = player.UserId,
		createdAt = now,
		expiresAt = now + Config.CommunityLifetimeDays * 86400,
		finds = 0,
		sales = 0,
	}

	CommunityItems.Register(entry)
	replicate(nil)

	print(("[CommunityService] %s created %q (%s)"):format(player.Name, entry.name, entry.id))
	return entry
end

--------------------------------------------------------------------
-- Engagement — the only "rating" we keep
--
-- No upvotes and no downvotes: brigading is real, and telling a nine-year-old
-- their creation was voted down is a feel-bad machine pointed at the players who
-- cared most. Counting finds and sales measures the same thing quietly.
--------------------------------------------------------------------

function CommunityService.NoteFind(itemId: string)
	local entry = CommunityItems.Get(itemId)
	if entry then
		entry.finds += 1
	end
end

function CommunityService.NoteSale(itemId: string)
	local entry = CommunityItems.Get(itemId)
	if entry then
		entry.sales += 1
	end
end

--------------------------------------------------------------------
-- Rolling one into the loot pool
--------------------------------------------------------------------

function CommunityService.Roll(rng: Random): CommunityItems.CommunityItem?
	local pool = CommunityItems.All()
	if #pool == 0 or rng:NextNumber() > Config.CommunityDropChance then
		return nil
	end
	return pool[rng:NextInteger(1, #pool)]
end

--------------------------------------------------------------------
-- Expiry
--------------------------------------------------------------------

-- Items rotate out after their month. Popularity does NOT extend a life here on
-- its own — the reward for a popular item is promotion into ItemDatabase by a
-- human curator, which is a deliberate editorial act, not an automatic one.
local function sweep()
	local now = os.time()
	local removed = 0

	for _, entry in CommunityItems.All() do
		if now >= entry.expiresAt then
			CommunityItems.Remove(entry.id)
			removed += 1
			print(
				("[CommunityService] retired %q by %s — %d finds, %d sales"):format(
					entry.name,
					entry.creatorName,
					entry.finds,
					entry.sales
				)
			)
		end
	end

	if removed > 0 then
		replicate(nil)
	end
end

--------------------------------------------------------------------

function CommunityService.Init()
	Players.PlayerAdded:Connect(function(player)
		replicate(player)
	end)
	for _, player in Players:GetPlayers() do
		replicate(player)
	end

	task.spawn(function()
		while true do
			task.wait(Config.CommunitySweepInterval)
			sweep()
		end
	end)
end

return CommunityService
