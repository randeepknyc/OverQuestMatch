//
//  PotionShopHeaderView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Header bar
//  Place in: PotionShop/ folder
//
//  PHASE 5D: Gear icon on the left to open the debug menu sheet.
//  PHASE 7: Composure bar flashes red on damage / green on heal,
//           driven by gs.composureFlashCounter increments.
//

import SwiftUI

struct PotionShopHeaderView: View {
    @Bindable var gs: PotionShopGameState
    @Binding var showDebugMenu: Bool

    var body: some View {
        HStack(spacing: 10) {
            Button {
                showDebugMenu = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(PotionShopTheme.muted)
                    .padding(8)
                    .background(Color.white.opacity(0.5))
                    .clipShape(Circle())
            }

            HStack(spacing: 4) {
                Text("🧪").font(.system(size: 20))
                Text("×\(gs.potionsBrewed)")
                    .font(Font.gameScore(size: 22))
                    .foregroundColor(PotionShopTheme.accent)
            }

            PotionShopComposureBarView(
                composure: gs.composure,
                maxComposure: PotionShopConfig.maxComposure,
                shield: gs.shield,
                flashCounter: gs.composureFlashCounter,
                flashKind: gs.composureFlashKind
            )
            .frame(maxWidth: .infinity)

            VStack(alignment: .trailing, spacing: 2) {
                Text("Day 1")
                    .font(Font.gameUI(size: 25))
                    .foregroundColor(PotionShopTheme.muted)
                Text(gs.currentRoundLabel)
                    .font(Font.gameUI(size: 20))
                    .foregroundColor(PotionShopTheme.ink)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .ignoresSafeArea(edges: .top)
        )
        .overlay(
            Rectangle()
                .fill(PotionShopTheme.accent.opacity(0.25))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Composure bar (with PHASE 7 flash)

struct PotionShopComposureBarView: View {
    let composure: Int
    let maxComposure: Int
    let shield: Int
    let flashCounter: Int
    let flashKind: PotionShopComposureFlash

    @State private var flashOpacity: Double = 0.0

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

    private var flashColor: Color {
        switch flashKind {
        case .damage: return PotionShopTheme.composureBad
        case .heal:   return PotionShopTheme.composureGood
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color(red: 0.85, green: 0.81, blue: 0.72))

                    RoundedRectangle(cornerRadius: 7)
                        .fill(barColor)
                        .frame(width: geo.size.width * compoPct)
                        .animation(.easeInOut(duration: 0.35), value: composure)

                    if shield > 0 {
                        let shieldWidth = min(geo.size.width * shieldPct, geo.size.width * compoPct)
                        RoundedRectangle(cornerRadius: 7)
                            .fill(PotionShopTheme.shield)
                            .frame(width: shieldWidth)
                            .offset(x: max(0, geo.size.width * compoPct - shieldWidth))
                            .animation(.easeInOut(duration: 0.35), value: shield)
                    }

                    // PHASE 7: Flash overlay across the entire bar.
                    RoundedRectangle(cornerRadius: 7)
                        .fill(flashColor)
                        .opacity(flashOpacity)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 14)

            HStack(spacing: 6) {
                Text("Composure \(composure)")
                    .font(Font.gameUI(size: 20))
                    .foregroundColor(PotionShopTheme.muted)
                if shield > 0 {
                    Text("(+\(shield) 🛡)")
                        .font(Font.gameUI(size: 20))
                        .foregroundColor(PotionShopTheme.shield)
                }
                Spacer()
            }
        }
        .onChange(of: flashCounter) {
            // Flash on/off when state machine increments the counter.
            withAnimation(.easeOut(duration: 0.05)) {
                flashOpacity = PotionShopBrewAnimator.composureFlashIntensity
            }
            DispatchQueue.main.asyncAfter(
                deadline: .now() + PotionShopBrewAnimator.composureFlashDuration
            ) {
                withAnimation(.easeOut(duration: 0.20)) {
                    flashOpacity = 0.0
                }
            }
        }
    }
}
