//
//  PotionShopTutorialOverlay.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — 4-step tutorial overlay.
//  Place in: PotionShop/ folder
//
//  A transparent, full-screen layer drawn on top of the game.
//  Dims the background, highlights one element at a time, and walks the
//  player through 4 steps. Skippable at any point.
//
//  Steps 1–3 are watch-only (advance on tap).
//  Step 4 is do-it: the player drags real dice and presses Brew.
//

import SwiftUI

// MARK: - Tutorial constants

/// All step text, scripted values, and timing live here.
/// Edit this one enum to change copy, timings, or the scripted hand.
enum PotionShopTutorialConstants {

    // ── Step text (placeholder copy — easy to tweak) ─────────────

    static let step1Title = "Welcome!"
    static let step1Body  = "Welcome to Ednar's potion shop! Your job is to make potions for customers and keep the shop open as long as possible."

    static let step2Title = "Customers Arrive"
    static let step2Body  = "Customers arrive and line up. Each one wants a potion of a certain strength."

    static let step3Title = "Potion Value"
    static let step3Body  = "This is the potion value your customer wants. Match or exceed it to satisfy them!"

    static let step4Title = "Your Turn!"
    static let step4Body  = "Now you try — drag dice from the tray onto the cauldron, then press BREW."

    // ── Scripted opening hand (fixed values for the tutorial) ────
    // Five dice: type + value. Kept simple for the first-ever brew.
    // JULY 2, 2026: values capped at 3 — the basic die is now
    // [1,1,2,2,3,3], so a 4 would be an impossible roll.

    static let scriptedHand: [(type: PotionShopDieType, value: Int)] = [
        (.potency,  3),
        (.potency,  2),
        (.heal,     2),
        (.potency,  3),
        (.shield,   1),
    ]

    // ── Visual timing ────────────────────────────────────────────

    /// Duration of the boiling-circle draw animation (step 3).
    static let boilCircleDuration: Double = 0.8
    /// Pulse scale range for the boil effect.
    static let boilPulseMin: CGFloat = 0.97
    static let boilPulseMax: CGFloat = 1.03
}

// MARK: - Tutorial state

@Observable
class PotionShopTutorialState {

    /// Whether the tutorial overlay is currently showing.
    var isActive: Bool = false

    /// Current step index (0–3). Reset to 0 when `isActive` is set true.
    var currentStep: Int = 0

    /// JULY 3, 2026: total number of tutorial steps — the ONE number to
    /// change when adding steps. The debug menu's stepper ("Step X of Y"),
    /// the brew-step check below, and advance() all derive from it.
    let stepCount: Int = 4

    /// JULY 3, 2026: GameView finishes the tutorial when the player brews
    /// during the do-it step — defined as the LAST step, via stepCount.
    var currentStepIsBrewStep: Bool { currentStep >= stepCount - 1 }

    /// UserDefaults key for first-run tracking.
    static let hasSeenKey = "ps_hasSeenTutorial"

    /// True if the player has completed (or skipped) the tutorial before.
    var hasSeenTutorial: Bool {
        get { UserDefaults.standard.bool(forKey: Self.hasSeenKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.hasSeenKey) }
    }

    /// Start (or restart) the tutorial from step 0.
    func start() {
        currentStep = 0
        isActive = true
    }

    /// Advance to the next step, or finish if on the last step.
    func advance() {
        if currentStep < stepCount - 1 {
            currentStep += 1
        } else {
            finish()
        }
    }

    /// End the tutorial (skip or completion).
    func finish() {
        isActive = false
        hasSeenTutorial = true
    }
}

// MARK: - Tutorial overlay view

struct PotionShopTutorialOverlay: View {
    @Bindable var tutorial: PotionShopTutorialState
    @Bindable var gs: PotionShopGameState

    // Boil-circle animation state (step 3)
    @State private var boilTrim: CGFloat = 0
    @State private var boilPulse: CGFloat = 1.0
    @State private var boilRotation: Double = 0

    // Step appearance animation
    @State private var cardOpacity: Double = 0
    @State private var cardOffset: CGFloat = 30

    var body: some View {
        let step = tutorial.currentStep

        ZStack {
            // ── DIM LAYER ───────────────────────────────────────
            // Step 4: dim only the header + scene; leave cauldron/tray
            // interactive. Steps 0–3: dim everything.
            Color.black.opacity(step < 3 ? 0.6 : 0.35)
                .ignoresSafeArea()
                .allowsHitTesting(step < 3)  // steps 0-2 block taps on game
                .onTapGesture {
                    if step < 3 {
                        advanceWithAnimation()
                    }
                }

            // ── SPOTLIGHT / HIGHLIGHT ────────────────────────────
            // Step 3: boiling circle around HP badge area
            if step == 2 {
                boilingCircleHighlight
            }

            // ── TEXT CARD ────────────────────────────────────────
            VStack {
                if step == 0 {
                    // Step 1: centered
                    Spacer()
                    tutorialCard(title: PotionShopTutorialConstants.step1Title,
                                 body: PotionShopTutorialConstants.step1Body,
                                 showNext: true)
                    Spacer()
                } else if step == 1 {
                    // Step 2: top third (above customer scene)
                    Spacer().frame(height: 60)
                    tutorialCard(title: PotionShopTutorialConstants.step2Title,
                                 body: PotionShopTutorialConstants.step2Body,
                                 showNext: true)
                    Spacer()
                } else if step == 2 {
                    // Step 3: top area (HP badge highlight is in the scene)
                    Spacer().frame(height: 60)
                    tutorialCard(title: PotionShopTutorialConstants.step3Title,
                                 body: PotionShopTutorialConstants.step3Body,
                                 showNext: true)
                    Spacer()
                } else {
                    // Step 4: top area, cauldron/tray interactive below
                    Spacer().frame(height: 60)
                    tutorialCard(title: PotionShopTutorialConstants.step4Title,
                                 body: PotionShopTutorialConstants.step4Body,
                                 showNext: false)
                    Spacer()
                }
            }
            .padding(.horizontal, 24)

            // ── SKIP BUTTON (always visible, top-right) ──────────
            VStack {
                HStack {
                    Spacer()
                    Button {
                        tutorial.finish()
                    } label: {
                        Text("Skip")
                            .font(Font.gameUI(size: 14))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .padding(.top, 54)
                    .padding(.trailing, 16)
                }
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: tutorial.currentStep)
        .onAppear {
            animateCardIn()
        }
        .onChange(of: tutorial.currentStep) { _, newStep in
            animateCardIn()
            if newStep == 2 {
                startBoilAnimation()
            }
        }
    }

    // MARK: - Tutorial card

    private func tutorialCard(title: String, body: String, showNext: Bool) -> some View {
        VStack(spacing: 14) {
            Text(title)
                .font(Font.gameUI(size: 22))
                .foregroundColor(.white)

            Text(body)
                .font(Font.gameUI(size: 15))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if showNext {
                Button {
                    advanceWithAnimation()
                } label: {
                    Text("Next")
                        .font(Font.gameUI(size: 16))
                        .foregroundColor(PotionShopTheme.ink)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(PotionShopTheme.accent)
                        )
                }
                .padding(.top, 4)
            } else {
                // Step 4 hint
                Text("Tap BREW when ready")
                    .font(Font.gameUI(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PotionShopTheme.accent.opacity(0.5), lineWidth: 1.5)
        )
        .opacity(cardOpacity)
        .offset(y: cardOffset)
    }

    // MARK: - Boiling circle (step 3)

    private var boilingCircleHighlight: some View {
        // Position the boiling circle in the customer scene area,
        // roughly where the active customer's HP badge sits.
        // This is a visual indicator, not pixel-perfect anchored.
        VStack {
            Spacer().frame(height: 180) // below header, into scene area
            Circle()
                .trim(from: 0, to: boilTrim)
                .stroke(
                    PotionShopTheme.accent,
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round, dash: [6, 4])
                )
                .frame(width: 70, height: 70)
                .scaleEffect(boilPulse)
                .rotationEffect(.degrees(boilRotation))
                .shadow(color: PotionShopTheme.accent.opacity(0.6), radius: 8)
            Spacer()
        }
    }

    // MARK: - Animations

    private func animateCardIn() {
        cardOpacity = 0
        cardOffset = 30
        withAnimation(.easeOut(duration: 0.4)) {
            cardOpacity = 1
            cardOffset = 0
        }
    }

    private func startBoilAnimation() {
        boilTrim = 0
        boilPulse = 1.0
        boilRotation = 0

        withAnimation(.easeInOut(duration: PotionShopTutorialConstants.boilCircleDuration)) {
            boilTrim = 1.0
        }
        withAnimation(
            .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true)
        ) {
            boilPulse = PotionShopTutorialConstants.boilPulseMax
        }
        withAnimation(
            .linear(duration: 4.0)
                .repeatForever(autoreverses: false)
        ) {
            boilRotation = 360
        }
    }

    private func advanceWithAnimation() {
        // Fade out, advance, fade in
        withAnimation(.easeIn(duration: 0.15)) {
            cardOpacity = 0
            cardOffset = -10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            tutorial.advance()
        }
    }
}
