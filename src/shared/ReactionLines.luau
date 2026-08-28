--!strict
-- ReactionLines — what customers say when they walk away.
--
-- This file is the single highest-value content target in the project, and the
-- best possible first task to hand to a cheap bulk agent. The near-miss bubble
-- is doing three jobs at once (teaching the value distribution, creating
-- tension, delivering the joke) and it fires far more often than a sale does.
--
-- Target: 200+ lines per category. Ship with these, expand relentlessly.
-- Keep them SHORT — they render in a bubble for 2.5 seconds over a customer's
-- head, and anything past about eight words won't get read.

local ReactionLines = {}

-- Priced above what they'd pay, but they could afford it.
ReactionLines.TooExpensive = {
	"...for that? In this economy?",
	"I've seen better at a gas station.",
	"That's a whole week of lunch money.",
	"My grandma would slap me.",
	"Bold pricing. Genuinely bold.",
	"I respect the confidence. I won't pay it.",
	"That's a car payment.",
	"I'm not made of money. I'm made of mostly water.",
	"Hard pass. Beautiful item though.",
	"For legal reasons I have to say no.",
	"I'll think about it. (They will not.)",
	"Steep. Real steep.",
	"That price is a personal attack.",
	"I came here to save money, not spend it.",
	"Nope. Not today. Not at that number.",
}

-- They genuinely don't want it at any price. Low taste roll.
ReactionLines.NotInterested = {
	"It's not really my aesthetic.",
	"What would I even do with that?",
	"I'm trying to own fewer things.",
	"My therapist says no more clutter.",
	"It's giving... something. Not sure what.",
	"I already have three of those.",
	"Something about it unsettles me.",
	"I don't like the way it's looking at me.",
	"Wrong vibe entirely.",
	"Maybe next weekend.",
	"I'll admit I'm curious. Not curious enough.",
	"That belongs in a museum. A bad one.",
}

-- They want it and the price is fair, but they're broke.
ReactionLines.CantAfford = {
	"I want it. I cannot have it.",
	"Payday is Friday. Hold it for me?",
	"This is genuinely tragic for me.",
	"I only brought coins.",
	"Ugh. I'll be back. Probably.",
	"My wallet says no but my heart says yes.",
	"Save that for me. Please. I mean it.",
}

-- Nothing on the shelves at all.
ReactionLines.EmptyStall = {
	"Nothing here?",
	"Are you even open?",
	"Bold retail strategy.",
	"I walked all this way.",
}

-- Bought something, and got a deal on it.
ReactionLines.HappyBuy = {
	"This is a STEAL.",
	"You're going to regret this price.",
	"Don't tell anyone what I paid.",
	"I would have paid triple.",
	"Sold! Before you change your mind.",
	"My whole day just improved.",
}

-- Whale entrance lines.
ReactionLines.WhaleArrival = {
	"I collect. Extensively.",
	"Money is not the issue here.",
	"Show me something unusual.",
	"I have a very large house.",
	"Price is rarely my concern.",
}

local rng = Random.new()

function ReactionLines.Pick(category: string): string
	local pool = (ReactionLines :: any)[category]
	if type(pool) ~= "table" or #pool == 0 then
		return "..."
	end
	return pool[rng:NextInteger(1, #pool)]
end

return ReactionLines
