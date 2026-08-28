# Session Log

Append one entry per 15-minute session. Agents append their run summaries
underneath the session that launched them.

Keep it short. This exists so that "what was I doing?" takes 30 seconds
to answer, not five minutes.

---

## TEMPLATE — copy this

## YYYY-MM-DD — Session A/B
**Reviewed:**
**Playtest notes:**
**Decisions:**
**Launched:**

---
## 2026-08-27 — Session A (Claude, Cowork)
**Reviewed:** nothing yet — first build session.
**Built:** Phase 1 vertical slice, complete. 9 modules.
- shared: Config, ItemDatabase (38 items), ReactionLines, Remotes
- server: Main, PlayerDataService, WorldBuilder, PlotService, ScavengeService, CustomerService
- client: Main (full UI built in code)
**Decisions:** see DECISIONS.md entries dated today.
**Not done (needs a human):** toolchain install, Studio MCP enable, Rojo sync,
first playtest. Nothing in this code has ever been run.
**Next:** Phase 0 setup from docs/SETUP.md, then sync and playtest.

## 2026-08-27 — Session B (setup, with Claude in Cowork)
**Built:** nothing new — environment setup.
**Installed:** Rokit 1.2.0, Rojo 7.7.0, selene 0.31.0, StyLua 2.5.2, Rojo Studio plugin.
**Result:** Rojo connected to Studio, project "SellMyJunk" serving on localhost:34872,
sync confirmed live. Place is a cloud experience ("Untitled Experience", private).
**Blocked:** Studio's built-in MCP server is not present in this Studio build —
searched Studio Settings for "mcp" (no results) and "assistant" (only a Script
Editor tooltip toggle), and the View menu has no Assistant panel. Deferred;
not required. Rojo is the piece that matters and it works.
**Corrections made:** the Rokit install URL in docs/SETUP.md was wrong and has
been fixed. The Studio MCP menu path stated earlier was also wrong — both came
from web-search summaries rather than from looking at the actual UI.
**Not done:** Claude Code not installed yet. Code has still never been run.
**Next:** docs/NEXT-SESSION.md — install Claude Code, then Prompts 1-4.

## 2026-08-27 — Session C — FIRST RUN
**Result: the Phase 1 vertical slice runs.** First time this code has ever executed.

Verified in Studio:
- Rojo synced all 10 modules to correct locations (ReplicatedStorage.Shared,
  ServerScriptService.Server, StarterPlayer.StarterPlayerScripts.Client)
- `[SellMyJunk] server ready` printed from Main:44
- WorldBuilder generated the map — stalls and counters visible
- Client UI rendered: BAG 0/8, $50 cash, SHELVES (3) with empty slots, UPGRADES
- Clean shutdown, no crash

**Zero blocking errors on first run.** Not expected — assume there are still bugs
that only show up once you actually play the loop.

**One known issue (not a code bug):**
DataStoreService: StudioAccessToApisNotAllowed. PlayerDataService catches this and
falls back to memory-only, exactly as designed, so the game runs — but nothing
persists in Studio. Fix: Game Settings → Security → Enable Studio Access to API
Services. One checkbox.

**Minor, low priority:** save fires twice on shutdown (PlayerRemoving and
BindToClose both call Save). Harmless, but wasteful. Worth a guard later.

**Not yet tested:** scavenging, pricing, customers, sales, upgrades. The UI drew
but nobody has played the actual loop yet.

**Next:** install Claude Code (docs/NEXT-SESSION.md), enable the API checkbox,
then play the loop and see what's actually broken.

## 2026-08-27 — Session D (Claude Code) — design pivot + persistence backend
**Built:** no gameplay code. Design docs and one backend swap.
- Pivoted to **Sigma Garage Sale** (13-house cul-de-sac, raid/hide/sell loop).
  Old design archived at docs/archive/GAME-DESIGN-selljunk-v1.md.
- New docs: MONETIZATION.md, FIRST-SESSION.md, PERSISTENCE.md.
- DevCommands.luau added earlier this session (_G.SMJ.*, Studio-only).
- **Swapped PlayerDataService to ProfileStore** for session locking. Schema
  unchanged at v1. Vendored to src/server/Packages/, excluded from lint.

**Decisions:** see DECISIONS.md — six entries dated today.

**NOT DONE / RISK:** the ProfileStore swap has never been executed. selene and
StyLua pass; that is not evidence saving works. Next session must verify:
enable Studio API access → join → earn cash → rejoin → cash survived.

**Next:** verify persistence, then either schema v2 (docs/PERSISTENCE.md §3) or
the v1.0 slice brief (docs/GAME-DESIGN.md §14).
