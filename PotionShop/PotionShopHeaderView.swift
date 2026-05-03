//
//  PotionShopHeaderView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Header bar
//  Place in: PotionShop/ folder
//
//  Top of the screen: shows player composure (with shield overlay),
//  potions brewed counter, and current day / round-of-day.
//
//  NAMING NOTE: Every public struct in this file uses the PotionShop
//  prefix to avoid collisions with the existing CauldronGame and
//  ShopOfOddities folders. Don't rename them.
//

import SwiftUI

struct PotionShopHeaderView: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        HStack(spacing: 10) {
            // Potions brewed counter
            HStack(spacing: 4) {
                Text("🧪").font(.system(size: 18))
                Text("×\(gs.potionsBrewed)")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(PotionShopTheme.accent)
            }

            // Composure bar with shield overlay
            PotionShopComposureBarView(
                composure: gs.composure,
                maxComposure: PotionShopConfig.maxComposure,
                shield: gs.shield
            )
            .frame(maxWidth: .infinity)

            // Day + round indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text("Day 1")
                    .font(.system(size: 9, weight: .semibold, design: .serif))
                    .foregroundColor(PotionShopTheme.muted)
                Text(gs.currentRoundLabel)
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .foregroundColor(PotionShopTheme.ink)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .ignoresSafeArea(edges: .top)
        )
        .overlay(
            // Bottom border line
            Rectangle()
                .fill(PotionShopTheme.accent.opacity(0.25))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Composure bar

struct PotionShopComposureBarView: View {
    let composure: Int
    let maxComposure: Int
    let shield: Int

    private var compoPct: Double {
        guard maxComposure > 0 else { return 0 }
        return Double(composure) / Double(maxComposure)
    }

    private var shieldPct: Double {
        guard maxComposure > 0 else { return 0 }
        return min(Double(shield), Double(maxComposure)) / Double(maxComposure)
    }

    private var barColor: Color {
        if compoPct > 0.6 { return PotionShopTheme.composureGood }
        if compoPct > 0.3 { return PotionShopTheme.composureWarn }
        return PotionShopTheme.composureBad
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color(red: 0.85, green: 0.81, blue: 0.72))

                    // Composure fill
                    RoundedRectangle(cornerRadius: 7)
                        .fill(barColor)
                        .frame(width: geo.size.width * compoPct)
                        .animation(.easeInOut(duration: 0.35), value: composure)

                    // Shield overlay (sits on the right portion of composure)
                    if shield > 0 {
                        let shieldWidth = min(geo.size.width * shieldPct, geo.size.width * compoPct)
                        RoundedRectangle(cornerRadius: 7)
                            .fill(PotionShopTheme.shield)
                            .frame(width: shieldWidth)
                            .offset(x: max(0, geo.size.width * compoPct - shieldWidth))
                            .animation(.easeInOut(duration: 0.35), value: shield)
                    }
                }
            }
            .frame(height: 14)

            HStack(spacing: 6) {
                Text("Composure \(composure)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(PotionShopTheme.muted)
                if shield > 0 {
                    Text("(+\(shield) 🛡)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(PotionShopTheme.shield)
                }
                Spacer()
            }
        }
    }
}
