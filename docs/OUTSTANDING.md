# Outstanding work — as of 2026-08-27

> Honest status: **the design is far ahead of the code.** Everything designed in
> the Sigma pivot is unbuilt. What actually runs today is the original *Sell My
> Junk* vertical slice — junkyard, stalls, customers, no houses, no raids, no
> hiding, no heat.
>
> Ordered by what blocks what. P0 items block everything below them.

---

## Done and working

- Phase 1 vertical slice runs end to end (`SESSIONS.md` C) — world generates,
  UI renders, no blocking errors
- `selene` + `StyLua` clean, with config and vendored-code exclusions
- `DevCommands.luau` — `_G.SMJ.give/giveRandom/cash/customer/reset`, Studio-only
- Design corpus: `GAME-DESIGN.md`, `MONETIZATION.md`, `FIRST-SESSION.md`,
  `PERSISTENCE.md`, plus `DECISIONS.md`

## Done but **never executed**

- **ProfileStore swap** — written, lint-clean, statically verified against the
  library source. Has never run. Lint passing is not evidence saving works.

---

## P0 — Blocking, do these first

### 1. ~~There is no version control~~ — **DONE 2026-08-27**
`git init` on `main`, initial commit `e86eb39` (34 files), pushed private to
`git@github.com:Kamchatka15/sigma-garage-sale.git` over SSH (ed25519 key at
`~/.ssh/id_ed25519`). Off-machine backup now exists.

This also unblocks parallel agent work via `git worktree`
(`OPERATING-MODEL.md` §5) — with the Roblox caveat that only one worktree can be
Rojo-synced to Studio at a time, so **playtesting stays serial**.

### 2. Verify persistence actually works
The ProfileStore swap is unproven. Sequence:
1. Game Settings → Security → **Enable Studio Access to API Services**
2. Play → `_G.SMJ.cash(500)` → stop → play again → is it still 500?
3. If the output says `NOTHING WILL PERSIST`, the checkbox is off and the test
   is meaningless

### 3. Playtest the existing loop
Per `SESSIONS.md` C, **scavenging, pricing, customers, sales, and upgrades have
never been played.** The UI drew; nobody has run the loop. Bugs are near-certain
and everything downstream is built on this code.

Use `_G.SMJ.giveRandom(5)` and `_G.SMJ.customer()` to skip the walking.

---

## P1 — Decisions needed before building the pivot

### 4. Three open design questions (`GAME-DESIGN.md` §15)
- Own one house at a time (move up the block) or accumulate? *I lean moving.*
- Does the mansion owner get raided by everyone? *I lean yes — self-balancing.*
- Server size? 13 houses wants ~12–20 players.

### 5. `ROADMAP.md` is pre-pivot
Phases 1–2 describe the old junkyard/stall game. It's the file that decides what
gets built each week, and it currently points at the wrong game.

---

## P2 — Debt this session created or exposed

Small, cheap, and each one is a landmine if left.

| # | Item | Why it matters |
|---|---|---|
| 6 | `Magnet Gloves` game pass (`Config.luau:136`) auto-collects junk | Violates `MONETIZATION.md` §5 rule 2 — a raid advantage sold for Robux. Reword or cut |
| 7 | `Config.AutosaveInterval` orphaned | ProfileStore owns autosaving now; nothing reads it. Dead config misleads |
| 8 | `MarkChanged` / `OnChanged` has zero subscribers | Dead plumbing since before this session. Wire it to `PlotService.Sync` or delete it |
| 9 | Theme strings hardcoded across `WorldBuilder`, `Config`, `Main`, client UI | Violates the reskin decision in `DECISIONS.md`. Every one makes the next reskin a rewrite |
| 10 | Identity still "SellMyJunk" (`default.project.json`, `Config.DataStoreName`) | Renaming `DataStoreName` **orphans every existing save** — treat as a migration, not a rename |

---

## P3 — The game itself (nothing built)

The v1.0 slice from `GAME-DESIGN.md` §14. Roughly dependency-ordered:

| # | System | Notes |
|---|---|---|
| 11 | **Schema v2** | `PERSISTENCE.md` §3. Own brief, own playtest. Blocks 15–17 |
| 12 | **Houses** (5 for v1.0) | `WorldBuilder` generates them; interiors + yards + gate |
| 13 | **Search spots** | 15 per house, 4–6 populated randomly per raid |
| 14 | **Heat system** | The readable risk dial. Blocks defenders being fun |
| 15 | **Hiding** | Slit camera, peek, heartbeat. Same objects as search spots |
| 16 | **Roaming NPC defenders** | Patrol → suspicious → searching → chasing |
| 17 | **Catch + extraction** | Drop carried loot, ragdoll eject, gate requirement |
| 18 | **Traps + counters** | 3 traps, 2 counters. In-game currency only |
| 19 | **House ownership ladder** | Replaces/extends the upgrade system |
| 20 | **Onboarding** | `FIRST-SESSION.md` — rigged first customer, safe first raid |
| 21 | **Offline earnings** | The D1 return hook. Needs `lastSeen` from schema v2 |
| 22 | **Combat-log resolution** | Disconnect mid-raid must resolve as a catch, or alt-F4 is optimal |

### 23. Analytics — build before launch, not after
`MONETIZATION.md` §7. D1/D7, time-to-first-purchase, conversion, and the
**pay-to-win canary** (raid success rate, payers vs free). Retroactive data does
not exist; every day without instrumentation is a day of blind tuning.

---

## P4 — Monetization (only after retention is proven)

Per `MONETIZATION.md` §8, deliberately last:

- **Phase B:** cosmetic store (blanket skins, house skins), private servers
- **Phase C:** game passes — requires in-game ceilings settled first, or the
  "never exceed what play achieves" rule can't be enforced
- **Phase D:** seasonal drops, UGC

---

## The honest summary

Three P0 items are hours of work, mostly yours not mine. P3 is months at 30
minutes a day. The single most valuable thing available right now is **P0-3, the
playtest** — it's the only item that can invalidate design assumptions before
they get built on, and it's the one no agent can do.
