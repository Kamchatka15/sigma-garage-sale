# Game Design — Sell My Junk

---

## 1. The central insight

Almost every Roblox tycoon is: **click → earn → wait → upgrade → click faster.** There is no decision in it. The player isn't playing, they're maintaining.

Sell My Junk has an actual decision at its center: **what do I charge?**

That single question is the whole game, and it's why this concept has a higher ceiling than the other four. Price too high and customers walk. Price too low and you left money on the table — and you *watch* them buy it happily, which stings in a productive way. There's a real optimum, it's discoverable through play, and players who understand it earn dramatically more than players who don't.

That's a **skill curve**, and skill curves are rare in this genre. It's your differentiation and every other design decision should protect it.

---

## 2. The nested loops

Good games stack loops at different timescales. Each one has to close — the player must feel it complete — before the next begins.

### 30-second loop: appraise → price → sell
Grab an item, decide a number, watch a customer react. This is the atom of the game.

### 10-minute loop: fill bag → stock shelves → watch → upgrade
Run to the junkyard, fill your bag, come back, stock everything, watch a wave of customers, spend the profit on an upgrade. This is one session's worth of satisfaction.

### 1-day loop: offline earnings → daily board → new stock
You come back to money earned while away and a new "Wanted" board. This is the loop that determines your D1 retention, which is the number Roblox's algorithm actually ranks on.

### 1-week loop: prestige / district unlock
Reset your stall for a permanent multiplier and access to a richer neighborhood. This is what keeps week-two players from running out of game.

**Design rule:** if a player quits mid-session, they should be mid-30-second-loop, never mid-10-minute loop. Never make them lose progress by leaving. Stocked shelves keep selling.

---

## 3. Progression is *knowledge*, not just numbers

This is the best idea in the design. Take it seriously.

**Early game, you cannot see what anything is worth.** An item's card says `Haunted Furby — Cursed — Value: ???`. You have to guess. You'll guess badly.

As you sell copies of an item, you unlock information about it:

| Sales | What you learn |
|---|---|
| 1st | "Sold for 480." |
| 3rd | "Average sale: 512" |
| 5th | "Typical range: 400–900. Best sale: 890." |
| 10th | **Appraised.** Exact base value + optimal price band shown. |

Now the number-go-up feels *earned*. The player isn't richer because time passed — they're richer because they **got better at the game**. Returning players feel smarter, not just topped-up.

This also solves the tutorial problem. You don't need to teach pricing. The information gap teaches it, and closing the gap is the reward.

**Second-order effect:** it creates a reason to specialize. A player who's appraised all the Cursed items will hunt Cursed items. That's an identity, and identity drives retention harder than currency.

---

## 4. The customer system (where the feel lives)

Each customer rolls:
- **Taste** — a multiplier on the item's base value, `0.55` to `1.75`. Wide on purpose.
- **Wallet** — how much they can actually spend, scaled by your stall level.
- **Patience** — how long they browse before leaving.

They buy the item with the best *surplus* (their perceived value minus your price) that they can afford.

### The near-miss is the most important interaction

When a customer considers an item and walks away, they must **show you why**:

> 💭 *"...for a bucket of rain? In this economy?"* — walked away, valued it at 90, you asked 140

This is doing three jobs at once:
1. **Information** — the player learns the value distribution without a menu
2. **Tension** — near-misses hold attention harder than clean wins
3. **Comedy** — the customer's reaction line is a joke delivery mechanism

Write 200+ of these reaction lines. They're cheap to generate and they're most of the game's personality.

### Whales

5% of customers roll a 6x wallet and a taste bonus. These are your clip moments — *"someone paid 40,000 for a broken umbrella"* — and they should be visually loud. Gold particle effect, distinct walk-in, the whole thing.

Critically: **a whale is only lucrative if your shelf is stocked with something good and priced high.** That turns the whale from pure luck into a payoff for good preparation. Luck that rewards skill is the good kind.

### Haggling (v1.1, not v1.0)

Customer counter-offers. You accept, reject, or counter once. Turns passive watching into an active beat. Powerful, but it's scope — it goes in the backlog until the core is shipped.

---

## 5. The social layer

**Player-to-player stalls.** You can visit another player's stall and buy from it at their listed price.

This creates *arbitrage*: an experienced player spots a rare item that a new player underpriced, buys it, and resells it at their own stall for 5x. That's an emergent economy nobody had to design, and it generates stories, which generate clips.

It also creates the strongest social hook in the genre: **you are competing for the same customers on the same street.** Undercut your neighbor, or price above them and hope the taste roll saves you.

**Risks to manage:**
- Scamming and griefing potential — mitigate with a confirm-purchase dialog showing the item's known value range
- Alt-account exploitation (transfer money between your own accounts) — cap trades per player per day, and don't let a purchase price exceed some multiple of base value
- Gate this behind stall level 3 so brand-new players aren't immediately fleeced

**Ship v1.0 without it.** Add it in week 5 when you have players. It's the single highest-value post-launch feature.

---

## 6. The junkyard

Where you get stock. A shared open area with junk piles spawning continuously.

- **Common spawns** are everywhere. No competition, no stress.
- **Rare spawns** are announced server-wide with a beam of light and a 45-second timer. Everyone races for it.

That race is important: it creates a **reason to be online at a specific moment** without punishing you for being offline. Nobody loses anything by missing it. That's the distinction between a good engagement hook and a bad one.

---

## 7. Economy pacing targets

Numbers to design against. Tune until these hold.

| Milestone | Target time | Why |
|---|---|---|
| First sale | < 60 seconds | The loop must close before they can get bored |
| First upgrade purchased | < 4 minutes | Proves the progression exists |
| First "Odd" rarity item | < 8 minutes | Escalation, and a taste of the real money |
| Stall level 3 | ~45 min | End of session one |
| First item fully appraised | ~35 min | The knowledge system announces itself |
| First whale encounter | ~25 min | Early enough to be a hook, rare enough to be a story |
| Prestige available | ~6 hours playtime | Week-one goal |

**The first four minutes are 80% of your retention.** If a player doesn't reach an upgrade in four minutes, they leave and Roblox's algorithm reads that as a bad experience and stops showing you to people. Tune the opening harder than anything else.

---

## 8. Compelling vs. extractive

You said "addictive," and the honest read is you mean *compelling* — a loop people want to come back to. That's legitimate craft and this whole document is about how to do it well.

There is a line, though, and it's worth naming once so it can just live in the design constraints:

**Build:** loops that reward skill and knowledge, offline progression, cosmetics, permanent unlocks, convenience purchases for players already enjoying themselves.

**Don't build:** paid randomness (also a compliance minefield — Roblox now mandates published odds globally), timers engineered to be painful enough to buy out of, progression walls placed exactly where the frustration peaks, or anything whose conversion depends on a nine-year-old's impulse control rather than their genuine enjoyment.

The practical argument, not just the moral one: Roblox's 2026 discovery algorithm ranks on **return behavior** — D1 around 12%, D7 around 3%. Extractive design produces a spend spike and a retention collapse. The algorithm reads the collapse and buries you. The incentives genuinely line up here, which is convenient.

Your son is roughly the target demographic. That's a useful gut check to keep available.

---

## 9. Art direction: the anti-*Ideology* clause

*The Ideology* stalled on graphics. This one cannot, because of one rule:

> **Every junk item is a labeled crate. The joke is the label.**

A grey box that says *"Jar of Old Air (2003 Vintage) — notes of basement, sommeliers are divided"* is funnier than a photorealistic jar, costs zero minutes to produce, and is infinitely scalable. Two hundred items is a writing task, not a modeling task.

Commit to this as a **style**, not an apology. Bold flat colors, thick outlines, chunky readable type, rarity-colored borders. It should look intentional — like a deliberate aesthetic choice — because it is one.

Where to spend the small art budget you have, in order:
1. **UI polish** — the item cards and price dialogs are 90% of what players look at
2. **The sale animation** — money popping out, satisfying sound, screen shake
3. **The whale entrance** — this is your clip
4. **Everything else** — free library assets, no exceptions

---

## 10. What's explicitly NOT in v1.0

Locked. These go in `BACKLOG.md`.

- Haggling minigame
- Player-to-player stalls
- Prestige system
- Multiple districts
- Custom stall decoration
- Pets, minigames, obbies, anything borrowed from another genre
- Any mesh you'd have to model

v1.0 is: junkyard → bag → shelves → pricing → customers → four upgrades → save/load. That's it. Ship that ugly, in two weeks, and let real player data tell you what to build third.
