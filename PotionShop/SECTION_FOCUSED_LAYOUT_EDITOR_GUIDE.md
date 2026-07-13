# 🎯 SECTION-FOCUSED LAYOUT EDITOR - Quick Start

**Created:** May 5, 2026  
**Status:** ✅ COMPLETE - Ready to test  
**Type:** Section-focused UI (only shows active section at a time)

---

## ✅ What Was Changed

### **Before (Old Editor):**
- All sections shown at once in a long scrolling list
- Collapsible headers with chevrons
- Lots of scrolling to find controls
- Hard to see which section you're editing

### **After (New Editor):**
- **Horizontal section picker** at top (scrollable pills)
- **Only active section's controls visible**
- Tap a pill to switch sections instantly
- Clean, focused interface - no scrolling through everything

---

## 🚀 How to Use (Step-by-Step)

### **Step 1: Open the editor**
1. Launch the game
2. Tap the **gear icon** (⚙️) in the top-right
3. Tap **"Layout Editor"** in the debug menu
4. A new screen opens with section pills at the top

### **Step 2: Select a section**
At the top, you'll see **6 colored pills**:
- 📏 Section Heights
- 🧙 Ednar Art
- 🍲 Cauldron Art
- 🥘 Cauldron Bowl
- 🎲 Dice & Tray
- 🥄 Brew Tap Zone

**Tap any pill** to activate that section. The pill turns **cyan** and the controls appear below.

### **Step 3: Adjust sliders**
- Drag sliders to change values
- **Changes apply instantly** to the game (live preview!)
- Current value shown on the right
- Use reset buttons if you get lost

### **Step 4: Switch sections**
- Tap a **different pill** to switch sections
- Only that section's controls show
- Previous section collapses automatically

### **Step 5: Generate code**
1. When happy with your changes, tap **"Generate Code"** (top-right)
2. Code appears in a sheet
3. **Automatically copied to clipboard**
4. You can also select/copy from the text view
5. Tap **"Close"** to go back

### **Step 6: Paste values**
1. Close the layout editor
2. Open `PotionShopGameView.swift` in Xcode
3. Find the relevant section (code has comments)
4. Paste the generated values

---

## 📋 What Each Section Controls

### **📏 Section Heights**
Controls vertical space allocation (percentages):
- Header (1% default)
- Scene (26.3% default)
- Profile Row (9.5% default)
- Cauldron (37.2% default)
- Preview Bar (3.2% default)
- Dice Tray (19.3% default)

**Total percentage shown** - turns RED if over 100%

### **🧙 Ednar Art**
Controls Ednar's character image:
- Uniform Scale (overall size)
- Width Scale (independent horizontal stretch)
- Height Scale (independent vertical stretch)
- X Position (horizontal offset)
- Y Position (vertical offset)

**Buttons:** "Reset Position", "Reset Scale"

### **🍲 Cauldron Art**
Same controls as Ednar:
- Uniform/Width/Height scales
- X/Y positions
- Reset buttons

### **🥘 Cauldron Bowl**
Controls the parametric bowl shape:
- Scale (overall size)
- X Offset (horizontal shift)
- Y Offset (vertical shift)

**Button:** "Reset"

### **🎲 Dice & Tray**
Controls dice size and tray position:
- Die Scale (how big dice appear)
- Tray X Offset (move tray left/right)
- Tray Y Offset (move tray up/down)

**Button:** "Reset"

### **🥄 Brew Tap Zone**
Controls invisible tap area for brewing:
- X Position (0.0-1.0 fraction)
- Y Position (0.0-1.0 fraction)
- Width (50-300 pts)
- Height (50-300 pts)
- **Toggle:** "Show Debug Zone" (yellow rectangle)

**Button:** "Reset"

---

## 🎨 UI Features

### **Section Pills (Top Bar)**
- **Inactive pill:** Cyan border, transparent fill
- **Active pill:** Solid cyan fill, white text
- **Smooth animation:** Spring animation when switching
- **Horizontal scroll:** Swipe if all pills don't fit

### **Controls Area**
- **Empty state:** Shows "Select a section above to edit" with icon
- **Active section:** Shows only that section's sliders
- **Clean layout:** No clutter, easy to read
- **Immediate feedback:** Values update as you drag

### **Toolbar**
- **Left:** "Close" button (returns to debug menu)
- **Right:** "Generate Code" button
- **Title:** "Layout Editor"

---

## 🔧 Testing Steps in Xcode

1. **Build and run** (Command+R)
2. **Launch the game** from selector
3. **Tap gear icon** (⚙️)
4. **Tap "Layout Editor"**
5. **Tap "🧙 Ednar Art" pill**
6. **Drag "Width Scale" slider** to 2.0
7. **Watch Ednar stretch wide** (live preview!)
8. **Tap "🍲 Cauldron Art" pill**
9. **Verify Ednar section collapsed**
10. **Verify only cauldron controls showing**
11. **Tap "Generate Code"**
12. **Verify code appears and is copied**

---

## ✨ Benefits

✅ **Cleaner interface** - Only see what you're editing  
✅ **Faster navigation** - One tap to switch sections  
✅ **Less scrolling** - No need to scroll past other sections  
✅ **Visual clarity** - Active section is clearly highlighted  
✅ **Easier to focus** - No distractions from other controls  
✅ **Live preview** - See changes instantly  
✅ **Code generation** - Copy-paste ready Swift code  

---

## 🗑️ Files You Can Delete

Once this editor is working:
- ❌ `PotionShopLayoutEditorView.swift` (old collapsible editor)

Everything is now in `PotionShopDebugMenu.swift` (self-contained).

---

**END OF GUIDE**
