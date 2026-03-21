# 🛠️ DEBUG MODE - COMPLETE SETUP GUIDE

**Created**: March 20, 2026  
**Feature**: In-game debug menu for testing and development

---

## 📋 WHAT WAS ADDED

✅ **Debug button in top-right corner** (hammer icon)  
✅ **Full debug menu panel** with multiple testing tools  
✅ **Force 5-matches** for any gem type  
✅ **Instant max mana** (7/7)  
✅ **Spawn bonus coffee tiles** anywhere  
✅ **Battle stat manipulation** (HP, shield, score)  
✅ **Game speed controls** (toggle async, skip pauses)  
✅ **Board manipulation** (clear board, remove bonus tiles)

---

## 🎯 HOW TO ACCESS DEBUG MENU

### **In Game:**
1. **Start the game** (get past title/map screens)
2. Look at the **top-right corner**
3. See the **orange hammer icon**
4. **Tap it** to open debug menu
5. **Tap X** or tap outside to close

---

## 🎮 DEBUG MENU FEATURES

### **⚡ QUICK ACTIONS**

| Button | What It Does |
|--------|-------------|
| **Fill Mana (7/7)** | Instantly gives you full mana (can use coffee ability) |
| **Full HP** | Restores player to maximum health |
| **Kill Enemy** | Sets enemy health to 1 (one hit from winning) |
| **+50 Shield** | Adds 50 shield points to player |

---

### **🎲 BOARD MANIPULATION**

#### **Force 5-Match (Top Row)**
- Click any **gem type button** (Sword, Fire, Shield, Heart, Mana, Poison)
- Creates a **horizontal line of 5 matching gems** in the top row (row 0, columns 2-6)
- **Perfect for testing bonus tile spawning!**

**Example:**
1. Tap **"Sword"** button
2. Top row shows: `[random] [random] [Sword] [Sword] [Sword] [Sword] [Sword] [random]`
3. Swap any of those 5 swords
4. **Coffee bonus tile spawns!** ☕

#### **Spawn Coffee Bonus**
- **"Spawn Coffee Bonus (Center)"** - Places coffee tile at center of board
- **"Spawn at (3,3)"** - Places coffee at row 3, column 3
- **"Spawn at (5,5)"** - Places coffee at row 5, column 5

#### **Clear Entire Board**
- Removes all gems
- Board automatically refills with new gems after 0.1 seconds
- Useful for resetting test scenarios

---

### **⚔️ BATTLE STATS**

**Displays current game state:**
- Player HP / Max HP
- Enemy HP / Max HP  
- Mana (current/7)
- Shield amount
- Current score

**Updates in real-time** - watch values change as you play!

---

### **⏱️ GAME SPEED**

#### **Skip Pauses Toggle**
- **ON** (green) = Fast gameplay, minimal waiting
- **OFF** (gray) = Original timing with all pauses
- Same as `skipWaitingPauses` in GameViewModel

#### **Async Enemy Toggle**
- **ON** (green) = Enemy attacks in background, board unlocks faster
- **OFF** (gray) = Traditional blocking enemy turns
- Same as `asyncEnemyTurn` in GameViewModel

#### **Auto-Chain Speed Slider**
- **Range**: 0.1x to 2.0x
- **0.5x** = Auto-chains twice as fast
- **1.0x** = Normal speed
- **2.0x** = Auto-chains half speed (slow motion)
- Adjusts `autoChainSpeedMultiplier` in GameViewModel

---

### **☕ BONUS TILE TESTING**

- **Spawn at (3,3)** - Creates coffee tile at row 3, col 3
- **Spawn at (5,5)** - Creates coffee tile at row 5, col 5
- **Remove All Bonus Tiles** - Clears all coffee tiles from board
- Shows **Current Clear Mode** (row/column/both from BonusTileConfig)

---

## 📖 COMMON TESTING SCENARIOS

### **Scenario 1: Test Bonus Tile Spawning**
1. Open debug menu
2. Tap **"Sword"** (or any gem type) under "Force 5-Match"
3. Close debug menu
4. **Swap one of the 5 matching gems** in top row
5. Watch coffee tile spawn at center!

---

### **Scenario 2: Test Row Clear**
1. Open debug menu
2. Tap **"Spawn Coffee Bonus (Center)"**
3. Close debug menu
4. **Swap coffee with any adjacent gem**
5. Watch entire row disappear!

---

### **Scenario 3: Test Fast Gameplay**
1. Open debug menu
2. Turn **"Skip Pauses"** to **ON** (green)
3. Turn **"Async Enemy"** to **ON** (green)
4. Set **Auto-Chain Speed** to **0.3x**
5. Close debug menu
6. Play - notice how much faster everything is!

---

### **Scenario 4: Test Coffee Ability**
1. Open debug menu
2. Tap **"Fill Mana (7/7)"**
3. Close debug menu
4. Tap **coffee cup button** on battle screen
5. Select any gem type
6. All of that type disappear!

---

### **Scenario 5: Almost-Winning State**
1. Open debug menu
2. Tap **"Kill Enemy"** (enemy at 1 HP)
3. Tap **"Full HP"** (you at max HP)
4. Tap **"+50 Shield"** (extra protection)
5. Close debug menu
6. Make one match to win!

---

### **Scenario 6: Test Multiple Coffee Tiles**
1. Open `BonusTileConfig.swift`
2. Make sure line 56 says: `allowMultiple: Bool = true`
3. Open debug menu
4. Tap **"Spawn at (3,3)"**
5. Tap **"Spawn at (5,5)"**
6. Close debug menu
7. See **two coffee cups** on board!

---

## 🎨 CUSTOMIZING DEBUG MENU

### **Add New Quick Action Button**

Open `DebugMenuView.swift`, find the `quickActionsSection` (around line 63), add:

```swift
debugButton(title: "Your Feature", icon: "star.fill", color: .blue) {
    // Your code here
    viewModel.score += 1000
}
```

---

### **Add New Force Match Type**

The menu already has all 6 gem types! But if you want to change the position:

Find line 124 in `DebugMenuView.swift`:
```swift
private func force5Match(type: TileType) {
    // Create 5 tiles in top row (row 0, columns 2-6)
    for col in 2...6 {  // ← Change these numbers
```

**Examples:**
- `2...6` = Top row, slightly right of center (current)
- `0...4` = Top row, left side
- `3...7` = Top row, right side
- Change `row: 0` to `row: 7` for bottom row

---

### **Add Stat Display**

Find `battleStatsSection` (around line 105), add:

```swift
statRow(label: "Your Stat", value: "123")
```

---

### **Add New Section**

Copy any section (like `bonusTileSection`) and modify:

```swift
private var myCustomSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        sectionHeader(title: "🎯 MY FEATURE", icon: "star.fill")
        
        debugButton(title: "Do Something", icon: "bolt", color: .purple) {
            // Your code
        }
    }
}
```

Then add it to the main ScrollView (around line 45):

```swift
Divider()
myCustomSection
```

---

## 🐛 TROUBLESHOOTING

### **Problem: Debug button not visible**

**Solution:**
1. Make sure you're **in the game** (past title/map screens)
2. Look at **top-right corner** (orange hammer icon)
3. If still not there, check ContentView.swift was updated correctly

---

### **Problem: Menu appears behind other UI**

**Solution:**
- Menu has `zIndex(1500)` - should be above everything except pause menu
- If needed, increase zIndex in ContentView.swift (line with `DebugMenuView`)

---

### **Problem: "Force 5-Match" doesn't work**

**Solution:**
1. Make sure you're clicking the **gem type buttons** (not other buttons)
2. Look at the **TOP ROW** of the board (row 0)
3. Gems are at **columns 2, 3, 4, 5, 6** (middle of row)
4. You still need to **swap one of them** to trigger the match

---

### **Problem: Coffee doesn't spawn after 5-match**

**Checklist:**
- [ ] Open `BonusTileConfig.swift`
- [ ] Line 15: `enabled: Bool = true` ✅
- [ ] Line 19: `minimumMatchSize: Int = 5` (or less) ✅
- [ ] Force 5-match created **5 gems in a straight line**
- [ ] Actually **swapped** one of the matching gems
- [ ] Coffee should appear after gems disappear

---

### **Problem: Stats not updating**

**Solution:**
- Stats update in real-time
- If frozen, close and reopen debug menu
- Stats show: player/enemy HP, mana, shield, score
- These should match what you see in the game

---

## 🔒 DISABLING DEBUG MODE (FOR RELEASE)

### **Option 1: Remove the Button**

In `ContentView.swift`, **comment out** or **delete** lines with debug button (around line 103-117):

```swift
// 🛠️ DEBUG BUTTON (Top-right corner)
/*
VStack {
    HStack {
        Spacer()
        Button(action: { showDebugMenu = true }) {
            // ... button code ...
        }
    }
    Spacer()
}
.zIndex(100)
*/
```

Also comment out the debug menu overlay (around line 155):

```swift
/*
if showDebugMenu {
    DebugMenuView(viewModel: viewModel, isShowing: $showDebugMenu)
        .transition(.opacity)
        .zIndex(1500)
}
*/
```

---

### **Option 2: Add Password Protection**

Modify the debug button action:

```swift
Button(action: {
    // Show alert for password
    // Only open menu if correct
    showDebugMenu = true
}) {
```

---

### **Option 3: Hide Button in Release Builds**

```swift
#if DEBUG
VStack {
    HStack {
        Spacer()
        Button(action: { showDebugMenu = true }) {
            // Debug button
        }
    }
    Spacer()
}
#endif
```

This button **only appears** when running from Xcode. Disappears in App Store builds!

---

## 📝 FILES MODIFIED

| File | What Changed |
|------|-------------|
| **DebugMenuView.swift** | NEW FILE - Complete debug menu |
| **ContentView.swift** | Added debug button + menu overlay |

---

## ✨ FUTURE DEBUG FEATURES (IDEAS)

Want to add more debug tools? Here are ideas:

### **Time Controls**
- Slow motion (0.5x speed)
- Fast forward (2x speed)
- Pause game entirely

### **Visual Debugging**
- Show grid positions on tiles
- Highlight spawn delays
- Show match detection areas

### **Cheats**
- God mode (invincible)
- Infinite mana
- Auto-win button

### **Spawn Controls**
- Force specific gem at position
- Remove specific gem
- Swap any two gems

### **Animation Testing**
- Trigger specific animations
- Adjust animation speeds
- Test all character states

---

## 🎓 HOW TO ADD FEATURES

All debug functions are in **DebugMenuView.swift**.

**Template for new button:**

```swift
debugButton(title: "Button Name", icon: "icon.name", color: .blue) {
    // What happens when clicked
    viewModel.something = value
}
```

**Access to game state:**
- `viewModel.boardManager` - Board/gems
- `viewModel.battleManager` - Battle stats
- `viewModel.score` - Score
- `viewModel.skipWaitingPauses` - Speed settings
- `BonusTileConfig` - Bonus tile settings

**Example - Add 100 to score:**

```swift
debugButton(title: "+100 Score", icon: "star.fill", color: .yellow) {
    viewModel.score += 100
}
```

---

**Last Updated**: March 20, 2026  
**Status**: ✅ Fully functional  
**Version**: 1.0
