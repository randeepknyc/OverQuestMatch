# 🎚️ Haptic Customization Guide

## 📍 Where to Make Changes

**Open this file:** `HapticManager.swift`

**Look for this section at the top (around lines 13-60):**

```swift
// ═══════════════════════════════════════════════════════════════
// ⚡ HAPTIC CUSTOMIZATION SETTINGS - ADJUST THESE!
// ═══════════════════════════════════════════════════════════════
```

**All the settings you can change are right there!**

---

## 🎮 **What Each Setting Does**

### 🎯 **TILE INTERACTIONS**

```swift
var tileTapIntensity: Double = 0.5
```
- **What it controls:** How strong it feels when you tap a gem
- **Range:** 0.0 (barely feel it) to 1.0 (maximum)
- **Try this:**
  - `0.3` = Very subtle tap
  - `0.7` = Stronger, more noticeable
  - `1.0` = Maximum feedback

---

### 🔄 **SWAP FEEDBACK**

```swift
var swapStartIntensity: Double = 0.7
var swapCompleteIntensity: Double = 0.8
```

**swapStartIntensity:**
- When you START dragging a gem
- Higher = more noticeable pickup feel

**swapCompleteIntensity:**
- When gems finish swapping
- Higher = more satisfying "snap" into place

**Try this:**
- Make swaps feel snappier: `swapCompleteIntensity = 1.0`
- Make swaps subtle: `swapCompleteIntensity = 0.5`

---

### 💎 **MATCH INTENSITIES**

```swift
var match3Intensity: Double = 0.6    // 3-gem match
var match4Intensity: Double = 0.9    // 4-gem match
var match5PlusIntensity: Double = 1.0 // 5+ gem match
```

**What these control:** How strong the vibration is for different match sizes

**Examples:**

**Make ALL matches feel stronger:**
```swift
var match3Intensity: Double = 0.8
var match4Intensity: Double = 1.0
var match5PlusIntensity: Double = 1.0
```

**Make small matches subtle, big matches HUGE:**
```swift
var match3Intensity: Double = 0.3
var match4Intensity: Double = 0.6
var match5PlusIntensity: Double = 1.0
```

**Make all matches the same strength:**
```swift
var match3Intensity: Double = 0.7
var match4Intensity: Double = 0.7
var match5PlusIntensity: Double = 0.7
```

---

### 🌊 **CASCADE COMBOS**

```swift
var cascadeBaseIntensity: Double = 0.4
var cascadeIntensityPerCombo: Double = 0.15
```

**How cascades work:**
- **Combo 1:** Intensity = 0.4 + (1 × 0.15) = **0.55**
- **Combo 2:** Intensity = 0.4 + (2 × 0.15) = **0.70**
- **Combo 3:** Intensity = 0.4 + (3 × 0.15) = **0.85**
- **Combo 4:** Intensity = 0.4 + (4 × 0.15) = **1.0** (maxed out!)

**Examples:**

**Make cascades build up FASTER:**
```swift
var cascadeBaseIntensity: Double = 0.5
var cascadeIntensityPerCombo: Double = 0.25  // Each combo adds MORE
```

**Make cascades more subtle:**
```swift
var cascadeBaseIntensity: Double = 0.3
var cascadeIntensityPerCombo: Double = 0.1   // Each combo adds LESS
```

**Make all cascades the same strength:**
```swift
var cascadeBaseIntensity: Double = 0.6
var cascadeIntensityPerCombo: Double = 0.0   // No scaling!
```

---

### ⚡ **POWER SURGE (Triple-Pulse Effect)**

```swift
var powerSurgeDelay1: Int = 100      // Delay between 1st and 2nd pulse (milliseconds)
var powerSurgeDelay2: Int = 200      // Delay between 2nd and 3rd pulse (milliseconds)
var powerSurge1stIntensity: Double = 1.0
var powerSurge2ndIntensity: Double = 0.7
var powerSurge3rdIntensity: Double = 1.0
```

**Current pattern:** BOOM → (0.1s) → boom → (0.2s) → **BOOM!**

**Examples:**

**Make it SUPER dramatic (slow build-up):**
```swift
var powerSurgeDelay1: Int = 200      // Longer pause
var powerSurgeDelay2: Int = 400      // Even longer pause
var powerSurge1stIntensity: Double = 0.5
var powerSurge2ndIntensity: Double = 0.8
var powerSurge3rdIntensity: Double = 1.0  // Builds to max!
```

**Make it rapid-fire:**
```swift
var powerSurgeDelay1: Int = 50       // Quick!
var powerSurgeDelay2: Int = 50       // Quick!
var powerSurge1stIntensity: Double = 1.0
var powerSurge2ndIntensity: Double = 1.0
var powerSurge3rdIntensity: Double = 1.0  // All max power!
```

**Make it subtle (just two pulses):**
```swift
var powerSurgeDelay1: Int = 100
var powerSurgeDelay2: Int = 200
var powerSurge1stIntensity: Double = 0.6
var powerSurge2ndIntensity: Double = 0.4
var powerSurge3rdIntensity: Double = 0.0  // Turn off 3rd pulse
```

---

### ☕ **COFFEE CUP ABILITY**

```swift
var abilityDelay: Int = 50           // Delay between two pulses (milliseconds)
var abilityFirstIntensity: Double = 1.0
var abilitySecondIntensity: Double = 0.6
```

**Current pattern:** BOOM → (0.05s) → boom

**Make it one HUGE pulse:**
```swift
var abilityDelay: Int = 0
var abilityFirstIntensity: Double = 1.0
var abilitySecondIntensity: Double = 0.0  // Turn off 2nd pulse
```

**Make it a double-tap:**
```swift
var abilityDelay: Int = 100          // Longer gap
var abilityFirstIntensity: Double = 1.0
var abilitySecondIntensity: Double = 1.0  // Both max power!
```

---

### ⚔️ **BATTLE DAMAGE**

```swift
var heavyDamageThreshold: Int = 10
var playerHeavyDamageIntensity: Double = 1.0
var playerLightDamageIntensity: Double = 0.7
var enemyHeavyDamageIntensity: Double = 0.9
var enemyLightDamageIntensity: Double = 0.8
```

**How it works:**
- Damage **< 10** = "light damage" haptic
- Damage **≥ 10** = "heavy damage" haptic

**Examples:**

**Make heavy hits feel MORE brutal:**
```swift
var heavyDamageThreshold: Int = 15   // Need MORE damage to trigger
var playerHeavyDamageIntensity: Double = 1.0
```

**Make ALL damage feel heavy:**
```swift
var heavyDamageThreshold: Int = 0    // Everything is heavy!
var playerHeavyDamageIntensity: Double = 1.0
var playerLightDamageIntensity: Double = 1.0
```

**Make enemy damage more subtle:**
```swift
var enemyHeavyDamageIntensity: Double = 0.5
var enemyLightDamageIntensity: Double = 0.3
```

---

### 🏆 **VICTORY SEQUENCE**

```swift
var victoryDelay1: Int = 150
var victoryDelay2: Int = 300
```

**Current pattern:** SUCCESS! → (0.15s) → bump → (0.3s) → BOOM!

**Make it faster celebration:**
```swift
var victoryDelay1: Int = 80
var victoryDelay2: Int = 160
```

**Make it slow, dramatic:**
```swift
var victoryDelay1: Int = 300
var victoryDelay2: Int = 600
```

---

### 💀 **DEFEAT SEQUENCE**

```swift
var defeatDelay: Int = 100
var defeatIntensity: Double = 0.5
```

**Current pattern:** ERROR → (0.1s) → thud

**Make it more impactful:**
```swift
var defeatDelay: Int = 150
var defeatIntensity: Double = 1.0  // Heavy thud
```

---

## 🎨 **UNDERSTANDING HAPTIC TYPES**

Your iPhone has **5 built-in haptic styles**:

### **1. Light** (`.impactLight`)
- Feels like: Gentle tap, touching a button
- Used for: Tile taps, mana gain, subtle feedback
- Intensity range: 0.0-1.0

### **2. Medium** (`.impactMedium`)
- Feels like: Standard button press, notification
- Used for: Swaps, 3-4 matches, cascades
- Intensity range: 0.0-1.0

### **3. Heavy** (`.impactHeavy`)
- Feels like: Solid thump, important action
- Used for: 5+ matches, damage, abilities, Power Surge
- Intensity range: 0.0-1.0

### **4. Rigid** (`.impactRigid`)
- Feels like: Sharp, precise snap (like toggle switch)
- Used for: Shield activation, final Power Surge pulse
- Intensity range: 0.0-1.0

### **5. Selection** (`.selectionFeedback`)
- Feels like: Wheel clicking, picker scrolling
- Used for: Gem selection changes
- No intensity control (always same strength)

### **6. Notification** (`.notificationFeedback`)
- Three types: `.success`, `.warning`, `.error`
- Used for: Victory, defeat, invalid swaps
- No intensity control

---

## 📊 **TIMING REFERENCE**

**Milliseconds to Seconds:**
- `50ms` = 0.05 seconds (very quick)
- `100ms` = 0.1 seconds (quick)
- `150ms` = 0.15 seconds (noticeable pause)
- `200ms` = 0.2 seconds (medium pause)
- `300ms` = 0.3 seconds (longer pause)
- `500ms` = 0.5 seconds (half second)
- `1000ms` = 1.0 second

---

## 🎯 **QUICK PRESETS**

### **PRESET 1: Subtle & Refined**
```swift
var match3Intensity: Double = 0.4
var match4Intensity: Double = 0.6
var match5PlusIntensity: Double = 0.8

var swapCompleteIntensity: Double = 0.6
var cascadeBaseIntensity: Double = 0.3
var cascadeIntensityPerCombo: Double = 0.1
```

### **PRESET 2: Maximum Impact (AGGRESSIVE)**
```swift
var match3Intensity: Double = 0.8
var match4Intensity: Double = 1.0
var match5PlusIntensity: Double = 1.0

var swapCompleteIntensity: Double = 1.0
var cascadeBaseIntensity: Double = 0.6
var cascadeIntensityPerCombo: Double = 0.2

var powerSurge1stIntensity: Double = 1.0
var powerSurge2ndIntensity: Double = 1.0
var powerSurge3rdIntensity: Double = 1.0
```

### **PRESET 3: Balanced (Recommended)**
```swift
var match3Intensity: Double = 0.6
var match4Intensity: Double = 0.9
var match5PlusIntensity: Double = 1.0

var swapCompleteIntensity: Double = 0.8
var cascadeBaseIntensity: Double = 0.4
var cascadeIntensityPerCombo: Double = 0.15
```

---

## 🧪 **HOW TO TEST YOUR CHANGES**

1. **Make your changes** in HapticManager.swift (top section)
2. **Save the file** (Command + S)
3. **Build and run** (Command + R)
4. **Test on a REAL device** (haptics don't work in Simulator!)
5. **Try these actions:**
   - Tap a gem → Feel tile tap
   - Swap gems → Feel swap complete
   - Make a 3-match → Feel match intensity
   - Make a 4-match → Feel stronger + Power Surge!
   - Create a cascade → Feel intensity build!
   - Use coffee cup → Feel ability activation!

6. **Not happy?** Change the numbers and repeat!

---

## ⚠️ **TIPS & WARNINGS**

### ✅ **DO:**
- Start with small changes (0.1-0.2 differences)
- Test on a real device every time
- Keep intensity values between 0.0 and 1.0
- Make timing delays at least 50ms (smaller = too fast to feel)

### ❌ **DON'T:**
- Use intensity values above 1.0 (won't make it stronger, just caps at 1.0)
- Use negative values (will cause errors)
- Make delays too short (< 30ms won't feel distinct)
- Make EVERY haptic max intensity (loses meaning)

---

## 🎮 **MY RECOMMENDATION**

**If you're unsure where to start, try this:**

1. **Make Power Surge more dramatic:**
   ```swift
   var powerSurgeDelay1: Int = 150
   var powerSurgeDelay2: Int = 300
   var powerSurge1stIntensity: Double = 0.6
   var powerSurge2ndIntensity: Double = 0.9
   var powerSurge3rdIntensity: Double = 1.0
   ```

2. **Make swaps feel snappier:**
   ```swift
   var swapCompleteIntensity: Double = 1.0
   ```

3. **Make cascades more satisfying:**
   ```swift
   var cascadeBaseIntensity: Double = 0.5
   var cascadeIntensityPerCombo: Double = 0.2
   ```

4. **Test it!** See how it feels. Adjust from there!

---

## 🆘 **NEED HELP?**

Just tell me what you want to change:
- "Make matches feel stronger"
- "Make Power Surge slower"
- "Make cascades more subtle"
- "Make damage feel heavier"

And I'll give you the exact numbers to change! 😊

---

**Happy haptic tuning! 🎚️✨**
