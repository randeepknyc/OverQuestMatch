//
//  PotionShopCustomerSceneView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Customer scene + profile row
//  Place in: PotionShop/ folder
//
//  PHASE 5C: Queue spacing is COUNT-AWARE. Customers right-align with
//  Ednar gap based on customer count.
//
//  PHASE 5: Customer queue swap uses matchedGeometryEffect for smooth
//  slide+scale animations. Settle bounce on active arrival.
//
//  PHASE 6B: Inspect strip opens IN PLACE (scale + fade from center)
//  instead of falling from the top of the screen.
//
//  PHASE 6C: Inspect strip styled to match the web artifact —
//  larger, green ring around portrait, "Order • Atk N" subtitle,
//  brew target pill (🧪 N) on the right, plus a "Tap a node" hint
//  banner below when a die is selected.
//
//  NAMING NOTE: PotionShop prefix on every public type. Don't rename.
//

import SwiftUI

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

    @Namespace private var queueAnimation
    @State private var activeArrivalCounter: Int = 0
    @State private var lastActiveId: UUID? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [
                        Color(red: 0.94, green: 0.90, blue: 0.80),
                        Color(red: 0.90, green: 0.84, blue: 0.69)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

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

                PotionShopEdnarView(gs: gs)
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
}

// MARK: - Ednar (the player avatar)

struct PotionShopEdnarView: View {
    @Bindable var gs: PotionShopGameState

    private var expressionEmoji: String {
        let pct = Double(gs.composure) / Double(PotionShopConfig.maxComposure)
        if pct < 0.3 { return "😨" }
        if pct < 0.7 { return "😟" }
        if !gs.placements.isEmpty { return "🤨" }
        return "🧙‍♂️"
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(expressionEmoji)
                .font(.system(size: 64))
            Capsule()
                .fill(PotionShopTheme.ink.opacity(0.15))
                .frame(width: 64, height: 4)
                .blur(radius: 1)
        }
    }
}

// MARK: - One customer in the scene

struct PotionShopCustomerInSceneView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer
    let queueIndex: Int
    let queueCount: Int
    let sceneSize: CGSize
    let animationNamespace: Namespace.ID
    let arrivalCounter: Int

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

    @State private var settleBoost: CGFloat = 1.0

    var body: some View {
        if let char = char {
            ZStack {
                Circle()
                    .fill(Color(red: 0.96, green: 0.92, blue: 0.84))
                    .overlay(
                        Text(char.iconFallback)
                            .font(.system(size: 36 * scale))
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
            }
            .opacity(dim ? 0.55 : 1.0)
            .scaleEffect(scale * settleBoost)
            .position(x: xPos, y: yPos)
            .matchedGeometryEffect(
                id: customer.id,
                in: animationNamespace,
                properties: [.position, .size]
            )
            .animation(
                .spring(response: 0.55, dampingFraction: 0.78),
                value: queueIndex
            )
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
}

// MARK: - Profile row (with optional inspect strip + hint banner)

struct PotionShopProfileRowView: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if let inspectedId = gs.inspectedId,
                   let inspected = gs.customers.first(where: { $0.id == inspectedId }),
                   inspected.status == .waiting {
                    PotionShopInspectStripView(gs: gs, customer: inspected)
                        .transition(
                            .scale(scale: 0.9, anchor: .center)
                            .combined(with: .opacity)
                        )
                } else {
                    PotionShopProfileButtonsRow(gs: gs)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)
            .animation(.easeInOut(duration: 0.25), value: gs.inspectedId)

            // Hint banner below the inspect card / profile row when a
            // die is selected and ready to be placed.
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
                .background(
                    Color.white.opacity(0.55)
                )
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
                    Text(char.iconFallback)
                        .font(.system(size: 26))
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

// MARK: - Inspect strip (matches web artifact)
//
// Bigger card, green ring around portrait, "Order • Atk N" subtitle,
// brew target pill (🧪 N) on the right.

struct PotionShopInspectStripView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer

    private var char: PotionShopCharacter? {
        PotionShopData.character(customer.charKey)
    }

    private var isActive: Bool { gs.queue.first == customer.id }

    /// Brew target shown in the pill: HP + intimidating modifier
    /// (only for the active customer; waiters show their HP).
    private var brewTargetForPill: Int {
        if isActive {
            return gs.currentBrewTarget
        } else {
            return customer.hp
        }
    }

    /// Attack shown in the subtitle: active-attack if active,
    /// waiting-attack otherwise.
    private var attackForSubtitle: Int {
        guard let c = char else { return 0 }
        return isActive ? c.activeAttack : c.waitingAttack
    }

    /// Patience ring color — matches the logic on the profile button.
    /// Green when patience > 40% remaining, amber/warn below.
    private var patienceRingColor: Color {
        if customer.maxPatience == 0 { return PotionShopTheme.muted }
        let pct = Double(customer.patience) / Double(customer.maxPatience)
        if pct > 0.4 { return PotionShopTheme.composureGood }
        return PotionShopTheme.composureWarn
    }

    var body: some View {
        if let char = char {
            Button {
                gs.dismissInspect()
            } label: {
                HStack(spacing: 14) {
                    // Portrait with patience ring — matches the profile
                    // button's patience ring (trim shows remaining
                    // patience, color shifts to warn under 40%).
                    ZStack {
                        // Track (faint, full circle, so the ring
                        // visually reads as "patience meter" rather
                        // than just an arc floating in space)
                        Circle()
                            .stroke(PotionShopTheme.muted.opacity(0.25), lineWidth: 3)
                            .frame(width: 70, height: 70)
                        // Active patience trim
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
                                Text(char.iconFallback)
                                    .font(.system(size: 36))
                            )
                    }

                    // Name + subtitle (order • atk)
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

                    Spacer()

                    // Brew target pill on the right (red, 🧪 + N)
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
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(PotionShopTheme.accent, lineWidth: 2)
                        )
                )
            }
            .padding(.horizontal, 12)
        }
    }
}
