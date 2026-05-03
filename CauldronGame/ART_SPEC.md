# Ednar's Cauldron — Art Specification

**Source of truth for all art assets.** Created from a Procreate-on-iPad workflow, but file naming and dimensions are platform-agnostic. Drop this file into your Xcode project folder alongside the JSON files so Claude in Xcode knows what asset names to expect.

---

## Quick reference — file count

**34 files total for v1.**

| Category | Count |
|---|---|
| Character portraits | 14 |
| Ednar expressions | 5 |
| Cauldron layers | 3 |
| Dice | 5 |
| Background | 1 |
| UI icons | 6 |

---

## Workflow rules

1. **All assets exported as PNG with transparency** unless noted otherwise.
2. **In Procreate**, before exporting: toggle off the bottom-most "Background" layer (the white one Procreate adds by default), or use File → Share → PNG which auto-excludes it.
3. **File naming is exact and case-sensitive.** Use the names in the tables below verbatim. The game's data files (characters.json) reference these names.
4. **Drop assets into the Xcode asset catalog** (`Assets.xcassets`) once finalized. Use Image("filename") in SwiftUI to reference them. While iterating, placeholder PNGs at the right dimensions with the right names work fine.
5. **Source files (`.procreate`) live separately**, not in the Xcode project. Keep them in iCloud or Procreate Files for editing later.

---

## 1. Character portraits

**14 files.** Each is a customer that visits Ednar's shop.

**Procreate canvas: 1024×1024 px @ 300 DPI**

| Filename | Character | Color theme |
|---|---|---|
| `mildred.png` | Mildred Honeycomb (Anxious Farmwife) | Soft pink #FBEAF0 |
| `tomik.png` | Tomik Cooper (Sleepy Apprentice) | Pale green #EAF3DE |
| `greta.png` | Greta Marshlow (Cheerful Villager) | Sunflower yellow #FFF6D4 |
| `pemberton.png` | Pemberton Quill (Travelling Merchant) | Warm tan #F4E2C9 |
| `sister_halla.png` | Sister Halla (Wandering Sister) | Soft lavender #E6E1F2 |
| `ardo.png` | Ardo Quill (Nervous Scholar) | Cream #FAEEDA |
| `wendelina.png` | Wendelina Rookpool (Hedge Witch) | Forest sage #E1E8DA |
| `bram.png` | Bram the Bard (Travelling Lutist) | Burnt orange #F5DCC0 |
| `crispin.png` | Lord Crispin Vorne (Petty Noble) | Cool lavender #DDDCEC |
| `hexa_mott.png` | Hexa Mott (Murky Witch) | Murky green #D4DDD0 |
| `ironhilde.png` | Captain Ironhilde (Battle-Weary Knight) | Steel grey #D8D8D8 |
| `grimdrek.png` | Grimdrek the Volatile (Hellsworn Merchant) | Hellfire red #E8C5C5 |
| `carmilla.png` | Lady Carmilla Veil (Vampire Countess) | Wine purple #D4C5DC |
| `royal_envoy.png` | The Royal Envoy (On Crown Business) | Royal gold #E8DAB8 |

**Composition rules:**
- **Bust shot** — head and shoulders, centered.
- **~10% padding** around the figure on all sides (the game crops into a circle, corners get trimmed).
- **Distinct silhouettes** — the player must recognize the customer at the small profile-button size (rendered at ~56px). Use hats, hair, posture to make each one read instantly.
- **Strong color identity** — each character has a tint color (above) which becomes the circular background behind their portrait in the game. Your art should COMPLEMENT that color, not fight it.
- **Background transparent** — the game compositing handles the circular tint background.

---

## 2. Ednar expressions

**5 files.** The player avatar, switches based on game state.

**Procreate canvas: 1024×1536 px @ 300 DPI** (taller than wide because Ednar is rendered standing behind a counter, so a more vertical bust shot)

| Filename | Triggers | Composition |
|---|---|---|
| `ednar_calm.png` | Default. Composure 70%+, no incoming threats. | Neutral, focused, confident. Default base pose. |
| `ednar_focused.png` | Mid-brew (when player has dice placed but hasn't tapped BREW yet) | Concentrated, looking at cauldron. Slight forward lean. |
| `ednar_concerned.png` | Composure 30-70%, or shield breaks. | Eyebrows raised, slight worry. Mouth slightly open. |
| `ednar_alarmed.png` | Composure under 30%. | Wide-eyed, leaning back. Visibly stressed. |
| `ednar_satisfied.png` | Customer defeated (potion delivered, usually 1-2 second hold). | Soft smile, slight relief. |

**Composition rules:**
- **Same body pose across all 5** — only the face changes. Easiest workflow: draw the base body once in Procreate, duplicate the file 5 times, modify just the face for each.
- **3/4 facing right** — Ednar stands behind a counter on the LEFT side of the screen, customers approach from the RIGHT, so he should be turned slightly toward them.
- **Bust shot** — head, shoulders, hands optional (could be on counter or holding ladle).
- **Background transparent** — the shop interior background sits behind him.
- **Optional v2 expression**: `ednar_hurt.png` (brief flinch frame during attack hits). Don't draw now; add later if desired.

---

## 3. Cauldron — three layers

**3 files**, all from a single Procreate file with 3 group layers. Same canvas, drawn in registration, exported separately by toggling layer visibility.

**Procreate canvas: 2048×1536 px @ 300 DPI**

| Filename | Contents | z-index in game |
|---|---|---|
| `cauldron_back.png` | Cauldron body, exterior, base, shadow underneath | 1 (bottom) |
| `cauldron_liquid.png` | Just the green bubbling potion surface, NO rim | 2 (middle — dice render layered on top of this) |
| `cauldron_front.png` | The metal rim, foreground details, ladle handle silhouette, any handles visible from the front | 4 (top — above the dice and ladle BREW button) |

**Why layered:** when the player places dice on the 12 nodes inside the cauldron, the dice sit BETWEEN the liquid layer and the front layer. This makes them appear to float ON the potion surface, not hover above the entire cauldron. Without this layering, the visual reads as wrong.

**Composition rules:**
- **Liquid layer top edge:** clean horizontal-ish edge representing the potion surface. Slight wobble for organic feel.
- **Front layer rim:** should overlap the liquid layer's top edge by ~20-40 px so there's no visible seam.
- **Background transparent** — the shop interior background sits behind the cauldron.
- **Don't draw nodes in the cauldron art.** The 12 placement nodes are runtime UI elements drawn by the game on top of `cauldron_liquid.png`.

**Procreate workflow:**
1. Make ONE 2048×1536 file with 3 group layers named "Back", "Liquid", "Front."
2. Draw all three in the same file so they're aligned perfectly.
3. To export each: hide all groups except one, File → Share → PNG, save with the matching filename. Repeat for all three.

---

## 4. Dice — five flat-faced types

**5 files.** One per die type. Numbered face (1-6) is rendered as text by the game at runtime — DO NOT draw numbers on the die.

**Procreate canvas: 512×512 px @ 300 DPI**

| Filename | Type | Color | Suggested face icon |
|---|---|---|---|
| `die_potency.png` | POT — main damage | Red (bg #FCEBEB, border #E24B4A) | Flame, skull, or splash |
| `die_stability.png` | STB — 0.8x potency damage | Blue (bg #E6F1FB, border #378ADD) | Anchor, shield-tower, mountain |
| `die_boost.png` | BST — multiplies neighbors | Purple (bg #EEEDFE, border #7F77DD) | Starburst, sparkle, up-arrow |
| `die_heal.png` | HEAL — restores composure | Green (bg #EAF3DE, border #639922) | Heart, cross, leaf |
| `die_shield.png` | SHD — adds shield | Teal (bg #E1F5EE, border #1D9E75) | Shield outline |

**Composition rules:**
- **Flat-faced (top-down view)** — looking straight at the face of the die, not 3/4 angle. The game uses pure 2D rotation animation, so flat reads better.
- **Square with rounded corners** — slight corner radius, like a wooden block.
- **Center of die kept BLANK** — the middle 30% of the face is empty space. The game renders the face value (1, 2, 3, 4, etc.) as text on top of your art at runtime.
- **Icon goes in upper-left corner** OR is small and recessed at the edges, NOT in the center.
- **Background transparent** — game tray frame shows through the corners.
- **Style consistency** — all 5 dice should feel like the same set (same border treatment, same corner radius, same icon size). Players need to read them as "the same kind of object" with different functions.

---

## 5. Background — full-screen shop interior

**1 file.**

**Procreate canvas: 1242×2688 px @ 300 DPI** (native iPhone Pro Max resolution; scales cleanly to smaller iPhones)

**Filename:** `shop_background.png`

**Composition zones (top to bottom):**

```
┌─────────────────────────────────────────┐
│  TOP 220px — DEBUG BAR ZONE             │
│  Don't draw here, gets covered          │
├─────────────────────────────────────────┤
│  220-360px — HEADER ZONE                │
│  Composure bar + potion icon overlays   │
│  Keep neutral, mid-tone                 │
├─────────────────────────────────────────┤
│  360-960px — CUSTOMER SCENE (~600px)    │
│  • LEFT third: Ednar's counter area    │
│    (counter + shelves + jars)           │
│  • RIGHT two-thirds: customer line      │
│    space — show shop entrance / door /  │
│    a hint of village outside on far     │
│    right edge                           │
├─────────────────────────────────────────┤
│  960-1100px — PROFILE ROW ZONE          │
│  Solid neutral background, no detail    │
├─────────────────────────────────────────┤
│  1100-2200px — CAULDRON ZONE (~1100px)  │
│  Empty floor / table / Ednar's          │
│  workspace. Cauldron art layers on top  │
│  of this. Hanging herbs OK in upper     │
│  edges. Floor texture in lower edges.   │
├─────────────────────────────────────────┤
│  2200-2688px — DICE TRAY ZONE (~488px)  │
│  Wooden counter / table edge.           │
│  Subtle texture, not busy.              │
└─────────────────────────────────────────┘
```

**Composition rules:**
- **Reading order is top→bottom** (customer area → action area → dice area), so light/depth should support that flow.
- **Avoid busy patterns** in the cauldron and dice zones — the dice and nodes need to read clearly on top.
- **Color palette:** warm wood, candlelight, shadowy corners. Not too saturated. The portraits and dice are bright; the background should let them pop.

---

## 6. UI icons

**6 files.** Small overlays that sit on top of game UI.

**Procreate canvas: 256×256 px @ 300 DPI** (overkill but allows headroom for retina + future scaling)

| Filename | Where it appears | Style |
|---|---|---|
| `icon_heart.png` | Composure bar, healing floaters | Filled red heart |
| `icon_shield.png` | Shield badge next to Ednar, shielding floaters | Teal/green shield silhouette |
| `icon_potion.png` | Potions-brewed counter in header | Purple potion bottle (small) |
| `icon_brew_sign.png` | The "BREW" wooden sign on the ladle | Carved wooden plank texture, "BREW" letters carved/painted on |
| `icon_hamburger.png` | Top-right menu toggle | 3 horizontal lines, neutral |
| `icon_back_arrow.png` | (Future) back to map button | Simple back arrow |

**Composition rules:**
- **Icons should read at 32×32 actual pixel size** (which means very simple silhouettes — no fine detail).
- **Single dominant color** per icon (heart = red, shield = teal, etc.) so they're recognizable at a glance.
- **Background transparent.**

---

## Animation notes (informational — not art deliverables)

The art is static. Animation is handled by the game engine (SwiftUI). What follows is just so you know how your art will move, in case it affects how you draw it.

### Dice rolling — Path B with drop-from-above bounce

When dice appear in the tray each turn, they animate as follows:
- **Origin**: each die starts ~80px above its final tray slot (just above the tray, NOT from the top of the screen — short fall focused on the tray area).
- **Entry**: appears instantly fully visible at origin position (no fade-in — punchier, more physical).
- **Fall**: descends with gravity-like easing (accelerates toward the slot) while rotating 360-720° (random per die, mix of clockwise and counter-clockwise).
- **Landing**: at the slot, bounces — overshoots by ~8px down, springs back up ~4px, settles into final position.
- **Duration**: ~600ms per die, end-to-end.
- **Stagger**: each die starts ~80-100ms after the previous one, so they patter in like real dice hitting a table rather than landing simultaneously.
- **Optional polish**: a brief radial glow/dust effect at the impact point on landing (rendered by the engine, no art needed).
- **Tiny shadow under each die** that compresses slightly on bounce (also engine-rendered).

**Implication for your art:** flat-faced dice are correct. Symmetrical icons rotate cleanly. Asymmetric icons (like a flame leaning right) will look like they're tumbling during the fall, which is the desired feel.

### Customer scene — slide animations

When you tap a profile to swap customers:
- Customers slide horizontally between positions with 0.35s ease-in-out
- Active (front) customer is at full size and full opacity
- Waiting customers are at 0.85x scale and 50% opacity (dimmed)

**Implication for your art:** portrait composition should look good at both full and 0.85x scales. Don't put critical details in the bottom corners that might get cut off when scaled.

### Brew animation phases

When the player taps BREW, a 7-phase sequence runs (~2-3 seconds total):
1. Boost dice pulse (placed BST dice scale up briefly)
2. Heal applies (composure bar grows, +N float from Ednar)
3. Shield applies (shield badge appears next to Ednar)
4. Brew damage (active customer shakes, -N floats from them)
5. Each customer attacks (one-by-one, customer shakes, composure flashes red, -N floats from Ednar)
6. Patience ticks (silent, just rings update)
7. Expirations if any

**Implication for your art:** characters need to look good both relaxed AND mid-shake. The shake is a horizontal wiggle of ~6px, fast. If your character has long thin limbs that would look silly wiggling, design around it.

### Ednar expression switching

The 5 Ednar expressions swap based on game state (composure level, mid-brew, post-defeat). The swap is INSTANT — no cross-fade. Since all 5 share the same body pose, the eye reads it as the face changing, not as a different image.

---

## Placeholder workflow while iterating

While you make real art, drop these grey placeholders into the Xcode asset catalog:

1. Make a 1024×1024 grey PNG with "MILDRED" written in the middle. Name it `mildred.png`. Repeat for all 14 customers.
2. Same trick for Ednar expressions — 1024×1536 grey with "EDNAR CALM" / "EDNAR FOCUSED" etc.
3. Cauldron — three 2048×1536 grey-with-label files.
4. Dice — five 512×512 grey-with-label files.
5. Background — one 1242×2688 grey-with-label file.

When you make the real art, just replace the file with the same filename. Xcode picks up the new image automatically — no code changes needed.

This means **art and code can progress independently**. Claude in Xcode builds Phase 1-8 with placeholders. You make real art on your own timeline. When you're ready, Phase 9 ("Art" phase) is just "drop in real PNGs."

---

## Source files

Keep your `.procreate` source files SEPARATE from the Xcode project. Suggested folder structure on iPad:

```
Procreate Files/
└─ Ednars Cauldron Art/
   ├─ Characters/
   │  ├─ mildred.procreate
   │  ├─ tomik.procreate
   │  └─ ...
   ├─ Ednar/
   │  └─ ednar_expressions.procreate  (one file with 5 layer variants)
   ├─ Cauldron/
   │  └─ cauldron_layered.procreate   (one file with 3 group layers)
   ├─ Dice/
   │  └─ dice.procreate               (one file with 5 layer variants)
   ├─ Background/
   │  └─ shop_background.procreate
   └─ Icons/
      └─ icons.procreate              (one file with 6 layer variants)
```

This way you have one place to find and re-edit any asset.

---

## Final summary

**34 PNGs total. All transparent backgrounds (except shop_background). Drop into Xcode asset catalog with exact filenames above. The game references them by name; rename one and it breaks.**

Tell Claude in Xcode at Phase 9 of the REPLACEMENT_PLAN: "Use the asset catalog. I have placeholder PNGs ready to migrate into Assets.xcassets. Load via Image('filename'). Refer to ART_SPEC.md for the asset list. Files go in the existing `CauldronGame/` folder, asset catalog Resources."
