# Day 3 / Auto-Layout — Where to Edit What

Quick reference for tuning Day 3 characters, buckets, combat values, and the auto-layout. **Day 1 and Day 2 are untouched** — none of these edits affect them.

All file paths are relative to the project root (`OverQuestMatch3 copy 39/`).

---

## 1. Change a character's height OR width bucket

**File:** `PotionShop/PotionShopLayoutConfig.swift`
**Find:** `// ─── DAY 3 GUIDE CHARACTERS` (around line 840)

You'll see a block of 13 calls like:
```swift
applyGuideCharacter(id: "guide_octo",     height: .short,      width: .wide)
applyGuideCharacter(id: "guide_girl",     height: .medium,     width: .skinny)
applyGuideCharacter(id: "guide_skull",    height: .tall,       width: .skinny)
... etc.
```

**To change a character's bucket:** edit the `height:` or `width:` arg on that line.

**Valid height values:**
| Tag | Head box Y range | Notes |
|---|---|---|
| `.superShort` | y 768–992 | children, gnomes |
| `.short` | y 576–800 | dwarves |
| `.medium` | y 384–640 | average adults |
| `.tall` | y 192–448 | knights, ogres |
| `.tallHat` | y 96–480 | wizards with pointy hats |
| `.floater` | y 384–640, feet at y=1260 | ghosts (no floor contact) |

**Valid width values:** `.skinny` / `.medium` / `.wide`

After editing, just rebuild — no slider tuning needed.

---

## 2. Change a character's combat values (HP, attack, patience, dialogue)

**File:** `PotionShop/PotionShopData.swift`
**Find:** `// ─── DAY 3 GUIDE CHARACTERS` (around line 456)

Each character is a `PotionShopCharacter` block:
```swift
"guide_octo": PotionShopCharacter(
    id: "guide_octo", name: "Octo", title: "Tentacled Customer",
    portrait: "guide_octo", scenePortrait: "guide_octo",
    iconFallback: "🐙",
    difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
    orderName: "A Potion, Please", orderDialogue: "Bloop. Need a brew.",
    hp: 12, patience: 6, activeAttack: 2, waitingAttack: 1,
    activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 4,
    tickDialogue: "Tentacles wriggle impatiently.",
    expireDialogue: "Bloop! Leaving now.",
    defeatDialogue: "Bloop! Splendid.",
    trait: nil
),
```

**To tweak:** edit any of the fields (hp, activeAttack, etc.) and rebuild. Defaults follow the table:

| Bucket | HP | active_atk | waiting_atk | expire | patience |
|---|---:|---:|---:|---:|---:|
| superShort | 8 | 1 | 1 | 3 | 4 |
| short | 12 | 2 | 1 | 4 | 6 |
| medium | 16 | 2 | 1 | 5 | 8 |
| tall | 20 | 3 | 1 | 6 | 10 |
| tallHat | 22 | 3 | 1 | 7 | 11 |
| floater | 14 | 2 | 2 | 5 | 7 |

---

## 3. Change Day 3 round structure (fixed rounds, random pool, round count)

**File:** `PotionShop/PotionShopData.swift`
**Find:** `static let day3: PotionShopFlexDay = PotionShopFlexDay(` (around line 596)

```swift
static let day3: PotionShopFlexDay = PotionShopFlexDay(
    id: "day_3",
    name: "Day 3",
    subtitle: "Random Combos (Test)",
    fixedRounds: [
        // Round 1 — change these character IDs to swap who's in R1
        PotionShopRound(timeOfDay: .morning,
                        customerIds: ["guide_woman", "guide_traveler"]),
        // Round 2
        PotionShopRound(timeOfDay: .morning,
                        customerIds: ["guide_octo", "guide_girl", "guide_skull"])
    ],
    randomPool: [
        // Add/remove character IDs here to control who's in the RNG pool
        "guide_slug", "guide_fishguy", "guide_bull", "guide_demon",
        "guide_frog", "guide_pig", "guide_faun", "guide_fox"
    ],
    // Number of chars per random round, in order. [3, 3, 2] = 3 random
    // rounds with 3/3/2 chars. Change to [3, 2, 2, 1] for 4 rounds, etc.
    randomRoundSizes: [3, 3, 2]
)
```

**To change Round 1's customers:** edit the first `customerIds` array.
**To change Round 2's customers:** edit the second `customerIds` array.
**To change the random pool:** add or remove IDs from `randomPool`.
**To change how many random rounds:** edit `randomRoundSizes`. Each integer becomes one random round of that size. Constraint: sum should not exceed `randomPool.count` (no repeats within day).

---

## 4. Tune the auto-layout positions LIVE (sliders)

**In-app:**
1. Tap gear icon → **Layout Editor**.
2. Open the **"🎲 Auto-Layout"** section.
3. Sliders for all positions, scales, weights, and bucket Y adjustments.
4. Tap **"📋 Copy Layout Values"** in the debug menu — values get copied to clipboard.
5. Paste back to me — I bake them into the file as new defaults.

**In code (manual):**
**File:** `PotionShop/PotionShopLayoutConfig.swift`
**Find:** `// MARK: - Auto-Layout Values` (around line 477)

```swift
var autoLayoutStartX: Double = 0.45   // Active customer X
var autoLayoutEndX: Double = 0.82     // Back-of-line X
var autoLayoutYActive: Double = 0.48  // Active Y
var autoLayoutYWaiting: Double = 0.48 // Waiter Y

var autoLayoutScaleActive: Double = 1.0
var autoLayoutScaleWaiting1: Double = 0.85
var autoLayoutScaleWaiting2: Double = 0.75

var autoLayoutWidthWeightSkinny: Double = 1.0
var autoLayoutWidthWeightMedium: Double = 1.4
var autoLayoutWidthWeightWide: Double = 2.0

var autoLayoutYAdjustSuperShort: Double = 0.0
var autoLayoutYAdjustShort: Double = 0.0
var autoLayoutYAdjustMedium: Double = 0.0
var autoLayoutYAdjustTall: Double = 0.0
var autoLayoutYAdjustTallHat: Double = 0.0
var autoLayoutYAdjustFloater: Double = -0.05
```

Edit any default — rebuild — done.

---

## 5. Change head-anchor positions for new buckets (where badges sit on the character)

**File:** `PotionShop/PotionShopLayoutConfig.swift`
**Find:** `// Template head anchors` (around line 468)

```swift
var headAnchorYSuperShort: Double = 0.573   // (head box center / canvas height)
var headAnchorYTallHat: Double = 0.188
var headAnchorYFloater: Double = 0.333
```

These are **fractions** (0.0 = top of image, 1.0 = bottom). They tell the badge system where the head sits within the 1024×1536 PNG. Edit if badges are floating in wrong spots for a bucket.

For the OLDER buckets (short/medium/tall), Day 3 chars override individually via the `applyGuideCharacter` helper — see line ~876:

```swift
switch height {
case .short:  cs.headAnchorYOverride = 0.448
case .medium: cs.headAnchorYOverride = 0.333
case .tall:   cs.headAnchorYOverride = 0.208
case .superShort, .tallHat, .floater: cs.headAnchorYOverride = nil
}
```

Edit these fractions if badges are off for a specific bucket on Day 3 characters.

---

## 6. Add a new guide character

Three places to update:

**(a) PNG:** Drop `guide_<name>.png` into Xcode's Assets.xcassets. Drawn against the safe-zone template (see `CHARACTER_ART_TEMPLATE_SPEC.md`).

**(b) `PotionShop/PotionShopData.swift`:** Add a new `"guide_<name>": PotionShopCharacter(...)` entry under the `// ─── DAY 3 GUIDE CHARACTERS` block. Use the placeholder template from one of the existing 13.

**(c) `PotionShop/PotionShopLayoutConfig.swift`:** Add one `applyGuideCharacter(id: "guide_<name>", height: ..., width: ...)` call in the bucket-assignment block (around line 840).

Then either:
- Add the new ID to Day 3's `randomPool` (or `fixedRounds`) in `PotionShopData.swift`.
- Or just hand it to me and I'll wire it in.

---

## 7. Where the auto-layout algorithm actually lives

If you ever want to change HOW the auto-layout computes positions (vs just tuning values):

**File:** `PotionShop/PotionShopCustomerSceneView.swift`
**Find:** `enum PotionShopAutoQueueLayout` (around line 130)

Three functions:
- `xFractions(for:config:)` — computes X positions
- `yFractions(for:config:)` — computes Y positions  
- `scales(for:config:)` — returns per-slot scale (active vs waiting1 vs waiting2)

Each reads its tuning values from `PotionShopLayoutConfig` (so all the sliders in §4 above hook in there). Don't change unless you're modifying the formula itself.

---

## Quick mental map

```
PNG ─────────► Assets.xcassets ──┐
                                 │
Character data ──► PotionShopData.swift                       (HP, dialogue, etc.)
                       │
                       ├─ guide_* dict entries
                       └─ day3: PotionShopFlexDay (rounds, pool)
                                 │
Bucket assignment ──► PotionShopLayoutConfig.swift
                       │
                       └─ applyGuideCharacter calls (height/width tag per char)
                                 │
Auto-layout values ──► PotionShopLayoutConfig.swift
                       │
                       └─ autoLayout* properties (positions, scales, weights)
                                 │
Algorithm ──► PotionShopCustomerSceneView.swift
              │
              └─ PotionShopAutoQueueLayout enum
```

---

## Revert escape hatch

If something breaks and Day 1/2 are affected, the test for "is Day 1/2 untouched":
- All Day 3 code is gated on `PotionShopData.isFlexDay(dayId)`.
- All new bucket cases (`.superShort, .tallHat, .floater`) are NOT assigned to any Day 1/2 character.
- All `autoLayout*` properties only fire when `gs.isFlexDay == true`.

If Day 1/2 visuals look wrong, it's a bug — tell me and I'll trace it.
