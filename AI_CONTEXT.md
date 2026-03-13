# AI Context & Project Knowledge Base
**OverQuestMatch3 - Match-3 RPG Battle Game**

> **IMPORTANT**: This file MUST be read at the start of EVERY new conversation. After EVERY user request, update this file with what was changed, what works, what doesn't work, and what needs to be done next.

---

## 🎮 PROJECT OVERVIEW

**Game Type**: Match-3 puzzle game with RPG battle mechanics
**Platform**: iOS (SwiftUI)
**User's Coding Experience**: The user knows NOTHING about coding or Xcode - always provide complete, copy-paste-ready code

---

## 📁 PROJECT STRUCTURE

### Core Files
- **ContentView.swift** - Main app container with screen management and overlay systems
- **BattleSceneView.swift** - Character portraits, health bars, battle UI, coffee cup ability button
- **GameBoardView.swift** - Match-3 game board (8x8 grid)
- **GameViewModel.swift** - Main game logic and state management
- **BattleManager.swift** - Battle mechanics, damage, health, mana
- **Character.swift** - Character data models
- **TileType.swift** - Gem/tile type definitions
- **GameConfig.swift** - Game constants and configuration

### UI Screens
- **TitleScreenView.swift** - Opening title screen
- **MapScreenView.swift** - Map selection (shows after title screen)
- **PauseMenuView.swift** - Full-screen pause overlay
- **GameOverView.swift** - Victory/defeat screen

---

## 🎯 CURRENT GAME MECHANICS

### Match-3 Board
- **Size**: 8x8 grid of tiles
- **Tile Types**: Sword, Fire, Shield, Heart, Mana, Poison
- **Matching**: Match 3+ tiles horizontally or vertically
- **Effects**: Different tiles have different battle effects

### Battle System
- **Player Character**: "Ramp" (left side)
- **Enemy Character**: "Ednar" (right side)
- **Health System**: Both characters have health bars with color coding (green > 50%, yellow > 25%, red < 25%)
- **Shield System**: Shield badge appears in top-right of character portrait when shield > 0
- **Mana System**: Max 7 mana, displayed via pie chart fill on coffee cup button

### Special Ability - Coffee Cup
- **Location**: Left side of battle scene, centered
- **Cost**: 5 mana to activate
- **Function**: Opens gem selector to clear all tiles of a chosen type
- **Visual**: Circular button with pie chart fill showing current mana (0-7)
- **States**: 
  - Disabled (grey) when mana < 5 or processing
  - Enabled (orange) when affordable
  - Fill animation shows mana percentage

### Gem Selector (Special Ability UI)
- **Trigger**: Click coffee cup button when mana >= 5
- **Display**: Popup overlay with 6 tile type buttons
- **Position**: BELOW the coffee cup button (height: 0.44 of screen)
- **Scale**: 1.5x for better visibility
- **Behavior**: 
  - Appears ONLY when coffee button is pressed
  - Click any gem type to clear all of that type from board
  - Click outside to dismiss
  - Has dark overlay behind it
- **Location**: Managed in ContentView.swift (lines 90-103)

---

## 🏗️ ARCHITECTURE DETAILS

### BattleSceneView.swift Layout
```
ZStack {
    Background Gradient
    VStack {
        SECTION 1: Character Portraits (side-by-side HStack)
            - Left: Player (Ramp) + Health Bar + Shield Badge
            - Right: Enemy (Ednar) + Health Bar
        
        SECTION 2: Status & Info (side-by-side HStack)
            - Left: Coffee Cup Ability Button (centered)
            - Right: Battle Narrative (3 recent event messages)
    }
}
```

### ContentView.swift Overlay System
```
ZStack {
    GameScreen (if not on title/map)
    MapScreen (if showing)
    TitleScreen (if showing)
    PauseMenu (if showing)
    
    // Inside GameScreen:
    GeometryReader {
        ZStack {
            VStack {
                GameHUDView (60pt height)
                BattleSceneView (42% of screen)
                GameBoardView (58% of screen)
            }
            
            // Overlays (z-indexed):
            - Tap-away overlay (z: 90) - for gem selector dismissal
            - Gem selector popup (z: 200) - positioned at 0.44 height
            - Game over screen
        }
    }
}
```

---

## ✅ WHAT WORKS (TESTED & CONFIRMED)

1. **Coffee Cup Button**
   - Displays correctly on battle scene
   - Shows mana fill with pie chart animation
   - Disables when mana < 5
   - Triggers gem selector popup

2. **Gem Selector Popup**
   - Appears BELOW coffee button when activated
   - Shows all 6 tile types with proper images
   - Clears tiles when clicked
   - Dismisses when tapping outside
   - Properly scaled and positioned

3. **Battle Scene Layout**
   - Characters display side-by-side
   - Health bars animate properly
   - Shield badges show when shield > 0
   - Battle narrative shows 3 recent events

4. **No Duplicate Gem Selectors**
   - Removed permanent gem selector from BattleSceneView
   - Only popup version exists (in ContentView)

5. **4-Match Power Surge Effect** ✨ **FULLY WORKING!**
   - Triggers on 4+ tile matches in any single turn
   - Full-screen golden lightning bolts flash across entire game
   - Giant "⚡ POWER SURGE! ⚡" text with floating animation
   - Screen flash effect (yellow fade)
   - Awards +2 bonus mana automatically
   - Battle narrative announces: "⚡ POWER SURGE! X MATCHES! +2 bonus mana!"
   - Easy to toggle on/off: `GameConfig.enablePowerSurgeEffect`
   - Adjustable threshold: `GameConfig.powerSurgeChainThreshold` (default: 4)
   - Adjustable bonus: `GameConfig.powerSurgeManaBonus` (default: 2)
   - 100% code-based - no image assets required

---

## ❌ KNOWN ISSUES

- None currently reported

---

## 🔧 RECENT CHANGES

### Session 3: 4-Match Power Surge Effect - WORKING! (March 12, 2026)

**Problem Identified:**
- User wanted Power Surge to trigger on 4+ tile matches (not cascading combos)
- Initial implementation had effect triggering on 4-chain combos which was too hard to achieve

**Changes Made:**

1. **BattleManager.swift (Lines 127-135)**
   - Changed from `comboCount` to `totalMatches` calculation
   - Now sums all tiles matched: `matches.reduce(0) { $0 + $1.count }`
   - Triggers when total matches >= 4 in a single turn
   - Battle narrative shows "⚡ POWER SURGE! X MATCHES! +2 bonus mana!"

2. **GameViewModel.swift (Lines 143-151)**
   - Added debug print statements to track Power Surge detection
   - Added 100ms delay before 1500ms wait to give SwiftUI time to see flag change
   - Properly resets `triggeredPowerSurge` flag after effect completes

3. **ContentView.swift (Lines 108-115)**
   - Added PowerSurgeEffect overlay to GameScreen ZStack
   - Positioned with z-index 500 (above game, below pause menu)
   - Effect covers entire screen (HUD + Battle + Board)

**Result:**
✅ Power Surge triggers on ANY 4+ tile match in one move
✅ Full-screen golden lightning effect with text
✅ Screen flash animation
✅ Battle narrative announces the surge
✅ Awards +2 bonus mana
✅ Easy to test: Match 4-5 tiles or use coffee cup ability
✅ 100% code-based - no image assets needed

**How It Works:**
1. Player matches 4+ tiles (or uses coffee cup ability for guaranteed trigger)
2. BattleManager calculates total matches and sets `triggeredPowerSurge = true`
3. GameViewModel detects flag, waits 100ms + 1500ms for effect to play
4. ContentView shows `PowerSurgeEffect` overlay covering entire screen
5. Effect displays: blue flash → diagonal lightning bolt → particles → text
6. Flag resets after 1.6 seconds total
7. Game continues normally

**Files Modified:**
- ChainComboEffects.swift (created - visual effect code with custom lightning shape)
- GameAssets.swift (added config toggles)
- BattleManager.swift (detection logic)
- GameViewModel.swift (timing control)
- ContentView.swift (display overlay)

---

### Session 4: Custom Blue Lightning Effect (March 12, 2026)

**Changes Made:**

1. **ChainComboEffects.swift - Complete Visual Overhaul**
   - Changed from 7 small vertical yellow bolts to **1 massive diagonal blue bolt**
   - Created `DiagonalCracklingBolt` custom Shape (replaces `CracklingLightningBolt`)
   - Lightning goes from top-left (0.1, 0.05) to bottom-right (0.9, 0.92)
   - 16+ zigzag points for crackling effect + 5 side branches
   - Changed colors: yellow/orange → **cyan/blue/white gradient**
   - Line width: 3px → **8px** (much thicker)
   - Shadows: yellow/white → **cyan (30px) + blue (20px) + white (15px)**

2. **Particle System Enhanced**
   - Increased from 20 → **40 particles**
   - Changed from solid yellow → **cyan/blue gradient**
   - Varied sizes: 3-12px (was 4-10px)
   - Larger spread: ±200x/±300y (was ±150x/±200y)
   - Varied blur: 1-4px for depth effect

3. **Screen Flash Color**
   - Changed from solid yellow → **cyan with 0.4 opacity** (more subtle)

4. **Font Fixed**
   - Changed `.gameTitle()` (didn't exist) → `.gameScore()` (OverQuest font)
   - Both title and subtitle now use custom OverQuest font

**How to Customize Lightning:**
- **Method 1 (Current):** Edit `DiagonalCracklingBolt` path coordinates
- **Method 2:** Import SVG and convert to Path
- **Method 3:** Use PNG image instead (replace `lightningBolts` with `Image()`)
- **Method 4:** Use Lottie animation for complex effects

**Result:**
✅ ONE massive diagonal blue lightning bolt across entire screen
✅ Intense cyan/blue glow effect
✅ 40 blue particles with gradient and depth
✅ Blue screen flash
✅ Custom OverQuest font working
✅ Fully customizable via code (no assets needed)

---

### Session 2: Initial Power Surge Attempt (Debugging Session)

**Note:** This session involved extensive debugging of indentation issues and view hierarchy problems. The effect was originally placed in BattleSceneView (wrong - only 42% of screen) instead of ContentView (correct - full screen). Final working implementation documented in Session 3 above.

---

### Session 1: Gem Selector Positioning Fix

**Problem Identified:**
- User had TWO gem selectors appearing:
  1. A permanent one always visible below coffee button (INCORRECT)
  2. A popup one that appeared above coffee button (CORRECT but wrong position)

**Changes Made:**

1. **BattleSceneView.swift (Lines 52-71)**
   - REMOVED the permanent `GemTypeSelector` that was always showing
   - Kept only the `CoffeeCupAbilityButton` in the left section
   - Changed VStack alignment from `.leading` to `.center`
   - Removed the extra `.frame(maxWidth: .infinity, alignment: .center)` wrapper

2. **ContentView.swift (Line 92)**
   - Changed popup position from `0.30` to `0.44` of screen height
   - This moves the gem selector from ABOVE to BELOW the coffee button
   - Updated comment to reflect new position

**Result:**
✅ Only ONE gem selector now exists
✅ It appears as a popup BELOW the coffee button
✅ Activates when coffee button is pressed
✅ Can be dismissed by tapping outside

---

## 📝 COMPONENT REFERENCE

### CoffeeCupAbilityButton (BattleSceneView.swift)
- Size: 60x60 circular button
- Icon: `cup.and.saucer.fill` SF Symbol
- Mana display: PieChartFill shape (custom)
- Animation: Opacity and scale on disable/enable

### GemTypeSelector (BattleSceneView.swift, lines 349-401)
- Display: VStack with "SELECT:" text + HStack of 6 buttons
- Button size: 20x20 points each
- Background: Black with 0.9 opacity, rounded corners
- Tile order: Sword, Fire, Shield, Heart, Mana, Poison

### CharacterPortrait (BattleSceneView.swift)
- Height: 160 points
- Attack animation: 15-point horizontal offset with spring
- Flash effect: White overlay at 0.5 opacity
- Fallback: Colored rectangle with initial letter

### CharacterHealthBar (BattleSceneView.swift)
- Width: 140 points
- Height: 12 points
- Shows: Heart icon + "current/max" text + progress bar
- Colors: Green (>50%), Yellow (>25%), Red (<25%)

### ShieldBadge (BattleSceneView.swift)
- Size: 28x28 circular badge
- Position: Top-right corner of portrait (offset x:8, y:-8)
- Display: Cyan circle with white border + shield amount
- Font size: 20 (updated from 12)

### PowerSurgeEffect (ChainComboEffects.swift) ✨ UPDATED!
- Full-screen overlay effect for 4+ tile matches
- Components:
  - **Blue cyan screen flash** (fades from 0.8 to 0.0 opacity over 0.6s)
  - **ONE massive diagonal lightning bolt** (8px thick, cyan→blue→white gradient)
  - **40 blue particles** (varied sizes 3-12px, cyan/blue gradient, scattered ±200x/±300y)
  - Main text: "CRACKLE POWER!!" (size 60, OverQuest font, white with yellow/orange shadows)
  - Sub text: "+2 MANA BONUS!" (size 30, OverQuest font, orange)
- Lightning details:
  - **DiagonalCracklingBolt** custom Shape (top-left to bottom-right)
  - 16+ zigzag direction changes for crackling effect
  - 5 side branches for complexity
  - Triple shadow glow: cyan (30px), blue (20px), white (15px)
  - Flickers 5 times rapidly (0.1s duration, autoreverses)
- Animation timing:
  - Flash: 0.6s ease-out fade
  - Lightning: 0.2s appear, flickers at 0.3s, fades at 1.0s
  - Particles: 0.2s appear, 0.8s scatter and fade
  - Text: Spring scale (0.5 → 1.2), fades at 1.0s
- Total duration: ~1.5 seconds
- Z-index: 500 (in ContentView - above game, below pause menu)
- Displays when: `GameConfig.enablePowerSurgeEffect && viewModel.battleManager.triggeredPowerSurge`

**Customization Guide:**
- To change lightning: Edit `DiagonalCracklingBolt` struct (line ~165)
- To use image instead: Replace `lightningBolts` view with `Image("filename")`
- To change colors: Edit `lightningGradient` colors (line ~62)
- To adjust particles: Change `electricParticles` ForEach range (line ~72)
- To modify glow: Edit `.shadow()` modifiers (line ~50-52)

---

## 🎨 DESIGN PATTERNS

### Color Scheme
- Background: Green gradient (0.3-0.5 RGB mix)
- Battle narrative: Black boxes with 0.6 opacity
- Gem selector: Black background with 0.9 opacity
- Button states: Orange (active), Grey (disabled)

### Animation Philosophy
- Spring animations for character attacks
- Ease-in-out for health changes
- Scale + opacity for popups
- All durations: 0.2-0.4 seconds

### Layout Strategy
- Geometry-based responsive sizing
- Percentage-based heights (42% battle, 58% board)
- Fixed-size UI elements (buttons, badges)
- Z-index layering for overlays

---

## 🚀 PLANNED FEATURES (Not Yet Implemented)

**ALL ITEMS BELOW ARE PLANNING PHASE - DISCUSSED BUT NOT CODED YET**

Quick Reference: [Feature #1: LLM Narratives](#feature-1-dynamic-battle-narratives-with-llm) | [Feature #2: Curse Mechanic](#feature-2-hidden-cursepoison-mechanic-minesweeper-style) | [Feature #3: Combat Systems](#feature-3-advanced-combat-systems) | [Feature #4: Character Animations](#feature-4-character-animation-system) | [Feature #5: Code-Based Effects](#feature-5-code-based-animation-system-zero-assets)

---

### Feature #1: Dynamic Battle Narratives with LLM

**Concept**: Replace hardcoded battle messages with Apple's on-device AI for infinite variety.

**How It Works**:
1. Define tone/style instructions (heroic, humorous, concise)
2. Battle events trigger prompts to LLM instead of random array selection
3. LLM generates contextually appropriate messages
4. Every playthrough has unique narratives

**Technical Requirements**:
- iPhone 15 Pro+ or M1+ Mac/iPad (Apple Intelligence devices)
- Fallback to hardcoded messages for older devices
- ~0.5-2 second response time per message

**Files to Create/Modify**:
- Create: `BattleNarrator.swift` (handles LLM session)
- Modify: `BattleManager.swift` (call LLM instead of hardcoded arrays)
- Modify: `BattleEvent.swift` (receives LLM-generated text)

**Reference**: Discussed in chat about making battle text dynamic and contextual.

---

### Feature #2: Hidden Curse/Poison Mechanic (Minesweeper-Style)

**Concept**: Hidden "cursed" tiles on the board that damage the player when matched (like hitting a mine).

**Core Mechanics**:
- Tiles have hidden `isCursed: Bool` property
- Matching over a cursed tile = 5 HP damage to player
- Visual: Subtle purple glow OR completely invisible (difficulty setting)
- Spawn rate: 5-10% of tiles at any time
- Curses respawn when board refills

**Advanced Ideas Discussed**:

**A. Curse Chains**
- Multiple curses in one match = escalating damage
- Formula: First curse = 5 HP, each additional = +2 HP
- Example: 3 curses in one match = 5 + 2 + 2 = 9 HP damage
- Narrative: "CURSE CHAIN x3! -9 HP!"

**B. Curse Types** (Different Effects)
- 💀 Death Curse: Direct damage (5 HP)
- 🔥 Flame Curse: Damage + burns adjacent gems (locked 1 turn)
- 🧊 Freeze Curse: Locks a random column (can't swap 1 turn)
- 🌀 Chaos Curse: Randomizes 3x3 area of gems

**C. Curse Vision Ability**
- New coffee cup option (costs 3 mana)
- Reveals all curses on board for 3 moves
- Glowing purple outlines appear

**D. Cleansing Mechanic**
- Matching Heart gems adjacent to curse removes it safely
- No damage taken, curse disappears
- Narrative: "❤️ PURIFIED! Curse removed!"

**E. Curse Meter UI**
- Display: "⚠️ Curses: 6/8" at top of screen
- When full (8), next curse is a "Boss Curse" (double damage)
- Creates urgency to clear curses

**F. Enemy Curse Attacks**
- Enemy can cast "Dark Hex" to spawn curses
- Narrative: "Ednar curses the battlefield! 3 new curses appear!"

**Files to Modify**:
- `Tile.swift` or `TileType.swift`: Add `isCursed: Bool` property
- `BoardManager.swift`: Curse placement logic, reveal methods
- `BattleManager.swift`: Curse damage processing
- `GameBoardView.swift`: Visual indicators, explosion animations
- `GameConfig.swift`: Curse spawn rates, damage values

**Complexity**: Medium (2-3 hours core + 3-5 hours per advanced feature)

**Reference**: Discussed as minesweeper-style mechanic for strategic depth.

---

### Feature #3: Advanced Combat Systems

**Three Major Subsystems**: Enemy Spells | Board Manipulation | Chain Effects

---

#### 3A. Enemy Spell Casting System

**Concept**: Enemy has a "spell deck" with different effects instead of just dealing damage.

**Spell Meter Mechanic**:
- Meter fills 10-20% each player turn
- At 100%, enemy casts a spell
- Player can SEE it charging (creates tension)
- Visual warning at 80%: "⚠️ EDNAR PREPARES A SPELL!"

**Example Spells**:

**🔥 Swamp Fire** (Direct Damage)
- Effect: 8 damage to player
- Visual: Flames erupt across board (code-based animation)
- Narrative: "🔥 Swamp fire scorches you! -8 HP!"

**💀 Death's Touch** (Curse + Damage)
- Effect: Spawns 5 curses on board + 5 damage
- Visual: Skulls rain down onto random tiles
- Narrative: "💀 The board is cursed! -5 HP!"

**🛡️ Ribbit Shield** (Defensive)
- Effect: Enemy gains 10 shield
- Visual: Cyan bubble around enemy portrait
- Narrative: "🛡️ Ednar croaks defensively! +10 shield!"

**⚡ Mana Drain** (Resource Attack)
- Effect: Steals 3 mana from player
- Visual: Blue wisps flow from player to enemy
- Narrative: "⚡ Your power drains away! -3 mana!"

**🌀 Temporal Chaos** (Board Disruption)
- Effect: All tiles shift down one row (wraparound)
- Visual: Board spins/rotates animation
- Narrative: "🌀 Reality bends! The board shifts!"

**Visual Sequence for Spell Cast**:
1. Enemy portrait pulses with colored glow (spell type indicator)
2. Spell name appears in large text: "TOAD'S CURSE"
3. Spell effect animates (1-2 seconds)
4. Battle narrative updates
5. Player sees result

---

#### 3B. Enemy Board Manipulation

**Concept**: Enemy actively changes the board state during combat.

**Manipulation Abilities**:

**Toxic Hex** (Every 3 turns)
- Spawns 3 random curses on board
- Visual: Green skulls materialize on tiles
- Narrative: "💀 Ednar hexes the battlefield!"

**Gem Transmutation** (Every 5 turns)
- Converts all of one gem type to another (e.g., all Swords → Poison)
- Visual: Tiles shimmer and change color
- Narrative: "🔮 Your weapons turn to venom!"

**Chaos Shuffle** (Reactive - when player gets 5+ combo)
- Randomly swaps 10-15 tiles
- Visual: Whirlwind effect across board
- Narrative: "🌪️ Ednar disrupts your combo flow!"

**Column Freeze** (Every 4 turns)
- Locks 1-2 columns (can't swap tiles for 2 turns)
- Visual: Ice overlay on frozen columns
- Narrative: "🧊 Frozen solid! Column locked!"

---

#### 3C. Chain Combo Special Effects

**Concept**: High combo counts (4+) trigger spectacular effects beyond damage multipliers.

**4-Chain: "Power Surge"**
- **Effect**: +2 bonus mana (on top of normal rewards)
- **Visual**: 
  - Golden lightning strikes across board
  - Extra particle explosions from matched tiles
  - "⚡ POWER SURGE!" text floats up
- **Narrative**: "⚡ 4-CHAIN! Power surges through you! +2 mana!"
- **Board Effect**: Shockwave ripples from matches

**5-Chain: "Critical Strike"**
- **Effect**: Double damage + stun enemy (skip next spell)
- **Visual**:
  - Screen flash white
  - Slow-motion tile cascade (1 second)
  - Massive "CRITICAL!" text across screen
  - Camera shake
  - Enemy portrait recoils/staggers
- **Narrative**: "💥 5-CHAIN CRITICAL! DEVASTATING BLOW! Enemy stunned!"
- **Board Effect**: All tiles glow with combo's gem color

**6-Chain: "Divine Intervention"**
- **Effect**: Triple damage + 5 mana + cleanse all curses + 10 shield
- **Visual**:
  - Golden light beams from top of screen
  - 2-second pause
  - Angel wing particles around player
  - "✨ DIVINE CHAIN ✨" in massive glowing text
- **Narrative**: "✨ 6-CHAIN DIVINE STRIKE! The gods smile upon you!"
- **Board Effect**: Curses explode and vanish, new tiles guaranteed curse-free

**7+ Chain: "Apocalypse Combo"** (Legendary - game-winning)
- **Effect**: 4x damage + full mana (7/7) + full health + enemy loses all shield
- **Visual**:
  - Complete game pause
  - White → black → color explosion sequence
  - "LEGENDARY CHAIN" in animated flaming text
  - Background changes to swirling energy vortex
  - Fireworks across entire screen
- **Narrative**: "🌟 LEGENDARY 7-CHAIN! UNSTOPPABLE POWER!"

**UI Enhancements Needed**:
- Enemy spell meter (below enemy health bar)
- Status effect icons (frozen columns, debuffs)
- Chain counter during combos: "Current Chain: x3 ⚡⚡⚡"
- Active effects display: "🧊 Column 3 Frozen (1 turn left)"

**Files to Create**:
- `EnemySpellManager.swift` - Spell deck, meter, spell logic
- `ChainEffectsManager.swift` - Detect chains, trigger effects
- `BoardStatusEffects.swift` - Track frozen columns, debuffs

**Files to Modify**:
- `BattleManager.swift` - Integrate spell system, check chain thresholds
- `BattleSceneView.swift` - Enemy spell meter UI, status displays
- `GameBoardView.swift` - Frozen overlays, chain flash effects
- `GameConfig.swift` - Spell timing, chain thresholds

**Complexity**: High (~20-30 hours total)

**Reference**: Discussed as complete combat overhaul with enemy AI and player combo rewards.

---

### Feature #4: Character Animation System

**Four Implementation Options** (increasing complexity):

---

#### Option 1: Portrait Expression Swap ⭐ RECOMMENDED

**Concept**: Character portrait changes based on action (like a flipbook).

**Images Needed** (per character):
1. `character_idle.png` - Neutral expression
2. `character_attack.png` - Aggressive/striking
3. `character_hurt.png` - Damage/pain
4. `character_defend.png` - Shielding
5. `character_spell.png` - Casting magic
6. `character_victory.png` - Triumphant
7. `character_defeat.png` - Knocked out

**Total**: 7 images per character × 2 characters (Ramp + Ednar) = **14 images**

**Specifications**:
- Format: PNG with transparency
- Dimensions: 512x512 pixels (or 1024x1024 for retina)
- Resolution: 72 DPI minimum, 144 DPI recommended
- Aspect Ratio: 1:1 (square)
- File Size: <500KB each
- Color Space: sRGB

**Naming Convention**:
```
Assets.xcassets/
├─ ramp_idle.imageset/
├─ ramp_attack.imageset/
├─ ramp_hurt.imageset/
├─ ramp_defend.imageset/
├─ ramp_spell.imageset/
├─ ramp_victory.imageset/
├─ ramp_defeat.imageset/
├─ ednar_idle.imageset/
└─ (repeat for Ednar)
```

**How It Works**:
- Character has `currentState` property (enum: idle/attack/hurt/etc.)
- Portrait displays image based on state
- State changes trigger fade transitions (0.2s opacity animation)
- Auto-return to idle after action completes

**Transition Timing**:
- Attack → Idle: 0.3 seconds
- Hurt → Idle: 0.5 seconds
- Defend → Idle: 0.4 seconds
- Spell → Idle: 0.6 seconds

**Files to Modify**:
- `Character.swift`: Add `var currentState: CharacterState` enum
- `CharacterPortrait` (BattleSceneView.swift): Use state-based image names
- `BattleManager.swift`: Set states during battle events

**Complexity**: Low (1-2 hours coding + art time)

---

#### Option 2: Spritesheet Animation

**Concept**: Full motion animation using multiple frames per action.

**Spritesheet Structure**:
- One large PNG containing all frames in a grid
- OR individual frame files (easier to create)

**Frame Counts** (per character):
- Idle: 4-6 frames (breathing loop)
- Attack: 4-8 frames (wind up → strike → follow through)
- Hurt: 2-3 frames (recoil → recover)
- Defend: 3-4 frames (shield up → hold)
- Spell: 6-10 frames (gather → cast → release)
- Victory: 4-6 frames (celebration)
- Defeat: 3-5 frames (collapse)

**Total**: ~30-45 frames per character

**Specifications**:
- Individual Frame Size: 256x256 pixels
- Total Spritesheet: 2048x1024 pixels (8 columns × 4 rows example)
- Resolution: 144 DPI
- File Size: ~2MB per spritesheet

**Frame Rates**:
- Idle: 6-8 FPS (slow, subtle)
- Attack: 12-16 FPS (fast, snappy)
- Hurt: 12 FPS (quick)
- Spell: 10-12 FPS (deliberate)

**Files to Create**:
- `SpriteAnimator.swift` - Custom view for playing sprite animations

**Complexity**: Medium (4-6 hours coding + significant art time)

---

#### Option 3: Lottie/Vector Animation

**Concept**: Vector-based animations exported as JSON (After Effects workflow).

**Animations Needed** (per character):
- Same 7 states as Option 1, but as JSON files
- Example: `ramp_attack.json`, `ednar_spell.json`

**Total**: 7 JSON files per character = **14 files**

**Specifications**:
- Format: .json (Lottie) or .riv (Rive)
- File Size: 10-100KB per animation
- Scalability: Infinite (vector)

**Tools Required**:
- Adobe After Effects + Lottie plugin
- OR Rive animation tool

**Integration**:
- Requires `Lottie` library via Swift Package Manager
- URL: `https://github.com/airbnb/lottie-ios`

**Pros**:
✅ Incredibly smooth
✅ Very small file sizes
✅ Scalable to any resolution
✅ Easy to update (replace JSON)

**Cons**:
⚠️ Requires animation software knowledge
⚠️ External dependency
⚠️ Learning curve

**Complexity**: Medium-High (2-3 hours coding + animation learning curve)

---

#### Option 4: Full-Body Character Animation

**Concept**: Show entire character with limb movement, weapon swings (JRPG-style).

**Frame Requirements**:
- Frame Size: 512x512 pixels (larger to show full body + weapon arcs)
- Frame Count: 50-80 frames per character
  - Idle: 6 frames
  - Attack: 12 frames (full sword swing arc)
  - Spell: 15 frames (hand gestures, energy)
  - Hurt: 4 frames
  - Defend: 6 frames
  - Victory: 8 frames
  - Defeat: 10 frames

**Total Spritesheet**: 5120x4096 pixels (LARGE!)

**Layout Changes Required**:
- Current: 42% battle scene, 58% board
- Full-Body: 60% battle scene, 40% board (shrink board)

**Attack Animation Arc** (12 frames example):
1. Ready stance
2-3. Wind up (pull weapon back)
4-5. Swing begins (body rotates)
6-7. Impact point (weapon at target, flash)
8-9. Follow through
10-11. Recovery
12. Return to idle

**Complexity**: Very High (8-12 hours coding + extensive art time)

---

**Upgrade Path** (Recommended):
1. Start with portrait swaps (easiest)
2. Add particle effects (sword slashes, glows)
3. Upgrade to spritesheets (smooth motion)
4. Expand to full-body (if desired)

**Reference**: Discussed as progressive enhancement system for character visuals.

---

### Feature #5: Code-Based Animation System (Zero Assets)

**Core Concept**: Build 95% of visual effects using pure SwiftUI code without any image assets.

**What's Possible 100% in Code**:

---

#### Spell Visual Effects (Code-Based)

**🔥 Fire Spell** (Swamp Fire)
- **Elements**: 20+ colored circles with gradients
- **Colors**: Red → Orange → Yellow gradient
- **Animation**: Circles rise upward (offset y: 0 → -200) and fade (opacity: 1 → 0)
- **Effect**: Blur radius 5 for glow
- **Code**: ForEach creating circles, each with random size/position, staggered delays

**💀 Curse Spell** (Toxic Hex)
- **Elements**: Purple gradient wave + skull emoji particles
- **Wave**: Rectangle with LinearGradient (clear → purple → clear)
- **Animation**: Scale (0.5 → 1.5) + opacity (1 → 0) over 1 second
- **Skulls**: Text("💀") with random positions, rotating + falling
- **Code**: Rectangle + ForEach Text with offset/rotation animations

**🛡️ Shield Spell** (Ribbit Shield)
- **Elements**: Expanding circular rings
- **Rings**: Circle().stroke() with cyan/blue gradient
- **Animation**: Scale (1.0 → 2.5) + opacity (1 → 0)
- **Effect**: Multiple rings at different timings for ripple effect
- **Code**: ForEach Circle with scaleEffect animation

**⚡ Mana Drain**
- **Elements**: Blue orbs (circles with radial gradients)
- **Animation**: Offset x: -100 (player side) → +100 (enemy side)
- **Colors**: Center blue → edge cyan → transparent
- **Effect**: 10 particles with staggered timing
- **Code**: ForEach Circle with RadialGradient + offset animation

**🌀 Chaos Shuffle** (Whirlwind)
- **Elements**: 3 spinning spiral rings
- **Shape**: Circle.trim(from: 0, to: 0.7) - partial circles
- **Animation**: Continuous rotation (0° → 360° repeating)
- **Colors**: Purple, different sizes/speeds for depth
- **Code**: ForEach Circle trim with rotation animation

**🧊 Column Freeze** (Ice Lock)
- **Elements**: Blue/cyan gradient overlay + diamond ice crystals
- **Overlay**: Rectangle with LinearGradient (shimmer effect)
- **Animation**: Gradient position animates (top → bottom repeat)
- **Crystals**: Custom Diamond shape (4-point star)
- **Code**: Rectangle + custom Shape in overlay, animated gradient

---

#### Chain Combo Effects (Code-Based)

**⚡ 4-Chain Power Surge**
- **Elements**: Golden screen flash + lightning bolts
- **Flash**: Rectangle, yellow opacity 0.3, fade out
- **Lightning**: Custom zigzag Path (6 segments)
- **Animation**: Lightning appears with shadow glow
- **Code**: Rectangle + custom Path with stroke + shadow

**💥 5-Chain Critical Strike**
- **Elements**: White screen flash + giant text
- **Flash**: Rectangle, white, full opacity → 0 in 0.3s
- **Text**: "CRITICAL!" size 80, gradient fill (red → orange → yellow)
- **Animation**: Spring scale (0.5 → 1.2) for impact
- **Code**: Rectangle + Text with LinearGradient + scaleEffect

**✨ 6-Chain Divine Intervention**
- **Elements**: Golden light beams + particle explosion + text
- **Beams**: Rectangles from top, yellow with blur
- **Particles**: Circles scattering outward (random trajectories)
- **Text**: "✨ DIVINE CHAIN ✨" massive glowing
- **Code**: ForEach Rectangle (beams) + ForEach Circle (particles) + Text

**🌟 7+ Chain Legendary**
- **Elements**: Color sequence + fireworks + vortex
- **Sequence**: White Rectangle → Black Rectangle → Color explosion
- **Fireworks**: Circles with random trajectories + trails
- **Vortex**: AngularGradient rotating continuously
- **Code**: Sequential Rectangle transitions + ForEach particles + rotating gradient

---

#### SwiftUI Animation Toolkit Reference

**Shapes** (all code, no images):
```swift
Circle()
Rectangle()
RoundedRectangle(cornerRadius:)
Capsule()
Ellipse()
Path() // Custom shapes (lightning, diamonds, etc.)
```

**Visual Effects**:
```swift
.fill(Color.red)
.fill(LinearGradient(...))    // Directional color blend
.fill(RadialGradient(...))    // Circular color blend
.fill(AngularGradient(...))   // Rainbow/spinning effects
```

**Transforms**:
```swift
.offset(x:, y:)      // Move position
.scaleEffect()       // Grow/shrink
.rotationEffect()    // Spin
.blur(radius:)       // Glow/soft edges
.opacity()           // Fade in/out
```

**Animations**:
```swift
.animation(.easeInOut(duration:))           // Smooth
.animation(.spring(response:, damping:))    // Bouncy
.animation(.linear(duration:).repeatForever()) // Continuous
```

**Advanced**:
```swift
.overlay { }              // Layer on top
.background { }           // Layer behind
.shadow(color:, radius:)  // Drop shadows and glows
.blendMode(.screen)       // Additive blending (bright effects)
```

---

#### When Assets ARE Needed

**1. Character Portraits** (for different states)
- Can use emoji as temporary placeholders: 😠 🗡️ 😫 🛡️ ✨
- Custom art recommended for polish

**2. Spell Icons** (UI buttons)
- Can use SF Symbols: `bolt.fill`, `flame.fill`, `shield.fill`
- Or emoji: 💫 ✨ 🌟 ⚡ 🔥

**3. Particle Textures** (optional enhancement)
- Smoke wisps, spark trails
- Can fake with blurred circles initially

**4. Sound Effects** (audio files)
- Not visual, add later

---

#### Implementation Phases

**Phase 1: Pure Code Animations** ⭐ START HERE
- Implement all spell effects using shapes/gradients
- Use emoji for temporary variety (💀🔥⚡🛡️)
- Screen flashes, geometric shapes, text overlays
- **Result**: Fully functional with impressive visuals, ZERO art assets

**Phase 2: Add Character Portrait States**
- 7 images per character (Option 1 from Feature #4)
- Keep all spell effects code-based

**Phase 3: Polish with Optional Assets**
- Custom particle textures if desired
- Sound effects library
- Professional spell icons

**Phase 4: Advanced Assets** (optional)
- Animated spritesheets (Option 2 from Feature #4)
- High-res particle effects
- Voice acting / music

---

#### Technical Implementation Notes

**Files to Create**:
- `SpellEffectViews.swift` - All spell visual components
  - FireSpellEffect, CurseSpellEffect, ShieldSpellEffect, etc.
- `ChainComboEffects.swift` - Chain combo visuals
  - PowerSurgeEffect, CriticalStrikeEffect, etc.
- `BoardManipulationEffects.swift` - Board overlays
  - ChaosShuffleEffect, FrozenColumnOverlay, etc.

**Files to Modify**:
- `BattleSceneView.swift` - Add spell effect overlay layer (z-index)
- `GameBoardView.swift` - Add board manipulation overlays
- `BattleManager.swift` - Trigger effect displays
- `GameViewModel.swift` - Coordinate effect timing

**Animation Timing**:
- Charge up: 0.5-1.0 seconds
- Spell cast: 1.0-1.5 seconds
- Impact/flash: 0.2-0.4 seconds
- Chain combos: 1.5-2.5 seconds (more dramatic)

**Performance Tips**:
- Use `.drawingGroup()` for complex particles (renders to bitmap)
- Limit particle count (20-30 max per effect)
- Remove from view hierarchy after animation completes
- Use `.transition()` for smooth appear/disappear

**Benefits**:
✅ Zero art asset dependency - build immediately
✅ Easy iteration - tweak colors/timing instantly
✅ Small file sizes - no images to load
✅ Scalable - looks sharp on any screen
✅ Maintainable - all logic in Swift code

**Limitations**:
⚠️ Code-based effects have "generic" look initially
⚠️ Complex particles can impact performance
⚠️ Some effects (realistic fire/smoke) look better with textures

**Reference**: Discussed as complete alternative to asset-based VFX, enabling rapid prototyping.

---

## 🚀 NEXT STEPS / TODO

- All planned features documented above
- Ready to implement any feature when user decides
- User will specify which feature to build next

---

## 💡 CRITICAL INSTRUCTIONS FOR AI - READ FIRST

### 🚨 USER EXPERIENCE LEVEL

**THE USER HAS ZERO CODING KNOWLEDGE - TREAT THEM LIKE A COMPLETE BEGINNER**

### ✅ MANDATORY REQUIREMENTS FOR EVERY CODE CHANGE

**1. ALWAYS Provide Complete, Copy-Paste Ready Code**
- ❌ NEVER give partial code snippets or say "add this line here"
- ✅ ALWAYS give the ENTIRE file or ENTIRE function to replace
- ✅ Include clear "replace THIS with THAT" instructions
- ✅ Show exactly where to paste (file name, line numbers if possible)

**2. ALWAYS Give Step-by-Step Xcode Instructions**

Example format:
```
STEP 1: Open the file
- Look at the left sidebar in Xcode (Project Navigator)
- Find and click on "BattleSceneView.swift"

STEP 2: Find what to replace
- Press Command+F (or Edit menu → Find)
- Search for "struct CharacterPortrait"
- Click the first result

STEP 3: Replace the code
- Click inside the code block
- Select everything from "struct CharacterPortrait {" to the closing "}"
- Delete it
- Paste this new code: [FULL CODE HERE]

STEP 4: Save and test
- Press Command+S to save
- Press Command+R to run the app
- Test by: [specific test instructions]
```

**3. ALWAYS Explain in Simple Language**
- ❌ Don't say: "Refactor the Observable macro with binding semantics"
- ✅ Do say: "This changes how the app tracks when things update"
- ✅ Use analogies when possible
- ✅ Explain what the user will SEE change in the app

**4. ALWAYS Update This Context File**

**AFTER EVERY SINGLE CHANGE YOU MAKE:**

Update these sections:
- **"Recent Changes"** - Add new entry with date/description
- **"What Works"** - Add new working features
- **"Known Issues"** - Add any new bugs or problems
- **"File Status Tracker"** - Update modified files
- **"Component Reference"** - Add new components

**Format for logging changes:**
```
### Session X: [Feature Name]

**Date**: [Date]
**Changes Made**:
1. File 1: What changed and why
2. File 2: What changed and why

**New Features**:
- Feature A now does X
- Feature B was added

**What Works Now**:
✅ Thing 1
✅ Thing 2

**Known Issues** (if any):
⚠️ Issue 1
⚠️ Issue 2

**Files Modified**:
- File1.swift (lines X-Y)
- File2.swift (lines A-B)
```

### 📋 CODE STYLE REQUIREMENTS

**Must Use:**
- Swift + SwiftUI only (no UIKit unless absolutely necessary)
- @Observable macro (not @ObservableObject)
- @Bindable for passing observable objects
- async/await (not Combine or Dispatch unless required)
- SF Symbols for icons (e.g., "heart.fill", "shield.fill")

**Naming:**
- Clear, descriptive names
- camelCase for variables/functions
- PascalCase for types/structs

### 🔄 WORKFLOW FOR EVERY NEW CHAT

**When a new conversation starts:**
1. ✅ Read this ENTIRE AI_CONTEXT.md file first
2. ✅ Check "Recent Changes" for latest updates
3. ✅ Check "Known Issues" before suggesting solutions
4. ✅ Check "File Status Tracker" to see what was modified when
5. ✅ Reference existing patterns in "Component Reference"

**When the user asks for changes:**
1. ✅ Provide complete code (never snippets)
2. ✅ Give step-by-step Xcode instructions
3. ✅ Explain in simple language what changes
4. ✅ Update this context file immediately after
5. ✅ Test mentally: "Could someone with zero coding knowledge follow this?"

### 🎯 LIVING DOCUMENT PROTOCOL

**This file is a LIVING DOCUMENT that must be updated constantly:**

✅ Every feature added → Log it  
✅ Every bug fixed → Log it  
✅ Every file changed → Log it  
✅ Every new component → Document it  
✅ Every UI change → Document measurements/colors  
✅ Every mechanic change → Update game mechanics section  

**Goal**: Any AI in a future chat should be able to read this file and know:
- What the game currently does
- What's been tried and worked
- What's been tried and failed
- What's planned but not implemented
- Exact specifications of every UI element
- Complete history of changes

### ⚠️ COMMON MISTAKES TO AVOID

❌ Assuming user knows Xcode keyboard shortcuts  
❌ Giving partial code and saying "merge this with existing code"  
❌ Using technical jargon without explanation  
❌ Forgetting to update this context file  
❌ Not testing instructions mentally before giving them  
❌ Referencing line numbers without showing what's there  
❌ Saying "just add this function" without showing where  

### ✅ QUALITY CHECKLIST BEFORE RESPONDING

Before submitting ANY code change, verify:

- [ ] Is the code COMPLETE and copy-pasteable?
- [ ] Are Xcode instructions step-by-step for a beginner?
- [ ] Is everything explained in simple language?
- [ ] Did I update the context file with changes?
- [ ] Would someone with zero coding knowledge understand this?
- [ ] Did I test this mentally to ensure it works?

**If any checkbox is unchecked, revise your response.**

---

## 📊 FILE STATUS TRACKER

| File | Last Modified | Status | Notes |
|------|---------------|--------|-------|
| ChainComboEffects.swift | Session 4 | ✅ Working | Blue diagonal lightning + particles effect |
| GameAssets.swift | Session 3 | ✅ Working | Added Power Surge config toggles |
| BattleManager.swift | Session 3 | ✅ Working | Detects 4+ matches, triggers Power Surge |
| GameViewModel.swift | Session 3 | ✅ Working | Controls Power Surge timing and flag reset |
| ContentView.swift | Session 3 | ✅ Working | Displays Power Surge effect overlay (z:500) |
| BattleSceneView.swift | Session 1 | ✅ Working | Gem selector removed, coffee button centered |
| GameBoardView.swift | Initial | ✅ Working | Not modified yet |

---

**Last Updated**: Session 4 - Custom Blue Lightning Effect
**Status**: All systems operational! ONE massive diagonal blue lightning bolt with particles! ⚡💙
