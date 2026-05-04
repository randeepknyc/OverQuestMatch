# CAULDRON_CONTEXT.md
**Ednar's Potion Cauldron — Full Project Context**

> **Last Updated:** May 4, 2026  
> **Status:** Phase 7+ complete. Game is playable end-to-end for Day 1. **Drag-and-drop dice placement implemented.** Layout fully tuned. Art assets pending.  
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

Always available in v1. Will be moved behind a `GameConfig.enableDebugMenu` toggle for App Store builds (deferred — see §17).

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

## 16. ART ASSETS — 34 PNGs (LOCKED SPEC)

The user is drawing all art in **Procreate on iPad**. Naming and dimensions below are final (changeable per-file later if needed; user said "I may rename, but the spec is fine for now").

### 16.1 Asset list with Procreate canvas sizes

| Category               | Count | Procreate canvas | Notes                                                    |
|------------------------|-------|------------------|----------------------------------------------------------|
| Character portraits    | 14    | 1024×1024 px @ 300 DPI | One per customer. Square; circular crop in-game. Transparent BG. |
| Ednar expressions      | 5     | 1024×1536 px @ 300 DPI | calm / focused / concerned / alarmed / satisfied — same body, different face |
| Cauldron (layered)     | 3     | 2048×1536 px @ 300 DPI | back / liquid / front — single Procreate file, exported as 3 PNGs |
| Dice (flat-faced)      | 5     | 512×512 px @ 300 DPI   | potency / stability / boost / heal / shield. Center 30% kept BLANK (runtime renders the number on top) |
| Background             | 1     | 1242×2688 px @ 300 DPI | Full-screen iPhone Pro Max. Shop interior, top→bottom zones described in §16.4 |
| UI icons               | 6     | 256×256 px @ 300 DPI   | heart, shield, potion, brew sign, hamburger, etc.       |
| **TOTAL v1**           | **34**|                  |                                                          |

### 16.2 Procreate export rules
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

background.png,

icon_heart.png, icon_shield.png, icon_potion.png, icon_brew_sign.png,
icon_hamburger.png, icon_gear.png
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
