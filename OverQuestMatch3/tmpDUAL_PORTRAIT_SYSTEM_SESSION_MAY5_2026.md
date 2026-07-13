# DUAL PORTRAIT SYSTEM FOR CUSTOMERS
**Session Date:** May 5, 2026  
**Status:** PLANNED - Ready for Implementation  
**Context:** Ednar's Potion Cauldron - Customer artwork separation

---

## 📋 SESSION SUMMARY

**User Request:**
Split customer artwork into two separate image sets:
- **Scene Portraits** - Full body/bust images for customer scene (big visual area)
- **Profile Portraits** - Head/face closeups for profile row (buttons)

**Current State:**
- One image per customer (`portrait` field)
- Same image used in both customer scene and profile row
- 14 customers total

**Goal State:**
- Two images per customer (`portrait` + `scenePortrait` fields)
- Scene shows full body art
- Profile row shows head closeups
- **ZERO behavior changes** - only visual swap in customer scene

---

## 🎯 LAYOUT TERMINOLOGY (Established This Session)

### **Complete Layout Hierarchy (Top to Bottom):**

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. HEADER (1% of screen)                                        │
│    ├─ Composure bar                                            │
│    ├─ Shield badge (if player has shield)                      │
│    ├─ Day/Round indicator                                      │
│    └─ Gear icon (⚙️ debug menu)                                │
├─────────────────────────────────────────────────────────────────┤
│ 2. CUSTOMER SCENE (26.3% of screen) ← WHERE EDNAR LIVES!       │
│    ├─ Background Layer                                         │
│    │  ├─ Gradient (tan/cream - always present)                 │
│    │  └─ customerbg.png (if found - overlay on gradient)       │
│    ├─ Floor Line (brown rectangle, 12pt tall)                  │
│    ├─ Ednar (left side, 13% from left edge)                    │
│    │  ├─ Expression image (ednar_calm/focused/concerned/alarmed)│
│    │  └─ Shadow blob (capsule below feet)                      │
│    ├─ Customer Line (right side)                               │
│    │  ├─ Circular portraits (76pt diameter)                    │
│    │  ├─ HP Badge (top-left, only on active customer)          │
│    │  ├─ Attack Badge (bottom-right, all customers)            │
│    │  └─ Expiration Emoji (💢 if enabled)                      │
│    └─ Shield Badge (teal capsule near Ednar, if shield > 0)    │
├─────────────────────────────────────────────────────────────────┤
│ 3. PROFILE ROW (9.5% of screen)                                │
│    ├─ Profile Buttons (circular, 56pt diameter)                │
│    │  ├─ Patience Ring (outer circle, color-coded)             │
│    │  ├─ Portrait Image (head closeup)                         │
│    │  └─ Status Overlay (✓ defeated, ✗ expired)                │
│    ├─ Inspect Strip (when profile tapped)                      │
│    │  ├─ Portrait with patience ring (70pt)                    │
│    │  ├─ Customer info (name, order, attack)                   │
│    │  └─ Brew Target Pill (🧪 N)                               │
│    └─ Hint Banner (when die selected)                          │
│       └─ "🎯 Tap a node in the cauldron to place this die"     │
├─────────────────────────────────────────────────────────────────┤
│ 4. CAULDRON AREA (37.2% of screen) ← BIGGEST SECTION!          │
│    ├─ Cauldron Bowl (ellipse shape, 1.65:1 aspect ratio)       │
│    ├─ Liquid Surface (green ellipse)                           │
│    ├─ 12 Nodes (placement spots for dice)                      │
│    └─ BREW Tap Zone (invisible, 83% from left)                 │
├─────────────────────────────────────────────────────────────────┤
│ 5. BREW PREVIEW BAR (3.2% of screen)                           │
│    └─ Shows: 🧪 damage • 💚 heal • 🛡️ shield                   │
├─────────────────────────────────────────────────────────────────┤
│ 6. DICE TRAY (19.3% of screen) ← SECOND BIGGEST!               │
│    └─ 5 dice slots (POT/STB/BST/HEAL/SHD)                      │
└─────────────────────────────────────────────────────────────────┘
```

### **Quick Reference Terms:**

| User Says | Refers To |
|-----------|-----------|
| "customer scene" | Section 2 - Ednar + customer line + background |
| "profile row" | Section 3 - Circular portrait buttons |
| "inspect strip" | Expanded card showing customer details |
| "hint banner" | Yellow "🎯 Tap a node..." text |
| "cauldron" | Section 4 - Bowl with 12 nodes |
| "dice tray" | Section 6 - Bottom section with 5 dice |
| "preview bar" | Section 5 - Thin strip showing brew results |
| "floor line" | Brown rectangle at bottom of customer scene |
| "HP badge" | Red circle top-left of active customer |
| "attack badge" | Red circle bottom-right of customers |
| "patience ring" | Colored circle around profile portraits |
| "shield badge" | Teal capsule near Ednar showing shield amount |

---

## 🎨 THE DUAL PORTRAIT PLAN

### **Current System:**
```swift
// In PotionShopCharacter struct
let portrait: String  // Used EVERYWHERE (scene + profile + inspect)

// In customer scene
assetName: char.portrait  // "mildred.png"

// In profile row
assetName: char.portrait  // Same "mildred.png"
```

### **New System:**
```swift
// In PotionShopCharacter struct
let portrait: String        // Profile row (head closeup)
let scenePortrait: String   // Customer scene (full body/bust)

// In customer scene
assetName: char.scenePortrait  // "mildred_scene.png" ← CHANGE

// In profile row
assetName: char.portrait       // "mildred.png" ← NO CHANGE
```

---

## 📐 IMAGE SPECIFICATIONS

### **Profile Portraits (Head Closeups):**
- **Filename Pattern:** `[customerid].png`
  - Examples: `mildred.png`, `tomik.png`, `greta.png`
- **Size:** 1024×1024 px @ 300 DPI
- **Aspect Ratio:** 1:1 (square)
- **Crop:** Tight on face/head
- **Background:** Transparent
- **Usage:** Profile row buttons, possibly inspect strip
- **Count:** 14 images (one per customer)

### **Scene Portraits (Full Body/Bust):**
- **Filename Pattern:** `[customerid]_scene.png`
  - Examples: `mildred_scene.png`, `tomik_scene.png`, `greta_scene.png`
- **Size:** 1024×1536 px @ 300 DPI (same as Ednar expressions)
- **Aspect Ratio:** 2:3 (portrait orientation)
- **Crop:** Waist-up or full body
- **Background:** Transparent
- **Usage:** Customer scene (the main visual area)
- **Count:** 14 NEW images (one per customer)

### **Total Asset Count:**
- **Existing:** 14 profile portraits
- **New:** 14 scene portraits
- **Total:** 28 customer images

### **Complete Filename List (NEW IMAGES):**
```
mildred_scene.png
tomik_scene.png
greta_scene.png
pemberton_scene.png
sister_halla_scene.png
ardo_scene.png
wendelina_scene.png
bram_scene.png
crispin_scene.png
hexa_mott_scene.png
ironhilde_scene.png
grimdrek_scene.png
carmilla_scene.png
royal_envoy_scene.png
```

---

## 🔧 TECHNICAL IMPLEMENTATION

### **Files to Modify:**

1. **PotionShopModels.swift** - Add `scenePortrait` field to struct
2. **PotionShopData.swift** - Add `scenePortrait:` value to all 14 characters
3. **PotionShopCustomerSceneView.swift** - Change `char.portrait` to `char.scenePortrait`

### **Files That DON'T Change:**
- ❌ PotionShopGameState.swift (no logic changes)
- ❌ PotionShopGameView.swift (no layout changes)
- ❌ PotionShopHeaderView.swift (unrelated)
- ❌ PotionShopCauldronView.swift (unrelated)
- ❌ PotionShopDebugMenu.swift (unrelated)
- ❌ PotionShopBrewAnimator.swift (unrelated)

### **Step-by-Step Modification Guide:**

#### **STEP 1: Update PotionShopModels.swift**

**Location:** Find `struct PotionShopCharacter` (around line 60)

**Change:**
```swift
// BEFORE (current)
struct PotionShopCharacter {
    let id: String
    let name: String
    let title: String
    let iconFallback: String
    let portrait: String  // ← Only one portrait field
    let difficulty: Int
    // ... rest of fields ...
}

// AFTER (add new field)
struct PotionShopCharacter {
    let id: String
    let name: String
    let title: String
    let iconFallback: String
    let portrait: String        // Profile row (head closeup)
    let scenePortrait: String   // Customer scene (full body) ← ADD THIS LINE
    let difficulty: Int
    // ... rest of fields ...
}
```

---

#### **STEP 2: Update PotionShopData.swift**

**Location:** Find `let allCharacters: [PotionShopCharacter] = [...]` (around line 50)

**Change:** Add `scenePortrait:` to ALL 14 character definitions

**Example (Mildred):**
```swift
// BEFORE (current)
PotionShopCharacter(
    id: "mildred",
    name: "Mildred Honeycomb",
    title: "Baker",
    iconFallback: "👵",
    portrait: "mildred",  // ← Only one portrait
    difficulty: 1,
    // ... rest of fields ...
)

// AFTER (add scene portrait)
PotionShopCharacter(
    id: "mildred",
    name: "Mildred Honeycomb",
    title: "Baker",
    iconFallback: "👵",
    portrait: "mildred",            // Profile row (head)
    scenePortrait: "mildred_scene", // Customer scene (full body) ← ADD THIS LINE
    difficulty: 1,
    // ... rest of fields ...
)
```

**Repeat for all 14 customers:**
- mildred → `portrait: "mildred"`, `scenePortrait: "mildred_scene"`
- tomik → `portrait: "tomik"`, `scenePortrait: "tomik_scene"`
- greta → `portrait: "greta"`, `scenePortrait: "greta_scene"`
- pemberton → `portrait: "pemberton"`, `scenePortrait: "pemberton_scene"`
- sister_halla → `portrait: "sister_halla"`, `scenePortrait: "sister_halla_scene"`
- ardo → `portrait: "ardo"`, `scenePortrait: "ardo_scene"`
- wendelina → `portrait: "wendelina"`, `scenePortrait: "wendelina_scene"`
- bram → `portrait: "bram"`, `scenePortrait: "bram_scene"`
- crispin → `portrait: "crispin"`, `scenePortrait: "crispin_scene"`
- hexa_mott → `portrait: "hexa_mott"`, `scenePortrait: "hexa_mott_scene"`
- ironhilde → `portrait: "ironhilde"`, `scenePortrait: "ironhilde_scene"`
- grimdrek → `portrait: "grimdrek"`, `scenePortrait: "grimdrek_scene"`
- carmilla → `portrait: "carmilla"`, `scenePortrait: "carmilla_scene"`
- royal_envoy → `portrait: "royal_envoy"`, `scenePortrait: "royal_envoy_scene"`

---

#### **STEP 3: Update PotionShopCustomerSceneView.swift**

**Location:** Find `struct PotionShopCustomerInSceneView` body (around line 458)

**Change:** ONE line only

**BEFORE (current):**
```swift
struct PotionShopCustomerInSceneView: View {
    // ... state variables ...
    
    var body: some View {
        if let char = char {
            ZStack {
                Circle()
                    .fill(Color(red: 0.96, green: 0.92, blue: 0.84))
                    .overlay(
                        PotionShopImageLoader.imageOrEmoji(
                            assetName: char.portrait,  // ← CHANGE THIS LINE
                            fallbackEmoji: char.iconFallback,
                            size: PotionShopSceneLayout.portraitDiameter * scale
                        )
                    )
                // ... rest of body ...
```

**AFTER (change to scenePortrait):**
```swift
struct PotionShopCustomerInSceneView: View {
    // ... state variables ...
    
    var body: some View {
        if let char = char {
            ZStack {
                Circle()
                    .fill(Color(red: 0.96, green: 0.92, blue: 0.84))
                    .overlay(
                        PotionShopImageLoader.imageOrEmoji(
                            assetName: char.scenePortrait,  // ← CHANGED FROM char.portrait
                            fallbackEmoji: char.iconFallback,
                            size: PotionShopSceneLayout.portraitDiameter * scale
                        )
                    )
                // ... rest of body ...
```

**That's the ONLY code change in this file!**

---

#### **STEP 4 (OPTIONAL): Update Inspect Strip**

**Location:** Find `struct PotionShopInspectStripView` → `portraitView` (around line 770)

**Current State:**
```swift
@ViewBuilder
private func portraitView(char: PotionShopCharacter) -> some View {
    ZStack {
        // ... patience ring ...
        PotionShopImageLoader.imageOrEmoji(
            assetName: char.portrait,  // ← Currently uses profile closeup
            fallbackEmoji: char.iconFallback,
            size: 70
        )
    }
}
```

**Option A (Keep Head Closeup):**
```swift
assetName: char.portrait  // Matches profile row
```

**Option B (Use Full Body):**
```swift
assetName: char.scenePortrait  // Matches customer scene
```

**Decision Point:** Ask user which they prefer!

---

## ✅ WHAT STAYS EXACTLY THE SAME

### **Game Logic (100% Unchanged):**
- ✅ HP values and calculations
- ✅ Attack values and calculations
- ✅ Patience mechanics
- ✅ Patience ticking behavior
- ✅ Combat math (brew damage, customer attacks, shield absorption)
- ✅ Queue swapping logic
- ✅ Customer status tracking (waiting/defeated/expired)
- ✅ All trait effects (intimidating, volatile, skittish, etc.)

### **Visual Effects (100% Unchanged):**
- ✅ Shake animation when hit
- ✅ Slide-out animation when expired
- ✅ Settle bounce when becoming active
- ✅ Queue swap animation (matchedGeometryEffect)
- ✅ Dimming (waiting customers at 55% opacity)
- ✅ Scaling (active 1.0×, second 0.78×, third 0.72×)
- ✅ 💢 emoji burst on expiration
- ✅ All animation timing from PotionShopBrewAnimator

### **Badge Positions (100% Unchanged):**
- ✅ HP Badge (top-left, -28 offset scaled)
- ✅ Attack Badge (bottom-right, +28 offset scaled)
- ✅ Badge sizes (HP: 26pt, Attack: 22pt)
- ✅ Badge colors (red circles, white text)
- ✅ Badge visibility (HP only on active, Attack on all)

### **Layout Values (100% Unchanged):**
- ✅ Portrait diameter: 76pt (in scene)
- ✅ Profile diameter: 56pt (in profile row)
- ✅ Customer X positions (48%, 68%, 88% for 3 customers)
- ✅ Customer Y positions (48%, 55%, 55%)
- ✅ Ednar position (13% from left, 55% from top)
- ✅ All spacing, padding, borders

### **Profile Row (100% Unchanged):**
- ✅ Still uses `char.portrait` (head closeups)
- ✅ Patience rings (green/amber/gray)
- ✅ Tap behavior (queue swap)
- ✅ Active highlighting (1.05× scale, full opacity)
- ✅ Defeated/expired overlays (✓/✗)
- ✅ Button size (56pt diameter)

---

## 🎨 VISUAL COMPARISON

### **BEFORE (Current State):**
```
CUSTOMER SCENE:
  ┌─────┐
  │ 👵  │  ← mildred.png (head closeup)
  └─────┘

PROFILE ROW:
  ┌───┐
  │👵 │  ← mildred.png (same head closeup)
  └───┘
```

### **AFTER (New State):**
```
CUSTOMER SCENE:
  ┌─────┐
  │ 🧓  │  ← mildred_scene.png (full body/bust)
  │ 👗  │
  └─────┘

PROFILE ROW:
  ┌───┐
  │👵 │  ← mildred.png (still head closeup)
  └───┘
```

---

## 🧪 TESTING STRATEGY

### **Phase 1: Test with ONE Customer (Mildred)**

**Setup:**
1. Add `scenePortrait` field to `PotionShopCharacter` struct
2. Update ONLY Mildred's definition:
   ```swift
   portrait: "mildred",
   scenePortrait: "mildred_scene",
   ```
3. For ALL other 13 customers, use same image:
   ```swift
   portrait: "tomik",
   scenePortrait: "tomik",  // Same as portrait (temporary)
   ```
4. Add ONLY `mildred_scene.png` to Assets.xcassets
5. Change customer scene to use `char.scenePortrait`

**Test:**
- Run game
- Morning round (Mildred + Tomik)
- **Expected:** Mildred shows full body in scene, head in profile
- **Expected:** Tomik shows same image in both (temporary)
- **Verify:** HP/attack badges still appear
- **Verify:** Animations still work (shake, swap, expire)

### **Phase 2: Add Remaining 13 Scene Portraits**

**Once Mildred test passes:**
1. Draw the other 13 scene portraits
2. Add them to Assets.xcassets
3. Update the other 13 character definitions:
   ```swift
   scenePortrait: "tomik_scene",
   scenePortrait: "greta_scene",
   // etc.
   ```

**Final Test:**
- Play full Day 1 (all 4 rounds)
- **Verify:** All customers show full body in scene
- **Verify:** All customers show head in profile
- **Verify:** No animation glitches
- **Verify:** No combat bugs

---

## 📋 ASSET CATALOG CHECKLIST

### **Existing Assets (Keep):**
```
✓ mildred.png (1024×1024, head)
✓ tomik.png (1024×1024, head)
✓ greta.png (1024×1024, head)
✓ pemberton.png (1024×1024, head)
✓ sister_halla.png (1024×1024, head)
✓ ardo.png (1024×1024, head)
✓ wendelina.png (1024×1024, head)
✓ bram.png (1024×1024, head)
✓ crispin.png (1024×1024, head)
✓ hexa_mott.png (1024×1024, head)
✓ ironhilde.png (1024×1024, head)
✓ grimdrek.png (1024×1024, head)
✓ carmilla.png (1024×1024, head)
✓ royal_envoy.png (1024×1024, head)
```

### **New Assets (Add):**
```
☐ mildred_scene.png (1024×1536, full body)
☐ tomik_scene.png (1024×1536, full body)
☐ greta_scene.png (1024×1536, full body)
☐ pemberton_scene.png (1024×1536, full body)
☐ sister_halla_scene.png (1024×1536, full body)
☐ ardo_scene.png (1024×1536, full body)
☐ wendelina_scene.png (1024×1536, full body)
☐ bram_scene.png (1024×1536, full body)
☐ crispin_scene.png (1024×1536, full body)
☐ hexa_mott_scene.png (1024×1536, full body)
☐ ironhilde_scene.png (1024×1536, full body)
☐ grimdrek_scene.png (1024×1536, full body)
☐ carmilla_scene.png (1024×1536, full body)
☐ royal_envoy_scene.png (1024×1536, full body)
```

---

## 🚨 COMMON PITFALLS & SOLUTIONS

### **Problem 1: Build Errors After Adding Field**

**Error Message:**
```
Missing argument for parameter 'scenePortrait' in call
```

**Cause:** Forgot to add `scenePortrait:` to one of the 14 character definitions

**Solution:** Check ALL 14 characters in `PotionShopData.swift`

---

### **Problem 2: Scene Shows Wrong Image**

**Symptom:** Customer scene still shows head closeup instead of full body

**Cause:** Forgot to change `char.portrait` to `char.scenePortrait` in customer scene view

**Solution:** Check line ~458 in `PotionShopCustomerSceneView.swift`

---

### **Problem 3: Image Not Found**

**Error in Console:**
```
❌ mildred_scene NOT FOUND - Using emoji fallback
```

**Causes:**
1. Image not added to Assets.xcassets
2. Image added but wrong filename (case-sensitive!)
3. Image added but wrong Target Membership

**Solution:**
1. Open Assets.xcassets in Xcode
2. Check if `mildred_scene` exists
3. If missing, drag PNG into Assets
4. Right-click image → Show in Finder → verify filename
5. Select image → File Inspector → check Target Membership (OverQuestMatch3 checked)

---

### **Problem 4: Circular Crop Looks Weird**

**Symptom:** Full body image doesn't look good in circular frame

**Cause:** Scene portraits are taller (2:3 aspect ratio) but cropped to circle (1:1)

**Options:**
1. **Accept circle crop** - SwiftUI will center the image
2. **Draw art with circle in mind** - Keep important parts in center
3. **Change scene to rectangle** - Would require more code changes (NOT recommended)

**Recommendation:** Draw full body art knowing it will be circle-cropped. Test with placeholder first!

---

## 📖 CONTEXT FILE UPDATES NEEDED

After implementing this feature, update these documentation files:

### **CAULDRON_CONTEXT.md:**

**Section 16.1 (Asset List):**
```markdown
| Category               | Count | Procreate canvas | Notes                                                    |
|------------------------|-------|------------------|----------------------------------------------------------|
| Character portraits    | 14    | 1024×1024 px @ 300 DPI | Profile row - head closeups. Transparent BG. |
| Character scene art    | 14    | 1024×1536 px @ 300 DPI | Customer scene - full body/bust. Transparent BG. ← ADD THIS |
| Ednar expressions      | 5     | 1024×1536 px @ 300 DPI | calm / focused / concerned / alarmed / satisfied |
```

**Section 16.3 (Filename List):**
```markdown
mildred.png, tomik.png, greta.png, ... (14 profile portraits)
mildred_scene.png, tomik_scene.png, greta_scene.png, ... (14 scene portraits) ← ADD THIS
ednar_calm.png, ednar_focused.png, ...
```

**Total v1 Assets:** Change from 34 to 48 (added 14 scene portraits)

---

### **Phase History (Section 13):**

Add new phase entry:
```markdown
| Phase | Title                                | Status | Notes                                                  |
|-------|--------------------------------------|--------|--------------------------------------------------------|
| **7h** | **Dual portrait system (May 5)**     | ✅     | **Separate images for customer scene vs profile row. Scene uses full body/bust (`scenePortrait`), profile uses head closeup (`portrait`). 14 new assets added.** |
```

---

## 🎯 DECISION POINTS FOR USER

Before implementing, confirm these choices:

### **1. Inspect Strip Portrait**

**Question:** Should the inspect strip use head closeup or full body?

**Option A:** `char.portrait` (matches profile row - head closeup)  
**Option B:** `char.scenePortrait` (matches customer scene - full body)

**Current Recommendation:** Use `scenePortrait` for visual consistency with scene

---

### **2. Testing Strategy**

**Question:** Test with one customer first (Mildred) or all 14 at once?

**Option A:** One-by-one (safer, can verify before drawing all 14)  
**Option B:** All at once (faster if confident in implementation)

**Current Recommendation:** Test with Mildred first, then add remaining 13

---

### **3. Fallback Strategy**

**Question:** What if scene portrait is missing?

**Current Behavior:** Falls back to emoji (`char.iconFallback`)

**Alternative:** Fall back to `char.portrait` (head closeup) instead of emoji?

**Code Change (if desired):**
```swift
// In PotionShopImageLoader.swift (create new helper function)
static func sceneImageOrProfileFallback(
    sceneAsset: String,
    profileAsset: String,
    fallbackEmoji: String,
    size: CGFloat
) -> some View {
    if let sceneImage = loadImage(named: sceneAsset) {
        // Use scene portrait (preferred)
        return Image(uiImage: sceneImage).resizable()...
    } else if let profileImage = loadImage(named: profileAsset) {
        // Fall back to profile portrait
        return Image(uiImage: profileImage).resizable()...
    } else {
        // Last resort: emoji
        return Text(fallbackEmoji)...
    }
}
```

**Current Recommendation:** Keep current emoji fallback (simpler)

---

## 🚀 READY FOR NEXT SESSION

### **Paste This Prompt:**

```
Read DUAL_PORTRAIT_SYSTEM_SESSION_MAY5_2026.md FIRST, then CAULDRON_CONTEXT.md.

I want to implement the dual portrait system for customers in Ednar's Potion Cauldron:
- Scene portraits (full body/bust) for customer scene
- Profile portraits (head closeups) for profile row
- Zero behavior changes - only visual swap

Decision points:
1. Inspect strip should use: [scenePortrait / portrait - USER CHOOSE]
2. Test strategy: [One customer first / All 14 at once - USER CHOOSE]
3. Fallback: [Keep emoji fallback / Use profile as fallback - USER CHOOSE]

Please provide:
1. Complete code for PotionShopModels.swift (add scenePortrait field)
2. Complete code for PotionShopData.swift (all 14 characters with scenePortrait)
3. Complete code for PotionShopCustomerSceneView.swift (use char.scenePortrait)
4. Step-by-step Xcode instructions for testing

Critical requirements from CAULDRON_CONTEXT.md still apply:
- I don't know how to code
- Provide ONLY complete, copy-pasteable code
- Include beginner-friendly Xcode instructions
- Never break existing functionality
```

### **Files to Attach in Next Session:**
1. ✅ DUAL_PORTRAIT_SYSTEM_SESSION_MAY5_2026.md (this file)
2. ✅ CAULDRON_CONTEXT.md
3. ✅ PotionShopModels.swift
4. ✅ PotionShopData.swift
5. ✅ PotionShopCustomerSceneView.swift
6. ⚠️ PotionShopImageLoader.swift (if fallback strategy changes)

---

**END OF SESSION DOCUMENTATION**

This file contains everything discussed in the May 5, 2026 chat session about implementing separate portrait images for customer scene vs profile row.

