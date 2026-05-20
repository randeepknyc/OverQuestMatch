# NODE-TO-NODE DICE DRAG SESSION
**Date:** May 20, 2026  
**Status:** ❌ NOT WORKING - Needs Continuation  
**Goal:** Enable dragging dice from one cauldron node to another node (not just node → tray)

---

## 🎯 WHAT THE USER WANTS

**Current behavior:**
- Dice can be dragged from **tray → node** ✅ (works)
- Dice can be **tapped to remove** (node → tray) ✅ (works)

**Desired behavior:**
- Dice should be draggable from **node → node** ❌ (NOT working yet)
- User should be able to reposition placed dice without returning them to tray

**User requirements:**
1. Drag die from node to another node using drag gesture
2. Hover glow on valid empty target nodes
3. **Origin node should stay visible** (not disappear during drag)
4. **Die should follow finger smoothly** (not way off screen)
5. **Die should animate smoothly** to new position (not snap instantly)
6. If dropped on occupied node → die returns to original node
7. If dropped outside all nodes → die returns to original node
8. Tap-to-remove should still work (quick way to send die back to tray)

---

## ❌ CURRENT PROBLEMS (AS OF LAST ATTEMPT)

**The user reported 3 issues:**

1. **Origin node disappears still**
   - When dragging starts, the source node appears empty/invisible
   - Should stay visible with the die on it during drag

2. **Die way off screen**
   - Die is being moved around but far away from finger position
   - Not following the finger properly
   - Offset calculation is wrong

3. **Snaps instead of animates**
   - Die appears instantly at destination
   - No smooth `matchedGeometryEffect` animation
   - Should slide smoothly from source to target

---

## 📋 WHAT HAS BEEN TRIED

### **Attempt 1: Complex Floating Die System** ❌ FAILED
- Added `nodeDragOffset` and `nodeDragStartPosition` state variables
- Created floating die overlay that calculated position from node center + offset
- **Problem:** Offset math was wrong, die appeared way off screen
- **Problem:** Source node disappeared because die was conditionally hidden

### **Attempt 2: Simplified with matchedGeometryEffect** ❌ FAILED  
- Removed floating die overlay
- Removed offset state variables
- Die stays on source node during drag using `matchedGeometryEffect`
- **Problem:** All 3 issues still present (user confirmed)

---

## 📂 FILES INVOLVED

### **PotionShopGameState.swift**
**Current drag state variables:**
```swift
var draggedDieIndex: Int? = nil      // Hand index when dragging from tray
var draggedDie: PotionShopDie? = nil // The die being dragged
var draggedFromNode: Int? = nil      // Source node for node-to-node moves
var nodePositions: [Int: CGRect] = [:]  // Node positions for hit detection
var hoveredNodeIndex: Int? = nil     // Which node is hovered during drag
```

**Key methods:**
- `startDraggingFromNode(nodeId:)` - Marks source node, stores die
- `tryDropFromNodeToPosition(_:)` - Hit detection, moves die if valid
- `cancelNodeDrag()` - Clears drag state (die stays on original node)
- `updateDragHoverPosition(_:)` - Updates which node is hovered (excludes source)

### **PotionShopCauldronView.swift**
**Current structure:**
```swift
if let die = placedDie {
    let isDraggingThisDie = (gs.draggedFromNode == nodeIndex)
    
    // Show die normally when not dragging
    if !isDraggingThisDie {
        PotionShopPlacedDieView(die: die, visualScale: visualScale)
            .matchedGeometryEffect(...)
            .onTapGesture { /* tap to remove */ }
            .gesture(DragGesture(...) { /* node-to-node drag */ })
    }
}
```

**The node button has:**
- Conditional rendering: hides die when `isDraggingThisDie == true`
- Drag gesture on the die view
- Tap gesture for removal
- `matchedGeometryEffect` for animations

---

## 🔍 ROOT CAUSE ANALYSIS

### **Problem 1: Why does origin node disappear?**

**Theory A:** Die is being hidden when `isDraggingThisDie == true`
```swift
if !isDraggingThisDie {
    PotionShopPlacedDieView(...)  // Only renders when NOT dragging
}
```
This means when drag starts, the die disappears completely from the source node.

**Theory B:** Die is still in `placements` dictionary
The node thinks it has a die, but the view isn't rendering it because of the conditional.

### **Problem 2: Why is die way off screen?**

**Theory A:** Offset calculation uses wrong coordinate space
The drag gesture uses `.global` coordinate space, but the die position might need local coordinates.

**Theory B:** No offset being applied at all
Current code doesn't have any offset state variables anymore - die position is purely controlled by `matchedGeometryEffect`, which only works when die exists in both source and destination.

### **Problem 3: Why does it snap instead of animate?**

**Theory A:** `matchedGeometryEffect` not working
For `matchedGeometryEffect` to animate smoothly, the die needs to:
1. Exist in source location with ID
2. Exist in destination location with same ID
3. SwiftUI animates the transition

Currently, the die is conditionally hidden during drag, so there's no source to animate from.

---

## 💡 PROPOSED SOLUTION (FOR NEXT ATTEMPT)

### **Key Insight:**
The tray → node drag works perfectly using `.offset(dragOffset)`. We should copy that pattern for node → node.

### **How tray drag works:**
```swift
// In PotionShopDieButtonView (tray dice)
@State private var dragOffset: CGSize = .zero
@State private var isDragging: Bool = false

.offset(dragOffset)  // Die follows finger via offset
.gesture(
    DragGesture(coordinateSpace: .global)
        .onChanged { value in
            dragOffset = value.translation  // Update offset during drag
        }
)
```

### **Proposed node drag approach:**

**Option A: Add offset to placed die (like tray dice)**
```swift
if let die = placedDie {
    @State var dragOffset: CGSize = .zero  // NEW
    
    PotionShopPlacedDieView(die: die, visualScale: visualScale)
        .matchedGeometryEffect(...)
        .offset(dragOffset)  // NEW - die follows finger
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    dragOffset = value.translation  // Die follows finger
                }
                .onEnded { value in
                    // Try to drop, animate back if failed
                }
        )
}
```

**Benefits:**
- ✅ Die follows finger smoothly (like tray dice)
- ✅ Die stays visible on source node
- ✅ Can use `withAnimation` to spring back on failure

**Option B: Keep die in placements during drag, use global overlay**
```swift
// In PotionShopCauldronView (at top level, not in node)
if let draggedDie = gs.draggedDie,
   let sourceNodeId = gs.draggedFromNode,
   let sourceRect = gs.nodePositions[sourceNodeId] {
    
    PotionShopPlacedDieView(die: draggedDie, ...)
        .position(x: fingerX, y: fingerY)  // Absolute position
        .zIndex(1000)
}
```

**Benefits:**
- ✅ Source node keeps original die (doesn't disappear)
- ✅ Floating die follows finger precisely
- ❌ Two copies of die visible (source + floating)

---

## 🎯 RECOMMENDED NEXT STEPS

### **Step 1: Add local drag offset to node die view**

Add `@State` variable to track drag offset for placed dice:

```swift
// In PotionShopNodeButtonView
@State private var nodeDragOffset: CGSize = .zero
```

### **Step 2: Apply offset to die during drag**

```swift
if let die = placedDie {
    PotionShopPlacedDieView(die: die, visualScale: visualScale)
        .matchedGeometryEffect(...)
        .offset(nodeDragOffset)  // Die follows finger
        .scaleEffect(gs.draggedFromNode == nodeIndex ? 1.15 : 1.0)
        .shadow(...)
        .gesture(...)
}
```

### **Step 3: Update gesture to use translation**

```swift
.gesture(
    DragGesture(minimumDistance: 5, coordinateSpace: .global)
        .onChanged { value in
            if gs.draggedFromNode == nil {
                gs.startDraggingFromNode(nodeId: nodeIndex)
            }
            nodeDragOffset = value.translation  // Die follows finger!
            gs.updateDragHoverPosition(value.location)
        }
        .onEnded { value in
            let dropped = gs.tryDropFromNodeToPosition(value.location)
            if dropped {
                nodeDragOffset = .zero  // Reset for animation
            } else {
                withAnimation(.spring(...)) {
                    nodeDragOffset = .zero  // Spring back
                    gs.cancelNodeDrag()
                }
            }
        }
)
```

### **Step 4: Don't hide die during drag**

Remove the conditional hiding:
```swift
// REMOVE THIS:
if !isDraggingThisDie {
    PotionShopPlacedDieView(...)
}

// REPLACE WITH:
PotionShopPlacedDieView(...)  // Always visible
    .offset(gs.draggedFromNode == nodeIndex ? nodeDragOffset : .zero)
```

---

## 🔧 ALTERNATIVE APPROACH (IF ABOVE FAILS)

### **Copy the exact tray drag system**

1. Add the same state variables to placed dice that tray dice use
2. Use the same gesture handling
3. Use the same offset logic
4. Only difference: `onEnded` tries node-to-node placement instead of tray-to-node

**Files to reference:**
- `PotionShopDieButtonView` in `PotionShopCauldronView.swift` (lines ~700-820)
- Look for `@State private var dragOffset: CGSize = .zero`
- Look for `.offset(dragOffset)`
- Copy that pattern exactly

---

## 📝 TESTING CHECKLIST (FOR NEXT ATTEMPT)

Once implemented, test these scenarios:

**Basic Movement:**
- [ ] Drag die from Node 0 to Node 3
- [ ] Die follows finger smoothly (not offset/far away)
- [ ] Source node stays visible (doesn't disappear)
- [ ] Target node glows yellow when hovering
- [ ] Die animates smoothly to new position (no snap)

**Edge Cases:**
- [ ] Drag to occupied node → die springs back to source
- [ ] Drag outside nodes → die springs back to source
- [ ] Drag to same node → just cancels (die stays)
- [ ] Tap die → removes to tray (still works)

**Visual Polish:**
- [ ] Die scales up 15% during drag
- [ ] Die has colored glow shadow during drag
- [ ] Source node doesn't glow (excluded from hover)
- [ ] Empty target nodes glow yellow

---

## 💬 CONVERSATION CONTEXT

**What the user said:**
> "the origin node disappears still"
> "the die is being moved around but wayyyy off screen, not following the finger"  
> "the die will appear in the new node but as if it snaps to it instead of moving"

**Current token usage:**
- ~138,000 / 200,000 tokens used
- ~62,000 tokens remaining
- Conversation is at 69% capacity

**User coding level:**
- Zero coding knowledge
- Needs complete copy-paste code
- Needs step-by-step Xcode instructions
- Prefers complete files over snippets

---

## 🎯 FOR THE NEXT AI ASSISTANT

**What to do:**
1. Read this file first
2. Implement **Option A** from "Proposed Solution" section
3. Add `@State var dragOffset` to placed dice
4. Use `.offset(dragOffset)` like tray dice do
5. Update gesture to set `dragOffset = value.translation`
6. Don't hide the die during drag
7. Test all 3 problems are fixed
8. Provide complete copy-paste code for both files

**What NOT to do:**
- Don't create complex floating overlays
- Don't use absolute positioning
- Don't calculate offsets from node centers
- Don't hide the die conditionally
- Don't try fancy matchedGeometryEffect tricks

**Keep it simple:** Copy the tray drag system exactly, just change where the die goes on drop.

---

**Good luck! 🍀**
