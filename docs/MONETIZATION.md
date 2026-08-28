# Monetization — Sigma Garage Sale

> Governed by the hard guardrail in `CLAUDE.md`: **convenience and cosmetics
> only.** No paid randomness, no progression walls, no timers engineered to be
> painful enough to buy out of. The audience is children.
>
> This document exists to show that constraint is not a tax on revenue. For this
> particular game it's the *better* business.

---

## 1. The strategic frame — retention is the monetization

The instinct is to design the store first. On Roblox that's backwards, and the
reason is structural:

```
Revenue  =  Daily Active Users  ×  Revenue per user
                    ↑
          driven by DISCOVERY, which the
          algorithm awards based on RETENTION
```

Roblox's discovery algorithm ranks on **return behavior** — does a player come
back tomorrow, and next week. Traffic is the scarce input, and it is bought with
retention, not with conversion tuning. A 2% conversion rate on 50,000 daily
players beats a 6% conversion rate on 2,000 every single time.

**The practical consequence, and it drives the phasing in §8:** every hour spent
on the store before the raid loop is proven fun is an hour spent optimizing the
monetization of a game nobody returns to. Fix fun → get traffic → then monetize
the traffic.

This is also why the ethical line and the profitable line are the same line
here. Extractive design produces a spend spike followed by a retention collapse;
the algorithm reads the collapse and buries the game. That's not a moral
argument, it's the mechanic.

---

## 2. This game's natural advantage

**Sigma Garage Sale is a game about visible status on a street.** That is an
unusually good fit for cosmetic monetization, and it's mostly luck of the
premise — we should exploit it deliberately.

Every other player can see your house from the sidewalk. A house skin isn't a
private inventory item nobody notices; it's a billboard in the middle of the
shared space that the entire game is *about*. Kids buy identity, and this design
hands us the single best surface for selling it without touching game balance.

That means the flagship product is **house and yard cosmetics**, and we can hit
revenue targets without ever going near the raid mechanics.

---

## 3. Revenue streams available

| Stream | Type | Fit here | Balance risk |
|---|---|---|---|
| **Game passes** | One-time, permanent | Strong | Medium — see §5 |
| **Cosmetic store** | One-time, permanent | **Flagship** | None |
| **Private servers** | Monthly recurring | Strong | None |
| **Premium payouts** | Passive, engagement | Free money | None |
| **Developer products** | Repeatable consumable | Use sparingly | **High** |
| **UGC avatar items** | One-time | Later | None |

Two notes:

- **Private servers are underrated for this game.** "Rent the cul-de-sac for you
  and your friends" is recurring monthly revenue, zero balance impact, and a
  natural fit for a 13-house block that friend groups will want to themselves.
- **Premium payouts** pay for engagement time from Roblox Premium members. No
  design work, no store, no balance risk — it rewards being a good game. It also
  means retention work is *directly* revenue work, reinforcing §1.

**Developer products (repeatable consumables) are where kids' games go bad.**
They're the natural home of the painful-timer pattern. We use them for cosmetic
bundles and seasonal drops only — never for anything that removes friction the
game deliberately created.

---

## 4. The catalog

### Cosmetics — flagship, zero balance impact

Buyable with **both in-game cash and Robux**. This matters: free players earn
some, payers skip the grind, and the store stays aspirational for everyone
rather than reading as a wall.

| Category | Items |
|---|---|
| **House skins** | Haunted, Candy, Neon, Castle, Spaceship, Treehouse |
| **Yard decor** | Flamingo flock, gnome army, hedge maze, above-ground pool |
| **Blanket skins** | For the homeless start — cheap, funny, the ideal first purchase |
| **Cart skins** | The wagon you haul loot in |
| **Trap skins** | Cosmetic reskins only — **never** power |
| **Sale table** | Tablecloths, signage, price-tag styles |
| **Emotes** | The "caught" taunt, victory poses, the sigma stare |

The blanket skin is the deliberate entry product — a homeless player on the curb
is the one moment where *everyone* wants to look less pathetic, it costs us
nothing to make, and first purchase is the hardest conversion in the funnel.

### Game passes — one-time, permanent

| Pass | What it does | Why it isn't pay-to-win |
|---|---|---|
| **Night Shift** | 2× offline sale earnings | Offline only; no effect on raids or price ceiling |
| **Cargo Pants** | +bag slots, **capped at the in-game maximum** | Accelerator, not exceeder |
| **Second Table** | Extra sale slots | More listings — pricing skill still decides the outcome |
| **Yard Sign Studio** | Custom sign text and art | Pure expression |
| **Quick Sale** | Instantly restock your own yard once a day | Your own yard only; no raid advantage |

### Private servers

Monthly. Whole cul-de-sac, friends only, all 13 houses available.

---

## 5. The pay-to-win line — specific rules for this game

The pivot to a competitive raid game **moved this line**, and the old design's
assumptions no longer hold. In the solo version, a bigger bag was harmless
convenience. In a game where players raid each other, carry capacity is combat
power. Three rules:

1. **Nothing purchasable may exceed a ceiling reachable through play.** Robux can
   make you faster to the cap. It can never raise the cap.
2. **Nothing purchasable may affect a raid in progress.** No bought movement
   speed inside a yard, no heat reduction, no trap power, no raid immunity,
   no faster searching. The raid is a pure skill space and it stays that way.
3. **Nothing purchasable may make you harder to raid.** The moment a player can
   buy an impassable yard, the core loop dies for everyone else and the game
   becomes a rich-kid diorama.

Rule 2 is the one that will be under constant pressure, because "just a little
speed boost" is the most obvious thing to sell in a chase game. It is also the
one that would kill this design fastest.

**The canary metric (§7): if paying players have a materially higher raid
success rate than free players, the line has been crossed** — regardless of what
we intended when we shipped the item.

---

## 6. What we deliberately will not sell

### Mystery Junk Crates — the trap we must name out loud

A paid mystery box of random junk fits this game's theme *perfectly*. That is
exactly why it's dangerous — it will keep looking like a great idea.

It's out, for three independent reasons, any one of which is sufficient:
- It's paid randomness aimed at children, which the guardrail forbids outright
- Roblox mandates published odds, and gambling-adjacent mechanics aimed at
  minors carry live regulatory risk in multiple jurisdictions
- It converts on impulse control rather than enjoyment, which is the exact
  failure mode `CLAUDE.md` was written to prevent

### Also out

- **Raid protection or immunity** — sells the core loop for parts
- **Trap power** (as opposed to trap skins) — makes yards unraidable by wallet
- **Skip-the-cooldown products** — this is the painful-timer pattern; if a
  cooldown is bad, shorten it for everyone
- **Direct cash purchases** — buying the house ladder is buying the game's
  entire progression, which was the one item cut from the original pivot pitch
- **Energy or stamina systems** — a limiter invented purely to sell its removal

---

## 7. Instrumentation — what to measure

Nothing here is tunable without data. Minimum viable analytics:

| Metric | Why | Healthy signal |
|---|---|---|
| **D1 / D7 retention** | The input to discovery — the number that matters most | D1 ~12%, D7 ~3% as a floor |
| **Time to first purchase** | First conversion is the hardest | Under one session |
| **Conversion rate** | % of players who ever spend | 1–3% typical |
| **ARPDAU** | Revenue per daily user | Track the trend, not the value |
| **Raid success: payers vs free** | **The pay-to-win canary (§5)** | Gap ≈ 0 |
| **Cosmetic attach rate** | Which items actually convert | Informs what to build next |
| **Session length by house tier** | Does the ladder hold attention? | Flat or rising |

The raid-success canary is the one nobody else will think to build. It's what
turns "we intended not to be pay-to-win" into something falsifiable.

---

## 8. Phasing — when to build each piece

Ordered by §1: fun first, traffic second, revenue third.

**Phase A — before any store exists**
Prove the raid loop is fun (`GAME-DESIGN.md` §14 v1.0 slice). Ship Premium
payouts by default — they need no store and reward retention directly. Build
the analytics in §7 *now*, because retroactive data doesn't exist.

**Phase B — first revenue, after D1 clears the floor**
Cosmetic store, 6–10 items, blanket skins and house skins first. Private
servers. These are zero-balance-risk, so they can ship while tuning continues.

**Phase C — game passes, once the economy is tuned**
Night Shift, Cargo Pants, Second Table. Requires the in-game ceilings to be
settled first, or rule 1 in §5 can't be enforced — you can't cap a purchase at
an in-game maximum that doesn't exist yet.

**Phase D — seasonal and UGC**
Seasonal cosmetic drops, avatar items, holiday house skins. This is the
long-tail revenue engine and it only works on an audience that already returns.

---

## 9. The revenue math — structure, not promises

Verify current rates on the Creator Dashboard before planning against them; the
platform's cut and the DevEx rate have both changed historically and any number
written here will age.

```
Monthly revenue ≈ DAU × conversion% × average spend × (dev share)
                                                       ↑
                            Robux → USD via DevEx, minus platform cut
```

Two things this structure makes obvious:

1. **DAU is the term with the most leverage**, and it's bought with retention,
   not with store tuning. A 10× traffic increase beats every possible pricing
   optimization.
2. **Small purchases from many players beat large purchases from few.** Price the
   entry cosmetics low enough that a kid with a nearly empty Robux balance can
   buy *something*. The second purchase is far easier than the first.

**The honest expectation:** most Roblox games earn approximately nothing,
because most never clear the discovery threshold. The distribution is extremely
top-heavy. Plan for this to make little money, build it because the loop is fun,
and treat revenue as the consequence of retention rather than the target.

The kill criterion in `DECISIONS.md` still stands and is the relevant guardrail:
if D1 is below 8% after two full tuning passes, stop and write the post-mortem.
No amount of store design fixes a game people don't return to.
