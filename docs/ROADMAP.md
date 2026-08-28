# Roadmap

Eight weeks at 30 minutes a day. Each phase has a **gate** — a question you answer honestly before continuing.

---

## Phase 0 — Setup (one weekend, ~2 hours)

Not 15-minute sessions. Sit down once and do it properly.

- [ ] Install Claude Code, Rojo, VS Code + Luau LSP, `selene`, `StyLua`
- [ ] Enable Studio's built-in MCP server
- [ ] Create the repo, push to GitHub (private)
- [ ] Create `CLAUDE.md`, `DECISIONS.md`, `SESSIONS.md`, `BACKLOG.md`
- [ ] Create the Roblox universe with **two places**: `staging` and `production`
- [ ] Verify the loop end to end: edit a file in VS Code → see it in Studio → commit → push

**Gate:** Can you change one line, see it in Studio, and commit it — in under 60 seconds? If not, fix that before writing any game code. Everything downstream compounds off this loop.

---

## Phase 1 — Vertical slice (week 1)

One ugly path through the entire game. No polish, no upgrades, no saving.

**Build:** walk to junkyard → pick up 1 item → walk to your stall → place it on a shelf → set a price → one customer walks up → buys or declines → you get money.

- 10 items, no rarity system yet
- One shelf
- One customer at a time
- Grey boxes with text labels
- No saving — progress lost on leave, that's fine

**Gate:** Does the sell moment feel *good*? The money popping out, the sound, the number going up. If that one interaction isn't satisfying, nothing built on top of it will be. Spend an extra session here rather than moving on.

---

## Phase 2 — The v1.0 loop (weeks 2–3)

Locked scope. Everything here, nothing more.

- [ ] 40 items across 5 rarities
- [ ] Bag with capacity limit
- [ ] 3→12 shelves via upgrade
- [ ] Four upgrades: shelves, stall level, customer rate, bag size
- [ ] Customer taste/wallet/patience system
- [ ] **Near-miss thought bubbles** (the teaching mechanism — do not cut this)
- [ ] **Knowledge/appraisal progression** (the differentiator — do not cut this)
- [ ] Whale customers
- [ ] DataStore save/load with a versioned schema
- [ ] Offline earnings
- [ ] Basic HUD + pricing dialog

**Gate:** Can a stranger reach their first upgrade in under 4 minutes without you explaining anything? Watch someone do it silently. Do not help them. What they do wrong is your onboarding backlog.

---

## Phase 3 — Tuning (week 4)

The week that turns "functional" into "fun." Mostly numbers, almost no new code.

- Hit the pacing targets in `GAME-DESIGN.md` §7
- Playtest with your son and 3–4 of his friends. **They are the target demographic and you are not.** Watch, don't coach.
- Write down every moment someone looks confused or bored. Those are your bugs, regardless of what the code does.
- Tune the first four minutes obsessively

**Gate:** Do playtesters ask to play again *without being asked*? That's the only signal that matters at this stage.

---

## Phase 4 — Ship (week 5)

- [ ] Game icon and thumbnails (see `ART-PIPELINE.md` — highest-leverage art in the project)
- [ ] Title, description, tags
- [ ] Analytics events wired for the funnel: join → first sale → first upgrade → session end
- [ ] Two game passes live (convenience only)
- [ ] Publish to production
- [ ] Post your first 10 TikToks

**Gate:** none. Ship it. It will be imperfect. Shipping is the point.

---

## Phase 5 — Retention iteration (weeks 6–7)

Now you have real data instead of opinions.

- Watch D1 and D7 daily
- One change per cycle, measured — not five changes at once
- Ship an update **weekly minimum** (Roblox's algorithm rewards freshness with visibility)
- Fix the biggest drop-off point in the funnel, then re-measure

**Gate — the honest one:** After two full tuning passes, is D1 above 8%?

- **Yes** → continue to Phase 6, and consider putting money into creator promotion
- **No** → **stop.** Write a post-mortem, bank what you learned about the workflow, and start concept #2 with a much faster setup phase.

Write that criterion into `DECISIONS.md` *now*, while you're unattached to the outcome. The failure mode for side projects isn't picking wrong — it's spending eight more months on something the data already answered.

---

## Phase 6 — Growth (week 8+)

Only if you cleared the gate.

- Player-to-player stalls (the highest-value backlog item)
- Haggling minigame
- Prestige system
- Paid creator promotion, informed by which of your own clips performed
- Automate the boring half aggressively — you now know what "good" looks like well enough to supervise it

---

## Realistic expectations

| Outcome | Rough likelihood | What you get |
|---|---|---|
| Game earns nothing | Most likely | A working agent workflow and a shipped game. Goal #1 achieved. |
| Earns $50–500 total | Plausible | Above plus the full monetization loop learned end to end |
| Earns steady monthly income | Uncommon | A real asset worth maintaining |
| Breakout hit | Rare | You'd know by week 6 |

Most Roblox games earn approximately nothing — that's the base rate, and pretending otherwise would be lying to you. **Structure the project so you win even in row one.** That's why goal #1 is listed first in the README, and it isn't a consolation prize: a workflow you can point at any project is worth more than one game's revenue.

---

## Scope discipline — read this when you're tempted

You will, around week 3, have an idea that is genuinely better than something in v1.0.

Write it in `BACKLOG.md`. Do not build it.

*The Ideology* didn't fail because the ideas were bad. It stalled because the scope kept moving and the graphics bar kept rising. The single highest-value habit available to you on this project is finishing a small thing.
