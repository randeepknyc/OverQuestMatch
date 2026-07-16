//
//  DevMode.swift
//  OverQuestMatch3
//
//  JULY 13, 2026 — SHARED DEV MODE (one switch for the whole app).
//  Place in: the project ROOT (next to OverQuestMatch3App.swift),
//  NOT inside the PotionShop folder — both games and the game
//  selector use it.
//
//  ═══════════════════════════════════════════════════════════════════
//  WHAT IT CONTROLS (dev mode OFF = the friend/TestFlight experience):
//    • Potion shop debug button (top-right, under the gear) — hidden
//    • Match-3 hammer 🔨 button — hidden
//    • Enna's Tavern + Shop of Oddities — greyed "Coming soon" in the
//      game selector, not launchable
//
//  HOW IT UNLOCKS (ON only — never toggles off by tapping):
//    5 quick taps (each within 1.5s of the last) on any of:
//      • the "Day N" label in the potion shop header
//      • the score/title strip at the top of Match-3
//      • the "GAME SELECTOR" title on the selector screen
//    A haptic bump + a small "Dev mode ON" toast confirm it.
//
//  HOW IT TURNS OFF:
//    The "🙈 Hide Dev Mode" button inside either debug menu.
//
//  DEFAULTS: Xcode (DEBUG) builds start ON — your normal workflow is
//  unchanged. TestFlight/App Store (RELEASE) builds start OFF — friends
//  see the locked build. Your choice persists per device after that
//  (UserDefaults), including across TestFlight updates.
//

import SwiftUI

@Observable
final class DevMode {

    static let shared = DevMode()
    static let storageKey = "devModeUnlocked"

    /// The one switch. Views that read this re-render automatically
    /// when it flips (Observation framework).
    var unlocked: Bool {
        didSet { UserDefaults.standard.set(unlocked, forKey: Self.storageKey) }
    }

    /// Bumped when the 5-tap unlock fires; screens observing it show
    /// the toast below.
    var toastToken: Int = 0
    /// JULY 13 (rev 3): what the toast says — "already ON" when the
    /// 5-tap fires while unlocked, so the secret target always gives
    /// feedback and "already on" can't be mistaken for "broken".
    var toastText: String = "🛠 Dev mode ON"

    private var tapCount = 0
    private var lastTap: Date = .distantPast

    private init() {
        // JULY 13 (rev 2): OFF by default in EVERY build — Xcode runs
        // included (user request; the DEBUG-on default surprised them).
        // 5 taps turn it on; the choice persists per device after that.
        unlocked = UserDefaults.standard.bool(forKey: Self.storageKey)
    }

    /// Call from a secret tap target. 5 quick taps (≤1.5s apart) turn
    /// dev mode ON. Never turns it OFF (that's the debug-menu button
    /// only, so a stray tap flurry can't lock you out) — but JULY 13
    /// (rev 3): if it's ALREADY on, 5 taps now show an "already ON"
    /// toast instead of doing nothing silently.
    func registerSecretTap() {
        let now = Date()
        if now.timeIntervalSince(lastTap) > 1.5 { tapCount = 0 }
        lastTap = now
        tapCount += 1
        if tapCount >= 5 {
            tapCount = 0
            if unlocked {
                toastText = "🛠 Dev mode already ON"
            } else {
                unlocked = true
                toastText = "🛠 Dev mode ON"
            }
            toastToken += 1
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    /// The debug menus' "Hide Dev Mode" button.
    func turnOff() {
        unlocked = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// MARK: - "Dev mode ON" toast
//
// Attach `.devModeToast()` to a screen that hosts a secret tap target.
// Shows a small capsule at the top for ~1.8s when the unlock fires.

struct DevModeToastModifier: ViewModifier {
    @State private var visible = false

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            // Reading toastToken here registers observation; the hidden
            // Text re-evaluates this overlay when the token bumps.
            let token = DevMode.shared.toastToken
            ZStack {
                if visible {
                    Text(DevMode.shared.toastText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.black.opacity(0.8)))
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, 8)
            .onChange(of: token) { _, _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { visible = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeOut(duration: 0.3)) { visible = false }
                }
            }
        }
    }
}

extension View {
    /// Shows the "Dev mode ON" toast on this screen when the 5-tap
    /// unlock fires. Purely visual; safe to attach anywhere.
    func devModeToast() -> some View {
        modifier(DevModeToastModifier())
    }
}
