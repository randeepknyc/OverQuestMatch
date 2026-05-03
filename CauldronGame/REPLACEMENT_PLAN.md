# Cauldron Game — Replacement Plan

**Status:** Existing `CauldronGame/` folder in OverQuestMatch3 contains a complete-but-undesired implementation. This plan replaces it with the new design from our recent design sessions.

**For:** the user (designer, doesn't code) and Claude in Xcode (does the implementation).

**Read first:** SESSION_CHECKPOINT.md, EdnarsCauldron_Reference.jsx. This plan assumes you understand the new design.

---

## Summary

- ✅ Keep: folder name `CauldronGame/`, dev switcher routing, splash/title/map navigation in app
- ✅ Salvage from existing code: bag/discard system, dice tier enum (kept dormant), debug positioning overlay
- ❌ Throw out: combat model, patron generation, all views, theme colors, dice types (mirror/restoration/terrain), `CauldronSketch.png` asset
- 🆕 Build new: JSON data layer, turn-based combat, queue/swap, 7-phase animation, 14 named characters, 4-rounds-per-day, customer-line scene

---

## Pre-flight checklist (the user does these, BEFORE starting Phase 1)

### 1. Commit current state to source control

In Xcode: Source Control → Commit → label it "Pre-Cauldron-rewrite checkpoint." This is your safety net. If anything goes wrong during the rewrite, you can revert to this commit.

### 2. Place the JSON data files in the project

Drag `traits.json`, `characters.json`, and `rounds.json` from this design output folder into Xcode's `CauldronGame/` group. In the dialog: ✅ "Copy items if needed" and ✅ Add to OverQuestMatch3 target.

### 3. Have ART_SPEC.md and the reference files visible

Open these in Xcode tabs so Claude in Xcode can read them:
- `EdnarsCauldron_Reference.jsx`
- `traits.json`, `characters.json`, `rounds.json`
- `ART_SPEC.md`
- `SESSION_CHECKPOINT.md`
- This file (`REPLACEMENT_PLAN.md`)

### 4. Decide: placeholder art now, or build code first?

Recommendation: **build code first with emoji/SVG placeholders matching the web prototype.** When real art arrives, swap in PNGs in Phase 8. This means you don't need any art to start coding.

---

## The first prompt to give Claude in Xcode

Copy and paste this verbatim:

> I'm replacing the existing CauldronGame implementation in my OverQuestMatch3 project with a new design. The existing code (CauldronModels.swift, CauldronViewModel.swift, CauldronGameView.swift) is going to be largely thrown out and replaced.
>
> Read these files first, in this order:
> 1. REPLACEMENT_PLAN.md (this is the playbook)
> 2. SESSION_CHECKPOINT.md (current design state)
> 3. EdnarsCauldron_Reference.jsx (architectural spec)
> 4. The three JSON files (traits.json, characters.json, rounds.json)
>
> Also read the existing Swift files in CauldronGame/ so you know what's being replaced and what bits we're salvaging (bag/discard system, dice tier enum, debug positioning overlay).
>
> I do NOT code. You're the implementation. I'll verify each phase works before we move on.
>
> **Phase 1 only**: Set up the data layer. Create the new Codable structs (Trait, Character, RoundDef, GlobalSettings) matching the JSON shape (use CodingKeys for snake_case → camelCase mapping). Create an ObservableObject called `CauldronGameData` that loads the three JSON files at app launch. Add a debug print confirming the load: e.g. "Loaded 14 characters, 8 traits, day_1 round structure."
>
> Don't touch the existing Swift files yet. We're going to migrate piece by piece. Phase 1 is just data loading running alongside the existing code.

---

## Phases (do in order, verify after each)

### Phase 1 — Data layer (no UI changes)

**What Claude builds:**
- New file: `CauldronGameData.swift`
- Codable structs: `Trait`, `TraitEffects`, `Character`, `RoundDef`, `DayDef`, `GlobalSettings`, `RoundRules`
- JSON loader using `Bundle.main.url(forResource:withExtension:)`
- Single `ObservableObject` called `CauldronGameData` exposing loaded data via `@Published` properties
- Debug print at app launch confirming load

**What you verify:**
- Run app → console shows "Loaded 14 characters, 8 traits, day_1 round structure"
- App still works (existing Cauldron game still runs as before — we haven't touched it)

**Commit when verified.**

### Phase 2 — Game state model (still no UI changes)

**What Claude builds:**
- New file: `CauldronGameState.swift`
- New struct: `Customer` (instance of a character with HP, patience, status — created at round start from a character template)
- New struct: `Die`, `Placement`
- New ObservableObject: `CauldronGameState` with @Published properties for: `customers`, `queue`, `inspectedId`, `composure`, `shield`, `hand`, `placements`, `selectedHandIndex`, `gameState`, `isAnimating`
- Functions: `tapProfile(id:)`, `placeDie(handIdx:nodeId:)`, `unplaceDie(nodeId:)`, `selectHand(idx:)`, `computeBrew()`
- The full `doBrew()` async function with all 7 animation phases (phase logic complete; visual animations come in Phase 5)

**What Claude SALVAGES from the existing code:**
- The `BagDie` struct from `CauldronModels.swift` (unchanged)
- The `DieTier` enum from `CauldronModels.swift` (KEEP for future use — every die created at `.basic` tier in v1, but the enum stays defined)
- The `drawFromBag()`, `discardAllDice()`, `buildStartingBag()` logic from existing `CauldronViewModel.swift` — adapted to use the new dice types (5 types: potency/stability/boost/heal/shield, not 6)

**What you verify:**
- Ask Claude to write a debug test in `CauldronGameDataTests` that simulates a round programmatically: "Spawn 3 customers from rounds.json (day_1.evening), tap profile customer at index 1, verify queue order swapped correctly, place 2 dice, brew, verify damage applied AND each customer attacked back AND patience ticked."
- Run the test in Xcode, see it print expected results in console.

**Commit when verified.**

### Phase 3 — Replace the views (UI starts being new)

**Now we delete and rebuild.** This is the destructive phase.

**What Claude does:**
- DELETE entire contents of `CauldronGameView.swift` (or rename old file to `CauldronGameView.swift.old` for safekeeping until verified)
- DELETE the contents of `CauldronModels.swift` (move salvaged bits — `BagDie`, `DieTier` — into `CauldronGameData.swift` or a new `CauldronDie.swift` first)
- DELETE the contents of `CauldronViewModel.swift` (`CauldronGameState.swift` from Phase 2 replaces it; if naming conflicts, rename old VM file to `.old`)
- Build new `CauldronGameView.swift` with:
  - Top bar: composure bar + shield overlay + potion-count badge + hamburger
  - Customer scene (200pt tall, Ednar at counter on LEFT, customers approaching from RIGHT)
  - Profile button row OR inspect strip (conditional)
  - Cauldron with 12 nodes
  - Dice tray with 5 slots
  - All wired to `CauldronGameState`
- For now use emoji placeholders (matching the web prototype) instead of art assets
- Theme: warm/parchment palette from the web prototype (`#FAF6EE`, `#3a2410`) — NOT the existing dark/purple theme. The user will refine colors later when art is in.

**What you verify:**
- Run app → switch dev switcher to Cauldron → see new layout
- All sections render (might be ugly but everything's there)
- App doesn't crash

**Commit when verified.**

### Phase 4 — Wire up the queue/swap mechanic

**Critical phase. This took 8 attempts in the web prototype.**

**What Claude builds:**
- Render `customers[]` array as profile buttons in the row (NEVER reordered)
- Render `queue[]` array as positioned customers in the scene (uses queue index → QUEUE_X/Y/SCALE/DIM tables)
- `tapProfile(id)` swaps `queue[indexOfTapped]` with `queue[0]` — pure 2-element swap
- Animate position changes with `.animation(.easeInOut(duration: 0.35), value: queue)`

**What you verify:**
- Round opens with 3 customers visible. Customer 1 leftmost (active), 2 middle, 3 rightmost.
- Tap profile button for customer 2 → customer 2 slides to leftmost, customer 1 slides to where 2 was, customer 3 doesn't move
- Tap profile button for customer 3 → customer 3 slides to leftmost, the previously-leftmost customer slides to position 3
- Profile buttons in the row NEVER reorder
- Inspect strip opens on tap (showing the tapped customer's name, order, trait, HP)

**If the swap is wrong:** describe what you SEE happening, not what you think the bug is. (See the bug pattern in SESSION_CHECKPOINT.md — the fix is always: queue is the truth, no derived state.)

**Commit when verified.**

### Phase 5 — Cauldron + dice + brewing (no animation yet)

**What Claude builds:**
- 12-node cauldron rendered using `CauldronBoard.nodes` positions (matching the existing topology, since that worked)
- Dice tray with 5 slots showing `hand[]` dice
- Tap-die-then-tap-node placement
- BREW button on the rotated ladle
- `MAX_PLACEMENTS_PER_BREW = 3` cap enforced visually (nodes dim when at cap)
- Tap BREW → state updates from `doBrew()` (Phase 2's logic), customers take damage / shield / heal applied, attacks fire — but ALL AT ONCE without the animation sequence yet

**What Claude SALVAGES:**
- The 12 node positions from `CauldronBoard.nodes` (the existing custom layout from the user's debug positioning work)
- The brew button rotation angle and position (the user fine-tuned this with debug tools)

**What you verify:**
- Tap a die → highlighted ring
- Tap a node → die lands there
- 3-die cap enforced
- Tap placed die → returns to tray
- Tap BREW → damage applied to active customer, each customer's attack hits you, hand reshuffles for next turn
- Killing a customer removes them from queue, next customer becomes active

**Commit when verified.**

### Phase 6 — Animation sequence (the polish phase)

**What Claude builds:**
- The 7-phase animated brew sequence (see EdnarsCauldron_Reference.jsx for timing)
- Shake modifier (CSS `ec-shake` equivalent — use `GeometryEffect` with sine wave)
- Float modifier for damage/heal numbers (animate offset y -50, opacity 1 → 0, over 0.9s)
- Pulse modifier for boost dice (`scaleEffect` 1 → 1.15 → 1, brightness 1 → 1.4 → 1)
- Composure flash when hit (red overlay 0.35s)
- Persistent shield badge (appears when shield > 0, positioned to the right of Ednar)
- Input lock via `isAnimating` — disables all tap handlers during the sequence
- Dice "drop and bounce" animation when hand is dealt (each die starts ~80pt above its slot, falls with rotation, bounces, settles, ~600ms each, staggered ~80-100ms — see ART_SPEC.md)

**What you verify:**
- Tap BREW with shield + heal + potency placed:
  1. Boost dice pulse first (if any)
  2. Heal applies, +N float from Ednar, bar grows
  3. Shield applies, 🛡 +N float, badge appears next to Ednar
  4. Active customer shakes, -N float from them
  5. Each customer attacks one by one with visible gaps, composure flashes red, -N floats from Ednar
  6. Patience ticks (silent)
  7. Expirations fire if any
- All input ignored during the sequence
- Dice "patter in" when hand deals at start of next turn

**Commit when verified.**

### Phase 7 — Round flow + win/lose states + composure rest

**What Claude builds:**
- Round-end overlay (when `queue` empties): "Round complete" + potions brewed + "Continue" button
- "Continue" advances to next round (morning → afternoon → evening → night)
- Apply `COMPOSURE_REST_BETWEEN_ROUNDS` (currently 5) when round ends
- Day-end overlay (when night round complete): "Day complete" + "Begin Next Day" or "End Game"
- Lose overlay (composure ≤ 0): "You collapsed" + "Try again" or "End Game"
- "End Game" buttons return to the app's title screen (matching how Match-3, Physics, Shop work — see MASTER_CONTEXT.md)

**Important architectural note:**
DO NOT build a per-game title screen or end screen. The app's main flow (splash → title → map → game selector → game) is in `OverQuestMatch3App.swift` and is shared across all games. The Cauldron game starts directly in `playing` state and ends by returning to the app's title.

**What you verify:**
- Complete a round → "Round complete" → tap Continue → next round starts with full hand
- Composure value shows +5 when round transitions
- Complete all 4 rounds (full day) → "Day complete" → Begin Next Day → Day 2 starts
- Let composure hit 0 → "You collapsed" → End Game → returns to app title screen

**Commit when verified.**

### Phase 8 — Trait effects + polish

**What Claude builds:**
- Implement these trait effects (functioning):
  - `intimidating` — brew target +2 per intimidating customer in queue
  - `volatile` — overbrew triggers retaliation BEFORE shield/heal
  - `pious` — flavor only (no mechanical effect, but trait shows in inspect strip)
  - `skittish` — `active_patience_tick` × 2 (already in JSON, just needs to read the value correctly)
  - `draining` — 1 composure per turn per draining customer in queue
  - `inspiring` — +1 to all dice values while in queue
- STUB these (declared in code but not firing):
  - `loud` — log a TODO when this customer is in queue, don't apply effect yet
  - `hexer` — same, TODO

**What Claude SALVAGES:**
- The Debug Positioning Overlay (`DraggableNodeView`, `DebugPositionOverlay`, `DraggableBrewButtonView`) from existing `CauldronGameView.swift` — this is genuinely useful authoring tooling for fine-tuning the layout when art is in. Adapt to work with the new layout system.

**What you verify:**
- Round with Crispin (intimidating) — brew targets show +2 above his HP
- Round with Greta (inspiring) — all dice in hand show +1 to face value
- Round with Grimdrek (volatile) — overbrew him → eat retaliation damage
- Round with Ironhilde (draining) — see composure tick down 1 each turn
- Round with Ardo (skittish, active) — patience drops 2 per turn instead of 1 when he's at the front

**Commit when verified.**

### Phase 9 — Art swap-in

**What Claude does:**
- When user provides PNGs (per ART_SPEC.md), migrate the asset catalog
- Replace emoji placeholders with `Image("filename")` references
- DELETE old `CauldronSketch.png` from assets (per user direction)
- Color theme adjusts to match the user's art-driven palette (user will direct this)

**What you verify:**
- Each character portrait renders correctly at all three sizes (active scene ~76pt, profile button ~56pt, inspect strip ~56pt)
- Cauldron 3-layer rendering: dice appear BETWEEN liquid layer and front layer
- Ednar 5 expressions swap correctly based on game state
- Background shop interior is visible behind everything

**Commit when verified. THIS IS V1 SHIP.**

---

## Files in `CauldronGame/` after the rewrite

```
CauldronGame/
├─ CauldronGameView.swift        ← all views (rewritten)
├─ CauldronGameState.swift       ← game logic + state (rewritten)
├─ CauldronGameData.swift        ← JSON loader + structs (new)
├─ CauldronDie.swift             ← die types, tier enum, bag system (new, but salvages from existing)
├─ CauldronBoard.swift           ← node positions and edges (lifted from existing CauldronModels.swift)
├─ CauldronTheme.swift           ← color palette (rewritten — warm/parchment instead of dark/purple)
├─ DebugPositioning.swift        ← debug overlay (lifted from existing CauldronGameView.swift)
├─ traits.json                   ← (added in pre-flight)
├─ characters.json               ← (added in pre-flight)
└─ rounds.json                   ← (added in pre-flight)
```

Compare with existing structure:
```
CauldronGame/
├─ CauldronModels.swift          ← deleted, contents redistributed
├─ CauldronViewModel.swift       ← deleted, replaced by CauldronGameState.swift
└─ CauldronGameView.swift        ← rewritten (debug overlay extracted)
```

---

## Verification at the end of the rewrite

The integration test that proves the rewrite is correct:

1. Launch app → splash → title → map → game selector
2. Tap "Cauldron" → game loads directly into Day 1 / Morning round (no per-game title screen)
3. See Mildred (active) and Tomik (waiting) in the scene
4. Tap Tomik's profile → Tomik slides to active, Mildred slides to waiting
5. Place 2 dice in cauldron, tap BREW → animation sequence plays out
6. Continue through morning, afternoon, evening, night → "Day complete"
7. Game offers "Begin Next Day" → Day 2 generates customers from random rules
8. Open debug menu → "End Game" → returns to app title screen

If all 8 work, the rewrite is shipped.

---

## When something breaks

1. **The console error wins.** If Xcode prints an error, paste it to Claude verbatim. Don't paraphrase.
2. **Describe what you SEE, not what you think is wrong.** "Customer 3 is leftmost when I tapped customer 2" is useful. "The queue is broken" is not.
3. **Compare to the playable web prototype.** If you're not sure what the correct behavior is, play the artifact in chat and confirm.
4. **Revert often.** If a phase derails, `Source Control → Revert` to the last committed state. Don't try to fix on top of broken state.

---

## What this plan deliberately does NOT do

- ❌ Migrate the existing code's "underbrew penalty" or "expiry-only damage" combat model. We're using the new turn-based model. Period.
- ❌ Migrate the existing 6-dice-types system. We're using 5 (potency/stability/boost/heal/shield).
- ❌ Migrate the patron generator (`PatronData`). All customers come from `characters.json`.
- ❌ Migrate the existing title/end screens. The app handles those globally.
- ❌ Migrate the gold/payment system from the existing code. Our session design didn't include economy. **If the user wants gold/economy in v1, this is a TODO that needs separate design.**
- ❌ Migrate the brew tier system (Failed/Basic/Silver/Gold). Our session design has binary outcome (defeated or not). **If the user wants tiered brewing, this is a TODO.**
- ❌ Migrate the 5-day campaign structure. Our session design has 4 rounds × N days; the existing code has 5 days × variable patrons. **If the user wants a fixed 5-day season, that's a campaign-design decision separate from the core game.**

These deliberate omissions are FUTURE_CHANGES candidates. If any of them feel important to you (the user), tell Claude in Xcode to add them as TODOs in the new code so they're not forgotten.

---

## Final note for the user

This is a real rewrite. Plan for it to take time — likely several Xcode sessions, with playtesting between phases. The phases are ordered so each one stands on its own — after Phase 4, you have a working queue. After Phase 5, you have working brewing. After Phase 6, you have a polished animation. **Stopping after any phase leaves you with a runnable game**, just less feature-complete than the next phase would.

If you ever feel overwhelmed: **just do Phase 1.** Get the data loading. Verify it. Stop. Come back tomorrow for Phase 2. The rewrite isn't a sprint, it's a build.

When in doubt about anything not covered here, the source of truth order is:
1. `EdnarsCauldron_Reference.jsx` — architecture
2. The playable web artifact — behavior
3. This plan — execution order
4. `SESSION_CHECKPOINT.md` — locked decisions
5. `FUTURE_CHANGES.md` — what's deferred

Good luck.
