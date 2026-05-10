# LAYOUT REFINEMENT SESSION - MAY 6, 2026
**Ednar's Potion Cauldron - Layout Updates & Edge Line Fixes**

> **Session Date:** May 6, 2026  
> **Status:** ✅ COMPLETE - Mildred layout refined, edge lines fixed, documentation updated  
> **Next Steps:** Node image replacement + edge line controls in debug menu

---

## 📋 SESSION SUMMARY

This session focused on:
1. ✅ Updating Mildred's character width from layout editor values
2. ✅ Updating documentation (CAULDRON_CONTEXT.md + MASTER_CONTEXT.md)
3. ✅ Fixing edge lines to follow per-node offsets
4. ✅ Adding edge line deduplication
5. 📋 **PENDING:** Node image replacement system
6. 📋 **PENDING:** Edge line controls in debug menu

---

## 🎨 PART 1: MILDRED LAYOUT REFINEMENT

### **User Request:**
User provided layout values from the layout editor's "Copy to Clipboard" feature and requested they be made permanent.

### **Changes Made:**

#### **1. PotionShopLayoutConfig.swift**
**File:** `/repo/PotionShopLayoutConfig.swift`

**Updated Mildred's width:**
```swift
// BEFORE:
"mildred": CharacterScale(width: 2.34, height: 2.13, x: -1.0283708572387695, y: 15.539002418518066)

// AFTER:
"mildred": CharacterScale(width: 2.461897164583206, height: 2.13, x: -1.0283708572387695, y: 15.539002418518066)
```

**What Changed:**
- Mildred's width: `2.34` → `2.461897164583206` (5.2% wider)
- Height, X, Y positions: Unchanged

#### **2. CAULDRON_CONTEXT.md**
**File:** `/repo/CAULDRON_CONTEXT.md`

**Updates Made:**
1. **Top summary section (line 3):**
   - Changed "Last Updated" from "Tomik Added to Customer Scaling" to "Mildred Width Refined to 2.46×"
   - Updated character scaling note to show specific values for each character

2. **Section 12.1.2 - Current Characters with Art:**
   ```markdown
   BEFORE:
   - **Mildred** - `mildred_scene.png` (2.34×, 2.13×, 5pt, 51pt)
   
   AFTER:
   - **Mildred** - `mildred_scene.png` (2.46×, 2.13×, -1.03pt, 15.54pt) ✨ Updated May 6, 2026
   ```

3. **Phase History Entry (7h):**
   - Updated from generic description to specific values for both characters

#### **3. MASTER_CONTEXT.md**
**File:** `/repo/MASTER_CONTEXT.md`

**Updates Made:**
1. **Top summary:**
   - Changed "Last Updated" to "May 6, 2026 (Ednar's Potion Cauldron - Mildred Layout Refined)"
   - Added "(layout refinement ongoing)" to current work

2. **"What's In Progress" section:**
   ```markdown
   BEFORE:
   - 🟡 **Ednar's Cauldron Rewrite** - Phase 1 (Data Layer) complete, Phase 2 next
   
   AFTER:
   - 🟡 **Ednar's Potion Cauldron** - Phase 7 complete, layout refinement ongoing
     - Day 1 fully playable
     - Live preview overlay layout editor functional
     - Per-character scaling system active (Mildred: 2.46×2.13×, Tomik: 2.34×2.13×)
     - **Latest update:** Mildred's width refined from 2.34× to 2.46× (5.2% wider)
     - Art is placeholder (ready for asset integration - Phase 8)
   ```

---

## 🔗 PART 2: EDGE LINE FIXES

### **Issue Discovered:**
Edge lines connecting cauldron nodes were NOT following per-node fine-tuning offsets, causing visual disconnect when nodes were moved.

### **Problem:**
```swift
// BEFORE (BROKEN):
Path { path in
    for (a, b) in PotionShopBoard.edges {
        let na = PotionShopBoard.nodes[a]
        let nb = PotionShopBoard.nodes[b]
        path.move(
            to: CGPoint(
                x: g.nodeOriginX + CGFloat(na.x) * g.nodeSpacingMultiplier,
                y: g.nodeOriginY + CGFloat(na.y) * g.nodeSpacingMultiplier
            )
        )
        path.addLine(
            to: CGPoint(
                x: g.nodeOriginX + CGFloat(nb.x) * g.nodeSpacingMultiplier,
                y: g.nodeOriginY + CGFloat(nb.y) * g.nodeSpacingMultiplier
            )
        )
    }
}
```

❌ **Lines used base node positions only (no per-node offsets)**

### **Fix Applied:**

#### **File:** `PotionShopCauldronView.swift` (lines 245-271)

**Added offset tracking:**
```swift
// AFTER (FIXED):
Path { path in
    for (a, b) in PotionShopBoard.edges {
        let na = PotionShopBoard.nodes[a]
        let nb = PotionShopBoard.nodes[b]
        let offsetA = a < perNodeOffsets.count ? perNodeOffsets[a] : .zero
        let offsetB = b < perNodeOffsets.count ? perNodeOffsets[b] : .zero
        path.move(
            to: CGPoint(
                x: g.nodeOriginX + CGFloat(na.x) * g.nodeSpacingMultiplier + offsetA.x,
                y: g.nodeOriginY + CGFloat(na.y) * g.nodeSpacingMultiplier + offsetA.y
            )
        )
        path.addLine(
            to: CGPoint(
                x: g.nodeOriginX + CGFloat(nb.x) * g.nodeSpacingMultiplier + offsetB.x,
                y: g.nodeOriginY + CGFloat(nb.y) * g.nodeSpacingMultiplier + offsetB.y
            )
        )
    }
}
```

✅ **Lines now follow nodes at their actual displayed positions**

### **Position Calculation:**
```
Final Line Point =
  Base Grid Origin
  + (Node Base Coordinate × Spacing Multiplier)
  + Per-Node Offset  ← NEW!
```

---

## 🔄 PART 3: EDGE LINE DEDUPLICATION

### **User Request:**
"Can we have just one line per connection only"

### **Issue:**
User wanted to ensure no duplicate lines were being drawn if the edges array contained both (a,b) and (b,a).

### **Solution Applied:**

**Added deduplication system:**
```swift
// Edge lines connecting nodes (one line per connection)
Path { path in
    // Create set to track drawn edges (ensure no duplicates)
    var drawnEdges = Set<String>()
    
    for (a, b) in PotionShopBoard.edges {
        // Create a unique key for this edge (bidirectional check)
        let edgeKey = a < b ? "\(a)-\(b)" : "\(b)-\(a)"
        
        // Only draw if we haven't drawn this edge yet
        guard !drawnEdges.contains(edgeKey) else { continue }
        drawnEdges.insert(edgeKey)
        
        // ... draw line from a to b (with offsets as shown above)
    }
}
```

### **How It Works:**

**Edge Key System:**
```swift
// For edge (3, 7):
let edgeKey = 3 < 7 ? "3-7" : "7-3"  // → "3-7"

// For edge (7, 3):
let edgeKey = 7 < 3 ? "7-3" : "3-7"  // → "3-7"  (same key!)
```

Both directions produce the **same unique key**, so the second one gets skipped.

**Result:**
- ✅ Only one line per unique node connection
- ✅ No duplicate lines even if edges array has both (a,b) and (b,a)
- ✅ Lines follow per-node offsets
- ✅ Performance-safe (Set lookup is O(1))

---

## 🎨 PART 4: NODE IMAGE REPLACEMENT (PENDING)

### **User Question:**
"Is there a way to replace the node layout with hand-drawn images?"

### **Answer:**
✅ **YES!** Nodes can be replaced with custom images.

### **Current System:**
- Nodes are drawn as `RoundedRectangle` shapes with fills/strokes
- Located in `PotionShopNodeButtonView` (lines 365-400 in PotionShopCauldronView.swift)

### **Implementation Options:**

#### **Option A: Single Node Image (All Nodes Look The Same)**
```swift
// In Assets.xcassets, add:
// - "cauldron_node.png" (e.g., a circular stone/rune marker)

// Replace the RoundedRectangle with:
if let nodeImage = PotionShopImageLoader.loadImage(named: "cauldron_node") {
    Image(uiImage: nodeImage)
        .resizable()
        .scaledToFit()
        .frame(
            width: PotionShopCauldronLayout.nodeVisible * visualScale,
            height: PotionShopCauldronLayout.nodeVisible * visualScale
        )
        .opacity(canBePlacedOn ? 1.0 : 0.7)  // Dim when can't place
} else {
    // Fallback to RoundedRectangle
}
```

#### **Option B: Per-Node Custom Images (Each Node Has Its Own Look)**
```swift
// In Assets.xcassets, add:
// - "node_0.png", "node_1.png", ..., "node_11.png"

// Load specific image per node:
let imageName = "node_\(nodeIndex)"
if let nodeImage = PotionShopImageLoader.loadImage(named: imageName) {
    // Use custom image for this specific node
}
```

#### **Option C: State-Based Images (Empty vs Can-Place vs Occupied)**
```swift
// Different image depending on node state:
let imageName = if placedDie != nil {
    "node_occupied"
} else if canBePlacedOn {
    "node_ready"
} else {
    "node_empty"
}

if let nodeImage = PotionShopImageLoader.loadImage(named: imageName) {
    // Use state-appropriate image
}
```

### **Recommended Approach:**
**Option C (State-Based)** is most flexible:
- Shows visual feedback when nodes are ready to receive dice
- Different look when occupied vs empty
- Only needs 3 images instead of 12

---

## 🎛️ PART 5: EDGE LINE CONTROLS (PENDING)

### **User Question:**
"Can you add connect/delete lines to the debug menu?"

### **Answer:**
✅ **YES!** We can add full edge line controls to the layout editor.

### **Proposed Controls:**

#### **In Layout Editor - New Section: 🔗 Edge Lines**

**Toggles:**
- ✅ **Show Edge Lines** (on/off toggle) - Hide lines completely
- ✅ **Edge Line Opacity** slider (0% to 100%) - Current: 30%
- ✅ **Edge Line Thickness** slider (1pt to 5pt) - Current: 1pt
- ✅ **Edge Line Color** picker (white, yellow, cyan, red, etc.)

**Current Edge Line Properties:**
```swift
.stroke(Color.white.opacity(0.30), lineWidth: 1)
```

### **Implementation Plan:**

#### **1. Add to PotionShopLayoutConfig.swift:**
```swift
// Edge Line Settings
var showEdgeLines: Bool = true
var edgeLineOpacity: Double = 0.30
var edgeLineThickness: Double = 1.0
var edgeLineColor: Color = .white  // or store as RGB components
```

#### **2. Update PotionShopCauldronView.swift:**
```swift
// Edge lines connecting nodes (conditionally shown)
if showEdgeLines {
    Path { path in
        // ... existing edge drawing code
    }
    .stroke(edgeLineColor.opacity(edgeLineOpacity), lineWidth: edgeLineThickness)
}
```

#### **3. Add UI to Layout Editor:**
```swift
// In PotionShopLayoutOverlay (🔗 Edge Lines section)
VStack(alignment: .leading, spacing: 12) {
    Toggle("Show Edge Lines", isOn: $layoutConfig.showEdgeLines)
    
    if layoutConfig.showEdgeLines {
        VStack(alignment: .leading, spacing: 8) {
            Text("Opacity: \(Int(layoutConfig.edgeLineOpacity * 100))%")
            Slider(value: $layoutConfig.edgeLineOpacity, in: 0...1)
            
            Text("Thickness: \(layoutConfig.edgeLineThickness, specifier: "%.1f") pt")
            Slider(value: $layoutConfig.edgeLineThickness, in: 1...5)
            
            // Color picker (simplified - 5 preset colors)
            HStack {
                ForEach([Color.white, Color.yellow, Color.cyan, Color.red, Color.green], id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle().stroke(
                                layoutConfig.edgeLineColor == color ? Color.blue : Color.clear,
                                lineWidth: 3
                            )
                        )
                        .onTapGesture {
                            layoutConfig.edgeLineColor = color
                        }
                }
            }
        }
    }
}
```

---

## 📁 FILES MODIFIED IN THIS SESSION

### **1. PotionShopLayoutConfig.swift**
- Updated Mildred's `width` from `2.34` to `2.461897164583206`

### **2. CAULDRON_CONTEXT.md**
- Updated top summary with new date and Mildred refinement note
- Updated Section 12.1.2 with new Mildred values
- Updated Phase 7h history entry with specific character values

### **3. MASTER_CONTEXT.md**
- Updated top summary date
- Completely rewrote "What's In Progress" section with current status

### **4. PotionShopCauldronView.swift**
- **Lines 245-271:** Added per-node offset tracking to edge line rendering
- **Lines 245-271:** Added edge line deduplication system

---

## 🧪 TESTING INSTRUCTIONS

### **Test 1: Verify Mildred Width Change**
1. Build and run app (Command+R)
2. Navigate to Ednar's Potion Cauldron
3. Start game (should see Mildred in Morning round)
4. **Expected:** Mildred's portrait should be slightly wider than before

### **Test 2: Verify Layout Editor Defaults**
1. Open debug menu (⚙️ gear icon)
2. Tap "Layout Editor (Live Overlay)"
3. Swipe to 🧍 Customers section
4. Select Mildred from dropdown
5. **Expected:** Width slider shows ~2.46 (not 2.34)

### **Test 3: Verify Edge Lines Follow Nodes**
1. Open layout editor
2. Swipe to 🔧 Fine-Tune section
3. Select any node (e.g., Node 5)
4. Drag X Offset slider left/right
5. **Expected:** Edge lines stretch and stay connected to the moving node
6. Drag Y Offset slider up/down
7. **Expected:** Lines follow the node vertically

### **Test 4: Verify No Duplicate Lines**
1. Look at the cauldron node grid
2. Count visible edge lines between nodes
3. **Expected:** Only ONE line between each connected pair of nodes

---

## 🎯 NEXT STEPS (FOR FUTURE SESSION)

### **Priority 1: Node Image Replacement**
**User needs to decide:**
- ✅ Which option: A (single), B (per-node), or C (state-based)?
- ✅ Asset name(s) to use in Assets.xcassets
- ✅ Desired size/style of node images

**Files to modify:**
- `PotionShopNodeButtonView` in `PotionShopCauldronView.swift`

### **Priority 2: Edge Line Controls**
**Implementation steps:**
1. Add edge line properties to `PotionShopLayoutConfig.swift`
2. Add conditional rendering in `PotionShopCauldronView.swift`
3. Add 🔗 Edge Lines section to layout editor overlay
4. Test toggle, opacity, thickness, and color controls

**Files to modify:**
- `PotionShopLayoutConfig.swift` (add edge line properties)
- `PotionShopCauldronView.swift` (conditional rendering)
- Layout editor view (add UI controls)

---

## 📝 QUICK REFERENCE: CURRENT PRODUCTION VALUES

### **Character Scaling (as of May 6, 2026):**
```swift
"mildred": CharacterScale(
    width: 2.461897164583206,
    height: 2.13,
    x: -1.0283708572387695,
    y: 15.539002418518066
)

"tomik": CharacterScale(
    width: 2.34,
    height: 2.13,
    x: 5.0,
    y: 51.0
)
```

### **Edge Line Properties:**
```swift
// Current (hardcoded):
.stroke(Color.white.opacity(0.30), lineWidth: 1)

// Proposed (configurable):
showEdgeLines: true
edgeLineOpacity: 0.30
edgeLineThickness: 1.0
edgeLineColor: .white
```

### **Node Visual Properties:**
```swift
// Current rendering:
RoundedRectangle(cornerRadius: 4)
    .fill(visibleFill)  // Color based on state
    .frame(
        width: PotionShopCauldronLayout.nodeVisible * visualScale,
        height: PotionShopCauldronLayout.nodeVisible * visualScale
    )
    .overlay(
        RoundedRectangle(cornerRadius: 4)
            .stroke(visibleStroke, lineWidth: visibleStrokeWidth)
    )

// Future: Replace with Image(uiImage: nodeImage)
```

---

## 🔗 RELATED DOCUMENTATION

- **CAULDRON_CONTEXT.md** - Complete game context (updated in this session)
- **MASTER_CONTEXT.md** - Project overview (updated in this session)
- **PotionShopLayoutConfig.swift** - Layout configuration (updated in this session)
- **PotionShopCauldronView.swift** - Cauldron rendering (updated in this session)

---

## ✅ SESSION COMPLETE

**Summary:**
- ✅ Mildred width refined to 2.46× (5.2% wider)
- ✅ Documentation updated (CAULDRON_CONTEXT + MASTER_CONTEXT)
- ✅ Edge lines now follow per-node offsets
- ✅ Edge line deduplication system active
- 📋 Node image replacement - awaiting user decision
- 📋 Edge line controls - ready to implement

**Next Chat:**
Read this document first, then ask user which node image option they prefer and implement it along with edge line controls.

---

**END OF SESSION DOCUMENT**
