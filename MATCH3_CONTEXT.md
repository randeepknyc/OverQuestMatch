# MATCH-3 GAME CONTEXT
**OverQuestMatch3 - Match-3 RPG Battle Game**

> **Last Updated:** March 28, 2026  
> **Status:** ✅ COMPLETE & FULLY WORKING

---

## 🎮 GAME OVERVIEW

**Game Type:** Match-3 RPG Battle System  
**Platform:** iOS (SwiftUI)  
**Main View:** `Match3ContentView.swift` (renamed from ContentView.swift)  
**Folder:** `Match3Game/` (all game-specific files organized here)

### **Core Gameplay:**
- 8×8 grid of colorful gem tiles
- Match 3+ gems horizontally or vertically
- Different gem types have different battle effects
- Turn-based combat between Ramp (player) and Ednar (enemy)
- Special abilities activated via coffee cup button
- Bonus tiles that clear entire rows/columns

---

## 📁 MATCH-3 FILE STRUCTURE

```
Match3Game/
├─ Match3ContentView.swift       // Main game container & screen management
├─ GameViewModel.swift            // Core game logic & state management  
├─ BattleManager.swift            // Battle mechanics, damage, health
├─ BoardManager.swift             // Board state, matching, gravity
├─ GameBoardView.swift            // 8×8 grid visual rendering
├─ BattleSceneView.swift          // Character portraits, health, UI
├─ TileType.swift                 // Gem types & tile data models
├─ GameOverView.swift             // Victory/defeat screen
├─ GameHUDview.swift              // Top HUD (score, pause button)
├─ DebugMenuView.swift            // Debug tools (force matches, spawn bonuses)
├─ GameMode.swift                 // Swap vs Chain mode enum
├─ BattleEvent.swift              // Battle narrative message model
├─ BonusTileConfig.swift          // Bonus tile settings
├─ BonusBlastEffects.swift        // Row/column blast visual effects
├─ ChainComboEffects.swift        // Power Surge effect (4+ matches)
├─ ChainInputHandler2.swift       // Chain mode input handling
├─ ChainVisualConfig.swift        // Chain mode visual settings
├─ Ability.swift                  // Special ability enum & data
└─ PoisonPillScreenEffect.swift   // Poison damage screen effect
```

**Shared Files** (in `/Shared` folder, used by all games):
- `Character.swift` - Character data models
- `GameAssets.swift` - Asset names & UI config
- `BattleMechanicsConfig.swift` - All battle numbers centralized
- `CharacterAnimations-Shared.swift` - Character animation system
- `HapticManager.swift` - Haptic feedback

---

## 🎯 GAME MECHANICS

### **Match-3 Board**
- **Size:** 8×8 grid (64 tiles total)
- **Tile Types:** 6 types
  - ⚔️ Sword (red) - Physical damage
  - 🔥 Fire (orange) - Magic damage
  - 🛡️ Shield (blue) - Grants shield points
  - ❤️ Heart (pink) - Heals player
  - 💎 Mana (purple) - Charges abilities
  - ☠️ Poison (green) - Damages player
- **Matching:** 3+ tiles horizontally or vertically
- **Swap Modes:**
  - **Swap Mode** (default) - Tap two adjacent tiles to swap
  - **Chain Mode** - Draw line connecting same-type tiles

### **Battle System**
- **Player:** Ramp (barbarian warrior) - left side
- **Enemy:** Ednar (Toad King boss) - right side
- **Health:** 100 HP (player) vs 200 HP (enemy)
- **Mana:** Max 7 mana (displayed on coffee cup button)
- **Shield:** Temporary damage absorption (shows badge on portrait)

### **Gem Effects**
| Gem Type | Effect | Value |
|----------|--------|-------|
| ⚔️ Sword | Physical damage to enemy | 8 per gem |
| 🔥 Fire | Magic damage to enemy | 12 per gem |
| 🛡️ Shield | Grant shield to player | 5 per gem |
| ❤️ Heart | Heal player HP | 10 per gem |
| 💎 Mana | Charge ability mana | 1 per gem |
| ☠️ Poison | Damage to player | 3 per gem |

*All values configurable in `BattleMechanicsConfig.swift`*

### **Combo System**
- Match multiple groups in one turn → 1.5× damage multiplier
- Example: 3 swords (24 damage) + 3 fires (36 damage) = 60 damage → ×1.5 = **90 damage**

### **Power Surge Effect**
- Triggers on 4+ tile matches in a single turn
- Full-screen blue lightning effect
- Giant "⚡ POWER SURGE! ⚡" text
- Awards +2 bonus mana
- 100% code-based visual effect (no images required)

---

## ☕ SPECIAL ABILITIES

### **Coffee Cup Button**
- **Location:** Left side of battle scene, centered
- **Visual:** Circular button with pie chart fill (shows current mana)
- **Cost:** 5 mana to activate
- **Function:** Opens gem selector popup
- **States:**
  - Grey (disabled): mana < 5 or processing
  - Orange (enabled): mana ≥ 5 and ready

### **Gem Selector Popup**
- **Trigger:** Click coffee cup when mana ≥ 5
- **Display:** 6 gem type buttons in circular arrangement
- **Position:** Below coffee cup (44% down screen)
- **Scale:** 1.5× for better tap targets
- **Animation:** Gems pop in order (Mana → Poison → Sword → Fire → Shield → Heart)
- **Effect:** Clears ALL gems of selected type from board
- **Damage:** (Number of gems) × (gem effect value)

**Example:**
- 12 swords on board → Clear all → 12 × 8 = **96 damage to enemy**

---

## 💥 BONUS TILES

### **Spawning Conditions**
- **5-gem straight line** (horizontal or vertical) → Spawns at center
- **L-shape** (3 horizontal + 3 vertical sharing corner = 5 unique) → Spawns at corner
- **Image:** `coffee_bonus.png` (static coffee cup)
- **Glow:** Animated golden glow effect

### **Bonus Tile Behavior**
- ✅ Immune to auto-matching (won't get caught in cascades)
- ✅ Breaks match chains (3 Red + Bonus + 3 Red = TWO separate matches)
- ✅ Can always be swapped (bypasses stability check)
- ✅ Falls with gravity like normal gems
- ✅ Persists until player swipes it

### **Activation**
- **Horizontal swipe** (left/right) → Clears entire row
- **Vertical swipe** (up/down) → Clears entire column
- **Effect:** Applies ALL gem type effects in cleared line
  - Example: Row with 3 swords, 2 fires, 2 hearts
  - Result: 6 sword damage + 6 fire damage + 6 HP healing

### **Cross Blast** (Super Combo)
- Swap TWO bonus tiles together
- Clears BOTH row AND column simultaneously
- Combines gem counts from both directions
- **+** shaped blast pattern

---

## 🏗️ ARCHITECTURE

### **Screen Layout**
```
Match3ContentView
├─ GameHUDView (60pt height)
│  ├─ Score display
│  └─ Pause button
├─ BattleSceneView (42% of screen)
│  ├─ Character Portraits (side-by-side)
│  │  ├─ Ramp (player) + Health Bar + Shield Badge
│  │  └─ Ednar (enemy) + Health Bar
│  └─ Status & Info (side-by-side)
│     ├─ Coffee Cup Button
│     └─ Battle Narrative (last 3 messages)
└─ GameBoardView (58% of screen)
   └─ 8×8 grid of gem tiles
```

### **Overlay System**
```
ZStack (z-index layers):
├─ Base Game Screen (z: 0)
├─ Tap-away overlay (z: 90) - dismisses gem selector
├─ Gem selector popup (z: 200) - when coffee cup pressed
├─ Power Surge effect (z: 500) - full screen lightning
├─ Pause menu (z: 1000) - when pause button pressed
└─ Game over screen (z: auto) - victory/defeat
```

---

## ✅ WHAT WORKS (CONFIRMED)

### **Core Features**
- ✅ 8×8 Match-3 board with 6 gem types
- ✅ Smooth swap animations (0.4s ease-in-out)
- ✅ Raindrop cascade spawning (gems fall from top)
- ✅ Bottom-to-top initial board fill
- ✅ Gravity and auto-matching after swaps
- ✅ Match detection (3+ horizontal/vertical)
- ✅ Cascade processing (chain reactions)

### **Battle System**
- ✅ Health bars with color coding (green/yellow/red)
- ✅ Shield system with badge display
- ✅ Mana charging and pie chart display
- ✅ Battle narrative with slide-in animation
- ✅ Enemy turn with random damage (8-15)
- ✅ Victory/defeat detection
- ✅ Game over screen with "Play Again"

### **Gestures & Input**
- ✅ Swipe to swap (25+ pixel threshold)
- ✅ Tap-to-select two-tap swap
- ✅ No stuck selection boxes (fixed Session 19)
- ✅ Drag feedback (gems follow finger)
- ✅ Invalid swap shake animation

### **Special Features**
- ✅ Coffee cup ability (5 mana cost)
- ✅ Gem selector popup with animation
- ✅ Gem clearing with multiplied effects
- ✅ Bonus tile spawning (5-match, L-shapes)
- ✅ Bonus row/column blasts
- ✅ Cross blast (double bonus combo)
- ✅ PNG animation support for blasts
- ✅ Power Surge effect (4+ matches)
- ✅ Combo damage multiplier (1.5×)

### **Debug & Testing**
- ✅ Debug menu (orange hammer icon)
- ✅ Force 5-match for all gem types
- ✅ Manual bonus tile spawning
- ✅ Fill mana, HP, shield buttons
- ✅ Speed controls (skip pauses, async enemy)

---

## 🎨 ANIMATIONS

### **Raindrop Cascade** ⭐ CRITICAL FEATURE
**Overview:** New gems spawn with cascading effect from top

**User-Adjustable Constants** (GameBoardView.swift lines 23-25):
```swift
let RAINDROP_BASE_DELAY: Double = 0.15        // Delay between columns
let RAINDROP_RANDOMNESS: Double = 0.25        // Random variation
let RAINDROP_SPAWN_DURATION: Double = 0.4     // Fall duration
```

**Animation Components:**
- Scale: 30% → 100% (grow)
- Opacity: 0 → 100% (fade in)
- Offset: -150px above → final position (fall)
- Spring physics: `.spring(response: 0.4, dampingFraction: 0.7)`

**⚠️ PRESERVATION RULES:**
- Lines 276-323 in GameBoardView.swift are CRITICAL
- `spawnDelay > 0` conditional must NEVER be removed
- Separate from swap animations - do not modify when changing swap logic
- `hasAppeared` and `currentTileID` state tracking required

### **Gem Swap Animation**
- **Current:** `.easeInOut(duration: 0.4)`
- Silky smooth glide between positions
- Like Candy Crush or Bejeweled
- Adjustable: 0.3s (faster) to 0.5s (slower)

### **Springy Drag Gesture**
- **Current:** `.interpolatingSpring(stiffness: 250, damping: 20)`
- Bounce when releasing drag
- Fun, playful, tactile feel
- Adjustable: More springy (300/15), Less springy (200/25)

### **Match Disappear**
- **Current:** `.scale(0.01).combined(with: .opacity)`
- Shrink to nothing while fading
- Simple and clean

### **Battle Narrative Slide**
- Messages slide in from right edge
- `.asymmetric` transition (slide in, fade out)
- 0.3s spring animation
- Identity tracking with `.id(event.id)`

### **Gem Selector Pop**
- Gems appear in order: Mana → Poison → Sword → Fire → Shield → Heart
- 60ms stagger between each
- Bounce: 1.0 → 1.2 → 1.0 scale
- Creates clockwise wave effect

---

## 🔧 CONFIGURATION FILES

### **BattleMechanicsConfig.swift** (Battle Numbers)
```swift
// Character Stats
playerStartingHealth = 100
enemyStartingHealth = 200
maxMana = 7

// Gem Effects
swordDamagePerGem = 8
fireDamagePerGem = 12
shieldPerGem = 5
healingPerGem = 10
manaPerGem = 1

// Combo & Power Surge
comboMultiplier = 1.5
powerSurgeThreshold = 4
powerSurgeBonusMana = 2

// Enemy AI
enemyMinDamage = 8
enemyMaxDamage = 15

// Abilities
gemClearAbilityCost = 5
shieldAbilityCost = 4
shieldAbilityAmount = 25
healAbilityCost = 5
healAbilityAmount = 40
```

### **BonusTileConfig.swift** (Bonus Tiles)
```swift
enabled = true
minimumMatchSize = 5
enableGlow = true
glowSpeed = 1.0
glowColor = (1.0, 0.9, 0.3)  // Golden
imageName = "coffee_bonus"
allowMultiple = true
```

### **GameAssets.swift** (UI & Assets)
```swift
// Board Layout
boardSize = 8
specialTileThreshold = 4

// Visual Effects
enablePowerSurgeEffect = true

// Splash & Title
enableDeveloperSplash = true
splashDuration = 4.0
titleAnimationStyle = .floatAndPulse
```

---

## 🎯 BATTLE MECHANICS REFERENCE

### **Damage Calculation Examples**

**Example 1: Simple Match**
```
Match 3 swords
= 3 × 8 damage
= 24 damage to enemy
```

**Example 2: Combo Match**
```
Match 3 swords + 3 fires (in one turn)
= (3 × 8) + (3 × 12)
= 24 + 36 = 60 base damage
× 1.5 combo multiplier
= 90 damage to enemy
```

**Example 3: Power Surge**
```
Match 4 mana gems
= 4 × 1 = 4 mana
+ 2 bonus mana (Power Surge)
= 6 total mana gained
```

**Example 4: Gem Clear Ability**
```
12 swords on board
Clear all swords (costs 5 mana)
= 12 × 8 damage
= 96 damage to enemy
```

**Example 5: Bonus Row Blast**
```
Row contains: 3 swords, 2 fires, 2 hearts, 1 bonus tile
Effects applied:
- 3 × 8 = 24 sword damage
- 2 × 12 = 24 fire damage
- 2 × 10 = 20 HP healing
Total: 48 damage + 20 HP healed
```

---

## 🐛 KNOWN BUGS & FIXES

### **Fixed Issues:**

**Session 19 - Selection Box Bug** ✅
- **Problem:** Phantom selection boxes after "Play Again"
- **Fix:** Clear `selectedPosition` BEFORE board regeneration
- **Fix:** Mark gems stable after reset with 100ms delay
- **Result:** Works on both simulator and physical devices

**Session 19 - Battle Narrative Animation** ✅
- **Problem:** Messages "popping" instead of sliding
- **Fix:** Added `.id(event.id)` for identity tracking
- **Fix:** Changed to `.asymmetric` transition (slide in, fade out)
- **Result:** Smooth slide-in animation from right edge

**Session 17 - Bonus Tile Cascade** ✅
- **Problem:** Board staying empty after bonus blast
- **Fix:** Removed duplicate gravity/refill from bonus functions
- **Fix:** Manual refill in `performSwap()` before `processCascades()`
- **Result:** Cascades work normally after bonus blasts

**Session 16 - Game Over Delay** ✅
- **Problem:** Victory/defeat screen showing during animations
- **Fix:** Added `pendingGameOver` state
- **Fix:** Call `finalizeGameOver()` after all animations complete
- **Result:** Screen appears only after turn finishes

**Session 15 - Swipe/Tap Gesture** ✅
- **Problem:** Selection box appearing when trying to swipe
- **Fix:** Moved tap logic inside DragGesture `.onEnded`
- **Fix:** Only tap if drag < 25 pixels
- **Result:** Swipe and tap coexist perfectly

### **No Current Bugs**
All major issues resolved! Game is stable and fully playable.

---

## 🎮 DEBUG MENU

**Access:** Orange hammer icon in top-right corner

### **Quick Actions:**
- Fill Mana (set to 7)
- Full HP (restore to 100)
- Kill Enemy (reduce to 1 HP)
- +50 Shield

### **Board Manipulation:**
- Force 5-Match (all 6 gem types)
  - Spawns row of 5 same-type gems
  - Top row, columns 2-6
  - Triggers bonus tile spawn
- Spawn Coffee (3 positions available)
- Clear Board
- Remove All Bonuses

### **Battle Stats Display:**
- Real-time HP, Mana, Shield, Score
- Updates live during gameplay

### **Speed Controls:**
- Skip Waiting Pauses (toggle)
- Async Enemy Turn (toggle)
- Auto-Chain Speed (slider 0.5-2.0×)

### **Bonus Testing:**
- Spawn at (4,4)
- Spawn at (3,3)
- Spawn at (5,5)
- **Spawn TWO at (4,4) + (4,5)** - Cross blast test

---

## 📝 BATTLE NARRATIVE MESSAGES

**Location:** `BattleMechanicsConfig.swift`

**Message System:**
- Random selection from arrays (4-5 messages per type)
- Template placeholders: `{damage}`, `{amount}`, `{gemType}`
- Easy to expand (just add to arrays)

**Message Types:**
- Barbarian attack (sword matches)
- Magic attack (fire matches)
- Shield gain
- Healing
- Enemy attacks
- Power Surge
- Victory/Defeat
- Abilities (Gem Clear, Divine Shield, Greater Heal)
- Bonus blasts (Row, Column, Cross)

**Example Messages:**
```
"Ramp swings for {damage}!"
"Critical bonk! {damage} damage!"
"💥 POWER SURGE! {totalMatches} MATCHES! +{bonusMana} bonus mana!"
"⚔️ CROSS BLAST! → {damage} damage, +{shield} shield, +{healing} HP, +{mana} mana"
```

---

## 🚀 RESPONSIVE GAMEPLAY

**Speed Controls** (GameViewModel.swift lines 26-39):
```swift
var skipWaitingPauses: Bool = true      // Skip artificial delays
var asyncEnemyTurn: Bool = true         // Enemy attacks in background
```

### **Effect When Enabled:**
- Board unlocks ~60% faster
- Enemy turn doesn't block player input
- Power Surge pauses skipped
- All animations still play at same speed
- Damage applied instantly (animations are cosmetic)

### **Timing Comparison:**
| Event | Original | Responsive | Saved |
|-------|----------|-----------|-------|
| Pre-buzz pause | 150ms | 0ms | 150ms |
| Disappear wait | 300ms | 200ms | 100ms |
| Explosion cleanup | 100ms | 0ms | 100ms |
| Fall wait | 500ms | 300ms | 200ms |
| Spawn wait | ~560ms | ~390ms | ~170ms |
| Power Surge | 1600ms | 0ms | 1600ms |
| Pre-enemy pause | 400ms | 0ms | 400ms |
| **TOTAL** | **~2700ms** | **~1200ms** | **~1500ms** |

### **To Revert to Original:**
```swift
var skipWaitingPauses: Bool = false
var asyncEnemyTurn: Bool = false
```

---

## 📚 RECENT MAJOR CHANGES

**Session 22 (March 28, 2026)** - Project Reorganization
- Created `Match3Game/` folder
- Moved all 18 Match-3 files into folder
- Renamed `ContentView` → `Match3ContentView`
- Implemented dev switcher system

**Session 21 (March 26, 2026)** - Bonus Blast PNG Animation
- Support for custom hand-drawn PNG sequences
- 6 frames per direction (row + column)
- Separate positioning controls
- 12 FPS frame rate (adjustable)

**Session 20 (March 23, 2026)** - Gem Clear Effects Multiply
- Gem Clear: (gems cleared) × (effect) = total
- Bonus Blasts: Apply ALL gem type effects
- Cross Blast: Combine row + column counts

**Session 19 (March 22, 2026)** - Bug Fixes
- Fixed selection box after reset
- Fixed battle narrative animation
- Customized gem selector pop order

**Session 18.5 (March 22, 2026)** - Message Centralization
- Moved all battle text to `BattleMechanicsConfig.swift`
- Template system with placeholders

**Session 18 (March 22, 2026)** - Config Separation
- Created `BattleMechanicsConfig.swift`
- Separated battle mechanics from UI config
- All battle numbers centralized

---

## 🎨 ASSET REQUIREMENTS

### **Required Images:**
- `tile_sword.png` - Red sword gem
- `tile_fire.png` - Orange fire gem
- `tile_shield.png` - Blue shield gem
- `tile_heart.png` - Pink heart gem
- `tile_mana.png` - Purple mana gem
- `tile_poison.png` - Green poison gem
- `coffee_bonus.png` - Bonus tile (coffee cup)

### **Character Portraits:**
- `ramp_idle.png`, `ramp_attack.png`, `ramp_hurt.png`, `ramp_hurt2.png`
- `ednar_idle.png`, `ednar_attack.png`, `ednar_hurt.png`

### **Optional PNG Animations (Bonus Blasts):**
- `bonus_blast_row_1.png` through `bonus_blast_row_6.png` (2048×256px)
- `bonus_blast_col_1.png` through `bonus_blast_col_6.png` (256×2048px)

---

## 💡 FOR AI ASSISTANTS

### **When Modifying Match-3 Code:**

**CRITICAL RULES:**
1. ✅ **NEVER** modify raindrop cascade animation (lines 276-323 in GameBoardView.swift)
2. ✅ Always provide COMPLETE files or functions (never snippets)
3. ✅ Include Xcode step-by-step instructions
4. ✅ Test on both swap and chain modes
5. ✅ Verify board state after changes
6. ✅ Check debug menu still works

**Common Tasks:**
- Adjust battle numbers → Edit `BattleMechanicsConfig.swift`
- Change gem effects → Edit values in `BattleMechanicsConfig.swift`
- Add battle messages → Add to arrays in `BattleMechanicsConfig.swift`
- Modify animations → Edit GameBoardView.swift (preserve raindrop!)
- Debug board issues → Use Debug Menu (hammer icon)

**Files to Check:**
- Match-3 changes → Edit files in `Match3Game/` folder
- Shared code → Only if affects all games
- Configuration → `BattleMechanicsConfig.swift` or `BonusTileConfig.swift`

---

**END OF MATCH-3 CONTEXT**

For project-wide information, see: `MASTER_CONTEXT.md`  
For Physics Chain Game, see: `PHYSICS_CONTEXT.md`
