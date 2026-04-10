# SHOP OF ODDITIES CONTEXT
**OverQuestMatch3 - Ednar's Shop of Oddities (Card Repair Game)**

> **Created:** April 4, 2026  
> **Last Updated:** April 9, 2026 (Major layout optimization - balanced approach)  
> **Game Status:** ✅ COMPLETE & FULLY PLAYABLE - Ready for custom artwork  
> **Game Type:** Miracle Merchant-style Card Solitaire

---

## 🎯 GAME OVERVIEW

**Game Name:** Ednar's Shop of Oddities  
**Genre:** Card-based solitaire puzzle game  
**Inspired By:** Miracle Merchant  
**Platform:** iOS (SwiftUI)

### **Core Concept:**
You run Ednar's repair shop, fixing broken magical items for customers by drafting component cards from four different decks. Each repair requires exactly 4 cards (one opportunity to draw from each deck), and you must meet the customer's requirements while maximizing your score through strategic card placement.

### **Win Condition:**
- Serve all 13 customers successfully
- Each repair must include at least one card of the customer's required type
- Final repair score must be positive (> 0)

### **Lose Condition:**
- Fail a single repair (missing required type OR negative total score)
- Game ends immediately

---

## 📁 PROJECT STRUCTURE

**Location:** `ShopOfOddities/` folder (same level as Match3Game, PhysicsChainGame)

```
ShopOfOddities/
├─ Data Models (7 files) ✅
│  ├─ ComponentType.swift (4 component deck types)
│  ├─ ComponentCard.swift (Individual card data + deck generation)
│  ├─ Customer.swift (Customer data + queue generation + public portrait helper)
│  ├─ RepairSlot.swift (4 repair slots for card placement)
│  ├─ RepairResult.swift (Scoring calculation + repair name generation)
│  ├─ ShopGameState.swift (Main game logic and state management + debug forcing)
│  └─ CommentaryManager.swift (Character commentary system)
│
└─ UI Components (11 files) ✅
   ├─ ShopOfOdditiesView.swift (Main game screen with debug button)
   ├─ ShopSceneView.swift (3-layer scene composite with slide-in animation) ✨ UPDATED (April 6, 2026)
   ├─ ComponentCardView.swift (Visual card component)
   ├─ DeckView.swift (Deck display with top card + flip animation) ✨ UPDATED (April 6, 2026)
   ├─ RepairSlotView.swift (Visual repair slot with animations)
   ├─ CustomerView.swift (Customer display panel with custom portraits)
   ├─ RepairResultOverlay.swift (Success popup after repair)
   ├─ ShopGameOverOverlay.swift (Win/lose screen with stats)
   ├─ NewRepairDiscoveredBanner.swift (New repair notification banner)
   ├─ CommentaryView.swift (Character commentary display with custom icons)
   └─ AssetsDebugView.swift (Debug menu for testing custom assets + character forcing) ✨ NEW
```

---

## 🎮 GAME MECHANICS

### **The Four Component Decks:**

Each deck has **13 cards** (52 total in the game):
- **10 normal cards** with values 1-4
- **3 cursed cards** with negative values (-1 to -3)

| Deck Type | Color | Icon | Description |
|-----------|-------|------|-------------|
| **Structural** | Brown/Amber | Hammer | Physical repair materials (wood, iron, stone) |
| **Enchantment** | Blue/Purple | Sparkles | Magical energy (runes, spell fragments, arcane dust) |
| **Memory** | Gold/Yellow | Brain | Emotional/identity components (echoes, impressions, residue) |
| **Wildcraft** | Green | Leaf | Improvised/scavenged materials (Ednar specials, weird stuff) |

### **Card Properties:**

Each card has:
- **Type:** Which deck it belongs to
- **Value:** Points (1-4 for normal, negative for cursed)
- **Name:** Flavor text (e.g., "Oak Plank", "Whispered Echo", "Gremlock Spit")
- **Adjacency Bonus (30% chance):** If placed next to a card of a specific type, gain +2 bonus points
- **Cursed Status:** Visual indicator and negative value

### **Customer Requirements:**

Each customer has:
- **Name:** Character name (includes OverQuest characters!)
- **Item:** What they brought to repair
- **Required Type:** MUST include at least one card of this type or repair fails
- **Preferred Type:** Bonus points (+3 per card) for including this type
- **Portrait:** SF Symbol placeholder (future custom asset)
- **Dialogue:** Arrival, success, and failure lines

---

## 🎲 GAMEPLAY FLOW

### **Game Structure:**
1. Game starts with 13 customers in queue
2. Each round, you see the current customer and preview the next customer
3. All 4 decks show their top card (face-up, like Miracle Merchant)
4. You draw 4 cards total (one from each deck, in any order)
5. Cards are placed left-to-right in 4 repair slots
6. When all 4 slots filled, repair is evaluated automatically
7. Success → Score points, serve next customer
8. Failure → Game over immediately
9. Serve all 13 customers → You win!

### **Scoring System:**

**Base Score:**
```
Total Score = Σ(card values) + adjacency bonuses + preferred type bonuses
```

**Adjacency Bonuses:**
- If a card has an adjacency requirement (shown as small icon on card)
- And it's placed next to a card of that type (left or right neighbor)
- Add +2 points per adjacency match

**Preferred Type Bonus:**
- Customer has a preferred component type
- +3 points for each card of that type in the repair

**Example Scoring:**
```
Cards: [Structural +3] [Enchantment +2] [Memory +1] [Wildcraft -1]
Adjacency: Structural wants Enchantment (neighbor!) → +2
Preferred: Customer likes Memory → +3
Total: 3 + 2 + 1 + (-1) + 2 + 3 = 10 points ✓
```

### **Repair Success Conditions:**

✅ **Successful Repair:**
- Contains at least one card of the customer's required type
- Total score > 0

❌ **Failed Repair (Game Over):**
- Missing the required type
- OR total score ≤ 0

---

## 🏆 REPAIR NAME GENERATION

Each repair gets a generated name based on the card combination. These names are collected in the **Repair Ledger** (persistent across games).

### **Repair Name Rules:**

| Pattern | Repair Name | Example |
|---------|-------------|---------|
| All same type (4) | "Pure [Type] Restoration" | "Pure Structural Restoration" |
| All different types (1+1+1+1) | "Rainbow Repair" | "Rainbow Repair" |
| Three of one + one other (3+1) | "Triple [Type] Fix" | "Triple Enchantment Fix" |
| Two pairs (2+2) | "Duplex Mend" | "Duplex Mend" |
| Two of one + two different (2+1+1) | "Twin [Type] Patch" | "Twin Memory Patch" |
| All Wildcraft | "Ednar's Gambit" | (special name) |
| All Memory | "Memory Palace" | (special name) |

### **Quality Prefixes:**

- **"Masterwork"** → 0 cursed cards AND all adjacency bonuses activated
- **"Risky"** → 2+ cursed cards
- **No prefix** → All other cases

**Examples:**
- "Masterwork Rainbow Repair"
- "Risky Triple Wildcraft Fix"
- "Pure Memory Restoration"

---

## 📊 DATA MODELS

### **1. ComponentType.swift**

**Purpose:** Defines the 4 component deck types

**Properties:**
- `displayName` → "Structural", "Enchantment", etc.
- `color` → SwiftUI Color for visual identity
- `iconName` → Custom icon image asset name (e.g., "structural-icon") ✨
- `cardImageName` → Custom card background image asset name (e.g., "card-structural") ✨ NEW
- `lightColor` → Tinted background color
- `darkColor` → Border/accent color

### **2. ComponentCard.swift**

**Purpose:** Individual card data and deck generation logic

**Properties:**
- `id: UUID` → Unique identifier
- `type: ComponentType` → Which deck
- `value: Int` → Point value (1-4 or negative)
- `isCursed: Bool` → True for negative cards
- `adjacencyBonus: ComponentType?` → Bonus requirement
- `name: String` → Flavor name

**Key Functions:**
- `generateDeck(for:)` → Creates a shuffled 13-card deck
- Card name pools (normal + cursed variants)

**Card Distribution per Deck:**
- 3× value +1
- 3× value +2
- 2× value +3
- 2× value +4
- 1× cursed -1
- 1× cursed -2
- 1× cursed -3

### **3. Customer.swift**

**Purpose:** Customer data and queue generation

**Properties:**
- `id: UUID`
- `name: String` → Character name
- `itemName: String` → What they brought
- `requiredType: ComponentType` → Must include
- `preferredType: ComponentType` → Bonus points
- `portraitName: String` → SF Symbol (future custom asset)
- `arrivalLine` → Dialogue when they appear
- `satisfiedLine` → Dialogue on success
- `failedLine` → Dialogue on failure

**Key Functions:**
- `generateCustomerQueue(count:)` → Creates 13 random customers

**OverQuest Characters Included:**
- Bakasura
- Noamron
- Gremlock #12, #47, #203
- Traveling Merchant
- Retired Soldier
- Newcomer Family
- The Baker
- Ramp (Found It!)

### **4. RepairSlot.swift**

**Purpose:** Represents one of the 4 repair slots

**Properties:**
- `id: UUID`
- `index: Int` → Position (0-3)
- `card: ComponentCard?` → Nil until filled

**Array Extensions:**
- `firstEmptySlot` → Find next available slot
- `allFilled` → Check if all 4 slots have cards
- `filledCount` → How many cards placed
- `cards` → Array of non-nil cards

### **5. RepairResult.swift**

**Purpose:** Calculates repair outcome and generates names

**Properties:**
- `id: UUID`
- `slots: [RepairSlot]` → The 4 filled slots
- `customer: Customer` → Who the repair is for

**Computed Properties:**
- `totalScore: Int` → Full score calculation
- `meetsRequirement: Bool` → Has required type?
- `isSuccessful: Bool` → Meets requirement AND score > 0
- `repairName: String` → Generated name

**Scoring Logic:**
1. Sum all card base values
2. Check each card's adjacency bonus
3. Add +2 for each activated adjacency
4. Add +3 for each preferred type card
5. Return total

**Name Generation Logic:**
1. Count card types used
2. Check for special patterns (all same, all different, etc.)
3. Determine quality prefix (Masterwork, Risky, or none)
4. Combine pattern + prefix → final name

### **6. ShopGameState.swift**

**Purpose:** Main game state manager (@Observable)

**Properties:**
- `decks: [ComponentType: [ComponentCard]]` → All 4 decks
- `repairSlots: [RepairSlot]` → The 4 repair slots
- `customers: [Customer]` → Customer queue
- `currentCustomer: Customer?` → Active customer
- `nextCustomer: Customer?` → Preview next customer
- `score: Int` → Running total
- `customersServed: Int` → Count of successful repairs
- `repairsCompleted: [RepairResult]` → History
- `discoveredRepairNames: Set<String>` → Persistent collectible catalog
- `gameOver: Bool`
- `gameOverReason: String?`

**Key Functions:**

**startNewGame()**
- Generates and shuffles 4 decks (13 cards each)
- Creates 4 empty repair slots
- Generates 13 customers
- Resets score and state

**drawCard(from: ComponentType)**
- Takes top card from specified deck
- Places in next empty repair slot
- Prints debug info

**canDraw(from: ComponentType) -> Bool**
- Checks if deck has cards remaining
- Checks if repair slots not full

**topCard(of: ComponentType) -> ComponentCard?**
- Returns visible top card of a deck

**completeRepair() async**
- Validates all slots filled
- Creates RepairResult
- Calculates score
- Checks success/failure
- If success: Add points, clear slots, next customer
- If failure: Game over immediately

**advanceToNextCustomer()**
- Removes current customer from queue
- Sets new current/next customers
- If no customers left → You win!

**Helper Functions:**
- `clearRepairSlots()` → Empty all slots
- `totalCardsRemaining()` → Cards left across all decks
- `cardsRemaining(in:)` → Cards in specific deck
- `discoveredRepairNamesCount` → Collectible count

---

## 🎨 DESIGN SPECIFICATIONS

### **Color Palette:**

| Component | Color (RGB) | Usage |
|-----------|-------------|-------|
| Structural | (0.6, 0.4, 0.2) | Brown/Amber theme |
| Enchantment | (0.4, 0.3, 0.8) | Blue/Purple theme |
| Memory | (0.9, 0.7, 0.2) | Gold/Yellow theme |
| Wildcraft | (0.3, 0.7, 0.3) | Green theme |

Each color has:
- Base color (full opacity)
- Light color (30% opacity for backgrounds)
- Dark color (darker variant for borders)

### **Custom Asset System:** ✨ UPDATED (April 5, 2026)

The game now supports custom images for a fully polished visual experience!

**Icon Images (card corners and adjacency indicators):**

| Component Type | Image Asset Name | Where Used |
|----------------|------------------|------------|
| Structural | `structural-icon` | Card top icons, adjacency indicators |
| Enchantment | `enchantment-icon` | Card top icons, adjacency indicators |
| Memory | `memory-icon` | Card top icons, adjacency indicators |
| Wildcraft | `wildcraft-icon` | Card top icons, adjacency indicators |

**Card Background Images (full card art):**

| Component Type | Image Asset Name | Where Used |
|----------------|------------------|------------|
| Structural | `card-structural` | Background of all structural cards |
| Enchantment | `card-enchantment` | Background of all enchantment cards |
| Memory | `card-memory` | Background of all memory cards |
| Wildcraft | `card-wildcraft` | Background of all wildcraft cards |
| **Cursed** ✨ | **`card-cursed`** | **Background of all cursed cards (negative value)** |

**Customer Portrait Images (character faces):**

| Character | Image Asset Name | Where Used | Status |
|-----------|------------------|------------|--------|
| Bakasura | `customer-bakasura` | Customer panel (70×70pt circle) | ✅ ADDED |
| Noamron | `customer-noamron` | Customer panel (70×70pt circle) | ✅ ADDED |
| Gremlock #12 | `customer-gremlock-12` | Customer panel | 📋 Future |
| Gremlock #47 | `customer-gremlock-47` | Customer panel | 📋 Future |
| Gremlock #203 | `customer-gremlock-203` | Customer panel | 📋 Future |
| Merchant | `customer-merchant` | Customer panel | 📋 Future |
| Soldier | `customer-soldier` | Customer panel | 📋 Future |
| Generic | `customer-generic` | Customer panel (fallback) | 📋 Future |

**Commentary Character Icons (dialogue speakers):**

| Character | Image Asset Name | Where Used | Status |
|-----------|------------------|------------|--------|
| Sword | `commentary-sword` | Commentary box (30×30pt circle) | ✅ ADDED |
| Ednar | `commentary-ednar` | Commentary box (30×30pt circle) | 📋 Future |

**Scene Images (shop environment + customer scenes):** ✨ NEW (April 6, 2026)

| Image Type | Image Asset Name | Where Used | Status |
|------------|------------------|------------|--------|
| **Shop Layers** | | | |
| Table Background | `shop-table-bg` | Full-screen background texture | 📋 Optional |
| Shop Background | `shop-background` | Scene layer 1 (static shop interior) | 📋 Planned |
| Shop Foreground | `shop-foreground` | Scene layer 3 (Ednar + Sword) | 📋 Planned |
| **Customer Scenes** | | | |
| Bakasura | `scene-bakasura` | Scene layer 2 (customer with item) | 📋 Planned |
| Noamron | `scene-noamron` | Scene layer 2 | 📋 Planned |
| Gremlock #12 | `scene-gremlock-12` | Scene layer 2 | 📋 Planned |
| Gremlock #47 | `scene-gremlock-47` | Scene layer 2 | 📋 Planned |
| Gremlock #203 | `scene-gremlock-203` | Scene layer 2 | 📋 Planned |
| Merchant | `scene-merchant` | Scene layer 2 | 📋 Planned |
| Soldier | `scene-soldier` | Scene layer 2 | 📋 Planned |
| Family | `scene-family` | Scene layer 2 | 📋 Planned |
| Baker | `scene-baker` | Scene layer 2 | 📋 Planned |
| Ramp | `scene-ramp` | Scene layer 2 | 📋 Planned |
| Wizard | `scene-wizard` | Scene layer 2 | 📋 Planned |
| Guard | `scene-guard` | Scene layer 2 | 📋 Planned |
| Farmer | `scene-farmer` | Scene layer 2 | 📋 Planned |
| Blacksmith | `scene-blacksmith` | Scene layer 2 | 📋 Planned |
| Generic | `scene-generic` | Scene layer 2 (fallback) | 📋 Planned |

**Image Specifications:**
- **Icons:** 100×100 px minimum (draw at 1024×1024px), square aspect ratio
- **Card Backgrounds:** 400×615 px (draw at 2000×3075px), portrait orientation (0.65 aspect ratio)
- **Customer Portraits:** 200×200 px (draw at 1024×1024px or 2048×2048px), square (displayed as circle) — DEPRECATED in favor of scene images
- **Commentary Icons:** 100×100 px (draw at 1024×1024px), square (displayed as circle)
- **Scene Images:** 1200×1000 px or higher (draw at 2400×2000px), portrait/square ~1.2:1 aspect ratio ✨ NEW
  - Background/foreground layers: Full scene width, slightly taller than wide
  - Customer scenes: Character positioned in center/right, holding item
  - All scene images should use same dimensions for consistency
  - Portrait-oriented or nearly square (NOT landscape 16:9!)
- **Format:** PNG files added to Assets.xcassets
- **Integration:** Plug-and-play — images automatically replace SF Symbols when named correctly

**Drawing Workflow:**

**For Regular Assets (Icons, Cards):**
1. Create canvas at larger size (2-10× bigger) in Procreate/art app
2. Draw artwork at high resolution
3. Export and resize to final dimensions
4. Save with exact asset name (lowercase, hyphens only)
5. Add to Assets.xcassets in Xcode

**For Scene Images (3-Layer Composite):** ✨ NEW (April 6, 2026)

**Step 1: Set Up Canvas**
- Create canvas: **2400×2000 px** (1.2:1 ratio) in Procreate
- DPI: 300
- Color profile: Display P3 or sRGB

**Step 2: Create All 3 Layers**
Create 3 separate layer groups or canvases:

1. **Background Layer (`shop-background`):**
   - Draw shop interior (shelves, window, walls, floor)
   - This is your static environment
   - Save as `shop-background.png`

2. **Customer Layer (`scene-[customer]`):**
   - Draw customer character holding their broken item
   - Position anywhere in the frame (full width available)
   - Leave space for foreground elements
   - Save as `scene-noamron.png` (or whatever customer)
   - **Create one for EACH customer** (15 total)

3. **Foreground Layer (`shop-foreground`):**
   - Draw Ednar and Sword in the foreground
   - Maybe counter edge, hanging objects, etc.
   - Creates depth and frames the scene
   - Save as `shop-foreground.png`

**Step 3: Alignment Tips**
- Draw all 3 on the same canvas with layers, OR
- Use guides to mark key positions (counter edge, character placement)
- Export each layer separately
- All 3 will composite perfectly since they're the same dimensions!

**Step 4: Export**
- Resize to **1200×1000 px** each
- Save as PNG with transparency (if needed)
- Name exactly: `shop-background`, `scene-noamron`, `shop-foreground`

**Step 5: Add to Xcode**
- Drag PNG files into Assets.xcassets
- Verify names are exact (lowercase, hyphens, no spaces)

**Step 6: Test**
1. Run game (Command+R)
2. Tap wrench 🔧 to open debug menu
3. Scroll to "Scene Images" section
4. **Tap the customer scene thumbnail** (e.g., "Noamron")
5. Debug menu closes, customer is forced
6. See your 3-layer composite in the game immediately!
7. Check console for debug output:
   ```
   🔍 Looking for scene asset: scene-noamron
   🔍 Image exists: true
   ✅ Loaded scene image: scene-noamron - Size: (1200.0, 1000.0)
   ```

**Customer Portrait SF Symbols (fallback when custom image not found):**

| Element | SF Symbol Fallback |
|---------|---------------------|
| Bakasura | figure.martial.arts |
| Noamron | figure.walk |
| Gremlock | ant.fill |
| Merchant | cart.fill |
| Default Customer | person.fill |

### **UI Design Philosophy:** ✨ UPDATED (April 6, 2026)

**Minimalist, Image-First Design:**
- **No bounding boxes** around cards or decks
- **No header bars** on deck displays
- **Invisible repair slots** until cards are placed
- **Full-bleed card images** as primary visual elements
- **Clean shadows** for depth (no borders or outlines)
- **Side-by-side deck layout** (4 decks horizontal, not 2×2 grid)
- **Scene-based character display** (not portraits)
- **3-layer composite scenes** for depth and immersion
- **Full-screen background texture** for ambient setting

**Visual Hierarchy:**
1. Scene artwork is the primary focus (largest visual element - 38% height)
2. Card artwork and deck displays (30% height with fanned arc)
3. Repair area (16% height with larger card slots)
4. Customer info and score bar (functional UI elements)
5. Character commentary (contextual dialogue)
6. Minimal labels (only where necessary)

**Fanned Deck System:** ✨ NEW (April 6, 2026)
- **Rotation:** Each deck rotates to create arc (-12°, -4°, +4°, +12°)
- **Ghost Cards:** Behind each deck, faded cards show depth
  - 3+ cards → 2 ghost cards
  - 2 cards → 1 ghost card
  - 1 card → No ghosts
- **Card Count:** Badge below each deck shows cards remaining
- **Tap Target:** Entire deck card is tappable (including ghosts)
- **Visual Cohesion:** Creates hand-of-cards aesthetic

---

## 🔧 TECHNICAL IMPLEMENTATION

### **SwiftUI + Swift Concurrency:**
- `@Observable` for game state (iOS 17+) ✅
- `async/await` for repair completion timing ✅
- Value types (structs) for all data models ✅
- Class for game state management ✅

### **Animation System:** ✨ UPDATED (April 6, 2026)

**Card Flip Animation (DeckView.swift):**
- **State:** `@State private var isFlipping: Bool = false`
- **Effect:** `.rotation3DEffect(.degrees(isFlipping ? 90 : 0), axis: (x: 0.0, y: 1.0, z: 0.0))`
- **Timing:** 0.15s ease-in animation
- **Flow:**
  1. User taps deck
  2. `isFlipping` set to `true` → Card rotates to 90° + fades out
  3. After 0.15s, `onTap()` callback fires (draws card)
  4. `isFlipping` reset to `false` → New card appears
- **Visual:** Smooth 3D horizontal flip with perspective depth
- **Why:** Eliminates "weird visual effect" of instant card replacement

**Character Slide-In Animation (ShopSceneView.swift):**
- **Transition:** `.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity)`
- **Animation:** `.spring(response: 0.5, dampingFraction: 0.8)`
- **Flow:**
  1. Customer changes (repair completes)
  2. Old customer fades out (`.opacity` removal)
  3. New customer slides in from right (`.trailing`) + fades in
  4. Spring physics creates subtle bounce effect
- **Visual:** Natural entrance like customer walking into shop
- **Why:** More engaging than simple fade, feels alive

**Current Animation Parameters:**
- Card flip speed: 0.15s (adjustable via `duration` parameter)
- Character slide response: 0.5s (how long animation takes)
- Character bounce: 0.8 dampingFraction (0.5 = bouncy, 1.0 = no bounce)
- All animations use `.easeInOut` or `.spring` for smooth motion

### **Layout & Geometry:**
- **Dual Geometry Reading for Edge-to-Edge Overlays:** ✨ NEW (April 6, 2026)
  - Parent view (`ShopOfOdditiesView`) has `.padding(.horizontal, 12)`
  - Scene view is inset by 12pt on each side
  - **Customer info overlay uses TWO width measurements:**
    - Text HStack: `.frame(width: geometry.size.width)` → Respects parent padding
    - Background: `.frame(width: UIScreen.main.bounds.width)` → Full screen width
    - Background uses `.edgesIgnoringSafeArea(.horizontal)` to extend past padding
  - Result: Background stretches edge-to-edge while text stays properly padded
  - This technique allows elements to "break out" of parent padding constraints

### **Animations:**
- Card placement: 0.3s spring animation (scale 0.5→1.0, fade in) ✅
- **Card flip animation:** 3D horizontal flip when drawing from deck ✅ NEW (April 6, 2026)
  - 0.15s ease-in rotation to 90° (edge-on)
  - Fades out during flip
  - New card appears after callback
- **Character entrance animation:** Slide-in from right with spring bounce ✅ NEW (April 6, 2026)
  - `.move(edge: .trailing)` combined with `.opacity`
  - Spring animation: response 0.5, dampingFraction 0.8
  - Smooth, natural customer arrival
- Repair resolution: 0.5s delay before evaluation ✅
- Result overlay: 1.5s display duration ✅
- New repair banner: 1s display duration ✅
- Commentary display: 2s display duration with fade in/out ✅
- Overlay transitions: Scale + opacity combined ✅

**Future Animation Enhancement (Planned):**
- **Variance-based character animations** using mathematical mapping
- 3-4 different entrance animations (slide-right, slide-left, fade-scale, bounce-up)
- Hash-based selection from customer name → consistent per-customer
- Provides visual variety without manual per-customer mapping
- Potential approaches: modulo rotation, weighted random, story progression, personality types

### **Character Commentary System:** ✨ NEW
- `CommentaryManager.swift` manages all dialogue lines ✅
- Triggered by game events (card draws, repairs, customers) ✅
- Random selection from dialogue pools ✅
- 2-second display duration with smooth fade animations ✅
- Kill switch for easy disable (`commentaryEnabled` flag) ✅
- Sword and Ednar commentary alternates/weighted 50/50 ✅
- Easily extensible (add more lines to arrays) ✅

### **Persistence:**
- UserDefaults for discovered repair names ✅
- Survives across game sessions ✅
- Set-based tracking (no duplicates) ✅
- Collectible catalog feature ✅

### **Custom Image Assets:** ✨ UPDATED (April 5, 2026)
- Custom icon images for all 4 component types ✅
- Custom card background images for 4 component types + cursed variant (5 total) ✅
- Cursed cards use dedicated `card-cursed` background instead of overlay ✅
- Customer portrait support (Bakasura, Noamron added; 6 more planned) ✅
- Commentary icon support (Sword added; Ednar planned) ✅
- Image assets automatically loaded from Assets.xcassets ✅
- Plug-and-play integration with SF Symbol fallbacks ✅
- Text shadows added for readability over custom images ✅
- Icon images sized properly (12×12 in UI, resizable) ✅
- Card images fill card backgrounds with aspect ratio maintained ✅
- Text shadows added for readability over custom backgrounds ✅
- Icon images sized properly (12×12 in UI, resizable) ✅
- Card images fill card backgrounds with aspect ratio maintained ✅

### **Print Debugging:**
All major actions print to console:
- Game start ✅
- Card draws ✅
- Repair completion ✅
- Success/failure ✅
- Customer changes ✅

### **No External Dependencies:**
- Pure Swift + SwiftUI ✅
- Custom image assets for icons and cards ✅
- SF Symbols for UI elements (customer portraits, etc.) ✅
- No third-party frameworks ✅

---

## 📝 IMPLEMENTATION CHECKLIST

### ✅ **COMPLETED (April 4, 2026):**

**Data Models:**
- [x] Created ShopOfOddities/ folder
- [x] Added .shopOfOddities to GameType enum
- [x] Created ComponentType.swift (4 deck types)
- [x] Created ComponentCard.swift (card data + generation)
- [x] Created Customer.swift (customer data + generation)
- [x] Created RepairSlot.swift (repair slot management)
- [x] Created RepairResult.swift (scoring + name generation)
- [x] Created ShopGameState.swift (main game logic)
- [x] Created CommentaryManager.swift (character dialogue system) ✨ NEW

**UI Components:**
- [x] Created ShopOfOdditiesView.swift (main game screen)
- [x] Created ComponentCardView.swift (card visual display with custom images) ✨ UPDATED
- [x] Created DeckView.swift (deck with top card and custom icons) ✨ UPDATED
- [x] Created RepairSlotView.swift (slot with animations)
- [x] Created CustomerView.swift (customer info panel)
- [x] Created RepairResultOverlay.swift (success popup)
- [x] Created ShopGameOverOverlay.swift (win/lose screen)
- [x] Created NewRepairDiscoveredBanner.swift (notification banner)
- [x] Created CommentaryView.swift (character commentary display) ✨ NEW

**Features:**
- [x] Card drafting system (tap decks to draw)
- [x] Card placement animations (scale + fade, 0.3s)
- [x] Repair auto-resolution (0.5s delay after 4th card)
- [x] Adjacency bonus calculation (left + right neighbors)
- [x] Preferred type bonus calculation (+3 per card)
- [x] Repair result overlay (shows for 1.5 seconds)
- [x] New repair discovery notification (shows for 1 second)
- [x] Character commentary system (Sword + Ednar reactions) ✨ NEW
- [x] Commentary triggers for cursed cards, high values, repairs, customers ✨ NEW
- [x] Commentary kill switch for easy disable ✨ NEW
- [x] Game over/win screens with detailed stats
- [x] Play Again functionality (resets game)
- [x] Persistent repair catalog (UserDefaults)
- [x] Score tracking and display
- [x] Customer queue management (13 customers)
- [x] Repair name generation (16+ unique patterns)
- [x] Custom image asset integration (icons + card backgrounds) ✨ NEW (April 5, 2026)
- [x] Customer portrait support with UIImage loading ✨ NEW (April 5, 2026)
- [x] Commentary icon support with UIImage loading ✨ NEW (April 5, 2026)
- [x] Debug menu with asset viewer and character forcing ✨ NEW (April 5, 2026)
- [x] Text shadows for readability over custom images ✨ NEW

**All code compiles with no errors** ✅  
**Game is fully playable** ✅  
**Documentation complete** ✅  
**Debug tools available** ✅ ✨ NEW

---

## 🎮 USER INTERFACE

### **Screen Layout (Portrait):** ✨ UPDATED (April 9, 2026 - Layout Optimization)

```
┌─────────────────────────────────────────┐
│══⭐ 123     👤 5/13         🔧══════════│ ← Score bar (5% height) EDGE-TO-EDGE
│                                         │
│      [Shop Scene Illustration]          │ ← Scene View (38% height) PRESERVED
│      (3-layer composite + overlay)      │   Background + Customer + Foreground
│      Customer: Bakasura                 │   + Semi-transparent info box
│      Cracked Shield                     │   NO GAP ABOVE (touches score bar)
│      Required: 🔨  Preferred: ✨        │
│                                         │
├─────────────────────────────────────────┤
│   [Character Commentary Area]           │ ← Commentary (4% height) SHRUNK
├─────────────────────────────────────────┤
│   ~~~~ GAP (3.5%) ~~~~                  │ ← Gap reduced for compactness
├─────────────────────────────────────────┤
│                                         │
│   [CARD] [CARD] [CARD] [CARD]          │ ← Repair area (20% height) BIGGER!
│                                         │   Invisible slots until filled
├─────────────────────────────────────────┤
│   ~~~~ GAP (3%) ~~~~                    │ ← Gap reduced (decks moved up)
├─────────────────────────────────────────┤
│                                         │
│  👻 [DECK]  [DECK]  [DECK]  [DECK] 👻  │ ← 4 fanned decks (36% height) BIGGER!
│     ↑       ↑       ↑       ↑          │   12pt spacing (doubled!)
│   -12°     -4°     +4°     +12°        │   NO LABEL (removed)
│    13      13      13      13          │   Ghost cards + count badges
│                                         │
└─────────────────────────────────────────┘
```

### **Scene Composite System:** ✨ NEW (April 6, 2026)

The game uses a 3-layer composited scene system for immersive character display:

**Layer 1 - Shop Background:**
- Image: `shop-background`
- Static (never changes)
- Shows shop interior (shelves, windows, etc.)
- Full width of scene view
- Dimensions: 1200×1000 px (1.2:1 aspect ratio)

**Layer 2 - Customer Scene:**
- Image: `scene-[customer]` (e.g., `scene-bakasura`, `scene-noamron`)
- Changes with each customer (fade transition)
- Shows customer holding their broken item
- Position: Anywhere in the scene (full-width composite)
- Dimensions: 1200×1000 px (same as background/foreground)
- **Loads dynamically** based on customer name mapping

**Layer 3 - Shop Foreground:**
- Image: `shop-foreground`
- Static (never changes)
- Shows Ednar + Sword in foreground
- Creates depth and framing
- Dimensions: 1200×1000 px (same as background/customer)

**Customer Info Overlay:** ✨ UPDATED (April 6, 2026 - Edge-to-edge fix)
- Semi-transparent black box at bottom of scene (0.7 opacity)
- Left side: Customer name (13pt bold) + Item name (10pt, 80% opacity)
- Right side: Required type icon (18×18, full color) + Preferred type icon (18×18, 60% opacity)
- 16pt horizontal padding, 10pt vertical padding
- **Edge-to-edge background:** Uses TWO separate width measurements
  - Text content: Uses `geometry.size.width` (respects parent 12pt padding)
  - Background: Uses `UIScreen.main.bounds.width` with `.edgesIgnoringSafeArea(.horizontal)`
  - This allows background to extend edge-to-edge while text stays properly padded
- Text scaling: `.minimumScaleFactor(0.7)` allows text to shrink if needed
- Renders via SwiftUI (not part of image files)
- Spacer with minLength ensures minimum gap between text and icons

**Scene Name Mapping:**
The system automatically maps customer names to scene asset names:
- "Bakasura" → `scene-bakasura`
- "Noamron" → `scene-noamron`
- "Gremlock #12" → `scene-gremlock-12` (extracts number)
- "Traveling Merchant" → `scene-merchant` (simplified)
- "The Baker" → `scene-baker` (removes "The")
- "Ramp (Found It!)" → `scene-ramp` (removes parentheses)
- Unmapped names → `scene-generic` (fallback)

**Fallback System:**
1. Try to load `scene-[customer]` (custom scene image)
2. If not found, try `customer-[customer]` (portrait circle - centered)
3. If not found, use SF Symbol (centered circle with icon)

**Debug Logging:**
The scene view prints to console for debugging:
```
🔍 Looking for scene asset: scene-noamron
🔍 Image exists: true
✅ Loaded scene image: scene-noamron - Size: (1200.0, 1000.0)
```

This helps verify images are loading correctly.

### **Design Changes (April 6, 2026):**

**Old Layout (Portrait + Separate Customer Panel):**
```
[70×70 Circle Portrait]
Bakasura - Cracked Shield
Required: 🔨  Preferred: ✨
```

**New Layout (Full Scene Illustration):**
```
┌───────────────────────────────┐
│  [Background Layer]           │
│    [Customer Scene Layer]     │
│      [Foreground Layer]       │
│  ┌─────────────────────────┐  │
│  │ Bakasura                │  │ ← Semi-transparent overlay
│  │ Cracked Shield          │  │
│  │ Required: 🔨  Preferred: ✨│  │
│  └─────────────────────────┘  │
└───────────────────────────────┘
```

**Key Differences:**
- ✅ Scene-based character display (not portraits)
- ✅ 3-layer compositing for depth and parallax potential
- ✅ Full-screen background texture (`shop-table-bg`)
- ✅ Customer info as overlay (not separate panel)
- ✅ Larger scene area (38% vs 20% height)
- ✅ Fanned deck arc with ghost cards
- ✅ Rotation angles: -12°, -4°, +4°, +12°
- ✅ Card count badges below decks

### **Interaction Flow:** ✅ FULLY IMPLEMENTED
1. Tap a deck to draw its top card
2. Card animates to next empty repair slot (0.3s scale + fade)
3. Deck shows new top card
4. When 4th card placed → Wait 0.5s → Auto-evaluate repair
5. Show result overlay with score breakdown (1.5s)
6. If new repair → Show discovery banner (1s)
7. If success → Clear slots, next customer appears
8. If failure → Game over screen with stats and Play Again button

---

## 🔧 DEBUG MENU ✨ NEW (April 5, 2026)

### **Accessing the Debug Menu:**

1. Run the game (Command+R)
2. Look for the **🔧 cyan wrench icon** in the top score bar
3. Tap the wrench to open the debug menu
4. Full-screen modal with multiple sections

### **Debug Menu Features:**

**1. End Game Button:** ✨ NEW (April 6, 2026)
- Located in top-left of navigation bar (red color)
- Icon: Arrow left circle + "End Game" text
- Returns to title screen when tapped
- Dismisses debug menu first, then dismisses game
- Proper cleanup of game state

**2. Character Forcing:**
- Grid of all 15 customer characters
- **Tap any character** to force them as the current customer
- Instantly see their scene image in the game (or fallback)
- Perfect for testing custom scene images
- Auto-closes after selection

**3. Customer Portraits Section:**
- View all 15 customer portrait assets (DEPRECATED - use Scene Images)
- Shows **✅ Custom** (green) if image found in Assets.xcassets
- Shows **⚠️ SF Symbol** (orange) if using fallback
- Current status:
  - ✅ Bakasura (custom image)
  - ✅ Noamron (custom image)
  - ⚠️ All others (SF Symbol fallbacks)

**4. Commentary Icons Section:**
- View both commentary character icons (Sword, Ednar)
- Current status:
  - ✅ Sword (custom image)
  - ⚠️ Ednar (SF Symbol fallback)

**5. Component Icons Section:**
- View all 4 component type icons
- All show ✅ Custom (structural, enchantment, memory, wildcraft)

**6. Card Backgrounds Section:**
- View all 5 card background images
- All show ✅ Custom (4 types + cursed variant)

**7. Scene Images Section:** ✨ NEW (April 6, 2026)
- View all scene-related assets
- **Shop Layers:** table-bg, shop-background, shop-foreground (not tappable)
- **Customer Scenes:** scene-bakasura, scene-noamron, etc. (15 total) **→ TAPPABLE!**
- **Tap any customer scene** to force that customer and see their scene image immediately
- Shows **✅ Custom** (green) if image found with thick green border
- Shows **⚠️ Missing** (orange) if not found
- Preview thumbnails in 1.2:1 aspect ratio
- Tappable scenes show hand tap icon in corner
- Perfect for testing scene compositing!

**8. Toggle:**
- "Show Only Custom Images" - hides missing placeholders
- Useful for seeing only completed assets

### **Debug Workflow:**

1. **Create asset in Procreate**
2. **Export and add to Assets.xcassets**
3. **Run game** (Command+R)
4. **Tap wrench** 🔧
5. **Verify asset shows ✅ green badge**
6. **Tap character to force them** (for portraits)
7. **See portrait in game immediately**
8. **Done!**

### **Technical Details:**

**Character Forcing:**
- Uses `ShopGameState.forceCustomer()` method
- Creates temporary customer with specified name
- Replaces current customer without affecting queue
- Portrait automatically loaded via `Customer.portraitIconPublic(for:)` helper

**Asset Detection:**
- Uses `UIImage(named:)` to check if asset exists
- Automatic fallback to SF Symbol if not found
- No crashes if images missing

---

## 🔍 DEBUGGING & TESTING

### **Console Output Examples:**

**Game Start:**
```
🏪 Starting new Shop of Oddities game...
   ✅ Game started! Customer 1: Bakasura
   📦 Total cards: 52
```

**Drawing Cards:**
```
   🃏 Drew Oak Plank (+3) → Slot 0
   🃏 Drew Arcane Dust (+2) → Slot 1
   🃏 Drew Whispered Echo (+1) → Slot 2
   🃏 Drew Gremlock Spit (-1) → Slot 3
   ✅ All slots filled! Ready to complete repair.
```

**Repair Completion:**
```
🔨 Completing repair for Bakasura...
   📊 Score: 8
   📝 Repair Name: Twin Structural Patch
   ✓ Meets Requirement: true
   ✓ Successful: true
   ✅ SUCCESS! Total score: 8
   👤 Next customer: Noamron
```

**Game Over (Failure):**
```
🔨 Completing repair for Gremlock #47...
   📊 Score: -2
   📝 Repair Name: Risky Duplex Mend
   ✓ Meets Requirement: true
   ✓ Successful: false
   ❌ FAILURE! Game Over. Reason: Negative repair score: -2
```

**Game Over (Victory):**
```
   🎉 ALL CUSTOMERS SERVED! Game Won!
```

### **Testing Completed:** ✅
- [x] Start new game
- [x] Draw cards from each deck
- [x] Complete successful repairs
- [x] Verify score increases
- [x] Check next customer appears
- [x] Test card animations
- [x] Test result overlay display
- [x] Test new repair banner
- [x] Test failed repair (game over)
- [x] Test winning condition (all 13 customers)
- [x] Check repair names in console
- [x] Verify discovered names persist
- [x] Test Play Again functionality
- [x] All game flows working correctly

---

## 🎯 DESIGN GOALS

### **Strategic Depth:**
- **Planning Ahead:** Preview next customer to optimize card choices
- **Risk Management:** Balance high-value cursed cards vs. safe low cards
- **Adjacency Optimization:** Arrange cards to activate bonuses
- **Preference Targeting:** Prioritize preferred types for bonus points

### **Replayability:**
- Random customer queue each game
- Random deck shuffles
- Discover all repair name combinations (collectible goal)
- Try to beat high score

### **Accessibility:**
- Clear visual indicators for required/preferred types
- Color-coded decks
- Simple tap-to-draw interaction
- Automatic repair evaluation (no complex inputs)

### **OverQuest Integration:**
- Familiar characters appear as customers
- Ednar's shop fits into OverQuest world lore
- Potential for story integration later
- Shared art assets (character portraits)

---

## 🎨 CUSTOM IMAGE ASSET SETUP

### **Required Image Assets:**

The game supports custom images for a polished, professional look. All images are loaded from Assets.xcassets.

**Total Assets Needed:** 8 images

### **Icon Images (4 files):**

These small icons appear in deck headers, card corners, and adjacency indicators.

| Asset Name | Component Type | Recommended Size | Used Where |
|------------|----------------|------------------|------------|
| `structural-icon` | Structural | 100×100 px | Deck headers, card top corners, adjacency bonuses |
| `enchantment-icon` | Enchantment | 100×100 px | Deck headers, card top corners, adjacency bonuses |
| `memory-icon` | Memory | 100×100 px | Deck headers, card top corners, adjacency bonuses |
| `wildcraft-icon` | Wildcraft | 100×100 px | Deck headers, card top corners, adjacency bonuses |

**Specifications:**
- Square aspect ratio (1:1)
- Transparent background recommended
- PNG format
- Will be tinted with component type colors
- Appears at 12×12 points in UI (scales automatically)

### **Card Background Images (4 files):**

These full images serve as the background for all cards of each type.

| Asset Name | Component Type | Recommended Size | Aspect Ratio |
|------------|----------------|------------------|--------------|
| `card-structural` | Structural | 400×600 px | 0.65 (portrait) |
| `card-enchantment` | Enchantment | 400×600 px | 0.65 (portrait) |
| `card-memory` | Memory | 400×600 px | 0.65 (portrait) |
| `card-wildcraft` | Wildcraft | 400×600 px | 0.65 (portrait) |

**Specifications:**
- Portrait orientation (width = 65% of height)
- PNG format
- Consider adding texture/patterns
- Text will overlay (card value, name, etc.) with shadows for readability
- Background fills entire card with aspect ratio maintained

### **Adding Images to Xcode:**

**Step-by-Step Instructions:**

1. **Prepare Images:**
   - Create or export all 8 images as PNG files
   - Name them exactly as shown in tables above
   - Ensure correct sizes and aspect ratios

2. **Add to Assets Catalog:**
   - Open Xcode project
   - In Project Navigator (left sidebar), find **Assets.xcassets**
   - Click on Assets.xcassets to open asset catalog
   - Drag all 8 PNG files into the asset catalog
   - Xcode creates image sets automatically

3. **Verify Names:**
   - Check that each image asset has the exact name from tables
   - If name is wrong: Right-click → Rename → Enter correct name
   - Names are case-sensitive and must match exactly

4. **Test:**
   - Set dev switcher to `.shopOfOddities`
   - Run app (Command+R)
   - Custom images should appear on cards and decks
   - If images don't appear, verify names and try clean build (Command+Shift+K, then Command+B)

### **Image Design Tips:**

**For Icons:**
- Simple, clear designs that work at small sizes
- High contrast for visibility
- Consider the component theme (hammer for Structural, sparkles for Enchantment, etc.)
- Transparent backgrounds allow color tinting

**For Card Backgrounds:**
- Add subtle textures or patterns
- Keep center area clearer for text readability
- Remember card value appears large in center
- Card name appears at bottom
- Cursed cards get red/black overlay
- Leave some visual breathing room for UI elements

### **Fallback Behavior:**

If custom images are not found in Assets.xcassets:
- **Cards:** Display as solid color gradients (fallback built-in)
- **Icons:** Display as SF Symbols (hammer.fill, sparkles, etc.)
- Game remains fully functional without custom assets

---

## 📚 RELATED FILES

**Project Structure:**
- `MASTER_CONTEXT.md` - Overall project documentation
- `STRUCTURE_CONTEXT.md` - Folder organization guide
- `OverQuestMatch3App.swift` - Dev switcher (line 25)

**Game-Specific Contexts:**
- `MATCH3_CONTEXT.md` - Match-3 RPG Battle documentation
- `PHYSICS_CONTEXT.md` - Physics Chain Game documentation

---

## 🔄 INTEGRATION WITH DEV SWITCHER

**Current Dev Switcher Status:**
```swift
enum GameType {
    case match3
    case physicsChain
    case shopOfOddities ✅ PLAYABLE!
    case cooking
    case potionSolitaire
    case mapNavigation
}
```

**To Play This Game:**
1. Open `OverQuestMatch3App.swift`
2. Change line 25 to: `private let currentGame: GameType = .shopOfOddities`
3. Press Command+R to run
4. ✅ **Game is fully playable!**

**Game Features Working:**
- ✅ Card drafting with tap interactions
- ✅ Animated card placement (scale + fade)
- ✅ Auto-resolution after 4th card
- ✅ Result overlay with repair name and score
- ✅ New repair discovery notifications
- ✅ Game over/win screens
- ✅ Play Again functionality
- ✅ Persistent collectible catalog

---

## 💡 FUTURE ENHANCEMENTS

### **Animation System Improvements (Planned):**

**Variance-Based Character Entrance Animations:**
- Multiple entrance animations that vary mathematically, not per-customer manually
- Goal: Visual variety without excessive manual mapping

**Potential Implementation Approaches:**

1. **Hash-Based Selection (Recommended):**
   - Hash customer name → Select from animation pool
   - Same customer always gets same animation (consistent)
   - Different customers get different animations (variety)
   - Simple to implement: `customerName.hash % animationPool.count`

2. **Modulo-Based Rotation:**
   - 3-4 animations: slide-right, slide-left, fade-scale, bounce-up
   - Customer index % 4 determines animation
   - Every 4th customer uses same type
   - Predictable pattern

3. **Weighted Random:**
   - 60% slide-in from right (most common)
   - 20% slide-in from left
   - 10% fade + scale (magical effect)
   - 10% bounce up (energetic)
   - Adds unpredictability

4. **Personality-Based Mapping:**
   - Aggressive characters → Fast slide-in
   - Calm characters → Gentle fade
   - Chaotic characters → Bounce/spring
   - Based on character archetype

5. **Story Progression:**
   - Early game (customers 1-5) → Simple fade
   - Mid-game (6-10) → Slide animations
   - Late game (11-13) → Dramatic effects
   - Builds excitement

**Why Hash-Based is Best:**
- ✅ Automatic variety without manual work
- ✅ Consistent per-customer (feels intentional)
- ✅ Easy to tweak animation pool
- ✅ No random unpredictability
- ✅ Simple implementation

### **Potential Gameplay Additions:**
- Special customer requests (e.g., "no cursed cards")
- Rare legendary cards with unique abilities
- Daily challenge mode
- Leaderboards
- Story mode with narrative progression
- Difficulty levels (adjust cursed card ratio)

### **Visual Polish:**
- Custom card artwork ✅ COMPLETE (April 5, 2026)
- Custom icon artwork ✅ COMPLETE (April 5, 2026)
- Cursed card background variant ✅ COMPLETE (April 5, 2026)
- Customer portrait support ✅ IN PROGRESS (2/8 added: Bakasura, Noamron)
- Commentary character icons ✅ IN PROGRESS (1/2 added: Sword)
- Shop background image 📋 PLANNED (can replace gradient)
- Particle effects for successful repairs (future enhancement)
- Character animations for customers (future enhancement)
- Enhanced card flip/draw animations (future enhancement)
- Repair name reveal effect with particles (future enhancement)
- Sound effects and background music (future enhancement)

### **Meta Progression:**
- Unlock new customers
- Unlock new card types
- Shop upgrades (Ednar's inventory improvements)
- Achievement system
- Statistics tracking (best score, repairs catalog completion %)

### **Integration with OverQuest:**
- Connect to map system (unlock after completing tutorial)
- Earn currency for other games
- Story cutscenes with Ednar
- Cross-game character appearances
- Rewards for completing repair collections

---

## 📊 GAME BALANCE NOTES

### **Math:**
- 52 total cards for 13 rounds (4 cards per round)
- Perfect use of all cards
- Average positive card value: ~2.5
- Average cursed card value: ~-2
- Adjacency bonuses provide ~20% score boost
- Preferred type bonuses provide ~30% score boost

### **Difficulty Curve:**
- Early rounds easier (more cards, more options)
- Late rounds harder (fewer cards, less flexibility)
- Cursed cards create risk/reward decisions
- Required types force strategic compromises

### **Fail Rate Target:**
- Goal: ~20-30% failure rate for average player
- High skill ceiling (100% completion possible)
- Low skill floor (beginners can complete ~50%)

---

## ✅ VERIFICATION

**All Data Model Files Created:** ✅ (7/7 files - added CommentaryManager)  
**All UI Component Files Created:** ✅ (9/9 files - added CommentaryView)  
**All Code Compiles:** ✅  
**Dev Switcher Updated:** ✅  
**Documentation Complete:** ✅  
**Game Fully Playable:** ✅  
**Animations Working:** ✅  
**Overlays Working:** ✅  
**Persistence Working:** ✅  
**Character Commentary Working:** ✅ ✨ NEW
**Custom Image Assets Integrated:** ✅ ✨ UPDATED (April 5, 2026)
**Cursed Card Background Support:** ✅ ✨ NEW
**Customer Portrait Support:** ✅ IN PROGRESS (2/8 added)
**Commentary Icon Support:** ✅ IN PROGRESS (1/2 added)
**Card Flip Animation:** ✅ ✨ NEW (April 6, 2026)
**Character Slide-In Animation:** ✅ ✨ NEW (April 6, 2026)
**All Features Implemented:** ✅  

**Status:** 🎉 **COMPLETE & READY TO PLAY!**

---

**Custom Assets Status (April 5, 2026):**

**Complete (9 assets):**
- ✅ 4 component type icons (structural, enchantment, memory, wildcraft)
- ✅ 5 card backgrounds (4 component types + cursed variant)

**In Progress (3 assets):**
- ✅ 2 customer portraits added (Bakasura, Noamron)
- ✅ 1 commentary icon added (Sword)

**Planned (7-8 assets):**
- 📋 6 more customer portraits (Gremlocks, Merchant, Soldier, Generic)
- 📋 1 more commentary icon (Ednar)
- 📋 1 shop background (optional - can replace gradient)

**Total Custom Assets:** 19-20 images planned (12 complete, 7-8 remaining)

**Code Updated for Custom Assets:**
- ComponentCardView.swift - Cursed card background support ✅
- CustomerView.swift - Portrait loading with UIImage ✅
- CommentaryView.swift - Icon loading with UIImage ✅
- Customer.swift - Custom portrait names (Bakasura, Noamron) ✅

**Asset Documentation:**
- PROCREATE_DIMENSIONS_AND_CURSED_CARD.md - Canvas sizes and workflow ✅
- See additional asset guides for complete specifications ✅

---

**END OF SHOP OF ODDITIES CONTEXT**

**Game Status:** Fully playable Miracle Merchant-style card game with character commentary and custom artwork  
**Total Files:** 18 files (7 data models + 11 UI components)  
**Total Lines of Code:** ~2,300 lines  
**Custom Assets:** 12 images complete (4 icons + 5 card backgrounds + 2 portraits + 1 commentary icon)  
**Remaining Assets:** 7-8 images (6 more portraits + 1 more commentary icon + optional shop background)

**Last Updated:** April 9, 2026 (Major layout optimization - balanced approach preserving scene size)  
**Implementation Time:** Single development session + commentary feature + custom image integration + UI redesign + scene composite system + overlay fix + animations + layout optimization  
**Status:** ✅ COMPLETE - Clean, minimalist design with image-first aesthetic, edge-to-edge layouts, polished animations, and optimized spacing

**Layout Optimization (April 9, 2026):** ✨ NEW

**Goals Achieved:**
1. ✅ Score bar background extends edge-to-edge (text stays centered)
2. ✅ Scene view touches score bar (removed 8pt gap)
3. ✅ Decks moved up closer to repair area (better use of space)
4. ✅ Decks and repair cards significantly bigger (more prominent)
5. ✅ Scene view preserved at 38% (no reduction)
6. ✅ "COMPONENT DECKS" label removed (cleaner minimalist look)

**Detailed Layout Changes:**

| Section | OLD % | NEW % | Change | Notes |
|---------|-------|-------|--------|-------|
| **Score Bar** | 5.0% | 5.0% | No change | ✨ Edge-to-edge background added |
| **Gap 1 (Score→Scene)** | 8pt | **REMOVED** | Deleted | Scene now touches score bar |
| **Scene View** | 38.0% | 38.0% | **PRESERVED** | Kept large as requested |
| **Gap 2 (Scene→Commentary)** | 8pt | 8pt | No change | Fixed padding |
| **Commentary** | 5.0% | **4.0%** | -1.0% | Slightly smaller but still readable |
| **Gap 3 (Commentary→Repair)** | 5.5% | **3.5%** | -2.0% | More compact |
| **Repair Area** | 17.7% | **20.0%** | +2.3% | ⬆️ Cards visibly bigger! |
| **Gap 4 (Repair→Decks)** | 6.0% | **3.0%** | -3.0% | ⬆️ Decks moved up significantly! |
| **Decks Area** | 30.0% | **36.0%** | +6.0% | ⬆️ Deck cards much bigger! |
| **Deck Spacing** | 6pt | **12pt** | +6pt | Doubled gap between deck cards |
| **Deck Label** | Shown | **REMOVED** | Deleted | "COMPONENT DECKS" text gone |
| **Gap 5 (Bottom)** | 8pt | 8pt | No change | Breathing room |

**Technical Implementation:**
- **Edge-to-edge score bar:** Uses ZStack with geometry-aware background that extends full screen width
- **Text positioning preserved:** Increased horizontal padding from 16pt → 28pt to compensate for removed VStack padding
- **Padding strategy change:** Removed `.padding(.horizontal, 12)` from VStack, applied individually to each section
- **Score bar function:** Changed from computed var to function accepting `GeometryProxy` for full-width calculation

**Visual Impact:**
- More immersive (score bar feels like true HUD overlay)
- Better space utilization (no wasted gaps)
- Bigger playable elements (decks and repair cards are the stars)
- Cleaner minimalist aesthetic (removed label clutter)
- Scene remains prominent focal point (38% preserved)
- Decks more accessible and visible (36% vs 30%)

**Net Percentage Change:** -1.0% - 2.0% + 2.3% - 3.0% + 6.0% = **+2.3%** (accommodated by removing fixed gaps)

**File Modified:** ShopOfOdditiesView.swift (complete rewrite of layout structure)

---

**UI Changes (April 5, 2026):**
- Removed all bounding boxes and borders from cards
- Removed deck headers (no names, icons, or counts displayed)
- Changed deck layout from 2×2 grid to side-by-side (1×4)
- Increased card size by 16% (35% vs 30% screen height)
- Made repair slots invisible until cards are placed
- Added subtle colored shadows for depth
- Minimalist, image-first design philosophy

**Scene System & Edge-to-Edge Layout (April 6, 2026):** ✨ UPDATED
- Created ShopSceneView.swift for 3-layer composite system
- Background, customer, and foreground layers with slide-in transitions
- **Character entrance animation:** Slide from right with spring bounce
- **Edge-to-edge overlay fix:** Customer info uses dual geometry reading
  - Text HStack respects parent padding (geometry.size.width)
  - Background extends full screen (UIScreen.main.bounds.width)
  - Background uses `.edgesIgnoringSafeArea(.horizontal)` to break out of parent padding
  - Result: Text properly padded, background stretches edge-to-edge perfectly

**Card Deck Animations (April 6, 2026):** ✨ NEW
- Created 3D flip animation for card drawing in DeckView.swift
- Horizontal flip (rotation3DEffect around Y-axis)
- 0.15s ease-in animation to 90° with fade-out
- New card appears after callback completes
- Smooth, polished interaction feel

**Custom Asset Integration (April 5, 2026):**
- Component icons and card backgrounds fully integrated ✅
- Cursed cards use dedicated `card-cursed` background ✅
- Customer portraits support added (2/8 complete: Bakasura, Noamron) ✅
- Commentary icons support added (1/2 complete: Sword) ✅
- All images have SF Symbol fallbacks (no crashes if missing) ✅
- Code updated: ComponentCardView.swift, CustomerView.swift, CommentaryView.swift, ShopSceneView.swift ✅
- Procreate workflow documented with canvas sizes ✅

