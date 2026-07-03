//
//  PotionShopTutorialOverlay.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — data-driven tutorial overlay (FULLY EDITABLE).
//  Place in: PotionShop/ folder  (REPLACES the old 4-step version)
//
//  ═══════════════════════════════════════════════════════════════════════
//  EVERYTHING is edited in ONE place: the array `PotionShopTutorialSteps.all`
//  further down. Each step is one entry, and EVERY visual property is a field
//  you can set per step:
//
//     • text .......... title, body
//     • font size ..... titleSize, bodySize
//     • card position . cardX, cardY  (0…1 fractions of the screen)
//     • card width .... cardWidth     (fraction of screen width)
//     • overlay dim ... dimOpacity    (0 = clear, 1 = black)
//     • card panel .... cardBgOpacity (darkness of the text box itself)
//     • interaction ... mode          (.watch = tap Next | .doBrew = player brews)
//     • indicators .... indicators: [ ... ]  (the glowing markers — see below)
//
//  POSITION VALUES are fractions of the screen: x 0 = left, 1 = right;
//  y 0 = top, 1 = bottom. So cardY: 0.22 puts the card near the top,
//  cardY: 0.85 near the bottom. Same for each indicator's x / y.
//
//  INDICATORS: each step can have any number. Each one is:
//     PotionShopTutorialIndicator(
//         shape: .ring,          // .ring | .boilRing (animated) | .box
//         x: 0.5, y: 0.6,        // where it points (screen fractions)
//         size: 150,             // ring diameter, or box WIDTH
//         height: 90,            // box HEIGHT (ignored for rings)
//         lineWidth: 3.5,
//         color: PotionShopTheme.accent,
//         opacity: 1.0
//     )
//
//  The LAST step should be `.doBrew` — the player performs it, and the game
//  finishes the tutorial when they press BREW (wired in PotionShopGameView
//  via `tutorial.currentStepIsBrewStep`). Skip button (top-right) always ends it.
//

import SwiftUI

// MARK: - Enums

enum PotionShopTutorialMode {
    case watch    // dim blocks the game; tap Next / anywhere to advance
    case doBrew   // dim lets taps through; player brews; finishes on BREW
}

enum PotionShopTutorialIndicatorShape {
    case ring        // simple pulsing circle
    case boilRing    // animated "boiling" dashed circle that draws + rotates
    case box         // rounded rectangle (use size = width, height = height)
}

// MARK: - Indicator (a glowing marker)

struct PotionShopTutorialIndicator: Identifiable {
    let id = UUID()
    var shape: PotionShopTutorialIndicatorShape = .ring
    /// Screen-fraction position of the marker's CENTER. 0…1.
    var x: CGFloat = 0.5
    var y: CGFloat = 0.5
    /// Ring diameter, or box width, in points.
    var size: CGFloat = 130
    /// Box height in points (ignored by rings).
    var height: CGFloat = 130
    var lineWidth: CGFloat = 3.5
    var color: Color = PotionShopTheme.accent
    var opacity: Double = 1.0
}

// MARK: - Step

struct PotionShopTutorialStep: Identifiable {
    let id = UUID()

    // Text
    var title: String
    var body: String

    // Font size
    var titleSize: CGFloat = 22
    var bodySize: CGFloat = 15

    // Overlay + card
    var dimOpacity: Double = 0.6      // darkness of the whole overlay this step
    var cardBgOpacity: Double = 0.75  // darkness of the text panel

    // Interaction
    var mode: PotionShopTutorialMode = .watch

    // Card placement (screen fractions; the card is CENTERED on this point)
    var cardX: CGFloat = 0.5
    var cardY: CGFloat = 0.22
    var cardWidth: CGFloat = 0.86     // fraction of screen width

    // Markers
    var indicators: [PotionShopTutorialIndicator] = []
}

// MARK: - THE TUTORIAL  (edit these entries freely)

enum PotionShopTutorialSteps {

    static let all: [PotionShopTutorialStep] = [

        // 1 — Welcome
        PotionShopTutorialStep(
            title: "Welcome!",
            body: "Welcome to Ednar's potion shop! Your job is to brew potions for customers and keep the shop open as long as you can.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.5,
            indicators: []
        ),

        // 2 — Customers arrive
        PotionShopTutorialStep(
            title: "Your Customers",
            body: "Customers line up here. You serve the one in front — the rest wait their turn.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.78,
            indicators: [
                PotionShopTutorialIndicator(shape: .ring, x: 0.5, y: 0.28, size: 150)
            ]
        ),

        // 3 — The order (potion value)
        PotionShopTutorialStep(
            title: "The Order",
            body: "Each customer wants a potion of a certain strength. This number is their order — your brew must meet or beat it.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.78,
            indicators: [
                PotionShopTutorialIndicator(shape: .boilRing, x: 0.5, y: 0.28, size: 80)
            ]
        ),

        // 4 — Your dice
        PotionShopTutorialStep(
            title: "Your Dice",
            body: "These are your dice. You roll a fresh set each turn — the number on a die is how strong it is.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.22,
            indicators: [
                PotionShopTutorialIndicator(shape: .box, x: 0.5, y: 0.86, size: 320, height: 90)
            ]
        ),

        // 5 — The cauldron
        PotionShopTutorialStep(
            title: "The Cauldron",
            body: "Drag dice from the tray onto the cauldron's slots to build your potion. Where you place them matters.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.22,
            indicators: [
                PotionShopTutorialIndicator(shape: .ring, x: 0.5, y: 0.60, size: 170)
            ]
        ),

        // 6 — Potency dice
        PotionShopTutorialStep(
            title: "Potency (Red)",
            body: "Red POTENCY dice are your main strength — each one adds its number straight to the potion.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.22,
            indicators: [
                PotionShopTutorialIndicator(shape: .box, x: 0.5, y: 0.86, size: 320, height: 90,
                                            color: PotionShopDieType.potency.color)
            ]
        ),

        // 7 — Boost dice
        PotionShopTutorialStep(
            title: "Boost (Purple)",
            body: "Purple BOOST dice make other dice stronger — but they reach the slots TWO spaces away, skipping their direct neighbors. Placing them well is the puzzle.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.22,
            indicators: [
                PotionShopTutorialIndicator(shape: .ring, x: 0.5, y: 0.60, size: 170,
                                            color: PotionShopDieType.boost.color)
            ]
        ),

        // 8 — Heal dice
        PotionShopTutorialStep(
            title: "Heal (Green)",
            body: "Green HEAL dice restore your Composure — your nerve, shown up here. If it ever hits zero, the shop closes.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.7,
            indicators: [
                PotionShopTutorialIndicator(shape: .ring, x: 0.5, y: 0.07, size: 110,
                                            color: PotionShopDieType.heal.color)
            ]
        ),

        // 9 — Shield dice
        PotionShopTutorialStep(
            title: "Shield (Teal)",
            body: "Teal SHIELD dice soak the customer's impatience this turn, protecting your Composure.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.7,
            indicators: [
                PotionShopTutorialIndicator(shape: .ring, x: 0.5, y: 0.07, size: 110,
                                            color: PotionShopDieType.shield.color)
            ]
        ),

        // 10 — Stability & the fire
        PotionShopTutorialStep(
            title: "Keep the Fire Lit",
            body: "The fire under your cauldron burns down as you brew. Blue STABILITY dice refill it — don't let it go out.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.22,
            indicators: [
                PotionShopTutorialIndicator(shape: .box, x: 0.5, y: 0.74, size: 200, height: 60,
                                            color: PotionShopDieType.stability.color)
            ]
        ),

        // 11 — Patience
        PotionShopTutorialStep(
            title: "Don't Keep Them Waiting",
            body: "Customers lose patience the longer they wait, and impatience chips away at your Composure. Keep the line moving.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.78,
            indicators: [
                PotionShopTutorialIndicator(shape: .box, x: 0.5, y: 0.42, size: 300, height: 70)
            ]
        ),

        // 12 — Days / the goal
        PotionShopTutorialStep(
            title: "Survive the Day",
            body: "Serve enough customers to finish the day, then the next day begins. How many days you survive is your score.",
            dimOpacity: 0.6,
            cardX: 0.5, cardY: 0.7,
            indicators: [
                PotionShopTutorialIndicator(shape: .ring, x: 0.5, y: 0.07, size: 110)
            ]
        ),

        // 13 — Your turn (PLAYER BREWS)  ← keep this one .doBrew
        PotionShopTutorialStep(
            title: "Your Turn!",
            body: "Now you try — drag dice onto the cauldron to reach the order, then press BREW.",
            dimOpacity: 0.32,          // lighter so the player can see what they're doing
            mode: .doBrew,
            cardX: 0.5, cardY: 0.18,
            indicators: [
                PotionShopTutorialIndicator(shape: .ring, x: 0.5, y: 0.60, size: 170)
            ]
        ),
    ]
}

// MARK: - Tuning constants (animation only)

enum PotionShopTutorialConstants {
    /// Duration of the boiling-ring draw animation.
    static let boilCircleDuration: Double = 0.8
}

// MARK: - Tutorial state

@Observable
class PotionShopTutorialState {

    var isActive: Bool = false
    var currentStep: Int = 0

    static let hasSeenKey = "ps_hasSeenTutorial"

    var hasSeenTutorial: Bool {
        get { UserDefaults.standard.bool(forKey: Self.hasSeenKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.hasSeenKey) }
    }

    var steps: [PotionShopTutorialStep] { PotionShopTutorialSteps.all }
    var stepCount: Int { steps.count }

    var step: PotionShopTutorialStep? {
        steps.indices.contains(currentStep) ? steps[currentStep] : nil
    }

    /// True when the current step is the "player brews" step. GameView watches
    /// this to finish the tutorial on BREW.
    var currentStepIsBrewStep: Bool { step?.mode == .doBrew }

    func start() {
        currentStep = 0
        isActive = true
    }

    func advance() {
        if currentStep < stepCount - 1 {
            currentStep += 1
        } else {
            finish()
        }
    }

    func finish() {
        isActive = false
        hasSeenTutorial = true
    }
}

// MARK: - Overlay view

struct PotionShopTutorialOverlay: View {
    @Bindable var tutorial: PotionShopTutorialState
    @Bindable var gs: PotionShopGameState

    @State private var cardOpacity: Double = 0
    @State private var cardOffset: CGFloat = 30

    var body: some View {
        GeometryReader { geo in
            if let step = tutorial.step {
                let isWatch = (step.mode == .watch)
                let W = geo.size.width
                let H = geo.size.height

                ZStack {
                    // ── DIM LAYER ────────────────────────────────
                    Color.black.opacity(step.dimOpacity)
                        .ignoresSafeArea()
                        .allowsHitTesting(isWatch)   // watch blocks the game; doBrew passes taps through
                        .onTapGesture {
                            if isWatch { advanceWithAnimation() }
                        }

                    // ── INDICATORS ───────────────────────────────
                    ForEach(step.indicators) { ind in
                        indicatorView(ind)
                            .position(x: W * ind.x, y: H * ind.y)
                    }
                    .id(tutorial.currentStep)   // re-animate markers each step

                    // ── TEXT CARD ────────────────────────────────
                    card(for: step)
                        .frame(width: W * step.cardWidth)
                        .position(x: W * step.cardX, y: H * step.cardY)

                    // ── SKIP (always top-right) ──────────────────
                    skipButton
                }
                .onAppear { animateCardIn() }
                .onChange(of: tutorial.currentStep) { _, _ in animateCardIn() }
                .animation(.easeInOut(duration: 0.35), value: tutorial.currentStep)
            }
        }
    }

    // MARK: Card

    private func card(for step: PotionShopTutorialStep) -> some View {
        VStack(spacing: 14) {
            Text(step.title)
                .font(Font.gameUI(size: step.titleSize))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(step.body)
                .font(Font.gameUI(size: step.bodySize))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if step.mode == .watch {
                Button { advanceWithAnimation() } label: {
                    Text("Next")
                        .font(Font.gameUI(size: 16))
                        .foregroundColor(PotionShopTheme.ink)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(PotionShopTheme.accent))
                }
                .padding(.top, 4)
            } else {
                Text("Tap BREW when ready")
                    .font(Font.gameUI(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(step.cardBgOpacity)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PotionShopTheme.accent.opacity(0.5), lineWidth: 1.5)
        )
        .opacity(cardOpacity)
        .offset(y: cardOffset)
    }

    // MARK: Indicators

    @ViewBuilder
    private func indicatorView(_ ind: PotionShopTutorialIndicator) -> some View {
        switch ind.shape {
        case .ring:
            TutorialMarker(diameter: ind.size, lineWidth: ind.lineWidth,
                           color: ind.color, boiling: false)
                .opacity(ind.opacity)
        case .boilRing:
            TutorialMarker(diameter: ind.size, lineWidth: ind.lineWidth,
                           color: ind.color, boiling: true)
                .opacity(ind.opacity)
        case .box:
            TutorialBox(width: ind.size, height: ind.height,
                        lineWidth: ind.lineWidth, color: ind.color)
                .opacity(ind.opacity)
        }
    }

    // MARK: Skip

    private var skipButton: some View {
        VStack {
            HStack {
                Spacer()
                Button { tutorial.finish() } label: {
                    Text("Skip")
                        .font(Font.gameUI(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white.opacity(0.2)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
                }
                .padding(.top, 54)
                .padding(.trailing, 16)
            }
            Spacer()
        }
    }

    // MARK: Card animation

    private func animateCardIn() {
        cardOpacity = 0
        cardOffset = 30
        withAnimation(.easeOut(duration: 0.4)) {
            cardOpacity = 1
            cardOffset = 0
        }
    }

    private func advanceWithAnimation() {
        withAnimation(.easeIn(duration: 0.15)) {
            cardOpacity = 0
            cardOffset = -10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            tutorial.advance()
        }
    }
}

// MARK: - Marker shapes

/// A circular marker — simple pulse, or animated "boiling" dashed ring.
private struct TutorialMarker: View {
    let diameter: CGFloat
    let lineWidth: CGFloat
    let color: Color
    let boiling: Bool

    @State private var pulse: CGFloat = 1.0
    @State private var trim: CGFloat = 0
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .trim(from: 0, to: boiling ? trim : 1)
            .stroke(
                color,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round,
                                   dash: boiling ? [6, 4] : [])
            )
            .frame(width: diameter, height: diameter)
            .scaleEffect(pulse)
            .rotationEffect(.degrees(boiling ? rotation : 0))
            .shadow(color: color.opacity(0.6), radius: 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    pulse = 1.06
                }
                if boiling {
                    withAnimation(.easeInOut(duration: PotionShopTutorialConstants.boilCircleDuration)) {
                        trim = 1.0
                    }
                    withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                } else {
                    trim = 1.0
                }
            }
    }
}

/// A rounded-rectangle marker (for highlighting the tray, a row, etc.).
private struct TutorialBox: View {
    let width: CGFloat
    let height: CGFloat
    let lineWidth: CGFloat
    let color: Color

    @State private var pulse: CGFloat = 1.0

    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, dash: [8, 5]))
            .frame(width: width, height: height)
            .scaleEffect(pulse)
            .shadow(color: color.opacity(0.6), radius: 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    pulse = 1.04
                }
            }
    }
}
