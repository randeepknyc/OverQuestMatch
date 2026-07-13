# 🎮 PHYSICS CHAIN GAME - QUICK START GUIDE

**Created:** March 28, 2026  
**Status:** ✅ READY TO PLAY

---

## 🚀 HOW TO TEST IT NOW

### **STEP 1: Open the Project**
1. **Open Xcode** if it's not already open
2. Your project should already be loaded

---

### **STEP 2: Switch to Physics Chain Game**
1. In Xcode's **left sidebar** (Project Navigator), find and click: **`OverQuestMatch3App.swift`**
2. Look for **line 25** - you'll see:
   ```swift
   private let currentGame: GameType = .match3
   ```
3. **Change `.match3` to `.physicsChain`** so it looks like:
   ```swift
   private let currentGame: GameType = .physicsChain
   ```
4. **Press Command+S** to save

---

### **STEP 3: Run the Game**
1. **Press Command+R** (or click the Play ▶️ button in the top-left)
2. Wait for the app to build and launch
3. **You should see:**
   - Purple/blue gradient background
   - Score counter in top-left (starting at 0)
   - 90 colorful tiles falling from the top with physics!
   - Tiles bouncing off the bottom and walls

---

### **STEP 4: Play the Game!**

**To make a match:**
1. **Wait for tiles to settle** at the bottom
2. **Drag your finger** across 3 or more tiles of the SAME color/type
3. You'll see:
   - Selected tiles **glow** and grow slightly
   - An **animated line** connecting them
4. **Release your finger** to complete the match
5. Watch the tiles **disappear** and new ones **fall from above**!

**Tips:**
- Tiles must be **close together** to connect (about 1.5× tile width)
- You need **at least 3 tiles** to make a valid match
- **Same type only** - can't mix Swords with Hearts, etc.
- Build **combos** by matching quickly for bonus points!

**Backtracking:**
- If you accidentally added the wrong tile, **touch the second-to-last tile** to undo

---

### **STEP 5: Switch Back to Match-3 (When Done Testing)**
1. Go back to **`OverQuestMatch3App.swift`**
2. Change line 25 back to:
   ```swift
   private let currentGame: GameType = .match3
   ```
3. **Press Command+S** and **Command+R** to run your Match-3 game again

---

## ✅ WHAT TO TEST

### **Basic Physics:**
- [ ] Tiles fall from the top
- [ ] Tiles bounce when they hit the ground
- [ ] Tiles bounce off the left/right walls
- [ ] Tiles push each other around when they collide

### **Chain Matching:**
- [ ] Can drag across 3+ tiles of the same type
- [ ] See glowing effect on selected tiles
- [ ] See animated line connecting selected tiles
- [ ] Can't connect tiles that are too far apart
- [ ] Can't connect different tile types (e.g., Sword + Fire)

### **Match Completion:**
- [ ] Releasing finger with 3+ tiles makes them disappear
- [ ] Score increases (10 points per tile)
- [ ] New tiles spawn from the top to replace matched ones
- [ ] Combo counter increases (top-right) when matching multiple times

### **Backtracking:**
- [ ] While building a chain, touch the second-to-last tile
- [ ] The last tile gets deselected (stops glowing)
- [ ] Can continue building the chain

---

## 🎨 TILE TYPES (Same as Match-3!)

The game uses your existing Match-3 tile images:

1. **Sword** (⚔️) - Gray/White
2. **Fire** (🔥) - Orange/Yellow
3. **Shield** (🛡️) - Cyan/Mint
4. **Heart** (❤️) - Red/Pink
5. **Mana** (💙) - Blue/Cyan
6. **Poison** (☠️) - Purple/Indigo

---

## ⚙️ QUICK CUSTOMIZATION

Want to change how it feels? Edit **`PhysicsChainGame/GameConfig.swift`**:

### **Make it easier:**
```swift
static let minimumChainLength = 2  // Default: 3 (accept 2-tile chains)
static let chainConnectionDistance: CGFloat = 2.0  // Default: 1.5 (connect from farther)
```

### **More tiles (more chaos):**
```swift
static let initialTileCount = 150  // Default: 90
```

### **Faster falling:**
```swift
static let gravity: CGFloat = 1.5  // Default: 0.9
```

### **More bouncy:**
```swift
static let bounce: CGFloat = 0.9  // Default: 0.7 (1.0 = perfectly elastic)
```

---

## 🐛 TROUBLESHOOTING

**Problem:** App crashes when I run it  
**Solution:** Make sure you changed the switcher to `.physicsChain` and saved (Command+S)

**Problem:** I don't see any tiles  
**Solution:** Wait a few seconds - they spawn above the screen and fall down

**Problem:** Tiles look weird or are missing  
**Solution:** The game uses your Match-3 tile images. Make sure these exist in Assets.xcassets:
- tile_sword, tile_fire, tile_shield, tile_heart, tile_mana, tile_poison

**Problem:** Tiles are falling off the screen  
**Solution:** In `PhysicsChainGame/GameConfig.swift`, make sure `enableFloorCollision = true`

**Problem:** Can't make any matches  
**Solution:** 
- Make sure you're dragging across at least 3 tiles
- Make sure they're the same type (same color)
- Make sure they're close enough to each other

---

## 📁 FILES CREATED

All files are in the **`PhysicsChainGame/`** folder:

1. **TileType.swift** - Defines the 6 tile types
2. **Tile.swift** - Individual tile model
3. **GameConfig.swift** - All game settings (CUSTOMIZE HERE!)
4. **TileView.swift** - How tiles look
5. **GameViewModel.swift** - Physics engine and game logic
6. **PhysicsChainGameView.swift** - Main game screen

---

## 🎯 NEXT STEPS

After testing the Physics Chain Game, you can:

1. **Keep playing** and see how high of a score you can get!
2. **Customize it** by editing GameConfig.swift
3. **Switch back to Match-3** to work on that game
4. **Build the Cooking Game** next (3rd game type)
5. **Create a Map Screen** to connect all games together

---

## ✅ SUCCESS!

You now have **TWO complete games** in your project:
1. ✅ **Match-3 RPG Battle** - Your original game
2. ✅ **Physics Chain Game** - Your new Tsum-Tsum style game

Both are self-contained and easy to switch between!

**Have fun!** 🎮✨

---

**Quick Reference:**
- Switch games: Edit `OverQuestMatch3App.swift` line 25
- Customize physics: Edit `PhysicsChainGame/GameConfig.swift`
- Test: Press Command+R
- Questions? Check `PHYSICS_CHAIN_GAME_COMPLETE.md` for detailed docs
