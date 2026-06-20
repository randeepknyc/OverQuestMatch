# CAULDRON_CONTEXT.md
**Ednar's Potion Cauldron — Full Project Context**

> **Last Updated:** June 10, 2026 — Big additions since May 25: feet-anchor mode for Day 3 R2, 18-cell bucket×slot size matrix, per-cell sparse overrides for character size+X+Y, two-tier HP badge override system (HxW shared + per-slot), focused per-slot editor in the layout overlay, AND a real 3D dice slot-machine spin (SceneKit) gated to Day 2 R2 with custom face textures, motion blur, per-die stagger, and a floating test SPIN button. See **§26** for the full block of post-May-25 work. Earlier (May 25 PM) Day 3 flex-day RNG test, §25. May 25 AM: art template floor shifted to y=1500, §24. May 24 eve: badge body-follow + waiting2 overrides, §23.17.
> **Status:** Phase 7 complete + partial Phase 8. Game is playable end-to-end for Day 1 → Day 2 → Day 3. Art assets pending. Day 2 R2 now visually demonstrates 3D-cube dice with placeholder textures from Assets.xcassets (`die_face_1`…`die_face_6`).
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

**v1 ships Day 1 and Day 2.** Day 3, randomized days, and a "streak-based win" mode are planned but explicitly deferred. See §17.

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

### 4.3b Day 2 round structure (curated — added 2026-05-23)

Day 2 introduces all 5 previously-unused characters (Sister Halla, Bram, Hexa Mott, Ironhilde, Carmilla) plus the Royal Envoy as the boss, with 3 Day 1 repeats (Mildred, Ardo) filling out the lineup. Curated, not random — the "random Day 2" plan in the original design (§4.4 below) was set aside.

| Round     | Customers                                       | Notes                                                              |
|-----------|-------------------------------------------------|--------------------------------------------------------------------|
| Morning   | Sister Halla + Mildred                          | Sister Halla (new, pious) eases the player into Day 2              |
| Afternoon | Bram + Lady Carmilla                            | Two new characters, Carmilla brings tier-5 HP early                |
| Evening   | Hexa Mott + Ironhilde + Ardo                    | Two new tier-4 heavy hitters + Ardo (skittish, faster patience)   |
| Night     | The Royal Envoy                                 | Boss — intimidating (+2 brew target while active), HP 34           |

**End-of-Day-1 flow:** Beating Day 1 Night now shows the overlay "Success, Day Complete!" with button "**Re-open shop tomorrow**" → advances to Day 2 Morning (via `gs.advanceDay()`). Beating Day 2 Night shows the same overlay with button "Restart" (since Day 3 doesn't exist yet) → calls `resetGame()`.

Composure carry-over between days uses `PotionShopConfig.composureRestBetweenDays`.

**Boss assignment shift:** §4.4 originally designated Royal Envoy as the Day 3 boss. He's now the Day 2 boss. When Day 3 is eventually built, it'll need a different boss design.

### 4.4 Day 3 — DESIGNED, NOT BUILT
- Day 3 was originally templated as hybrid (procedural mornings, hand-picked Evening set-piece, fixed Royal Envoy night). With Royal Envoy now in Day 2, Day 3 needs a fresh boss concept.
- Templates exist on paper; **NOT wired into Swift.** See §17.

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

### 6.8 Drag-and-drop dice placement (May 22, 2026 - FULLY WORKING)

**Status:** ✅ FULLY IMPLEMENTED (including node-to-node drag with NO FADE!)

The game supports **three methods** for placing and moving dice on nodes:

#### **Method 1: Tap-select-then-tap-node (original)**
1. Tap a die in the tray → yellow border appears (selected)
2. Tap an empty node → die slides to that node
3. Tap the placed die → slides back to tray

#### **Method 2: Drag-and-drop from tray to node**
1. Touch and drag a die from the tray
2. Die follows your finger with 15% scale increase + colored glow shadow
3. Empty nodes glow as you drag over them
4. Release over an empty node → die slides smoothly to node center
5. Release outside nodes → die springs back to tray

#### **Method 3: Drag-and-drop from node to node (May 22, 2026)** ✨
1. Touch and drag a die that's already placed on a node
2. During drag:
   - **Ghost die** appears at source node (30% opacity)
   - **Floating die** follows your finger (115% scale + colored glow)
   - **Source node** stays visible (doesn't disappear)
   - **Target nodes glow** when you hover over them (cyan reach preview!)
3. Release over an empty node:
   - Die **instantly moves** in data model (no animation wrapper)
   - `matchedGeometryEffect` **smoothly slides** die from source to target
   - **No fade animation** (instant data update lets SwiftUI animate cleanly)
4. Release over occupied node or outside:
   - Die **springs back** to source node

**⚠️ CRITICAL: Node-to-node animation fix (May 22, 2026):**
The fade animation bug was caused by wrapping the data model change in `withAnimation`. This competed with `matchedGeometryEffect`.

**CORRECT pattern (no fade):**
```swift
if canDrop, let target = targetNodeId {
    // Move die INSTANTLY (no withAnimation wrapper)
    gs.placements[nodeIndex] = nil
    gs.placements[target] = die
    
    // Clean up instantly
    gs.nodeDragLocation = nil
    isDraggingFromHere = false
}
```

**WRONG pattern (causes fade):**
```swift
if canDrop, let target = targetNodeId {
    withAnimation {  // ← Don't do this!
        gs.placements[nodeIndex] = nil
        gs.placements[target] = die
    }
}
```

**Why this works:**
- ✅ Data model updates **instantly** (no animation)
- ✅ `matchedGeometryEffect` sees die at target node only
- ✅ SwiftUI animates die **sliding to target** (smooth!)
- ✅ No competing animations = no fade

**Technical implementation:**
- **Gesture:** `DragGesture(coordinateSpace: .global)` on placed dice
- **Ghost die system:** Source node shows 30% opacity copy during drag
- **Floating die:** Cauldron top layer renders dragging die at `zIndex: 1000`
- **Position tracking:** Nodes register global `CGRect` positions
- **Hit detection:** `findNodeAtPosition(_:)` checks drop location
- **Hover state:** `updateDragHoverPosition(_:)` updates cyan glow preview
- **Animation:** `matchedGeometryEffect(id: die.id, in: diceFlight)` handles slide

**State management:**
- `draggedDie: PotionShopDie?` - The die being dragged
- `draggedFromNode: Int?` - Source node for node-to-node moves
- `nodeDragLocation: CGPoint?` - Current drag position (for floating die)
- `hoveredNodeIndex: Int?` - Which node is hovered during drag
- `nodePositions: [Int: CGRect]` - Global positions of all nodes

**See also:** `NODE_TO_NODE_DRAG_SESSION.md` for complete implementation history and troubleshooting.

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

### 7.2 Key methods
- `tapProfile(customerId:)` — the queue swap. **DO NOT redesign this.** It took 8 attempts in the chat to get right. See §10 for the rule.
- `selectDie(handIndex:)` / `placeDie(nodeId:)` / `unplaceDie(nodeId:)`
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

## 8. LAYOUT (LOCKED PROPORTIONS)

The layout is driven by `GeometryReader` in `PotionShopGameView.swift`, with vertical sections allocated as fractions of the available play area. This was iterated repeatedly to match the web artifact mockup we built in earlier sessions.

### 8.1 Vertical section heights
| Section                    | Fraction of play area | Why                                        |
|----------------------------|-----------------------|--------------------------------------------|
| Header                     | ~6%                   | slim chrome, composure bar + day/round + gear |
| Customer scene (hero)      | ~38%                  | the visual focus; Ednar + customer line    |
| Profile row + inspect strip| ~12%                  | inspect strip overlays in place when shown |
| Cauldron + BREW            | ~30%                  | the tool; not the focal point              |
| Brew preview bar           | ~4%                   | small status strip above tray              |
| Dice tray                  | ~10%                  | bottom edge                                |

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
- **Layers (in z-order, bottom to top):** bowl back (dark fill) → liquid surface (green ellipse) → 12 nodes → optional foreground rim → BREW sign on a tilted wooden post.

### 8.5 BREW button (placeholder)
Wooden brown sign with carved-style "BREW" text, tilted ~12°, on a vertical post going down toward the cauldron. **It is a placeholder.** The user will replace it with their own art (likely a real ladle dipping into the green liquid). Don't waste effort tuning placeholder pixels — the final position will be dictated by the art.

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

| Action                  | What it does                                                 |
|-------------------------|--------------------------------------------------------------|
| End Game                | Dismisses the game, returns to Game Selector                 |
| Skip to Day & Round     | Collapsible **Day 1** / **Day 2** disclosure groups (auto-iterates `PotionShopData.allDays`, so a future Day 3 will appear automatically). Each day expands to Round 1–4 buttons that jump straight to that day + round and reset composure/customers. |
| Layout Editor (Overlay) | Opens the live layout overlay; the dim background uses `.allowsHitTesting(false)` so the game underneath stays interactive. Close via X button at top of panel. |
| Reset Round             | Re-spawn current round from scratch                          |
| Reset Game              | Back to Day 1 Morning                                        |
| Heal to Full            | composure → 30, shield → 0                                   |
| Win Round               | Defeat all current customers instantly (test round-end overlay) |
| Lose Game               | composure → 0 (test lose overlay)                            |

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
| 8a    | Day-advancement flow                 | ✅     | `advanceDay()` actually advances `dayId`; `.dayWon` overlay shows "Success, Day Complete!" with "Re-open shop tomorrow" button (or "Restart" if it's the last day). Helpers `PotionShopData.nextDayId(after:)` and `isLastDay(_:)` |
| 8b    | Day 2 wired up (May 23, 2026)        | ✅     | Day 2 added as curated round structure — see §4.3b. Boss = Royal Envoy. `PotionShopData.allDays = [day1, day2]`. Debug menu auto-iterates allDays. |
| 8c    | Per-character waiting badge overrides | ✅    | 6 new optional `waiting*` fields on `CharacterScale`; all 6 badge lookups take `isWaiting: Bool = false`; Customers tab in Layout Editor has waiting sliders; clipboard export includes them. See §23.14. |
| 8d    | Badge head-anchor Fix A (May 24)      | ✅    | When a character is in any waiting slot, the head-anchor calc uses unified `customerWaiting*` dims (not slot-specific). Body keeps its slot-specific scale; only the badge anchor is unified. Makes "Share" mode visually consistent across waiting1/waiting2. See §23.16. |
| 8e    | Layout overlay click-through         | ✅     | `Color.black.opacity(0.2)` background now has `.allowsHitTesting(false)`; the spacer above the floating panel also. Game underneath is interactable while tuning. Close via X button. |

---

## 14. WHAT'S PENDING (NEXT STEPS)

### 14.1 Phase 8 — Round-end / Day-end / Lose overlays (PARTIAL — day-advancement done, polish remaining)
The **day-advancement flow** is now wired (May 23–24, 2026): beating Day 1 Night shows "Success, Day Complete!" with "Re-open shop tomorrow" button → advances to Day 2. Beating Day 2 Night shows the same title with "Restart" button. See §4.3b for the flow.

What's STILL needed for full Phase 8:
- **Richer Round complete overlay:** which customers were defeated, composure remaining (current is just "Round Complete / Continue")
- **Richer Day complete overlay:** full summary panel instead of the placeholder
- **Lose overlay:** "You Collapsed" message currently uses placeholder. Needs "Try Again" (restart current round) and "End Game" buttons; the current single button restarts the whole game
- **Boss-defeat flourish** on Night rounds (light effect, not over-engineered)

### 14.2 Phase 9 — Trait stub implementation
- **Loud (Bram):** while Bram is in the queue (and not active), reduce the player's "focus" by 1. **NOTE:** "focus" is not yet a defined mechanic in this codebase — needs design clarification before coding. Possible interpretations: -1 to all dice in hand while loud is waiting, or a separate visible "focus" stat. ASK the user before implementing.
- **Hexer (Hexa Mott, Carmilla):** each turn the customer waits, one random die in the player's current hand rerolls to its lowest face. Mechanic is well-defined; needs to fire during a turn-end phase, probably between phase 5 (patience ticks) and phase 6 (expirations).

### 14.3 Phase 10 — Day 3 (procedural rounds)
Day 2 is **done** (curated, not procedural — see §4.3b). Day 3 is still future work. Note Royal Envoy was originally the Day 3 boss in the design doc but has been moved to Day 2; Day 3 needs a new boss concept.

If Day 3 ends up procedural, wiring it in requires:
- A round-builder function that takes `min/max difficulty + must_include_tag + required_trait + exclude_ids` and returns a customer list
- "Day N" indicator in the header (currently shows "Day 1" / "Day 2" via `gs.dayId`)
- Day-advancement already works via `gs.advanceDay()` — no flow changes needed, just data

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
| 13 | Day 3+ multi-day progression / unlocks            | Day 1 and Day 2 wired. Tier system in code is dormant; will activate when Day 3+ ships |
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

potion_node.png,

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

### 16.5.1 Node socket rules (drawing)
The `potion_node.png` asset is the empty cauldron slot art. Draw rules:
- **Square canvas** (e.g., 256×256 or 512×512), transparent background
- The actual socket shape lives in the center; **leave ~20% transparent padding around the edges** so the glow has room to bleed out beyond the visible art
- Should read as an "empty socket" or "rune frame" — a die will be drawn inside it at ~78% of its size, so the inner well should be just slightly larger than what a die looks like
- The glow color comes from the code (yellow/cyan/die-color), so the socket art itself should be **neutral / desaturated** — anything strongly colored will clash with the glow tint
- If unsure, look at Die in the Dungeon's socket frames for reference

If the asset isn't present, the code falls back to a parchment-colored rounded rectangle so the game still runs while you draw.

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
| 1 | ~~Reach preview only works on desktop hover~~ | **RESOLVED (May 22, 2026):** preview glow now triggers during drag-hover on mobile. See §22. |
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
| Change which nodes a die affects (reach rules)          | `PotionShopModels.swift` → `PotionShopDieRules.affectedNodes` |
| Change node socket art                                   | replace `potion_node.png` in `Assets.xcassets`       |
| Tune node glow colors / intensity                       | `PotionShopCauldronView.swift` → `PotionShopNodeButtonView` → `glowColor` / `glowRadius` / `glowOpacity` |
| Change base die size (tray)                             | `PotionShopCauldronView.swift` → `PotionShopCauldronLayout.dieSize` (default 44) |
| Change base node size                                   | `PotionShopCauldronView.swift` → `PotionShopCauldronLayout.nodeVisible` (default 26) |
| Change node touch-target size                           | `PotionShopCauldronView.swift` → `PotionShopCauldronLayout.nodeHitArea` (default 36) |
| Change how big a placed die is INSIDE a node socket     | `PotionShopCauldronView.swift` → `PotionShopNodeButtonView`, the `* 0.78` multiplier (smaller = more frame shows) |
| Runtime dice/node scale (already in Layout Editor)      | `dieScale` / `nodeScale` in `PotionShopLayoutConfig.swift` (or via Layout Editor sliders) |

---

## 22. NODE GLOW & DIE REACH SYSTEM (Session May 22, 2026)

This section documents the cauldron interaction layer: how nodes look, how they glow, how the die-reach preview works, and where every tunable lives. It replaces the older grow/shrink scale system. **Read this if you want to change how dice interact with the board, change which nodes a die affects, or restyle the glow.**

### 22.1 What changed in this session
| Before | After |
|--------|-------|
| Empty node = parchment rectangle. Disappears when a die is placed. | Node art is **always visible** (your `potion_node.png`) — the die sits on top of it like a socket. |
| Hover state = node *grows* 15%. | Hover state = node *glows*. No size change. |
| Die-reach math was embedded inside `computeBrew()` only. | Reach rules now live in one struct (`PotionShopDieRules`) shared by both brew math and the preview glow. |
| No preview of "which nodes will this die affect?" before placement. | Die-in-the-Dungeon-style: dragging a die over a target makes affected nodes **glow cyan**. |
| Die was the same size as the node frame, so the frame never "showed". | Placed die is 78% of node size, so your `potion_node.png` shows as a frame around it. |
| Drag gestures lived on the die view only — small hit area → "stuck dice" feel. | Drag/tap gestures live on the whole node area → entire node is grabbable. |

### 22.2 The four glow states
Defined in `PotionShopNodeButtonView` inside `PotionShopCauldronView.swift`. Priority is top-down — the highest match wins.

| State            | When                                                      | Default color           | Default radius |
|------------------|-----------------------------------------------------------|-------------------------|----------------|
| Hovered target   | Empty node, you're dragging a die over it                 | Bright yellow           | 20             |
| Tap candidate    | Empty node, a die is selected from the tray (tap mode)    | Soft yellow             | 12             |
| In reach preview | Empty node, within the dragged die's reach                | Cyan                    | 14             |
| Locked-in        | Has a die placed                                          | Die's own type color    | 9              |
| (none)           | Default                                                   | Transparent             | 0              |

### 22.3 The die-reach rules (THE most important tuning knob)
File: **`PotionShopModels.swift`**, struct **`PotionShopDieRules`** at the bottom.

This is the **single source of truth** for "which nodes does this die affect?" — used both by the preview glow AND the brew math. Change it once, both systems update.

Each of the 5 die types (potency, stability, boost, heal, shield) has its own block. Each block returns a `[Int]` of node indices.

**Default for all five types:** `PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)` — nodes within `value` graph hops.

**Common edits the file shows examples for:**
- "Heal dice are self-only" → return `[]` in the `.heal` case
- "Boost only affects immediate neighbors regardless of value" → `hops: 1` in the `.boost` case
- "Boost is always 2 hops" → `hops: 2`
- Hard-coded patterns (e.g., always corners) → return `[0, 1, 8, 11].filter { $0 != nodeIndex }`
- Position-dependent reach → branch on `nodeIndex` inside the case

Returning invalid indices or the die's own index never crashes — the brew loop and preview both ignore them.

### 22.4 Size tuning knobs (cheat sheet)
There are **three layers of scale**. They multiply together. If something looks too big or too small, figure out which layer is wrong before changing numbers.

```
final visible size  =  base constant  ×  runtime scale  ×  fine-tuning multiplier
                       (in code)         (Layout Editor)    (e.g. the 0.78 for placed dice)
```

#### Base constants (in `PotionShopCauldronLayout` at the top of `PotionShopCauldronView.swift`)
| Constant         | Default | What it controls                                              |
|------------------|--------:|---------------------------------------------------------------|
| `dieSize`        |      44 | Size of dice **in the tray** (pre-runtime-scale)              |
| `nodeVisible`    |      26 | Size of the node socket art / locked-in die slot              |
| `nodeHitArea`    |      36 | Invisible touchable area around each node (bigger = more forgiving taps) |

These are starting points. Don't change them unless you've tried adjusting runtime scale first.

#### Runtime scales (already saved in your Layout Editor)
| Field            | Where                                | What it does                                        |
|------------------|--------------------------------------|-----------------------------------------------------|
| `dieScale`       | Layout Editor → "🎲 Dice & Tray"     | Multiplies every tray die's visible size            |
| `nodeScale`      | Layout Editor → "🔵 Nodes"           | Multiplies every node's visible AND touchable size  |

Your current values: `dieScale ≈ 1.41`, `nodeScale ≈ 1.83`.

#### Fine-tuning multiplier (the one most people miss)
File: `PotionShopCauldronView.swift`, in `PotionShopNodeButtonView`, the line:
```swift
PotionShopPlacedDieView(die: die, visualScale: visualScale * 0.78)
```
That **`0.78`** controls how big the die looks **inside its socket**. Lower = more node frame shows around the die. Higher = die fills the socket. Two places in the function (one for ghosted, one for locked-in); change both to the same value.

| Value | Look |
|-------|------|
| 0.60  | Tiny die, large empty frame around it (very "socket" feel) |
| 0.78  | Default. Frame visible as a ring. |
| 0.90  | Die fills most of the socket. Frame is just a thin border. |
| 1.00  | Die fills the entire socket. Frame not visible — equivalent to the old behavior. |

The touch area (drag/tap) is **the full `nodeHitArea`**, independent of how big the die looks. Shrinking the die visually doesn't make it harder to grab.

### 22.5 Glow color tuning
Same file, same struct. Find the three properties:
```swift
private var glowColor: Color { ... }
private var glowRadius: CGFloat { ... }
private var glowOpacity: Double { ... }
```
Each is a chain of `if` statements with one return value per state. Change the colors / numbers in any branch.

**Examples:**
- Want preview to be magical purple instead of cyan? Change the cyan RGB in the `isInPreview` branch of `glowColor` to `Color(red: 0.65, green: 0.45, blue: 1.00)`.
- Want stronger glow when locked-in? Bump `placedDie != nil` branch of `glowRadius` from 9 to 14.
- Want all dice to glow the same color when locked-in (not their type color)? In `glowColor`, change `return die.type.color` to a fixed color like `Color.orange`.

### 22.6 How drag + tap routing works (so you don't break it)
The whole `nodeHitArea` (~36pt × nodeScale) is one interactive zone with two gestures:

- `.onTapGesture` — fires on a tap with no movement.
   - If node has a die: removes the die back to the tray.
   - If node is empty: places the currently-selected tray die here.
- `.gesture(DragGesture(minimumDistance: 5))` — fires when you move 5pt+ before releasing.
   - Only does anything if a die is present at this node.
   - Updates `gs.nodeDragLocation` for the floating drag-overlay.
   - On release: checks `findNodeAtPosition`, moves the die if target is empty, otherwise springs back.

The visible die and the node art both have `.allowsHitTesting(false)` — they're purely decorative. **Don't add gestures to either of them.** Add them to the outer `ZStack` instead.

### 22.7 If the game feels "stuck" or unresponsive
Likely causes, in order:
1. **Adjacent nodes overlap.** With `nodeHitArea = 36` and `nodeScale ≈ 1.83`, each hit zone is ~66pt. If two nodes' on-screen centers are closer than ~70pt, their hit zones overlap and drops can land on the wrong neighbor. Fix: reduce per-node fine-tuning offsets, lower `nodeScale`, or lower `nodeHitArea`.
2. **`isAnimating` flag stuck on.** If a brew animation crashed midway, `gs.isAnimating` may have stayed `true`. The whole node disables itself when `gs.isAnimating == true`. Restart the round via the debug menu.
3. **Hit area too small.** If you lowered `nodeHitArea` below ~30 at scale 1.0, fingers can miss the node. Bump back up.

### 22.8 If you ever want to revert to grow/shrink scale instead of glow
In `PotionShopNodeButtonView`, after the two `.shadow(...)` lines, add:
```swift
.scaleEffect(isHovered ? 1.15 : 1.0)
.animation(.spring(response: 0.25, dampingFraction: 0.6), value: isHovered)
```
This adds scale ON TOP of the glow. To replace the glow entirely, also delete the two `.shadow(...)` lines.

### 22.9 Companion doc
A focused, code-free tuning reference for this whole system lives in **`NODE_SYSTEM_GUIDE.md`** (separate file). Keep that one open while tuning visuals; keep this section as the deeper reference.

---

## 23. CUSTOMER BADGE + HEAD-ANCHOR SYSTEM (May 22–23, 2026)

This section documents the badge graphics + smart positioning system added over two days. It's a fairly intricate set of features, so the layout below mirrors how it's organized in code.

### 23.1 What was built (high-level)

Each customer in the scene now has:

- A **custom HP badge** (red drop-style graphic, `hp_badge.png`) showing live HP — visible for *all* queued customers (active + waiting), not just the front.
- A **custom Attack badge** (`attack_badge.png`) showing the customer's attack value.
- Badge positions snap to each character's *head* (not the geometric center), using a head-anchor system tuned per bucket and per character.
- An **inspect banner** with a `potion_bottle_outline.png` graphic showing the inspected customer's live HP number.
- A **fully revamped debug overlay** (🎨 Badges tab) to tune all of this visually.

### 23.2 Height buckets

Three buckets describe how characters' heads sit in their images:

- `.short` — head lower in the image (default anchor Y = 0.20)
- `.medium` — head ~1/6 from top (default anchor Y = 0.15)
- `.tall` — head near the top (default anchor Y = 0.10)

Plus an X anchor per bucket (defaults are non-center, tuned for the current art):

- short → X 0.378
- medium → X 0.537
- tall → X 0.565

These live as `headAnchorYShort/Medium/Tall` and `headAnchorXShort/Medium/Tall` on `PotionShopLayoutConfig`. The helpers `headAnchorY(for:)` and `headAnchorX(for:)` resolve to the right value per character.

**Current bucket assignments** (seeded in `applyDefaultHeightBuckets()`):

| Bucket | Characters |
|---|---|
| short | pemberton, greta, ardo |
| medium | mildred, wendelina, crispin |
| tall | tomik, grimdrek |

All other characters (sister_halla, hexa_mott, bram, ironhilde, carmilla, royal_envoy) default to `.medium` until tagged.

### 23.3 Per-bucket badge values

Each bucket has its own HP and Attack badge Size / OffsetX / OffsetY (18 values total). These live as e.g. `hpBadgeSizeShort`, `attackBadgeOffsetXTall` on `PotionShopLayoutConfig`. The helpers `hpBadgeSize(for:)`, `hpBadgeOffsetX(for:)`, `hpBadgeOffsetY(for:)` (and `attackBadge*` equivalents) look up the value for a character based on their bucket.

Tuned defaults (May 23, 2026 revision 3) are in `PotionShopLayoutConfig.swift` init and mirrored in `restoreLockedDefaults()`.

### 23.4 Per-character overrides (the "make it more malleable" layer)

`CharacterScale` (in PotionShopLayoutConfig) has 6 optional override fields:

```
var hpBadgeSizeOverride: Double? = nil
var hpBadgeOffsetXOverride: Double? = nil
var hpBadgeOffsetYOverride: Double? = nil
var attackBadgeSizeOverride: Double? = nil
var attackBadgeOffsetXOverride: Double? = nil
var attackBadgeOffsetYOverride: Double? = nil
```

When set, an override wins over the bucket default. Useful when characters in the same bucket vary in width (e.g. crispin is wider than ardo even though both could be short). Lookup order in the badge helpers: **override → bucket default**.

`CharacterScale` also has `headAnchorYOverride: Double?` for the Y anchor specifically. There is no X anchor override yet (X is bucket-only).

### 23.5 Badge offset math

For each badge:

```
renderedImageHeight = portraitDiameter * scale * 1.5 * customerSceneBaseScale * effectiveHeight
renderedImageWidth  = portraitDiameter * scale       * customerSceneBaseScale * effectiveWidth
headOffsetY = renderedImageHeight * (headAnchorY - 0.5)
headOffsetX = renderedImageWidth  * (headAnchorX - 0.5)

badge.offset(
    x: headOffsetX + hpBadgeOffsetX(for: char) * scale,
    y: headOffsetY + hpBadgeOffsetY(for: char) * scale
)
```

Meaning: the badge's stored X/Y are *displacements from the head anchor*, scaled by the queue-position factor. This way tall characters (head higher in image) get badges higher than short ones automatically, and the per-bucket offsets only need to fine-tune from there.

### 23.6 Live HP propagation

The HP badge text reads via `liveHP`, a computed property on `PotionShopCustomerInSceneView`:

```swift
private var liveHP: Int {
    gs.customers.first(where: { $0.id == customer.id })?.hp ?? customer.hp
}
```

This reads HP straight from `gs.customers` (which is `@Observable`), instead of relying on the cached `customer` snapshot passed in via `ForEach`. Earlier, when only the `customer` snapshot was used, the HP badge wouldn't update during a brew because SwiftUI's ForEach caching prevented the parameter update from reaching the child view. Reading via `gs` directly fixes the propagation. **If a similar "stale value" bug shows up elsewhere, use this same pattern.**

The inspect-banner bottle number works the same way via `brewTargetForPill` → `customer.hp`.

### 23.7 Ednar render now matches customer recipe

`PotionShopEdnarView.body` was rewritten to use the same `Color.clear` placeholder + `.scaleEffect(customerSceneBaseScale × …)` recipe that customer scene images use. The old pixel-dimension formula (`image.size.width * ednarBaseScale * …`) is gone. Result: Ednar's calm picture renders at the same physical size as a default customer scene image, regardless of its PNG dimensions. `ednarBaseScale` is still accepted as a parameter (so the call site doesn't break) but is no longer used in the render formula.

### 23.8 Per-character scale seeding (`applyTunedCharacterScales`)

There's no UserDefaults / file persistence for layout config — it's a singleton that initializes from code defaults each launch. To prevent the user from re-tuning every session, `applyTunedCharacterScales()` (in `PotionShopLayoutConfig.swift`) seeds the dictionary `perCharacterScales` with the tuned width / height / X / Y / waiting_* / waiting2_* values for 8 characters: mildred, tomik, greta, wendelina, grimdrek, pemberton, ardo, crispin. Called from both `init()` and `restoreLockedDefaults()`.

When the user copies layout values from the in-app debug menu and asks for them to be persisted, the workflow is:
1. Paste the dump back to me.
2. I update the matching defaults (badge per-bucket, head anchor, queue permutations, bottle, etc.).
3. For per-character scale changes (mildred_x, grimdrek_x, etc.), I update the corresponding lines in `applyTunedCharacterScales()`.

### 23.9 Debug overlay (🎨 Badges tab)

Layout: `PotionShopGameView.swift`, `PotionShopLayoutOverlay`, `case .badges`. Sections, top to bottom:

1. **HP + Attack Badges (per height bucket)** — three sub-blocks (Short / Medium / Tall), each with HP Size/X/Y + Atk Size/X/Y. X sliders range −300…300. Y and Size range −150…150 (Y) / 10…100 (Size).
2. **🧪 Bottle Graphic (inspect banner)** — Size / X / Y, plus inner number Size / X / Y.
3. **🧍 Head Anchor Defaults (by bucket)** — Y and X for each of short/medium/tall.
4. **👤 Per-Character Overrides** — character picker (shared with the Customers tab) + 6 sliders (HP & Atk Size/X/Y). Sliders display the *effective* value (override if set, else bucket); touching a slider sets the override. A "Reset {Character} badge overrides" button wipes all 6.

### 23.10 Copy Layout Values output

`copyLayoutValuesToClipboard()` in `PotionShopDebugMenu.swift` dumps the following in order:

- 🎨 BADGE GRAPHICS (per height bucket) — 9 HP + 9 Attack + 6 bottle fields
- 🧍 HEAD ANCHOR DEFAULTS (per height bucket) — 6 anchor fields
- 👤 PER-CHARACTER BADGE OVERRIDES — only characters with at least one non-nil override are listed; bucket label included

If a future feature adds new tunable values, **also add them to this function** so they survive the copy/paste flow.

### 23.11 Header `🧪` is now `potion_bottle_header.png`

`PotionShopHeaderView.swift:33` renders `Image(uiImage: UIImage(named: "potion_bottle_header"))` at 20×20pt, with the `🧪` emoji as a fallback. Asset lives in `Assets.xcassets/potion_bottle_header.imageset/`. (The `potion_bottle_outline` asset is still used by the inspect banner in `PotionShopCustomerSceneView.swift:877`.)

### 23.12 Patience ring (unchanged but worth knowing)

The green ring around each customer's profile button shows `patience / maxPatience`, where patience ticks down every brew (Phase 5 of `doBrew`). It never goes up. At 0, the customer expires and damages Ednar by `char.expireDamage`. Ring color shifts from green to orange below 40%. This is NOT an HP indicator — HP is on the badge.

### 23.13 Hard-won lessons from this session

- **`do { ZStack { … } }` inside a `@ViewBuilder` compiles but breaks SwiftUI observation propagation.** If you need to remove a conditional wrapper around a view, drop the wrapper entirely — don't replace with `do {}`.
- **`ForEach(…, id: \.element) { … }` can cache child views by ID** such that struct-parameter updates don't reach the child body. When live data needs to flow into a child view that lives inside a `ForEach`, prefer reading from the observable source (`gs.customers.first(where: …)?.field`) inside the child, not just relying on a passed-in struct snapshot.
- **Per-character X tuning beats bucket-only for narrow vs wide characters.** Buckets sort by height, but width varies independently. Adding per-character overrides for X (and size, and Y) made tuning much faster.
- **Never assume an asset is gone.** Earlier in the session, I claimed `hp_badge` and `attack_badge` didn't exist because they weren't on disk where I expected. The user clarified they were there; I had misread. Always verify with the user before suggesting assets are missing — and never delete from `Assets.xcassets` without explicit permission.

### 23.14 Per-character WAITING badge overrides (May 23, 2026)

Badges (HP + Attack) can now be tuned **independently for the waiting state** versus the active state. Six new optional fields on `CharacterScale`:

```swift
var waitingHpBadgeSizeOverride: Double? = nil
var waitingHpBadgeOffsetXOverride: Double? = nil
var waitingHpBadgeOffsetYOverride: Double? = nil
var waitingAttackBadgeSizeOverride: Double? = nil
var waitingAttackBadgeOffsetXOverride: Double? = nil
var waitingAttackBadgeOffsetYOverride: Double? = nil
```

**Lookup hierarchy:** The 6 badge lookup functions (`hpBadgeSize/OffsetX/OffsetY`, `attackBadgeSize/OffsetX/OffsetY`) now take an `isWaiting: Bool = false` parameter:

1. If `isWaiting` AND the corresponding `waiting*Override` is set → use it
2. Else if the active `*Override` is set → use it
3. Else → bucket default (Short/Medium/Tall)

**Share, not Separate:** Waiting1 and waiting2 share the same override (one set of waiting values per character covers both waiting slots). The choice was deliberate — see §23.16 for why the body's per-slot scales conspire to make "Share" look natural with Fix A in place.

**Renderer integration:** In `PotionShopCustomerSceneView`, all 6 badge calls now pass `isWaiting: !isActive`. `isActive` is defined as `gs.queue.first == customer.id`.

**Live editor controls:** In the Layout Editor (live overlay) → Customers tab, there's now a "⏳ Waiting HP Badge" and "⏳ Waiting Attack Badge" sub-section beneath the active sliders. The Reset button clears all 12 (6 active + 6 waiting) overrides for the selected character.

**Clipboard export:** `copyLayoutValuesToClipboard()` now also writes the 6 waiting overrides under the per-character section if any are set.

### 23.15 Layout overlay click-through (May 23, 2026)

`PotionShopLayoutOverlay` (the live layout editor in `PotionShopGameView.swift`) previously blocked all taps with a full-screen `Color.black.opacity(0.2)` background + `.onTapGesture { isPresented = false }`. That has been replaced with:

- `Color.black.opacity(0.2)` + `.allowsHitTesting(false)` — dim is visible, doesn't capture taps
- The empty `Spacer()` above the floating control panel also has `.allowsHitTesting(false)`
- The floating panel itself (sliders, section picker, buttons) still captures taps normally
- **Tap-anywhere-to-close behavior is gone.** Use the **X button** at the top-right of the floating panel to close.

This lets the user interact with the actual game (tap profiles to swap, place dice, brew) while the layout editor is open — perfect for tuning against real visual states.

### 23.16 Badge head-anchor Fix A (May 24, 2026)

**Problem:** Even with the "Share" mode for waiting badge overrides (§23.14), characters appeared to have their badges shift between waiting1 and waiting2 in 3-customer rounds. The cause: the badge head-anchor computation was driven by the slot-specific body dimensions (`effectiveWidth/Height` switched between `customerWaitingWidth/Height` and `customerWaiting2Width/Height`). When a character's waiting1 and waiting2 body scales differ (e.g. Ironhilde at 0.896 vs 0.94), the rendered image dimensions differ → head anchor moves → badge follows the head to a different absolute position.

**Fix A:** Decouple the badge anchor from the slot-specific body dimensions. In `PotionShopCustomerSceneView`:

```swift
// Body uses slot-specific (unchanged)
let effectiveWidth/Height/X/Y = isActive ? customerScene* : (queueIndex == 1 ? customerWaiting* : customerWaiting2*)

// NEW: badge anchor uses unified waiting1 dims for any waiting slot
let badgeAnchorWidth: Double = isActive ? customerSceneWidth : customerWaitingWidth
let badgeAnchorHeight: Double = isActive ? customerSceneHeight : customerWaitingHeight

let renderedImageWidth  = portraitDiameter * scale * customerSceneBaseScale * badgeAnchorWidth
let renderedImageHeight = portraitDiameter * scale * 1.5 * customerSceneBaseScale * badgeAnchorHeight
```

Result: a "Share" waiting badge override now produces visually identical placement in waiting1 AND waiting2. Body still scales per-slot (depth perspective preserved); only the badge's head anchor is unified.

**Tradeoff:** If a character has dramatically different `waiting2Width/Height` vs `waitingWidth/Height`, the badge may sit slightly off the actual head in waiting2 (since the head's true position depends on the body's actual rendered size, but the badge anchor uses the unified value). In practice the differences are small. If a specific character looks off, the fix is to nudge `waiting2Width/Height` closer to `waitingWidth/Height` rather than reintroduce slot-aware badge anchors.

### 23.17 Badge body-follow + per-slot waiting2 overrides (May 24, 2026 evening)

**Problem:** Even after Fix A (§23.16), when the user adjusted per-character badge positions in Day 1 Round 3 (Evening: Wendelina + Crispin + Ardo, 3 customers) and then reshuffled the queue, badges visibly drifted away from each character's head.

**Two root causes:**

1. **Badge offsets ignored `effectiveX/Y`.** The character body in `PotionShopCustomerSceneView` is offset by `effectiveX/effectiveY` per slot (active → `customerSceneX/Y`; waiting1 → `customerWaitingX/Y`; waiting2 → `customerWaiting2X/Y`), but the badge `.offset(...)` only used `headOffsetX/Y + badgeOffsetX/Y * scale`. So when a character moved between slots, the body shifted but the badges stayed.
2. **Waiting1 and Waiting2 shared one override set.** A single `waitingHpBadgeOffsetXOverride` (etc.) applied to BOTH waiting slots. If a character's `waitingX` ≠ `customerWaiting2X`, the badge could only look right in one slot.

**Fix (Option C = A + B):**

- **Option A — badges follow body.** In `PotionShopCustomerSceneView`, HP and Attack badge `.offset(...)` now include `effectiveX` and `effectiveY`. Badges automatically track the body wherever it sits within a slot.
- **Option B — separate waiting2 overrides.** Added 6 new fields to `CharacterScale`: `waiting2HpBadgeSizeOverride`, `waiting2HpBadgeOffsetXOverride`, `waiting2HpBadgeOffsetYOverride`, `waiting2AttackBadgeSizeOverride`, `waiting2AttackBadgeOffsetXOverride`, `waiting2AttackBadgeOffsetYOverride`. They override queue[2] only and fall back to waiting1 → active → bucket if nil.

**API change:** Badge lookup functions in `PotionShopLayoutConfig` changed from `isWaiting: Bool = false` to `queueSlot: Int = 0` (0=active, 1=waiting1, 2=waiting2). Precedence: slot 2 → `waiting2*` → `waiting*` → active override → bucket. All callsites updated in `PotionShopCustomerSceneView`, `PotionShopGameView`, `PotionShopDebugMenu`.

**Layout editor:** Added "⏳ Waiting 2 HP Badge" and "⏳ Waiting 2 Attack Badge" slider sections in `PotionShopGameView` so the user can tune queue[2] independently. The Per-Character Reset button now clears all 18 override fields (6 active + 6 waiting1 + 6 waiting2).

**Copy Layout Values:** `PotionShopDebugMenu` exports the 6 new `waiting2*` fields in the per-character section.

**Baked defaults (May 24, 2026 evening):** Two rounds of user-tuned values were pulled in via the Copy Layout Values export → applied to `applyTunedCharacterScales()` in `PotionShopLayoutConfig`. Notable changes: Bram now has full active+waiting badge overrides; Carmilla gained active badge overrides; Ironhilde gained 8 badge overrides; Royal Envoy gained `x = -68.44`; sister_halla / grimdrek / hexa_mott / wendelina / crispin / mildred all re-tuned post-Option-A shift; Ardo gained 3 `waiting2*` overrides (the first character to use the new Option B fields). Queue permutations for the 5 Day-1-Evening 3-character arrangements updated to new X/Y values.

**Result:** Customers can be reshuffled freely; badges follow each character's body and head regardless of slot. If queue[1] and queue[2] need different badge placements (rare — only when `customerWaitingX/Y` differs significantly from `customerWaiting2X/Y`), the Waiting 2 sliders can be tuned independently.

---

## 24. CHARACTER ART TEMPLATE — SCALING TO 50–75 CHARACTERS (May 24, 2026)

The current character system requires per-character layout tuning (X/Y/scale + badge offsets per slot per height bucket per width). That works for 14 hand-tuned characters but won't scale. To support a future random-matchmaking mode with 50–75 characters, a new art workflow was designed.

**Spec file:** `PotionShop/CHARACTER_ART_TEMPLATE_SPEC.md` — the authoritative source for the art workflow.

### 24.1 Core idea

Every new character is drawn inside a **shared 1024×1536 portrait template** with safe-zone rectangles for each height bucket. Conforming to the template means the character drops into the game with **zero per-character layout tuning** — no `customerSceneX`, no badge overrides, no permutation entries.

### 24.2 The template

Built once in Photoshop (pixel-precise Shape Tool + Properties panel), exported as a transparent PNG, imported into Procreate as a locked Reference layer for every drawing session. The PSD contains 15 colored shape layers:

- **Group A (4 rectangles):** do-not-draw red margins on all 4 canvas edges (96 px wide).
- **Group B (3 rectangles, nested):** body bands — wide (640 px), medium (480 px), skinny (320 px) — for the 3 width buckets.
- **Group C (6 rectangles):** head boxes per height bucket — `tallHat`, `tall`, `medium`, `short`, `superShort`, `floater`. Each pinned to a fixed Y range so the head always lands in a predictable spot.
- **Group D (2 strips):** floor lines — yellow at y=1500 (feet touch this), pink at y=1260 (floater feet touch this). *(Floor line shifted from y=1440 to y=1500 on May 25 to match existing 14 characters' art, which were drawn with feet at ~y=1480–1500. Bottom do-not-draw zone shrank to 36 px to compensate.)*

### 24.3 Two-axis tagging

Each character is tagged with two buckets:

- **Height** (6 options): `tall` / `medium` / `short` / `superShort` / `tallHat` / `floater`
- **Width** (3 options): `skinny` / `medium` / `wide`

Total possible combos: 18. The artist self-tags during/after drawing based on which head box and which body-band inset they filled.

### 24.4 What still needs to be built in code

Currently the spec only exists as a markdown doc + intent. **Not yet implemented in Swift:**

- Add `widthBucket` enum to `CharacterScale` (or character data definition).
- Expand `CustomerHeightBucket` enum to include `superShort`, `tallHat`, `floater` (currently has only `short`/`medium`/`tall`).
- Auto-spacing algorithm for the queue that reads each character's `widthBucket` and `heightBucket` and computes X positions algorithmically — replaces the hand-tuned `queuePermutations` dictionary for templated characters.
- Tier-based RNG matchmaking (Morning/Afternoon/Evening/Night drawing from tier 1-5 pools) for the future random-day mode.

### 24.5 Migration plan (not started)

Existing 14 characters are NOT in the template format. They'll keep their hand-tuned overrides until re-drawn against the template, at which point their overrides can be cleared. New characters (#15 onward) should be drawn template-first and added with only `id / name / tier / heightBucket / widthBucket / HP / attack / trait / dialogue` — no layout tuning.

---

## 25. DAY 3 — FLEX-DAY RNG TEST (May 25, 2026)

Day 3 is the **first test of the auto-layout queue system**. It exists separately from Day 1/2 so the existing hand-tuned layouts stay safe. If the auto-layout works well here, the plan is to migrate everything to it.

### 25.1 What Day 3 is

- **13 new "guide_*" characters** drawn against the safe-zone art template (see §24).
  - Heights span 6 buckets: `tallHat, tall, medium, short, superShort, floater`.
  - Widths span 3 buckets: `skinny, medium, wide`.
  - Each is just `guide_<name>` (octo, girl, skull, slug, fishguy, bull, traveler, demon, frog, pig, faun, fox, woman). Placeholder names and dialogue.
- **5 rounds, no Morning/Afternoon/Evening/Night labels** — just "Round 1" through "Round 5":
  - **Round 1 (fixed):** woman + traveler (2 chars, gentle intro)
  - **Round 2 (fixed):** octo + girl + skull (3 chars, variety)
  - **Rounds 3-5 (random):** 3/3/2 chars drawn without repeats from the 8-char random pool (slug, fishguy, bull, demon, frog, pig, faun, fox).
- **RNG reseeds every app launch.** Once Day 3 is entered, the random rounds are generated and stay stable for the rest of the session. New app launch → new shuffle.

### 25.2 Files added/changed

- **`PotionShopModels.swift`** — unchanged in this phase.
- **`PotionShopLayoutConfig.swift`** —
  - Extended `CustomerHeightBucket` enum with `superShort`, `tallHat`, `floater` cases.
  - New `CustomerWidthBucket` enum (`skinny / medium / wide`).
  - Added `widthBucket` + `headAnchorXOverride` fields to `CharacterScale`.
  - New head-anchor properties for the 3 template-only buckets.
  - All 6 badge-lookup switches updated to handle the new cases (mapped: superShort→short bucket, floater→medium, tallHat→tall for sizing).
  - New `applyGuideCharacter(id:height:width:)` helper called for all 13 guides during init.
- **`PotionShopData.swift`** —
  - Added 13 `PotionShopCharacter` entries (placeholder combat stats by height bucket).
  - Added `PotionShopFlexDay` struct (separate from legacy `PotionShopDay` to support variable round counts).
  - Added `day3: PotionShopFlexDay` with the fixed + random rounds spec.
  - `nextDayId(after:)` and `isLastDay(_:)` updated to chain day_2 → day_3.
  - `roundCount(forDayId:)` helper handles both legacy and flex days.
- **`PotionShopGameState.swift`** —
  - `flexDayGeneratedRounds: [PotionShopRound]` property holds the runtime-generated random rounds.
  - `isFlexDay` getter checks current dayId against `PotionShopData.isFlexDay(_:)`.
  - `startRound()` routes flex-day starts through `generateFlexDayRounds()` + a shared `spawnCustomers(from:)` helper.
  - `advanceRound()` uses `PotionShopData.roundCount(forDayId:)` instead of the hardcoded 4.
  - `advanceDay()` and `resetGame()` clear `flexDayGeneratedRounds` so they regenerate (with a fresh RNG draw) when the next Day 3 starts.
  - `currentRoundLabel` returns "Round N" for flex days instead of morning/afternoon/etc.
- **`PotionShopCustomerSceneView.swift`** —
  - Added `PotionShopAutoQueueLayout` enum (inlined in the same file to avoid Xcode project-membership issues).
  - The 3 static helpers (`queueXFractions`, `queueYFractions`, `queueScales`) take a new `useAutoLayout: Bool = false` parameter. When true, they call `PotionShopAutoQueueLayout.{x,y,scales}For:config:` instead of reading hand-tuned permutations.
  - The 3 computed properties (`scale`, `xPos`, `yPos`) on `PotionShopCustomerInSceneView` pass `useAutoLayout: gs.isFlexDay`.
- **`PotionShopDebugMenu.swift`** — "Skip to Day & Round" section now lists both `allDays` (Day 1/2, 4 rounds each) AND `allFlexDays` (Day 3, 5 rounds).

### 25.3 Auto-layout algorithm

For each customer the layout reads `widthBucket` and assigns a relative weight: `skinny=1.0, medium=1.4, wide=2.0`. It accumulates the weights into a cumulative array, then maps that range linearly to `x ∈ [0.45, 0.92]` of the scene width — so the active customer always sits at 0.45 and the back of the queue at 0.92, with everyone in between proportionally spaced. Wide chars take more room, skinny take less.

For Y, active = 0.48, waiters = 0.55, with per-bucket micro-adjustments so heads of different heights end up roughly horizontal across the screen (floaters sit higher; tall hats sit slightly lower to compensate for headroom).

Scale = 1.0 for every slot (the template canvas already encodes character size).

### 25.4 If it works → migrate Day 1/2

Once the auto-layout is verified visually for Day 3, the plan is:
1. Re-tag existing 14 characters with `widthBucket` (currently all default to `.medium`).
2. Switch all rounds to `useAutoLayout: true`.
3. Delete the hand-tuned `queuePermutations` dictionary entries — they're no longer needed once auto-layout produces equivalent or better spacing.
4. Stop generating per-character X/Y/scale values in `applyTunedCharacterScales` and let auto-layout handle it.

Migration is deferred until Day 3 is visually validated.

---

## 26. POST-MAY-25 WORK (May 26 → June 10, 2026)

Everything below was added or refactored during the May 26 – June 10 window. The §23 character/badge tuning system is still authoritative for Day 1 and most of Day 2. The new feet-anchor + matrix + per-cell systems are scoped to Day 3 R2 and don't disrupt the older code. The 3D dice are scoped strictly to Day 2 R2.

### 26.1 Feet-anchor mode (Day 3 R2 only)

Customers in Day 3 R2 sit on per-slot floor lines (their FEET snap to a Y fraction; characters of any height align cleanly to the ground). All other rounds keep their existing top-down anchoring.

- **Gate:** `PotionShopGameState.currentRoundUsesFeetAnchor` → true when the round's `PotionShopRound.useFeetAnchor` flag is set (currently only Day 3 R2 + the randomized R3 fork).
- **Floor-Y per slot:** `autoLayoutFeetYActive` / `autoLayoutFeetYWaiting1` / `autoLayoutFeetYWaiting2` on `PotionShopLayoutConfig` (range 0…1, fraction of scene height).
- **Slot-X fractions:** `autoLayoutSlotXFraction{Active,Waiting1,Waiting2}` lock each slot to a horizontal anchor so spacing is identity-independent.
- **Render lookup:** `PotionShopCustomerSceneView` checks `gs.currentRoundUsesFeetAnchor` and uses floor-Y + slot-X-fraction lookup instead of the per-character X/Y tuning.

### 26.2 Bucket × slot size matrix (replaces the old scale stack)

For each (height bucket × slot) combination, the matrix stores a `scale` value (0.3 – 2.0). 6 heights × 3 slots = 18 cells. Replaces what used to be the `autoLayoutScaleActive/Waiting1/Waiting2` triplet + bucket-specific defaults.

- 18 properties on `PotionShopLayoutConfig`: `autoLayoutSize{Active,Waiting1,Waiting2}{SuperShort,Short,Medium,Tall,TallHat,Floater}`.
- Renderer in feet-anchor mode reads `(slot, bucket)` → matrix scale; all other rounds keep the legacy scale.

### 26.3 Per-cell character overrides (slot × height × width — sparse)

On top of the 18-cell matrix, there's a **sparse override dict** keyed by `(slot, heightBucket, widthBucket)`. Each cell can override `size`, `x`, and `y` independently. Used to fine-tune awkward combinations like `tall × skinny` in slot 1 that the matrix alone doesn't handle.

- Storage: `PotionShopLayoutConfig.bucketCellOverrides: [BucketCellKey: BucketCell]` (max 3 × 6 × 3 = 54 possible cells, all sparse).
- Setter: `setBucketCellSize/X/Y(slot:height:width:...)`.
- Resolve order (in feet-anchor mode): per-cell override → bucket-slot matrix → default.
- ~13 cells currently baked (see `bake(...)` calls in `applyTunedCharacterScales`).

### 26.4 Slot fine-tune offsets

Two final pixel-level offsets per slot on top of the resolved X/Y: `autoLayoutActive{X,Y}`, `autoLayoutWaiting1{X,Y}`, `autoLayoutWaiting2{X,Y}`. Used for tiny push/pull after the matrix + cell-override math.

### 26.5 Focused per-slot editor

When the user taps a customer in the scene with the layout editor open, the auto-layout section collapses from the full 18-cell grid view to only the controls that affect that slot + that customer's bucket cell, plus a character-swap picker for the slot.

- State: `PotionShopLayoutConfig.selectedSlotIndex: Int?` + `selectedCharacterId: String`.
- View: `focusedAutoLayoutEditor(slotIdx:)` in `PotionShopGameView`.
- "Show all sliders ›" button returns to the full grid view.

### 26.6 HP badge two-tier override system

**Layer 1 — shared HxW (`bucketHpBadgeOverrides: [BucketKeyHW: BucketHpBadgeCell]`):** keyed by `(heightBucket, widthBucket)` only — head-anchored, inherits per-slot scale at render time. Currently 10 cells baked. Was originally keyed by `(slot, H, W)` until we realized HP is anchored to the head and the slot already scales it; June 3 refactor collapsed it to (H × W).

**Layer 2 — per-slot override (`bucketHpBadgeSlotOverrides: [BucketCellKey: BucketHpBadgeCell]`):** added June 3 when we hit cases where the same HxW combo needs different offsets in different slots (e.g. `medium×wide` in slot 1 vs slot 2). Keyed by `(slot, H, W)`. Wins over Layer 1 field-by-field. Currently 13 cells baked.

**Resolve chain (render time):**
1. Per-slot HP override (most specific)
2. Shared HxW HP override
3. Legacy per-bucket `hpBadgeSize/OffsetX/OffsetY{Short,Medium,Tall}` (oldest)

**Editor:** in the focused slot editor, a red toggle "Override for slot N only" switches between Layer 1 and Layer 2 writes. The header label updates live: `HP Badge (shared HxW) — H · W` vs `HP Badge (slot N override) — H · W`.

**Bake helpers:** `bakeHp(height:width:size:x:y:)` (Layer 1) and `bakeHpSlot(slot:height:width:size:x:y:)` (Layer 2). Nil fields leave the cell unset → falls through to the next layer.

**Future plan (not yet built):** a third tier — **neighbor-aware HP overrides** — that activates only when an adjacent slot has a specific H×W. See the `project_neighboring_hp_values_plan.md` memory file for the design. Triggered by a real case where slot 1's `tall × medium` needs different HP values when active is `tall × wide`.

### 26.7 Export / paste-back workflow

The layout editor exports a giant text blob covering every tunable property. The user pastes it back into chat and I "bake" the deltas into the corresponding source-of-truth defaults in `PotionShopLayoutConfig.swift` (modifying the property's initial value) and the `applyTunedCharacterScales` baker calls. New HP badge sections appear in the export:

```
HP badge per-cell overrides (height × width, sparse — June 3, 2026):
  [tall · wide] size=… x=… y=…

HP badge per-slot overrides (slot × height × width, sparse — wins over HxW):
  [2 · tallHat · medium] size=… x=… y=…
```

### 26.8 Day 2 R2 — 3D dice (slot-machine spin)

A REAL 3D cube rendered via SceneKit replaces the static dice in the tray for Day 2 Round 2 ONLY. Every other round renders the existing 2D dice. Started June 8.

**Gate:** `PotionShopGameState.currentRoundUses3DDice` → true iff `!isFlexDay && dayId == "day_2" && roundIndex == 1`.

**Implementation lives in `PotionShop/PotionShopCauldronView.swift`:**
- `DieFaceView3D` (SwiftUI) — wraps the SceneKit view, picks a random target face per spin, lives inside `PotionShopDieButtonView` which gates the render.
- `DieSceneView3D` (`UIViewRepresentable`) — hosts the `SCNView`, builds the scene, exposes `targetFace`, `dieColor`, `spinDelay`. Uses a `Coordinator` to track `lastBuiltFace` so `updateUIView` can rebuild the scene whenever the target face changes — bypasses any `.id()` weirdness.
- Cube: `SCNBox` with `chamferRadius: 0.12`. The cube's front (`+Z`) material is assigned to `targetFace` so a multiple-of-360° X-axis spin lands it camera-facing without any landing-rotation math.
- Camera: at `z=1.85`, FOV `42°`, with `motionBlurIntensity: 1.0` — close enough to fill the bounding square, blur smears the fast portion of the spin.
- Lighting: omni key light at `(2, 4, 4)` + ambient fill so cube edges read clearly.
- Animation: `SCNAction.rotateBy(x: π * 10, …, duration: 0.85)` ease-out → small scale bounce (1.0 → 1.10 → 0.96 → 1.0) for the "thud."

**Per-die stagger:** each die delays its spin by `DieFaceView3D.spinStaggerStep * dieIndex` (currently 40ms × index). 5 dice → die 4 stops ~160ms after die 0. Tweak the constant for more/less lag.

**Face textures:** `renderFaceTexture(value:)` loads `UIImage(named: "die_face_\(value)")` from Assets.xcassets. Procedural fallback (`fallbackFaceTexture`) draws a colored square + number if the asset is missing.

**Random face per spin:** `@State var randomTargetFace: Int = Int.random(in: 1...6)` on `DieFaceView3D`, updated via `.onChange(of: spinToken)` and `.onChange(of: die.value)` using a `pickDifferentFace(from:)` helper that guarantees the new face differs from the previous one. Currently uniform; will swap for a weighted/real-value selector once gameplay needs it.

**3D Dice Test SPIN button:** when the editor toggle `gs.show3DTestSpinButton` is ON AND `gs.currentRoundUses3DDice` is true, a floating orange "🎲 SPIN" button appears in the top-right of the main screen. Tapping it increments `gs.spinTrigger3D` → onChange fires → all 5 dice independently re-roll and replay the spin animation. Toggle lives in the editor's `.dice` section. **Rendered on top of the layout editor overlay** (ZStack order) so it stays tappable while you're tuning. Additionally, an inline "🎲 Reset Spin Now" button lives in the same `.dice` section of the layout editor as a direct trigger.

### 26.9 Animation iterations — `runSlotSpin` evolution (June 8–10)

The spin animation went through several iterations as the user (an animator) refined timing/feel. Revert points are tagged git commits.

**Iteration 1 (`fc8d23a`):** Slot-machine X-axis spin only (no drop). Per-die stagger 40ms × index. Scale bounce settle.

**Iteration 3 (`5690df0`):** Added a drop phase before the spin. Drop height in scene units, impact bounce (Y up + Y down), THEN spin, THEN Y-overshoot settle (replaces the iter-1 scale bounce). Stagger removed (all dice sync).

**Iteration 4 (`d7145dd`):** Drop and spin run IN PARALLEL via `SCNAction.group`. Spin lags drop by `spinJoinDelay = 0.06s`. Impact bounce removed — overlap is energetic enough. Total ~1.14s.

**Iteration 5 (`9c9219e`, "DROP THEN SPIN"):** Back to fully sequential. Adds OVERSHOOT + BOUNCE UP + BOUNCE DOWN between drop and spin. Drop is taller (height 0.99 user-tuned) and faster (0.13s). Total ~1.48s.

**Iteration 6 (uncommitted, "DROP AND SPIN TOGETHER"):** Drop runs alone first. Then bounce-sequence (overshoot + bounce up + bounce down) runs IN PARALLEL with the spin. Spin starts at `dropDuration + spinStartDelay` (~0.14s by default). New knob: `spinStartDelay`. Total ~1.22s.

**Iteration 7 (current, "viewport drop semantics"):** Changes the MEANING of `dropHeight`. Previously: absolute scene Y coordinate where the cube starts. Now: "distance the cube's BOTTOM starts above the window's top edge" — intuitive for an animator. Internally:
```swift
let visibleTopY: CGFloat = 0.71      // camera-derived: cameraZ × tan(FOV/2)
let cubeHalfHeight: CGFloat = 0.5
let startY = visibleTopY + cubeHalfHeight + dropHeight
node.position = SCNVector3(0, Float(startY), 0)
let drop = SCNAction.moveBy(x: 0, y: -startY, z: 0, duration: dropDuration)
```
- `dropHeight = 0` → cube starts JUST off-screen (bottom edge touching window top)
- `dropHeight = 5` → cube starts 5 scene units above the window top edge — long invisible fall, fast entry
- **Caveat:** if the camera changes (FOV or Z), update `visibleTopY` to match: `visibleTopY = cameraZ × tan(FOV/2 in radians)`.

**All tuning knobs (current state, top of `runSlotSpin`):**
| Knob | Value | Meaning |
|---|---|---|
| `dropHeight` | 0.99 | off-screen distance above window top |
| `dropDuration` | 0.13 | how fast the fall is |
| `dropOvershootY` | 0.07 | how far PAST Y=0 the drop sinks (momentum) |
| `overshootDuration` | 0.09 | hit-the-floor compression time |
| `bounceUpY` | 0.04 | how high above Y=0 the bounce peaks |
| `bounceUpDuration` | 0.10 | spring-up time |
| `bounceDownDuration` | 0.08 | settle-down time after bounce |
| `spinDuration` | 0.85 | X-axis spin length |
| `spinStartDelay` | 0.0 | wait after drop ends before spin starts |
| `settleOvershoot` | 0.12 | post-spin Y sink depth |
| `settleDownDuration` | 0.09 | post-spin hit-floor time |
| `settleUpDuration` | 0.14 | post-spin rebound time |

Plus `DieFaceView3D.spinStaggerStep` (currently 0) — per-die start delay (die N waits `N × stagger` before its sequence starts). Used for left-to-right cascade.

### 26.10 Camera framing notes (June 10)

The cube's screen size depends on `camera.fieldOfView` and `cameraNode.position.z`. Set this ONCE for the visual you want, then animate within it — don't iterate between camera and animation values.

- Current: FOV 42°, Z 1.85 → cube fills ~95% of bounding square, visible Y range ±0.71
- Wider FOV or larger Z → smaller cube, larger visible region (taller drops fit)
- Camera Y offset → shifts cube within the bounding square (NOT used — reverted; user preferred the viewport-aware `dropHeight` approach instead)

### 26.11 Future plans saved as project memories (NOT IMPLEMENTED)

These are pending designs locked-in during planning conversations but not yet built. Each has a dedicated memory file in the project's auto-memory store:

- **HP badge image swap plan** (`project_hp_badge_image_swap_plan.md`) — per-slot HP badge image variants (different speech-balloon tail directions). When a customer slides between slots, the badge image cross-fades via `.id(slotName)` while X/Y auto-animate to the new slot's tuned values through the existing override chain.
- **Node highlight plan** (`project_node_highlight_plan.md`) — die-type-aware lighting of secondary nodes on hover during Day 3 R3's dungeon round. PNG sequence overlays, in-sync across all lit nodes, one-way affects-map per die type.
- **Neighboring HP values plan** (`project_neighboring_hp_values_plan.md`) — tier 3 HP override that activates when an adjacent slot has a specific H×W. Editor would add a second toggle below the existing per-slot toggle.

Pull any of these up when the user references them.

### 26.12 3D dice picture/math split + the Equatable trap (June 11)

**Problem context.** Day 2 R2's 3D-spinning dice originally had a single `value: Int` on `PotionShopDie` that drove *both* the brew math (damage/healing) AND the picture shown on the cube/placed die. Two issues fell out of this:

1. **Tier bias.** `tier.rollFace()` rolls a weighted face for basic tier (`[1,2,2,3,3,4]`), so the cube — wired to `die.value` — could only land on 4 of the 5 asset graphics. Shield (5) and stability (6) never showed.
2. **Independent randoms.** An attempted fix introduced a local `@State private var randomTargetFace` inside `DieFaceView3D` that was uniform 1–6 — but this was **independent** of `die.value`. The cube settled on `randomTargetFace`; the placed-die view (in `PotionShopPlacedDieView`) read `die.value`. They were two completely unrelated random draws → cube and node almost always disagreed.

**The fix (two parts).**

**Part A — split picture from math.** Added a second field `faceValue: Int = 1` to `PotionShopDie` (PotionShopModels.swift:373) alongside the existing `value`. New static helper `PotionShopDie.rollFaceImageValue()` rolls a uniform 1–6 — independent of the tier table, so brew balance is untouched. `drawFromBag` now seeds both: `value: bd.tier.rollFace(), faceValue: PotionShopDie.rollFaceImageValue()`. Both the cube (`DieFaceView3D` → `DieSceneView3D.targetFace`) and the placed-die view (`PotionShopPlacedDieView` when `useFaceAsset == true`) read from the SAME `die.faceValue` — single source of truth.

New method on `PotionShopGameState`: `reroll3DDice()` mutates every die in the hand (both `value` and `faceValue`) and bumps `spinTrigger3D`. Both spin entry points (the floating 🎲 SPIN button in `PotionShopGameView` and the in-editor "Reset Spin Now" button in `PotionShopDebugMenu`) call `gs.reroll3DDice()` instead of bumping the trigger directly.

`DieSceneView3D` gained a `spinSession: Int` property + matching coordinator field. The scene rebuilds when EITHER `spinSession` changes (forces replay on every spin, even on the 1-in-6 case where new face == old face) OR `targetFace` changes. The old `randomTargetFace` `@State` and the `pickDifferentFace` helper were deleted.

**Part B — the Equatable trap.** Part A alone fixed *auto-roll* (start of D2R2 → matches) but **NOT** the floating SPIN button path. Cubes spun and settled fine, but dragging a die to a node still showed a different graphic.

Root cause: `PotionShopDie`'s custom `==` only compared `id`. When `reroll3DDice` mutated `faceValue` in place, the struct compared equal to its pre-reroll self by SwiftUI's standards. SwiftUI used that equality to skip body re-evaluation on the wrapping views — the dice tray's `DieFaceView3D` body never re-ran, so `DieSceneView3D` was reconstructed with a stale `targetFace` (even though the scene DID rebuild because `spinSession` changed). Result: cube rendered the OLD face; the placed-die view (which reads `die.faceValue` directly at render time through a separate path) rendered the NEW face. Mismatch.

The auto-roll path bypassed this because `drawFromBag` creates entirely fresh struct instances — different `id`s, so Equatable returned false → SwiftUI refreshed everything correctly.

Fix at PotionShopModels.swift:388 — extend `==` to compare ALL three identifying fields:
```swift
static func == (lhs: PotionShopDie, rhs: PotionShopDie) -> Bool {
    lhs.id == rhs.id &&
    lhs.value == rhs.value &&
    lhs.faceValue == rhs.faceValue
}
```

**If a similar "cube vs placed-die graphic doesn't match" bug happens again, check in this order:**

1. **Are both views reading from the SAME field?** Cube: `DieSceneView3D.targetFace` is set from `die.faceValue` in `DieFaceView3D.body`. Placed-die: `PotionShopPlacedDieView` reads `die.faceValue` when `useFaceAsset == true` (which is gated on `gs.currentRoundUses3DDice`). If either path drifts to a different field (`value`, `type.assetName`, a local `@State`), that's the bug.
2. **Equatable.** If a new mutable field is added to `PotionShopDie`, extend `==` to include it. Otherwise SwiftUI will skip view updates after in-place mutation.
3. **`spinSession` plumbing.** `DieSceneView3D` MUST rebuild on `spinSession` change, otherwise repeated spins with the same final face won't replay the animation.
4. **`reroll3DDice` scope.** It only re-rolls dice in `hand`. Dice already placed on nodes keep their pre-spin `faceValue` — that's intentional (placed dice are "locked in"), but if you ever want spin to re-roll placed dice too, that's where to add it.

**Why brew balance is preserved.** `value` is still rolled from `tier.rollFace()` (basic tier = `[1,2,2,3,3,4]`). `faceValue` is purely cosmetic — it never feeds into `computeBrew()`. Per-round weighting tables for both can be plugged in later by replacing the bodies of `rollFaceImageValue()` (pictures) and `tier.rollFace()` (math) with round-keyed lookups. TODO seams are marked in both functions.

### 26.13 Dice tray: fixed slots, return-from-cauldron, drag-back-to-tray (June 11)

A connected pile of UX changes to the dice tray, all driven by a desire for the tray to "feel solid" — dice keep their slot, returning dice don't re-spin, and the player can drag placed dice back to any open slot with the same fidelity as placing them.

**1. Fixed-position slots (no more HStack reflow).**

Old behavior: the tray was a packed `HStack` over `gs.hand` — placing a die on the cauldron caused the remaining dice to slide leftward.

New: each die has a `trayIndex: Int = 0` field on `PotionShopDie` (PotionShopModels.swift), assigned 0...4 on `drawFromBag`. The tray renders `ForEach(0..<5)` and for each slot looks up the die in `hand` whose `trayIndex` matches — if none, renders a dashed placeholder. Remaining dice never move when one is dragged out. A die returning to the tray lands in its original slot by default. `==` was extended to include `trayIndex` (same Equatable trap as §26.12).

**2. "Settled in tray" dice don't replay the spin animation.**

When a die comes BACK to the tray from a node, the SwiftUI cube view (`DieFaceView3D` / `DieSceneView3D`) is freshly created — without intervention, `makeUIView` → `buildScene` → `runSlotSpin` would replay the full drop + spin + settle on every return, which looks wrong.

Fix: new `settledDiceIds: Set<String>` on `PotionShopGameState`.
- **Cleared** by `drawFromBag` (fresh deal) and `reroll3DDice` (spin button) → "spin everything next time."
- **Populated** by every "die returns to the tray" path: `unplaceDie`, `dragPlacedDieToTray`, `returnDraggedDie` (drag cancel).
- `PotionShopDieButtonView` reads `!gs.settledDiceIds.contains(die.id)` and passes it as `animateOnAppear: Bool` through `DieFaceView3D` → `DieSceneView3D`.
- In `buildScene`, `runSlotSpin` is gated on `animateOnAppear`. When false, the cube is added to the scene at rest position (0,0,0, identity rotation, `targetFace` camera-facing) and just sits there.

**3. Drag a placed die from a node back to the tray.**

Used to be: only way back was a tap to unplace.

Now: the node drag's `onEnded` checks three drop zones in order:
- `gs.trayDropZone.contains(value.location)` — drop into the tray.
- An empty, non-source node → swap to that node.
- Anywhere else → snap back to source node.

Plumbing:
- `gs.trayFrame: CGRect` — published by `PotionShopDiceTrayView` via a `GeometryReader` background.
- `gs.trayDropZone: CGRect` — computed property that grows `trayFrame` upward by `PotionShopCauldronLayout.trayDropZoneTopExtension` (default 80pt) so the player can release a bit above the visible brown panel and still land it. Tune the constant to adjust the buffer.
- `gs.traySlotPositions: [Int: CGRect]` — each slot publishes its global frame too.
- `findEmptyTraySlot(at: CGPoint) -> Int?` — returns the slot whose frame contains the point if that slot's `trayIndex` isn't already claimed by a die in `hand`.
- `unplaceDie(_:toSlot:)` — gained an optional `toSlot: Int?` parameter. When provided AND the target slot is unoccupied, the die's `trayIndex` is rewritten so it lands there. When nil OR slot is occupied, falls back to the die's original slot. The tray drag uses this with `findEmptyTraySlot(at:)` so the player can choose ANY open slot by dropping over it.

**4. Visible drag overlay lifted to the screen-level ZStack.**

The "die at finger position" overlay used to render INSIDE `PotionShopCauldronView`, but the cauldron view is laid out BEFORE the tray view in the parent `VStack` — so when the player dragged into the tray's area, the die rendered BEHIND the tray.

Fix: the visible drag overlay was extracted into `PotionShopDraggedDieOverlay` at the top of the screen-level ZStack in `PotionShopGameView`. The overlay also hosts the `matchedGeometryEffect` placeholder, which is now **positioned at `gs.nodeDragLocation`** instead of screen center — so when the player releases, the matched effect animates from the FINGER position to the destination (tray slot or another node), not from the original node.

**5. Drop-snap animation knob.**

The tray-drop branch wraps `unplaceDie` + `cancelNodeDrag` in `withAnimation(.spring(response: 0.42, dampingFraction: 0.72))` — the same curve as the node-to-node swap. Other curves to consider: `.spring(response: 0.25, dampingFraction: 0.9)` (quick, no bounce), `.easeOut(duration: 0.18)` (smooth glide), or NO `withAnimation` for a hard snap.

**Bug pitfall worth remembering (Equatable, again).**

`PotionShopDie`'s custom `==` keeps growing as new mutable fields are added (`value` → `+ faceValue` → `+ trayIndex`). Every new mutable field that affects rendering MUST be added to `==`, or SwiftUI will optimize away the body re-evaluation after in-place mutation and you'll see "stale visual after the data changed" bugs. See §26.12 for the original case (cube face). The fixed-slot tray would have had the same bug if `trayIndex` had been left out.

---

## 27. JUNE 12, 2026 — D2R2 DICE SESSION (node sizing, tray snap-back, face table, glow pulse, value badge)

Eight requests handled in one pass. D2R2 (Day 2 Round 2) remains the dice
test environment; D3R3 is the customers/scene/HP-badge test environment.
Files changed: `PotionShopCauldronView.swift`, `PotionShopGameView.swift`,
`PotionShopGameState.swift`, `PotionShopModels.swift`. Nothing else touched.

### 27.1 Request 1 — Nodes render at the SAME SIZE as tray dice

New toggle + helper in `PotionShopCauldronLayout` (PotionShopCauldronView.swift):

```swift
static let nodeMatchesTrayDieSize: Bool = true
static func effectiveNodeScale(layoutNodeScale: Double, trayDieScale: Double) -> Double
```

How it works: the node visual scale handed down from `PotionShopGameView`
is no longer `layoutConfig.nodeScale` directly. Both call sites (the
`PotionShopCauldronView` init AND the `PotionShopDraggedDieOverlay` init)
now pass `PotionShopCauldronLayout.effectiveNodeScale(layoutNodeScale:trayDieScale:)`.
When the toggle is true, that helper returns `(dieSize / nodeVisible) × dieScale`
= `(44 / 26) × layoutConfig.dieScale`, so a node's visible art is EXACTLY
`dieSize × dieScale` — the same on-screen size as a die sitting in the tray.
With the saved dieScale (≈1.405) that's ≈62pt, up from the old ≈48pt.

Consequences to remember:
- **The layout editor's "Node Scale" slider is INERT while the toggle is
  true.** The tray's "Die Scale" slider drives both sizes. Flip
  `nodeMatchesTrayDieSize` to `false` to restore the old independent slider.
- The hit area scales along with it (`nodeHitArea 36 × effective scale`),
  so nodes are also easier to tap/drop on.
- A placed die fills its node edge-to-edge (placed-die view renders at
  `nodeVisible × visualScale`, which now equals the tray die size).
- The dragged-from-node overlay die uses the same effective scale, so the
  die does NOT change size as it travels node → finger → tray.
- Node POSITIONS/SPACING are untouched (spacing multiplier + per-node
  offsets still apply). Bigger nodes on the same spacing can crowd —
  if any pair overlaps, fix it with the spacing slider or per-node offsets.

### 27.2 Request 2 — Node→tray drop now SNAPS (crossfade/float killed)

Diagnosis: the `withTransaction(disablesAnimations: true)` snap from §26.13
was already in place, but TWO other effects were still firing on the
returning die's freshly-created tray view:
1. `PotionShopDiceDropInModifier` replayed its "fall from 80pt above +
   spring" entrance — meant for fresh deals, wrong for a die being dropped
   back by hand.
2. The default matchedGeometryEffect insertion crossfade layered on top.

Fix: `PotionShopDiceDropInModifier` gained an `enabled: Bool` (default
true). When false, the modifier's initial offset is 0 (not −80) and
`.onAppear` does nothing — the die materializes at rest in its slot,
instantly. The tray die view passes
`enabled: !gs.settledDiceIds.contains(die.id)` — i.e. dice RETURNING from
the cauldron skip the drop-in; fresh deals (whose ids were cleared from
`settledDiceIds` by `drawFromBag`) still drop in as before.

Combined result on release over the tray: disablesAnimations transaction
(no matched-geometry tween) + no drop-in (no fall) + the existing
`landPopScale` 1.35→1.0 spring punch = a hard snap with a satisfying pop,
matching the feel of snapping a die ONTO a node.

`settledDiceIds` lifecycle reminder (unchanged, but now load-bearing for
two systems): inserted by `unplaceDie`/`returnDraggedDie`; cleared by
`drawFromBag`, `discardAllDice`, and `reroll3DDice`. It now gates BOTH the
3D cube's animate-on-appear AND the drop-in modifier AND the value badge
reveal (§27.6).

### 27.3 Request 3 — Drop into ANY open tray slot (forgiving picker)

`findEmptyTraySlot(at:)` in `PotionShopGameState` was strict frame
containment (release had to be exactly inside an empty slot's rect, which
is only ~62pt tall — easy to miss). Rewritten with two passes:

1. **Column match:** if the release point's X falls within an empty slot's
   X-range, that slot wins regardless of Y. So releasing anywhere in the
   80pt-extended drop zone above the tray maps to the column under the
   finger.
2. **Nearest-empty fallback:** otherwise (released over an occupied slot,
   a gap between slots, or the tray padding) the empty slot with the
   smallest horizontal distance to the finger wins.

Returns nil only if no slot frames are known / all occupied → die falls
back to its original `trayIndex` via `unplaceDie`'s existing nil-handling
(that slot is empty anyway, since the die left from there).

**This supersedes the `findEmptyTraySlot` description in §26.13.** The
`unplaceDie(_:toSlot:)` plumbing from that section is unchanged.

### 27.4 Request 4 — Re-roll + spin at the top of every turn (verified, no change)

Confirmed already working as designed; nothing was modified:
- A "turn" ends when BREW's 7-phase sequence finishes → `doBrew()` calls
  `discardAllDice()` + `drawFromBag()`.
- A round starts via `startRound()` → `spawnCustomers(from:)` → `drawFromBag()`.
- `drawFromBag()` clears `settledDiceIds`/`diceToPopIds` FIRST, rolls
  fresh `value` + `faceValue` for 5 new dice, then bumps `spinTrigger3D`
  — which forces every `DieSceneView3D` to rebuild its scene and replay
  the drop/bounce/spin/settle, even when a slot's new face equals the old
  one (the June-11 duplicate-face guard).

So: every turn AND every round start = full re-roll + full spin. Already true.

### 27.5 Request 6 — THE FACE TABLE (data-driven dice faces, weights, new types)

The hardcoded `assetName(forValue:)` switch and the `[1,2,3,4,5,6]` cube
fill are GONE. `PotionShop3DDiceAssetMap` (top of PotionShopCauldronView.swift)
is now built around one editable table:

```swift
struct PotionShopDieFaceSpec {
    let value: Int        // face id, unique within the table
    let assetName: String // art shown on the cube face AND the placed die
    var weight: Int = 1   // relative roll weight; 0 = never lands (art-only)
}
static var faceSpecs: [PotionShopDieFaceSpec] = [ ...6 entries today... ]
```

Today's table reproduces the old behavior exactly: values 1 & 2 both →
`die_potency`, 3 → boost, 4 → heal, 5 → shield, 6 → stability, all weight 1.

**How to use it (the whole point):**
- **Upgrade a face's art** (e.g. heal becomes higher-value heal): edit that
  entry's `assetName`. Done — cube face and placed-die render both follow.
- **Change odds:** edit `weight`. weight 2 lands twice as often as weight 1.
  weight 0 keeps a face in the cosmetic spin rotation without it ever
  being the landed result.
- **Add a new die face/type:** append `.init(value: 7, assetName: "die_bonus", weight: 1)`.
  Nothing else changes anywhere.
- **Remove a face:** delete its entry.

Plumbing that makes one table enough:
- `PotionShopDie.rollFaceImageValue()` (Models) now delegates to
  `PotionShop3DDiceAssetMap.rollWeightedFaceValue()` — a weighted roll over
  the table. Every roll site (deal, post-brew redraw, editor SPIN button)
  goes through it.
- `assetName(forValue:)` is a table lookup with a safe fallback to the
  first entry.
- `DieSceneView3D.buildScene()` fills the cube's 6 physical sides from the
  table: landed face at the FRONT slot (the multiple-of-360° spin trick
  from §26.8 still applies), the other 5 sides drawn at random from the
  rest of the pool. Pools **larger than 6** work (extras just don't appear
  on that particular cube's spin); pools **smaller than 6** work too
  (entries repeat to fill the cube). Cosmetic only — the landed face is
  always correct.

REMINDER (still true from §26.12): `value` = brew math (tier table),
`faceValue` = picture (face table). Independent rolls. Both are in
`PotionShopDie.==` — keep them there.

### 27.6 Request 8 — Numeric value badge on tray dice (3D rounds)

New view `PotionShopTrayDieValueBadge` (PotionShopCauldronView.swift),
layered over `DieFaceView3D` in a ZStack inside `PotionShopDieButtonView`'s
3D branch. Shows `die.value` (the BREW-MATH value — same number a placed
die shows, so the number "travels" with the die), white `Font.gameScore`
with the standard black shadow, centered (the art keeps its center ~30%
blank, per the asset spec).

Reveal timing: hidden while the cube drops/spins, fades in after the spin
settles. Knobs at the top of the badge struct:
- `revealDelay: Double = 1.30` — seconds after a re-roll before the fade-in
  (the cube's full timeline ends ≈1.22s; see §26.9). If you re-tune
  `runSlotSpin`, re-tune this to match.
- `revealFadeDuration: Double = 0.20`

Replays on every `spinTrigger3D` bump (deal, redraw, SPIN button). Dice
returning from the cauldron (`settledDiceIds`) didn't spin → badge shows
instantly. Non-3D rounds are untouched (they already drew the value).

### 27.7 Request 7 — Reach-preview glow now PULSES (tuning struct)

The reach-preview system itself already existed (§ drag-and-drop work):
while a die is dragged and hovering a node, `gs.previewAffectedNodes`
(computed from `PotionShopDieRules.affectedNodes(for:placedAt:)`) marks
every node that die would reach, and those nodes glowed static cyan.
Works for tray→node AND node→node drags.

This session made it unmissable and fully tunable. New struct
`PotionShopNodeGlowTuning` (PotionShopCauldronView.swift, just above
`PotionShopNodeButtonView`):

```swift
previewColor              // cyan default
tintPreviewWithDieColor   // false; true = glow uses the dragged die's color
pulseEnabled              // true
pulseOpacityMin / Max     // 0.35 → 1.00 glow brightness oscillation
pulseHalfPeriod           // 0.45s per dim→bright half-cycle
pulseScaleMax             // 1.08 — node art "breathes" up to this at peak
previewGlowRadius         // 16
```

Implementation: `PotionShopNodeButtonView` gained
`@State previewPulse: Double` driven by `.onChange(of: isInPreview)` —
entering the preview starts a `repeatForever(autoreverses: true)`
ease-in-out 0↔1 oscillation; leaving settles it back without residue.
`glowOpacity` (preview branch) and a new `previewScale` (applied via
`.scaleEffect` on the node background) both read `previewPulse`.

**Division of labor (important):** WHICH nodes light up for WHICH die is
STILL defined ONLY in `PotionShopDieRules` (PotionShopModels.swift) — e.g.
"boost dragged over node 0 → nodes 4 & 5 glow" is a reach-rule edit there,
not a glow edit. `PotionShopNodeGlowTuning` controls only how the glow
LOOKS and PULSES. The hovered node itself keeps its own yellow drop-target
glow (priority order in the node view is unchanged).

### 27.8 Request 5 — Changing the node count (CONTEXT ONLY, NOT EXECUTED)

User may change how many cauldron nodes exist. Map of what to touch,
also written as a comment at the top of `PotionShopBoard` (Models):
1. `PotionShopBoard.nodes` (positions) + `PotionShopBoard.edges`
   (topology — reach/boost math depends on it).
2. `PotionShopLayoutConfig.perNodeOffsets` default array is sized 12
   (and its reset/saved-values block) — resize to the new count.
3. `PotionShopCauldronView`'s `perNodeOffsets` default parameter is also
   `count: 12` — match it.
Everything else (node ForEach, connection lines, drag targets, glow)
loops over `nodes.count` and adapts automatically.

### 27.9 Hard-won lessons from this session

- **A "crossfade" complaint can be three stacked animations.** The
  node→tray fade survived the §26.13 disablesAnimations fix because the
  drop-in entrance modifier was independently re-firing on the new tray
  view. When a snap doesn't snap, audit EVERY modifier that runs on the
  destination view's appearance, not just the matched-geometry pair.
- **`settledDiceIds` is now triple-duty** (cube animate-on-appear, drop-in
  skip, value-badge instant reveal). Any future "returning vs fresh die"
  visual should key off it too — and any new code path that returns a die
  to the hand MUST insert into it, or all three systems replay entrance
  animations.
- **Strict rect containment is hostile on touch.** The slot picker's
  column-match + nearest-empty fallback pattern (ignore Y inside an
  already-validated drop zone, then distance fallback) is the shape to
  reuse for future drop targets.
- **One table beats N switches.** The face table collapsed three sources
  of truth (asset switch, hardcoded cube fill, uniform roller) into one
  editable array. When adding the next dice feature (per-round weighting,
  upgrades), extend `faceSpecs` / swap it per round — don't add a new switch.
- **Editor slider shadowing:** with `nodeMatchesTrayDieSize == true` the
  Node Scale slider silently does nothing. If future-you "can't change
  node size from the editor," this toggle is why.

## 28. JUNE 12, 2026 — EDITOR QUALITY-OF-LIFE PACK (drag-to-edit, undo, A/B, tier dots, diff export)

Eight editor upgrades built in one pass, AWAITING USER TESTING as of this
writing. Files changed: **PotionShopEditorKit.swift (NEW FILE — must be
added to the Xcode target or nothing compiles)**, PotionShopGameView.swift,
PotionShopCustomerSceneView.swift, PotionShopCauldronView.swift,
PotionShopLayoutConfig.swift, PotionShopDebugMenu.swift.

### 28.1 The new file: PotionShopEditorKit.swift

Everything shared lives here:
- `PotionShopEditorHistory` — @Observable singleton: undo stack, A/B
  snapshot engine, tap-to-jump request bus, diff-export baseline.
- `PotionShopTunerRow` — the upgraded slider row (steppers, tap-to-type,
  tier dot, automatic undo/A·B recording).
- `PotionShopEditorJump` — jump-request payload (target tab + optional
  node index).
- `PotionShopEditorDragSession` — per-element drag bookkeeping used by the
  scene/cauldron drag gestures (records undo on drag start).
- `PotionShopTunerTier` — tier-dot descriptor (color, label, onClear).

### 28.2 One-helper leverage: sliderRow → TunerRow

GameView's `sliderRow(_:value:range:format:)` keeps its signature (plus a
new optional `tier:` param) but its body now just returns
`PotionShopTunerRow`. ALL ~130 editor rows gained, with zero call-site
changes:
- **−/+ steppers.** Step size derives from the format string:
  `%.0f` → 1, `%.1f` → 0.1, `%.2f` → 0.01, `%.3f` → 0.001. So pt-valued
  rows nudge by a point; fraction rows nudge by their display precision.
- **Tap-the-number-to-type.** The cyan value is a button → inline
  TextField (numbersAndPunctuation keyboard), commit on return, clamped to
  the row's range. " pt" suffixes are stripped before parsing.
- **Automatic history recording** (next section).

LESSON: because every row funnels through ONE component, future row-level
features (e.g. long-press to reset, per-row lock) are one-spot changes.
Never add raw `Slider(...)` rows to the editor — go through sliderRow.

### 28.3 Undo + A/B engine (PotionShopEditorHistory)

**Recording.** Each TunerRow holds a per-instance `@State token = UUID()`.
`beginChange(token:label:current:read:apply:)` appends a
`PotionShopEditorChange` (oldValue + read/apply closures); consecutive
changes with the SAME token merge into one step — so a burst of stepper
taps or one slider scrub = ONE undo. Slider records on
`onEditingChanged(true)`; steppers/typing record per action; drags record
on drag start via `PotionShopEditorDragSession.begin` (X and Y as two
steps, so one drag = two undos). Stack capped at 100.

**Undo.** Header button pops the last change and applies `oldValue`.
Disabled while viewing snapshot A.

**A/B.** "Set A" marks the current index in the change list. "A ⇄ B":
flip-to-A caches each subsequent change's CURRENT value (read closure)
into `bCache`, then replays oldValues in REVERSE order (correctly unwinds
multiple edits to the same row); flip-to-B replays the cached values
forward. Editing while viewing A clears the marker (user picked a
direction). Undoing past the marker also clears it.

**CAVEAT (by design):** A/B and undo cover changes made THROUGH the
recording paths (sliders, steppers, typing, the three drag gestures). They
do NOT snapshot the whole config — programmatic changes (e.g. Restore
Locked Defaults) are invisible to them.

### 28.4 Drag-the-thing-itself (scene + cauldron)

All drags: `DragGesture(minimumDistance: ~8–12)` so plain taps still
work; gated on `layoutConfig.layoutEditorIsOpen`; write through the SAME
setters the sliders use; record undo on start. Write targets:

- **Character body** (CustomerSceneView, gesture on the inner character
  ZStack): feet-anchor rounds → per-cell `setBucketCellX/Y(slot·H·W)`
  (same as the focused editor's "Cell X/Y" sliders); legacy rounds →
  `characterScale.x/y`, `.waitingX/Y`, `.waiting2X/Y` by slot tier. Body
  offsets render in raw points → 1:1 drag delta. Drag also selects the
  character/slot for the editor.
- **HP badge** (gesture on the badge ZStack): feet-anchor → slot-cell or
  shared-H×W dict per the `editHpBadgePerSlot` toggle (exactly like the
  sliders); legacy → per-character `hpBadgeOffsetX/YOverride` /
  `waiting…` / `waiting2…` by slot. **Badge offsets render multiplied by
  `scale`, so drag deltas convert back by ÷ scale** — the badge tracks the
  finger even on shrunken waiting-slot characters.
- **Node** (CauldronView NodeButtonView): editor open re-purposes the
  existing drag gesture — writes `layoutConfig.perNodeOffsets[i]` (same
  value as Fine-Tune sliders), 1:1 screen points. Gameplay die-drag branch
  is skipped entirely while the editor is open.

### 28.5 Tap-anything-to-jump

While the editor is open: tapping a character or its HP badge selects it
(`selectedCharacterId` + `selectedSlotIndex`) AND posts
`PotionShopEditorJump(target: .autoLayout)`; tapping a node posts
`(.fineTune, nodeIndex:)`. The editor overlay's
`.onChange(of: PotionShopEditorHistory.shared.jumpRequest)` switches
`activeSection` (and `selectedNodeIndex` for nodes), reveals the legacy
strip group if needed, then nils the request.
**Gameplay node taps (place/unplace die) are SUSPENDED while the editor is
open** — the editor branch returns before the gameplay branch.

### 28.6 Tier dots + ⊘ clear (HP badge rows, focused editor)

New LayoutConfig introspection:
- `hpBadgeTierSource(slot:height:width:field:)` → `.slotCell` /
  `.sharedCell` / `.legacy` per field (size/x/y).
- `clearWinningHpBadgeTier(...)` — nils the winning tier's field; removes
  fully-empty cells from their dict (keeps exports clean). Tapping ⊘
  repeatedly walks down the chain (slot → shared → done).

UI convention (legend shown above the rows): 🔴 dot = slot override
winning, 🟠 = shared H×W winning, ⚪ gray = legacy/default (no ⊘ shown).
Row shows "from: …" under the slider. This is the foundation tier-clarity
work that the FUTURE contextual badge layer (§28.9) will plug into as a
fourth dot color.

### 28.7 Diff export ("Copy Changed Values Only")

`copyLayoutValuesToClipboard()` was refactored: the giant string builder
is now `generateLayoutValuesText() -> String`; the copy button is a thin
wrapper. The **first time the debug menu appears each session**, an
`.onAppear` captures the full text as the baseline
(`captureExportBaselineIfNeeded`). The new "📋 Copy Changed Values Only"
button diffs current vs baseline by LINE SETS (decoration/header/
"Generated:" lines excluded): lines only in current = CHANGED/NEW, lines
only in baseline = REMOVED (cleared overrides). Set-based diffing is
robust to the dict exports growing/shrinking/reordering.
GOTCHA: the baseline captures when the menu first opens — if values were
somehow changed before ever opening the menu, those would not show as
diffs. In practice the editor is launched FROM the menu, so this is fine.

### 28.8 Tab strip grouping

Primary strip: Auto-Layout, Badges, Customers, Fine-Tune, Nodes, Dice.
Behind "More ▾": Sections, Ednar, Permutations, Cauldron, Bowl, Brew.
Edit the two static arrays (`primarySections` / `legacySections`) in the
overlay struct to re-prioritize. Tap-to-jump into a hidden tab auto-opens
the group. The header row also hosts Undo / Set A / A⇄B next to close.

### 28.9 Contextual HP badge layer — BUILT (later same day; untested)

User green-lit immediate build as a separate test step (test §28.1–28.8
first, then this). Design as agreed:
- Trigger: badge placement sometimes needs to depend on the NEIGHBOR one
  slot in front (slot 0 for slot 1, slot 1 for slot 2) — e.g. small-thin
  in slot 1 behind tall-wide active. Badges hang LEFT (negative X) into
  the front neighbor's space, hence the collision.
- Architecture: **Option 1 — sparse contextual NUDGE layer** on top of the
  existing resolve chain (deltas, not absolutes, so base re-tunes carry
  through automatically).
- Key: **(my slot, my H×W, neighbor's FULL H×W)** — user explicitly wants
  both height AND width on the neighbor side, not width-only. Sparse dict;
  only problem pairings get entries.
- Resolution must be LIVE from the current queue (badges re-resolve when
  the lineup changes); consider a short ease on the offset so the jump
  reads as intentional.
- Editor: third write-mode toggle in the badge section ("contextual nudge
  for the CURRENT live pairing"), entries in Copy Layout Values + the new
  diff export, and a fourth tier-dot color in §28.6's indicator.

**As implemented:**
- Storage: `hpBadgeContextNudges: [HpBadgeContextKey: HpBadgeContextNudge]`
  in LayoutConfig. Key = (slot, myHeight, myWidth, nbrHeight, nbrWidth);
  nudge = (dx, dy, sizeMul) DELTAS. Identity nudges auto-delete on write
  (`setHpBadgeContextNudge`) so the dict stays sparse.
- Render: in CustomerSceneView the badge computes `frontNeighborKey` LIVE
  from `gs.queue[badgeQueueSlot - 1]`, looks up the nudge, and applies
  `size × sizeMul`, `x + dx`, `y + dy` ON TOP of the fully-resolved values
  — in BOTH feet-anchor and legacy rounds. A 0.25s easeInOut keyed on the
  neighbor's charKey makes lineup-change hops read as intentional.
- Editor (focused per-slot editor, below the HP rows): purple "Contextual
  nudge" block with (a) `editHpBadgeContextual` toggle — when ON, dragging
  the HP badge in the scene writes the NUDGE for the live pairing instead
  of base tiers (badgeX/YAccessors branch on it FIRST, before the
  feet-anchor branch); (b) live pairing readout (me H×W ← neighbor H×W,
  with char names); (c) ΔX / ΔY / Size× rows with purple tier dot when an
  entry exists, ⊘ deletes the whole entry. Slot 0 shows an explainer
  instead (nobody in front). Pairings are staged with the swap pickers.
- Export: `formatHpBadgeContextNudges()` adds one stable sorted line per
  entry to Copy Layout Values (and therefore the changed-only diff).
- GOTCHA (fixed during build): inserting the export section via str-replace
  initially landed INSIDE an open `"""` literal, silently swallowing
  code as text. When editing the giant export string builder, always
  verify triple-quote parity afterward.
- Tuning workflow: D3R3, swap pickers to stage the problem pairing →
  toggle contextual ON → drag the badge (or use ΔX/ΔY) → toggle OFF →
  Copy Changed Values Only.

### 28.10 Hard-won lessons

- **Funnel rows through one component before adding row features.** The
  131-call-site sliderRow delegation made steppers/typing/undo a single
  edit. Same principle as §27's face table: one source of truth.
- **Closure-log undo beats config snapshots here.** LayoutConfig is a
  huge non-Codable class; recording (read, apply, oldValue) per edit gave
  undo AND A/B without serializing anything. The cost is the §28.3 caveat:
  only recorded paths are covered.
- **Per-view-instance `@State token = UUID()` is a clean row identity.**
  Labels repeat ("HP X" exists in a dozen rows); tokens don't, and they
  survive re-renders. Never key undo merging on labels.
- **Drag deltas must respect the render math.** Body offsets apply raw
  (1:1); badge offsets apply ×scale (÷ on the way back). When adding new
  draggables, find the render expression first and invert it.
- **Editor-open must suspend conflicting gameplay gestures explicitly**
  (node taps/drags) — the same surface can't serve both masters at once.
## 29. CUSTOMER SPAWNING: random pool (BUILT) vs HP-bucket→visual (PLANNED)

(Reconstructed June 15, 2026 — this section was lost in a doc-merge and
rewritten from the code + session history.)

### 29.1 What EXISTS today — `randomFromPool` (built June 3, 2026)

`PotionShopRound` (PotionShopModels.swift) can carry `randomFromPool: [String]?`.
When set and non-empty, `spawnCustomers(from:)` treats the round's literal
`customerIds` as a COUNT ONLY and draws that many ids at random from the
pool, fresh every spawn:
```swift
if let pool = round.randomFromPool, !pool.isEmpty {
    resolvedIds = Array(pool.shuffled().prefix(round.customerIds.count))
} else {
    resolvedIds = round.customerIds   // literal, fixed lineup
}
```
- Re-draws every spawn; re-entering a round (advance, restart, debug jump)
  reshuffles. Debug "reshuffle" forces a new draw without quitting.
- WHOLE-BUNDLE draw: each id resolves via `PotionShopData.character(id)` to
  a fixed bundle (hp, patience, trait, visual). The draw picks bundles; HP
  comes FROM the drawn character, not a target.
- So "random pool of 50–100 customers" is already viable: define characters,
  list ids in `randomFromPool`, set the count.

### 29.2 What is NOT built — HP-bucket → random-visual (intended)

User's vision: customers bucketed by HP/difficulty, with the VISUAL chosen
at random from a pool. This INVERTS 29.1's flow (pick difficulty first, then
dress with a random skin). Requires: (1) decouple stats from appearance,
(2) tag the visual pool by H×W bucket so a skin only lands where its
silhouette fits, (3) difficulty-first spawner. NOTE: §34 (later) confirms
this became the agreed model. Superseded/expanded by §35 (spawn architecture).

### 29.3 Prerequisite for endless mode

Endless mode needs difficulty-first spawning (Day 40 wants "a 25-HP enemy",
not a named character). So 29.2 is groundwork for endless, not a separate
nicety — build it AS PART OF endless work, against the real difficulty curve.

## 30. JUNE 12, 2026 — DAY 1 = FULL-GAME-FLOW TEST GROUND

(Reconstructed June 15, 2026.) Day 1 became the integrated test bed: D2R2
dice/node behavior + D3R3 customer-scene visuals + random draws, together.
Files: PotionShopData.swift, PotionShopGameState.swift.

### 30.1 The four requirements

1. D2R2 dice+node behavior → every Day 1 round. `currentRoundUses3DDice`
   extended to return true for all of `dayId == "day_1"` (plus the original
   Day 2 Round 2). One flag gates the whole §27/§28 dice package.
2. D3R3 customer-scene visuals → every Day 1 round. Each Day 1 round set
   `useFeetAnchor: true` (the flag `currentRoundUsesFeetAnchor` reads). Clean
   half — feet-anchor was always per-round data, just flipped on.
3. Counts: morning/afternoon/evening = 3 customers; night = 1 (boss). Via
   each round's `customerIds.count` (count-only when a pool is set).
4. Random customers from the gmarker pool, re-drawn every entry. Each Day 1
   round sets `randomFromPool: PotionShopData.gmarkerPool`. Falls out of
   §29.1 — switching away and back re-spawns fresh. ZERO new code.

### 30.2 The gmarker pool

`static let gmarkerPool: [String]` in PotionShopData — the 12 `gmarker_*`
ids. Add/remove to change Day 1's cast. Night boss draws 1 from the same
pool (give `night` its own array later if a distinct boss pool is wanted).

### 30.3 Notes

- Old Day-1 hand-authored cast (mildred, tomik, etc.) no longer referenced
  by Day 1 but still in the `characters` dict (Day 2+ and swap pickers use
  them) — don't delete.
- First time the 3D dice run outside D2R2, and first time 3D dice + the
  feet-anchor scene run in the SAME round. They're independent subsystems;
  Day 1 is where to watch for any interaction.

## 31. JUNE 13, 2026 — DAY 1 SCENE FIX: auto-layout was gated on flex-day, not feet-anchor

(Reconstructed June 15, 2026.) After §30, Day 1 customers rendered
wrong-sized/mis-positioned (giant minotaur, pile-up) while Day 3 R3 — same
characters — looked right. File: PotionShopCustomerSceneView.swift.

### 31.1 Root cause

The bucket-based auto-layout (sizes each customer by H×W bucket, spreads
them out) was switched on by `useAutoLayout: gs.isFlexDay` at the `scale`
and `xPos` render sites. Day 3 is a flex day → got it. Day 1 is a legacy
day → `isFlexDay == false` → auto-layout OFF → fell back to untuned
per-character defaults. The Y path already short-circuited on
`currentRoundUsesFeetAnchor`, so only SCALE + X were broken (right vertical
spot, wrong size/spacing — exactly the bad screenshot).

KEY INSIGHT: feet-anchor IS the bucket system; auto-layout and feet-anchor
must travel together. Gating one on flex-day and the other on feet-anchor
was a latent inconsistency that surfaced once a feet-anchor round existed on
a non-flex day (Day 1).

### 31.2 Fix

Scene visuals that distinguished "flex day" now trigger on
`gs.isFlexDay || gs.currentRoundUsesFeetAnchor`: scale + xPos auto-layout;
floor line hidden; background uses the `bgtest1` perspective-grid template.
HP badges already keyed on feet-anchor (they were using the matrix all
along — they just looked wrong pinned to mis-sized characters; fixing
scale+X fixed them for free).

GENERAL RULE: gate D3R3-style scene behavior on `currentRoundUsesFeetAnchor`,
NOT `isFlexDay`.

## 32. JUNE 13, 2026 — UNIFIED DICE OUTCOME (ii-a): spin decides type+value, locked tray→node (DAY 1)

The tray spin is now a real slot machine on Day 1: one weighted roll lands a
whole outcome (type + value + face art), the player drags those known dice
to nodes, and what the tray showed is exactly what fires. Scoped to Day 1
only; all other days keep the old behavior. Files changed:
PotionShopCauldronView.swift, PotionShopGameState.swift, PotionShopModels.swift.

### 32.1 The model chosen (recap of the design convo)

Player picked **(ii-a)**: the spin decides BOTH type and value; the bag is an
ODDS TABLE (weights), not a list of typed dice; results are LOCKED from tray
to node (no re-roll on placement — "value between tray and node stays the
same"). Strategy = reacting to rolled outcomes + choosing which node each
die goes on. 5 effect types today; more values/types come later via the
odds table + balloons.

### 32.2 The core problem this fixed

Pre-June-13 a dealt die had THREE independent rolls that didn't agree:
`type` (from the bag list), `value` (from `tier.rollFace()`), `faceValue`
(picture, from a separate roller). So the cube could show heal art, act as
potency, and display a third number. The dice were "lying." ii-a collapses
this to ONE roll.

### 32.3 The face table became the ODDS table

`PotionShopDieFaceSpec` (PotionShopCauldronView.swift) gained `type` and
`brewValue`; its old `value` field was renamed `id` (it's the cube face id,
NOT the brew number — this distinction matters because the cube spin places
a face by id and spins to it). Each row is now a complete outcome:
`(id, type, brewValue, assetName, weight)`. `weight` is the odds knob.

New roller `rollOutcome(dayId:roundIndex:)` does ONE weighted pick and
returns the whole spec. This is THE seam every future weighting feature
plugs into (all labeled in-code):
- per-day/round odds → branch to pick a different table by (dayId, roundIndex)
- per-day value caps ("nothing above 3 until Day X") → filter pool by brewValue
- pity timer → handled in the draw loop, can override the roll
`rollWeightedFaceValue()` kept as a legacy shim (returns just an id) for
non-Day-1 picture rolls.

### 32.4 The deal rolls once (drawFromBag + reroll3DDice)

`drawFromBag`: on `dayId == "day_1"`, each drawn slot calls `rollOutcome`
and builds the die with type/value/faceValue ALL from that one face. The
bag die now contributes only id+tier; its type is overridden by the roll.
Other days unchanged (type from bag, value from tier, picture separate).

`reroll3DDice` (editor SPIN + post-unplace): same Day-1 branch, but it had
to REBUILD the die struct (not just mutate value/faceValue) because `type`
is a `let` — without rebuilding, a reroll would land new art+value but keep
the OLD type (a fresh what-you-see≠what-you-get bug). Fixed.

### 32.5 Why "locked tray→node" needed NO extra code

`computeBrew` already reads `die.type` + `die.value` off the PLACED die
(it switches type→effect: potency/stability→damage, heal→heal,
shield→shield, boost→neighbor multiplier; value = magnitude; reach from
`PotionShopDieRules`). The placed-die VIEW already reads
`assetName(forValue: die.faceValue)` + `die.value` — the same id+value the
cube showed. So once the deal stores one consistent outcome, every
downstream reader (cube, badge, placed art, brew math, type color/abbr/glow)
agrees automatically. The fix was REMOVING the second roll, not adding
lock logic.

### 32.6 Scope + what was deliberately NOT built

- Scoped to ALL of Day 1 (every reader keys on `dayId == "day_1"`); other
  days bit-for-bit unchanged. Port further later by widening that check.
- NOT built (seams left clean, per plan): the actual weighting formula,
  per-day value caps, specific boost-reach rules (still in
  `PotionShopDieRules`), and the pity timer (a bad-luck guarantee — force a
  type if absent N turns; N needs real play to pick, so deferred until
  streaks are observed; the draw loop is its hook).

### 32.7 Tier overlap (known, intentional, deferred)

`PotionShopDieTier` (basic/silver/gold → value ranges 1–4/2–5/3–6) still
exists and still works on non-Day-1 days. On Day 1 the odds table sets
value, so tier's value role is now redundant there (the die keeps a tier
for compatibility but its value comes from the face). Eventually fold
"stronger dice" into the odds table and retire tier; not this turn.

### 32.8 Gotcha for next session

The cube spin keys on `faceValue` as a FACE ID, and `==`/scene-rebuild
logic compares value+faceValue. If you add faces to the table, keep `id`
unique. If two faces share art but differ in type/value, that's fine — the
cube shows by id, the math reads type/value. Don't collapse id back into
brewValue; they are intentionally separate (multiple faces can have the
same brewValue but different ids/types).
## 33. JUNE 13, 2026 — DAY 1 SPIN REGRESSION: a reverted flag, plus a misdiagnosis worth remembering

After §32, Day 1 dice showed CORRECT numbers/effects but NO spin animation,
while D2R2 still spun. Took two attempts; the lesson is as valuable as the
fix. File ultimately changed: PotionShopGameState.swift (one property).

### 33.1 The real cause (a lost edit, not a logic bug)

`currentRoundUses3DDice` in the uploaded GameState had reverted to its
ORIGINAL form:
    `!isFlexDay && dayId == "day_2" && roundIndex == 1`
i.e. the §30 Day-1 extension was GONE. So on Day 1 the flag was false, the
tray rendered the FLAT (non-3D) dice branch, and there was no cube to spin.
Numbers/effects still worked because §32's value unification keys on
`dayId == "day_1"` in `drawFromBag` SEPARATELY and survived the revert —
hence the exact split "right numbers, no spin." D2R2 still spun because the
reverted flag still pointed at exactly that round.

Fix: restored the extension —
    `if isFlexDay { return false }`
    `if dayId == "day_1" { return true }`
    `return dayId == "day_2" && roundIndex == 1`

### 33.2 The misdiagnosis (so we don't repeat it)

First attempt assumed a SwiftUI diffing problem (cube not rebuilding because
the unified roll could re-land the same faceValue) and added a defensive
`.id("die3d-\(die.id)-\(spinToken)-\(die.faceValue)-...")` to
DieFaceView3D. That was solving a problem that didn't exist: the cube was
never CREATED on Day 1 (flat branch), so there was nothing to force-rebuild.
The `.id()` is harmless and remains (it's a legitimate belt-and-suspenders
guarantee that a deal/reroll replays the spin), but it was NOT the fix.

ROOT-CAUSE LESSON: when a visual subsystem works in round A but not round B
with identical code, check the per-round GATE FLAG first
(`currentRoundUses3DDice`, `currentRoundUsesFeetAnchor`), before suspecting
the subsystem's internals. A "works here, not there" split almost always
means a flag, not a bug.

### 33.3 Process lesson — reverts keep biting

This is the SECOND revert-caused issue in two sessions (earlier: uploads
missing `rollOutcome`; now: missing the Day-1 flag extension). The Day-1
feature set spans MANY files (Data: gmarker pool + feetAnchor; GameState:
the 3D flag + unified-roll branches; CustomerSceneView: auto-layout on
feet-anchor; CauldronView: the odds table). A stale copy of any one silently
undoes cross-file work. When verifying a regression, grep the expected edits
across ALL relevant files (e.g. `grep -c gmarkerPool`, `grep -c
currentRoundUsesFeetAnchor`, `grep -c 'dayId == "day_1"'`) to spot which
file reverted. In §33's case that grep confirmed only the one flag was lost.

### 33.4 Current Day-1 state (all confirmed present + working)

- 3D spinning dice: ON (currentRoundUses3DDice → true for day_1). ✓ spins.
- Unified roll (§32): type+value+face from one `rollOutcome`. ✓ numbers correct.
- Feet-anchor customer scene + bucket sizing (§30/§31). ✓
- Random gmarker pool, reshuffles on round re-entry (§30). ✓
- `.id()` spin-replay guard on the cube (this session). ✓ harmless safety net.
---

## 34. JUNE 15, 2026 — Three new gmarker characters + HP badge context nudges (June 15, 2026)

### 34.1 New gmarker characters

Three new art assets added to the gmarker customer pool:

| id             | name      | height      | width  | HP | patience |
|----------------|-----------|-------------|--------|----|----------|
| gmarker_bird   | Feathers  | medium      | medium | 14 | 7        |
| gmarker_dino   | Rex       | medium      | medium | 16 | 7        |
| gmarker_puck   | Puck      | superShort  | skinny | 10 | 6        |

**Pool size:** 12 → 15 (`gmarkerPool` in `PotionShopData.swift`).

**Where they appear:** Random draws only — Day 3 R2's `randomFromPool` and `gmarkerPool`. No curated Day 1/2 rounds changed.

**Files changed:**
- `PotionShopData.swift` — character entries + pool arrays
- `PotionShopLayoutConfig.swift` — `applyGuideCharacter()` bucket registration
- `PotionShopGameView.swift` — `allGuideCharIds` (layout editor picker)
- `PotionShopDebugMenu.swift` — `allCharacterIds` (export list, also added all 12 existing gmarkers that were previously missing)

### 34.2 HP badge context nudges (bakeHpContext system)

New system added to `PotionShopLayoutConfig.swift` for context-dependent HP badge positioning. When a character in slot 1 or 2 has a specific neighbor in the slot ahead, the badge can be nudged (dx/dy/sizeMul) to avoid overlaps.

- **Storage:** `hpBadgeContextNudges: [HpBadgeContextKey: HpBadgeContextNudge]` (sparse dictionary)
- **Key:** slot + myHeight + myWidth + neighborHeight + neighborWidth
- **Seeding:** `bakeHpContext()` helper called from `applyTunedCharacterScales()`
- **15 pairings baked** as of this session (slots 1 and 2, various body combos)
- **Editor support:** already wired in the layout overlay; values are exported in the "Copy Layout Values" clipboard dump


## 35. SPAWN ARCHITECTURE PLAN (June 13, 2026) — HP buckets, art-repeat rules, dice pity (DESIGN, NOT BUILT)

Settled design for how customers spawn, scale in difficulty, and avoid
repeating — plus where the dice pity timer sits. NONE of this is built yet;
this is the agreed spec so a future session/Claude-in-Xcode builds it the
RIGHT way. The big realization: difficulty and customer-identity are FULLY
DECOUPLED, which removes every conflict the earlier (weighted) framing had.

### 35.1 Three independent systems (no interactions to manage)

1. HP-BUCKET TABLE = difficulty, per round/day, by RANGE.
2. ART-REPEAT EXCLUSION = cosmetic, no-repeat memory at round/day/run scope.
3. DICE PITY TIMER = playability guarantee, lives in DICE logic (§32), not customers.

Because customers are NEVER weighted (user decision, June 13), the art pick
is "grab an unused face" with no odds to distort — so repeat-rules and
difficulty never fight. This supersedes the earlier worry (old § planning)
that weighting + no-repeats conflict: there IS no weighting.

### 35.2 HP-bucket table (difficulty)

- Each round defines an HP RANGE; every customer SLOT in that round rolls
  its HP somewhere in that range (range, NOT fixed — user confirmed).
- Bosses are just a tight range (e.g. 16–16 = exactly 16).
- Example shape (illustrative, real numbers TBD by user balance pass):
    day_1 rounds 1–3 → HP 6–12 ; day_1 round 4 (boss) → 16
    day_2 rounds … → own ranges ; etc.
- One editable table keyed by (dayId, roundIndex). No logic — pure data,
  the home for all future difficulty tuning.
- IMPLEMENTATION NOTE: this REPLACES the current model where HP is baked
  into each named character in PotionShopData. The character's `hp` field
  becomes irrelevant for pooled spawns; HP comes from the round's range
  roll. This is exactly the HP-bucket→random-visual decoupling flagged in
  §29.2 as an endless-mode prerequisite — it's now the live spawn model.

### 35.3 Art-repeat rules (cosmetic exclusion)

Same mechanism (a "used" set the draw excludes), three scopes:
1. WITHIN A ROUND: likely already free — `pool.shuffled().prefix(N)` can't
   pick a dup. Only needs work IF the queue refills mid-round (unverified;
   check `spawnCustomers`/queue-refill before assuming it's free).
2. WITHIN A DAY: a "used today" set; morning records its draw, afternoon
   draws from pool minus used, etc.; resets at day start. Pool (12 gmarkers)
   > day need (3+3+3+1=10), so room exists. OPEN CHOICE: should a debug
   re-entry of a round respect the day's used-set, or be exempt? (Currently
   re-entry redraws fresh — §30/§33.)
3. WITHIN A RUN (#3): "used this run" set; never repeat UNTIL the whole pool
   has cycled, THEN reshuffle and allow repeats. User confirmed this
   cycle-and-reshuffle behavior (June 13).

KEY CONSEQUENCE of decoupling: a cycled-back face is HARMLESS — same picture,
new HP (from the round's range), genuinely a different challenge. So #3 does
NOT require procedural customers; a big-enough art rotation makes repeats
feel rare. (Procedural §29.2 customers would make it literally infinite, but
aren't REQUIRED for endless under this model — a meaningful simplification.)

MATH CONSTRAINT (the only one that survives): true never-repeat holds only
until the art pool is exhausted; past that, cycle-and-reshuffle is the
designed fallback. Per-day #2 needs pool ≥ 10; per-run #3 just needs the
rotation big enough that cycling is infrequent.

### 35.4 Dice pity timer (separate; lives in §32 dice logic)

NOT a customer system. "If Y turns pass without the player rolling a die
that lets them act (attack/heal/etc.), force one into the next deal." Hooks
into the odds-table draw loop (`drawFromBag`/`rollOutcome`, §32). Y is a
balance number to set from real play (why it was deferred — see §32.6).
Keep this mentally separate from art-repeat: customers don't REPEAT (art
exclusion), dice don't STARVE (forced inclusion). Different boxes.

### 35.5 Suggested build order (when greenlit)

1. HP-bucket table (difficulty by range) — foundational; the spawn model
   everything else assumes.
2. Per-round + per-day art-repeat (#1 verify-free, #2 used-set).
3. Per-run no-repeat + cycle-reshuffle (#3).
4. Dice pity timer (needs Y from playtesting first).
Build 1 before 2–3 (they assume art is decoupled from HP). 4 is independent
and can land any time after §32's odds table is exercised in play.

---

## 36. CUSTOMER ANIMATION PLAN (June 15, 2026) — idle boil + hit/attack poses (DESIGN, NOT BUILT)

Goal: customers feel alive — line-boil while ACTIVE (slot 0), and hit/attack
poses while WAITING (slots 1 & 2). NOT built; this is the spec so a future
session / Claude-in-Xcode builds it right. The big advantage: the boil
ENGINE already exists in the Match-3 game and can likely be reused.

### 36.1 What already exists (don't reinvent)

Per MASTER_CONTEXT (Session 25): the Match-3 game has a working line-boil
flipbook — 3 frames, 0.15s/frame, 0.45s/loop, driven by TimelineView
(clock-based, can't freeze), managed by `AnimationCoordinator` (one per
character) with a queue + PRIORITY system (hurt interrupts attack;
victory/defeat interrupt all; repeated attacks merge). Lives in `Shared/`:
- `Shared/AnimationCoordinator.swift` — queue/priority engine
- `Shared/CharacterAnimations.swift` — the boil flipbook driver
- Art convention: `ramp_<state>_boil1/2/3` PNGs; missing frames → static art
- ⚠️ Only AnimationCoordinator may write `character.currentState`

IMPORTANT: these files were NOT in the potion file set when this spec was
written (they're in Shared/, not uploaded). Whoever builds this MUST read
the real AnimationCoordinator.swift + CharacterAnimations.swift first — do
NOT assume the API from this doc; confirm signatures against the source.

### 36.2 The integration point in the potion scene

`PotionShopCustomerInSceneView` (PotionShopCustomerSceneView.swift) renders
the portrait via `sceneAsset: char.scenePortrait` — a SINGLE static image —
around the body render (~lines 898–929), with a white-silhouette variant
for waiting customers (`useWhiteSilhouette = !isActive && ...`). THIS is
where a boil flipbook view replaces the static Image. The scene already
reacts to state: `.waiting/.defeated/.expired`, shake via
`customerShakeCounters`, and the June-13 defeat fade. So the EVENT triggers
for poses largely exist already (see 35.4).

### 36.3 The asks + difficulty

1. IDLE BOIL while active — reuse the boil engine on the active customer's
   scene portrait. Mostly plumbing, low invention. START HERE.
2. HIT + ATTACK poses for slots 1 & 2 — swap to a hit-frame / attack-frame
   when the existing events fire. Today a hit = shake + floating number
   (NO pose change); an attack = `customerShakeCounters` bump + damage.
   Work = art-swap-on-event, triggers already fire.
3. DEFEAT pose — ACTIVE SLOT ONLY (user, June 15). The pose plays DURING the
   existing June-13 defeat exit (`runDefeat()` freezes position + fades over
   0.35s, see §ref) — the pose is just the ART shown while that fade carries
   the customer off (a slump/knockout), NOT a competing animation. Cleanest
   of the four: defeat is TERMINAL (plays once, no loop, no return-to-idle)
   and the AnimationCoordinator already treats victory/defeat as
   interrupt-everything top priority. MAYBE later: if waiting customers (slot
   1/2) become attackable, defeat would need to work in all slots — but for
   now defeat only happens to the active customer, so it's slot-0 only.
4. ALL coexisting (boil loops, hit/attack/defeat poses interrupt, return to
   idle except defeat which is terminal) — EXACTLY what AnimationCoordinator's
   queue/priority already does in Match-3. Proven pattern; reuse value highest.

### 36.4 Existing event hooks to drive poses

- Attack (waiting customer acts): brew sequence already bumps
  `gs.customerShakeCounters[id]` and applies damage → hook the attack pose
  to the same moment.
- Hit (customer takes brew damage): currently shake + floating number only
  → add a hit-frame swap at that event.
- Defeat (active customer's HP hits 0): the June-13 `runDefeat()` in
  PotionShopCustomerSceneView already fires on `customer.status == .defeated`,
  freezing position and fading opacity 0 over 0.35s. The defeat POSE swaps
  the art at that same trigger — the fade/freeze plumbing is done, only the
  frame swap is new. Active slot only for now.
- Expire: already handled (June-13 expire slide).

### 36.5 THE REAL CONSTRAINT — it's ART, not code

Boil/poses are hand-drawn FRAMES, not code effects. Per state, per customer:
- idle boil = 3 frames; hit = ≥1 frame; attack = ≥1 frame; defeat = ≥1 frame
  (slump/knockout; active customer only).
- ~12 gmarkers today, heading toward 50–100. Full boil on every state for
  every customer = a LOT of frames.
- The engine degrades gracefully: missing frames → static art (MASTER_CONTEXT
  confirms "other states show static until boil frames added"). So roll out
  INCREMENTALLY — customer by customer, state by state. Nothing blocks
  partial coverage. (Missing defeat frame = today's plain fade, so defeat
  poses are purely additive.)

### 36.6 Open design decisions (resolve before building)

1. HOW MUCH per customer? Recommend LIGHT to start: boil on IDLE only
   (most-seen), single STATIC poses (no boil) for hit/attack/defeat. Slashes
   art load while still reading as "reacts when hit / winds up to attack /
   slumps when defeated." Full boil-everything is the rich-but-expensive version.
2. REUSE Match-3's AnimationCoordinator, or a slim potion-specific one?
   It's in Shared/ so reusable, but the potion scene is a different render
   path (feet-anchor + scenePortrait) than Match-3 battle portraits. Reuse
   = less new code, more adaptation; slim custom = more code, no Match-3
   entanglement. Decide by reading the coordinator's coupling first.
3. ASSET NAMING: customers currently render ONE `scenePortrait`
   (`gmarker_octo`). Boil needs a frame set per state — decide the
   convention BEFORE drawing art, e.g. `gmarker_octo_idle_boil1/2/3`,
   `gmarker_octo_hit`, `gmarker_octo_attack`, `gmarker_octo_defeat`,
   mirroring `ramp_<state>_boilN`.

### 36.7 Recommended sequencing

START: idle boil on the ACTIVE customer only — one state, reuses the proven
engine, immediately makes the scene feel alive, minimal art (3 frames ×
however many customers you choose to animate first). FEEL the art workload.
THEN: add hit/attack poses (static first, boil later if wanted). Doing all
three states × all customers at once is a big art commitment before knowing
whether the light version already suffices.

### 36.8 Cross-refs

- MASTER_CONTEXT "Character Portrait Animation System" (Session 25) + its
  ANIMATION_ART_GUIDE.md / SESSION_25 doc = the authoritative engine docs.
- This plan slots alongside §34 (spawn architecture) as a planned-feature
  spec; both are art-gated content systems for the same customer scene.

## 37. JUNE 15–18, 2026 — COMBAT/UX FIXES: defeat fade, patience ring, patience=10, boost multiplies

Several real BUILT changes this session (distinct from the planning in
§34–36). Files: PotionShopCustomerSceneView.swift, PotionShopGameState.swift,
PotionShopData.swift.

### 37.1 Defeat exit — fade in place (was: snap to screen right)

A defeated customer used to get yanked from the queue instantly; the queue
re-index + matchedGeometryEffect dragged the dying view rightward before it
vanished ("snap to screen right"). FIX: `runDefeat()` in
PotionShopCustomerSceneView freezes the customer at its current spot
(`defeatFrozenX/Y`, `defeatFrozen`) and fades opacity 0 over 0.35s, opting
OUT of the queue reposition and matchedGeometry (via new
`PotionShopConditionalMatchedGeometry` modifier, `active: !defeatFrozen`).
Triggered on `customer.status == .defeated`. Expired customers' intentional
slide-off (storm out, `expireSlideX = 200`) is untouched — defeat ≠ expire.
NOTE: `PotionShopConditionalMatchedGeometry.id` is `UUID` (customer.id is a
UUID, not String) — an early build error was a String/UUID mismatch.

### 37.2 Patience ring not depleting — STALE-COPY bug (the real one)

Symptom: the green ring around the 3 profile buttons sat full no matter how
many brews. Patience WAS ticking correctly in the brew sequence (doBrew
Phase 5, `customers[cIdx].patience -= tick`) — the ring just wasn't seeing
it. ROOT CAUSE: the ring read `customer.patience` from the `let customer`
COPY passed into the profile-button view, which went stale; the live decrement
was on `gs.customers`. FIX: new helpers in BOTH ring-drawing structs
(`PotionShopProfileButtonView` AND `PotionShopInspectStripView` — there are
TWO) look the customer up live by id:
    `liveCustomer = gs.customers.first { $0.id == customer.id } ?? customer`
    `livePatience / liveMaxPatience`
and the ring/trim/color/animation all read those. ALSO thickened 3→6pt with
a gray track + round line caps so the per-tick step is visible.
GOTCHA THAT BIT US: the file has TWO structs each drawing a patience ring;
the first fix added helpers to one struct but edited the ring in the other →
7 "cannot find in scope" errors. Both structs now have the helpers. When
touching the profile ring, remember there are two.
XCODE QUIRK: after the successful fix, stale red "cannot find in scope"
errors lingered in the issue navigator even though the build SUCCEEDED and
the rings worked — ghost diagnostics from the prior failed compile. Cleared
by reopening the file / deleting derived data. A successful build = correct
code; surviving errors are an editor display bug, not real.

### 37.3 Patience timing + value

- Patience ticks ONCE PER BREW, during the brew sequence AFTER damage/attacks
  resolve (doBrew Phase 5). It is NOT a background timer — it does not move
  while the player just sits there. This matches the intended "tick at the
  top of every turn, after a brew."
- All 15 gmarker customers set to `patience: 10` in PotionShopData (Day 1
  cast). Old hand-authored characters left untouched (Day 2+ unaffected).
  Per-customer patience values will be tuned later (placeholder 10 for now).

### 37.4 Boost — multiply EXPERIMENT, reverted to ADDITIVE (June 18)

History: June 15 changed boost from additive to multiplicative
(`multiplier *= boost.value`, also applied to heal/shield). June 18 the user
REVERTED to ADDITIVE — the multiply was too swingy. CURRENT (canonical)
behavior in `computeBrew`:
- `multiplier += boost.value * 0.5` — a 4-boost gives ×3 to adjacent dice.
- Boost affects DAMAGE dice only (potency, stability). Heal/shield are plain
  `baseValue`, NOT boosted.
Which dice a boost REACHES still comes from `PotionShopDieRules.affectedNodes`;
the specific reach rules (§ planning #3) remain NOT wired — today it's
whatever that struct returns.

### 37.5 Still open / not built (unchanged by this session)

- Specific boost-reach rules (which nodes a boost affects) — §ref planning #3.
- Spawn architecture (§35): HP-bucket table, art-repeat rules, dice pity.
- Customer animation (§36): idle boil + hit/attack/defeat poses.
- A NUMBERS-TESTING system (user gathering balance numbers): discussed three
  levels — (1) live-tunable values + on-screen readout of hidden state
  (patience/damage/composure each turn), (2) a simulator that dry-runs a
  round N times for win-rate, (3) an analytical math dump. Recommended
  starting at level 1 (most confusion has been "couldn't see the numbers,"
  e.g. the patience-expiration "slot-1 death" and this ring bug). NOT built.
## 38. JUNE 18, 2026 — PER-CHARACTER FLAVOR (order phrases + trait names), banner relabel, boost FINAL

Cosmetic per-character flavor system BUILT, plus a banner rework and the
final word on boost. Files: PotionShopModels.swift, PotionShopGameState.swift,
PotionShopData.swift, PotionShopCustomerSceneView.swift. (These FOUR must
ship together — the feature spans all of them; a stale copy of any one
causes "has no member 'chosenOrderPhrase/chosenTraitName'" build errors,
which happened twice this session due to partial uploads.)

### 38.1 The model chosen — PER-CHARACTER pools (not global)

User's decision (vs the global-pool idea in §35): each character owns its
OWN bag of flavor; on spawn the game picks one at random from THAT
character's bag. Result: a customer varies what they say / which trait shows,
but always stays in-character (no global mixing, no incoherent combos). This
is COSMETIC only. Functional stats (HP, attack) are unchanged and remain
per-character numbers for now (their bucketing is still §35 future work).

### 38.2 What was added (data model)

- `PotionShopCharacter` (Models) gained two optional arrays, default empty:
  `var orderPhrases: [String]` and `var traitNames: [String]`.
- `PotionShopCustomer` (live, GameState) gained `var chosenOrderPhrase` and
  `var chosenTraitName`, picked ONCE at spawn from the character's bags and
  held stable (don't re-roll per render). Both spawn sites set them:
    `chosenOrderPhrase: char.orderPhrases.randomElement() ?? char.orderDialogue`
    `chosenTraitName: char.traitNames.randomElement() ?? ""`
- Back-compat: empty bags fall back to the old single `orderDialogue` /
  no trait, so non-gmarker characters are unaffected.

### 38.3 Banner layout (PotionShopCustomerSceneView, inspect strip)

TWO rows now:
- TOP: `name • [trait] number` — the word "Atk" was REMOVED; the trait word
  is the label, the bare number is the attack value (kept visible for
  testing). e.g. "Rex • Towering 2". Trait shown in accent color; hidden if
  the bag is empty.
- BOTTOM: the order PHRASE the customer is "saying" (`orderLineToShow`,
  prefers chosenOrderPhrase → orderDialogue → orderName). 2-line limit with
  slight auto-shrink since real phrases run longer than "A Potion, Please".

### 38.4 ⚠️ WHERE TO WRITE / REPLACE TEXT (for the user)

All flavor lives in `PotionShopData.swift`, one block per gmarker right after
`trait: nil,`. As of June 18 each of the 15 gmarkers has 3 REAL placeholder
phrases + 3 trait words (themed, usable as-is). TO EDIT:
- Open PotionShopData.swift, find each `"gmarker_*": PotionShopCharacter(`.
- The `orderPhrases: [ ... ]` array = what that customer SAYS (bottom banner
  row). Replace/extend freely — add as many lines as you want (10–30 fine).
- The `traitNames: [ ... ]` array = the PERSONALITY word by their name.
  Replace/extend freely.
- These are COSMETIC — editing them never changes HP/attack/mechanics.
- Current placeholder content (replace at will): e.g. dino/Rex says
  "Rawr — a big one, brewer. Big." with traits Ancient/Towering/Roaring;
  demon "Your finest, or your last." with Wrathful/Smoldering/Dread; etc.
- Non-gmarker (Day 2+) characters have EMPTY bags → they show their old
  single orderDialogue and no trait until you write bags for them too.

### 38.5 BOOST — FINAL behavior decisions (history of flip-flops)

Boost has changed several times; current state and the PENDING change:
- June 15: changed additive→MULTIPLICATIVE (`multiplier *= boost.value`),
  applied to heal/shield too. Too swingy.
- June 18 (early): reverted to ADDITIVE-TO-MULTIPLIER
  (`multiplier += boost.value * 0.5`; a 4-boost → ×3), damage dice only,
  heal/shield NOT boosted. THIS is what's in the delivered code right now.
- June 18 (PENDING — user's latest ask, NOT yet built): boost should ADD ITS
  FACE VALUE FLAT to connected die VALUES, not a multiplier. "A 4-boost adds
  4 to all values" → a 3-potency next to a 4-boost = 3+4 = 7. Open confirms
  before building: (A) add to die value pre-effect [expected] vs (B) +flat to
  final output; whether it hits heal/shield too ["all values" suggests yes];
  whether two boosts stack additively [expected yes]. The boost loop in
  `computeBrew` is the single edit site (currently
  `multiplier += Double(adjDie.value) * 0.5`). Reach still from
  `PotionShopDieRules.affectedNodes` (specific reach rules still NOT wired).

### 38.6 Process note — stale uploads (recurring)

Third+ time this session a partial/old upload undid cross-file work (the
flavor feature missing entirely from one upload; boost reverting; the
context doc itself arriving stale at §33 while the live doc was §37). RULE:
features here span multiple files — always pull the WHOLE delivered set, and
treat the highest-numbered context doc as canonical. When diagnosing, grep
the expected symbols across files (`chosenOrderPhrase`, `orderPhrases`,
`multiplier +=`) to spot which file reverted.
## 39. DYNAMIC BOARD PLAN (June 18, 2026) — per-day node/connection variation (DESIGN, OPTIONS OPEN, NOT BUILT)

Idea: every day the cauldron board is slightly rearranged — different
connections (and maybe different node positions) — so strategy shifts. User
undecided on the variants; this captures the analysis so it isn't re-derived.

### 39.1 Key finding — the board is already data-driven

`PotionShopBoard` (PotionShopModels.swift) is just two constants:
`static let nodes: [Node]` (12 positions) and `static let edges: [(Int,Int)]`
(connections). EVERYTHING else reads from them and adapts: node views,
connection lines, drag targets (loop over nodes.count), and the reach/boost
math (BFS over edges via `neighbors`/`neighborsWithin`). So "dynamic board"
fundamentally = swap what's in nodes/edges per day. The machinery to USE a
different board already exists; only the SELECTION is missing.

### 39.2 Two axes the user is deciding between

A. WHAT varies:
   - CONNECTIONS ONLY (easier/safer): fixed 12 node positions, different
     edge list per day. Same dots, different lines. Keeps ALL visual tuning
     valid (perNodeOffsets, cauldron art alignment, drag frames) since
     nodes don't move. RECOMMENDED first version.
   - NODES + CONNECTIONS (harder): positions move too → drags the whole
     visual-tuning system in (perNodeOffsets, bowl art, editor all assume
     fixed positions). More involved.
B. HOW chosen:
   - PREDETERMINED BUCKET (recommended): hand-author 3–5 layouts, pick one
     per day (by day number or random from bucket). Every layout is seen +
     tuned + approved; controllable difficulty/feel; fits the existing
     tune-in-editor→save-values workflow.
   - FULLY RANDOM: generate topology each day. More variety but unpredictable
     (can be trivial, brutal, or ugly); needs guardrails (all nodes
     reachable, edge count in range) and still won't look as intentional.

### 39.3 Nice property — reach is graph-hops, so connections drive strategy free

Reach = graph hops over `edges` (a die reaches nodes N connections away),
NOT physical distance. So changing the edge list automatically changes
reach/boost strategy at runtime — dynamic connections don't just LOOK
different, they PLAY different with no extra code.

### 39.4 Recommendation + sequencing

Start with CONNECTIONS-ONLY + PREDETERMINED BUCKET: lowest risk, reuses all
tuning, every layout pre-approved, and reach-changes-for-free gives real
gameplay variety. Implementation: convert nodes/edges from `static let` to a
per-day SELECTION (board chosen at day start, like HP buckets §35). Belongs
near the §35 day/round-driven systems. Moving-nodes and fully-random are
possible later but trade designed-feel + tuning-stability for unpredictability.
STATUS: user undecided (June 18) — do NOT build until A + B are chosen.
## 40. RUN SYSTEM PLAN — boons (deck-building) + relics (June 18, 2026) (DESIGN, NOT BUILT)

The roguelite spine: a persistent RUN, a deck that grows via BOONS, and
optional always-on RELICS. This is the same neighborhood as the endless-mode
idea (§35) and should be built as ONE coherent run-system, not piecemeal.
Standard roguelite architecture (cf. Slay the Spire cards + relics). User has
zero coding background — this spec is the full blueprint for a future
session / Claude-in-Xcode; build nothing until greenlit.

### 40.1 The foundation — a RUN-STATE CONTAINER (build this first, always)

Today `PotionShopGameState` (an @Observable class) already persists across
rounds/days (dayId, roundIndex, composure, potionsBrewed, bag). BUT
`buildStartingBag()` REBUILDS the deck from a hardcoded list every round
(called at lines ~398, ~463) — so the deck resets constantly. That reset is
the ONE thing between today and deck-building.

THE FOUNDATION: an explicit run-state bundle that survives the WHOLE run and
resets ONLY on death / new run. It holds:
  • the player's RUN DECK (accumulated dice — replaces the per-round rebuild)
  • the list of BOONS taken
  • (later) the list of active RELICS
  • run progress (day, etc.)
KEY CHANGE: `buildStartingBag()` runs ONCE at run start to seed the deck;
after that the deck only changes when a boon modifies it. The deck STOPS
being regenerated each round and instead carries forward.
⚠️ CRITICAL: even for a boons-ONLY first version, build the run-state
container PROPERLY. Hacking deck-persistence in ad hoc is the one decision
that's expensive to reverse — a clean container keeps relics (40.3) an
optional later add with no rebuild.

### 40.2 BOONS — deck-building (the EASIER half, build first)

User's model: boons add/upgrade dice, and a die can CARRY A RULE that affects
the run when that die is used. Your dice get stronger.
- A DIE becomes: type + value + tier + OPTIONAL rule(s). (Today it's
  type+value+tier; needs an optional modifier bundle added.)
- A BOON = "add this die to your run deck" OR "upgrade a die in your run
  deck" (upgrade = same mechanism pointed at an existing die). The die may
  carry a rule (e.g. an upgraded boost die carries a higher value / a special
  reach).
- PERSISTENCE IS AUTOMATIC: the rule rides on the die, the die rides in the
  run deck, the run deck carries forward. Acquire the die → its effect is
  part of your run until the run ends. No separate global system needed —
  everything flows through the deck (the channel that already exists).
- WHY EASIER: reuses the existing bag/deck. The only structural work is
  (a) persist the deck (40.1), (b) let a die carry a rule, (c) the menu (40.4).

### 40.3 RELICS — always-on run effects (the HARDER half, optional later layer)

User's model: relics carry rules/values/effects that persist for the ENTIRE
run, independent of the deck (e.g. "Amulet: +1 focus every evening & night
round").
- A relic is NOT carried by a die. It's a free-floating, always-on effect at
  the RUN level, firing on triggers unrelated to the deck.
- REQUIRES (the new work relics need and boons don't):
  1. a run-level LIST OF ACTIVE RELICS (lives in the 40.1 container).
  2. TRIGGER HOOKS scattered through the game — start-of-round, end-of-round,
     start-of-day, on-brew, on-defeat, etc. Each moment must "check active
     relics and fire any that apply here." This is essentially a small EVENT
     system, and it's why relics are harder — not any single relic, but the
     wiring of moments-that-announce-themselves.
- WHY IT'S A CLEAN SECOND LAYER: relics are just a SECOND list added to the
  same run-state container from 40.1. Boons don't get rebuilt; relics slot in
  beside them. The only genuinely new work is the trigger hooks.

### 40.4 The BETWEEN-ROUNDS MENU (frequency is a SETTING, not a structural choice)

After a round (or day) clears: pause, show 2–3 boon cards, player picks one,
it's applied to the run deck. New UI (a card-choice screen) + a "pick N random
boons from the boon pool" roll.
FREQUENCY — every-round vs every-day: this is JUST A TRIGGER, identical system
either way. Build it as a FLAG ("boon menu: every round / every day") so the
user can toggle and playtest which feels better — NO rebuild to switch, no
"remove and expand." (Same toggle pattern as the dice/scene flags.)

### 40.5 Difficulty / sequencing answers (for the user)

- EASIER: boons (deck-building) — reuses the deck system. Relics need a new
  event/trigger layer.
- "Boons for a few days, then relics?" YES, the right order. Both share the
  40.1 run-state container; build it properly with boons, and relics become a
  second list + trigger hooks later with no rebuild.
- "Both or one?" Don't have to decide now. A proper run-state container keeps
  relics OPTIONAL for free. Only expensive mistake = ad-hoc deck persistence.
- BUILD ORDER: (1) run-state container + persist deck; (2) dice carry rules;
  (3) boon menu (frequency flag); (4) [later] relics list + trigger hooks.
- Interlocks with §35 (spawn/HP buckets), §39 (dynamic board) — all are
  per-run/per-day systems hanging off the same run-state. Design together
  against real balance numbers; don't build ad hoc before those land.
## 41. JUNE 18, 2026 — RUN SYSTEM TEST BUILD (boons + persistent deck) — BUILT

First testable cut of the roguelite spine from §40. BUILT (test, not final).
NEW FILE: PotionShopRunSystem.swift (must be ADDED to the Xcode target — it's
a new file, not a replacement). Also changed: PotionShopGameState.swift,
PotionShopModels.swift, PotionShopGameView.swift, PotionShopDebugMenu.swift.

### 41.1 What was built

- RUN-STATE CONTAINER (§40.1): `PotionShopRunState` (deck + boonsTaken) lives
  on PotionShopGameState as `run`. The deck is SEEDED ONCE at run start and
  carries forward; it is NO LONGER rebuilt each round. Both deal sites now do
  `ensureRunDeck(); bag = run.deck.shuffled()` instead of buildStartingBag().
  resetGame() reseeds (new run = fresh deck).
- BOONS (§40.2): `PotionShopBoon` with effect `.addDie(type, rule)` or
  `.upgradeDie(type, amount)`. `PotionShopBoonPool` = 8 placeholder boons,
  draws 3 per menu. `run.apply(boon)` mutates the deck.
- DICE CARRY RULES: `PotionShopBagDie` gained `var rule: PotionShopDieRule`
  (bonusValue + label). `PotionShopDie` gained `var ruleBonus: Int`. The
  bonus threads bag→live die→computeBrew (`baseValue = die.value +
  dieValueMod + die.ruleBonus`).
- BOON MENU UI: new `.choosingBoon` phase; `PotionShopBoonMenuView` (3 cards,
  tap to pick, shows a live deck summary so you watch it grow). advanceRound
  routes through `offerBoons(thenAdvanceToDay:)` → menu → `chooseBoon` →
  continues to next round or dayWon.
- FREQUENCY FLAG: `boonFrequency` (.everyRound / .everyDay) — toggle, no
  rebuild (§40.4). CURRENT DEFAULT: .everyDay (changed June 18, see §44).

### 41.2 KNOWN TEST LIMITATION — Day-1/Day-2 type override

Because Day 1 & 2 use the §32 unified-roll (spin DECIDES type), a boon-added
"potency die" grows the deck and its ruleBonus still applies, BUT its TYPE is
re-rolled by the slot machine when drawn — so you can't yet see boon
type-TARGETING on those days (deck-growth + bonus magnitude ARE visible).
On non-unified days the type would stick. → This limitation is exactly why
the DICE-MODEL PIVOT (§42, next) is happening.

### 41.3 What's NOT in this build

Relics, dynamic board, real balance values, focus mechanics. All deferred.

## 42. DICE-MODEL PIVOT — bag-of-real-dice (Dice-in-the-Dungeon model) — BUILT June 18, 2026

Major decision that REVISES §32. The user wants Dice-in-the-Dungeon
mechanics, NOT the §32 "spin decides type" slot machine. NOT yet built;
this is the agreed spec for the next build.

### 42.1 The pivot

OLD (§32, ii-a): the bag is ODDS; the spin DECIDES a die's type+value; a die
has no identity until it lands. NEW: the bag holds REAL TYPED+TIERED DICE you
own; you draw a random assortment; each drawn die's TYPE is fixed (its own
identity, from the bag); the spin is COSMETIC animation that lands on that
die's OWN type; only the VALUE rolls. Strategy = your bag composition (what
you own, shaped by boons), not reacting to a slot machine.

Player-facing: looks almost identical (dice still tumble + stop). What
changes is MEANING — the tumble decorates a die that already knows what it
is, instead of choosing what it is.

### 42.2 A die = TYPE + TIER + (rolled VALUE) + (rule BONUS)

- TYPE — fixed, from the bag (potency/boost/heal/shield/stability; later
  mirror, bomb, etc. — new types are just enum + brew-math additions, each
  can have tiers + be boons).
- TIER — basic → silver → gold, fixed per die, UPGRADEABLE. Tier sets the
  VALUE RANGE the die rolls in (e.g. you may never roll a 4-potency until
  silver). Code ALREADY has `PotionShopDieTier` + `tier.rollFace()` — it's
  just bypassed today by the §32 override. The pivot reconnects it.
- VALUE — rolled fresh each draw, WITHIN the tier's range. (Later: a
  weighting table ties values to HP buckets/day — see §35.)
- RULE BONUS — TYPE-WIDE flat add from boons/relics ("all boosts +2"),
  applied to whatever value is rolled, on top, regardless of die. NOTE: this
  is a CORRECTION to §41's per-die bonus — the user wants the rule to follow
  the TYPE across every die of that type, not ride one physical die.

### 42.3 Boons/relics under this model

- Boon: ADD a die (type+tier) to the bag, or UPGRADE a die's TIER (raise its
  value range), or apply a TYPE-WIDE rule ("all X +N").
- Owning a die ≠ drawing it every turn — you still draw a random assortment;
  the bag composition just makes some types more likely (they're physically
  in the bag). e.g. 3 boost dice + "boost +2": you might draw 1, it rolls its
  own value, +2 applies; the other 2 stay in the bag.
- FOCUS (how many dice you can PLAY) becomes a run-level number boons/relics
  can change (+1 focus, or +1 focus / −1 boost-value trade-offs). Run-state
  layer, same as relics.

### 42.4 Build implications

- The §32 deal currently OVERRIDES type via `rollOutcome`. Pivot: on
  unified-roll days the deal reads each drawn bag die's REAL type, rolls a
  value via its tier, and the cube cosmetically spins to that die's own
  type-face. Centralized gate already exists: `usesUnifiedDiceRoll` (Day 1 +
  Day 2) — ONE place to change.
- Everything downstream (place/brew/boon bonus) already works with a typed
  die, so it mostly "just works" once the deal respects bag types.
- Sequencing: Day 2 was made to MIRROR Day 1 first (done, §below) so there
  are two comparable days before the pivot.

### 42.5 Day 2 mirrors Day 1 (BUILT June 18, pre-pivot step)

Day 2 now matches Day 1: all rounds feet-anchor + gmarker random pool +
3/3/3/1 counts; `currentRoundUses3DDice` and `usesUnifiedDiceRoll` extended
to day_2. Old Day-2 cast (sister_halla, bram, carmilla, royal_envoy…) no
longer referenced but kept in the characters dict (Day 3+ / pickers use them).
Files: PotionShopData.swift, PotionShopGameState.swift.
## 43. JUNE 18, 2026 — DICE PIVOT BUILT + BOOST REBUILT (ADD) + type-wide boons — BUILT

Implements the §42 pivot and reworks boost from multiply→add, plus type-wide
boons. Files: PotionShopGameState.swift, PotionShopCauldronView.swift,
PotionShopRunSystem.swift.

### 43.1 Dice pivot — now BUILT (was §42 plan)

On `usesUnifiedDiceRoll` days (Day 1 + Day 2), `drawFromBag` and `reroll3DDice`
now build each die as: TYPE from the bag (`bd.type`, its own identity), VALUE
from `bd.tier.rollFace()` (tier ranges: basic 1–4, silver 2–5, gold 3–6),
and `faceValue = PotionShop3DDiceAssetMap.faceId(forType:)` so the cube
COSMETICALLY spins to land on the die's OWN type. The §32 slot-machine
(`rollOutcome` deciding type) is no longer called in dealing (function kept,
unused). Reroll preserves type, only re-rolls value. Badge shows die.value
(tier-rolled). Boons now target real types.

### 43.2 BOOST rebuilt — ADD, not multiply (FINAL for now)

computeBrew Stage 2 rewritten. THE MODEL (plain language):
  STAGE 1 (the die's number) = rolled value + inspiring bonus + the die's own
    per-die boon bonus (ruleBonus, which now also includes type-wide bonus).
  STAGE 2 (boost) = every boost CONNECTED to the die adds its value; all
    connected boosts SUM, then that sum is ADDED to the die's number.
    • Boost AFFECTS EVERY TYPE now (potency, stability, heal, shield) — not
      just damage.
    • A boost does NOT boost another boost (boosts add to non-boost dice only).
    • A boost's contribution = adjDie.value + adjDie.ruleBonus (so "all boosts
      +2" makes a 4-boost add 6).
  APPLY:
    • potency → damage += total
    • stability → damage += total × 0.5  (clean HALF of potency for now;
      stability's real "stabilize the cauldron" role is UNDECIDED)
    • heal → healing += total
    • shield → shielding += total
    • boost → contributes nothing itself
  EXAMPLE (user's screenshot): 5-shield with two 3-boosts = 5 + (3+3) = 11 shield.

HISTORY: boost was multiply (§32-era), then additive-to-multiplier (§38.5),
now ADD-to-value (§43). This is the current/final-for-now model.

### 43.3 Boons — per-die AND type-wide (both now exist)

- PER-DIE (`.upgradeDie`): +N on a specific die in the deck (rides on that
  die's rule.bonusValue). Already existed.
- TYPE-WIDE (`.typeWideBonus`, NEW): +N to EVERY die of a type for the rest
  of the run. Stored in `run.typeBonuses[type]`; applied in drawFromBag as
  `combinedBonus = bd.rule.bonusValue + run.typeBonuses[bd.type]`. New pool
  boons: Reinforced Shields (+2 shield), Healing Mastery (+1 heal), Amplified
  Boosts (+2 boost), Potent Brew (+1 potency).
- Both persist for the whole run; reset on new run (seedStartingDeck clears
  typeBonuses).

### 43.4 NOT yet built — trade-off boons need the EVENT SYSTEM

User wants explicitly-worded boons WITH trade-offs, e.g. "+2 boost, lose 1
health every time a boost die is used." The downside ("every time X is used")
needs a TRIGGER/event system (same machinery relics need, §40.3). The simple
additive type-wide boons (43.3) are built; the trade-off/triggered boons are
the NEXT step (user said: test this first, then do the event system).
## 44. JUNE 18, 2026 — BOON FREQUENCY set to EVERY DAY + tier-upgrade status

### 44.1 Boon menu now fires per-DAY (was per-round)

`boonFrequency` default changed `.everyRound` → `.everyDay` in
PotionShopGameState. Flow now: play all rounds of a day → day clears → boon
menu (1 of 3) → dayWon screen → next day. The everyDay path was already
wired symmetrically (advanceRound day-boundary branch → offerBoons(
thenAdvanceToDay: true) → chooseBoon → .dayWon), so this was a ONE-LINE
flip, no rebuild. Effect: slower deck growth (one boon per full day).
TO SWITCH BACK: flip the one default to .everyRound. (Could be wired to a
debug-menu toggle later for self-serve playtesting — not done yet.)

### 44.2 Tier-upgrade boon — NOT built (clarification)

The tier system (basic/silver/gold → value ranges 1–4 / 2–5 / 3–6) is fully
wired and the pivot (§43) USES it, but NOTHING currently promotes a die's
tier. The existing `.upgradeDie` boon is a flat +N bonus (misleadingly
named) — it does NOT change tier. A real `.upgradeTier(type:)` boon
(basic→silver→gold, raising the value RANGE) is a small clean addition that
does not yet exist. Seeded dice are all `.basic` and stay basic. Build when
desired — slots next to the §43.3 type-wide boons.
## 45. JUNE 20, 2026 — IN-THE-MOMENT FEEDBACK (realized values, Ednar bubble, dynamic HP, boost lines) — BUILT

Inspired by Die in the Dungeon's "marker" feedback (user shared screenshots).
Goal: show the player what their dice are DOING before they brew, instead of
making them do the math. Files: PotionShopGameState.swift,
PotionShopCauldronView.swift, PotionShopCustomerSceneView.swift,
PotionShopGameView.swift. Boon frequency: back to .everyRound.

### 45.1 Realized-value preview (per-die final number)

`computeBrew()`/`BrewPreview` now also returns `nodeValues: [Int:Int]` — each
placed die's FINAL value after boosts/bonuses (stability stored as its halved
output; boost dice omitted). The board overlays this as a clean number badge
on each placed non-boost die (e.g. a 3-potency next to a 4-boost shows "7",
NOT "3+4"). Positioned at the node's UPPER-RIGHT corner (notification style,
zIndex 50) after it was hidden behind the node below at first. Gated on
`!gs.isAnimating` so it only shows while PLACING, not mid-brew.
`var livePreview: BrewPreview { computeBrew() }` is the cached accessor the
views read.

### 45.2 Ednar heal/shield bubble

Overlay to Ednar's LEFT (PotionShopEdnarView) showing the current brew's
healing ("+X", green) and shielding ("🛡 #", blue) as dice are placed. Only
appears when healing/shielding > 0; gated on !isAnimating.

### 45.3 Dynamic active-customer HP + slot-machine roll on swap

Active customer's HP previews live as dice are placed (active 20, board 8 →
shows 12), clamped at 0. THE KEY BUG FIXED: real hp is reduced at the brew
damage phase but placements don't clear until much later, so the preview was
subtracting damage AGAIN from already-reduced hp during the animation →
gated on !isAnimating so brew shows real hp dropping once.
ROLL ON SWAP (PotionShopRollingHPText, new view at end of CustomerSceneView):
when a customer BECOMES active via swap, the HP number slot-machine-spins
from their ORIGINAL hp down to the board-adjusted value (16 → reel → 12).
Placing dice on the already-active customer updates INSTANTLY (no spin) — the
spin is ONLY for swaps. Robust to SwiftUI recreating the view on swap (spins
from onAppear-if-active-with-damage AND onChange(isActive)). A `spinning`
flag blocks the instant-update path from snapping mid-reel.
TIMING KNOBS (top of PotionShopRollingHPText):
  • `spinStartDelay` (currently 0.60) — seconds to wait after the tap so the
    reel starts AFTER the swap slide settles, not during it.
  • reel length: `let ticks = min(10, 5 + span)` (currently) — bigger = longer.
  • reel speed: the `interval` fn `0.018 + 0.085*(p*p)` — fastest→slowest tick.

### 45.4 Boost connection lines — gold + pulsing

PotionShopNodeConnectionLines now takes `gs` and computes `boostEdges`: edges
where one end is a placed boost and the other a non-boost die the boost
REACHES (asks the boost's own reach, consistent with §43 boost direction).
Those edges draw GOLD and PULSE (opacity 0.55→1.0, width 4→6) via a
TimelineView(.animation) sine; other edges stay static green. Shows the
player what a boost is feeding.

### 45.5 Cauldron rescale-on-boon-screen bug — FIXED

The boon menu's full-screen background used `.ignoresSafeArea()`, which
momentarily changed the geometry the GameView GeometryReader reads to size
every section (header/scene/cauldron/tray all = totalHeight × percent), so
the cauldron + nodes visibly rescaled when the boon screen appeared. FIX:
`phaseOverlay` pinned to `geo.size` and given `.ignoresSafeArea()` at THAT
level; the boon menu's inner background no longer ignores safe area. Layout
underneath stays put.

### 45.6 Recommendations given (for later)

Beyond what's built, suggested but NOT done: a live BREW TOTAL near the brew
button ("Damage 11 / Heal 5 / Shield 4"). The realized per-die numbers + the
Ednar bubble + dynamic HP cover most of the need; a single total is the
natural next add if the player still can't read the whole brew at a glance.
## 46. JUNE 20, 2026 — feedback polish: burst on HP badge, Ednar bubble repositioned, particle burst (active only)

Follow-ups to §45. File: PotionShopCustomerSceneView.swift.

### 46.1 Damage particle burst

`PotionShopDamageBurst` (new view, end of file): radial burst of red shards
fired via `burstTick` when the ACTIVE customer is hit by a brew (gated on
`gs.queue.first == customer.id` so waiting customers attacking don't burst).
Now lives INSIDE the HP badge ZStack, so it inherits the EXACT badge
position/size configured in the debug menu (no separate offset to keep in
sync). Shake already fired on damage; this adds the particle pop.

### 46.2 HP "stays down" on brew (no flash-back)

`PotionShopRollingHPText` gained an `isAnimating` param. During a brew the
displayed HP HOLDS the previewed value and follows realHP DOWN as the damage
phase applies, instead of snapping back up to pre-damage hp then dropping.
(The earlier flash was target reverting to actual hp once isAnimating turned
the preview off.)

### 46.3 Ednar heal/shield bubble — POSITION KNOBS + future art

The bubble was originally placed to Ednar's LEFT, but Ednar sits at the far-
LEFT screen edge, so it was clipped off-screen (NOT behind the image as first
suspected). Moved to his INWARD side.
TO REPOSITION (PotionShopEdnarView, in PotionShopCustomerSceneView.swift):
  • `.overlay(alignment: .topTrailing)` (~line 527) — the ANCHOR CORNER.
    Change to .topLeading / .bottomTrailing / .center / .leading / etc.
  • `.offset(x: 30, y: 10)` (~line 554) — fine-tune nudge in points
    (x: +right/−left, y: +down/−up).
⚠️ FUTURE: the heal/shield bubble (and likely the realized-value badges and
damage shards) are placeholder SwiftUI shapes/text — user plans to REPLACE
these with IMAGE ASSETS later. Keep the values/positions easy to retarget.

### 46.4 Realized-value badge position

Moved to the placed die's upper-RIGHT corner (`.offset(x: 16, y: -16)`,
zIndex 50) after it was hidden behind the node below at first.
---

**End of CAULDRON_CONTEXT.md**
