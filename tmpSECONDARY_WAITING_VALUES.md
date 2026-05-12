# SECONDARY_WAITING_VALUES.md
**Ednar's Potion Cauldron — 3-Position Character Scaling System**

> **Created:** May 12, 2026  
> **Status:** IMPLEMENTED  
> **Purpose:** Document the addition of secondary waiting position values for queue-aware character scaling

---

## PROBLEM STATEMENT

### Original System (2 Positions)
Each character had **2 sets of scale/position values**:
- **Active position** (queue[0]): Custom width/height/x/y per character
- **Waiting position** (queue[1+]): Single set of width/height/x/y values

### The Issue
When customers swapped queue positions:
- Characters at `queue[1]` (first waiting spot): Used waiting values ✅
- Characters at `queue[2]` (second waiting spot): Used **SAME** waiting values ❌

**Visual Problem:**
- User carefully positioned each character in layout editor for aesthetic appearance
- When characters swapped positions, they looked wrong because both waiting spots shared one set of values
- `queue[1]` might need: `0.8× scale, 0pt X offset`
- `queue[2]` might need: `0.75× scale, 5pt X offset`
- But both used the same values → incorrect visual appearance

---

## SOLUTION: 3-POSITION SYSTEM

### New Data Structure

Each character now has **3 complete sets of scale/position values**:

```swift
struct CharacterScale {
    // ACTIVE POSITION (queue[0])
    var width: Double = 1.0
    var height: Double = 1.0
    var x: Double = 0.0
    var y: Double = 0.0
    
    // WAITING POSITION 1 (queue[1])
    var waitingWidth: Double = 1.0      // ← CHANGED: Now defaults to match active
    var waitingHeight: Double = 1.0     // ← CHANGED: Now defaults to match active
    var waitingX: Double = 0.0
    var waitingY: Double = 0.0
    
    // WAITING POSITION 2 (queue[2]) ← NEW!
    var waiting2Width: Double = 1.0     // ← NEW: Also defaults to match active
    var waiting2Height: Double = 1.0    // ← NEW: Also defaults to match active
    var waiting2X: Double = 0.0         // ← NEW
    var waiting2Y: Double = 0.0         // ← NEW
}
```

### Default Values Strategy

**All waiting positions now default to match active position (1.0×1.0×0,0)**
- This ensures new characters appear correctly sized without manual tuning
- User can adjust individual positions in layout editor if needed
- Maintains pixel-accurate sizing system introduced May 12, 2026

**Old defaults (May 10, 2026):**
- Active: 1.0×1.0×0,0 ✅
- Waiting: 0.8×0.8×0,0 ❌ (caused shrinking depth effect)

**New defaults (May 12, 2026):**
- Active: 1.0×1.0×0,0 ✅
- Waiting 1: 1.0×1.0×0,0 ✅ (matches active)
- Waiting 2: 1.0×1.0×0,0 ✅ (matches active)

---

## LAYOUT EDITOR CHANGES

### Previous UI (2 Sections)
- ⭐️ **ACTIVE POSITION** (green header)
- ⏸️ **WAITING POSITION** (orange header)

### New UI (3 Sections)
- ⭐️ **ACTIVE POSITION** (green header) — Queue[0]
- ⏸️ **WAITING POSITION 1** (orange header) — Queue[1] ← RENAMED
- ⏸️ **WAITING POSITION 2** (purple header) — Queue[2] ← NEW!

### Each Section Contains
- 🔗 **Uniform Scale** slider (yellow) — Adjusts width AND height together
- **Width** slider (cyan) — Independent horizontal scaling
- **Height** slider (cyan) — Independent vertical scaling
- **X Offset** slider (cyan) — Horizontal position offset
- **Y Offset** slider (cyan) — Vertical position offset

---

## RENDERING LOGIC

### Previous (2-Way Choice)
```swift
let effectiveWidth = isActive ? customerSceneWidth : customerWaitingWidth
let effectiveHeight = isActive ? customerSceneHeight : customerWaitingHeight
let effectiveX = isActive ? customerSceneX : customerWaitingX
let effectiveY = isActive ? customerSceneY : customerWaitingY
```

### New (3-Way Choice)
```swift
let effectiveWidth: Double
let effectiveHeight: Double
let effectiveX: Double
let effectiveY: Double

if isActive {
    effectiveWidth = customerSceneWidth
    effectiveHeight = customerSceneHeight
    effectiveX = customerSceneX
    effectiveY = customerSceneY
} else if queueIndex == 1 {
    effectiveWidth = customerWaitingWidth
    effectiveHeight = customerWaitingHeight
    effectiveX = customerWaitingX
    effectiveY = customerWaitingY
} else {
    effectiveWidth = customerWaiting2Width
    effectiveHeight = customerWaiting2Height
    effectiveX = customerWaiting2X
    effectiveY = customerWaiting2Y
}
```

---

## FILES MODIFIED

### 1. PotionShopLayoutConfig.swift
**Changes:**
- Added 4 new fields to `CharacterScale` struct:
  - `waiting2Width: Double = 1.0`
  - `waiting2Height: Double = 1.0`
  - `waiting2X: Double = 0.0`
  - `waiting2Y: Double = 0.0`
- Changed waiting defaults from 0.8 to 1.0 (match active)
- Updated all 14 character entries in `perCharacterScales` dictionary

**Backup:** `PotionShopLayoutConfig_BACKUP_May12_2026_PreWaiting2.swift`

---

### 2. PotionShopGameView.swift
**Changes:**
- Added new **"⏸️ WAITING POSITION 2"** UI section (purple header)
- Added waiting2 uniform scale slider (yellow)
- Added 4 waiting2 sliders (width/height/x/y)
- Renamed "WAITING POSITION" → "WAITING POSITION 1"
- Updated character picker to handle 3 positions

**Backup:** `PotionShopGameView_BACKUP_May12_2026_PreWaiting2.swift`

---

### 3. PotionShopCustomerSceneView.swift
**Changes:**
- Added 4 new parameters to `PotionShopCustomerInSceneView`:
  - `customerWaiting2Width: Double = 1.0`
  - `customerWaiting2Height: Double = 1.0`
  - `customerWaiting2X: Double = 0.0`
  - `customerWaiting2Y: Double = 0.0`
- Updated call site in `PotionShopCustomerSceneView` to pass waiting2 values from config
- Updated rendering logic to use 3-way conditional

**Backup:** `PotionShopCustomerSceneView_BACKUP_May12_2026_PreWaiting2.swift`

---

## REVERSIBILITY

### Method 1: File Restoration (IMPLEMENTED)

**Backup files created:**
- `PotionShopLayoutConfig_BACKUP_May12_2026_PreWaiting2.swift`
- `PotionShopGameView_BACKUP_May12_2026_PreWaiting2.swift`
- `PotionShopCustomerSceneView_BACKUP_May12_2026_PreWaiting2.swift`

**To revert (30-second process):**
1. Delete the 3 modified files
2. Rename backup files (remove `_BACKUP_May12_2026_PreWaiting2` suffix)
3. Clean build (Command+Shift+K)
4. Build and run (Command+R)

**Xcode steps:**
1. Right-click file in Project Navigator → Delete → Move to Trash
2. Repeat for all 3 files
3. Right-click backup files → Rename → Remove backup suffix
4. Product menu → Clean Build Folder
5. Product menu → Build

---

## TESTING CHECKLIST

### Basic Functionality
- ✅ Layout editor shows 3 sections (Active / Waiting 1 / Waiting 2)
- ✅ Each section has 5 sliders (uniform scale + 4 individual)
- ✅ Sliders update instantly in live preview
- ✅ Character picker dropdown shows all 14 characters

### Queue Swap Behavior
- ✅ Start with 3-customer round (Evening: Wendelina, Crispin, Ardo)
- ✅ Wendelina at queue[0] uses active values
- ✅ Crispin at queue[1] uses waiting1 values
- ✅ Ardo at queue[2] uses waiting2 values
- ✅ Tap Ardo → He moves to queue[0] (active values)
- ✅ Wendelina moves to queue[2] (waiting2 values)
- ✅ Crispin stays at queue[1] (waiting1 values)

### Visual Appearance
- ✅ All characters appear at correct size (1.0× default)
- ✅ No unexpected shrinking or distortion
- ✅ Smooth animations during queue swaps
- ✅ Per-character scaling applies correctly

---

## KNOWN EDGE CASES

### Queue Size Variations
- **1 customer (Night boss):** Only uses active position (queue[0])
- **2 customers:** Uses active (queue[0]) + waiting1 (queue[1])
- **3 customers:** Uses active (queue[0]) + waiting1 (queue[1]) + waiting2 (queue[2])

**Waiting2 values are ignored for 1-2 customer rounds** — this is expected behavior.

### Queue Index Out of Range
Current code handles this gracefully:
```swift
} else if queueIndex == 1 {
    // Waiting 1 values
} else {
    // Waiting 2 values (for queueIndex 2, 3, 4, etc.)
}
```

If future rounds have 4+ customers, positions 3+ will reuse waiting2 values.

---

## FUTURE ENHANCEMENTS

### Potential Additions (Not Implemented)
1. **Waiting Position 3** — For 4-customer rounds (if added later)
2. **Per-position depth scaling** — Automatic scale reduction based on queue position
3. **Position-aware attack values** — Different attack damage based on queue position
4. **Visual depth cues** — Blur/opacity based on queue depth

### NOT Recommended
- **Dynamic position count** — 3 positions is sufficient for Day 1 (max 3 customers)
- **Feature toggle** — User prefers clean implementation without toggles
- **Auto-scaling formulas** — User wants manual control per character

---

## COMPATIBILITY NOTES

### Pixel-Accurate Sizing System (May 12, 2026)
This change is **compatible** with the pixel-accurate sizing system:
- All characters still drawn on 1536×1024 canvas
- `ednarBaseScale: 0.15` unchanged
- `customerSceneBaseScale: 2.0` unchanged
- Default scales changed from 0.8 to 1.0 (no distortion)

### Active/Waiting Scale System (May 10, 2026)
This change **extends** the existing system:
- Active position logic unchanged
- Waiting position split into 2 positions
- Smooth transitions still work via `matchedGeometryEffect`

---

## CONTEXT FILE UPDATES

### CAULDRON_CONTEXT.md
**Section 12.1.2** updated to reflect:
- 3-position system (Active / Waiting 1 / Waiting 2)
- New default values (1.0×1.0× for all positions)
- Layout editor UI structure (3 sections)
- Rendering logic (3-way conditional)

### MASTER_CONTEXT.md
**Phase 7h** updated to reflect:
- Secondary waiting values implementation
- Default value changes (0.8 → 1.0)
- 3-position queue-aware scaling

---

## DESIGN RATIONALE

### Why Default to 1.0× (Match Active)?

**Problem with 0.8× default:**
- Characters appeared smaller than intended when waiting
- Required manual adjustment for every character
- Broke pixel-accurate sizing system (characters drawn at correct size in Procreate appeared wrong in-game)

**Solution with 1.0× default:**
- Characters appear at uploaded size regardless of queue position
- No manual adjustment needed for most characters
- Pixel-accurate sizing preserved (upload once, perfect size)
- User can still adjust individual positions for depth effects if desired

### Why Not Auto-Scale Based on Queue Position?

User prefers **manual control** over automated formulas:
- Each character has unique visual design
- Some characters look better smaller/larger
- Automated scaling removes artistic control
- Layout editor provides real-time visual feedback

---

## RELATED SESSIONS

- **May 12, 2026 (Morning):** Pixel-accurate sizing system implemented
- **May 10, 2026:** Active/waiting scale system introduced
- **May 6, 2026:** Per-character scaling system introduced
- **May 5, 2026:** Live preview overlay layout editor introduced

---

**END OF SECONDARY_WAITING_VALUES.md**
