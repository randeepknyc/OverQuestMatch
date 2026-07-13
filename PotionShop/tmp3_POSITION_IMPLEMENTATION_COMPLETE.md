# 3-POSITION SYSTEM IMPLEMENTATION - COMPLETE GUIDE

**Date:** May 12, 2026  
**Status:** ✅ Config updated, backup created. CustomerSceneView + GameView updates needed.

---

## ✅ COMPLETED

1. **Documentation created:** `SECONDARY_WAITING_VALUES.md`
2. **Backup created:** `PotionShopLayoutConfig_BACKUP_May12_2026_PreWaiting2.swift`
3. **Config file updated:** `PotionShopLayoutConfig.swift`
   - Added 4 new fields to `CharacterScale` struct
   - Changed all waiting defaults from 0.8 to 1.0
   - Updated all 14 character entries with new structure

---

## 🔄 REMAINING CHANGES NEEDED

### File 1: PotionShopCustomerSceneView.swift

**Backup Location:** Create `PotionShopCustomerSceneView_BACKUP_May12_2026_PreWaiting2.swift`

**Change 1:** Add 4 new parameters to `PotionShopCustomerInSceneView` struct (lines 309-332)

**FIND THIS:**
```swift
struct PotionShopCustomerInSceneView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer
    let queueIndex: Int
    let queueCount: Int
    let sceneSize: CGSize
    let animationNamespace: Namespace.ID
    let arrivalCounter: Int
    
    // Customer scaling parameters (May 11, 2026 - ACTUAL SIZE SYSTEM)
    // Base scale applied to ALL images (makes 1536×1024 images visible)
    var customerSceneBaseScale: Double = 2.0
    
    // Active position (queue[0])
    var customerSceneWidth: Double = 1.0
    var customerSceneHeight: Double = 1.0
    var customerSceneX: Double = 0.0
    var customerSceneY: Double = 0.0
    
    // Waiting position (queue[1+])
    var customerWaitingWidth: Double = 0.8
    var customerWaitingHeight: Double = 0.8
    var customerWaitingX: Double = 0.0
    var customerWaitingY: Double = 0.0
```

**REPLACE WITH:**
```swift
struct PotionShopCustomerInSceneView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer
    let queueIndex: Int
    let queueCount: Int
    let sceneSize: CGSize
    let animationNamespace: Namespace.ID
    let arrivalCounter: Int
    
    // Customer scaling parameters (May 12, 2026 - 3-POSITION SYSTEM)
    // Base scale applied to ALL images (makes 1536×1024 images visible)
    var customerSceneBaseScale: Double = 2.0
    
    // Active position (queue[0])
    var customerSceneWidth: Double = 1.0
    var customerSceneHeight: Double = 1.0
    var customerSceneX: Double = 0.0
    var customerSceneY: Double = 0.0
    
    // Waiting position 1 (queue[1])
    var customerWaitingWidth: Double = 1.0     // ← CHANGED: Now defaults to 1.0 (was 0.8)
    var customerWaitingHeight: Double = 1.0    // ← CHANGED: Now defaults to 1.0 (was 0.8)
    var customerWaitingX: Double = 0.0
    var customerWaitingY: Double = 0.0
    
    // Waiting position 2 (queue[2]) ← NEW!
    var customerWaiting2Width: Double = 1.0
    var customerWaiting2Height: Double = 1.0
    var customerWaiting2X: Double = 0.0
    var customerWaiting2Y: Double = 0.0
```

---

**Change 2:** Update rendering logic (lines 400-404)

**FIND THIS:**
```swift
    var body: some View {
        if let char = char {
            // Determine which scale to use based on position in queue
            let effectiveWidth = isActive ? customerSceneWidth : customerWaitingWidth
            let effectiveHeight = isActive ? customerSceneHeight : customerWaitingHeight
            let effectiveX = isActive ? customerSceneX : customerWaitingX
            let effectiveY = isActive ? customerSceneY : customerWaitingY
```

**REPLACE WITH:**
```swift
    var body: some View {
        if let char = char {
            // Determine which scale to use based on position in queue (3-way choice)
            let effectiveWidth: Double
            let effectiveHeight: Double
            let effectiveX: Double
            let effectiveY: Double
            
            if isActive {
                effectiveWidth = customerSceneWidth
                effectiveHeight = customerSceneHeight
                effectiveX = customerSceneX
                effectiveY = customerSceneY
            } else if queueIndex == 1 {
                effectiveWidth = customerWaitingWidth
                effectiveHeight = customerWaitingHeight
                effectiveX = customerWaitingX
                effectiveY = customerWaitingY
            } else {
                effectiveWidth = customerWaiting2Width
                effectiveHeight = customerWaiting2Height
                effectiveX = customerWaiting2X
                effectiveY = customerWaiting2Y
            }
```

---

**Change 3:** Update call site to pass waiting2 values (lines 118-148)

**FIND THIS:**
```swift
                        PotionShopCustomerInSceneView(
                            gs: gs,
                            customer: cust,
                            queueIndex: idx,
                            queueCount: gs.queue.count,
                            sceneSize: geo.size,
                            animationNamespace: queueAnimation,
                            arrivalCounter: activeArrivalCounter,
                            // Base scale (makes 1536×1024 images visible)
                            customerSceneBaseScale: layoutConfig?.customerSceneBaseScale ?? 2.0,
                            // Active position values
                            customerSceneWidth: scale.width,
                            customerSceneHeight: scale.height,
                            customerSceneX: scale.x,
                            customerSceneY: scale.y,
                            // Waiting position values
                            customerWaitingWidth: scale.waitingWidth,
                            customerWaitingHeight: scale.waitingHeight,
                            customerWaitingX: scale.waitingX,
                            customerWaitingY: scale.waitingY
                        )
```

**REPLACE WITH:**
```swift
                        PotionShopCustomerInSceneView(
                            gs: gs,
                            customer: cust,
                            queueIndex: idx,
                            queueCount: gs.queue.count,
                            sceneSize: geo.size,
                            animationNamespace: queueAnimation,
                            arrivalCounter: activeArrivalCounter,
                            // Base scale (makes 1536×1024 images visible)
                            customerSceneBaseScale: layoutConfig?.customerSceneBaseScale ?? 2.0,
                            // Active position values
                            customerSceneWidth: scale.width,
                            customerSceneHeight: scale.height,
                            customerSceneX: scale.x,
                            customerSceneY: scale.y,
                            // Waiting position 1 values
                            customerWaitingWidth: scale.waitingWidth,
                            customerWaitingHeight: scale.waitingHeight,
                            customerWaitingX: scale.waitingX,
                            customerWaitingY: scale.waitingY,
                            // Waiting position 2 values ← NEW!
                            customerWaiting2Width: scale.waiting2Width,
                            customerWaiting2Height: scale.waiting2Height,
                            customerWaiting2X: scale.waiting2X,
                            customerWaiting2Y: scale.waiting2Y
                        )
```

---

### File 2: PotionShopGameView.swift

**Backup Location:** Create `PotionShopGameView_BACKUP_May12_2026_PreWaiting2.swift`

**Change:** Add new "Waiting Position 2" section to layout editor overlay

This file is 780 lines - I'll provide the specific location and code to add. The change involves adding a third section to the customers pill picker in the layout editor.

Search for the 🧍 Customers section and add a new **⏸️ WAITING POSITION 2** section with purple header after the existing waiting position section.

**Key changes:**
1. Rename "WAITING POSITION" → "WAITING POSITION 1"
2. Add new "⏸️ WAITING POSITION 2" section (purple header)
3. Add waiting2 uniform scale slider (yellow)
4. Add 4 waiting2 sliders (width/height/x/y)

---

## 🎯 TESTING PLAN

Once all changes are made:

1. **Build the app** (Command+R)
2. **Test Evening round** (3 customers: Wendelina, Crispin, Ardo)
3. **Open layout editor** (Debug menu → Layout Editor)
4. **Navigate to 🧍 Customers section**
5. **Verify 3 sections appear:**
   - ⭐️ ACTIVE POSITION (green)
   - ⏸️ WAITING POSITION 1 (orange)
   - ⏸️ WAITING POSITION 2 (purple) ← NEW!
6. **Adjust waiting2 sliders** - watch characters update in real-time
7. **Test queue swaps** - verify characters use correct values for each position

---

## 🔄 REVERSION PROCESS (if needed)

**To restore previous version:**

1. **In Xcode Project Navigator:**
   - Delete `PotionShopLayoutConfig.swift`
   - Delete `PotionShopCustomerSceneView.swift`
   - Delete `PotionShopGameView.swift`

2. **Rename backup files** (remove `_BACKUP_May12_2026_PreWaiting2` suffix):
   - `PotionShopLayoutConfig_BACKUP...` → `PotionShopLayoutConfig.swift`
   - `PotionShopCustomerSceneView_BACKUP...` → `PotionShopCustomerSceneView.swift`
   - `PotionShopGameView_BACKUP...` → `PotionShopGameView.swift`

3. **Clean build:**
   - Product menu → Clean Build Folder (Command+Shift+K)
   - Product menu → Build (Command+B)

---

## ✅ NEXT STEPS

I'll now continue with the implementation. Would you like me to:

1. **Complete the CustomerSceneView changes** (3 replacements)
2. **Complete the GameView changes** (add Waiting Position 2 UI)
3. **Provide testing instructions**

Ready to proceed?
