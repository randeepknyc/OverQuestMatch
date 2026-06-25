//
//  PotionShopCustomerSceneView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Customer scene + profile row
//  Place in: PotionShop/ folder
//
//  PHASE 5C: Queue spacing is COUNT-AWARE.
//  PHASE 5: Customer queue swap uses matchedGeometryEffect.
//  PHASE 6C: Inspect card matches the web artifact.
//  PHASE 6D: Inspect card SPLIT-SLIDES open.
//  PHASE 7: Customers SHAKE on damage (driven by gs.customerShakeCounters)
//           and SLIDE OFF-SCREEN on expiration (driven by gs.expiringCustomerIds).
//  PHASE 12: ART HOOKUP — Customer portraits load from Assets with emoji fallback
//
//  NAMING NOTE: PotionShop prefix on every public type.
//

import SwiftUI
import UIKit

// MARK: - Debug Helper

/// Prints ALL asset names that Xcode can find (helps debug missing images)
fileprivate func debugPrintAllAssetNames() {
    print("🔍 DEBUG: Attempting to find customer_scene_background in common variations...")
    
    // List of possible names to try
    let possibleNames = [
        "customer_scene_background",
        "customer_scene_background.png",
        "customer-scene-background",
        "scene_background",
        "CustomerSceneBackground",
        "customer scene background"
    ]
    
    for name in possibleNames {
        if let img = UIImage(named: name) {
            print("   ✅ FOUND: '\(name)' - Size: \(img.size)")
        } else {
            print("   ❌ NOT FOUND: '\(name)'")
        }
    }
    
    print("🔍 If none found, check:")
    print("   1. Is the image in Assets.xcassets?")
    print("   2. Is it in the correct Target Membership?")
    print("   3. Try the Asset Catalog name exactly as shown in Xcode")
}

// MARK: - Layout proportions

struct PotionShopSceneLayout {
    static let ednarX: CGFloat = 0.13
    static let ednarYFraction: CGFloat = 0.55

    // DEFAULT positions (used when no custom permutation is defined)
    static let queueXFractions1: [CGFloat] = [0.75]
    static let queueXFractions2: [CGFloat] = [0.55, 0.85]
    static let queueXFractions3: [CGFloat] = [0.48, 0.68, 0.88]

    static let queueYFractions: [CGFloat] = [0.48, 0.55, 0.55]

    static let queueScales: [CGFloat] = [1.0, 1.0, 1.0]  // ← CHANGED: All same size (was [1.0, 0.78, 0.72])
    static let queueDims:   [Bool]    = [false, true, true]

    static let portraitDiameter: CGFloat = 76
    static let profileDiameter:  CGFloat = 56

    /// Get X positions for queue, checking for custom permutation first.
    /// When `useAutoLayout` is true (Day 3+ flex days), the auto-layout
    /// system computes X positions from each character's widthBucket.
    static func queueXFractions(for count: Int, characterKeys: [String], config: PotionShopLayoutConfig?, useAutoLayout: Bool = false, feetAnchor: Bool = false) -> [CGFloat] {
        if useAutoLayout, let config = config {
            return PotionShopAutoQueueLayout.xFractions(for: characterKeys, config: config, feetAnchor: feetAnchor)
        }
        // Check for custom permutation in config
        if let config = config, count == 3 {
            let permutation = config.queuePositions(for: characterKeys)
            return permutation.xPositions.map { CGFloat($0) }
        }

        // Fall back to defaults
        switch count {
        case 1:  return queueXFractions1
        case 2:  return queueXFractions2
        case 3:  return queueXFractions3
        default: return queueXFractions3
        }
    }

    /// Get Y positions for queue, checking for custom permutation first.
    static func queueYFractions(for count: Int, characterKeys: [String], config: PotionShopLayoutConfig?, useAutoLayout: Bool = false) -> [CGFloat] {
        if useAutoLayout, let config = config {
            return PotionShopAutoQueueLayout.yFractions(for: characterKeys, config: config)
        }
        // Check for custom permutation in config
        if let config = config, count == 3 {
            let permutation = config.queuePositions(for: characterKeys)
            return permutation.yPositions.map { CGFloat($0) }
        }

        // Fall back to defaults
        return queueYFractions
    }

    /// Get scales for queue, checking for custom permutation first.
    static func queueScales(for count: Int, characterKeys: [String], config: PotionShopLayoutConfig?, useAutoLayout: Bool = false, feetAnchor: Bool = false) -> [CGFloat] {
        if useAutoLayout, let config = config {
            return PotionShopAutoQueueLayout.scales(for: characterKeys, config: config, feetAnchor: feetAnchor)
        }
        // Check for custom permutation in config
        if let config = config, count == 3 {
            let permutation = config.queuePositions(for: characterKeys)
            if let overrides = permutation.scaleOverrides {
                return overrides.map { CGFloat($0) }
            }
        }

        // Fall back to defaults
        return queueScales
    }
}

// MARK: - Auto Queue Layout (May 25, 2026 — for Day 3 RNG test)
//
// Replaces hand-tuned `queuePermutations` for flex days. Reads each
// customer's widthBucket and computes left-to-right X positions that
// scale with the character's visual width. Day 1/2 keep their existing
// hand-tuned positions; only flex days (Day 3+) go through this path.
//
// All numeric values live on PotionShopLayoutConfig as instance properties
// (so they can be tuned live via the Layout Editor sliders).

enum PotionShopAutoQueueLayout {

    /// Per-bucket width weight lookup (reads from config).
    static func widthWeight(for bucket: PotionShopLayoutConfig.CustomerWidthBucket,
                            config: PotionShopLayoutConfig) -> CGFloat {
        switch bucket {
        case .skinny: return CGFloat(config.autoLayoutWidthWeightSkinny)
        case .medium: return CGFloat(config.autoLayoutWidthWeightMedium)
        case .wide:   return CGFloat(config.autoLayoutWidthWeightWide)
        }
    }

    /// Per-height-bucket Y micro-adjustment.
    static func heightYAdjust(for bucket: PotionShopLayoutConfig.CustomerHeightBucket,
                              config: PotionShopLayoutConfig) -> CGFloat {
        switch bucket {
        case .superShort: return CGFloat(config.autoLayoutYAdjustSuperShort)
        case .short:      return CGFloat(config.autoLayoutYAdjustShort)
        case .medium:     return CGFloat(config.autoLayoutYAdjustMedium)
        case .tall:       return CGFloat(config.autoLayoutYAdjustTall)
        case .tallHat:    return CGFloat(config.autoLayoutYAdjustTallHat)
        case .floater:    return CGFloat(config.autoLayoutYAdjustFloater)
        }
    }

    /// Per-height-bucket scale multiplier (feet-anchor mode only).
    static func bucketScale(for bucket: PotionShopLayoutConfig.CustomerHeightBucket,
                            config: PotionShopLayoutConfig) -> CGFloat {
        switch bucket {
        case .superShort: return CGFloat(config.autoLayoutBucketScaleSuperShort)
        case .short:      return CGFloat(config.autoLayoutBucketScaleShort)
        case .medium:     return CGFloat(config.autoLayoutBucketScaleMedium)
        case .tall:       return CGFloat(config.autoLayoutBucketScaleTall)
        case .tallHat:    return CGFloat(config.autoLayoutBucketScaleTallHat)
        case .floater:    return CGFloat(config.autoLayoutBucketScaleFloater)
        }
    }

    /// Floor Y-fraction for the given queue slot (feet-anchor mode).
    static func feetYFraction(for queueIndex: Int,
                              config: PotionShopLayoutConfig) -> CGFloat {
        switch queueIndex {
        case 0:  return CGFloat(config.autoLayoutFeetYActive)
        case 1:  return CGFloat(config.autoLayoutFeetYWaiting1)
        default: return CGFloat(config.autoLayoutFeetYWaiting2)
        }
    }

    /// X positions (fractions of scene width) for the queue.
    /// When `feetAnchor` is true, returns fixed per-slot X fractions so the
    /// X is character-independent (no widthBucket math).
    static func xFractions(for characterKeys: [String],
                           config: PotionShopLayoutConfig,
                           feetAnchor: Bool = false) -> [CGFloat] {
        let count = characterKeys.count
        if count == 0 { return [] }

        if feetAnchor {
            return (0..<count).map { idx in
                switch idx {
                case 0:  return CGFloat(config.autoLayoutSlotXFractionActive)
                case 1:  return CGFloat(config.autoLayoutSlotXFractionWaiting1)
                default: return CGFloat(config.autoLayoutSlotXFractionWaiting2)
                }
            }
        }

        let startX = CGFloat(config.autoLayoutStartX)
        let endX = CGFloat(config.autoLayoutEndX)
        if count == 1 { return [startX] }

        let weights: [CGFloat] = characterKeys.map { key in
            widthWeight(for: config.characterScale(for: key).widthBucket, config: config)
        }

        var cumulative: [CGFloat] = [0]
        for w in weights.dropLast() {
            cumulative.append(cumulative.last! + w)
        }
        let total = cumulative.last ?? 1
        if total <= 0 {
            let step = (endX - startX) / CGFloat(max(count - 1, 1))
            return (0..<count).map { startX + CGFloat($0) * step }
        }
        let range = endX - startX
        return cumulative.map { startX + ($0 / total) * range }
    }

    /// Y positions (fractions of scene height) for the queue.
    static func yFractions(for characterKeys: [String],
                           config: PotionShopLayoutConfig) -> [CGFloat] {
        characterKeys.enumerated().map { idx, key in
            let bucket = config.characterScale(for: key).heightBucket
            let adj = heightYAdjust(for: bucket, config: config)
            let base = CGFloat(idx == 0 ? config.autoLayoutYActive : config.autoLayoutYWaiting)
            return base + adj
        }
    }

    /// Per-customer scale (active vs waiting1 vs waiting2 + beyond).
    /// In feet-anchor mode the per-bucket-per-slot MATRIX is the single source
    /// of size truth (replaces per-slot scale × slot uniform × bucket scale).
    static func scales(for characterKeys: [String],
                       config: PotionShopLayoutConfig,
                       feetAnchor: Bool = false) -> [CGFloat] {
        characterKeys.enumerated().map { idx, key in
            if feetAnchor {
                let cs = config.characterScale(for: key)
                let slotIndex = min(idx, 2)
                // June 1, 2026: use per-cell (slot × height × width) override
                // if set, else fall back to 6×3 height-only matrix.
                return CGFloat(config.resolvedBucketSize(slot: slotIndex,
                                                         height: cs.heightBucket,
                                                         width: cs.widthBucket))
            }
            switch idx {
            case 0:  return CGFloat(config.autoLayoutScaleActive)
            case 1:  return CGFloat(config.autoLayoutScaleWaiting1)
            default: return CGFloat(config.autoLayoutScaleWaiting2)
            }
        }
    }
}

// MARK: - Customer scene

struct PotionShopCustomerSceneView: View {
    @Bindable var gs: PotionShopGameState
    var ednarBaseScale: Double = 0.15 // BASE SCALE - Makes 1536×1024 images visible at reasonable size (MATCHES LAYOUT CONFIG)
    var ednarArtScale: Double = 1.0  // ART SCALE - Pass through to Ednar view
    var ednarArtWidth: Double = 1.0  // FREEFORM - Width scale
    var ednarArtHeight: Double = 1.0 // FREEFORM - Height scale
    var ednarArtXOffset: Double = 0  // FREEFORM - X position
    var ednarArtYOffset: Double = 0  // FREEFORM - Y position
    // @Bindable so SwiftUI's Observable tracking propagates layout-editor
    // changes (auto-layout sliders, per-character X/Y, etc.) into this view
    // and its children. Without @Bindable the customer view doesn't see
    // updates and characters appear frozen in Day 3 (May 30, 2026 fix).
    @Bindable var layoutConfig: PotionShopLayoutConfig = PotionShopLayoutConfig.shared

    @Namespace private var queueAnimation
    @State private var activeArrivalCounter: Int = 0
    @State private var lastActiveId: UUID? = nil

    var body: some View {
        GeometryReader { geo in
            // Get character keys in queue order for permutation lookup
            let characterKeys = gs.queue.compactMap { id in
                gs.customers.first(where: { $0.id == id })?.charKey
            }
            
            ZStack(alignment: .topLeading) {
                // LAYER 1: BACKGROUND (always first = bottom layer)
                backgroundLayer(geo: geo)

                // LAYER 2: Floor line (legacy non-feet-anchor rounds only —
                // feet-anchor rounds, like Day 3 R3 and now Day 1, hide it so
                // the template's safe-zone floor is the visual edge).
                // JUNE 13, 2026: trigger is feet-anchor, not flex-day, so Day 1
                // matches Day 3 R3 exactly.
                if !gs.isFlexDay && !gs.currentRoundUsesFeetAnchor {
                    floorLine
                }

                // LAYER 3: Ednar — zIndex(100) so she overlaps any customer
                // who drifts into her column (June 1, 2026).
                PotionShopEdnarView(
                    gs: gs,
                    ednarBaseScale: ednarBaseScale,
                    ednarArtScale: ednarArtScale,
                    ednarArtWidth: ednarArtWidth,
                    ednarArtHeight: ednarArtHeight,
                    ednarArtXOffset: ednarArtXOffset,
                    ednarArtYOffset: ednarArtYOffset
                )
                    .position(
                        x: geo.size.width * PotionShopSceneLayout.ednarX,
                        y: geo.size.height * PotionShopSceneLayout.ednarYFraction
                    )
                    .zIndex(100)

                ForEach(Array(gs.queue.enumerated()), id: \.element) { idx, custId in
                    if let cust = gs.customers.first(where: { $0.id == custId }) {
                        // Get per-character scaling values from layout config
                        let charKey = cust.charKey
                        let scale = layoutConfig.characterScale(for: charKey)
                        
                        PotionShopCustomerInSceneView(
                            gs: gs,
                            customer: cust,
                            queueIndex: idx,
                            queueCount: gs.queue.count,
                            sceneSize: geo.size,
                            animationNamespace: queueAnimation,
                            arrivalCounter: activeArrivalCounter,
                            characterKeys: characterKeys,  // ← NEW: Pass character keys for permutation lookup
                            layoutConfig: layoutConfig,     // ← NEW: Pass layout config
                            // Base scale (makes 1536×1024 images visible)
                            customerSceneBaseScale: layoutConfig.customerSceneBaseScale,
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
                        // JUNE 24, 2026: layer front-to-back by queue position.
                        // Active (idx 0) on top, slot1 (idx 1) behind it, slot2
                        // (idx 2) furthest back. Higher index = lower zIndex.
                        .zIndex(Double(gs.queue.count - idx))
                    }
                }

                if gs.shield > 0 {
                    Text("🛡 \(gs.shield)")
                        .font(Font.gameScore(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(PotionShopTheme.shield)
                        .clipShape(Capsule())
                        .position(
                            x: geo.size.width * (PotionShopSceneLayout.ednarX + 0.10),
                            y: geo.size.height * 0.30
                        )
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeOut(duration: 0.3), value: gs.shield)
                }
            }
            .clipped()
            .animation(.spring(response: 0.55, dampingFraction: 0.78), value: gs.queue)
            .onChange(of: gs.queue.first) { _, newActive in
                if newActive != lastActiveId {
                    lastActiveId = newActive
                    activeArrivalCounter += 1
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func backgroundLayer(geo: GeometryProxy) -> some View {
        ZStack {
            // LAYER 1: Gradient (bottom layer - always present as fallback)
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.90, blue: 0.80),
                    Color(red: 0.90, green: 0.84, blue: 0.69)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // LAYER 2: Background image (above gradient)
            // Day 3 uses bgtest1 temporarily so you can preview the new
            // drawn layout in-game (May 30, 2026). Legacy non-feet-anchor
            // rounds keep customerbg.
            // JUNE 13, 2026: the bgtest1 perspective-grid template now shows
            // on ANY feet-anchor round (Day 3 R3 AND Day 1), not just flex
            // days, so Day 1 matches Day 3 R3. Revert by changing bgName back
            // to gs.isFlexDay ? ... or to "customerbg" only.
            let bgName: String = (gs.isFlexDay || gs.currentRoundUsesFeetAnchor) ? "bgtest1" : "customerbg"
            if let backgroundImage = UIImage(named: bgName) {
                let _ = print("✅ LOADED: \(bgName)")
                Image(uiImage: backgroundImage)
                    .resizable()
                    // .scaledToFill so the image covers the whole scene
                    // area edge-to-edge. .clipped() trims any overflow if
                    // the image's aspect ratio doesn't perfectly match.
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height,
                           alignment: .center)
                    .clipped()
            } else {
                let _ = print("❌ \(bgName) NOT FOUND - Using gradient only")
            }
        }
    }
    
    private var floorLine: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(Color(red: 0.55, green: 0.36, blue: 0.18))
                .frame(height: 12)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.40, green: 0.25, blue: 0.10))
                        .frame(height: 2)
                        .offset(y: -1),
                    alignment: .top
                )
        }
    }
}

// MARK: - Ednar (the player avatar)

struct PotionShopEdnarView: View {
    @Bindable var gs: PotionShopGameState
    var ednarBaseScale: Double = 0.15   // BASE SCALE - Makes 1536×1024 images visible at reasonable size (MATCHES LAYOUT CONFIG)
    var ednarArtScale: Double = 1.0    // ART SCALE - Scale multiplier for Ednar image
    var ednarArtWidth: Double = 1.0    // FREEFORM - Independent width scale
    var ednarArtHeight: Double = 1.0   // FREEFORM - Independent height scale
    var ednarArtXOffset: Double = 0    // FREEFORM - X position offset (pts)
    var ednarArtYOffset: Double = 0    // FREEFORM - Y position offset (pts)

    private var expressionAssetName: String {
        let pct = Double(gs.composure) / Double(PotionShopConfig.maxComposure)
        if pct < 0.3 { return "ps_ednar_alarmed" }
        if pct < 0.7 { return "ps_ednar_concerned" }
        if !gs.placements.isEmpty { return "ps_ednar_focused" }
        return "ps_ednar_calm"
    }
    
    private var expressionEmojiFallback: String {
        let pct = Double(gs.composure) / Double(PotionShopConfig.maxComposure)
        if pct < 0.3 { return "😨" }
        if pct < 0.7 { return "😟" }
        if !gs.placements.isEmpty { return "🤨" }
        return "🧙‍♂️"
    }

    var body: some View {
        // Match the customer scene-image scaling system: fixed placeholder + scaleEffect.
        let baseScale = PotionShopLayoutConfig.shared.customerSceneBaseScale
        let placeholderW = PotionShopSceneLayout.portraitDiameter
        let placeholderH = PotionShopSceneLayout.portraitDiameter * 1.5
        let finalHeight = placeholderH * baseScale * ednarArtScale * ednarArtHeight

        VStack(spacing: 0) {
            // Try to load Ednar expression image, fallback to emoji
            if let ednarImage = PotionShopImageLoader.loadImage(named: expressionAssetName) {
                ZStack {
                    Color.clear
                        .frame(width: placeholderW, height: placeholderH)

                    Image(uiImage: ednarImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: placeholderW, height: placeholderH)
                        .scaleEffect(
                            x: baseScale * ednarArtScale * ednarArtWidth,
                            y: baseScale * ednarArtScale * ednarArtHeight,
                            anchor: .center
                        )
                        .offset(x: ednarArtXOffset, y: ednarArtYOffset)
                        .allowsHitTesting(false)
                }

                // Shadow scales proportionally to image height (20% of height, min 4pt)
                Capsule()
                    .fill(PotionShopTheme.ink.opacity(0.15))
                    .frame(
                        width: max(64, finalHeight * 0.20),
                        height: 4
                    )
                    .blur(radius: 1)
                    .offset(y: ednarArtYOffset * 0.5)
            } else {
                // Emoji fallback - pixel-accurate sizing
                let baseEmojiSize: CGFloat = 76  // Match customer base size
                let finalSize = baseEmojiSize
                
                Text(expressionEmojiFallback)
                    .font(.system(size: finalSize))
                    .offset(x: ednarArtXOffset, y: ednarArtYOffset)
                
                // Shadow scales with emoji size
                Capsule()
                    .fill(PotionShopTheme.ink.opacity(0.15))
                    .frame(
                        width: max(64, finalSize * 0.64),  // Shadow width = 64% of emoji size
                        height: 4
                    )
                    .blur(radius: 1)
                    .offset(y: ednarArtYOffset * 0.5)
            }
        }
        // JUNE 20, 2026: HEAL/SHIELD PREVIEW BUBBLE. Ednar sits at the far
        // LEFT edge of the screen, so a left-side bubble was clipped off-
        // screen. Placed on his INWARD (right) side, slightly above, where
        // there's room and it's visible. Shows the brew's healing (+X) and
        // shielding (🛡 #) as dice are placed.
        .overlay(alignment: .topTrailing) {
            let p = gs.livePreview
            if !gs.isAnimating, p.healing > 0 || p.shielding > 0 {
                VStack(alignment: .leading, spacing: 3) {
                    if p.healing > 0 {
                        Text("+\(p.healing)")
                            .font(Font.gameScore(size: 16))
                            .foregroundColor(PotionShopTheme.composureGood)
                    }
                    if p.shielding > 0 {
                        Text("🛡 \(p.shielding)")
                            .font(Font.gameScore(size: 15))
                            .foregroundColor(Color(red: 0.45, green: 0.65, blue: 0.95))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.92))
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(PotionShopTheme.ink.opacity(0.3), lineWidth: 1)
                )
                .fixedSize()
                .offset(x: 30, y: 10)
                .zIndex(200)
                .transition(.scale.combined(with: .opacity))
                .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - One customer in the scene
//
// PHASE 7 additions:
//   - Shake when gs.customerShakeCounters[id] increments
//   - Slide off-screen + fade when gs.expiringCustomerIds contains id
//   - Optional 💢 emoji burst on expiration (PotionShopBrewAnimator.expirationShowEmoji)
//
// PHASE 7H (May 5, 2026): FULL-BODY CUSTOMERS (NO CIRCLES)
//   - Character image shows at natural 2:3 aspect ratio (NO circle crop!)
//   - HP badge ABOVE head (centered horizontally)
//   - Attack badges ABOVE head (offset to left/right)
//   - All effects, values, and behaviors unchanged

struct PotionShopCustomerInSceneView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer
    let queueIndex: Int
    let queueCount: Int
    let sceneSize: CGSize
    let animationNamespace: Namespace.ID
    let arrivalCounter: Int
    
    // NEW: Character keys for permutation lookup
    let characterKeys: [String]
    // @Bindable so layout-editor changes (sliders) propagate updates here
    // and the character actually moves (May 30, 2026 fix).
    @Bindable var layoutConfig: PotionShopLayoutConfig
    
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

    @State private var shakeOffset: CGFloat = 0
    // JUNE 20, 2026: true briefly while this customer is attacking (shaking),
    // so they pop to full opacity during their attack.
    @State private var attacking: Bool = false
    @State private var settleBoost: CGFloat = 1.0
    @State private var expireSlideX: CGFloat = 0
    @State private var expireOpacity: Double = 1.0
    /// JUNE 13, 2026 fix — DEFEAT exit. A defeated customer used to get
    /// yanked from the queue instantly; the queue re-index + the
    /// matchedGeometryEffect then dragged its dying view toward the new
    /// layout (the "snap to screen right" before it vanished). Now a
    /// defeated customer FADES IN PLACE: we freeze its position at the spot
    /// it was defeated and fade opacity to 0, opting out of the reposition.
    @State private var defeatOpacity: Double = 1.0
    @State private var defeatFrozen: Bool = false
    @State private var defeatFrozenX: CGFloat = 0
    @State private var defeatFrozenY: CGFloat = 0
    @State private var emojiOpacity: Double = 0.0
    // JUNE 20, 2026: damage particle burst (fires with the shake on brew hit).
    @State private var burstTick: Int = 0
    // JUNE 20, 2026: true briefly while the active customer is being HIT by a
    // brew (after Brew pressed), so the HP badge can swap to hp_damage.
    @State private var takingDamage: Bool = false
    @State private var emojiOffset: CGFloat = 0

    private var char: PotionShopCharacter? {
        PotionShopData.character(customer.charKey)
    }

    private var isActive: Bool { gs.queue.first == customer.id }
    private var attack: Int {
        guard let c = char else { return 0 }
        return isActive ? c.activeAttack : c.waitingAttack
    }
    // Read HP straight from gs so SwiftUI's observation on the customers array
    // triggers a re-render here even if the parent's cached `customer` snapshot is stale.
    private var liveHP: Int {
        let actual = gs.customers.first(where: { $0.id == customer.id })?.hp ?? customer.hp
        // JUNE 20, 2026: for the ACTIVE customer (front of queue), show the
        // HP they'll have AFTER the current brew's damage — dynamically, as
        // dice are placed. Clamped at 0 so it never goes negative.
        // CRITICAL: only preview while PLACING (not animating). During doBrew
        // the real hp is reduced at the damage phase but placements aren't
        // cleared until much later, so previewing then would subtract the
        // damage a SECOND time from the already-reduced hp. Gating on
        // !isAnimating makes the brew show real hp; preview resumes after.
        if gs.queue.first == customer.id, !gs.isAnimating {
            let dmg = gs.livePreview.damage
            return max(0, actual - dmg)
        }
        return actual
    }

    private var dim: Bool {
        if queueIndex < PotionShopSceneLayout.queueDims.count {
            return PotionShopSceneLayout.queueDims[queueIndex]
        }
        return true
    }
    private var scale: CGFloat {
        // Use permutation-aware scale lookup. JUNE 13, 2026: the bucket-based
        // auto-layout (the thing that sizes customers by their H×W bucket) is
        // now driven by whether the ROUND uses feet-anchor — NOT by whether
        // the day is a flex day. Feet-anchor IS the bucket system, so they
        // travel together. This makes Day 1 (legacy day, but feet-anchor on)
        // size its customers exactly like Day 3 R3 instead of falling back to
        // untuned per-character defaults (the giant-minotaur bug). Non-feet-
        // anchor rounds (Day 2, etc.) are unchanged.
        let useAuto = gs.isFlexDay || gs.currentRoundUsesFeetAnchor
        let scales = PotionShopSceneLayout.queueScales(for: queueCount, characterKeys: characterKeys, config: layoutConfig, useAutoLayout: useAuto, feetAnchor: gs.currentRoundUsesFeetAnchor)
        if queueIndex < scales.count {
            return scales[queueIndex]
        }
        return 0.7
    }
    private var xPos: CGFloat {
        // Use permutation-aware X position lookup. JUNE 13, 2026: auto-layout
        // X spacing follows feet-anchor too (see `scale` above) so Day 1
        // spreads customers by bucket like Day 3 R3.
        let useAuto = gs.isFlexDay || gs.currentRoundUsesFeetAnchor
        let fractions = PotionShopSceneLayout.queueXFractions(for: queueCount, characterKeys: characterKeys, config: layoutConfig, useAutoLayout: useAuto, feetAnchor: gs.currentRoundUsesFeetAnchor)
        let frac: CGFloat
        if queueIndex < fractions.count {
            frac = fractions[queueIndex]
        } else {
            frac = 0.95
        }
        return sceneSize.width * frac
    }
    private var yPos: CGFloat {
        // Feet-anchor mode (Day 3 Round 2): position the CENTER of the
        // character so the bottom of the rendered image lands on the per-slot
        // floor-Y. Per-character waitingY/waiting2Y offsets are skipped (the
        // floor handles vertical placement).
        if gs.currentRoundUsesFeetAnchor {
            let floorFrac = PotionShopAutoQueueLayout.feetYFraction(for: queueIndex, config: layoutConfig)
            let renderedHeight = PotionShopSceneLayout.portraitDiameter
                * scale
                * 1.5
                * CGFloat(customerSceneBaseScale)
                * CGFloat(effectiveHeightForSlot)
            return sceneSize.height * floorFrac - renderedHeight / 2
        }

        // Use permutation-aware Y position lookup (auto-layout on Day 3+).
        let fractions = PotionShopSceneLayout.queueYFractions(for: queueCount, characterKeys: characterKeys, config: layoutConfig, useAutoLayout: gs.isFlexDay)
        let frac: CGFloat
        if queueIndex < fractions.count {
            frac = fractions[queueIndex]
        } else {
            frac = 0.55
        }
        return sceneSize.height * frac
    }

    /// The total height multiplier for the current queue slot. Mirrors the
    /// effectiveHeight logic in `body` so `yPos` (feet-anchor) and rendering
    /// agree. In feet-anchor mode this includes the slot template multiplier.
    private var effectiveHeightForSlot: Double {
        let perChar: Double
        if queueIndex == 0 { perChar = customerSceneHeight }
        else if queueIndex == 1 { perChar = customerWaitingHeight }
        else { perChar = customerWaiting2Height }
        let tpl = slotTemplateForCurrentSlot
        return perChar * tpl.h * tpl.scale
    }

    /// Per-slot W/H/X/Y/scale template (feet-anchor mode). Outside feet-anchor
    /// returns identity (W=1, H=1, X=0, Y=0, scale=1) so per-character values
    /// pass through unchanged.
    /// June 1, 2026: per-cell X/Y overrides (for the character's height +
    /// width bucket combo in this slot) ADD on top of the slot fine-tune X/Y.
    private var slotTemplateForCurrentSlot: (w: Double, h: Double, x: Double, y: Double, scale: Double) {
        guard gs.currentRoundUsesFeetAnchor else { return (1.0, 1.0, 0.0, 0.0, 1.0) }
        let slotIdx = min(queueIndex, 2)
        let cs = layoutConfig.characterScale(for: customer.charKey)
        let cellX = layoutConfig.resolvedCellX(slot: slotIdx, height: cs.heightBucket, width: cs.widthBucket)
        let cellY = layoutConfig.resolvedCellY(slot: slotIdx, height: cs.heightBucket, width: cs.widthBucket)
        let slotX: Double
        let slotY: Double
        switch slotIdx {
        case 0:
            slotX = layoutConfig.autoLayoutActiveX
            slotY = layoutConfig.autoLayoutActiveY
        case 1:
            slotX = layoutConfig.autoLayoutWaiting1X
            slotY = layoutConfig.autoLayoutWaiting1Y
        default:
            slotX = layoutConfig.autoLayoutWaiting2X
            slotY = layoutConfig.autoLayoutWaiting2Y
        }
        return (1.0, 1.0, slotX + cellX, slotY + cellY, 1.0)
    }

    // ─── Editor drag-the-thing-itself (June 12, 2026) ──────────────────
    // With the layout editor open, the character body and the HP badge can
    // be dragged directly in the scene. Drags write to the SAME values the
    // editor sliders edit (mode-aware), and register as undo steps.
    @State private var editorBodyDrag = PotionShopEditorDragSession()
    @State private var editorBadgeDrag = PotionShopEditorDragSession()

    /// Read/write closures for the character body's X offset — matches
    /// whatever the focused editor's sliders would write for this slot:
    /// feet-anchor rounds → the per-cell (slot·H×W) X; legacy rounds → the
    /// per-character x / waitingX / waiting2X for this slot tier.
    private func bodyXAccessors(slotIdx: Int) -> (read: () -> Double, apply: (Double) -> Void) {
        let key = customer.charKey
        let cfg = PotionShopLayoutConfig.shared
        // JUNE 24, 2026: contextual write-mode — drag/sliders write the
        // CONTEXTUAL character nudge dx for the current front+back context.
        if cfg.editCharacterContextual {
            let front = liveFrontNeighborKey(forSlot: slotIdx)
            let back = liveBackNeighborKey(forSlot: slotIdx)
            return ({ cfg.characterContextNudge(slot: slotIdx, myCharacterId: key, frontNeighborId: front, backNeighborId: back).dx },
                    { cfg.setCharacterContextNudge(slot: slotIdx, myCharacterId: key, frontNeighborId: front, backNeighborId: back, dx: $0) })
        }
        if gs.currentRoundUsesFeetAnchor {
            let cs = cfg.characterScale(for: key)
            let h = cs.heightBucket, w = cs.widthBucket
            return ({ cfg.resolvedCellX(slot: slotIdx, height: h, width: w) },
                    { cfg.setBucketCellX(slot: slotIdx, height: h, width: w, x: $0) })
        }
        switch slotIdx {
        case 0:
            return ({ cfg.characterScale(for: key).x },
                    { v in var cs = cfg.characterScale(for: key); cs.x = v; cfg.updateCharacterScale(for: key, scale: cs) })
        case 1:
            return ({ cfg.characterScale(for: key).waitingX },
                    { v in var cs = cfg.characterScale(for: key); cs.waitingX = v; cfg.updateCharacterScale(for: key, scale: cs) })
        default:
            return ({ cfg.characterScale(for: key).waiting2X },
                    { v in var cs = cfg.characterScale(for: key); cs.waiting2X = v; cfg.updateCharacterScale(for: key, scale: cs) })
        }
    }

    private func bodyYAccessors(slotIdx: Int) -> (read: () -> Double, apply: (Double) -> Void) {
        let key = customer.charKey
        let cfg = PotionShopLayoutConfig.shared
        // JUNE 24, 2026: contextual write-mode for character Y.
        if cfg.editCharacterContextual {
            let front = liveFrontNeighborKey(forSlot: slotIdx)
            let back = liveBackNeighborKey(forSlot: slotIdx)
            return ({ cfg.characterContextNudge(slot: slotIdx, myCharacterId: key, frontNeighborId: front, backNeighborId: back).dy },
                    { cfg.setCharacterContextNudge(slot: slotIdx, myCharacterId: key, frontNeighborId: front, backNeighborId: back, dy: $0) })
        }
        if gs.currentRoundUsesFeetAnchor {
            let cs = cfg.characterScale(for: key)
            let h = cs.heightBucket, w = cs.widthBucket
            return ({ cfg.resolvedCellY(slot: slotIdx, height: h, width: w) },
                    { cfg.setBucketCellY(slot: slotIdx, height: h, width: w, y: $0) })
        }
        switch slotIdx {
        case 0:
            return ({ cfg.characterScale(for: key).y },
                    { v in var cs = cfg.characterScale(for: key); cs.y = v; cfg.updateCharacterScale(for: key, scale: cs) })
        case 1:
            return ({ cfg.characterScale(for: key).waitingY },
                    { v in var cs = cfg.characterScale(for: key); cs.waitingY = v; cfg.updateCharacterScale(for: key, scale: cs) })
        default:
            return ({ cfg.characterScale(for: key).waiting2Y },
                    { v in var cs = cfg.characterScale(for: key); cs.waiting2Y = v; cfg.updateCharacterScale(for: key, scale: cs) })
        }
    }

    /// The charKey of whoever stands one slot in front (live queue), or
    /// nil for slot 0 / empty. Used by contextual nudges + their editor.
    private func liveFrontNeighborKey(forSlot slotIdx: Int) -> String? {
        guard slotIdx >= 1,
              slotIdx - 1 < gs.queue.count,
              let nbr = gs.customers.first(where: { $0.id == gs.queue[slotIdx - 1] })
        else { return nil }
        return nbr.charKey
    }

    /// The charKey of whoever stands one slot BEHIND (live queue), or nil.
    /// Used by the character contextual nudge (front + back context).
    private func liveBackNeighborKey(forSlot slotIdx: Int) -> String? {
        guard slotIdx + 1 < gs.queue.count,
              let nbr = gs.customers.first(where: { $0.id == gs.queue[slotIdx + 1] })
        else { return nil }
        return nbr.charKey
    }

    /// Read/write closures for the HP badge X offset — same precedence the
    /// focused editor uses: feet-anchor → slot-cell or shared-H×W dict
    /// (per the editHpBadgePerSlot toggle); legacy → per-character override
    /// for this slot tier.
    /// June 12, 2026 (§28.9): when `editHpBadgeContextual` is ON and this
    /// slot has a live front neighbor, the drag writes the CONTEXTUAL
    /// NUDGE dx for the current pairing instead of the base tiers.
    private func badgeXAccessors(slotIdx: Int) -> (read: () -> Double, apply: (Double) -> Void) {
        let key = customer.charKey
        let cfg = PotionShopLayoutConfig.shared
        if cfg.editHpBadgeContextual, let nbrKey = liveFrontNeighborKey(forSlot: slotIdx) {
            return ({ cfg.hpBadgeContextNudge(slot: slotIdx, myCharacterId: key, neighborCharacterId: nbrKey).dx },
                    { cfg.setHpBadgeContextNudge(slot: slotIdx, myCharacterId: key, neighborCharacterId: nbrKey, dx: $0) })
        }
        if gs.currentRoundUsesFeetAnchor {
            let cs = cfg.characterScale(for: key)
            let h = cs.heightBucket, w = cs.widthBucket
            return ({ cfg.resolvedHpBadgeX(height: h, width: w, characterId: key, slotForLegacy: slotIdx) },
                    { v in
                        if cfg.editHpBadgePerSlot {
                            cfg.setHpBadgeSlotCellX(slot: slotIdx, height: h, width: w, x: v)
                        } else {
                            cfg.setHpBadgeCellX(height: h, width: w, x: v)
                        }
                    })
        }
        return ({ cfg.hpBadgeOffsetX(for: key, queueSlot: slotIdx) },
                { v in
                    var cs = cfg.characterScale(for: key)
                    if slotIdx >= 2 { cs.waiting2HpBadgeOffsetXOverride = v }
                    else if slotIdx >= 1 { cs.waitingHpBadgeOffsetXOverride = v }
                    else { cs.hpBadgeOffsetXOverride = v }
                    cfg.updateCharacterScale(for: key, scale: cs)
                })
    }

    private func badgeYAccessors(slotIdx: Int) -> (read: () -> Double, apply: (Double) -> Void) {
        let key = customer.charKey
        let cfg = PotionShopLayoutConfig.shared
        if cfg.editHpBadgeContextual, let nbrKey = liveFrontNeighborKey(forSlot: slotIdx) {
            return ({ cfg.hpBadgeContextNudge(slot: slotIdx, myCharacterId: key, neighborCharacterId: nbrKey).dy },
                    { cfg.setHpBadgeContextNudge(slot: slotIdx, myCharacterId: key, neighborCharacterId: nbrKey, dy: $0) })
        }
        if gs.currentRoundUsesFeetAnchor {
            let cs = cfg.characterScale(for: key)
            let h = cs.heightBucket, w = cs.widthBucket
            return ({ cfg.resolvedHpBadgeY(height: h, width: w, characterId: key, slotForLegacy: slotIdx) },
                    { v in
                        if cfg.editHpBadgePerSlot {
                            cfg.setHpBadgeSlotCellY(slot: slotIdx, height: h, width: w, y: v)
                        } else {
                            cfg.setHpBadgeCellY(height: h, width: w, y: v)
                        }
                    })
        }
        return ({ cfg.hpBadgeOffsetY(for: key, queueSlot: slotIdx) },
                { v in
                    var cs = cfg.characterScale(for: key)
                    if slotIdx >= 2 { cs.waiting2HpBadgeOffsetYOverride = v }
                    else if slotIdx >= 1 { cs.waitingHpBadgeOffsetYOverride = v }
                    else { cs.hpBadgeOffsetYOverride = v }
                    cfg.updateCharacterScale(for: key, scale: cs)
                })
    }

    var body: some View {
        // Determine which scale to use based on position in queue (3-way choice)
        let perCharWidth: Double = isActive ? customerSceneWidth : (queueIndex == 1 ? customerWaitingWidth : customerWaiting2Width)
        let perCharHeight: Double = isActive ? customerSceneHeight : (queueIndex == 1 ? customerWaitingHeight : customerWaiting2Height)
        let perCharX: Double = isActive ? customerSceneX : (queueIndex == 1 ? customerWaitingX : customerWaiting2X)
        let perCharY: Double = isActive ? customerSceneY : (queueIndex == 1 ? customerWaitingY : customerWaiting2Y)

        // Feet-anchor mode (Day 3 R2): slot template fully owns X/Y so every
        // character that steps into a slot stands at the same spot. Width &
        // height still compose (slot × per-character) so individual chars
        // can be slightly wider/taller. Outside feet-anchor the slot template
        // is identity (1.0 / 0) so per-character values pass through.
        let slotTemplate = slotTemplateForCurrentSlot
        // JUNE 24, 2026: CHARACTER CONTEXTUAL NUDGE. Look up the front (one
        // ahead in queue) and back (one behind) neighbors and apply a
        // bucket-keyed nudge to this character's position + scale. Sparse —
        // identity when no entry, so most characters are unaffected.
        let charFrontNeighborKey: String? = {
            guard queueIndex - 1 >= 0, queueIndex - 1 < gs.queue.count,
                  let nbr = gs.customers.first(where: { $0.id == gs.queue[queueIndex - 1] })
            else { return nil }
            return nbr.charKey
        }()
        let charBackNeighborKey: String? = {
            guard queueIndex + 1 < gs.queue.count,
                  let nbr = gs.customers.first(where: { $0.id == gs.queue[queueIndex + 1] })
            else { return nil }
            return nbr.charKey
        }()
        let charContextNudge = layoutConfig.characterContextNudge(
            slot: queueIndex,
            myCharacterId: customer.charKey,
            frontNeighborId: charFrontNeighborKey,
            backNeighborId: charBackNeighborKey
        )
        let effectiveWidth: Double = perCharWidth * slotTemplate.w * slotTemplate.scale * charContextNudge.sizeMul
        let effectiveHeight: Double = perCharHeight * slotTemplate.h * slotTemplate.scale * charContextNudge.sizeMul
        let effectiveX: Double = (gs.currentRoundUsesFeetAnchor ? slotTemplate.x : perCharX) + charContextNudge.dx
        let effectiveY: Double = (gs.currentRoundUsesFeetAnchor ? slotTemplate.y : perCharY) + charContextNudge.dy

        // Fix A (May 24, 2026): badge head-anchor uses unified waiting1 dimensions when the
        // character is in ANY waiting slot, so a "Share"-mode waiting badge override produces
        // visually identical placement in waiting1 and waiting2. Body still renders at its
        // slot-specific size (effectiveWidth/Height above) — only the badge anchor uses these.
        let badgeAnchorWidth: Double = isActive ? customerSceneWidth : customerWaitingWidth
        let badgeAnchorHeight: Double = isActive ? customerSceneHeight : customerWaitingHeight

        // Head anchor (May 22, 2026): badge offsets are relative to where the character's head renders,
        // not the layout center, so different-height characters all get badges near their actual heads.
        let renderedImageWidth = PotionShopSceneLayout.portraitDiameter * scale * customerSceneBaseScale * badgeAnchorWidth
        let renderedImageHeight = PotionShopSceneLayout.portraitDiameter * scale * 1.5 * customerSceneBaseScale * badgeAnchorHeight
        let anchorFractionY = PotionShopLayoutConfig.shared.headAnchorY(for: customer.charKey)
        let anchorFractionX = PotionShopLayoutConfig.shared.headAnchorX(for: customer.charKey)
        let headOffsetY = renderedImageHeight * (anchorFractionY - 0.5)
        let headOffsetX = renderedImageWidth * (anchorFractionX - 0.5)

        // White-silhouette test (May 25, 2026): Day 1 Evening waiters render with
        // a solid-white silhouette underneath + a faded character on top, so the
        // scene background doesn't show through the body. Active customer always
        // renders normally. Scoped to Wendelina + Crispin + Ardo for now.
        // JUNE 24, 2026: white-silhouette backing now applies to ALL waiting
        // (non-active) customers, so the background never shows through the
        // dimmed art. (Was limited to wendelina/crispin/ardo.)
        let useWhiteSilhouette = !isActive

        // Editor-selection state (May 26, 2026): when the layout editor is
        // open AND this customer is the currently-selected one, draw a thin
        // yellow ring around the character body so the user can see which
        // customer they're tuning.
        let editorOpen = PotionShopLayoutConfig.shared.layoutEditorIsOpen
        let isEditorSelected = editorOpen &&
            PotionShopLayoutConfig.shared.selectedCharacterId == customer.charKey

        if let char = char {
            ZStack {
                // Character image (full body, NO circle!)
                // Apply custom scaling and positioning
                ZStack {
                    Color.clear
                        .frame(
                            width: PotionShopSceneLayout.portraitDiameter * scale,
                            height: PotionShopSceneLayout.portraitDiameter * scale * 1.5  // 2:3 aspect ratio
                        )

                    if useWhiteSilhouette {
                        // Underlay: opaque white silhouette of the character.
                        // `.colorMultiply(.white).brightness(1.0)` pushes every visible
                        // pixel to pure white while preserving the alpha channel.
                        PotionShopImageLoader.sceneImageOrFallback(
                            sceneAsset: char.scenePortrait,
                            profileAsset: char.portrait,
                            fallbackEmoji: char.iconFallback,
                            size: PotionShopSceneLayout.portraitDiameter * scale
                        )
                        .scaleEffect(x: customerSceneBaseScale * effectiveWidth,
                                    y: customerSceneBaseScale * effectiveHeight,
                                    anchor: .center)
                        .offset(x: effectiveX, y: effectiveY)
                        .colorMultiply(.white)
                        .brightness(1.0)

                        // Overlay: original character art at reduced opacity.
                        PotionShopImageLoader.sceneImageOrFallback(
                            sceneAsset: char.scenePortrait,
                            profileAsset: char.portrait,
                            fallbackEmoji: char.iconFallback,
                            size: PotionShopSceneLayout.portraitDiameter * scale
                        )
                        .scaleEffect(x: customerSceneBaseScale * effectiveWidth,
                                    y: customerSceneBaseScale * effectiveHeight,
                                    anchor: .center)
                        .offset(x: effectiveX, y: effectiveY)
                        .opacity(0.55)
                    } else {
                        PotionShopImageLoader.sceneImageOrFallback(
                            sceneAsset: char.scenePortrait,
                            profileAsset: char.portrait,
                            fallbackEmoji: char.iconFallback,
                            size: PotionShopSceneLayout.portraitDiameter * scale
                        )
                        // Apply base scale FIRST (makes 1536×1024 visible), then per-character scale
                        .scaleEffect(x: customerSceneBaseScale * effectiveWidth,
                                    y: customerSceneBaseScale * effectiveHeight,
                                    anchor: .center)
                        .offset(x: effectiveX, y: effectiveY)
                    }

                    // Selected-character indicator (May 26, 2026): yellow ring
                    // around the character body when the layout editor is open
                    // and this customer is selected. Width/height are clamped
                    // to a positive minimum so SwiftUI never sees a 0-size frame.
                    if isEditorSelected {
                        let ringW = max(20.0, PotionShopSceneLayout.portraitDiameter * scale * customerSceneBaseScale * effectiveWidth)
                        let ringH = max(30.0, PotionShopSceneLayout.portraitDiameter * scale * 1.5 * customerSceneBaseScale * effectiveHeight)
                        Rectangle()
                            .stroke(Color.yellow, lineWidth: 3)
                            .frame(width: ringW, height: ringH)
                            .offset(x: effectiveX, y: effectiveY)
                            .allowsHitTesting(false)
                    }
                }
                // Tap-to-select (May 26, 2026): scoped to the inner character
                // ZStack ONLY (not the whole outer ZStack including badges/emoji)
                // so adjacent customers' tap rectangles don't overlap.
                // June 12, 2026: tap also JUMPS the editor to the focused
                // per-slot tab, and dragging the body moves the character
                // (writes the same values the position sliders edit).
                .contentShape(Rectangle())
                .onTapGesture {
                    if PotionShopLayoutConfig.shared.layoutEditorIsOpen {
                        PotionShopLayoutConfig.shared.selectedCharacterId = customer.charKey
                        PotionShopLayoutConfig.shared.selectedSlotIndex = min(queueIndex, 2)
                        PotionShopEditorHistory.shared.jumpRequest =
                            PotionShopEditorJump(target: .autoLayout)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 12)
                        .onChanged { value in
                            guard PotionShopLayoutConfig.shared.layoutEditorIsOpen else { return }
                            let slotIdx = isActive ? 0 : min(max(queueIndex, 1), 2)
                            let xAcc = bodyXAccessors(slotIdx: slotIdx)
                            let yAcc = bodyYAccessors(slotIdx: slotIdx)
                            if !editorBodyDrag.active {
                                PotionShopLayoutConfig.shared.selectedCharacterId = customer.charKey
                                PotionShopLayoutConfig.shared.selectedSlotIndex = slotIdx
                                editorBodyDrag.begin(label: "\(customer.charKey) body",
                                                     readX: xAcc.read, applyX: xAcc.apply,
                                                     readY: yAcc.read, applyY: yAcc.apply)
                            }
                            // Body offsets are applied in raw points → 1:1 delta.
                            xAcc.apply(editorBodyDrag.startX + value.translation.width)
                            yAcc.apply(editorBodyDrag.startY + value.translation.height)
                        }
                        .onEnded { _ in
                            editorBodyDrag.end()
                        }
                )

                // Badge queue slot (May 24, 2026): 0 = active (queue[0]),
                // 1 = waiting1 (queue[1]), 2 = waiting2 (queue[2]). Clamped for safety.
                let badgeQueueSlot: Int = isActive ? 0 : min(max(queueIndex, 1), 2)

                // HP badge visibility (June 3, 2026): visible in all rounds —
                // Day 1/2 use legacy per-bucket values, Day 3 R2/R3 use the
                // per-cell HP matrix. Attack badge stays hidden in any
                // feet-anchor round.
                if true {

                // June 3, 2026: in feet-anchor mode, look up HP badge values
                // from the per-cell (height × width) HP matrix. Falls back to
                // legacy per-bucket values when the cell isn't set.
                let csHpBadge = layoutConfig.characterScale(for: customer.charKey)
                // CONTEXTUAL NUDGE (June 12, 2026 — §28.9): who stands one
                // slot in front of me right now? If a nudge entry exists for
                // (my slot · my H×W · their H×W) it shifts/scales the badge.
                // Live from the current queue, so it re-resolves on swaps,
                // defeats, and expirations. Identity when slot 0 / no entry.
                let frontNeighborKey: String? = {
                    guard badgeQueueSlot >= 1,
                          badgeQueueSlot - 1 < gs.queue.count,
                          let nbr = gs.customers.first(where: { $0.id == gs.queue[badgeQueueSlot - 1] })
                    else { return nil }
                    return nbr.charKey
                }()
                let contextNudge = layoutConfig.hpBadgeContextNudge(
                    slot: badgeQueueSlot,
                    myCharacterId: customer.charKey,
                    neighborCharacterId: frontNeighborKey
                )
                let hpSize: Double = (gs.currentRoundUsesFeetAnchor
                    ? layoutConfig.resolvedHpBadgeSize(height: csHpBadge.heightBucket, width: csHpBadge.widthBucket, characterId: customer.charKey, slotForLegacy: badgeQueueSlot)
                    : layoutConfig.hpBadgeSize(for: customer.charKey, queueSlot: badgeQueueSlot)
                ) * contextNudge.sizeMul
                let hpOffX: Double = (gs.currentRoundUsesFeetAnchor
                    ? layoutConfig.resolvedHpBadgeX(height: csHpBadge.heightBucket, width: csHpBadge.widthBucket, characterId: customer.charKey, slotForLegacy: badgeQueueSlot)
                    : layoutConfig.hpBadgeOffsetX(for: customer.charKey, queueSlot: badgeQueueSlot)
                ) + contextNudge.dx
                let hpOffY: Double = (gs.currentRoundUsesFeetAnchor
                    ? layoutConfig.resolvedHpBadgeY(height: csHpBadge.heightBucket, width: csHpBadge.widthBucket, characterId: customer.charKey, slotForLegacy: badgeQueueSlot)
                    : layoutConfig.hpBadgeOffsetY(for: customer.charKey, queueSlot: badgeQueueSlot)
                ) + contextNudge.dy

                // HP Badge (ABOVE character's head — shows for active AND waiting customers)
                ZStack {
                    // Custom HP badge graphic (background).
                    // JUNE 20, 2026: use the RED badge when this is the ACTIVE
                    // customer and the current board previews damage against
                    // them (potion/stability dice placed) — signals "taking
                    // damage". Otherwise the normal (purple) badge. Hidden
                    // during the brew animation so it tracks placement only.
                    // JUNE 20, 2026: badge asset by state, in priority order:
                    //  1. hp_damage  — actively being HIT (brew landed), brief.
                    //  2. PULSE between hp_badge_red ↔ hp_badge — active
                    //     customer with STAGED damage (potion/stability dice
                    //     placed, pre-brew). Pulses to draw the eye to the
                    //     pending damage.
                    //  3. hp_badge   — normal (purple).
                    let isActiveCustomer = (gs.queue.first == customer.id)
                    let hasIncomingDamage = isActiveCustomer
                        && !gs.isAnimating
                        && gs.livePreview.damage > 0
                    TimelineView(.animation) { timeline in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        // Smooth 0→1 fade (sine), ~0.7s period, for a gentle
                        // pulse rather than a hard flash. Shared phase with the
                        // banner so they pulse in sync.
                        let fade = 0.5 + 0.5 * sin(t * PotionShopBrewAnimator.damagePulseSpeed)
                        ZStack {
                            if takingDamage, let img = UIImage(named: "hp_damage") {
                                Image(uiImage: img).resizable().scaledToFit()
                                    .frame(width: hpSize * scale, height: hpSize * scale)
                            } else {
                                // Base normal badge
                                badgeImage("hp_badge", hpSize: hpSize, scale: scale)
                                // Red badge fades in/out on top when damage staged
                                if hasIncomingDamage {
                                    badgeImage("hp_badge_red", hpSize: hpSize, scale: scale)
                                        .opacity(fade)
                                }
                            }
                        }
                    }

                    // HP number — rolling counter. JUNE 20, 2026: when this
                    // customer BECOMES active, the number rolls down from their
                    // real HP to the board-adjusted value (real − board damage).
                    // While already active and placing dice, it tracks live.
                    PotionShopRollingHPText(
                        target: liveHP,
                        realHP: gs.customers.first(where: { $0.id == customer.id })?.hp ?? customer.hp,
                        isActive: gs.queue.first == customer.id,
                        isAnimating: gs.isAnimating,
                        fontSize: 18 * scale
                    )

                    // JUNE 20, 2026: damage burst CENTERED ON THE HP BADGE.
                    // Living inside the badge ZStack means it inherits the
                    // exact badge position/size configured in the debug menu.
                    PotionShopDamageBurst(trigger: burstTick, scale: scale)
                }
                // Include effectiveX/Y so the badge tracks the body within the slot.
                .offset(
                    x: effectiveX + headOffsetX + hpOffX * scale,
                    y: effectiveY + headOffsetY + hpOffY * scale
                )
                // JUNE 24, 2026: badge follows the SAME front-to-back order as
                // the customers (active in front, slot2 behind). The badge has
                // transition/animation modifiers that can lift it out of normal
                // z-flow, so it gets an explicit zIndex tied to queue position.
                .zIndex(Double(queueCount - queueIndex))
                .transition(.scale.combined(with: .opacity))
                // Contextual nudges re-resolve when the lineup changes —
                // ease the hop so it reads as intentional, not a glitch.
                .animation(.easeInOut(duration: 0.25), value: frontNeighborKey)
                // June 12, 2026: with the editor open, the HP badge itself is
                // tappable (jumps to the focused editor) and draggable (writes
                // the same X/Y the HP badge sliders edit — mode-aware, and
                // respecting the "Override for slot N only" toggle).
                .contentShape(Circle())
                .onTapGesture {
                    if PotionShopLayoutConfig.shared.layoutEditorIsOpen {
                        PotionShopLayoutConfig.shared.selectedCharacterId = customer.charKey
                        PotionShopLayoutConfig.shared.selectedSlotIndex = badgeQueueSlot
                        PotionShopEditorHistory.shared.jumpRequest =
                            PotionShopEditorJump(target: .autoLayout)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            guard PotionShopLayoutConfig.shared.layoutEditorIsOpen else { return }
                            let xAcc = badgeXAccessors(slotIdx: badgeQueueSlot)
                            let yAcc = badgeYAccessors(slotIdx: badgeQueueSlot)
                            if !editorBadgeDrag.active {
                                PotionShopLayoutConfig.shared.selectedCharacterId = customer.charKey
                                PotionShopLayoutConfig.shared.selectedSlotIndex = badgeQueueSlot
                                editorBadgeDrag.begin(label: "\(customer.charKey) HP badge",
                                                      readX: xAcc.read, applyX: xAcc.apply,
                                                      readY: yAcc.read, applyY: yAcc.apply)
                            }
                            // Badge offsets render multiplied by `scale`, so a
                            // screen-point drag delta converts back by ÷ scale.
                            let s = max(scale, 0.001)
                            xAcc.apply(editorBadgeDrag.startX + value.translation.width / s)
                            yAcc.apply(editorBadgeDrag.startY + value.translation.height / s)
                        }
                        .onEnded { _ in
                            editorBadgeDrag.end()
                        }
                )

                } // end HP badge conditional

                // Attack Badge (ABOVE character's head, offset to right)
                // Hidden in any feet-anchor round (R2 + R3) for now.
                if !gs.currentRoundUsesFeetAnchor, attack > 0 {
                    ZStack {
                        // Custom attack badge graphic (background)
                        if let attackBadgeImage = UIImage(named: "attack_badge") {
                            Image(uiImage: attackBadgeImage)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: PotionShopLayoutConfig.shared.attackBadgeSize(for: customer.charKey, queueSlot: badgeQueueSlot) * scale,
                                    height: PotionShopLayoutConfig.shared.attackBadgeSize(for: customer.charKey, queueSlot: badgeQueueSlot) * scale
                                )
                        } else {
                            // Fallback: red circle if image missing
                            Circle()
                                .fill(PotionShopTheme.composureBad)
                                .frame(
                                    width: PotionShopLayoutConfig.shared.attackBadgeSize(for: customer.charKey, queueSlot: badgeQueueSlot) * scale,
                                    height: PotionShopLayoutConfig.shared.attackBadgeSize(for: customer.charKey, queueSlot: badgeQueueSlot) * scale
                                )
                        }

                        // Attack number (white text on top)
                        Text("\(attack)")
                            .font(Font.gameScore(size: 15 * scale))
                            .foregroundColor(.white)
                    }
                    .offset(
                        x: effectiveX + headOffsetX + PotionShopLayoutConfig.shared.attackBadgeOffsetX(for: customer.charKey, queueSlot: badgeQueueSlot) * scale,
                        y: effectiveY + headOffsetY + PotionShopLayoutConfig.shared.attackBadgeOffsetY(for: customer.charKey, queueSlot: badgeQueueSlot) * scale
                    )
                } // end Attack badge conditional

                // PHASE 7: 💢 emoji burst on expiration
                if PotionShopBrewAnimator.expirationShowEmoji {
                    Text(PotionShopBrewAnimator.expirationEmoji)
                        .font(.system(size: 30 * scale))
                        .opacity(emojiOpacity)
                        .offset(x: 20, y: -30 + emojiOffset)
                }
            }
            // Skip global dim when silhouette mode is active (silhouette
            // handles its own fade and we want badges/emoji at full opacity).
            .opacity((dim && !useWhiteSilhouette && !attacking) ? 0.55 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: attacking)
            .opacity(expireOpacity)
            .opacity(defeatOpacity)   // JUNE 13: defeat fade-out
            .scaleEffect(scale * settleBoost)
            // JUNE 13 fix: once defeated, hold the position FROZEN at the
            // defeat spot so the queue re-index can't drag the dying view
            // rightward. Until then, normal positioning.
            .position(
                x: defeatFrozen ? defeatFrozenX : (xPos + shakeOffset + expireSlideX),
                y: defeatFrozen ? defeatFrozenY : yPos
            )
            // Skip matchedGeometry while defeated — being in the namespace is
            // what pulled the dying view toward the new layout.
            .modifier(PotionShopConditionalMatchedGeometry(
                active: !defeatFrozen,
                id: customer.id,
                namespace: animationNamespace
            ))
            .animation(
                // Freeze the queue-reposition spring while defeated so the
                // fade plays cleanly in place.
                defeatFrozen ? nil : .spring(response: 0.55, dampingFraction: 0.78),
                value: queueIndex
            )
            // PHASE 7: shake when shake counter increments
            .onChange(of: gs.customerShakeCounters[customer.id] ?? 0) {
                runShake()
                // JUNE 20: pop to full opacity for the shake's duration (so a
                // dimmed waiter is clearly visible while it attacks).
                attacking = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    attacking = false
                }
                // damage burst + hp_damage badge only for the ACTIVE customer
                // (the one taking the brew hit) — not waiting customers.
                if gs.queue.first == customer.id {
                    burstTick += 1
                    takingDamage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        takingDamage = false
                    }
                }
            }
            // PHASE 7: slide off-screen when added to expiringCustomerIds
            .onChange(of: gs.expiringCustomerIds.contains(customer.id)) { _, isExpiring in
                if isExpiring {
                    runExpiration()
                }
            }
            // JUNE 13 fix: when this customer becomes defeated, freeze it at
            // its current spot and fade out in place (no snap, no slide).
            .onChange(of: customer.status) { _, newStatus in
                if newStatus == .defeated && !defeatFrozen {
                    runDefeat()
                }
            }
            .onAppear {
                // Catch the case where the view appears already defeated.
                if customer.status == .defeated && !defeatFrozen {
                    runDefeat()
                }
            }
            .onChange(of: arrivalCounter) {
                guard isActive else { return }
                withAnimation(.easeOut(duration: 0.12)) {
                    settleBoost = 1.10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                        settleBoost = 1.0
                    }
                }
            }
        }
    }

    /// JUNE 20, 2026: helper to build a badge image (or red-circle fallback)
    /// at the right size, used by the crossfade pulse.
    @ViewBuilder
    private func badgeImage(_ name: String, hpSize: Double, scale: CGFloat) -> some View {
        if let img = UIImage(named: name) {
            Image(uiImage: img).resizable().scaledToFit()
                .frame(width: hpSize * scale, height: hpSize * scale)
        } else {
            Circle().fill(PotionShopTheme.composureBad)
                .frame(width: hpSize * scale, height: hpSize * scale)
        }
    }

    private func runShake() {
        let amp = PotionShopBrewAnimator.shakeAmplitude
        let oscillations = PotionShopBrewAnimator.shakeOscillations
        let totalDur = PotionShopBrewAnimator.shakeDuration
        let stepDur = totalDur / Double(oscillations * 2)

        // Build the shake pattern: +amp, -amp, +amp*0.7, -amp*0.7, ... → 0
        var deadline: DispatchTime = .now()
        for i in 0..<(oscillations * 2) {
            let dampening = 1.0 - (Double(i) / Double(oscillations * 2)) * 0.5
            let target: CGFloat = (i % 2 == 0 ? amp : -amp) * CGFloat(dampening)
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                withAnimation(.easeInOut(duration: stepDur)) {
                    shakeOffset = target
                }
            }
            deadline = deadline + .milliseconds(Int(stepDur * 1000))
        }
        // Settle back to 0
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            withAnimation(.easeOut(duration: stepDur)) {
                shakeOffset = 0
            }
        }
    }

    /// JUNE 13, 2026 — DEFEAT exit. Freeze the customer at its current
    /// on-screen spot (so the impending queue re-index can't drag it
    /// rightward) and fade it out in place. The GameState removes it from
    /// the queue shortly after (end-of-brew bookkeeping); by then it's
    /// already invisible, so the removal is unseen and there's no snap.
    private func runDefeat() {
        defeatFrozenX = xPos + shakeOffset
        defeatFrozenY = yPos
        defeatFrozen = true
        withAnimation(.easeIn(duration: 0.35)) {
            defeatOpacity = 0.0
        }
    }

    private func runExpiration() {
        // 💢 emoji burst (if enabled)
        if PotionShopBrewAnimator.expirationShowEmoji {
            withAnimation(.easeOut(duration: 0.25)) {
                emojiOpacity = 1.0
                emojiOffset = -10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                withAnimation(.easeIn(duration: 0.20)) {
                    emojiOpacity = 0.0
                }
            }
        }
        // Slide off-screen + fade
        withAnimation(.easeIn(duration: PotionShopBrewAnimator.expirationDuration * 0.85)) {
            expireSlideX = PotionShopBrewAnimator.expirationSlideDistance
            expireOpacity = 0.0
        }
    }
}

// MARK: - Conditional matchedGeometryEffect (June 13, 2026)
//
// Applies matchedGeometryEffect ONLY when `active`. A defeated customer
// sets active=false so its dying view leaves the shared-geometry group and
// can't be pulled toward the re-indexed queue layout (the snap-right bug).
struct PotionShopConditionalMatchedGeometry: ViewModifier {
    let active: Bool
    let id: UUID
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        if active {
            content.matchedGeometryEffect(
                id: id, in: namespace, properties: [.position, .size]
            )
        } else {
            content
        }
    }
}

// MARK: - Profile row (with optional inspect strip + hint banner)

struct PotionShopProfileRowView: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                PotionShopProfileButtonsRow(gs: gs)
                    .opacity(gs.inspectedId == nil ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.2), value: gs.inspectedId)

                if let inspectedId = gs.inspectedId,
                   let inspected = gs.customers.first(where: { $0.id == inspectedId }),
                   inspected.status == .waiting {
                    PotionShopInspectStripView(gs: gs, customer: inspected)
                }
            }
            .frame(maxWidth: .infinity)

            if gs.selectedHandIndex != nil {
                HStack(spacing: 6) {
                    Text("🎯")
                        .font(.system(size: 13))
                    Text("Tap a node in the cauldron to place this die")
                        .font(Font.gameUI(size: 12))
                        .foregroundColor(PotionShopTheme.accent)
                }
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.55))
                .overlay(
                    Rectangle()
                        .fill(PotionShopTheme.accent.opacity(0.3))
                        .frame(height: 1),
                    alignment: .top
                )
                .overlay(
                    Rectangle()
                        .fill(PotionShopTheme.accent.opacity(0.3))
                        .frame(height: 1),
                    alignment: .bottom
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 6)
        .animation(.easeInOut(duration: 0.2), value: gs.selectedHandIndex)
    }
}

struct PotionShopProfileButtonsRow: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        HStack(spacing: 18) {
            ForEach(gs.customers) { cust in
                PotionShopProfileButtonView(gs: gs, customer: cust)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PotionShopProfileButtonView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer

    private var char: PotionShopCharacter? {
        PotionShopData.character(customer.charKey)
    }
    private var isActive: Bool { gs.queue.first == customer.id }

    /// JUNE 15, 2026 fix — read LIVE patience from gs.customers (by id)
    /// rather than the `let customer` copy passed into this view. The copy
    /// could go stale, leaving the ring stuck at full even though the brew
    /// sequence was decrementing the real array. Looking it up here forces
    /// the ring to reflect the current value every render.
    private var liveCustomer: PotionShopCustomer {
        gs.customers.first(where: { $0.id == customer.id }) ?? customer
    }
    private var livePatience: Int { liveCustomer.patience }
    private var liveMaxPatience: Int { liveCustomer.maxPatience }

    private var ringColor: Color {
        if liveMaxPatience == 0 { return PotionShopTheme.muted }
        let pct = Double(livePatience) / Double(liveMaxPatience)
        if pct > 0.4 { return PotionShopTheme.composureGood }
        return PotionShopTheme.composureWarn
    }

    var body: some View {
        Button {
            gs.tapProfile(customer.id)
        } label: {
            ZStack {
                // JUNE 15, 2026: thicker (3→6) gray track + live-patience
                // colored ring so the depletion is visible and actually moves.
                Circle()
                    .stroke(PotionShopTheme.muted.opacity(0.22),
                            lineWidth: 6)
                    .frame(
                        width: PotionShopSceneLayout.profileDiameter + 8,
                        height: PotionShopSceneLayout.profileDiameter + 8
                    )
                Circle()
                    .trim(
                        from: 0,
                        to: liveMaxPatience > 0
                            ? Double(livePatience) / Double(liveMaxPatience)
                            : 0
                    )
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(
                        width: PotionShopSceneLayout.profileDiameter + 8,
                        height: PotionShopSceneLayout.profileDiameter + 8
                    )
                    .animation(.easeInOut(duration: 0.4), value: livePatience)

                Circle()
                    .fill(Color(red: 0.96, green: 0.92, blue: 0.84))
                    .frame(
                        width: PotionShopSceneLayout.profileDiameter,
                        height: PotionShopSceneLayout.profileDiameter
                    )
                    .overlay(
                        Circle()
                            .stroke(isActive ? PotionShopTheme.ink : PotionShopTheme.muted, lineWidth: isActive ? 2.5 : 1.5)
                    )

                if let char = char {
                    PotionShopImageLoader.imageOrEmoji(
                        assetName: char.portrait,
                        fallbackEmoji: char.iconFallback,
                        size: PotionShopSceneLayout.profileDiameter
                    )
                }

                if customer.status == .defeated {
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(
                            width: PotionShopSceneLayout.profileDiameter,
                            height: PotionShopSceneLayout.profileDiameter
                        )
                    Text("✓")
                        .font(Font.gameScore(size: 28))
                        .foregroundColor(PotionShopTheme.composureGood)
                } else if customer.status == .expired {
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(
                            width: PotionShopSceneLayout.profileDiameter,
                            height: PotionShopSceneLayout.profileDiameter
                        )
                    Text("✗")
                        .font(Font.gameScore(size: 28))
                        .foregroundColor(PotionShopTheme.composureBad)
                }
            }
            .opacity(isActive ? 1.0 : 0.65)
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
        }
        .disabled(customer.status != .waiting || gs.isAnimating)
    }
}

// MARK: - Inspect strip (split-slide animation, Phase 6d)

struct PotionShopInspectStripView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer

    @State private var isExpanded: Bool = false
    // JUNE 20, 2026: true briefly while the inspected customer is being HIT by
    // a brew, so the banner bottle can show hp_damage (synced to the HP badge).
    @State private var takingDamage: Bool = false

    private var char: PotionShopCharacter? {
        PotionShopData.character(customer.charKey)
    }

    private var isActive: Bool { gs.queue.first == customer.id }

    private var brewTargetForPill: Int {
        // Always show the inspected customer's HP — updates as HP changes.
        return customer.hp
    }

    /// JUNE 20, 2026: board-adjusted HP for the banner pill, so it can roll the
    /// same way the HP badge does. If the inspected customer is the ACTIVE one
    /// and not mid-brew, subtract the previewed board damage (clamped at 0).
    private var bannerLiveTarget: Int {
        let actual = liveCustomer.hp
        if gs.queue.first == customer.id, !gs.isAnimating {
            return max(0, actual - gs.livePreview.damage)
        }
        return actual
    }

    /// JUNE 15, 2026 fix — read LIVE patience from gs.customers (by id)
    /// rather than the `let customer` copy passed into this view, so the
    /// ring reflects the brew-sequence decrement instead of sitting full.
    private var liveCustomer: PotionShopCustomer {
        gs.customers.first(where: { $0.id == customer.id }) ?? customer
    }
    private var livePatience: Int { liveCustomer.patience }
    private var liveMaxPatience: Int { liveCustomer.maxPatience }

    private var attackForSubtitle: Int {
        guard let c = char else { return 0 }
        return isActive ? c.activeAttack : c.waitingAttack
    }

    /// June 18, 2026: the order PHRASE shown on the banner's bottom row —
    /// the random line picked at spawn; falls back to orderDialogue / orderName.
    private var orderLineToShow: String {
        if !customer.chosenOrderPhrase.isEmpty { return customer.chosenOrderPhrase }
        if let c = char, !c.orderDialogue.isEmpty { return c.orderDialogue }
        return char?.orderName ?? ""
    }

    private var patienceRingColor: Color {
        if liveMaxPatience == 0 { return PotionShopTheme.muted }
        let pct = Double(livePatience) / Double(liveMaxPatience)
        if pct > 0.4 { return PotionShopTheme.composureGood }
        return PotionShopTheme.composureWarn
    }

    var body: some View {
        if let char = char {
            HStack(spacing: -35) {
                // Portrait circle (LEFT - sticks out)
                portraitView(char: char)
                    .offset(x: isExpanded ? 0 : 40)
                    .opacity(isExpanded ? 1.0 : 0.0)
                    .zIndex(1)
                
                // Main banner capsule (contains text + potion bottle value)
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        // TOP ROW (June 18, 2026): name • [trait] number.
                        // The "Atk" word is dropped; the trait word stands in
                        // for the label and the bare number is the attack value
                        // (kept visible for testing). e.g. "Rex • Brave 2".
                        HStack(spacing: 8) {
                            Text(char.name)
                                .font(Font.gameUI(size: 48))
                                .foregroundColor(PotionShopTheme.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text("•")
                                .foregroundColor(PotionShopTheme.muted)
                            HStack(spacing: 5) {
                                if !customer.chosenTraitName.isEmpty {
                                    Text(customer.chosenTraitName)
                                        .font(Font.gameUI(size: 28))
                                        .foregroundColor(PotionShopTheme.accent)
                                        .lineLimit(1)
                                }
                                Text("\(attackForSubtitle)")
                                    .font(Font.gameUI(size: 33))
                                    .foregroundColor(PotionShopTheme.muted)
                            }
                        }
                        // BOTTOM ROW: the order PHRASE the customer is saying.
                        Text(orderLineToShow)
                            .font(Font.gameUI(size: 25))
                            .foregroundColor(PotionShopTheme.muted)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .offset(x: isExpanded ? 0 : -40)
                    .opacity(isExpanded ? 1.0 : 0.0)
                    
                    Spacer()
                    
                    // Potion bottle value (INSIDE banner)
                    // Option C + D: Fixed size with number shrinking to fit, resizable via layout editor
                    ZStack {
                        // Bottle graphic (background)
                        // JUNE 20, 2026: banner bottle + number, with a synced
                        // staged-damage pulse. The bottle crossfades to
                        // potion_bottle_damage and the number fades toward red,
                        // both on the SAME sine phase as the HP badge.
                        let bannerHasIncomingDamage = (gs.queue.first == customer.id)
                            && !gs.isAnimating
                            && gs.livePreview.damage > 0
                        TimelineView(.animation) { timeline in
                            let t = timeline.date.timeIntervalSinceReferenceDate
                            let fade = 0.5 + 0.5 * sin(t * PotionShopBrewAnimator.damagePulseSpeed)
                            let dmgFade = bannerHasIncomingDamage ? fade : 0.0
                            let bottleSize = PotionShopLayoutConfig.shared.bannerBottleSize
                            ZStack {
                                // JUNE 20, 2026: during the HIT, hp_damage
                                // REPLACES the bottle entirely. Otherwise show
                                // the normal bottle + the staged-damage fade.
                                if takingDamage, let hitImage = UIImage(named: "hp_damage") {
                                    Image(uiImage: hitImage).resizable().scaledToFit()
                                        .frame(width: bottleSize, height: bottleSize)
                                        // JUNE 20, 2026: y-offset knob for the
                                        // hp_damage banner image. Negative = up,
                                        // positive = down. Adjust this number.
                                        .offset(y: 5)
                                } else {
                                    // Base bottle outline
                                    if let bottleImage = UIImage(named: "potion_bottle_outline") {
                                        Image(uiImage: bottleImage).resizable().scaledToFit()
                                            .frame(width: bottleSize, height: bottleSize)
                                    } else {
                                        Text("🧪").font(.system(size: bottleSize * 0.7))
                                    }
                                    // Damage bottle fades in/out on top when staged
                                    if let dmgImage = UIImage(named: "potion_bottle_damage") {
                                        Image(uiImage: dmgImage).resizable().scaledToFit()
                                            .frame(width: bottleSize, height: bottleSize)
                                            .opacity(dmgFade)
                                    }
                                }
                                // Number stays WHITE (the bottle carries the
                                // red pulse) so it never blends into the red,
                                // and zIndex forces it above both bottle images.
                                PotionShopRollingHPText(
                                    target: bannerLiveTarget,
                                    realHP: liveCustomer.hp,
                                    isActive: gs.queue.first == customer.id,
                                    isAnimating: gs.isAnimating,
                                    fontSize: PotionShopLayoutConfig.shared.bannerBottleNumberSize,
                                    color: .white
                                )
                                .shadow(color: .black.opacity(0.55), radius: 1, x: 0, y: 1)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .offset(
                                    x: PotionShopLayoutConfig.shared.bannerBottleNumberOffsetX,
                                    y: PotionShopLayoutConfig.shared.bannerBottleNumberOffsetY
                                )
                                .zIndex(10)
                            }
                        }
                    }
                    .offset(
                        x: (isExpanded ? 0 : -60) + PotionShopLayoutConfig.shared.bannerBottleOffsetX,
                        y: PotionShopLayoutConfig.shared.bannerBottleOffsetY
                    )
                    .opacity(isExpanded ? 1.0 : 0.0)
                }
                .padding(.leading, 50)
                .padding(.trailing, 14)
                .padding(.vertical, 8)
                .background(
                    // OPTION 3: Custom parchment border replaces code border entirely
                    GeometryReader { geo in
                        if let borderImage = UIImage(named: "banner_border") {
                            // User's hand-drawn parchment border (PRIMARY)
                            Image(uiImage: borderImage)
                                .resizable()
                                .frame(width: geo.size.width, height: geo.size.height)
                        } else {
                            // Fallback to code-drawn border if image missing (SAFETY NET)
                            Capsule()
                                .fill(Color.white.opacity(0.85))
                                .overlay(
                                    Capsule()
                                        .stroke(PotionShopTheme.accent, lineWidth: 2)
                                )
                        }
                    }
                    .opacity(isExpanded ? 1.0 : 0.0)
                )
                .zIndex(0)
            }
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    gs.dismissInspect()
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                    isExpanded = true
                }
            }
            // JUNE 20, 2026: when the inspected customer is the ACTIVE one and
            // gets hit (shake counter ticks), flash hp_damage on the banner —
            // same window/signal the HP badge uses, so they show together.
            .onChange(of: gs.customerShakeCounters[customer.id] ?? 0) {
                if gs.queue.first == customer.id {
                    takingDamage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        takingDamage = false
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func portraitView(char: PotionShopCharacter) -> some View {
        ZStack {
            // Opaque background circle (blocks banner behind it)
            Circle()
                .fill(Color(red: 0.96, green: 0.92, blue: 0.84))
                .frame(width: 70, height: 70)
            
            // Gray guide ring (shows full patience capacity)
            Circle()
                .stroke(PotionShopTheme.muted.opacity(0.25), lineWidth: 6)
                .frame(width: 70, height: 70)
            
            // Colored patience ring (shows remaining time).
            // JUNE 15, 2026: thickened 3→6pt with round caps, AND reads LIVE
            // patience (livePatience/liveMaxPatience from gs.customers) so it
            // actually depletes — the passed-in `customer` copy was stale,
            // which is why the ring sat full no matter how many brews.
            Circle()
                .trim(
                    from: 0,
                    to: liveMaxPatience > 0
                        ? Double(livePatience) / Double(liveMaxPatience)
                        : 0
                )
                .stroke(patienceRingColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 70, height: 70)
                .animation(.easeInOut(duration: 0.4), value: livePatience)
            
            // Portrait image (on top of everything)
            Circle()
                .fill(Color(red: 0.96, green: 0.92, blue: 0.84))
                .frame(width: 62, height: 62)
                .overlay(
                    PotionShopImageLoader.imageOrEmoji(
                        assetName: char.portrait,
                        fallbackEmoji: char.iconFallback,
                        size: 62
                    )
                )
        }
    }
}

// MARK: - Rolling HP counter — slot-machine style (June 20, 2026)
//
// Shows a customer's HP. When ACTIVE and the board reduces their HP, the
// number "spins" slot-machine style from their real HP down to the
// board-adjusted target, then settles. Robust to the view being recreated
// on customer-switch (it keys the roll off target/realHP at appear time and
// on change, not just onChange(isActive) which may never fire across a swap).
struct PotionShopRollingHPText: View {
    let target: Int      // value to display (board-adjusted for the active customer)
    let realHP: Int      // true current HP (pre-board)
    let isActive: Bool
    let isAnimating: Bool   // JUNE 20: true during a brew — hold value, don't snap
    let fontSize: Double
    var color: Color = .white   // JUNE 20: tintable (banner pulses it red)

    @State private var displayed: Int = 0
    @State private var spinTimer: Timer? = nil
    @State private var rollTimer: Timer? = nil
    @State private var wasActive: Bool = false
    @State private var spinning: Bool = false
    @State private var didInit: Bool = false

    var body: some View {
        Text("\(displayed)")
            .font(Font.gameScore(size: fontSize))
            .foregroundColor(color)
            .onAppear {
                guard !didInit else { return }
                didInit = true
                wasActive = isActive
                if isActive && target < realHP {
                    beginDelayedSpin(from: realHP, to: target)
                } else {
                    displayed = isActive ? target : realHP
                }
            }
            .onDisappear { spinTimer?.invalidate(); rollTimer?.invalidate() }
            // The ONLY trigger for the slot-machine spin: this customer just
            // became active (a SWAP). Start from their ORIGINAL HP (realHP)
            // and roll down to the board-adjusted target.
            .onChange(of: isActive) { _, nowActive in
                if nowActive && !wasActive {
                    if target < realHP {
                        beginDelayedSpin(from: realHP, to: target)
                    } else {
                        displayed = target          // no board damage → just show it
                    }
                } else if !nowActive {
                    spinTimer?.invalidate()
                    rollTimer?.invalidate()
                    spinning = false
                    displayed = realHP              // demoted: show true HP
                }
                wasActive = nowActive
            }
            // Placing/removing dice on the ALREADY-active customer now SCROLLS
            // the number to the new target (quick count) instead of snapping.
            // Interruptible: each new placement restarts the short roll from
            // the CURRENT displayed value, so rapid placing stays responsive.
            // Skipped during the swap spin (spinning) or the brew (isAnimating).
            .onChange(of: target) { _, newTarget in
                // Placement scroll runs for the active customer — but NOT while
                // a swap spin is in progress/pending (spinning), or it would
                // cancel the spin and snap to the affected value (the bug where
                // a swapped-in customer started at affected HP). The brew
                // animation also suppresses it.
                if isActive && !spinning && !isAnimating {
                    quickRoll(to: newTarget)
                }
            }
            // Real HP changing keeps non-active honest. For the ACTIVE
            // customer DURING a brew, the damage phase lowers realHP — follow
            // it down so the number lands on the true post-brew hp (no flash).
            .onChange(of: realHP) { _, newReal in
                if !isActive {
                    displayed = newReal
                } else if isAnimating {
                    rollTimer?.invalidate()
                    displayed = newReal
                }
            }
    }

    /// Delay before the spin so it waits out the customer-swap slide, THEN
    /// spins from the original HP down to the board-adjusted target. Show the
    /// original HP during the wait so it visibly starts at the right number.
    private func beginDelayedSpin(from: Int, to: Int) {
        spinTimer?.invalidate()
        spinning = true
        displayed = from                            // hold ORIGINAL HP during the wait
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.spinStartDelay) {
            // Bail if the player swapped away again during the delay.
            guard isActive, wasActive else { spinning = false; return }
            spin(from: from, to: to)
        }
    }

    /// Delay before the become-active spin starts, so it waits out the
    /// customer-swap slide. Bump this up if the spin still overlaps the slide.
    static let spinStartDelay: Double = 0.60

    /// JUNE 20, 2026: quick interruptible count from the CURRENT displayed
    /// value to `to`, used when placing/removing dice on the active customer.
    /// Steps one number at a time, fast (~28ms/step), capped so big jumps
    /// don't drag. Restarting it (new placement) cancels the prior roll.
    private func quickRoll(to: Int) {
        rollTimer?.invalidate()
        let from = displayed
        guard from != to else { return }
        let step = to > from ? 1 : -1
        let stepInterval = 0.028
        // Cap total duration ~0.32s: if the jump is large, move >1 per tick.
        let distance = abs(to - from)
        let maxTicks = 12
        let perTick = max(1, Int(ceil(Double(distance) / Double(maxTicks))))
        let t = Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { timer in
            let remaining = to - displayed
            if abs(remaining) <= perTick {
                displayed = to
                timer.invalidate()
            } else {
                displayed += step * perTick
            }
        }
        RunLoop.main.add(t, forMode: .common)
        rollTimer = t
    }

    /// Slot-machine spin: flicker through rapidly-changing numbers, decelerate,
    /// land on `to`. Uses a repeating timer with easing on the step interval.
    private func spin(from: Int, to: Int) {
        displayed = from
        let span = max(1, from - to)
        // Total ticks of the reel — more for bigger drops, capped.
        let ticks = min(10, 5 + span)
        var i = 0
        // Ease-out: start fast, end slow.
        func interval(forStep step: Int) -> Double {
            let p = Double(step) / Double(ticks)          // 0→1
            return 0.018 + 0.085 * (p * p)                // 18ms → ~103ms
        }
        func scheduleNext() {
            guard i < ticks else {
                displayed = to
                spinning = false
                return
            }
            let t = Timer.scheduledTimer(withTimeInterval: interval(forStep: i), repeats: false) { _ in
                i += 1
                if i >= ticks {
                    displayed = to
                    spinning = false
                } else {
                    // For the last few ticks, home in toward `to`; before that,
                    // flicker random values in the (to...from) range for the
                    // slot-machine look.
                    let remaining = ticks - i
                    if remaining <= 4 {
                        // Glide the final stretch deterministically to `to`.
                        let stepDown = Double(from - to) * (Double(remaining) / 4.0)
                        displayed = to + Int(stepDown.rounded())
                    } else {
                        displayed = Int.random(in: min(to, from)...max(to, from))
                    }
                    scheduleNext()
                }
            }
            RunLoop.main.add(t, forMode: .common)
            spinTimer = t
        }
        scheduleNext()
    }
}

// MARK: - Damage particle burst (June 20, 2026)
//
// A quick radial burst of shards, fired when `trigger` increments (the brew
// hits this customer). Purely cosmetic feedback to sell the HP drop.
struct PotionShopDamageBurst: View {
    let trigger: Int
    let scale: CGFloat

    @State private var animate = false
    @State private var shown = false

    private let count = 10

    var body: some View {
        ZStack {
            if shown {
                ForEach(0..<count, id: \.self) { i in
                    let angle = Double(i) / Double(count) * 2 * .pi
                    let dist: CGFloat = animate ? 34 * scale : 4 * scale
                    Circle()
                        .fill(PotionShopTheme.composureBad)
                        .frame(width: 7 * scale, height: 7 * scale)
                        .offset(
                            x: cos(angle) * dist,
                            y: sin(angle) * dist
                        )
                        .opacity(animate ? 0 : 1)
                        .scaleEffect(animate ? 0.4 : 1.0)
                }
            }
        }
        .onChange(of: trigger) { _, _ in
            guard trigger > 0 else { return }
            shown = true
            animate = false
            withAnimation(.easeOut(duration: 0.45)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shown = false
            }
        }
    }
}

// JUNE 20, 2026: linear interpolation between two SwiftUI Colors via UIColor
// RGBA components. Used to fade the banner HP number white → red on the pulse.
func PotionShopLerpColor(_ a: Color, _ b: Color, _ t: Double) -> Color {
    let ua = UIColor(a); let ub = UIColor(b)
    var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
    var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
    ua.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
    ub.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
    let f = CGFloat(max(0, min(1, t)))
    return Color(
        red: Double(ar + (br - ar) * f),
        green: Double(ag + (bg - ag) * f),
        blue: Double(ab + (bb - ab) * f),
        opacity: Double(aa + (ba - aa) * f)
    )
}
