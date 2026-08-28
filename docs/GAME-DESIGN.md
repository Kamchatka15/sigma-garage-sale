# Game Design — Sigma Garage Sale

> Supersedes the original *Sell My Junk* design, archived at
> `docs/archive/GAME-DESIGN-selljunk-v1.md`. The pricing engine survives the
> pivot intact; the wrapper around it is new. See `DECISIONS.md` for why.

---

## 1. The central insight

The old design had a real skill curve — *what do I charge?* — and no reason for
a ten-year-old to click on it. "Sell My Junk" is a spreadsheet with a hat on.

The fix isn't to replace the pricing game. It's to give it **stakes and a
fantasy**:

> **You start homeless on a cul-de-sac of thirteen houses. You scavenge other
> people's yards, sell the loot at your own garage sale, and buy your way up the
> block. The mansion at the end is the win condition.**

That single sentence is legible to a child in about four seconds, which the
previous premise never was. Underneath it, the pricing decision is unchanged —
it's now the thing you do with the loot you *risked something to get*.

**Design rule that governs everything below:** the raid creates the tension, the
sale resolves it. If a change makes raiding safer or pricing more automatic, it
is probably making the game worse.

---

## 2. Why this is fun — four distinct sources, four timescales

Naming these explicitly so we can check features against them. A proposed
mechanic that doesn't feed one of these is scope.

| Timescale | The fun | The mechanic |
|---|---|---|
| 5 seconds | *"Do I search one more spot or leave?"* | Heat meter rising while you loot |
| 60 seconds | *"I got out with the good stuff."* | The extraction beat |
| 5 minutes | *"What is this actually worth?"* | Hidden values, near-miss feedback |
| 1 week | *"I own the house at the end of the block."* | The ladder, and defending it |

The 5-second loop is the one the old design completely lacked, and it's the one
that makes kids press the button again.

---

## 3. The nested loops

### 30-second loop: sneak → search → escape
Enter a yard, search hiding spots, watch your heat rise, get out before the
defender catches you. **This is the new atom of the game.**

### 3-minute loop: raid → price → sell
Come home with a bag, decide what each piece is worth, set out your sale, watch
customers react. The old 30-second loop becomes the mid-loop — it's now the
*payoff* for a raid rather than the whole game.

### 30-minute loop: bank → buy → move up
Enough profit buys traps, bag upgrades, tools — and eventually the next house up
the block. You physically move. The progress is visible from the street.

### 1-week loop: hold the block
You own a good house. Now other players raid *you*. Traps, layout, and being
online become defense. The mansion owner is the most-raided player on the
server, which self-balances the endgame.

**Inherited rule, still absolute:** if a player quits mid-session they should be
mid-30-second-loop, never mid-30-minute-loop. Leaving never costs banked
progress. Your sale table keeps selling while you're gone.

---

## 4. The block — thirteen houses

Thirteen rungs, each with a distinct loot table, a distinct defender, and a
distinct *movement puzzle*. Defender variety is what keeps raid #200 different
from raid #3 — not loot rarity.

| # | House | Loot flavor | Defender | What makes it different |
|---|---|---|---|---|
| 0 | **The Curb** (start) | — | — | You sell off a blanket. Can't be raided. |
| 1 | Condemned Fixer-Upper | Construction scrap, rusted tools | None | Undefended. The tutorial house. |
| 2 | Cat Lady House | Doilies, porcelain, surprise antiques | Cats (many, fast, noisy) | Alarms, not chasers — heat spikes |
| 3 | Hoarder House | Volume junk, occasional buried gem | Slow resident | Piles block your escape routes |
| 4 | Nerd House | Sealed collectibles, high appraised value | Camera drone | Sightlines — must break line of sight |
| 5 | Jock House | Trophies, sports gear | Sprinter | Pure footrace; hardest to outrun |
| 6 | Party House | Speakers, novelty items | Distracted host | Loud music masks *your* noise too |
| 7 | Health Nut House | Gadgets, supplements, smoothie tech | Endless jogger | Never tires — you must break contact |
| 8 | Crypto Bro House | High value, prices swing wildly | Security cameras | Volatile loot; sell timing matters |
| 9 | Doomsday Prepper | Canned goods, gear, bunker stash | Owner + max traps | Trap density, not speed |
| 10 | Retired Rockstar | Memorabilia, legendary-tier items | Roadie | Slow but hits hard on catch |
| 11 | Influencer House | Ring lights, unopened PR boxes | Livestreamer | Reveals your position to the *whole server* |
| 12 | Celebrity House | Extremely valuable | Bodyguard | Fast *and* strong |
| 13 | **The Mansion** | Best in game | Whoever owns it | The win condition and the target |

**On the archetypes:** these are chosen to be funny and moderation-safe. The
earlier list included a meth house, a "diddy house," and a fat-person house —
all three are drug/sex-crime references or body mockery aimed at an audience of
children, and any one of them is a plausible reason for Roblox to pull the
experience. The comedic register is preserved; the takedown risk isn't.

### Houses keep producing loot regardless of ownership

Critical: **owning a house does not remove it from the loot pool.** If it did, a
full server would have nothing left to scavenge.

- Your own yard restocks and yields to you passively — a small private income.
- The *best* loot is always in houses you don't own.
- So the pressure to leave your house and take risks never goes away.

---

## 5. The raid loop — heat, catching, and the carry

This is the section to get right. Everything here is tuned to be tense without
being punishing, because the audience is nine.

### Searching

Each house has ~15 possible stash spots (mailbox, under the porch, trash cans,
shed, doghouse, car trunk, kiddie pool, garage shelving, under the bed, closets).
**4–6 are populated per raid, chosen randomly.** Searching a spot is a
1.5-second hold.

You never know which spots are live, so you search, and searching is what gets
you caught. That's the whole tension in one sentence.

### Hiding — and the trick that makes it work

**The defender roams.** NPCs walk a patrol route through the yard and house,
pause to investigate noise, and chase on sight. A static guard is a solved puzzle
after two attempts; a roaming one keeps every raid live.

So you need somewhere to go when you hear footsteps. **You hide** — under the
bed, in the closet, behind the couch, in the laundry basket, in the shed, inside
a trash can.

> **The design trick: hiding spots and loot spots are the same objects.**

That single decision does an enormous amount of work:

- The closet you're hiding in **might have loot in it** — and searching it while
  the defender is three feet away makes noise. That's an agonising, funny,
  entirely player-made decision.
- The world needs one set of objects, not two, so the whole system is cheap to
  build and instantly readable.
- Players learn the map as *both* a treasure map and an escape map, which is
  what makes the tenth raid on a house still interesting.

While hidden, the camera drops to a slit view — closet slats, the gap under the
bed — and you watch the defender's feet go past. Hold a key to **peek**, which
sees more and risks more.

The defender can **open hiding spots** when their suspicion is high. Being found
under the bed is the single best moment in the game and it needs the loudest
comedy in the whole design.

### Heat — the readable risk dial

Instead of random gotchas, a visible **heat meter**:

- Searching a spot: +heat
- Sprinting: +heat
- Tripping a trap: large +heat
- Crouch-walking, standing still: heat decays

At full heat the defender knows where you are and hunts you. Heat is
**telegraphed and player-controlled**, which is the difference between "I made a
bad call" (fun) and "the game got me" (quit).

### Getting caught — you lose loot, never money

Defender touches you →

- You drop the **unsold loot in your bag from this run**, scattered in the yard
  (recoverable by anyone, including you, if you dare go back)
- You're ejected to the street, 10-second cooldown
- **You lose no cash, no banked items, no sale-table items, no house**

**Loot, never money — and the distinction is load-bearing.** Losing banked cash
reads to a child as *the game took something I earned*, and they log off. Losing
what you were carrying reads as *I searched one spot too many*, and they go
straight back in. Same penalty size, opposite retention outcome.

Scattering the loot rather than deleting it adds the greed beat: your stuff is
lying in the grass, visible, and the defender is still in there.

This is an extraction-game risk model — you only ever risk what you're carrying.
It's proven fun and it's kid-safe. A robbed kid who lost nothing permanent
tries again; a kid who lost their house logs off forever.

### Escaping

You must leave through the yard gate. That's the extraction beat — the moment
where a greedy player loses everything they were carrying and a disciplined one
banks it. **Do not remove the gate requirement.** "Loot and teleport home" kills
the entire tension curve.

### Suspense — built with audio, not scripting

Tension in this genre is almost entirely an **audio** problem. Kids playing
Piggy-likes and Hello-Neighbor-likes are listening far more than they're looking.

| Layer | What it does |
|---|---|
| **Footsteps with distance falloff** | The primary information channel — you track the defender by ear |
| **Floorboard creaks** | Specific boards creak. Learning the quiet route *is* skill |
| **Heartbeat** | Rate rises with proximity while hidden. The single cheapest tension tool that exists |
| **Idle muttering** | You always know roughly where they are, so being surprised is your own fault |
| **Door sounds** | A door opening somewhere in the house is pure dread |
| **Music stinger on max heat** | The chase is scored; silence returns when you break contact |

**The rigged near-miss.** When a player is hidden and the defender's patrol
passes nearby, bias the route to bring them *close, pause, then leave*. Players
remember the time they almost got caught far more vividly than a clean escape —
so manufacture that moment deliberately and often. It costs nothing and it's the
clip people post.

**Escalation, so dread has a shape:** the defender moves through *unaware →
suspicious (pauses, looks around) → searching (opens hiding spots) → chasing*.
Each stage is audibly and visually distinct. The player should always be able to
tell which stage they're in, because dread requires knowing how much trouble
you're in.

### Comedy — the release valve

Suspense with no release is just stress, and stress makes nine-year-olds quit.
Every tense beat needs a funny one behind it.

- **The catch is slapstick.** Comic yelp, ragdoll launch out the front door, dust
  cloud, your loot bouncing across the lawn. Getting caught should be something
  players *show each other*, not something they dread.
- **Every defender is a character, and their catch line is the joke.** The jock
  bellows; the cat lady says *"Mr. Whiskers, we have a guest"*; the influencer
  points a phone at you and says *"say hi to chat."*
- **Muttering doubles as characterisation.** *"Where did I put my... other
  shoe?"* is a patrol cue, a joke, and a hint that there's a Left Shoe in this
  house, all at once.
- **The item names carry the humour** — that's the art direction (§13) and it's
  free comedy at scale.
- **The hiding-spot gag.** Shuffling across a room inside a laundry basket is
  funny every single time. Let players move slowly while hidden in portable
  spots.
- **Taunt emotes at the gate.** Escaping cleanly should be brag-able.

The tonal target is *cartoon burglary* — Home Alone, not horror. When the tension
resolves, it resolves into a laugh.

---

## 6. Defenders — NPC first, players later

The elegant part of this design: **the danger source scales with server
population automatically.**

- **Unowned house** → NPC resident defends it. New player on an empty server
  still gets a real challenge.
- **Owned house, player offline** → NPC house-sitter + whatever traps they set.
  Their stuff is still protected while they sleep.
- **Owned house, player online** → the player can physically chase raiders
  themselves, on top of their traps.

So a brand-new player at 3am and a full 20-player server at peak both get a
game. No dead-server problem, no "wait for players" problem.

**Rule:** an offline player can never lose their sale table, their cash, or
their house. Only **stash** loot is raidable, and the stash has a hard cap.
Bounded downside, always.

---

## 7. Traps — and why every trap needs a counter

Traps are bought with **in-game cash, never Robux** (see §12). Cap per house by
tier so nobody builds an impassable wall.

| Trap | Effect | Counter |
|---|---|---|
| Sprinkler | Soaks, −40% move speed for 5s | Look for the head; walk around |
| Garden gnome alarm | Instant heat spike | Spot it and give it a wide berth |
| Marbles / banana peel | Slip, drop one carried item | Crouch-walk over it |
| Motion light | Reveals your position to defender | Break the beam line, or disarm |
| Guard dog | Chases inside its zone | Throw a decoy (bought tool) |
| Flypaper | Rooted for 2 seconds | Disarm tool, or bait it |

**Every trap must be visible if the player is paying attention.** Telegraphed
traps make getting hit feel like your own mistake, which is fun. Invisible traps
make it feel like the game cheated, which is churn. This is the single most
important tuning rule in the section.

Counters (crouch-walk, disarm tool, decoy) are cheap early purchases, so the
counter-play is available to new players immediately — otherwise traps become a
wall that only veterans can pass.

---

## 8. Progression is knowledge — protect this

**Unchanged from the original design, and it is still the reason this game isn't
generic.** Full detail in `docs/archive/GAME-DESIGN-selljunk-v1.md` §3.

Item values are hidden. Selling copies unlocks information:

| Sales | What you learn |
|---|---|
| 1st | "Sold for 480." |
| 3rd | "Average sale: 512" |
| 5th | "Typical range: 400–900." |
| 10th | **Appraised** — exact base value + optimal band |

The risk: with a house ladder bolted on, this game can collapse into
number-go-up and lose the only mechanic that isn't in every other tycoon on the
platform. **The house is the fantasy. Pricing is the game.** If playtests show
players ignoring prices and just grinding raids, that's a five-alarm signal, not
a tuning note.

House-themed loot tables actually *strengthen* this: appraising all the Rockstar
memorabilia is an identity, and identity drives retention harder than currency.

---

## 9. The garage sale — and the sell-now-or-hold decision

Customers walk up to your sale automatically and buy on the same taste/wallet
model as before (§4 of the archived doc). The **near-miss bubble** stays — it's
the teaching mechanism and most of the game's comedy.

New decision the pivot creates, and it's a good one:

- **Sale table = sacred.** Never raidable. Limited slots.
- **Stash = raidable.** Where unsold loot waits.

So: price it now at a guess and it's safe but maybe underpriced — or hold it in
the stash until you've appraised the item and can charge properly, risking a
raid. That's the pricing skill curve extended into the new premise rather than
bolted next to it.

---

## 10. Economy pacing targets

**The first four minutes are 80% of retention.** Tune the opening harder than
anything else.

| Milestone | Target | Why |
|---|---|---|
| First loot picked up | < 30s | Prove the verb immediately |
| First sale | < 90s | Close the loop before boredom |
| First purchase (trap/bag/tool) | < 4 min | Proves progression exists |
| First successful defended raid | < 5 min | The actual hook |
| First house owned (#1) | ~20 min | End of session one |
| First item fully appraised | ~35 min | Knowledge system announces itself |
| Second house | ~45 min | Ladder is real |
| Mansion | Many hours / week goal | Long-tail retention |

Note the gap: first *house* at 20 minutes is too slow to be the first reward, so
traps and bag upgrades fill the 0–20 minute window. Get that laddering right or
the opening feels empty.

---

## 11. Multiplayer and anti-grief

The audience is children and the mechanic is *taking their stuff*. This needs
active management, not good intentions.

- **Bounded downside** — carried loot only, never banked progress (§5)
- **Stash cap** so a single raid can never be catastrophic
- **Raid cooldown per target** — you can't be farmed by one player repeatedly
- **Grace period** — a newly-bought house is un-raidable for its first minutes
- **No player-vs-player damage.** Defenders eject raiders; nobody fights
- **The Curb is safe.** A homeless player has nothing to lose, so the bottom of
  the ladder is stress-free rather than a pit

Being homeless must read as *funny and scrappy*, not as losing. Selling off a
blanket on the sidewalk is a bit, and it's where everyone starts.

---

## 12. Compelling vs. extractive — the line

**Non-negotiable, from `CLAUDE.md`.** Monetization is convenience and cosmetics
only.

**Build:** house paint and skins, yard signs, stall decoration, cosmetic trap
skins, bigger bag, extra sale slots, offline earnings boost.

**Do not build:** the original pitch included *"players can buy special junk
items that convert to cash which allow them to buy the house."* That's selling
progression directly — the house must be earnable through play, always.

The practical argument beyond the principle: Roblox's discovery algorithm ranks
on **return behavior** (D1 ~12%, D7 ~3%). Pay-to-win produces a spend spike and
a retention collapse; the algorithm reads the collapse and buries the game. The
incentives line up with the ethics here, which is convenient.

Also non-negotiable: **traps and counters are in-game currency only.** A player
who can buy an impassable yard has ended the game for everyone else.

---

## 13. Art direction — unchanged, and it's why this is shippable

> **Every junk item is a labeled box. The joke is the label.**

A grey box reading *"Jar of Old Air (2003 Vintage) — notes of basement,
sommeliers are divided"* is funnier than a modeled jar, costs zero minutes, and
scales to 200 items as a *writing* task. Houses are chunky flat-colored blocks
with readable silhouettes. Commit to it as a style, not an apology.

**Theming is data, never code.** The plan is to ship this engine under several
names and themes on Roblox (`DECISIONS.md`, 2026-08-27). Every themeable string
and colour — house names, item names, reaction lines, palettes, store copy —
lives in `Config` / `ItemDatabase` / `ReactionLines`. A service that hardcodes
"cul-de-sac" or "garage sale" has just made the next reskin a rewrite.

Spend the small art budget in this order:
1. **UI** — item cards, price dialog, heat meter
2. **The heat meter and catch moment** — must be instantly readable
3. **The sale animation** — money pop, sound, shake
4. **Everything else** — free library assets

---

## 14. Scope — the honest version

This design is **substantially larger** than the two-week v1.0 it replaces. A
thirteen-house block with trap systems and player raiding is months of solo work
at 30 minutes a day, not weeks. Pretending otherwise is how projects die.

### v1.0 slice — ships the premise, cuts the tail

- **5 houses**, not 13 (Curb, Fixer-Upper, Cat Lady, Hoarder, Nerd)
- **NPC defenders only** — no player-vs-player raiding yet
- **Heat, searching, catching, extraction** — the whole 30-second loop, complete
- **3 traps + 2 counters**
- **Own one house tier**, to prove the ladder reads
- Existing pricing, customers, near-miss, appraisal — already built

That is still a real game and it tests the actual question: *is the raid loop
fun?* Everything in §14's cut list depends on that answer being yes.

### Deferred to post-v1.0 (`BACKLOG.md`)

Houses 6–13 · player-vs-player raiding · trap tiers · the mansion endgame ·
haggling · prestige · offline raid reports

---

## 15. Open questions for the developer

Decisions I shouldn't make alone:

1. ~~**"Sigma"** — hook vs. slang shelf life.~~ **Decided 2026-08-27:** keep it.
   Shelf life is handled by reskinning the same engine under multiple themes,
   which makes data-driven theming a hard architectural requirement — see
   `DECISIONS.md` and §13.
2. **Do players own one house at a time (move up) or accumulate?** Moving is
   cleaner and makes progress visible from the street; accumulating is a
   stronger flex. I lean moving.
3. **Does the mansion owner get raided by everyone?** I think yes — it
   self-balances the endgame and generates stories. But it may feel punishing.
4. **Server size?** 13 houses wants ~12–20 players to feel populated.
