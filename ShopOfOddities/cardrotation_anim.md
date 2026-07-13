# CARD FLIP ANIMATION REFERENCE
**DeckView.swift - 3D Card Flip Animation Settings**

> **Last Updated:** April 11, 2026  
> **File:** `ShopOfOddities/DeckView.swift`  
> **Lines:** 14-30 (ANIMATOR CONTROLS section)

---

## 🎨 CURRENT ANIMATION VALUES

### **Animator Controls (Lines 14-30)**

```swift
/// Flip animation total duration (in seconds)
private let flipDuration: Double = 0.4

/// Flip animation curve - Options: .linear, .easeIn, .easeOut, .easeInOut
private let flipCurve: Animation = .linear

/// At what rotation angle (0-180°) should we swap from back to face?
/// 90° = exactly edge-on (recommended), lower = swap earlier, higher = swap later
private let swapAngle: Double = 75

/// Smooth crossfade window (in degrees) - creates gradual transition around swap point
/// 10-15° gives smooth card flip feel, 5° or less looks snappy, 20° or more looks like dissolve
private let crossfadeWindow: Double = 30
```

---

## 📊 ANIMATION BREAKDOWN

### **Timing**
- **Total Duration:** 0.4 seconds (400ms)
- **Part 1 (0° → swap):** 0.2 seconds (200ms)
- **State Swap Delay:** 0.01 seconds (10ms)
- **Part 2 (swap → 180°):** 0.2 seconds (200ms)

### **Angles**
- **Start:** 0° (card back facing viewer)
- **Swap Point:** 75° (where back/face swap happens)
- **End:** 180° (card face facing viewer, then reset to 0°)

### **Crossfade Zone**
- **Start:** 60° (75° - 15°)
- **Midpoint:** 75° (swap angle)
- **End:** 90° (75° + 15°)
- **Total Width:** 30° (crossfadeWindow)

---

## 🎬 FRAME-BY-FRAME TIMELINE

| Time | Angle | Back Opacity | Face Opacity | Visual State |
|------|-------|--------------|--------------|--------------|
| **0ms** | 0° | 1.0 ✅ | 0.0 ❌ | Card back fully visible |
| **120ms** | 60° | 1.0 ✅ | 0.0 ❌ | Card back rotating |
| **130ms** | 65° | ~0.9 🔸 | ~0.1 🔸 | **Crossfade begins** |
| **150ms** | 75° | ~0.5 🔸 | ~0.5 🔸 | **Swap point** (50/50 blend) |
| **170ms** | 85° | ~0.2 🔸 | ~0.8 🔸 | Mostly face visible |
| **180ms** | 90° | 0.0 ❌ | 1.0 ✅ | **Crossfade ends** |
| **200ms** | 90° | 0.0 ❌ | 1.0 ✅ | **State swap** (showingCardBack = false) |
| **210ms** | 90° | 0.0 ❌ | 1.0 ✅ | Delay (state registration) |
| **400ms** | 180° | 0.0 ❌ | 1.0 ✅ | Card face fully visible |
| **401ms** | 0° | 0.0 ❌ | 1.0 ✅ | **Reset** (angle back to 0°) |

---

## 🔧 KEY MODIFIER LOCATIONS

### **3D Rotation (Lines 171-176)**
```swift
cardBackView
    .rotation3DEffect(
        .degrees(isDragging ? 0 : flipAngle),
        axis: (x: 0.0, y: 1.0, z: 0.0),
        perspective: 0.5
    )
```

### **Horizontal Mirror Flip (Line 319)**
```swift
.scaleEffect(x: -1, y: 1) // ALWAYS flip to counteract reverse rotation
```

**Purpose:** Prevents card face from appearing backwards during 3D rotation.

**To disable mirror flip:** Change `x: -1` to `x: 1` (card will be mirrored/backwards)

---

## 🎯 OPACITY CALCULATION

### **Ease Curves**
- **Card Back:** Ease-out curve `1.0 - pow(1.0 - progress, 2.0)`
  - Fades out fast at first, then slows down
- **Card Face:** Ease-in curve `progress * progress`
  - Fades in slow at first, then speeds up

### **Opacity Functions (Lines 218-270)**
Located in `calculateBackOpacity()` and `calculateFaceOpacity()`

---

## 🎨 RECOMMENDED TWEAKS

### **For Snappier Flip:**
```swift
private let swapAngle: Double = 90
private let crossfadeWindow: Double = 10
```

### **For Smoother Flip:**
```swift
private let swapAngle: Double = 75
private let crossfadeWindow: Double = 40
```

### **For Earlier Crossfade:**
```swift
private let swapAngle: Double = 60
private let crossfadeWindow: Double = 30
```

### **For Faster Animation:**
```swift
private let flipDuration: Double = 0.25
private let flipCurve: Animation = .easeInOut
```

---

## 🔄 PROGRESSIVE REVEAL SYSTEM

### **How It Works:**
1. **Opening animation:** All 4 cards flip face-up together on game start
2. **After opening:** New cards appear face-down when previous card is drawn
3. **Trigger:** When user places card in repair area, face-down card flips face-up
4. **UUID-based:** `flipTriggerID` changes → triggers `triggerFlipAnimation()`

### **Key State Variables:**
- `hasFlippedThisCard: Bool` - Tracks if current card has been revealed
- `showingCardBack: Bool` - True = show back, False = show face
- `flipAngle: Double` - Current rotation angle (0-180°)

---

## 📝 SIMPLE PROMPT FOR NEW CHAT

```
I'm working on the card flip animation in DeckView.swift for the 
Shop of Oddities game. The animation uses 3D rotation with crossfade 
opacity blending.

Current settings:
- swapAngle: 75°
- crossfadeWindow: 30°
- flipDuration: 0.4s
- flipCurve: .linear

Reference file: cardrotation_anim.md

[Describe what you want to adjust]
```

---

## 🗂️ FILE LOCATIONS

- **Main File:** `ShopOfOddities/DeckView.swift`
- **Config File:** `ShopOfOddities/ShopLayoutConfig.swift`
- **Context Doc:** `ReadFilesForContext/ShopOfOddities_CONTEXT.md`

---

## 📊 VISUAL DIAGRAM

```
FLIP ANIMATION TIMELINE (75° swap, 30° crossfade):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
0°        60°    75°    90°        180°      0°
│          │      │      │          │        │
│ CARD BACK│ CROSSFADE  │CARD FACE │  FACE  │RESET
│ VISIBLE  │ BLENDING   │ VISIBLE  │ DONE   │TO 0°
│          │◄───30°───►│          │        │
│          │            │          │        │
0ms      120ms  150ms  180ms     400ms    401ms
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BACK OPACITY:  ████████████▓▓▓▓▒▒▒░░░░░░░░░░░░░░░░
FACE OPACITY:  ░░░░░░░░░░░░▒▒▒▓▓▓▓████████████████
                        ↑
                   SWAP POINT
```

---

**END OF REFERENCE**
