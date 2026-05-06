# FULL BODY CUSTOMERS - REVISION TO DUAL PORTRAIT SYSTEM
**Session Date:** May 5, 2026  
**Status:** ⚠️ NEEDS CODE UPDATE  
**Context:** Ednar's Potion Cauldron - Customer scene shows full-body standing characters (NOT circles)

---

## 📋 REVISED UNDERSTANDING

### **What Was Implemented (INCORRECT):**
```
CUSTOMER SCENE:
┌─────────────────────────────────────┐
│  Ednar    ⭕  ⭕  ⭕                 │  ← Circular portraits
│   🧙      (customers in circles)    │     (WRONG!)
└─────────────────────────────────────┘
```

### **What User Actually Wants (CORRECT):**
```
CUSTOMER SCENE:
┌─────────────────────────────────────┐
│            HP  HP  HP               │  ← Badges ABOVE heads
│            ↓   ↓   ↓                │
│  Ednar    🧍  🧍  🧍               │  ← Full body standing!
│   🧙     (standing/walking)         │     (NO circles!)
│                                     │
│  ════════════════════════           │  ← Floor line
└─────────────────────────────────────┘

PROFILE ROW (Below - Correct):
┌─────────────────────────────────────┐
│     ⭕      ⭕      ⭕              │  ← Circular head closeups
│  (Mildred) (Tomik) (Greta)          │     (this part is RIGHT!)
└─────────────────────────────────────┘
```

---

## ✅ USER DECISIONS (CONFIRMED)

1. **Circles:** Remove completely (no circle backgrounds)
2. **Badges:** Above character heads (floating badges)
3. **Dimensions:** 1024×1536 px is fine (same as planned)
4. **Spacing:** Keep current spacing (no layout changes)

---

## 💻 CODE CHANGES NEEDED

### **File to Modify:**
**PotionShopCustomerSceneView.swift** - Only the `PotionShopCustomerInSceneView` struct

### **Current Code (INCORRECT - Lines ~329-370):**

```swift
var body: some View {
    if let char = char {
        ZStack {
            Circle()  // ← REMOVE THIS
                .fill(Color(red: 0.96, green: 0.92, blue: 0.84))
                .overlay(
                    PotionShopImageLoader.sceneImageOrFallback(
                        sceneAsset: char.scenePortrait,
                        profileAsset: char.portrait,
                        fallbackEmoji: char.iconFallback,
                        size: PotionShopSceneLayout.portraitDiameter * scale
                    )
                )
                .frame(
                    width: PotionShopSceneLayout.portraitDiameter * scale,
                    height: PotionShopSceneLayout.portraitDiameter * scale
                )
                .overlay(
                    Circle()  // ← REMOVE THIS
                        .stroke(PotionShopTheme.ink, lineWidth: dim ? 2 : 3)
                )

            if isActive {
                Text("\(customer.hp)")
                    .font(.system(size: 14 * scale, weight: .bold))
                    .foregroundColor(.white)
                    .frame(
                        width: 26 * scale,
                        height: 26 * scale
                    )
                    .background(Circle().fill(PotionShopTheme.composureBad))
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                    .offset(x: -28 * scale, y: -28 * scale)  // ← WRONG POSITION
                    .transition(.scale.combined(with: .opacity))
            }

            if attack > 0 {
                Text("\(attack)")
                    .font(.system(size: 11 * scale, weight: .bold))
                    .foregroundColor(.white)
                    .frame(
                        width: 22 * scale,
                        height: 22 * scale
                    )
                    .background(Circle().fill(PotionShopTheme.composureBad))
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                    .offset(x: 28 * scale, y: 28 * scale)  // ← WRONG POSITION
            }
```

---

### **New Code (CORRECT):**

```swift
var body: some View {
    if let char = char {
        ZStack {
            // Character image (full body, NO circle!)
            PotionShopImageLoader.sceneImageOrFallback(
                sceneAsset: char.scenePortrait,
                profileAsset: char.portrait,
                fallbackEmoji: char.iconFallback,
                size: PotionShopSceneLayout.portraitDiameter * scale
            )
            
            // HP Badge (ABOVE character's head)
            if isActive {
                Text("\(customer.hp)")
                    .font(.system(size: 14 * scale, weight: .bold))
                    .foregroundColor(.white)
                    .frame(
                        width: 26 * scale,
                        height: 26 * scale
                    )
                    .background(Circle().fill(PotionShopTheme.composureBad))
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                    .offset(x: 0, y: -60 * scale)  // ← ABOVE head (centered horizontally)
                    .transition(.scale.combined(with: .opacity))
            }

            // Attack Badge (ABOVE character's head, offset to right)
            if attack > 0 {
                Text("\(attack)")
                    .font(.system(size: 11 * scale, weight: .bold))
                    .foregroundColor(.white)
                    .frame(
                        width: 22 * scale,
                        height: 22 * scale
                    )
                    .background(Circle().fill(PotionShopTheme.composureBad))
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                    .offset(x: 20 * scale, y: -50 * scale)  // ← ABOVE head (offset right)
            }

            // 💢 emoji burst on expiration (unchanged)
            if PotionShopBrewAnimator.expirationShowEmoji {
                Text(PotionShopBrewAnimator.expirationEmoji)
                    .font(.system(size: 30 * scale))
                    .opacity(emojiOpacity)
                    .offset(x: 20, y: -30 + emojiOffset)
            }
        }
        .opacity(dim ? 0.55 : 1.0)
        .opacity(expireOpacity)
        .scaleEffect(scale * settleBoost)
        .position(x: xPos + shakeOffset + expireSlideX, y: yPos)
        .matchedGeometryEffect(
            id: customer.id,
            in: animationNamespace,
            properties: [.position, .size]
        )
        .animation(
            .spring(response: 0.55, dampingFraction: 0.78),
            value: queueIndex
        )
        // ... rest unchanged (shake/expiration handlers)
    }
}
```

---

## 🔄 WHAT CHANGED

### **Removed:**
1. ❌ `Circle().fill(...)` - Circle background removed
2. ❌ `Circle().stroke(...)` - Circle border removed
3. ❌ `.frame(width: diameter, height: diameter)` - Fixed size removed
4. ❌ `.clipShape(Circle())` - Circle clipping removed

### **Changed:**
1. ✅ Character image now renders at natural aspect ratio (2:3)
2. ✅ HP badge moved to `offset(x: 0, y: -60 * scale)` (above head, centered)
3. ✅ Attack badge moved to `offset(x: 20 * scale, y: -50 * scale)` (above head, right)

### **Unchanged:**
- ✅ Dimming (55% opacity for waiting customers)
- ✅ Scaling (1.0×, 0.78×, 0.72× based on queue position)
- ✅ Position calculations (xPos, yPos)
- ✅ Shake animation
- ✅ Expiration slide-out animation
- ✅ 💢 emoji burst
- ✅ All other gameplay logic

---

## 🎨 ART SPECIFICATIONS (UNCHANGED)

### **Profile Portraits (Head Closeups):**
```
Procreate Canvas: 1024×1024 px @ 300 DPI
Aspect Ratio: 1:1 (square)
Crop: Tight on face/head
Background: Transparent
Safe Zone: Center 80% circle (will be cropped to circle in profile row)
Usage: Profile row buttons + Inspect strip

Files: mildred.png, tomik.png, greta.png, etc. (14 total)
```

### **Scene Portraits (Full Body Standing):**
```
Procreate Canvas: 1024×1536 px @ 300 DPI
Aspect Ratio: 2:3 (portrait orientation)
Crop: Full body or waist-up standing pose
Background: Transparent
Pose: Standing upright (like they're in line at a shop)
Usage: Customer scene (NO circle crop!)

Files: mildred_scene.png, tomik_scene.png, greta_scene.png, etc. (14 total)
```

### **Important Drawing Notes:**
- **No circle safe zone needed!** Full image will be visible
- **Draw characters standing on a "ground"** - bottom of image is their feet
- **Keep head in upper 1/3 of canvas** - leaves room for badges above
- **Transparent background** - characters will overlay on scene background
- **Same style as Ednar** - warm, hand-drawn, parchment aesthetic

---

## 📏 LAYOUT DETAILS

### **Character Sizing:**

The characters will render at:
```
Active customer:    76pt wide × 114pt tall (1.0× scale)
Second customer:    59pt wide × 89pt tall  (0.78× scale)
Third customer:     55pt wide × 82pt tall  (0.72× scale)
```

**Badge Positioning:**
```
HP Badge (active only):
- Position: Centered above head
- Offset: (0, -60 × scale) from character center
- Size: 26pt diameter circle

Attack Badge (all customers):
- Position: Above head, slightly right
- Offset: (20 × scale, -50 × scale) from character center
- Size: 22pt diameter circle
```

---

## 🧪 TESTING CHECKLIST

### **After Code Update:**

1. **Build Project** (Command+B)
2. **Add `mildred_scene.png`** to Assets.xcassets
   - Full body standing Mildred (1024×1536)
   - Transparent background
3. **Run Game** (Command+R)
4. **Navigate to Morning Round** (Mildred + Tomik)

### **Verify:**

**Customer Scene:**
- ✅ Mildred shows full body (not in circle)
- ✅ Tomik shows full body (or head closeup if scene portrait missing)
- ✅ HP badge floats ABOVE Mildred's head (centered)
- ✅ Attack badges float ABOVE both customers' heads (offset right)
- ✅ Badges don't clip or disappear
- ✅ Characters scale correctly (active bigger, waiters smaller)
- ✅ Dimming works (Tomik at 55% opacity)

**Animations:**
- ✅ Queue swap works (characters slide to new positions)
- ✅ Shake animation works (characters shake when hit)
- ✅ Expiration works (customer slides off-screen)
- ✅ Settle bounce works (active customer bounces into position)

**Profile Row (Unchanged):**
- ✅ Circular head closeups still show
- ✅ Patience rings work
- ✅ Tap behavior works (swaps queue)

---

## 🚨 POTENTIAL ISSUES & SOLUTIONS

### **Problem 1: Badges Too High/Low**

**Symptom:** HP/Attack badges don't align well with character heads

**Solution:** Adjust Y offset values:
```swift
// HP Badge - make lower if too high
.offset(x: 0, y: -50 * scale)  // was -60

// Attack Badge - make lower if too high
.offset(x: 20 * scale, y: -40 * scale)  // was -50
```

---

### **Problem 2: Characters Too Big/Small**

**Symptom:** Full body characters are too large or too small

**Solution:** Adjust `portraitDiameter` in `PotionShopSceneLayout`:
```swift
// In PotionShopCustomerSceneView.swift, around line 67
static let portraitDiameter: CGFloat = 100  // was 76 (make bigger)
// or
static let portraitDiameter: CGFloat = 60   // was 76 (make smaller)
```

---

### **Problem 3: Character Image Distorted**

**Symptom:** Full body image looks squished or stretched

**Cause:** `sceneImageOrFallback` function uses `.scaledToFill()` which maintains aspect ratio but crops

**Solution:** Update the image loader function to use `.scaledToFit()` instead:

```swift
// In PotionShopModels.swift, sceneImageOrFallback function
Image(uiImage: uiImage)
    .resizable()
    .scaledToFit()  // ← CHANGE from .scaledToFill()
    .frame(width: size, height: size * 1.5)  // ← CHANGE to 2:3 aspect
    // Remove .clipShape(Circle()) ← REMOVE THIS LINE
```

---

### **Problem 4: Badges Overlap Character**

**Symptom:** Badges appear behind or inside the character image

**Cause:** Z-index ordering issue

**Solution:** Add explicit `.zIndex()`:
```swift
// Character image
PotionShopImageLoader.sceneImageOrFallback(...)
    .zIndex(0)  // ← Back layer

// HP Badge
if isActive {
    Text("\(customer.hp)")
        // ...
        .zIndex(1)  // ← Front layer
}

// Attack Badge
if attack > 0 {
    Text("\(attack)")
        // ...
        .zIndex(1)  // ← Front layer
}
```

---

## 📐 BADGE POSITION TUNING GUIDE

If badges don't look right, use this guide:

### **Badge Too High:**
```swift
.offset(x: 0, y: -60 * scale)  // Current
.offset(x: 0, y: -50 * scale)  // Lower (closer to head)
.offset(x: 0, y: -40 * scale)  // Even lower
```

### **Badge Too Low:**
```swift
.offset(x: 0, y: -60 * scale)  // Current
.offset(x: 0, y: -70 * scale)  // Higher (further from head)
.offset(x: 0, y: -80 * scale)  // Even higher
```

### **Attack Badge Position:**
```swift
// Current: Right and slightly lower than HP
.offset(x: 20 * scale, y: -50 * scale)

// More to the right:
.offset(x: 30 * scale, y: -50 * scale)

// Same height as HP:
.offset(x: 20 * scale, y: -60 * scale)

// Left side instead:
.offset(x: -20 * scale, y: -50 * scale)
```

---

## 🎨 DRAWING TIPS FOR SCENE PORTRAITS

### **Composition:**
```
┌─────────────────┐
│                 │ ← Top 1/6: Leave space for badges
│     😊          │ ← Head: Upper 1/3
│    👕👔         │ ← Torso: Middle 1/3
│     👖          │ ← Legs: Lower 1/3
│    👞👞         │ ← Feet: Bottom edge
└─────────────────┘
```

### **Pose Ideas:**
- **Standing neutral** (arms at sides)
- **Hands on hips** (confident)
- **Arms crossed** (impatient)
- **Holding something** (bag, book, weapon)
- **Slight lean** (casual waiting pose)

### **Procreate Layers:**
```
✓ Shadow blob (soft ellipse under feet)
✓ Feet/legs
✓ Body/torso
✓ Arms
✓ Head/face
✓ Props/accessories
✓ Outline/border (optional)
✗ Background (turn OFF before export!)
```

---

## 📋 FILES MODIFIED (SUMMARY)

### **Files That Need Changes:**
1. ✅ `PotionShopCustomerSceneView.swift` - Remove circles, reposition badges
2. ⚠️ `PotionShopModels.swift` - MAYBE update `sceneImageOrFallback` (if distortion issues)

### **Files That DON'T Change:**
- ❌ `PotionShopModels.swift` - Struct definition unchanged
- ❌ `PotionShopData.swift` - Character data unchanged
- ❌ `PotionShopGameState.swift` - Logic unchanged
- ❌ All other files - No changes needed

---

## 🚀 NEXT STEPS

### **Immediate Actions:**
1. ✅ Update `PotionShopCustomerSceneView.swift` with new code (see §💻 CODE CHANGES NEEDED)
2. ⚠️ Build project (Command+B)
3. ⚠️ Create `mildred_scene.png` (1024×1536, full body standing)
4. ⚠️ Add to Assets.xcassets
5. ⚠️ Test game

### **If Test Passes:**
1. Draw remaining 13 scene portraits
2. Add them to Assets.xcassets
3. Update `PotionShopData.swift` (change `scenePortrait` values from temp to `_scene`)
4. Rebuild and test all characters

### **If Issues:**
1. Check badge positioning (see §🚨 POTENTIAL ISSUES)
2. Check character sizing (adjust `portraitDiameter`)
3. Check image loader (verify `.scaledToFit()` vs `.scaledToFill()`)

---

## 📞 WHAT TO REPORT

### **Success Report:**
```
✅ Characters show full body (no circles)
✅ HP badge above active customer's head
✅ Attack badges above all customers' heads
✅ Animations work (swap, shake, expire)
✅ Profile row still circular (correct!)
```

### **Issue Report:**
```
❌ [Problem description]
📸 Screenshot attached
🔍 Console output: [paste here]
```

---

## 💡 VISUAL REFERENCE

### **Expected Final Result:**

```
CUSTOMER SCENE:
┌──────────────────────────────────────────┐
│  Background gradient or custom art       │
│                                          │
│           ⚫HP  ⚫Atk ⚫Atk              │  ← Badges floating above
│            ↓     ↓     ↓                │
│   🧙      🧍   🧍    🧍               │  ← Full body characters
│  Ednar   Mildred Tomik Greta           │     (NO circles!)
│   👟      👟    👟    👟               │
│  ═════════════════════════════          │  ← Floor line
└──────────────────────────────────────────┘

PROFILE ROW:
┌──────────────────────────────────────────┐
│      ⭕       ⭕       ⭕                │  ← Circular portraits
│   (Mildred) (Tomik)  (Greta)            │     (with patience rings)
└──────────────────────────────────────────┘
```

---

**END OF REVISION GUIDE**

✅ User wants: Full body characters (no circles), badges above heads, 1024×1536 art  
⚠️ Code update needed: Remove circle backgrounds, reposition badges  
🎨 Art unchanged: Still 1024×1536 px full body standing poses
