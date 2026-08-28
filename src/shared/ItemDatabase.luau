--!strict
-- ItemDatabase — every piece of junk in the game.
--
-- The humor lives HERE, not in the models. A grey cube labeled
-- "Jar of Old Air (2003 Vintage)" is funnier than a detailed mesh of a jar,
-- costs zero minutes to produce, and scales to 200 items as a writing task.
-- See docs/GAME-DESIGN.md §9.

local CommunityItems = require(script.Parent:WaitForChild("CommunityItems"))

local ItemDatabase = {}

export type Item = {
	id: string,
	name: string,
	desc: string,
	rarity: string,
	baseValue: number,
}

ItemDatabase.Rarities = {
	Junk = { weight = 52, color = Color3.fromRGB(155, 155, 155) },
	Common = { weight = 29, color = Color3.fromRGB(120, 205, 120) },
	Odd = { weight = 13, color = Color3.fromRGB(95, 165, 255) },
	Cursed = { weight = 5, color = Color3.fromRGB(190, 110, 255) },
	Legendary = { weight = 1, color = Color3.fromRGB(255, 190, 60) },
}

ItemDatabase.RarityOrder = { "Junk", "Common", "Odd", "Cursed", "Legendary" }

-- A coarse "what's this tier roughly worth" number, used to seed the default
-- asking price when a player shelves an item they haven't appraised yet.
--
-- WHY this exists: seeding from the item's real baseValue would hand the player
-- the answer to the core puzzle the first time they shelve anything. Rarity is
-- already visible from the item's color, so seeding from rarity leaks nothing
-- they can't see.
ItemDatabase.RarityGuess = {
	Junk = 10,
	Common = 40,
	Odd = 150,
	Cursed = 700,
	Legendary = 6000,
}

local items: { Item } = {
	-- ===================== JUNK =====================
	{
		id = "left_shoe",
		name = "Left Shoe",
		desc = "Just the one. Size unknown. Slightly warm.",
		rarity = "Junk",
		baseValue = 6,
	},
	{
		id = "cable_bag",
		name = "Bag of Assorted Cables",
		desc = "None of them go to anything you own.",
		rarity = "Junk",
		baseValue = 9,
	},
	{
		id = "expired_coupons",
		name = "Expired Coupon Book",
		desc = "Every offer ended in 2011. The savings were real once.",
		rarity = "Junk",
		baseValue = 5,
	},
	{
		id = "three_leg_chair",
		name = "Chair With Three Legs",
		desc = "Structurally a stool if you're optimistic.",
		rarity = "Junk",
		baseValue = 12,
	},
	{
		id = "torn_poster",
		name = "Motivational Poster (Torn)",
		desc = "It says 'PERSIST' but the rest is missing.",
		rarity = "Junk",
		baseValue = 8,
	},
	{
		id = "one_rollerblade",
		name = "One Rollerblade",
		desc = "Half a hobby. Endless possibility.",
		rarity = "Junk",
		baseValue = 11,
	},
	{
		id = "old_toothbrush",
		name = "Slightly Used Toothbrush",
		desc = "We are not going to discuss the bristles.",
		rarity = "Junk",
		baseValue = 4,
	},
	{
		id = "wet_fishtank",
		name = "Fish Tank (No Fish)",
		desc = "Still wet. Nobody knows why. Nobody is asking.",
		rarity = "Junk",
		baseValue = 14,
	},
	{
		id = "broken_umbrella",
		name = "Umbrella Skeleton",
		desc = "The fabric left. The frame stayed. A story of loss.",
		rarity = "Junk",
		baseValue = 7,
	},
	{
		id = "unknown_manual",
		name = "Manual For Unknown Device",
		desc = "247 pages. Never identifies the device.",
		rarity = "Junk",
		baseValue = 10,
	},

	-- ===================== COMMON =====================
	{
		id = "fourth_trophy",
		name = "Trophy For 4th Place",
		desc = "So close to a story worth telling.",
		rarity = "Common",
		baseValue = 28,
	},
	{
		id = "tupperware",
		name = "Grandma's Mystery Tupperware",
		desc = "Sealed since the Obama administration. Do not open indoors.",
		rarity = "Common",
		baseValue = 45,
	},
	{
		id = "wedding_vhs",
		name = "VHS: 'WEDDING 1997'",
		desc = "Someone's whole day. Now forty dollars to a stranger.",
		rarity = "Common",
		baseValue = 38,
	},
	{
		id = "solid_lavalamp",
		name = "Lava Lamp (Solidified)",
		desc = "The lava has retired. It is now a lamp with a secret.",
		rarity = "Common",
		baseValue = 33,
	},
	{
		id = "giant_fork",
		name = "Novelty Giant Fork",
		desc = "Wall decor. Weapon-adjacent. Great conversation starter.",
		rarity = "Common",
		baseValue = 52,
	},
	{
		id = "old_cake",
		name = "Half-Eaten Birthday Cake",
		desc = "The candles say 7. The mold says considerably older.",
		rarity = "Common",
		baseValue = 22,
	},
	{
		id = "one_song_karaoke",
		name = "Karaoke Machine",
		desc = "Only plays one song. Won't say which until you buy it.",
		rarity = "Common",
		baseValue = 58,
	},
	{
		id = "participation",
		name = "Participation Medal",
		desc = "You were there. That counted for something, apparently.",
		rarity = "Common",
		baseValue = 25,
	},
	{
		id = "antique_knob",
		name = "Antique Doorknob",
		desc = "From a door that no longer exists. Outlived its purpose.",
		rarity = "Common",
		baseValue = 41,
	},
	{
		id = "opened_capsule",
		name = "Time Capsule (Opened)",
		desc = "Someone already read the letter. They seemed disappointed.",
		rarity = "Common",
		baseValue = 47,
	},

	-- ===================== ODD =====================
	{
		id = "jar_of_air",
		name = "Jar of Old Air",
		desc = "2003 vintage. Notes of basement. Sommeliers are divided.",
		rarity = "Odd",
		baseValue = 130,
	},
	{
		id = "support_brick",
		name = "Emotional Support Brick",
		desc = "It has never once let anyone down. Can't say that about people.",
		rarity = "Odd",
		baseValue = 95,
	},
	{
		id = "mystery_key",
		name = "Mysterious Key",
		desc = "Opens something. Somewhere. The search is the point.",
		rarity = "Odd",
		baseValue = 175,
	},
	{
		id = "celeb_rock",
		name = "Rock Shaped Like Someone",
		desc = "You know who it is. You just can't say it out loud.",
		rarity = "Odd",
		baseValue = 110,
	},
	{
		id = "retired_puppet",
		name = "Sock Puppet (Retired)",
		desc = "Had a good run on local access television. Doesn't talk now.",
		rarity = "Odd",
		baseValue = 88,
	},
	{
		id = "bucket_of_rain",
		name = "Bucket of Rain",
		desc = "From a specific storm. The label names the date. It matters.",
		rarity = "Odd",
		baseValue = 145,
	},
	{
		id = "nobody_autograph",
		name = "Autographed Photo of Nobody",
		desc = "Signature illegible. Photo is an empty chair. Authentic.",
		rarity = "Odd",
		baseValue = 205,
	},
	{
		id = "moon_rock",
		name = "Genuine Moon Rock",
		desc = "Probably gravel. Comes with a certificate someone printed.",
		rarity = "Odd",
		baseValue = 240,
	},

	-- ===================== CURSED =====================
	{
		id = "haunted_furby",
		name = "Haunted Furby",
		desc = "Blinks when you're not looking. Batteries removed. Still going.",
		rarity = "Cursed",
		baseValue = 620,
	},
	{
		id = "cursed_beanie",
		name = "Cursed Beanie Baby",
		desc = "The tag says it's worth millions. The tag has lied for 30 years.",
		rarity = "Cursed",
		baseValue = 890,
	},
	{
		id = "human_tooth",
		name = "A Tooth (Human?)",
		desc = "The question mark is doing a lot of work in that name.",
		rarity = "Cursed",
		baseValue = 450,
	},
	{
		id = "mirror_wrong",
		name = "Mirror That Lags",
		desc = "Your reflection arrives half a second late. Sold as-is.",
		rarity = "Cursed",
		baseValue = 1150,
	},
	{
		id = "screaming_mug",
		name = "Mug That Screams",
		desc = "Only when filled. Only when nobody else is home.",
		rarity = "Cursed",
		baseValue = 780,
	},

	-- ===================== LEGENDARY =====================
	{
		id = "occupied_urn",
		name = "Urn (Possibly Occupied)",
		desc = "The family said 'just get rid of it.' We are getting rid of it.",
		rarity = "Legendary",
		baseValue = 4200,
	},
	{
		id = "first_dollar",
		name = "The First Dollar Ever Made",
		desc = "Not THE first. But the first one somebody framed. Close enough.",
		rarity = "Legendary",
		baseValue = 6800,
	},
	{
		id = "sealed_tupper",
		name = "Tupperware That Won't Open",
		desc = "Four generations have tried. It hums faintly on Tuesdays.",
		rarity = "Legendary",
		baseValue = 9500,
	},
}

-- Lookups built once at require time.
local byId: { [string]: Item } = {}
local byRarity: { [string]: { Item } } = {}

for _, item in items do
	byId[item.id] = item
	local bucket = byRarity[item.rarity]
	if not bucket then
		bucket = {}
		byRarity[item.rarity] = bucket
	end
	table.insert(bucket, item)
end

ItemDatabase.All = items

-- Falls back to the player-created registry so every existing call site —
-- shelf rendering, pricing ceilings, customer decisions, client toasts —
-- resolves community junk without needing to know it exists.
--
-- The dependency runs one way (ItemDatabase -> CommunityItems) and
-- CommunityItems requires nothing, so there is no cycle.
function ItemDatabase.Get(id: string): Item?
	local curated = byId[id]
	if curated then
		return curated
	end

	local community = CommunityItems.Get(id)
	if community then
		return {
			id = community.id,
			name = community.name,
			desc = community.desc,
			rarity = community.rarity,
			baseValue = community.baseValue,
		}
	end

	return nil
end

function ItemDatabase.GetRarityColor(rarity: string): Color3
	local r = ItemDatabase.Rarities[rarity]
	return if r then r.color else Color3.fromRGB(200, 200, 200)
end

-- Weighted roll: pick a rarity by weight, then a uniform item within it.
-- Two-stage rather than one flat weighted list so that adding a new item to a
-- rarity doesn't silently change how often that rarity appears.
function ItemDatabase.RollRandom(rng: Random?): Item
	local random = rng or Random.new()

	local total = 0
	for _, rarityName in ItemDatabase.RarityOrder do
		total += ItemDatabase.Rarities[rarityName].weight
	end

	local roll = random:NextNumber() * total
	local chosen = "Junk"

	for _, rarityName in ItemDatabase.RarityOrder do
		roll -= ItemDatabase.Rarities[rarityName].weight
		if roll <= 0 then
			chosen = rarityName
			break
		end
	end

	local pool = byRarity[chosen] or byRarity.Junk
	return pool[random:NextInteger(1, #pool)]
end

return ItemDatabase
