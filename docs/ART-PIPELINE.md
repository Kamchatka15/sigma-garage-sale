# Art Pipeline

You have Gemini Pro and SuperGrok available. Here's exactly where to point them — and where not to.

---

## The core rule stays intact

**In-game junk items remain labeled boxes.** That's the style, and it's what protects you from repeating *The Ideology*'s failure. Do not let access to image generation quietly raise your art bar. The moment you start generating a custom image for each of 40 items, you've reintroduced the exact problem this design was built to avoid.

Image generation is for the **four places where art actually moves the numbers**, listed below in priority order.

---

## 1. Game icon and thumbnails — by far the highest leverage

This is the single most valuable art in the project, and it isn't close.

Your icon is what players see on the discovery page. It determines click-through rate, which determines whether Roblox's algorithm keeps showing you to people. **A great game with a bad icon gets buried.** A mediocre game with a great icon gets a chance.

**What to generate:**
- 1 game icon (512×512) — must read clearly at thumbnail size on a phone
- 3–5 thumbnails (1920×1080) — these are the screenshots on your game page

**Prompting notes:**
- Bold, high-contrast, few elements. It will be displayed at ~150px.
- Faces and big readable objects outperform detailed scenes
- Match the game's actual look, or you get clicks followed by immediate bounces — which hurts retention worse than the clicks help
- Text on thumbnails should be huge or absent

**Test it properly:** shrink your candidates to 150px, put them in a row with five real Roblox icons, and see if yours draws the eye. Generate 20, keep 1.

---

## 2. UI elements

The item cards, price dialogs, and buttons are what players stare at for 90% of playtime. Worth real effort.

Generate: panel backgrounds, button states, rarity frames, currency icons, the shop panel. Keep a consistent palette — decide the palette first, then reference it in every prompt.

**Constraint:** Roblox UI wants clean 9-slice-able panels and transparent PNGs. Generated images often need cleanup. Budget time for that, or generate simple shapes and style them in Studio instead.

---

## 3. Decals and signage

Stall signs, junkyard posters, the "Wanted" board, background billboards. Great use of image gen — they're flat textures, no modeling involved, and they add a lot of environmental personality per unit of effort.

---

## 4. Marketing clips and TikTok assets

Thumbnails for your Shorts, channel art, meme templates. Cheap, high-volume, directly tied to the promotion plan.

---

## Where NOT to use it

- **3D meshes.** Neither tool produces game-ready Roblox meshes. Roblox's own AI mesh tools are the better path if you go there at all — and you shouldn't, in v1.0.
- **Per-item art.** Covered above. This is the trap.
- **Anything you'd need 40 consistent variations of.** Style consistency across many generations is still the weak point, and inconsistent items look worse than uniform boxes.

---

## Two real constraints

**Moderation.** Every image you upload to Roblox goes through automated review, and Roblox's AI moderation is aggressive — [it has a documented history of false positives](https://scand.ai/scandal/roblox-ai-moderation-controversy). Upload your icon early, not the night before launch, so a rejection doesn't block your ship date.

**IP risk.** Generated images can inadvertently reproduce protected designs, and this is unresolved industry-wide. Practical guardrails: never prompt with a brand, character, or artist name; give anything that looks recognizable a second look; and keep your generations, so you can show provenance if it ever matters.

---

## Which tool for which job

Both are capable; use whichever gives you better results in practice, and don't overthink it.

| Job | Suggested | Why |
|---|---|---|
| Icons and thumbnails | Try both, A/B the outputs | This matters enough to generate 20+ and pick |
| UI panels and frames | Whichever holds a palette more consistently | Consistency matters more than peak quality here |
| Decals, posters, signage | Either | Low stakes, high volume |
| Marketing images | Either | Volume work |

**Workflow tip:** ask me here in Cowork to write the prompts, then run them in Gemini or Grok. Prompt-writing is thinking work and it's the part that determines whether you generate 20 usable candidates or 20 near-misses. Bring the results back and I'll help you pick — evaluating an icon at thumbnail scale against competitors is a real skill and easy to get wrong when you're attached to one you like.

---

## Where this fits the schedule

Art is a **Phase 4** activity. Do not generate a single image before Phase 3 is complete.

The temptation to make it look good before it *is* good is exactly what stalled the last project. Ugly and fun beats beautiful and unfinished, every time, and only one of the two can be fixed later.
