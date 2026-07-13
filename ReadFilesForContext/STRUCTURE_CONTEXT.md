# PROJECT REORGANIZATION TRACKER

**Project:** OverQuestMatch3 Multi-Game Expansion  
**Started:** March 28, 2026  
**Last Updated:** May 3, 2026  
**Status:** 🟢 ACTIVE DEVELOPMENT - Cauldron Game Rewrite Phase 1 Complete

---

## 🎮 GAMES IN PROJECT

### ✅ COMPLETE & PLAYABLE:
1. **Match-3 RPG Battle** - Puzzle combat with character abilities (Match3Game/)
2. **Shop of Oddities** - Card repair solitaire game (ShopOfOddities/)
3. **Physics Chain Game** - Bubble chain matching (PhysicsChainGame/)

### 🟡 IN DEVELOPMENT:
4. **Ednar's Cauldron** - Dice placement combat game (CauldronGame/)
   - **Status:** Phase 1 (Data Layer) COMPLETE ✅
   - **Files:** CauldronGameData.swift created, JSON loaded at app launch
   - **Next:** Phase 2 - Game State Model (see REPLACEMENT_PLAN.md)
   - **Reference:** SESSION_CHECKPOINT.md, REPLACEMENT_PLAN.md, EdnarsCauldron_Reference.jsx

### ⏸️ PLANNED:
5. **Cooking Game** (CookingGame/)
6. **Potion Solitaire** (PotionSolitaireGame/)
7. **Map Navigation** (Navigation/)

---

## 📊 CAULDRON GAME REWRITE PROGRESS

**Current Phase:** Phase 1 of 9 ✅ COMPLETE

### Phase 1: Data Layer Setup ✅
- [x] Created CauldronGameData.swift with Codable structs
- [x] JSON loading (traits.json, characters.json, rounds.json)
- [x] Salvaged DieTier and BagDie from existing code
- [x] Debug print confirming load at app launch
- [x] Existing Cauldron game still functional

### Upcoming Phases:
- [ ] Phase 2: Game State Model (CauldronGameState.swift)
- [ ] Phase 3: Replace the views
- [ ] Phase 4: Wire up queue/swap mechanic
- [ ] Phase 5: Cauldron + dice + brewing
- [ ] Phase 6: Animation sequence
- [ ] Phase 7: Round flow + win/lose states
- [ ] Phase 8: Trait effects + polish
- [ ] Phase 9: Art swap-in

**See:** REPLACEMENT_PLAN.md for detailed phase-by-phase instructions

---

## 📊 REORGANIZATION CHECKLIST

### ✅ **COMPLETED STEPS:**
- [x] Step 1: Create folder structure ✅ COMPLETE
- [x] Step 2: Move Match-3 files into Match3Game folder ✅ COMPLETE
- [x] Step 3: Rename ContentView.swift to Match3ContentView.swift ✅ COMPLETE
- [x] Step 4: Update OverQuestMatch3App.swift with dev switcher ✅ COMPLETE
- [ ] Step 5: Test the switcher functionality

### 🎯 **CURRENT STEP:** 
**Step 5** - Testing the switcher functionality

### ⚠️ **NEXT STEP WHEN RESUMING:**
Step 5 (test that the app runs and switcher works)

---

## 📁 CURRENT PROJECT STRUCTURE (AFTER STEPS 1-3)

```
OverQuestMatch3/ (ROOT)
├─ OverQuestMatch3App.swift (TO BE UPDATED in Step 4)
├─ Match3Game/ ✅ NEW
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
├─ Shared/ ✅ NEW
│  ├─ Character.swift
│  ├─ GameAssets.swift
│  ├─ BattleMechanicsConfig.swift
│  ├─ CharacterAnimations-Shared.swift
│  └─ HapticManager.swift
├─ PhysicsChainGame/ ✅ NEW (empty)
├─ ShopOfOddities/ ✅ NEW (card repair game - data models complete)
├─ CookingGame/ ✅ NEW (empty)
├─ PotionSolitaireGame/ ✅ NEW (empty)
├─ Navigation/ ✅ NEW (empty)
├─ Logic/ (existing folder - now mostly empty)
├─ ViewModels/ (existing folder - now mostly empty)
├─ Views/ (existing folder - some files remain)
├─ Utilities/ (existing folder - unchanged)
├─ Models/ (existing folder - now mostly empty)
└─ ReadFilesForContext/ (context docs - unchanged)
```

---

## 🎯 TARGET PROJECT STRUCTURE (AFTER REORGANIZATION)

```
OverQuestMatch3/
├─ OverQuestMatch3App.swift (UPDATED with dev switcher)
├─ Shared/ (NEW - code ALL games use)
│  ├─ Character.swift
│  ├─ GameAssets.swift
│  └─ BattleMechanicsConfig.swift
├─ Match3Game/ (NEW - all Match-3 specific files)
│  ├─ Match3ContentView.swift (RENAMED from ContentView.swift)
│  ├─ GameViewModel.swift
│  ├─ BattleManager.swift
│  ├─ BoardManager.swift
│  ├─ GameBoardView.swift
│  ├─ BattleSceneView.swift
│  ├─ TileType.swift
│  ├─ PauseMenuView.swift
│  └─ GameOverView.swift
├─ PhysicsChainGame/ (NEW - empty for now)
├─ ShopOfOddities/ (NEW - card repair game)
├─ CookingGame/ (NEW - empty for now)
├─ PotionSolitaireGame/ (NEW - empty for now)
├─ Navigation/ (NEW - empty for now)
├─ Logic/ (existing folder - some files may move)
├─ ViewModels/ (existing folder - some files may move)
├─ Views/ (existing folder - some files may move)
├─ Utilities/ (existing folder - stays as-is)
├─ Models/ (existing folder - some files may move)
└─ ReadFilesForContext/ (existing folder - stays as-is)
```

---

## 📝 DETAILED STEPS & STATUS

### **STEP 1: Create Folder Structure** 
**Status:** ✅ COMPLETE
**Action:** Create 6 new groups (folders) in Xcode

**Folders created:**
1. ✅ `Match3Game` - Contains all Match-3 battle game files
2. ✅ `Shared` - Contains code used by ALL game types
3. ✅ `PhysicsChainGame` - Empty (for future physics bubble chain game)
4. ✅ `CookingGame` - Empty (for future cooking game)
5. ✅ `PotionSolitaireGame` - Empty (for future potion solitaire game)
6. ✅ `Navigation` - Empty (for future map/progression system)

**Result:** All folders created successfully!

---

### **STEP 2: Move Match-3 Files**
**Status:** ✅ COMPLETE
**Action:** Drag files into Match3Game and Shared folders

**Files moved INTO Match3Game/:**
- ✅ GameViewModel.swift
- ✅ BattleManager.swift
- ✅ BoardManager.swift
- ✅ GameBoardView.swift
- ✅ BattleSceneView.swift
- ✅ TileType.swift
- ✅ GameOverView.swift
- ✅ GameHUDview.swift
- ✅ DebugMenuView.swift
- ✅ PoisonPillScreenEffect.swift
- ✅ BonusBlastEffects.swift
- ✅ GameMode.swift
- ✅ BattleEvent.swift
- ✅ BonusTileConfig.swift
- ✅ ChainComboEffects.swift
- ✅ ChainInputHandler2.swift
- ✅ Ability.swift
- ✅ ChainVisualConfig.swift

**Files moved INTO Shared/:**
- ✅ Character.swift
- ✅ GameAssets.swift
- ✅ BattleMechanicsConfig.swift
- ✅ CharacterAnimations.swift (renamed to CharacterAnimations-Shared.swift)
- ✅ HapticManager.swift

**Result:** All Match-3 files successfully organized!

---

### **STEP 3: Rename ContentView.swift**
**Status:** ✅ COMPLETE
**Action:** Rename file and struct name

**Changes completed:**
1. ✅ Renamed file: `ContentView.swift` → `Match3ContentView.swift`
2. ✅ Updated struct name: `struct Match3ContentView: View`
3. ✅ Updated Preview: `#Preview { Match3ContentView() }`
4. ✅ Moved file into `Match3Game/` folder

**Result:** Main game view successfully renamed and organized!

---

### **STEP 4: Update OverQuestMatch3App.swift**
**Status:** ✅ COMPLETE
**Action:** Replace contents with dev switcher

**File:** `OverQuestMatch3App.swift`

**Changes completed:**
1. ✅ Added `GameType` enum with 5 game options
2. ✅ Added `currentGame` switcher variable (set to `.match3`)
3. ✅ Created switch statement to handle different game types
4. ✅ Updated to use `Match3ContentView()` instead of `ContentView()`
5. ✅ Added `PlaceholderView` for future games

**Result:** ✅ Dev switcher successfully implemented! Can now easily switch between game types.

---

### **STEP 5: Test Switcher**
**Status:** ⏸️ NOT STARTED  
**Action:** Verify everything still works

**Tests:**
1. Run app (Command+R) - Match-3 should work perfectly
2. Change switcher to `.physicsChain` - should see "Coming Soon"
3. Change switcher back to `.match3` - should work again

**Result:** Confirmation that reorganization was successful

---

## ⚠️ KNOWN ISSUES

**None yet** - will be updated if issues arise during reorganization

---

## 🔄 INSTRUCTIONS FOR NEW CHAT SESSIONS

If you're starting a new chat and continuing this reorganization:

1. **Tell the AI:** "Read STRUCTURE_CONTEXT.md to see where we are in the reorganization"
2. **Check:** Look at "CURRENT STEP" section above
3. **Continue:** Start from the step marked "NEXT STEP WHEN RESUMING"
4. **Update this file:** After completing each step, AI should update this file

---

## 📚 REFERENCE FILES

**Planning Document:** `GAME_PLANNING_TAVERN_TSUM_MATCH.md`  
**Project Context:** `AI_CONTEXT.md`  
**Additional Context:** `ReadFilesForContext/` folder

---

## 🎯 WHY WE'RE DOING THIS

**Goal:** Transform single-game project into multi-game project with:
- Match-3 RPG Battle (existing game)
- Physics Chain Game (falling bubble physics with chain matching)
- Shop of Oddities (card-based repair solitaire game)
- Cooking Game (real-time cooking resource management)
- Potion Solitaire Game (card-based potion crafting puzzle)
- Story-driven map connecting all games

**Benefits:**
- Clean separation between game types
- Easy to work on one game at a time
- Simple to test individual games
- Ready for map/navigation system later

---

**Last Updated:** March 28, 2026 - Step 3 Complete (ContentView → Match3ContentView)  
**Last Updated By:** AI Assistant
