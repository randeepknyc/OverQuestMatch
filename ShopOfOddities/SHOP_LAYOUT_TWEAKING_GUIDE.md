# SHOP OF ODDITIES LAYOUT TWEAKING GUIDE
**Created:** April 6, 2026  
**Purpose:** Reference guide for adjusting Shop of Oddities UI layout spacing and sizing  
**Status:** ⚙️ IN PROGRESS - Layout redesign in progress

---

## 🎯 OVERVIEW

This guide helps you adjust the Shop of Oddities game layout by modifying percentage-based values. All sizing is responsive and works across different iOS device screen sizes.

---

## 📐 CURRENT LAYOUT STRUCTURE

The game uses a **vertical stack (VStack)** with 5 main sections. All heights are **percentage-based** relative to screen height using `geometry.size.height`.

### **Layout Hierarchy:**

```
┌─────────────────────────────────────┐
│  Score Bar         (5.0%)           │
│  Gap               (8pt fixed)      │
│  Scene View        (38.0%)          │
│  Gap               (8pt fixed)      │
│  Commentary Area   (5.0%)           │
│  🆕 GAP            (5.5%)           │ ← NEW: Background shows through
│  Repair Area       (17.7%)          │ ← GREW from 16%
│  🆕 GAP            (6.0%)           │ ← NEW: Background shows through
│  Decks Area        (30.0%)          │
│  Gap               (8pt fixed)      │
└─────────────────────────────────────┘
```

---

## 🔧 ADJUSTABLE LAYOUT VARIABLES

### **FILE: ShopOfOdditiesView.swift**

All layout values are in the **`body` computed property** inside the `VStack`:

| Section | Variable Line | Current Value | What It Controls | Notes |
|---------|---------------|---------------|------------------|-------|
| **Score Bar** | `.frame(height: geometry.size.height * 0.05)` | **5.0%** | Top HUD overlay with score, customer count, debug button | Semi-transparent black box |
| **Gap 1** | `.frame(height: 8)` | **8pt** | Space after score bar | Fixed pixel value |
| **Scene View** | `.frame(height: geometry.size.height * 0.38)` | **38.0%** | 3-layer character scene composite | Edge-to-edge with overlay |
| **Gap 2** | `.frame(height: 8)` | **8pt** | Space after scene | Fixed pixel value |
| **Commentary** | `.frame(height: geometry.size.height * 0.05)` | **5.0%** | Character dialogue box | Shows/hides dynamically |
| **🆕 Gap 3** | `.frame(height: geometry.size.height * 0.055)` | **5.5%** | Space after commentary | ✨ NEW - Background visible |
| **Repair Area** | `.frame(height: geometry.size.height * 0.177)` | **17.7%** | 4 card slots for repair | ✨ GREW from 16% |
| **🆕 Gap 4** | `.frame(height: geometry.size.height * 0.06)` | **6.0%** | Space after repair area | ✨ NEW - Background visible |
| **Decks Area** | `.frame(height: geometry.size.height * 0.30)` | **30.0%** | 4 component decks | Straight row (no rotation) |
| **Gap 5** | `.frame(height: 8)` | **8pt** | Bottom breathing room | Fixed pixel value |

---

## 📊 SECTION BREAKDOWN

### **1. SCORE BAR (5%)**
**Location:** Top of screen  
**Purpose:** HUD overlay showing game state

**Contains:**
- Star icon + score (left)
- Customer count "X/13" (center)
- Wrench debug button (right)

**Adjustable Properties:**
```swift
.frame(height: geometry.size.height * 0.05)  // ← Change this percentage
```

**Visual Notes:**
- Semi-transparent black background (0.35 opacity)
- 16pt horizontal padding, 6pt vertical padding
- Rounded corners (10pt radius)

---

### **2. SCENE VIEW (38%)**
**Location:** Below score bar  
**Purpose:** 3-layer composite showing customer + shop environment

**Contains:**
- Background layer (shop interior)
- Customer scene layer (character with item)
- Foreground layer (Ednar + Sword)
- Semi-transparent info overlay at bottom

**Adjustable Properties:**
```swift
.frame(height: geometry.size.height * 0.38)  // ← Change this percentage
```

**Visual Notes:**
- Edge-to-edge (uses `.frame(maxWidth: .infinity)`)
- Customer info overlay uses dual geometry reading for edge-to-edge background
- Slide-in animation when customer changes

---

### **3. COMMENTARY AREA (5%)**
**Location:** Below scene view  
**Purpose:** Character dialogue/reactions

**Contains:**
- Character icon (30×30pt circle)
- Dialogue text
- Shows/hides dynamically based on game events

**Adjustable Properties:**
```swift
.frame(height: geometry.size.height * 0.05)  // ← Change this percentage
```

**Visual Notes:**
- 0.3s fade in/out animation
- Semi-transparent black background (0.6 opacity)
- Shows `Color.clear` when no commentary active

---

### **4. REPAIR AREA (17.7%)**
**Location:** Below commentary (with 5.5% gap)  
**Purpose:** 4 slots for placing component cards

**Contains:**
- "REPAIR AREA" label
- 4 horizontal card slots (8pt spacing)
- Cards animate in when placed

**Adjustable Properties:**
```swift
.frame(height: geometry.size.height * 0.177)  // ← Change this percentage (was 0.16)
```

**Visual Notes:**
- Label: 12pt semibold, white 0.7 opacity, 1pt tracking
- HStack spacing: 8pt between slots
- Slots are invisible until cards placed

---

### **5. DECKS AREA (30%)**
**Location:** Below repair area (with 6% gap)  
**Purpose:** 4 component decks for drawing cards

**Contains:**
- "COMPONENT DECKS" label
- 4 deck stacks (Structural, Enchantment, Memory, Wildcraft)
- Ghost cards behind each deck
- Card count below each deck

**Adjustable Properties:**
```swift
.frame(height: geometry.size.height * 0.30)  // ← Change this percentage

// Inside decksArea computed property:
HStack(spacing: 4) {  // ← Change this for deck spacing (currently 4px)
```

**Deck Configuration:**
- **Current:** Straight horizontal row (0° rotation)
- **Previous:** Fanned arc (-12°, -4°, +4°, +12°)
- **Spacing:** 4px between decks (changed from 6px)

**Visual Notes:**
- Label: 12pt semibold, white 0.6 opacity, 1pt tracking
- Ghost cards rotate slightly (-2.5°, -1.2°) for depth
- Cards flip 3D when drawing (0.15s animation)
- Active/inactive opacity (1.0 vs 0.5)

---

## 🎨 GAP SYSTEM (NEW)

### **Gap 3: Commentary → Repair (5.5%)**
```swift
Spacer()
    .frame(height: geometry.size.height * 0.055)  // ← Change this percentage
```

**Purpose:** Create visual separation, show background texture  
**Effect:** Dark table background visible between sections

---

### **Gap 4: Repair → Decks (6.0%)**
```swift
Spacer()
    .frame(height: geometry.size.height * 0.06)  // ← Change this percentage
```

**Purpose:** Create visual separation, show background texture  
**Effect:** Dark table background visible between sections

---

## 🔄 DECK ROTATION SYSTEM

### **Current State: NO ROTATION**

All decks pass `rotationDegrees: 0` to DeckView.

```swift
// Inside decksArea:
DeckView(
    type: .structural,
    topCard: gameState.topCard(of: .structural),
    cardsRemaining: gameState.cardsRemaining(in: .structural),
    canDraw: gameState.canDraw(from: .structural),
    rotationDegrees: 0,  // ← Change this to rotate deck
    onTap: { /* ... */ }
)
```

### **Previous Fanned Arc Values:**
- Structural: `-12°` (leftmost)
- Enchantment: `-4°`
- Memory: `+4°`
- Wildcraft: `+12°` (rightmost)

### **To Restore Fanned Arc:**
1. Change `rotationDegrees:` values in ShopOfOdditiesView.swift
2. Uncomment rotation line in DeckView.swift:
   ```swift
   .rotationEffect(.degrees(rotationDegrees), anchor: .bottom)
   ```

---

## 📱 RESPONSIVE DESIGN NOTES

### **Percentage-Based Sizing:**
All main sections use `geometry.size.height * [percentage]`:
- ✅ Scales automatically for different iOS devices
- ✅ Works on iPhone SE, iPhone 15 Pro Max, iPad, etc.
- ✅ Maintains proportional layout

### **Fixed Pixel Values:**
Small gaps use fixed `8pt` values:
- These provide consistent padding regardless of screen size
- Can be changed to percentages if needed: `.frame(height: geometry.size.height * 0.01)`

### **HStack Spacing:**
Horizontal spacing (like deck gaps) uses fixed pixel values:
- `HStack(spacing: 4)` means 4 points between items
- Scales with screen density (retina displays handle this automatically)

---

## 🛠️ HOW TO ADJUST LAYOUT

### **To Make a Section Bigger/Smaller:**

1. **Find the section** in the table above
2. **Locate the line** in ShopOfOdditiesView.swift
3. **Change the percentage:**
   ```swift
   // Example: Make repair area bigger
   .frame(height: geometry.size.height * 0.20)  // 20% instead of 17.7%
   ```

### **To Add/Remove Gaps:**

1. **Add a gap:** Insert a Spacer between sections
   ```swift
   Spacer()
       .frame(height: geometry.size.height * 0.05)  // 5% gap
   ```

2. **Remove a gap:** Delete the Spacer line

### **To Change Deck Spacing:**

1. **Find decksArea** computed property
2. **Change HStack spacing:**
   ```swift
   HStack(spacing: 8) {  // Change from 4 to 8 for wider gaps
   ```

### **To Restore Deck Rotation:**

1. **ShopOfOdditiesView.swift:** Change `rotationDegrees:` values
2. **DeckView.swift:** Uncomment `.rotationEffect()` line

---

## ⚠️ IMPORTANT CONSTRAINTS

### **Total Height Warning:**
The sum of all percentages can exceed 100% because:
- Fixed 8pt gaps compress as needed
- SwiftUI's VStack handles overflow with Spacers
- Content stays within safe area

### **Recommended Totals:**
- **Main sections:** ~95-100% (allows breathing room)
- **Gaps:** Use percentages or small fixed values (8-12pt)
- **Bottom gap:** Always keep 8pt for safe area padding

### **If Layout Breaks:**
- Reduce largest section percentages first (Scene or Decks)
- Convert fixed gaps to smaller percentages
- Test on smallest device (iPhone SE) to ensure nothing clips

---

## 🎯 QUICK REFERENCE TABLE

Copy this table for quick adjustments:

| Section | Current | Adjust To | Effect |
|---------|---------|-----------|--------|
| Score Bar | 5.0% | _____% | Make HUD bigger/smaller |
| Scene View | 38.0% | _____% | Make character art bigger/smaller |
| Commentary | 5.0% | _____% | Make dialogue box bigger/smaller |
| Gap 3 (Commentary→Repair) | 5.5% | _____% | More/less space, background shows |
| Repair Area | 17.7% | _____% | Make card slots bigger/smaller |
| Gap 4 (Repair→Decks) | 6.0% | _____% | More/less space, background shows |
| Decks Area | 30.0% | _____% | Make deck cards bigger/smaller |
| Deck Spacing | 4px | _____px | Gap between deck cards |

---

## 📝 STEP-BY-STEP MODIFICATION GUIDE

### **Example: Make Repair Area 20% and Commentary 7%**

1. Open **ShopOfOdditiesView.swift** in Xcode
2. Press **Command+F** to find
3. Search for: `geometry.size.height * 0.177`
4. Change to: `geometry.size.height * 0.20`
5. Search for: `geometry.size.height * 0.05` (commentary line)
6. Change to: `geometry.size.height * 0.07`
7. Press **Command+S** to save
8. Press **Command+R** to run and test

---

## 🧪 TESTING CHECKLIST

After making layout changes:

- [ ] Score bar visible at top
- [ ] Scene view shows customer properly
- [ ] Commentary appears when triggered
- [ ] Gaps show background texture
- [ ] Repair slots visible and tappable
- [ ] All 4 decks visible and tappable
- [ ] Card count text visible below decks
- [ ] Ghost cards visible behind decks
- [ ] Nothing clips off screen (test on iPhone SE)
- [ ] Overlays still work (repair result, game over)

---

## 🔗 RELATED FILES

**Files That Control Layout:**
- `ShopOfOdditiesView.swift` - Main layout percentages and structure
- `DeckView.swift` - Deck rotation and card sizing
- `ShopSceneView.swift` - Scene composite layers (DO NOT MODIFY)
- `RepairSlotView.swift` - Individual repair slot sizing (DO NOT MODIFY)

**Files To NOT Modify:**
- All data model files (ComponentType, ComponentCard, Customer, etc.)
- Overlay files (RepairResultOverlay, ShopGameOverOverlay, NewRepairDiscoveredBanner)
- AssetsDebugView (debug menu)

---

## 🎨 DESIGN PHILOSOPHY

**Current Design Goals:**
- ✅ Image-first aesthetic (scenes and cards are primary focus)
- ✅ Minimalist UI (invisible elements until needed)
- ✅ Breathing room between sections (gaps show background)
- ✅ Responsive scaling (percentages adapt to screen size)
- ✅ Clean, organized layout (straight rows, consistent spacing)

**Layout Priorities:**
1. Scene view (largest - 38%)
2. Decks area (second - 30%)
3. Repair area (third - 17.7%)
4. Commentary + Score bar (smallest - 5% each)

---

## 📄 CHANGES MADE SO FAR

**Step 1: Added Gaps + Grew Repair Area**
- Added 5.5% gap between commentary and repair
- Added 6.0% gap between repair and decks
- Grew repair area from 16% → 17.7%
- Changed from fixed 8pt spacers to percentage-based gaps

**Step 2: Removed Deck Rotation**
- Changed deck rotation from -12°, -4°, +4°, +12° → 0° (all straight)
- Changed deck spacing from 6px → 4px
- Updated DeckView.swift to not apply rotation
- Ghost cards still rotate (-2.5°, -1.2°) for depth

---

## 🚀 PROMPT TO CONTINUE IN NEW CHAT

**Copy this prompt to start the next chat session:**

```
Shop of Oddities Layout Tweaking (Continued)

I'm continuing layout adjustments for Shop of Oddities. Please read these files IN ORDER:
1. MASTER_CONTEXT.md
2. ShopOfOddities_CONTEXT.md
3. SHOP_LAYOUT_TWEAKING_GUIDE.md (THIS FILE)

Current state:
- Step 1 COMPLETE: Added gaps (5.5% and 6%), grew repair area to 17.7%
- Step 2 COMPLETE: Removed deck rotation (all 0°), changed spacing to 4px

I'm ready for Step 3 or additional layout tweaks. The current file is ShopOfOdditiesView.swift.

All layout values are in the SHOP_LAYOUT_TWEAKING_GUIDE.md file. I need COMPLETE, copy-paste ready code (never snippets). Step-by-step Xcode instructions required.

What layout adjustments would you like me to make next?
```

---

**END OF SHOP LAYOUT TWEAKING GUIDE**

**Last Updated:** April 6, 2026  
**Status:** Ready for continued development in new chat session  
**Next Steps:** Further layout refinements as needed
