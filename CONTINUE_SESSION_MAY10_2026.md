# SESSION CONTINUATION - May 10, 2026
**Ednar's Potion Cauldron - Customer Portrait Integration**

---

## WHAT WAS JUST COMPLETED

### ✅ Customer Scene Portrait Default Scaling + Uniform Scale Control (May 10, 2026)

**Problem Solved:**
- New customer portraits (Greta, Sister Halla, Wendelina, Grimdrek, Hexa Mott) were appearing too small at 1.0× default scale
- User's Procreate canvas is 1536×1024 px (3:2 landscape), not the originally documented 512×768 px
- Needed a quick way to scale characters proportionally without adjusting width/height separately

**Changes Made:**

**1. Updated Default Scales (PotionShopLayoutConfig.swift):**
- **Before:** All 5 new characters defaulted to 1.0× width, 1.0× height (too small)
- **After:** All 5 new characters default to **1.6× width, 2.0× height** (matches Ednar's proportions)
- Characters affected: Greta, Sister Halla, Wendelina, Grimdrek, Hexa Mott
- Mildred & Tomik: Kept existing tuned values (~2.18×2.03× and ~2.09×1.90×)

**2. Added Uniform Scale Slider (PotionShopGameView.swift):**
- **Location:** Debug Menu (⚙️) → Layout Editor → 🧍 Customers section
- **Position:** At the top, below character picker, above individual width/height sliders
- **Label:** "🔗 Uniform Scale" (yellow color to distinguish from cyan individual controls)
- **Behavior:** Dragging slider adjusts **both width AND height** to the same value
- **Range:** 0.5× to 3.0× (same as individual sliders)
- **Per-character:** Only affects the currently selected character in picker
- **Helper text:** "Adjusts width AND height together" (italic, small font)

**3. Updated Canvas Dimensions Documentation (CAULDRON_CONTEXT.md):**
- **Section 16.1** completely rewritten
- **Old:** 512×768px @ 300 DPI (2:3 portrait)
- **New:** 1536×1024px @ 300 DPI (3:2 landscape)
- **Reference:** All portraits scaled relative to `ednar_idle.png`
- **Updated header** with new canvas info + uniform scale feature

**Files Modified:**
1. **PotionShopLayoutConfig.swift** - Updated 5 character defaults from 1.0×1.0× to 1.6×2.0×
2. **PotionShopGameView.swift** - Added uniform scale slider UI to 🧍 Customers section
3. **CAULDRON_CONTEXT.md** - Updated canvas dimensions + added uniform scale docs

**How It Works:**

**Workflow for New Characters:**
1. Open Layout Editor → Tap 🧍 Customers pill
2. Select character from picker (e.g., "Greta")
3. Character appears at **1.6× × 2.0×** (visible size, not tiny 1.0×!)
4. Drag **🔗 Uniform Scale** slider to quickly adjust both dimensions together
5. OR drag individual Width/Height sliders for asymmetric adjustment
6. Adjust X/Y position sliders to fine-tune placement
7. Character updates instantly in live preview

**Workflow for Existing Characters:**
- Mildred & Tomik: Already tuned, uniform slider shows their current width value
- Dragging uniform slider will **override** existing asymmetric scaling
- Individual sliders still available for precise control

**Current Character Scales:**

| Character    | Width  | Height | X      | Y     | Notes                    |
|--------------|--------|--------|--------|-------|--------------------------|
| Mildred      | 2.18×  | 2.03×  | -5.3pt | 5.6pt | Already tuned            |
| Tomik        | 2.09×  | 1.90×  | -17pt  | 18pt  | Already tuned            |
| Greta        | 1.6×   | 2.0×   | 0pt    | 0pt   | ✅ NEW - Default visible |
| Sister Halla | 1.6×   | 2.0×   | 0pt    | 0pt   | ✅ NEW - Default visible |
| Wendelina    | 1.6×   | 2.0×   | 0pt    | 0pt   | ✅ NEW - Default visible |
| Grimdrek     | 1.6×   | 2.0×   | 0pt    | 0pt   | ✅ NEW - Default visible |
| Hexa Mott    | 1.6×   | 2.0×   | 0pt    | 0pt   | ✅ NEW - Default visible |

---

### ✅ Customer Scene Portrait System Integration (Previous Session)

**7 characters integrated with scene portraits:**
- Mildred, Tomik, Greta, Sister Halla, Wendelina, Grimdrek, Hexa Mott

**Files Modified:**
1. **PotionShopLayoutConfig.swift** - Added 5 new characters to `perCharacterScales` dictionary (all default 1.0×, 0 offset) ← **NOW UPDATED TO 1.6×2.0×**
2. **PotionShopGameView.swift** - Updated character picker dropdown to include all 7 characters + **ADDED UNIFORM SCALE SLIDER**
3. **PotionShopDebugMenu.swift** - Updated clipboard output to include all 7 characters' values
4. **PotionShopData.swift** - Updated `scenePortrait` fields from `"characterid"` to `"characterid_scene"` for 5 characters

**Canvas Dimensions Specified:**
- ~~**Recommended**: 512×768px @ 300 DPI~~ ← OLD
- ~~**Aspect Ratio**: 2:3 (CRITICAL - DO NOT CHANGE)~~ ← OLD
- ~~**Alternative**: 1024×1536px (matches Ednar expressions)~~ ← OLD
- **ACTUAL**: 1536×1024px @ 300 DPI (3:2 landscape) ← **CURRENT**
- **Default Scale**: 1.6× width, 2.0× height (matches Ednar) ← **NEW**

**Documentation Updated:**
- **CAULDRON_CONTEXT.md** Section 16 completely rewritten with:
  - ✅ Correct canvas dimension specifications (1536×1024)
  - ✅ Default scale documentation (1.6× × 2.0×)
  - ✅ Uniform scale slider feature
  - Asset naming conventions (unchanged)
  - Integration status table (7 integrated, 7 pending)
  - Updated total asset count from 34 to 47

---

## CURRENT STATE

### Character Portrait Status

| Character    | Scene Asset         | Config Entry | Default Scale | Status        |
|--------------|---------------------|--------------|---------------|---------------|
| Mildred      | `mildred_scene`     | ✅           | 2.18×2.03×    | ✅ INTEGRATED |
| Tomik        | `tomik_scene`       | ✅           | 2.09×1.90×    | ✅ INTEGRATED |
| Greta        | `greta_scene`       | ✅           | **1.6×2.0×**  | ✅ INTEGRATED |
| Sister Halla | `sister_halla_scene`| ✅           | **1.6×2.0×**  | ✅ INTEGRATED |
| Wendelina    | `wendelina_scene`   | ✅           | **1.6×2.0×**  | ✅ INTEGRATED |
| Grimdrek     | `grimdrek_scene`    | ✅           | **1.6×2.0×**  | ✅ INTEGRATED |
| Hexa Mott    | `hexa_mott_scene`   | ✅           | **1.6×2.0×**  | ✅ INTEGRATED |
| Pemberton    | `pemberton_scene`   | ❌           | (not added)   | 🟡 PENDING    |
| Ardo         | `ardo_scene`        | ❌           | (not added)   | 🟡 PENDING    |
| Bram         | `bram_scene`        | ❌           | (not added)   | 🟡 PENDING    |
| Crispin      | `crispin_scene`     | ❌           | (not added)   | 🟡 PENDING    |
| Ironhilde    | `ironhilde_scene`   | ❌           | (not added)   | 🟡 PENDING    |
| Carmilla     | `carmilla_scene`    | ❌           | (not added)   | 🟡 PENDING    |
| Royal Envoy  | `royal_envoy_scene` | ❌           | (not added)   | 🟡 PENDING    |

**Note:** Bold = newly updated defaults (was 1.0×1.0×, now 1.6×2.0× to match Ednar proportions)

### Layout Editor Features

**🧍 Customers Section:**
- **Character picker dropdown** (7 characters)
- **🔗 Uniform Scale slider** (0.5×-3.0×) - **NEW!** Adjusts width AND height together
- Width/Height sliders (0.5×-3.0×) - Independent control
- X/Y position sliders (±200pt)
- Live preview - changes apply instantly
- No circle clipping - full images visible

**How to Use Uniform Scale:**
1. Debug Menu (⚙️) → Layout Editor
2. Tap 🧍 Customers pill
3. Select character from dropdown (e.g., "Greta")
4. **Drag "🔗 Uniform Scale" slider** (yellow) to adjust both width AND height
5. OR drag individual Width/Height sliders for asymmetric scaling
6. Adjust X/Y sliders to position
7. Watch character resize in real-time!

**Current Values:**
- Mildred: 2.18×2.03×, -5pt, 6pt (already tuned)
- Tomik: 2.09×1.90×, -17pt, 18pt (already tuned)
- Greta: **1.6×2.0×**, 0pt, 0pt (**NEW - default visible size**)
- Sister Halla: **1.6×2.0×**, 0pt, 0pt (**NEW - default visible size**)
- Wendelina: **1.6×2.0×**, 0pt, 0pt (**NEW - default visible size**)
- Grimdrek: **1.6×2.0×**, 0pt, 0pt (**NEW - default visible size**)
- Hexa Mott: **1.6×2.0×**, 0pt, 0pt (**NEW - default visible size**)

---

## HOW TO TEST THE NEW FEATURES

### Test 1: Verify New Characters Appear at Visible Size

**What to check:** Greta, Sister Halla, Wendelina, Grimdrek, and Hexa Mott should now appear at a reasonable size (not tiny like before).

**Steps:**
1. **Run the app** in Xcode (Command+R)
2. Navigate to Ednar's Potion Cauldron
3. **Play through rounds** to encounter the new characters:
   - **Morning (Round 1):** Mildred + Tomik (already tuned - unchanged)
   - **Afternoon (Round 2):** Pemberton + **Greta** ← **Should be 1.6×2.0× now!**
   - **Evening (Round 3):** **Wendelina** + Crispin + Ardo ← **Should be 1.6×2.0× now!**
   - **Night (Round 4):** **Grimdrek** ← **Should be 1.6×2.0× now!**

**Expected Result:**
- ✅ Greta, Wendelina, and Grimdrek appear **visibly larger** than before
- ✅ Characters are **proportional** (not squished or stretched weirdly)
- ✅ Characters **don't overlap** Ednar or each other (may need X/Y tuning)

**If characters are too small/large:**
- Use Layout Editor to adjust (see Test 2)

---

### Test 2: Use Uniform Scale Slider

**What to check:** The new 🔗 Uniform Scale slider should adjust both width AND height together.

**Steps:**
1. **Open Debug Menu:** Tap ⚙️ gear icon in top-right
2. **Tap "Layout Editor (Live Overlay)"**
3. **Tap 🧍 Customers pill** (in horizontal pill picker at top)
4. **Select a character** from dropdown (e.g., "Greta")
5. **Look for the yellow "🔗 Uniform Scale" slider** (should be at the top, below character picker)
6. **Drag the slider left** (smaller) or **right** (larger)

**Expected Result:**
- ✅ **Both Width AND Height** values update together
- ✅ Character **resizes proportionally** in live preview
- ✅ Helper text says **"Adjusts width AND height together"**
- ✅ Slider is **yellow** (different from cyan individual sliders below)

**Try this:**
- Drag uniform slider to **2.5×** → character gets bigger
- Drag uniform slider to **1.0×** → character shrinks
- Now drag **individual Width slider** to 2.0× → only width changes (breaks proportional scaling)
- Drag **uniform slider again** → width AND height reset to same value

---

### Test 3: Compare Uniform vs Individual Sliders

**What to check:** Uniform slider is a shortcut; individual sliders still work independently.

**Steps:**
1. **Open Layout Editor** → 🧍 Customers → Select "Sister Halla"
2. **Drag 🔗 Uniform Scale to 2.0×** 
   - Width should be 2.0×
   - Height should be 2.0×
3. **Drag individual Width slider to 2.5×**
   - Width becomes 2.5×
   - Height stays 2.0× (asymmetric!)
4. **Drag 🔗 Uniform Scale slider again**
   - Both Width AND Height jump to whatever uniform slider shows
   - This **overrides** the asymmetric scaling

**Expected Result:**
- ✅ Uniform slider = quick proportional scaling
- ✅ Individual sliders = precise asymmetric control
- ✅ Uniform slider always sets width = height = slider value

---

### Test 4: Verify All 7 Characters in Picker

**What to check:** Character picker should have all 7 integrated characters.

**Steps:**
1. **Open Layout Editor** → 🧍 Customers
2. **Tap character picker dropdown**
3. **Check the list:**
   - Mildred ✅
   - Tomik ✅
   - Greta ✅
   - Sister Halla ✅
   - Wendelina ✅
   - Grimdrek ✅
   - Hexa Mott ✅

**Expected Result:**
- ✅ All 7 characters listed
- ✅ Selecting each character shows their current scale values in sliders
- ✅ Mildred/Tomik show tuned values (~2.18×, ~2.09×)
- ✅ Greta/Sister Halla/Wendelina/Grimdrek/Hexa Mott show **1.6×2.0×** defaults

---

### Test 5: Position New Characters (Optional Fine-Tuning)

**What to adjust:** If any new character overlaps Ednar or another character, adjust X/Y position.

**Steps:**
1. **Play to Evening round** (3 customers: Wendelina, Crispin, Ardo)
2. **Check if characters overlap** or are positioned oddly
3. **Open Layout Editor** → 🧍 Customers → Select "Wendelina"
4. **Adjust X slider** (move left/right) until Wendelina doesn't overlap
5. **Adjust Y slider** (move up/down) for vertical alignment
6. **Repeat for other characters** as needed

**Expected Result:**
- ✅ All characters visible and clearly separated
- ✅ No clipping off screen edges
- ✅ Characters form a nice line from left to right

---

## TROUBLESHOOTING

### Problem: "Characters are still tiny!"

**Cause:** You might be looking at a character that doesn't have art yet (Pemberton, Ardo, Bram, Crispin, Ironhilde, Carmilla, Royal Envoy).

**Solution:** 
- These 7 characters are NOT in the config yet (see "PENDING" in table above)
- They'll show emoji fallbacks at default size
- To integrate them, follow same process as before (add to config, update picker, etc.)

---

### Problem: "Uniform slider doesn't exist!"

**Cause:** You might be looking at the wrong section or Xcode didn't rebuild.

**Solution:**
1. **Force quit the app** completely (swipe up in app switcher)
2. **Clean build folder** in Xcode (Product → Clean Build Folder, or Shift+Command+K)
3. **Rebuild** (Command+B)
4. **Run again** (Command+R)
5. Check you're in **🧍 Customers section** (not 🧙 Ednar or 🍲 Cauldron)

---

### Problem: "Layout values aren't saving!"

**Cause:** Layout editor values are NOT persistent in v1 (they reset when app closes).

**Solution:**
- To save permanently: Use **"📋 Copy Layout Values"** in debug menu
- Paste values into `PotionShopLayoutConfig.swift` defaults
- Rebuild app

---

## NEXT STEPS

### Option 1: Position New Characters
Use Layout Editor to adjust the 5 new characters:
1. Debug Menu (⚙️) → Layout Editor
2. Tap 🧍 Customers pill
3. Select character from dropdown
4. **Use 🔗 Uniform Scale for quick sizing**
5. Use X/Y sliders for positioning
6. Copy layout values and paste to lock in

### Option 2: Add Remaining 7 Characters
Follow same process to integrate:
- Pemberton, Ardo, Bram, Crispin, Ironhilde, Carmilla, Royal Envoy

**Steps:**
1. Add entries to `PotionShopLayoutConfig.swift` `perCharacterScales` (default 1.6×2.0×)
2. Add to character picker in `PotionShopGameView.swift`
3. Add to clipboard output in `PotionShopDebugMenu.swift`
4. Update `scenePortrait` in `PotionShopData.swift`

### Option 3: Continue Other Work
- Round-end overlays (Phase 9)
- Trait implementation (Phase 10)
- Day 2/3 (Phase 11)
- Other art assets

---

## KEY TECHNICAL DETAILS

### Asset Naming Convention
- Profile: `characterid.png` (e.g., `mildred.png`)
- Scene: `characterid_scene.png` (e.g., `mildred_scene.png`)

### Code Architecture
```
Layout Editor Sliders
    ↓
PotionShopLayoutConfig.perCharacterScales[id]
    ↓
PotionShopGameView (passes config)
    ↓
PotionShopCustomerSceneView (reads config)
    ↓
PotionShopCustomerInSceneView (applies scale/offset)
    ↓
Visual renders on screen
```

### Important Files
- **PotionShopLayoutConfig.swift** - Stores all layout values
- **PotionShopData.swift** - Character definitions with `scenePortrait` field
- **PotionShopGameView.swift** - Character picker UI
- **PotionShopDebugMenu.swift** - Clipboard copy function
- **CAULDRON_CONTEXT.md** - Complete documentation

---

## CRITICAL REMINDERS

1. **2:3 aspect ratio is mandatory** for customer scene portraits
2. **Always prefix types with `PotionShop`** to avoid name collisions
3. **Asset names must match exactly** (case-sensitive, no `.png` suffix in code)
4. **Use Layout Editor** to position characters - instant live preview
5. **Copy layout values** via Debug Menu → "📋 Copy Layout Values"

---

## TO RESUME IN NEW CHAT

Paste this prompt:

> I'm continuing work on Ednar's Potion Cauldron. We just integrated 7 customer scene portraits (Mildred, Tomik, Greta, Sister Halla, Wendelina, Grimdrek, Hexa Mott). Read CAULDRON_CONTEXT.md and CONTINUE_SESSION_MAY10_2026.md for full context. 
>
> Current status: 7 characters have art and config entries, 7 are still pending. Layout editor has character picker with live preview for positioning.
>
> What would you like to work on next?

**Attach these files:**
- CAULDRON_CONTEXT.md
- CONTINUE_SESSION_MAY10_2026.md
- PotionShopLayoutConfig.swift
- PotionShopData.swift
- PotionShopGameView.swift
- PotionShopDebugMenu.swift

---

**End of continuation document**
