# MASTER PROJECT CONTEXT
**OverQuestMatch3 - Multi-Game iOS Application**

> **Last Updated:** July 11, 2026 — CAULDRON **PLAYTEST V1 built** (hpGrowth 1.07→1.09, split round/relic pools, Focus-Free dice cap-1/lane, Bitter Dregs, Iron Kettle, Ember Charm, patience jitter). Balance lab **v3.3** models the game's tap-to-swap targeting (earlier labs understated the player) + ⭐ PLAYTEST V1 preset. Layout bake batches 2–4 merged; editor exports proved CUMULATIVE (only the last of a stack matters). Full detail: CAULDRON_CONTEXT **§73**. — Previously July 10: 🧠 MEMORY ARCHITECTURE (the 2.8GB saga resolution + the global image-loading rule)  
> **Project Status:** Active Development — current focus is **Ednar's Potion Cauldron** (a dice-roguelite in `PotionShop/`). That game has its own authoritative doc, `CAULDRON_CONTEXT.md`.

---

## 🎯 PROJECT OVERVIEW

**Project Name:** OverQuestMatch3  
**Platform:** iOS (SwiftUI)  
**Architecture:** Multi-game collection with integrated progression system  
**User Coding Level:** Zero coding knowledge - Requires complete, copy-paste ready code

### **Current Games:**
1. **Match-3 RPG Battle** - ✅ COMPLETE & WORKING (S26: multi-enemy roster, "Choose Your Foe" screen, signature gems — see MATCH3_CONTEXT.md)
2. **Ednar's Potion Cauldron** - 🔨 ACTIVE DEVELOPMENT (current focus) — a dice-roguelite in `PotionShop/`. Full, authoritative docs: **`CAULDRON_CONTEXT.md`**
3. **Shop of Oddities** - module present in the project (`ShopOfOddities/`); see `ShopOfOddities_CONTEXT.md`
4. **Physics Chain Game** - ⚠️ CODE COMPLETE - Debugging tile display issue
5. **Cooking Game** - 📋 Planned
6. **Potion Solitaire** - 📋 Planned
7. **Map Navigation System** - 📋 Planned

---

## 📁 PROJECT STRUCTURE

**Root Level:**
```
OverQuestMatch3/ (ROOT)
├─ OverQuestMatch3App.swift ✨ Main app entry (dev switcher + GameType enum)
├─ GameSelectorView.swift ✨ Runtime game selector (routes to each game)
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
│  ├─ CharacterAnimations.swift (a.k.a. CharacterAnimations-Shared in older docs)
│  ├─ AnimationCoordinator.swift ✨ NEW (Session 25 - animation queue/priority)
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
├─ PotionShop/ 🔨 (Ednar's Potion Cauldron — ACTIVE; authoritative doc: CAULDRON_CONTEXT.md)
│  ├─ PotionShopModels.swift          (data types + PotionShopConfig + image loader)
│  ├─ PotionShopData.swift            (customers, traits, day/round content)
│  ├─ PotionShopGameState.swift       (@Observable engine: queue, dice, brewing, ednarPose)
│  ├─ PotionShopGameView.swift        (root view + live layout-editor overlay w/ tabs)
│  ├─ PotionShopHeaderView.swift
│  ├─ PotionShopCustomerSceneView.swift (Ednar poses + customer line + inspect strip)
│  ├─ PotionShopCauldronView.swift    (bowl, nodes, BREW, dice tray, fire meter)
│  ├─ PotionShopDebugMenu.swift
│  ├─ PotionShopBrewAnimator.swift    (animation timing — single source of truth)
│  ├─ PotionShopLayoutConfig.swift    (@Observable live-tunable layout values)
│  ├─ PotionShopRunSystem.swift
│  ├─ PotionShopEditorKit.swift
│  ├─ PotionShopFireMeterView.swift / PotionShopFireMeterDebugView.swift
│  └─ PotionShopFireMeterConfig.swift (now an empty stub — merged into LayoutConfig)
│   └─ (full current file list lives in CAULDRON_CONTEXT.md §2.1)
│
├─ ShopOfOddities/ ✅ (separate game module; see ShopOfOddities_CONTEXT.md)
├─ CauldronGame/ ⚠️ (LEGACY original Cauldron — NOT wired in; slated for deletion)
│
├─ CookingGame/ ✅ (Empty - ready for development)
├─ PotionSolitaireGame/ ✅ (Empty - ready for development)
├─ Navigation/ ✅ (Empty - ready for development)
├─ Utilities/ (Existing - unchanged)
├─ Models/ (Existing - mostly empty after migration)
└─ ReadFilesForContext/ (Documentation and context files)
```

---

## 🎮 DEV SWITCHER SYSTEM

**Location:** `OverQuestMatch3App.swift` (Line 25)

```swift
private let currentGame: GameType = .match3
```

**Available Game Types:**
- `.match3` - Match-3 RPG Battle Game (✅ WORKING)
- `.ednarsPotionShop` - Ednar's Potion Cauldron (🔨 active focus)
- `.physicsChain` - Physics Chain Game (⚠️ CODE COMPLETE - tiles not rendering)
- `.cooking` - Cooking Game (coming soon)
- `.potionSolitaire` - Potion Solitaire Game (coming soon)
- `.mapNavigation` - Map Navigation System (coming soon)

> **Note (June 28, 2026):** a runtime `GameSelectorView.swift` now also routes between games. Ednar's Potion Cauldron is reached from the selector ("Ednar's Potion Cauldron" → launches straight into Day 1 / Morning). "End Game" in its debug menu returns to the selector.
> **Note (July 13, 2026):** Shop of Oddities + Enna's Tavern are LOCKED in the selector ("Coming soon", greyed, 🔒) unless dev mode is on — see 🛠 DEV MODE SYSTEM below.

**How to Switch Games:**
1. Open `OverQuestMatch3App.swift`
2. Find line 25: `private let currentGame: GameType = .match3`
3. Change `.match3` to another game type
4. Press Command+R to run
5. App launches with selected game

---

## 🛠 DEV MODE SYSTEM (July 13, 2026)

One app-wide switch separating the DEVELOPER experience from the
FRIEND/TESTFLIGHT experience. Lives in **`DevMode.swift` (project root)** —
`DevMode.shared.unlocked`, @Observable, persisted in UserDefaults
(`devModeUnlocked`). **Default OFF in every build**, Xcode runs included.

**Dev mode OFF (what friends see):**
- No potion-shop debug button, no Match-3 hammer
- Enna's Tavern + Shop of Oddities: greyed "Coming soon" + 🔒 in the game
  selector, not launchable

**Turning it ON — 5 quick taps (≤1.5s apart) on any of:**
- the "Day N" label in the potion shop header
- the invisible center strip over Match-3's HUD (score area)
- the "GAME SELECTOR" title (so locked games unlock without entering a game)
Feedback: medium haptic + "🛠 Dev mode ON" toast (`.devModeToast()`).
Taps only turn it ON — never off (no accidental lockouts). Rev 3: if already on, 5 taps show "🛠 Dev mode already ON" instead of silence. NOTE: dev mode persists PER DEVICE — every simulator is its own device with its own state.

**Turning it OFF:** the "🙈 Hide Dev Mode" button inside either debug menu
(potion debug menu top section; Match-3 debug menu under End Game).

**Shim:** `PotionShopDebugAccess.isAvailable` now just reads
`DevMode.shared.unlocked` (old 7-tap toggle + `ps_debugUnlocked` key retired).
TestFlight builds ship locked automatically — nothing to flip before archiving
(see `TESTFLIGHT_STEPS.md`).

---

## 🏗️ ARCHITECTURE PHILOSOPHY

### **Self-Contained Game Modules**
Each game is built as a completely independent module:
- ✅ Has its own ContentView (e.g., `Match3ContentView`, `PhysicsChainGameView`)
- ✅ Has its own ViewModel and logic files
- ✅ Can be tested independently via dev switcher
- ✅ Uses shared resources from `Shared/` folder
- ✅ **Prefixes its own types to avoid cross-game name collisions.** The Cauldron prefixes everything `PotionShop` after real build breaks (`Customer` collided with `ShopOfOddities/Customer`; `CauldronBoardView` with `CauldronGame/`). See `CAULDRON_CONTEXT.md` §3.

### **Shared Resources**
Common code used by ALL games lives in `Shared/`:
- Character data models (`Character.swift`)
- Asset names and UI config (`GameAssets.swift`)
- Battle mechanics config (`BattleMechanicsConfig.swift`)
- Character animations (`CharacterAnimations.swift` - boil flipbook engine)
- Animation queue/priority system (`AnimationCoordinator.swift` - Session 25)
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

## 🧠 MEMORY ARCHITECTURE (July 10, 2026 — read before adding ANY full-screen art)

**THE ONE RULE: every drawn-art image in the ENTIRE APP routes through `PotionShopImageLoader.loadDisplayImage(named:displaySize:)`** — the budgeted, 2048px-capped, at-size decoder living in `PotionShopModels.swift`. Raw SwiftUI `Image("name")` decodes at FULL export resolution into Apple's process-wide cache and is forbidden for drawn art on every screen: game screens AND app-level screens (splash, title, map, selector). SF Symbols and tiny UI glyphs are fine raw.

**Why this rule is global (the 2.8GB saga, resolved July 10):** the splash/title/map flow drew ~28 full-screen PNGs (~134MB decoded EACH — exports are ~4,000×8,600px) via raw `Image("…")`. Because all games open inside the same process via fullScreenCover, Ednar's Potion Cauldron inherited up to ≈2.66GB of decoded title art, sized by how long the user lingered before entering — weeks of "bimodal" 200MB-vs-2,800MB launches. Fixed by routing `TitleScreenView`, `DeveloperSplashView`, and `MapScreenView` through the loader (leaves at half screen height to fit the budget) and stopping three never-invalidated animation Timers in those files. Post-fix: flat ~190MB launches. Full detail, instruments, and rules: **CAULDRON_CONTEXT.md §72**.

**Cross-game facts to respect:**
- `MapScreenView` and `GameSelectorView` stay MOUNTED underneath a running game (fullScreenCover) — anything they hold stays resident all session.
- `GameSelectorView` purges image caches on game dismissal (`purgeInterGameCaches`).
- Every repeating `Timer` in a SwiftUI view MUST be stored and invalidated in `onDisappear` — three "runs forever after the screen is gone" leaks were found in the title flow.
- The Potion Cauldron debug menu's Memory panel is the shared diagnostic instrument set (footprint, VM buckets, exposure ledger, liveness census, launch curve, layer audit, decode profiler, title-flow probe) — screenshot the whole panel for any future memory anomaly in ANY game.

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
- Board/UI durations: 0.2-0.4 seconds

### **Character Portrait Animation System** ✨ NEW (Session 25)
- Every character state plays a 3-frame line-boil flipbook (0.15s/frame,
  0.45s per loop), driven by TimelineView (clock-based, cannot freeze)
- AnimationCoordinator (one per character) manages a queue + priority
  system: hurt interrupts attack, victory/defeat interrupt everything,
  repeated cascade attacks merge into one
- Enemy turns WAIT for the player's animation queue to finish
- Game-over screen appears when the 2s victory/defeat animation completes
- All tuning (hold times, priorities, queue/drop rules) lives in the config
  table at the top of AnimationCoordinator.swift
- Boil art is plug-and-play: drop ramp_<state>_boil1/2/3 PNGs into Assets,
  no code changes (see ANIMATION_ART_GUIDE.md)
- ⚠️ ONLY AnimationCoordinator may write character.currentState

### **Layout Strategy**
- Geometry-based responsive sizing
- Percentage-based heights (varies by game)
- Fixed-size UI elements (buttons, badges)
- Z-index layering for overlays

### **Haptic Feedback System** ✨ (June 26, 2026)
- `Shared/HapticManager.swift` owns ALL haptics for every game. It keeps
  **retained, pre-prepared** `UIImpactFeedbackGenerator`s (light/medium/heavy/
  rigid) and exposes `HapticManager.shared`.
- ⚠️ LESSON: generators that are created + prepared + fired in the same instant
  get dropped by the cold Taptic Engine and feel "dead." ALWAYS go through the
  shared, pre-prepared instances — never spin up a one-off generator at the call
  site.
- Match-3 haptics: original, working, untouched.
- Cauldron haptics: an additive "Ednar's Potion Cauldron" section in the same
  file, with labeled knobs for three events — ROLL (tray dice tumble),
  PLACE (die into a node), HIT (combat). Master switch:
  `PotionShopHaptics.enabled` in `PotionShopGameState.swift`.
  Full knob reference + call sites: see `CAULDRON_CONTEXT.md` §53.6 and the
  non-coder cheat sheet PDF.
- Device note: haptics fire only on a **physical iPhone** with System Haptics ON.

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

### **Phase 3: Physics Chain Game** ⚠️ IN PROGRESS (March 28, 2026)
- All code files created (6 files, ~700 lines total)
- Physics engine, spawning, collision detection complete
- **Issue:** Tiles not rendering on screen (debugging in progress)
- **Result:** Code complete, troubleshooting display

### **Phase 4: Additional Games** 📋 PLANNED
- Cooking game design and implementation
- Potion Solitaire design and implementation

### **Phase 5: Map/Navigation Integration** 📋 PLANNED
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
- TimelineView for character boil flipbooks (Session 25)
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
- ✅ Dev switcher functional
- ✅ Match-3 game fully playable
- ✅ Character animation queue/priority system (Session 25) — idle + attack
  boils animating; other states show static art until boil frames are added
- ✅ Physics Chain Game code complete

### **What's In Progress:**
- 🔨 **Ednar's Potion Cauldron** — active development (dice/brewing core playable; recently: stability fire meter w/ live editor, Ednar pose art system). Authoritative status in `CAULDRON_CONTEXT.md`.
- ⚠️ Physics Chain Game - Debugging tile display issue

### **What's Planned:**
- 📋 Cooking game design & implementation
- 📋 Potion Solitaire design & implementation
- 📋 Map/navigation system
- 📋 Progress tracking system

---

## 📚 RELATED DOCUMENTATION

**Detailed Game Context:**
- `CAULDRON_CONTEXT.md` - **Ednar's Potion Cauldron — authoritative & current** (read first when working on that game)
- `MATCH3_CONTEXT.md` - Complete Match-3 game documentation
- `PHYSICS_CONTEXT.md` - Physics Chain Game documentation
- `ShopOfOddities_CONTEXT.md` - Shop of Oddities documentation

**Project Organization:**
- `STRUCTURE_CONTEXT.md` - Reorganization tracker and guide

**Planning Documents:**
- `GAME_PLANNING_TAVERN_TSUM_MATCH.md` - Multi-game expansion plans

**Animation System (Session 25):**
- `ANIMATION_ART_GUIDE.md` - 🎨 NON-CODER guide for all animation/art changes
- `SESSION_25_ANIMATION_COORDINATOR_SYSTEM.md` - How the system was built
- ⚠️ Supersedes animation sections of `final_charactersystem_WORKING-ramp.md`
  and `SESSION_15_CHARACTER_ANIMATION_PLANNING.md` (old static-image system)

**Session Transcripts:**
- Located in `ReadFilesForContext/` folder
- Contains detailed implementation histories

---

## 🤝 WORKING WITH THIS PROJECT

### **For New Chat Sessions:**
1. Read this file first for project overview
2. Read game-specific context file (`MATCH3_CONTEXT.md` or `PHYSICS_CONTEXT.md`)
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
- Dev Mode (app-wide): `DevMode.swift` (project root)
- Match-3 Main View: `Match3Game/Match3ContentView.swift`
- Physics Game Main View: `PhysicsChainGame/PhysicsChainGameView.swift`
- Shared Character Data: `Shared/Character.swift`
- Game Assets Config: `Shared/GameAssets.swift`

**Common Tasks:**
- Switch games: Edit `OverQuestMatch3App.swift` line 25
- Add new game: Create folder + ContentView, add to GameType enum
- Modify Match-3: Edit files in `Match3Game/` folder
- Modify Physics Game: Edit files in `PhysicsChainGame/` folder
- Share code: Add to `Shared/` folder

**Layout law (July 13, 2026 — the 440pt landmine):** never let fixed frames +
fixed spacing/padding in a row sum past the narrowest supported screen. A
Pro-Max-tuned 180+180pt portrait row in Match-3 had a 440pt minimum and
right-clipped every narrower device for weeks (fix: sizes derive from real
width, capped at the design size — see MATCH3_CONTEXT Session 27). The
potion shop had the same disease across ALL its hand-baked layout values and
uses the opposite cure: the whole game renders at a fixed 440×863 design
canvas and uniformly scales to the real screen (CAULDRON_CONTEXT §78).

---

**END OF MASTER CONTEXT**

For game-specific details, see:
- Match-3 Game: `MATCH3_CONTEXT.md`
- Physics Chain Game: `PHYSICS_CONTEXT.md`
