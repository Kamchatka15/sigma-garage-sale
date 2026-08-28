--!strict
-- Config — every tunable number in the game lives here.
--
-- Rule: no magic numbers anywhere else in the codebase. When you're tuning in
-- Phase 3 you want one file open, not fourteen.
--
-- Upgrade levels ALL start at 0 and the real value is derived by the helper
-- functions at the bottom. Storing levels rather than derived values means a
-- balance change re-tunes existing save files for free instead of stranding
-- everyone who already bought the upgrade.

local Config = {}

--------------------------------------------------------------------
-- PLAYER START STATE
--------------------------------------------------------------------
Config.StartingCash = 50
Config.StartingShelves = 3
Config.StartingBagSlots = 8

--------------------------------------------------------------------
-- SCAVENGING (the junkyard)
--------------------------------------------------------------------
Config.JunkSpawnInterval = 1.5 -- seconds between new junk piles appearing
Config.MaxJunkInYard = 45 -- cap so the yard never floods
Config.JunkDespawnTime = 120 -- uncollected junk disappears after this

--------------------------------------------------------------------
-- CUSTOMERS
--------------------------------------------------------------------
Config.BaseCustomerInterval = 11.0 -- seconds between customers at a stall
Config.MinCustomerInterval = 2.0 -- floor, no matter how many upgrades
Config.CustomerBrowseTime = 2.2 -- how long they consider your shelves
Config.CustomerWalkTime = 2.5 -- seconds to walk in (and again to walk out)

-- Taste: each customer values an item at baseValue * taste.
-- The range is deliberately WIDE. A narrow range makes optimal pricing
-- solvable in ten minutes and the game becomes rote data entry.
Config.TasteMin = 0.55
Config.TasteMax = 1.75

-- Whales: rare customers with deep pockets. These are the clip moments.
Config.WhaleChance = 0.05
Config.WhaleWalletMult = 6.0
Config.WhaleTasteBonus = 0.45

-- Base wallet range, before stall-level scaling
Config.WalletMin = 25
Config.WalletMax = 120

--------------------------------------------------------------------
-- HOUSES (raidable)
--
-- Populated spots are a RANGE, not a fixed count: a fixed number would let a
-- player stop searching the moment they'd found it, which removes the decision
-- the whole mechanic is built on.
--------------------------------------------------------------------
Config.HouseOrigin = Vector3.new(0, 0, -90)
Config.HouseSearchSpots = 12 -- total spots built into the house
Config.HouseSpotsPopulatedMin = 4 -- how many hold loot on a given restock
Config.HouseSpotsPopulatedMax = 6
Config.SearchHoldDuration = 1.5 -- seconds to search one spot
Config.HouseRestockInterval = 90 -- seconds before spots repopulate

--------------------------------------------------------------------
-- DEFENDERS AND HEAT
--
-- Heat is the readable risk dial (docs/GAME-DESIGN.md §5). It must always be
-- something the player did — searching, being seen — never a random gotcha.
-- Chase speed sits just under the default character walkspeed of 16 on purpose:
-- a caught player should feel they were cornered, not simply outrun.
--------------------------------------------------------------------

-- DEV TOGGLE — must be false before launch. docs/FIRST-SESSION.md §3 requires
-- the Fixer-Upper to be defender-free so a player's first raid can't fail. It
-- is true now only because it is the only house that exists to test against.
Config.DefenderOnFirstHouse = true

Config.DefenderPatrolSpeed = 7
Config.DefenderChaseSpeed = 14
Config.DefenderSightRange = 36
Config.DefenderCatchRange = 4.5
Config.DefenderInvestigateTime = 6 -- seconds spent at a last-known position
Config.DefenderLeash = 62 -- studs from the house before they give up and go home

Config.HeatMax = 100
Config.HeatFromSight = 44 -- per second while in line of sight
Config.HeatFromSearch = 20 -- one-off, per spot searched
Config.HeatDecay = 14 -- per second while unobserved
Config.HeatSuspicious = 40 -- defender investigates your last known position
Config.HeatChase = 78 -- defender pursues directly
Config.CatchCooldown = 10 -- seconds before you may re-enter after a catch

--------------------------------------------------------------------
-- COMMUNITY JUNK (player-created)
--------------------------------------------------------------------
Config.CommunityLifetimeDays = 30 -- must be disclosed before any purchase
Config.CommunityMaxLive = 60 -- ceiling on the live pool
Config.CommunityDropChance = 0.12 -- chance a found item is a community one
Config.CommunitySweepInterval = 300 -- seconds between expiry checks

--------------------------------------------------------------------
-- PRICING
--------------------------------------------------------------------
Config.MinPrice = 1
Config.MaxPriceMultiplier = 25 -- can't list above 25x base value

--------------------------------------------------------------------
-- KNOWLEDGE / APPRAISAL
-- Progression is knowledge, not just currency. See GAME-DESIGN.md §3.
--------------------------------------------------------------------
Config.KnowledgeTiers = {
	{ sales = 1, reveal = "last" }, -- "Sold for 480."
	{ sales = 3, reveal = "average" }, -- "Average sale: 512"
	{ sales = 5, reveal = "range" }, -- "Typical range: 400-900"
	{ sales = 10, reveal = "appraised" }, -- exact base value + optimal band
}

--------------------------------------------------------------------
-- UPGRADES
-- cost(level) = price to go from `level` to `level + 1`. Levels start at 0.
--------------------------------------------------------------------
Config.Upgrades = {
	shelves = {
		name = "Extra Shelf",
		desc = "One more slot to display junk.",
		maxLevel = 9,
		cost = function(level: number): number
			return math.floor(120 * (1.85 ^ level))
		end,
	},
	bagSize = {
		name = "Bigger Bag",
		desc = "Carry more junk back from the yard.",
		maxLevel = 20,
		cost = function(level: number): number
			return math.floor(80 * (1.6 ^ level))
		end,
	},
	stallLevel = {
		name = "Nicer Stall",
		desc = "Attracts customers with fatter wallets.",
		maxLevel = 25,
		cost = function(level: number): number
			return math.floor(200 * (1.7 ^ level))
		end,
	},
	customerRate = {
		name = "Street Sign",
		desc = "Customers show up more often.",
		maxLevel = 15,
		cost = function(level: number): number
			return math.floor(150 * (1.75 ^ level))
		end,
	},
}

Config.UpgradeOrder = { "shelves", "bagSize", "stallLevel", "customerRate" }

--------------------------------------------------------------------
-- DERIVED VALUES — the only place levels turn into real numbers
--------------------------------------------------------------------
function Config.ShelfCount(level: number): number
	return Config.StartingShelves + level
end

function Config.BagSlots(level: number): number
	return Config.StartingBagSlots + level * 2
end

function Config.WalletMultiplier(stallLevel: number): number
	return 1 + stallLevel * 0.85
end

function Config.CustomerInterval(rateLevel: number): number
	local interval = Config.BaseCustomerInterval * (0.88 ^ rateLevel)
	return math.max(Config.MinCustomerInterval, interval)
end

--------------------------------------------------------------------
-- MONETIZATION HOOKS
-- Fill in real IDs from the Creator Dashboard once published.
-- Convenience and cosmetics only — no paid randomness, no progression walls.
-- See CLAUDE.md "Design guardrails".
--------------------------------------------------------------------
Config.GamePasses = {
	autoCollect = { id = 0, name = "Magnet Gloves", desc = "Auto-collect junk you walk near." },
	offlineBoost = { id = 0, name = "Night Shift", desc = "2x offline earnings." },
	extraBag = { id = 0, name = "Cargo Pants", desc = "+10 permanent bag slots." },
}

--------------------------------------------------------------------
-- PERSISTENCE
--------------------------------------------------------------------
Config.SchemaVersion = 1
Config.DataStoreName = "SellMyJunk_v1"
Config.AutosaveInterval = 120

--------------------------------------------------------------------
-- WORLD LAYOUT (WorldBuilder generates all of this at runtime)
--------------------------------------------------------------------
Config.PlotCount = 6
Config.PlotSpacing = 44
Config.PlotOrigin = Vector3.new(-110, 0, 0)
Config.JunkyardCenter = Vector3.new(0, 0, 140)
Config.JunkyardSize = Vector3.new(150, 1, 130)

return Config
