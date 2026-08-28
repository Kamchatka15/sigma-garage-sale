# Backlog

Every good idea that is not v1.0. One line, dated.

This file is scope defense. Writing an idea down is what lets you not
build it without feeling like you lost it. Never build straight from here —
ideas graduate to a brief in docs/briefs/ first, and only after a phase gate.

## Post-v1.0 (already agreed, see GAME-DESIGN.md §10)
- Haggling minigame — customer counter-offers, accept/reject/counter
- Player-to-player stalls — the arbitrage economy, highest-value item here
- Prestige system
- Multiple districts
- Custom stall decoration

## Captured during development
<!-- add below, newest first -->

### 2026-08-28 — Player-created junk ("leave your mark on the game")
Pay Robux to add an item to the game world. Strong hook — it's the Roblox
ethos, it monetizes expression rather than power, and finding another kid's
item in the wild is a story. **Post-v1.0.** Four constraints, all load-bearing:

1. **Community items must not participate in appraisal.** The knowledge system
   (GAME-DESIGN.md §8) only works on a finite, learnable item set. An
   ever-growing pool makes nothing learnable and quietly kills the core
   progression. Community items resolve to a fixed value for their rarity tier.
2. **Players never set value.** Name, description, and flavor only — the server
   derives worth from rarity. Otherwise the first "$50,000 banana peel" ends the
   economy. This is the MONETIZATION.md §5 pay-to-win line.
3. **Combinatorial naming, not free text.** Pick one word from each of three
   curated lists (`[Rotten] [Banana] [Peel]`). Free text written by children and
   shown to children needs filtering *and* a review queue *and* a refund process
   for post-purchase moderation. The combinatorial version is safe by
   construction, cheaper to build, and funnier — constraint breeds comedy.
4. **Live for one month, then rotate out.** Bounds the pool by time rather than
   by a hard cap. Must be disclosed *before* purchase or it's a refund request.

**Popularity buys PERMANENCE, not value.** The most-collected community items
graduate out of the monthly rotation into the permanent curated item list. That
is a far better reward than a rising number, and it costs the economy nothing.

Rejected — value rising with how often an item sells:
- **Money printer.** Players farm it, sell it back and forth, use alts. First
  thing anyone tries.
- **Unappraisable by construction.** An item whose worth changes over time can
  never be learned, so it opts out of the progression system entirely.

Rejected — explicit player ratings:
- Brigadable, and downvoting a nine-year-old's creation is a feel-bad machine
  pointed at the players who cared enough to pay. Measure by engagement
  (collected / sold counts) instead: same signal, nobody gets told their thing
  is bad.

**The creator's record is permanent even when the item isn't.** "You made this.
It was found 12,000 times." Name on the item, a stats page, a trophy in your
house. That recognition is the actual product being sold — not the item.
- 2026-08-27 — Sigma Garage Sale deferred scope (see GAME-DESIGN.md §14):
  houses 6–13, player-vs-player raiding, trap tiers, the mansion endgame,
  offline raid reports. v1.0 slice is 5 houses + NPC defenders only.
- 2026-08-27 — Guard against double-save on shutdown (PlayerRemoving and
  BindToClose both fire Save). Harmless but wasteful; noted in SESSIONS.md C.
