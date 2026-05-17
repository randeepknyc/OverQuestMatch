# Queue Permutation System - Custom Spacing for 3-Character Arrangements

**Created:** May 16, 2026  
**Status:** ✅ IMPLEMENTED  
**Purpose:** Prevent character overlaps by defining custom X/Y positions for specific 3-character arrangements

---

## 🎯 What Problem Does This Solve?

When you have 3 characters in the Evening round (Wendelina, Crispin, Ardo), they might overlap with each other because:
- Each character has different widths (some are wider than others)
- The default spacing (48%, 68%, 88%) might not work for all combinations
- Different characters in different queue positions create different layouts

**This system lets you define custom spacing for ANY specific arrangement of 3 characters.**

---

## 🧩 How It Works

### **Key Concept: Permutations**

A "permutation" is a specific arrangement of 3 characters in queue order:
- `["wendelina", "crispin", "ardo"]` = Wendelina at front, Crispin in middle, Ardo at back
- `["crispin", "wendelina", "ardo"]` = Different permutation (Crispin at front now)

**Each permutation can have custom:**
- **X positions** (horizontal spacing as % of scene width, 0.0 to 1.0)
- **Y positions** (vertical positioning as % of scene height, 0.0 to 1.0)
- **Scale overrides** (optional: make specific spots bigger/smaller)

**If no custom permutation is defined, falls back to defaults:**
- X: [0.48, 0.68, 0.88] (queue[0], queue[1], queue[2])
- Y: [0.48, 0.55, 0.55]
- Scale: [1.0, 1.0, 1.0]

---

## 📱 How to Use It (Step-by-Step in Xcode)

### **Option 1: Quick Presets (In Debug Menu)**

**Best for:** Quick testing during gameplay

**Steps:**
1. **Build and run** the game (Command+R)
2. **Navigate to Evening round:** Tap ⚙️ (gear icon) → "Skip to Round" → "Round 3 – Evening"
3. **Open debug menu again:** Tap ⚙️
4. **Scroll to "🎭 Queue Permutations" section**
5. **You'll see:**
   - Current arrangement: "wendelina → crispin → ardo"
   - Three buttons:
     - **"Use Wider Spacing"** (40% → 65% → 90%) - More spread out
     - **"Use Tighter Spacing"** (50% → 70% → 85%) - Closer together
     - **"Reset to Default Spacing"** (48% → 68% → 88%) - Back to normal
6. **Tap "Use Wider Spacing"**
7. **Close debug menu** (tap "Done")
8. **Characters now use wider spacing!** (Instantly, no restart needed)

**To test different arrangements:**
- Tap a customer's profile button to swap them to front
- Open debug menu again → New permutation buttons appear for the new arrangement
- Apply spacing preset
- Close and watch the new spacing

---

### **Option 3: Visual Layout Editor (NEW - May 17, 2026)**

**Best for:** Real-time visual adjustment with instant preview

**Steps:**

1. **Build and run** the game (Command+R)

2. **Navigate to Evening round:** ⚙️ → "Round 3 – Evening" (or any 3-character round)

3. **Open layout editor:** ⚙️ → "Layout Editor (Live Overlay)"

4. **Tap the 🎭 Permutations pill** in the horizontal scrolling section picker

5. **The permutation editor appears:**
   - **Current arrangement** shown at top (e.g., "wendelina → crispin → ardo")
   - **Horizontal Spacing (X Positions)** section with 3 green sliders:
     - queue[0]: Left/right position for active customer (0.0 to 1.0)
     - queue[1]: Left/right position for first waiting customer
     - queue[2]: Left/right position for second waiting customer
   - **Vertical Positioning (Y Positions)** section with 3 blue sliders:
     - queue[0]: Up/down position for active customer (0.0 to 1.0)
     - queue[1]: Up/down position for first waiting customer
     - queue[2]: Up/down position for second waiting customer
   - **Scale Overrides** section (optional purple toggle + sliders):
     - Enable to make specific queue positions bigger/smaller
     - queue[0], queue[1], queue[2] scale multipliers (0.5× to 2.0×)
   - **Quick Presets** buttons:
     - **Wider** (40%, 65%, 90%) - Green button
     - **Tighter** (50%, 70%, 85%) - Blue button
     - **Reset** (back to defaults) - Orange button
   - **Current Values Summary** box shows exact numbers

6. **Drag sliders to adjust:**
   - **Characters move in real-time** as you drag!
   - **Green sliders** control horizontal spacing (left/right)
   - **Blue sliders** control vertical positioning (up/down)
   - **Purple sliders** (if enabled) control individual sizes

7. **Watch the preview:**
   - Game view updates instantly behind the overlay
   - See exactly how characters are positioned
   - No need to close editor or rebuild!

8. **Test different arrangements:**
   - Close editor (tap X or background)
   - Tap a profile button to swap queue
   - Reopen editor → New arrangement sliders appear!
   - Adjust spacing for the new permutation

9. **Quick presets:**
   - **Wider** = Characters further apart (good for wide characters)
   - **Tighter** = Characters closer together (good for thin characters)
   - **Reset** = Back to default [0.48, 0.68, 0.88]

**Pro Tips:**
- **Start with Quick Presets** then fine-tune with sliders
- **Use X sliders first** (most common adjustment)
- **Y sliders** useful for creating diagonal line effects
- **Scale Overrides** make waiting customers smaller (depth effect)
- **Close editor** to test gameplay with new spacing
- **Values persist** until you reset or restart app

---

**Best for:** Permanent changes, exact positioning

**Example: Custom Evening Round Spacing**

**Steps:**

1. **Open PotionShopLayoutConfig.swift** in Xcode:
   - Left sidebar → PotionShop folder → PotionShopLayoutConfig.swift

2. **Find the `init()` method** (around line 270)

3. **Add custom permutation code AFTER** `private init() {}`

**Example Code:**
```swift
private init() {
    // Add custom permutations here after initialization
    
    // Evening round: Wendelina-Crispin-Ardo
    // Wider spacing to prevent Wendelina's wide stance from overlapping Crispin
    addPermutation(
        for: ["wendelina", "crispin", "ardo"],
        xPositions: [0.38, 0.65, 0.92],  // Wendelina further left, Ardo further right
        yPositions: [0.48, 0.55, 0.55]   // Same Y as default
    )
    
    // Alternative: if Crispin is at front instead
    addPermutation(
        for: ["crispin", "wendelina", "ardo"],
        xPositions: [0.42, 0.68, 0.90],  // Slightly different spacing
        yPositions: [0.48, 0.55, 0.55]
    )
}
```

4. **Save the file** (Command+S)

5. **Build and run** (Command+R)

6. **Navigate to Evening round** → Characters now use your custom spacing!

---

## 🎨 Position Values Guide

### **X Positions (Horizontal Spacing)**

Values are **fractions of scene width** (0.0 to 1.0):
- **0.0** = Far left edge of scene
- **0.5** = Center of scene
- **1.0** = Far right edge of scene

**Typical ranges:**
- **queue[0] (active):** 0.35 to 0.50 (left side, near Ednar)
- **queue[1] (waiting 1):** 0.60 to 0.75 (middle)
- **queue[2] (waiting 2):** 0.80 to 0.95 (right side)

**Examples:**
- `[0.40, 0.65, 0.90]` = Wide spacing (50% apart, 25% apart)
- `[0.48, 0.68, 0.88]` = Default spacing (20% apart each)
- `[0.50, 0.70, 0.85]` = Tight spacing (20% apart, 15% apart)
- `[0.35, 0.60, 0.90]` = Very wide (25% apart, 30% apart)

### **Y Positions (Vertical Positioning)**

Values are **fractions of scene height** (0.0 to 1.0):
- **0.0** = Top of scene
- **0.5** = Middle of scene
- **1.0** = Bottom of scene

**Typical ranges:**
- **queue[0] (active):** 0.45 to 0.52 (slightly higher for prominence)
- **queue[1] (waiting 1):** 0.52 to 0.58 (middle)
- **queue[2] (waiting 2):** 0.52 to 0.58 (same as waiting 1)

**Examples:**
- `[0.48, 0.55, 0.55]` = Default (active slightly higher)
- `[0.45, 0.55, 0.58]` = Active highest, waiting 2 lowest (diagonal line effect)
- `[0.50, 0.50, 0.50]` = All same height (flat line)

### **Scale Overrides (Optional)**

Values are **multipliers** (0.5 to 2.0):
- **1.0** = Normal size (100%)
- **0.8** = 80% size (smaller)
- **1.2** = 120% size (bigger)

**Example:**
```swift
addPermutation(
    for: ["wendelina", "crispin", "ardo"],
    xPositions: [0.40, 0.65, 0.90],
    yPositions: [0.48, 0.55, 0.55],
    scaleOverrides: [1.0, 0.85, 0.75]  // Active normal, waiting 1 smaller, waiting 2 smallest
)
```

---

## 🔍 Finding the Right Values

### **Method 1: Trial and Error (Quickest)**

1. **Start with default:** [0.48, 0.68, 0.88]
2. **If characters overlap on the left:** Decrease queue[0] (e.g., 0.48 → 0.42)
3. **If characters overlap on the right:** Increase queue[2] (e.g., 0.88 → 0.92)
4. **If middle character overlaps both:** Adjust queue[1] (e.g., 0.68 → 0.65 or 0.70)
5. **Test by building and running** (Command+R)

### **Method 2: Presets (Easiest)**

Use the debug menu quick presets:
- **Wider Spacing:** [0.40, 0.65, 0.90] - Good for wide characters
- **Tighter Spacing:** [0.50, 0.70, 0.85] - Good for thin characters
- **Default:** [0.48, 0.68, 0.88] - Balanced

### **Method 3: Per-Character Adjustment (Most Precise)**

1. Use the existing **Layout Editor** (⚙️ → "Layout Editor (Live Overlay)")
2. Go to **🧍 Customers** section
3. Select character from dropdown
4. Adjust **X position sliders** for active/waiting/waiting2
5. These offsets **stack with** permutation positions
6. **Result:** Base permutation position + per-character offset = final position

---

## 🧪 Testing Different Arrangements

### **Test All 6 Permutations of Evening Round**

The Evening round has 3 characters (Wendelina, Crispin, Ardo) which can be arranged 6 ways:

**To test all arrangements:**

1. **Load Evening round:** ⚙️ → Skip to Round → Round 3
2. **Default arrangement:** Wendelina at front
   - Check for overlaps
   - If overlap, add permutation for ["wendelina", "crispin", "ardo"]
3. **Tap Crispin's profile** → Crispin moves to front
   - Check for overlaps
   - If overlap, add permutation for ["crispin", "wendelina", "ardo"]
4. **Tap Ardo's profile** → Ardo moves to front
   - Check for overlaps
   - If overlap, add permutation for ["ardo", "crispin", "wendelina"]
5. **Continue swapping and testing** all 6 combinations

**Pro tip:** Only define permutations that actually have overlaps. Most arrangements will be fine with defaults!

---

## 🛠️ Troubleshooting

### **Problem: Changes don't appear after adding permutation**

**Solution:**
1. Make sure you're testing the **exact character arrangement** you defined
2. Character order matters! ["wendelina", "crispin", "ardo"] ≠ ["crispin", "wendelina", "ardo"]
3. Check spelling: character IDs are lowercase (e.g., "wendelina" not "Wendelina")

### **Problem: Characters still overlap after custom spacing**

**Solutions:**
1. **Increase spacing:** Make X positions further apart
   - Example: [0.40, 0.65, 0.90] → [0.35, 0.65, 0.95]
2. **Use per-character X offsets:** Some characters might be wider/taller
   - Layout Editor → 🧍 Customers → Select character → Adjust X position
3. **Use scale overrides:** Make waiting characters smaller
   - `scaleOverrides: [1.0, 0.85, 0.75]`

### **Problem: I want to remove a permutation**

**Method 1: Debug Menu**
- ⚙️ → 🎭 Queue Permutations → "Reset to Default Spacing"

**Method 2: Code**
```swift
// In PotionShopLayoutConfig.swift init()
removePermutation(for: ["wendelina", "crispin", "ardo"])
```

### **Problem: I want to see all active permutations**

**Debug Menu:**
- ⚙️ → Scroll to bottom of "🎭 Queue Permutations" section
- Footer shows: "Active: wendelina_crispin_ardo, crispin_wendelina_ardo"

**Code:**
```swift
let active = PotionShopLayoutConfig.shared.listPermutations()
print("Active permutations: \(active)")
```

---

## 📋 Quick Reference: Evening Round Permutations

Copy-paste these into `PotionShopLayoutConfig.swift` `init()` method:

```swift
// Evening Round: All 6 possible arrangements with wider spacing

// 1. Wendelina at front (default spawn order)
addPermutation(
    for: ["wendelina", "crispin", "ardo"],
    xPositions: [0.38, 0.65, 0.92]
)

// 2. Crispin at front
addPermutation(
    for: ["crispin", "wendelina", "ardo"],
    xPositions: [0.42, 0.68, 0.90]
)

// 3. Ardo at front
addPermutation(
    for: ["ardo", "wendelina", "crispin"],
    xPositions: [0.45, 0.68, 0.88]
)

// 4. Wendelina-Ardo-Crispin
addPermutation(
    for: ["wendelina", "ardo", "crispin"],
    xPositions: [0.38, 0.65, 0.88]
)

// 5. Crispin-Ardo-Wendelina
addPermutation(
    for: ["crispin", "ardo", "wendelina"],
    xPositions: [0.42, 0.65, 0.92]
)

// 6. Ardo-Crispin-Wendelina
addPermutation(
    for: ["ardo", "crispin", "wendelina"],
    xPositions: [0.45, 0.68, 0.92]
)
```

---

## 🎯 Best Practices

### ✅ DO:
- Test the most common arrangement first (default spawn order)
- Only add permutations that actually need custom spacing
- Use debug menu quick presets for rapid testing
- Document why you chose specific spacing values (add comments)
- Start with small adjustments (±0.05) and iterate

### ❌ DON'T:
- Define permutations for arrangements that work fine with defaults
- Make X positions overlap (queue[0] > queue[1] or queue[1] > queue[2])
- Use extreme Y values (<0.3 or >0.7) - characters might go off-screen
- Forget to test after queue swaps (arrangement changes → spacing changes)
- Hardcode values without comments (you'll forget what they mean later)

---

## 🔮 Future Enhancements (Possible)

**✅ IMPLEMENTED (May 17, 2026):**

1. **✅ Layout editor UI for permutation adjustment (visual sliders)** - Complete with:
   - Real-time X/Y position sliders for all 3 queue spots
   - Optional scale override toggles
   - Quick preset buttons (Wider, Tighter, Reset)
   - Live value display with color-coded labels
   - Only visible in 3-character rounds (Evening)
   - Auto-updates as you drag sliders (instant preview!)

**Still possible (not yet implemented):**

2. **Per-permutation Y offsets** for height variations ← (Already supported in UI!)
3. **Dynamic spacing** based on character widths (auto-calculate)
4. **Permutation presets** for all rounds (Morning, Afternoon, Evening, Night)
5. **Save/load permutation configs** as JSON files
6. **Preview mode** showing all 6 permutations side-by-side

---

## 📝 Summary

**What you can do now:**
- ✅ Define custom X/Y positions for any 3-character arrangement
- ✅ Use quick presets in debug menu (wider/tighter spacing)
- ✅ **Use visual layout editor with real-time sliders** ← NEW (May 17, 2026)
- ✅ Test arrangements by swapping queue order
- ✅ Remove custom permutations to return to defaults
- ✅ Stack with per-character offsets from layout editor
- ✅ Optional scale overrides to make specific spots bigger/smaller

**Three ways to adjust spacing:**
1. **Debug Menu Presets** - Quickest for testing (⚙️ → 🎭 Queue Permutations)
2. **Manual Code** - Permanent changes in `PotionShopLayoutConfig.swift` init()
3. **Visual Layout Editor** - Real-time sliders with instant preview (⚙️ → Layout Editor → 🎭 Permutations)

**Files modified:**
- `PotionShopLayoutConfig.swift` - Added permutation system + helper methods
- `PotionShopCustomerSceneView.swift` - Updated positioning to check permutations first
- `PotionShopDebugMenu.swift` - Added "🎭 Queue Permutations" section
- `PotionShopGameView.swift` - Added 🎭 Permutations section to layout editor overlay ← NEW (May 17, 2026)

**Result:** No more character overlaps! Every arrangement can have perfect spacing with real-time visual adjustment! 🎨✨

---

**END OF GUIDE**
