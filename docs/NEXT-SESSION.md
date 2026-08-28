# Next Session — Install List & First Prompts

Everything you need to paste, in order, plus how to actually drive Claude Code once it's running.

---

## 1. Already done (Aug 27)

Don't redo these.

| Thing | Status |
|---|---|
| Rokit 1.2.0 | installed |
| Rojo 7.7.0 | installed |
| selene 0.31.0 | installed |
| StyLua 2.5.2 | installed |
| Rojo Studio plugin | installed |
| Rojo ↔ Studio sync | **connected and working** |
| Project folder | `~/Downloads/robloxseptember` |
| Studio place | "Untitled Experience" (cloud, private) |

You do **not** have Node or Homebrew. You don't need either.

---

## 2. Still to install

### Claude Code — required

```
curl -fsSL https://claude.ai/install.sh | bash
```

This is the **native installer**: a self-contained binary, no Node.js, puts `claude` on your PATH and self-updates. It's Anthropic's recommended install path.

Open a new Terminal tab afterward (PATH won't refresh in the current one), then verify:

```
claude --version
```

### VS Code + Luau LSP — strongly recommended, not required

Download VS Code from code.visualstudio.com, then install two extensions from inside it:

- **Luau Language Server** (JohnnyMorganz) — autocomplete, type errors, Roblox API awareness
- **Rojo** (evaera) — start/stop the sync from the editor

Without this you're editing Luau in a plain text editor with no type checking, which means you find typos by playtesting instead of by reading. It costs ten minutes and saves hours.

### git repo — do it before you write more code

```
cd ~/Downloads/robloxseptember && git init && git add -A && git commit -m "chore: project skeleton and Phase 1 vertical slice"
```

Ask Claude Code to push it to a private GitHub repo later — it can walk you through auth, which is fiddlier than it should be.

---

## 3. Starting Claude Code

```
cd ~/Downloads/robloxseptember && claude
```

First run asks you to log in — it opens a browser, you approve, you're back.

**Important: launch it from the project folder.** Claude Code reads `CLAUDE.md` from wherever you start it. Start it in your home directory and it has no idea what this project is or what its rules are.

### Commands worth knowing on day one

| Command | Does |
|---|---|
| `/model` | Switch models. Default to Sonnet; escalate to Opus when stuck. |
| `/clear` | Wipe the conversation. Use between unrelated tasks — a stale context makes answers worse. |
| `Esc` | Interrupt. Use freely the moment it heads somewhere wrong. |
| `/help` | Everything else |

---

## 4. Your first four prompts, in order

Copy these. They're sequenced deliberately.

### Prompt 1 — orientation, no changes

```
Read CLAUDE.md and docs/GAME-DESIGN.md, then read every file in src/.

Don't change anything yet. Tell me:
1. What the code does, in 10 lines
2. Anything that will error on first run
3. Anything that contradicts the design doc

Follow the teaching mandate in CLAUDE.md.
```

This costs one minute to read and orients the agent before it touches anything. It also tests whether `CLAUDE.md` is being picked up — if the reply doesn't follow the teaching mandate, Claude Code isn't reading it, and you started it in the wrong folder.

### Prompt 2 — lint and format

```
Run `selene src/` and `stylua --check src/`. Fix everything they flag.
Do NOT change any game behavior — style and lint only.
Show me the diff summary when done.
```

A safe first task with an objective pass/fail. Good calibration for what its output looks like when the answer is unambiguous.

### Prompt 3 — first playtest

In Studio, press **Play**. Watch the Output window. Copy any red errors.

```
I pressed Play and got these errors:

[paste everything]

Fix them one at a time. After each fix, explain what was wrong in one sentence.
Don't batch the fixes — I want to see them separately.
```

The code has never run. There will be errors. That's expected, not a sign anything is broken about the plan.

### Prompt 4 — the first real playtest question

Once it runs without errors, play for five minutes, then:

```
I played for 5 minutes. Here's what happened: [what you did, what felt
slow, what confused you]

Against the pacing targets in docs/GAME-DESIGN.md §7, what's off?
Propose ONE change. Don't implement it yet.
```

One change, measured. Not five at once — you won't know which one worked.

---

## 5. The loop from here

Per `docs/OPERATING-MODEL.md`:

- 15 minutes, twice a day
- Read the report → playtest → decide → write the next brief
- Agents work between sessions on things with a clear "Done when"
- Log each session in `SESSIONS.md`, each real decision in `DECISIONS.md`

Don't automate anything until you've done a week of this by hand. You can't supervise work you've never done, and week one is where you learn what "good" looks like in this codebase.

---

## 6. Deferred

**Studio MCP server** — not present in your Studio build (checked Aug 27: no MCP entry in Studio Settings, no Assistant panel in the View menu). Retry after a Studio update. It's an accelerant, not a requirement; Rojo is what actually matters and it's working.

**Renaming the place** — "Untitled Experience" should become "Sell My Junk" eventually. Cosmetic, changes nothing mechanically.

**Empty `ReplicatedStorage` folder** in the project root — leftover from the file move. Drag it to the trash.
