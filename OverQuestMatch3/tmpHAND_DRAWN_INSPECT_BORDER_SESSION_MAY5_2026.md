# HAND-DRAWN INSPECT STRIP BORDER
**Session Date:** May 5, 2026  
**Status:** PLANNED - Design Option for Inspect Strip  
**Context:** Ednar's Potion Cauldron - Custom artwork for inspect strip border

---

## 📋 USER QUESTION

> "if i want to change the border of the inspect strip into a hand drawn element, is that possible"

**Answer:** YES! Absolutely possible! 🎨

You can replace the programmatic `RoundedRectangle` border with a custom hand-drawn PNG image.

---

## 🎨 HOW IT WORKS

### **Current System (Programmatic):**
```swift
// In PotionShopInspectStripView
RoundedRectangle(cornerRadius: 16)
    .fill(Color.white.opacity(0.85))
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .stroke(PotionShopTheme.accent, lineWidth: 2)  // ← Programmatic border
    )
```

### **New System (Hand-Drawn Image):**
```swift
// Background layer with hand-drawn border
if let borderImage = UIImage(named: "inspect_border") {
    Image(uiImage: borderImage)
        .resizable()
        .frame(width: inspectWidth, height: inspectHeight)
} else {
    // Fallback to programmatic border
    RoundedRectangle(cornerRadius: 16)
        .stroke(PotionShopTheme.accent, lineWidth: 2)
}
```

---

## 📐 ART SPECIFICATIONS

### **Image Requirements:**

**Filename:** `inspect_border.png`

**Size Recommendations:**
- **Width:** ~800-1000 px (will scale to fit screen width minus padding)
- **Height:** ~150-200 px (inspect strip is ~64pt tall = ~192px @3x)
- **DPI:** 300 DPI
- **Format:** PNG with transparency

**What to Draw:**
- Hand-drawn rounded rectangle border
- Leave the **CENTER TRANSPARENT** (content shows through)
- Draw decorative edges, corners, flourishes
- Can be asymmetric, wavy, sketchy - whatever style you want!

**Color:**
- Your hand-drawn accent color (brown/tan/gold to match theme)
- Can have multiple colors/shading

---

## 🎨 DESIGN APPROACH OPTIONS

### **Option 1: Border Only (Transparent Center)**
```
┌────────────────────────────────┐
│ ╔═══════════════════════════╗  │
│ ║                           ║  │ ← Hand-drawn wavy border
│ ║  (transparent center)     ║  │    Content shows through here
│ ║                           ║  │
│ ╚═══════════════════════════╝  │
└────────────────────────────────┘
```

**Use Case:** Just want custom border, keep programmatic background fill

---

### **Option 2: Border + Background Fill**
```
┌────────────────────────────────┐
│ ╔═══════════════════════════╗  │
│ ║▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒║  │ ← Hand-drawn border
│ ║▒▒ (semi-transparent) ▒▒▒▒▒║  │    + parchment fill
│ ║▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒║  │
│ ╚═══════════════════════════╝  │
└────────────────────────────────┘
```

**Use Case:** Complete custom background (texture + border in one image)

---

### **Option 3: Decorative Corners Only**
```
┌────────────────────────────────┐
│ ╔═╗                     ╔═╗    │ ← Ornate corners
│ ║                         ║    │    (programmatic lines between)
│                               │
│ ╚═╝                     ╚═╝    │
└────────────────────────────────┘
```

**Use Case:** Keep simple edges, add fancy corners

---

## 🔧 IMPLEMENTATION OPTIONS

### **A. Simple Swap (Border Only)**

Replace the entire border with your image.

**Pros:**
- ✅ Easiest to implement
- ✅ Full artistic control

**Cons:**
- ⚠️ Need to draw at correct aspect ratio

---

### **B. 9-Slice (Stretchable Borders)**

Use SwiftUI's `.resizable(capInsets:)` to make edges stretchable.

**Pros:**
- ✅ Adapts to different screen sizes
- ✅ Corners stay sharp

**Cons:**
- ⚠️ Slightly more complex art setup

**How 9-Slice Works:**
```
┌─────────────────────────────────┐
│  50px │         │  50px         │
├───────┼─────────┼───────────────┤
│       │         │               │ ← Top 50px: Fixed
│  TL   │   Top   │      TR       │
│       │ (stretch)│               │
├───────┼─────────┼───────────────┤
│       │         │               │
│ Left  │ Center  │     Right     │ ← Middle: Stretches both ways
│(stretch) (stretch)   (stretch)  │
├───────┼─────────┼───────────────┤
│       │         │               │
│  BL   │ Bottom  │      BR       │ ← Bottom 50px: Fixed
│       │ (stretch)│               │
└───────┴─────────┴───────────────┘
   50px      │       50px
```

**Result:** Corners stay crisp, edges stretch to fit content

---

### **C. Layered (Background + Border Separate)**

Two images: one for fill, one for border.

**Pros:**
- ✅ Can animate background separately
- ✅ Easy to swap border style

**Cons:**
- ⚠️ Two art files instead of one

---

## 📝 RECOMMENDED APPROACH

**Use Option A (Simple Swap) with 9-Slice for adaptability.**

### **Art Setup in Procreate:**

1. **Canvas:** 1000×200 px @ 300 DPI
2. **Draw border:** Rounded rectangle with hand-drawn edges
3. **Center area:** Keep transparent (or fill with parchment color)
4. **Corner decorations:** Add flourishes, but keep them inside 50px from edges
5. **Export:** PNG with transparency

### **Asset Setup in Xcode:**

1. Drag `inspect_border.png` into Assets.xcassets
2. Select the image
3. In Attributes Inspector → **Slicing:**
   - Horizontal: Left 50, Right 50
   - Vertical: Top 50, Bottom 50
   - This makes corners fixed, edges stretchable

---

## 💻 CODE CHANGES

### **File to Modify:**

**PotionShopCustomerSceneView.swift** (specifically `PotionShopInspectStripView`)

---

### **BEFORE (Current - Programmatic Border):**

```swift
struct PotionShopInspectStripView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer

    @State private var isExpanded: Bool = false

    // ... helper properties ...

    var body: some View {
        if let char = char {
            ZStack {
                // Programmatic background + border
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(PotionShopTheme.accent, lineWidth: 2)  // ← PROGRAMMATIC BORDER
                    )
                    .opacity(isExpanded ? 1.0 : 0.0)

                // Content (portrait, name, brew target)
                HStack(spacing: 14) {
                    portraitView(char: char)
                        .offset(x: isExpanded ? 0 : 40)
                        .opacity(isExpanded ? 1.0 : 0.0)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(char.name)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                        // ... subtitle ...
                    }
                    .offset(x: isExpanded ? 0 : -40)
                    .opacity(isExpanded ? 1.0 : 0.0)

                    Spacer()

                    // Brew target pill
                    // ...
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    gs.dismissInspect()
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                    isExpanded = true
                }
            }
        }
    }
}
```

---

### **AFTER (With Hand-Drawn Border - Simple Version):**

```swift
struct PotionShopInspectStripView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer

    @State private var isExpanded: Bool = false

    // ... helper properties ...

    var body: some View {
        if let char = char {
            ZStack {
                // Background fill (keep programmatic for consistency)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.85))
                    .opacity(isExpanded ? 1.0 : 0.0)
                
                // Hand-drawn border overlay
                if let borderImage = UIImage(named: "inspect_border") {
                    Image(uiImage: borderImage)
                        .resizable()
                        .opacity(isExpanded ? 1.0 : 0.0)
                } else {
                    // Fallback: programmatic border
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(PotionShopTheme.accent, lineWidth: 2)
                        .opacity(isExpanded ? 1.0 : 0.0)
                }

                // Content (portrait, name, brew target)
                HStack(spacing: 14) {
                    portraitView(char: char)
                        .offset(x: isExpanded ? 0 : 40)
                        .opacity(isExpanded ? 1.0 : 0.0)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(char.name)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                        // ... subtitle ...
                    }
                    .offset(x: isExpanded ? 0 : -40)
                    .opacity(isExpanded ? 1.0 : 0.0)

                    Spacer()

                    // Brew target pill
                    // ...
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    gs.dismissInspect()
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                    isExpanded = true
                }
            }
        }
    }
}
```

**Changes:**
1. ✅ Kept background fill (programmatic)
2. ✅ Replaced `.stroke()` with image overlay
3. ✅ Added fallback to programmatic border if image not found

---

### **AFTER (With 9-Slice Stretchable Border):**

```swift
// Hand-drawn border overlay with 9-slice
if let borderImage = UIImage(named: "inspect_border") {
    Image(uiImage: borderImage)
        .resizable(capInsets: EdgeInsets(
            top: 50,       // Top 50px fixed
            leading: 50,   // Left 50px fixed
            bottom: 50,    // Bottom 50px fixed
            trailing: 50   // Right 50px fixed
        ))
        .opacity(isExpanded ? 1.0 : 0.0)
} else {
    // Fallback: programmatic border
    RoundedRectangle(cornerRadius: 16)
        .stroke(PotionShopTheme.accent, lineWidth: 2)
        .opacity(isExpanded ? 1.0 : 0.0)
}
```

**Benefits:**
- ✅ Border adapts to different screen sizes
- ✅ Corners stay sharp and detailed
- ✅ Edges stretch smoothly

---

### **ALTERNATIVE: Replace ENTIRE Background**

If you want to draw the **ENTIRE inspect strip** (background + border + decorations):

**Art Specs:**
- Full inspect strip design (background + border + optional decorations)
- Size: 1000×200 px
- Include parchment texture, border, corner flourishes, everything!

**Code:**
```swift
ZStack {
    // Replace entire background with single image
    if let inspectBg = UIImage(named: "inspect_strip_bg") {
        Image(uiImage: inspectBg)
            .resizable(capInsets: EdgeInsets(top: 50, leading: 50, bottom: 50, trailing: 50))
            .opacity(isExpanded ? 1.0 : 0.0)
    } else {
        // Fallback
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.85))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(PotionShopTheme.accent, lineWidth: 2)
            )
            .opacity(isExpanded ? 1.0 : 0.0)
    }
    
    // Content on top (unchanged)
    HStack(spacing: 14) {
        // ... (portrait, name, brew target)
    }
}
```

---

## 🖼️ PROCREATE WORKFLOW

### **Step-by-Step Drawing Guide:**

#### **1. Create Canvas**
- **Size:** 1200×250 px (gives buffer for 9-slice)
- **DPI:** 300
- **Background:** Transparent

#### **2. Add Guide Layers (Temporary)**
- Draw 4 vertical lines at 50px, 250px, 950px, 1150px (marks 9-slice zones)
- Draw 2 horizontal lines at 50px, 200px (marks top/bottom zones)
- Make guides layer invisible before export

#### **3. Draw Border**
- **Tool:** Ink brush / Calligraphy brush
- **Color:** Brown/tan/gold (match PotionShopTheme.accent)
- **Style:** Wavy edges, hand-drawn, organic
- **Important:** Keep decorative elements INSIDE the guide lines (50px margins)

#### **4. Add Corner Flourishes**
- Small scrollwork, dots, or decorative elements
- Keep within 50px×50px corner zones
- These will NOT stretch (good for detail)

#### **5. Add Background Fill (Optional)**
```
Option A: Transparent center
- Border only, content shows through programmatic background

Option B: Parchment texture
- Add cream/tan gradient or texture
- Keep semi-transparent (85% opacity)
- Allows text to show clearly
```

#### **6. Export**
- **Format:** PNG
- **Steps:**
  1. Hide guide layer
  2. File → Share → PNG
  3. **CRITICAL:** If background is transparent, toggle OFF the "Background" layer
  4. Save to Files → Name: `inspect_border.png`

---

## 📐 SIZING GUIDE

### **Inspect Strip Dimensions:**

The inspect strip is:
- **Height:** ~64pt in code
- **Width:** Screen width minus 24pt padding (≈ ~360pt on iPhone)

**At @3x resolution (iPhone):**
- Height: 64pt × 3 = 192 px
- Width: 360pt × 3 = 1080 px

**Recommended canvas size:** 1200×250 px (gives buffer for 9-slice + different devices)

---

### **9-Slice Zone Breakdown:**

For 1200×250 canvas with 50px margins:

```
┌──────┬────────────────┬──────┐
│  TL  │      Top       │  TR  │ ← 50px tall (fixed)
│ 50×50│   1100×50      │ 50×50│
├──────┼────────────────┼──────┤
│      │                │      │
│ Left │     Center     │ Right│ ← 150px tall (stretches)
│50×150│  1100×150      │50×150│
│      │                │      │
├──────┼────────────────┼──────┤
│  BL  │    Bottom      │  BR  │ ← 50px tall (fixed)
│ 50×50│   1100×50      │ 50×50│
└──────┴────────────────┴──────┘
  50px      1100px       50px
 (fixed)  (stretches)   (fixed)
```

**What to keep in each zone:**
- **Corners (TL, TR, BL, BR):** Decorative elements (NEVER stretch)
- **Edges (Top, Bottom, Left, Right):** Simple patterns or solid lines (stretch horizontally or vertically)
- **Center:** Background fill or transparent (stretches both ways)

---

## ✅ TESTING WORKFLOW

### **Phase 1: Test with Placeholder**

1. **Quick Test Border:**
   - Draw simple wavy rectangle in Procreate
   - Export as `inspect_border_test.png`

2. **Add to Xcode:**
   - Drag into Assets.xcassets
   - Name it `inspect_border_test`

3. **Update Code:**
   ```swift
   if let borderImage = UIImage(named: "inspect_border_test") {
   ```

4. **Run Game:**
   - Tap any profile button
   - Inspect strip opens
   - **Check:** Does hand-drawn border show?
   - **Check:** Is it the right size?

5. **Test on Different Devices:**
   - iPhone SE (small screen)
   - iPhone Pro Max (large screen)
   - **Check:** Does 9-slice stretch correctly?

---

### **Phase 2: Refine Art**

1. Based on test, adjust:
   - Border thickness
   - Corner decorations
   - Color/opacity

2. Re-export and test again

3. When satisfied, rename to `inspect_border.png`

---

## 🎨 STYLE RECOMMENDATIONS

### **Match the Game Theme:**

The game has a warm, parchment, hand-drawn aesthetic:
- **Colors:** Browns, tans, golds, creams
- **Style:** Organic, sketchy, not too perfect
- **Decorations:** Simple flourishes (not over-decorated)

### **Example Style Directions:**

**Option A: Medieval Manuscript**
- Thick brown border
- Gold corner flourishes
- Simple geometric patterns

**Option B: Tavern Sign**
- Rough wooden frame look
- Nail heads at corners
- Weathered texture

**Option C: Potion Label**
- Decorative scroll corners
- Thin elegant lines
- Alchemical symbols

---

## 🚨 COMMON ISSUES & SOLUTIONS

### **Problem 1: Border Too Thick**

**Symptom:** Border covers text/content

**Solution:** 
- Draw thinner border (10-20px line width)
- Or increase canvas size to 1400×300px

---

### **Problem 2: Corners Stretch Weirdly**

**Symptom:** Corner decorations look distorted on different screen sizes

**Cause:** Didn't set up 9-slice correctly

**Solution:**
1. In Xcode, select `inspect_border` in Assets
2. Attributes Inspector → Slicing
3. Set all margins to 50px
4. Preview in different device sizes

---

### **Problem 3: Border Doesn't Show**

**Symptom:** Still seeing programmatic border

**Causes:**
1. Image not added to Assets
2. Wrong filename (case-sensitive!)
3. Wrong Target Membership

**Solution:**
1. Check Assets.xcassets has `inspect_border`
2. Verify exact name (no `.png` in code)
3. Select image → File Inspector → Target Membership: OverQuestMatch3 ✓

---

### **Problem 4: Background Visible Instead of Transparent**

**Symptom:** White/colored background shows behind border

**Cause:** Didn't turn off background layer in Procreate before export

**Solution:**
1. In Procreate, toggle OFF "Background" layer
2. Re-export PNG
3. Replace in Assets.xcassets

---

## 📖 ASSET CATALOG ADDITIONS

### **New Assets Needed:**

**For Border-Only Approach:**
```
✓ inspect_border.png (1200×250 px)
  - Hand-drawn border frame
  - Transparent center
  - Optional: parchment fill
```

**For Full Background Approach:**
```
✓ inspect_strip_bg.png (1200×250 px)
  - Complete inspect strip design
  - Border + background + decorations
  - Replaces both fill and stroke
```

---

## 🔄 CONTEXT FILE UPDATES

After implementing this feature, update:

### **CAULDRON_CONTEXT.md:**

**Section 16.1 (Asset List):**
```markdown
| Category               | Count | Procreate canvas | Notes                                                    |
|------------------------|-------|------------------|----------------------------------------------------------|
| UI frames              | 1     | 1200×250 px @ 300 DPI | Inspect strip border (9-slice). Transparent BG. ← ADD THIS |
```

**Section 16.3 (Filename List):**
```markdown
inspect_border.png  ← Inspect strip hand-drawn border (optional, falls back to programmatic)
```

---

### **Phase History (Section 13):**

Add new phase entry:
```markdown
| Phase | Title                                | Status | Notes                                                  |
|-------|--------------------------------------|--------|--------------------------------------------------------|
| **7i** | **Hand-drawn inspect border (May 5)** | 🎨 | **Optional custom art for inspect strip. Replaces programmatic border with hand-drawn PNG. Supports 9-slice stretching. Fallback to programmatic if image missing.** |
```

---

## 🎯 IMPLEMENTATION CHECKLIST

### **Pre-Implementation:**
- [ ] Decide: Border only OR full background?
- [ ] Decide: Use 9-slice stretching?
- [ ] Draw test border in Procreate
- [ ] Export PNG with transparency

### **Xcode Setup:**
- [ ] Add `inspect_border.png` to Assets.xcassets
- [ ] (Optional) Set up 9-slice slicing (50px margins)
- [ ] Verify Target Membership checked

### **Code Changes:**
- [ ] Open `PotionShopCustomerSceneView.swift`
- [ ] Find `PotionShopInspectStripView`
- [ ] Replace programmatic border with image overlay
- [ ] Add fallback to programmatic border
- [ ] Test on device

### **Testing:**
- [ ] Run game
- [ ] Tap profile button → inspect opens
- [ ] Verify border shows
- [ ] Test on different screen sizes
- [ ] Verify content is readable
- [ ] Verify animations still work

### **Polish:**
- [ ] Refine art based on in-game appearance
- [ ] Adjust colors/thickness if needed
- [ ] Update CAULDRON_CONTEXT.md

---

## 🚀 READY TO IMPLEMENT

### **Decision Point:**

**Do you want to implement this now OR defer to later?**

**Option A: Implement Now**
- I'll provide complete updated code for `PotionShopCustomerSceneView.swift`
- Include both simple and 9-slice versions
- Add to DUAL_PORTRAIT_SYSTEM document

**Option B: Defer to Later**
- Keep programmatic border for now
- Add this to "Phase 8 - Art Integration" task list
- Implement when doing all art swaps

---

**END OF HAND-DRAWN BORDER SESSION**

This file documents the conversation about replacing the inspect strip's programmatic border with custom hand-drawn artwork.

