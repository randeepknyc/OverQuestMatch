# CAULDRON_CONTEXT.md
**Ednar's Potion Cauldron — Full Project Context**

> **Last Updated:** May 12, 2026 (PIXEL-ACCURATE SIZING SYSTEM COMPLETE — Ednar + Customers Unified)  
> **Status:** Phase 7+ complete. Game is playable end-to-end for Day 1. **PIXEL-ACCURATE SIZING SYSTEM IMPLEMENTED (May 12, 2026)** - Ednar and customers now use identical scaling approach. All characters drawn on 1536×1024px canvas @ 300 DPI appear at predictable, proportional sizes without manual tuning. **Ednar base scale: 0.15** (matches layout config). **Customer base scale: 2.0** (compensates for queue depth scaling). **All 14 customer scene portraits linked** with proper `_scene` nomenclature. **Active/Waiting scale system** - each character has separate scale/position values for active (front of line) vs waiting (back of line). **Drag-and-drop dice placement implemented.** Layout fully tuned and LOCKED. **Freeform art scaling system complete.** **Customer scene background integrated** - `customerbg.png` loading with gradient fallback. Live preview overlay layout editor complete with per-node fine-tuning AND per-character scaling with **14-character picker dropdown**. **Edge line controls implemented** - fully configurable color/opacity/thickness via 🔗 Lines section in layout editor. **Custom edge topology active** - 23 connections matching user's design. **Circle clipping REMOVED from scene portraits** - full images visible for proper resizing. **Canvas dimensions**: 1536×1024px @ 300 DPI (3:2 aspect ratio, landscape) for ALL art (Ednar + customers). **Default character scale**: 1.0× width, 1.0× height (no distortion). **Default waiting scale**: 0.8× width, 0.8× height (creates depth effect). **Smooth transitions** between active/waiting states during queue swaps.  
> **Read this file FIRST when continuing work in a new chat or in Claude in Xcode.**

---

## 0. CRITICAL REQUIREMENTS (read before doing anything)

Before starting any work, read the files attached IN ORDER. Then:

- **The user does not know how to code.** Give step-by-step Xcode instructions. Never assume the user knows where a setting is, what a button does, or what a Swift error means.
- **Provide ONLY complete, copy-pasteable code** (never snippets) using `str_replace_based_edit_tool`. Whole files, every time.
- **Ask clarifying questions instead of making assumptions.** If a request is ambiguous, ask. The user prefers "wait, before I write this, here's what I'm planning" over "I just did the thing you didn't want."
- **Never break existing functionality.** When you add a new struct/view/file, prefix it with `PotionShop` to avoid name collisions with other games (Match-3, ShopOfOddities, the legacy CauldronGame, etc.). This rule was established the hard way after the `Customer` and `CauldronBoardView` collisions.
- **Always update `MASTER_CONTEXT.md` and `CAULDRON_CONTEXT.md`** after making structural changes.
- **Test instructions must be beginner-friendly.** Every Xcode UI step spelled out (right-click which thing, what dialog appears, which checkbox to tick).

---

## 1. WHAT THIS GAME IS

**Display name:** Ednar's Potion Cauldron
**Folder name:** `PotionShop/`
**Enum case:** `.ednarsPotionShop` (in `GameType` in `OverQuestMatch3App.swift`)
**Status:** Standalone game inside the OverQuestMatch3 multi-game project.

A turn-based dice-placement potion-brewing game. The player is Ednar (the witch behind a counter). Customers form a line on the right. The active customer (front of line) is the brew target. The player draws a hand of 5 dice, places up to 3 on a 12-node cauldron board, and taps BREW. Damage hits the active customer; heal/shield buffer Ednar; then every customer in the queue attacks back. First side to lose all HP/composure loses.

A "Day" has four rounds: **Morning → Afternoon → Evening → Night**. Night is the boss fight. Composure carries between rounds (currently +5 partial rest between rounds — tunable; see §8.3).

**v1 ships Day 1 only.** Day 2, Day 3, randomized days, and a "streak-based win" mode are planned but explicitly deferred. See §17.

---

## 2. PROJECT INTEGRATION

### 2.1 Where the game lives
```
OverQuestMatch3/
├─ OverQuestMatch3App.swift              ← edited: new .ednarsPotionShop case in GameType enum
├─ GameSelectorView.swift                ← edited: added "Ednar's Potion Cauldron" button + route
├─ CauldronGame/                         ← LEGACY, leave alone, will delete in a future cleanup
└─ PotionShop/                           ← THIS GAME
   ├─ PotionShopModels.swift             ← data type definitions (Trait, CharacterDef, Round, Day, Dice, board)
   ├─ PotionShopData.swift               ← actual game content (14 customers, 8 traits, Day 1 rounds)
   ├─ PotionShopGameState.swift          ← @Observable engine — queue, dice, brewing, animated doBrew
   ├─ PotionShopGameView.swift           ← root view (composes all sections + floating-number overlay)
   ├─ PotionShopHeaderView.swift         ← composure bar, shield, day/round, gear icon
   ├─ PotionShopCustomerSceneView.swift  ← Ednar + customer line + profile row + inspect strip
   ├─ PotionShopCauldronView.swift       ← bowl shape, 12 nodes, BREW sign, dice tray
   ├─ PotionShopDebugMenu.swift          ← gear-icon sheet (skip round, heal, win/lose, end game)
   └─ PotionShopBrewAnimator.swift       ← all animation timing constants (single source of truth)
```

### 2.2 Selector entry
- **Title displayed:** "Ednar's Potion Cauldron"
- **Description:** "Brew potions for the town"
- **Icon:** None — keeps it clean and matches the user's intent ("no icon for now").

### 2.3 Splash → Title → Selector → Game flow
The game launches DIRECTLY into Day 1 / Morning when tapped from the selector. No per-game title screen (matches the convention used by Match-3, Physics Chain, Shop of Oddities). End Game in the debug menu returns to the selector.

### 2.4 The legacy CauldronGame folder
The original Cauldron implementation in `CauldronGame/` is left alone for now. It is **not** wired into the selector anymore. The user will delete it in a future cleanup; it is **not** the game we are building.

---

## 3. NAMING CONVENTIONS (LOCKED — DO NOT VIOLATE)

This rule was established after two real bugs in the chat:
- `Customer` collided with `ShopOfOddities/Customer` → 10 build errors
- `CauldronBoardView` collided with `CauldronGame/CauldronBoardView` → "Invalid redeclaration"

**Rule: every type, view, modifier, and namespace ID introduced by this game starts with `PotionShop`.** No exceptions, no matter how generic or "obviously safe" the name feels.

| Type kind          | Example                                  |
|--------------------|------------------------------------------|
| Struct (data)      | `PotionShopCustomer`, `PotionShopTrait`  |
| Struct (view)      | `PotionShopCauldronBoardView`            |
| Enum               | `PotionShopCustomerStatus`, `PotionShopDieType` |
| ViewModifier       | `PotionShopDiceDropInModifier`           |
| Animation helper   | `PotionShopBrewAnimator`                 |
| State class        | `PotionShopGameState`                    |
| Floating number    | `PotionShopFloatingNumber`               |

**Exception:** the file names themselves use the `PotionShop` prefix too (e.g. `PotionShopGameView.swift`), not `EdnarsPotionCauldron…` or anything else.

---

## 4. GAME DATA — 14 CUSTOMERS, 8 TRAITS, DAY 1

All data is hardcoded in Swift in `PotionShopData.swift`. **No JSON files.** This matches the convention used by every other game in the project. (We had JSON during web prototyping but abandoned it for the Xcode build.)

### 4.1 The 14 customers

Each customer has: id, name, title, emoji fallback, difficulty (1–5), time-of-day tags, order name, order dialogue, HP, patience, tick dialogue, expire dialogue, defeat dialogue, optional trait id, **active_attack**, **waiting_attack**, **active_patience_tick**, **waiting_patience_tick**, **expire_damage**.

**Tier 1 (Morning, tutorial easy):**
| id        | name             | trait      | HP | active_atk | waiting_atk | active_tick | waiting_tick | expire |
|-----------|------------------|------------|----|-----------:|------------:|------------:|-------------:|-------:|
| mildred   | Mildred Honeycomb| —          | 10 |          1 |           1 |           1 |            1 |      4 |
| tomik     | Tomik            | —          |  8 |          1 |           1 |           1 |            1 |      3 |
| greta     | Greta            | inspiring  | 12 |          1 |           1 |           1 |            1 |      3 |

**Tier 2 (Morning/Afternoon, light pressure):**
| id           | name             | trait      | HP | active_atk | waiting_atk | active_tick | waiting_tick | expire |
|--------------|------------------|------------|----|-----------:|------------:|------------:|-------------:|-------:|
| pemberton    | Pemberton        | —          | 14 |          2 |           1 |           1 |            1 |      5 |
| sister_halla | Sister Halla     | pious      | 12 |       (auto) |       (auto) |       (auto) |        (auto) |  (auto) |
| ardo         | Ardo             | skittish   | 12 |          1 |           1 |           2 |            1 |      6 |

**Tier 3 (Afternoon/Evening, real fight):**
| id        | name              | trait        | HP | active_atk | waiting_atk | active_tick | waiting_tick | expire |
|-----------|-------------------|--------------|----|-----------:|------------:|------------:|-------------:|-------:|
| wendelina | Wendelina         | —            | 18 |          3 |           1 |           1 |            1 |      7 |
| bram      | Bram              | loud (STUB)  | 16 |     (auto) |      (auto) |     (auto) |      (auto) |  (auto) |
| crispin   | Lord Crispin      | intimidating | 18 |          3 |           1 |           1 |            1 |      7 |

**Tier 4 (Evening, hard):**
| id         | name                  | trait     | HP | active_atk | waiting_atk | active_tick | waiting_tick | expire |
|------------|-----------------------|-----------|----|-----------:|------------:|------------:|-------------:|-------:|
| hexa_mott  | Hexa Mott             | hexer (STUB) | 22 | (auto, ~3) |   (auto, 1) |   (auto, 1) |    (auto, 1) | (auto) |
| ironhilde  | Captain Ironhilde     | draining  | 24 | (auto, ~3) |   (auto, 1) |   (auto, 1) |    (auto, 1) | (auto) |

**Tier 5 (Night, bosses):**
| id          | name              | trait        | HP | active_atk | waiting_atk | active_tick | waiting_tick | expire |
|-------------|-------------------|--------------|----|-----------:|------------:|------------:|-------------:|-------:|
| grimdrek    | Grimdrek          | volatile     | 28 | (auto, ~4) |   (auto, 1) |   (auto, 1) |    (auto, 1) | (auto) |
| carmilla    | Lady Carmilla     | hexer (STUB) | 30 | (auto, ~4) |   (auto, 1) |   (auto, 1) |    (auto, 1) | (auto) |
| royal_envoy | The Royal Envoy   | intimidating | 34 | (auto, ~5) |   (auto, 1) |   (auto, 1) |    (auto, 1) | (auto) |

> **(auto)** = combat values were defaulted by tier (tier 4 → active_attack ≈ 3, tier 5 → 4–5) without playtest. **These values are flagged for retuning** after Day 1 playtest. See §17 → "Tier-4/5 auto-defaulted combat values."

### 4.2 The 8 traits

| id            | name           | effect                                                                 | status     |
|---------------|----------------|------------------------------------------------------------------------|------------|
| intimidating  | Intimidating   | brew target +2 while this customer is active                           | LIVE       |
| volatile      | Volatile       | overbrew triggers retaliation BEFORE defenses apply                    | LIVE       |
| pious         | Pious          | flavor only, no mechanical effect                                      | LIVE       |
| skittish      | Skittish       | active_patience_tick is 2 instead of 1 (drains faster while active)   | LIVE       |
| loud          | Loud           | reduces player focus by 1 while customer is in waiting position       | **STUB**   |
| hexer         | Hexer          | each turn this customer waits, one die in hand rerolls to lowest face  | **STUB**   |
| draining      | Draining       | -1 composure per turn for each draining customer in queue              | LIVE       |
| inspiring     | Inspiring      | +1 to all dice rolls while this customer is in queue                   | LIVE       |

Stubbed traits are declared on their owning characters (Bram = loud; Hexa Mott + Carmilla = hexer) but **have no mechanical effect** — they show in the inspect strip but don't fire. Implement in Phase 9.

### 4.3 Day 1 round structure (curated)

| Round     | Customers                                | Notes                                  |
|-----------|------------------------------------------|----------------------------------------|
| Morning   | Mildred + Tomik                          | 2 easy, no traits, learn the loop      |
| Afternoon | Pemberton + Greta                        | introduces patience pressure + a positive trait |
| Evening   | Wendelina + Crispin + Ardo               | first 3-customer round, mixed pressure |
| Night     | Grimdrek                                 | boss, volatile (overbrew retaliation)  |

### 4.4 Days 2 and 3 — DESIGNED, NOT BUILT
- Day 2 is templated as fully random (pull from pool by difficulty + time-of-day tag, randomize boss).
- Day 3 is templated as hybrid (procedural mornings, hand-picked Evening set-piece, fixed Royal Envoy night).
- Templates exist on paper; **NOT wired into Swift in v1.** See §17.

### 4.5 How to add or edit characters/traits later
Detailed comments at the top of `PotionShopData.swift` explain the format. Short version:
- **Add a trait:** new entry in `allTraits` with id, name, description, effect closure (or stub).
- **Add a customer:** new `PotionShopCharacterDef` in `allCharacters` with all fields. Make sure their `trait` id (if any) exists in `allTraits`.
- **Tune a combat value:** find the character in `allCharacters`, change the relevant integer.

---

## 5. COMBAT MODEL (LOCKED — Session 4 turn-based system)

This is the model that replaced the original underbrew-penalty model. Everything below is **decided and committed**.

### 5.1 Per-turn sequence (player taps BREW)
1. **Brew applies** — heal hits Ednar, shield hits Ednar, brew damage hits the active customer.
2. **Volatile retaliation** — if overbrew on a Volatile customer, they retaliate BEFORE defenses (skipped if no Volatile customer or no overbrew).
3. **Customer attacks** — every customer in queue attacks. Active uses `active_attack`. Waiters use `waiting_attack` (smaller). Shield absorbs first, then composure.
4. **Patience ticks** — each customer's patience drops by their tick value (active uses `active_patience_tick`, waiters use `waiting_patience_tick`).
5. **Expirations** — any customer at 0 patience storms out, dealing `expire_damage` once.
6. **Draining drain** — 1 composure per draining customer in queue.

### 5.2 Locked rules (do not redesign)
- **No underbrew penalty.** If your damage falls short, the customer just lives. You don't take extra damage for missing.
- **All customers attack every turn**, not just the active.
- **Active and waiters use different attack values** (waiting_attack < active_attack typically).
- **Shield absorbs first, then composure.** Shield is a separate pool.
- **Composure carries between rounds** with `COMPOSURE_REST_BETWEEN_ROUNDS = 5` (tunable; see §8.3).
- **Patience is a timer, not a damage source.** It only deals damage when it expires.
- **Player gets 5 dice in hand, places up to 3 per brew** (`MAX_PLACEMENTS_PER_BREW = 3`).
- **Profile button row never reorders.** Tapping a profile swaps the queue, not the buttons.
- **Queue swap rule:** tapping a non-front profile swaps that customer with whoever is currently at queue[0]. Two-element swap, the third (if any) doesn't move. The visual line is anchored at left (closest to Ednar = front of line = active brew target).

### 5.3 Things you might change later (FLAGGED, ASK BEFORE EXECUTING)
- Reordering turn phases (e.g., they attack first, then you brew)
- Letting players brew multiple times per turn
- Patience also affecting attack power (low patience = harder hitter?)
- Some customer types skip attacks but compensate with heavy patience pressure
- Boss-only telegraphed attacks (you see the next attack value before brewing)
- Combo brew effects that delay or skip enemy turns
- Reaction system: shield triggers a counter, etc.
- Removing the +5 composure rest entirely (refill only between full days)

When the user wants to change any of these, the assistant should propose, get confirmation, then implement.

---

## 6. DICE SYSTEM

### 6.1 Five die types
| type      | color shorthand | role                                                       |
|-----------|-----------------|------------------------------------------------------------|
| potency   | red             | main damage dealer                                         |
| stability | blue            | secondary damage at 80% efficiency (intentionally weaker)  |
| boost     | purple          | doesn't damage; multiplies neighbors within reach          |
| heal      | green           | restores composure to Ednar                                |
| shield    | teal            | adds shield to Ednar                                       |

### 6.2 Face value distribution
- Potency / Stability / Heal / Shield: faces are **1, 2, 2, 3, 3, 4** (avg 2.5)
- Boost: faces are **1, 1, 2, 2, 2, 3** (avg 1.83 — intentionally weaker since it multiplies)

### 6.3 Starting bag (8 dice)
- 3× Potency
- 2× Stability
- 1× Boost
- 1× Heal
- 1× Shield

Drawn 5 at a time into the hand.

### 6.4 Brewing math
- **Potency:** `face × boostMultiplier` damage to active customer
- **Stability:** `face × boostMultiplier × 0.8` damage to active customer
- **Heal:** `face` composure (no boost interaction)
- **Shield:** `face` shield (no boost interaction)
- **Boost:** adds `face × 0.5` to the multiplier of every die within `face` graph-hops on the cauldron board. Boosts can stack on the same target.
- **Inspiring trait** (Greta): +1 to every die's face value during the round (applied at brew time).

### 6.5 Tier system (DORMANT in v1)
- `DieTier` enum exists with `.basic`, `.silver`, `.gold` cases.
- Every die in v1 is created at `.basic`.
- Silver/gold faces are designed (silver: 2,3,3,4,4,5 avg 3.5; gold: 4,5,5,6,6,7 avg 5.5) but inactive.
- Reserved for multi-day progression / unlocks system in a future phase.

### 6.6 Bag/discard
The bag depletes properly (each draw removes from bag, plays go to discard, when bag empties the discard reshuffles). This was salvaged from the legacy `CauldronViewModel.swift` and reimplemented inside `PotionShopGameState.swift`. The bag/discard is currently **functional but not visualized** — no on-screen bag pile or discard pile. See §17 for "bag/discard visualization."

### 6.7 Dice animation (LOCKED)
- **On deal:** all 5 dice drop simultaneously from ~80pt above the tray and bounce-spring into place.
- **No rotation** — the user explicitly chose dice land straight every time. (Earlier iterations had random tumble; that was reverted.)
- **On placement:** die slides via `matchedGeometryEffect` from tray slot to cauldron node (Phase 6). About 0.4s with a small spring bounce.
- **On unplacement:** die slides back to tray (same mechanic, reversed).

### 6.8 Drag-and-drop dice placement (May 4, 2026)

**Status:** ✅ FULLY IMPLEMENTED AND WORKING

The game supports **two methods** for placing dice on nodes:

#### **Method 1: Tap-select-then-tap-node (original)**
1. Tap a die in the tray → yellow border appears (selected)
2. Tap an empty node → die slides to that node
3. Tap the placed die → slides back to tray

#### **Method 2: Drag-and-drop (new)**
1. Touch and drag a die from the tray
2. Die follows your finger with:
   - **15% scale increase** (looks bigger while dragging)
   - **Colored glow shadow** (matches die type color)
   - **Stays visible** over all UI elements (no clipping)
3. As you drag over nodes:
   - **Empty nodes pulse** (scale 1.15×)
   - **Empty nodes glow** (bright yellow fill + thick border)
4. Release over an empty node:
   - Die **smoothly slides** to node center via `matchedGeometryEffect`
   - **Spring animation** (0.35s response, 0.72 damping)
5. Release outside nodes:
   - Die **springs back** to tray (0.4s response, 0.75 damping)

#### **Removing placed dice (both methods work):**
- **Tap:** Tap a placed die → slides back to tray
- **Drag:** Drag a placed die off the node → slides back to tray

#### **Technical implementation:**
- **Gesture:** `DragGesture(coordinateSpace: .global)` on dice in tray
- **Position tracking:** Nodes register their global `CGRect` positions using `GeometryReader`
- **Hit detection:** `tryDropDieAtPosition(_:dieIndex:)` checks if drop position intersects any node rect
- **Hover state:** `updateDragHoverPosition(_:)` updates `hoveredNodeIndex` during drag
- **Visual offset:** Die uses `.offset(dragOffset)` for manual positioning during drag
- **Animation:** `matchedGeometryEffect(id: die.id, in: diceFlight)` handles slide-to-node animation
- **Z-index:** Dragging die has `zIndex: 1000` to appear above all content
- **Clipping fix:** Removed `.clipShape()` from dice tray background to prevent dice from disappearing behind tray border

#### **Edge cases handled:**
- ✅ Can't place 4th die (max 3 placements enforced)
- ✅ Can't drop on occupied node
- ✅ Can't drag during brew animation (`isAnimating` check)
- ✅ Multiple dice can be dragged in quick succession
- ✅ Tap still works without interfering with drag
- ✅ Die stays visible during entire drag (no clipping behind cauldron/tray)

#### **Animation parameters (tunable in code):**
```swift
.scaleEffect(isDragging ? 1.15 : 1.0)  // Drag scale
.shadow(radius: isDragging ? 12 : 0)    // Drag glow
.zIndex(isDragging ? 1000 : 0)          // Z-layer

// Node pulse
.scaleEffect(isHovered ? 1.15 : 1.0)
.animation(.spring(response: 0.25, dampingFraction: 0.6), value: isHovered)

// Drop animation (handled by matchedGeometryEffect)
withAnimation(.spring(response: 0.35, dampingFraction: 0.72))

// Return to tray animation
withAnimation(.spring(response: 0.4, dampingFraction: 0.75))
```

#### **State management:**
- `nodePositions: [Int: CGRect]` - Global positions of all nodes (updated by nodes)
- `hoveredNodeIndex: Int?` - Which node is currently hovered during drag
- `updateDragHoverPosition(_:)` - Updates hover state based on drag position
- `tryDropDieAtPosition(_:dieIndex:)` - Attempts to place die, returns success/fail

---

## 7. STATE MACHINE — `PotionShopGameState`

`@Observable class` (iOS 17+ macro). All UI binds to its published fields.

### 7.1 Key public properties
- `currentDay`, `currentRound`
- `customers: [PotionShopCustomer]` — never reorders. Drives the profile button row.
- `queue: [String]` — array of customer ids in scene-line order. `queue[0]` = front = active. Drives the customer scene layout.
- `composure`, `maxComposure`, `shield`
- `hand: [DiePlacement]`, `placements: [Int: DiePlacement]` (node-id → die)
- `bag`, `discard`
- `activeFloatingNumbers: [PotionShopFloatingNumber]` — drives the overlay
- `customerShakeCounters: [String: Int]` — drives the shake modifier on each customer view
- `composureFlashColor: Color?` — header listens to this for red/green flashes
- `isAnimating: Bool` — when true, every interactive control is disabled
- `nodePositions: [Int: CGRect]` — global screen positions of cauldron nodes (for drag-and-drop)
- `hoveredNodeIndex: Int?` — which node is currently hovered during drag

### 7.2 Key methods
- `tapProfile(customerId:)` — the queue swap. **DO NOT redesign this.** It took 8 attempts in the chat to get right. See §10 for the rule.
- `selectHand(_ idx: Int)` - Tap-select a die from tray (toggles selection)
- `tapNode(_ nodeId: Int)` - Tap an empty node to place selected die, or tap placed die to remove
- `placeDie(handIdx:nodeId:)` - Internal method to place die on node
- `unplaceDie(_ nodeId: Int)` - Remove die from node back to tray
- `updateDragHoverPosition(_ position: CGPoint)` - Update hover state during drag
- `tryDropDieAtPosition(_ position: CGPoint, dieIndex: Int)` - Attempt to drop die at position
- `dragPlacedDieToTray(nodeId: Int)` - Remove placed die via drag gesture
- `computeBrew()` — returns predicted damage/heal/shield from current placements (used for the preview bar above the tray)
- `applyDamage(_ amount:)` — shield-first, then composure. Returns `(absorbed, dealt)` so animation events can show "🛡 -N" vs "-N" floaters.
- `doBrew()` — `@MainActor async` — runs the 7-phase animated sequence with `Task.sleep` between phases. Emits floating numbers, shake events, flash colors.
- `debugWinRound()`, `debugLoseGame()` — used by debug menu
- Standard advance methods: `advanceToNextRound()`, `restartRound()`, `restartDay()`

### 7.3 Concurrency
- `doBrew()` is `@MainActor async`.
- Callers must use `Task { @MainActor in await gs.doBrew() }`. A bare `Task { ... }` will trigger a Swift 6 concurrency error. Don't refactor.
- Floating-number cleanup uses `Timer.publish(...).autoconnect()` from Combine — `import Combine` required in `PotionShopGameView.swift`.

---

## 8. LAYOUT (LOCKED PROPORTIONS) — Updated May 4, 2026

The layout is driven by `GeometryReader` in `PotionShopGameView.swift`, with vertical sections allocated as fractions of the available play area. **Layout was extensively tuned using an interactive layout editor** (see `LAYOUT_EDITOR_SESSION_MAY4_2026_PART2.md`).

### 8.1 Vertical section heights (CURRENT PRODUCTION VALUES)
| Section                    | Fraction of play area | Why                                        |
|----------------------------|-----------------------|--------------------------------------------|
| Header                     | **1.0%**   (was 9%)   | Minimal - just composure bar               |
| Customer scene (hero)      | **26.3%** (was 21%)   | The visual focus; Ednar + customer line    |
| Profile row + inspect strip| **9.5%**  (same)      | Inspect strip overlays in place when shown |
| **Cauldron + BREW**        | **37.2%** (was 32%)   | **HERO ELEMENT - biggest section!**        |
| Brew preview bar           | **3.2%**  (same)      | Small status strip above tray              |
| **Dice tray**              | **19.3%** (was 10.5%) | **BIG - easier to tap dice**               |
| **Total:**                 | **96.5%**             | Spacer fills remaining 3.5%                |

**Key changes:**
- **Cauldron is now the largest section** (37.2%) - dominates the screen
- **Dice tray is massive** (19.3%) - same height as scene! Easy to see and tap
- **Header shrunk to 1%** - more room for gameplay
- **Preview bar minimal** (3.2%) - just shows essential info

### 8.2 Customer queue X-positions (count-aware, scene-relative fractions)
The customer line is right-aligned with explicit space between Ednar (left) and the first customer:
- **1 customer (Night boss):** at 75% of scene width
- **2 customers:** 55% + 85%
- **3 customers:** 48% + 68% + 88%

These are fractions, not pixel values. Should scale across iPhone sizes.

### 8.3 Tunable game settings (in `PotionShopData.swift`)
| Constant                          | Value | What it does                                                |
|-----------------------------------|-------|-------------------------------------------------------------|
| `STARTING_COMPOSURE`              |    30 | Day starts with this much composure                         |
| `MAX_COMPOSURE`                   |    30 | Cap on composure                                            |
| `MAX_PLACEMENTS_PER_BREW`         |     3 | Hand is 5 but you can only place 3 per brew                 |
| `COMPOSURE_REST_BETWEEN_ROUNDS`   |     5 | Free composure restored at the start of each new round; **set to 0 to disable** (user flagged this may flip later) |

### 8.4 Cauldron bowl construction
The bowl is **NOT** a `Path.addArc` — that approach failed three times with mis-rendered shapes. It is now built parametrically:
- **Aspect ratio:** 1.65:1 (wide:tall). Looks like a shallow stew pot, not a half-pipe.
- **Construction:** 60 line segments around the bottom half of an ellipse, computed via `cos(θ)`/`sin(θ)` outside the `Path { }` closure (precomputing avoids `Type '()' cannot conform to 'View'` errors).
- **Node area inset:** 70% on each axis. Math check: `0.70² + 0.70² = 0.98 ≤ 1`, so corners of the inset rectangle are provably inside the ellipse. Nodes never escape the bowl.
- **Layers (in z-order, bottom to top):** bowl back (dark fill) → liquid surface (green ellipse) → 12 nodes → optional foreground rim → BREW sign/tap-zone.

### 8.5 Cauldron parameters (applied from layout editor)
```swift
PotionShopCauldronView(
    gs: gs,
    diceFlight: diceFlight,
    cauldronScale: 1.29,          // 29% bigger than default
    cauldronXOffset: 44,           // Shifted right 44pt
    cauldronYOffset: 58,           // Shifted down 58pt
    nodeScale: 1.30,               // Nodes 30% bigger (independent!)
    nodeXOffset: 3,                // Nodes shifted right 3pt (independent!)
    nodeYOffset: -8,               // Nodes shifted up 8pt (independent!)
    brewXOffset: -50,              // (not used - button hidden)
    brewYPercent: 0.30,            // (not used - button hidden)
    showBrewButton: false,         // Button hidden - using tap zone
    brewZoneX: 0.81,               // Tap zone at 81% from left
    brewZoneY: 0.19,               // Tap zone at 19% from top
    brewZoneWidth: 90,             // 90pt wide
    brewZoneHeight: 123,           // 123pt tall
    showBrewZone: false            // Hidden in production (set true to debug)
)
```

**Node independent positioning:** Nodes scale and position separately from the bowl. This was added May 4, 2026 to allow fine-tuning the dice grid position without moving the bowl art.

### 8.6 Dice tray parameters (applied from layout editor)
```swift
PotionShopDiceTrayView(
    gs: gs,
    diceFlight: diceFlight,
    dieScale: 1.31                 // Dice 31% bigger than default
)
.offset(y: -25)                    // Tray moved up 25pt (closer to cauldron)
```

### 8.7 BREW button / tap zone (configurable)
**Current setup:** BREW button is **hidden**. An invisible tap zone at (81%, 19%) handles brew action.

**Purpose:** User plans to add a ladle art asset dipping into the cauldron. Tapping the ladle will brew. The tap zone is positioned where the ladle will be.

**Debug visualization:** Set `showBrewZone: true` to see a yellow dashed rectangle showing the tap zone boundaries.

### 8.8 Dice tray clipping fix (CRITICAL)
The dice tray background originally used `.clipShape(RoundedRectangle(cornerRadius: 8))` which caused dragged dice to disappear behind the tray border. This was changed to:

```swift
.background(
    RoundedRectangle(cornerRadius: 8)
        .fill(...)  // Gradient
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(...)  // Border
        )
)
// NO .clipShape() - allows dice to escape upward when dragged
```

This allows dice to remain visible during drag without being clipped by the tray's rounded corners.

### 8.9 Art Scaling & Positioning System (May 4, 2026 - Evening - FIXED)

**Status:** ✅ FULLY IMPLEMENTED AND FIXED

**Critical Fix Applied (Evening):** Removed `.scaledToFill()` from both cauldron and Ednar images, and added missing `*ArtScale` multiplier. This allows **true independent width/height scaling with full distortion**. Images can now be stretched/squished in any direction without aspect ratio constraints.

The layout editor includes comprehensive freeform art scaling and positioning controls for both the cauldron and Ednar images.

#### **Access:**
Debug Menu (⚙️) → Layout Editor → Scroll to **"🎨 ART SCALING & POSITIONING"**

#### **Control Structure:**

**Uniform Scale (Both):**
- **🔗 Uniform Scale** slider (0.5× to 3.0×) - Test scale for both elements
- **"Reset All to 1.0"** button - Resets all art controls
- **"Apply Uniform"** button - Applies uniform scale to all dimensions

**🍲 Cauldron Freeform (5 sliders):**
- **Uniform Scale** (0.5× to 3.0×) - Proportional scaling
- **↔️ Width Scale** (0.5× to 3.0×) - Independent width (stretch/squish horizontally) **✅ NOW WORKS**
- **↕️ Height Scale** (0.5× to 3.0×) - Independent height (stretch/squish vertically) **✅ NOW WORKS**
- **↔️ X Position** (-200 to +200 pts) - Horizontal offset from default position
- **↕️ Y Position** (-200 to +200 pts) - Vertical offset from default position
- **"Link W/H"** button - Copies width to height (make proportional)
- **"Reset Position"** button - Returns X/Y offsets to 0

**🧙 Ednar Freeform (5 sliders):**
- Same 5 controls as cauldron (uniform scale, width, height, X pos, Y pos)
- Same helper buttons ("Link W/H", "Reset Position")

#### **How It Works:**

**Real-Time Preview:**
- All sliders update instantly as you drag them
- No need to generate code or rebuild to see changes
- Perfect for fine-tuning art dimensions and positions
- **Images now distort freely** when width ≠ height scales

**Implementation (FIXED):**
```swift
// Cauldron parameters (in PotionShopCauldronView)
cauldronArtScale: Double = 1.0       // Uniform scale
cauldronArtWidth: Double = 1.0       // Width multiplier
cauldronArtHeight: Double = 1.0      // Height multiplier  
cauldronArtXOffset: Double = 0       // X position offset (pts)
cauldronArtYOffset: Double = 0       // Y position offset (pts)

// Ednar parameters (in PotionShopEdnarView)
ednarArtScale: Double = 1.0          // Uniform scale
ednarArtWidth: Double = 1.0          // Width multiplier
ednarArtHeight: Double = 1.0         // Height multiplier
ednarArtXOffset: Double = 0          // X position offset (pts)
ednarArtYOffset: Double = 0          // Y position offset (pts)
```

**Frame Calculation (FIXED - Now includes all multipliers and NO aspect ratio locking):**
```swift
// Cauldron image (PotionShopCauldronView.swift)
Image(uiImage: cauldronImage)
    .resizable()
    // ✅ NO .scaledToFit() or .scaledToFill() - allows independent width/height distortion
    .frame(
        width: baseGeometry.bowlW * cauldronArtScale * cauldronArtWidth,   // ✅ All 3 multipliers
        height: baseGeometry.bowlH * cauldronArtScale * cauldronArtHeight  // ✅ All 3 multipliers
    )
    .position(
        x: g.bowlCenterX + cauldronArtXOffset,
        y: g.bowlOriginY + g.bowlH / 2 + cauldronArtYOffset
    )

// Ednar image (PotionShopCustomerSceneView.swift)
Image(uiImage: ednarImage)
    .resizable()
    // ✅ NO .scaledToFit() or .scaledToFill() - allows independent width/height distortion
    .frame(
        width: 100 * ednarArtScale * ednarArtWidth,    // ✅ All 3 multipliers
        height: 120 * ednarArtScale * ednarArtHeight   // ✅ All 3 multipliers
    )
    .offset(x: ednarArtXOffset, y: ednarArtYOffset)
```

#### **What Was Fixed:**

**Problem 1:** Missing `*ArtScale` multiplier
- **Before:** `width: baseGeometry.bowlW * cauldronArtWidth`
- **After:** `width: baseGeometry.bowlW * cauldronArtScale * cauldronArtWidth`

**Problem 2:** `.scaledToFill()` forced aspect ratio
- **Before:** `.resizable().scaledToFill()` ← Ignores independent width/height!
- **After:** `.resizable()` only ← Allows true distortion

**Result:** Width and height sliders now work independently and can fully distort images to any aspect ratio.

#### **Files Modified:**
1. **PotionShopLayoutEditorView.swift** - Added art scaling UI section (8 state vars, ~50 lines UI)
2. **PotionShopCauldronView.swift** - ✅ FIXED: Added missing scale multiplier, removed `.scaledToFill()`
3. **PotionShopCustomerSceneView.swift** - ✅ FIXED: Added missing scale multiplier, removed `.scaledToFill()`

#### **Common Use Cases:**

**Make cauldron wider (without getting taller):**
```
Width Scale: 1.5
Height Scale: 1.0
Result: 50% wider, same height ✅ NOW WORKS
```

**Make cauldron flat and wide:**
```
Width Scale: 2.0
Height Scale: 0.5
Result: Double width, half height (squished) ✅ NOW WORKS
```

**Move Ednar left and up:**
```
X Position: -50
Y Position: -20
Result: 50pts left, 20pts up
```

**Make both 2× bigger proportionally:**
```
Uniform Scale: 2.0
→ Tap "Apply Uniform"
Result: Both double in size (both width and height)
```

#### **Code Generation:**

The layout editor's "📋 Generate Code" button will output values like:

```swift
// In PotionShopGameView.swift
PotionShopCauldronView(
    gs: gs,
    diceFlight: diceFlight,
    // ... other parameters ...
    cauldronArtScale: 1.0,
    cauldronArtWidth: 1.5,      // ← From width slider
    cauldronArtHeight: 0.8,     // ← From height slider
    cauldronArtXOffset: 20,     // ← From X position slider
    cauldronArtYOffset: -10     // ← From Y position slider
)

PotionShopCustomerSceneView(
    gs: gs,
    ednarArtScale: 1.0,
    ednarArtWidth: 1.2,         // ← From width slider
    ednarArtHeight: 1.4,        // ← From height slider
    ednarArtXOffset: -30,       // ← From X position slider
    ednarArtYOffset: 15         // ← From Y position slider
)
```

#### **Current Production Values (LOCKED - May 4, 2026 Evening):**

**Art Scaling:**
- `cauldronArtWidth: 1.45` (stretched 45% wider)
- `cauldronArtHeight: 2.00` (doubled in height)
- `cauldronArtXOffset: 7` (shifted right 7pt)
- `cauldronArtYOffset: -40` (shifted up 40pt)
- `ednarArtWidth: 1.59` (stretched 59% wider)
- `ednarArtHeight: 2.00` (doubled in height)
- `ednarArtXOffset: 14` (shifted right 14pt)
- `ednarArtYOffset: -17` (shifted up 17pt)

**BREW Tap Zone:**
- `brewZoneX: 0.83` (83% from left edge)
- `brewZoneWidth: 112pt` (tap area width)
- `showBrewZone: false` (yellow debug box hidden in production)

These values are locked into both PotionShopGameView.swift and PotionShopLayoutEditorView.swift defaults.

---

## 9. ANIMATION SYSTEM (Phase 7) — `PotionShopBrewAnimator.swift`

**Single source of truth for every animation timing.** All values live in this file as static constants. Editing animation feel = editing this file. The user is an animator and will tune these.

### 9.1 The 7-phase brew sequence
Total typical duration: ~3.5s. Each phase is skipped (zero time) if it has nothing to do.

| #  | Phase                            | Default duration | What's animated                                          |
|----|----------------------------------|------------------|----------------------------------------------------------|
| 1  | Heal & shield apply              | 0.40s            | green/blue floaters off Ednar; bar slides up; shield badge appears |
| 2  | Volatile pre-defense (rare)      | 0.35s            | red floater off the volatile customer; small shake       |
| 3  | Brew damage to active customer   | 0.50s            | red `-N 🧪` floater; active customer shakes; HP bubble updates |
| 4a | Active customer attacks alone    | 0.50s            | active customer "lunges"; red `-N` off Ednar; bar flashes red |
| 4b | All waiters attack together      | 0.50s            | each waiter shakes; one summed red `-N` off Ednar         |
| 5  | Patience ticks                   | 0.40s            | profile patience rings update                            |
| 6  | Expirations (per customer)       | 0.60s            | customer fades + slides off-screen with 💢 burst; red `-N` off Ednar |
| 7  | Draining drain                   | 0.30s            | one `-1` floater per draining customer in queue          |

**Customer attack split (Phase 4a / 4b) is locked at "hybrid":** active alone first, then all waiters together. This was the user's chosen balance between readable per-customer damage and not making 3-customer rounds drag.

### 9.2 Tunable visual constants (all in `PotionShopBrewAnimator.swift`)
| constant                | default | what it controls                                          |
|-------------------------|---------|-----------------------------------------------------------|
| `shakeAmplitude`        | 6pt     | how far customers shake left/right when hit               |
| `shakeOscillations`     | 4       | number of left/right oscillations in one shake            |
| `floatRiseDistance`     | 50pt    | how high floating numbers drift before fading             |
| `floatDuration`         | 0.7s    | total life of a floating number                           |
| `composureFlashDuration`| 0.25s   | how long header flashes red/green                         |
| `customerSlideOutDuration` | 0.55s | how long an expiring customer takes to leave              |
| `numberFont(size:)`     | system serif heavy | **swap target for OverQuest font** when it lands. One-line change. |

### 9.3 Input lockout
While `gs.isAnimating == true`:
- Dice tray buttons disabled
- Cauldron node buttons disabled
- Profile buttons disabled
- BREW sign disabled
- Gear icon disabled

This matches the convention in Match-3 (no skip-during-animation in v1).

### 9.4 Floating-number font swap (LOCKED PLAN)
The user has a custom OverQuest font used elsewhere in the project (per `FontExtensions.swift` — `Font.gameScore`, `Font.gameUI`). Floating numbers currently use system serif heavy. When the font is registered for this game, change one line:
```swift
// in PotionShopBrewAnimator.swift
static func numberFont(size: CGFloat) -> Font {
    Font.gameUI(size: size)   // ← was: .system(size: size, weight: .heavy, design: .serif)
}
```

---

## 10. THE QUEUE/SWAP MECHANIC (DO NOT REDESIGN — TOOK 8 ATTEMPTS)

This is the most-bug-prone part of the codebase. The locked rule:

**Tapping a non-front profile button swaps that customer with whoever is currently at `queue[0]`. The third customer (if present) does not move.**

Concrete trace with 3 customers — Wendelina (W), Crispin (C), Ardo (A) — initial queue `[W, C, A]`:
- Tap **C**'s profile → queue becomes `[C, W, A]`. C is now active. W moves to where C was. A is untouched.
- From `[C, W, A]`, tap **A**'s profile → queue becomes `[A, W, C]`. A is now active. C moves to where A was. W is untouched.

**Why this is hard:**
- The profile button row is driven by `customers` (insertion order, never changes).
- The customer scene line is driven by `queue` (changes on every swap).
- Earlier attempts derived scene positions from filtered/spawn-indexed arrays — that produced "tapping right button moves the WRONG customer" bugs.

**The fix:** `queue` is the single source of truth for scene order. `tapProfile()` is a 2-element swap on the queue array, nothing else. The renderer iterates `queue` and places each customer at `queueXFractions[index]`.

**Animation:** `matchedGeometryEffect` on each customer view (id = customer id, in a shared `Namespace`) makes SwiftUI animate the position change automatically. Plus a small "settle bounce" when a customer arrives at the active position.

---

## 11. INSPECT STRIP (the dynamic card)

**Trigger:** tapping any profile button (active or waiting).
**Effect:** the customer becomes active (queue swap fires) AND the strip opens.
**Layout:** parchment-cream pill, brown border, ~64pt tall.
- **Left:** circular portrait with green→amber patience ring (matches profile button ring color logic — green > 40%, amber otherwise). The ring is a real `Circle().trim(...)` reflecting `customer.patience / customer.maxPatience`.
- **Middle:** customer name (bold serif) on top, `OrderName • Atk N` subtitle on bottom.
- **Right:** red rounded-capsule pill with `🧪 N` showing the brew target (HP + Intimidating modifier if applicable; just HP for waiting customers).
**Open animation:** portrait slides outward to the LEFT from a center-collapsed position; body (name+subtitle) slides outward to the RIGHT; pill slides further right to its final spot. All three pieces fade in. ~0.45s spring. **Not a top-down drop** — that was a Phase 6 regression we explicitly fixed.
**Dismiss:** tap the strip → it fades out and shrinks back in place.

---

## 12. DEBUG MENU (always available in v1)

Triggered by **gear icon top-right of header**. Opens as a sheet.

| Action          | What it does                                                 |
|-----------------|--------------------------------------------------------------|
| End Game        | Dismisses the game, returns to Game Selector                 |
| Skip to Round 1 | Jump to Day 1 / Morning (resets composure, fresh customers)  |
| Skip to Round 2 | Jump to Day 1 / Afternoon                                    |
| Skip to Round 3 | Jump to Day 1 / Evening (3 customers — best for testing)     |
| Skip to Round 4 | Jump to Day 1 / Night (boss)                                 |
| Reset Round     | Re-spawn current round from scratch                          |
| Heal to Full    | composure → 30, shield → 0                                   |
| Win Round       | Defeat all current customers instantly (test round-end overlay) |
| Lose Game       | composure → 0 (test lose overlay)                            |
| **Layout Editor** | **NEW (May 5, 2026)** - Live overlay editor for visual tuning |

Always available in v1. Will be moved behind a `GameConfig.enableDebugMenu` toggle for App Store builds (deferred — see §17).

### 12.1 Layout Editor (NEW - May 5, 2026 - LIVE PREVIEW OVERLAY)

**Access:** Debug Menu → "Layout Editor (Live Overlay)"

**Mode:** Semi-transparent floating overlay that appears OVER the game view (20% opacity background)

**Key Innovation:** Overlay appears ON TOP of the actual game layout, so you see changes instantly in real-time while adjusting sliders. Game view is visible behind the controls at 80% brightness.

**Architecture:**
- **Shared Observable Config:** `PotionShopLayoutConfig.shared` singleton holds all layout values
- **Game View Binding:** `PotionShopGameView` reads from `layoutConfig` instead of hardcoded values
- **Overlay Binding:** `PotionShopLayoutOverlay` writes to same `layoutConfig` via sliders
- **Result:** Slider changes → config updates → game re-renders instantly (true live preview!)

**UI Design:**
- **Section-focused:** Only ONE section's controls visible at a time (reduced clutter)
- **Horizontal pill picker:** Swipe through section pills at top (📏 🧙 🍲 🥘 🔵 🎲 🥄)
- **Active pill:** Solid cyan fill with white text
- **Inactive pills:** Transparent with cyan border
- **Floating panel:** Rounded rectangle at bottom with dark semi-transparent background
- **Close button:** X icon at top-right of panel
- **No code generation button:** (Old sheet-based editor had this; new overlay skips it for cleaner UX)

**What You Can Control:**

| Section | Controls | Range | Notes |
|---------|----------|-------|-------|
| **📏 Sections** | Header, Scene, Profile, Cauldron, Preview, Tray percentages | 0-60% each | Shows total % (red if >100%) |
| **🧙 Ednar** | Width, Height, X, Y position | 0.5-3.0× scale, ±200pt position | Character art scaling |
| **🧍 Customers** | **All 14 characters: Active + Waiting + Waiting 2 positions** | **0.5-5.0× scale, ±200pt position** | **3-position system with uniform scale (May 12, 2026)** |
| **🍲 Cauldron** | Width, Height, X, Y position | 0.5-3.0× scale, ±200pt position | Cauldron art scaling |
| **🥘 Bowl** | Scale, X offset, Y offset | 0.5-3.0× scale, ±200pt offset | Parametric bowl shape |
| **🔵 Nodes** | Node scale, Grid X, Grid Y, **⚠️ Spacing Multiplier** | 0.5-3.0× scale, ±200pt offset, **0.5-2.0× spacing (EXPERIMENTAL)** | Entire node grid positioning + **experimental spacing** |
| **🔧 Fine-Tune** | **Per-node X/Y offsets (0-11)** | **±100pt per node** | **Individual node positioning (NEW May 5, 2026)** |
| **🎲 Dice** | Die scale, Tray X, Tray Y | 0.5-3.0× scale, ±200pt offset | Dice size + tray offset |
| **🥄 Brew** | X, Y position (fraction), Width, Height (pts), Show Zone toggle | 0-1 position, 50-300pt size | Invisible tap zone |

**How It Works:**
1. Tap "Layout Editor (Live Overlay)" in debug menu
2. Debug menu **closes automatically**
3. Overlay appears over game with section pill picker at top
4. Game is **visible behind overlay** (darkened to 80%)
5. Tap a section pill (e.g., **🧙 Ednar**)
6. Pill turns **solid cyan**, sliders appear below
7. **Drag sliders** → **game updates INSTANTLY** (live preview!)
8. Tap **different pill** to switch sections (previous section collapses)
9. Tap **X button** or **tap background** to close overlay
10. Debug menu does NOT reopen (back to full game view)

**Example Live Preview Flow:**
```
User drags Ednar Width slider to 3.0×
    ↓
PotionShopLayoutConfig.shared.ednarWidth = 3.0
    ↓
PotionShopGameView reads layoutConfig.ednarWidth
    ↓
Ednar re-renders at 3× width IMMEDIATELY (no rebuild needed!)
```

**Files Involved:**
1. **PotionShopLayoutConfig.swift** (NEW) - Shared `@Observable` singleton with all layout values
2. **PotionShopGameView.swift** - Modified to read from `layoutConfig` instead of hardcoded values
3. **PotionShopDebugMenu.swift** - Modified to pass `$showLayoutOverlay` binding + close menu when opening overlay
4. **PotionShopLayoutOverlay** (struct inside `PotionShopGameView.swift`) - The overlay UI itself
5. **PotionShopCauldronView.swift** - Modified to apply per-node offsets to node positioning

#### **12.1.1 Per-Node Fine-Tuning (NEW - May 5, 2026)**

**Status:** ✅ COMPLETE - Ready for Testing  
**Feature:** Individual node positioning with live preview

The layout editor includes a **🔧 Fine-Tune** section that allows you to adjust the position of each individual node independently.

**Key Features:**
- ✅ **Dropdown picker** to select which node (0-11)
- ✅ **X Offset slider** (-100 to +100 pts)
- ✅ **Y Offset slider** (-100 to +100 pts)  
- ✅ **Reset This Node** button (reset selected node to default)
- ✅ **Reset All Nodes** button (reset all 12 nodes at once)
- ✅ **Live preview** - changes apply instantly as you drag sliders
- ✅ **Relative positioning** - offsets apply AFTER spacing multiplier (global controls still work)

**How to Use:**

1. **Open Layout Editor:**
   - Debug Menu (⚙️) → "Layout Editor (Live Overlay)"

2. **Access Fine-Tune Section:**
   - Scroll pill picker to **🔧 Fine-Tune**
   - Tap pill → controls appear

3. **Adjust Individual Node:**
   - Tap **"Select Node"** dropdown
   - Choose a node (Node 0 through Node 11)
   - **X Offset slider** - Move node left (-) or right (+)
   - **Y Offset slider** - Move node up (-) or down (+)
   - Watch the node move in real-time!

4. **Reset When Done:**
   - **"Reset This Node"** - Undo changes to current node only
   - **"Reset All Nodes"** - Undo all per-node tweaks (back to defaults)

**Layered Positioning System:**
```
Final Node Position = 
  Grid Origin 
  + (Base Coordinate × Spacing Multiplier)  // Global controls
  + Per-Node Offset                          // Fine-tune controls
```

**Example:**
- Node 5 base position: (5.4, 82.3)
- Spacing multiplier: 1.2× = (6.5, 98.8)
- Grid X offset: +10 = (16.5, 98.8)
- Grid Y offset: -5 = (16.5, 93.8)
- **Per-node X offset: +25** = (41.5, 93.8)
- **Per-node Y offset: -10** = (41.5, 83.8) ← Final position!

**This means:**
- Global sliders (Grid X/Y) still move ALL nodes
- Spacing slider still spreads them apart
- Fine-tune offsets are applied ON TOP of those changes

**Data Structure:**
```swift
// In PotionShopLayoutConfig
var perNodeOffsets: [CGPoint] = Array(repeating: .zero, count: 12)

// CGPoint(x: Double, y: Double)
// x: horizontal offset in points (-100 to +100)
// y: vertical offset in points (-100 to +100)
```

**Position Calculation:**
```swift
// In PotionShopCauldronView
ForEach(0..<PotionShopBoard.nodes.count, id: \.self) { idx in
    let node = PotionShopBoard.nodes[idx]
    let perNodeOffset = perNodeOffsets[idx]  // Get this node's offset
    
    PotionShopNodeButtonView(...)
        .position(
            x: g.nodeOriginX + CGFloat(node.x) * g.nodeSpacingMultiplier + perNodeOffset.x,
            y: g.nodeOriginY + CGFloat(node.y) * g.nodeSpacingMultiplier + perNodeOffset.y
        )
}
```

**UI Design:**
- **Picker:** Dropdown menu shows "Node 0" through "Node 11"
- **Sliders:** Cyan theme (consistent with other controls)
- **"Reset This Node" button:** Orange (caution color)
- **"Reset All Nodes" button:** Red (danger color - more destructive)
- Currently selected node is highlighted in picker

**Common Use Cases:**

**Scenario 1: Fix Overlapping Nodes**
- Problem: Node 3 and Node 4 are too close after adjusting spacing
- Solution: Select Node 4 → X Offset +15 → nodes no longer overlap

**Scenario 2: Create Custom Layout**
- Problem: Want nodes in a circle instead of grid
- Solution: Fine-tune each node individually to form circle shape

**Scenario 3: Align with Art**
- Problem: New cauldron art has custom markings for node positions
- Solution: Fine-tune each node to align with art asset markings

**Scenario 4: Experimental Layouts**
- Problem: Want to test if different node positions affect gameplay
- Solution: Move nodes around, playtest, reset if it doesn't work

**⚠️ Warnings & Limitations:**

**Graph Topology Unchanged:**
- Moving nodes does NOT change which nodes are connected by edges
- Boost reach is based on GRAPH structure, not visual distance
- Example: Node 0 and Node 3 are connected via an edge. If you move Node 3 far away, the edge line will stretch but they're still "neighbors" for boost purposes.

**No Boundary Validation:**
- You CAN move nodes outside the cauldron bowl
- You CAN overlap nodes completely
- **Recommendation:** Use moderate offsets (-50 to +50) for best results

**Not Saved Between Sessions:**
- Closing the app resets all per-node offsets to zero
- To save a layout: Copy values from layout editor and paste into `PotionShopLayoutConfig.swift` defaults

**Testing Checklist:**

**Basic Functionality:**
- ✅ Fine-Tune pill appears in pill picker
- ✅ Tapping pill shows controls
- ✅ Dropdown shows all 12 nodes
- ✅ Selecting different nodes updates sliders
- ✅ X slider moves node left/right immediately
- ✅ Y slider moves node up/down immediately

**Reset Functions:**
- ✅ "Reset This Node" zeros out current node's offset
- ✅ "Reset All Nodes" zeros out all 12 nodes
- ✅ Sliders update to show 0 after reset

**Edge Cases:**
- ✅ Switch between nodes - sliders show correct values for each
- ✅ Move node to extreme (+100, +100) - still playable?
- ✅ Move node to opposite extreme (-100, -100) - doesn't escape bowl?
- ✅ Adjust global spacing THEN fine-tune - offsets stack correctly?
- ✅ Adjust fine-tune THEN global spacing - node keeps relative position?

**Gameplay:**
- ✅ Dice can still be placed on fine-tuned nodes
- ✅ Drag-and-drop still works
- ✅ Edge lines still connect to moved nodes
- ✅ No crashes during brew animation

**Current Production Values (Locked - May 5, 2026 - 1:36 AM):**
```swift
// Section Heights
headerPercent: 1.0
scenePercent: 26.3
profilePercent: 9.5
cauldronPercent: 37.2
previewPercent: 3.2
trayPercent: 19.3

// Ednar Art
ednarWidth: 1.59
ednarHeight: 2.0
ednarX: 14.0
ednarY: -17.0

// Cauldron Art
cauldronWidth: 1.3613475412130356
cauldronHeight: 1.9335107803344727
cauldronX: -2.219867706298828
cauldronY: -34.326231479644775

// Bowl
cauldronBowlScale: 1.3121631294488907
cauldronBowlX: 44.709229469299316
cauldronBowlY: 58.0

// Nodes
nodeScale: 1.8311170041561127
nodeXOffset: 70.21276950836182
nodeYOffset: 74.82268810272217
nodeSpacingMultiplier: 1.0  // ⚠️ EXPERIMENTAL: Kept at 1.0 for production

// Per-Node Offsets (all 12 nodes individually positioned)
perNodeOffsets: [
    CGPoint(x: -38.297873735427856, y: -37.94326186180115),  // Node 0
    CGPoint(x: 24.290776252746582, y: -37.41135001182556),   // Node 1
    CGPoint(x: -86.70212775468826, y: 5.6737542152404785),   // Node 2
    CGPoint(x: -7.446807622909546, y: -22.16312289237976),   // Node 3
    CGPoint(x: 83.68793725967407, y: 6.2056779861450195),    // Node 4
    CGPoint(x: -28.723400831222534, y: 28.19148302078247),   // Node 5
    CGPoint(x: 71.45389318466187, y: 7.0922017097473145),    // Node 6
    CGPoint(x: -53.014183044433594, y: 35.638296604156494),  // Node 7
    CGPoint(x: -91.13475382328033, y: 28.19148302078247),    // Node 8
    CGPoint(x: -38.1205677986145, y: 60.10638475418091),     // Node 9
    CGPoint(x: 20.567357540130615, y: 60.283684730529785),   // Node 10
    CGPoint(x: 83.51064920425415, y: 38.29786777496338)      // Node 11
]

// Dice
dieScale: 1.405301421880722
trayOffsetX: 4.609942436218262
trayOffsetY: 6.2056779861450195

// Brew Zone
brewZoneX: 0.8424113392829895
brewZoneY: 0.15010638535022736
brewZoneWidth: 113.10815364122391
brewZoneHeight: 95.51772773265839
showBrewZone: false
```

#### **12.1.2 Customer Scene Scaling (UPDATED - May 12, 2026)**

**Status:** ✅ COMPLETE - All 14 Characters + 3-Position System (Active / Waiting / Waiting 2)  
**Feature:** Per-character width/height/X/Y scaling with live preview, character picker, uniform scale slider, AND separate active/waiting/waiting2 positions

The layout editor includes a **🧍 Customers** section that allows you to adjust the size and position of customer scene portraits independently for **THREE queue positions: active (queue[0]), waiting (queue[1]), and waiting 2 (queue[2])**.

**Key Features:**
- ✅ **Character picker dropdown** - Select any of 14 characters (ALL customers now included!)
- ✅ **⭐️ ACTIVE POSITION** section (green header) - Controls for when customer is at queue[0] (front of line)
  - 🔗 Uniform Scale slider (0.5× to 5.0×) - Adjusts width AND height together (yellow color)
  - Width slider (0.5× to 5.0×) - Horizontal scaling (independent)
  - Height slider (0.5× to 5.0×) - Vertical scaling (independent)
  - X Offset slider (-200 to +200 pts) - Horizontal position
  - Y Offset slider (-200 to +200 pts) - Vertical position
- ✅ **⏸️ WAITING POSITION** section (orange header) - Controls for when customer is at queue[1] (second position)
  - 🔗 Uniform Scale slider (0.5× to 5.0×) - Adjusts waiting width AND height together
  - Width slider (0.5× to 5.0×) - Waiting horizontal scaling
  - Height slider (0.5× to 5.0×) - Waiting vertical scaling
  - X Offset slider (-200 to +200 pts) - Waiting horizontal position
  - Y Offset slider (-200 to +200 pts) - Waiting vertical position
- ✅ **⏸️ WAITING POSITION 2 (queue[2])** section (**NEW May 12, 2026** - purple header) - Controls for when customer is at queue[2] (back of line)
  - 🔗 Uniform Scale slider (0.5× to 5.0×) - Adjusts waiting2 width AND height together
  - Width slider (0.5× to 5.0×) - Waiting2 horizontal scaling
  - Height slider (0.5× to 5.0×) - Waiting2 vertical scaling
  - X Offset slider (-200 to +200 pts) - Waiting2 horizontal position
  - Y Offset slider (-200 to +200 pts) - Waiting2 vertical position
  - **"Link W/H" button** (cyan) - Copies width value to height for proportional scaling
  - **"Reset Position" button** (orange) - Resets X and Y offsets to 0
- ✅ **Dynamic reset button** - Changes to "Reset [Character]" based on selection
- ✅ **Live preview** - Changes apply instantly to the selected character
- ✅ **No circle clipping** - Full images visible for proper resizing
- ✅ **Smooth transitions** - Characters animate between active/waiting/waiting2 scales during queue swaps

**All 14 Characters Available:**
1. Mildred Honeycomb
2. Tomik Cooper
3. Greta Marshlow
4. Pemberton Quill
5. Sister Halla
6. Ardo Quill
7. Wendelina Rookpool
8. Bram the Bard
9. Lord Crispin Vorne
10. Hexa Mott
11. Captain Ironhilde
12. Grimdrek the Volatile
13. Lady Carmilla Veil
14. The Royal Envoy

**Uniform Scale Feature:**
- Located at the **top of each section** (Active and Waiting)
- **Yellow color** (distinct from cyan individual sliders)
- Dragging slider sets **both width AND height to the same value**
- Perfect for **quick proportional scaling** without touching individual sliders
- Displays current width value (since width = height when using uniform scale)
- Helper text: "Adjusts width AND height together" (Active) or "Waiting scale (when not active)" (Waiting)

**3-Position System (NEW - May 12, 2026):**
- **Active position** = When customer is at `queue[0]` (front of line, closest to Ednar)
- **Waiting position** = When customer is at `queue[1]` (middle position)
- **Waiting 2 position** = When customer is at `queue[2]` (back of line, farthest from Ednar)
- **Queue swap animation** smoothly transitions between all three states
- **Example use**: Make waiting2 customers 70% size to create strong depth effect (queue[0]=100%, queue[1]=85%, queue[2]=70%)
- **Default (May 12, 2026)**: All positions are 1.0× (same size) - depth effect achieved via queue depth scaling instead

**Workflow:**
1. Select character from picker
2. **Adjust Active Position:**
   - Scroll to **⭐️ ACTIVE POSITION** (green header)
   - Drag **🔗 Uniform Scale** for quick proportional sizing
   - OR drag individual Width/Height sliders for asymmetric scaling
   - Adjust X/Y sliders to position when active
3. **Adjust Waiting Position:**
   - Scroll to **⏸️ WAITING POSITION** (orange header)
   - Drag **🔗 Uniform Scale** for quick proportional sizing
   - OR drag individual Width/Height sliders for asymmetric scaling
   - Adjust X/Y sliders to position when waiting at queue[1]
4. **Adjust Waiting 2 Position (NEW!):**
   - Scroll to **⏸️ WAITING POSITION 2 (queue[2])** (purple header)
   - Drag **🔗 Uniform Scale** for quick proportional sizing
   - OR drag individual Width/Height sliders for asymmetric scaling
   - Adjust X/Y sliders to position when waiting at queue[2]
   - Use **"Link W/H"** button to make width = height (proportional)
   - Use **"Reset Position"** button to zero out X/Y offsets
5. Character updates instantly in live preview
6. Test by playing round with 3 customers (Skip to Round 3 - Evening) and tapping profiles to swap

**Current Characters with Default Values (May 12, 2026):**

| Character    | Active Scale | Active Pos | Waiting Scale | Waiting Pos | Waiting 2 Scale | Waiting 2 Pos | Notes |
|--------------|--------------|------------|---------------|-------------|-----------------|---------------|-------|
| All 14       | 1.0×1.0×     | 0pt, 0pt   | 1.0×1.0×      | 0pt, 0pt    | 1.0×1.0×        | 0pt, 0pt      | Same size at all positions (May 12) |

**Default Scale Rationale (CHANGED May 12, 2026):**
- All positions: 1.0× width, 1.0× height (pixel-accurate, no distortion)
- Images drawn at 1536×1024 @ 300 DPI appear at correct proportions without manual adjustment
- Depth effect achieved via queue depth scaling (active: 1.0×, waiting: 0.78×, waiting2: 0.72×) rather than per-character config
- Based on user's 1536×1024 px Procreate canvas (3:2 landscape)
- **All positions start at same scale** - use layout editor to customize per-character if needed

**Technical Implementation:**
- Data structure: `CharacterScale` struct with 12 properties (4 active + 4 waiting + 4 waiting2)
- Dynamic rendering: `isActive ? activeValues : (queueIndex == 1 ? waitingValues : waiting2Values)`
- Animation: `matchedGeometryEffect` handles smooth transitions during queue swaps
- Spring animation: 0.55s response, 0.78 damping fraction

**Circle Clipping Removal (CRITICAL FIX):**

**Problem:** Scene portraits were being cropped to circles, making it impossible to see the full image while resizing.

**Solution:** Modified `sceneImageOrFallback()` in `PotionShopModels.swift`:

**Before (WRONG):**
```swift
Image(uiImage: uiImage)
    .resizable()
    .scaledToFill()
    .frame(width: size, height: size)
    .clipShape(Circle())  // ← CROPPED TO CIRCLE!
```

**After (CORRECT):**
```swift
Image(uiImage: uiImage)
    .resizable()
    .scaledToFit()  // ← Preserves aspect ratio
    .frame(width: size, height: size * 1.5)  // ← 2:3 aspect ratio
    // NO .clipShape(Circle()) ← REMOVED! Full image visible!
```

**Value Flow (Connection Chain):**
```
Layout Editor Sliders
    ↓
PotionShopLayoutConfig.perCharacterScales[characterId]
    ↓
PotionShopGameView (passes layoutConfig to scene)
    ↓
PotionShopCustomerSceneView (reads character scale from config)
    ↓
PotionShopCustomerInSceneView (receives active + waiting values)
    ↓
let effectiveWidth = isActive ? customerSceneWidth : customerWaitingWidth
let effectiveHeight = isActive ? customerSceneHeight : customerWaitingHeight
    ↓
.scaleEffect(x: effectiveWidth, y: effectiveHeight)
.offset(x: effectiveX, y: effectiveY)
    ↓
VISUAL UPDATE (Character uses correct values based on queue position!)
    ↓
During queue swap: matchedGeometryEffect animates smooth transition
```

**Files Modified:**
1. **PotionShopLayoutConfig.swift** 
   - Added `waiting2Width`, `waiting2Height`, `waiting2X`, `waiting2Y` to `CharacterScale` struct (May 12, 2026)
   - Changed all defaults to 1.0×1.0× for all positions (active, waiting, waiting2)
   - All 14 characters in `perCharacterScales` dictionary
2. **PotionShopGameView.swift** 
   - Added **"⏸️ WAITING POSITION 2 (queue[2])"** UI section (purple header) (May 12, 2026)
   - Added waiting2 uniform scale slider (yellow)
   - Added 4 waiting2 sliders (width/height/x/y)
   - Added "Link W/H" and "Reset Position" helper buttons for waiting2
   - Split UI with green **"⭐️ ACTIVE"**, orange **"⏸️ WAITING"**, and purple **"⏸️ WAITING 2"** headers
3. **PotionShopCustomerSceneView.swift** 
   - Added 4 waiting2 parameters to `PotionShopCustomerInSceneView` (May 12, 2026)
   - Updated to 3-way conditional: `isActive ? active : (queueIndex == 1 ? waiting : waiting2)`
   - Passes waiting2 values from layout config
   - Renders using correct values based on queue position (0, 1, or 2)
4. **PotionShopData.swift**
   - All 14 characters use proper `_scene` suffix for scene portraits
5. **PotionShopModels.swift** 
   - **REMOVED circle clipping**, changed to `.scaledToFit()`
6. **CAULDRON_CONTEXT.md**
   - Updated documentation to reflect 3-position system (May 12, 2026)

**Deprecation:**
- The old sheet-based editor (`PotionShopNewLayoutEditor` struct in `PotionShopDebugMenu.swift`) is still present but **not used**
- Can be deleted in a future cleanup
- Old editor had collapsible sections + code generation button; new overlay is cleaner without those

**Safety Notes:**
- Node spacing/positioning is SAFE (only grid translation + uniform scale)
- Node rearrangement/removal is **NOT implemented** (would break graph topology)
- All changes are real-time but NOT persisted (closing app resets to defaults)
- To make changes permanent: copy values from layout editor → paste into `PotionShopLayoutConfig.swift` defaults

---

## 13. WHAT'S DONE (PHASE HISTORY)

| Phase | Title                                | Status | Notes                                                  |
|-------|--------------------------------------|--------|--------------------------------------------------------|
| 1     | Project scaffold + selector wiring   | ✅     | Folder, enum case, selector route, "Phase 1 complete!" stub |
| 2     | Data layer                           | ✅     | 14 customers, 8 traits, Day 1 rounds — all hardcoded   |
| 3     | Game state machine                   | ✅     | Queue/swap, dice, brewing math, instant `doBrew()`. `Customer` → `PotionShopCustomer` (collision fix) |
| 4     | Real gameplay UI                     | ✅     | Header, customer scene, profile row, cauldron, dice tray, end-of-round placeholder. `CauldronBoardView` → `PotionShopCauldronBoardView` (collision fix). All views prefixed for safety. |
| 5     | Queue/swap animation polish          | ✅     | `matchedGeometryEffect` + settle bounce                |
| 5b    | Layout proportions                   | ✅     | GeometryReader vertical sections, count-aware queue X  |
| 5c    | Cauldron bowl shape + BREW sign      | ✅     | Wide ellipse half-bowl with wooden post sign           |
| 5d    | Debug menu                           | ✅     | Gear icon, sheet, removed broken back chevron          |
| 6     | Dice slide animation (tray ↔ board)  | ✅     | `matchedGeometryEffect` shared `@Namespace var diceFlight` |
| 6b    | Dice fall straight + inspect in-place| ✅     | Removed tumble; inspect transition `.move(.top)` → in-place scale+fade |
| 6c    | Inspect card matches web artifact    | ✅     | Bigger card, target pill, green ring, hint banner      |
| 6d    | Patience ring on inspect portrait    | ✅     | Reflects `patience/maxPatience` like profile buttons   |
| 6e    | Inspect card slide-outward animation | ✅     | Portrait→left, body→right from center-collapsed start |
| 7     | Animated 7-phase brew sequence       | ✅     | Full floating numbers, shake, flash, expiration slide-out, input lockout, animator constants file |
| **7b** | **Interactive layout editor (May 4)** | ✅ | **Real-time visual editor with 20+ sliders, code generation, colored overlays. Node independent positioning. Integrated into debug menu. See `LAYOUT_EDITOR_SESSION_MAY4_2026_PART2.md`.** |
| **7c** | **Drag-and-drop dice (May 4)**       | ✅ | **Full gesture-based drag system with visual feedback (scale, glow, node pulse). Both tap and drag methods work. Clipping fix for tray. Global coordinate hit detection.** |
| **7d** | **Freeform art scaling (May 4 evening)** | ✅ | **Independent width/height scaling + X/Y positioning for cauldron & Ednar. Real-time sliders in layout editor. 8 new parameters total. See §8.9 for full documentation.** |
| **7e** | **Art scaling FIX (May 4 evening)** | ✅ | **CRITICAL FIX: Removed `.scaledToFill()` from both images and added missing `*ArtScale` multiplier. Width/height sliders now work independently with true distortion. Images can be stretched/squished freely without aspect ratio constraints.** |
| **7f** | **Live preview overlay editor (May 5)** | ✅ | **MAJOR REFACTOR: Replaced sheet-based editor with semi-transparent floating overlay that appears OVER the game. Shared `@Observable` config (`PotionShopLayoutConfig.shared`) enables true live preview. Section-focused UI with horizontal pill picker (📏🧙🍲🥘🔵🎲🥄). Added 🔵 Nodes section for grid positioning. Slider changes update game instantly without rebuild. See §12.1 for full documentation.** |
| **7g** | **Per-node fine-tuning (May 5)** | ✅ | **Added 🔧 Fine-Tune section to layout editor. Individual X/Y offset controls for all 12 nodes (±100pt range). Dropdown picker to select node. "Reset This Node" and "Reset All Nodes" buttons. Offsets apply AFTER spacing multiplier (layered positioning). See §12.1.1 for full documentation.** |
| **7h** | **Customer scene scaling system (May 6)** | ✅ | **Added 🧍 Customers section to layout editor. Per-character width/height/X/Y scaling with character picker dropdown (Mildred & Tomik). Removed circle clipping from scene portraits so full images are visible. Values passed from layoutConfig → GameView → SceneView → CustomerView. Both characters default to 2.34×2.13× with 5pt, 51pt offsets. See §12.1.2 for full documentation.** |

---

## 14. WHAT'S PENDING (NEXT STEPS)

### 14.1 Phase 8 — Art asset integration (PRIORITY NEXT)
**Status:** User is ready to begin adding art assets to the game.

**Art System Overview:**
- Asset loader in `PotionShopImageLoader` (or similar)
- All placeholder art references use `UIImage` loading with emoji fallbacks
- See §16 (ART ASSETS) for complete specifications

**Assets Needed:**
- 14 customer portraits (1024×1024 px)
- 5 Ednar expressions (1024×1536 px)
- 1 cauldron image (2048×1536 px) - single layer, replaces 3-layer system
- 5 dice face images (512×512 px) - flat-faced, center 30% blank for number overlay
- 1 shop background (1242×2688 px)
- 6 UI icons (256×256 px)

**Current Art Status:**
- All art is emoji/placeholder colored shapes
- Customer portraits: emoji fallbacks
- Ednar: no art (implied presence)
- Cauldron: parametric bowl shape (brown gradient)
- Dice: colored squares with text labels
- Background: parchment color fill

**See NEW DOCUMENT:** `ART_INTEGRATION_HANDOFF_MAY4_2026.md` for complete guide to art integration work.

### 14.2 Phase 9 — Round-end / Day-end / Lose overlays
Currently when a round ends the game shows a black overlay with "Round Complete" and a "Continue" button — placeholder from Phase 4. Need:
- **Round complete overlay:** which customers were defeated, composure remaining, "Continue to [next round]" button
- **Day complete overlay:** "Day 1 Complete" with full summary, "Return to Selector" button (or "Play Again")
- **Lose overlay:** "You Collapsed" message, "Try Again" (restart current round) and "End Game" buttons
- **Boss-defeat flourish** on Night round when Grimdrek goes down (light effect, not over-engineered)

### 14.3 Phase 10 — Trait stub implementation
- **Loud (Bram):** while Bram is in the queue (and not active), reduce the player's "focus" by 1. **NOTE:** "focus" is not yet a defined mechanic in this codebase — needs design clarification before coding. Possible interpretations: -1 to all dice in hand while loud is waiting, or a separate visible "focus" stat. ASK the user before implementing.
- **Hexer (Hexa Mott, Carmilla):** each turn the customer waits, one random die in the player's current hand rerolls to its lowest face. Mechanic is well-defined; needs to fire during a turn-end phase, probably between phase 5 (patience ticks) and phase 6 (expirations).

### 14.4 Phase 11 — Day 2 + Day 3 (procedural rounds)
The data file has Day 2 and Day 3 templates designed (random pulls + hybrid). Wiring them in requires:
- A round-builder function that takes `min/max difficulty + must_include_tag + required_trait + exclude_ids` and returns a customer list
- Day-transition flow (Day 1 complete → Day 2 starts)
- "Day N" indicator in the header

### 14.4 Phase 11 — Streak-based win condition
The user's eventual win mode: **after Day 3, days are randomized, and "winning" is a streak count of how many days the player can survive without losing.** Adds: streak counter, save state for personal-best, "you survived N days" end screen.

### 14.5 Phase 12 — Real art swap (placeholder → final)
See §16 for the full art spec. When the user's Procreate PNGs are ready, the swap is: drop PNGs into `Assets.xcassets`, change `iconFallback` emoji to `Image("name")` in the relevant views. The placeholder code is already structured to make this a 1-line change per asset.

### 14.6 Phase 13 — Audio + haptics polish
Deferred to v2. Will need: brew sound on each phase, customer-chatter ambient, success/fail jingles, haptic on shield break, haptic on customer expire, etc.

---

## 15. THINGS THE USER WANTS TO EDIT EVENTUALLY (running list)

These are items the user explicitly flagged as "I might change this" or "let's revisit." **Ask the user before changing them.**

| # | Topic                                              | What might change                                                                 |
|---|----------------------------------------------------|----------------------------------------------------------------------------------|
| 1 | `COMPOSURE_REST_BETWEEN_ROUNDS`                    | Likely going to 0 — composure refills only between full days, not between rounds |
| 2 | Turn order (brew → attacks → patience → ...)       | User said "I may want to change this and ask before executing"                  |
| 3 | Tier-4/5 customers' auto-defaulted combat values   | Sister Halla, Bram, Hexa Mott, Ironhilde, Grimdrek, Carmilla, Royal Envoy — values were set by tier defaults without playtest. Retune after playing Day 1. |
| 4 | Dice board layout                                  | User explicitly said "I may want to change the layout of the dice board later"   |
| 5 | All Phase 7 animation timings                      | User is an animator; everything in `PotionShopBrewAnimator.swift` is up for tuning. See `BREW_ANIMATION_DOC.md`. |
| 6 | Floating-number font                               | Will swap to OverQuest font when registered                                      |
| 7 | BREW button visual                                 | Placeholder wooden sign — user will replace with their art (possibly a real ladle dipping in) |
| 8 | Dice icons (POT/STB/BST/HEAL/SHD)                  | Currently colored squares with text labels. User will draw real dice art (flat-faced 512×512, center kept blank for runtime number) |
| 9 | Cauldron art                                       | Placeholder parametric ellipse. User will replace with 3-layer Procreate art (back/liquid/front) |
| 10 | Customer expiration drama                         | Currently a small shake + slide-off + 💢 burst. User said "fine for now, I may want it more dramatic" |
| 11 | Tap-to-expand inspect alternative                  | Earlier discussion: long-press, "i" icon, or other gesture instead of single-tap (currently single-tap promotes AND inspects) |
| 12 | Persistent inspect strip option                    | Earlier mockup had "always visible" inspect strip option; locked decision was "tap-only." User said "may change my mind to A later" — keep this discoverable. |
| 13 | Day 2+ multi-day progression / unlocks            | Tier system in code is dormant; will activate when Day 2+ ships                 |
| 14 | Bag/discard visualization                         | Currently invisible; future v2 add                                              |
| 15 | Drag-and-drop dice                                 | Currently tap-die-then-tap-node. Drag is a v2 polish item.                       |
| 16 | Reach preview on iOS                              | Hover preview works on desktop only; needs a tap-and-hold or auto-on-select for iOS |
| 17 | Stability dice usage                               | Possibly underused; rebalance after Day 1 playtest                              |
| 18 | "Focus" mechanic for Loud trait                   | The Loud trait says "reduces focus by 1" — focus isn't defined yet. Needs design before Phase 9. |
| 19 | Layered cauldron animation                        | Once 3-layer cauldron art is in, the liquid layer can bubble/shimmer independently |
| 20 | 6th Ednar expression — "hurt"                     | Optional flinch frame during attack animations. Not in the v1 art deliverable.   |
| 21 | Save state                                         | None implemented. Eventually need to persist streak count, current day, options. |
| 22 | iPad layout                                        | iPhone-only for v1. iPad layout work deferred.                                   |
| 23 | Debug menu toggle                                  | Always-available in v1; gate behind `GameConfig.enableDebugMenu` for App Store. |
| 24 | Legacy `CauldronGame/` folder                     | User wants to delete it eventually but not now. Don't touch it without asking.   |

---

## 16. ART ASSETS — CUSTOMER SCENE PORTRAITS (UPDATED MAY 10, 2026)

The user is drawing all art in **Procreate on iPad**. Customer scene portraits use a **dual portrait system** with separate profile and scene images.

### 16.1 Customer Scene Portrait Canvas Dimensions (✅ SPECIFIED - UPDATED MAY 10, 2026)

Based on the user's Procreate workflow, customer scene portraits are drawn at:

**CANVAS SIZE: 1536 × 1024 pixels @ 300 DPI**

- **Aspect Ratio**: 3:2 (width:height, landscape orientation)
- **Default scale in code**: 1.0× width, 1.0× height (NO DISTORTION - May 12, 2026 update)
- **Reference image**: All characters drawn on same canvas size for proportional consistency

**Why these dimensions:**
- Matches the user's existing Procreate canvas setup
- Provides high-quality retina rendering for iPhone displays
- Same canvas for ALL characters ensures proportional relationships are preserved
- Independent width/height sliders allow fine-tuning per character if needed

### 16.1.1 PIXEL-ACCURATE SIZING SYSTEM (✅ COMPLETE - May 12, 2026)

**The Problem (Before May 12, 2026):**
- Ednar was using `ednarBaseScale: 2.0` (200% scale)
- But layout config had `ednarBaseScale: 0.15` (15% scale)
- Result: Ednar appeared 13× bigger than intended (2.0 ÷ 0.15 = 13.3×)
- Customers and Ednar were using mismatched scaling systems
- Manual tuning required for every character to compensate

**The Solution (Implemented May 12, 2026):**

All art is now drawn on **identical 1536×1024 canvas** and uses **unified base scale approach**:

| Character Type | Canvas Size     | Base Scale | Code Location | Purpose |
|---------------|-----------------|------------|---------------|---------|
| **Ednar**     | 1536×1024 @ 300 DPI | **0.15** | `PotionShopCustomerSceneView` → `ednarBaseScale` | Makes image visible at reasonable size |
| **Customers** | 1536×1024 @ 300 DPI | **2.0**  | `PotionShopCustomerInSceneView` → `customerSceneBaseScale` | Compensates for queue depth scaling |

**Why Different Base Scales?**
- Customers have **queue depth scaling** (active: 1.0×, waiting: 0.78×, back: 0.72×) that reduces their size
- Ednar has NO queue depth scaling (always full size)
- Different base scales compensate for this difference
- **End result:** Characters drawn at same height in Procreate appear same height in-game!

**Frame Calculation (Unified Formula):**
```swift
// EDNAR (PotionShopEdnarView)
let finalWidth = ednarImage.size.width * ednarBaseScale * ednarArtScale * ednarArtWidth
let finalHeight = ednarImage.size.height * ednarBaseScale * ednarArtScale * ednarArtHeight

// CUSTOMER (PotionShopCustomerInSceneView)
let finalWidth = customerImage.size.width * customerSceneBaseScale * effectiveWidth
let finalHeight = customerImage.size.height * customerSceneBaseScale * effectiveHeight

// Where effectiveWidth/Height = isActive ? activeWidth : waitingWidth
```

**Scaling Math Example:**
| Character | Canvas | Base Scale | Art Multiplier | Final Calculation |
|-----------|--------|------------|----------------|-------------------|
| Ednar     | 1536×1024 | 0.15 | 1.0×1.0 | `1536 × 0.15 × 1.0 × 1.0 = 230px wide` |
| Grimdrek (active) | 1536×1024 | 2.0 | 1.0×1.0 | `1536 × 2.0 × 1.0 × 1.0 = 3072px` THEN scaled by queue position (1.0× at front) = **3072px** |
| Grimdrek (waiting) | 1536×1024 | 2.0 | 0.8×0.8 | `1536 × 2.0 × 0.8 × 0.8 = 1966px` THEN scaled by queue position (0.78×) = **~1533px** |

**What Changed (Code-Level Details):**

**File:** `PotionShopCustomerSceneView.swift`

**Before (WRONG - May 11, 2026):**
```swift
struct PotionShopCustomerSceneView: View {
    var ednarBaseScale: Double = 2.0  // ❌ WRONG - doesn't match layout config!
}

struct PotionShopEdnarView: View {
    var ednarBaseScale: Double = 2.0  // ❌ WRONG - doesn't match layout config!
    
    // Emoji fallback - hardcoded size
    let baseEmojiSize: CGFloat = 100
    let finalSize = baseEmojiSize * ednarBaseScale * ednarArtScale  // 100 × 2.0 = 200pt ❌
}
```

**After (CORRECT - May 12, 2026):**
```swift
struct PotionShopCustomerSceneView: View {
    var ednarBaseScale: Double = 0.15  // ✅ MATCHES layout config!
}

struct PotionShopEdnarView: View {
    var ednarBaseScale: Double = 0.15  // ✅ MATCHES layout config!
    
    // Emoji fallback - pixel-accurate sizing
    let baseEmojiSize: CGFloat = 76  // Match customer base size
    let finalSize = baseEmojiSize  // 76pt ✅ (no multiplication - already correct size)
}
```

**Shadow Scaling (Added May 12, 2026):**
```swift
// Ednar shadow now scales proportionally
Capsule()
    .fill(PotionShopTheme.ink.opacity(0.15))
    .frame(
        width: max(64, finalHeight * 0.20),  // 20% of character height
        height: 4
    )
    .offset(y: ednarArtYOffset * 0.5)  // Follows character Y offset (damped)
```

**Benefits:**
- ✅ **Upload once, perfect size** - 1536×1024 images appear at intended proportions without tuning
- ✅ **Consistent workflow** - Same Procreate canvas for ALL characters (Ednar + 14 customers)
- ✅ **Proportional relationships preserved** - Characters drawn taller appear taller in-game
- ✅ **Layout editor still works** - Per-character sliders available for fine-tuning
- ✅ **Default scale 1.0×** - No distortion, images appear as drawn
- ✅ **Shadow scales automatically** - Gets bigger/smaller with character height

**Testing Workflow:**
1. Draw character in Procreate at **1536×1024 @ 300 DPI**
2. Draw at the height/proportions you want relative to other characters
3. Export PNG with **transparent background**
4. Drag into **Assets.xcassets** with exact name (e.g., `ednar_calm`, `mildred_scene`)
5. Build and run → **Character appears at perfect size!** ✨
6. (Optional) Fine-tune via Layout Editor if needed (rarely necessary)

**Current Production Values (LOCKED - May 12, 2026):**
```swift
// Ednar (in PotionShopLayoutConfig.swift)
ednarBaseScale: 0.15     // Base scale (makes 1536×1024 visible)
ednarWidth: 1.0          // Width multiplier (no distortion)
ednarHeight: 1.0         // Height multiplier (no distortion)
ednarX: 0.0              // X offset (centered)
ednarY: 0.0              // Y offset (centered)

// Customers (in PotionShopLayoutConfig.swift)
customerSceneBaseScale: 2.0  // Base scale (compensates for queue depth)

// All 14 characters default to:
width: 1.0, height: 1.0      // Active position (no distortion)
waitingWidth: 0.8, waitingHeight: 0.8  // Waiting position (80% size for depth)
x: 0.0, y: 0.0               // Centered (no offset)
```

**Historical Note:**
- **May 10, 2026:** Character defaults were 1.6×2.0× (distorted aspect ratio)
- **May 12, 2026:** Reset to 1.0×1.0× (pixel-accurate, no distortion)
- **Reason:** User wanted to upload images and have them appear correctly sized without manual adjustment
- **Result:** System now works as intended - draw at correct proportions, upload, done! ✨

### 16.2 Customer Scene Portraits - Asset Naming Convention

**Profile portraits** (head closeups for profile buttons): Use character ID only
- `mildred.png`, `tomik.png`, `greta.png`, etc.

**Scene portraits** (full-body for customer scene): Use character ID + `_scene` suffix
- `mildred_scene.png`, `tomik_scene.png`, `greta_scene.png`, etc.

### 16.3 Integrated Customer Scene Portraits (Status: May 10, 2026)

| Character    | Profile Asset   | Scene Asset         | Status        |
|--------------|-----------------|---------------------|---------------|
| Mildred      | `mildred`       | `mildred_scene`     | ✅ INTEGRATED |
| Tomik        | `tomik`         | `tomik_scene`       | ✅ INTEGRATED |
| Greta        | `greta`         | `greta_scene`       | ✅ INTEGRATED |
| Sister Halla | `sister_halla`  | `sister_halla_scene`| ✅ INTEGRATED |
| Wendelina    | `wendelina`     | `wendelina_scene`   | ✅ INTEGRATED |
| Grimdrek     | `grimdrek`      | `grimdrek_scene`    | ✅ INTEGRATED |
| Hexa Mott    | `hexa_mott`     | `hexa_mott_scene`   | ✅ INTEGRATED |
| Pemberton    | `pemberton`     | `pemberton_scene`   | ✅ INTEGRATED |
| Ardo         | `ardo`          | `ardo_scene`        | ✅ INTEGRATED |
| Bram         | `bram`          | `bram_scene`        | ✅ INTEGRATED |
| Crispin      | `crispin`       | `crispin_scene`     | ✅ INTEGRATED |
| Ironhilde    | `ironhilde`     | `ironhilde_scene`   | ✅ INTEGRATED |
| Carmilla     | `carmilla`      | `carmilla_scene`    | ✅ INTEGRATED |
| Royal Envoy  | `royal_envoy`   | `royal_envoy_scene` | ✅ INTEGRATED |

**All 14 Characters Now Integrated:**
- ✅ All have `scenePortrait` field using proper `_scene` nomenclature
- ✅ All have config entries in `PotionShopLayoutConfig.perCharacterScales`
- ✅ All appear in layout editor character picker dropdown
- ✅ All have default active scale (**1.0×1.0× - NO DISTORTION** as of May 12, 2026)
- ✅ All have default waiting scale (0.8×0.8× - creates depth effect)
- ✅ All support active/waiting position system with smooth transitions

**Per-Character Scaling System:**
- Each character has independent width/height/x/y values in `PotionShopLayoutConfig.swift`
- **Active values** used when character is at `queue[0]` (front of line)
- **Waiting values** used when character is at `queue[1+]` (back of line)
- **Default active: 1.0×1.0×** (pixel-accurate, no distortion - May 12, 2026 update)
- **Default waiting: 0.8×0.8×** (80% of active size for depth effect)
- Adjusted via Layout Editor → 🧍 Customers section → Character picker dropdown
- Values can be locked in config after tuning for each character (rarely needed now)

### 16.4 Original Art Asset Spec (Profile Portraits & Other Assets)

| Category               | Count | Procreate canvas | Notes                                                    |
|------------------------|-------|------------------|----------------------------------------------------------|
| Character profile portraits | 14 | 1024×1024 px @ 300 DPI | Head closeups for profile buttons. Square; circular crop in-game. Transparent BG. |
| Character scene portraits | 14 | 1536×1024 px @ 300 DPI | Full-body for customer scene. 3:2 landscape ratio. Transparent BG. Uses `_scene` suffix. **ALL 14 NOW INTEGRATED!** |
| Ednar expressions      | 5     | 1024×1536 px @ 300 DPI | calm / focused / concerned / alarmed / satisfied — same body, different face |
| Cauldron (layered)     | 3     | 2048×1536 px @ 300 DPI | back / liquid / front — single Procreate file, exported as 3 PNGs |
| Dice (flat-faced)      | 5     | 512×512 px @ 300 DPI   | potency / stability / boost / heal / shield. Center 30% kept BLANK (runtime renders the number on top) |
| Background             | 1     | 1242×2688 px @ 300 DPI | Full-screen iPhone Pro Max. Shop interior, top→bottom zones described in §16.7 |
| UI icons               | 6     | 256×256 px @ 300 DPI   | heart, shield, potion, brew sign, hamburger, etc.       |
| **TOTAL v1**           | **47**|                  | (14 profiles + 14 scenes + 5 Ednar + 3 cauldron + 5 dice + 1 bg + 6 icons) - **All characters integrated!** |

### 16.5 Procreate export rules
- Format: PNG
- Background: **transparent** — user must toggle off the bottom "Background" layer in Procreate before File → Share → PNG, otherwise the export has a white background
- Color profile: sRGB or Display P3
- Workflow for layered files (Ednar expressions, cauldron): one Procreate file with all variants on toggleable layers; show only the relevant layer per export

### 16.3 Filename list (case-sensitive, exact)
```
mildred.png, tomik.png, greta.png, pemberton.png, sister_halla.png,
ardo.png, wendelina.png, bram.png, crispin.png, hexa_mott.png,
ironhilde.png, grimdrek.png, carmilla.png, royal_envoy.png,

ednar_calm.png, ednar_focused.png, ednar_concerned.png,
ednar_alarmed.png, ednar_satisfied.png,

cauldron_back.png, cauldron_liquid.png, cauldron_front.png,

die_potency.png, die_stability.png, die_boost.png, die_heal.png, die_shield.png,

customerbg.png,    ← Customer scene background (✅ INTEGRATED May 5, 2026)

icon_heart.png, icon_shield.png, icon_potion.png, icon_brew_sign.png,
icon_hamburger.png, icon_gear.png
```

### 16.3.1 Customer Background Integration (✅ COMPLETE - May 5, 2026)

**Asset:** `customerbg.png`  
**Location in code:** `PotionShopCustomerSceneView.swift` → `backgroundLayer(geo:)`  
**Implementation:** Uses `UIImage(named: "customerbg")` with `.scaledToFit()` scaling  
**Layer order:**
1. **Gradient** (bottom) - Tan/cream fallback, always present
2. **customerbg** (above gradient) - User's sketch background
3. **Floor line** (brown rectangle at bottom)
4. **Ednar** (wizard character on left)
5. **Customers** (characters on right)
6. **Shield badge** (if player has shield)

**Scaling behavior:**
- `.scaledToFit()` maintains aspect ratio
- Shows entire image without cropping
- May show gradient at edges if aspect ratio doesn't match scene area
- Gradient acts as underlay/fallback

**Code location:**
```swift
// PotionShopCustomerSceneView.swift, line ~170
if let backgroundImage = UIImage(named: "customerbg") {
    Image(uiImage: backgroundImage)
        .resizable()
        .scaledToFit()
        .frame(width: geo.size.width, height: geo.size.height)
}
```

### 16.4 Background composition zones (1242×2688 canvas)
| Y range (px)    | Zone                          | Composition guidance                                  |
|-----------------|-------------------------------|-------------------------------------------------------|
| 0–360           | Header strip                  | Dark/light contrast neutral. UI overlays here.        |
| 360–960         | Customer scene                | Shop interior — wooden walls, shelves behind Ednar (left third), hint of door / window light (right). Customers stand on the right two-thirds. |
| 960–1100        | Profile button row            | Solid neutral. No clutter.                            |
| 1100–2200       | Cauldron area                 | Empty floor / table / Ednar's workspace. Hanging herbs OK in upper edges. Cauldron art layers on top. |
| 2200–2688       | Dice tray area                | Wooden counter / table edge. Subtle texture.          |

### 16.5 Dice rules (drawing)
- **Flat-faced** (top-down view), not 3/4 — animation is pure 2D, no faux-3D needed
- Center 30% kept BLANK — runtime renders the face value (1–6) as text
- Strong color identity: POT red, STB blue, BST purple, HEAL green, SHD teal
- Optional icon in upper-left or top edge: POT flame, STB anchor, BST starburst, HEAL heart, SHD shield outline
- Drop animation parameters (in code, not art): drop from -80pt above with spring bounce, **no rotation**, simultaneous deal of all 5

### 16.6 Ednar expression triggers
| Expression       | When it shows                                                       |
|------------------|---------------------------------------------------------------------|
| ednar_calm       | Default. Composure ≥ 70%. No incoming damage.                       |
| ednar_focused    | Mid-brew (player has dice placed, hasn't tapped BREW yet)           |
| ednar_concerned  | Composure 30–70%, or shield breaks                                  |
| ednar_alarmed    | Composure < 30%                                                     |
| ednar_satisfied  | A customer was just defeated (potion delivered)                     |

Same body pose across all 5; only face changes. Easiest workflow: draw base body once in Procreate, duplicate, modify face per file.

### 16.7 Cauldron layer rules
- Three Procreate group layers in ONE file at 2048×1536, exported separately
- Render z-order: cauldron_back → cauldron_liquid → 12 nodes (with placed dice) → cauldron_front
- Liquid layer should have a clean upper edge (the surface line). Front layer's rim overlaps that edge slightly so there's no visible seam.

### 16.8 Asset catalog vs raw files
**Use the asset catalog.** Drag PNGs into `Assets.xcassets` with @1x/@2x/@3x slots. Load via `Image("mildred")`. Don't use raw PNGs in folder.

### 16.9 Placeholder workflow
While drawing, drop a gray PNG at correct dimensions with a label (e.g., a 1024×1024 gray square with "MILDRED" text) into the asset catalog with the final filename. When the real art is ready, replace the file with the same name. No code changes.

---

## 17. ANIMATION TUNING REFERENCE (BREW_ANIMATION_DOC.md companion)

Every animation timing lives in `PotionShopBrewAnimator.swift`. Edit one number, rebuild, see the change. The user is an animator; this is intentional.

**Quick tuning targets:**
- "Brew is too slow" → reduce `brewDamageDuration` (0.50 → 0.35) and `activeAttackDuration` (0.50 → 0.35). Saves ~0.3s per brew.
- "Shake too subtle" → `shakeAmplitude: 6 → 10`
- "Shake too aggressive" → `shakeAmplitude: 6 → 4`
- "Floating numbers don't drift enough" → `floatRiseDistance: 50 → 80`
- "Floaters disappear too fast" → `floatDuration: 0.7 → 1.0`
- "Composure flash too short" → `composureFlashDuration: 0.25 → 0.4`
- "Customer leaves too slowly when expired" → `customerSlideOutDuration: 0.55 → 0.35`

**Floating-number positions** (hardcoded in `PotionShopGameState.swift`):
- `ednarOriginPoint` — where heal floaters appear
- `ednarShieldPoint` — where shield floaters appear
- `activeCustomerPoint` — where brew-damage floaters appear

If numbers appear in the wrong screen position, those are the values to tweak. They use absolute CGPoint and are tuned for typical iPhone screen size — may need adjustment if iPad or different size class.

---

## 18. KNOWN REGRESSIONS / TRADEOFFS

| # | Item                                          | Status / mitigation                                                              |
|---|-----------------------------------------------|----------------------------------------------------------------------------------|
| 1 | Reach preview only works on desktop hover     | Mobile users see no preview. Needs a tap-and-hold or auto-show-on-select. v2.    |
| 2 | Bag/discard not visualized                    | Mechanic works but invisible. v2.                                                |
| 3 | Stability dice possibly underused             | At 80% efficiency, players may always favor Potency. Watch in playtest.           |
| 4 | Loud trait stubbed                            | "Focus" not defined; needs design discussion before Phase 9.                     |
| 5 | Hexer trait stubbed                           | Mechanic well-defined; just needs implementation.                                 |
| 6 | Tier 4/5 combat numbers untested              | Playtest Day 1 fully, then revisit Sister Halla, Bram, Hexa Mott, Ironhilde, Grimdrek, Carmilla, Royal Envoy. |
| 7 | No save state                                 | Closing the app loses progress. Add when streak mode ships.                       |
| 8 | iPad layout untested                          | iPhone only for v1.                                                               |
| 9 | All art is placeholder                        | Replace via asset catalog when Procreate files are ready.                         |

---

## 19. BUILD / RUNTIME REQUIREMENTS

- **iOS deployment target:** iOS 17+ (uses `@Observable` macro from Swift 5.9)
- **Required imports:**
  - `import SwiftUI` everywhere
  - `import Combine` in `PotionShopGameView.swift` (for `Timer.publish(...).autoconnect()`)
- **Concurrency:** `doBrew()` is `@MainActor async`. Callers MUST use `Task { @MainActor in await gs.doBrew() }`.
- **Project file:** new files go into the `PotionShop/` group in Xcode. Right-click group → Add Files… → check "Copy items if needed" → check the OverQuestMatch3 target.

---

## 20. HOW TO CONTINUE WORK IN A NEW CHAT

When starting a fresh session with Claude in Xcode:

1. Upload (or have already-attached) these files:
   - `MASTER_CONTEXT.md`
   - `CAULDRON_CONTEXT.md` (this file)
   - All 9 Swift files in `PotionShop/`
   - The two edited shared files: `OverQuestMatch3App.swift`, `GameSelectorView.swift`
   - Optionally: `BREW_ANIMATION_DOC.md` if you have it

2. Paste this prompt:
   > Read the files attached IN ORDER. CAULDRON_CONTEXT.md is the single source of truth for Ednar's Potion Cauldron — it covers folder structure, naming conventions, locked decisions, all 14 customers and 8 traits, the combat model, animation tuning, and pending phases. Read it first. Then tell me what state you understand the project to be in, and ask what I want to work on next. Critical requirements (DO NOT VIOLATE): I do not know how to code. Provide ONLY complete, copy-pasteable code (never snippets) using str_replace_based_edit_tool. Ask clarifying questions instead of making assumptions. Never break existing functionality. Always update MASTER_CONTEXT.md and CAULDRON_CONTEXT.md after structural changes. Test instructions must be beginner-friendly. Every new struct/view/modifier must be prefixed `PotionShop` to avoid collisions with other games.

3. Pick the next phase from §14 ("WHAT'S PENDING") and tell Claude which one.

---

## 21. QUICK-EDIT REFERENCE TABLE

| Want to do…                                            | Edit this file                                       |
|--------------------------------------------------------|------------------------------------------------------|
| Tune a customer's HP / attack / patience                | `PotionShopData.swift`                               |
| Add a new customer                                      | `PotionShopData.swift` (in `allCharacters`)          |
| Add a new trait                                         | `PotionShopData.swift` (in `allTraits`)              |
| Change Day 1's round structure                          | `PotionShopData.swift` (in `day1`)                   |
| Disable the +5 composure rest                           | `PotionShopData.swift` → `COMPOSURE_REST_BETWEEN_ROUNDS = 0` |
| Change MAX_PLACEMENTS_PER_BREW                          | `PotionShopData.swift`                               |
| Tune any animation timing                               | `PotionShopBrewAnimator.swift`                       |
| Change floating-number font                             | `PotionShopBrewAnimator.swift` → `numberFont(size:)` |
| Change cauldron bowl shape / size                       | `PotionShopCauldronView.swift` → `PotionShopCauldronGeometry` |
| Change customer queue X positions                       | `PotionShopCustomerSceneView.swift` → `queueXFractions` |
| Change vertical section heights                         | `PotionShopGameView.swift` (GeometryReader fractions)|
| Add a debug action                                      | `PotionShopDebugMenu.swift` + matching method on `PotionShopGameState` |
| Swap a placeholder asset for real art                   | drop PNG into `Assets.xcassets`, change `iconFallback` emoji to `Image("name")` |
| Implement Hexer trait                                   | `PotionShopGameState.swift` → add a phase between patience-tick and expirations in `doBrew()` |

---

**End of CAULDRON_CONTEXT.md**
