# AI_Context
**OverQuestMatch3 - Multi-Game Project**

> **CRITICAL READING INSTRUCTIONS**: 
> 1. Read this ENTIRE AI_CONTEXT.md file FULLY at the start of EVERY conversation
> 2. Read everything in the ReadFilesForContext/ folder FULLY
> 3. Read STRUCTURE_CONTEXT.md for complete project organization details
> 
> **CODING RULES**:
> - Provide applicable OR copy-pasteable code ONLY (ideally applicable)
> - Make NO assumptions - ask clarifying questions if anything is unclear
> - Ask for full code paste or folder structure refresh if needed
> - **PREVENT BREAKING ANYTHING** - User does not know how to code
> - Always ask questions instead of making assumptions to prevent errors

---

## 🎮 PROJECT OVERVIEW

**Project Type**: Multi-game collection with integrated progression system
**Current Games**: 
- Match-3 RPG Battle (✅ COMPLETE & WORKING)
- Physics Chain Game (⚠️ CODE COMPLETE - Debugging tile display issue)
- Cooking Game (planned)
- Potion Solitaire (planned)
- Map Navigation System (planned)

**Platform**: iOS (SwiftUI)
**User's Coding Experience**: The user knows NOTHING about coding or Xcode - always provide complete, copy-paste-ready code

---

## 📁 PROJECT STRUCTURE (POST-REORGANIZATION)

### ✅ REORGANIZATION COMPLETE (March 28, 2026)

The project has been reorganized from a single-game structure into a multi-game architecture with clean separation.

**Root Level:**
- **OverQuestMatch3App.swift** - ✨ **UPDATED** - Main app entry with dev switcher system

**New Folder Structure:**

```
OverQuestMatch3/ (ROOT)
├─ OverQuestMatch3App.swift ✅ (dev switcher implemented)
├─ Match3Game/ ✅ (all Match-3 specific files)
│  ├─ Match3ContentView.swift ✅ (renamed from ContentView)
│  ├─ GameViewModel.swift
│  ├─ BattleManager.swift
│  ├─ BoardManager.swift
│  ├─ GameBoardView.swift
│  ├─ BattleSceneView.swift
│  ├─ TileType.swift
│  ├─ GameOverView.swift
│  ├─ GameHUDview.swift
│  ├─ DebugMenuView.swift
│  ├─ PoisonPillScreenEffect.swift
│  ├─ BonusBlastEffects.swift
│  ├─ GameMode.swift
│  ├─ BattleEvent.swift
│  ├─ BonusTileConfig.swift
│  ├─ ChainComboEffects.swift
│  ├─ ChainInputHandler2.swift
│  ├─ Ability.swift
│  └─ ChainVisualConfig.swift
├─ Shared/ ✅ (code used by ALL games)
│  ├─ Character.swift
│  ├─ GameAssets.swift
│  ├─ BattleMechanicsConfig.swift
│  ├─ CharacterAnimations-Shared.swift
│  └─ HapticManager.swift
├─ PhysicsChainGame/ ✅ (complete - Tsum-Tsum style physics game)
├─ CookingGame/ ✅ (empty - ready for development)
├─ PotionSolitaireGame/ ✅ (empty - ready for development)
├─ Navigation/ ✅ (empty - ready for development)
├─ Utilities/ (existing - unchanged)
├─ Models/ (existing - mostly empty after migration)
└─ ReadFilesForContext/ (context docs - unchanged)
```

### 🎯 Dev Switcher System

**Location**: `OverQuestMatch3App.swift` (Line 25)

```swift
private let currentGame: GameType = .match3
```

**Available Game Types:**
- `.match3` - Match-3 RPG Battle Game (✅ WORKING)
- `.physicsChain` - Physics Chain Game (⚠️ CODE COMPLETE - tiles not rendering yet)
- `.cooking` - Cooking Game (coming soon)
- `.potionSolitaire` - Potion Solitaire Game (coming soon)
- `.mapNavigation` - Map Navigation System (coming soon)

**How It Works:**
- Change the `currentGame` value to switch between games
- Match-3 game launches `Match3ContentView()` (✅ WORKING)
- Physics Chain game launches `PhysicsChainGameView()` (⚠️ background shows, tiles not rendering)
- Other games show "Coming Soon" placeholder views
- Easy to test individual games during development

### Core Match-3 Files (Now in Match3Game/)
- **Match3ContentView.swift** - Main Match-3 container with screen management (RENAMED from ContentView.swift)
- **BattleSceneView.swift** - Character portraits, health bars, battle UI, coffee cup ability button
- **GameBoardView.swift** - Match-3 game board (8x8 grid)
- **GameViewModel.swift** - Main game logic and state management
- **BattleManager.swift** - Battle mechanics, damage, health, mana logic
- **BoardManager.swift** - Board state, matching logic, gravity, spawning

### Shared Files (Used by ALL games)
- **Character.swift** - Character data models
- **GameAssets.swift** - Asset names and UI configuration (non-battle)
- **BattleMechanicsConfig.swift** - All battle numbers (damage, health, abilities) centralized here
- **CharacterAnimations-Shared.swift** - Character animation system
- **HapticManager.swift** - Haptic feedback system

### UI Screens (Match-3 Specific)
- **TitleScreenView.swift** - Opening title screen
- **MapScreenView.swift** - Map selection (shows after title screen)
- **PauseMenuView.swift** - Full-screen pause overlay
- **GameOverView.swift** - Victory/defeat screen

---

## 🎯 CURRENT GAME MECHANICS

### Match-3 Board
- **Size**: 8x8 grid of tiles
- **Tile Types**: Sword, Fire, Shield, Heart, Mana, Poison
- **Matching**: Match 3+ tiles horizontally or vertically
- **Effects**: Different tiles have different battle effects

### Battle System
- **Player Character**: "Ramp" (left side)
- **Enemy Character**: "Ednar" (right side)
- **Health System**: Both characters have health bars with color coding (green > 50%, yellow > 25%, red < 25%)
- **Shield System**: Shield badge appears in top-right of character portrait when shield > 0
- **Mana System**: Max 7 mana, displayed via pie chart fill on coffee cup button

### Special Ability - Coffee Cup
- **Location**: Left side of battle scene, centered
- **Cost**: 5 mana to activate
- **Function**: Opens gem selector to clear all tiles of a chosen type
- **Visual**: Circular button with pie chart fill showing current mana (0-7)
- **States**: 
  - Disabled (grey) when mana < 5 or processing
  - Enabled (orange) when affordable
  - Fill animation shows mana percentage

### Gem Selector (Special Ability UI)
- **Trigger**: Click coffee cup button when mana >= 5
- **Display**: Popup overlay with 6 tile type buttons
- **Position**: BELOW the coffee cup button (height: 0.44 of screen)
- **Scale**: 1.5x for better visibility
- **Behavior**: 
  - Appears ONLY when coffee button is pressed
  - Click any gem type to clear all of that type from board
  - Click outside to dismiss
  - Has dark overlay behind it
- **Location**: Managed in ContentView.swift (lines 90-103)

---

## 🏗️ ARCHITECTURE DETAILS

### BattleSceneView.swift Layout
```
ZStack {
    Background Gradient
    VStack {
        SECTION 1: Character Portraits (side-by-side HStack)
            - Left: Player (Ramp) + Health Bar + Shield Badge
            - Right: Enemy (Ednar) + Health Bar
        
        SECTION 2: Status & Info (side-by-side HStack)
            - Left: Coffee Cup Ability Button (centered)
            - Right: Battle Narrative (3 recent event messages)
    }
}
```

### ContentView.swift Overlay System
```
ZStack {
    GameScreen (if not on title/map)
    MapScreen (if showing)
    TitleScreen (if showing)
    PauseMenu (if showing)
    
    // Inside GameScreen:
    GeometryReader {
        ZStack {
            VStack {
                GameHUDView (60pt height)
                BattleSceneView (42% of screen)
                GameBoardView (58% of screen)
            }
            
            // Overlays (z-indexed):
            - Tap-away overlay (z: 90) - for gem selector dismissal
            - Gem selector popup (z: 200) - positioned at 0.44 height
            - Game over screen
        }
    }
}
```

---

## ✅ WHAT WORKS (TESTED & CONFIRMED)

1. **Selection Box Reset Bug** ✨ **FIXED IN SESSION 19!**
   - No more phantom selection boxes after victory/reset
   - Works correctly on both simulator AND physical devices
   - Proper state clearing order prevents race conditions
   - Gems are immediately swappable after "Play Again"
   - Board is marked stable after reset

2. **Battle Narrative Slide Animation** ✨ **FIXED IN SESSION 19!**
   - Messages smoothly slide in from the right edge
   - No more "popping" into view
   - Asymmetric transitions (slide in, fade out)
   - Identity tracking with `.id(event.id)` works perfectly
   - 0.3s spring animation with 0.75 damping

3. **Gem Selector Animation** ✨ **CUSTOMIZED IN SESSION 19!**
   - Gems pop in custom order: Mana → Poison → Sword → Fire → Shield → Heart
   - Creates clockwise-ish wave effect from bottom-left
   - 60ms stagger between each gem (adjustable)
   - Bounce animation (1.0 → 1.2 → 1.0) with spring physics
   - Visual positions unchanged, only timing modified

4. **Battle Narrative Messages** ✨ **CENTRALIZED IN SESSION 18.5!**
   - ALL battle messages now in BattleMechanicsConfig.swift
   - Random message selection from arrays (4-5 messages per type)
   - Template system with placeholders: {damage}, {amount}, {gemType}
   - Easy to expand (add more messages without code changes)
   - Special event messages included (Power Surge, Victory, Defeat, Abilities)

5. **Swipe/Tap Gesture System** ✨ **FIXED IN SESSION 15!**
   - Swipe gestures work smoothly (drag 25+ pixels to swap)
   - Tap-to-select still works (tap gem, then tap adjacent gem)
   - No more stuck selection boxes when swiping
   - Both input methods coexist perfectly
   - Visual drag feedback (gems follow finger)
   - Quick flick gestures responsive

6. **Coffee Cup Button**
   - Displays correctly on battle scene
   - Shows mana fill with pie chart animation
   - Disables when mana < 5
   - Triggers gem selector popup

7. **Gem Selector Popup**
   - Appears BELOW coffee button when activated
   - Shows all 6 tile types with proper images
   - Clears tiles when clicked
   - Dismisses when tapping outside
   - Properly scaled and positioned

8. **Battle Scene Layout**
   - Characters display side-by-side
   - Health bars animate properly
   - Shield badges show when shield > 0
   - Battle narrative shows 3 recent events

9. **No Duplicate Gem Selectors**
   - Removed permanent gem selector from BattleSceneView
   - Only popup version exists (in ContentView)

10. **4-Match Power Surge Effect** ✨ **FULLY WORKING!**
   - Triggers on 4+ tile matches in any single turn
   - Full-screen golden lightning bolts flash across entire game
   - Giant "⚡ POWER SURGE! ⚡" text with floating animation
   - Screen flash effect (yellow fade)
   - Awards +2 bonus mana automatically
   - Battle narrative announces: "⚡ POWER SURGE! X MATCHES! +2 bonus mana!"
   - Easy to toggle on/off: `GameConfig.enablePowerSurgeEffect`
   - Adjustable threshold: `GameConfig.powerSurgeChainThreshold` (default: 4)
   - Adjustable bonus: `GameConfig.powerSurgeManaBonus` (default: 2)
   - 100% code-based - no image assets required

11. **🌧️ RAINDROP CASCADE ANIMATION - COMPREHENSIVE REFERENCE** ✨ **WORKING PERFECTLY!**
   
   **Overview:**
   - New gems spawn with cascading "raindrop" effect from top of screen
   - Gems fall from above with delay, fade-in, and scale-up animation
   - CRITICAL: This is SEPARATE from swap animations - modifications must preserve this!
   
   **User-Adjustable Constants (Lines 23-25):**
   ```swift
   let RAINDROP_BASE_DELAY: Double = 0.15        // Delay between each column starting
   let RAINDROP_RANDOMNESS: Double = 0.25        // Random variation added to each column
   let RAINDROP_SPAWN_DURATION: Double = 0.4     // How long each gem takes to fall
   ```
   
   **Animation Components (Lines 276-280 in GemTileView):**
   ```swift
   // Scale: Gems start at 30% size, grow to 100%
   .scaleEffect(hasAppeared ? 1.0 : (spawnDelay > 0 ? 0.3 : 1.0))
   
   // Opacity: Gems start invisible, fade to fully visible
   .opacity(hasAppeared ? 1.0 : (spawnDelay > 0 ? 0.0 : 1.0))
   
   // Offset: Gems start 150 pixels above their final position
   .offset(y: hasAppeared ? 0 : (spawnDelay > 0 ? -150 : 0))
   ```
   
   **Spawn Logic (Lines 283-307):**
   ```swift
   .onChange(of: tile.id) { _, newID in
       if currentTileID != newID {
           currentTileID = newID
           
           // CRITICAL: Only animate if spawnDelay > 0
           if spawnDelay > 0 {
               hasAppeared = false
               
               Task {
                   try? await Task.sleep(for: .seconds(spawnDelay))
                   // Spring animation for smooth landing
                   withAnimation(.spring(response: RAINDROP_SPAWN_DURATION, dampingFraction: 0.7)) {
                       hasAppeared = true
                   }
               }
           } else {
               // No spawn delay = swap/move, appear instantly
               hasAppeared = true
           }
       }
   }
   ```
   
   **Initial Appearance Logic (Lines 309-323):**
   ```swift
   .onAppear {
       currentTileID = tile.id
       
       if spawnDelay > 0 {
           hasAppeared = false
           Task {
               try? await Task.sleep(for: .seconds(spawnDelay))
               withAnimation(.spring(response: RAINDROP_SPAWN_DURATION, dampingFraction: 0.7)) {
                   hasAppeared = true
               }
           }
       } else {
           hasAppeared = true
       }
   }
   ```
   
   **State Variables Required (Lines 232-234):**
   ```swift
   @State private var hasAppeared = false      // Tracks if spawn animation completed
   @State private var currentTileID: UUID?     // Tracks tile ID changes for spawn detection
   ```
   
   **How spawnDelay is Set:**
   - Set by `BoardManager.swift` during board refill operations
   - Different delays per tile position create cascading effect
   - Pass to `GemTileView` via parameter: `spawnDelay: viewModel.boardManager.spawnDelays[position] ?? 0`
   
   **Bottom-to-Top Initial Fill (BoardManager.swift):**
   - Special function: `fillEmptySpacesWithBottomUpRaindrop()`
   - Creates wave effect: bottom row first, then each row up
   - Formula: `baseDelay = Double(rowIndex) * 0.1`
   - Used ONLY on game start/reset
   
   **Gameplay Refill (BoardManager.swift):**
   - Function: `fillEmptySpacesWithRaindrop()`
   - Random delays across columns
   - Used during normal gameplay after matches
   
   **⚠️ CRITICAL PRESERVATION RULES:**
   - Lines 276-323 must NEVER be modified when changing swap animations
   - `spawnDelay > 0` conditional is crucial - DO NOT remove
   - Spring animation parameters (.spring(response:dampingFraction:)) are tuned perfectly
   - hasAppeared state tracking must remain intact
   - currentTileID tracking must remain intact
   
   **Related Files:**
   - GameBoardView.swift (lines 276-323) - Animation implementation
   - BoardManager.swift - Spawn delay calculation and assignment
   - GridPosition.swift - Position tracking for delays

12. **💎 GEM SWAP ANIMATION** ✅ **WORKING PERFECTLY!**
   - **Current Configuration**: `.easeInOut(duration: 0.4)` (lines 200-201)
   - Gems glide smoothly when swapping positions
   - Silky smooth ease-in/ease-out curve (like Candy Crush)
   - 0.4 seconds duration (adjustable: 0.3 = faster, 0.5 = slower)
   - Alternative styles available: linear, spring physics
   - Full adjustment guide in Session 8 documentation

13. **🎮 SPRINGY DRAG GESTURE** ✅ **WORKING PERFECTLY!**
   - **Current Configuration**: `.interpolatingSpring(stiffness: 250, damping: 20)` (line 378)
   - Gems bounce slightly when released from drag
   - Fun, playful, tactile feel when moving gems around
   - Responsive and game-like
   - Adjustable: More springy (300/15), Less springy (200/25)

14. **🎯 MATCH DISAPPEAR ANIMATION** ✅ **WORKING PERFECTLY!**
   - **Current Configuration**: `.scale(scale: 0.01).combined(with: .opacity)` (lines 193-198)
   - Matched gems shrink to nearly nothing while fading out
   - Simple, clean removal - no wiggle, no buzz
   - Old code style

15. **⚠️ INVALID SWAP SHAKE** ✅ **WORKING PERFECTLY!**
   - **Current Configuration**: `startShaking()` function (lines 321-328)
   - Gentle shake when attempting invalid swap
   - Settings: 6 repeats, ±5 pixels, 0.05s duration, 0.3s timeout
   - Old code style

---

## ❌ KNOWN ISSUES

**Physics Chain Game - Tiles Not Displaying (Current Session)**
- Game builds successfully
- All code files created and integrated
- PhysicsChainGameView shows background and score header
- **Issue:** Tiles are not rendering on screen (90 tiles should be visible)
- **Files Complete:** PhysicsChainGameView.swift, PhysicsGameViewModel.swift, PhysicsTileView.swift, PhysicsTile.swift, PhysicsTileType.swift, PhysicsGameConfig.swift
- **Status:** Investigating display issue

**Recent Fixes:**
- ✅ Session 17: Bonus tile cascade bug fixed - board refills properly
- ✅ Session 16: Game over screen delay fixed - animations complete first
- ✅ Session 15: Swipe/tap gesture bug fixed - no more stuck selection boxes

---

## 🔧 RECENT CHANGES

### Session 24: Physics Chain Game - Debugging Tile Display (March 28, 2026) 🔧 IN PROGRESS

**Goal:**
- Fix tiles not displaying in Physics Chain Game
- All code is complete and builds successfully
- Background and UI showing correctly, but 90 tiles not visible

**Status:**
- ✅ All 6 game files created and integrated
- ✅ App builds without errors
- ✅ Dev switcher routing to PhysicsChainGameView correctly
- ⚠️ Tiles not rendering (investigating)

**Files Verified:**
- PhysicsChainGameView.swift (184 lines) - Main game UI
- PhysicsGameViewModel.swift (303 lines) - Physics engine and game logic
- PhysicsTileView.swift (28 lines) - Tile rendering
- PhysicsTile.swift (26 lines) - Tile model
- PhysicsTileType.swift (54 lines) - Tile types with image names
- PhysicsGameConfig.swift (79 lines) - Configuration

**⚠️ MISLEADING DOCUMENTATION FILES (SHOULD BE DELETED OR ARCHIVED):**
- PHYSICS_CHAIN_GAME_COMPLETE.md - Says game is "ready to play" but tiles don't render
- QUICK_START_PHYSICS_CHAIN.md - Has play instructions for non-working game

**Next Steps:**
- Investigating why ForEach tiles not rendering
- Checking viewModel initialization
- Verifying tile spawning logic

---

### Session 23: Physics Chain Game - Complete Implementation (March 28, 2026) ⚠️ CODE COMPLETE - TILES NOT RENDERING

**Goal:**
- Create complete Tsum-Tsum style physics-based chain matching game
- Implement in the PhysicsChainGame/ folder
- Use existing Match-3 tile images
- Fully self-contained game with dev switcher integration

**What Was Completed:**

**6 New Files Created in PhysicsChainGame/ folder:**
1. **PhysicsTileType.swift** (54 lines)
   - Defines 6 tile types: Sword, Fire, Shield, Heart, Mana, Poison
   - Reuses Match-3 image names (tile_sword, tile_fire, etc.)
   - Color and glow properties for each type

2. **PhysicsTile.swift** (26 lines)
   - @Observable tile model with physics properties
   - Tracks position, velocity, selection state, match state
   - Unique ID for SwiftUI identity

3. **PhysicsGameConfig.swift** (79 lines)
   - Complete configuration system with 80+ adjustable settings
   - Physics settings: gravity, bounce, friction, collision
   - Gameplay rules: minimum chain length, connection distance, scoring
   - Visual settings: colors, glow effects, animations
   - Helper functions for random spawning

4. **PhysicsTileView.swift** (28 lines)
   - Visual rendering of individual tiles
   - Glow effect when selected
   - Shrink/fade animation when matched
   - Uses existing Match-3 tile images

5. **PhysicsGameViewModel.swift** (303 lines)
   - Complete 60 FPS physics engine
   - Tile spawning and respawning
   - Collision detection (tile-to-tile, walls, floor)
   - Chain matching with backtracking support
   - Score and combo tracking

6. **PhysicsChainGameView.swift** (184 lines)
   - Main game UI with score header and combo display
   - Game board with physics simulation
   - Drag gesture for chain building
   - Animated chain line view with smooth curves
   - Timer setup and cleanup

**Files Modified:**
1. **OverQuestMatch3App.swift**
   - Updated `.physicsChain` case to show `PhysicsChainGameView()`
   - Removed placeholder, now shows actual game

**Game Features Implemented (CODE COMPLETE):**
✅ 90 falling tiles with realistic physics (code written)
✅ Gravity, bouncing, air resistance, friction (code written)
✅ Tile-to-tile collision detection (code written)
✅ Wall and floor bouncing (code written)
✅ Chain matching (drag across same-type tiles) (code written)
✅ Backtracking (undo last tile in chain) (code written)
✅ Minimum 3-tile requirement (code written)
✅ Adjacent connection requirement (1.5× tile distance) (code written)
✅ Score system (10 points per tile) (code written)
✅ Combo system (+5 points per combo level) (code written)
✅ Auto-respawn new tiles after matches (code written)
✅ Smooth animated chain line (code written)
✅ Glow effects on selected tiles (code written)
✅ Match disappear animation (code written)

**Physics System Details (CODE WRITTEN):**
- **60 FPS update loop** using Timer
- **Gravity:** 0.9 constant downward acceleration
- **Bounce:** 0.7 coefficient (70% energy retained)
- **Collision:** Soft/hard collision based on relative velocity
- **Max velocity:** 12.0 (prevents runaway speeds)
- **Resting threshold:** 0.1 (stops nearly-still tiles)

**⚠️ CURRENT ISSUE:**
- **All code is written and builds successfully**
- **Background and UI display correctly**
- **BUT: 90 tiles are NOT rendering on screen**
- Debugging in Session 24

**Files in PhysicsChainGame/ folder:**
- PhysicsTileType.swift ✅
- PhysicsTile.swift ✅
- PhysicsGameConfig.swift ✅
- PhysicsTileView.swift ✅
- PhysicsGameViewModel.swift ✅
- PhysicsChainGameView.swift ✅

**Status**: ⚠️ Code complete, but tiles not displaying - debugging in progress (Session 24)

---

### Session 22: Project Reorganization - Multi-Game Architecture (March 28, 2026) ✅ COMPLETE

**Goal:**
- Transform single-game project into multi-game project structure
- Create clean separation between game types
- Implement dev switcher for easy game selection during development
- Prepare for 4 additional game types + navigation system

**What Was Completed:**

**Step 1: Folder Structure Creation**
- Created 6 new folder groups in Xcode:
  - `Match3Game/` - All Match-3 specific files
  - `Shared/` - Code used by ALL game types
  - `PhysicsChainGame/` - Empty (ready for development)
  - `CookingGame/` - Empty (ready for development)
  - `PotionSolitaireGame/` - Empty (ready for development)
  - `Navigation/` - Empty (ready for development)

**Step 2: File Migration**
- Moved 18 Match-3 specific files into `Match3Game/` folder:
  - GameViewModel.swift, BattleManager.swift, BoardManager.swift
  - GameBoardView.swift, BattleSceneView.swift, TileType.swift
  - GameOverView.swift, GameHUDview.swift, DebugMenuView.swift
  - PoisonPillScreenEffect.swift, BonusBlastEffects.swift
  - GameMode.swift, BattleEvent.swift, BonusTileConfig.swift
  - ChainComboEffects.swift, ChainInputHandler2.swift
  - Ability.swift, ChainVisualConfig.swift

- Moved 5 shared files into `Shared/` folder:
  - Character.swift, GameAssets.swift, BattleMechanicsConfig.swift
  - CharacterAnimations-Shared.swift (renamed from CharacterAnimations.swift)
  - HapticManager.swift

**Step 3: ContentView Rename**
- Renamed `ContentView.swift` → `Match3ContentView.swift`
- Updated struct name: `struct Match3ContentView: View`
- Updated Preview: `#Preview { Match3ContentView() }`
- Fixed Preview reference (was showing old `ContentView()`)

**Step 4: Dev Switcher Implementation**
- Updated `OverQuestMatch3App.swift` with complete dev switcher system
- Added `GameType` enum with 5 game options:
  ```swift
  enum GameType {
      case match3
      case physicsChain
      case cooking
      case potionSolitaire
      case mapNavigation
  }
  ```
- Added switcher variable: `private let currentGame: GameType = .match3`
- Implemented switch statement to route to correct game
- Created `PlaceholderView` for future games (shows "Coming Soon")

**Step 5: Testing & Verification**
- ✅ App builds without errors
- ✅ Match-3 game launches and runs perfectly
- ✅ All existing features work (battle, combos, bonus tiles, etc.)
- ✅ Dev switcher ready to toggle between game types

**Benefits:**
- ✅ Clean separation between game types
- ✅ Easy to work on one game at a time
- ✅ Simple to test individual games
- ✅ Ready for map/navigation system later
- ✅ No Match-3 functionality affected

**How Dev Switcher Works:**
```swift
// In OverQuestMatch3App.swift, line 25:
private let currentGame: GameType = .match3  // Change this to switch games

// Options:
.match3          → Launches Match3ContentView() (working game)
.physicsChain    → Shows "Physics Chain Game - Coming Soon"
.cooking         → Shows "Cooking Game - Coming Soon"
.potionSolitaire → Shows "Potion Solitaire Game - Coming Soon"
.mapNavigation   → Shows "Map Navigation - Coming Soon"
```

**Files Created:**
- STRUCTURE_CONTEXT.md - Complete reorganization tracker and reference guide

**Files Modified:**
- OverQuestMatch3App.swift - Added dev switcher system
- Match3ContentView.swift - Renamed from ContentView.swift, fixed Preview

**Files Moved:**
- 18 files → Match3Game/ folder
- 5 files → Shared/ folder

**Documentation:**
- STRUCTURE_CONTEXT.md contains:
  - Complete step-by-step reorganization guide
  - Current project structure diagram
  - Target project structure diagram
  - File movement tracking
  - Why we're doing this (multi-game expansion plan)
  - Instructions for continuing in new chat sessions

**Future Game Plans:**
1. **Physics Chain Game** - Falling bubble physics with chain matching
2. **Cooking Game** - Real-time cooking resource management
3. **Potion Solitaire** - Card-based potion crafting puzzle
4. **Map Navigation** - Story-driven map connecting all games

**Status**: ✅ Reorganization 100% complete! Ready to build new games! 🎮✨

---

### Session 19: Bug Fixes & Gem Selector Animation (March 22, 2026) ✅ COMPLETE

**Goal:**
- Fix selection box bug after victory/reset (especially noticeable on physical devices)
- Fix battle narrative slide animation (messages were popping instead of sliding)
- Customize gem selector animation order to create clockwise wave effect

**Items Completed**: 3/3 ✅

---

#### Issue 1: Selection Box Bug After Victory - FIXED ✅

**Problem:**
- After winning/losing and clicking "Play Again", yellow selection box would appear and prevent gem swapping
- More noticeable on physical devices due to faster state changes than simulator

**Root Cause:**
- `pendingGameOver` state not cleared in `BattleManager.reset()`
- `selectedPosition` and other visual states not cleared in proper order in `GameViewModel.resetGame()`
- Gems not marked as stable after board regeneration

**Solution Applied:**

**File 1: BattleManager.swift (Line 240)**
```swift
func reset() {
    // ... existing resets ...
    gameState = .playing
    pendingGameOver = nil  // ✅ NEW: Clear pending game over state
}
```

**File 2: GameViewModel.swift (Lines 591-617)**
```swift
func resetGame() {
    // ✅ FIX: Clear selection state FIRST (prevents phantom selection box)
    selectedPosition = nil
    isSelectingGemToClear = false
    isProcessing = false
    
    // Clear visual states
    shakeTiles.removeAll()
    floatingDamage.removeAll()
    explosionParticles.removeAll()
    bonusBlasts.removeAll()
    
    // Clear animation flags
    isPlayerAttacking = false
    isEnemyAttacking = false
    flashPlayer = false
    flashEnemy = false
    
    // Reset game state
    score = 0
    boardManager.generateInitialBoard()
    battleManager.reset()
    
    // 🎮 FIX: Mark all gems stable after reset (ensures gems can be swapped immediately)
    Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(100))
        boardManager.markAllGemsStable()
    }
}
```

**Why This Matters:**
- **Simulator vs Physical Device**: Physical devices process state changes faster, exposing race conditions that simulators mask
- **Order Matters**: Clearing selection state BEFORE regenerating board prevents phantom UI states
- **Gem Stability**: Ensures board is immediately interactive after reset

---

#### Issue 2: Battle Narrative Slide Animation - FIXED ✅

**Problem:**
- Battle narrative messages were "popping" into view instead of sliding in from the right as intended

**Root Cause:**
- Missing `.id(event.id)` for unique identity tracking
- Animation watching `events.count` instead of individual event IDs
- Symmetric transition (same animation in and out)

**Solution Applied:**

**File: BattleSceneView.swift - BattleNarrativeColumn (Lines 380-420)**
```swift
struct BattleNarrativeColumn: View {
    let events: [BattleEvent]
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(events.prefix(3)) { event in
                HStack(spacing: 6) {
                    // ... message content ...
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .frame(height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.6))
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                )
                .id(event.id)  // ✅ FIX: Force unique identity for each message
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    )
                )
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: events.map { $0.id })  // ✅ FIX: Faster, smoother animation
    }
}
```

**Key Changes:**
1. **`.id(event.id)`** - Forces SwiftUI to track each message uniquely
2. **`.asymmetric` transition** - Slides in from right, fades out (no slide on removal)
3. **Animation tracks `events.map { $0.id }`** - Triggers on ID changes, not count
4. **Faster timing** - 0.3s response (was 0.4s), 0.75 damping (was 0.8)

**Result:**
✅ Messages now smoothly slide in from the right edge with fade, creating a polished notification effect

---

#### Issue 3: Gem Selector Animation Customization - COMPLETE ✅

**Original Request:**
- User wanted gems to "pop out from coffee cup" or "spread clockwise like cards" when coffee cup ability is activated

**Design Iterations:**

**Iteration 1: Pop from Coffee Cup (Complex)**
- Attempted to animate gems from coffee cup center position to circular positions
- Required passing `centerPosition` through multiple components
- Added pulse effect to coffee cup button
- **User Feedback**: "That's not what I want"

**Iteration 2: Simple Animation Order Change (Final) ✅**
- User clarified: Keep original scale animation, but change the ORDER gems animate in
- Create clockwise-ish wave starting from bottom-left (Mana at 8 o'clock)

**Requested Order:**
1. MANA (8 o'clock) - 0ms delay
2. POISON (10 o'clock) - 60ms delay
3. SWORD (12 o'clock) - 120ms delay
4. FIRE (2 o'clock) - 180ms delay
5. SHIELD (4 o'clock) - 240ms delay
6. HEART (6 o'clock) - 300ms delay

**Solution Applied:**

**File: BattleSceneView.swift - GemButton (Lines 550-590)**
```swift
struct GemButton: View {
    let type: TileType
    @Bindable var viewModel: GameViewModel
    
    @State private var hasPopped = false
    @State private var bounceScale: CGFloat = 0.0
    
    var body: some View {
        Button {
            Task {
                await viewModel.clearGemsOfType(type)
            }
        } label: {
            ZStack {
                // ... gem visual content ...
            }
            .shadow(color: .yellow, radius: 10)
            .shadow(color: .black.opacity(0.5), radius: 3)
            .scaleEffect(bounceScale)
            .onAppear {
                // ✨ CUSTOM ANIMATION ORDER: Mana → Poison → Sword → Fire → Shield → Heart
                // Positions stay the same, only animation timing changes
                let animationOrder: [TileType] = [.mana, .poison, .sword, .fire, .shield, .heart]
                let gemIndex = animationOrder.firstIndex(of: type) ?? 0
                let delay = Double(gemIndex) * 0.06 // 0.06s apart (60ms stagger)
                
                // Start small
                bounceScale = 0.0
                
                // Pop out with bounce after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // First: Pop to overshoot
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        bounceScale = 1.2
                    }
                    
                    // Then: Settle to normal size
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            bounceScale = 1.0
                            hasPopped = true
                        }
                    }
                }
            }
        }
    }
}
```

**Gem Positions (Unchanged):**
```
        SWORD
          🗡️
          12

POISON      FIRE
  ☠️   10  2   🔥

MANA    8  4    SHIELD
  💎              🛡️

       HEART
    6     ❤️
```

**Animation Flow:**
- Creates a clockwise-ish wave starting from bottom-left (Mana at 8 o'clock)
- Sweeps up and around the circle
- Total animation completes in ~360ms (6 gems × 60ms stagger + 200ms settle)

---

**Files Modified:**

1. **BattleManager.swift** (Line 240)
   - Added `pendingGameOver = nil` to `reset()` function
   - Ensures clean game state on restart

2. **GameViewModel.swift** (Lines 591-617)
   - Complete overhaul of `resetGame()` function
   - Added proper state clearing order
   - Added gem stability check after board regeneration

3. **BattleSceneView.swift** (Two changes)
   - **BattleNarrativeColumn struct** (Lines 380-420) - Fixed slide animation
     - Added `.id(event.id)` for identity tracking
     - Changed to `.asymmetric` transition
     - Updated animation to track event IDs
   - **GemButton struct** (Lines 550-590) - Custom animation order
     - Changed animation order array to `[.mana, .poison, .sword, .fire, .shield, .heart]`
     - Kept 60ms stagger timing
     - Maintained original bounce animation

4. **ContentView.swift** (Lines 146-147)
   - Adjusted coffee cup center position calculation (+30px for actual cup position)
   - **Note**: This change was part of the complex "pop from cup" solution that was ultimately not used, but doesn't hurt to keep

---

**Testing Results:**

**Selection Box Bug:**
✅ Fixed on both simulator and physical device
✅ Gems swap normally after "Play Again"
✅ No more stuck selection boxes

**Battle Narrative Animation:**
✅ Messages now slide in smoothly from right edge
✅ Fade effect works perfectly
✅ No more "popping" into view

**Gem Selector Animation:**
✅ Gems pop in order: Mana → Poison → Sword → Fire → Shield → Heart
✅ Clockwise-ish wave effect achieved
✅ 60ms stagger creates smooth progression

---

**Key Learnings:**

**Physical Device vs Simulator:**
- Physical devices expose race conditions that simulators hide
- Always test critical UI flows on real hardware
- State clearing order matters more on faster devices

**SwiftUI Animation Identity:**
- `.id()` modifier is crucial for proper transition tracking
- Animating on `value: array.map { $0.id }` triggers on content changes, not count
- `.asymmetric` transitions allow different in/out animations

**Animation Customization:**
- Separating animation **order** from visual **position** provides flexibility
- Using `animationOrder` array decouples display from timing
- Simple solutions often better than complex ones (user feedback validated this)

---

**Status**: ✅ Session 19 Complete! All bugs fixed, gem selector animates beautifully!

---

### Session 21: Bonus Blast PNG Animation Implementation (March 26, 2026) ✅ COMPLETE

**Goal:**
- Implement custom hand-drawn PNG frame animations for bonus tile blast effects
- Replace code-based blasts with user's cartoon-style artwork
- Support both horizontal and vertical blasts with separate positioning controls
- Enable PNG animations for cross blasts (two bonus tiles matched)

**User Requests:**
1. "If for the coffee cup power blast/cross blast, I wanted to animate my own PNG assets, what would I need specifically and what would the dimensions be?"
2. "Do I need to extend these if the bonus gem happens at 2,7 or 5,2 etc.?" (Answer: NO - blasts cover full board)
3. "Can you add the same variables for horizontal and cross blast? and implement the cross blast"
4. "I added the column assets too" (vertical PNG frames uploaded)
5. "Cross blast isn't using PNG" → **FIXED**

**Asset Specifications:**

**12 PNG Images Required:**
- **Horizontal blast**: `bonus_blast_row_1.png` through `bonus_blast_row_6.png`
  - Dimensions: 2048px wide × 256px tall
  - Style: Cartoon/hand-drawn
  
- **Vertical blast**: `bonus_blast_col_1.png` through `bonus_blast_col_6.png`
  - Dimensions: 256px wide × 2048px tall
  - Style: Cartoon/hand-drawn

**Specifications:**
- Format: PNG with transparent background
- Resolution: 144 DPI
- Frame count: 6 frames per animation
- Frame rate: 12 FPS (adjustable)

**Frame Animation Sequence:**
1. Frame 1: Starting spark (10% size, faint)
2. Frame 2: Expanding beam (40% length from center)
3. Frame 3: **PEAK BLAST** (100% length, maximum brightness) ⚡
4. Frame 4: Sustaining (100% length, 80% brightness)
5. Frame 5: Fading (100% length, 50% brightness)
6. Frame 6: Almost gone (20% brightness)

**Key Design Detail:**
- Blasts **originate from bonus gem position** and expand outward
- 2048px dimensions cover **entire board** regardless of where bonus gem is located
- No need for multiple sizes - positioning is handled in code

**Changes Made:**

1. **GameViewModel.swift - Enabled PNG Animations**
   
   **Single Bonus Tile** (Line ~670):
   ```swift
   bonusBlasts = [BonusBlastData(
       position: position,
       isRow: clearRow,
       color: .yellow,
       id: UUID(),
       useCustomImages: true,  // ✅ PNG images enabled
       frameCount: 6,
       frameRate: 12
   )]
   ```
   
   **Cross Blast** (Line ~805 - FIXED):
   ```swift
   bonusBlasts = [
       // Horizontal blast
       BonusBlastData(..., useCustomImages: true, frameCount: 6, frameRate: 12),
       // Vertical blast  
       BonusBlastData(..., useCustomImages: true, frameCount: 6, frameRate: 12)
   ]
   ```

2. **BonusBlastEffects.swift - Separate Positioning Controls**
   
   **Horizontal Blast Controls** (Lines ~267-290):
   ```swift
   private let horizontalWidthMultiplier: CGFloat = 2.0      // Length (left/right)
   private let horizontalThicknessMultiplier: CGFloat = 1.0  // Height of beam
   private let horizontalXOffset: CGFloat = 0                // Shift left/right
   private let horizontalYOffset: CGFloat = -30              // Shift up/down
   ```
   
   **Vertical Blast Controls** (Lines ~292-315):
   ```swift
   private let verticalHeightMultiplier: CGFloat = 2.5       // Length (up/down)
   private let verticalThicknessMultiplier: CGFloat = 1.0    // Width of beam
   private let verticalXOffset: CGFloat = 0                  // Shift left/right
   private let verticalYOffset: CGFloat = 0                  // Shift up/down
   ```

3. **BonusBlastEffects.swift - Updated Rendering Logic** (Lines ~325-380)
   ```swift
   if blastData.isRow {
       // HORIZONTAL: Uses horizontal-specific controls
       Image(imageName)
           .frame(
               width: CGFloat(boardSize) * tileSize * scaleProgress * horizontalWidthMultiplier,
               height: tileSize * BlastEffectConfig.thickness * horizontalThicknessMultiplier
           )
           .position(
               x: CGFloat(blastData.position.col) * tileSize + tileSize / 2 + horizontalXOffset,
               y: CGFloat(blastData.position.row) * tileSize + tileSize / 2 + horizontalYOffset
           )
   } else {
       // VERTICAL: Uses vertical-specific controls
       Image(imageName)
           .frame(
               width: tileSize * BlastEffectConfig.thickness * verticalThicknessMultiplier,
               height: CGFloat(boardSize) * tileSize * scaleProgress * verticalHeightMultiplier
           )
           .position(
               x: CGFloat(blastData.position.col) * tileSize + tileSize / 2 + verticalXOffset,
               y: CGFloat(blastData.position.row) * tileSize + tileSize / 2 + verticalYOffset
           )
   }
   ```

**How It Works:**

**Positioning System:**
- Blast image is centered at bonus gem position: `position.col * tileSize + tileSize / 2`
- Expansion animation: Scales from 0 → 1.0 over 0.24 seconds
- Frame timer: Cycles through frames 1-6 at specified FPS
- After frame 6: Fades out over 0.2 seconds

**Image Naming Convention:**
- Format: `bonus_blast_{direction}_{frameNumber}`
- Examples: `bonus_blast_row_3`, `bonus_blast_col_5`

**Customization Controls:**

**Animation Speed:**
```swift
frameRate: 12  // Change in GameViewModel.swift
// 6 = Slower, dramatic
// 12 = Smooth (recommended)
// 15 = Very fast
```

**Positioning (BonusBlastEffects.swift):**
```swift
// Horizontal blast
horizontalWidthMultiplier: 2.0    // How far left/right
horizontalYOffset: -30            // Shift up/down in pixels

// Vertical blast
verticalHeightMultiplier: 2.5     // How far up/down
verticalXOffset: 0                // Shift left/right in pixels
```

**Result:**
✅ Horizontal blasts use PNG images (6 frames, 12 FPS)
✅ Vertical blasts use PNG images (6 frames, 12 FPS)
✅ Cross blasts use PNG images (both directions simultaneously)
✅ Separate positioning controls for each direction
✅ User's cartoon hand-drawn style displayed
✅ Blasts originate from bonus gem position and expand outward
✅ Full board coverage regardless of gem position

**What Works Now:**
- ✅ Single horizontal blast (swipe left/right) → Custom PNG animation
- ✅ Single vertical blast (swipe up/down) → Custom PNG animation
- ✅ Cross blast (two bonus tiles) → Both PNG animations simultaneously
- ✅ Independent positioning per direction
- ✅ Expansion animation from match origin
- ✅ Adjustable frame rate and positioning

**Testing Instructions:**
1. **Single horizontal**: Spawn bonus tile, swipe left/right
2. **Single vertical**: Spawn bonus tile, swipe up/down
3. **Cross blast**: Debug menu → "⚔️ Spawn TWO at (4,4) + (4,5)" → Swipe together

**Critical Bug Fixed:**
- **Cross blast PNG not enabled** - Added `useCustomImages: true` to both horizontal and vertical blasts in `processCrossBlast()` function

**Files Modified:**
- GameViewModel.swift (enabled PNG for single + cross blasts)
- BonusBlastEffects.swift (separate horizontal/vertical controls, updated rendering)

**Files Created:**
- BONUS_BLAST_PNG_IMPLEMENTATION.md (complete user documentation)

**Status**: ✅ PNG animation system fully implemented and tested! 🎨⚡

---

### Session 20: Gem Clear & Bonus Tile Effects - Multiply by Gem Count (March 23, 2026) ✅ COMPLETE

**Goal:**
- Make Gem Clear ability apply gem effects based on number of gems cleared
- Make Bonus Tile blasts apply gem effects for ALL gem types cleared  
- Formula: (Number of gems) × (effect per gem) = Total effect
- Provide configuration to enable/disable effects per gem type

**User Requests:**
- "when the player uses the coffee cup to clear one type of gem, multiple the effects of that gem with the number of that gem cleared"
- "can we add this same math/logic to the bonus gem as well"
- Selected Option C: Apply effects for ALL gem types in cleared row/column

**What Was Completed:**

**1. Coffee Cup Gem Clear - Now Multiplies Effects**
- Counts how many gems are cleared (e.g., 12 swords)
- Multiplies by effect value (12 × 2 damage = 24 damage)
- Shows total in battle message: `"💥 CLEARED ALL ATTACK GEMS! → 24 damage!"`

**2. Bonus Tile Row/Column Blast - Now Applies ALL Gem Effects**
- Counts ALL gem types in cleared row/column
- Applies effects for EACH type found
- Example: Row with 3 swords, 2 fires, 2 hearts → 12 damage + 6 HP
- Message: `"💥 ROW BLAST! → 12 damage, +6 HP"`

**3. Cross Blast - Combines Row + Column**
- Counts gems from BOTH row AND column
- Combines totals (2 swords in row + 3 in column = 5 total)
- Applies combined effects
- Message: `"⚔️ CROSS BLAST! → 24 damage, +8 shield, +9 HP, +3 mana"`

**Files Modified:**

1. **BattleMechanicsConfig.swift** (Lines 95-130)
   - Added 6 boolean flags to control which gem types apply effects
   - Same config used for BOTH Gem Clear AND Bonus Tiles
   - `gemClearApplySwordDamage`, `gemClearApplyFireDamage`, etc.

2. **BattleManager.swift**
   - Line 246: Modified `useAbility()` to accept `gemCount` parameter
   - Added effect calculation for all 6 gem types
   - Line 364: Changed `addEvent()` from private to public (fixes error)

3. **BoardManager.swift** (Lines 304-337)
   - Modified `clearWithBonusTile()` return type
   - **Before:** Returns `[GridPosition]`
   - **After:** Returns `[TileType: Int]` (dictionary of gem counts)
   - **Critical fix:** Bonus tiles now clear correctly (were staying on board)

4. **GameViewModel.swift**
   - `clearGemsOfType()`: Counts gems, passes to BattleManager
   - `processBonusTile()`: Calculates effects from gem counts, applies effects
   - `processCrossBlast()`: Combines row + column counts, applies effects

**Files Created:**
- GEM_CLEAR_EFFECTS_GUIDE.md - Complete user documentation
- BONUS_TILE_EFFECTS_SUMMARY.md - Bonus tile documentation

**Critical Bug Fixed:**
- **Bonus tiles now disappear after blast**
- Problem: `if !isBonusTile` check excluded bonus from removal list
- Fixed: Add ALL positions to clear list, only count non-bonus for effects

**Examples:**

**Coffee Cup - 12 Swords:**
```
12 gems × 2 damage = 24 damage
Message: "💥 CLEARED ALL ATTACK GEMS! → 24 damage!"
```

**Row Blast - Mixed:**
```
3 swords × 2 = 6 damage
2 fires × 3 = 6 damage
2 hearts × 3 = 6 HP
Total: 12 damage, +6 HP
Message: "💥 ROW BLAST! → 12 damage, +6 HP"
```

**Cross Blast:**
```
Row: 4 swords, 3 fires  
Column: 3 hearts, 4 shields
Combined: 4 swords, 3 fires, 3 hearts, 4 shields
Effects: 17 damage, +9 HP, +8 shield
Message: "⚔️ CROSS BLAST! → 17 damage, +8 shield, +9 HP"
```

**Configuration:**
```swift
// Turn off shield/mana effects:
static let gemClearApplyShield = false
static let gemClearApplyMana = false
```

**What Works Now:**
- ✅ Gem Clear multiplies by count (12 × 2 = 24 damage)
- ✅ Bonus row blast applies ALL gem type effects
- ✅ Bonus column blast applies ALL gem type effects  
- ✅ Cross blast combines row + column counts
- ✅ Battle messages show all effects
- ✅ Configuration works for both abilities
- ✅ Bonus tiles disappear correctly

**Status**: ✅ Session 20 Complete! All effects working! 💎✨

---

### Session 18.5: Battle Narrative Message Migration (March 22, 2026) ✅ COMPLETE

**Goal:**
- Move ALL battle narrative messages from BattleManager.swift to BattleMechanicsConfig.swift
- Centralize all battle text in one file for easy editing
- Prepare for future expansion (eventually 10 messages per type)

**What Was Completed:**

1. **BattleMechanicsConfig.swift - Added Complete Battle Narrative Section**
   
   **Message Arrays Created:**
   - Barbarian attack messages (4 messages)
   - Magic attack messages (4 messages)
   - Shield messages (4 messages)
   - Heal messages (4 messages)
   - Enemy attack messages (5 messages)
   - Mana message (1 message)
   
   **Special Event Messages:**
   - Power Surge message
   - Victory message
   - Defeat message
   - Poison message
   - Gem Clear ability message
   - Divine Shield ability message
   - Greater Heal ability message

2. **BattleManager.swift - Updated to Read from Config**
   
   **All 6 Match Type Message Functions Now Use Config:**
   - Uses `.randomElement()` to pick random messages
   - Uses `.replacingOccurrences(of:with:)` to insert damage/amount values
   
   **7 Hardcoded Special Messages Replaced:**
   - Line 120: Poison message
   - Lines 150-153: Power Surge message
   - Line 223: Victory message
   - Line 235: Defeat message
   - Lines 270-272: Gem Clear message
   - Lines 282-284: Divine Shield message
   - Lines 294-296: Greater Heal message

**How It Works:**

```swift
// Messages stored as templates in config:
static let barbarianAttackMessages = [
    "Ramp swings for {damage}!",
    "Critical bonk! {damage} damage!",
    ...
]

// BattleManager picks random and fills in values:
let template = BattleMechanicsConfig.barbarianAttackMessages.randomElement()!
let message = template.replacingOccurrences(of: "{damage}", with: "\(damage)")
```

**Benefits:**
- ✅ All battle text in ONE place (BattleMechanicsConfig.swift)
- ✅ Easy to add more messages (just expand arrays)
- ✅ No code changes needed to add variety
- ✅ Consistent placeholder system: {damage}, {amount}, {gemType}, {totalMatches}, {bonusMana}

**Files Modified:**
- BattleMechanicsConfig.swift (added complete battle narrative section with all message arrays)
- BattleManager.swift (updated 6 message functions + 7 special messages to use config)

**Status**: ✅ Battle narrative message migration 100% complete!

---

### Session 18: Battle Mechanics Migration to BattleMechanicsConfig.swift (March 22, 2026) ✅ COMPLETE

**Goal:**
- Centralize ALL battle-related configuration into one dedicated file
- Separate battle mechanics from UI/asset configuration
- Make game balance easier to adjust and test
- Prepare for future expansion (status effects, enemy AI, difficulty levels)

**User Request:**
- "hypothetically if i wanted to make very involved detailed battle mechanics, could we port these over to their own file and manage all battle mechanics from one spot?"

**Why This Was Needed:**

**Before** (scattered configuration):
```
GameAssets.swift/GameConfig:
- barbarianStartHealth = 100
- toadStartHealth = 200
- baseDamage = 8
- magicDamage = 12
- healAmount = 10
- shieldAmount = 5
- manaPerGem = 1
- maxMana = 10
- comboMultiplier = 1.5
- enemyMinDamage = 8
- enemyMaxDamage = 15
- divineShieldAmount = 25
- greaterHealAmount = 40
- powerSurgeChainThreshold = 4
- powerSurgeManaBonus = 2
```

**Problems:**
- Battle mechanics mixed with UI/asset settings
- Hard to find and adjust values
- Difficult to test different balance configurations
- Not ready for advanced features (status effects, enemy spells, etc.)

**After** (centralized configuration):
```
BattleMechanicsConfig.swift (NEW FILE):
- All battle numbers in one place
- Organized into logical sections
- Easy to add new mechanics
- Clear separation from UI settings

GameAssets.swift (cleaned up):
- ONLY asset names and UI settings
- No battle mechanics
```

---

**Changes Made:**

### 1. BattleMechanicsConfig.swift - NEW FILE ✨

**Complete battle configuration structure:**

```swift
struct BattleMechanicsConfig {
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Character Stats
    // ═══════════════════════════════════════════════════════════════
    
    static let playerStartingHealth = 100
    static let enemyStartingHealth = 200
    static let maxMana = 10
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Gem Match Damage & Effects
    // ═══════════════════════════════════════════════════════════════
    
    static let swordDamagePerGem = 8      // Physical attack
    static let fireDamagePerGem = 12      // Magic attack
    static let shieldPerGem = 5           // Shield points
    static let healingPerGem = 10         // HP healed
    static let manaPerGem = 1             // Mana gained
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Combo System
    // ═══════════════════════════════════════════════════════════════
    
    static let comboMultiplier = 1.5      // 50% bonus damage
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Enemy AI & Attacks
    // ═══════════════════════════════════════════════════════════════
    
    static let enemyMinDamage = 8
    static let enemyMaxDamage = 15
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Special Abilities (Coffee Cup Button)
    // ═══════════════════════════════════════════════════════════════
    
    static let gemClearAbilityCost = 5    // Mana cost
    static let shieldAbilityCost = 4      // Mana cost
    static let shieldAbilityAmount = 25   // Shield granted
    static let healAbilityCost = 5        // Mana cost
    static let healAbilityAmount = 40     // HP restored
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Power Surge Effect (4+ Match Chain)
    // ═══════════════════════════════════════════════════════════════
    
    static let powerSurgeThreshold = 4    // Matches needed
    static let powerSurgeBonusMana = 2    // Bonus mana awarded
}
```

**Benefits:**
- ✅ All battle numbers in ONE place
- ✅ Clear organization with MARK comments
- ✅ Easy to find specific values
- ✅ Ready for future expansion
- ✅ Can add difficulty presets later

---

### 2. GameAssets.swift - CLEANED UP

**Removed ALL battle mechanics, kept ONLY UI/asset configuration:**

```swift
struct GameConfig {
    
    // MARK: - Board Layout
    static let boardSize = 8
    static let specialTileThreshold = 4
    
    // MARK: - Visual Effects
    static let enablePowerSurgeEffect = true  // Toggle visual effect
    
    // MARK: - Splash Screen Settings
    static let enableDeveloperSplash = true
    static let splashDuration: Double = 4.0
    static let useAnimatedSplash = false
    
    // MARK: - Title Screen Animation
    static let titleAnimationStyle: TitleAnimationStyle = .floatAndPulse
}
```

**What was removed:**
- ❌ All health/damage values
- ❌ All ability costs/effects
- ❌ All combo/power surge mechanics
- ❌ All enemy attack values

**What was kept:**
- ✅ Board size (layout-related)
- ✅ Visual effect toggles (UI-related)
- ✅ Splash screen settings (UI-related)
- ✅ Title animation style (UI-related)

---

### 3. BattleManager.swift - UPDATED ALL REFERENCES

**Changed ALL `GameConfig` references to `BattleMechanicsConfig`:**

**init() function (Lines 35-47):**
```swift
// OLD:
maxHealth: GameConfig.barbarianStartHealth,
currentHealth: GameConfig.barbarianStartHealth
maxHealth: GameConfig.toadStartHealth,
currentHealth: GameConfig.toadStartHealth

// NEW:
maxHealth: BattleMechanicsConfig.playerStartingHealth,
currentHealth: BattleMechanicsConfig.playerStartingHealth
maxHealth: BattleMechanicsConfig.enemyStartingHealth,
currentHealth: BattleMechanicsConfig.enemyStartingHealth
```

**processMatches() function (Lines 70-140):**
```swift
// OLD:
let multiplier = isCombo ? GameConfig.comboMultiplier : 1.0
let damage = Int(Double(GameConfig.baseDamage * matchCount) * multiplier)
let damage = Int(Double(GameConfig.magicDamage * matchCount) * multiplier)
let shield = GameConfig.shieldAmount * matchCount
let healing = GameConfig.healAmount * matchCount
let manaGain = GameConfig.manaPerGem * matchCount
mana = min(GameConfig.maxMana, mana + totalMana)

// NEW:
let multiplier = isCombo ? BattleMechanicsConfig.comboMultiplier : 1.0
let damage = Int(Double(BattleMechanicsConfig.swordDamagePerGem * matchCount) * multiplier)
let damage = Int(Double(BattleMechanicsConfig.fireDamagePerGem * matchCount) * multiplier)
let shield = BattleMechanicsConfig.shieldPerGem * matchCount
let healing = BattleMechanicsConfig.healingPerGem * matchCount
let manaGain = BattleMechanicsConfig.manaPerGem * matchCount
mana = min(BattleMechanicsConfig.maxMana, mana + totalMana)
```

**Power Surge detection (Lines 143-152):**
```swift
// OLD:
if totalMatches >= GameConfig.powerSurgeChainThreshold {
    let bonusMana = GameConfig.powerSurgeManaBonus
    mana = min(GameConfig.maxMana, mana + bonusMana)
}

// NEW:
if totalMatches >= BattleMechanicsConfig.powerSurgeThreshold {
    let bonusMana = BattleMechanicsConfig.powerSurgeBonusMana
    mana = min(BattleMechanicsConfig.maxMana, mana + bonusMana)
}
```

**enemyTurn() function (Line 186):**
```swift
// OLD:
let damage = Int.random(in: GameConfig.enemyMinDamage...GameConfig.enemyMaxDamage)

// NEW:
let damage = Int.random(in: BattleMechanicsConfig.enemyMinDamage...BattleMechanicsConfig.enemyMaxDamage)
```

**useAbility() function (Lines 255-280):**
```swift
// OLD:
let shieldAmount = GameConfig.divineShieldAmount
let healAmount = GameConfig.greaterHealAmount

// NEW:
let shieldAmount = BattleMechanicsConfig.shieldAbilityAmount
let healAmount = BattleMechanicsConfig.healAbilityAmount
```

---

**Battle Mechanics Reference Table:**

| Mechanic | Value | Location | Description |
|----------|-------|----------|-------------|
| **Player Health** | 100 | BattleMechanicsConfig.swift:18 | Ramp's starting HP |
| **Enemy Health** | 200 | BattleMechanicsConfig.swift:21 | Ednar's starting HP |
| **Max Mana** | 10 | BattleMechanicsConfig.swift:24 | Maximum mana storage |
| **Sword Damage** | 8 per gem | BattleMechanicsConfig.swift:32 | Physical attack damage |
| **Fire Damage** | 12 per gem | BattleMechanicsConfig.swift:35 | Magic attack damage |
| **Shield Gain** | 5 per gem | BattleMechanicsConfig.swift:38 | Shield points granted |
| **Healing** | 10 per gem | BattleMechanicsConfig.swift:41 | HP restored |
| **Mana Gain** | 1 per gem | BattleMechanicsConfig.swift:44 | Mana charged |
| **Combo Bonus** | 1.5x (50% more) | BattleMechanicsConfig.swift:52 | Multiple match groups |
| **Enemy Min Attack** | 8 | BattleMechanicsConfig.swift:60 | Minimum enemy damage |
| **Enemy Max Attack** | 15 | BattleMechanicsConfig.swift:63 | Maximum enemy damage |
| **Gem Clear Cost** | 5 mana | BattleMechanicsConfig.swift:72 | Coffee cup ability |
| **Divine Shield Cost** | 4 mana | BattleMechanicsConfig.swift:75 | Shield ability |
| **Divine Shield Amount** | 25 | BattleMechanicsConfig.swift:78 | Shield granted |
| **Greater Heal Cost** | 5 mana | BattleMechanicsConfig.swift:81 | Heal ability |
| **Greater Heal Amount** | 40 | BattleMechanicsConfig.swift:84 | HP restored |
| **Power Surge Threshold** | 4 matches | BattleMechanicsConfig.swift:93 | Trigger requirement |
| **Power Surge Bonus** | 2 mana | BattleMechanicsConfig.swift:96 | Extra mana awarded |

---

**How Battle Damage Calculation Works:**

**Example 1: Match 3 Swords**
```
swordDamagePerGem = 8
Gems matched = 3
Damage = 8 × 3 = 24 HP to enemy
```

**Example 2: Match 3 Swords + 3 Fire (COMBO!)**
```
swordDamagePerGem = 8
fireDamagePerGem = 12
comboMultiplier = 1.5

Sword damage: 8 × 3 = 24
Fire damage: 12 × 3 = 36
Base total: 24 + 36 = 60

With combo: 60 × 1.5 = 90 HP to enemy
```

**Example 3: Match 4 Mana Gems (Power Surge!)**
```
manaPerGem = 1
Gems matched = 4
Base mana = 1 × 4 = 4

Power Surge bonus = 2
Total mana = 4 + 2 = 6 mana gained
```

**Example 4: Enemy Attacks**
```
enemyMinDamage = 8
enemyMaxDamage = 15

Random damage = 8 to 15 HP
(Different each turn)
```

---

**How to Adjust Game Balance:**

**Make Game Easier (Player Advantages):**

Open `BattleMechanicsConfig.swift` and change:

```swift
// Player survives longer
static let playerStartingHealth = 150  // was 100

// Enemy dies faster
static let enemyStartingHealth = 150   // was 200

// Player deals more damage
static let swordDamagePerGem = 12      // was 8
static let fireDamagePerGem = 16       // was 12

// Player heals more
static let healingPerGem = 15          // was 10

// Enemy is weaker
static let enemyMinDamage = 5          // was 8
static let enemyMaxDamage = 10         // was 15
```

**Make Game Harder (Enemy Advantages):**

```swift
// Player has less health
static let playerStartingHealth = 75   // was 100

// Enemy has more health
static let enemyStartingHealth = 300   // was 200

// Player deals less damage
static let swordDamagePerGem = 6       // was 8
static let fireDamagePerGem = 10       // was 12

// Enemy is stronger
static let enemyMinDamage = 12         // was 8
static let enemyMaxDamage = 20         // was 15
```

**Adjust Abilities:**

```swift
// Cheaper coffee cup (easier to use)
static let gemClearAbilityCost = 3    // was 5

// More powerful abilities
static let shieldAbilityAmount = 40   // was 25
static let healAbilityAmount = 60     // was 40
```

---

**Future Expansion Possibilities:**

Now that battle mechanics are centralized, it's easy to add:

**Easy Additions:**
```swift
// Difficulty presets
enum Difficulty { case easy, normal, hard, nightmare }

// Multiple enemy types
static let bossHealthMultiplier = 2.0
static let eliteEnemyDamageBonus = 5

// Level progression
static let healthGainPerLevel = 10
static let damageGainPerLevel = 2
```

**Medium Additions:**
```swift
// Status effects
static let poisonEnabled = true
static let poisonDamagePerTurn = 3
static let burnDuration = 2
static let freezeChance = 0.15

// Critical hits
static let criticalHitChance = 0.1
static let criticalHitMultiplier = 2.0
```

**Advanced Additions:**
```swift
// Enemy spell system
static let enemySpellChance = 0.2
static let spellDamageMin = 15
static let spellDamageMax = 25

// Combo escalation
static let tripleComboMultiplier = 2.0
static let megaComboMultiplier = 3.0

// Board manipulation
static let curseTileSpawnChance = 0.1
static let curseDamageOnMatch = 5
```

---

**What Works Now:**

✅ All battle mechanics in one centralized file
✅ Easy to find and adjust any value
✅ Game plays exactly the same as before
✅ Clean separation: battle logic vs UI configuration
✅ Ready for advanced features (status effects, enemy AI, etc.)
✅ Can create difficulty presets in the future
✅ All damage calculations use BattleMechanicsConfig
✅ All ability costs use BattleMechanicsConfig
✅ All character stats use BattleMechanicsConfig
✅ Code is more maintainable and organized

**Testing Checklist:**

✅ Game builds without errors
✅ Sword gems deal 8 damage per gem
✅ Fire gems deal 12 damage per gem
✅ Heart gems heal 10 HP per gem
✅ Shield gems grant 5 shield per gem
✅ Mana gems grant 1 mana per gem
✅ Enemy attacks for 8-15 damage (random)
✅ Combos multiply damage by 1.5x
✅ Power Surge triggers on 4+ matches
✅ Power Surge awards 2 bonus mana
✅ Coffee cup costs 5 mana
✅ Coffee cup clears all gems of selected type
✅ Divine Shield costs 4 mana, grants 25 shield
✅ Greater Heal costs 5 mana, restores 40 HP

**Files Created:**
- BattleMechanicsConfig.swift (99 lines) ✨ NEW

**Files Modified:**
- GameAssets.swift (removed all battle mechanics, kept UI/asset config)
- BattleManager.swift (all references changed from GameConfig to BattleMechanicsConfig)

**Files NOT Modified:**
- GameViewModel.swift (no changes needed)
- Character.swift (no changes needed)
- TileType.swift (no changes needed)
- All other files unchanged

**Documentation:**
- Complete battle mechanics reference table created
- Damage calculation examples provided
- Balance adjustment guide included
- Future expansion roadmap outlined

**Status**: ✅ Session 18 100% Complete! Battle mechanics fully centralized and ready for expansion! 🎮⚔️

---

### Session 17: Bonus Tile Cascade Bug Fix (March 22, 2026) ✅ FIXED

**Goal:**
- Fix bonus tiles not clearing 3-match patterns after blast
- Fix board staying empty after bonus tile activation
- Ensure cascades process correctly after bonus blasts

**User Report:**
1. "after bonus tile matches/blasts, matches on the board stop working"
2. "3 tiles auto matched don't clear"
3. Happens with both single bonus tiles and cross blasts (two bonuses swapped)

**Problem Identified:**

**Root Cause #1: Duplicate Gravity/Refill Logic**
- `processBonusTile()` and `processCrossBlast()` were calling gravity/refill INTERNALLY
- Then `performSwap()` called `processCascades()` which tried to apply gravity AGAIN
- Board was in weird state - gems already fallen, but `processCascades()` expected empty spaces
- Result: Match detection failed, board stayed empty

**Root Cause #2: Empty Board, No Matches**
- After bonus blast cleared gems, board was completely empty
- `processCascades()` looks for matches with `findMatches()`
- Empty board = no matches found
- `guard !matches.isEmpty else { break }` exited immediately
- Gravity/spawn never happened
- Result: Board stayed empty forever

**The Fix:**

**Solution: Manual Refill BEFORE processCascades()**

In `performSwap()` function in GameViewModel.swift:

**Lines 154-177 (Cross Blast Path):**
```swift
// Use the "to" position for the cross blast
await processCrossBlast(at: to)

// ✅ REFILL BOARD: Apply gravity and spawn new gems
_ = boardManager.applyGravity()
try? await Task.sleep(for: .milliseconds(300))

let _ = boardManager.fillEmptySpacesWithFastCascade()
try? await Task.sleep(for: .milliseconds(400))

// Mark gems stable
boardManager.markAllGemsStable()

// NOW check for cascading matches
await processCascades()
```

**Lines 186-209 (Single Bonus Blast Path):**
```swift
// Trigger bonus tile effect with direction
await processBonusTile(at: bonusPosition, clearRow: isHorizontalSwipe)

// ✅ REFILL BOARD: Apply gravity and spawn new gems
_ = boardManager.applyGravity()
try? await Task.sleep(for: .milliseconds(300))

let _ = boardManager.fillEmptySpacesWithFastCascade()
try? await Task.sleep(for: .milliseconds(400))

// Mark gems stable
boardManager.markAllGemsStable()

// NOW check for cascading matches
await processCascades()
```

**Changes to processBonusTile() and processCrossBlast():**

Removed ALL gravity/refill/battle logic from both functions:

**processBonusTile() (Lines 449-482):**
```swift
@MainActor
private func processBonusTile(at position: GridPosition, clearRow: Bool) async {
    // Highlight the bonus tile
    shakeTiles = [position]
    hapticManager?.powerSurgeTriggered()
    
    try? await Task.sleep(for: .milliseconds(300))
    
    // Clear row or column based on swipe direction
    let clearedPositions = boardManager.clearWithBonusTile(at: position, clearRow: clearRow)
    
    // Show bonus blast effect
    bonusBlasts = [BonusBlastData(
        position: position,
        isRow: clearRow,
        color: .yellow,
        id: UUID()
    )]
    
    shakeTiles.removeAll()
    try? await Task.sleep(for: .milliseconds(600))  // Wait for blast animation
    bonusBlasts.removeAll()
    
    // ✅ REMOVED: Gravity and refill - performSwap() handles this!
    // ✅ REMOVED: Battle effects - processCascades() handles this!
    // ✅ REMOVED: Attack animation - processCascades() handles this!
    
    // Just wait for blast to finish, then return
}
```

**processCrossBlast() (Lines 487-524):**
```swift
@MainActor
private func processCrossBlast(at position: GridPosition) async {
    // Highlight the position
    shakeTiles = [position]
    hapticManager?.powerSurgeTriggered()
    
    try? await Task.sleep(for: .milliseconds(300))
    
    // Clear BOTH row and column
    let rowPositions = boardManager.clearWithBonusTile(at: position, clearRow: true)
    let colPositions = boardManager.clearWithBonusTile(at: position, clearRow: false)
    let allClearedPositions = Set(rowPositions + colPositions)
    
    // Create TWO blasts (cross pattern)
    bonusBlasts = [
        BonusBlastData(position: position, isRow: true, color: .yellow, id: UUID()),
        BonusBlastData(position: position, isRow: false, color: .yellow, id: UUID())
    ]
    
    shakeTiles.removeAll()
    try? await Task.sleep(for: .milliseconds(600))
    bonusBlasts.removeAll()
    
    // ✅ REMOVED: Gravity and refill - performSwap() handles this!
    // ✅ REMOVED: Battle effects - processCascades() handles this!
    // ✅ REMOVED: Attack animation - processCascades() handles this!
    
    // Just wait for blast to finish, then return
}
```

**How It Works Now:**

**Before (BROKEN):**
```
Bonus blast clears gems
  ↓
processBonusTile applies gravity internally
  ↓
processBonusTile spawns new gems internally
  ↓
performSwap calls processCascades()
  ↓
processCascades tries to apply gravity AGAIN
  ↓
❌ Conflict - board in weird state
❌ Matches don't detect
❌ Board stays empty
```

**After (FIXED):**
```
Bonus blast clears gems (just visual effect)
  ↓
performSwap manually applies gravity ONCE
  ↓
performSwap manually spawns new gems ONCE
  ↓
performSwap calls processCascades()
  ↓
processCascades finds any 3-matches in new gems
  ↓
✅ Matches clear properly
✅ Cascades continue normally
✅ Board refills completely
```

**Timeline Example:**

```
1. Player swaps bonus tile
2. Blast effect plays (600ms visual)
3. Gems are cleared from row/column
4. ⚡ Gravity applied (300ms wait)
5. ⚡ New gems spawn (400ms wait)
6. ⚡ Gems marked stable
7. processCascades() checks for matches
8. If 3-match found → Clear → Gravity → Spawn → Repeat
9. Enemy turn
10. Board unlocked ✅
```

**Result:**
✅ Single bonus tiles work 100% of the time
✅ Cross blasts (bonus + bonus) work 100% of the time
✅ All 3-matches created by new gems clear properly
✅ Cascades process normally after bonus blasts
✅ Board never stays empty
✅ Match detection works correctly
✅ No more stuck selection boxes

**What Changed:**
- `processBonusTile()` - Removed gravity, spawn, battle effects, attack animation
- `processCrossBlast()` - Removed gravity, spawn, battle effects, attack animation
- `performSwap()` - Added manual gravity + spawn + markStable BEFORE processCascades()

**Key Insight:**
The problem was DUPLICATE gravity/spawn calls. By removing them from the bonus functions and doing them ONCE in `performSwap()`, the board state stays consistent and `processCascades()` can detect matches normally.

**Files Modified:**
- GameViewModel.swift (lines 154-177, 186-209, 449-482, 487-524)

**Status**: ✅ Session 17 Complete! Bonus tiles now work perfectly with full cascade support! ☕💥

---

### Session 16: Delayed Game Over Screen - Finish All Animations First (March 22, 2026) ✅ FIXED

**Goal:**
- Prevent victory/defeat screen from showing immediately when HP hits 0
- Allow all remaining matches, cascades, and animations to complete first
- Show game over screen only after turn is fully finished

**User Request:**
- "currently the game shows a victory or defeat screen as soon as, and immediately upon one of the character's HP running out. I would like all matches, cascades, and animations to finish on screen before the victory or defeat screen is shown."

**Clarifications Given:**
1. All remaining cascades in that turn should finish completely
2. Player attack animations should complete (if player makes killing blow)
3. Enemy attack animations should complete (if enemy makes killing blow)
4. Bonus tile blast animations should complete

**Problem Identified:**
- In `BattleManager.swift`, `checkGameOver()` was called immediately after damage
- This set `gameState = .victory` or `.defeat` instantly
- In `ContentView.swift`, the `GameOverView` appeared as soon as `gameState != .playing`
- Result: Game over screen showed BEFORE animations finished

**The Fix:**

**BattleManager.swift Changes:**

1. **Added pendingGameOver variable (Line 27)**
   ```swift
   var gameState: GameState = .playing
   var pendingGameOver: GameState? = nil  // ✨ NEW: Holds victory/defeat until animations finish
   ```

2. **Modified checkGameOver() function (Lines 226-245)**
   - Changed from immediately setting `gameState`
   - Now stores result in `pendingGameOver` instead
   - Character states still update (for animations)
   - Haptics still trigger
   - Battle narrative still adds messages
   
   ```swift
   private func checkGameOver() {
       if !enemy.isAlive {
           // ✨ DON'T show game over yet - store it for later!
           pendingGameOver = .victory
           
           // 🎨 SET PLAYER TO VICTORY STATE (animation will play)
           player.currentState = .victory
           
           hapticManager?.victory()
           addEvent(BattleEvent(text: "Victory! The Toad King croaks his last!", type: .special))
       } else if !player.isAlive {
           // ✨ DON'T show game over yet - store it for later!
           pendingGameOver = .defeat
           
           // 🎨 SET PLAYER TO DEFEAT STATE (animation will play)
           player.currentState = .defeat
           
           hapticManager?.defeat()
           addEvent(BattleEvent(text: "Defeated! The swamp claims another hero...", type: .special))
       }
   }
   ```

3. **Added finalizeGameOver() function (After line 333)**
   ```swift
   // ✨ NEW: Call this after ALL animations complete to show game over screen
   func finalizeGameOver() {
       if let pending = pendingGameOver {
           gameState = pending
           pendingGameOver = nil
       }
   }
   ```

**GameViewModel.swift Changes:**

Called `battleManager.finalizeGameOver()` at the end of each turn completion:

1. **performSwap() function (Line 293)**
   ```swift
   } else {
       await enemyTurn()
   }
   
   // ✨ ALL ANIMATIONS DONE - Now show game over screen if needed
   battleManager.finalizeGameOver()
   
   isProcessing = false
   ```

2. **processChainRelease() function (Line 782)**
   ```swift
   // Enemy turn
   await enemyTurn()
   
   // ✨ ALL ANIMATIONS DONE - Now show game over screen if needed
   battleManager.finalizeGameOver()
   
   isProcessing = false
   ```

3. **clearGemsOfType() function (Line 714)**
   ```swift
   // Enemy turn
   await enemyTurn()
   
   // ✨ ALL ANIMATIONS DONE - Now show game over screen if needed
   battleManager.finalizeGameOver()
   
   isProcessing = false
   ```

**How It Works:**

**Before:**
```
HP hits 0 → gameState = .victory immediately → Game over screen shows instantly
```

**After:**
```
HP hits 0 → pendingGameOver = .victory (stored, not shown yet)
    ↓
All matches continue → All cascades finish → All animations play
    ↓
End of turn → finalizeGameOver() called → gameState = .victory → Screen shows NOW
```

**Timeline Example (Player Defeats Enemy):**

```
1. Player makes final match
2. Enemy HP → 0
3. checkGameOver() sets pendingGameOver = .victory
4. player.currentState = .victory (victory animation starts)
5. Remaining cascades process (if any)
6. All match animations complete
7. All spawn animations complete
8. Player attack animation finishes
9. Enemy turn skipped (enemy dead)
10. finalizeGameOver() sets gameState = .victory
11. ✅ NOW victory screen appears!
```

**Timeline Example (Enemy Defeats Player):**

```
1. Enemy attacks
2. Player HP → 0
3. checkGameOver() sets pendingGameOver = .defeat
4. player.currentState = .defeat (defeat animation starts)
5. Enemy attack animation completes
6. Hurt flash animation completes
7. finalizeGameOver() sets gameState = .defeat
8. ✅ NOW defeat screen appears!
```

**What This Ensures:**

✅ All remaining cascades finish completely
✅ Player attack animations complete (if player makes killing blow)
✅ Enemy death/defeat animations play fully
✅ Enemy attack animations complete (if enemy makes killing blow)
✅ Bonus tile blast animations finish
✅ All tile spawn animations complete
✅ Victory/defeat character state animations play
✅ THEN game over screen shows

**No Gameplay Affected:**
- Only adds one line after enemy turn in 3 places
- No animation timings changed
- No game logic modified
- Just delays the screen appearance until proper time

**Files Modified:**
- BattleManager.swift (added pendingGameOver variable, modified checkGameOver(), added finalizeGameOver() function)
- GameViewModel.swift (added finalizeGameOver() calls in performSwap, processChainRelease, clearGemsOfType)

**Status**: ✅ Session 16 Complete! Game over screen now appears AFTER all animations finish!

---

### Session 15: Swipe/Tap Gesture Bug Fix (March 22, 2026) ✅ FIXED

**Goal:**
- Fix inconsistent selection box appearing when trying to swipe gems
- User reported: "When I try to drag/swipe a gem, it just shows the selection box around the first gem and doesn't do anything"

**User Report:**
1. When trying to swipe a gem, selection box appears instead
2. Selection box stays visible
3. Happens randomly
4. Box appears on the tapped gem and stays there

**Problem Identified:**
- In `GameBoardView.swift` line 764, `.onTapGesture` was placed **BEFORE** `.gesture(DragGesture)`
- SwiftUI gesture priority: earlier modifiers take precedence
- When user tried to swipe, tap fired immediately → gem selected → drag gesture ignored
- Result: Stuck with white selection box, no swipe action

**Root Cause:**
```swift
// ❌ BUGGY CODE (line 764):
self
    .onTapGesture { onTap() }  // ← Fires FIRST, blocks drag
    .gesture(DragGesture(minimumDistance: 10) { ... })
```

**The Fix:**
```swift
// ✅ FIXED CODE (lines 761-793):
self
    .gesture(
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                // Visual drag feedback
            }
            .onEnded { value in
                let threshold: CGFloat = 25
                
                if horizontal && absWidth > threshold {
                    onSwipe(...)  // Swipe detected!
                } else if !horizontal && absHeight > threshold {
                    onSwipe(...)  // Swipe detected!
                } else {
                    // 🐛 FIX: Only tap if drag was too small
                    onTap()
                }
            }
    )
```

**How It Works Now:**
1. User touches gem → DragGesture starts monitoring
2. **IF** user drags ≥25 pixels → Swipe happens ✅
3. **IF** user barely moves or doesn't move → Tap happens ✅
4. No more competing gestures!

**Changes Made:**

1. **GameBoardView.swift - conditionalGestures modifier (lines 761-793)**
   - Removed separate `.onTapGesture { onTap() }`
   - Moved tap logic inside DragGesture's `.onEnded`
   - Added `else` clause on line 783-785:
     ```swift
     } else {
         // 🐛 FIX: Only trigger tap if drag was too small (not a swipe attempt)
         onTap()
     }
     ```

**Result:**
✅ Swipe gestures work smoothly (no more stuck selection boxes)
✅ Tap-to-select still works (for traditional two-tap swap method)
✅ User confirmed: "ok that seems to work!"
✅ Gesture detection is now reliable and predictable

**What Works Now:**
- ✅ Swipe left/right/up/down to swap gems instantly
- ✅ Tap a gem to select it (white box appears)
- ✅ Tap adjacent gem to complete swap (traditional method)
- ✅ Quick flick gestures work correctly
- ✅ No more "ghost" selection boxes when swiping
- ✅ Both input methods coexist perfectly

**Technical Details:**
- **Swipe threshold**: 25 pixels (adjustable if needed)
- **Drag minimum distance**: 10 pixels (prevents accidental drags)
- **Gesture priority**: DragGesture now has full control, decides tap vs swipe
- **Visual feedback**: Drag offset still works (gems follow finger while dragging)

**Files Modified:**
- GameBoardView.swift (lines 761-793 - conditionalGestures modifier)

**Status**: ✅ Session 15 100% Complete! Gesture system working perfectly!

---

### Session 12: Coffee Bonus Tile System + Debug Menu (March 20-22, 2026) ✅ FULLY WORKING

**Goal:**
- Add bonus tile that spawns on 5-gem matches (straight lines or L-shapes)
- Bonus tiles clear row/column based on swipe direction
- Bonus tiles immune to auto-matching (persist through cascades)
- Add comprehensive debug menu for testing
- Support L-shape detection (3 horizontal + 3 vertical sharing corner)
- **FIXED**: Match detection bug (bonuses breaking chains)
- **FIXED**: Swap validation bug (bonuses can always swap)

**User Requests:**
1. "i want to add a bonus tile that appears when a 5 gem match happens. can that tile be animated?"
2. "can you add a debug mode so i can force 5 match tiles, force coffee mana, and add other options as needed"
3. "make sure when the coffee cup appears, it doesn't appear OVER an existing tile"
4. "Let's change whether a row or a column disappears, based on which direction the user swipes"
5. "if the coffee cup is part of a cascade, it should remain on the board and not disappear til the user swipes it"
6. "i want 3 across, 2 down in any combo, an L shape facing any direction basically made of 5 gems"
7. "sometimes when a single bonus tile is on the board, it shows a bounding box when i try to match, instead of actually swiping/matching" → **FIXED**

**Changes Made:**

1. **BonusTileConfig.swift - NEW FILE (Complete bonus tile settings)**
   ```swift
   struct BonusTileConfig {
       static let enabled: Bool = true
       static let minimumMatchSize: Int = 5
       static let enableGlow: Bool = true
       static let glowSpeed: Double = 1.0
       static let glowColor = (1.0, 0.9, 0.3)  // Golden
       static let glowOpacity: Double = 0.5
       static let imageName: String = "coffee_bonus"
       static let allowMultiple: Bool = true
   }
   ```
   - All configurable settings in one place
   - Easy toggle for feature, glow, colors
   - Multiple bonus tiles support

2. **DebugMenuView.swift - NEW FILE (Complete debug system)**
   ```swift
   struct DebugMenuView: View {
       // Quick Actions: Fill Mana, Full HP, Kill Enemy, +50 Shield
       // Board Manipulation: Force 5-Match (all types), Spawn Coffee, Clear Board
       // Battle Stats: Real-time HP, Mana, Shield, Score display
       // Game Speed: Toggle Skip Pauses, Async Enemy, Auto-Chain Speed slider
       // Bonus Testing: Spawn at specific positions, Remove all bonuses
   }
   ```
   - Orange hammer icon in top-right corner
   - Force 5-match for any tile type (top row, columns 2-6)
   - Manual coffee spawn at center, (3,3), or (5,5)
   - Real-time battle stats display
   - Speed controls (skip pauses, async enemy, chain speed)

3. **TileType.swift - Added Bonus Tile Tracking**
   ```swift
   struct Tile {
       var isBonusTile: Bool = false  // ☕ NEW
       
       static func bonusTile(row: Int, col: Int) -> Tile {
           var tile = Tile(type: .mana, row: row, col: col)
           tile.isBonusTile = true
           return tile
       }
   }
   ```

4. **BoardManager.swift - Complete Bonus Tile Logic**
   - `findMatches()` - **FIXED:** Skip bonus tiles entirely (lines 94-152)
     - ✅ Bonus tiles don't start matches
     - ✅ Bonus tiles break match chains
     - Added `if gemToCheck.isBonusTile { col/row += 1; continue }`
     - Added `!nextGem.isBonusTile` check in while loops
   - `clearMatches()` - Protect bonus tiles from removal (line 163)
     - `!gemToRemove.isBonusTile` protection
   - `canSwap()` - **FIXED:** Always allow bonus swaps (line 60-67)
     - ✅ Added special case: `if gem1.isBonusTile || gem2.isBonusTile { return true }`
     - Bypasses stability check for bonus tiles
     - Fixes "bounding box" rejection bug
   - `shouldSpawnBonusTile()` - Detect 5-matches and L-shapes (lines 171-189)
     - Checks L-shapes first
     - Then checks straight 5s
   - `detectLShapeMatch()` - NEW FUNCTION (lines 195-223)
     - Finds pairs of matches sharing corner
     - Must be same type
     - Must share exactly 1 tile
     - Total unique tiles ≥ 5
     - Returns corner position
   - `clearWithBonusTile()` - Direction-based clearing (lines 241-265)
     - `clearRow: true` → Clear horizontal row
     - `clearRow: false` → Clear vertical column
   - `spawnBonusTile()` - Create bonus tile (lines 229-236)
   - `isBonusTileSwap()` - Check if swap involves bonus (lines 232-236)
   - `calculateBonusSpawnPosition()` - Find spawn position (lines 195-215)

5. **GameViewModel.swift - Bonus Tile Activation**
   - `performSwap()` - Detect bonus swaps and direction (lines 128-150)
     ```swift
     let isBonusSwap = boardManager.isBonusTileSwap(from: from, to: to)
     if isBonusSwap {
         let isHorizontalSwipe = from.row == to.row
         let bonusPosition = ...
         await processBonusTile(at: bonusPosition, clearRow: isHorizontalSwipe)
     }
     ```
   - `processCascades()` - Spawn bonus after clearing (lines 270-285)
     ```swift
     let bonusSpawnPosition = boardManager.shouldSpawnBonusTile(for: matches)
     withAnimation(.easeOut(duration: 0.3)) {
         let clearedPositions = boardManager.clearMatches(matches)
     }
     if let spawnPos = bonusSpawnPosition {
         try? await Task.sleep(for: .milliseconds(Int(300 * speedMultiplier)))
         boardManager.spawnBonusTile(at: spawnPos)
     }
     ```
   - `processBonusTile()` - NEW FUNCTION (lines 421-447)
     - Highlights bonus tile
     - Clears row or column based on direction
     - Creates explosions
     - Applies gravity and refill
     - Processes battle effects

6. **GameBoardView.swift - Bonus Tile Rendering**
   - `mainContent` - Conditional rendering (lines 325-345)
     ```swift
     if tile.isBonusTile {
         bonusTileContent
     } else {
         // Regular tile
     }
     ```
   - `bonusTileContent` - NEW VIEW (lines 348-362)
     - Shows coffee_bonus image
     - Applies BonusTileGlowModifier
   - `BonusTileGlowModifier` - NEW STRUCT (lines 853-872)
     - Pulsing glow effect
     - Two shadow layers
     - Animates between 0.5 and 1.0 intensity
     - Repeats forever with autoreverses

7. **ContentView.swift - Debug Menu Integration**
   - `@State private var showDebugMenu = false` (line 82)
   - Debug button in top-right corner (lines 111-127)
     - Orange hammer icon
     - Circle background
     - Opens menu on tap
   - Debug menu overlay (lines 164-168)
     - Shows when `showDebugMenu = true`
     - Z-index 1500 (above game, below pause)

**Asset Requirements:**
- `coffee_bonus.png` - Static coffee cup image for bonus tile
  - Add to Assets.xcassets
  - Name exactly "coffee_bonus"
  - Place in 1x slot

**Bonus Tile Behavior:**
- ✅ Spawns on 5-gem straight lines (horizontal or vertical)
- ✅ Spawns on L-shapes (3+3 sharing corner = 5 unique tiles)
- ✅ Appears AFTER matched gems disappear (not on top)
- ✅ **IMMUNE to auto-matching** (won't be included in cascades) - FIXED
- ✅ **BREAKS match chains** (3 Red + Bonus + 3 Red = TWO matches) - FIXED
- ✅ Falls with gravity (moves down like normal gems)
- ✅ Persists until player swipes it
- ✅ **CAN ALWAYS BE SWAPPED** (bypasses stability check) - FIXED
- ✅ Horizontal swipe = clear row
- ✅ Vertical swipe = clear column
- ✅ Optional animated glow effect

**Critical Bugs Fixed:**
1. **Match Detection Bug** - `findMatches()` now skips bonus tiles:
   - Added `if gemToCheck.isBonusTile { continue }` before checking matches
   - Added `!nextGem.isBonusTile` in while loops to break chains
   - Result: Bonus tiles no longer participate in automatic matching

2. **Swap Validation Bug** - `canSwap()` now allows bonus swaps:
   - Added special case: `if gem1.isBonusTile || gem2.isBonusTile { return true }`
   - Bypasses `isStable` check for bonus tiles
   - Result: Bonus tiles can be swapped even if other gem is unstable

**Before Fixes:**
- ❌ 3 Red + Bonus + 3 Red = ONE match of 7 (bonus included)
- ❌ Bonus tiles could get caught in auto-matching
- ❌ Tapping bonus showed bounding box rejection

**After Fixes:**
- ✅ 3 Red + Bonus + 3 Red = TWO separate matches of 3
- ✅ Bonus tiles immune to auto-matching
- ✅ Tapping bonus always allows swap

**Debug Menu Features:**
- ⚡ Quick Actions: Mana, HP, Kill Enemy, Shield
- 🎲 Board Tools: Force 5-match (all 6 types), Spawn Coffee, Clear Board
- ⚔️ Stats Display: Real-time HP, Mana, Shield, Score
- ⏱️ Speed Controls: Skip Pauses, Async Enemy, Chain Speed slider
- ☕ Bonus Testing: Spawn at positions, Remove all

**What Works Now:**
- ✅ 5-gem straight matches spawn coffee at center
- ✅ L-shape matches spawn coffee at corner
- ✅ **Coffee tiles IMMUNE to auto-matching (FIXED)**
- ✅ **Coffee tiles BREAK match chains (FIXED)**
- ✅ **Coffee tiles CAN ALWAYS SWAP (FIXED - no more bounding box)**
- ✅ Coffee tiles fall with gravity
- ✅ Coffee tiles persist through cascades
- ✅ Horizontal swipe clears row
- ✅ Vertical swipe clears column
- ✅ Glow effect animates smoothly
- ✅ Debug menu fully functional
- ✅ Force 5-match works for all tile types
- ✅ Manual coffee spawning works
- ✅ Real-time stat display updates correctly

**L-Shape Detection Examples:**
```
Pattern 1:            Pattern 2:            Pattern 3:
[S] [S] [S]                  [S]          [S]
        [S]                  [S]          [S]
        [S]          [S] [S] [S]          [S] [S] [S]

All spawn coffee at corner position
```

**Documentation Created:**
- `BONUS_TILE_INSTRUCTIONS.md` - Complete user guide
- `DEBUG_MODE_GUIDE.md` - Debug menu documentation  
- `SESSION_12_BONUS_TILES_COMPLETE.md` - Full session transcript

**Files Modified:**
- TileType.swift (added isBonusTile tracking, bonusTile() function)
- BoardManager.swift (L-shape detection, match immunity, direction-based clearing)
- GameViewModel.swift (bonus activation, spawn timing, direction detection)
- GameBoardView.swift (coffee rendering, glow effect)
- ContentView.swift (debug button, debug menu overlay)

**Files Created:**
- BonusTileConfig.swift (all bonus settings)
- DebugMenuView.swift (complete debug UI)
- BONUS_TILE_INSTRUCTIONS.md (user guide)
- DEBUG_MODE_GUIDE.md (debug documentation)
- SESSION_12_BONUS_TILES_COMPLETE.md (session transcript)

---

### Session 14: Character Animation Priority System + Portrait Fix (March 21, 2026) ✅

**Goal:**
- Implement animation priority system for character states
- Fix character portraits not updating during gameplay
- Support Bejeweled-style continuous matching (stable gems during cascades)

**User Requests:**
1. "Create animation priority system so attacks don't interrupt hurt animations"
2. "Fix portraits not changing - they're stuck on idle even when states change"
3. "Allow matching stable gems during cascades (like Bejeweled)"

**Changes Made:**

1. **CharacterAnimationConfig.swift - NEW FILE (Animation Priority System)**
   ```swift
   enum AnimationPriority: Int {
       case canSkip = 1        // Idle, defend - interruptible
       case high = 2           // Attack, spell - important
       case critical = 3       // Hurt, hurt2, victory, defeat - never skip
   }
   
   enum InterruptBehavior {
       case queue     // Add to queue, play in order
       case override  // Higher priority interrupts immediately
   }
   ```
   - **3-tier priority system**: Critical > High > CanSkip
   - **Configurable durations**: Each state has specific timing
   - **Interrupt behavior**: Queue or override modes
   - **Auto-idle**: Returns to idle after animations complete

2. **CharacterAnimationManager.swift - NEW FILE (Queue & State Management)**
   ```swift
   @Observable
   class CharacterAnimationManager {
       var currentState: CharacterState {
           didSet {
               // ✅ Updates character.currentState automatically
               character.currentState = currentState
           }
       }
       
       func requestState(_ newState: CharacterState, force: Bool = false)
       func setStateImmediately(_ state: CharacterState)
   }
   ```
   - **Priority-based queuing**: High priority can interrupt low
   - **Animation timers**: Auto-return to idle after duration
   - **Force mode**: Victory/defeat always show immediately
   - **🎯 KEY FIX**: `didSet` updates `character.currentState` so SwiftUI sees changes

3. **CharacterAnimations.swift - Simplified State Reading (Lines 14-27)**
   ```swift
   var body: some View {
       let displayState = character.currentState  // ✅ Just read from character
       
       Group {
           if character.name == "Ramp" {
               RampAnimatedPortrait(state: displayState)
           } else {
               StaticCharacterPortrait(character: character, displayState: displayState)
           }
       }
   }
   ```
   - **Removed**: Hacky `.id()` modifier with timestamp
   - **Removed**: `getDisplayState()` helper function
   - **Now**: Simply reads `character.currentState` (controlled by animation manager)
   - **Result**: SwiftUI's `@Observable` system works correctly

4. **GameViewModel.swift - All State Changes Use Animation Manager**
   - Line 210: Invalid swap → `.requestState(.hurt2)`
   - Line 231: Return to idle → `.requestState(.idle)`
   - Line 550: Enemy attacks → `.requestState(.hurt)`
   - Line 567: Return to idle → `.requestState(.idle)`
   - **Benefit**: All state changes respect priority and queueing

5. **BattleManager.swift - Animation Manager Integration**
   - Lines 82, 97, 112, 127: Match processing → `.requestState(.attack)`
   - Lines 219, 230: Victory/defeat → `.requestState(.victory/.defeat, force: true)`
   - Lines 272, 289, 306: Spell casts → `.requestState(.spell)`
   - **Force mode**: Victory/defeat always show (bypass queue)

6. **TileType.swift - Per-Gem Stability Tracking (Line 60)**
   ```swift
   var isStable: Bool = true  // ✅ NEW: Tracks if gem can be swapped
   ```
   - **Purpose**: Prevent swapping gems that are falling or spawning
   - **Bejeweled-style**: Can match stable gems during cascades

7. **BoardManager.swift - Stability System**
   - **Line 64**: `canSwap()` checks both gems are stable
   - **Line 335**: `applyGravity()` marks falling gems unstable
   - **Line 377**: `fillEmptySpaces()` marks spawning gems unstable
   - **Line 441**: `markAllGemsStable()` restores after cascades
   - **Result**: Can match stable gems even during cascades!

8. **GameViewModel.swift - Removed Global Processing Lock (Line 96)**
   ```swift
   // REMOVED: guard !isProcessing else { return }
   // NOW: Only check if gems are stable (per-gem check)
   ```
   - **Before**: Entire board locked during cascades
   - **After**: Only falling/spawning gems locked
   - **Bejeweled-style**: Can make new matches during cascades

**Animation Priority Examples:**

**Low Priority (idle) → High Priority (attack)**:
```
Player idle → Match made → Attack interrupts immediately
```

**High Priority (attack) → Critical (hurt)**:
```
Player attacking → Enemy hits → Hurt interrupts attack (higher priority)
```

**Critical (hurt) → High (attack)**:
```
Player taking damage → New match made → Attack QUEUED (waits for hurt to finish)
```

**Force Mode (victory)**:
```
Any state → Victory called with force: true → Victory shows immediately
```

**How Portrait Fix Works:**

**Problem**:
- Animation manager tracked state separately from character
- Views tried to read from global `AnimationManagers` (not `@Observable`)
- SwiftUI never detected state changes
- Portraits stuck on idle

**Solution (Option 4)**:
1. Animation manager's `currentState` has `didSet`
2. `didSet` automatically updates `character.currentState`
3. Views read from `character.currentState` (which is `@Observable`)
4. SwiftUI detects changes and updates views
5. No hacky workarounds needed!

**Result:**
✅ Ramp shows `.hurt` when enemy attacks (even during async turns)
✅ Ramp shows `.hurt2` when invalid swap (different image!)
✅ Ramp shows `.attack` when matching gems
✅ All portraits update instantly when states change
✅ Animation priority system prevents state conflicts
✅ Bejeweled-style continuous matching works perfectly

**Documentation Created:**
- `CharacterAnimationConfig.swift` - Priority system configuration
- `CharacterAnimationManager.swift` - Queue and state management
- `SESSION_14_PORTRAIT_FIX_COMPLETE.md` - Complete fix documentation
- `SESSION_14_QUICK_STATUS.md` - Session status summary

**Files Created:**
- CharacterAnimationConfig.swift (121 lines)
- CharacterAnimationManager.swift (224 lines)
- SESSION_14_PORTRAIT_FIX_COMPLETE.md
- SESSION_14_QUICK_STATUS.md

**Files Modified:**
- TileType.swift (added isStable property)
- BoardManager.swift (stability tracking, canSwap check, markAllGemsStable)
- GameViewModel.swift (removed isProcessing lock, all state changes use animation manager)
- BattleManager.swift (all state changes use animation manager, force mode for victory/defeat)
- CharacterAnimations.swift (simplified to read character.currentState directly)

**What Works Now:**
- ✅ Character portraits update correctly during all gameplay
- ✅ Animation priority system prevents conflicts
- ✅ Bejeweled-style continuous matching (match stable gems during cascades)
- ✅ Per-gem stability prevents invalid swaps
- ✅ Victory/defeat always show (force mode)
- ✅ Auto-return to idle after animations
- ✅ Queue system for overlapping animations

**Status**: ✅ Session 14 100% Complete! All systems working perfectly!

---

### Session 11: Title & Splash Screen Animations + Enemy Turn Fix (March 20, 2026) ✅

**Goal:**
- Add leaf animation to title screen (leaf1-17 cycling)
- Add character animations to splash screen (RK and Milo)
- Fix `ramp_hurt` not displaying during async enemy turns
- Add loop delay option for leaf animation

**User Requests:**
1. "add leaf1.png-leaf17.png cycling with a 1s delay between loops on top of title_screen.png"
2. "add splashrk1.png-splashrk3.png, and splashmilo1.png-splashmilo3.png overlaid on to splash_screen.png at 4fps"
3. "wait, ramp_hurt isn't working again"
4. "can i add a delay between the leaf looping"
5. "can we do splashmilo3/2/1, and splashrk1/2/3" (reverse Milo)

**Changes Made:**

1. **TitleScreenView.swift - Leaf Animation (Lines 18, 40-51, 113-129)**
   ```swift
   @State private var currentLeafFrame = 1  // New state variable
   
   // Leaf animation layer
   Image("leaf\(currentLeafFrame)")
       .resizable()
       .aspectRatio(contentMode: .fit)
       .frame(width: geometry.size.width, height: geometry.size.height)
   
   // Animation function with loop pause
   func startLeafAnimation() {
       let frameDelay = 0.1        // 10fps playback
       let loopPauseDelay = 2.0    // 2 second pause after leaf17
       
       Timer.scheduledTimer(withTimeInterval: frameDelay, repeats: true) { timer in
           if currentLeafFrame < 17 {
               currentLeafFrame += 1
           } else {
               timer.invalidate()
               DispatchQueue.main.asyncAfter(deadline: .now() + loopPauseDelay) {
                   currentLeafFrame = 1
                   startLeafAnimation()
               }
           }
       }
   }
   ```
   - Cycles `leaf1.png` → `leaf17.png` at 10fps
   - Pauses 2 seconds after `leaf17` before looping
   - Displayed at full screen size on top of `title_screen.png`
   - User can adjust `frameDelay` and `loopPauseDelay` as needed

2. **DeveloperSplashView.swift - Character Animations (Lines 13-14, 38-66, 105-125)**
   ```swift
   @State private var currentRKFrame = 1      // RK animation state
   @State private var currentMiloFrame = 1    // Milo animation state
   
   // RK character layer (forward: 1→2→3)
   Image("splashrk\(currentRKFrame)")
       .resizable()
       .aspectRatio(contentMode: .fit)
       .padding(0)
   
   // Milo character layer (reverse: 3→2→1)
   Image("splashmilo\(currentMiloFrame)")
       .resizable()
       .aspectRatio(contentMode: .fit)
       .padding(0)
   
   // Animation function
   func startCharacterAnimations() {
       // RK: forward 1→2→3→loop
       Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
           currentRKFrame += 1
           if currentRKFrame > 3 { currentRKFrame = 1 }
       }
       
       // Milo: reverse 3→2→1→loop
       currentMiloFrame = 3
       Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
           currentMiloFrame -= 1
           if currentMiloFrame < 1 { currentMiloFrame = 3 }
       }
   }
   ```
   - RK animates forward at 4fps: `splashrk1 → splashrk2 → splashrk3`
   - Milo animates backward at 4fps: `splashmilo3 → splashmilo2 → splashmilo1`
   - Both overlaid on `splash_screen.png` at 100% scale
   - Both loop continuously while splash is visible

3. **GameViewModel.swift - Fixed Enemy Turn State Override (Lines 346-375)**
   
   **Problem Identified:**
   - When `asyncEnemyTurn = true`, enemy turn runs in background
   - Player could make new match before enemy sets `.hurt` state
   - Protection code in BattleManager blocked `.hurt` from showing
   - Result: `ramp_hurt.png` never displayed during fast gameplay
   
   **Solution:**
   ```swift
   @MainActor
   private func enemyTurn() async {
       // Skip pre-enemy pause if responsive mode
       if !skipWaitingPauses {
           try? await Task.sleep(for: .milliseconds(400))
       }
       
       // ⚠️ FORCE OVERRIDE: Enemy attack ALWAYS interrupts any other state
       battleManager.enemy.currentState = .attack
       battleManager.player.currentState = .hurt  // ALWAYS SET (removed protection)
       
       // Show visual effects
       isEnemyAttacking = true
       flashPlayer = true
       battleManager.enemyTurn()
       
       try? await Task.sleep(for: .milliseconds(350))
       isEnemyAttacking = false
       flashPlayer = false
       
       try? await Task.sleep(for: .milliseconds(150))
       
       // ⚠️ SAFE IDLE RETURN: Only if still in .hurt state
       if battleManager.player.currentState == .hurt {
           battleManager.player.currentState = .idle
       }
       // Removed .hurt2 check (invalid swaps don't happen during enemy turn)
       
       battleManager.enemy.currentState = .idle
   }
   ```
   
   **What Changed:**
   - Enemy turn now FORCES `.hurt` state immediately (ignores current state)
   - Idle return only happens if Ramp is STILL in `.hurt` (protects new player actions)
   - Removed `.hurt2` protection from idle return (not needed here)
   
   **Result:**
   - `ramp_hurt.png` always displays when enemy attacks
   - Works perfectly with `asyncEnemyTurn = true` and fast gameplay
   - Brief flash of hurt state even if player makes another match immediately

**Asset Requirements:**
- `leaf1.png` through `leaf17.png` (17 images) - Title screen leaves
- `splashrk1.png`, `splashrk2.png`, `splashrk3.png` - RK character frames
- `splashmilo1.png`, `splashmilo2.png`, `splashmilo3.png` - Milo character frames
- `title_screen.png` - Title background (already exists)
- `splash_screen.png` - Splash background (already exists)

**Animation Timing:**
- **Leaf**: 10fps playback (0.1s per frame), 2s pause after loop
- **RK**: 4fps (0.25s per frame), forward cycle
- **Milo**: 4fps (0.25s per frame), reverse cycle
- **Enemy hurt state**: Shows for 350ms minimum, even during async turns

**What Works Now:**
- ✅ Title screen: Leaves fly across in sequence with loop pause
- ✅ Splash screen: RK animates forward, Milo animates backward
- ✅ Enemy attacks: `ramp_hurt.png` always displays correctly
- ✅ Fast gameplay: Hurt state protected from being overwritten
- ✅ Async enemy turns: Work perfectly with visual feedback

**Customization Options:**

**Leaf Speed:**
```swift
let frameDelay = 0.1        // Change for faster/slower playback
let loopPauseDelay = 2.0    // Change loop pause duration
```

**Character Speed:**
```swift
Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true)  // Change 0.25 for different fps
```

**Splash Duration:**
In `DeveloperSplashView.swift`:
```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {  // Change 3.0 for longer/shorter
    skipSplash()
}
```

**Files Modified:**
- TitleScreenView.swift (added leaf animation system)
- DeveloperSplashView.swift (added RK + Milo character animations)
- GameViewModel.swift (fixed enemy turn state override logic)

---

### Session 8: Springy Drag Gesture & Final Animation Tuning (March 16, 2026) ✅

**Goal:**
- Add springiness to drag gestures for fun, playful feel when moving gems
- Maintain smooth swap animations
- Document all final animation values
- **100% PRESERVE raindrop cascade animation** (most critical feature)

**User Request:**
- "I would like to add some springiness to the animation so that when players move them around they're kind of fun and smooth and springy to move"

**Changes Made:**

1. **GameBoardView.swift - Springy Drag Snap-Back (Line 378)**
   ```swift
   withAnimation(.interpolatingSpring(stiffness: 250, damping: 20)) {
       dragOffset.wrappedValue = .zero
   }
   ```
   - **Before**: `.spring(response: 0.3, dampingFraction: 0.6)` - soft, smooth
   - **After**: `.interpolatingSpring(stiffness: 250, damping: 20)` - springy, playful ✅
   - Gems now bounce slightly when released from drag
   - Fun, tactile feel when moving gems around
   - More responsive and game-like

**Drag Gesture Spring Options:**

| Feel | Configuration | Use Case |
|------|--------------|----------|
| **Current (Playful)** ✅ | `stiffness: 250, damping: 20` | Fun, bouncy, responsive |
| **More Springy** | `stiffness: 300, damping: 15` | Very bouncy, arcade-like |
| **Less Springy** | `stiffness: 200, damping: 25` | Gentle bounce |
| **Very Bouncy** | `stiffness: 350, damping: 12` | Game-like, exaggerated |
| **Smooth (Old)** | `response: 0.3, dampingFraction: 0.6` | Soft, no bounce |

**Final Animation Summary:**

1. **Swap Animation (Lines 200-201)**:
   ```swift
   .animation(.easeInOut(duration: 0.4), value: row)
   .animation(.easeInOut(duration: 0.4), value: col)
   ```
   - Silky smooth glide when swapping
   - No bounce, pure ease-in-out curve

2. **Drag Snap-Back (Line 378)**:
   ```swift
   .interpolatingSpring(stiffness: 250, damping: 20)
   ```
   - Springy bounce when releasing drag
   - Fun, playful feel

3. **Raindrop Cascade (Lines 276-323)**:
   - **100% PRESERVED** - No changes
   - Spring animation: `.spring(response: RAINDROP_SPAWN_DURATION, dampingFraction: 0.7)`

4. **Match Disappear (Lines 193-198)**:
   - Scale to 0.01 combined with opacity fade
   - Simple, clean removal

5. **Invalid Shake (Lines 321-328)**:
   - Gentle shake: 6 repeats, ±5 pixels, 0.3s timeout

**What Was PRESERVED (100% unchanged):**
✅ **Raindrop cascade animation** - All timing, delays, and spawn logic untouched
✅ **Spawn delay system** - `spawnDelay > 0` conditional logic intact
✅ **Swap animation smoothness** - `.easeInOut(duration: 0.4)` unchanged
✅ **Match disappear** - Simple scale + opacity unchanged
✅ **All user-adjustable constants** - RAINDROP_BASE_DELAY, RAINDROP_RANDOMNESS, RAINDROP_SPAWN_DURATION

**Result:**
✅ Dragging gems feels springy and fun (stiffness: 250, damping: 20)
✅ Swaps remain silky smooth (easeInOut 0.4s)
✅ Raindrop cascade 100% preserved
✅ All animations working perfectly
✅ **USER CONFIRMED: Ready for next modifications**

**Files Modified:**
- GameBoardView.swift (updated drag snap-back spring, line 378)
- AI_CONTEXT.md (documented springy drag gesture)

---

### Session 10: Character Portrait State System - Hurt vs Hurt2 (March 20, 2026) ✅

**Goal:**
- Fix `ramp_hurt` not showing when `skipWaitingPauses = true`
- Implement separate hurt states for enemy attacks vs invalid swaps
- Ensure all character states display correctly during fast gameplay

**User Request:**
- "when i change skipwaitingpauses to true - it doesn't run ramp_hurt because the attack from the enemy is happening in the background"
- "play ramp_hurt2.png when invalid swap happens, and ramp_hurt.png when hes attacked"

**Problem Identified:**
1. When `skipWaitingPauses = true` and `asyncEnemyTurn = true`, Ramp's `.hurt` state was being overwritten
2. If player made a new match while enemy was attacking in background, the new match would set Ramp to `.attack`, overriding `.hurt`
3. No distinction between enemy damage (fair) and invalid swap damage (mistake)

**Changes Made:**

1. **Character.swift - Added `.hurt2` State (Line 56)**
   ```swift
   enum CharacterState {
       case idle       // Normal standing
       case attack     // Attacking
       case hurt       // Taking damage from enemy
       case hurt2      // Taking damage from mistake (invalid swap) ⚠️ NEW!
       case defend     // Blocking/shielding
       case spell      // Casting ability
       case victory    // Won the battle
       case defeat     // Lost the battle
   }
   ```
   - `.hurt` = Enemy attack damage (shows `ramp_hurt.png`)
   - `.hurt2` = Invalid swap penalty (shows `ramp_hurt2.png`)

2. **Character.swift - Updated Image Name Mapping (Line 70)**
   ```swift
   case .hurt:
       return "ramp_hurt"       // Enemy attack damage
   case .hurt2:
       return "ramp_hurt2"      // Invalid swap penalty
   ```

3. **GameViewModel.swift - Invalid Swap Uses `.hurt2` (Line 144)**
   ```swift
   battleManager.player.currentState = .hurt2  // Different hurt image for invalid swap!
   ```

4. **GameViewModel.swift - Protected Both Hurt States in Enemy Turn (Line 372)**
   ```swift
   // Only set to idle if player is STILL in .hurt or .hurt2 state
   if battleManager.player.currentState == .hurt || battleManager.player.currentState == .hurt2 {
       battleManager.player.currentState = .idle
   }
   ```
   - Prevents `.idle` from overwriting `.attack` if player made new match

5. **BattleManager.swift - Protected Both States in Match Processing (Lines 79, 91, 103, 115)**
   ```swift
   // Don't override .hurt/.hurt2 states (taking damage)
   if player.currentState != .hurt && player.currentState != .hurt2 {
       player.currentState = .attack
   }
   ```
   - Applied to: Sword matches, Fire matches, Shield matches, Heart matches
   - Prevents new matches from overwriting damage states

6. **BattleManager.swift - Protected Both States in Idle Return (Line 171)**
   ```swift
   // Only set to idle if player is still in attack/defend state
   // Don't override .hurt/.hurt2 (taking damage) or other critical states
   if player.currentState == .attack || player.currentState == .defend {
       player.currentState = .idle
   }
   ```

7. **CharacterAnimations.swift - Added `.hurt2` Case to Switch (Line 57)**
   ```swift
   case .hurt2:
       // Hurt2 state - invalid swap penalty - static image (FOR NOW)
       StaticImage(imageName: "ramp_hurt2")
   ```

**State Flow Examples:**

**Enemy Attack (Normal):**
```
1. Enemy turn starts in background
2. Ramp.currentState = .hurt (shows ramp_hurt.png)
3. Player makes new match
4. Check: Is Ramp .hurt or .hurt2? YES → Skip setting .attack
5. .hurt animation completes → Set to .idle
6. THEN Ramp changes to .attack for new match
```

**Invalid Swap (Penalty):**
```
1. Player swaps invalid gems
2. Gems shake and swap back
3. Ramp.currentState = .hurt2 (shows ramp_hurt2.png)
4. 8 damage penalty applied
5. Flash animation plays
6. .hurt2 animation completes → Set to .idle
```

**State Protection Logic:**
- New matches check: "Is player currently .hurt or .hurt2?" → Skip state change if true
- Idle return checks: "Is player STILL .hurt or .hurt2?" → Only then reset to idle
- Prevents state overwriting during fast, overlapping actions

**Asset Requirements:**
- `ramp_hurt.png` - Enemy attack damage (should exist)
- `ramp_hurt2.png` - Invalid swap penalty (user added to assets)

**Timing:**
- Invalid swap hurt: 350ms flash + 150ms transition = 500ms total
- Enemy attack hurt: 350ms flash + 150ms transition = 500ms total
- Both protected from being overwritten by new matches

**Result:**
✅ Ramp always shows `.hurt` when enemy attacks (even with fast gameplay)
✅ Ramp shows `.hurt2` when invalid swap happens (different image!)
✅ State protection prevents overwrites during background enemy turns
✅ Works perfectly with `skipWaitingPauses = true` and `asyncEnemyTurn = true`
✅ Both hurt animations complete fully before returning to idle
✅ Fast, responsive gameplay maintained while preserving visual feedback

**What Works Now:**
- ✅ Enemy attack → `ramp_hurt.png` displays correctly
- ✅ Invalid swap → `ramp_hurt2.png` displays correctly
- ✅ Fast gameplay doesn't skip hurt states
- ✅ Multiple overlapping actions don't conflict
- ✅ Portrait states always reflect current situation

**Files Modified:**
- Character.swift (added `.hurt2` state, updated image mapping)
- GameViewModel.swift (invalid swap uses `.hurt2`, protected both hurt states)
- BattleManager.swift (protected both hurt states in all match types, idle return logic)
- CharacterAnimations.swift (added `.hurt2` switch case for rendering)

---

### Session 9: Responsive Gameplay - Non-Blocking Enemy Attacks (March 19, 2026) ✅

**Goal:**
- Reduce waiting time between player matches
- Keep all animation speeds unchanged
- Make board unlock faster without removing visual feedback
- Allow experimentation with timing settings

**User Request:**
- "Less waiting between when I can make moves, without taking away from current gameplay experience"
- "User should not be able to make matches during autochain matches"

**Changes Made:**

1. **GameViewModel.swift - Added Responsive Gameplay Control Flags (Lines 26-39)**
   ```swift
   // ⚡ RESPONSIVE GAMEPLAY CONTROLS (NEW!)
   var skipWaitingPauses: Bool = true      // Skip artificial pauses
   var asyncEnemyTurn: Bool = true         // Enemy attacks in background
   ```
   - **Easy revert**: Change both to `false` to restore original behavior
   - Two independent toggles for fine-tuning

2. **GameViewModel.swift - Non-Blocking Enemy Turn (Lines 166-178)**
   ```swift
   if asyncEnemyTurn {
       // Board unlocks immediately, enemy attacks in background
       Task {
           await enemyTurn()
       }
   } else {
       // Original: wait for enemy turn to complete
       await enemyTurn()
   }
   ```
   - **Async mode**: Board unlocks ~500-800ms sooner
   - **Original mode**: Traditional turn-based blocking

3. **GameViewModel.swift - Skip Waiting Pauses Throughout (Multiple Lines)**
   - Line 216: Skip pre-buzz pause (150ms → 0ms)
   - Line 233: Shorter disappear wait (300ms → 200ms)
   - Line 239: Skip explosion cleanup pause (100ms → 0ms)
   - Line 263: Faster fall wait (500ms → 300ms)
   - Line 276: Faster spawn wait (calculated × 0.7)
   - Line 292-295: Skip Power Surge pauses (1600ms → 0ms)
   - Line 319: Skip cascade check pause (100ms → 0ms)
   - Line 353: Skip pre-enemy pause (400ms → 0ms)

**Timing Comparison:**

| Event | Original | Responsive | Time Saved |
|-------|----------|-----------|------------|
| Pre-buzz pause | 150ms | 0ms | 150ms |
| Disappear wait | 300ms | 200ms | 100ms |
| Explosion cleanup | 100ms | 0ms | 100ms |
| Fall animation wait | 500ms | 300ms | 200ms |
| Spawn wait | ~560ms | ~390ms | ~170ms |
| Power Surge delays | 1600ms | 0ms | 1600ms |
| Pre-enemy pause | 400ms | 0ms | 400ms |
| **TOTAL PER MATCH** | **~2700ms** | **~1200ms** | **~1500ms** |

**What Changed:**
- ✅ Board unlocks 50-60% faster
- ✅ All animations play at same visual speed
- ✅ Enemy attacks in background (you can select next match)
- ✅ Power Surge effect still plays (pauses skipped)
- ✅ Two easy toggle switches for experimentation

**What DIDN'T Change:**
- ❌ Animation durations (gems still fall/disappear at same speed)
- ❌ Visual appearance (everything looks identical)
- ❌ Game logic (damage, scoring, match detection)
- ❌ Cascade locking (still can't match during falling gems)

**Damage Application:**
- **Player damage to enemy**: Applied instantly when `battleManager.processMatches(matches)` runs
- **Enemy damage to player**: Applied instantly when `battleManager.enemyTurn()` runs
- **Animations**: Visual-only, damage already applied before they play
- **Result**: Health bars update immediately, animations are just cosmetic

**Documentation Created:**
- `RESPONSIVE_GAMEPLAY_CHANGES.md` - Full guide with revert instructions
- `blocking_nonblocking.md` - Detailed explanation of blocking vs non-blocking

**How to Revert:**
```swift
// To restore original behavior:
var skipWaitingPauses: Bool = false  // Line 32
var asyncEnemyTurn: Bool = false     // Line 37
```

**Result:**
✅ Gameplay feels ~60% faster (less dead time between matches)
✅ Same visual quality (no animations sped up)
✅ Easy to customize or revert
✅ User confirmed ready to test!

**Files Modified:**
- GameViewModel.swift (added control flags, modified timing throughout)
- RESPONSIVE_GAMEPLAY_CHANGES.md (created - user guide)
- AI_CONTEXT.md (updated this section)

---

### Session 8: Springy Drag Gesture & Final Animation Tuning (March 16, 2026) ✅

---

### Session 7: Match Animation Overhaul - Wiggle, Disappear, Swap Fixes (March 16, 2026)

**Goal:**
- Create satisfying match animations (wiggle before disappearing)
- Fix gems disappearing/reappearing during swaps
- Separate spawn animations from swap animations completely
- Make animations feel weighty and impactful

**Problems Identified:**
1. Gems just "clicked off" like a light switch (no animation)
2. Gems disappeared and reappeared during swaps (spawn animation interfering)
3. No visual feedback before tiles vanish
4. Swap and spawn animations were interfering with each other

**Changes Made:**

1. **GameBoardView.swift - Match Wiggle Animation**
   - Added state variables: `matchWiggleScale`, `matchWiggleRotation`
   - Created `startMatchWiggle()` function: 8 wiggles, ±8° rotation, 1.02↔1.08 scale
   - Triggers when `isShaking` becomes true

2. **GameBoardView.swift - Disappear Transition**
   - `.transition(.asymmetric(removal: .scale(scale: 0.3).combined(with: .opacity)))`
   - Tiles shrink to 30% while fading out

3. **GameBoardView.swift - Conditional Spawn Animation**
   - Spawn animation ONLY if `spawnDelay > 0`
   - No spawn delay = instant appearance (for swaps)

4. **BoardManager.swift - Clear Spawn Delays on Swap**
   - `swap()` function now clears spawn delays for swapped tiles

5. **GameViewModel.swift - Swap Flow Refactor**
   - Pre-check: swap → check matches → swap back (instant)
   - THEN animate based on validity
   - Prevents visual flashing

**Animation Timings:**
- Wiggle: 450ms
- Disappear: 500ms
- Valid swap: 400ms
- Invalid swap: 300ms forward + 200ms shake + 300ms back

**Status:**
✅ Wiggle animation working
✅ Disappear transition implemented
⚠️ Swap fix in progress (may still have issues)
⚠️ Needs testing

**Files Modified:**
- GameBoardView.swift (wiggle, spawn conditions, transitions)
- BoardManager.swift (clear spawn delays)
- GameViewModel.swift (swap flow, timing, withAnimation wrapper)

---

### Session 6: Bottom-to-Top Initial Board Fill (March 16, 2026)

**Goal:**
- Make initial board fill (game start/reset) use a "filling container" effect
- Gems should appear from bottom row to top row with wave-like progression
- Different from gameplay refills which remain random/scattered

**Changes Made:**

1. **BoardManager.swift - New Function: `fillEmptySpacesWithBottomUpRaindrop()`**
   - **Option A (ACTIVE)**: Staggered row delays creating wave effect
     - Bottom row: 0.0-0.1s delays
     - Each row up: +0.1s base delay
     - Formula: `baseDelay = Double(rowIndex) * 0.1`
     - Random offset within each row: `0...0.1s`
   - **Option B (Available)**: Random delays but processed bottom-to-top
     - Toggle with `useOptionA = false`

2. **BoardManager.swift - Modified `generateInitialBoard()`**
   - Changed from `fillEmptySpacesWithRaindrop()` to `fillEmptySpacesWithBottomUpRaindrop()`
   - Only affects initial board setup

3. **BoardManager.swift - Kept Original Function**
   - `fillEmptySpacesWithRaindrop()` still exists for gameplay refills

**Result:**
✅ **Initial board fill**: Beautiful bottom-to-top wave effect (0.1s per row)
✅ **Gameplay refills**: Random raindrop effect (original behavior)
✅ **Two distinct fill styles**: Start/reset vs during-game

**Files Modified:**
- BoardManager.swift (added new function, modified generateInitialBoard)

---

### Session 5: Game Mode Separation - Chain Mode No Match-3 (March 15, 2026)

**Problem Identified:**
- Chain mode was processing BOTH manual chains AND automatic match-3 patterns
- User wanted chain mode to ONLY work with manual chains (no auto-matching)
- Match-3 mechanics should be completely disabled in chain mode

**Changes Made:**

1. **GameViewModel.swift - Added Game Mode Tracking (Line 29)**
   ```swift
   // Game mode tracking
   var currentGameMode: GameMode = .swap
   ```
   - ViewModel now tracks which mode is active (swap vs chain)
   - Defaults to swap mode on initialization

2. **GameViewModel.swift - Modified processCascades() (Lines 107-110)**
   ```swift
   @MainActor
   private func processCascades() async {
       // 🔗 CHAIN MODE: Skip match-3 processing entirely
       if currentGameMode == .chain {
           return
       }
       // ... rest of match-3 cascade logic
   }
   ```
   - Early return exits function if in chain mode
   - Prevents any match-3 detection and processing
   - Tiles still fall and refill, but no automatic matching

3. **ContentView.swift - Game Mode Synchronization (Lines 72-77)**
   ```swift
   .onChange(of: gameMode) { _, newMode in
       viewModel.currentGameMode = newMode
   }
   .onAppear {
       viewModel.currentGameMode = gameMode
   }
   ```
   - Syncs selected game mode to ViewModel
   - Updates whenever user switches modes in pause menu
   - Ensures ViewModel always knows current mode

**Result:**
✅ **SWAP MODE** (original behavior):
   - Match-3 patterns detected and processed
   - Cascades trigger automatically
   - Battle effects from matches

✅ **CHAIN MODE** (new behavior):
   - ONLY manual chains processed
   - No automatic match-3 detection
   - Tiles fall and refill normally
   - No cascade loops after chain release
   - Player has full control over damage timing

**How It Works:**
- User draws chain → Tiles removed → Gravity applies → New tiles spawn → `processCascades()` called
- In swap mode: Function continues, finds matches, creates cascades
- In chain mode: Function returns immediately, no match detection occurs
- Board still looks normal, but won't auto-match 3-in-a-row

**Files Modified:**
- GameViewModel.swift (added currentGameMode property, modified processCascades)
- ContentView.swift (added game mode synchronization)

---

### Session 4: Smooth Gem Animations - Spring Physics (March 15, 2026)

**Problem Identified:**
- Gems were "snapping" into place with no animation
- No bounce, spring, or transition effects
- Swaps, falls, and new tile spawns felt abrupt and jarring

**Changes Made:**

1. **GameBoardView.swift - Global Board Animation (Line 28)**
   ```swift
   .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.boardManager.tiles.map { $0.map { $0?.id } })
   ```
   - Watches entire board state for changes
   - Triggers spring animation when any tile ID changes
   - response: 0.5s = animation duration
   - dampingFraction: 0.7 = moderate bounce (lower = bouncier)

2. **GameBoardView.swift - Individual Tile Animations (Lines 171-172)**
   ```swift
   .animation(.spring(response: 0.45, dampingFraction: 0.68), value: row)
   .animation(.spring(response: 0.45, dampingFraction: 0.68), value: col)
   ```
   - Each tile animates when row or column changes
   - Slightly faster (0.45s) and bouncier (0.68) than global
   - Triggers during gravity falls and swaps

3. **GameBoardView.swift - Improved Transitions (Lines 164-168)**
   ```swift
   .transition(
       .asymmetric(
           insertion: .scale(scale: 0.1).combined(with: .opacity),
           removal: .scale(scale: 0.5).combined(with: .opacity)
       )
   )
   ```
   - New tiles: Pop in from 0.1 scale with fade
   - Removed tiles: Shrink to 0.5 scale with fade
   - Asymmetric = different in/out animations

**Result:**
✅ Smooth falling animations with physics bounce
✅ Swaps animate smoothly between positions
✅ New tiles pop in with scale effect
✅ Matched tiles shrink and fade out
✅ All movements use spring physics (natural feel)

**Animation Parameters Explained:**
- **response**: How long the animation takes (seconds)
- **dampingFraction**: How bouncy (0.0 = infinite bounce, 1.0 = no bounce)
- **scale**: Size multiplier (0.1 = 10% size, 1.0 = 100% size)

**Files Modified:**
- GameBoardView.swift (added animations and transitions)

---

### Session 3: 4-Match Power Surge Effect - WORKING! (March 12, 2026)

**Problem Identified:**
- User wanted Power Surge to trigger on 4+ tile matches (not cascading combos)
- Initial implementation had effect triggering on 4-chain combos which was too hard to achieve

**Changes Made:**

1. **BattleManager.swift (Lines 127-135)**
   - Changed from `comboCount` to `totalMatches` calculation
   - Now sums all tiles matched: `matches.reduce(0) { $0 + $1.count }`
   - Triggers when total matches >= 4 in a single turn
   - Battle narrative shows "⚡ POWER SURGE! X MATCHES! +2 bonus mana!"

2. **GameViewModel.swift (Lines 143-151)**
   - Added debug print statements to track Power Surge detection
   - Added 100ms delay before 1500ms wait to give SwiftUI time to see flag change
   - Properly resets `triggeredPowerSurge` flag after effect completes

3. **ContentView.swift (Lines 108-115)**
   - Added PowerSurgeEffect overlay to GameScreen ZStack
   - Positioned with z-index 500 (above game, below pause menu)
   - Effect covers entire screen (HUD + Battle + Board)

**Result:**
✅ Power Surge triggers on ANY 4+ tile match in one move
✅ Full-screen golden lightning effect with text
✅ Screen flash animation
✅ Battle narrative announces the surge
✅ Awards +2 bonus mana
✅ Easy to test: Match 4-5 tiles or use coffee cup ability
✅ 100% code-based - no image assets needed

**How It Works:**
1. Player matches 4+ tiles (or uses coffee cup ability for guaranteed trigger)
2. BattleManager calculates total matches and sets `triggeredPowerSurge = true`
3. GameViewModel detects flag, waits 100ms + 1500ms for effect to play
4. ContentView shows `PowerSurgeEffect` overlay covering entire screen
5. Effect displays: blue flash → diagonal lightning bolt → particles → text
6. Flag resets after 1.6 seconds total
7. Game continues normally

**Files Modified:**
- ChainComboEffects.swift (created - visual effect code with custom lightning shape)
- GameAssets.swift (added config toggles)
- BattleManager.swift (detection logic)
- GameViewModel.swift (timing control)
- ContentView.swift (display overlay)

---

### Session 4: Custom Blue Lightning Effect (March 12, 2026)

**Changes Made:**

1. **ChainComboEffects.swift - Complete Visual Overhaul**
   - Changed from 7 small vertical yellow bolts to **1 massive diagonal blue bolt**
   - Created `DiagonalCracklingBolt` custom Shape (replaces `CracklingLightningBolt`)
   - Lightning goes from top-left (0.1, 0.05) to bottom-right (0.9, 0.92)
   - 16+ zigzag points for crackling effect + 5 side branches
   - Changed colors: yellow/orange → **cyan/blue/white gradient**
   - Line width: 3px → **8px** (much thicker)
   - Shadows: yellow/white → **cyan (30px) + blue (20px) + white (15px)**

2. **Particle System Enhanced**
   - Increased from 20 → **40 particles**
   - Changed from solid yellow → **cyan/blue gradient**
   - Varied sizes: 3-12px (was 4-10px)
   - Larger spread: ±200x/±300y (was ±150x/±200y)
   - Varied blur: 1-4px for depth effect

3. **Screen Flash Color**
   - Changed from solid yellow → **cyan with 0.4 opacity** (more subtle)

4. **Font Fixed**
   - Changed `.gameTitle()` (didn't exist) → `.gameScore()` (OverQuest font)
   - Both title and subtitle now use custom OverQuest font

**How to Customize Lightning:**
- **Method 1 (Current):** Edit `DiagonalCracklingBolt` path coordinates
- **Method 2:** Import SVG and convert to Path
- **Method 3:** Use PNG image instead (replace `lightningBolts` with `Image()`)
- **Method 4:** Use Lottie animation for complex effects

**Result:**
✅ ONE massive diagonal blue lightning bolt across entire screen
✅ Intense cyan/blue glow effect
✅ 40 blue particles with gradient and depth
✅ Blue screen flash
✅ Custom OverQuest font working
✅ Fully customizable via code (no assets needed)

---

### Session 2: Initial Power Surge Attempt (Debugging Session)

**Note:** This session involved extensive debugging of indentation issues and view hierarchy problems. The effect was originally placed in BattleSceneView (wrong - only 42% of screen) instead of ContentView (correct - full screen). Final working implementation documented in Session 3 above.

---

### Session 1: Gem Selector Positioning Fix

**Problem Identified:**
- User had TWO gem selectors appearing:
  1. A permanent one always visible below coffee button (INCORRECT)
  2. A popup one that appeared above coffee button (CORRECT but wrong position)

**Changes Made:**

1. **BattleSceneView.swift (Lines 52-71)**
   - REMOVED the permanent `GemTypeSelector` that was always showing
   - Kept only the `CoffeeCupAbilityButton` in the left section
   - Changed VStack alignment from `.leading` to `.center`
   - Removed the extra `.frame(maxWidth: .infinity, alignment: .center)` wrapper

2. **ContentView.swift (Line 92)**
   - Changed popup position from `0.30` to `0.44` of screen height
   - This moves the gem selector from ABOVE to BELOW the coffee button
   - Updated comment to reflect new position

**Result:**
✅ Only ONE gem selector now exists
✅ It appears as a popup BELOW the coffee button
✅ Activates when coffee button is pressed
✅ Can be dismissed by tapping outside

---

### Session 13: Bonus Blast Visual Effects + Cross Blast Combo (March 21-22, 2026) ✅ FULLY WORKING

**Goal:**
- Replace circular explosions with dramatic blast effects across row/column
- Support custom hand-drawn animated blasts
- Implement cross blast when two bonus tiles are matched
- Provide complete PNG specifications for hand-drawn animations
- **FIXED**: Blast now originates FROM bonus gem position and expands outward

**User Requests:**
1. "can i change the type of explosion effect during the bonus tile? maybe even a custom one. I want one long blast across the row or column."
2. "if two bonus gems are swiped with each other, have BOTH the horizontal row and vertical column where the match occurs be cleared."
3. "can i have the hand drawn animation originate at the match origin"
4. "provide the image specifications for a png sequenced hand animated blast"
5. "add two bonus tiles next to each other in the debug menu"
6. "is it possible to have the blast visual originate at the bonus gem position and blast outwards in the relevant directions" → **FIXED**

**Changes Made:**

1. **BonusBlastEffects-Views.swift - NEW FILE (Complete blast system)**
   ```swift
   struct BlastEffectConfig {
       static let enabled: Bool = true
       static let duration: Double = 0.6         // Animation timing
       static let color: Color = .white          // Blast color
       static let thickness: CGFloat = 0.8       // Beam width
       static let particleCount: Int = 15        // Particles along blast
       static let particleSize: CGFloat = 8      // Particle size
       static let scatterParticles: Bool = true  // Spray effect
       static let scatterDistance: CGFloat = 40  // Scatter range
   }
   ```
   - **Code-based blast** (default): Pure SwiftUI, no images needed
   - **Custom image blast**: Supports hand-drawn PNG sequences
   - **Cross blast support**: Can show multiple blasts simultaneously

2. **Code-Based Blast Features (BonusBlastEffects-Views.swift)**
   - **Horizontal blast**: Rectangle with gradient, expands left-to-right FROM bonus position ✅
   - **Vertical blast**: Rectangle with gradient, expands top-to-bottom FROM bonus position ✅
   - **Origin point**: Blast centered AT bonus gem (col * tileSize + tileSize/2) ✅
   - **Expansion**: Width/height scales from 0 → full board size ✅
   - **Particle system**: 15 particles scatter perpendicular to blast
   - **Glow effects**: Triple shadow layers (opacity 0.8, 0.5)
   - **Screen blend mode**: Additive blending for bright effect
   - **Customizable**: Color, thickness, speed, particle density

3. **Custom Image Blast Features (BonusBlastEffects-Views.swift)**
   - **Frame-by-frame animation**: PNG sequences (1-2-3-4-5-6)
   - **Origin expansion**: Blast expands from match position outward
   - **Horizontal images**: `bonus_blast_row_1.png` through `bonus_blast_row_6.png`
   - **Vertical images**: `bonus_blast_col_1.png` through `bonus_blast_col_6.png`
   - **Adjustable framerate**: 6fps, 12fps (recommended), or custom
   - **Scale animation**: Expands from 0 to full width/height

4. **GameViewModel.swift - Cross Blast Implementation (Lines 117-165)**
   ```swift
   // Check if BOTH tiles are bonus tiles (SUPER COMBO!)
   let fromIsBonus = boardManager.gem(at: from)?.isBonusTile == true
   let toIsBonus = boardManager.gem(at: to)?.isBonusTile == true
   let isSuperCombo = fromIsBonus && toIsBonus
   
   if isSuperCombo {
       await processCrossBlast(at: from)  // Clear BOTH row AND column!
   }
   ```
   - Detects when two bonus tiles are swapped together
   - Triggers special cross blast instead of single direction
   - Clears entire row AND entire column simultaneously

5. **GameViewModel.swift - processCrossBlast() Function (Lines 477-520)**
   ```swift
   bonusBlasts = [
       BonusBlastData(position: position, isRow: true, ...),   // Horizontal
       BonusBlastData(position: position, isRow: false, ...)   // Vertical
   ]
   ```
   - Creates TWO blasts at the same time
   - Both originate from the match position
   - Visual **+** cross pattern across the board
   - Double the damage (clears all positions in row + column)

6. **GameViewModel.swift - Changed bonusBlast to bonusBlasts Array (Line 73)**
   ```swift
   var bonusBlasts: [BonusBlastData] = []  // Can show multiple for cross blast
   ```
   - Changed from single optional to array
   - Supports displaying multiple blasts simultaneously
   - Required for cross blast effect

7. **GameBoardView.swift - Multiple Blast Rendering (Lines 143-150)**
   ```swift
   ForEach(viewModel.bonusBlasts) { bonusBlast in
       BonusBlastView(
           blastData: bonusBlast,
           boardSize: viewModel.boardManager.size,
           tileSize: tileSize
       )
   }
   ```
   - Renders all active blasts (1 for single, 2 for cross)
   - Each blast animates independently
   - Overlays correctly on game board

8. **DebugMenuView.swift - Cross Blast Test Button (Lines 239-250)**
   ```swift
   debugButton(title: "⚔️ Spawn TWO at (4,4) + (4,5) [CROSS TEST]", ...) {
       // Spawns two bonus tiles next to each other
       // Perfect for testing cross blast effect
   }
   ```
   - New orange button in debug menu
   - Spawns two bonus tiles at (4,4) and (4,5)
   - Horizontal neighbors - easy to test cross blast
   - Removes existing gems first (no overlap)

9. **BONUS_BLAST_PNG_SPECS.md - NEW FILE (Complete art guide)**
   
   **Horizontal Blast Specifications:**
   - **Dimensions**: 2048 × 256 pixels (wide and thin)
   - **Files**: `bonus_blast_row_1.png` through `bonus_blast_row_6.png`
   - **Resolution**: 144 DPI
   - **Format**: PNG with transparency
   
   **Vertical Blast Specifications:**
   - **Dimensions**: 256 × 2048 pixels (tall and thin)
   - **Files**: `bonus_blast_col_1.png` through `bonus_blast_col_6.png`
   - **Resolution**: 144 DPI
   - **Format**: PNG with transparency
   
   **6-Frame Animation Sequence:**
   1. Frame 1: Faint glow (10% size, centered at match origin)
   2. Frame 2: Expanding beam (40% length from center)
   3. Frame 3: **PEAK** - Full blast (100% length, maximum brightness)
   4. Frame 4: Sustaining (100% length, 80% brightness)
   5. Frame 5: Fading (100% length, 50% brightness)
   6. Frame 6: Almost gone (100% length, 20% brightness)
   
   **Cross Blast Requirements:**
   - Uses same 12 files (6 horizontal + 6 vertical)
   - Both animations play simultaneously
   - Creates **+** pattern across the board

**How It Works:**

**Single Bonus Tile:**
```
Horizontal Swap → Blast expands FROM bonus gem left AND right → Clear row
Vertical Swap   → Blast expands FROM bonus gem up AND down     → Clear column
```

**Cross Blast (Bonus + Bonus):**
```
         ║
         ║ (up)
═════════☕═════════  ← Blasts originate AT the bonus gem position
  (left)  ║ (down)
          ║
```

**Blast Origin Animation:**
- Blast starts at 0 scale (invisible)
- Position is FIXED at bonus gem location (col * tileSize + tileSize/2)
- Width/height expands from 0 → full board size
- Rectangle stays centered at origin while growing
- Creates "explosion FROM the gem" effect

**Custom Image Animation Flow:**
```
1. Match occurs at position (4,4)
2. Blast starts at (4,4) with scale 0
3. Expands outward to full width/height
4. Frames 1→2→3→4→5→6 play at 12fps
5. Frame 3 is peak (brightest, most dramatic)
6. Fades out after frame 6
```

**Customization Examples:**

**Fire Blast:**
```swift
static let color: Color = .orange
static let thickness: CGFloat = 1.2
static let particleCount: Int = 30
```

**Ice Blast:**
```swift
static let color: Color = .cyan
static let duration: Double = 0.4  // Faster
static let scatterDistance: CGFloat = 60  // Wide spray
```

**Laser Beam:**
```swift
static let thickness: CGFloat = 0.3  // Thin
static let scatterParticles: Bool = false  // No scatter
static let particleCount: Int = 0  // No particles
```

**Enable Custom Images:**

In `GameViewModel.swift`, line ~435:
```swift
bonusBlasts = [BonusBlastData(
    position: position,
    isRow: clearRow,
    color: .yellow,
    id: UUID(),
    useCustomImages: true,  // ← ENABLE THIS
    frameCount: 6,
    frameRate: 12
)]
```

Also in `processCrossBlast`, line ~505.

**Testing Instructions:**

**Test Code-Based Blast:**
1. Run game (Command+R)
2. Open debug menu (hammer icon)
3. Click "⚔️ Spawn TWO at (4,4) + (4,5) [CROSS TEST]"
4. Swipe them together horizontally
5. See **white cross blast** (horizontal + vertical)

**Test Custom Images:**
1. Add 12 PNG files to Assets.xcassets (6 row + 6 col)
2. Enable `useCustomImages: true` in code
3. Repeat test above
4. See your custom animation expand from match origin

**Result:**
✅ Single bonus blast works (row OR column based on swipe)
✅ Cross blast works (row AND column when bonus + bonus)
✅ Code-based blasts look epic (no images needed)
✅ **Blasts originate FROM bonus gem and expand outward (FIXED)**
✅ Custom image support ready (with expansion animation)
✅ Debug menu has cross blast test button
✅ Complete PNG specifications provided

**What Works Now:**
- ✅ Single bonus tile → directional blast (horizontal or vertical)
- ✅ Double bonus tiles → cross blast (both directions)
- ✅ Code-based effects with particles and glow
- ✅ **Blast originates FROM bonus gem position** ✅
- ✅ **Expansion animation (0 → full size) centered at match** ✅
- ✅ Custom image support with frame-by-frame animation
- ✅ Debug menu test button for cross blast
- ✅ Full art specifications document

**Assets Requirements:**

**Code-Based (Active Now):**
- ❌ NO IMAGES REQUIRED - 100% SwiftUI code
- White blast color (customizable to any color)

**Custom Images (Optional):**
- `bonus_blast_row_1.png` through `bonus_blast_row_6.png` (2048×256px)
- `bonus_blast_col_1.png` through `bonus_blast_col_6.png` (256×2048px)
- Total: 12 PNG files with transparency
- Frame rate: 12 FPS recommended (adjustable)

**Documentation Created:**
- `BONUS_BLAST_PNG_SPECS.md` - Complete image specifications and art guide
- Updated `AI_CONTEXT.md` (this file)

**Files Created:**
- BonusBlastEffects-Views.swift (complete blast system with code-based + custom image support)
- BONUS_BLAST_PNG_SPECS.md (art specifications)

**Files Modified:**
- GameViewModel.swift (added cross blast detection, processCrossBlast function, changed bonusBlast to bonusBlasts array)
- GameBoardView.swift (renders multiple blasts with ForEach)
- DebugMenuView.swift (added cross blast test button)
- AI_CONTEXT.md (documented all changes)

**Customization Guide:**
- **Colors**: Edit `BlastEffectConfig.color` (line 32 in BonusBlastEffects-Views.swift)
- **Speed**: Edit `BlastEffectConfig.duration` (line 26)
- **Thickness**: Edit `BlastEffectConfig.thickness` (line 38)
- **Particles**: Edit `BlastEffectConfig.particleCount` (line 44)
- **Spray**: Edit `BlastEffectConfig.scatterDistance` (line 58)

**Status**: ✅ Bonus blast system fully operational! Code-based blasts working, custom image support ready, cross blast implemented! 💥⚡

---

## 📝 COMPONENT REFERENCE

### CoffeeCupAbilityButton (BattleSceneView.swift)
- Size: 60x60 circular button
- Icon: `cup.and.saucer.fill` SF Symbol
- Mana display: PieChartFill shape (custom)
- Animation: Opacity and scale on disable/enable

### GemTypeSelector (BattleSceneView.swift, lines 349-401)
- Display: VStack with "SELECT:" text + HStack of 6 buttons
- Button size: 20x20 points each
- Background: Black with 0.9 opacity, rounded corners
- Tile order: Sword, Fire, Shield, Heart, Mana, Poison

### CharacterPortrait (BattleSceneView.swift)
- Height: 160 points
- Attack animation: 15-point horizontal offset with spring
- Flash effect: White overlay at 0.5 opacity
- Fallback: Colored rectangle with initial letter

### CharacterHealthBar (BattleSceneView.swift)
- Width: 140 points
- Height: 12 points
- Shows: Heart icon + "current/max" text + progress bar
- Colors: Green (>50%), Yellow (>25%), Red (<25%)

### ShieldBadge (BattleSceneView.swift)
- Size: 28x28 circular badge
- Position: Top-right corner of portrait (offset x:8, y:-8)
- Display: Cyan circle with white border + shield amount
- Font size: 20 (updated from 12)

### PowerSurgeEffect (ChainComboEffects.swift) ✨ UPDATED!
- Full-screen overlay effect for 4+ tile matches
- Components:
  - **Blue cyan screen flash** (fades from 0.8 to 0.0 opacity over 0.6s)
  - **ONE massive diagonal lightning bolt** (8px thick, cyan→blue→white gradient)
  - **40 blue particles** (varied sizes 3-12px, cyan/blue gradient, scattered ±200x/±300y)
  - Main text: "CRACKLE POWER!!" (size 60, OverQuest font, white with yellow/orange shadows)
  - Sub text: "+2 MANA BONUS!" (size 30, OverQuest font, orange)
- Lightning details:
  - **DiagonalCracklingBolt** custom Shape (top-left to bottom-right)
  - 16+ zigzag direction changes for crackling effect
  - 5 side branches for complexity
  - Triple shadow glow: cyan (30px), blue (20px), white (15px)
  - Flickers 5 times rapidly (0.1s duration, autoreverses)
- Animation timing:
  - Flash: 0.6s ease-out fade
  - Lightning: 0.2s appear, flickers at 0.3s, fades at 1.0s
  - Particles: 0.2s appear, 0.8s scatter and fade
  - Text: Spring scale (0.5 → 1.2), fades at 1.0s
- Total duration: ~1.5 seconds
- Z-index: 500 (in ContentView - above game, below pause menu)
- Displays when: `GameConfig.enablePowerSurgeEffect && viewModel.battleManager.triggeredPowerSurge`

**Customization Guide:**
- To change lightning: Edit `DiagonalCracklingBolt` struct (line ~165)
- To use image instead: Replace `lightningBolts` view with `Image("filename")`
- To change colors: Edit `lightningGradient` colors (line ~62)
- To adjust particles: Change `electricParticles` ForEach range (line ~72)
- To modify glow: Edit `.shadow()` modifiers (line ~50-52)

---

## 🎨 DESIGN PATTERNS

### Color Scheme
- Background: Green gradient (0.3-0.5 RGB mix)
- Battle narrative: Black boxes with 0.6 opacity
- Gem selector: Black background with 0.9 opacity
- Button states: Orange (active), Grey (disabled)

### Animation Philosophy
- Spring animations for character attacks
- Ease-in-out for health changes
- Scale + opacity for popups
- All durations: 0.2-0.4 seconds

### Layout Strategy
- Geometry-based responsive sizing
- Percentage-based heights (42% battle, 58% board)
- Fixed-size UI elements (buttons, badges)
- Z-index layering for overlays

---

## 🚀 PLANNED FEATURES (Not Yet Implemented)

**ALL ITEMS BELOW ARE PLANNING PHASE - DISCUSSED BUT NOT CODED YET**

Quick Reference: [Feature #1: LLM Narratives](#feature-1-dynamic-battle-narratives-with-llm) | [Feature #2: Curse Mechanic](#feature-2-hidden-cursepoison-mechanic-minesweeper-style) | [Feature #3: Combat Systems](#feature-3-advanced-combat-systems) | [Feature #4: Character Animations](#feature-4-character-animation-system) | [Feature #5: Code-Based Effects](#feature-5-code-based-animation-system-zero-assets)

---

### Feature #1: Dynamic Battle Narratives with LLM

**Concept**: Replace hardcoded battle messages with Apple's on-device AI for infinite variety.

**How It Works**:
1. Define tone/style instructions (heroic, humorous, concise)
2. Battle events trigger prompts to LLM instead of random array selection
3. LLM generates contextually appropriate messages
4. Every playthrough has unique narratives

**Technical Requirements**:
- iPhone 15 Pro+ or M1+ Mac/iPad (Apple Intelligence devices)
- Fallback to hardcoded messages for older devices
- ~0.5-2 second response time per message

**Files to Create/Modify**:
- Create: `BattleNarrator.swift` (handles LLM session)
- Modify: `BattleManager.swift` (call LLM instead of hardcoded arrays)
- Modify: `BattleEvent.swift` (receives LLM-generated text)

**Reference**: Discussed in chat about making battle text dynamic and contextual.

---

### Feature #2: Hidden Curse/Poison Mechanic (Minesweeper-Style)

**Concept**: Hidden "cursed" tiles on the board that damage the player when matched (like hitting a mine).

**Core Mechanics**:
- Tiles have hidden `isCursed: Bool` property
- Matching over a cursed tile = 5 HP damage to player
- Visual: Subtle purple glow OR completely invisible (difficulty setting)
- Spawn rate: 5-10% of tiles at any time
- Curses respawn when board refills

**Advanced Ideas Discussed**:

**A. Curse Chains**
- Multiple curses in one match = escalating damage
- Formula: First curse = 5 HP, each additional = +2 HP
- Example: 3 curses in one match = 5 + 2 + 2 = 9 HP damage
- Narrative: "CURSE CHAIN x3! -9 HP!"

**B. Curse Types** (Different Effects)
- 💀 Death Curse: Direct damage (5 HP)
- 🔥 Flame Curse: Damage + burns adjacent gems (locked 1 turn)
- 🧊 Freeze Curse: Locks a random column (can't swap 1 turn)
- 🌀 Chaos Curse: Randomizes 3x3 area of gems

**C. Curse Vision Ability**
- New coffee cup option (costs 3 mana)
- Reveals all curses on board for 3 moves
- Glowing purple outlines appear

**D. Cleansing Mechanic**
- Matching Heart gems adjacent to curse removes it safely
- No damage taken, curse disappears
- Narrative: "❤️ PURIFIED! Curse removed!"

**E. Curse Meter UI**
- Display: "⚠️ Curses: 6/8" at top of screen
- When full (8), next curse is a "Boss Curse" (double damage)
- Creates urgency to clear curses

**F. Enemy Curse Attacks**
- Enemy can cast "Dark Hex" to spawn curses
- Narrative: "Ednar curses the battlefield! 3 new curses appear!"

**Files to Modify**:
- `Tile.swift` or `TileType.swift`: Add `isCursed: Bool` property
- `BoardManager.swift`: Curse placement logic, reveal methods
- `BattleManager.swift`: Curse damage processing
- `GameBoardView.swift`: Visual indicators, explosion animations
- `GameConfig.swift`: Curse spawn rates, damage values

**Complexity**: Medium (2-3 hours core + 3-5 hours per advanced feature)

**Reference**: Discussed as minesweeper-style mechanic for strategic depth.

---

### Feature #3: Advanced Combat Systems

**Three Major Subsystems**: Enemy Spells | Board Manipulation | Chain Effects

---

#### 3A. Enemy Spell Casting System

**Concept**: Enemy has a "spell deck" with different effects instead of just dealing damage.

**Spell Meter Mechanic**:
- Meter fills 10-20% each player turn
- At 100%, enemy casts a spell
- Player can SEE it charging (creates tension)
- Visual warning at 80%: "⚠️ EDNAR PREPARES A SPELL!"

**Example Spells**:

**🔥 Swamp Fire** (Direct Damage)
- Effect: 8 damage to player
- Visual: Flames erupt across board (code-based animation)
- Narrative: "🔥 Swamp fire scorches you! -8 HP!"

**💀 Death's Touch** (Curse + Damage)
- Effect: Spawns 5 curses on board + 5 damage
- Visual: Skulls rain down onto random tiles
- Narrative: "💀 The board is cursed! -5 HP!"

**🛡️ Ribbit Shield** (Defensive)
- Effect: Enemy gains 10 shield
- Visual: Cyan bubble around enemy portrait
- Narrative: "🛡️ Ednar croaks defensively! +10 shield!"

**⚡ Mana Drain** (Resource Attack)
- Effect: Steals 3 mana from player
- Visual: Blue wisps flow from player to enemy
- Narrative: "⚡ Your power drains away! -3 mana!"

**🌀 Temporal Chaos** (Board Disruption)
- Effect: All tiles shift down one row (wraparound)
- Visual: Board spins/rotates animation
- Narrative: "🌀 Reality bends! The board shifts!"

**Visual Sequence for Spell Cast**:
1. Enemy portrait pulses with colored glow (spell type indicator)
2. Spell name appears in large text: "TOAD'S CURSE"
3. Spell effect animates (1-2 seconds)
4. Battle narrative updates
5. Player sees result

---

#### 3B. Enemy Board Manipulation

**Concept**: Enemy actively changes the board state during combat.

**Manipulation Abilities**:

**Toxic Hex** (Every 3 turns)
- Spawns 3 random curses on board
- Visual: Green skulls materialize on tiles
- Narrative: "💀 Ednar hexes the battlefield!"

**Gem Transmutation** (Every 5 turns)
- Converts all of one gem type to another (e.g., all Swords → Poison)
- Visual: Tiles shimmer and change color
- Narrative: "🔮 Your weapons turn to venom!"

**Chaos Shuffle** (Reactive - when player gets 5+ combo)
- Randomly swaps 10-15 tiles
- Visual: Whirlwind effect across board
- Narrative: "🌪️ Ednar disrupts your combo flow!"

**Column Freeze** (Every 4 turns)
- Locks 1-2 columns (can't swap tiles for 2 turns)
- Visual: Ice overlay on frozen columns
- Narrative: "🧊 Frozen solid! Column locked!"

---

#### 3C. Chain Combo Special Effects

**Concept**: High combo counts (4+) trigger spectacular effects beyond damage multipliers.

**4-Chain: "Power Surge"**
- **Effect**: +2 bonus mana (on top of normal rewards)
- **Visual**: 
  - Golden lightning strikes across board
  - Extra particle explosions from matched tiles
  - "⚡ POWER SURGE!" text floats up
- **Narrative**: "⚡ 4-CHAIN! Power surges through you! +2 mana!"
- **Board Effect**: Shockwave ripples from matches

**5-Chain: "Critical Strike"**
- **Effect**: Double damage + stun enemy (skip next spell)
- **Visual**:
  - Screen flash white
  - Slow-motion tile cascade (1 second)
  - Massive "CRITICAL!" text across screen
  - Camera shake
  - Enemy portrait recoils/staggers
- **Narrative**: "💥 5-CHAIN CRITICAL! DEVASTATING BLOW! Enemy stunned!"
- **Board Effect**: All tiles glow with combo's gem color

**6-Chain: "Divine Intervention"**
- **Effect**: Triple damage + 5 mana + cleanse all curses + 10 shield
- **Visual**:
  - Golden light beams from top of screen
  - 2-second pause
  - Angel wing particles around player
  - "✨ DIVINE CHAIN ✨" in massive glowing text
- **Narrative**: "✨ 6-CHAIN DIVINE STRIKE! The gods smile upon you!"
- **Board Effect**: Curses explode and vanish, new tiles guaranteed curse-free

**7+ Chain: "Apocalypse Combo"** (Legendary - game-winning)
- **Effect**: 4x damage + full mana (7/7) + full health + enemy loses all shield
- **Visual**:
  - Complete game pause
  - White → black → color explosion sequence
  - "LEGENDARY CHAIN" in animated flaming text
  - Background changes to swirling energy vortex
  - Fireworks across entire screen
- **Narrative**: "🌟 LEGENDARY 7-CHAIN! UNSTOPPABLE POWER!"

**UI Enhancements Needed**:
- Enemy spell meter (below enemy health bar)
- Status effect icons (frozen columns, debuffs)
- Chain counter during combos: "Current Chain: x3 ⚡⚡⚡"
- Active effects display: "🧊 Column 3 Frozen (1 turn left)"

**Files to Create**:
- `EnemySpellManager.swift` - Spell deck, meter, spell logic
- `ChainEffectsManager.swift` - Detect chains, trigger effects
- `BoardStatusEffects.swift` - Track frozen columns, debuffs

**Files to Modify**:
- `BattleManager.swift` - Integrate spell system, check chain thresholds
- `BattleSceneView.swift` - Enemy spell meter UI, status displays
- `GameBoardView.swift` - Frozen overlays, chain flash effects
- `GameConfig.swift` - Spell timing, chain thresholds

**Complexity**: High (~20-30 hours total)

**Reference**: Discussed as complete combat overhaul with enemy AI and player combo rewards.

---

### Feature #4: Character Animation System

**Four Implementation Options** (increasing complexity):

---

#### Option 1: Portrait Expression Swap ⭐ RECOMMENDED

**Concept**: Character portrait changes based on action (like a flipbook).

**Images Needed** (per character):
1. `character_idle.png` - Neutral expression
2. `character_attack.png` - Aggressive/striking
3. `character_hurt.png` - Damage/pain
4. `character_defend.png` - Shielding
5. `character_spell.png` - Casting magic
6. `character_victory.png` - Triumphant
7. `character_defeat.png` - Knocked out

**Total**: 7 images per character × 2 characters (Ramp + Ednar) = **14 images**

**Specifications**:
- Format: PNG with transparency
- Dimensions: 512x512 pixels (or 1024x1024 for retina)
- Resolution: 72 DPI minimum, 144 DPI recommended
- Aspect Ratio: 1:1 (square)
- File Size: <500KB each
- Color Space: sRGB

**Naming Convention**:
```
Assets.xcassets/
├─ ramp_idle.imageset/
├─ ramp_attack.imageset/
├─ ramp_hurt.imageset/
├─ ramp_defend.imageset/
├─ ramp_spell.imageset/
├─ ramp_victory.imageset/
├─ ramp_defeat.imageset/
├─ ednar_idle.imageset/
└─ (repeat for Ednar)
```

**How It Works**:
- Character has `currentState` property (enum: idle/attack/hurt/etc.)
- Portrait displays image based on state
- State changes trigger fade transitions (0.2s opacity animation)
- Auto-return to idle after action completes

**Transition Timing**:
- Attack → Idle: 0.3 seconds
- Hurt → Idle: 0.5 seconds
- Defend → Idle: 0.4 seconds
- Spell → Idle: 0.6 seconds

**Files to Modify**:
- `Character.swift`: Add `var currentState: CharacterState` enum
- `CharacterPortrait` (BattleSceneView.swift): Use state-based image names
- `BattleManager.swift`: Set states during battle events

**Complexity**: Low (1-2 hours coding + art time)

---

#### Option 2: Spritesheet Animation

**Concept**: Full motion animation using multiple frames per action.

**Spritesheet Structure**:
- One large PNG containing all frames in a grid
- OR individual frame files (easier to create)

**Frame Counts** (per character):
- Idle: 4-6 frames (breathing loop)
- Attack: 4-8 frames (wind up → strike → follow through)
- Hurt: 2-3 frames (recoil → recover)
- Defend: 3-4 frames (shield up → hold)
- Spell: 6-10 frames (gather → cast → release)
- Victory: 4-6 frames (celebration)
- Defeat: 3-5 frames (collapse)

**Total**: ~30-45 frames per character

**Specifications**:
- Individual Frame Size: 256x256 pixels
- Total Spritesheet: 2048x1024 pixels (8 columns × 4 rows example)
- Resolution: 144 DPI
- File Size: ~2MB per spritesheet

**Frame Rates**:
- Idle: 6-8 FPS (slow, subtle)
- Attack: 12-16 FPS (fast, snappy)
- Hurt: 12 FPS (quick)
- Spell: 10-12 FPS (deliberate)

**Files to Create**:
- `SpriteAnimator.swift` - Custom view for playing sprite animations

**Complexity**: Medium (4-6 hours coding + significant art time)

---

#### Option 3: Lottie/Vector Animation

**Concept**: Vector-based animations exported as JSON (After Effects workflow).

**Animations Needed** (per character):
- Same 7 states as Option 1, but as JSON files
- Example: `ramp_attack.json`, `ednar_spell.json`

**Total**: 7 JSON files per character = **14 files**

**Specifications**:
- Format: .json (Lottie) or .riv (Rive)
- File Size: 10-100KB per animation
- Scalability: Infinite (vector)

**Tools Required**:
- Adobe After Effects + Lottie plugin
- OR Rive animation tool

**Integration**:
- Requires `Lottie` library via Swift Package Manager
- URL: `https://github.com/airbnb/lottie-ios`

**Pros**:
✅ Incredibly smooth
✅ Very small file sizes
✅ Scalable to any resolution
✅ Easy to update (replace JSON)

**Cons**:
⚠️ Requires animation software knowledge
⚠️ External dependency
⚠️ Learning curve

**Complexity**: Medium-High (2-3 hours coding + animation learning curve)

---

#### Option 4: Full-Body Character Animation

**Concept**: Show entire character with limb movement, weapon swings (JRPG-style).

**Frame Requirements**:
- Frame Size: 512x512 pixels (larger to show full body + weapon arcs)
- Frame Count: 50-80 frames per character
  - Idle: 6 frames
  - Attack: 12 frames (full sword swing arc)
  - Spell: 15 frames (hand gestures, energy)
  - Hurt: 4 frames
  - Defend: 6 frames
  - Victory: 8 frames
  - Defeat: 10 frames

**Total Spritesheet**: 5120x4096 pixels (LARGE!)

**Layout Changes Required**:
- Current: 42% battle scene, 58% board
- Full-Body: 60% battle scene, 40% board (shrink board)

**Attack Animation Arc** (12 frames example):
1. Ready stance
2-3. Wind up (pull weapon back)
4-5. Swing begins (body rotates)
6-7. Impact point (weapon at target, flash)
8-9. Follow through
10-11. Recovery
12. Return to idle

**Complexity**: Very High (8-12 hours coding + extensive art time)

---

**Upgrade Path** (Recommended):
1. Start with portrait swaps (easiest)
2. Add particle effects (sword slashes, glows)
3. Upgrade to spritesheets (smooth motion)
4. Expand to full-body (if desired)

**Reference**: Discussed as progressive enhancement system for character visuals.

---

### Feature #5: Code-Based Animation System (Zero Assets)

**Core Concept**: Build 95% of visual effects using pure SwiftUI code without any image assets.

**What's Possible 100% in Code**:

---

#### Spell Visual Effects (Code-Based)

**🔥 Fire Spell** (Swamp Fire)
- **Elements**: 20+ colored circles with gradients
- **Colors**: Red → Orange → Yellow gradient
- **Animation**: Circles rise upward (offset y: 0 → -200) and fade (opacity: 1 → 0)
- **Effect**: Blur radius 5 for glow
- **Code**: ForEach creating circles, each with random size/position, staggered delays

**💀 Curse Spell** (Toxic Hex)
- **Elements**: Purple gradient wave + skull emoji particles
- **Wave**: Rectangle with LinearGradient (clear → purple → clear)
- **Animation**: Scale (0.5 → 1.5) + opacity (1 → 0) over 1 second
- **Skulls**: Text("💀") with random positions, rotating + falling
- **Code**: Rectangle + ForEach Text with offset/rotation animations

**🛡️ Shield Spell** (Ribbit Shield)
- **Elements**: Expanding circular rings
- **Rings**: Circle().stroke() with cyan/blue gradient
- **Animation**: Scale (1.0 → 2.5) + opacity (1 → 0)
- **Effect**: Multiple rings at different timings for ripple effect
- **Code**: ForEach Circle with scaleEffect animation

**⚡ Mana Drain**
- **Elements**: Blue orbs (circles with radial gradients)
- **Animation**: Offset x: -100 (player side) → +100 (enemy side)
- **Colors**: Center blue → edge cyan → transparent
- **Effect**: 10 particles with staggered timing
- **Code**: ForEach Circle with RadialGradient + offset animation

**🌀 Chaos Shuffle** (Whirlwind)
- **Elements**: 3 spinning spiral rings
- **Shape**: Circle.trim(from: 0, to: 0.7) - partial circles
- **Animation**: Continuous rotation (0° → 360° repeating)
- **Colors**: Purple, different sizes/speeds for depth
- **Code**: ForEach Circle trim with rotation animation

**🧊 Column Freeze** (Ice Lock)
- **Elements**: Blue/cyan gradient overlay + diamond ice crystals
- **Overlay**: Rectangle with LinearGradient (shimmer effect)
- **Animation**: Gradient position animates (top → bottom repeat)
- **Crystals**: Custom Diamond shape (4-point star)
- **Code**: Rectangle + custom Shape in overlay, animated gradient

---

#### Chain Combo Effects (Code-Based)

**⚡ 4-Chain Power Surge**
- **Elements**: Golden screen flash + lightning bolts
- **Flash**: Rectangle, yellow opacity 0.3, fade out
- **Lightning**: Custom zigzag Path (6 segments)
- **Animation**: Lightning appears with shadow glow
- **Code**: Rectangle + custom Path with stroke + shadow

**💥 5-Chain Critical Strike**
- **Elements**: White screen flash + giant text
- **Flash**: Rectangle, white, full opacity → 0 in 0.3s
- **Text**: "CRITICAL!" size 80, gradient fill (red → orange → yellow)
- **Animation**: Spring scale (0.5 → 1.2) for impact
- **Code**: Rectangle + Text with LinearGradient + scaleEffect

**✨ 6-Chain Divine Intervention**
- **Elements**: Golden light beams + particle explosion + text
- **Beams**: Rectangles from top, yellow with blur
- **Particles**: Circles scattering outward (random trajectories)
- **Text**: "✨ DIVINE CHAIN ✨" massive glowing
- **Code**: ForEach Rectangle (beams) + ForEach Circle (particles) + Text

**🌟 7+ Chain Legendary**
- **Elements**: Color sequence + fireworks + vortex
- **Sequence**: White Rectangle → Black Rectangle → Color explosion
- **Fireworks**: Circles with random trajectories + trails
- **Vortex**: AngularGradient rotating continuously
- **Code**: Sequential Rectangle transitions + ForEach particles + rotating gradient

---

#### SwiftUI Animation Toolkit Reference

**Shapes** (all code, no images):
```swift
Circle()
Rectangle()
RoundedRectangle(cornerRadius:)
Capsule()
Ellipse()
Path() // Custom shapes (lightning, diamonds, etc.)
```

**Visual Effects**:
```swift
.fill(Color.red)
.fill(LinearGradient(...))    // Directional color blend
.fill(RadialGradient(...))    // Circular color blend
.fill(AngularGradient(...))   // Rainbow/spinning effects
```

**Transforms**:
```swift
.offset(x:, y:)      // Move position
.scaleEffect()       // Grow/shrink
.rotationEffect()    // Spin
.blur(radius:)       // Glow/soft edges
.opacity()           // Fade in/out
```

**Animations**:
```swift
.animation(.easeInOut(duration:))           // Smooth
.animation(.spring(response:, damping:))    // Bouncy
.animation(.linear(duration:).repeatForever()) // Continuous
```

**Advanced**:
```swift
.overlay { }              // Layer on top
.background { }           // Layer behind
.shadow(color:, radius:)  // Drop shadows and glows
.blendMode(.screen)       // Additive blending (bright effects)
```

---

#### When Assets ARE Needed

**1. Character Portraits** (for different states)
- Can use emoji as temporary placeholders: 😠 🗡️ 😫 🛡️ ✨
- Custom art recommended for polish

**2. Spell Icons** (UI buttons)
- Can use SF Symbols: `bolt.fill`, `flame.fill`, `shield.fill`
- Or emoji: 💫 ✨ 🌟 ⚡ 🔥

**3. Particle Textures** (optional enhancement)
- Smoke wisps, spark trails
- Can fake with blurred circles initially

**4. Sound Effects** (audio files)
- Not visual, add later

---

#### Implementation Phases

**Phase 1: Pure Code Animations** ⭐ START HERE
- Implement all spell effects using shapes/gradients
- Use emoji for temporary variety (💀🔥⚡🛡️)
- Screen flashes, geometric shapes, text overlays
- **Result**: Fully functional with impressive visuals, ZERO art assets

**Phase 2: Add Character Portrait States**
- 7 images per character (Option 1 from Feature #4)
- Keep all spell effects code-based

**Phase 3: Polish with Optional Assets**
- Custom particle textures if desired
- Sound effects library
- Professional spell icons

**Phase 4: Advanced Assets** (optional)
- Animated spritesheets (Option 2 from Feature #4)
- High-res particle effects
- Voice acting / music

---

#### Technical Implementation Notes

**Files to Create**:
- `SpellEffectViews.swift` - All spell visual components
  - FireSpellEffect, CurseSpellEffect, ShieldSpellEffect, etc.
- `ChainComboEffects.swift` - Chain combo visuals
  - PowerSurgeEffect, CriticalStrikeEffect, etc.
- `BoardManipulationEffects.swift` - Board overlays
  - ChaosShuffleEffect, FrozenColumnOverlay, etc.

**Files to Modify**:
- `BattleSceneView.swift` - Add spell effect overlay layer (z-index)
- `GameBoardView.swift` - Add board manipulation overlays
- `BattleManager.swift` - Trigger effect displays
- `GameViewModel.swift` - Coordinate effect timing

**Animation Timing**:
- Charge up: 0.5-1.0 seconds
- Spell cast: 1.0-1.5 seconds
- Impact/flash: 0.2-0.4 seconds
- Chain combos: 1.5-2.5 seconds (more dramatic)

**Performance Tips**:
- Use `.drawingGroup()` for complex particles (renders to bitmap)
- Limit particle count (20-30 max per effect)
- Remove from view hierarchy after animation completes
- Use `.transition()` for smooth appear/disappear

**Benefits**:
✅ Zero art asset dependency - build immediately
✅ Easy iteration - tweak colors/timing instantly
✅ Small file sizes - no images to load
✅ Scalable - looks sharp on any screen
✅ Maintainable - all logic in Swift code

**Limitations**:
⚠️ Code-based effects have "generic" look initially
⚠️ Complex particles can impact performance
⚠️ Some effects (realistic fire/smoke) look better with textures

**Reference**: Discussed as complete alternative to asset-based VFX, enabling rapid prototyping.

---

## 🚀 NEXT STEPS / TODO

- All planned features documented above
- Ready to implement any feature when user decides
- User will specify which feature to build next

---

## 💡 CRITICAL INSTRUCTIONS FOR AI - READ FIRST

### 🚨 USER EXPERIENCE LEVEL

**THE USER HAS ZERO CODING KNOWLEDGE - TREAT THEM LIKE A COMPLETE BEGINNER**

### ✅ MANDATORY REQUIREMENTS FOR EVERY CODE CHANGE

**1. ALWAYS Provide Complete, Copy-Paste Ready Code**
- ❌ NEVER give partial code snippets or say "add this line here"
- ✅ ALWAYS give the ENTIRE file or ENTIRE function to replace
- ✅ Include clear "replace THIS with THAT" instructions
- ✅ Show exactly where to paste (file name, line numbers if possible)

**2. ALWAYS Give Step-by-Step Xcode Instructions**

Example format:
```
STEP 1: Open the file
- Look at the left sidebar in Xcode (Project Navigator)
- Find and click on "BattleSceneView.swift"

STEP 2: Find what to replace
- Press Command+F (or Edit menu → Find)
- Search for "struct CharacterPortrait"
- Click the first result

STEP 3: Replace the code
- Click inside the code block
- Select everything from "struct CharacterPortrait {" to the closing "}"
- Delete it
- Paste this new code: [FULL CODE HERE]

STEP 4: Save and test
- Press Command+S to save
- Press Command+R to run the app
- Test by: [specific test instructions]
```

**3. ALWAYS Explain in Simple Language**
- ❌ Don't say: "Refactor the Observable macro with binding semantics"
- ✅ Do say: "This changes how the app tracks when things update"
- ✅ Use analogies when possible
- ✅ Explain what the user will SEE change in the app

**4. ALWAYS Update This Context File**

**AFTER EVERY SINGLE CHANGE YOU MAKE:**

Update these sections:
- **"Recent Changes"** - Add new entry with date/description
- **"What Works"** - Add new working features
- **"Known Issues"** - Add any new bugs or problems
- **"File Status Tracker"** - Update modified files
- **"Component Reference"** - Add new components

**Format for logging changes:**
```
### Session X: [Feature Name]

**Date**: [Date]
**Changes Made**:
1. File 1: What changed and why
2. File 2: What changed and why

**New Features**:
- Feature A now does X
- Feature B was added

**What Works Now**:
✅ Thing 1
✅ Thing 2

**Known Issues** (if any):
⚠️ Issue 1
⚠️ Issue 2

**Files Modified**:
- File1.swift (lines X-Y)
- File2.swift (lines A-B)
```

### 📋 CODE STYLE REQUIREMENTS

**Must Use:**
- Swift + SwiftUI only (no UIKit unless absolutely necessary)
- @Observable macro (not @ObservableObject)
- @Bindable for passing observable objects
- async/await (not Combine or Dispatch unless required)
- SF Symbols for icons (e.g., "heart.fill", "shield.fill")

**Naming:**
- Clear, descriptive names
- camelCase for variables/functions
- PascalCase for types/structs

### 🔄 WORKFLOW FOR EVERY NEW CHAT

**When a new conversation starts:**
1. ✅ Read this ENTIRE AI_CONTEXT.md file first
2. ✅ Check "Recent Changes" for latest updates
3. ✅ Check "Known Issues" before suggesting solutions
4. ✅ Check "File Status Tracker" to see what was modified when
5. ✅ Reference existing patterns in "Component Reference"

**When the user asks for changes:**
1. ✅ Provide complete code (never snippets)
2. ✅ Give step-by-step Xcode instructions
3. ✅ Explain in simple language what changes
4. ✅ Update this context file immediately after
5. ✅ Test mentally: "Could someone with zero coding knowledge follow this?"

### 🎯 LIVING DOCUMENT PROTOCOL

**This file is a LIVING DOCUMENT that must be updated constantly:**

✅ Every feature added → Log it  
✅ Every bug fixed → Log it  
✅ Every file changed → Log it  
✅ Every new component → Document it  
✅ Every UI change → Document measurements/colors  
✅ Every mechanic change → Update game mechanics section  

**Goal**: Any AI in a future chat should be able to read this file and know:
- What the game currently does
- What's been tried and worked
- What's been tried and failed
- What's planned but not implemented
- Exact specifications of every UI element
- Complete history of changes

### ⚠️ COMMON MISTAKES TO AVOID

❌ Assuming user knows Xcode keyboard shortcuts  
❌ Giving partial code and saying "merge this with existing code"  
❌ Using technical jargon without explanation  
❌ Forgetting to update this context file  
❌ Not testing instructions mentally before giving them  
❌ Referencing line numbers without showing what's there  
❌ Saying "just add this function" without showing where  

### ✅ QUALITY CHECKLIST BEFORE RESPONDING

Before submitting ANY code change, verify:

- [ ] Is the code COMPLETE and copy-pasteable?
- [ ] Are Xcode instructions step-by-step for a beginner?
- [ ] Is everything explained in simple language?
- [ ] Did I update the context file with changes?
- [ ] Would someone with zero coding knowledge understand this?
- [ ] Did I test this mentally to ensure it works?

**If any checkbox is unchecked, revise your response.**

---

## 📊 FILE STATUS TRACKER

| File | Last Modified | Status | Notes |
|------|---------------|--------|-------|
| File | Last Modified | Status | Notes |
|------|---------------|--------|-------|
| PhysicsChainGameView.swift | Session 24 | ⚠️ Debugging | Main game view - tiles not displaying |
| PhysicsGameViewModel.swift | Session 24 | ⚠️ Code complete | Physics engine with 60 FPS update loop - tiles not spawning visually |
| PhysicsTileView.swift | Session 24 | ⚠️ Code complete | Tile rendering component - not being called |
| PhysicsTile.swift | Session 24 | ✅ Complete | Tile model with physics properties |
| PhysicsTileType.swift | Session 24 | ✅ Complete | 6 tile types with Match-3 image names |
| PhysicsGameConfig.swift | Session 24 | ✅ Complete | 80+ configuration settings |
| OverQuestMatch3App.swift | Session 23 | ✅ Working | **Routes to PhysicsChainGameView** |
| Match3ContentView.swift | Session 22 | ✅ Working | **Renamed from ContentView.swift** - Fixed Preview reference |
| STRUCTURE_CONTEXT.md | Session 22 | ✅ Working | **NEW** - Complete reorganization tracker and reference guide |
| BattleSceneView.swift | Session 19 | ✅ Working | Fixed battle narrative slide animation, custom gem selector animation order |
| GameViewModel.swift | Session 19 | ✅ Working | Fixed resetGame() function - proper state clearing order |
| BattleManager.swift | Session 19 | ✅ Working | Fixed reset() function - clears `pendingGameOver` |
| BattleMechanicsConfig.swift | Session 18.5 | ✅ Working | **ALL battle messages added** - centralized message system |
| GameAssets.swift | Session 18 | ✅ Working | Cleaned up - UI/asset configuration only |
| GameBoardView.swift | Session 15 | ✅ Working | Fixed swipe/tap gesture priority bug |
| CharacterAnimationManager.swift | Session 14 | ✅ Working | Priority queue system for character states |
| CharacterAnimations-Shared.swift | Session 14 | ✅ Working | **Renamed from CharacterAnimations.swift** during reorganization |
| TileType.swift | Session 14 | ✅ Working | Added isStable property, isBonusTile tracking |
| BoardManager.swift | Session 14 | ✅ Working | Stability tracking, bonus tile system |
| BonusBlastEffects.swift | Session 13 | ✅ Working | Code-based + custom image blast system |
| DebugMenuView.swift | Session 13 | ✅ Working | Cross blast test button, force 5-match |
| TitleScreenView.swift | Session 11 | ✅ Working | Leaf animation with loop pause |
| DeveloperSplashView.swift | Session 11 | ✅ Working | RK + Milo character animations |
| Character.swift | Session 10 | ✅ Working | Added `.hurt2` state for invalid swap |
| ChainComboEffects.swift | Session 4 | ✅ Working | Blue diagonal lightning + particles |
| HapticManager.swift | Session 22 | ✅ Working | **Moved to Shared/** folder during reorganization |

**Folder Organization (Session 22):**
- ✅ Match3Game/ - 18 Match-3 specific files
- ✅ Shared/ - 5 files used by all games
- ✅ PhysicsChainGame/ - Empty (ready for development)
- ✅ CookingGame/ - Empty (ready for development)
- ✅ PotionSolitaireGame/ - Empty (ready for development)
- ✅ Navigation/ - Empty (ready for development)

---

**Last Updated**: Session 24 - Physics Chain Game Tile Display Debugging (March 28, 2026)

**Status**: ⚠️ Physics Chain Game code complete but tiles not rendering - debugging in progress

**Recent Highlights:**
- ⚠️ Session 24: **DEBUGGING** - Physics Chain Game tiles not displaying (background shows, UI works, but 90 tiles not visible)
- ⚠️ Session 23: **CODE COMPLETE** - All Physics Chain Game files created, builds successfully
- ✅ Session 22: **PROJECT REORGANIZATION** - Multi-game architecture, dev switcher, folder structure
- ✅ Session 20: Gem Clear & Bonus Tile effects multiply by count
- ✅ Session 19: Fixed 3 major bugs (selection box, narrative animation, gem selector timing)
- ✅ Session 18.5: ALL battle messages centralized in BattleMechanicsConfig.swift
- ✅ Session 18: Battle mechanics fully migrated to dedicated config file

**Project Structure:**
- ✅ Match3Game/ folder - 18 Match-3 specific files (WORKING)
- ✅ Shared/ folder - 5 files used by all games
- ⚠️ PhysicsChainGame/ folder - 6 files created (CODE COMPLETE - tiles not rendering)
- ✅ 3 empty game folders ready for development
- ✅ Dev switcher in OverQuestMatch3App.swift
- ✅ Match-3 game fully working and tested

**Reference Documents:**
- **STRUCTURE_CONTEXT.md** - Complete reorganization guide and project structure reference
- **AI_CONTEXT.md** - This file - complete project knowledge base


