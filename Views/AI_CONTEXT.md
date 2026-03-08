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

---

## ❌ KNOWN ISSUES

- None currently reported

---

## 🔧 RECENT CHANGES

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

## 🚀 NEXT STEPS / TODO

- Ready for gameplay feature development
- User will specify next feature to implement

---

## 💡 IMPORTANT NOTES FOR AI

1. **User Experience Level**: User knows NOTHING about coding
   - Always provide complete, copy-paste ready code
   - Explain what changed and why
   - Use simple, non-technical language when possible

2. **Code Style Preferences**:
   - Swift + SwiftUI only
   - Use @Bindable for ObservableObject properties
   - Prefer async/await over Combine/Dispatch
   - Use SF Symbols for icons when possible

3. **Update Protocol**:
   - After EVERY change, update this file
   - Document what was changed
   - Document what works now
   - Document any new issues
   - Update the "Recent Changes" section

4. **When Starting New Chat**:
   - Read this entire file first
   - Reference the current state before making suggestions
   - Check "Known Issues" before proposing solutions

---

## 📊 FILE STATUS TRACKER

| File | Last Modified | Status | Notes |
|------|---------------|--------|-------|
| BattleSceneView.swift | Session 1 | ✅ Working | Gem selector removed, coffee button centered |
| ContentView.swift | Session 1 | ✅ Working | Popup positioned below coffee button (0.44) |
| GameViewModel.swift | Initial | ✅ Working | Not modified in Session 1 |
| BattleManager.swift | Initial | ✅ Working | Not modified in Session 1 |
| GameBoardView.swift | Initial | ✅ Working | Not modified in Session 1 |

---

**Last Updated**: Session 1 - Gem Selector Positioning Fix
**Status**: All systems operational, ready for new features
