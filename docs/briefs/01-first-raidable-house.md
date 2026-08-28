# Brief: The first raidable house

**Goal:** One raidable house on the block with searchable hiding spots that yield
loot into the player's bag. No defender, no heat, no hiding — just walk in,
search, walk out with junk.

**Why:** This is the smallest slice of the Sigma raid loop that is playable end
to end. It's also literally the tutorial house from `FIRST-SESSION.md` §3
(4:00–6:00) — the Condemned Fixer-Upper is abandoned and undefended *by design*,
so a player's first exposure to searching isn't also their first exposure to
being chased. Proving the search mechanic feels good is a precondition for
everything in `GAME-DESIGN.md` §5.

**Scope:**
- New `src/server/HouseService.luau`, `.Init()` called from `Main.server.luau`
  after `PlotService.Init()`
- `WorldBuilder` gains a `buildHouse()` that generates ONE house: floor, four
  walls with a doorway, a roof, a fenced yard, and a gate part. Labeled-box art
  direction — no meshes.
- **12 search spots** as parts inside the house and yard (mailbox, trash can,
  under-porch, closet, bed, shed, etc.). Each carries a `SearchSpot` attribute
  and a readable name.
- On each raid session, **4–6 spots chosen at random** are populated. The rest
  are empty. Populated spots are NOT visually distinguishable before searching —
  that's the whole point.
- Searching uses a **`ProximityPrompt` with `HoldDuration = 1.5`**. (Note: junk
  in the junkyard is walk-into-collect by deliberate design — see the header of
  `ScavengeService.luau`. Searching is different and *should* be a hold, because
  the hold is what will later cost you heat.)
- Success: roll an item with `ItemDatabase.RollRandom()` and add it via
  `PlotService.AddToBag(player, itemId)`. Respect its `false` return (bag full).
- Empty spot: give clear feedback too — an empty search must feel like a result,
  not a bug.
- A spot that has been searched stays searched until the house restocks.
- New tunables go in `Config.luau` (spot count, populated range, hold duration,
  restock interval). No magic numbers elsewhere.

**Done when:**
- I can walk into the house, search spots, and watch items land in my bag
- Roughly 4–6 of the 12 spots yield something; the rest clearly say "nothing here"
- Searching with a full bag tells me the bag is full instead of silently eating
  the item
- Re-entering after the restock interval repopulates different spots
- `selene` and `StyLua` pass
- No errors in Output

**Do NOT:**
- Touch `PlayerDataService` or the save schema. House ownership, stash, and
  persistence of searched state are a separate brief (`PERSISTENCE.md` §3).
  Searched-state living in memory and resetting on rejoin is CORRECT for now.
- Build heat, defenders, hiding, traps, or the catch/eject flow. Later briefs.
- Touch `CustomerService`, or any validation in `PlotService` beyond calling
  the existing `AddToBag`.
- Remove or modify the junkyard. It still works and still feeds the old loop.
- Add more than one house.
