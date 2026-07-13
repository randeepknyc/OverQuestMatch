# ENNA'S TAVERN — CARD GAME CONTEXT
**OverQuestMatch3 → EnnaCardGame module**

> **Last Updated:** May 25, 2026 (Initial context document created)
> **Status:** ✅ PLAYABLE — Core systems complete, content is the editable surface
> **Style:** Reigns-style swipe card game (left/right choices, meter management, narrative)

---

## 🎯 WHAT THIS GAME IS

**Enna's Tavern** is a swipe-based narrative card game inspired by *Reigns*.
The player makes binary choices (swipe left or right) on story cards. Each choice changes meter values. When meters hit extremes, things happen — narrative threshold events fire, special cards get injected, or the game ends.

The story unfolds across **3 progressively unlocking acts**, each adding a new layer of meters and stakes.

---

## 📁 FILE MAP

All files live in: `OverQuestMatch3/EnnaCardGame/`

| File | Purpose | Edit For |
|---|---|---|
| `CardGameModels.swift` | All data types (MeterType, Card, MeterEffect, CardCondition, ThresholdEvent) | **Don't edit** — only touch if changing the type system itself |
| `CardDatabase.swift` | All cards, starting meter values, threshold events, act unlock timing | ✅ **CONTENT — edit this for cards, numbers, story, thresholds** |
| `CardGameViewModel.swift` | `@Observable` game state, meter tracking, card draw, threshold checking, act progression | Edit for **logic/rules** changes |
| `CardGameView.swift` | All UI: swipe card, meter panel, overlays, game over screen, act indicator | Edit for **visual/UI** changes |

**Hookup:** Connected via `Navigation/GameSelectorView.swift` with `case .ennaCardGame: CardGameView()` and `case ennaCardGame` in the `GameType` enum.

---

## 🧱 ARCHITECTURE OVERVIEW

- **iOS 17+ SwiftUI**, `@Observable` pattern (not Combine, not `@StateObject`)
- `CardGameViewModel` owns all state and exposes it as `@Observable` properties
- `CardGameView` reads state via `@State private var viewModel = CardGameViewModel()`
- Cards are drawn randomly from a filtered pool (act-appropriate, condition-met, not played-once)
- Threshold events fire only ONCE per run (tracked in `firedThresholdKeys`)
- Injected cards (from thresholds) bypass random draw on the next turn

---

## 📊 THE 12 METERS (0–100 each)

All meters run from **0 (catastrophic low) to 100 (extreme high)**, starting at values defined in `CardDatabase.startingValues`.

### Act 1 — Enna Personal *(available from start)*
| Meter | Color | Icon | Starts at |
|---|---|---|---|
| Resolve | Red | heart.fill | 60 |
| Coin (personal) | Yellow | dollarsign.circle.fill | 45 |
| Reputation | Orange | star.fill | 50 |
| Secrets | Purple | eye.slash.fill | 10 |

### Act 2 — Tavern Vitals *(unlocks after 10 cards played)*
| Meter | Color | Icon | Starts at |
|---|---|---|---|
| Tavern Coin | Green | bag.fill | 55 |
| Regulars | Blue | person.3.fill | 50 |
| Stock | Brown | shippingbox.fill | 60 |
| Order | Teal | checkmark.shield.fill | 55 |

### Act 3 — Factions *(unlocks after 25 cards played)*
| Meter | Color | Icon | Starts at |
|---|---|---|---|
| The Guild | Orange | hammer.fill | 50 |
| Nobles | Yellow | crown.fill | 50 |
| Common Folk | Green | house.fill | 50 |
| The Watch | Blue | shield.fill | 50 |

**Visual cue:** Meter icon turns red when value ≤ 20 (low warning).

---

## ⚙️ TUNABLE NUMBERS (top of `CardDatabase.swift`)

```swift
static let act2UnlocksAfterCards: Int = 10   // Cards played before Act 2 begins
static let act3UnlocksAfterCards: Int = 25   // Cards played before Act 3 begins
```

Starting meter values live in `CardDatabase.startingValues` — change them to make a run start harsher or kinder.

---

## 🃏 HOW TO ADD A CARD

Open `CardDatabase.swift` and copy any existing `Card(...)` block into the `allCards` array. Then edit the fields.

### Card fields explained
| Field | What it does |
|---|---|
| `id` | Unique string, no spaces, use underscores (e.g. `"merchant_gossip"`). Used by threshold events to inject specific cards. |
| `act` | 1, 2, or 3. Card won't appear until that act is unlocked. |
| `speaker` | Italicized line at top of card (who's talking or scene description) |
| `text` | The card body. Use `\"` for quotes inside strings. |
| `leftChoice` | Text shown on the red pill when swiping left |
| `rightChoice` | Text shown on the green pill when swiping right |
| `leftEffects` | Array of `MeterEffect` applied on swipe left |
| `rightEffects` | Array of `MeterEffect` applied on swipe right |
| `characterImageName` | Optional asset name in Assets.xcassets. Falls back to silhouette placeholder if missing. |
| `condition` | Optional `CardCondition` — card only appears when a meter is in a specified range |
| `isOnce` | If `true`, card only appears once per run |

### Numbers guide for meter effects
| Value | Feel |
|---|---|
| `±2` | Small, barely noticed |
| `±5` | Meaningful moment |
| `±10` | Significant decision |
| `±15` | Life-changing event |

### Example
```swift
Card(
    id: "merchant_gossip",
    act: 1,
    speaker: "A traveling merchant",
    text: "\"I know things about the old innkeeper...\"",
    leftChoice: "\"I don't deal in gossip.\"",
    rightChoice: "\"Tell me. What's your price?\"",
    leftEffects: [
        MeterEffect(meter: .resolve,    value: +2),
        MeterEffect(meter: .reputation, value: +2)
    ],
    rightEffects: [
        MeterEffect(meter: .personalCoin, value: -5),
        MeterEffect(meter: .secrets,      value: +8),
        MeterEffect(meter: .reputation,   value: -2)
    ],
    characterImageName: "char_merchant"
)
```

### Conditional cards
A card with a `condition` only enters the draw pool when the condition is met.

```swift
condition: CardCondition(meter: .secrets, minimum: 30)
// Only appears when Secrets is at least 30

condition: CardCondition(meter: .tavernCoin, minimum: 60)
// Only appears when Tavern Coin is at least 60

condition: CardCondition(meter: .resolve, maximum: 25)
// Only appears when Resolve is 25 or lower
```

You can also use both `minimum` and `maximum` for a range.

---

## ⚡ THRESHOLD EVENTS

Threshold events fire **once** when a meter crosses a value. They live in `CardDatabase.thresholds`.

### Fields
| Field | What it does |
|---|---|
| `meter` | Which meter triggers it |
| `value` | The trigger number (0–100) |
| `isHigh` | `true` = fires when meter rises **to** value or above. `false` = fires when meter falls **to** value or below. |
| `message` | Text shown in dark overlay (player taps to dismiss) |
| `injectCardID` | Optional — force a specific card next turn (by its `id`) |
| `isGameOver` | If `true`, the run ends and the ending screen shows the message |

### Current thresholds in the game
- Resolve ≤ 10 → **GAME OVER** ("Enna can't carry this anymore...")
- Reputation ≥ 80 → message about word spreading
- Reputation ≤ 15 → people stopped trusting her
- Secrets ≥ 60 → cloaked figure watching
- Tavern Coin ≤ 10 → nearly broke
- Regulars ≤ 15 → empty common room
- Order ≤ 10 → brawl breaks out, injects card `"brawl_aftermath"`
- Guild ≥ 80 → Guildmaster sends word
- Guild ≤ 15 → declared an outsider
- Common Folk ≤ 15 → neighborhood cold
- Watch ≤ 15 → Watch raid, injects card `"watch_raid"`

---

## 🎴 CURRENT CARD COUNT

| Act | Cards | Notes |
|---|---|---|
| Act 1 — Enna Personal | 8 cards | Includes 2 `isOnce` cards (`debt_collector`, `the_letter`) and 1 conditional (`high_secrets_visitor`, requires Secrets ≥ 30) |
| Act 2 — Tavern Vitals | 6 cards | Includes 2 `isOnce` (`brawl_aftermath` — also threshold-injected, `renovation_offer` — requires Tavern Coin ≥ 60) |
| Act 3 — Factions | 4 cards | Includes 1 `isOnce` (`watch_raid` — also threshold-injected) |
| **Total** | **18 cards** | |

---

## 🖼️ ASSET HOOKUP

All art is **optional**. The game uses graceful fallbacks (gradient backgrounds, silhouette placeholders) when an image isn't in Assets.xcassets.

### Backgrounds (one per act)
Add to `Assets.xcassets` with these exact names:
- `enna_bg_act1` — Act 1 (warm browns/tavern interior)
- `enna_bg_act2` — Act 2 (blue/night)
- `enna_bg_act3` — Act 3 (purple/city)

Fallback if missing: mood-appropriate linear gradient.

### Character portraits
Match the `characterImageName` string in each card. Current names referenced in `CardDatabase.swift`:
- `char_merchant`, `char_stranger`, `char_debt_collector`, `char_regular_woman`, `char_old_friend`
- `char_staff`, `char_carpenter`, `char_guild_runner`, `char_noble_lady`, `char_watch_captain`

Fallback if missing: dark gradient with silhouette and small "art: char_xxx" label so you can see which asset name to add.

---

## 🎛️ WHAT TO EDIT WHERE — CHEAT SHEET

| You want to... | File to edit |
|---|---|
| Add a new card | `CardDatabase.swift` → `allCards` array |
| Change starting meter values | `CardDatabase.swift` → `startingValues` dictionary |
| Change when Acts 2 / 3 unlock | `CardDatabase.swift` → `act2UnlocksAfterCards` / `act3UnlocksAfterCards` |
| Add or tune a threshold event | `CardDatabase.swift` → `thresholds` array |
| Add a new meter | `CardGameModels.swift` (add to enum + icon/color/act) — **also** add starting value in `CardDatabase.swift` |
| Change swipe sensitivity | `CardGameView.swift` → `swipeThreshold` in `SwipeCardView` (currently 85) |
| Change card visual style (size, fonts, gradients) | `CardGameView.swift` → `CardFaceView` |
| Change meter panel layout | `CardGameView.swift` → `CardMeterPanel` / `CardMeterRow` / `CardMeterItem` |
| Change act unlock overlay text | `CardGameView.swift` → `CardActUnlockOverlay.actTitle` / `actDescription` |
| Change "low meter" red warning threshold | `CardGameView.swift` → `CardMeterItem.isLow` (currently ≤ 20) |
| Change ending screen text | `CardGameView.swift` → `CardEndingView` ("The story ends here." line) |

---

## 🔧 KEY METHODS IN VIEW MODEL

`CardGameViewModel.swift` — read-only reference, no need to edit unless changing rules:

| Method | What it does |
|---|---|
| `chooseLeft()` / `chooseRight()` | Player swiped — apply effects, advance turn |
| `applyEffects(_:)` | Clamp meter values to 0–100 after applying |
| `drawNextCard()` | Pick the next card (injected first, else random from `availableCards()`) |
| `availableCards()` | Filter: correct act, not played-once, conditions met |
| `checkThresholds()` | Fire any new thresholds (game over takes precedence) |
| `checkActProgression()` | Unlock Act 2 then Act 3 based on cards played |
| `restart()` | Wipe all state and start a new run |

---

## ⚠️ THINGS TO BE CAREFUL ABOUT

1. **Folder name typo (FIXED):** Folder was originally `EnnaCardGaame` (double "a") — renamed to `EnnaCardGame` on May 25, 2026.
2. **Card IDs must be unique.** If two cards share an `id`, threshold injection and once-tracking will get confused.
3. **`isOnce` + threshold-injected combo:** Cards like `brawl_aftermath` and `watch_raid` are both `isOnce` AND injected by thresholds. After the threshold fires, the card plays, gets marked played, and is then permanently removed from the random pool. This is intentional.
4. **Meter starting values must cover all 12 meters.** Even Act 2/3 meters start with values from day one — they just aren't visible until that act unlocks.
5. **Game over threshold:** Currently only `Resolve ≤ 10` ends the game. Add more `isGameOver: true` thresholds with care — they end the run immediately.
6. **No save state.** Each run is fresh. Restart is via the "Begin Again" button on the game over screen.

---

## 📝 SESSION LOG

### **Session: Initial Module Creation** (May 25, 2026)
- 4 source files added in `EnnaCardGame/`:
  - `CardGameModels.swift` — types
  - `CardDatabase.swift` — 18 cards across 3 acts, 11 threshold events, starting values
  - `CardGameViewModel.swift` — `@Observable` game logic
  - `CardGameView.swift` — full UI (swipe card, meter panel, overlays, ending)
- Hooked into `GameSelectorView.swift` via `case .ennaCardGame: CardGameView()`
- `GameType` enum extended with `case ennaCardGame`
- Folder originally `EnnaCardGaame` (typo), renamed to `EnnaCardGame`
- Context document `EnnaCardGame_CONTEXT.md` created
- `MASTER_CONTEXT.md` updated to list Enna's Tavern as Game #5

### **Session: Debug Menu + End Game Button** (May 25, 2026)
Added a floating debug wrench in `CardGameView.swift` that opens a sectioned debug menu, matching the pattern used by Potion Shop and Shop of Oddities.

**Added to `CardGameView`:**
- `@Environment(\.dismiss) private var dismiss`
- `@State private var showDebugMenu: Bool = false`
- `.overlay(alignment: .topTrailing)` modifier holding a small wrench button (`CardGameDebugButton`) at `.padding(.top, 14).padding(.trailing, 14)`
- `.sheet(isPresented: $showDebugMenu)` that presents `CardGameDebugMenu`

**New structs at bottom of `CardGameView.swift`:**
- `CardGameDebugButton` — circular black button (32×32), wrench icon, warm gold border (matches existing overlay aesthetic)
- `CardGameDebugMenu` — `NavigationStack` + `List` with sections:
  - **Current State** — Act, Cards Played, Current Card ID, Game Over flag
  - **Act 1/2/3 meters** — read-only meter values (Act 2/3 sections only appear when those acts are unlocked)
  - **Exit** — red "End Game (back to selector)" button → calls `isPresented = false; onEndGame()`
  - Toolbar "Close" button

**How return-to-selector works:**
- `CardGameView` is launched from `GameSelectorView` via `.fullScreenCover(item: $selectedGame)`
- `onEndGame: { dismiss() }` is passed into `CardGameDebugMenu`
- End Game button: closes the sheet first, then dismisses the fullScreenCover, returning to the selector list
- **No game state cleanup required** — Enna's Tavern has no timers, no async work, no external resources

**Wrench is visible during game over screen too** — gives the player an exit path even after the run ends (the existing "Begin Again" button only restarts).

**Files modified:** `EnnaCardGame/CardGameView.swift` only.

**Xcode diagnostics:** No errors or warnings.

---

**END OF ENNA'S TAVERN CONTEXT**

For project-wide context, see `MASTER_CONTEXT.md`.
