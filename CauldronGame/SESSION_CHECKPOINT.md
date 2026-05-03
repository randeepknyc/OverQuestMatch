# Ednar's Cauldron — Session Checkpoint

**Last updated:** End of Session 4 (combat model overhaul + animation sequence locked)

This document is your **resume point**. If you start a fresh chat with Claude (in claude.ai or in Xcode) and want to pick up where you left off, share this file plus the others in the project folder. Claude will know what's done, what's pending, and how to proceed without you re-explaining.

---

## What this project is

**Ednar's Cauldron** is a witch potion-shop dice-placement game with turn-based combat, designed as a new game folder inside an existing iOS multi-game project called **OverQuestMatch3**. It's intended to ship as a standalone game first, with possible cross-game progression integration later.

**Inspiration:** Die in the Dungeon (turn-based dice combat) meets a friendly potion-shop sim (customers in queue, time pressure).

**Platform:** iOS (SwiftUI). Eventually iPad. Maybe Android someday.

**User context:** Designer who does NOT code. Iterates with Claude (in chat for design, in Xcode for implementation). Uses Procreate on iPad for art.

---

## ⚠️ IMPORTANT: existing implementation is being replaced

The `CauldronGame/` folder in OverQuestMatch3 already contains a **complete-but-undesired** implementation (CauldronModels.swift, CauldronViewModel.swift, CauldronGameView.swift). The user designed a different game in our recent design sessions and **wants to replace the existing code wholesale**.

**This means the Xcode work is a REWRITE, not a port.** Read `REPLACEMENT_PLAN.md` for the concrete step-by-step execution order.

What gets salvaged from the existing code:
- Folder name `CauldronGame/` (don't rename)
- Bag/discard system from `CauldronViewModel.swift`
- `DieTier` enum (kept dormant in v1, every die at `.basic` tier)
- Debug positioning overlay from `CauldronGameView.swift` (authoring tool)
- Custom-positioned 12-node board layout from `CauldronModels.swift`

Everything else is thrown out and rebuilt.

## Where things stand

### ✅ DONE

- **Game design fully locked**, including turn-based combat model
- **Data files written** — characters.json (14 customers), traits.json (8 traits), rounds.json (Day 1 curated, Day 2/3 templated)
- **Playable web prototype** working with all the locked mechanics (queue/swap, brewing, animation sequence)
- **Architectural reference** written for the Xcode rewrite (`EdnarsCauldron_Reference.jsx`)
- **Xcode rewrite plan** written (`REPLACEMENT_PLAN.md`) — concrete step-by-step plan for replacing the existing code, with all instructions written for someone who doesn't code
- **Art specification** written (`ART_SPEC.md`) — 34 PNGs at locked dimensions
- **Authoring guide** for adding new characters/traits (`CHARACTER_AUTHORING_GUIDE.md`)
- **Future changes list** consolidated (`FUTURE_CHANGES.md`)

### 🟡 IN PROGRESS / NEXT

- **Art:** user is making 34 PNGs in Procreate. Suggested order: dice → one test character → remaining characters → Ednar (5 expressions) → cauldron (3 layers) → background → UI icons.
- **Xcode rewrite:** not started. Will begin once user is ready, following the 9-phase plan in `REPLACEMENT_PLAN.md`. Placeholder emojis let code progress without art being ready.

### ⏸ DEFERRED

See `FUTURE_CHANGES.md` for the full list. Highlights:
- Hexer + Loud trait implementations (stubbed in data, not wired in code)
- Bag/discard visualization (currently reshuffles fresh each brew)
- Drag-and-drop dice (currently tap-to-place)
- Days 2-7 difficulty curve (Day 1 first)
- Sound + haptics (v2)
- Save state / persistence (v2)

---

## Locked design decisions (do not re-litigate)

These were settled across multiple sessions. If a fresh chat tries to question them, point at this list.

### Game structure
- **Day = 4 rounds**: morning → afternoon → evening → night
- **Night is always 1 boss customer**
- **3 dice max per brew**, hand of 5 (forces strategic choice)
- **Composure carries between rounds** with +5 partial rest (`COMPOSURE_REST_BETWEEN_ROUNDS = 5`, may flip to 0 later)

### The customer queue
- **`queue[0]` is always front of line**, leftmost on screen, closest to Ednar's counter, the active brew target
- **Tap profile = swap with `queue[0]`** (pure 2-element swap), open inspect strip
- **Profile buttons NEVER reorder** (driven by `customers[]` which is never reordered)
- **Strip = inspect-on-tap**, not always-visible
- **THIS TOOK 8 ATTEMPTS TO GET RIGHT** — don't redesign

### Combat model (Session 4)
- **Each turn after brew applies**, every customer in queue attacks: active uses `active_attack`, waiters use `waiting_attack`
- **Patience is purely a timer**, ticks down 1/turn (2 for Skittish while active), no per-turn damage
- **Patience hits 0 → customer storms out + deals one-time `expire_damage`**
- **NO underbrew penalty**
- **Shield absorbs first, then composure**
- **Turn order:** brew applies → customers attack → patience ticks → expirations → draining drain

### Animation sequence (BREW tap, ~2-3s total)
1. Boost dice pulse (~450ms)
2. Heal applies, +N float from Ednar (~500ms)
3. Shield applies, badge appears next to Ednar (~500ms)
4. Brew damage hits active customer, shake (~450ms)
5. Each customer attacks one by one (~400ms each, staggered)
6. Patience ticks (silent, ~200ms)
7. Expirations resolve (~450ms each)
8. Draining trait drain (~400ms)

Input is locked during the sequence (`isAnimating` flag).

### Layout (mobile portrait)
- Header: composure bar + potion-count + hamburger
- Customer scene: 200px tall, Ednar at counter on LEFT, customers in line going RIGHT
- Profile button row OR inspect strip (conditional)
- Cauldron: 12 nodes, ladle with BREW button
- Dice tray: 5 slots, wooden frame at bottom
- **Persistent shield badge** appears between Ednar and customers when shield > 0

### Art
- **34 PNGs total** (14 customers + 5 Ednar expressions + 3 cauldron layers + 5 dice + 1 background + 6 UI icons)
- **Dice animation: drop-from-above with bounce**, ~600ms per die, staggered ~80-100ms
- **Customer transitions: 0.35s ease-in-out** when queue changes
- **Cauldron is 3 layers**: back (z1) / liquid (z2) / front (z4) so dice render BETWEEN liquid and front

---

## Critical bugs solved (so they don't recur)

### "Wrong customer goes to the back" bug

**What it looked like:** tapping profile 2 caused customer 3 to slide to the front instead.

**Root cause across 7 failed attempts:** trying to derive scene positions from filtered/sorted state.

**The fix:** `queue` is a simple ordered array of customer ids. `queue[0]` is the front. The renderer iterates the queue and places `queue[i]` at `QUEUE_X[i]`. Tap profile = swap `queue[indexOf(tapped)]` with `queue[0]`. ZERO derived state. The queue array IS the truth.

**Lesson:** when in doubt, make the data structure match the visual layout exactly.

### "Inline onclick doesn't fire" bug

**What it looked like:** tapping dice/nodes did nothing in the artifact.

**Root cause:** inline `onclick="..."` strings don't always work in artifact rendering environments.

**The fix:** event delegation. Single root-level click listener reads `data-action` attributes and dispatches. `pointer-events: none` on inner SVG elements so clicks bubble cleanly.

**Lesson:** this is a web-prototype issue only. SwiftUI doesn't have this problem.

### "First brew kills me" bug

**What it looked like:** in the 3-customer round, the first brew nearly drained all composure.

**Root cause:** old "damage soup" model stacked underbrew penalty + patience tick damage + trait passives all simultaneously.

**The fix:** Session 4 turn-based combat overhaul. Removed underbrew penalty. Patience became pure timer. Each customer makes ONE attack per turn (active_attack vs waiting_attack).

**Lesson:** if it feels punishing on turn 1, it probably IS punishing.

---

## Files in the project folder

| File | Purpose | When to read |
|---|---|---|
| `traits.json` | Game data: 8 traits | When adding/editing traits |
| `characters.json` | Game data: 14 customers with combat fields | When adding/editing customers |
| `rounds.json` | Game data: day/round structure | When adding/editing days |
| `EdnarsCauldron_Reference.jsx` | Architectural spec (React) | First, to understand the system |
| `REPLACEMENT_PLAN.md` | Concrete 9-phase plan to rewrite the existing code | When starting Xcode work |
| `ART_SPEC.md` | 34-PNG asset specification | When making art |
| `CHARACTER_AUTHORING_GUIDE.md` | How to add customers/traits | When expanding the cast |
| `FUTURE_CHANGES.md` | Deferred decisions log | When deciding what to work on next |
| `SESSION_CHECKPOINT.md` | This file | First, to understand state |

---

## How to resume in a fresh chat

### If you want to keep iterating on the design

> "I'm working on Ednar's Cauldron — a witch potion-shop dice game. I have all the design docs in the project folder. Read SESSION_CHECKPOINT.md first to see where we are, then [your specific request]."

### If you want to start the Xcode port

> "I'm replacing the existing CauldronGame implementation in my OverQuestMatch3 project with the design from our recent sessions. Read SESSION_CHECKPOINT.md, REPLACEMENT_PLAN.md, and EdnarsCauldron_Reference.jsx. Then begin with Phase 1 from REPLACEMENT_PLAN.md — the data layer."

### If you're stuck on something specific

> "I'm working on Ednar's Cauldron and stuck on [specific thing]. Here's what I see: [screenshot/description]. Here's what I expected: [what should happen]. Read SESSION_CHECKPOINT.md and EdnarsCauldron_Reference.jsx for context."

### If you're starting a new design sub-feature

> "Adding [new feature] to Ednar's Cauldron. Read SESSION_CHECKPOINT.md and FUTURE_CHANGES.md to understand current state and what's already deferred. Then propose how to design [feature] without breaking the locked decisions in the checkpoint."

---

## What to NOT redesign

In a fresh chat, Claude might be tempted to "improve" things that are already settled. Push back if it tries to:

- Redesign the queue/swap mechanic (8 attempts, finally works)
- Reintroduce the underbrew penalty (Session 4 explicitly removed it)
- Change `MAX_PLACEMENTS_PER_BREW` away from 3
- Reorder the BREW animation phases (locked at 7 phases)
- Suggest a different layout direction (left-to-right line approaching Ednar is locked)
- Propose a different file structure (JSON data + reference JSX is the architecture)

If a fresh Claude proposes any of these, point at this file and `FUTURE_CHANGES.md`.

---

## Final note

The hard design work is done. The hard implementation work (queue/swap mechanic, turn-based combat, animation sequence) is figured out. **The next bottlenecks are art-making and Xcode coding** — those are execution, not design.

If a future session feels like it's churning on already-settled decisions, that's a smell. Stop, re-read this checkpoint, get back on track.
