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
    // ⚠️ RULE: every value must be a face its die can ACTUALLY roll
    // (see PotionShopDieTier.faces(for:)). Current basic faces (§69.1):
    // potency/shield max 2 · heal max 3 (the only 3) · boost max 2.
    // JULY 4, 2026: potency 3s → 2s (the §69.1 curve made 3 impossible).

    static let scriptedHand: [(type: PotionShopDieType, value: Int)] = [
        (.potency,  2),
        (.potency,  2),
        (.heal,     2),
        (.potency,  2),
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

    // JULY 4, 2026: layout config (positions, dim levels) + live drag.
    @Bindable private var cfg = PotionShopLayoutConfig.shared
    @State private var dragStart: CGSize? = nil
    @State private var circleDragStart: CGSize? = nil

    var body: some View {
        let step = tutorial.currentStep

        ZStack {
            // ── DIM LAYER ───────────────────────────────────────
            // Step 4: dim only the header + scene; leave cauldron/tray
            // interactive. Steps 0–3: dim everything.
            // JULY 4, 2026: dim levels are config knobs (debug → 🎓 Tutorial
            // Layout): tutDimWatch for steps 1–3, tutDimDoIt for step 4.
            Color.black.opacity(step < 3 ? cfg.tutDimWatch : cfg.tutDimDoIt)
                .ignoresSafeArea()
                .allowsHitTesting(step < 3)  // steps 0-2 block taps on game
                .onTapGesture {
                    // JULY 4, 2026 (evening 5): EDIT MODE FREEZES the
                    // tutorial — no tap-to-advance, so drags edit instead
                    // of skipping steps. Navigate with the edit toolbar.
                    if step < 3, !cfg.tutorialEditMode {
                        advanceWithAnimation()
                    }
                }

            // ── SPOTLIGHT / HIGHLIGHT ────────────────────────────
            // JULY 4, 2026 (evening 3): dotted circles are a configurable
            // LIST — every circle assigned to the current step renders,
            // positioned by OFFSET FROM SCREEN CENTER (the old version was
            // anchored to the top with a Spacer guess — placement was off).
            // Edit mode: drag any circle; sliders live in 🎓 Tutorial Layout.
            ForEach(Array(cfg.tutCircles.enumerated()), id: \.element.id) { pair in
                if pair.element.step == step {
                    dottedCircle(index: pair.offset)
                }
            }

            // ── ✏️ EDIT TOOLBAR (July 4, 2026 — evening 5) ────────────
            // Visible ONLY in edit mode. The tutorial is frozen while
            // editing; this is how you move between steps and add circles
            // without fighting the tap-to-advance.
            if cfg.tutorialEditMode {
                VStack(spacing: 8) {
                    Spacer()
                    HStack(spacing: 14) {
                        Button {
                            if tutorial.currentStep > 0 { tutorial.currentStep -= 1 }
                        } label: {
                            Image(systemName: "chevron.left.circle.fill").font(.title2)
                        }
                        Text("Step \(step + 1) / \(tutorial.stepCount)")
                            .font(Font.gameUI(size: 14))
                            .foregroundColor(.white)
                            .monospacedDigit()
                        Button {
                            if tutorial.currentStep < tutorial.stepCount - 1 {
                                tutorial.currentStep += 1
                            }
                        } label: {
                            Image(systemName: "chevron.right.circle.fill").font(.title2)
                        }
                        Divider().frame(height: 22).background(Color.white.opacity(0.4))
                        Button {
                            cfg.tutCircles.append(
                                PotionShopLayoutConfig.TutorialCircle(step: step, x: 0, y: 0)
                            )
                        } label: {
                            Label("Circle", systemImage: "plus.circle.fill")
                                .font(Font.gameUI(size: 14))
                        }
                    }
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.black.opacity(0.82)))
                    .overlay(Capsule().stroke(Color.cyan.opacity(0.5), lineWidth: 1))
                    Text("✏️ Edit mode — taps don't advance. Drag the card & circles (grab anywhere inside a circle). Sliders: editor drawer → 🎓 Tutorial.")
                        .font(Font.gameUI(size: 11))
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 14)
                }
                .zIndex(80)
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
                            .font(Font.gameUI(size: 23))
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
            if cfg.tutCircles.contains(where: { $0.step == newStep }) {
                startBoilAnimation()
            }
        }
        // Circles on step 1 need the draw animation at first appearance too.
        .onAppear {
            if cfg.tutCircles.contains(where: { $0.step == tutorial.currentStep }) {
                startBoilAnimation()
            }
        }
    }

    // MARK: - Tutorial card

    private func tutorialCard(title: String, body: String, showNext: Bool) -> some View {
        VStack(spacing: 14) {
            Text(title)
                .font(Font.gameUI(size: 30))
                .foregroundColor(.white)

            Text(body)
                .font(Font.gameUI(size: 24))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if showNext, !cfg.tutorialEditMode {   // edit mode: navigate via the ✏️ toolbar
                Button {
                    advanceWithAnimation()
                } label: {
                    Text("Next")
                        .font(Font.gameUI(size: 26))
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
                    .font(Font.gameUI(size: 28))
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
        .frame(maxWidth: cfg.tutCardMaxWidth)
        .opacity(cardOpacity)
        .offset(y: cardOffset)
        // JULY 4, 2026: per-step nudge from the layout config, plus LIVE
        // DRAG when edit mode is on (debug → 🎓 Tutorial Layout). Dragging
        // writes straight into the config, so the values stick.
        .offset(x: cfg.tutCardOffsetX[min(tutorial.currentStep, 3)],
                y: cfg.tutCardOffsetY[min(tutorial.currentStep, 3)])
        .gesture(cfg.tutorialEditMode ? DragGesture()
            .onChanged { v in
                let i = min(tutorial.currentStep, 3)
                if dragStart == nil {
                    dragStart = CGSize(width: cfg.tutCardOffsetX[i],
                                       height: cfg.tutCardOffsetY[i])
                }
                cfg.tutCardOffsetX[i] = (dragStart?.width ?? 0) + v.translation.width
                cfg.tutCardOffsetY[i] = (dragStart?.height ?? 0) + v.translation.height
            }
            .onEnded { _ in dragStart = nil } : nil)
        .overlay(alignment: .top) {
            if cfg.tutorialEditMode {
                Text("EDIT MODE — drag me · step \(tutorial.currentStep + 1)")
                    .font(.caption2).foregroundColor(.yellow)
                    .padding(4).background(Color.black.opacity(0.7))
                    .offset(y: -22)
            }
        }
    }

    // MARK: - Boiling circle (step 3)

    @ViewBuilder
    private func dottedCircle(index: Int) -> some View {
        if index < cfg.tutCircles.count {
            let c = cfg.tutCircles[index]
            Circle()
                .trim(from: 0, to: boilTrim)
                .stroke(
                    PotionShopTheme.accent,
                    style: StrokeStyle(lineWidth: c.lineWidth, lineCap: .round, dash: [6, 4])
                )
                .frame(width: c.size, height: c.size)
                .scaleEffect(boilPulse)
                .rotationEffect(.degrees(boilRotation))
                .shadow(color: PotionShopTheme.accent.opacity(0.6), radius: 8)
                // JULY 5, 2026: DRAG FIX. The stroked dashes were the ONLY
                // touch target — a 3.5pt dotted line is impossible to grab.
                // In edit mode a faint fill shows the grab area, and
                // contentShape makes the WHOLE disc draggable (not just
                // the painted line). Normal runs: unchanged, untouchable.
                .background(
                    Circle()
                        .fill(PotionShopTheme.accent.opacity(cfg.tutorialEditMode ? 0.16 : 0))
                )
                .contentShape(Circle())
                // Offset from SCREEN CENTER — what the sliders say is
                // exactly where it sits, no hidden Spacer math.
                .offset(x: c.x, y: c.y)
                .gesture(cfg.tutorialEditMode ? DragGesture()
                    .onChanged { v in
                        if circleDragStart == nil {
                            circleDragStart = CGSize(width: c.x, height: c.y)
                        }
                        cfg.tutCircles[index].x = (circleDragStart?.width ?? 0) + v.translation.width
                        cfg.tutCircles[index].y = (circleDragStart?.height ?? 0) + v.translation.height
                    }
                    .onEnded { _ in circleDragStart = nil } : nil)
                .allowsHitTesting(cfg.tutorialEditMode)
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


// MARK: - 🎓 Tutorial layout editor (July 4, 2026 — debug menu sheet)
//
// Sliders for everything the overlay reads from the layout config, plus the
// EDIT MODE toggle that makes the tutorial card draggable in place. Start
// the tutorial (pause menu → Tutorial) with edit mode on to position live.

struct PotionShopTutorialLayoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var cfg = PotionShopLayoutConfig.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("✋ Edit mode (drag the card in-game)", isOn: $cfg.tutorialEditMode)
                    Text("Turn this ON, then start the tutorial (pause menu → Tutorial). Drag the text card where you want it — each step remembers its own spot. Values land in the sliders below.")
                        .font(.caption).foregroundColor(.secondary)
                }
                Section("Screen fade (dim)") {
                    row("Watch steps (1–3)", $cfg.tutDimWatch, 0...0.95, step: 0.05, decimals: 2)
                    row("Do-it step (4)", $cfg.tutDimDoIt, 0...0.95, step: 0.05, decimals: 2)
                }
                ForEach(0..<4, id: \.self) { i in
                    Section("Card · step \(i + 1)") {
                        row("X", $cfg.tutCardOffsetX[i], -200...200)
                        row("Y", $cfg.tutCardOffsetY[i], -300...300)
                    }
                }
                Section("Card size") {
                    row("Max width", $cfg.tutCardMaxWidth, 220...420)
                }
                // JULY 4 (evening 3): the dotted circles are a LIST — add
                // as many as you want, each pinned to a step. Positions are
                // offsets from SCREEN CENTER. With edit mode on, drag them
                // live in-game.
                ForEach(Array(cfg.tutCircles.enumerated()), id: \.element.id) { pair in
                    Section("Dotted circle \(pair.offset + 1)") {
                        Picker("Shows on step", selection: $cfg.tutCircles[pair.offset].step) {
                            ForEach(0..<4, id: \.self) { Text("Step \($0 + 1)").tag($0) }
                        }
                        row("X (from center)", $cfg.tutCircles[pair.offset].x, -220...220)
                        row("Y (from center)", $cfg.tutCircles[pair.offset].y, -420...420)
                        row("Size", $cfg.tutCircles[pair.offset].size, 30...220)
                        row("Line width", $cfg.tutCircles[pair.offset].lineWidth, 1...10, step: 0.5, decimals: 1)
                        Button(role: .destructive) {
                            cfg.tutCircles.remove(at: pair.offset)
                        } label: {
                            Label("Remove this circle", systemImage: "trash")
                        }
                    }
                }
                Section {
                    Button {
                        cfg.tutCircles.append(PotionShopLayoutConfig.TutorialCircle())
                    } label: {
                        Label("➕ Add a dotted circle", systemImage: "plus.circle")
                    }
                }
                Section {
                    Button(role: .destructive) {
                        cfg.resetTutorialLayout()
                    } label: {
                        Label("Reset tutorial layout", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("🎓 Tutorial Layout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }

    @ViewBuilder
    private func row(_ title: String, _ value: Binding<Double>,
                     _ range: ClosedRange<Double>, step: Double = 1, decimals: Int = 0) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title); Spacer()
                Text(String(format: "%.\(decimals)f", value.wrappedValue))
                    .foregroundColor(.secondary).monospacedDigit()
            }
            Slider(value: value, in: range, step: step)
        }
    }
}
