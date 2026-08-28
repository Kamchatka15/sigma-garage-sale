# Operating Model

How the work actually happens: your 15 minutes, the agents' 12 hours, and who owns what.

---

## 1. The core principle

> **Your scarce resource is judgment, not typing.**

Agents can produce code far faster than you can evaluate it. That means the binding constraint on this project is *your review capacity*, and every process decision below exists to protect it.

The practical consequence: **an agent task is only worth running if you can verify its output in under five minutes.** A task you can't verify quickly isn't automation, it's just debt you haven't discovered yet.

---

## 2. The 15-minute session

Twice a day, roughly 12 hours apart. Same structure every time.

| Time | What you're doing |
|---|---|
| **0:00–2:00** | Read the agent report. Last entry in `SESSIONS.md`, plus PR titles. Don't read the code yet. |
| **2:00–9:00** | **Playtest.** Open Studio, play the current build. This is the part no agent can do. |
| **9:00–12:00** | Decide on each open PR: merge, revise, or reject. Reject freely — a rejected PR costs you nothing. |
| **12:00–15:00** | Write the next brief(s). Launch the agents. Close the laptop. |

**The trick that makes 3 minutes of brief-writing possible:** dictate while you playtest. When something feels wrong, say it out loud into a notes app immediately — *"customers arrive too slowly at the start, first sale took 90 seconds"*. By minute 12 you have the brief already written, and you're just formatting it.

### The two sessions have different jobs

- **Morning session:** review overnight work, playtest, launch the day's tasks. This is your *quality* session — you're freshest, so this is where you judge fun.
- **Evening session:** shorter review, launch overnight tasks. This is your *throughput* session — queue up the well-specified work that can run while you sleep.

Put the ambiguous, taste-dependent work in the morning. Put the grindy, well-defined work overnight.

---

## 3. The brief is the unit of work

Everything an agent does starts from a brief you wrote. A good brief has five parts:

```markdown
## Brief: Customer near-miss feedback

**Goal:** When a customer declines an item, show a thought bubble with
their reaction line and what they valued it at.

**Why:** Players currently have no way to learn the value distribution.
This is the primary teaching mechanism in the design (see GAME-DESIGN §4).

**Scope:**
- CustomerService fires a `NearMiss` remote with (itemId, perceivedValue, reactionLine)
- Client renders a BillboardGui above the customer for 2.5s
- Pull reaction lines from a new ReactionLines module (20 lines to start)

**Done when:**
- I can decline-test 10 customers and see 10 distinct bubbles
- No errors in output
- `selene` and `StyLua` pass

**Do NOT:** touch the pricing logic or the customer spawn rate.
```

That last line matters more than it looks. **Scope fences are how you keep review time under five minutes.** An agent that touched three files you didn't expect costs you twenty minutes of reading.

---

## 4. What agents can and can't run unattended

### Tier 1 — safe, run in parallel, review by skimming the diff
- Implementing a brief you approved, with tests
- Generating content batches (item descriptions, customer reaction lines)
- Refactors covered by existing tests
- Writing test suites
- Analytics reports and data pulls
- Research ("what are the top 20 tycoons doing for onboarding?")

### Tier 2 — agent drafts, you review carefully before merge
- Economy tuning (agent can model the math; only you can feel the pacing)
- UI layout and visual work
- Anything touching the DataStore schema

### Tier 3 — never unattended
- "Make the game more fun" — unverifiable, therefore not a task
- Publishing to the production place
- Monetization changes
- Anything with no stated success criterion

**The test for which tier:** if you can't write the "Done when" section, it's Tier 3 and you're not ready to delegate it yet.

---

## 5. Parallel agents with git worktrees

This is the technique you asked about, and it's the real unlock.

A **worktree** is a second working copy of the same repository, in a different folder, on a different branch. Same git history, separate files. Three worktrees means three agents editing simultaneously without ever colliding.

```bash
# from your main repo folder
git worktree add ../smj-customers   -b feat/customer-feedback
git worktree add ../smj-content     -b feat/item-batch-2
git worktree add ../smj-tests       -b chore/test-suite
```

Now run one Claude Code session in each folder, each with its own brief. In the morning you have three branches to review as three separate pull requests, each independently mergeable or rejectable.

When you're done with one:
```bash
git worktree remove ../smj-customers
```

### The Roblox-specific catch

**Only one worktree can be synced to Studio at a time.** Rojo maps *one* folder into your place. So:

- Agents write code in parallel across worktrees — fine
- But **playtesting is serial.** You sync one branch into Studio, test it, then switch.

Practical rule: **run at most one Tier 2 (needs playtesting) task at a time, plus as many Tier 1 tasks as you like.** Tier 1 work is verified by reading and by tests, not by playing, so it parallelizes cleanly.

This constraint is the single most common way this workflow goes wrong. Respect it.

---

## 6. Which Claude program for which job

| Job | Tool | Model | Why |
|---|---|---|---|
| Writing game code, live Studio loop | **Claude Code** + Studio MCP | Sonnet 5 | Needs the game tree, console, and playtest control |
| Architecture, economy math, stuck for 2+ attempts | **Claude Code** | Opus 5 | Worth the cost exactly when you're stuck |
| Bulk content (200 item descriptions) | **Claude Code headless** (`claude -p`) | Haiku 4.5 | Volume work, cheap, easy to skim |
| Design docs, planning, marketing, analytics review | **Cowork chat** (here) | Opus 5 | Thinking work, no repo access needed |
| Daily analytics digest, trend monitoring | **Scheduled task** | Sonnet 5 | Runs without your machine on |
| Lint + tests on every push | **GitHub Action** headless | Sonnet 5 | Deterministic, no judgment required |

**Default to Sonnet. Escalate to Opus when stuck, then drop back.** Most of your hours are implementation, not architecture.

---

## 7. Who owns what

### You own — non-delegable
- **"Is this fun?"** The only question that matters and the only one you can answer
- **Scope discipline.** Saying no to good ideas. Agents will never say no.
- **Anything reaching real players.** Every production publish is your keystroke.
- **Monetization decisions.** What gets sold, at what price, to children.
- **Accounts, money, legal, taxes.** Never delegated, never automated.
- **Final merge approval.** Every PR.

### Claude owns
- Implementation from an approved brief
- Tests, linting, refactors
- Content generation in an established voice
- Research and competitive analysis
- Reporting: what changed, why, and what it cost
- **Explaining its own work** — see below

### Shared, with a clear tiebreaker
- **Design:** Claude proposes, you decide.
- **Economy tuning:** Claude models the math, you feel the pacing. If the spreadsheet and your gut disagree, **your gut wins** — then go find out why the model was wrong.

---

## 8. The teaching mandate

You asked to actually understand what's happening rather than just accepting output. That doesn't happen by default — you have to require it. Two mechanisms:

**1. Put it in `CLAUDE.md`** so it applies to every session automatically. Exact text is in `SETUP.md`.

**2. Ask for the reasoning before the code, not after.** The highest-value question you can ask in a 15-minute session:

> "Before you write anything — what's your approach, and what are the two alternatives you rejected?"

Sixty seconds of reading that tells you more about the codebase than ten minutes of reading the diff. And it catches bad approaches before they become code you have to review.

**3. The Friday rule.** Once a week, pick one thing an agent built and rewrite a piece of it yourself, by hand. Not for the code — for the calibration. You cannot supervise work you've never done.

---

## 9. Files that make 15-minute sessions possible

Short sessions fail because of **lost context** — you'll forget why you decided things. Four files fix that.

| File | Contains | Written by |
|---|---|---|
| `CLAUDE.md` | Project conventions, teaching mandate, architecture rules | You, once, then rarely |
| `DECISIONS.md` | Every non-obvious choice + the reasoning + the date | You (2 lines per decision) |
| `SESSIONS.md` | Log of each 15-min session and each agent run | Agents append, you skim |
| `BACKLOG.md` | Every good idea that isn't v1.0 | You, constantly |

`DECISIONS.md` is the one people skip and regret. When you come back in three days and wonder why the taste range is 0.55–1.75 instead of 0.8–1.2, the answer needs to be written down. Two lines is enough:

```markdown
## 2026-08-29 — Taste range widened to 0.55–1.75
Narrow range made optimal pricing solvable in ~10 minutes and the
game became rote. Wide range keeps pricing a live judgment call.
```

`BACKLOG.md` is your scope defense. When an idea arrives mid-session — and it will, constantly — writing it down is what lets you *not build it* without feeling like you lost it.

---

## 10. Budget and guardrails

- **Set a usage budget before you start**, and check it weekly. Parallel agents burn usage far faster than interactive work — three worktrees running overnight is roughly three times the cost of one.
- **Never give an unattended agent production credentials.** Open Cloud API keys stay out of any environment an agent can read. Publishing is a human keystroke.
- **Cap unattended runs.** An agent in a retry loop overnight is the expensive failure mode. Use explicit turn limits.
- **Back up your `.rbxl`** on every publish. Roblox's version history is decent but not a substitute.

---

## 11. Honest expectations

The workflow above is real and it works, but calibrate:

- **Weeks 1–2 will be slower than doing it yourself.** You're learning the tooling while building. That's the point — goal #1 is the tooling.
- **You'll reject a lot of agent output early.** That's the system working. Rejection is cheap; merging something you didn't understand is expensive.
- **30 minutes a day is real but tight.** Expect 8–10 weeks to a polished v1.0, not 4. The roadmap accounts for this.
- **The first version won't be fun.** It'll be *functional*. Fun comes from the tuning pass in weeks 3–4, after you've watched someone who isn't you play it.
