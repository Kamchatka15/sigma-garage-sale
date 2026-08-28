--!strict
-- CommunityItems — junk created by players.
--
-- DESIGN CONSTRAINTS, all load-bearing (see BACKLOG.md, 2026-08-28):
--
--   1. Names are COMBINATORIAL, never free text. Three curated word lists. This
--      is safe by construction for an audience of children — no filter to beat,
--      no review queue, no refunds when something gets moderated after purchase.
--      It is also funnier: constraint breeds comedy.
--   2. Creators pick a rarity, never a value. The server derives worth. A
--      player-set value is a $50,000 banana peel and a dead economy.
--   3. Community items are EXCLUDED FROM APPRAISAL. The knowledge system only
--      works on a finite learnable set; an open-ended pool makes nothing
--      learnable. Their ids are prefixed so every system can spot them cheaply.
--   4. They live for a month, then rotate out. Popularity buys PERMANENCE (a
--      curator promotes them into ItemDatabase), never a higher price.

local CommunityItems = {}

-- Every community id starts with this. Cheap to test, no lookup needed.
CommunityItems.PREFIX = "c_"

export type CommunityItem = {
	id: string,
	name: string,
	desc: string,
	rarity: string,
	baseValue: number,
	creatorName: string,
	creatorUserId: number,
	createdAt: number, -- os.time()
	expiresAt: number,
	finds: number, -- engagement, which is the only "rating" we keep
	sales: number,
}

--------------------------------------------------------------------
-- The word lists — this is where the comedy lives
--------------------------------------------------------------------

CommunityItems.Adjectives = {
	"Rotten",
	"Haunted",
	"Slightly Used",
	"Discontinued",
	"Suspicious",
	"Damp",
	"Expired",
	"Half-Eaten",
	"Unlabeled",
	"Sticky",
	"Forgotten",
	"Bootleg",
	"Emotional Support",
	"Novelty",
	"Regrettable",
}

CommunityItems.Nouns = {
	"Banana",
	"Sock",
	"Trophy",
	"Lamp",
	"Doll",
	"Mug",
	"Helmet",
	"Keyboard",
	"Sandwich",
	"Trombone",
	"Traffic Cone",
	"Wig",
	"Sponge",
	"Beanbag",
	"Lawn Gnome",
}

CommunityItems.Suffixes = {
	"Peel",
	"Collection",
	"Replica",
	"Fragment",
	"Set",
	"Bundle",
	"Prototype",
	"Souvenir",
	"Husk",
	"Situation",
}

CommunityItems.Descriptions = {
	"Nobody has been brave enough to ask about it.",
	"Came from a house. Which house is not important.",
	"It was like this when we found it.",
	"Technically still functional. Spiritually, no.",
	"Smells like a decision someone regrets.",
	"There were two. There is now one. Don't ask.",
	"Left behind on purpose, we think.",
	"Guaranteed authentic. Guarantee not included.",
	"It hums when nobody is listening.",
	"An heirloom, if you squint and lower your standards.",
}

-- The only rarities a player may choose. Deliberately excludes Cursed and
-- Legendary: the top of the curated table stays authored, so the rarest things
-- in the game are always ones the designer placed.
CommunityItems.AllowedRarities = { "Junk", "Common", "Odd" }

-- Fixed worth per tier. Community junk is learnable ONCE — "community stuff
-- goes for about this" — and then it stops being a puzzle, which is exactly
-- what protects the real appraisal system from being diluted.
CommunityItems.RarityValue = {
	Junk = 12,
	Common = 44,
	Odd = 160,
}

--------------------------------------------------------------------
-- Registry
--
-- Populated on the server and replicated to clients so item names resolve on
-- both sides. Clients never create entries; they only receive them.
--------------------------------------------------------------------

local registry: { [string]: CommunityItem } = {}

function CommunityItems.IsCommunity(itemId: string): boolean
	return string.sub(itemId, 1, #CommunityItems.PREFIX) == CommunityItems.PREFIX
end

function CommunityItems.Get(itemId: string): CommunityItem?
	return registry[itemId]
end

function CommunityItems.All(): { CommunityItem }
	local list: { CommunityItem } = {}
	for _, entry in registry do
		table.insert(list, entry)
	end
	return list
end

function CommunityItems.Count(): number
	local n = 0
	for _ in registry do
		n += 1
	end
	return n
end

function CommunityItems.Register(entry: CommunityItem)
	registry[entry.id] = entry
end

function CommunityItems.Remove(itemId: string)
	registry[itemId] = nil
end

-- Wholesale replace, used when the server pushes the registry to a client.
function CommunityItems.ReplaceAll(entries: { CommunityItem })
	table.clear(registry)
	for _, entry in entries do
		registry[entry.id] = entry
	end
end

--------------------------------------------------------------------
-- Name assembly
--------------------------------------------------------------------

-- Indices rather than free text: what crosses the network is three numbers, so
-- there is no user-authored string anywhere in the pipeline.
function CommunityItems.BuildName(adjective: number, noun: number, suffix: number): string?
	local a = CommunityItems.Adjectives[adjective]
	local n = CommunityItems.Nouns[noun]
	local s = CommunityItems.Suffixes[suffix]
	if not a or not n or not s then
		return nil
	end
	return ("%s %s %s"):format(a, n, s)
end

return CommunityItems
