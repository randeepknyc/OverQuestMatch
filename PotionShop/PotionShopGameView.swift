//
//  PotionShopGameView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Main game view
//  Place in: PotionShop/ folder
//
//  PHASE 6: Adds a @Namespace ("diceFlight") that's passed to both
//  the cauldron view and the dice tray view. Both views apply
//  matchedGeometryEffect to dice using their stable string id, so
//  when a die is placed (moves from tray to cauldron) or unplaced
//  (moves from cauldron back to tray), SwiftUI animates the position
//  change automatically.
//
//  Composes:
//    PotionShopHeaderView          (composure, shield, day/round, gear icon)
//    PotionShopCustomerSceneView   (Ednar + customer line)
//    PotionShopProfileRowView      (profile buttons or inspect strip)
//    PotionShopCauldronView        (bowl + nodes + BREW)
//    PotionShopBrewPreviewBar      (placement count + damage preview)
//    PotionShopDiceTrayView        (5 dice in wooden frame)
//    PotionShopDebugMenu           (sheet, accessed via gear icon)
//

import SwiftUI

struct PotionShopGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gs = PotionShopGameState()
    @State private var showDebugMenu = false

    /// Shared namespace so dice can animate between the tray and the
    /// cauldron via matchedGeometryEffect.
    @Namespace private var diceFlight

    var body: some View {
        GeometryReader { geo in
            let totalH = geo.size.height
            let headerH      = max(54,  totalH * 0.07)
            let sceneH       = max(180, totalH * 0.32)
            let profileRowH  = max(86,  totalH * 0.11)
            let cauldronH    = max(220, totalH * 0.28)
            let previewBarH  = max(28,  totalH * 0.035)
            let trayH        = max(78,  totalH * 0.10)

            ZStack {
                PotionShopTheme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    PotionShopHeaderView(gs: gs, showDebugMenu: $showDebugMenu)
                        .frame(height: headerH)

                    PotionShopCustomerSceneView(gs: gs)
                        .frame(height: sceneH)
                        .frame(maxWidth: .infinity)

                    PotionShopProfileRowView(gs: gs)
                        .frame(height: profileRowH)

                    PotionShopCauldronView(gs: gs, diceFlight: diceFlight)
                        .frame(height: cauldronH)

                    PotionShopBrewPreviewBar(gs: gs)
                        .frame(height: previewBarH)

                    PotionShopDiceTrayView(gs: gs, diceFlight: diceFlight)
                        .frame(height: trayH)

                    Spacer(minLength: 0)
                }

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
    }

    // MARK: - Phase-end placeholder overlays (Phase 8 will replace)

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

// MARK: - Preview

#Preview {
    PotionShopGameView()
}
