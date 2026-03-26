# 🧪 POISON PILL SYSTEM DOCUMENTATION

**Date**: March 24, 2026  
**Status**: Fully Implemented  
**Type**: Minesweeper-style hidden hazard

---

## 🎯 OVERVIEW

The Poison Pill is a single hidden hazard placed randomly on the board at the start of each battle. When the player matches gems on top of the poison pill's location, it is revealed and triggers a damage-over-time effect.

---

## ⚙️ HOW IT WORKS

### **1. PLACEMENT (Battle Start)**
- ONE poison pill is placed at a random board position
- It's completely invisible (hidden under normal gems)
- Position is different every match
- Placed in `GameViewModel.init()` and `resetGame()`

### **2. REVEAL (When Matched)**
- When player creates a match on the poison pill's position, it's revealed
- Visual effect: Purple blast → smoke dissipation → poison pill tile image
- Player takes **3 damage immediately** (Turn 0)
- Player portrait gets purple glow overlay with 3 dots showing poison turns remaining
- Poison status is activated

### **3. DAMAGE OVER TIME**
- Poison damage applies **at the START of each turn** (before enemy attack)
- Damage progression:
  - **Turn 1**: 3 damage
  - **Turn 2**: 4 damage  
  - **Turn 3**: 5 damage
  - **After Turn 3**: Poison wears off automatically

### **4. VISUAL EFFECTS**
- **Board**: Purple blast + smoke effect when revealed, shows `poisonpill_tile.png`
- **Portrait**: Purple pulsing glow around player portrait
- **Indicator**: 3 dots at top of portrait showing current poison turn (1/2/3)
- **Animation**: Ramp flashes and goes to `.hurt2` state when taking poison damage

---

## 📁 FILES CREATED/MODIFIED

### **New Files**:
1. `PoisonPillManager.swift` - Core poison pill logic and state management
2. `PoisonRevealEffectView.swift` - Visual effect when poison is revealed on board
3. `PoisonGlowOverlay.swift` - Purple glow effect for poisoned character portrait

### **Modified Files**:
1. `BattleManager.swift`:
   - Added `poisonPillManager` property
   - Added `applyPoisonDamage()` function
   - Integrated poison reset in `reset()`

2. `GameViewModel.swift`:
   - Setup poison pill in `init()` and `resetGame()`
   - Check for poison reveal in `processCascades()`
   - Apply poison damage at start of `enemyTurn()`

3. `BoardManager.swift`:
   - Added `setupPoisonPill()` helper function

4. `GameBoardView.swift`:
   - Added poison reveal effect rendering in `boardContent()`

5. `BattleSceneView.swift`:
   - Added `PoisonGlowOverlay` to player portrait

---

## 🎨 REQUIRED ASSET

**Image**: `poisonpill_tile.png`  
- Should be placed in your Assets catalog
- This is the visual representation of the revealed poison pill
- Shows briefly after the purple blast/smoke effect

---

## 🔧 CUSTOMIZATION OPTIONS

### **Change Damage Values**
In `PoisonPillManager.swift`, function `getPoisonDamageForTurn()`:
```swift
switch poisonTurnCounter {
case 1:
    return 3  // Turn 1 damage - CHANGE THIS
case 2:
    return 4  // Turn 2 damage - CHANGE THIS
case 3:
    return 5  // Turn 3 damage - CHANGE THIS
```

### **Change Number of Poison Turns**
In `PoisonPillManager.swift`, function `advancePoisonTurn()`:
```swift
if poisonTurnCounter > 3 {  // CHANGE 3 to different number
    isPoisoned = false
```

Also update the indicator dots in `PoisonGlowOverlay.swift`:
```swift
ForEach(1...3, id: \.self) { turn in  // CHANGE 3 here too
```

### **Change Initial Reveal Damage**
In `GameViewModel.swift`, function `processCascades()`:
```swift
if poisonRevealed {
    battleManager.player.takeDamage(3)  // CHANGE THIS
```

### **Change Visual Effect Colors**
In `PoisonRevealEffectView.swift` and `PoisonGlowOverlay.swift`:
- Change `Color.purple` to any other color
- Adjust opacity values for intensity

---

## 🐛 TROUBLESHOOTING

### **Poison pill not appearing**
- Check console for: `🧪 POISON PILL: Hidden at row X, col Y`
- This confirms the pill was placed

### **Poison damage not applying**
- Check console for: `💀 POISON REVEALED at GridPosition(...)`
- If this appears but no damage, check `applyPoisonDamage()` is called in `enemyTurn()`

### **Purple glow not showing**
- Verify `PoisonGlowOverlay` is added to portrait in `BattleSceneView.swift`
- Check `isPoisoned` is true in `poisonPillManager`

### **Visual effect not playing**
- Ensure `poisonpill_tile.png` exists in Assets
- Check `revealedPoisonEffect` is not nil when poison reveals

---

## 🚀 FUTURE ENHANCEMENTS (OPTIONAL)

You mentioned you might want to change things later. Here are easy additions:

### **Cure/Cleanse Mechanic**
Add to `PoisonPillManager.swift`:
```swift
func curePoison() {
    isPoisoned = false
    poisonTurnCounter = 0
    print("✅ Poison cured!")
}
```

### **Multiple Poison Pills**
Change `poisonPillPosition` to an array:
```swift
var poisonPillPositions: [GridPosition] = []
```

### **Poison Resistance Items**
Add damage reduction in `getPoisonDamageForTurn()`:
```swift
let baseDamage = [0, 3, 4, 5][poisonTurnCounter]
let reducedDamage = Int(Double(baseDamage) * resistanceMultiplier)
return reducedDamage
```

---

## ✅ TESTING CHECKLIST

- [ ] Poison pill places at battle start
- [ ] Poison pill in different position each match
- [ ] Matching on poison position reveals it
- [ ] Purple blast/smoke effect plays
- [ ] 3 immediate damage when revealed
- [ ] Purple glow appears on portrait
- [ ] 3 dots show poison turn counter
- [ ] Turn 1: 3 damage at turn start
- [ ] Turn 2: 4 damage at turn start
- [ ] Turn 3: 5 damage at turn start
- [ ] Poison wears off after turn 3
- [ ] Purple glow disappears when cured
- [ ] New poison pill on game restart

---

**System is ready to use! Just add the `poisonpill_tile.png` image to your Assets.**
