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
4. **Cap the live pool** and rotate. 10k players is otherwise 10k items.

Credit the creator on the item ("— by @username"); that's the actual product
being sold.
- 2026-08-27 — Sigma Garage Sale deferred scope (see GAME-DESIGN.md §14):
  houses 6–13, player-vs-player raiding, trap tiers, the mansion endgame,
  offline raid reports. v1.0 slice is 5 houses + NPC defenders only.
- 2026-08-27 — Guard against double-save on shutdown (PlayerRemoving and
  BindToClose both fire Save). Harmless but wasteful; noted in SESSIONS.md C.
