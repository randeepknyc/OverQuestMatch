# Chat Summary: Campaign System & Multi-Game Design Discussion

**Date:** March 25, 2026

---

## 📋 User's Questions

The user asked two main questions about expanding their match-3 game:

### Question 1: Multiple Levels with Same Character
- Can they add multiple levels with the same character?
- What would they be and how would it work?

### Question 2: Multiple Game Types
- Can they create a second and third type of game within the same game?
- Specifically:
  - **a)** A physics-based chain matching game
  - **b)** A solitaire style/tavern resource game

---

## 🎯 Clarifying Questions Asked

### For Question 1:
1. Do you currently have any level/stage system, or is it just one battle?
2. Multiple battles where Ramp fights different enemies, OR same enemy with different challenges?

### For Question 2:
1. Should these be completely separate games or integrated into progression?
2. Would these use the same character (Ramp) and continue the story?
3. Would they share progress/currency/unlocks with match-3 game?

### General:
- What does your main menu/navigation structure look like currently?

---

## 💬 User's Answers

### Question 1 Response:
- **Not yet implemented**, but they want to add it
- Want **BOTH**:
  - Same enemy (Toad King) with different difficulty levels
  - Different enemies with different levels

### Question 2 Response:
1. **Integrated to unlock** - switch between them on map screen once unlocked
2. **Ramp in some games**, other characters in others, but **same world/story/theme/tone**
3. **Maybe share progress** - unsure what this means and how it works

### Navigation:
- Don't have navigation structure yet
- Thinking about a **map screen**
- Also open to "in-between levels" like Royal Match style

---

## ✅ Answers Provided

### Answer to Question 1: **YES, 100% Possible!**

#### How It Would Work:
- **Level/Stage System** - List of all levels with their settings
- **Campaign/Map Screen** - Shows which levels are unlocked
- **Modified BattleManager** - Accepts level data to configure each battle

#### Example Level Structure:
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

#### Example Levels:
- **Level 1**: Ramp vs Toad King (50 HP, easy)
- **Level 2**: Ramp vs Toad King (100 HP, medium)
- **Level 3**: Ramp vs Fire Demon (80 HP, new enemy)
- **Level 4**: Ramp vs Toad King (150 HP, hard, poison pill)
- **Level 5**: Different character vs new enemy

**Key Point:** Same character can appear in many levels, same enemy can appear multiple times with different difficulty.

---

### Answer to Question 2: **YES, Possible!**

#### What "Share Progress" Could Mean:
- Beat Match-3 Level 1 → Earn 50 gold coins
- Use 50 gold to unlock Physics Puzzle game
- Beat Physics Puzzle → Earn 30 gold
- Use gold to upgrade Ramp's health
- That upgrade works in BOTH games
- **OR** they could be completely separate

#### How It Would Work:
```
Main Map Screen
├── Match-3 Section (Levels 1-10) ← Current game
├── Physics Puzzle Section (Unlocks at Level 3) ← New game type
└── Solitaire Section (Unlocks at Level 7) ← New game type
```

Each game type would:
- Be its own SwiftUI view
- Use the same characters/art style
- Optionally share currency/progress
- Feel like part of the same world

---

## 🎯 Recommendation Given

**Start with Option A: Campaign/Map System**

Build the campaign/map system for the EXISTING match-3 game first. This gives:

1. ✅ Multiple levels with Ramp vs Toad King (different difficulties)
2. ✅ Ability to add new enemies later
3. ✅ Foundation for adding other game types
4. ✅ Progress tracking (which levels beaten)
5. ✅ Unlock system already working

**Then later**, adding new game types is just "another section on the map."

---

## 🤔 Options Presented to User

### Option A: Start with Map/Campaign System (RECOMMENDED)
- Create a map screen like Royal Match
- Show levels 1, 2, 3, etc.
- Track which levels are unlocked/completed
- Launch battles with different settings per level
- **This is probably the foundation needed first**

### Option B: Start with One New Game Type
- Keep current match-3 as-is
- Add physics puzzle OR solitaire game
- Simple menu to switch between them
- Try out the concept before building full map

### Option C: Just Explain the Architecture
- Describe how it would all fit together
- Show code examples
- User decides what to build first

---

## ❓ Pending User Response

Waiting for user to choose:
- **A)** Create campaign/map system for match-3 levels (recommended)
- **B)** Show example code for how different game types would integrate
- **C)** Something else

Also need to know: **Do they want Royal Match style map** (scrolling vertical path with level circles), or a different style?

---

## 📝 Current Game State

- User has a working match-3 game with battle system
- Character: **Ramp** (player character)
- Enemy: **Toad King**
- Features: Swap/Chain modes, bonus tiles, poison pill, abilities
- NO level progression system yet
- NO navigation/map screen yet
- NO other game types implemented yet

---

## 🎮 Next Steps (Once User Responds)

1. Create campaign system structure
2. Build map screen UI
3. Implement level progression
4. Add level data storage
5. Modify BattleManager to accept level configs
6. (Future) Add new game types as separate sections

---

**Status:** ⏳ Awaiting user's decision on which option to pursue first
