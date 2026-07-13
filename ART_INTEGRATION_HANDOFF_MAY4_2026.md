# ART INTEGRATION HANDOFF — May 4, 2026
**Ednar's Potion Cauldron — Art Asset Integration Guide**

> **Purpose:** Complete guide for integrating art assets into Ednar's Potion Cauldron  
> **Status:** Game is fully playable with placeholder art. Ready for real art swap.  
> **Next Phase:** Phase 8 — Replace all placeholder art with Procreate PNG exports

---

## 📋 QUICK START FOR NEW CHAT

### **Files to Attach:**
1. ✅ **MASTER_CONTEXT.md** - Project overview
2. ✅ **CAULDRON_CONTEXT.md** - Complete game documentation (updated May 4, 2026)
3. ✅ **This file** (`ART_INTEGRATION_HANDOFF_MAY4_2026.md`)
4. ✅ **LAYOUT_EDITOR_SESSION_MAY4_2026_PART2.md** - Layout details (optional, for reference)

### **What to Say:**
```
Read the attached files IN ORDER. I'm ready to add art assets to Ednar's Potion Cauldron. 
The game is fully playable with placeholder art (emojis, colored shapes). I have Procreate 
PNG files ready to export and integrate. Follow the guide in ART_INTEGRATION_HANDOFF_MAY4_2026.md.

Current status:
- ✅ Game fully playable (Day 1)
- ✅ Layout finalized (May 4, 2026)
- ✅ Drag-and-drop dice placement working
- ✅ All animations polished
- ⏳ Art is placeholder (emojis/colored shapes)

I want to replace placeholder art with real assets. Let's start with [SPECIFY WHICH].
```

---

## 🎨 CURRENT ART STATUS

### **What's Placeholder:**
| Asset Type | Current State | Location in Code |
|------------|---------------|------------------|
| **Customer Portraits** | Emoji fallbacks (👵, 🧔, etc.) | `PotionShopData.swift` - customer definitions |
| **Ednar (player)** | Implied presence (no visual) | `PotionShopCustomerSceneView.swift` |
| **Cauldron Bowl** | Parametric brown gradient bowl | `PotionShopCauldronView.swift` - `PotionShopBowlShape` |
| **Dice Faces** | Colored squares with text (POT/STB/BST/HEAL/SHD) | `PotionShopCauldronView.swift` - `PotionShopDieButtonView` |
| **Shop Background** | Parchment color fill | `PotionShopGameView.swift` - `PotionShopTheme.bg` |
| **BREW Button** | Wooden sign with text | `PotionShopCauldronView.swift` - `PotionShopBrewSignView` |
| **UI Icons** | System SF Symbols | Various files |

### **What Works (No Art Needed Yet):**
- Floating damage/heal numbers (text-based)
- Profile buttons (circular frames with portraits inside)
- Health bars (drawn with shapes)
- Patience rings (drawn with `Circle().trim()`)
- Shield badge (drawn with shapes)
- Composure bar (gradient fill)

---

## 📦 ART ASSET SPECIFICATIONS

### **Complete Asset List (34 PNGs)**

#### **1. Customer Portraits (14 files)**
**Canvas Size:** 1024×1024 px @ 300 DPI  
**Format:** PNG with **transparent background**  
**Naming Convention:** `lowercase_with_underscores.png`

**Files Needed:**
```
mildred.png        - Mildred Honeycomb (elderly baker, tier 1)
tomik.png          - Tomik (gruff lumberjack, tier 1)
greta.png          - Greta (nun with Inspiring trait, tier 1)
pemberton.png      - Pemberton (merchant, tier 2)
sister_halla.png   - Sister Halla (nun with Pious trait, tier 2)
ardo.png           - Ardo (nervous alchemist with Skittish trait, tier 2)
wendelina.png      - Wendelina (farmer, tier 3)
bram.png           - Bram (loud town crier with Loud trait, tier 3)
crispin.png        - Lord Crispin (noble with Intimidating trait, tier 3)
hexa_mott.png      - Hexa Mott (rival witch with Hexer trait, tier 4)
ironhilde.png      - Captain Ironhilde (warrior with Draining trait, tier 4)
grimdrek.png       - Grimdrek (orc boss with Volatile trait, tier 5)
carmilla.png       - Lady Carmilla (vampire with Hexer trait, tier 5)
royal_envoy.png    - The Royal Envoy (final boss with Intimidating, tier 5)
```

**Art Notes:**
- Square composition (centered face/bust)
- Character personality should read clearly
- Will be displayed at ~60–80pt diameter (circular crop)
- Keep important details centered (avoid edge detail loss from crop)

---

#### **2. Ednar Expressions (5 files)**
**Canvas Size:** 1024×1536 px @ 300 DPI (portrait orientation)  
**Format:** PNG with **transparent background**  
**Body:** Same body pose across all 5 - only face changes

**Files Needed:**
```
ednar_calm.png       - Default expression (composure ≥ 70%)
ednar_focused.png    - Concentrating (player has dice placed, hasn't brewed yet)
ednar_concerned.png  - Worried (composure 30-70%, or shield breaks)
ednar_alarmed.png    - Panicked (composure < 30%)
ednar_satisfied.png  - Happy (customer just defeated)
```

**Art Notes:**
- Ednar is a witch (user's design)
- Body: consistent across all files (arms, outfit, stance)
- Face: changes per expression
- Positioned left side of customer scene (standing behind counter)
- Rendered at ~120-160pt wide

**Workflow in Procreate:**
1. Draw base body once
2. Duplicate layer group 5 times
3. Modify face on each duplicate
4. Export each as separate PNG

---

#### **3. Cauldron (1 file)**
**Canvas Size:** 2048×1536 px @ 300 DPI  
**Format:** PNG with **transparent background**  
**Important:** Single-layer image (NOT 3 separate files)

**File Needed:**
```
cauldron.png  - Complete cauldron (bowl + liquid + rim + depth)
```

**Art Notes:**
- **Replaces 3-layer system** (back/liquid/front consolidated into ONE image)
- Draw everything: bowl exterior, liquid surface, rim, depth, shadows
- Dice nodes will render **ON TOP** of this image
- Aspect ratio should roughly match current parametric bowl (wide, shallow)
- Green liquid suggested (potion theme)
- Rendered at variable sizes (scales 50%-200% via layout editor)

**What NOT to include:**
- Don't draw dice on the image (rendered separately)
- Don't draw the BREW button (separate element)

---

#### **4. Dice Faces (5 files)**
**Canvas Size:** 512×512 px @ 300 DPI  
**Format:** PNG with **transparent background**  
**Critical:** Center 30% MUST BE BLANK (number overlaid at runtime)

**Files Needed:**
```
die_potency.png    - Red/fire theme (damage die)
die_stability.png  - Blue/ice theme (secondary damage)
die_boost.png      - Purple/magic theme (multiplier die)
die_heal.png       - Green/nature theme (heal composure)
die_shield.png     - Teal/cyan theme (add shield)
```

**Art Notes:**
- **Flat-faced** (top-down view, not 3D angled)
- Center 30% radius: BLANK (runtime text shows "1", "2", "3", etc.)
- Strong color identity (red/blue/purple/green/teal)
- Optional: small icon in corner (flame/anchor/star/heart/shield)
- Rendered at 44-58pt size (scales via `dieScale` parameter)

**Layout:**
```
┌────────────────────────┐
│ [icon]                 │  ← Top 20%: optional icon
│                        │
│        [BLANK]         │  ← Center 30%: TEXT GOES HERE
│                        │
│                        │  ← Bottom: texture/pattern OK
└────────────────────────┘
```

---

#### **5. Shop Background (1 file)**
**Canvas Size:** 1242×2688 px @ 300 DPI (iPhone 14 Pro Max)  
**Format:** PNG with **transparent background** (or opaque if full-screen)

**File Needed:**
```
shop_background.png  - Interior of Ednar's potion shop
```

**Composition Zones:**
| Y Range (px) | Zone | Purpose | Design Notes |
|--------------|------|---------|--------------|
| 0–270 | Header | Composure bar area | Neutral contrast for UI |
| 270–970 | Customer Scene | Ednar (left 1/3) + customers (right 2/3) | Wooden walls, shelves, door/window light |
| 970–1226 | Profile Row | Customer profile buttons | Solid neutral, no clutter |
| 1226–2226 | Cauldron Area | Ednar's workspace | Empty floor/table, hanging herbs OK in upper edges |
| 2226–2688 | Dice Tray | Table edge / counter | Wooden texture |

**Art Notes:**
- Think: cozy medieval shop interior
- Ednar's workspace visible (left side, behind counter)
- Door/window on right (where customers stand)
- Warm lighting
- Herb bundles, shelves, bottles for atmosphere
- Keep center areas clear (UI overlays here)

---

#### **6. UI Icons (6 files) — OPTIONAL**
**Canvas Size:** 256×256 px @ 300 DPI  
**Format:** PNG with **transparent background**

**Files Needed:**
```
icon_heart.png       - Composure/health indicator
icon_shield.png      - Shield indicator
icon_potion.png      - Brew preview icon
icon_brew_sign.png   - BREW button replacement (ladle dipping in cauldron?)
icon_hamburger.png   - Pause menu icon
icon_gear.png        - Settings/debug menu icon
```

**Art Notes:**
- Simple, readable silhouettes
- Currently using SF Symbols (system icons)
- **Low priority** - can defer to later

---

## 🔧 HOW ASSET LOADING WORKS

### **Current System:**

```swift
// Try to load from Assets.xcassets, fallback to placeholder
if let image = PotionShopImageLoader.loadImage(named: "cauldron") {
    Image(uiImage: image)
        .resizable()
        .scaledToFit()
} else {
    // Placeholder code (parametric bowl, emoji, etc.)
    PotionShopBowlShape()
        .fill(Color.brown)
}
```

### **Where Assets Are Loaded:**

| Asset Type | Loaded In | Fallback |
|------------|-----------|----------|
| Customer portraits | `PotionShopCustomerSceneView` | Emoji from `customer.iconFallback` |
| Ednar expressions | `PotionShopCustomerSceneView` | None (implied presence) |
| Cauldron | `PotionShopCauldronView` | `PotionShopBowlShape()` (parametric) |
| Dice faces | `PotionShopDieButtonView` | Colored squares with text |
| Background | `PotionShopGameView` | `PotionShopTheme.bg` (parchment color) |

---

## 📝 STEP-BY-STEP ART INTEGRATION

### **Step 1: Export from Procreate**
1. Open Procreate file
2. **CRITICAL:** Turn OFF bottom "Background" layer (must be transparent)
3. Tap wrench icon → Share → PNG
4. Save to Files app or AirDrop to Mac

### **Step 2: Add to Xcode Assets**
1. Open Xcode project
2. In left sidebar, find **Assets.xcassets**
3. Right-click Assets.xcassets → **Show in Finder**
4. Drag PNG file into Assets.xcassets (or use Xcode's UI)
5. Make sure **"Render As"** is set to **"Template Image"** (for icons) or **"Original Image"** (for full-color art)

### **Step 3: Verify Naming**
Asset name in Xcode MUST match name in code:
- `cauldron` (not `cauldron.png`)
- `mildred` (not `mildred_portrait`)
- `die_potency` (exact match, lowercase, underscores)

### **Step 4: Test in Simulator**
1. Press **Command + R** (run)
2. Navigate to Ednar's Potion Cauldron
3. Verify asset appears (no fallback)
4. Check for transparency issues (white boxes = background not transparent)

### **Step 5: Adjust If Needed**
If asset looks wrong:
- **Too big/small:** Use layout editor (debug menu → Layout Editor)
- **Wrong position:** Adjust offset sliders in layout editor
- **Wrong color:** Re-export from Procreate (check color profile)
- **Has white background:** Re-export with Background layer OFF

---

## 🎯 SUGGESTED ORDER OF INTEGRATION

### **Phase 8a: Cauldron (Easiest First)**
**Why:** Single file, replaces parametric shape, immediate visual impact
**File:** `cauldron.png`
**Code Change:** Already supports image loading (no code change needed!)
**Test:** Should see custom cauldron instead of brown gradient bowl

---

### **Phase 8b: Dice Faces**
**Why:** 5 files, all same process, improves core gameplay feel
**Files:** `die_potency.png`, `die_stability.png`, `die_boost.png`, `die_heal.png`, `die_shield.png`
**Code Change:** Already supports image loading (no code change needed!)
**Test:** Drag dice to cauldron - should see custom faces with numbers overlaid

**Critical Check:** Numbers must be readable on center of die face!

---

### **Phase 8c: Shop Background**
**Why:** Sets the scene atmosphere
**File:** `shop_background.png`
**Code Change:** Already supports image loading (no code change needed!)
**Test:** Background should fill entire screen behind all UI

---

### **Phase 8d: Customer Portraits (14 files)**
**Why:** Lots of files, but same process repeated
**Files:** All 14 customer portraits
**Code Change:** Already supports image loading (no code change needed!)
**Test:** Play through Day 1 Morning → Afternoon → Evening → Night, verify all customers show their portraits

---

### **Phase 8e: Ednar Expressions**
**Why:** Adds player character personality
**Files:** All 5 Ednar expressions
**Code Change:** **NEEDS IMPLEMENTATION** (currently no Ednar visual at all)
**Test:** Ednar should appear left side of scene, expression changes based on composure

**Implementation Required:**
```swift
// Add to PotionShopCustomerSceneView.swift
// Left side of scene, add Ednar character view
// Expression logic:
// - ednar_calm: composure >= 70%
// - ednar_focused: has dice placed, not yet brewed
// - ednar_concerned: composure 30-70%
// - ednar_alarmed: composure < 30%
// - ednar_satisfied: customer just defeated
```

---

### **Phase 8f: UI Icons (Optional)**
**Why:** Polish, low priority
**Files:** 6 icon files
**Code Change:** Replace SF Symbol references with custom images
**Test:** Icons should appear in header, debug menu, etc.

---

## 🐛 COMMON ISSUES & SOLUTIONS

### **Issue: White box instead of transparent background**
**Cause:** Background layer wasn't turned OFF in Procreate
**Solution:**
1. Re-open Procreate file
2. Tap Layers
3. Find bottom "Background" layer
4. Tap checkbox to turn it OFF
5. Re-export as PNG

---

### **Issue: Asset doesn't appear (shows fallback)**
**Cause:** Asset name mismatch
**Solution:**
1. Check code for exact asset name: `PotionShopImageLoader.loadImage(named: "X")`
2. Check Assets.xcassets for exact match
3. Names are case-sensitive: `Cauldron` ≠ `cauldron`

---

### **Issue: Dice numbers not visible on die face**
**Cause:** Die face art has busy pattern in center
**Solution:**
- Re-design die face with blank center circle (30% radius)
- Or: adjust text shadow in code for better contrast

---

### **Issue: Cauldron looks wrong / too small**
**Cause:** Layout values need adjustment
**Solution:**
1. Tap gear icon (debug menu)
2. Tap "Layout Editor"
3. Adjust cauldron scale slider (currently 1.29 = 29% bigger)
4. Generate code and apply

---

### **Issue: Customer portrait is cropped weird**
**Cause:** Important details too close to edge (circular crop cuts them)
**Solution:**
- Re-compose portrait with face/bust centered
- Keep important details within center 70% of canvas

---

### **Issue: Background doesn't fill screen**
**Cause:** Wrong aspect ratio or scaling mode
**Solution:**
- Check `.resizable().scaledToFill()` in code
- Verify image is 1242×2688 (iPhone 14 Pro Max aspect)

---

## 📊 ASSET LOADING CODE REFERENCE

### **Current Image Loader:**
```swift
// Assumed to be in PotionShopImageLoader (or similar)
static func loadImage(named name: String) -> UIImage? {
    return UIImage(named: name)
}
```

### **Customer Portrait Loading:**
```swift
// In PotionShopCustomerSceneView or CustomerView
if let portrait = PotionShopImageLoader.loadImage(named: customer.id) {
    Image(uiImage: portrait)
        .resizable()
        .scaledToFill()
        .frame(width: 80, height: 80)
        .clipShape(Circle())
} else {
    // Fallback: emoji
    Text(customer.iconFallback)
        .font(.system(size: 50))
}
```

### **Cauldron Loading:**
```swift
// In PotionShopCauldronView.swift (already implemented!)
if let cauldronImage = PotionShopImageLoader.loadImage(named: "cauldron") {
    Image(uiImage: cauldronImage)
        .resizable()
        .scaledToFit()
        .frame(width: g.bowlW, height: g.bowlH)
        .position(x: g.bowlCenterX, y: g.bowlOriginY + g.bowlH / 2)
} else {
    // Fallback: parametric bowl
    PotionShopBowlShape()
        .fill(LinearGradient(...))
}
```

### **Dice Face Loading:**
```swift
// In PotionShopDieButtonView (already implemented!)
if let dieImage = PotionShopImageLoader.loadImage(named: die.type.assetName) {
    ZStack {
        Image(uiImage: dieImage)
            .resizable()
            .scaledToFit()
            .frame(width: scaledSize, height: scaledSize)
        
        // Number overlaid on center
        Text("\(die.value)")
            .font(.system(size: scaledFontSize, weight: .heavy))
            .foregroundColor(.white)
    }
} else {
    // Fallback: colored square with text
    VStack {
        Text(die.type.abbr)  // "POT", "STB", etc.
        Text("\(die.value)")
    }
    .background(die.type.color)
}
```

### **Where `assetName` Comes From:**
```swift
// In PotionShopModels.swift (or wherever PotionShopDieType is defined)
enum PotionShopDieType: String, Codable {
    case potency, stability, boost, heal, shield
    
    var assetName: String {
        switch self {
        case .potency: return "die_potency"
        case .stability: return "die_stability"
        case .boost: return "die_boost"
        case .heal: return "die_heal"
        case .shield: return "die_shield"
        }
    }
}
```

---

## ✅ VERIFICATION CHECKLIST

After adding each asset:

- [ ] Asset appears in game (no fallback)
- [ ] Transparency works (no white box)
- [ ] Size looks correct (not stretched/squashed)
- [ ] Position looks correct (not cut off)
- [ ] Colors look correct (not washed out)
- [ ] Works on all screen sizes (test on different simulators)

---

## 📚 RELATED FILES

**Core Documentation:**
- `MASTER_CONTEXT.md` - Project overview
- `CAULDRON_CONTEXT.md` - Game documentation (§16 has full art spec)
- `LAYOUT_EDITOR_SESSION_MAY4_2026_PART2.md` - Layout details

**Code Files (Art Loading):**
- `PotionShopGameView.swift` - Background image loading
- `PotionShopCauldronView.swift` - Cauldron + dice image loading
- `PotionShopCustomerSceneView.swift` - Customer portrait loading (add Ednar here)
- `PotionShopModels.swift` - Data types (check `assetName` properties)

**Asset Specifications (in CAULDRON_CONTEXT.md §16):**
- Full list of 34 assets with Procreate canvas sizes
- Detailed art notes for each category
- Filename list (exact names required)

---

## 🎯 SUCCESS CRITERIA

### **Phase 8 Complete When:**
1. ✅ Cauldron shows custom PNG instead of brown gradient
2. ✅ All 5 dice types show custom faces with readable numbers
3. ✅ Background shows shop interior scene
4. ✅ All 14 customers show their portraits (no emojis)
5. ✅ Ednar appears on left with expression changes (if implemented)
6. ✅ No white boxes (all transparency working)
7. ✅ Everything looks correct on iPhone 14 Pro Max simulator

---

## 💡 TIPS FOR SUCCESS

1. **Start small:** Do cauldron first (1 file, immediate feedback)
2. **Test each asset:** Don't add all 34 at once
3. **Keep Procreate files organized:** Label layers clearly
4. **Export checklist:** Always turn off Background layer!
5. **Name precisely:** `die_potency.png`, not `die potency.png` or `diePotency.png`
6. **Use layout editor:** For any positioning issues
7. **Ask for help:** If asset doesn't appear after 3 attempts, stop and ask AI for help

---

**END OF HANDOFF DOCUMENT**

**Next Steps:** Export your first asset from Procreate and add to Assets.xcassets. Start with `cauldron.png` for quick win!

**Good luck!** 🎨✨
