# SHOP OF ODDITIES - DEBUG MENU IMPLEMENTATION

**Date:** April 5, 2026  
**Feature:** Debug Menu with Asset Viewer + Character Forcing  
**Status:** ✅ COMPLETE & WORKING

---

## 🎯 OVERVIEW

Added a comprehensive debug menu to Shop of Oddities that allows:
1. **Visual inspection** of all custom image assets
2. **Character forcing** to test specific customer portraits
3. **Asset status tracking** (custom image vs SF Symbol fallback)
4. **Quick testing workflow** for new artwork

---

## 📁 FILES CREATED/MODIFIED

### **New Files Created (1):**

**AssetsDebugView.swift** (ShopOfOddities/)
- Full-screen debug menu
- Asset grid displays for all image types
- Character forcing buttons
- Asset status badges (✅ Custom / ⚠️ SF Symbol)
- Toggle to show only custom images

### **Files Modified (4):**

1. **ShopOfOdditiesView.swift**
   - Added cyan wrench button (🔧) in score bar
   - Added `@State private var showingAssetsDebug = false`
   - Connected button to `.sheet()` presentation
   - Passes `$gameState` binding to debug view

2. **Customer.swift**
   - Renamed `portraitIcon()` to `portraitIconPublic()`
   - Changed from `private static` to `static` (public)
   - Allows debug menu to access portrait name mapping

3. **ShopGameState.swift**
   - Added `forceCustomer(_ customer: Customer)` method
   - Replaces current customer for testing
   - Prints debug message to console

4. **CustomerView.swift + CommentaryView.swift**
   - Already had UIImage loading with fallbacks (from previous session)
   - No changes needed (already compatible)

---

## 🎨 DEBUG MENU FEATURES

### **1. Character Forcing Section**

**Purpose:** Force specific customers to appear for portrait testing

**How it Works:**
- Grid of all 15 customer characters
- Each shows portrait (custom image or SF Symbol)
- Tap any character → Becomes current customer immediately
- Debug menu auto-closes
- Perfect for testing new portraits

**Technical Implementation:**
```swift
private func forceCustomer(name: String) {
    // Create temporary customer with specified name
    let customer = Customer(
        name: name,
        itemName: "Test Item",
        requiredType: ComponentType.allCases.randomElement()!,
        preferredType: ComponentType.allCases.randomElement()!,
        portraitName: Customer.portraitIconPublic(for: name),
        arrivalLine: "This is a test customer!",
        satisfiedLine: "Thanks!",
        failedLine: "Oh no!"
    )
    
    // Replace current customer
    gameState.forceCustomer(customer)
    
    // Dismiss menu
    dismiss()
}
```

### **2. Customer Portraits Section**

**Purpose:** Visual inspection of all customer portrait assets

**Displays:**
- 15 customer portraits in 3-column grid
- 70×70pt circles (matching game size)
- Asset name below each portrait
- Status badge: ✅ Custom (green) or ⚠️ SF Symbol (orange)

**Current Status:**
- ✅ Bakasura (customer-bakasura.png)
- ✅ Noamron (customer-noamron.png)
- ⚠️ 13 others (SF Symbol fallbacks)

### **3. Commentary Icons Section**

**Purpose:** Visual inspection of commentary character icons

**Displays:**
- 2 commentary icons in 2-column grid
- 50×50pt (larger for visibility)
- Asset name + status badge

**Current Status:**
- ✅ Sword (commentary-sword.png)
- ⚠️ Ednar (SF Symbol fallback)

### **4. Component Icons Section**

**Purpose:** Visual inspection of component type icons

**Displays:**
- 4 component icons in 4-column grid
- 50×50pt with component color tint
- Asset name + status badge

**Current Status:**
- ✅ All 4 complete (structural, enchantment, memory, wildcraft)

### **5. Card Backgrounds Section**

**Purpose:** Visual inspection of card background images

**Displays:**
- 5 card backgrounds in 2-column grid
- Correct 0.65 aspect ratio
- Border with component color
- Asset name + status badge

**Current Status:**
- ✅ All 5 complete (4 types + cursed variant)

### **6. Toggle Feature**

**Purpose:** Filter view to only show custom images

**How it Works:**
- Toggle switch at top: "Show Only Custom Images"
- When ON: Hides all SF Symbol fallbacks
- When OFF: Shows everything
- Useful for seeing what's actually complete

---

## 🔧 TECHNICAL DETAILS

### **Asset Detection:**

Uses `UIImage(named:)` to check if custom image exists:

```swift
var hasCustomImage: Bool {
    UIImage(named: assetName) != nil
}
```

**Benefits:**
- ✅ Real-time detection (no hardcoding)
- ✅ Automatic status badges
- ✅ Works with any asset you add
- ✅ No manual updates needed

### **Character Forcing:**

**Flow:**
1. User taps character in debug menu
2. `forceCustomer(name:)` called with character name
3. Temporary `Customer` object created
4. `gameState.forceCustomer()` replaces current customer
5. Debug menu dismisses
6. Character appears in game immediately with their portrait

**Why it's Useful:**
- Test portraits without waiting for random customer
- See exact same character multiple times
- Quick iteration cycle for artwork

### **Binding Architecture:**

Debug menu receives `@Binding var gameState: ShopGameState`:

```swift
struct AssetsDebugView: View {
    @Binding var gameState: ShopGameState
    @Environment(\.dismiss) private var dismiss
    // ...
}
```

**Benefits:**
- Direct access to game state
- Can modify customer in real-time
- Changes reflect immediately in game

---

## 🎮 USER WORKFLOW

### **Testing New Portraits:**

1. **Create portrait in Procreate** (1024×1024px or 2048×2048px)
2. **Export as PNG** (resize to 200×200px)
3. **Name exactly** (e.g., "customer-gremlock-12")
4. **Drag into Assets.xcassets** in Xcode
5. **Run game** (Command+R)
6. **Tap wrench 🔧** in score bar
7. **Check portrait section** - should show ✅ Custom (green)
8. **Tap character** to force them as current customer
9. **See portrait in game** immediately!
10. **Iterate** if needed (update PNG, repeat from step 5)

### **Debugging Workflow:**

**Problem:** Portrait doesn't appear

**Debug Steps:**
1. Tap wrench 🔧
2. Check portrait section
3. If ⚠️ SF Symbol (orange):
   - Image not found in Assets.xcassets
   - Check spelling (case-sensitive!)
   - Verify image added to project
4. If ✅ Custom (green):
   - Image found successfully
   - Tap character to force them
   - Check if portrait displays correctly in game

---

## 📊 ASSET STATUS TRACKING

### **Complete (12 assets):**
✅ 4 component icons (100×100px)  
✅ 5 card backgrounds (400×615px)  
✅ 2 customer portraits (200×200px) - Bakasura, Noamron  
✅ 1 commentary icon (100×100px) - Sword  

### **Remaining (7-8 assets):**
📋 6 customer portraits - Gremlocks, Merchant, Soldier, etc.  
📋 1 commentary icon - Ednar  
📋 1 shop background (optional)  

**Total Progress:** 12/19-20 assets (63% complete)

---

## 💡 DESIGN DECISIONS

### **Why a Wrench Icon?**
- 🔧 Clearly indicates "tools/debug"
- Different from ⚙️ gear (saved for settings/pause)
- Cyan color stands out from other UI elements
- Universal symbol for development tools

### **Why Auto-Close After Character Selection?**
- Faster workflow (no manual dismiss needed)
- Immediate visual feedback in game
- Reduces steps in testing cycle

### **Why Show SF Symbol Fallbacks?**
- See complete asset list
- Know what still needs creation
- Verify fallback system works
- Toggle available to hide them if desired

### **Why Grid Layouts?**
- Efficient use of screen space
- Quick visual scanning
- Consistent with iOS design patterns
- Easy to compare multiple assets

---

## 🧪 TESTING COMPLETED

**Verified:**
- ✅ Wrench button appears in score bar
- ✅ Debug menu opens full-screen
- ✅ All 15 customer portraits display
- ✅ Bakasura shows ✅ Custom badge
- ✅ Noamron shows ✅ Custom badge
- ✅ Others show ⚠️ SF Symbol badge
- ✅ Tapping Bakasura forces him as current customer
- ✅ Custom portrait appears in game
- ✅ Tapping Noamron forces him as current customer
- ✅ Toggle hides/shows SF Symbol fallbacks
- ✅ Sword commentary icon shows ✅ Custom
- ✅ All component icons show ✅ Custom
- ✅ All card backgrounds show ✅ Custom
- ✅ Menu dismisses correctly
- ✅ No crashes with missing images
- ✅ Game continues normally after character forcing

---

## 📝 FUTURE ENHANCEMENTS

**Possible Additions:**

1. **Asset Export Helper:**
   - Button to show recommended export sizes
   - Quick reference for dimensions

2. **Asset Quality Checker:**
   - Check if images meet minimum size requirements
   - Warn if aspect ratio is wrong

3. **Batch Testing:**
   - Cycle through all characters automatically
   - Screenshot each for documentation

4. **Asset Statistics:**
   - Show completion percentage
   - List missing assets by priority

5. **In-Game Screenshot Tool:**
   - Capture current game state
   - Save portraits for portfolio

---

## 🔗 RELATED FILES

**Implementation Files:**
- `AssetsDebugView.swift` - Debug menu view
- `ShopOfOdditiesView.swift` - Wrench button + sheet
- `Customer.swift` - Public portrait helper
- `ShopGameState.swift` - Force customer method

**Documentation Files:**
- `ShopOfOddities_CONTEXT.md` - Updated with debug section
- `MASTER_CONTEXT.md` - Updated Phase 4 details
- `DEBUG_MENU_SUMMARY.md` - This file

**Asset Guides:**
- `PROCREATE_DIMENSIONS_AND_CURSED_CARD.md` - Canvas sizes
- `SHOP_ASSETS_QUICK_REFERENCE.md` - Asset names
- `SESSION_SUMMARY_CUSTOM_ASSETS.md` - Previous integration

---

## 🎉 SUCCESS METRICS

**Code Quality:**
- ✅ Clean, readable implementation
- ✅ Proper SwiftUI architecture (@Binding usage)
- ✅ Reusable components (AssetInfo struct)
- ✅ No hardcoded asset lists (dynamic detection)
- ✅ Environment dismiss pattern

**User Experience:**
- ✅ Intuitive interface
- ✅ Fast workflow (one tap to force character)
- ✅ Clear visual feedback (color-coded badges)
- ✅ No learning curve needed
- ✅ Helpful for non-coders

**Developer Experience:**
- ✅ Easy to extend with more features
- ✅ Self-documenting code
- ✅ Useful for testing
- ✅ Speeds up asset creation workflow
- ✅ Reduces iteration time

---

**END OF DEBUG MENU SUMMARY**

**Feature:** Debug menu with asset viewer + character forcing  
**Files Created:** 1 new (AssetsDebugView.swift)  
**Files Modified:** 4 (ShopOfOdditiesView, Customer, ShopGameState, docs)  
**Status:** ✅ Complete & working  
**Impact:** Dramatically speeds up custom asset testing workflow

**Date:** April 5, 2026  
**Implementation Time:** ~1 hour  
**Lines of Code:** ~550 (AssetsDebugView.swift) + ~50 (modifications)

**Ready for:** Custom portrait creation and testing! 🎨✨
