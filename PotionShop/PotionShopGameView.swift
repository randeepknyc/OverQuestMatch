//
//  PotionShopGameView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Main View
//  Place in: PotionShop/ folder
//
//  PHASE 3: Adds a "Run Self-Test" button that exercises the
//  PotionShopGameState engine and displays results. Phase 4 replaces
//  this entire view with the real gameplay UI.
//

import SwiftUI

struct PotionShopGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selfTestResults: [String] = []

    // Quick stats from the data layer (same as Phase 2)
    private var characterCount: Int { PotionShopData.characters.count }
    private var traitCount: Int { PotionShopData.traits.count }
    private var firstMorningName: String {
        if let firstId = PotionShopData.day1.morning.customerIds.first,
           let char = PotionShopData.character(firstId) {
            return char.name
        }
        return "(none)"
    }

    var body: some View {
        ZStack {
            PotionShopTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    Spacer().frame(height: 30)

                    Text("🧪")
                        .font(.system(size: 56))

                    Text("Ednar's Potion Cauldron")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(PotionShopTheme.ink)

                    Text("Phase 3 complete!")
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(PotionShopTheme.muted)

                    // Data summary panel
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DATA LOADED:")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(PotionShopTheme.accent)
                        statRow("Characters", "\(characterCount) (expected 14)")
                        statRow("Traits", "\(traitCount) (expected 8)")
                        statRow("First morning customer", firstMorningName)
                    }
                    .padding(14)
                    .frame(maxWidth: 340)
                    .background(panelBackground)

                    // Self-test button
                    Button {
                        let gs = PotionShopGameState()
                        selfTestResults = gs.runSelfTest()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                            Text("Run Self-Test")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 11)
                        .background(PotionShopTheme.accent)
                        .clipShape(Capsule())
                    }

                    // Self-test results panel (only shows after running)
                    if !selfTestResults.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SELF-TEST RESULTS:")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(PotionShopTheme.accent)
                                .padding(.bottom, 4)
                            ForEach(Array(selfTestResults.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(lineColor(line))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: 340)
                        .background(panelBackground)
                    }

                    Text("Real gameplay UI arrives in Phase 4.")
                        .font(.system(size: 11))
                        .foregroundColor(PotionShopTheme.muted)
                        .padding(.top, 4)

                    Spacer().frame(height: 18)

                    Button {
                        dismiss()
                    } label: {
                        Text("← Back to Game Selector")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(PotionShopTheme.muted)
                            .clipShape(Capsule())
                    }

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(PotionShopTheme.accent.opacity(0.4), lineWidth: 1)
            )
    }

    private func lineColor(_ line: String) -> Color {
        if line.contains("❌") { return PotionShopTheme.composureBad }
        if line.contains("✅") { return PotionShopTheme.composureGood }
        if line.contains("───") { return PotionShopTheme.accent }
        return PotionShopTheme.ink
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(PotionShopTheme.ink)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(PotionShopTheme.muted)
        }
    }
}

// MARK: - Preview

#Preview {
    PotionShopGameView()
}
