# The First Session — structure, rules, and how players learn them

> **The first four minutes are 80% of retention.** If a player hasn't reached a
> purchase in four minutes they leave, Roblox reads that as a bad experience, and
> the algorithm stops showing the game to people. Everything in this document is
> tuned against that one fact.
>
> Companion docs: `GAME-DESIGN.md` (the design), `PERSISTENCE.md` (not losing
> your place), `MONETIZATION.md` (why retention is the revenue strategy).

---

## 1. The rules of the game, stated plainly

Twelve rules. A player must eventually know all of them; a player must never be
*told* all of them.

**Getting loot**
1. Walking into junk picks it up. There is no button.
2. Better loot is inside other people's yards, in stash spots that move.
3. Searching a spot takes 1.5 seconds and raises your **heat**.
4. **The people who live there roam.** They patrol, investigate noise, and chase.
5. **You can hide** — under beds, in closets, in the laundry basket. Hiding spots
   *are* loot spots, so the safest place to be is also worth searching.
6. Full heat means the defender knows where you are and comes for you.
7. Caught means you drop what you're carrying *from this run* and get ejected.
   **You never lose money, your sale table, your stash, or your house.**
8. You must leave through the gate. Loot isn't yours until you're out.

**Selling loot**
9. You set the price. Nobody tells you what anything is worth.
10. Customers arrive on their own and either buy or walk away — and when they
    walk away, they tell you what they thought it was worth.
11. Selling copies of an item teaches you its real value, permanently.

**Getting ahead**
12. Cash buys bag space, tools, traps — and eventually the next house up the
    block. Your sale table keeps selling while you're offline.

---

## 2. The teaching principle

> **Every rule is taught by a situation the player cannot fail, before it is
> tested by one they can.**

Kids skip tutorials. Text boxes are read by nobody. So the rules above are taught
by *staging the world*, not by explaining it — the first junk pile is three steps
from spawn and glowing, so rule 1 teaches itself in the two seconds it takes to
walk into it.

Corollary that matters: **the first instance of any mechanic is rigged.** The
first customer always buys. The first house has no defender. The first trap is
placed where it's impossible to miss and cheap to trip. We rig the introduction,
then remove the training wheels immediately after.

---

## 3. Minute by minute — the first session

### 0:00–0:30 · You are homeless, and it's funny

Spawn on the curb at the end of a cul-de-sac with a blanket laid out in front of
you. No menu, no cutscene, no dialog. Three junk items sit glowing within a few
steps.

**Taught:** rule 1 (walk into junk). **Failure possible:** none.

The homeless start has to read as *scrappy and funny*, not as punishment —
you're an underdog with a blanket, not a loser. This framing carries the whole
early game.

### 0:30–1:30 · Your first sale

The blanket is your sale table. Place an item; the game **suggests a price**
seeded from its rarity (never from its true value — see `GAME-DESIGN.md` §8).
Accepting the suggestion is one click.

**A customer arrives within ~15 seconds and always buys.** This first one is
scripted, not rolled.

**Taught:** rules 7, 8 (you set prices, customers come). **Failure possible:**
none — the sale is guaranteed.

The player has now closed the entire core loop inside 90 seconds and knows the
game works. *Then* we introduce the idea that it can fail.

### 1:30–3:00 · The first near-miss — the real lesson

The next customer refuses something and the near-miss bubble fires:

> 💭 *"...for a bucket of rain? In this economy?"*
> — walked away · valued it at **90** · you asked **140**

This is the single most important moment in the game's teaching, and it must be
unmissable: big bubble, both numbers, held long enough to read.

**Taught:** rules 8, 9 (pricing is a real decision, and refusals teach you).
**First genuine decision:** re-price that item, or hold and wait for a customer
with better taste.

### 3:00–4:00 · First purchase — progression proven

Cash from the first sales clears a cheap bag upgrade or a basic tool. Prompted
once, clearly.

**Taught:** rule 10. **Pacing gate:** this must land under four minutes. It is
the retention checkpoint the whole opening is built around.

### 4:00–6:00 · First raid — the safe sandbox

The **Condemned Fixer-Upper** (house #1) is abandoned and *has no defender*.
This is deliberate: it teaches the entire grammar of raiding with the danger
switched off.

Walk in the gate. Search spots — mailbox, trash can, under the porch. Feel the
1.5-second hold. Notice that only some spots have anything. Watch heat rise and
then decay when you stand still. Walk out the gate with a full bag.

**One scripted moment:** partway through, a *neighbour* wanders past the fence on
the sidewalk. Not a threat, can't catch you — but the game prompts you to duck
into a hiding spot and you watch them pass through the closet slats, heartbeat
running. Then they leave and nothing happens.

That single beat teaches hiding, the slit camera, the audio language, and the
whole feeling of the game — with the danger switched off.

**Taught:** rules 2, 3, 5, 8, and the *shape* of rules 4 and 6.
**Failure possible:** none.

Skipping this step is the most tempting cut in the whole design and it would be
a serious mistake — a player's first exposure to heat, searching, hiding, and the
gate should not also be their first exposure to being chased.

### 6:00–9:00 · The first real challenge

**The Cat Lady House.** The gentlest defended yard in the game: the cats are
noisy alarms rather than fast pursuers, so heat spikes are frequent but escape is
forgiving.

> **This is the first genuine challenge of the game: get out of a defended yard
> with loot still in your bag.**

Now hiding matters. The cats roam, the heartbeat runs, and the player has to
decide whether to search the closet they're currently hiding in.

Most players will be caught the first time. That has to be *funny and cheap* —
a yelp, a ragdoll launch onto the sidewalk, your dropped loot bouncing across the
lawn where you can see it and go back for it, 10 seconds of cooldown. Nothing
permanent is lost, and **no money is ever taken**.

**Taught:** rules 4, 5, 6, 7 by direct experience. The lesson lands as *"I
searched one spot too many"* — a decision they made — rather than *"the game got
me."*

### 9:00–20:00 · The ladder becomes visible

The loop is now fully open: raid → price → sell → buy. Traps and tools become
affordable. The player starts noticing that appraised items sell for far more,
which is the knowledge system announcing itself.

### ~20:00 · First house — the session-one payoff

Enough cash buys the Fixer-Upper. **The player physically moves off the curb into
a house on the block, and everyone on the server can see it.**

That visible, permanent, social change of status is the strongest possible place
to end session one, and it's the reason the player comes back tomorrow.

---

## 4. The staged difficulty curve

The question *"what is the first challenge?"* has three answers, deliberately
staggered so no two hard things arrive together:

| # | Challenge | When | Can the player fail? |
|---|---|---|---|
| 1 | Make a sale at all | 0:30–1:30 | **No** — rigged to succeed |
| 2 | Price something correctly | 1:30–3:00 | Yes, but harmlessly |
| 3 | Escape a defended yard | 6:00–9:00 | **Yes — this is the real one** |

Rule: **never introduce a new mechanic while the previous one can still fail
the player.** Heat arrives only after pricing is comfortable; player-defenders
arrive only after NPC defenders are routine.

---

## 5. Onboarding state must persist

Half of onboarding design is not repeating it. The save data carries an
`onboarding` block of step flags (`firstSaleDone`, `firstNearMissSeen`,
`firstRaidDone`, `firstCatchDone`) — see `PERSISTENCE.md` §3.

Consequences, all of which are retention bugs if missed:

- A returning player is **never** shown the rigged first customer again
- The Fixer-Upper is only defender-free until the player's first raid completes;
  after that it defends normally like any other house
- Tips fire once, ever, and never again
- A player who quits at 3:00 and returns tomorrow **resumes at 3:00**, not at
  0:00 — they keep their cash, their items, and their place in the teaching

---

## 6. The return hook — why they come back tomorrow

Day one retention is decided by what greets a returning player. On login:

1. **Offline sales report** — "While you were out: 6 items sold, $840 earned."
   The sale table keeps working (rule 11), so absence is rewarded, never punished.
2. **Knowledge gained while away** — offline sales also advance appraisal, so the
   player returns *smarter*, not just richer. This is the difference between
   number-go-up and genuine progression.
3. **The raid report** — "One raider got into your stash and took 2 items."
   Bounded by the stash cap, framed as a story rather than a loss, and it creates
   a reason to invest in traps.
4. **Restocked yards** — every house has fresh loot in new hiding spots.

---

## 7. What could break this, in priority order

1. **First sale takes longer than 90 seconds.** Kills the opening. Guaranteed
   first customer exists specifically to prevent this.
2. **First purchase slips past 4 minutes.** The single most-watched number in the
   design. Traps and bag upgrades exist partly to fill the 0–20 minute gap before
   the first house is affordable.
3. **Getting caught feels punishing rather than funny.** Comedy and a cheap,
   bounded penalty are load-bearing, not polish.
4. **The player never notices pricing is a decision.** If playtests show people
   accepting every suggested price and grinding raids instead, the game has
   collapsed into a generic tycoon and the near-miss bubble needs to be louder.
5. **Onboarding replays for returning players.** Reads as broken; drives churn on
   exactly the players who already liked it enough to come back.
