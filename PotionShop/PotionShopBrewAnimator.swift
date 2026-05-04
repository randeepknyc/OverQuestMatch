//
//  PotionShopBrewAnimator.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Brew animation timing constants
//  Place in: PotionShop/ folder
//
//  ═══════════════════════════════════════════════════════════════════════
//  THIS IS THE ANIMATION TUNING FILE.
//  ═══════════════════════════════════════════════════════════════════════
//  All timing values, animation curves, and visual parameters for the
//  brew sequence live here. Change values in this file to tune feel
//  without touching game logic.
//
//  Sections:
//    1. Phase durations  (how long each of the 7 brew phases takes)
//    2. Phase delays     (gap between phases)
//    3. Customer attack timing (the (c) hybrid: active alone, then waiters together)
//    4. Customer shake parameters
//    5. Floating number parameters
//    6. Composure flash parameters
//    7. Customer expiration parameters
//    8. FloatingNumber type definition
//

import SwiftUI

// MARK: - PotionShopBrewAnimator

enum PotionShopBrewAnimator {

    // ─── 1. PHASE DURATIONS ────────────────────────────────────────────

    /// Phase 1: heal + shield apply to player
    static let healShieldDuration: Double = 0.40

    /// Phase 2: volatile pre-defense (overbrew retaliation)
    static let volatileDuration: Double = 0.35

    /// Phase 3: brew damage to active customer
    static let brewDamageDuration: Double = 0.50

    /// Phase 4 (per-customer): customer attack lunge + recoil
    /// (c) hybrid: active customer attacks first, alone. Waiters
    /// attack together as a single beat.
    static let activeAttackDuration: Double = 0.50
    static let waiterGroupAttackDuration: Double = 0.50

    /// Phase 5: patience tick animation duration (rings shrink)
    static let patienceTickDuration: Double = 0.40

    /// Phase 6 (per-customer): expiration animation
    static let expirationDuration: Double = 0.60

    /// Phase 7: draining trait drain
    static let drainDuration: Double = 0.30

    // ─── 2. PHASE DELAYS (gap before each phase starts) ────────────────

    /// Initial pause after BREW tap before Phase 1 begins
    static let initialDelay: Double = 0.10
    static let preVolatileDelay: Double = 0.20
    static let preBrewDamageDelay: Double = 0.20
    static let preCustomerAttacksDelay: Double = 0.30
    /// Between active attack and waiter group attack
    static let betweenActiveAndWaitersDelay: Double = 0.15
    static let prePatienceDelay: Double = 0.20
    static let preExpirationsDelay: Double = 0.20
    static let preDrainDelay: Double = 0.20

    /// Pause at the very end before lockout releases
    static let endTrailDelay: Double = 0.20

    // ─── 3. CUSTOMER SHAKE ─────────────────────────────────────────────

    /// Shake amplitude (pixels)
    static let shakeAmplitude: CGFloat = 6.0
    /// Number of oscillations (each oscillation = back-and-forth)
    static let shakeOscillations: Int = 3
    /// Total duration of the shake
    static let shakeDuration: Double = 0.35

    // ─── 4. FLOATING NUMBER ────────────────────────────────────────────

    /// How far up a floating number drifts (pixels)
    static let floatRiseDistance: CGFloat = 50
    /// How long it's visible
    static let floatDuration: Double = 0.80
    /// Font size for floating numbers
    static let floatFontSize: CGFloat = 22

    /// SWAP THIS LINE WHEN OVERQUEST FONT IS AVAILABLE.
    /// Replace with: Font.custom("OverQuest", size: size)
    /// or whatever the registered name of your font ends up being.
    static func numberFont(size: CGFloat = floatFontSize) -> Font {
        Font.system(size: size, weight: .heavy, design: .serif)
    }

    // ─── 5. COMPOSURE FLASH ────────────────────────────────────────────

    /// How long the composure bar flashes red on damage / green on heal
    static let composureFlashDuration: Double = 0.25
    /// Flash intensity (0 = no flash, 1 = full color overlay)
    static let composureFlashIntensity: Double = 0.55

    // ─── 6. CUSTOMER EXPIRATION ────────────────────────────────────────

    /// How far the expiring customer slides off-screen (pixels right)
    static let expirationSlideDistance: CGFloat = 200
    /// Whether to show the 💢 emoji burst on expiration
    static let expirationShowEmoji: Bool = true
    static let expirationEmoji: String = "💢"
}

// MARK: - FloatingNumber type
//
// A single floating-number event the overlay should render. Stored on
// PotionShopGameState; the overlay observes the array and renders +
// removes them as they expire.

struct PotionShopFloatingNumber: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let color: Color
    /// Origin point in screen coordinates (where the number first appears).
    let position: CGPoint
    /// When this floating number was created (so the overlay can
    /// remove it after `floatDuration` seconds).
    let createdAt: Date

    static let healColor: Color = PotionShopTheme.composureGood
    static let damageEdnarColor: Color = PotionShopTheme.composureBad
    static let damageCustomerColor: Color = Color(red: 0.85, green: 0.18, blue: 0.18)
    static let shieldColor: Color = PotionShopTheme.shield
    static let drainColor: Color = PotionShopTheme.composureWarn
}

// MARK: - Damage / heal flash signal
//
// PotionShopGameState publishes one of these when composure changes
// during the brew sequence. The header observes and flashes accordingly.

enum PotionShopComposureFlash: Equatable {
    case damage
    case heal
}
