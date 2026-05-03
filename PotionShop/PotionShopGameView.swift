//
//  PotionShopGameView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Main View
//  Place in: PotionShop/ folder
//
//  PHASE 1: This is a stub — just shows "Phase 1 complete!" so we
//  can verify the new game is correctly hooked into the game selector
//  and launches when tapped. Phase 4 replaces this with the real UI.
//

import SwiftUI

struct PotionShopGameView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PotionShopTheme.bg.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("🧪")
                    .font(.system(size: 80))

                Text("Ednar's Potion Cauldron")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(PotionShopTheme.ink)

                Text("Phase 1 complete!")
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(PotionShopTheme.muted)

                Text("The new game is hooked up. Real gameplay arrives in Phase 4.")
                    .font(.system(size: 12))
                    .foregroundColor(PotionShopTheme.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("← Back to Game Selector")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(PotionShopTheme.accent)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PotionShopGameView()
}
