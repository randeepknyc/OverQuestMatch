# PotionShop — Buckets, Tags, and Rework Roadmap

A single page that tells you (a) what every character is tagged as today, (b) how to change those tags, and (c) what's still left to convert from the old hand-tuned system to the new bucket-driven auto-layout.

---

## Part 1 — The bucket system at a glance

PotionShop characters have **two independent tags**: a **height bucket** and a **width bucket**. Together they let the auto-layout system place the character correctly without any per-character X/Y/scale tuning.

### Height buckets (6 options)

| Tag | Head box Y on canvas | Body length to floor | When to use | Example |
|---|---|---:|---|---|
| `superShort` | y 768–992 | ~448 px | Children, gnomes, hobbits | (no chars yet) |
| `short` | y 576–800 | ~700 px | Dwarves, halflings | guide_octo, guide_slug, Greta-ish |
| `medium` | y 384–640 | ~860 px | Average adults | Most characters |
| `tall` | y 192–448 | ~1052 px | Knights, ogres, giants | Tomik, Grimdrek, guide_bull |
| `tallHat` | y 96–480 | ~1020 px | Wizards, witches, mitred bishops, anything with a pointy hat | guide_fishguy |
| `floater` | y 384–640, feet at y=1260 | ~620 px (hovers) | Ghosts, spectral mages | guide_demon |

> Canvas reference: 1024 × 1536 px portrait, feet touch y=1500 (floater feet at y=1260). See `CHARACTER_ART_TEMPLATE_SPEC.md` for the full safe-zone spec.

### Width buckets (3 options)

| Tag | Body fills | When to use |
|---|---|---|
| `skinny` | innermost band (~320 px wide) | Slim builds, old men, slender mages |
| `medium` | mid band (~480 px wide) | Average humans |
| `wide` | full outer band (~640 px wide) | Ogres, sumo, fat merchants, big shoulders |

---

## Part 2 — Every character's current tags

### Day 1 / Day 2 characters (legacy hand-tuned — NOT yet on auto-layout)

These 14 still use the OLD hand-tuned positioning system (per-character `customerSceneX/Y`, `customerWaitingX/Y`, badge overrides, etc.). They have `widthBucket = .medium` as a default placeholder but it's not yet read by anything. **Their `heightBucket` IS set** for badge anchor purposes.

| Character | heightBucket (current) | widthBucket (placeholder) | Notes |
|---|---|---|---|
| Mildred | `.medium` | `.medium` | Anxious farmwife |
| Tomik | `.tall` | `.medium` | Sleepy apprentice |
| Greta | `.short` | `.medium` | Cheerful villager |
| Pemberton | `.short` | `.medium` | Travelling merchant |
| Sister Halla | `.medium` | `.medium` | Wandering sister |
| Ardo | `.short` | `.medium` | Nervous scholar |
| Wendelina | `.medium` | `.medium` | Has high stats, no trait |
| Bram | `.medium` | `.medium` | Loud (STUB) |
| Crispin | `.medium` | `.medium` | Intimidating |
| Grimdrek | `.tall` | `.medium` | Volatile (Day 1 boss) |
| Hexa Mott | `.medium` | `.medium` | Hexer (STUB) |
| Ironhilde | `.medium` | `.medium` | Draining |
| Carmilla | `.medium` | `.medium` | Hexer (STUB) |
| Royal Envoy | `.medium` | `.medium` | Day 2 boss, intimidating |

### Day 3 guide characters (template-based, fully on auto-layout)

These 13 use the NEW system — bucket tags drive everything via `applyGuideCharacter()` in `PotionShopLayoutConfig.swift`. **No hand-tuned per-character overrides.**

| Character | height | width |
|---|---|---|
| guide_octo | `.short` | `.wide` |
| guide_girl | `.medium` | `.skinny` |
| guide_skull | `.tall` | `.skinny` |
| guide_slug | `.short` | `.medium` |
| guide_fishguy | `.tallHat` | `.medium` |
| guide_bull | `.tall` | `.wide` |
| guide_traveler | `.medium` | `.medium` |
| guide_demon | `.floater` | `.medium` |
| guide_frog | `.medium` | `.wide` |
| guide_pig | `.medium` | `.wide` |
| guide_faun | `.medium` | `.wide` |
| guide_fox | `.tall` | `.medium` |
| guide_woman | `.medium` | `.medium` |

---

## Part 3 — How to change a tag

### For a Day 3 (guide_*) character

**File:** `PotionShop/PotionShopLayoutConfig.swift`
**Find:** `// ─── DAY 3 GUIDE CHARACTERS` (around line 840)

```swift
applyGuideCharacter(id: "guide_octo",     height: .short,    width: .wide)
//                                              ↑                ↑
//                            edit either of these and rebuild
```

That's the whole change. Auto-layout reads the new value at runtime.

### For a Day 1 / Day 2 character

Currently their `widthBucket` is unused (auto-layout isn't wired up for Day 1/2). To change `heightBucket` (used for badge anchor):

**File:** `PotionShop/PotionShopLayoutConfig.swift`
**Find:** `private func applyDefaultHeightBuckets()` (around line 535)

```swift
let defaults: [(String, CustomerHeightBucket)] = [
    ("mildred", .medium),
    ("tomik", .tall),
    ...
]
```

Edit the bucket value. Rebuild.

---

## Part 4 — What still needs reworking

### A. Migrate Day 1/2 characters to template + auto-layout *(biggest pending item)*

**Why it matters:** Day 1/2 currently has ~3000 lines of hand-tuned per-character values in `applyTunedCharacterScales()`. Each character has X/Y/scale/badge offsets for 3 slots (active, waiting1, waiting2). That's brittle, hard to maintain, and prevents adding new characters quickly.

**Migration steps per character:**
1. Redraw the character at 512×768 against the safe-zone template (`CHARACTER_ART_TEMPLATE_SPEC.md`).
2. Pick a `heightBucket` and `widthBucket`.
3. Remove their entry from `applyTunedCharacterScales()` — delete all the X/Y/scale/badge overrides.
4. Add an `applyGuideCharacter("mildred", height: .medium, width: .medium)`-style call.
5. Visually verify. Re-tune the bucket choice if needed.

**Estimated effort per character:** ~30 min (mostly redrawing). All 14 characters: 1-2 days.

**Net result:** ~3000 lines of code in `applyTunedCharacterScales` deletable. Adding character #15+ becomes a 1-line code change.

### B. Resize source PNGs from 1024×1536 → 512×768

**Why:** Memory. Each character costs ~6 MB raw RAM at 1024×1536 vs ~1.5 MB at 512×768. With ~27 characters across all games, this is a real working-memory difference.

**Status:** Tomik is already redrawn at 512×768 (May 27). The other 13 originals are still at 1024×1536. All 13 Day 3 guides are at 1024×1536.

**Per character:** redraw at native 512×768 on your end, drop into the existing `*.imageset`, hit "Purge image cache" in debug menu to clear the stale cached version.

### C. Add `widthBucket` reads for Day 1/2 characters

**Status:** Even though Day 1/2 characters HAVE a `widthBucket = .medium` field, nothing reads it because Day 1/2 doesn't go through auto-layout.

**To fix:** when migrating each Day 1/2 character to the new template (item A above), flip them to use auto-layout instead of hand-tuned values. Their `widthBucket` then gets read.

### D. Animation states (per-character pose swaps)

**Status:** Not yet built. Documented in `CAULDRON_CONTEXT.md` §26 (animation roadmap).

When you start producing animation art, each character will need additional fields:
- `activePoseAsset: String?` — drawn at queue[0]
- `waitingPoseAsset: String?` — drawn at queue[1+]
- `hurtPoseAsset: String?` — flashes when customer attacks Ednar
- `speechBubbleAsset: String?` — overlay during dialogue
- `idleAnimationFrames: [String]?` — N-frame line-boil loop

Plus a state machine to swap them in/out. Estimated when the first animation art ships: 2-3 days of code work for the first character's full state machine, then ~30 min per subsequent character.

### E. Speech bubble system

**Status:** Not yet built. `tickDialogue`, `expireDialogue`, `orderDialogue`, etc. exist as strings in PotionShopData but there's no in-game speech bubble view yet.

**Needed:**
- A `PotionShopSpeechBubble` SwiftUI view that anchors to a character's head position.
- Triggers from existing game events (round start = orderDialogue, patience tick = tickDialogue, etc.).
- Animation timing (fade in, hold, fade out).

### F. SpriteKit migration *(eventual, optional)*

**Status:** Documented in earlier discussion. Not started.

**Trigger condition:** when total animation/effect count per character exceeds ~3-4 simultaneous (line boil + speech bubble + steam particles + pose state). Until then, SwiftUI handles fine.

**See:** `CAULDRON_CONTEXT.md` §26 for the migration plan.

---

## Part 5 — Quick reference

### Add a new character (TEMPLATE format — fastest)

1. Draw at 512×768 against the safe-zone template.
2. Drop PNG into `Assets.xcassets/<id>.imageset/`.
3. Add `PotionShopCharacter(id: ..., ...)` entry in `PotionShopData.swift`.
4. Add `applyGuideCharacter(id: ..., height: ..., width: ...)` call in `PotionShopLayoutConfig.swift`.
5. (Optional) Add to a Day's round in `PotionShopData.swift`.

Total: ~5 minutes of code + the art time.

### Add a new character (LEGACY format — DON'T, just use TEMPLATE)

If for some reason you need the old hand-tuned path, see how Mildred is set up: ~30 lines of per-character overrides in `applyTunedCharacterScales`. Avoid this for new work.

### Change which characters appear in Day 3's fixed rounds

**File:** `PotionShop/PotionShopData.swift` → `static let day3` (around line 596)
```swift
fixedRounds: [
    PotionShopRound(timeOfDay: .morning, customerIds: ["guide_woman", "guide_traveler"]),  // R1
    PotionShopRound(timeOfDay: .morning, customerIds: ["guide_octo", "guide_girl", "guide_skull"])  // R2
],
randomPool: [...],     // R3-5 pool
randomRoundSizes: [3, 3, 2]  // shape of random rounds
```

---

## Part 6 — Files this all lives in

| Concern | File | Section |
|---|---|---|
| Bucket enum definitions | `PotionShopLayoutConfig.swift` | `CustomerHeightBucket`, `CustomerWidthBucket` enums |
| Per-character bucket assignment (Day 3) | `PotionShopLayoutConfig.swift` | `applyGuideCharacter()` calls in `applyTunedCharacterScales()` |
| Per-character bucket assignment (Day 1/2) | `PotionShopLayoutConfig.swift` | `applyDefaultHeightBuckets()` |
| Character data (HP, dialogue, asset name) | `PotionShopData.swift` | `static let characters` dict |
| Round data | `PotionShopData.swift` | `day1`, `day2`, `day3` static vars |
| Auto-layout algorithm | `PotionShopCustomerSceneView.swift` | `PotionShopAutoQueueLayout` enum at end of file |
| Auto-layout tunable values | `PotionShopLayoutConfig.swift` | `autoLayout*` properties (~line 477) |
| Layout editor sliders | `PotionShopGameView.swift` | `case .autoLayout` in `sectionContent` switch |
| Hand-tuned legacy values | `PotionShopLayoutConfig.swift` | `applyTunedCharacterScales()` (~line 555-840) |

---

## TL;DR for someone new to this codebase

1. **Day 3 characters use buckets** (height + width) and the system places them automatically. Adding new template-format characters = ~5 lines of code.
2. **Day 1/2 characters DON'T use buckets yet** — they use hand-tuned values. Migrating them is the biggest pending item.
3. **To change a Day 3 bucket:** edit one line in `applyGuideCharacter()`.
4. **The art template is what makes auto-layout work** — character must be drawn at 1024×1536 (or 512×768 for memory) inside the safe-zone boxes. See `CHARACTER_ART_TEMPLATE_SPEC.md`.
