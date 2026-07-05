//
//  PotionShopPauseMenu.swift
//  Ednar's Potion Cauldron — PLAYER-FACING settings / pause menu
//
//  JULY 2, 2026 — built in the Match-3 pause-menu style:
//
//    • You DRAW the whole menu as ONE image ("ps_pausemenu"); the code
//      overlays INVISIBLE TAP ZONES on it. Until the art exists, a
//      code-drawn parchment panel renders buttons at the EXACT zone
//      positions — so the fallback doubles as your drawing template:
//      screenshot it, draw over it in Procreate, export, done.
//    • End Game shows a confirmation dialog ("ps_endgame_dialog" image,
//      same tap-zone system, code fallback until drawn).
//
//  ASSETS (transparent PNGs, Assets.xcassets):
//    ps_settings_button  — the ☰ button in the header (256×256)
//    ps_pausemenu        — full menu panel (suggest 900×1560 px ≈ 300×520 pt)
//    ps_endgame_dialog   — confirmation dialog (suggest 1020×1140 ≈ 340×380 pt)
//
//  TAP ZONES: edit the fractions in PotionShopPauseMenuLayout below to
//  match where you draw each button (0 = panel top, 1 = panel bottom).
//  Set showZones = true temporarily to SEE the zones over your art.
//

import SwiftUI

// MARK: - Zone layout (edit these to match your drawn art)

struct PotionShopPauseMenuLayout {
    /// Panel size in points (Match-3 used 280×500; this is a touch bigger).
    static let panelWidth: CGFloat = 300
    static let panelHeight: CGFloat = 520
    /// Dialog size in points.
    static let dialogWidth: CGFloat = 340
    static let dialogHeight: CGFloat = 380

    /// TEMPORARY TUNING AID: true = draw translucent colored rectangles
    /// over every tap zone so you can line them up with your art.
    static let showZones: Bool = false

    /// Each button's vertical band as fractions of the PANEL height
    /// (top, bottom). Horizontal span is horizontalInset from each side.
    static let horizontalInset: CGFloat = 0.14
    static let resumeZone:   (top: CGFloat, bottom: CGFloat) = (0.30, 0.41)
    static let restartZone:  (top: CGFloat, bottom: CGFloat) = (0.43, 0.54)
    static let tutorialZone: (top: CGFloat, bottom: CGFloat) = (0.56, 0.67)
    static let saveExitZone: (top: CGFloat, bottom: CGFloat) = (0.69, 0.80)
    static let endGameZone:  (top: CGFloat, bottom: CGFloat) = (0.82, 0.93)

    /// Confirmation dialog zones (fractions of DIALOG height).
    static let confirmZone:  (top: CGFloat, bottom: CGFloat) = (0.52, 0.70)
    static let cancelZone:   (top: CGFloat, bottom: CGFloat) = (0.74, 0.92)
}

// MARK: - The menu

struct PotionShopPauseMenu: View {
    @Bindable var gs: PotionShopGameState
    var tutorial: PotionShopTutorialState
    @Binding var isPresented: Bool
    /// Dismisses the whole game back to the title screen
    /// (GameView passes its `dismiss()` here, same as the debug menu).
    var onEndGame: () -> Void

    @State private var showEndGameConfirm = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Dimmed backdrop — tapping it resumes (standard pause behavior).
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { close() }

            if showEndGameConfirm {
                endGameDialog
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            } else {
                menuPanel
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    // ─── MENU PANEL ──────────────────────────────────────────────
    private var menuPanel: some View {
        let W = PotionShopPauseMenuLayout.panelWidth
        let H = PotionShopPauseMenuLayout.panelHeight
        return ZStack {
            if let art = PotionShopImageLoader.loadDisplayImage(named: "ps_pausemenu", displaySize: PotionShopPauseMenuLayout.panelHeight) {
                Image(uiImage: art)
                    .resizable()
                    .scaledToFit()
                    .frame(width: W, height: H)
            } else {
                fallbackPanel(width: W, height: H)
            }

            // Invisible tap zones (visible while showZones = true).
            zone(.red,    PotionShopPauseMenuLayout.resumeZone,   W, H) { close() }
            zone(.orange, PotionShopPauseMenuLayout.restartZone,  W, H) {
                // Restart the CURRENT round from scratch.
                gs.startRound()
                close()
            }
            zone(.yellow, PotionShopPauseMenuLayout.tutorialZone, W, H) {
                close()
                tutorial.start()
            }
            zone(.green,  PotionShopPauseMenuLayout.saveExitZone, W, H) {
                PotionShopSave.save(gs: gs)
                close()
                // Give the close animation a beat, then leave to title.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onEndGame()
                }
            }
            zone(.blue,   PotionShopPauseMenuLayout.endGameZone,  W, H) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showEndGameConfirm = true
                }
            }
        }
        .frame(width: W, height: H)
    }

    // ─── END GAME CONFIRMATION ───────────────────────────────────
    private var endGameDialog: some View {
        let W = PotionShopPauseMenuLayout.dialogWidth
        let H = PotionShopPauseMenuLayout.dialogHeight
        return ZStack {
            if let art = PotionShopImageLoader.loadDisplayImage(named: "ps_endgame_dialog", displaySize: PotionShopPauseMenuLayout.dialogHeight) {
                Image(uiImage: art)
                    .resizable()
                    .scaledToFit()
                    .frame(width: W, height: H)
            } else {
                fallbackDialog(width: W, height: H)
            }
            zone(.red,   PotionShopPauseMenuLayout.confirmZone, W, H) {
                // Does NOT save — "End Game" abandons the round.
                close()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onEndGame()
                }
            }
            zone(.green, PotionShopPauseMenuLayout.cancelZone,  W, H) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showEndGameConfirm = false
                }
            }
        }
        .frame(width: W, height: H)
    }

    // ─── HELPERS ─────────────────────────────────────────────────

    /// One tap zone: an invisible (or, while tuning, tinted) rectangle
    /// positioned by its vertical fraction band.
    private func zone(_ debugColor: Color,
                      _ band: (top: CGFloat, bottom: CGFloat),
                      _ W: CGFloat, _ H: CGFloat,
                      action: @escaping () -> Void) -> some View {
        let inset = PotionShopPauseMenuLayout.horizontalInset
        let zoneW = W * (1 - inset * 2)
        let zoneH = H * (band.bottom - band.top)
        let centerY = H * (band.top + band.bottom) / 2 - H / 2
        return Rectangle()
            .fill(PotionShopPauseMenuLayout.showZones
                  ? debugColor.opacity(0.35) : Color.clear)
            .frame(width: zoneW, height: zoneH)
            .contentShape(Rectangle())
            .offset(y: centerY)
            .onTapGesture(perform: action)
    }

    private func close() {
        withAnimation(.easeOut(duration: 0.2)) { appeared = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
            showEndGameConfirm = false
        }
    }

    /// Code-drawn panel — ALSO your drawing template: buttons render at
    /// the exact tap-zone positions, so drawing over a screenshot of
    /// this lines your art up with the zones automatically.
    private func fallbackPanel(width W: CGFloat, height H: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.95, green: 0.89, blue: 0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(red: 0.35, green: 0.22, blue: 0.10), lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.4), radius: 14, y: 6)

            Text("PAUSED")
                .font(Font.gameScore(size: 30))
                .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.10))
                .offset(y: -H * 0.36)

            fallbackButton("Resume",       PotionShopPauseMenuLayout.resumeZone,   W, H)
            fallbackButton("Restart Round",PotionShopPauseMenuLayout.restartZone,  W, H)
            fallbackButton("Tutorial",     PotionShopPauseMenuLayout.tutorialZone, W, H)
            fallbackButton("Save & Exit",  PotionShopPauseMenuLayout.saveExitZone, W, H)
            fallbackButton("End Game",     PotionShopPauseMenuLayout.endGameZone,  W, H,
                           tint: Color(red: 0.62, green: 0.17, blue: 0.12))
        }
    }

    private func fallbackButton(_ label: String,
                                _ band: (top: CGFloat, bottom: CGFloat),
                                _ W: CGFloat, _ H: CGFloat,
                                tint: Color = Color(red: 0.42, green: 0.27, blue: 0.14)) -> some View {
        let inset = PotionShopPauseMenuLayout.horizontalInset
        let centerY = H * (band.top + band.bottom) / 2 - H / 2
        return RoundedRectangle(cornerRadius: 10)
            .fill(tint)
            .overlay(
                Text(label)
                    .font(Font.gameUI(size: 17))
                    .foregroundColor(.white)
            )
            .frame(width: W * (1 - inset * 2), height: H * (band.bottom - band.top) * 0.9)
            .offset(y: centerY)
            .allowsHitTesting(false)   // the invisible zone handles taps
    }

    private func fallbackDialog(width W: CGFloat, height H: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.95, green: 0.89, blue: 0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(red: 0.35, green: 0.22, blue: 0.10), lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.4), radius: 14, y: 6)
            Text("ARE YOU SURE?")
                .font(Font.gameScore(size: 22))
                .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.10))
                .offset(y: -H * 0.28)
            Text("Ending abandons this round.\n(Use Save & Exit to keep it.)")
                .font(Font.gameUI(size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.10).opacity(0.8))
                .offset(y: -H * 0.10)
            fallbackButton("END GAME", PotionShopPauseMenuLayout.confirmZone, W, H,
                           tint: Color(red: 0.62, green: 0.17, blue: 0.12))
            fallbackButton("CANCEL",   PotionShopPauseMenuLayout.cancelZone,  W, H)
        }
    }
}
