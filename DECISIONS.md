# Decisions

Two lines per decision. Date it. Write it when you make it, not later —
the reasoning is the part you forget, and it's the part that matters.

## 2026-08-27 — ProfileStore for persistence, over hand-rolled session locking
Chose the library over writing our own lock. Reasoning is blast radius, not line
count: a subtle bug in hand-rolled session locking corrupts real player progress
and surfaces later as churn nobody traces back to saving. Cost accepted: a
third-party dependency and less learned than writing it ourselves. Cheap because
PlayerDataService is already the only module touching DataStores, so it's a
one-file swap behind the existing interface.

## 2026-08-27 — Hiding spots and loot spots are the same objects
Defenders roam, so players need somewhere to go. Making the closet you hide in
also a place loot spawns creates the game's best decision ("search it while
they're three feet away?"), halves the world objects needed, and makes the map
readable as both a treasure map and an escape map. Reference points are Piggy /
Hello Neighbor, which this audience already knows.

## 2026-08-27 — Getting caught costs loot, never money
Losing banked cash reads to a child as the game taking what they earned, and they
log off. Losing the run's carried loot reads as "I pushed too far," and they
immediately retry. Same penalty magnitude, opposite retention outcome. Dropped
loot scatters on the lawn rather than being deleted, which adds a greed beat.

## 2026-08-27 — "Sigma" branding accepted; reskins planned as a growth strategy
Slang shelf life is a real risk but accepted deliberately: the plan is to ship
the same engine under multiple themes/names on Roblox to maximize the concept's
value. ARCHITECTURAL CONSEQUENCE, and it is binding: all theming — house names,
item names, reaction lines, palettes, store copy — stays data-driven in
Config/ItemDatabase/ReactionLines. Never hardcode a theme string into a service.
A reskin must be a data change, not a rewrite, or this strategy costs more than
it earns.

## 2026-08-27 — Pivot to Sigma Garage Sale; raid loop added under the pricing game
"Sell My Junk" had a real skill curve and no hook a child would click on. New
premise: homeless on a 13-house cul-de-sac, scavenge yards, sell loot, buy up
the block. The pricing/appraisal engine is unchanged and still the differentiator
— the raid is what gives it stakes. Old doc archived at
docs/archive/GAME-DESIGN-selljunk-v1.md.

## 2026-08-27 — Defenders are NPCs first, players later
Unowned houses are defended by NPC residents; owned ones by the player's traps
plus an NPC house-sitter when they're offline. This makes danger scale with
server population automatically — solves both the dead-server problem and the
"protect my stuff while I sleep" problem with one mechanic.

## 2026-08-27 — Raiders risk only what they carry
Getting caught drops the current run's unsold loot and ejects you. Never cash,
banked items, sale table, or house. Audience is children: a kid who lost nothing
permanent retries, a kid who lost their house quits forever.

## 2026-08-27 — Three proposed house archetypes rejected
The meth house, "diddy house," and fat-person house were cut. Drug and sex-crime
references and body mockery aimed at children are a plausible reason for Roblox
to pull the experience. Replaced with hoarder/prepper/crypto-bro/influencer etc.,
which keep the comedic register without the takedown risk.

## 2026-08-27 — Kill criterion set before launch
If D1 retention is below 8% after two full tuning passes, stop and write a
post-mortem. Recorded now, while unattached to the outcome.

## 2026-08-27 — Items are labeled boxes, not models
Art bar is the failure mode from the previous project (The Ideology).
The joke is the label. This is a style commitment, not a temporary shortcut.

## 2026-08-27 — Progression is knowledge, not just currency
Item values are hidden until the player sells copies and unlocks appraisal
data. Rejected the standard "numbers go up" model because it has no skill
curve and every competitor already does it.

## 2026-08-27 — World is generated in code, not built in Studio
WorldBuilder creates the ground, junkyard, and all 6 plots at runtime. Map
changes become reviewable diffs and the game runs on an empty baseplate, so
any fresh clone or worktree is immediately playable. Cost: no visual editing.
Acceptable because the art direction is labeled boxes.

## 2026-08-27 — Customers are lerped Models, not Humanoids
Rejected Humanoid + PathfindingService. Customers walk a straight line to a
counter, so pathfinding buys nothing and costs physics, ragdolls, player
collision, and a class of NPC bugs. Revisit only if customers ever need to
navigate around obstacles.

## 2026-08-27 — Default shelf price seeds from rarity, never from baseValue
First draft seeded the asking price at 75% of the item's true value, which
silently handed the player the answer to the core pricing puzzle. Now seeds
from a coarse per-rarity guess (rarity is already visible via item color), or
from the player's own sales history once they have one.
