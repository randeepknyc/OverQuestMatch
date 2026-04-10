# MASTER PROJECT CONTEXT
**OverQuestMatch3 - Multi-Game iOS Application**

> **Last Updated:** April 9, 2026 (Shop of Oddities layout optimization)  
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
3. **Shop of Oddities** - ✅ COMPLETE & FULLY PLAYABLE - Minimalist card repair game with custom artwork, debug menu for asset testing + End Game button, optimized layout (April 9, 2026)
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
│  ├─ ShopOfOdditiesView.swift (with debug button)
│  ├─ ComponentCardView.swift
│  ├─ DeckView.swift
│  ├─ CustomerView.swift (with custom portrait support)
│  ├─ RepairSlotView.swift
│  ├─ RepairResultOverlay.swift
│  ├─ ShopGameOverOverlay.swift
│  ├─ NewRepairDiscoveredBanner.swift
│  ├─ CommentaryView.swift (with custom icon support)
│  └─ AssetsDebugView.swift (debug menu for asset testing + character forcing) ✨ NEW (character commentary display)
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

### **Phase 9: Additional Games** 📋 PLANNED
- Cooking game design and implementation
- Potion Solitaire design and implementation

### **Phase 10: Map/Navigation Integration** 📋 PLANNED
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
