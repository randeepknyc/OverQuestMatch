# MASTER PROJECT CONTEXT
**OverQuestMatch3 - Multi-Game iOS Application**

> **Last Updated:** April 10, 2026 (Shop of Oddities - Smart card rearrangement system complete)  
> **Project Status:** Active Development - Multi-Game Architecture Complete with Perfect Testing Flow

---

## 🎯 PROJECT OVERVIEW

**Project Name:** OverQuestMatch3  
**Platform:** iOS (SwiftUI)  
**Architecture:** Multi-game collection with integrated progression system  
**User Coding Level:** Zero coding knowledge - Requires complete, copy-paste ready code

### **Current Games:**
1. **Match-3 RPG Battle** - ✅ COMPLETE & WORKING
2. **Physics Chain Game** - ✅ COMPLETE & WORKING (with debug menu + End Game button)
3. **Shop of Oddities** - ✅ COMPLETE & FULLY PLAYABLE - Minimalist card repair game with custom artwork, debug menu, optimized layout, polished animations (deal/flip/drag-and-drop), and centralized config system (April 10, 2026)
4. **Cooking Game** - 📋 Planned
5. **Potion Solitaire** - 📋 Planned
6. **Map Navigation System** - 📋 Planned

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
├─ CookingGame/ ✅ (Empty - ready for development)
├─ PotionSolitaireGame/ ✅ (Empty - ready for development)
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
- Shows only working games (Match-3, Physics Chain, Shop of Oddities)
- Tap any game → Launches full-screen
- "Back to Map" button to return
- Clearly labeled as "🎮 DEBUG TEST 🎮"

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
- `.cooking` - Cooking Game (coming soon)
- `.potionSolitaire` - Potion Solitaire Game (coming soon)
- `.mapNavigation` - Map Navigation System (coming soon)

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
### **Phase 13: Additional Games** 📋 PLANNED
- Cooking game design and implementation
- Potion Solitaire design and implementation

### **Phase 14: Map/Navigation Integration** 📋 PLANNED
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
- ✅ Match-3 game fully playable
- ✅ Physics Chain Game fully playable with debug menu
- ✅ Shop of Oddities fully playable with debug menu
- ✅ All games have "End Game" buttons to return to title
- ✅ Match-3 has TWO ways to end game: Debug menu (🔨) AND Pause menu (☰)
- ✅ Easy testing on physical devices (no code editing)

### **What's In Progress:**
- Nothing! All core systems working

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
