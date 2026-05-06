# DUAL PORTRAIT SYSTEM - IMPLEMENTATION COMPLETE
**Session Date:** May 5, 2026  
**Status:** ✅ IMPLEMENTED - Ready for Testing  
**Context:** Ednar's Potion Cauldron - Customer dual portrait system

---

## 📋 SESSION SUMMARY

### **User Request:**
Implement dual portrait system for customers:
- **Scene Portraits** - Full body/bust images for customer scene (big visual area)
- **Profile Portraits** - Head/face closeups for profile row (buttons)

### **User Decisions:**
1. **Inspect strip:** Use `portrait` (head closeup - matches profile row) ✅
2. **Testing strategy:** Mildred only first (safer approach) ✅
3. **Fallback:** Profile → Emoji (graceful degradation) ✅

### **What Was Implemented:**
1. ✅ Added `scenePortrait` field to `PotionShopCharacter` struct
2. ✅ Updated all 14 characters in `PotionShopData.swift`:
   - Mildred uses `"mildred_scene"` (ready for real art)
   - All others temporarily use their current portrait name
3. ✅ Created new `sceneImageOrFallback()` function in `PotionShopImageLoader`
4. ✅ Updated customer scene view to use new function
5. ✅ Profile row and inspect strip unchanged (still use head closeups)

---

## 🎨 ART SPECIFICATIONS

### **Profile Portraits (Head Closeups):**
```
Procreate Canvas: 1024×1024 px @ 300 DPI
Aspect Ratio: 1:1 (square)
Crop: Tight on face/head
Background: Transparent
Safe Zone: Center 80% circle (will be cropped to circle)

Files to Create (14 total):
- mildred.png
- tomik.png
- greta.png
- pemberton.png
- sister_halla.png
- ardo.png
- wendelina.png
- bram.png
- crispin.png
- hexa_mott.png
- ironhilde.png
- grimdrek.png
- carmilla.png
- royal_envoy.png
```

### **Scene Portraits (Full Body/Bust):**
```
Procreate Canvas: 1024×1536 px @ 300 DPI
Aspect Ratio: 2:3 (portrait orientation, same as Ednar)
Crop: Waist-up or full body
Background: Transparent
Safe Zone: Center vertical circle (will be cropped to circle)

Files to Create (14 total):
- mildred_scene.png ← ONLY THIS ONE NEEDED FOR INITIAL TEST
- tomik_scene.png
- greta_scene.png
- pemberton_scene.png
- sister_halla_scene.png
- ardo_scene.png
- wendelina_scene.png
- bram_scene.png
- crispin_scene.png
- hexa_mott_scene.png
- ironhilde_scene.png
- grimdrek_scene.png
- carmilla_scene.png
- royal_envoy_scene.png
```

### **Important Notes:**
- Both types will be **cropped to circles** in-game
- Keep important details in the **center safe zone**
- Scene portraits use the **same canvas as Ednar expressions** (1024×1536)
- You can duplicate full body canvas and crop for profile portraits

---

## 💻 CODE CHANGES MADE

### **1. PotionShopModels.swift**

**Added `scenePortrait` field:**
```swift
struct PotionShopCharacter: Identifiable {
    let id: String
    let name: String
    let title: String
    let portrait: String        // Profile row (head closeup)
    let scenePortrait: String   // Customer scene (full body) ← NEW FIELD
    let iconFallback: String
    let difficulty: Int
    // ... rest of fields unchanged ...
}
```

**Added new fallback function:**
```swift
/// Creates a view showing scene portrait with graceful fallback chain:
/// 1. Try scenePortrait asset
/// 2. If not found, try portrait asset (profile closeup)
/// 3. If not found, show emoji
@ViewBuilder
static func sceneImageOrFallback(sceneAsset: String, profileAsset: String, fallbackEmoji: String, size: CGFloat) -> some View {
    if let uiImage = loadImage(named: sceneAsset) {
        // Preferred: scene portrait (full body)
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    } else if let uiImage = loadImage(named: profileAsset) {
        // Fallback: profile portrait (head closeup)
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    } else {
        // Last resort: emoji
        Text(fallbackEmoji)
            .font(.system(size: size * 0.55))
    }
}
```

---

### **2. PotionShopData.swift**

**Updated all 14 characters with `scenePortrait` field:**

```swift
// Example (Mildred - uses real scene portrait):
"mildred": PotionShopCharacter(
    id: "mildred",
    name: "Mildred Honeycomb",
    title: "Anxious Farmwife",
    portrait: "mildred",
    scenePortrait: "mildred_scene",  // ← READY FOR REAL ART
    iconFallback: "🧑‍🌾",
    // ... rest unchanged ...
),

// Example (Tomik - temporary same image):
"tomik": PotionShopCharacter(
    id: "tomik",
    name: "Tomik Cooper",
    title: "Sleepy Apprentice",
    portrait: "tomik",
    scenePortrait: "tomik",  // ← Temporary - will become "tomik_scene" later
    iconFallback: "😴",
    // ... rest unchanged ...
),
```

**All 14 characters updated:**
- ✅ mildred → `scenePortrait: "mildred_scene"` (ready for test)
- ✅ tomik → `scenePortrait: "tomik"` (temporary)
- ✅ greta → `scenePortrait: "greta"` (temporary)
- ✅ pemberton → `scenePortrait: "pemberton"` (temporary)
- ✅ sister_halla → `scenePortrait: "sister_halla"` (temporary)
- ✅ ardo → `scenePortrait: "ardo"` (temporary)
- ✅ wendelina → `scenePortrait: "wendelina"` (temporary)
- ✅ bram → `scenePortrait: "bram"` (temporary)
- ✅ crispin → `scenePortrait: "crispin"` (temporary)
- ✅ hexa_mott → `scenePortrait: "hexa_mott"` (temporary)
- ✅ ironhilde → `scenePortrait: "ironhilde"` (temporary)
- ✅ grimdrek → `scenePortrait: "grimdrek"` (temporary)
- ✅ carmilla → `scenePortrait: "carmilla"` (temporary)
- ✅ royal_envoy → `scenePortrait: "royal_envoy"` (temporary)

---

### **3. PotionShopCustomerSceneView.swift**

**Changed customer scene portrait loading:**

```swift
// BEFORE (line ~336):
PotionShopImageLoader.imageOrEmoji(
    assetName: char.portrait,
    fallbackEmoji: char.iconFallback,
    size: PotionShopSceneLayout.portraitDiameter * scale
)

// AFTER (line ~336):
PotionShopImageLoader.sceneImageOrFallback(
    sceneAsset: char.scenePortrait,   // ← Try scene portrait first
    profileAsset: char.portrait,       // ← Fallback to profile portrait
    fallbackEmoji: char.iconFallback,  // ← Last resort: emoji
    size: PotionShopSceneLayout.portraitDiameter * scale
)
```

**Profile row unchanged (line ~582):**
```swift
// Still uses char.portrait (head closeup)
PotionShopImageLoader.imageOrEmoji(
    assetName: char.portrait,  // ← NO CHANGE
    fallbackEmoji: char.iconFallback,
    size: PotionShopSceneLayout.profileDiameter
)
```

**Inspect strip unchanged (line ~751):**
```swift
// Still uses char.portrait (head closeup)
PotionShopImageLoader.imageOrEmoji(
    assetName: char.portrait,  // ← NO CHANGE
    fallbackEmoji: char.iconFallback,
    size: 62
)
```

---

## ✅ WHAT STAYED THE SAME (ZERO CHANGES)

### **Gameplay:**
- ✅ HP values and calculations
- ✅ Attack values and calculations
- ✅ Patience mechanics and ticking
- ✅ Combat math (brew damage, shield, composure)
- ✅ Queue swapping logic
- ✅ Customer status tracking
- ✅ All trait effects

### **Visuals:**
- ✅ Shake animation when hit
- ✅ Slide-out animation when expired
- ✅ Settle bounce when becoming active
- ✅ Queue swap animation
- ✅ Dimming (waiting customers at 55% opacity)
- ✅ Scaling (active 1.0×, second 0.78×, third 0.72×)
- ✅ 💢 emoji burst on expiration
- ✅ All animation timing

### **Badge Positions:**
- ✅ HP Badge (top-left, -28 offset)
- ✅ Attack Badge (bottom-right, +28 offset)
- ✅ Badge sizes (HP: 26pt, Attack: 22pt)
- ✅ Badge colors (red circles, white text)
- ✅ Badge visibility (HP only on active, Attack on all)

### **Layout:**
- ✅ Portrait diameter: 76pt (in scene)
- ✅ Profile diameter: 56pt (in profile row)
- ✅ Customer X positions (48%, 68%, 88% for 3 customers)
- ✅ Customer Y positions (48%, 55%, 55%)
- ✅ All spacing, padding, borders

---

## 📝 STEP-BY-STEP TESTING INSTRUCTIONS

### **Step 1: Build the Project**

1. **Open Xcode** (if not already open)
2. **Press Command+B** (or Product menu → Build)
3. **Wait for build to complete**
   - ✅ If successful: "Build Succeeded" appears
   - ❌ If errors: **STOP** and report the exact error message

---

### **Step 2: Add Mildred's Scene Portrait (Test Image)**

#### **Option A: Add Real Art (Recommended)**

1. **Create Mildred's Scene Portrait in Procreate:**
   - Canvas: 1024×1536 px @ 300 DPI
   - Draw Mildred full body/bust
   - Keep important parts in center (will be cropped to circle)
   - Export as PNG with transparent background

2. **Add to Xcode:**
   - Open **Assets.xcassets** (in left sidebar)
   - Click **+ button** (bottom-left) → **Image Set**
   - Rename to **`mildred_scene`** (exactly, no spaces)
   - Drag PNG into **1× slot**
   - Verify **Target Membership**: OverQuestMatch3 ✓

#### **Option B: Use Placeholder (Quick Test)**

1. **Duplicate Existing Portrait:**
   - In Assets.xcassets, find **`mildred`**
   - Right-click → Show in Finder
   - Duplicate the file → Rename to `mildred_scene.png`

2. **Add to Xcode:**
   - Open **Assets.xcassets**
   - Click **+ button** → **Image Set**
   - Rename to **`mildred_scene`**
   - Drag duplicated PNG into **1× slot**
   - Verify **Target Membership**: OverQuestMatch3 ✓

---

### **Step 3: Run the Game**

1. **Select a simulator:**
   - Top toolbar → Device dropdown
   - Choose **iPhone 15** or **iPhone 15 Pro**

2. **Press Command+R** (or click Play ▶️ button)

3. **Navigate to game:**
   - Splash/Title screens (if enabled)
   - Map screen → Tap **"Continue to Games"**
   - Game Selector → Tap **"Ednar's Potion Cauldron"**
   - Day 1 / Morning launches (Mildred + Tomik)

---

### **Step 4: Verify the Dual Portrait System**

#### **✅ Expected Results:**

**Customer Scene (Top Section):**
- **Mildred** (left customer):
  - Shows full body/bust image (if real art added)
  - OR same head closeup (if using placeholder)
  - OR 🧑‍🌾 emoji (if `mildred_scene` not found)
- **Tomik** (right customer):
  - Shows same head closeup as before (temporary)

**Profile Row (Below Customer Scene):**
- **Both buttons** show head closeups (unchanged)
- **Patience rings** work correctly (green/amber)
- **Tap behavior** works (swaps customers)

**HP/Attack Badges:**
- **HP badge** (red circle) on Mildred only (active customer)
- **Attack badges** (red circles) on both customers
- **Badges in correct positions** (not shifted)

**Animations Work:**
- **Queue swap:** Tap Tomik's profile → customers swap smoothly
- **Brew animation:** Place dice → BREW → shake/damage/floaters work
- **All existing animations** still work

---

### **Step 5: Troubleshooting**

#### **Build Error: "Missing argument for parameter 'scenePortrait'"**
- **Cause:** Missed updating a character definition
- **Fix:** Check all 14 characters in `PotionShopData.swift`

#### **Mildred Shows Emoji Instead of Image**
- **Cause:** `mildred_scene` not found in Assets
- **Check:**
  1. Is image set named EXACTLY `mildred_scene`?
  2. Did you drag PNG into 1× slot?
  3. Target Membership includes OverQuestMatch3?

#### **Game Crashes on Launch**
- **Action:** Check console (bottom panel in Xcode)
- **Report:** Copy error message

#### **HP/Attack Badges Missing or Misplaced**
- **Action:** Screenshot the issue
- **Report:** Which badges affected, which customers

---

### **Step 6: Once Mildred Test Passes**

1. **Draw the other 13 scene portraits** in Procreate (1024×1536 px)

2. **Add them to Assets.xcassets** (same process as Mildred)

3. **Update PotionShopData.swift:**
   - Change `scenePortrait: "tomik"` to `scenePortrait: "tomik_scene"`
   - Change `scenePortrait: "greta"` to `scenePortrait: "greta_scene"`
   - ... (all 13 remaining customers)

4. **Rebuild and test** again

---

## 🎨 PROCREATE WORKFLOW TIPS

### **Efficient Workflow:**

1. **Create full body portrait** (1024×1536)
2. **Duplicate canvas**
3. **Zoom in on head**
4. **Export cropped version** as profile portrait (1024×1024)
5. **Export full version** as scene portrait

### **Circle Crop Safe Zone:**

**In Procreate:**
1. Create new layer
2. Draw a circle that fits inside canvas
3. Toggle visibility while drawing (shows safe zone)
4. Delete guide layer before exporting

**Safe Zone Sizes:**
- Profile portraits (1024×1024): Keep important details in center 820px circle
- Scene portraits (1024×1536): Keep important details in center vertical oval

---

## 📊 ASSET COUNT

### **Current State:**
- ✅ 14 profile portraits (existing)
- ⚠️ 1 scene portrait ready for testing (mildred_scene)
- ⏳ 13 scene portraits to be created

### **Final State:**
- ✅ 14 profile portraits (1024×1024)
- ✅ 14 scene portraits (1024×1536)
- **Total:** 28 customer images

---

## 🔄 FALLBACK CHAIN

The new `sceneImageOrFallback()` function has a 3-tier fallback:

```
1. Try scenePortrait ("mildred_scene")
   ↓ Not found?
2. Try portrait ("mildred")
   ↓ Not found?
3. Show emoji ("🧑‍🌾")
```

**This means:**
- Missing scene portraits will gracefully show profile closeups
- Missing both will show emoji (easy to spot during testing)
- No crashes from missing assets

---

## 📋 QUICK REFERENCE

### **Files Modified:**
1. ✅ `PotionShopModels.swift` - Added `scenePortrait` field + new function
2. ✅ `PotionShopData.swift` - Updated all 14 characters
3. ✅ `PotionShopCustomerSceneView.swift` - Changed one line (scene portrait loading)

### **Files Unchanged:**
- ❌ PotionShopGameState.swift (no logic changes)
- ❌ PotionShopGameView.swift (no layout changes)
- ❌ PotionShopHeaderView.swift (unrelated)
- ❌ PotionShopCauldronView.swift (unrelated)
- ❌ PotionShopDebugMenu.swift (unrelated)
- ❌ PotionShopBrewAnimator.swift (unrelated)

### **Assets Needed:**
- ⚠️ `mildred_scene.png` (1024×1536) - FIRST PRIORITY
- ⏳ Other 13 scene portraits - AFTER MILDRED TEST PASSES

---

## 🚀 NEXT STEPS

### **Immediate (Before Testing):**
1. ✅ Code changes complete (all done!)
2. ⚠️ **YOU NEED TO:** Add `mildred_scene.png` to Assets.xcassets
3. ⚠️ **YOU NEED TO:** Build and test the game

### **After Mildred Test Passes:**
1. Draw remaining 13 scene portraits
2. Add them to Assets.xcassets
3. Update `PotionShopData.swift` (change temporary names to `_scene` versions)
4. Rebuild and test all characters

### **Later (Deferred):**
- Update `CAULDRON_CONTEXT.md` with new asset counts
- Update `MASTER_CONTEXT.md` with Phase 7h completion
- Consider hand-drawn inspect strip border (separate feature - see `tmpHAND_DRAWN_INSPECT_BORDER_SESSION_MAY5_2026.md`)

---

## 💡 TIPS FOR DRAWING

### **Portrait Style Consistency:**
- Keep same character across both portraits (same outfit, colors, features)
- Profile can be more detailed (closer crop)
- Scene can show more personality (full pose, props)

### **Circle Crop Awareness:**
- Don't put important details in corners
- Test by viewing in a circular frame
- Center the character's face/torso

### **Size Reference:**
- Profile portraits same size as Ednar's face (already drawn?)
- Scene portraits same canvas as Ednar's expressions (1024×1536)
- Can reuse Ednar's Procreate file as template

---

## 📞 SUPPORT

### **If Something Goes Wrong:**

**Report these details:**
1. What step you were on
2. Exact error message (if build failed)
3. Console output (if game crashed)
4. Screenshot (if visual issue)
5. Which character is affected

**Common Questions:**
- "Do I need to draw all 14 now?" → No, just Mildred for testing
- "Can I use the same image temporarily?" → Yes, that's why others use `scenePortrait: "tomik"` etc.
- "What if I want to change the inspect strip?" → See `tmpHAND_DRAWN_INSPECT_BORDER_SESSION_MAY5_2026.md`

---

**END OF IMPLEMENTATION GUIDE**

✅ All code changes are complete and ready for testing!  
⚠️ Waiting on: `mildred_scene.png` asset to be added to Xcode  
🎨 Then: Test with Mildred, then draw remaining 13 portraits
