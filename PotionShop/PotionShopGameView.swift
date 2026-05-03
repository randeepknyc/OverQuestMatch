//
//  PotionShopGameView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Main game view (Phase 4 — playable!)
//  Place in: PotionShop/ folder
//
//  Composes the header, customer scene, profile row, and cauldron
//  into the actual gameplay screen. Each section is its own file:
//
//  - PotionShopHeaderView         (composure bar, shield, day/round)
//  - PotionShopCustomerSceneView  (Ednar + customer line)
//  - PotionShopProfileRowView     (profile button row, or inspect strip)
//  - PotionShopCauldronView       (12 nodes + brew button + dice tray)
//
//  PHASE 4 DOES NOT INCLUDE:
//  - Animations during brew (Phase 7)
//  - Round-end / day-end / lose overlays (Phase 8)
//  - Trait visual effects (Phase 9)
//  - Debug menu (Phase 10)
//
//  When a round ends in Phase 4, the game shows a placeholder overlay.
//  You can also back out to the game selector via the navigation
//  chevron in the top-left.
//

import SwiftUI

struct PotionShopGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gs = PotionShopGameState()

    var body: some View {
        ZStack {
            // Parchment background
            PotionShopTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                PotionShopHeaderView(gs: gs)

                // Customer scene
                PotionShopCustomerSceneView(gs: gs)

                // Profile row (or inspect strip if a customer is being inspected)
                PotionShopProfileRowView(gs: gs)

                // Cauldron + brew preview + dice tray
                PotionShopCauldronView(gs: gs)

                Spacer(minLength: 0)
            }

            // Phase-end placeholder overlays (Phase 8 will replace with real ones)
            phaseOverlay
        }
        // Top-left back button (matches what other games do until Phase 10
        // adds a proper debug menu with End Game)
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(PotionShopTheme.ink.opacity(0.7))
                    .padding(8)
                    .background(Color.white.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(.top, 4)
            .padding(.leading, 8)
        }
    }

    // MARK: - Phase-end placeholder

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
