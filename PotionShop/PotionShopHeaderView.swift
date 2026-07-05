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
    /// JULY 2, 2026: player-facing settings menu (the ☰ button below).
    @Binding var showSettingsMenu: Bool

    // JULY 2, 2026 (night): secret-unlock tap tracking for the debug
    // gear (the gear itself lives at the cauldron's bottom-right now).
    @State private var secretTapCount: Int = 0
    @State private var secretLastTap: Date = .distantPast

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
        max(0, gs.focus - gs.placements.count)
    }

    /// Dynamic focus X offset — shifts left as more pips are added so the
    /// row stays visually centered. Tuned values from the layout editor:
    ///   3 pips → 259.79,  4 pips → 257.87,  5 pips → 228.83
    private var focusOffsetX: Double {
        let base = cfg.headerFocusOffsetX  // the default (tuned for 3 pips)
        switch gs.focus {
        case 4:  return base - 1.91   // 259.79 → ~257.87
        case 5:  return base - 30.96  // 259.79 → ~228.83
        default: return base          // 3 or fewer — use the config value as-is
        }
    }

    private var cfg: PotionShopLayoutConfig { PotionShopLayoutConfig.shared }

    var body: some View {
        VStack(spacing: 2) {
            // ── ROW 1: tod icon | composure bar | gear ─────────
            HStack(spacing: 8) {
                // Time-of-day icon (left of bar)
                if let todImg = PotionShopImageLoader.loadDisplayImage(named: todIconName, displaySize: cfg.headerTodIconSize) {  // JULY 5 memory: was full-res
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
                    // Predicted shield from placed dice — pulses in the bar
                    // while PLACING; 0 during the brew so the moment the
                    // real shield lands, the slice solidifies.
                    previewShield: gs.isAnimating ? 0 : gs.livePreview.shielding,
                    flashCounter: gs.composureFlashCounter,
                    flashKind: gs.composureFlashKind,
                    barHeight: cfg.headerBarHeight
                )
                .frame(maxWidth: .infinity)
                .offset(y: cfg.headerBarOffsetY)

                // JULY 2, 2026 (later): the header slot now holds the
                // PLAYER-FACING settings (☰) button — always visible.
                // The dev-only debug gear moved to the bottom-right of
                // the cauldron (see PotionShopGameView), still gated by
                // PotionShopDebugAccess + the secret Day-label taps.
                // Draw "ps_settings_button" (256×256) to replace the ☰.
                Button {
                    showSettingsMenu = true
                } label: {
                    // JULY 2 (latest): settings wears the GEAR again (user
                    // request) — ps_settings_button art wins if drawn,
                    // then the header_gear art, then the SF gear.
                    if let btnImg = PotionShopImageLoader.loadDisplayImage(named: "ps_settings_button", displaySize: cfg.headerGearSize) ?? PotionShopImageLoader.loadDisplayImage(named: "header_gear", displaySize: cfg.headerGearSize) {  // JULY 5 memory: was full-res
                        Image(uiImage: btnImg)
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
                    // JULY 2, 2026 (night): SECRET debug unlock for Release
                    // builds — 7 quick taps here toggles the gear icon.
                    // Does nothing meaningful on Xcode/DEBUG builds (gear
                    // is always on there). Taps more than 1.5s apart reset
                    // the count, so normal play can't trip it.
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let now = Date()
                        if now.timeIntervalSince(secretLastTap) > 1.5 {
                            secretTapCount = 0
                        }
                        secretLastTap = now
                        secretTapCount += 1
                        if secretTapCount >= 7 {
                            secretTapCount = 0
                            PotionShopDebugAccess.toggleUnlock()
                            // Nudge the observable so the CAULDRON's gear
                            // (which lives in GameView now) re-evaluates.
                            PotionShopLayoutConfig.shared.debugGearBump += 1
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }

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
                ForEach(0..<gs.focus, id: \.self) { i in
                    Image(i < focusRemaining ? "focus_fill" : "focus_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: cfg.headerFocusPipSize, height: cfg.headerFocusPipSize)
                }
                Spacer()
            }
            .offset(x: focusOffsetX, y: cfg.headerFocusOffsetY)
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
    /// JULY 2, 2026: shield the CURRENT placements would grant (from
    /// gs.livePreview) — rendered as a fading-in-and-out slice until the
    /// brew lands. 0 while brewing / nothing placed.
    var previewShield: Int = 0
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

    private var previewPct: Double {
        guard maxComposure > 0 else { return 0 }
        return min(Double(previewShield), Double(maxComposure)) / Double(maxComposure)
    }

    /// One teal shield slice (image-masked when the asset exists, plain
    /// teal otherwise) — shared by the solid and the pulsing preview.
    @ViewBuilder
    private func shieldSlice(width: CGFloat, offset: CGFloat,
                             barWidth: CGFloat, barHeight: CGFloat) -> some View {
        if let shieldImg = PotionShopImageLoader.loadDisplayImage(named: "composure_bar_shield", displaySize: barWidth) {  // JULY 5 memory: was full-res
            Image(uiImage: shieldImg)
                .resizable()
                .frame(width: barWidth, height: barHeight)
                .mask(
                    Rectangle()
                        .frame(width: width)
                        .offset(x: offset)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
        } else {
            Rectangle()
                .fill(PotionShopTheme.shield)
                .frame(width: width, height: barHeight)
                .offset(x: offset)
        }
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
                if let fillImg = PotionShopImageLoader.loadDisplayImage(named: fillAssetName, displaySize: barWidth) {  // JULY 5 memory: was full-res
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
                //    JULY 2, 2026 FIX: when composure is FULL the old math
                //    put the slice at the bar's right edge with zero width
                //    (invisible shield). The shield group is now RIGHT-
                //    ANCHORED when it runs out of room: at full composure
                //    it overlays the fill's right end, so you always see
                //    exactly how much shield you have.
                //    JULY 2, 2026 NEW: predicted shield from placed dice
                //    (livePreview) renders as an extra slice that FADES
                //    IN AND OUT until the brew lands; the real shield is
                //    solid. Both slide/solidify together on brew.
                if shield > 0 || previewShield > 0 {
                    let shieldW = barWidth * shieldPct
                    let previewW = barWidth * previewPct
                    let groupW = min(barWidth, shieldW + previewW)
                    let groupEnd = min(barWidth, barWidth * (compoPct + shieldPct + previewPct))
                    let groupStart = max(0, groupEnd - groupW)
                    let solidW = min(groupW, shieldW)

                    // Solid slice — the shield you actually have.
                    if solidW > 0 {
                        shieldSlice(width: solidW, offset: groupStart,
                                    barWidth: barWidth, barHeight: barHeight)
                            .animation(.easeInOut(duration: 0.35), value: shield)
                            .animation(.easeInOut(duration: 0.35), value: composure)
                    }

                    // Pulsing slice — shield the current placements WILL grant.
                    if groupW - solidW > 0.5 {
                        TimelineView(.animation) { timeline in
                            let t = timeline.date.timeIntervalSinceReferenceDate
                            let breathe = 0.30 + 0.45 * (0.5 + 0.5 * sin(t * 3.6))
                            shieldSlice(width: groupW - solidW, offset: groupStart + solidW,
                                        barWidth: barWidth, barHeight: barHeight)
                                .opacity(breathe)
                        }
                    }
                }

                // 3. Background frame (drawn ON TOP so the outline sits over fills)
                if let bgImg = PotionShopImageLoader.loadDisplayImage(named: "composure_bar_bg", displaySize: barWidth) {  // JULY 5 memory: was full-res
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
