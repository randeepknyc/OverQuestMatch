# MASTER PROJECT CONTEXT
**OverQuestMatch3 - Multi-Game iOS Application**

> **Last Updated:** May 17, 2026 (Title Screen Background Fade Fixed)  
> **Project Status:** Active Development - Multi-Game Architecture Complete with Perfect Testing Flow  
> **Current Work:** Ednar's Potion Cauldron playable (Phase 7 complete - Day 1 only, layout refinement ongoing)

---

## 🎯 PROJECT OVERVIEW

**Project Name:** OverQuestMatch3  
**Platform:** iOS (SwiftUI)  
**Architecture:** Multi-game collection with integrated progression system  
**User Coding Level:** Zero coding knowledge - Requires complete, copy-paste ready code

### **Current Games:**
1. **Match-3 RPG Battle** - ✅ COMPLETE & WORKING
2. **Physics Chain Game** - ✅ COMPLETE & WORKING (with debug menu + End Game button)
3. **Shop of Oddities** - ✅ COMPLETE & FULLY PLAYABLE - Minimalist card repair game with custom artwork, debug menu, optimized layout, polished animations (deal/flip/drag-and-drop), and centralized config system
4. **Ednar's Potion Cauldron** - ✅ PLAYABLE (Day 1 only) - Turn-based dice-placement potion brewing game, in `PotionShop/`
5. **Cooking Game** - 📋 Planned
6. **Potion Solitaire** - 📋 Planned
7. **Map Navigation System** - 📋 Planned

**Note:** Legacy `CauldronGame/` folder deprecated and removed from game selector (May 13, 2026). The working game is in `PotionShop/`.

### **Testing Flow:**
**Current (PERFECTED):** Splash → Title → Map → Game Selector → All Games Work  
**How It Works:**
- Splash/Title/Map are now in **OverQuestMatch3App.swift** (the main app)
- All animations and timing from Match-3 preserved (`.easeInOut(duration: 0.8)`)
- `GameConfig.enableDeveloperSplash` toggle still works
- Match-3, Physics, and Shop all launch directly to game boards (no looping!)
- All 3 games have "End Game" buttons in debug menus that return to title screen
- **Match-3 also has "End Game" in Pause Menu** (☰ hamburger menu → End Game → Confirm)

---

## 🧪 EDNAR'S POTION CAULDRON — QUICK REFERENCE

**Status:** Phase 7 complete. Day 1 fully playable. Art is placeholder.

**Source of Truth:** `CAULDRON_CONTEXT.md` (read this first for any work on this game)

**Critical Naming Rule:**  
Every struct/view/enum/modifier in this game MUST be prefixed `PotionShop` to avoid collisions with other games. Two real bugs were caused by:
- `Customer` colliding with `ShopOfOddities`
- `CauldronBoardView` colliding with the legacy `CauldronGame/` folder

**Combat Model:**
- Turn-based: every customer attacks every turn
- No underbrew penalty
- Shield absorbs damage first
- Composure carries between rounds with `COMPOSURE_REST_BETWEEN_ROUNDS` tunable

**Pending Phases:**
- Phase 8: Round-end overlays
- Phase 9: Hexer/Loud trait stubs
- Phase 10: Day 2 + Day 3
- Phase 11: Streak win mode
- Phase 12: Real art swap
- Phase 13: Audio/haptics

**Important:** Legacy `CauldronGame/` folder is unrelated — leave it alone, the user will delete later.

---

## 📁 PROJECT STRUCTURE

**Root Level:**
```
OverQuestMatch3/ (ROOT)
├─ OverQuestMatch3App.swift ✨ Main app entry with dev switcher system
│
├─ Match3Game/ ✅ (All Match-3 specific files)
│  ├─ Match3ContentView.swift (renamed from ContentView)
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
│
├─ Shared/ ✅ (Code used by ALL games)
│  ├─ Character.swift
│  ├─ GameAssets.swift
│  ├─ BattleMechanicsConfig.swift
│  ├─ CharacterAnimations-Shared.swift
│  └─ HapticManager.swift
│
├─ PhysicsChainGame/ ✅ (Complete - Tsum-Tsum style physics game)
│  ├─ PhysicsChainGameView.swift
│  ├─ PhysicsGameViewModel.swift
│  ├─ PhysicsTileView.swift
│  ├─ PhysicsTile.swift
│  ├─ PhysicsTileType.swift
│  └─ PhysicsGameConfig.swift
│
├─ ShopOfOddities/ ✅ (COMPLETE & PLAYABLE - Miracle Merchant-style card game)
│  ├─ ComponentType.swift
│  ├─ ComponentCard.swift
│  ├─ Customer.swift (with public portrait helper)
│  ├─ RepairSlot.swift
│  ├─ RepairResult.swift
│  ├─ ShopGameState.swift (with debug forcing method)
│  ├─ CommentaryManager.swift (character dialogue system)
│  ├─ ShopLayoutConfig.swift ✨ (centralized UI configuration)
│  ├─ ShopDebugSettings.swift ✨ NEW (ObservableObject for reactive debug toggles)
│  ├─ ShopOfOdditiesView.swift (with debug button)
│  ├─ ComponentCardView.swift (observes ShopDebugSettings)
│  ├─ DeckView.swift (with deal/flip animations + drag-and-drop)
│  ├─ CustomerView.swift (with custom portrait support)
│  ├─ RepairSlotView.swift
│  ├─ RepairResultOverlay.swift
│  ├─ ShopGameOverOverlay.swift
│  ├─ NewRepairDiscoveredBanner.swift
│  ├─ CommentaryView.swift (with custom icon support)
│  ├─ ShopSceneView.swift (3-layer composite scene system)
│  └─ AssetsDebugView.swift (debug menu for asset testing + character forcing + toggles)
│
├─ CauldronGame/ ⚠️ DEPRECATED (May 13, 2026 - Removed from game selector)
│  ├─ CauldronGameData.swift ⚠️ OLD - JSON loader (not used by new game)
│  ├─ traits.json ⚠️ OLD - 8 trait definitions (not used by new game)
│  ├─ characters.json ⚠️ OLD - 14 customers with combat stats (not used by new game)
│  ├─ rounds.json ⚠️ OLD - Day/round structure (not used by new game)
│  ├─ CauldronModels.swift ⚠️ OLD implementation
│  ├─ CauldronViewModel.swift ⚠️ OLD implementation
│  └─ CauldronGameView.swift ⚠️ OLD implementation
│  
│  **⚠️ THIS FOLDER IS DEPRECATED:**
│  - No longer accessible from game selector
│  - The working game is in PotionShop/ folder
│  - Will be deleted in a future cleanup
│  - DO NOT modify files in this folder
│
├─ CookingGame/ ✅ (Empty - ready for development)
├─ PotionSolitaireGame/ ✅ (Empty - ready for development)
├─ PotionShop/ ✅ (Ednar's Potion Cauldron — turn-based dice brewing, Day 1 playable)
│  ├─ PotionShopModels.swift
│  ├─ PotionShopData.swift
│  ├─ PotionShopGameState.swift
│  ├─ PotionShopGameView.swift
│  ├─ PotionShopHeaderView.swift
│  ├─ PotionShopCustomerSceneView.swift
│  ├─ PotionShopCauldronView.swift
│  ├─ PotionShopDebugMenu.swift
│  └─ PotionShopBrewAnimator.swift
│
├─ Navigation/ ✅ (Game selector + map placeholder for testing)
│  ├─ MapScreenView.swift (real map with "Continue to Games" button)
│  ├─ GameSelectorView.swift (debug game picker for device testing)
│  └─ (Map placeholder removed - using real flow)
├─ Utilities/ (Existing - unchanged)
├─ Models/ (Existing - mostly empty after migration)
└─ ReadFilesForContext/ (Documentation and context files)
```

---

## 🎮 GAME SELECTOR SYSTEM (TEMPORARY FOR TESTING)

**Location:** Splash → Title → Map → **Game Selector** → Games

**Purpose:** Easy game switching on physical device for testing

### **Flow:**
1. **Splash Screen** (if enabled in GameConfig)
2. **Title Screen** (with animated logo and leaves)
3. **Map Screen** (shows map image with "Continue to Games" button)
4. **Game Selector** (3 working games displayed)
5. **Play Selected Game**

### **Game Selector Features:**
- Clean list-style interface
- Shows working games (Match-3, Physics Chain, Shop of Oddities, Ednar's Potion Cauldron)
- Tap any game → Launches full-screen
- "Back to Map" button to return
- Clearly labeled as "🎮 DEBUG TEST 🎮"

**Note:** Legacy CauldronGame removed from selector (May 13, 2026). Only the working PotionShop game is accessible.

**To Access:**
1. Run app (splash/title/map flow)
2. Tap "Continue to Games" on map screen
3. See game selector with 3 options
4. Tap any game to play

**Future Plans:**
- Replace game selector with direct game launch from map
- Map will show unlockable game locations
- Progression system will gate access to games

---

## 🎮 DEBUG MENUS WITH END GAME BUTTONS

### **Physics Chain Game Debug Menu:**
**Access:** Tap wrench icon (🔧) in top-right of score header

**Features:**
- "End Game" button (red, centered)
- Returns to title screen
- Cleans up physics timer properly
- "Cancel" button to continue playing

### **Shop of Oddities Debug Menu:**
**Access:** Tap wrench icon (🔧) in score bar

**Features:**
- "End Game" button (red, top-left navigation bar)
- Asset viewer for all custom images
- Character forcing for testing portraits
- **"Hide Card Text Overlay" toggle** (purple background) - Shows only card background images ✨ NEW (April 10, 2026)
  - Perfect for verifying face-down/face-up card reveal system
  - Persistent setting (saved via UserDefaults)
  - Toggles all text, values, names, and icons on cards
- "Show Only Custom Images" toggle (gray background)
- Returns to title screen
- "Done" button to continue playing

---

## 🎮 OLD DEV SWITCHER SYSTEM (DEPRECATED)

**Previous Location:** `OverQuestMatch3App.swift` (Line 25)

**Previous Method (No Longer Used):**
```swift
private let currentGame: GameType = .match3
```

**This has been replaced by:**
- Splash → Title → Map → Game Selector flow
- Easier to test on physical devices
- No code editing required to switch games

**Available Game Types (Still Used Internally):**
- `.match3` - Match-3 RPG Battle Game (✅ WORKING)
- `.physicsChain` - Physics Chain Game (✅ WORKING)
- `.shopOfOddities` - Shop of Oddities Card Game (✅ COMPLETE & PLAYABLE)
- `.ednarsPotionShop` - Ednar's Potion Cauldron (✅ PLAYABLE — Day 1)
- `.cooking` - Cooking Game (coming soon)
- `.potionSolitaire` - Potion Solitaire Game (coming soon)
- `.mapNavigation` - Map Navigation System (coming soon)

**Removed (May 13, 2026):**
- `.cauldron` - DEPRECATED (legacy CauldronGame/ folder, removed from selector)

---

## 🏗️ ARCHITECTURE PHILOSOPHY

### **Self-Contained Game Modules**
Each game is built as a completely independent module:
- ✅ Has its own ContentView (e.g., `Match3ContentView`, `PhysicsChainGameView`)
- ✅ Has its own ViewModel and logic files
- ✅ Can be tested independently via dev switcher
- ✅ Uses shared resources from `Shared/` folder

### **Shared Resources**
Common code used by ALL games lives in `Shared/`:
- Character data models (`Character.swift`)
- Asset names and UI config (`GameAssets.swift`)
- Battle mechanics config (`BattleMechanicsConfig.swift`)
- Character animations (`CharacterAnimations-Shared.swift`)
- Haptic feedback (`HapticManager.swift`)

### **Development Workflow**
1. Choose which game to work on
2. Switch dev switcher to that game type
3. Edit files in that game's folder
4. Test by running app (Command+R)
5. Switch back to another game when needed

### **Future Integration**
Later, when ready to connect games:
1. Build map/navigation screen in `Navigation/` folder
2. Create `ProgressManager.swift` to track unlocks
3. Replace dev switcher with map screen in `OverQuestMatch3App.swift`
4. Map launches individual games based on player progress

---

## 🎨 SHARED DESIGN SYSTEM

### **Color Scheme**
- Background: Green gradient (0.3-0.5 RGB mix)
- Battle narrative: Black boxes with 0.6 opacity
- Gem selector: Black background with 0.9 opacity
- Button states: Orange (active), Grey (disabled)

### **Animation Philosophy**
- Spring animations for character attacks
- Ease-in-out for health changes
- Scale + opacity for popups
- All durations: 0.2-0.4 seconds

### **Layout Strategy**
- Geometry-based responsive sizing
- Percentage-based heights (varies by game)
- Fixed-size UI elements (buttons, badges)
- Z-index layering for overlays

---

## 💾 ASSET REQUIREMENTS

### **Shared Assets (Used by Multiple Games)**
- Character portraits (Ramp, Ednar, etc.)
- UI elements (buttons, badges)
- Fonts (OverQuest custom font)

### **Game-Specific Assets**
Each game has its own image sets:
- **Match-3:** Tile images, bonus tiles, battle effects
- **Physics Chain:** Bubble/character tiles (reuses Match-3 images)
- **Shop of Oddities:** Component icons (4 images) + Card backgrounds (4 images) ✅ IMPLEMENTED
- **Cooking:** Ingredient images, cooking equipment (TBD)
- **Potion Solitaire:** Card designs, potion bottles (TBD)

---

## 🚀 DEVELOPMENT PHASES

### **Phase 0: Title Screen Background Fade Fix** ✅ COMPLETE (May 17, 2026)
**Fixed the title screen background transition sequence.**

**Problem:**
- Title screen was showing: `title_screen.png` → `title_screen01.png` → `title_screen.png` (double appearance)
- User wanted: `title_screen01.png` → `title_screen.png` (clean fade)

**Root Cause:**
- Layer order was reversed - final background was on bottom, initial background faded out on top
- This created the visual: background → 01 → background again

**Solution Applied:**
- **Reversed layer order** in TitleScreenView.swift:
  - `title_screen01.png` is now BASE layer (bottom, always visible)
  - `title_screen.png` is now TOP layer (fades IN from opacity 0 → 1)
- Changed state variable from `initialBackgroundOpacity` (fade OUT) to `finalBackgroundOpacity` (fade IN)
- Removed unnecessary `showInitialBackground` boolean

**Files Modified:**
- TitleScreenView.swift (lines 33-60, 143-154)
  - Swapped Image layer positions in ZStack
  - Changed opacity logic: fade IN final background instead of fade OUT initial
  - Simplified state management

**Result:**
✅ Title screen now shows correct sequence: `title_screen01.png` FIRST → fades to `title_screen.png` after 2 seconds
✅ No more double-appearance of backgrounds
✅ Leaves continue animating throughout both backgrounds
✅ Timing configurable via `displayDuration` (2.0s) and `fadeDuration` (1.25s)

**Animation Flow:**
1. Splash screen completes
2. Title screen fades in showing `title_screen01.png`
3. Leaves animate (leaf1 → leaf17 with 2s loop pause)
4. After 2 seconds, `title_screen.png` fades in on top (1.25s fade)
5. Final state: `title_screen.png` visible with leaves continuing

---

### **Phase 1: Project Reorganization** ✅ COMPLETE (March 28, 2026)
- Created folder structure
- Moved files into appropriate folders
- Renamed `ContentView` to `Match3ContentView`
- Implemented dev switcher
- **Result:** Clean multi-game architecture ready

### **Phase 2: Match-3 Game Completion** ✅ COMPLETE
- Core gameplay working perfectly
- Bonus tiles, abilities, battle mechanics all functional
- Debug menu for testing
- **Result:** Polished, playable Match-3 RPG battle game

### **Phase 3: Physics Chain Game** ✅ COMPLETE (March 28, 2026)
- All code files created (6 files, ~700 lines total)
- Physics engine, spawning, collision detection complete
- Tiles rendering and falling properly
- Debug menu added with End Game button (April 6, 2026)
- **Result:** Fully playable Tsum-Tsum style physics game

### **Phase 4: Shop of Oddities** ✅ COMPLETE (April 6, 2026)
- All data model files created (7 files - added CommentaryManager)
- All UI component files created (11 files - added CommentaryView + AssetsDebugView)
- Game logic fully implemented (deck generation, scoring, repair names)
- Customer generation with OverQuest characters
- Persistent collectible catalog (repair ledger)
- Card draw animations (scale + fade + 3D flip)
- Repair result overlay (1.5 second display)
- New repair discovery banner (1 second display)
- Character commentary system (Sword + Ednar reactions)
- Commentary triggers for game events (cursed cards, high scores, customers)
- Game over/win screens with stats
- Play Again functionality
- Custom image asset support (icons + card backgrounds)
- Customer portrait support with UIImage loading
- Commentary icon support with UIImage loading
- Debug menu with asset viewer, character forcing, and End Game button
- UI redesign: Side-by-side deck layout (4 decks horizontal)
- Removed all bounding boxes and headers for minimalist design
- Image-first design philosophy with invisible UI elements
- Card flip animation (3D horizontal flip when drawing)
- Character slide-in animation (spring bounce from right)
- **Layout optimization (April 9, 2026):** Edge-to-edge score bar, bigger decks (36% vs 30%), bigger repair area (20% vs 17.7%), removed "COMPONENT DECKS" label, doubled deck spacing (12pt vs 6pt), scene preserved at 38%
- **Result:** Fully playable Miracle Merchant-style card game with minimalist, modern design and optimized layout

### **Phase 5: Game Selector System** ✅ COMPLETE (April 6, 2026)
- Created MapScreenView.swift (real map with continue button)
- Created GameSelectorView.swift (debug game picker)
- Integrated with existing Splash/Title/Map flow
- Added "Continue to Games" button to map screen
- Game selector shows 3 working games
- Easy testing on physical devices
- No code editing required to switch games
- **Result:** Seamless testing flow for all games

### **Phase 6: Debug Menu End Game Buttons** ✅ COMPLETE (April 6, 2026)
- Added debug menu to Physics Chain Game (wrench icon)
- Added "End Game" button to Physics debug menu (returns to title)
- Added "End Game" button to Shop of Oddities debug menu (returns to title)
- Proper cleanup of timers and game state
- Smooth transitions back to title screen
- **Result:** Easy exit from any game during testing

### **Phase 7: Splash/Title/Map Flow Fix** ✅ COMPLETE (April 6, 2026)
- Moved perfected splash/title/map logic from Match3ContentView to main app
- Preserved all animations (`.easeInOut(duration: 0.8)`)
- Preserved `GameConfig.enableDeveloperSplash` toggle
- Simplified Match3ContentView to just show game board
- Fixed infinite loop bug (Match-3 was showing its own splash/title/map)
- Added "End Game" button to Match-3 debug menu (returns to title)
- **Added "End Game" button to Match-3 pause menu** (☰ → End Game → Confirm → returns to title)
- All games now launch directly to game boards from game selector
- **Result:** Perfect flow with no looping, all animations intact, multiple exit options

### **Phase 8: Shop of Oddities Layout Optimization** ✅ COMPLETE (April 9, 2026)
- Complete layout restructuring for better space utilization
- Edge-to-edge score bar with preserved text positioning
- Removed gap between score bar and scene view
- Scene view preserved at 38% (no reduction)
- Commentary shrunk to 4% (from 5%)
- Gap 3 reduced to 3.5% (from 5.5%)
- Repair area increased to 20% (from 17.7%) - cards visibly bigger
- Gap 4 reduced to 3% (from 6%) - decks moved up
- Decks area increased to 36% (from 30%) - significantly bigger
- Deck spacing doubled to 12pt (from 6pt) - more breathing room
- "COMPONENT DECKS" label removed - cleaner minimalist aesthetic
- Changed padding strategy: individual section padding vs VStack padding
- Score bar refactored to function accepting GeometryProxy for edge-to-edge calculation
- **Result:** Optimized layout with bigger playable elements, preserved scene prominence, and improved visual hierarchy

### **Phase 9: Shop of Oddities UI Overhaul** ✅ COMPLETE (April 10, 2026)
**Complete 4-step UI redesign focusing on configurability, animations, and modern interaction:**

**Step 1: Layout Centralization**
- Created `ShopLayoutConfig.swift` - Single source of truth for all layout values
- Moved all hardcoded spacing, heights, padding, colors to config
- 30+ configurable parameters (section heights, gaps, ghost cards, animations)
- Well-documented with clear comments
- Easy to experiment with different layouts

**Step 2: Opening Animations (Deal + Flip)**
- Deal animation: Cards slide up from below (300pt offset, staggered 0.12s)
- Flip animation: 3D face-down to face-up reveal (staggered 0.15s, 0.4s duration)
- Card backs show purple gradient or custom `card-background` image
- Animation phase system: `.dealing` → `.flipping` → `.ready`
- All animations configurable (can disable for fast testing)

**Step 3: Drag-and-Drop System**
- Replaced tap-to-draw with modern drag-and-drop interaction
- Drag gesture with ghost card left behind (30% opacity)
- Card scales (1.1×) and becomes transparent (85%) while dragging
- Colored shadow follows card (deck color, 12pt radius)
- Snap-to-slot animation (0.25s) or spring-back-to-deck (0.3s)
- Repair area detection using global coordinates
- Master toggle in config (`dragEnabled`) - falls back to tap if disabled

**Step 4: Ghost Card Cleanup + Deck Rotation**
- Ghost card count configurable (0, 1, or 2)
- All ghost properties in config (rotation, opacity, X/Y offsets)
- Per-deck rotation array for fan effects or whimsical tilts
- Rotation applied to deck stack (anchor: bottom), card count stays horizontal
- Eliminated all hardcoded layout values

**Files Created:**
- `ShopLayoutConfig.swift` (184 lines)

**Files Modified:**
- `ShopOfOdditiesView.swift` - Animation phases, drag state management
- `DeckView.swift` - Deal/flip animations, drag-and-drop, ghost cards, rotation
- `RepairSlotView.swift` - Drop target feedback
- `ComponentCardView.swift` - Config references

**Benefits:**
- ✅ Polished professional animations
- ✅ Modern iOS-standard drag-and-drop
- ✅ Highly configurable (30+ parameters)
- ✅ No hardcoded values anywhere
- ✅ Easy to experiment with layouts
- ✅ All features can be toggled on/off

**Result:** Shop of Oddities now has AAA-quality UI with smooth animations and modern interaction patterns, all easily customizable via config file.

### **Phase 11: Debug Toggle System** ✅ COMPLETE (April 10, 2026)
**In-game debug controls for testing card reveal system:**

**Problem Solved:**
- Need to verify face-down/face-up card images are working correctly
- Text overlay on cards blocks view of background images
- No way to toggle visibility without editing code

**Solution Implemented:**
- Created `ShopDebugSettings.swift` - ObservableObject class for reactive debug settings
- Added "Hide Card Text Overlay" purple toggle in debug menu
- ComponentCardView observes settings and hides text when enabled
- Persistent storage via UserDefaults (survives app launches)
- Singleton pattern (`ShopDebugSettings.shared`)

**Files Created/Modified:**
- `ShopDebugSettings.swift` - NEW (ObservableObject with @Published property)
- `ComponentCardView.swift` - Added @ObservedObject observer
- `AssetsDebugView.swift` - Added purple toggle UI

**⚠️ Xcode Stability Issue Discovered:**
- **Problem:** ShopLayoutConfig.swift causes Xcode to crash when edited directly
- **Workaround:** All changes must be done via copy/paste full file replacement
- **Safe Method:**
  1. Copy entire replacement code
  2. Command+A in ShopLayoutConfig.swift
  3. Delete all
  4. Paste new code
  5. Command+S to save
- **Root Cause:** Unknown (possibly file corruption or Xcode index issue)
- **Status:** File is stable as of April 10, 2026 (no duplicate class definitions)
- **Other Files:** All other Shop of Oddities files work normally

**Benefits:**
- ✅ Toggle card text on/off in debug menu
- ✅ Easy verification of card reveal animations
- ✅ Persistent settings across app launches
- ✅ No code editing required
- ✅ Documented workaround for Xcode crash issue

**Result:** Debug toggle working perfectly for testing progressive card reveal system. Xcode stability issue documented with safe workaround.

### **Phase 10: Smart Card Rearrangement System** ✅ COMPLETE (April 10, 2026)
**iPhone home screen-style card insertion with smooth rearrangement and center bias:**

**Problem Solved:**
- Cards were always appending to the end regardless of drop position
- No visual feedback for where card would be inserted
- Limited strategic positioning options

**Solution Implemented:**
- **Position-aware insertion:** Calculate insert index based on drag X position
- **Gap detection:** Determine which gap (before, between, or after cards) user is hovering over
- **Smooth rearrangement:** Existing cards slide apart to make room for new card
- **Center bias:** All cards stay centered as a group regardless of insert position
- **No preview card:** Just existing cards animating (cleaner visual)

**Technical Implementation:**
1. **DragState enhancement:** Added `hoverInsertIndex: Int?` property
2. **RepairSlotView.calculateInsertIndex():** Static function calculates insert position from drag coordinates
3. **ShopOfOdditiesView.onChange:** Updates `dragState.hoverInsertIndex` when drag position changes
4. **ShopGameState.drawCard():** Modified to accept optional `insertAt` parameter and rearrange slots
5. **DeckView.handleCardSnap():** Passes insert index to onTap callback
6. **RepairSlotView positioning:** Creates gaps for hover positions, animates cards to new centered positions

**Key Fix:**
- Used `.onChange(of: dragState?.currentPosition)` to update state outside view rendering cycle
- Avoided SwiftUI "modifying state during view update" error
- State mutations now happen in proper lifecycle phase

**Files Modified:** 5 files
- `DeckView.swift` - Updated DragState model, handleCardSnap passes insert index
- `RepairSlotView.swift` - Added calculateInsertIndex() function, gap-based positioning
- `ShopOfOdditiesView.swift` - Added .onChange handler for drag position tracking
- `ShopGameState.swift` - Updated drawCard() to support insertion at specific index
- Debug logging added to all components for troubleshooting

**User Experience:**
- ✅ Drag card anywhere in repair area
- ✅ Watch existing cards slide apart showing where it will go
- ✅ Drop to insert at that exact position
- ✅ Strategic placement for adjacency bonuses
- ✅ Natural, intuitive interaction like iOS home screen

**Result:** Full smart rearrangement system working perfectly - cards can be placed in any order with smooth animations and center bias maintained.

### **Phase 11: Progressive Card Reveal Animation Fix** ✅ COMPLETE (April 11, 2026)
**Fixed the card flip animation for progressive reveal system - cards now flip smoothly from face-down to face-up without mirror image effect.**

**Problem Diagnosed:**
1. After implementing progressive reveal (cards stay face-down until previous card placed), the flip animation had issues
2. Card face appeared **horizontally mirrored** during the flip animation
3. This happened because 3D rotation around Y-axis makes content "face away" from camera after 90°

**Root Cause:**
- When rotating around Y-axis past 90°, the card is "facing away" from the viewer
- Card content appears mirrored (like looking at the back of the front face)
- Needed counter-rotation to keep content readable throughout flip

**Solution Implemented:**
- Added horizontal flip counter-rotation to card face view
- Applied `.scaleEffect(x: flipAngle > swapAngle ? -1 : 1, y: 1)` to `cardFaceView`
- When rotation angle exceeds swap angle (90°), card face is horizontally flipped
- This flip cancels out the mirroring effect from the 3D rotation
- Result: Card face stays readable throughout entire animation

**Files Modified:**
- `DeckView.swift` - Added counter-rotation to `cardFaceView` function (1 line)

**Technical Details:**
- Counter-rotation kicks in when `flipAngle > swapAngle` (90°) **AND** `animationPhase == .ready` **AND** actively flipping (`flipAngle > 0 && flipAngle < 180`)
- Uses `scaleEffect(x: -1)` to horizontally flip the card face content
- Only applies during progressive reveal flips (when flipAngle is actively changing)
- Opening animation keeps flipAngle at 0, so no counter-rotation applies
- The flip neutralizes the 3D rotation's mirroring effect
- Card text, values, and icons remain readable throughout flip

**Animation Flow:**
1. Card starts face-down (flipAngle = 0°)
2. User places card in repair area → Triggers flip
3. Animation rotates: 0° → 90° (card back visible)
4. **At 90°:** Counter-rotation activates, card face content flips horizontally
5. Animation continues: 90° → 180° (card face visible, readable)
6. Animation completes: Resets to 0°, card face-up

**Current Status:**
- ✅ Opening animation works perfectly (all 4 decks flip face-up together)
- ✅ Progressive reveal works (cards stay face-down until placed)
- ✅ Flip trigger works (UUID system activates flip)
- ✅ **Card face stays readable (no mirror image effect)**
- ✅ Smooth animation with clean crossfade

**Benefits:**
- ✅ Cards flip smoothly without visual glitches
- ✅ Card text and images stay readable throughout animation
- ✅ Professional 3D flip effect maintained
- ✅ Suspenseful progressive reveal system fully functional

**Result:** Progressive card reveal animation fully complete with smooth, readable card flips.

### **Phase 12: Debug Toggle System** ✅ COMPLETE (April 10, 2026)
**In-game debug controls for testing card reveal system:**

**Problem Solved:**
- Need to verify face-down/face-up card images are working correctly
- Text overlay on cards blocks view of background images
- No way to toggle visibility without editing code

**Solution Implemented:**
- Created `ShopDebugSettings.swift` - ObservableObject class for reactive debug settings
- Added "Hide Card Text Overlay" purple toggle in debug menu
- ComponentCardView observes settings and hides text when enabled
- Persistent storage via UserDefaults (survives app launches)
- Singleton pattern (`ShopDebugSettings.shared`)

**Files Created/Modified:**
- `ShopDebugSettings.swift` - NEW (ObservableObject with @Published property)
- `ComponentCardView.swift` - Added @ObservedObject observer
- `AssetsDebugView.swift` - Added purple toggle UI









**Benefits:**
- ✅ Toggle card text on/off in debug menu
- ✅ Easy verification of card reveal animations
- ✅ Persistent settings across app launches
- ✅ No code editing required
- ✅ Documented workaround for Xcode crash issue

**Result:** Debug toggle working perfectly for testing progressive card reveal system. Xcode stability issue documented with safe workaround.
### **Phase 13: Ednar's Cauldron Rewrite** 🟡 IN PROGRESS (May 3, 2026)
**Complete replacement of existing Cauldron game with new turn-based combat design.**

**Phase 1: Data Layer Setup** ✅ COMPLETE (May 3, 2026)
- Created `CauldronGameData.swift` with Codable structs
- Loaded traits.json (8 traits: intimidating, volatile, pious, skittish, draining, inspiring, loud, hexer)
- Loaded characters.json (14 customers: Mildred, Tomik, Greta, Pemberton, Ardo, etc.)
- Loaded rounds.json (Day 1 curated, Days 2-3 rule-based generation)
- Salvaged `DieTier` enum and `BagDie` struct from existing code
- Added `@StateObject` in OverQuestMatch3App.swift for app-launch loading
- Debug print confirms: "✅ Cauldron Data Loaded: 14 characters, 8 traits, days: day_1, day_2, day_3"
- **Result:** Data layer complete, existing game still functional

**Upcoming Phases (see REPLACEMENT_PLAN.md):**
- Phase 2: Game State Model (Customer struct, queue/swap, brew calculation)
- Phase 3: Replace the views (delete old, build new)
- Phase 4: Wire up queue/swap mechanic (critical - took 8 attempts in web prototype)
- Phase 5: Cauldron + dice + brewing (no animation yet)
- Phase 6: Animation sequence (7-phase brew with timing)
- Phase 7: Round flow + win/lose states
- Phase 8: Trait effects + polish
- Phase 9: Art swap-in

**Design Context:**
- Turn-based combat (every customer attacks per turn, active uses `active_attack`, waiters use `waiting_attack`)
- Queue/swap mechanic (tap profile = swap with queue[0], pure 2-element swap)
- 3 dice max per brew, hand of 5 (forces strategic choice)
- 5 dice types: potency, stability, boost, heal, shield (NOT the old 6-type system)
- Patience is purely a timer (ticks down, no per-turn damage)
- NO underbrew penalty (removed from old design)
- Day = 4 rounds: morning → afternoon → evening → night
- Night is always 1 boss customer

**Files:**
- REPLACEMENT_PLAN.md - Concrete 9-phase step-by-step plan
- SESSION_CHECKPOINT.md - Locked design decisions
- EdnarsCauldron_Reference.jsx - Architectural reference (combat math, animation timing)
- PHASE_1_COMPLETE.md - Verification instructions for Phase 1

**Salvaged from Existing Code:**
- Bag/discard system logic
- DieTier enum (kept dormant, all dice at `.basic` in v1)
- Debug positioning overlay (authoring tool for layout)
- Custom 12-node board topology

**Thrown Out:**
- Old patron generation system (replaced with characters.json)
- Old combat model (underbrew penalty, expiry-only damage)
- Old 6-dice-types system (mirror/restoration/terrain removed)
- Old theme colors (dark/purple → warm/parchment)

**Result:** Phase 1 complete - data loading working, ready for Phase 2.

### **Phase 14: Additional Games** 📋 PLANNED
- Cooking game design and implementation
- Potion Solitaire design and implementation

### **Phase 15: Map/Navigation Integration** 📋 PLANNED
- Map screen UI
- Progress tracking system
- Level unlock logic
- Story integration

---

## 🔧 TECHNICAL STACK

**Language:** Swift  
**Framework:** SwiftUI  
**iOS Target:** iOS 17.0+  
**Architecture Patterns:**
- @Observable for state management
- async/await for asynchronous operations
- Value types (structs) for data models
- Protocol-oriented design where appropriate

**Key Technologies:**
- SwiftUI for all UI
- Swift Concurrency (async/await, actors)
- Timer for physics updates (Physics Chain Game)
- GeometryReader for responsive layouts
- Custom shapes and paths for effects

---

## 📝 CODING GUIDELINES

### **For AI Assistants Working on This Project:**

**CRITICAL RULES:**
1. ✅ Provide COMPLETE, copy-paste ready code (never snippets)
2. ✅ Include step-by-step Xcode instructions for user
3. ✅ Explain in simple language (user has zero coding knowledge)
4. ✅ Ask clarifying questions instead of making assumptions
5. ✅ Never break existing functionality
6. ✅ Update appropriate CONTEXT files after changes
7. ✅ Test instructions must be beginner-friendly

**File Modification Protocol:**
- Always provide the ENTIRE file or ENTIRE function
- Show exactly WHERE to paste (file name, line numbers)
- Give step-by-step Xcode navigation instructions
- Explain WHAT will change in the app visually

**Testing Requirements:**
- Provide specific test scenarios
- Explain expected visual results
- Include rollback instructions if something breaks

---

## 🎯 CURRENT STATUS

### **What's Working:**
- ✅ Project reorganization complete
- ✅ Game selector flow functional (Splash → Title → Map → Selector → Games)
- ✅ **Title screen background fade sequence working correctly** (May 17, 2026)
  - ✅ Shows `title_screen01.png` first after splash
  - ✅ Fades to `title_screen.png` after 2 seconds
  - ✅ No more double-appearance of backgrounds
- ✅ Match-3 game fully playable
- ✅ Physics Chain Game fully playable with debug menu
- ✅ Shop of Oddities fully playable with debug menu
- ✅ All games have "End Game" buttons to return to title
- ✅ Match-3 has TWO ways to end game: Debug menu (🔨) AND Pause menu (☰)
- ✅ Easy testing on physical devices (no code editing)

### **What's In Progress:**
- 🟡 **Ednar's Potion Cauldron** - Phase 7 complete, layout refinement ongoing (May 6, 2026)
  - Day 1 fully playable (Morning → Afternoon → Evening → Night)
  - Live preview overlay layout editor functional
  - Per-character scaling system active (Mildred: 2.46×2.13×, Tomik: 2.34×2.13×)
  - **Latest update:** Mildred's width refined from 2.34× to 2.46× (5.2% wider)
  - Art is placeholder (ready for asset integration - Phase 8)
  - See `CAULDRON_CONTEXT.md` for complete details

### **What's Planned:**
- 📋 Cooking game design & implementation
- 📋 Potion Solitaire design & implementation
- 📋 Real map/navigation system with game unlocks
- 📋 Progress tracking system
- 📋 Story integration

---

## 📚 RELATED DOCUMENTATION

**Detailed Game Context:**
- `MATCH3_CONTEXT.md` - Complete Match-3 game documentation
- `PHYSICS_CONTEXT.md` - Physics Chain Game documentation
- `ShopOfOddities_CONTEXT.md` - Shop of Oddities game documentation
- `SHOP_IMAGE_ASSETS_REFERENCE.md` - Quick reference for Shop of Oddities custom images
- `REPLACEMENT_PLAN.md` - Ednar's Cauldron rewrite plan (9 phases)
- `SESSION_CHECKPOINT.md` - Ednar's Cauldron design decisions
- `EdnarsCauldron_Reference.jsx` - Ednar's Cauldron architecture reference
- `PHASE_1_COMPLETE.md` - Cauldron Phase 1 verification guide

**Project Organization:**
- `STRUCTURE_CONTEXT.md` - Reorganization tracker and guide

**Planning Documents:**
- `GAME_PLANNING_TAVERN_TSUM_MATCH.md` - Multi-game expansion plans

**Session Transcripts:**
- Located in `ReadFilesForContext/` folder
- Contains detailed implementation histories

---

## 🤝 WORKING WITH THIS PROJECT

### **For New Chat Sessions:**
1. Read this file first for project overview
2. Read game-specific context file (`MATCH3_CONTEXT.md`, `PHYSICS_CONTEXT.md`, or `ShopOfOddities_CONTEXT.md`)
3. Check `STRUCTURE_CONTEXT.md` for organization details
4. Use `query_search` to find additional files if needed

### **Before Making Changes:**
1. Identify which game the change affects
2. Check that game's context file for current state
3. Verify existing functionality won't break
4. Plan complete, testable implementation

### **After Making Changes:**
1. Update appropriate context file (Match3, Physics, or both)
2. Update this master context if architecture changes
3. Provide clear testing instructions
4. Document any new features or fixes

---

## 🔗 QUICK REFERENCE LINKS

**Key Files:**
- App Entry: `OverQuestMatch3App.swift`
- Match-3 Main View: `Match3Game/Match3ContentView.swift`
- Physics Game Main View: `PhysicsChainGame/PhysicsChainGameView.swift`
- Shop of Oddities Game State: `ShopOfOddities/ShopGameState.swift`
- Shared Character Data: `Shared/Character.swift`
- Game Assets Config: `Shared/GameAssets.swift`

**Common Tasks:**
- Switch games: Use game selector (Map → "Continue to Games" → Tap game)
- Test on device: Connect iPhone, select device, Command+R
- End game: Tap wrench icon in any game → "End Game" button
- Add new game: Create folder + ContentView, add to GameType enum and GameSelectorView
- Modify Match-3: Edit files in `Match3Game/` folder
- Modify Physics Game: Edit files in `PhysicsChainGame/` folder
- Modify Shop Game: Edit files in `ShopOfOddities/` folder
- Share code: Add to `Shared/` folder

---

**END OF MASTER CONTEXT**

For game-specific details, see:
- Match-3 Game: `MATCH3_CONTEXT.md`
- Physics Chain Game: `PHYSICS_CONTEXT.md`
- Shop of Oddities: `ShopOfOddities_CONTEXT.md`
- Ednar's Cauldron: `REPLACEMENT_PLAN.md`, `SESSION_CHECKPOINT.md`, `EdnarsCauldron_Reference.jsx`
---

## 📝 RECENT SESSION LOG

### **Session: Title Screen Background Fade Fix** (May 17, 2026)

**Issue Reported:**
User noticed title screen was showing backgrounds in wrong order:
- Current (broken): `title_screen.png` → `title_screen01.png` → `title_screen.png`
- Desired: `title_screen01.png` → `title_screen.png`

**Diagnosis:**
- Layer order in ZStack was reversed
- `title_screen.png` was bottom layer (always visible)
- `title_screen01.png` was top layer (fading OUT)
- This created double-appearance effect

**Fix Applied:**
- Reversed layer positions in TitleScreenView.swift
- Changed `title_screen01.png` to BASE layer (always visible)
- Changed `title_screen.png` to TOP layer (fades IN)
- Updated state variable: `initialBackgroundOpacity` → `finalBackgroundOpacity`
- Changed opacity animation: fade OUT (1.0 → 0.0) to fade IN (0.0 → 1.0)

**Files Modified:**
- TitleScreenView.swift (complete rewrite of background layer logic)

**Result:**
✅ Title screen now correctly shows: 01 → final (2 second delay, 1.25 second fade)
✅ No more double-appearance
✅ Leaves continue animating throughout both backgrounds

**Testing Verified:**
- Splash screen plays
- Fades to `title_screen01.png`
- After 2 seconds, `title_screen.png` fades in smoothly
- Final state maintained with leaf animation loop

