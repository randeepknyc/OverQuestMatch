# Blocking vs Non-Blocking Enemy Turns
**OverQuestMatch3 - Technical Explanation**

---

## 🎯 OVERVIEW

This document explains the difference between **blocking** and **non-blocking** enemy turns in OverQuestMatch3, and how the `asyncEnemyTurn` setting affects gameplay responsiveness.

---

## 📖 WHAT IS BLOCKING vs NON-BLOCKING?

### **Blocking (Traditional Turn-Based)**
- Player makes a match
- Game WAITS for enemy turn to FULLY complete
- Board locks until enemy attack animation finishes
- Player can THEN make next move
- **Total wait time**: ~500-800ms per match

### **Non-Blocking (Async/Background)**
- Player makes a match
- Enemy turn starts in BACKGROUND
- Board unlocks IMMEDIATELY
- Player can make next move while enemy is still attacking
- **Total wait time**: Nearly instant board unlock

---

## ⚙️ HOW TO TOGGLE

Open **GameViewModel.swift** and find this line (around line 37):

```swift
var asyncEnemyTurn: Bool = true  // ⚡ Non-blocking (default)
```

**To enable blocking (original behavior):**
```swift
var asyncEnemyTurn: Bool = false  // 🐢 Blocking mode
```

---

## 🔄 CODE COMPARISON

### **Blocking Mode** (`asyncEnemyTurn = false`)
```swift
// 3. Enemy turn
await enemyTurn()  // WAIT for enemy turn to complete
// Board still locked during this entire time ⏳

isProcessing = false  // Board unlocks AFTER enemy turn
```

**Timeline:**
1. Player swaps gems (400ms)
2. Process cascades (~1000ms)
3. **WAIT for enemy turn** (500ms) ⏸️
4. Board unlocks ✅

**Total**: ~1900ms before next match

---

### **Non-Blocking Mode** (`asyncEnemyTurn = true`)
```swift
// 3. Enemy turn
Task {
    await enemyTurn()  // Run in BACKGROUND
}
// Board unlocks immediately! 🚀

isProcessing = false  // Board unlocks NOW
```

**Timeline:**
1. Player swaps gems (400ms)
2. Process cascades (~1000ms)
3. Board unlocks ✅ (enemy attacks in background)

**Total**: ~1400ms before next match

**Time saved**: ~500ms per match!

---

## 🎨 VISUAL FEEDBACK

### **Problem with Async Mode**
When enemy attacks happen in the background, there's a risk that visual states (like `ramp_hurt.png`) get overwritten by new player actions.

**Solution (Session 11 Fix):**
```swift
@MainActor
private func enemyTurn() async {
    // ⚠️ FORCE OVERRIDE: Enemy attack ALWAYS interrupts any state
    battleManager.player.currentState = .hurt  // ALWAYS SET (no protection)
    
    // Visual effects
    isEnemyAttacking = true
    flashPlayer = true
    battleManager.enemyTurn()  // Apply damage
    
    try? await Task.sleep(for: .milliseconds(350))
    isEnemyAttacking = false
    flashPlayer = false
    
    try? await Task.sleep(for: .milliseconds(150))
    
    // ⚠️ SAFE IDLE RETURN: Only if still in .hurt state
    if battleManager.player.currentState == .hurt {
        battleManager.player.currentState = .idle
    }
    // If player made a new match, don't override their .attack state
}
```

**What This Does:**
- Enemy turn FORCES Ramp to `.hurt` state immediately
- Even if player makes a new match, they briefly see `ramp_hurt.png`
- After hurt animation, only returns to idle if Ramp is STILL hurt
- Protects new player actions from being overwritten

---

## 🎮 GAMEPLAY IMPACT

### **Blocking Mode**
**Pros:**
- ✅ All animations play in sequence
- ✅ Clear turn-based structure
- ✅ No visual conflicts
- ✅ Easy to understand for players

**Cons:**
- ⏸️ Slower gameplay (waiting between matches)
- ⏸️ Board feels "locked" more often
- ⏸️ Less responsive to player input

---

### **Non-Blocking Mode**
**Pros:**
- ✅ Faster gameplay (~30% quicker)
- ✅ Board feels more responsive
- ✅ Can chain matches rapidly
- ✅ More engaging for skilled players

**Cons:**
- ⚠️ Animations may overlap
- ⚠️ Requires state protection logic
- ⚠️ Slightly more complex code

---

## 🧪 TESTING BOTH MODES

### **Test Blocking Mode:**
1. Set `asyncEnemyTurn = false` in GameViewModel.swift
2. Run the game
3. Make several matches quickly
4. Notice: Board locks after each match until enemy finishes attacking

### **Test Non-Blocking Mode:**
1. Set `asyncEnemyTurn = true` in GameViewModel.swift
2. Run the game
3. Make several matches quickly
4. Notice: You can start selecting next match immediately

---

## 🔧 RELATED SETTINGS

These settings work together with `asyncEnemyTurn`:

### **skipWaitingPauses**
```swift
var skipWaitingPauses: Bool = true  // Skip artificial delays
```
- When `true`: Skips extra pauses between animations
- When `false`: Uses original timing with all pauses
- **Recommendation**: Use `true` with async mode for maximum responsiveness

### **autoChainSpeedMultiplier**
```swift
var autoChainSpeedMultiplier: Double = 0.5  // Auto-chain speed
```
- Controls how fast cascade combos (2nd, 3rd match) process
- Works with both blocking and non-blocking modes
- `0.5` = 2x faster auto-chains

---

## 📊 PERFORMANCE COMPARISON

| Metric | Blocking | Non-Blocking | Difference |
|--------|----------|--------------|------------|
| Board lock time | ~1900ms | ~1400ms | **500ms faster** |
| Matches per minute | ~30 | ~42 | **40% more** |
| Visual smoothness | Perfect | Good (with fixes) | Minor |
| Code complexity | Simple | Medium | State protection needed |

---

## 🎯 RECOMMENDED SETUP

**For responsive gameplay:**
```swift
var skipWaitingPauses: Bool = true
var asyncEnemyTurn: Bool = true
var autoChainSpeedMultiplier: Double = 0.5
```

**For traditional gameplay:**
```swift
var skipWaitingPauses: Bool = false
var asyncEnemyTurn: Bool = false
var autoChainSpeedMultiplier: Double = 1.0
```

---

## 🐛 TROUBLESHOOTING

### **Problem: Ramp hurt image not showing**
**Cause**: Enemy turn setting Ramp to `.hurt` but getting overwritten by new player action  
**Solution**: Use Session 11's force override fix (already implemented)

### **Problem: Animations feel janky**
**Cause**: Overlapping animations from async mode  
**Solution**: Try blocking mode (`asyncEnemyTurn = false`) or adjust speed multipliers

### **Problem: Game feels too fast**
**Cause**: All speed settings maxed out  
**Solution**: Increase `autoChainSpeedMultiplier` to 0.7 or 1.0

### **Problem: Game feels too slow**
**Cause**: Blocking mode + no skip pauses  
**Solution**: Enable `asyncEnemyTurn = true` and `skipWaitingPauses = true`

---

## 📝 TECHNICAL NOTES

### **Why Use Task { } for Async Mode?**
```swift
Task {
    await enemyTurn()
}
```
This creates a **detached background task** that runs independently of the main function flow. The parent function continues immediately without waiting for the Task to complete.

### **State Protection Strategy**
1. **Force Override**: Enemy turn ALWAYS sets `.hurt` (ignores current state)
2. **Safe Return**: Only returns to `.idle` if player is STILL in `.hurt`
3. **Protection in BattleManager**: New matches check if player is `.hurt` or `.hurt2` before changing state

### **Animation Timing**
- Hurt state shows for minimum 350ms
- Transition to idle takes 150ms
- Total hurt display: ~500ms
- Even with async mode, player sees hurt animation briefly

---

## 🎓 LEARNING RESOURCES

**Understanding Swift Concurrency:**
- `async/await`: Functions that can pause execution
- `Task { }`: Run code in background
- `@MainActor`: Ensure UI updates on main thread

**Key Concept:**
```swift
// Blocking
await doSomething()  // Wait here until done
nextStep()          // Runs AFTER doSomething finishes

// Non-blocking
Task { await doSomething() }  // Run in background
nextStep()                   // Runs IMMEDIATELY
```

---

**Created**: Session 11 (March 20, 2026)  
**Author**: AI Assistant  
**Purpose**: Explain async enemy turn system to future developers
