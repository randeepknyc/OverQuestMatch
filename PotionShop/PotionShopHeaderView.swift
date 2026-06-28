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
//  JUNE 27, 2026: Full header redesign with hand-drawn assets.
//  Layout (3-row, mockup-based):
//    Row 1: [Day #]  [═══ composure bar ═══]  [gear icon]
//    Row 2: [☀️ tod] [Composure #]            [Day 1]
//    Row 3:          [Focus ✦ ✦ ✦]            [Morning]
//
//  Art assets used:
//    composure_bar_bg   — empty bar frame (hand-drawn outline)
//    composure_bar_fill — green fill (>65% composure)
//    composure_bar_65   — yellow fill (40–65%)
//    composure_bar_40   — orange fill (20–40%)
//    composure_bar_20   — red fill (≤20%)
//    composure_bar_shield — teal shield fill
//    header_gear        — hand-drawn gear icon
//    tod_morning/afternoon/evening/night — time-of-day icons
//

import SwiftUI

struct PotionShopHeaderView: View {
    @Bindable var gs: PotionShopGameState
    @Binding var showDebugMenu: Bool

    /// Asset name for the current time-of-day icon.
    private var todIconName: String {
        switch gs.currentRoundTimeOfDay {
        case .morning:   return "tod_morning"
        case .afternoon: return "tod_afternoon"
        case .evening:   return "tod_evening"
        case .night:     return "tod_night"
        }
    }

    /// How many focus pips remain (dice NOT yet placed).
    private var focusRemaining: Int {
        max(0, PotionShopConfig.maxPlacementsPerBrew - gs.placements.count)
    }

    private var cfg: PotionShopLayoutConfig { PotionShopLayoutConfig.shared }

    var body: some View {
        VStack(spacing: 2) {
            // ── ROW 1: tod icon | composure bar | gear ─────────
            HStack(spacing: 8) {
                // Time-of-day icon (left of bar)
                if let todImg = UIImage(named: todIconName) {
                    Image(uiImage: todImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: cfg.headerTodIconSize, height: cfg.headerTodIconSize)
                        .offset(y: cfg.headerTodIconOffsetY)
                } else {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 20))
                        .foregroundColor(PotionShopTheme.accent)
                        .offset(y: cfg.headerTodIconOffsetY)
                }

                PotionShopComposureBarView(
                    composure: gs.composure,
                    maxComposure: PotionShopConfig.maxComposure,
                    shield: gs.shield,
                    flashCounter: gs.composureFlashCounter,
                    flashKind: gs.composureFlashKind,
                    barHeight: cfg.headerBarHeight
                )
                .frame(maxWidth: .infinity)
                .offset(y: cfg.headerBarOffsetY)

                Button {
                    showDebugMenu = true
                } label: {
                    if let gearImg = UIImage(named: "header_gear") {
                        Image(uiImage: gearImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: cfg.headerGearSize, height: cfg.headerGearSize)
                            .offset(y: cfg.headerGearOffsetY)
                    } else {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(PotionShopTheme.muted)
                            .padding(6)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                            .offset(y: cfg.headerGearOffsetY)
                    }
                }
            }

            // ── ROW 2: Day # + Composure # ──────────────────────
            HStack(spacing: 6) {
                Text("Day \(gs.dayNumber)")
                    .font(Font.gameUI(size: cfg.headerDayFontSize))
                    .foregroundColor(PotionShopTheme.ink)
                    .offset(x: cfg.headerDayOffsetX, y: cfg.headerDayOffsetY)

                HStack(spacing: 4) {
                    Text("Composure \(gs.composure)")
                        .font(Font.gameUI(size: cfg.headerComposureFontSize))
                        .foregroundColor(PotionShopTheme.muted)
                    if gs.shield > 0 {
                        Text("(+\(gs.shield) 🛡)")
                            .font(Font.gameUI(size: cfg.headerComposureFontSize))
                            .foregroundColor(PotionShopTheme.shield)
                    }
                }
                .offset(x: cfg.headerComposureOffsetX, y: cfg.headerComposureOffsetY)

                Spacer()
            }

            // ── ROW 3: Focus pips (full width) ──────────────────
            HStack(spacing: 3) {
                Text("Focus")
                    .font(Font.gameUI(size: cfg.headerFocusFontSize))
                    .foregroundColor(PotionShopTheme.muted)
                    .offset(y: cfg.headerFocusLabelOffsetY)
                ForEach(0..<PotionShopConfig.maxPlacementsPerBrew, id: \.self) { i in
                    Image(i < focusRemaining ? "focus_fill" : "focus_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: cfg.headerFocusPipSize, height: cfg.headerFocusPipSize)
                }
                Spacer()
            }
            .offset(x: cfg.headerFocusOffsetX, y: cfg.headerFocusOffsetY)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
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

// MARK: - Composure bar (hand-drawn assets, PHASE 7 flash)

struct PotionShopComposureBarView: View {
    let composure: Int
    let maxComposure: Int
    let shield: Int
    let flashCounter: Int
    let flashKind: PotionShopComposureFlash
    var barHeight: Double = 20

    @State private var flashOpacity: Double = 0.0

    private var compoPct: Double {
        guard maxComposure > 0 else { return 0 }
        return Double(composure) / Double(maxComposure)
    }

    private var shieldPct: Double {
        guard maxComposure > 0 else { return 0 }
        return min(Double(shield), Double(maxComposure)) / Double(maxComposure)
    }

    /// Which fill asset to use based on composure percentage.
    ///   >65% → green (composure_bar_fill)
    ///  40–65% → yellow (composure_bar_65)
    ///  20–40% → orange (composure_bar_40)
    ///   ≤20% → red (composure_bar_20)
    private var fillAssetName: String {
        let pct = compoPct * 100
        if pct > 65 { return "composure_bar_fill" }
        if pct > 40 { return "composure_bar_65" }
        if pct > 20 { return "composure_bar_40" }
        return "composure_bar_20"
    }

    private var flashColor: Color {
        switch flashKind {
        case .damage: return PotionShopTheme.composureBad
        case .heal:   return PotionShopTheme.composureGood
        }
    }

    var body: some View {
        GeometryReader { geo in
            let barWidth = geo.size.width
            let barHeight = geo.size.height
            ZStack(alignment: .leading) {
                // 1. Fill image, masked to composure percentage
                if let fillImg = UIImage(named: fillAssetName) {
                    Image(uiImage: fillImg)
                        .resizable()
                        .frame(width: barWidth, height: barHeight)
                        .mask(
                            Rectangle()
                                .frame(width: barWidth * compoPct)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        )
                        .animation(.easeInOut(duration: 0.35), value: composure)
                } else {
                    // Code fallback if asset missing
                    let barColor: Color = {
                        if compoPct > 0.65 { return PotionShopTheme.composureGood }
                        if compoPct > 0.4  { return PotionShopTheme.composureWarn }
                        return PotionShopTheme.composureBad
                    }()
                    RoundedRectangle(cornerRadius: 7)
                        .fill(barColor)
                        .frame(width: barWidth * compoPct)
                        .animation(.easeInOut(duration: 0.35), value: composure)
                }

                // 2. Shield overlay — sits right after the composure fill.
                //    The shield extends from compoPct to (compoPct + shieldPct),
                //    capped at the bar's right edge. We mask the full-width
                //    shield image to show only that slice.
                if shield > 0 {
                    let shieldStart = barWidth * compoPct
                    let shieldEnd = min(barWidth, barWidth * (compoPct + shieldPct))
                    let visibleWidth = shieldEnd - shieldStart
                    if visibleWidth > 0 {
                        if let shieldImg = UIImage(named: "composure_bar_shield") {
                            Image(uiImage: shieldImg)
                                .resizable()
                                .frame(width: barWidth, height: barHeight)
                                .mask(
                                    Rectangle()
                                        .frame(width: visibleWidth)
                                        .offset(x: shieldStart)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                )
                                .animation(.easeInOut(duration: 0.35), value: shield)
                                .animation(.easeInOut(duration: 0.35), value: composure)
                        } else {
                            Rectangle()
                                .fill(PotionShopTheme.shield)
                                .frame(width: visibleWidth, height: barHeight)
                                .offset(x: shieldStart)
                                .animation(.easeInOut(duration: 0.35), value: shield)
                                .animation(.easeInOut(duration: 0.35), value: composure)
                        }
                    }
                }

                // 3. Background frame (drawn ON TOP so the outline sits over fills)
                if let bgImg = UIImage(named: "composure_bar_bg") {
                    Image(uiImage: bgImg)
                        .resizable()
                        .frame(width: barWidth, height: barHeight)
                } else {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 2)
                }

                // 4. Flash overlay (PHASE 7)
                RoundedRectangle(cornerRadius: 7)
                    .fill(flashColor)
                    .opacity(flashOpacity)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: barHeight)
        .onChange(of: flashCounter) {
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
