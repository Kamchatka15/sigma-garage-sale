# Sell My Junk

A Roblox yard-sale tycoon. Scavenge absurd items, set your own prices, sell to customers with terrible taste.

**Two goals, in order of honesty:**
1. Learn agent-driven development and workflow automation well enough to apply it to anything else.
2. Make money.

Goal 2 is the scoreboard. Goal 1 is the thing you actually keep. If the game flops but you come out knowing how to run parallel agents against a real codebase with a real deadline, this was worth doing.

---

## Why this project, specifically

You've shipped a Roblox game before — *The Ideology* — and it stalled on two things: **graphics** and **scope**. This project is designed as the direct counter to both.

- **Graphics:** the art style is deliberately primitive. Junk items are labeled blocks. The comedy is in the *writing*, not the modeling. There is no scenario where this project stalls on a mesh.
- **Scope:** v1.0 is a locked feature list in `docs/ROADMAP.md`. Every good idea that arrives after that list goes into `BACKLOG.md` and does not get built. The backlog is where ideas go to wait, not to die — but they wait.

If you only take one habit from this project, take the second one.

---

## The documents

Read them in this order. Total read time is about 25 minutes — do it in two sittings, not one.

| Doc | What it's for | Read when |
|---|---|---|
| `docs/GAME-DESIGN.md` | The actual game. Loops, economy, what makes it stick. | First, all of it |
| `docs/OPERATING-MODEL.md` | Your 15-minute cadence, what agents do, who owns what | Before you write any code |
| `docs/GLOSSARY.md` | Every term and tool, explained with intent | Skim now, return constantly |
| `docs/ROADMAP.md` | 8 weeks, phased, with a locked v1.0 scope | Before week 1 |
| `docs/SETUP.md` | Environment checklist, exact commands, `CLAUDE.md` template | The day you start |
| `docs/ART-PIPELINE.md` | Where to point Gemini / SuperGrok, and where not to | Phase 4 — not before |

Files you'll create as you go: `CLAUDE.md`, `DECISIONS.md`, `BACKLOG.md`, `SESSIONS.md`. All explained in `OPERATING-MODEL.md`.

---

## The one-paragraph version

You work 15 minutes every 12 hours. In that window you review what agents built, playtest, and write the next brief. Between windows, agents implement specs you approved, generate content, run tests, and report back. You are a director and reviewer, not a typist. The bottleneck is your judgment about what's fun — that's the part that doesn't automate, and protecting your attention for it is the entire point of the workflow.

---

## Current status

**Phase 0 — Setup.** Nothing is built yet. Start with `docs/SETUP.md`.

Existing code in this folder: `ReplicatedStorage/Config.lua` — a first pass at the tunables. Treat it as a draft to argue with, not a foundation.
