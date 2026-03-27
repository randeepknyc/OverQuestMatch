# 🎮 Blocking vs Non-Blocking Enemy Attacks

**Date**: March 19, 2026  
**Purpose**: Detailed explanation of how enemy attack timing works

---

## 📖 Table of Contents

1. [What is Blocking vs Non-Blocking?](#what-is-blocking-vs-non-blocking)
2. [The 400ms Pause](#the-400ms-pause)
3. [How Damage Works](#how-damage-works)
4. [Timeline Comparisons](#timeline-comparisons)
5. [Technical Details](#technical-details)
6. [Which Should You Use?](#which-should-you-use)

---

## 🎯 What is Blocking vs Non-Blocking?

### 🔒 **BLOCKING** (`asyncEnemyTurn = false`)

**Simple Explanation:**
- The game **waits** for the enemy's turn to completely finish
- You **cannot** make your next move until enemy attack is done
- Board stays **locked** during enemy animations

**What "blocking" means:**
- The code execution **stops** and waits
- Like a traffic light: red = stop, wait, green = go
- Enemy turn "blocks" the game from continuing

**User Experience:**
- Clear, separated turns
- Traditional turn-based RPG feel
- More time to think between moves
- Slower paced, methodical gameplay

---

### ⚡ **NON-BLOCKING** (`asyncEnemyTurn = true`)

**Simple Explanation:**
- The enemy's turn runs **in the background**
- You **can** start selecting your next move immediately
- Board **unlocks** right after your cascades finish

**What "non-blocking" means:**
- The code execution **continues** without waiting
- Like multi-tasking: enemy attacks AND you can plan ahead
- Enemy turn doesn't "block" the game flow

**User Experience:**
- Fast, responsive feel
- Modern action-puzzle game feel
- Less perceived waiting
- Snappier, faster-paced gameplay

---

## ⏸️ The 400ms Pause

### **What Was It?**

In the original blocking version, there was a 400ms pause **before** the enemy attacked:

```swift
@MainActor
private func enemyTurn() async {
    try? await Task.sleep(for: .milliseconds(400))  // ← THE PAUSE
    
    // Enemy attacks here
    battleManager.enemyTurn()
}
```

### **Why Did It Exist?**

**Purpose: Dramatic Pause / "Breathing Room"**

1. **Pacing** - Gives you a moment to process what happened
   - "I just attacked the enemy... now it's their turn..."
   - Brief pause for mental transition

2. **Readability** - Prevents information overload
   - Without pause: Attack → Attack → Attack (too fast)
   - With pause: Attack → *pause* → Enemy Attack (clearer)

3. **Anticipation** - Creates tension
   - "My turn is done... what will the enemy do?"
   - Pause builds suspense before enemy strikes

4. **Turn Clarity** - Makes turns feel distinct
   - Your Turn (attack) → **Pause** → Enemy Turn (attack)
   - Feels more like traditional board game turns

### **Game Design Examples**

**Games WITH dramatic pauses:**
- **Pokémon**: "Pikachu used Thunderbolt!" → pause → damage number → pause
- **Final Fantasy**: Each character waits for ATB bar, clear turn separation
- **Chess**: You move → pause while opponent thinks → they move

**Games WITHOUT pauses (fast-paced):**
- **Tetris**: No waiting, pieces keep falling
- **Bejeweled Blitz**: Fast cascades, no pauses
- **Candy Crush** (modern): Faster than older match-3 games

### **In Your Game**

**With `skipWaitingPauses = true` (current):**
- ✅ 400ms pause is **removed**
- ✅ Enemy attacks immediately after player attack
- ✅ Faster gameplay flow

**With `skipWaitingPauses = false` (original):**
- ⏸️ 400ms pause is **kept**
- ⏸️ Brief moment between turns
- ⏸️ More traditional RPG pacing

**It's not a bug - it's a design choice!**
- Not required for the game to function
- Purely for pacing and player experience
- You can remove it for faster gameplay
- Or keep it for clearer turn separation

---

## ⚔️ How Damage Works

### **KEY CONCEPT: Damage is INSTANT, Animations are COSMETIC**

The most important thing to understand:
- **Damage calculation**: Happens immediately in code
- **Damage animation**: Visual effect that plays afterward
- **They are separate!**

---

### **Damage Flow in Non-Blocking Mode**

```
1. Your match completes cascades
   ↓
2. battleManager.processMatches(matches)
   ↓
✅ ENEMY HP REDUCED (damage applied HERE)
   ↓
3. playAttackAnimation() (350ms visual)
   ↓ [Animations are just "showing" what already happened]
   ↓
4. Task { await enemyTurn() } starts in background
   ↓
   battleManager.enemyTurn()
   ↓
✅ PLAYER HP REDUCED (damage applied HERE)
   ↓
   [Enemy attack animation - 350ms]
   
5. Board unlocks (isProcessing = false)
   ↓
🎮 YOU CAN MAKE NEXT MATCH
   ↓
(Enemy animation still playing in background)
```

---

### **Two Places Where Damage Happens**

**1. Player Damage to Enemy** (Line 294 in GameViewModel.swift):
```swift
battleManager.processMatches(matches)  // ← DAMAGE HERE
```

Inside BattleManager, this does something like:
```swift
func processMatches(_ matches: [Match]) {
    for match in matches {
        let damage = calculateDamage(match)
        enemy.takeDamage(damage)  // ← HP reduced INSTANTLY
        // No animation code here!
    }
}
```

**2. Enemy Damage to Player** (Line 357):
```swift
battleManager.enemyTurn()  // ← DAMAGE HERE
```

Inside BattleManager:
```swift
func enemyTurn() {
    let damage = enemy.attackPower
    player.takeDamage(damage)  // ← HP reduced INSTANTLY
    // No animation code here!
}
```

---

### **Animations Are Separate** (Lines 343-348):

```swift
@MainActor
private func playAttackAnimation() async {
    isPlayerAttacking = true  // ← Just a visual flag
    flashEnemy = true         // ← Just a visual flag
    
    // Wait for animation duration (visual only!)
    try? await Task.sleep(for: .milliseconds(350))
    
    isPlayerAttacking = false
    flashEnemy = false
}
```

**This function does NOT deal damage!**
- It just shows a sword swing / flash effect
- The damage was already applied before this runs
- The wait is purely for the animation to look good

---

### **Why This Matters in Non-Blocking**

**Blocking (old way):**
```
Player attacks → Enemy HP drops → Animation plays
    ↓
⏸️ WAIT 400ms
    ↓
Enemy attacks → Player HP drops → Animation plays
    ↓
✅ Board unlocks
```
**You see everything in order, nothing overlaps**

---

**Non-Blocking (new way):**
```
Player attacks → Enemy HP drops → Animation plays
    ↓
✅ Board unlocks IMMEDIATELY
    ↓
(Background: Enemy attacks → Player HP drops → Animation plays)
```
**You can start planning next move while enemy animation plays**

---

### **Health Bars Update Instantly**

**What you'll see:**

1. **Make a match**
2. **Enemy HP bar drops** ← Happens immediately
3. **Your attack animation plays** (visual only)
4. **Board unlocks** ← You can tap/select now
5. **Player HP bar drops** ← Enemy damage already happened
6. **Enemy attack animation plays** (visual only, in background)

**The numbers are always correct!**
- Damage is never "double applied"
- Health is never wrong
- Animations are just "replaying" what already occurred

---

### **Example Timeline**

**You make a match that deals 30 damage:**

```
t=0ms:    Match completes
t=0ms:    Enemy HP: 100 → 70 (damage applied INSTANTLY)
t=0-350ms: Player attack animation plays (visual)
t=350ms:  Board unlocks (non-blocking mode)
t=350ms:  Player HP: 50 → 42 (enemy damage applied INSTANTLY in background)
t=350-700ms: Enemy attack animation plays (visual, in background)
t=700ms:  Everything complete, you can swap gems
```

**In blocking mode, board would unlock at t=1100ms instead!**

---

### **Why Non-Blocking is Safe**

Because damage is calculated instantly:
- ✅ Enemy can't attack twice
- ✅ Health values are always accurate
- ✅ No timing bugs or race conditions
- ✅ Only the **visual presentation** is different

**The only thing that's "async" is the animation, not the damage!**

---

## 📊 Timeline Comparisons

### **BLOCKING Version** (`asyncEnemyTurn = false`)

```
YOUR MATCH COMPLETES
    ↓
    ↓ Gems disappear (200ms animation)
    ↓
    ↓ Gems fall (300ms animation)
    ↓
    ↓ New gems spawn (390ms animation)
    ↓
    ↓ Auto-cascades (if any - locked)
    ↓
[DAMAGE APPLIED] → Enemy HP drops
    ↓
    ↓ Player attack animation (350ms)
    ↓
⏸️  PAUSE (400ms) ← "Dramatic pause"
    ↓
[DAMAGE APPLIED] → Player HP drops
    ↓
    ↓ Enemy attack animation (350ms)
    ↓
✅ BOARD UNLOCKS
    ↓
YOU CAN MAKE NEXT MATCH

Total time: ~2700ms
```

---

### **NON-BLOCKING Version** (`asyncEnemyTurn = true`)

```
YOUR MATCH COMPLETES
    ↓
    ↓ Gems disappear (200ms animation)
    ↓
    ↓ Gems fall (300ms animation)
    ↓
    ↓ New gems spawn (390ms animation)
    ↓
    ↓ Auto-cascades (if any - locked)
    ↓
[DAMAGE APPLIED] → Enemy HP drops
    ↓
    ↓ Player attack animation (350ms)
    ↓
✅ BOARD UNLOCKS ← ~1200ms after match!
    ↓
YOU CAN SELECT NEXT MATCH
    ↓
[Background: Enemy damage applied → Player HP drops]
    ↓
[Background: Enemy attack animation plays (350ms)]

Total time to unlock: ~1200ms (60% faster!)
```

---

### **Side-by-Side Event Comparison**

| Event | Blocking | Non-Blocking | Difference |
|-------|----------|--------------|------------|
| Match completes | t=0ms | t=0ms | Same |
| Disappear animation | 200ms | 200ms | Same |
| Fall animation | 300ms | 300ms | Same |
| Spawn animation | 390ms | 390ms | Same |
| Player damage applied | t=890ms | t=890ms | Same |
| Player attack visual | 350ms | 350ms | Same |
| **Pre-enemy pause** | 400ms | **0ms** | **Removed** |
| Enemy damage applied | t=1640ms | t=1240ms | **400ms sooner** |
| Enemy attack visual | 350ms | 350ms (background) | **Non-blocking** |
| **Board unlocks** | **t=1990ms** | **t=1240ms** | **750ms faster** |

---

## 🔧 Technical Details

### **Code Differences**

**BLOCKING (original):**
```swift
// 3. Enemy turn
await enemyTurn()  // ← Code STOPS here and waits

isProcessing = false  // ← Only runs AFTER enemy turn completes
```

**NON-BLOCKING (new):**
```swift
// 3. Enemy turn
if asyncEnemyTurn {
    Task {
        await enemyTurn()  // ← Runs in background
    }
    // Code continues immediately!
} else {
    await enemyTurn()  // Original blocking behavior
}

isProcessing = false  // ← Runs RIGHT AWAY in async mode
```

---

### **What `Task { }` Does**

```swift
Task {
    await enemyTurn()  // Code inside runs independently
}
// Code here runs IMMEDIATELY, doesn't wait for Task to finish
```

**Think of it like:**
- **Blocking**: "Do A, then wait for B to finish, then do C"
- **Non-Blocking**: "Do A, start B in background, do C immediately"

---

### **The `await` Keyword**

**With `await` directly:**
```swift
await enemyTurn()
print("This prints AFTER enemy turn completes")
```

**With `await` inside Task:**
```swift
Task {
    await enemyTurn()
    print("This prints after enemy turn (in background)")
}
print("This prints IMMEDIATELY, doesn't wait!")
```

---

### **All Waiting Pauses Controlled**

The `skipWaitingPauses` flag removes these waits:

| Pause | Original | With Flag | Location (Line) |
|-------|----------|-----------|-----------------|
| Pre-buzz pause | 150ms | 0ms | 216 |
| Disappear wait | 300ms | 200ms | 233 |
| Explosion cleanup | 100ms | 0ms | 239 |
| Fall wait | 500ms | 300ms | 263 |
| Spawn wait | ~560ms | ~390ms | 276 |
| Power Surge | 1600ms | 0ms | 292-295 |
| Cascade check | 100ms | 0ms | 319 |
| Pre-enemy pause | 400ms | 0ms | 353 |

**Total saved: ~1500ms per match cycle!**

---

## 🎮 Which Should You Use?

### **Use BLOCKING if you want:**

✅ **Clear turn separation**
- "My turn" → pause → "Enemy's turn"
- Traditional RPG feel

✅ **More time to think**
- Natural pauses give you planning time
- Less rushed gameplay

✅ **Beginner-friendly**
- Easier to follow what's happening
- Less overwhelming

✅ **Story/narrative focus**
- Time to read battle messages
- Dramatic pacing

**Recommended for:**
- Story-driven gameplay
- Casual players
- Turn-based RPG fans
- Players who like to read battle text

---

### **Use NON-BLOCKING if you want:**

✅ **Fast, snappy gameplay**
- Minimal waiting between moves
- Action-oriented feel

✅ **Competitive play**
- Every millisecond counts
- Faster match completion

✅ **Modern puzzle game feel**
- Like Bejeweled Blitz, Puzzle & Dragons
- Quick match-make-match flow

✅ **High skill ceiling**
- Plan next move during enemy attack
- Rewards quick thinking

**Recommended for:**
- Action-puzzle fans
- Skilled/experienced players
- Speed-run gameplay
- Competitive modes

---

### **Hybrid Approach**

You can mix the settings:

**Fast with pauses:**
```swift
var skipWaitingPauses: Bool = false  // Keep dramatic pauses
var asyncEnemyTurn: Bool = true      // But don't block board
```
→ Keeps pacing, but board unlocks during enemy animation

**Slow but reactive:**
```swift
var skipWaitingPauses: Bool = true   // Remove pauses
var asyncEnemyTurn: Bool = false     // But wait for enemy turn
```
→ Faster animations, but traditional turn blocking

---

### **Recommended Presets**

**Casual Mode:**
```swift
var skipWaitingPauses: Bool = false
var asyncEnemyTurn: Bool = false
```
→ Full pauses, clear turns, traditional

**Balanced Mode:**
```swift
var skipWaitingPauses: Bool = true
var asyncEnemyTurn: Bool = false
```
→ Faster flow, but wait for enemy

**Competitive Mode (Current):**
```swift
var skipWaitingPauses: Bool = true
var asyncEnemyTurn: Bool = true
```
→ Maximum speed, minimum waiting

---

## 📝 Summary

### **Key Takeaways**

1. **Blocking** = Wait for enemy turn, slower, clearer
2. **Non-blocking** = Enemy runs in background, faster, modern
3. **Damage is instant** = Animations are just cosmetic
4. **400ms pause** = Design choice for pacing, not required
5. **Easy to toggle** = Two simple bools in GameViewModel.swift

### **How to Change**

Open `GameViewModel.swift`, lines 32 & 37:

```swift
// Line 32: Skip waiting pauses?
var skipWaitingPauses: Bool = true  // or false

// Line 37: Async enemy attacks?
var asyncEnemyTurn: Bool = true     // or false
```

Press **Command+S** to save, **Command+R** to test!

---

**Last Updated**: March 19, 2026  
**Version**: 1.0  
**Status**: ✅ Complete reference guide
