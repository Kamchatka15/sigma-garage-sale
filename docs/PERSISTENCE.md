# Persistence — never losing your place

> A player who loses hours of progress does not file a bug report. They leave and
> they don't come back, and Roblox's algorithm reads that as a bad experience.
> Data integrity is a retention feature.
>
> Companion docs: `FIRST-SESSION.md` (what gets taught), `GAME-DESIGN.md` (what
> gets saved), `CLAUDE.md` (schema rules — read before touching any of this).

---

## 1. What must survive, ranked by how badly losing it hurts

| Rank | Data | Why it matters | If lost |
|---|---|---|---|
| 1 | **Knowledge / appraisal** | The real progression. Hours of learning | **Unrecoverable. Player quits.** |
| 2 | **House tier** | Visible social status on the block | Catastrophic |
| 3 | **Cash** | Obvious | Severe |
| 4 | **Sale table** | Still earning while offline | Severe |
| 5 | **Cosmetics** | Real money was spent | **Refund request + trust loss** |
| 6 | **Stash** | Raidable by design, so already bounded | Annoying |
| 7 | **Traps** | Re-buyable | Minor |
| 8 | **Onboarding flags** | Prevents re-teaching a veteran | Reads as broken |
| 9 | **Carried bag** | At-risk by design anyway | Acceptable |

**Rule that falls out of this table: knowledge is sacred.** It is never reduced
by any mechanic — not raids, not being caught, not prestige (if that ever ships).
It is the one number that only ever goes up, and it's why a returning player
feels *smarter* rather than merely topped-up.

---

## 2. Current state — and what's missing

`PlayerDataService` already does the important structural thing right: it is the
only module in the codebase that touches DataStores, so a schema change is a
one-file change. Keep that.

Three gaps to close before launch, in priority order:

1. **No session locking.** Two servers can hold the same player's data
   simultaneously, and the second write wins. This is the standard Roblox item-
   duplication exploit *and* a real data-loss path for honest players who
   rejoin quickly. **Highest priority.**
2. **`SetAsync` with no retry.** A single transient DataStore failure silently
   loses the session. Should be `UpdateAsync` (which resolves concurrent writes
   against the stored value) with bounded retries and backoff.
3. **Double-save on shutdown.** `PlayerRemoving` and `BindToClose` both fire
   `Save`. Harmless today, wasteful against request budgets, already in
   `BACKLOG.md`.

---

## 3. Schema v2

> ⚠️ **This is a save-schema change and requires an explicit migration.**
> `CLAUDE.md` forbids doing it as a side effect of another task. It gets its own
> brief, its own review, and its own playtest.

```
SaveData v2 = {
  schemaVersion : 2,
  cash          : number,
  bag           : { BagItem },              -- carried; at risk on a raid
  stash         : { BagItem },              -- stored; raidable, hard cap
  shelves       : { [string]: ShelfEntry }, -- the sale table; NEVER raidable
  house         : { tier: number, skinId: string? },
  traps         : { [string]: TrapPlacement },
  upgrades      : { [string]: number },
  knowledge     : { [string]: Knowledge },  -- SACRED, never decreases
  cosmetics     : { owned: { string } },
  onboarding    : { step: number, flags: { [string]: boolean } },
  stats         : { totalSales, totalEarned, raidsWon, timesCaught },
  lastSeen      : number,                   -- unix time, for offline earnings
}
```

### Migration v1 → v2 is purely additive

Every v1 field keeps its name and meaning; the new fields get defaults. No
existing player loses anything, and the migration is reviewable in one screen.

**Deliberate choice: the sale table stays named `shelves` in the data.** The
player-facing name is "sale table," but renaming the field would mean touching
`PlotService`, `CustomerService`, and the client for a purely cosmetic gain.
Rename migrations are the ones that lose data. Not worth it — and `shelves` is
theme-neutral, which the reskin strategy (`DECISIONS.md`) actually requires.

---

## 4. Save triggers

| Trigger | When | Why |
|---|---|---|
| Autosave | Every ~120s | Bounds worst-case loss to two minutes |
| Player leaving | `PlayerRemoving` | The common case |
| Server shutdown | `BindToClose` | Roblox gives a short flush window |
| **After a house purchase** | Immediately | Highest-value event in the game |
| **After a cosmetic purchase** | Immediately | Real money; never risk it |
| After a raid resolves | On exit or catch | Settles what was actually banked |

The two "immediately" rows matter most: a player who spends Robux on a house skin
and loses it to a server crash is a refund request and a permanently lost player.

---

## 5. Anti-exploit rules

**Combat logging.** A player about to be caught can quit to keep their loot. On
disconnect while a raid is in progress, the server resolves the raid as a
**catch** before saving — carried loot drops, exactly as if they'd been caught.
Otherwise the optimal strategy is to alt-F4 every time a defender turns a corner.

**Duplication.** Session locking (§2.1) is the fix. Without it, two servers plus
a fast rejoin lets a player clone their whole inventory.

**Client authority.** Unchanged and non-negotiable from `CLAUDE.md`: prices,
cash, loot rolls, heat, and catches are all computed server-side. The client
renders state and sends requests. Every remote handler assumes hostile input.

**Offline raid bounds.** An offline player's losses are capped by the stash cap
and a per-target raid cooldown. There is no sequence of events where a player
logs in to find everything gone.

---

## 6. Offline earnings — the D1 retention hook

The sale table keeps selling while you're away. This is the mechanic that makes
players come back tomorrow, so it gets designed rather than bolted on.

- **Simulated on login** from `lastSeen`, not ticked live on the server
- **Capped at ~8 hours** so being away longer isn't strictly better than playing
- **Discounted** (~60% of the active rate) so active play always beats idling
- **Generates knowledge too** — offline sales advance appraisal, so the player
  returns smarter, not just richer
- **Night Shift** game pass doubles the rate (`MONETIZATION.md` §4)

On login the player sees the offline report, the raid report, and restocked
yards — the three-part return hook from `FIRST-SESSION.md` §6.

---

## 7. Solutions — how to actually close the gaps in §2

### The concepts, first

Three terms that decide this choice:

- **Session locking** — only one server may hold a player's save at a time. Its
  absence is *the* Roblox duplication exploit: join server A, drop items, rejoin
  fast into server B which loads the pre-drop save, and now the items exist
  twice. It's also a plain data-loss path for honest players who rejoin quickly.
- **`UpdateAsync` vs `SetAsync`** — `SetAsync` overwrites whatever is stored.
  `UpdateAsync` reads-modifies-writes atomically, so two near-simultaneous writes
  resolve instead of one silently clobbering the other. Current code uses
  `SetAsync`.
- **Reconciliation** — filling in fields a newer schema expects but an older save
  lacks, from a default template. This is exactly the v1→v2 migration in §3, and
  a good library does it for free.

### The options

| | **A · ProfileStore** | **B · Harden our own** | **C · Patch in place** |
|---|---|---|---|
| Session locking | Built in, cross-server aware | We write it | **Still missing** |
| Autosave / shutdown | Built in | We write it | Exists |
| Reconciliation | Built in | We write it | Manual (exists) |
| Studio without API access | Mock mode | We write it | Memory fallback |
| Code we maintain | ~none | Several hundred lines | Minimal |
| Failure mode | Well-trodden | **Our bugs, with real saves** | Duplication exploit |
| Understanding gained | Moderate | High | Low |

**A — [ProfileStore](https://github.com/MadStudioRoblox/ProfileStore).** The
community standard, successor to ProfileService by the same author. Session
locking, autosaving, `BindToClose` handling, reconciliation, and a Studio mock
mode all solved. Notably it uses `MessagingService` so one server can *ask*
another to release a lock, rather than a player waiting out a timeout after a
crash — that responsiveness is the main thing it improved over ProfileService.

**B — roll our own.** A lock field (`lockId` + timestamp) claimed atomically via
`UpdateAsync`, stolen after a timeout so a crashed server doesn't orphan a
player forever, plus retries with backoff. Entirely doable, and the edge cases
around crash recovery and lock stealing are where the bugs live — bugs whose
blast radius is players' real progress.

**C — patch in place.** Swap `SetAsync` for `UpdateAsync`, add retries, fix the
double-save. Cheap, strictly better than today, and **leaves the duplication
exploit open**. Acceptable while pre-launch and nobody has hours invested;
not acceptable at launch.

### Recommendation: A, and here's the tradeoff being made

Take ProfileStore. The reasoning is the blast radius, not the line count — a
subtle bug in hand-rolled session locking corrupts real progress for real
players, and it surfaces weeks later as churn nobody traces back to a save bug.

**The cost, stated honestly:** it's a third-party dependency with its own
lifecycle to learn, and it's less educational than writing the lock ourselves.
Against a teaching-oriented project that's a genuine loss. It's outweighed here
because the data is the one thing in this codebase that cannot be re-derived
after it's lost.

**Why the swap is low-risk:** `PlayerDataService` is already the only module in
the codebase that touches DataStores, so this is a one-file change behind the
existing `Load` / `Save` / `Get` interface. Nothing else in the game needs to
know. That existing discipline is what makes this decision cheap and reversible —
worth noticing as a payoff from an architectural rule that looked fussy at the
time.

Its mock mode also fixes the Studio testing problem in §8 as a side effect.

### Order of work

1. ~~Swap `PlayerDataService` internals to ProfileStore, schema v1 unchanged.~~
   **Done 2026-08-27 — but never executed. See "Status" below.**
2. **Separately**, migrate v1 → v2 (§3) with its own brief and playtest
3. Add combat-log resolution (§5) once raids exist

### Status of step 1

Written and passing `selene` / `StyLua`. **It has not been run.** Lint passing is
not evidence that saving works, and this is precisely the subsystem where that
distinction matters.

What changed:
- ProfileStore vendored at `src/server/Packages/ProfileStore.luau`, excluded from
  `selene.toml` and `.styluaignore` — keeping it byte-identical to upstream is
  what makes a version bump a re-download rather than a merge
- `PlayerDataService` now session-locks via `StartSessionAsync`, reconciles
  against the default template, and kicks a player whose session is taken by
  another server (their data is unsaveable at that point, so continuing would
  silently discard everything they do next)
- The manual autosave loop and `BindToClose` handler were **removed** —
  ProfileStore owns both, and duplicating them was the double-save noted in
  `BACKLOG.md`
- `Main.server.luau` now aborts `onPlayerAdded` when `Load` fails, instead of
  assigning a plot to a player who is being kicked

Schema is untouched at v1. The `shelves` / `stash` / `house` fields of §3 are
step 2 and deliberately not started.

**Verify before trusting it** — the §8 matrix, and at minimum: enable Studio API
access, join, earn cash, rejoin, confirm the cash survived. The mock-store
fallback will make Studio *look* correct with API access off.

Never combine steps 1 and 2. If saving breaks you want to know which change did
it, and `CLAUDE.md` forbids schema changes riding along with other work.

---

## 8. What to verify before trusting any of this

Studio's `StudioAccessToApisNotAllowed` fallback means **persistence silently
does not work in Studio** unless the API-services checkbox is enabled
(`SESSIONS.md`, Session C). The memory-only fallback is correct behaviour and it
is also an excellent way to convince yourself saving works when it doesn't.

Minimum test matrix before launch:

1. Buy a house → rejoin → still own it
2. Appraise an item → rejoin → knowledge intact
3. Quit mid-raid → rejoin → loot correctly forfeited, nothing else lost
4. Two devices, same account, fast rejoin → no duplication
5. Buy a cosmetic → force-close the server → cosmetic still owned
6. Fresh account → v1 save injected → migrates to v2 with nothing lost
