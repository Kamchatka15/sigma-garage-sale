# Glossary — the words, and why they exist

Not just definitions. Each entry says **what problem it solves**, because the intent is the part that makes it stick.

---

## Version control

**Repository (repo)**
A folder whose entire history git tracks. *Solves:* "I broke it and I don't know what I changed." Every state you've ever committed is recoverable.

**Commit**
A saved snapshot with a message. *Solves:* granular undo. Commit small and often — a commit is free, and a big commit is unreviewable.

**Branch**
A parallel line of history. Work on `feat/customers` doesn't touch `main` until you merge. *Solves:* letting broken work-in-progress exist without breaking the working game.

**`main`**
The branch that's always meant to work. Rule for this project: **`main` is always playable.** If `main` is broken, fixing it is the only task.

**Pull request (PR)**
A proposal to merge a branch into `main`, with a diff you review before accepting. *Solves:* the "agent wrote 800 lines while I slept" problem. The PR is the review surface — it's where you spend your 3 decision-minutes.

**Diff**
The line-by-line changes. Reading diffs is the core skill of supervising agents. Get fast at it.

**Worktree**
A second folder containing a second branch of the *same* repo. *Solves:* running multiple agents at once without them overwriting each other. See `OPERATING-MODEL.md` §5 — this is the parallelism primitive.

**Merge conflict**
Two branches changed the same lines; git can't decide. *Solves nothing — it's a symptom.* Prevention: give each agent a scope fence so they touch different files.

---

## Claude tooling

**Agent**
A model running in a loop with tools — it reads, writes, runs commands, and decides what to do next, repeatedly, until the task is done. The distinction from chat: an agent *acts* between your messages.

**Subagent**
An agent spawned by another agent for a sub-task, with its own fresh context. *Solves:* context exhaustion on big tasks. Cost: it starts cold and knows nothing you didn't tell it.

**Context window**
Everything the model can currently "see" — your files, the conversation, tool output. *Solves nothing; it's a limit.* When it fills, quality degrades. This is why scoped briefs beat "here's my whole codebase, fix it."

**`CLAUDE.md`**
A file in your repo that Claude reads automatically every session. Conventions, architecture rules, standing instructions. *Solves:* re-explaining your project every single time.

**Headless mode (`claude -p "..."`)**
Runs a prompt non-interactively, prints the result, exits. *Solves:* putting Claude in a script, a cron job, or a CI pipeline where there's no human to talk to.

**MCP (Model Context Protocol)**
A standard way for tools to expose capabilities to a model. The Roblox Studio MCP server is what lets Claude Code see your game tree and console. *Solves:* the model being blind to everything outside your text files.

**Skill**
A packaged set of instructions for a recurring task, invoked by name. *Solves:* "I explain the same workflow every week."

**Hook**
A command that runs automatically at a lifecycle point — e.g. run the linter after every file edit. *Solves:* enforcing standards without remembering to.

**Slash command**
A saved prompt you invoke with `/name`. *Solves:* retyping your common requests. Make one for your session-review routine.

**Plan mode**
Claude researches and proposes an approach, and won't edit until you approve. *Solves:* the agent confidently building the wrong thing. Use it for anything Tier 2 or above.

---

## Roblox development

**Luau**
Roblox's dialect of Lua. Gradually typed — add `--!strict` at the top of a file and you get real type checking, which catches a large class of bugs before playtesting.

**Rojo**
Syncs files on your disk into Studio in real time. *Solves:* Roblox scripts normally living *inside* the `.rbxl` place file, where git can't see them. Rojo makes your game a normal codebase.

**`default.project.json`**
Rojo's map from folders on disk to instances in Studio. `src/server/Foo.server.luau` → a `Script` named `Foo` in `ServerScriptService`.

**Luau LSP**
The VS Code extension giving autocomplete, type errors, and Roblox API awareness. Non-negotiable — it catches typos that would otherwise cost you a playtest cycle.

**`selene` / `StyLua`**
Linter and formatter. *Solves:* style arguments with an agent, and a category of real bugs. Wire both into CI.

**Place vs. Universe**
A *universe* (experience) contains one or more *places*. You want **two places**: production (players) and staging (you). Never test on production.

**Open Cloud**
Roblox's REST API. Can publish a place file, read analytics, manage DataStores. *Solves:* automating deployment. Keep its API keys away from unattended agents.

**DataStore**
Roblox's persistent per-player storage. *Solves:* saving progress. Its danger: a bad schema change can corrupt live player data irreversibly. Always version your schema and never let an agent change it unreviewed.

**Remote (RemoteEvent / RemoteFunction)**
The client↔server messaging boundary. *Solves:* the client and server being separate machines. **Security rule: never trust the client.** If the client sends "I sold this for 40,000," the server must verify it independently. Exploiters will find every remote you expose.

**CCU**
Concurrent users. The vanity metric. **Retention is the real one** — Roblox's algorithm ranks on return behavior, not peak players.

**D1 / D7 retention**
Percentage of new players who return the next day / a week later. Targets: ~12% D1, ~3% D7. These two numbers determine whether your game grows or dies.

---

## Process

**Vertical slice**
One complete path through the game, ugly but end-to-end. *Solves:* building three beautiful half-systems that have never once run together.

**Spec / brief**
A written description of what to build and how you'll know it's done. *Solves:* agents guessing. The "Done when" section is the whole value.

**Scope fence**
An explicit "do not touch these files" in a brief. *Solves:* unreviewable sprawling diffs.

**ADR (Architecture Decision Record)**
A dated note explaining why you chose something. Your `DECISIONS.md`. *Solves:* you, in three days, wondering why.

**CI (Continuous Integration)**
Automated checks on every push — lint, tests, build. *Solves:* discovering breakage during a playtest instead of in ten seconds.

**Technical debt**
Shortcuts that cost you later. Some is fine and correct at this stage. The unacceptable kind is **debt you don't know you have** — which is exactly what merging unreviewed agent code produces.

---

## The two rules worth memorizing

1. **You cannot supervise what you don't understand.** When an agent uses a term or a pattern you can't explain back, stop and ask. That question is not a detour from the work — for goal #1, it *is* the work.

2. **Verification is the bottleneck.** Every process choice in this project exists to make agent output faster to check. If a workflow change makes review slower, it's not an optimization no matter how much throughput it adds.
