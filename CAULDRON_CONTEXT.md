# CAULDRON_CONTEXT.md
**Ednar's Potion Cauldron — Full Project Context**

> **Last Updated:** May 25, 2026 (evening) — Day 3 (flex-day RNG test) built with 13 guide_* characters, auto-spacing queue layout for any width/height combo, new bucket cases (superShort/tallHat/floater + WidthBucket enum). Day 1/2 untouched. See §25. Earlier May 25: art template floor shifted to y=1500. See §24. May 24 (eve): badge body-follow + waiting2 overrides. See §23.17.
> **Status:** Phase 7 complete + partial Phase 8. Game is playable end-to-end for Day 1 → Day 2. Art assets pending.
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

**End of CAULDRON_CONTEXT.md**
