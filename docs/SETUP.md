# Setup

Phase 0. Do this in one sitting (~2 hours), not in 15-minute slices.

Commands assume macOS. Tool install methods change — if one fails, check the tool's current docs rather than fighting it.

---

## 1. Toolchain

```bash
# Rokit manages your Roblox tool versions per-project (like nvm for Roblox tools)
curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash

cd ~/dev/sell-my-junk        # wherever you want the project
rokit init
rokit add rojo-rbx/rojo
rokit add Kampfkarren/selene
rokit add JohnnyMorganz/StyLua
rokit install
```

```bash
# Claude Code
npm install -g @anthropic-ai/claude-code
```

**VS Code extensions:** `Luau Language Server` (JohnnyMorganz) and `Rojo`. Install the Luau LSP **Studio companion plugin** too — it's what gives the editor knowledge of your actual instance tree.

---

## 2. Roblox side

1. **Update Studio**, then: Assistant Settings → MCP Servers → **Enable Studio as MCP server**
2. **Create the universe** with two places:
   - `Sell My Junk` (production — real players)
   - `Sell My Junk [STAGING]` (yours — never linked publicly)
3. **Enable Studio access to API services** (Game Settings → Security) so DataStores work in Studio
4. **Consider creating a Roblox group** to own the game. Group ownership makes it much easier to add a collaborator later, keeps revenue separate from your personal account, and avoids a messy migration if this ever becomes real. Doing it now costs 10 minutes; doing it later costs a transfer.

---

## 3. Repo

```bash
cd ~/dev/sell-my-junk
git init
mkdir -p src/server src/client src/shared docs
git add -A && git commit -m "chore: project skeleton"
gh repo create sell-my-junk --private --source=. --push
```

### `default.project.json`

```json
{
  "name": "SellMyJunk",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Shared": { "$path": "src/shared" }
    },
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "Server": { "$path": "src/server" }
    },
    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "Client": { "$path": "src/client" }
      }
    },
    "Workspace": { "$className": "Workspace" }
  }
}
```

### `.gitignore`

```
*.rbxl
*.rbxlx
*.rbxl.lock
.DS_Store
/build/
.env
```

**Note the last two lines.** Secrets never enter the repo. Open Cloud API keys live in `.env`, and `.env` is never committed — an agent that can read your repo must not be able to read a key that publishes to production.

### Start Rojo

```bash
rojo serve
```

Then in Studio: Plugins → Rojo → Connect.

---

## 4. `CLAUDE.md`

Create this at the repo root. Claude Code reads it automatically every session — it's how your conventions and the teaching mandate persist without you retyping them.

```markdown
# Sell My Junk — Project Conventions

A Roblox yard-sale tycoon. Read `docs/GAME-DESIGN.md` before proposing
gameplay changes, and `docs/OPERATING-MODEL.md` before proposing process changes.

## Teaching mandate — applies to every session

The developer is using this project to learn agent-driven development.
Working code alone is not a complete response.

1. Before implementing anything non-trivial, state your approach in 2–3
   sentences and name one alternative you rejected and why. Wait for a
   go-ahead on anything Tier 2 or above.
2. When you use a pattern, tool, or term that hasn't come up before in
   this project, explain it in one sentence inline. Don't assume familiarity.
3. End every task with: what changed, why, and what to watch out for.
   Three bullets, not an essay.
4. When you make a tradeoff, say so explicitly. Never present one option
   as though it were the only one.
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
  server-side. Assume every value is hostile.
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
- If you think a task needs to touch files outside its stated scope, stop
  and say so instead of expanding the diff
- Good ideas outside current scope go in `BACKLOG.md`, not into the code
```

---

## 5. The four working files

**`DECISIONS.md`**
```markdown
# Decisions

## 2026-08-27 — Kill criterion set before launch
If D1 retention is below 8% after two full tuning passes, stop and write a
post-mortem. Recorded now, while unattached to the outcome.

## 2026-08-27 — Items are labeled boxes, not models
Art bar is the failure mode from the previous project. The joke is the
label. This is a style commitment, not a temporary shortcut.
```

**`SESSIONS.md`**
```markdown
# Session Log

## 2026-08-27 — Session A
**Reviewed:** —
**Playtest notes:** —
**Decisions:** —
**Launched:** —
```

**`BACKLOG.md`** — one line per idea, dated. Never build straight from it.

**`docs/briefs/`** — a folder for your written briefs. Keeping them is how you'll learn which briefs produced good output and which produced sprawl.

---

## 6. Verify before you build anything

Run through this end to end. If any step fails, fix it now — everything downstream compounds off this loop.

- [ ] Edit a file in VS Code → change appears in Studio within a second
- [ ] `selene src/` runs clean
- [ ] `stylua src/` runs clean
- [ ] Claude Code can list files in the repo
- [ ] Claude Code can see your Studio instance tree via MCP
- [ ] `git commit` and `git push` work
- [ ] `git worktree add ../smj-test -b test/scratch` works, then remove it
- [ ] A trivial DataStore write and read succeeds in Studio

**The gate:** change one line, see it in Studio, commit it — in under 60 seconds.

---

## 7. Admin worth handling early

Ten minutes each, and much more annoying later than now.

- **Usage budget.** Decide a monthly ceiling and check weekly. Three parallel worktrees overnight costs roughly three times one session.
- **Backups.** Save a `.rbxl` snapshot on every production publish. Roblox's version history is decent, not a substitute.
- **Taxes.** DevEx payouts are income. If this earns anything meaningful, you'll want records of it from day one rather than reconstructing them in April. Worth a short conversation with whoever does your taxes — I'm not the right source for that.
- **Working with your son.** If he contributes and this ever earns money, have the conversation about how that works *before* there's money to argue about. It's a much easier conversation at zero dollars.
- **Account hygiene.** 2FA on your Roblox account. It owns the revenue.

---

## 8. Your first real session

Once Phase 0 verifies clean, open Claude Code in the repo and start with:

> Read `docs/GAME-DESIGN.md` and `CLAUDE.md`. Then propose the file
> structure for the Phase 1 vertical slice — just the module list and
> what each is responsible for. Don't write code yet. Explain your
> reasoning and name one structural alternative you rejected.

That prompt does four things at once: loads the design into context, produces something reviewable in two minutes, forces the teaching mandate into play immediately, and establishes plan-before-code as the default rhythm for the whole project.
