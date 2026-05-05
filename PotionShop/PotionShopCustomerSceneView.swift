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

    static let queueXFractions1: [CGFloat] = [0.75]
    static let queueXFractions2: [CGFloat] = [0.55, 0.85]
    static let queueXFractions3: [CGFloat] = [0.48, 0.68, 0.88]

    static let queueYFractions: [CGFloat] = [0.48, 0.55, 0.55]

    static let queueScales: [CGFloat] = [1.0, 0.78, 0.72]
    static let queueDims:   [Bool]    = [false, true, true]

    static let portraitDiameter: CGFloat = 76
    static let profileDiameter:  CGFloat = 56

    static func queueXFractions(for count: Int) -> [CGFloat] {
        switch count {
        case 1:  return queueXFractions1
        case 2:  return queueXFractions2
        case 3:  return queueXFractions3
        default: return queueXFractions3
        }
    }
}

// MARK: - Customer scene

struct PotionShopCustomerSceneView: View {
    @Bindable var gs: PotionShopGameState
    var ednarArtScale: Double = 1.0  // ART SCALE - Pass through to Ednar view
    var ednarArtWidth: Double = 1.0  // FREEFORM - Width scale
    var ednarArtHeight: Double = 1.0 // FREEFORM - Height scale
    var ednarArtXOffset: Double = 0  // FREEFORM - X position
    var ednarArtYOffset: Double = 0  // FREEFORM - Y position

    @Namespace private var queueAnimation
    @State private var activeArrivalCounter: Int = 0
    @State private var lastActiveId: UUID? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                // LAYER 1: BACKGROUND (always first = bottom layer)
                backgroundLayer(geo: geo)
                
                // LAYER 2: Floor line
                floorLine

                // LAYER 3: Ednar
                PotionShopEdnarView(
                    gs: gs,
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

                ForEach(Array(gs.queue.enumerated()), id: \.element) { idx, custId in
                    if let cust = gs.customers.first(where: { $0.id == custId }) {
                        PotionShopCustomerInSceneView(
                            gs: gs,
                            customer: cust,
                            queueIndex: idx,
                            queueCount: gs.queue.count,
                            sceneSize: geo.size,
                            animationNamespace: queueAnimation,
                            arrivalCounter: activeArrivalCounter
                        )
                    }
                }

                if gs.shield > 0 {
                    Text("🛡 \(gs.shield)")
                        .font(.system(size: 12, weight: .bold))
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
            if let backgroundImage = UIImage(named: "customerbg") {
                let _ = print("✅ LOADED: customerbg")
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
            } else {
                let _ = print("❌ customerbg NOT FOUND - Using gradient only")
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
    var ednarArtScale: Double = 1.0    // ART SCALE - Scale multiplier for Ednar image
    var ednarArtWidth: Double = 1.0    // FREEFORM - Independent width scale
    var ednarArtHeight: Double = 1.0   // FREEFORM - Independent height scale
    var ednarArtXOffset: Double = 0    // FREEFORM - X position offset (pts)
    var ednarArtYOffset: Double = 0    // FREEFORM - Y position offset (pts)

    private var expressionAssetName: String {
        let pct = Double(gs.composure) / Double(PotionShopConfig.maxComposure)
        if pct < 0.3 { return "ednar_alarmed" }
        if pct < 0.7 { return "ednar_concerned" }
        if !gs.placements.isEmpty { return "ednar_focused" }
        return "ednar_calm"
    }
    
    private var expressionEmojiFallback: String {
        let pct = Double(gs.composure) / Double(PotionShopConfig.maxComposure)
        if pct < 0.3 { return "😨" }
        if pct < 0.7 { return "😟" }
        if !gs.placements.isEmpty { return "🤨" }
        return "🧙‍♂️"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Try to load Ednar expression image, fallback to emoji
            ZStack {
                // Invisible spacer to maintain layout position
                Color.clear
                    .frame(width: 100, height: 120)
                
                // Image with independent positioning (can move outside bounds)
                if let ednarImage = PotionShopImageLoader.loadImage(named: expressionAssetName) {
                    Image(uiImage: ednarImage)
                        .resizable()
                        // NO .scaledToFit() or .scaledToFill() - allows independent width/height distortion
                        .frame(
                            width: 100 * ednarArtScale * ednarArtWidth,    // base × uniform × width
                            height: 120 * ednarArtScale * ednarArtHeight   // base × uniform × height
                        )
                        // NO .clipped() - allows image to escape frame bounds
                        .offset(x: ednarArtXOffset, y: ednarArtYOffset)
                        .allowsHitTesting(false)  // Don't intercept touches
                } else {
                    Text(expressionEmojiFallback)
                        .font(.system(size: 64 * ednarArtScale))
                        .offset(x: ednarArtXOffset, y: ednarArtYOffset)
                }
            }
            
            Capsule()
                .fill(PotionShopTheme.ink.opacity(0.15))
                .frame(width: 64, height: 4)
                .blur(radius: 1)
        }
    }
}

// MARK: - One customer in the scene
//
// PHASE 7 additions:
//   - Shake when gs.customerShakeCounters[id] increments
//   - Slide off-screen + fade when gs.expiringCustomerIds contains id
//   - Optional 💢 emoji burst on expiration (PotionShopBrewAnimator.expirationShowEmoji)

struct PotionShopCustomerInSceneView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer
    let queueIndex: Int
    let queueCount: Int
    let sceneSize: CGSize
    let animationNamespace: Namespace.ID
    let arrivalCounter: Int

    @State private var shakeOffset: CGFloat = 0
    @State private var settleBoost: CGFloat = 1.0
    @State private var expireSlideX: CGFloat = 0
    @State private var expireOpacity: Double = 1.0
    @State private var emojiOpacity: Double = 0.0
    @State private var emojiOffset: CGFloat = 0

    private var char: PotionShopCharacter? {
        PotionShopData.character(customer.charKey)
    }

    private var isActive: Bool { gs.queue.first == customer.id }
    private var attack: Int {
        guard let c = char else { return 0 }
        return isActive ? c.activeAttack : c.waitingAttack
    }

    private var dim: Bool {
        if queueIndex < PotionShopSceneLayout.queueDims.count {
            return PotionShopSceneLayout.queueDims[queueIndex]
        }
        return true
    }
    private var scale: CGFloat {
        if queueIndex < PotionShopSceneLayout.queueScales.count {
            return PotionShopSceneLayout.queueScales[queueIndex]
        }
        return 0.7
    }
    private var xPos: CGFloat {
        let fractions = PotionShopSceneLayout.queueXFractions(for: queueCount)
        let frac: CGFloat
        if queueIndex < fractions.count {
            frac = fractions[queueIndex]
        } else {
            frac = 0.95
        }
        return sceneSize.width * frac
    }
    private var yPos: CGFloat {
        let frac: CGFloat
        if queueIndex < PotionShopSceneLayout.queueYFractions.count {
            frac = PotionShopSceneLayout.queueYFractions[queueIndex]
        } else {
            frac = 0.55
        }
        return sceneSize.height * frac
    }

    var body: some View {
        if let char = char {
            ZStack {
                Circle()
                    .fill(Color(red: 0.96, green: 0.92, blue: 0.84))
                    .overlay(
                        PotionShopImageLoader.imageOrEmoji(
                            assetName: char.portrait,
                            fallbackEmoji: char.iconFallback,
                            size: PotionShopSceneLayout.portraitDiameter * scale
                        )
                    )
                    .frame(
                        width: PotionShopSceneLayout.portraitDiameter * scale,
                        height: PotionShopSceneLayout.portraitDiameter * scale
                    )
                    .overlay(
                        Circle()
                            .stroke(PotionShopTheme.ink, lineWidth: dim ? 2 : 3)
                    )

                if isActive {
                    Text("\(customer.hp)")
                        .font(.system(size: 14 * scale, weight: .bold))
                        .foregroundColor(.white)
                        .frame(
                            width: 26 * scale,
                            height: 26 * scale
                        )
                        .background(Circle().fill(PotionShopTheme.composureBad))
                        .overlay(Circle().stroke(.white, lineWidth: 1.5))
                        .offset(x: -28 * scale, y: -28 * scale)
                        .transition(.scale.combined(with: .opacity))
                }

                if attack > 0 {
                    Text("\(attack)")
                        .font(.system(size: 11 * scale, weight: .bold))
                        .foregroundColor(.white)
                        .frame(
                            width: 22 * scale,
                            height: 22 * scale
                        )
                        .background(Circle().fill(PotionShopTheme.composureBad))
                        .overlay(Circle().stroke(.white, lineWidth: 1.5))
                        .offset(x: 28 * scale, y: 28 * scale)
                }

                // PHASE 7: 💢 emoji burst on expiration
                if PotionShopBrewAnimator.expirationShowEmoji {
                    Text(PotionShopBrewAnimator.expirationEmoji)
                        .font(.system(size: 30 * scale))
                        .opacity(emojiOpacity)
                        .offset(x: 20, y: -30 + emojiOffset)
                }
            }
            .opacity(dim ? 0.55 : 1.0)
            .opacity(expireOpacity)
            .scaleEffect(scale * settleBoost)
            .position(x: xPos + shakeOffset + expireSlideX, y: yPos)
            .matchedGeometryEffect(
                id: customer.id,
                in: animationNamespace,
                properties: [.position, .size]
            )
            .animation(
                .spring(response: 0.55, dampingFraction: 0.78),
                value: queueIndex
            )
            // PHASE 7: shake when shake counter increments
            .onChange(of: gs.customerShakeCounters[customer.id] ?? 0) {
                runShake()
            }
            // PHASE 7: slide off-screen when added to expiringCustomerIds
            .onChange(of: gs.expiringCustomerIds.contains(customer.id)) { _, isExpiring in
                if isExpiring {
                    runExpiration()
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
                        .font(.system(size: 12, weight: .semibold, design: .serif))
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

    private var ringColor: Color {
        if customer.maxPatience == 0 { return PotionShopTheme.muted }
        let pct = Double(customer.patience) / Double(customer.maxPatience)
        if pct > 0.4 { return PotionShopTheme.composureGood }
        return PotionShopTheme.composureWarn
    }

    var body: some View {
        Button {
            gs.tapProfile(customer.id)
        } label: {
            ZStack {
                Circle()
                    .trim(
                        from: 0,
                        to: customer.maxPatience > 0
                            ? Double(customer.patience) / Double(customer.maxPatience)
                            : 0
                    )
                    .stroke(ringColor, lineWidth: 3)
                    .rotationEffect(.degrees(-90))
                    .frame(
                        width: PotionShopSceneLayout.profileDiameter + 8,
                        height: PotionShopSceneLayout.profileDiameter + 8
                    )
                    .animation(.easeInOut(duration: 0.4), value: customer.patience)

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
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(PotionShopTheme.composureGood)
                } else if customer.status == .expired {
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(
                            width: PotionShopSceneLayout.profileDiameter,
                            height: PotionShopSceneLayout.profileDiameter
                        )
                    Text("✗")
                        .font(.system(size: 28, weight: .bold))
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

    private var char: PotionShopCharacter? {
        PotionShopData.character(customer.charKey)
    }

    private var isActive: Bool { gs.queue.first == customer.id }

    private var brewTargetForPill: Int {
        if isActive {
            return gs.currentBrewTarget
        } else {
            return customer.hp
        }
    }

    private var attackForSubtitle: Int {
        guard let c = char else { return 0 }
        return isActive ? c.activeAttack : c.waitingAttack
    }

    private var patienceRingColor: Color {
        if customer.maxPatience == 0 { return PotionShopTheme.muted }
        let pct = Double(customer.patience) / Double(customer.maxPatience)
        if pct > 0.4 { return PotionShopTheme.composureGood }
        return PotionShopTheme.composureWarn
    }

    var body: some View {
        if let char = char {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(PotionShopTheme.accent, lineWidth: 2)
                    )
                    .opacity(isExpanded ? 1.0 : 0.0)

                HStack(spacing: 14) {
                    portraitView(char: char)
                        .offset(x: isExpanded ? 0 : 40)
                        .opacity(isExpanded ? 1.0 : 0.0)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(char.name)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(PotionShopTheme.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        HStack(spacing: 6) {
                            Text(char.orderName)
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(PotionShopTheme.muted)
                                .lineLimit(1)
                            Text("•")
                                .foregroundColor(PotionShopTheme.muted)
                            Text("Atk \(attackForSubtitle)")
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(PotionShopTheme.muted)
                        }
                    }
                    .offset(x: isExpanded ? 0 : -40)
                    .opacity(isExpanded ? 1.0 : 0.0)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("🧪")
                            .font(.system(size: 13))
                        Text("\(brewTargetForPill)")
                            .font(.system(size: 18, weight: .heavy, design: .serif))
                            .foregroundColor(PotionShopTheme.composureBad)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(red: 1.0, green: 0.93, blue: 0.93))
                            .overlay(
                                Capsule()
                                    .stroke(PotionShopTheme.composureBad.opacity(0.5), lineWidth: 1.5)
                            )
                    )
                    .offset(x: isExpanded ? 0 : -60)
                    .opacity(isExpanded ? 1.0 : 0.0)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
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
        }
    }

    @ViewBuilder
    private func portraitView(char: PotionShopCharacter) -> some View {
        ZStack {
            Circle()
                .stroke(PotionShopTheme.muted.opacity(0.25), lineWidth: 3)
                .frame(width: 70, height: 70)
            Circle()
                .trim(
                    from: 0,
                    to: customer.maxPatience > 0
                        ? Double(customer.patience) / Double(customer.maxPatience)
                        : 0
                )
                .stroke(patienceRingColor, lineWidth: 3)
                .rotationEffect(.degrees(-90))
                .frame(width: 70, height: 70)
                .animation(.easeInOut(duration: 0.4), value: customer.patience)
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
