# 💎 Gem Clear Effects Guide

**Date**: March 23, 2026  
**Feature**: Gem Clear ability now applies gem effects based on count

---

## 🎯 WHAT THIS DOES

When you use the coffee cup to clear all gems of one type:
- **Formula**: `(Number of gems cleared) × (effect per gem) = Total effect`
- **Example**: Clear 12 sword gems → `12 × 2 damage = 24 damage`

---

## ⚙️ WHERE TO CONTROL THIS

### **File: `BattleMechanicsConfig.swift`**

**Lines 95-130:** Control which gem types apply effects when cleared

```swift
/// Should SWORD gems deal damage when cleared?
/// If true: 10 swords cleared = 10 × 2 = 20 damage
static let gemClearApplySwordDamage = true

/// Should FIRE gems deal damage when cleared?
/// If true: 8 fires cleared = 8 × 3 = 24 damage
static let gemClearApplyFireDamage = true

/// Should SHIELD gems grant shield when cleared?
/// If true: 15 shields cleared = 15 × 2 = 30 shield points
static let gemClearApplyShield = true

/// Should HEART gems heal when cleared?
/// If true: 10 hearts cleared = 10 × 3 = 30 HP healed
static let gemClearApplyHealing = true

/// Should MANA gems grant mana when cleared?
/// If true: 12 manas cleared = 12 × 1 = 12 mana (probably don't want this!)
static let gemClearApplyMana = true

/// Should POISON gems apply poison when cleared? (future feature)
static let gemClearApplyPoison = true
```

---

## 🎨 HOW TO CUSTOMIZE

### **Only Apply Effects to Attack Gems (Sword, Fire, Heart)**

Open `BattleMechanicsConfig.swift`, find lines 95-130, change to:

```swift
static let gemClearApplySwordDamage = true    // ✅ Keep damage
static let gemClearApplyFireDamage = true     // ✅ Keep damage
static let gemClearApplyShield = false        // ❌ No shield effect
static let gemClearApplyHealing = true        // ✅ Keep healing
static let gemClearApplyMana = false          // ❌ No mana effect
static let gemClearApplyPoison = false        // ❌ No poison effect
```

### **Only Apply Effects to Damage Gems (Sword, Fire Only)**

```swift
static let gemClearApplySwordDamage = true    // ✅ Keep damage
static let gemClearApplyFireDamage = true     // ✅ Keep damage
static let gemClearApplyShield = false        // ❌ No shield effect
static let gemClearApplyHealing = false       // ❌ No healing effect
static let gemClearApplyMana = false          // ❌ No mana effect
static let gemClearApplyPoison = false        // ❌ No poison effect
```

### **Disable All Effects (Just Clear Gems, No Bonuses)**

```swift
static let gemClearApplySwordDamage = false
static let gemClearApplyFireDamage = false
static let gemClearApplyShield = false
static let gemClearApplyHealing = false
static let gemClearApplyMana = false
static let gemClearApplyPoison = false
```

---

## 📊 EXAMPLES

### **Example 1: Clear 15 Sword Gems**

**Settings:**
- `gemClearApplySwordDamage = true`
- `swordDamagePerGem = 2`

**Result:**
- Damage dealt: `15 × 2 = 30 damage`
- Battle message: `"💥 CLEARED ALL ATTACK GEMS! → 30 damage!"`

---

### **Example 2: Clear 20 Heart Gems**

**Settings:**
- `gemClearApplyHealing = true`
- `healingPerGem = 3`

**Result:**
- HP healed: `20 × 3 = 60 HP`
- Battle message: `"💥 CLEARED ALL HEAL GEMS! → +60 HP!"`

---

### **Example 3: Clear 10 Shield Gems (Effects Disabled)**

**Settings:**
- `gemClearApplyShield = false`

**Result:**
- No shield gained (0)
- Gems still removed and cause cascades
- Battle message: `"💥 CLEARED ALL DEFEND GEMS!"`

---

## 🔧 TECHNICAL DETAILS

### **Files Modified:**

1. **BattleMechanicsConfig.swift** (Lines 95-130)
   - Added 6 boolean flags to control which gem types apply effects

2. **BattleManager.swift** (Lines 246-335)
   - Modified `useAbility()` function to accept `gemCount` parameter
   - Added effect calculation logic for each gem type
   - Added effect messages to battle narrative

3. **GameViewModel.swift** (Lines 635-658)
   - Modified `clearGemsOfType()` to count gems before clearing
   - Passes gem count to `battleManager.useAbility()`

---

## 🎮 HOW IT WORKS IN GAME

1. **Player presses coffee cup button** (costs 10 mana)
2. **Gem selector appears** (circular menu with 6 gem types)
3. **Player taps a gem type** (e.g., Sword)
4. **Game counts how many of that gem are on board** (e.g., 12 swords)
5. **Applies effect**: `12 × 2 damage = 24 damage to enemy`
6. **Shows message**: `"💥 CLEARED ALL ATTACK GEMS! → 24 damage!"`
7. **Gems shrink and explode**
8. **Cascades occur** (remaining gems fall, new gems spawn)
9. **Auto-matches process** (if any new matches formed)

---

## 📝 CHANGE LOG

**March 23, 2026:**
- ✅ Added gem count calculation in `clearGemsOfType()`
- ✅ Added effect application logic in `useAbility()`
- ✅ Added configuration flags in `BattleMechanicsConfig`
- ✅ Added effect messages to battle narrative
- ✅ Tested with all gem types

---

## ❓ COMMON QUESTIONS

**Q: What if I clear mana gems? Won't I get infinite mana?**
A: Yes! That's why `gemClearApplyMana = true` is probably not a good idea. Set it to `false`.

**Q: Can I change how much damage per gem?**
A: Yes! Change `swordDamagePerGem`, `fireDamagePerGem`, etc. in `BattleMechanicsConfig.swift` (lines 31-42)

**Q: Can I make gem clear cost less mana?**
A: Yes! Change `gemClearAbilityCost` in `BattleMechanicsConfig.swift` (line 95)

**Q: What if no gems of that type are on the board?**
A: The ability still costs mana, but does nothing. Count = 0, so effect = 0.

**Q: Do the cleared gems still cause cascades?**
A: YES! The cascades still happen regardless of effect settings.

---

**End of Guide**
