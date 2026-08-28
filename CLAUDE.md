# Sell My Junk — Project Conventions

A Roblox yard-sale tycoon. Read `docs/GAME-DESIGN.md` before proposing gameplay
changes, and `docs/OPERATING-MODEL.md` before proposing process changes.

## Teaching mandate — applies to every session

The developer is using this project to learn agent-driven development.
Working code alone is not a complete response.

1. Before implementing anything non-trivial, state your approach in 2–3
   sentences and name one alternative you rejected and why. Wait for a
   go-ahead on anything Tier 2 or above (see `docs/OPERATING-MODEL.md` §4).
2. When you use a pattern, tool, or term that hasn't come up before in this
   project, explain it in one sentence inline. Don't assume familiarity.
3. End every task with: what changed, why, and what to watch out for.
   Three bullets, not an essay.
4. When you make a tradeoff, say so explicitly. Never present one option as
   though it were the only one available.
5. If asked to do something that conflicts with these docs, say so rather
   than complying silently.

## Architecture

- `src/shared` — modules both sides use (Config, ItemDatabase, types)
- `src/server` — authoritative game logic. Services expose `.Init()`.
- `src/client` — UI and input only. **Zero game logic.**
- Strict Luau (`--!strict`) on all new files
- Services communicate through explicit requires. No circular dependencies.

## Security — non-negotiable

- **Never trust the client.** Every remote handler validates its inputs
  server-side. Assume every value arriving from a client is hostile.
- Money, prices, and inventory are computed server-side only.
- Never read, write, or reference `.env` or any API key.
- Never publish to the production place. Publishing is a human action.

## DataStore

- Schema is versioned. Any change to the shape of saved data requires an
  explicit migration path and must be flagged prominently in your summary.
- Never make a schema change as a side effect of another task.

## Style

- `selene` and `StyLua` must pass before you consider a task done
- Small, focused commits with conventional prefixes (`feat:`, `fix:`, `chore:`)
- Comments explain *why*, never *what*

## Scope

- If a brief has a "Do NOT" section, treat it as a hard boundary
- If you think a task needs to touch files outside its stated scope, stop and
  say so instead of expanding the diff
- Good ideas outside current scope go in `BACKLOG.md`, not into the code

## Design guardrails

Monetization is convenience and cosmetics only. No paid randomness, no
progression walls placed at frustration peaks, no timers engineered to be
painful enough to buy out of. The audience is children. If a proposed
mechanic's conversion depends on impulse control rather than genuine
enjoyment, flag it rather than building it.
