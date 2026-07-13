# NEW LAYOUT EDITOR - How to Use

**Created:** May 4, 2026  
**Status:** ✅ Complete and ready to use  
**Location:** Built into `PotionShopDebugMenu.swift`

---

## 🎯 How to Access

1. **Launch the game** from the game selector
2. **Tap the gear icon** (⚙️) in the top-right of the header
3. **Tap "Layout Editor"** in the debug menu
4. A new full-screen editor will open

---

## 📋 What You Can Control

### **📏 Section Heights**
Controls the vertical space allocation for each section:
- **Header** (0-20%)
- **Scene** (0-50%) - Ednar + customers
- **Profile Row** (0-20%)
- **Cauldron** (0-60%) - The bowl + nodes
- **Preview Bar** (0-10%)
- **Dice Tray** (0-30%)

**Total percentage is shown** - it will turn RED if over 100%

### **🧙 Ednar Art**
Controls Ednar's character image:
- **Uniform Scale** (0.5×-3.0×) - Overall size multiplier
- **Width Scale** (0.5×-3.0×) - Independent horizontal stretch/squish
- **Height Scale** (0.5×-3.0×) - Independent vertical stretch/squish
- **X Position** (-200 to +200 pts) - Horizontal offset
- **Y Position** (-200 to +200 pts) - Vertical offset

**Buttons:**
- "Reset Position" - Returns X/Y to 0
- "Reset Scale" - Returns all scales to 1.0

### **🍲 Cauldron Art**
Controls the cauldron image (same as Ednar):
- Uniform Scale, Width Scale, Height Scale
- X Position, Y Position
- Reset Position, Reset Scale buttons

### **🥘 Cauldron Bowl Position**
Controls the parametric bowl shape (the brown bowl under the art):
- **Scale** (0.5×-3.0×)
- **X Offset** (-200 to +200 pts)
- **Y Offset** (-200 to +200 pts)
- "Reset" button

### **🎲 Dice & Tray**
Controls dice size and tray position:
- **Die Scale** (0.5×-3.0×) - How big dice appear
- **Tray X Offset** (-200 to +200 pts) - Move tray left/right
- **Tray Y Offset** (-200 to +200 pts) - Move tray up/down
- "Reset" button

### **🥄 Brew Tap Zone**
Controls the invisible tap area for brewing:
- **X Position** (0.0-1.0) - Horizontal position (fraction of cauldron width)
- **Y Position** (0.0-1.0) - Vertical position (fraction of cauldron height)
- **Width** (50-300 pts) - Tap zone width
- **Height** (50-300 pts) - Tap zone height
- **Show Debug Zone** toggle - Shows yellow dashed rectangle for debugging
- "Reset" button

---

## 🎨 How to Use

### **Step 1: Expand a section**
Tap any section header (e.g., "🧙 Ednar Art") to expand/collapse it.

### **Step 2: Adjust sliders**
Drag the sliders to change values. **Changes apply immediately** - you'll see the game update in real-time behind the sheet.

### **Step 3: Generate code**
When you're happy with the layout:
1. Tap **"Generate Code"** in the top-right toolbar
2. A new sheet opens with formatted Swift code
3. The code is **automatically copied to clipboard**
4. You can also manually select/copy from the text view

### **Step 4: Apply the code**
1. Close both sheets (code generator, then layout editor)
2. Open `PotionShopGameView.swift` in Xcode
3. Find the relevant sections (look for comments like `// Section height calculations`)
4. **Paste the generated values** where indicated in the comments

---

## 📋 Generated Code Format

The code generator creates **copy-paste ready snippets** like this:

```swift
// ═══════════════════════════════════════════════════════════
// GENERATED LAYOUT CODE - Paste into PotionShopGameView.swift
// ═══════════════════════════════════════════════════════════

// ─── Section Heights (in GeometryReader) ───────────────────
let headerH      = max(70,  totalHeight * 0.010)
let sceneH       = max(160, totalHeight * 0.263)
let profileRowH  = max(74,  totalHeight * 0.095)
let cauldronH    = max(240, totalHeight * 0.372)
let previewBarH  = max(26,  totalHeight * 0.032)
let trayH        = max(82,  totalHeight * 0.193)

// ─── Ednar Art (in PotionShopCustomerSceneView call) ──────
ednarArtScale: 1.0,
ednarArtWidth: 1.59,
ednarArtHeight: 2.0,
ednarArtXOffset: 14,
ednarArtYOffset: -17

// ─── Cauldron Art (in PotionShopCauldronView call) ────────
cauldronArtScale: 1.0,
cauldronArtWidth: 1.45,
cauldronArtHeight: 2.0,
cauldronArtXOffset: 7,
cauldronArtYOffset: -40

// ... etc ...
```

Each section has **clear comments** showing where to paste in `PotionShopGameView.swift`.

---

## 🔧 Tips & Tricks

### **Live Preview**
- Keep the layout editor open while adjusting
- The game view updates in real-time behind the sheet
- Close the sheet to see the full effect

### **Distortion is OK**
- Width and height scales are **completely independent**
- You can make things tall and skinny, or short and wide
- This is intentional (for art fitting)

### **Section Heights**
- Watch the "Total: X%" display
- It turns RED if over 100%
- Recommended: Keep total around 96-98% for spacing

### **Brew Tap Zone**
- Turn on "Show Debug Zone" to see the yellow rectangle
- Position it where you want the ladle art to be
- Turn it off when done

### **Reset Buttons**
- Each section has reset buttons
- "Reset Position" only affects X/Y offsets
- "Reset Scale" only affects scale values
- Use these if you get lost

---

## 🗑️ Removing the Old Layout Editor

Once you're confident this new editor works:

1. **Delete the file:** `PotionShopLayoutEditorView.swift`
2. **That's it!** The new editor is self-contained in `PotionShopDebugMenu.swift`

---

## 🐛 Troubleshooting

### **"Changes aren't applying"**
- Make sure you're adjusting the sliders (not just viewing)
- Close and reopen the layout editor
- Restart the game if needed

### **"Total percentage is red"**
- You've allocated more than 100% vertical space
- Reduce one or more section heights
- Common fix: Reduce header or preview bar

### **"Generated code doesn't match what I see"**
- The code generator uses the **current slider values**
- Make sure you adjusted sliders before generating
- Try generating again after confirming slider positions

### **"Brew zone isn't working"**
- Make sure `showBrewZone: false` in the final code
- The yellow rectangle is for debugging only
- The tap zone works even when invisible

---

## ✅ Current Production Values (Locked - May 4, 2026)

These are the values currently in `PotionShopGameView.swift`:

**Section Heights:**
- Header: 1.0%
- Scene: 26.3%
- Profile: 9.5%
- Cauldron: 37.2%
- Preview: 3.2%
- Tray: 19.3%

**Ednar Art:**
- Width: 1.59, Height: 2.00
- X: 14, Y: -17

**Cauldron Art:**
- Width: 1.45, Height: 2.00
- X: 7, Y: -40

**Cauldron Bowl:**
- Scale: 1.29, X: 44, Y: 58

**Dice:**
- Scale: 1.31

**Tray:**
- X: 0, Y: -25

**Brew Zone:**
- X: 0.83, Y: 0.19
- Width: 112, Height: 123
- Show: false

---

**END OF INSTRUCTIONS**
