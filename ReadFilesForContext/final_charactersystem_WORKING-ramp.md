# ✅ FINAL CHARACTER PORTRAIT SYSTEM - WORKING PERFECTLY

**Date**: March 21, 2026  
**Status**: 100% WORKING - All portrait states change correctly and return to idle  
**System**: Direct state management with forced SwiftUI updates

---

## 🎯 WHAT WORKS

✅ Ramp portrait changes to `.attack` when matching gems  
✅ Ramp portrait changes to `.hurt` when enemy attacks  
✅ Ramp portrait changes to `.hurt2` when invalid swap  
✅ Ramp portrait changes to `.defend` when matching shields/hearts  
✅ Ramp portrait changes to `.spell` when using abilities  
✅ All states automatically return to `.idle` (line boil animation)  
✅ Works with async enemy turns (non-blocking gameplay)  
✅ No stuck portraits, no missing updates  

---

## 🏗️ ARCHITECTURE - HOW IT WORKS

### **3-Part System**:

1. **Character.swift** - State tracking with forced updates
2. **CharacterAnimations.swift** - View rendering with `.id()` modifier
3. **BattleManager.swift + GameViewModel.swift** - State changes with auto-return to idle

---

## 📝 COMPLETE CODE

### 1️⃣ **Character.swift** (State Tracking)

```swift
import Foundation
import SwiftUI

@Observable
class Character {
    var name: String
    var imageName: String
    var maxHealth: Int
    var currentHealth: Int
    var shield: Int = 0
    
    // ═══════════════════════════════════════════════════════════════
    // 🎨 CHARACTER STATE SYSTEM
    // ═══════════════════════════════════════════════════════════════
    var currentState: CharacterState = .idle {
        didSet {
            // Force SwiftUI to notice the change
            stateChangeID = UUID()
        }
    }
    
    // Helper property that changes every time state changes (forces SwiftUI updates)
    var stateChangeID: UUID = UUID()
    // ═══════════════════════════════════════════════════════════════
    
    var healthPercentage: Double {
        return Double(currentHealth) / Double(maxHealth)
    }
    
    var isAlive: Bool {
        return currentHealth > 0
    }
    
    init(name: String, imageName: String, maxHealth: Int, currentHealth: Int) {
        self.name = name
        self.imageName = imageName
        self.maxHealth = maxHealth
        self.currentHealth = currentHealth
    }
    
    func takeDamage(_ amount: Int) {
        let damageAfterShield = max(0, amount - shield)
        shield = max(0, shield - amount)
        currentHealth = max(0, currentHealth - damageAfterShield)
    }
    
    func heal(_ amount: Int) {
        currentHealth = min(maxHealth, currentHealth + amount)
    }
    
    func addShield(_ amount: Int) {
        shield += amount
    }
}

// ═══════════════════════════════════════════════════════════════
// 🎨 CHARACTER STATE ENUM
// ═══════════════════════════════════════════════════════════════
enum CharacterState {
    case idle       // Normal standing
    case attack     // Attacking
    case hurt       // Taking damage from enemy
    case hurt2      // Taking damage from mistake (invalid swap)
    case defend     // Blocking/shielding
    case spell      // Casting ability
    case victory    // Won the battle
    case defeat     // Lost the battle
    
    // Helper to get the image name based on character and state
    func imageName(for characterName: String) -> String {
        // Ramp has full dynamic portraits
        if characterName == "Ramp" {
            switch self {
            case .idle:
                return "ramp_idle"
            case .attack:
                return "ramp_attack"
            case .hurt:
                return "ramp_hurt"       // Enemy attack damage
            case .hurt2:
                return "ramp_hurt2"      // Invalid swap penalty
            case .defend:
                return "ramp_defend"
            case .spell:
                return "ramp_spell"
            case .victory:
                return "ramp_victory"
            case .defeat:
                return "ramp_defeat"
            }
        }
        
        // Ednar uses same image for all states (for now)
        else if characterName == "Ednar" || characterName == "Toad King" {
            return "ednar_idle"  // Uses ednar_idle for ALL states
        }
        
        // Fallback for any other character
        else {
            return GameAssets.toadImage
        }
    }
}
```

**KEY POINTS:**
- `@Observable` macro makes Character reactive to SwiftUI
- `currentState` has `didSet` that updates `stateChangeID`
- Every state change creates new UUID → forces SwiftUI to notice
- `CharacterState` enum maps states to image names

---

### 2️⃣ **CharacterAnimations.swift** (View Rendering)

```swift
import SwiftUI
import Combine

struct StateBasedCharacterPortrait: View {
    @Bindable var character: Character
    
    var body: some View {
        let displayState = character.currentState
        
        Group {
            // Ramp uses line boil animations (expandable to all states)
            if character.name == "Ramp" {
                RampAnimatedPortrait(state: displayState)
            }
            // Ednar uses static images for all states (for now)
            else if character.name == "Ednar" || character.name == "Toad King" {
                StaticCharacterPortrait(character: character, displayState: displayState)
            }
            // Fallback for unknown characters
            else {
                FallbackPortrait(characterName: character.name)
            }
        }
        .id(character.stateChangeID) // ← CRITICAL: Force refresh when stateChangeID changes
    }
}

struct RampAnimatedPortrait: View {
    let state: CharacterState
    
    var body: some View {
        Group {
            switch state {
            case .idle:
                // Idle state uses line boil animation
                LineBoilAnimation(framePrefix: "ramp_boil", frameCount: 3)
                
            case .attack:
                // Attack state - static image (FOR NOW)
                StaticImage(imageName: "ramp_attack")
                
            case .hurt:
                // Hurt state - enemy damage
                StaticImage(imageName: "ramp_hurt")
                
            case .hurt2:
                // Hurt2 state - invalid swap penalty
                StaticImage(imageName: "ramp_hurt2")
                
            case .defend:
                // Defend state - static image (FOR NOW)
                StaticImage(imageName: "ramp_defend")
                
            case .spell:
                // Spell state - static image (FOR NOW)
                StaticImage(imageName: "ramp_spell")
                
            case .victory:
                // Victory state - static image (FOR NOW)
                StaticImage(imageName: "ramp_victory")
                
            case .defeat:
                // Defeat state - static image (FOR NOW)
                StaticImage(imageName: "ramp_defeat")
            }
        }
    }
}

// Line boil animation for idle state
struct LineBoilAnimation: View {
    let framePrefix: String
    let frameCount: Int
    
    @State private var currentFrame = 0
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            let frameSequence = buildFrameSequence()
            
            if let image = UIImage(named: frameSequence[currentFrame]) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                FallbackPortrait(characterName: framePrefix)
            }
        }
        .onReceive(timer) { _ in
            currentFrame = (currentFrame + 1) % buildFrameSequence().count
        }
    }
    
    private func buildFrameSequence() -> [String] {
        guard frameCount > 0 else { return [] }
        var sequence: [String] = []
        for i in 1...frameCount {
            sequence.append("\(framePrefix)\(i)")
        }
        return sequence
    }
}

struct StaticImage: View {
    let imageName: String
    
    var body: some View {
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            FallbackPortrait(characterName: imageName)
        }
    }
}

struct FallbackPortrait: View {
    let characterName: String
    
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.3))
            .overlay(
                Text(String(characterName.prefix(1)))
                    .font(.system(size: 55, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}
```

**KEY POINTS:**
- `@Bindable var character` allows view to observe changes
- `.id(character.stateChangeID)` forces complete view refresh on state change
- Idle state uses line boil animation (ramp_boil1, ramp_boil2, ramp_boil3)
- Other states use static images

---

### 3️⃣ **BattleManager.swift** (State Changes - Attack/Defend/Spell)

```swift
func processMatches(_ matches: [Match]) {
    guard gameState == .playing else { return }
    
    // ... damage calculation code ...
    
    for match in matches {
        switch match.type {
        case .sword:
            // 🎨 SET PLAYER TO ATTACK STATE
            player.currentState = .attack
            
        case .fire:
            // 🎨 SET PLAYER TO ATTACK STATE
            player.currentState = .attack
            
        case .shield:
            // 🎨 SET PLAYER TO DEFEND STATE
            player.currentState = .defend
            
        case .heart:
            // 🎨 SET PLAYER TO DEFEND STATE
            player.currentState = .defend
            
        // ... other cases ...
        }
    }
    
    // Apply effects...
    
    // ═══════════════════════════════════════════════════════════════
    // 🎨 RETURN PLAYER TO IDLE STATE AFTER ANIMATIONS
    // ═══════════════════════════════════════════════════════════════
    Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(350))  // ⚡ CHANGE THIS for different duration
        if gameState == .playing {
            player.currentState = .idle
        }
    }
    // ═══════════════════════════════════════════════════════════════
    
    checkGameOver()
}
```

**KEY POINTS:**
- Sets `player.currentState = .attack` when matching swords/fire
- Sets `player.currentState = .defend` when matching shields/hearts
- Automatically returns to `.idle` after 350ms using Task
- Single timer for ALL states (attack, defend, spell)

---

### 4️⃣ **GameViewModel.swift** (State Changes - Hurt States)

**Invalid Swap (hurt2):**
```swift
// PENALTY: Enemy attacks for 8 damage due to invalid move
battleManager.player.takeDamage(8)

// 🎨 RAMP TAKES DAMAGE FROM MISTAKE (set to hurt2 state)
battleManager.player.currentState = .hurt2

// Show hurt animation
isEnemyAttacking = true
flashPlayer = true
try? await Task.sleep(for: .milliseconds(350))  // ⚡ HURT2 FLASH DURATION
isEnemyAttacking = false
flashPlayer = false

// 🎨 RETURN RAMP TO IDLE
try? await Task.sleep(for: .milliseconds(150))  // ⚡ PAUSE BEFORE IDLE
battleManager.player.currentState = .idle
```

**Enemy Attack (hurt):**
```swift
// 🎨 SET PORTRAIT STATES (direct update)
battleManager.enemy.currentState = .attack
battleManager.player.currentState = .hurt

// Show visual attack effects
isEnemyAttacking = true
flashPlayer = true

// Apply damage
battleManager.enemyTurn()

// Wait for animation to complete
try? await Task.sleep(for: .milliseconds(350))  // ⚡ HURT FLASH DURATION
isEnemyAttacking = false
flashPlayer = false

// 🎨 RETURN BOTH TO IDLE
try? await Task.sleep(for: .milliseconds(150))  // ⚡ PAUSE BEFORE IDLE
battleManager.player.currentState = .idle
battleManager.enemy.currentState = .idle
```

**KEY POINTS:**
- Sets `player.currentState = .hurt2` for invalid swaps (8 damage penalty)
- Sets `player.currentState = .hurt` for enemy attacks
- Manually returns to `.idle` after flash + pause
- Total hurt duration: 350ms flash + 150ms pause = 500ms

---

## ⏱️ ANIMATION DURATIONS

| State | Where Set | Duration | Pause | Total | Auto-Return? |
|-------|-----------|----------|-------|-------|--------------|
| **`.attack`** | BattleManager.swift line 82, 97 | 350ms | 0ms | 350ms | ✅ Yes (Task) |
| **`.defend`** | BattleManager.swift line 112, 127 | 350ms | 0ms | 350ms | ✅ Yes (Task) |
| **`.spell`** | BattleManager.swift line 272, 289, 306 | 350ms | 0ms | 350ms | ✅ Yes (Task) |
| **`.hurt2`** | GameViewModel.swift line 220 | 350ms | 150ms | 500ms | ✅ Yes (manual) |
| **`.hurt`** | GameViewModel.swift line 548 | 350ms | 150ms | 500ms | ✅ Yes (manual) |
| **`.victory`** | BattleManager.swift line 217 | ∞ | - | ∞ | ❌ No (game over) |
| **`.defeat`** | BattleManager.swift line 228 | ∞ | - | ∞ | ❌ No (game over) |

---

## 🎨 HOW TO CUSTOMIZE DURATIONS

### Change Attack/Defend/Spell Duration

**BattleManager.swift** (around line 175):
```swift
try? await Task.sleep(for: .milliseconds(350))  // Change this number
```

### Change Hurt2 Duration (Invalid Swap)

**GameViewModel.swift** (around lines 225, 230):
```swift
try? await Task.sleep(for: .milliseconds(350))  // Flash duration
try? await Task.sleep(for: .milliseconds(150))  // Pause before idle
```

### Change Hurt Duration (Enemy Attack)

**GameViewModel.swift** (around lines 558, 563):
```swift
try? await Task.sleep(for: .milliseconds(350))  // Flash duration
try? await Task.sleep(for: .milliseconds(150))  // Pause before idle
```

---

## 📁 REQUIRED IMAGE ASSETS

Add these to **Assets.xcassets**:

### Ramp Portraits:
- `ramp_boil1.png` - Idle animation frame 1
- `ramp_boil2.png` - Idle animation frame 2
- `ramp_boil3.png` - Idle animation frame 3
- `ramp_attack.png` - Attack state
- `ramp_hurt.png` - Enemy attack damage
- `ramp_hurt2.png` - Invalid swap penalty
- `ramp_defend.png` - Shield/heal state
- `ramp_spell.png` - Ability cast state
- `ramp_victory.png` - Victory state
- `ramp_defeat.png` - Defeat state

### Ednar Portraits (optional - currently uses one image):
- `ednar_idle.png` - All states (for now)

---

## 🔧 HOW TO RECREATE IN NEW PROJECT

### Step 1: Create Character.swift

1. Create new Swift file: **Character.swift**
2. Paste the complete Character.swift code from above
3. Make sure to include:
   - `@Observable` class Character
   - `currentState` property with `didSet`
   - `stateChangeID` property
   - `CharacterState` enum with `imageName()` helper

### Step 2: Create CharacterAnimations.swift

1. Create new Swift file: **CharacterAnimations.swift**
2. Paste the complete CharacterAnimations.swift code from above
3. Key components:
   - `StateBasedCharacterPortrait` with `.id(character.stateChangeID)`
   - `RampAnimatedPortrait` with state switch
   - `LineBoilAnimation` for idle state
   - `StaticImage` helper

### Step 3: Modify BattleManager.swift

Add this code to `processMatches()` function:

```swift
// Set states when matching
player.currentState = .attack  // or .defend

// Return to idle after 350ms
Task { @MainActor in
    try? await Task.sleep(for: .milliseconds(350))
    if gameState == .playing {
        player.currentState = .idle
    }
}
```

### Step 4: Modify GameViewModel.swift

Add hurt state code to enemy turn and invalid swap functions:

```swift
// Set hurt state
battleManager.player.currentState = .hurt

// Flash effects
try? await Task.sleep(for: .milliseconds(350))

// Return to idle
try? await Task.sleep(for: .milliseconds(150))
battleManager.player.currentState = .idle
```

### Step 5: Use in Views

In your battle scene view:

```swift
StateBasedCharacterPortrait(character: battleManager.player)
```

### Step 6: Add Images

Add all required portrait images to Assets.xcassets with exact names listed above.

---

## ✅ VERIFICATION CHECKLIST

Test these scenarios to confirm system works:

- [ ] Make a sword/fire match → Ramp shows attack → Returns to idle
- [ ] Make a shield/heart match → Ramp shows defend → Returns to idle
- [ ] Let enemy attack → Ramp shows hurt → Returns to idle
- [ ] Try invalid swap → Ramp shows hurt2 → Returns to idle
- [ ] Use ability → Ramp shows spell → Returns to idle
- [ ] Win battle → Ramp shows victory → Stays on victory
- [ ] Lose battle → Ramp shows defeat → Stays on defeat
- [ ] Idle state shows line boil animation (3 frames cycling)

---

## 🎯 WHY THIS SYSTEM WORKS

1. **`@Observable` macro** - Makes Character reactive to SwiftUI
2. **`didSet` on currentState** - Updates stateChangeID every time state changes
3. **`.id(stateChangeID)`** - Forces SwiftUI to completely rebuild view when ID changes
4. **Automatic return to idle** - Task delays ensure states don't get stuck
5. **Direct state assignment** - Simple, no complex priority system needed
6. **Async-safe** - Works with non-blocking enemy turns

---

## 🚀 FUTURE ENHANCEMENTS

### Add Line Boil to Other States

Replace static images with line boil animations:

```swift
case .attack:
    LineBoilAnimation(framePrefix: "ramp_attack_boil", frameCount: 3)
```

Add images: `ramp_attack_boil1.png`, `ramp_attack_boil2.png`, `ramp_attack_boil3.png`

### Add Ednar States

Update CharacterState enum:

```swift
else if characterName == "Ednar" {
    switch self {
    case .idle: return "ednar_idle"
    case .attack: return "ednar_attack"
    case .hurt: return "ednar_hurt"
    // etc.
    }
}
```

### Different Durations Per State

Replace single Task with switch:

```swift
Task { @MainActor in
    let duration: Int
    switch player.currentState {
    case .attack: duration = 250
    case .defend: duration = 350
    case .spell: duration = 500
    default: duration = 350
    }
    
    try? await Task.sleep(for: .milliseconds(duration))
    if gameState == .playing {
        player.currentState = .idle
    }
}
```

---

**Status**: ✅ System 100% working and documented  
**Last Updated**: March 21, 2026  
**Ready for**: Production use, future enhancements, new chat sessions
