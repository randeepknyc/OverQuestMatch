# 🎬 OverQuestMatch3 - Complete Animation Control Guidebook

**Last Updated**: March 16, 2026  
**For**: Non-coders who want to adjust animation speeds and behaviors  
**Purpose**: Complete reference for ALL animation variables with examples

---

## 📖 TABLE OF CONTENTS

1. [Quick Start - Most Important Settings](#quick-start)
2. [GameBoardView Animations (Visual Effects)](#gameboardview-animations)
   - [Match Disappear](#match-disappear)
   - [Swap Animation](#swap-animation)
   - [Gravity Fall](#gravity-fall)
   - [Spawn Animation](#spawn-animation)
   - [Initial Board Fill](#initial-board-fill)
   - [Invalid Swap Shake](#invalid-swap-shake)
   - [Drag Gesture](#drag-gesture)
3. [GameViewModel Timings (Gameplay Flow)](#gameviewmodel-timings)
   - [Invalid Swap Flow](#invalid-swap-flow)
   - [Valid Swap Flow](#valid-swap-flow)
   - [Cascade Processing](#cascade-processing)
   - [Attack Animations](#attack-animations)
   - [Enemy Turn](#enemy-turn)
   - [Ability System](#ability-system)
   - [Chain Mode](#chain-mode)
4. [Common Animation Recipes](#recipes)
5. [How To Test Changes](#testing)
6. [Terminology Guide](#terminology)

---

<a name="quick-start"></a>
## ⚡ QUICK START

### Want Faster Gameplay?

**GameBoardView.swift:**
- Line 13: Change `0.3` to `0.2` (match disappear)
- Line 23: Change `0.4` to `0.3` (swap speed)
- Line 42: Change `0.4` to `0.3` (spawn speed)

**GameViewModel.swift:**
- Line 135: Change `30` to `20` (fall speed)
- Line 146: Change `20` to `15` (spawn speed)

### Want Slower, Dramatic Gameplay?

**GameBoardView.swift:**
- Line 13: Change `0.3` to `0.6` (match disappear)
- Line 23: Change `0.4` to `0.6` (swap speed)
- Line 42: Change `0.4` to `0.6` (spawn speed)

**GameViewModel.swift:**
- Line 135: Change `30` to `50` (fall speed)
- Line 146: Change `20` to `30` (spawn speed)

---

<a name="gameboardview-animations"></a>
## 🎨 GAMEBOARDVIEW ANIMATIONS

**File**: GameBoardView.swift  
**Location**: Top of file (lines 10-67)  
**What**: Visual animation structs that control HOW things look

---

<a name="match-disappear"></a>
### 💥 MATCH DISAPPEAR (Lines 10-16)

**What it does**: Controls how matched gems vanish

```swift
struct MatchDisappearAnimation {
    static let duration: Double = 0.3
    static let scaleEnd: Double = 0.01
    static let useOpacityFade: Bool = true
    static let useBuzzShake: Bool = true
    static let buzzDuration: Double = 0.15
}
```

#### Variables:

**`duration` = 0.3**
- How long gems take to disappear (seconds)
- `0.2` = Very fast
- `0.3` = Fast (current)
- `0.5` = Slow and dramatic
- `1.0` = Too slow

**`scaleEnd` = 0.01**
- How small gems shrink (1.0 = full size)
- `0.01` = Nearly invisible (current)
- `0.3` = Still visible when gone
- `0.5` = Half size
- `0.0` = Instant vanish (glitchy)

**`useOpacityFade` = true**
- Should gems fade out while shrinking?
- `true` = Fade + shrink (current, smooth)
- `false` = Just shrink (abrupt)

**`useBuzzShake` = true**
- Should gems shake before disappearing?
- `true` = Shake enabled (currently not used)
- `false` = No shake

**`buzzDuration` = 0.15**
- How long the shake lasts (seconds)
- Only matters if buzz is re-enabled

---

<a name="swap-animation"></a>
### 🔄 SWAP ANIMATION (Lines 20-26)

**What it does**: Controls how two gems trade places

```swift
struct SwapAnimation {
    static let duration: Double = 0.4
    static let useSpring: Bool = false
    static let springStiffness: Double = 120
    static let springDamping: Double = 18
}
```

#### Variables:

**`duration` = 0.4**
- How long swaps take (seconds)
- `0.2` = Very fast, snappy
- `0.3` = Fast
- `0.4` = Smooth like Candy Crush (current)
- `0.5` = Slow and deliberate
- `0.6` = Too slow

**`useSpring` = false**
- Bouncy physics or smooth glide?
- `false` = Smooth glide (current)
- `true` = Bouncy physics

**`springStiffness` = 120**
- How tight the spring is (if useSpring = true)
- `80` = Loose, slow bounce
- `120` = Medium (current)
- `200` = Tight, fast bounce

**`springDamping` = 18**
- How much bounce vs smooth (if useSpring = true)
- `10` = Very bouncy
- `18` = Some bounce (current)
- `30` = Barely bounces

---

<a name="gravity-fall"></a>
### ⬇️ GRAVITY FALL (Lines 30-35)

**What it does**: Controls how existing gems fall down

```swift
struct GravityFallAnimation {
    static let enabled: Bool = true
    static let stiffness: Double = 120
    static let damping: Double = 18
    static let columnCascadeDelay: Double = 0.03
}
```

#### Variables:

**`enabled` = true**
- Animate falling or instant teleport?
- `true` = Smooth falling (current)
- `false` = Instant teleport (not recommended)

**`stiffness` = 120**
- How fast gems fall
- `80` = Slow, floaty like underwater
- `120` = Medium-fast, natural (current)
- `200` = Very fast, arcade-like
- `300` = Extremely fast (glitchy)

**`damping` = 18**
- How much gems bounce when landing
- `10` = Very bouncy
- `18` = Slight bounce (current)
- `30` = No bounce, smooth stop
- `50` = Dead stop

**`columnCascadeDelay` = 0.03**
- Delay between each column falling (seconds)
- `0.0` = All columns at once
- `0.03` = Slight wave effect (current)
- `0.1` = Obvious waterfall
- `0.2` = Very slow wave

---

<a name="spawn-animation"></a>
### 🌧️ SPAWN ANIMATION (Lines 39-46)

**What it does**: New gems appearing from top during gameplay

```swift
struct SpawnAnimation {
    static let enabled: Bool = true
    static let startScale: Double = 0.3
    static let startOpacity: Double = 0.0
    static let dropDistance: Double = -150
    static let duration: Double = 0.4
    static let springDamping: Double = 0.7
    static let columnDelay: Double = 0.02
}
```

#### Variables:

**`enabled` = true**
- Animate new gems or instant appearance?
- `true` = Raindrop effect (current)
- `false` = Instant (boring)

**`startScale` = 0.3**
- Starting size (1.0 = full size)
- `0.1` = Tiny, dramatic growth
- `0.3` = Small, good (current)
- `0.5` = Medium
- `1.0` = Full size, no growth

**`startOpacity` = 0.0**
- Starting visibility (0.0 = invisible, 1.0 = visible)
- `0.0` = Fade in from invisible (current)
- `0.5` = Half transparent
- `1.0` = Fully visible, no fade

**`dropDistance` = -150**
- How far above gems start (pixels, negative = above)
- `-50` = Just above, short drop
- `-150` = Way above, dramatic (current)
- `-300` = Very high, long fall

**`duration` = 0.4**
- How long drop takes (seconds)
- `0.2` = Fast drop
- `0.4` = Medium, balanced (current)
- `0.6` = Slow, dramatic
- `1.0` = Very slow

**`springDamping` = 0.7**
- Bounce when landing (0.0 = infinite, 1.0 = none)
- `0.5` = More bouncy
- `0.7` = Slight bounce, natural (current)
- `0.9` = Almost no bounce
- `1.0` = Dead stop

**`columnDelay` = 0.02**
- Delay between columns (seconds)
- `0.0` = All at once
- `0.02` = Slight wave (current)
- `0.1` = Obvious cascade
- `0.2` = Very slow wave

---

<a name="initial-board-fill"></a>
### 🎮 INITIAL BOARD FILL (Lines 50-58)

**What it does**: Game start/restart animation

```swift
struct InitialFillAnimation {
    static let enabled: Bool = true
    static let startScale: Double = 0.3
    static let startOpacity: Double = 0.0
    static let dropDistance: Double = -150
    static let rowDelay: Double = 0.1
    static let randomVariation: Double = 0.1
    static let duration: Double = 0.4
    static let springDamping: Double = 0.7
}
```

#### Variables:

**`enabled` = true**
- Animate game start or instant?
- `true` = Filling container effect (current)
- `false` = Instant, boring

**`startScale` = 0.3**
- Same as spawn animation (see above)

**`startOpacity` = 0.0**
- Same as spawn animation (see above)

**`dropDistance` = -150**
- Same as spawn animation (see above)

**`rowDelay` = 0.1**
- Delay between each ROW (bottom to top, seconds)
- `0.05` = Fast wave
- `0.1` = Medium, looks like filling (current)
- `0.2` = Slow, very noticeable
- `0.3` = Too slow

**`randomVariation` = 0.1**
- Random delay per gem in a row (seconds)
- `0.0` = Perfect sync, all gems together
- `0.1` = Slight randomness, natural (current)
- `0.2` = More random, scattered
- `0.5` = Very random, messy

**`duration` = 0.4**
- Same as spawn animation (see above)

**`springDamping` = 0.7**
- Same as spawn animation (see above)

---

<a name="invalid-swap-shake"></a>
### 📳 INVALID SWAP SHAKE (Lines 62-67)

**What it does**: Shake when you make a wrong move

```swift
struct InvalidSwapShake {
    static let enabled: Bool = true
    static let duration: Double = 0.05
    static let repeatCount: Int = 6
    static let distance: CGFloat = 5.0
}
```

#### Variables:

**`enabled` = true**
- Shake on invalid move?
- `true` = Shows error feedback (current)
- `false` = No shake, confusing

**`duration` = 0.05**
- Speed of each shake (seconds)
- `0.03` = Very fast vibration
- `0.05` = Fast, responsive (current)
- `0.1` = Slow shake

**`repeatCount` = 6**
- Number of shakes
- `4` = Quick double shake
- `6` = Triple shake, noticeable (current)
- `10` = Long shake
- `2` = Single shake, barely visible

**`distance` = 5.0**
- How far gems move (pixels)
- `3.0` = Tiny, subtle
- `5.0` = Small, clear (current)
- `10.0` = Big, very obvious
- `20.0` = Huge, looks broken

---

<a name="drag-gesture"></a>
### 🎯 DRAG GESTURE (Line 378)

**What it does**: Bounce back when you drag and release

**Location**: NOT in structs at top! In gesture code around line 378

```swift
withAnimation(.interpolatingSpring(stiffness: 250, damping: 20)) {
    dragOffset.wrappedValue = .zero
}
```

#### Variables:

**`stiffness: 250`**
- How fast gems snap back
- `150` = Slow, floaty
- `250` = Medium-fast, playful (current)
- `350` = Very fast, snappy
- `500` = Instant, harsh

**`damping: 20`**
- How much bounce
- `10` = Very bouncy, overshoots
- `15` = Bouncy, obvious
- `20` = Slight bounce, fun (current)
- `30` = Almost no bounce
- `50` = Dead stop

#### Alternative Styles (replace whole animation line):

**Super Bouncy:**
```swift
withAnimation(.interpolatingSpring(stiffness: 350, damping: 12)) {
```

**Very Smooth (no bounce):**
```swift
withAnimation(.easeOut(duration: 0.3)) {
```

**Gentle Float:**
```swift
withAnimation(.interpolatingSpring(stiffness: 180, damping: 25)) {
```

---

<a name="gameviewmodel-timings"></a>
## ⏱️ GAMEVIEWMODEL TIMINGS

**File**: GameViewModel.swift  
**What**: Wait times between animation steps (controls gameplay pacing)

---

<a name="invalid-swap-flow"></a>
### ❌ INVALID SWAP FLOW (Lines 76-99)

**What happens**: When you try an invalid swap

```swift
// Line 76
try? await Task.sleep(for: .milliseconds(300))  // Show invalid swap

// Line 79
try? await Task.sleep(for: .milliseconds(200))  // Shake duration

// Line 82
try? await Task.sleep(for: .milliseconds(300))  // Swap back

// Lines 88-89
try? await Task.sleep(for: .milliseconds(350))  // Enemy attack
```

#### Timing Breakdown:

**Line 76: 300ms**
- How long to show the invalid swap before shaking
- `200` = Faster
- `300` = Current
- `400` = Slower

**Line 79: 200ms**
- How long gems shake
- Must match shake duration in GameBoardView
- `200` = Current (6 shakes × 0.05s duration)

**Line 82: 300ms**
- Swap-back animation time
- `200` = Faster
- `300` = Current
- `400` = Slower

**Lines 88-89: 350ms**
- Enemy attack animation length
- `250` = Faster
- `350` = Current
- `500` = Slower

---

<a name="valid-swap-flow"></a>
### ✅ VALID SWAP FLOW (Line 99)

**What happens**: When you make a valid swap

```swift
// Line 99
try? await Task.sleep(for: .milliseconds(400))  // Let swap complete
```

#### Timing:

**Line 99: 400ms**
- Wait for swap animation to finish
- Should match SwapAnimation.duration in GameBoardView (0.4s = 400ms)
- `300` = If you set swap to 0.3s
- `400` = Current (matches 0.4s swap)
- `500` = If you set swap to 0.5s

---

<a name="cascade-processing"></a>
### 🌊 CASCADE PROCESSING (Lines 117-185)

**What happens**: When matches are processed and gems refill

```swift
// Line 117
try? await Task.sleep(for: .milliseconds(150))  // Buzz before disappear

// Line 123
try? await Task.sleep(for: .milliseconds(300))  // Wait for disappear

// Line 135
let fallWaitTime = 30 * boardManager.size + 300  // Fall time

// Line 146
let spawnWaitTime = 20 * boardManager.size + Int(SpawnAnimation.duration * 1000)  // Spawn time

// Lines 155-156
try? await Task.sleep(for: .milliseconds(100))   // Power Surge delay
try? await Task.sleep(for: .milliseconds(1500))  // Power Surge effect

// Line 165
try? await Task.sleep(for: .milliseconds(100))  // Pause before next cascade
```

#### Timing Breakdown:

**Line 117: 150ms**
- Buzz/shake before gems disappear
- `100` = Faster
- `150` = Current
- `300` = Slower

**Line 123: 300ms**
- Wait for disappear animation to finish
- Should match MatchDisappearAnimation.duration (0.3s = 300ms)
- `200` = If you set disappear to 0.2s
- `300` = Current
- `600` = If you set disappear to 0.6s

**Line 135: Calculated fall time**
- Formula: `30 * 8 + 300 = 540ms` for 8×8 board
- Change the `30` number:
  - `20` = Faster falling
  - `30` = Current
  - `50` = Slower falling

**Line 146: Calculated spawn time**
- Formula: `20 * 8 + 400 = 560ms` for 8×8 board
- Change the `20` number:
  - `15` = Faster spawning
  - `20` = Current
  - `30` = Slower spawning

**Lines 155-156: Power Surge**
- Line 155 (100ms): Delay before effect starts
- Line 156 (1500ms): Effect duration (1.5 seconds)
- Total: 1.6 seconds

**Line 165: 100ms**
- Pause before checking for next cascade
- `50` = Faster cascades
- `100` = Current
- `200` = Slower cascades

---

<a name="attack-animations"></a>
### ⚔️ ATTACK ANIMATIONS (Lines 188-193)

**What happens**: Player attacks enemy

```swift
// Line 191
try? await Task.sleep(for: .milliseconds(350))  // Attack animation
```

#### Timing:

**Line 191: 350ms**
- Player attack animation length
- `250` = Faster
- `350` = Current
- `500` = Slower

---

<a name="enemy-turn"></a>
### 👾 ENEMY TURN (Lines 196-204)

**What happens**: Enemy's turn to attack

```swift
// Line 197
try? await Task.sleep(for: .milliseconds(400))  // Pause before enemy

// Line 201
try? await Task.sleep(for: .milliseconds(350))  // Enemy attack
```

#### Timing:

**Line 197: 400ms**
- Pause before enemy turn starts
- `200` = Faster
- `400` = Current
- `600` = Slower

**Line 201: 350ms**
- Enemy attack animation length
- `250` = Faster
- `350` = Current
- `500` = Slower

---

<a name="ability-system"></a>
### ☕ ABILITY SYSTEM (Lines 222-280)

**What happens**: When you use coffee cup ability

```swift
// Line 227
try? await Task.sleep(for: .milliseconds(200))  // Highlight cleared gems

// Line 230
try? await Task.sleep(for: .milliseconds(150))  // Brief pause

// Line 237 & 245
// Uses same fall/spawn formulas as cascade processing

// Line 267
try? await Task.sleep(for: .milliseconds(350))  // Defensive ability flash
```

#### Timing:

**Line 227: 200ms**
- How long cleared gems are highlighted
- `100` = Faster
- `200` = Current
- `400` = Slower

**Line 230: 150ms**
- Brief pause after clearing
- `100` = Faster
- `150` = Current
- `300` = Slower

**Lines 237 & 245**
- Same as cascade processing (see above)

**Line 267: 350ms**
- Flash for shield/heal abilities
- `250` = Faster
- `350` = Current
- `500` = Slower

---

<a name="chain-mode"></a>
### 🔗 CHAIN MODE (Lines 286-336)

**What happens**: Chain mode gameplay

```swift
// Line 296
try? await Task.sleep(for: .milliseconds(150))  // Pause after chain release

// Lines 304 & 312
// Uses same fall/spawn formulas as cascade processing

// Line 327
try? await Task.sleep(for: .milliseconds(350))  // Chain attack
```

#### Timing:

**Line 296: 150ms**
- Pause after releasing chain
- `100` = Faster
- `150` = Current
- `300` = Slower

**Lines 304 & 312**
- Same as cascade processing (see above)

**Line 327: 350ms**
- Chain attack animation
- `250` = Faster
- `350` = Current
- `500` = Slower

---

<a name="recipes"></a>
## 🍳 ANIMATION RECIPES

### Recipe 1: SUPER FAST (Skilled Players)

**GameBoardView.swift:**
```swift
// Line 13 - Match disappear
static let duration: Double = 0.2

// Line 23 - Swap
static let duration: Double = 0.3

// Line 42 - Spawn duration
static let duration: Double = 0.3

// Line 45 - Spawn column delay
static let columnDelay: Double = 0.01
```

**GameViewModel.swift:**
```swift
// Line 117 - Buzz
try? await Task.sleep(for: .milliseconds(100))

// Line 123 - Disappear wait
try? await Task.sleep(for: .milliseconds(200))

// Line 135 - Fall time (change the 30)
let fallWaitTime = 20 * boardManager.size + 200

// Line 146 - Spawn time (change the 20)
let spawnWaitTime = 15 * boardManager.size + Int(SpawnAnimation.duration * 1000)
```

**Result**: Very snappy, fast-paced gameplay

---

### Recipe 2: SLOW & DRAMATIC (Beginners)

**GameBoardView.swift:**
```swift
// Line 13 - Match disappear
static let duration: Double = 0.6

// Line 23 - Swap
static let duration: Double = 0.6

// Line 42 - Spawn duration
static let duration: Double = 0.6

// Line 45 - Spawn column delay
static let columnDelay: Double = 0.05
```

**GameViewModel.swift:**
```swift
// Line 117 - Buzz
try? await Task.sleep(for: .milliseconds(300))

// Line 123 - Disappear wait
try? await Task.sleep(for: .milliseconds(600))

// Line 135 - Fall time (change the 30)
let fallWaitTime = 50 * boardManager.size + 500

// Line 146 - Spawn time (change the 20)
let spawnWaitTime = 30 * boardManager.size + Int(SpawnAnimation.duration * 1000)
```

**Result**: Slow, easy to follow for new players

---

### Recipe 3: SUPER BOUNCY ARCADE

**GameBoardView.swift:**
```swift
// Lines 24-26 - Swap spring
static let useSpring: Bool = true
static let springStiffness: Double = 200
static let springDamping: Double = 12

// Lines 32-33 - Gravity spring
static let stiffness: Double = 200
static let damping: Double = 12

// Line 43 - Spawn bounce
static let springDamping: Double = 0.5

// Line 378 - Drag gesture (replace entire line)
withAnimation(.interpolatingSpring(stiffness: 350, damping: 12)) {
    dragOffset.wrappedValue = .zero
}
```

**Result**: Everything bounces, playful arcade feel

---

### Recipe 4: SMOOTH & POLISHED (Candy Crush Style)

**GameBoardView.swift:**
```swift
// Lines 24-25 - Swap smooth
static let useSpring: Bool = false
static let duration: Double = 0.4

// Lines 32-33 - Gravity smooth
static let stiffness: Double = 150
static let damping: Double = 25

// Line 43 - Spawn smooth
static let springDamping: Double = 0.8

// Line 378 - Drag gesture (replace entire line)
withAnimation(.easeOut(duration: 0.3)) {
    dragOffset.wrappedValue = .zero
}
```

**Result**: Silky smooth, professional polish

---

### Recipe 5: INSTANT (Testing Only)

**GameBoardView.swift:**
```swift
// Lines 13-14 - Match disappear
static let duration: Double = 0.0
static let useOpacityFade: Bool = false

// Line 23 - Swap
static let duration: Double = 0.0

// Line 31 - Gravity
static let enabled: Bool = false

// Line 40 - Spawn
static let enabled: Bool = false

// Line 63 - Shake
static let enabled: Bool = false
```

**GameViewModel.swift:**
```swift
// Change ALL Task.sleep lines to:
try? await Task.sleep(for: .milliseconds(0))
```

**Result**: No animations, instant gameplay (for debugging)

---

<a name="testing"></a>
## 🧪 HOW TO TEST CHANGES

### Step 1: Make Changes
1. Open Xcode
2. Find the file (GameBoardView.swift or GameViewModel.swift)
3. Find the line number mentioned in this guide
4. Change the number
5. Press **Command+S** to save

### Step 2: Run Game
1. Press **Command+R** to run
2. Wait for app to launch

### Step 3: Test What You Changed

**Match Disappear**: Make a 3-gem match, watch them vanish

**Swap**: Tap two adjacent gems, watch them swap

**Gravity Fall**: Make a match, watch gems fall down

**Spawn**: Make a match, watch new gems appear from top

**Initial Fill**: Press Pause → New Game, watch board fill from bottom

**Invalid Shake**: Try to swap diagonal gems, watch them shake

**Drag Gesture**: Tap and hold a gem, drag it, release without swapping

### Step 4: Undo If Needed
1. Press **Command+Z** to undo
2. Or change number back to original
3. Press **Command+S** to save
4. Press **Command+R** to test again

---

<a name="terminology"></a>
## 📚 TERMINOLOGY GUIDE

### Animation Terms

**Duration**: How long something takes (in seconds)
- Example: `0.3` = 300 milliseconds = 0.3 seconds

**Stiffness**: How fast a spring snaps (higher = faster)
- Example: `120` = medium speed, `200` = fast

**Damping**: How much bounce (higher = less bounce)
- Example: `10` = very bouncy, `30` = smooth

**Scale**: Size multiplier
- `0.5` = half size, `1.0` = full size, `2.0` = double size

**Opacity**: Transparency
- `0.0` = invisible, `0.5` = half transparent, `1.0` = fully visible

**Offset**: Position movement (in pixels)
- `-150` = 150 pixels above

**Delay**: Wait time before starting (in seconds)
- `0.1` = wait one tenth of a second

### Code Terms

**Bool**: True or False value
- `true` = yes, enabled, on
- `false` = no, disabled, off

**Double**: Number with decimal point
- Example: `0.4`, `120.5`

**Int**: Whole number (no decimal)
- Example: `6`, `300`

**CGFloat**: Number for graphics/positions
- Example: `5.0`, `150.0`

**Milliseconds (ms)**: Thousandths of a second
- `100ms` = 0.1 seconds
- `300ms` = 0.3 seconds
- `1000ms` = 1 second

### What "static let" means

**static let** = A setting that doesn't change while game runs
- You change it in code, then run the game
- The new value applies to the whole game

### What "try? await Task.sleep" means

**try? await Task.sleep** = Wait for X time before continuing
- Example: `Task.sleep(for: .milliseconds(300))` = wait 0.3 seconds
- This controls timing/pacing between animation steps

---

## 🎯 QUICK REFERENCE CARD

### Most Common Adjustments

| What You Want | File | Line | Change From → To |
|--------------|------|------|------------------|
| Faster matches | GameBoardView.swift | 13 | `0.3` → `0.2` |
| Faster swaps | GameBoardView.swift | 23 | `0.4` → `0.3` |
| Faster spawns | GameBoardView.swift | 42 | `0.4` → `0.3` |
| Faster falling | GameViewModel.swift | 135 | `30` → `20` |
| More bouncy | GameBoardView.swift | 33 | `18` → `10` |
| Less bouncy | GameBoardView.swift | 33 | `18` → `30` |
| Longer shake | GameBoardView.swift | 65 | `6` → `10` |
| Shorter shake | GameBoardView.swift | 65 | `6` → `4` |

### Emergency Reset

If you break something, press **Command+Z** repeatedly until it works again.

If that doesn't help, look at this guide and change numbers back to the "current" values shown.

---

**End of Guidebook**

*Last updated: March 16, 2026*  
*For OverQuestMatch3 v1.0*
