//
//  PotionShopGameView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Main game view
//  Place in: PotionShop/ folder
//
//  PHASE 7: Adds a floating-number overlay above the game scene.
//  When the brew sequence emits floating numbers (via gs.emitFloatingNumber),
//  they appear at their origin point, drift upward, and fade out.
//  A timer-driven purge removes expired numbers from gs.
//  PHASE 12: ART HOOKUP — Background image with parchment fallback
//

import SwiftUI
import Combine

struct PotionShopGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gs = PotionShopGameState()
    @State private var showDebugMenu = false

    @Namespace private var diceFlight

    /// Timer that ticks every 100ms to purge expired floating numbers
    /// from gs.floatingNumbers.
    private let purgeTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            // ✅ VERIFIED CORRECT VALUES - May 4, 2026 Evening
            let totalHeight = geo.size.height
            
            // Section height calculations (percentages from layout editor)
            let headerH      = max(70,  totalHeight * 0.010)   // 1%   - Minimal header
            let sceneH       = max(160, totalHeight * 0.263)   // 26.3% - Scene (big!)
            let profileRowH  = max(74,  totalHeight * 0.095)   // 9.5%  - Profile row
            let cauldronH    = max(240, totalHeight * 0.372)   // 37.2% - HUGE CAULDRON!
            let previewBarH  = max(26,  totalHeight * 0.032)   // 3.2%  - Preview bar (tiny)
            let trayH        = max(82,  totalHeight * 0.193)   // 19.3% - BIG TRAY!

            ZStack {
                // Background image (or placeholder parchment color)
                if let bgImage = PotionShopImageLoader.loadImage(named: "shop_background") {
                    Image(uiImage: bgImage)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    // Placeholder parchment background
                    PotionShopTheme.bg.ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    PotionShopHeaderView(gs: gs, showDebugMenu: $showDebugMenu)
                        .frame(height: headerH)

                    PotionShopCustomerSceneView(
                        gs: gs,
                        ednarArtScale: 1.0,
                        ednarArtWidth: 1.59,    // ✅ FROM SCREENSHOT (proportional)
                        ednarArtHeight: 2.00,   // ✅ FROM SCREENSHOT (proportional)
                        ednarArtXOffset: 14,    // ✅ FROM SCREENSHOT
                        ednarArtYOffset: -17    // ✅ FROM SCREENSHOT
                    )
                        .frame(height: sceneH)
                        .frame(maxWidth: .infinity)

                    PotionShopProfileRowView(gs: gs)
                        .frame(height: profileRowH)

                    PotionShopCauldronView(
                        gs: gs,
                        diceFlight: diceFlight,
                        cauldronScale: 1.29,
                        cauldronXOffset: 44,
                        cauldronYOffset: 58,
                        nodeScale: 1.00,
                        nodeXOffset: 0,
                        nodeYOffset: 0,
                        brewXOffset: -50,
                        brewYPercent: 0.30,
                        showBrewButton: false,
                        brewZoneX: 0.83,          // ✅ FROM LAYOUT EDITOR
                        brewZoneY: 0.19,
                        brewZoneWidth: 112,       // ✅ FROM LAYOUT EDITOR
                        brewZoneHeight: 123,
                        showBrewZone: false,       // ✅ Visible (for tap zone debugging)
                        cauldronArtScale: 1.0,
                        cauldronArtWidth: 1.45,   // ✅ FROM SCREENSHOT (proportional)
                        cauldronArtHeight: 2.00,  // ✅ FROM SCREENSHOT (proportional)
                        cauldronArtXOffset: 7,    // ✅ FROM SCREENSHOT
                        cauldronArtYOffset: -40   // ✅ FROM SCREENSHOT
                    )
                    // BACKUP (to revert, copy these values back):
                    // brewZoneX: 0.80, brewZoneWidth: 90, showBrewZone: true
                    // cauldronArtWidth: 2.61, cauldronArtHeight: 1.28
                    // cauldronArtXOffset: 6, cauldronArtYOffset: -40
                        .frame(height: cauldronH)

                    PotionShopBrewPreviewBar(gs: gs)
                        .frame(height: previewBarH)

                    PotionShopDiceTrayView(
                        gs: gs,
                        diceFlight: diceFlight,
                        dieScale: 1.31
                    )
                        .frame(height: trayH)
                        .offset(y: -25)

                    Spacer(minLength: 0)
                }

                // Floating number overlay (above everything)
                PotionShopFloatingNumberOverlay(gs: gs)
                    .allowsHitTesting(false)
                
                // Dragged die overlay (above everything else so it doesn't go behind cauldron)
                PotionShopDraggedDieOverlay(gs: gs, diceFlight: diceFlight)
                    .allowsHitTesting(false)

                phaseOverlay
            }
        }
        .sheet(isPresented: $showDebugMenu) {
            PotionShopDebugMenu(
                gs: gs,
                isPresented: $showDebugMenu,
                onEndGame: { dismiss() }
            )
        }
        .onReceive(purgeTimer) { _ in
            gs.purgeExpiredFloatingNumbers()
        }
    }

    // MARK: - Phase-end placeholder overlays

    @ViewBuilder
    private var phaseOverlay: some View {
        switch gs.phase {
        case .playing:
            EmptyView()
        case .roundWon:
            placeholderOverlay(
                title: "Round Complete",
                subtitle: "Potions brewed: \(gs.potionsBrewed)",
                buttonLabel: "Continue",
                action: { gs.advanceRound() }
            )
        case .dayWon:
            placeholderOverlay(
                title: "Day Complete!",
                subtitle: "Phase 8 will add a proper day-end screen.\nTap to start over.",
                buttonLabel: "Restart",
                action: { gs.resetGame() }
            )
        case .lost:
            placeholderOverlay(
                title: "You Collapsed",
                subtitle: "Potions brewed before defeat: \(gs.potionsBrewed)",
                buttonLabel: "Try Again",
                action: { gs.resetGame() }
            )
        }
    }

    private func placeholderOverlay(
        title: String,
        subtitle: String,
        buttonLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy, design: .serif))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)

                Button {
                    action()
                } label: {
                    Text(buttonLabel)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(PotionShopTheme.accent)
                        .clipShape(Capsule())
                }
            }
            .padding(40)
        }
    }
}

// MARK: - Floating number overlay

struct PotionShopFloatingNumberOverlay: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        ZStack {
            ForEach(gs.floatingNumbers) { number in
                PotionShopFloatingNumberView(number: number)
            }
        }
    }
}

struct PotionShopFloatingNumberView: View {
    let number: PotionShopFloatingNumber
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        Text(number.text)
            .font(PotionShopBrewAnimator.numberFont())
            .foregroundColor(number.color)
            .shadow(color: .white.opacity(0.7), radius: 1, x: 0, y: 0)
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
            .position(number.position)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: PotionShopBrewAnimator.floatDuration)
                ) {
                    offsetY = -PotionShopBrewAnimator.floatRiseDistance
                    opacity = 0.0
                }
            }
    }
}

// MARK: - Dragged die overlay
//
// Renders the currently dragged die above ALL other content so it doesn't
// go behind the cauldron/nodes when being dragged upward from the tray.

struct PotionShopDraggedDieOverlay: View {
    @Bindable var gs: PotionShopGameState
    let diceFlight: Namespace.ID
    
    var body: some View {
        if let draggedDie = gs.draggedDie {
            // Invisible placeholder that uses matchedGeometryEffect
            // This acts as the destination for the dragged die
            Color.clear
                .frame(width: PotionShopCauldronLayout.dieSize, height: PotionShopCauldronLayout.dieSize)
                .matchedGeometryEffect(
                    id: draggedDie.id,
                    in: diceFlight,
                    properties: [.position, .size]
                )
        }
    }
}

// MARK: - Preview

#Preview {
    PotionShopGameView()
}
