# GAME PLANNING: TAVERN/TSUM/MATCH - Complete Transcript

**Date:** March 25, 2026  
**Project:** OverQuestMatch3 - Multi-Game Expansion Planning  
**Status:** Planning Phase - No Code Changes Made Yet

---

## 📋 EXECUTIVE SUMMARY

The user wants to expand their existing Match-3 RPG battle game into a **multi-game experience** with three distinct game types, all connected by a story-driven map/navigation system.

### **Current State:**
- ✅ Working Match-3 battle game with Ramp (player) vs Toad King (enemy)
- ✅ Features: Swap/Chain modes, bonus tiles, coffee cup abilities, battle mechanics
- ❌ No level progression system
- ❌ No map/navigation screen
- ❌ Only one battle scenario

### **Desired Future State:**
```
Story Map Screen
├─ Match-3 Battle Levels (current game + campaign system)
├─ Tsum Tsum Physics Game (falling bubble matching)
└─ Cooking/Merchant Game (Miracle Merchant + Stackland style)

All connected by story progression
All use same character (Ramp) and world/theme
Progress unlocks new game types
```

---

## 🎯 USER'S ORIGINAL QUESTIONS

### **Question 1: Multiple Levels with Same Character**
> "can i add multiple levels with the same character? what would they be and how would it work?"

**User's Answer (from previous chat):**
- Wants **BOTH** difficulty variations AND different enemies
- Example: Level 1 = Toad King (Easy), Level 5 = Fire Dragon, Level 10 = Toad King (Hard Mode)
- Same character (Ramp) progresses through different challenges

### **Question 2A: Physics-Based Chain Matching Game**
> "a physics based chain matching game"

**User Clarified:**
- **Tsum Tsum style** (falling character bubbles that stack, connect by drawing lines)
- **Already partially created in another project**
- Will be a **separate game type unlocked on the map**

### **Question 2B: Solitaire Style/Tavern Resource Game**
> "a solitaire style/tavern resource game"

**User Clarified:**
- **Miracle Merchant style** = card-matching merchant game (flip cards, match pairs, serve customers)
- **Culinarium/Stackland/Overcooked style** = resource management cooking game (gather ingredients, cook dishes, serve customers)
- Will be a **separate level/game type** on the map
- **NOTE:** These are two different game styles - user needs to clarify which one they want

### **Overall Integration:**
> "it's going to connect in a story fashion where a map type screen will unlock individual game types as the player progresses, and then the user can play between each type"

---

## 🤔 CLARIFYING QUESTIONS ASKED

### **About Map Screen Navigation:**
1. **Visual style preference:**
   - A) Royal Match style (vertical scrolling path with circular level nodes)
   - B) Overworld map (like Super Mario World - move between locations)
   - C) Chapter-based menu (text list)
   - D) Something else?

2. **Level unlock logic:**
   - A) Linear (beat Level 1 → unlock Level 2)
   - B) Branching (beat Level 1 → choose Level 2A OR 2B)
   - C) Star-based (need 3 stars total to unlock next section)

3. **Can you replay beaten levels?**
   - Yes (for high scores, grinding resources, practice)
   - No (one-and-done story progression)

**STATUS:** ❌ User has not answered these yet

---

### **About Tsum Tsum Project:**
1. **Is it in Swift/SwiftUI?** (Or another language/framework?)
2. **How complete is it?**
   - A) Just physics/falling bubbles work
   - B) Matching/connecting works
   - C) Full game loop (score, win/lose) works
3. **Do you want to:**
   - A) Copy it into this project and integrate it
   - B) Rebuild it from scratch inside this project
   - C) Show me the code from that project so I can adapt it

**STATUS:** ❌ User has not answered these yet

---

### **About Cooking/Merchant Game:**
User mentioned **TWO different game styles:**

**Option 1: Card-Based Merchant (Miracle Merchant)**
- Turn-based
- Flip cards, match customer orders, make potions
- Strategic puzzle

**Option 2: Real-Time Cooking (Culinarium/Stackland/Overcooked)**
- Time pressure
- Drag ingredients around
- Serve customers before time runs out

**Question:** Which one do you actually want? Or a hybrid?

**STATUS:** ❌ User has not answered this yet

---

### **About Progress Sharing:**
Options presented:

**A) Shared Currency System**
- Beat any level in any game → earn gold
- Spend gold to unlock new levels OR upgrade Ramp

**B) Shared Character Progression**
- Ramp's stats carry across all game types
- Upgrade Ramp in one game → stronger in all games

**C) Separate Progression Per Game Type**
- Match-3 levels separate from Tsum Tsum levels
- Only unlocking them is the connection

**D) Story-Only Connection**
- No shared mechanics, just narrative flow

**STATUS:** ❌ User said "maybe share progress" but unsure what this means

---

## 💡 KEY ARCHITECTURAL DECISION MADE

### **User's Key Question:**
> "is it advisable to create each game type/level in another project then merge them?"

### **AI's Answer: NO - Here's What to Do Instead**

#### ❌ **Why NOT Separate Xcode Projects:**
1. **Merging is nightmare-level complex**
   - Manually copy every file
   - Fix all import statements
   - Resolve naming conflicts
   - Recreate asset catalogs
   - Fix broken references
   - Could take DAYS of debugging

2. **Shared code gets duplicated**
   - Both projects have `Character.swift`, `GameAssets.swift`
   - When merged: which version to keep?

3. **Navigation becomes impossible**
   - Two different `ContentView.swift` files fight each other
   - Have to rebuild navigation anyway

4. **Can't test integration until after merge**
   - Find out problems WAY too late

---

#### ✅ **RECOMMENDED APPROACH: One Project, Separate Folders**

Build each game type as a **standalone, self-contained module** in the SAME project, then connect them with map/nav later.

**Project Structure:**
```
OverQuestMatch3/
│
├─ OverQuestMatch3App.swift        ← Main app entry (dev switcher)
│
├─ Shared/                          ← Code ALL games use
│  ├─ Character.swift               ← Ramp character data
│  ├─ GameAssets.swift              ← Images, fonts, colors
│  └─ Extensions.swift              ← Helper code
│
├─ Match3Game/                      ← Current game (self-contained)
│  ├─ Match3ContentView.swift      ← Main view for THIS game
│  ├─ GameViewModel.swift
│  ├─ BattleManager.swift
│  ├─ GameBoardView.swift
│  ├─ TileType.swift
│  └─ (all existing match-3 files)
│
├─ TsumTsumGame/                    ← Physics game (self-contained)
│  ├─ TsumTsumContentView.swift    ← Main view for THIS game
│  ├─ TsumTsumViewModel.swift
│  ├─ PhysicsManager.swift
│  └─ (all Tsum Tsum files)
│
├─ CookingGame/                     ← Cooking game (self-contained)
│  ├─ CookingContentView.swift     ← Main view for THIS game
│  ├─ CookingViewModel.swift
│  ├─ RecipeManager.swift
│  └─ (all cooking game files)
│
└─ Navigation/                      ← ADD LATER when ready
   ├─ MapScreenView.swift           ← Map connects everything
   ├─ GameLauncher.swift            ← Handles launching games
   └─ ProgressManager.swift         ← Tracks unlocks/completion
```

---

### **How Development Works:**

#### **Phase 1: Build Individual Games (NOW)**

In `OverQuestMatch3App.swift`, use a simple switcher:

```swift
import SwiftUI

@main
struct OverQuestMatch3App: App {
    
    // 🎮 DEVELOPMENT MODE: Switch which game you're working on
    enum ActiveGame {
        case match3
        case tsumTsum
        case cooking
    }
    
    // 👇 CHANGE THIS to work on different games
    let currentlyWorking: ActiveGame = .match3
    
    var body: some Scene {
        WindowGroup {
            switch currentlyWorking {
            case .match3:
                Match3ContentView()  // Your current game
                
            case .tsumTsum:
                TsumTsumContentView()  // Physics bubble game
                
            case .cooking:
                CookingContentView()  // Cooking game
            }
        }
    }
}
```

**To work on different games:**
- Change `.match3` to `.tsumTsum`
- Press Command+R (run app)
- Now testing Tsum Tsum game
- Switch back to `.match3` when needed

**Benefits:**
- ✅ Each game built in isolation
- ✅ No interference between games
- ✅ Test each one independently
- ✅ Easy to switch focus

---

#### **Phase 2: Connect with Map Screen (LATER)**

Replace the switcher with map screen:

```swift
import SwiftUI

@main
struct OverQuestMatch3App: App {
    
    // 🗺️ PRODUCTION MODE: Show map screen
    @State private var useMapScreen = true
    
    var body: some Scene {
        WindowGroup {
            if useMapScreen {
                MapScreenView()  // Map launches individual games
            } else {
                Match3ContentView()  // Quick testing bypass
            }
        }
    }
}
```

---

## 🛠️ REORGANIZATION STEPS PROVIDED

### **Step 1: Create Folder Structure**

**In Xcode:**
1. Right-click **OverQuestMatch3** folder
2. Select **"New Group"**
3. Create these folders:
   - `Match3Game`
   - `Shared`
   - `TsumTsumGame` (empty for now)
   - `CookingGame` (empty for now)
   - `Navigation` (empty for now)

---

### **Step 2: Move Files Into Match3Game Folder**

**Drag these INTO "Match3Game" folder:**
- GameViewModel.swift
- BattleManager.swift
- BoardManager.swift
- GameBoardView.swift
- BattleSceneView.swift
- TileType.swift
- PauseMenuView.swift
- GameOverView.swift
- (Any other Match-3 specific files)

**Move to "Shared" folder:**
- Character.swift
- GameAssets.swift
- BattleMechanicsConfig.swift

---

### **Step 3: Rename ContentView.swift**

**Current:** `ContentView.swift`  
**New:** `Match3ContentView.swift`

**How to rename:**
1. Click file in Xcode
2. Press Enter (name becomes editable)
3. Type: `Match3ContentView.swift`
4. Press Enter

**Inside the file, change:**
```swift
// OLD:
struct ContentView: View {

// NEW:
struct Match3ContentView: View {
```

**Move it into "Match3Game" folder**

---

### **Step 4: Update OverQuestMatch3App.swift**

**Replace contents with:**

```swift
import SwiftUI

@main
struct OverQuestMatch3App: App {
    
    // 🎮 DEVELOPMENT MODE: Switch which game you're working on
    enum ActiveGame {
        case match3
        case tsumTsum
        case cooking
    }
    
    // 👇 CHANGE THIS to work on different games during development
    let currentlyWorking: ActiveGame = .match3
    
    var body: some Scene {
        WindowGroup {
            switch currentlyWorking {
            case .match3:
                Match3ContentView()  // Your Match-3 battle game
                
            case .tsumTsum:
                // TsumTsumContentView()  // Uncomment when you build this
                Text("Tsum Tsum Game - Coming Soon")
                    .font(.largeTitle)
                
            case .cooking:
                // CookingContentView()  // Uncomment when you build this
                Text("Cooking Game - Coming Soon")
                    .font(.largeTitle)
            }
        }
    }
}
```

**Test:** Press Command+R - Match-3 game should work perfectly!

---

### **Step 5: Test the Switcher**

1. Change `currentlyWorking = .match3` to `.tsumTsum`
2. Press Command+R
3. Should see "Tsum Tsum Game - Coming Soon"
4. Change back to `.match3`
5. Press Command+R
6. Match-3 works again

**This proves the system works!**

---

## 🎯 WORKFLOW GOING FORWARD

### **When Adding Tsum Tsum Game:**
1. Create `TsumTsumContentView.swift` in `TsumTsumGame/` folder
2. Build the entire game inside that folder
3. Switch to `currentlyWorking = .tsumTsum` to test it
4. Switch back to `.match3` when working on that

### **When Adding Cooking Game:**
1. Create `CookingContentView.swift` in `CookingGame/` folder
2. Build it independently
3. Test by switching to `currentlyWorking = .cooking`

### **When Ready to Connect Everything:**
1. Create `MapScreenView.swift` in `Navigation/` folder
2. Build map UI with level nodes
3. Change `OverQuestMatch3App.swift` to show map
4. Map launches each game type

---

## 📊 BENEFITS OF THIS APPROACH

### ✅ **Advantages:**
1. **Focus on one game at a time** - no interference
2. **All in one project** - no scary merge later
3. **Easy to link later** - just build a map screen
4. **Test each game independently** - simple switch
5. **Shared code stays shared** - `Character.swift` used by all
6. **Navigation is clean** - one system handles everything
7. **Testing is easy** - run app, click level, play game
8. **Progress sharing is simple** - one `ProgressManager` for all

### ❌ **What to Avoid:**
1. **Don't build in separate Xcode projects** - merging is nightmare
2. **Don't tightly couple games yet** - keep them independent
3. **Don't build map screen first** - build games first, wire later

---

## 🎮 FUTURE IMPLEMENTATION DETAILS

### **Campaign System for Match-3 (Not Started Yet)**

**Level Data Structure:**
```swift
struct GameLevel {
    let id: Int
    let name: String
    let enemyName: String           // "Toad King", "Fire Demon", etc.
    let enemyHealth: Int
    let enemyDamage: Int
    let hasPoisonPill: Bool
    let boardSize: Int
    let specialMechanic: String?
}
```

**Example Levels:**
- Level 1: Ramp vs Toad King (50 HP, easy)
- Level 2: Ramp vs Toad King (100 HP, medium)
- Level 3: Ramp vs Fire Demon (80 HP, new enemy)
- Level 4: Ramp vs Toad King (150 HP, hard, poison pill)
- Level 5: Different character vs new enemy

---

### **Map Screen Navigation (Not Started Yet)**

**Example Navigation Flow:**
```swift
// MapScreenView.swift (TO BE CREATED)
struct MapScreenView: View {
    @State private var selectedGame: GameType? = nil
    
    var body: some View {
        ZStack {
            // Map background with level nodes
            
            if let game = selectedGame {
                // Show the selected game
                switch game {
                case .match3(let levelID):
                    Match3ContentView(levelID: levelID)
                case .tsumTsum(let levelID):
                    TsumTsumContentView(levelID: levelID)
                case .cooking(let levelID):
                    CookingContentView(levelID: levelID)
                }
            } else {
                // Show level selection buttons
                LevelNodeView(...)
            }
        }
    }
}
```

---

### **Progress Sharing System (Not Designed Yet)**

**Possible Implementation:**
```swift
// ProgressManager.swift (TO BE CREATED)
@Observable
class ProgressManager {
    var completedLevels: Set<String> = []
    var currency: Int = 0
    var characterStats: CharacterStats
    
    func completeLevel(_ levelID: String, gameType: GameType) {
        completedLevels.insert(levelID)
        currency += 50  // Award gold
        unlockNextLevel(after: levelID)
    }
    
    func unlockNextLevel(after levelID: String) {
        // Logic to determine what unlocks
    }
}
```

---

## ❓ OUTSTANDING QUESTIONS (User Needs to Answer)

### **Critical Design Decisions:**

1. **Map Screen Style:**
   - Royal Match (scrolling path)?
   - Overworld map (Super Mario World)?
   - Chapter menu?
   - Other?

2. **Level Unlock Logic:**
   - Linear progression?
   - Branching paths?
   - Star-based unlocking?

3. **Replay Levels:**
   - Yes (for grinding/practice)?
   - No (one-and-done)?

4. **Tsum Tsum Project:**
   - Language/framework?
   - How complete?
   - Copy files or rebuild?

5. **Cooking Game Type:**
   - Card-based (Miracle Merchant)?
   - Real-time (Overcooked/Stackland)?
   - Hybrid?

6. **Progress Sharing:**
   - Shared currency?
   - Shared character stats?
   - Separate progression?
   - Story-only connection?

---

## 📝 NEXT STEPS

### **User Said:**
> "i'm not going to do this now, but provide a complete transcript of this chat"

**This means:**
- User is **not ready to implement yet**
- They want to save this planning for later
- They'll return to this conversation in a future session

### **When User Returns:**

**They should:**
1. Share this transcript file with the AI
2. Answer the outstanding questions above
3. Decide which game to build first (or reorganize Match-3)
4. AI will provide step-by-step implementation code

**Recommended Order:**
1. ✅ Reorganize current Match-3 game into folders (Steps 1-5 above)
2. ✅ Test that Match-3 still works after reorganization
3. ✅ Build Tsum Tsum game in `TsumTsumGame/` folder
4. ✅ Build Cooking game in `CookingGame/` folder
5. ✅ Create Map Screen in `Navigation/` folder
6. ✅ Wire all games to launch from map
7. ✅ Add campaign system to Match-3
8. ✅ Implement progress sharing (if desired)

---

## 🔧 TECHNICAL NOTES

### **Current Project State:**
- **Platform:** iOS (SwiftUI)
- **Architecture:** @Observable pattern, async/await
- **Current Game:** Match-3 RPG battle (fully functional)
- **Files:** ~20+ Swift files, all currently in root folder
- **Assets:** Character portraits, gem images, UI elements
- **No Navigation:** Single-screen app (battle view only)
- **No Campaign:** One endless battle scenario

### **After Reorganization:**
- **Structure:** Folder-based modules
- **Navigation:** Dev switcher → Map screen later
- **Games:** Self-contained, independently testable
- **Shared:** Common code in `Shared/` folder
- **Scalable:** Easy to add new game types

---

## 📚 REFERENCE MATERIALS

### **Games Mentioned as Inspiration:**

**Match-3 Campaign:**
- Royal Match (level progression, map screen)

**Tsum Tsum Game:**
- Disney Tsum Tsum (falling bubble physics, chain matching)

**Cooking/Merchant Game:**
- Miracle Merchant (card-based merchant puzzle)
- Culinarium (cooking resource management)
- Stackland (card-based resource management)
- Overcooked (real-time cooking chaos)

### **Previous Chat Summary:**
- File: `CHAT_SUMMARY_Campaign_And_MultiGame.md`
- Date: March 25, 2026
- Topic: Initial discussion about campaign system and multi-game design

---

## ✅ SUMMARY

**What Was Decided:**
- ✅ Build all games in ONE Xcode project
- ✅ Use folder-based separation
- ✅ Dev switcher for testing individual games
- ✅ Map screen connects them later
- ✅ Story-driven progression unlocks game types

**What Was NOT Decided Yet:**
- ❌ Map screen visual style
- ❌ Level unlock logic
- ❌ Progress sharing mechanics
- ❌ Cooking game type (card vs real-time)
- ❌ How to handle Tsum Tsum project

**What's Ready to Build:**
- ✅ Project reorganization steps (Steps 1-5)
- ✅ Dev switcher code (provided)
- ✅ Folder structure (designed)

**What Needs Design First:**
- ⏸️ Map screen UI/UX
- ⏸️ Campaign level data
- ⏸️ Progress/unlock system
- ⏸️ Cooking game mechanics
- ⏸️ Tsum Tsum integration plan

---

## 🎯 STATUS: PLANNING COMPLETE, AWAITING IMPLEMENTATION

**User has all the information needed to:**
1. Reorganize their current project
2. Build new game types independently
3. Connect everything with a map screen later

**When user returns, they should:**
1. Share this transcript
2. Answer outstanding questions
3. Choose what to build first
4. Request step-by-step implementation code

---

**END OF TRANSCRIPT**

---

**File Created:** March 25, 2026  
**Session Type:** Planning & Architecture Discussion  
**Code Changes Made:** None (planning only)  
**Next Session:** Implementation (TBD)
