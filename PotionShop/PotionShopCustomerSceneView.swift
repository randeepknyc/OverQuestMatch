//
//  PotionShopCustomerSceneView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Customer scene + profile row
//  Place in: PotionShop/ folder
//
//  TWO STACKED SECTIONS:
//
//  1. The "scene": Ednar at his counter on the LEFT, customers
//     approaching from the RIGHT. queue[0] (front of line) is leftmost,
//     closest to Ednar. Active customer is at full size; waiters are
//     dimmed and slightly smaller.
//
//  2. The profile row OR inspect strip: below the scene, a horizontal
//     row of profile buttons — ONE PER customers[] entry, never
//     reordered. Tapping a profile button calls gs.tapProfile(id),
//     which swaps that customer to the front. If a customer is being
//     inspected, the row is replaced by an inspect strip showing
//     name, order, trait.
//
//  NAMING NOTE: Every public struct in this file uses the PotionShop
//  prefix to avoid collisions with the existing CauldronGame and
//  ShopOfOddities folders. Don't rename them.
//

import SwiftUI

// MARK: - Layout constants for the customer scene

struct PotionShopSceneLayout {
    /// Horizontal offsets for queue[0], queue[1], queue[2].
    static let queueXOffsets: [CGFloat]   = [110, 195, 270]
    /// Vertical offsets — front customer slightly higher.
    static let queueYOffsets: [CGFloat]   = [10, 35, 35]
    /// Front at full size; waiters smaller.
    static let queueScales:   [CGFloat]   = [1.0, 0.78, 0.72]
    /// Whether the customer is dimmed (waiter) or full color (active).
    static let queueDims:     [Bool]      = [false, true, true]

    static let sceneHeight:      CGFloat = 200
    static let portraitDiameter: CGFloat = 76
    static let profileDiameter:  CGFloat = 56
}

// MARK: - Customer scene

struct PotionShopCustomerSceneView: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background gradient (placeholder — real shop interior art arrives later)
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.90, blue: 0.80),
                    Color(red: 0.90, green: 0.84, blue: 0.69)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Counter strip at the bottom of the scene (placeholder)
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

            // Ednar (placeholder) on the LEFT
            PotionShopEdnarView(gs: gs)

            // Customers in queue, positioned by index
            ForEach(Array(gs.queue.enumerated()), id: \.element) { idx, custId in
                if let cust = gs.customers.first(where: { $0.id == custId }) {
                    PotionShopCustomerInSceneView(gs: gs, customer: cust, queueIndex: idx)
                }
            }

            // Persistent shield badge between Ednar and the customer line
            if gs.shield > 0 {
                Text("🛡 \(gs.shield)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(PotionShopTheme.shield)
                    .clipShape(Capsule())
                    .position(x: 90, y: 100)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeOut(duration: 0.3), value: gs.shield)
            }
        }
        .frame(height: PotionShopSceneLayout.sceneHeight)
        .clipped()
        .animation(.easeInOut(duration: 0.35), value: gs.queue)
    }
}

// MARK: - Ednar (the player avatar)

struct PotionShopEdnarView: View {
    @Bindable var gs: PotionShopGameState

    /// Pick the right Ednar expression based on game state.
    /// SF Symbols + emoji as placeholder until real art arrives.
    private var expressionEmoji: String {
        let pct = Double(gs.composure) / Double(PotionShopConfig.maxComposure)
        if pct < 0.3 { return "😨" }   // alarmed
        if pct < 0.7 { return "😟" }   // concerned
        if !gs.placements.isEmpty { return "🤨" }  // focused (mid-brew)
        return "🧙‍♂️"                   // calm
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(expressionEmoji)
                .font(.system(size: 50))
            // Counter shadow under the emoji (visual anchor)
            Capsule()
                .fill(PotionShopTheme.ink.opacity(0.15))
                .frame(width: 50, height: 4)
                .blur(radius: 1)
        }
        .position(x: 50, y: 100)
    }
}

// MARK: - One customer in the scene

struct PotionShopCustomerInSceneView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer
    let queueIndex: Int

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
        if queueIndex < PotionShopSceneLayout.queueXOffsets.count {
            return PotionShopSceneLayout.queueXOffsets[queueIndex]
        }
        return 320
    }
    private var yPos: CGFloat {
        if queueIndex < PotionShopSceneLayout.queueYOffsets.count {
            return PotionShopSceneLayout.queueYOffsets[queueIndex] + 60
        }
        return 95
    }

    var body: some View {
        if let char = char {
            ZStack {
                // Portrait (placeholder: emoji in a circle)
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

                // HP bubble (only on active customer — others show in profile row)
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
                }

                // Attack-value badge bottom-right
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
            .scaleEffect(scale)
            .position(x: xPos, y: yPos)
        }
    }
}

// MARK: - Profile row (with optional inspect strip)

struct PotionShopProfileRowView: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        Group {
            if let inspectedId = gs.inspectedId,
               let inspected = gs.customers.first(where: { $0.id == inspectedId }),
               inspected.status == .waiting {
                PotionShopInspectStripView(gs: gs, customer: inspected)
            } else {
                PotionShopProfileButtonsRow(gs: gs)
            }
        }
        .frame(height: 90)
        .padding(.vertical, 4)
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
                // Patience ring around portrait
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

                // Portrait
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

                // Defeated/expired overlay
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
        }
        .disabled(customer.status != .waiting || gs.isAnimating)
    }
}

// MARK: - Inspect strip (replaces profile row when a customer is tapped)

struct PotionShopInspectStripView: View {
    @Bindable var gs: PotionShopGameState
    let customer: PotionShopCustomer

    private var char: PotionShopCharacter? {
        PotionShopData.character(customer.charKey)
    }

    var body: some View {
        if let char = char {
            Button {
                gs.dismissInspect()
            } label: {
                HStack(spacing: 12) {
                    Text(char.iconFallback)
                        .font(.system(size: 32))
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.white.opacity(0.6)))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(char.name)
                            .font(.system(size: 13, weight: .semibold, design: .serif))
                            .foregroundColor(PotionShopTheme.ink)
                        Text(char.orderName)
                            .font(.system(size: 11, design: .serif))
                            .foregroundColor(PotionShopTheme.muted)
                        if let traitId = char.trait,
                           let trait = PotionShopData.trait(traitId) {
                            Text(trait.name)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(PotionShopTheme.accent)
                        }
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("HP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(PotionShopTheme.muted)
                        Text("\(customer.hp)")
                            .font(.system(size: 18, weight: .heavy, design: .serif))
                            .foregroundColor(PotionShopTheme.composureBad)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(PotionShopTheme.accent, lineWidth: 1.5)
                        )
                )
            }
            .padding(.horizontal, 14)
        }
    }
}
