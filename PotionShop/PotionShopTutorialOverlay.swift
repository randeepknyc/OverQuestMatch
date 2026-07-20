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
// MARK: - Tutorial script (JULY 11, 2026 — full rebuild, user-authored copy)
//
// The tutorial is now DATA: one step per row. Each row = one dialog box.
// gate: .tap = tap/Next advances · .placePotency / .brew = the player must
// DO the thing. effect fires when the step appears. glow adds a pulsing
// green ring behind that step's dotted circles (the patience beat).
// Circles are still positioned in-app: editor drawer → 🎓 Tutorial,
// edit mode, ➕ Circle — exactly as before, per step.
// ✏️ ALL text below is the designer's copy — edit freely.

enum PotionShopTutGate { case tap, placePotency, brew, peek }   // JULY 13: peek = hold-to-inspect a tray die
enum PotionShopTutEffect { case none, cycleTOD, openProfile, closeProfile, flameMinusOne, flameAllOut, patienceOut }   // JULY 15: patienceOut = rings render EMPTY on this step

struct PotionShopTutStep {
    let title: String
    let body: String
    var gate: PotionShopTutGate = .tap
    var effect: PotionShopTutEffect = .none
    var glow: Bool = false
    var centered: Bool = false
    /// JULY 13: pulsing ring over this step's highlight frames (the
    /// "hold a die" beat) + a haptic tick when the step appears.
    var pulse: Bool = false
    /// JULY 12: SHAPED highlights — registry keys ("customer0", "brewSpoon").
    /// PNG elements re-render in their own silhouette above the dim with a
    /// glow; code-drawn elements get a glowing frame + a matching cutout.
    var highlights: [String] = []
}

enum PotionShopTutorialConstants {

    static let script: [PotionShopTutStep] = [
        PotionShopTutStep(title: "Welcome!",
            body: "Welcome to Ednar's Potion Shop! Your job is to help Ednar learn to be the best wizard by making potions, and keeping the shop open as long as possible.",
            centered: true),
        PotionShopTutStep(title: "The Shop Day",
            body: "The shop is open every day — Morning, Afternoon, Evening, and Night.",
            effect: .cycleTOD,
            highlights: ["todIcon"]),
        PotionShopTutStep(title: "Customers",
            body: "Customers arrive and ask for potions.",
            highlights: ["customer0", "customer1", "customer2"]),
        PotionShopTutStep(title: "The Order",
            body: "Each customer wants a potion comprised of a potency value.",
            highlights: ["hpBadge0", "hpBadge1", "hpBadge2"]),
        PotionShopTutStep(title: "Choosing Customers",
            body: "You can choose which customer to service by clicking their profile picture button.",
            highlights: ["profile0", "profile1", "profile2"]),
        PotionShopTutStep(title: "The Profile",
            body: "When you click the profile, you'll see the customer's Name.",
            effect: .openProfile,
            highlights: ["inspectName"]),
        PotionShopTutStep(title: "Traits",
            body: "Their trait value — some customers can be annoyed when you don't serve them and may yell at you.",
            highlights: ["inspectTrait"]),
        PotionShopTutStep(title: "Composure",
            body: "If they yell or get angry/annoyed with you, you'll lose composure. If your composure reaches 0 you'll have to close the shop, study up, and start over.",
            effect: .closeProfile,
            highlights: ["composureBar"]),
        PotionShopTutStep(title: "Patience",
            body: "Each customer also has a patience timer.",
            glow: true,
            highlights: ["profile0", "profile1", "profile2"]),
        PotionShopTutStep(title: "Patience Runs Out",
            body: "If their patience runs out before you can fulfill an order, the customer will leave and may damage you while leaving.",
            effect: .patienceOut),   // JULY 15: rings drain to EMPTY (visual only)
        // JULY 13, 2026: the PEEK beats — two new steps before Brewing
        // 101 (user's copy ✏️). Step 1: the whole tray revealed. Step 2:
        // one die pulses; the gate is the player actually performing the
        // 0.4s hold — the real peek card pops (that's the "dialog box"),
        // and releasing it advances into Brewing 101.
        PotionShopTutStep(title: "Your Dice",
            body: "These are your dice that you'll place in the cauldron.",
            highlights: ["dice.potency", "dice.heal", "dice.shield", "dice.boost", "dice.stability"]),
        PotionShopTutStep(title: "Inspect a Die",
            body: "Hold any die to inspect its property.",
            gate: .peek,
            pulse: true,
            highlights: ["die0"]),
        // JULY 14, 2026: the read-the-card beat. The card that just
        // popped STAYS OPEN (gs.tutHoldPeekOpen), gets its own highlight
        // hole, and the player taps to close it and continue — fixes the
        // "advances the instant the card pops" whiplash (user report).
        PotionShopTutStep(title: "The Die Card",
            body: "This card shows the die's faces — what each roll can do. Tap anywhere to continue.",
            highlights: ["peekCard", "peekedDie"]),   // JULY 15: die follows the player's pick
        PotionShopTutStep(title: "Brewing 101",
            body: "You create potions by taking potency dice…",
            highlights: ["dice.potency"]),
        PotionShopTutStep(title: "Into the Cauldron",
            body: "…and placing them into the cauldron.",
            gate: .placePotency,
            highlights: ["cauldron"]),
        PotionShopTutStep(title: "Live Preview",
            body: "You'll see the potion value decrease to their affected value.",
            highlights: ["hpBadge0"]),
        PotionShopTutStep(title: "Focus",
            body: "You have a certain amount of focus per turn that limits how many dice you can put into the cauldron.",
            highlights: ["focusPips"]),
        PotionShopTutStep(title: "Brew!",
            body: "Once you're ready to brew, select \"BREW\".",
            gate: .brew,
            highlights: ["brewSpoon"]),
        PotionShopTutStep(title: "The Yell",
            body: "The customer's potion value will go down. If you don't fulfill their order they may yell at you, signified by the !"),   // JULY 12: hpBadge0 reveal removed — the user's placed circles cover this beat
        PotionShopTutStep(title: "The Fire",
            body: "The cauldron cools with one flame going out every turn, more with strong brews.",   // JULY 17: per-brew decay rule
            effect: .flameMinusOne,
            highlights: ["fireRow"]),
        PotionShopTutStep(title: "Dead Fire",
            body: "When the fire goes out altogether your brews are halved for every turn til it's restored. Tend to the fire by using the Stability die!",
            effect: .flameAllOut,
            highlights: ["fireRow"]),
        PotionShopTutStep(title: "The Other Dice",
            body: "There are several other dice: Stability, which will restore fire; Boost, will add a boost value to your brew and indicate which spaces are affected; Heal, will heal this many composure, Shield, will add to your composure,  .",
            highlights: ["dice.heal", "dice.shield", "dice.boost", "dice.stability"]),   // JULY 12: stability joins — all four non-potency dice light up
        PotionShopTutStep(title: "",
            body: "LET'S GET BREWING!",
            centered: true),   // JULY 12 rev 2: plain TAP — straight to Day 1 (the step-15 brew already spent the dice)
    ]

    /// JULY 12: the finale card after the final brew. ✏️
    static let finaleBody = "Let's Open the Shop!"

    /// Shown over the first boon offer after the tutorial round. ✏️
    static let boonTipBody = "Every round, you'll be presented with some boons — choose to upgrade your dice, or build bonuses to each round."

    // ── Scripted opening hand (unchanged from the 4-step tutorial) ────
    static let scriptedHand: [(type: PotionShopDieType, value: Int)] = [
        (.potency,  2),
        (.potency,  2),
        (.heal,     2),
        (.potency,  2),
        (.shield,   1),
    ]

    // ── Visual timing ────────────────────────────────────────────
    static let boilCircleDuration: Double = 0.8
    static let boilPulseMin: CGFloat = 0.97
    static let boilPulseMax: CGFloat = 1.03
    /// Seconds per time-of-day icon during the cycle beat.
    static let todCycleInterval: Double = 0.8
}

// MARK: - Tutorial state

@Observable
class PotionShopTutorialState {

    /// Whether the tutorial overlay is currently showing.
    var isActive: Bool = false

    /// Current step index. Reset to 0 when `isActive` is set true.
    var currentStep: Int = 0

    /// JULY 11, 2026: step count now derives from the SCRIPT — add a row
    /// to PotionShopTutorialConstants.script and everything follows.
    var stepCount: Int { PotionShopTutorialConstants.script.count }

    /// The current step's row (bounds-safe).
    var step: PotionShopTutStep {
        let s = PotionShopTutorialConstants.script
        return s[min(max(0, currentStep), s.count - 1)]
    }

    /// GameView advances the tutorial when the player brews during a
    /// brew-gated step (was "finish" in the 4-step version).
    var currentStepIsBrewStep: Bool { step.gate == .brew }

    /// JULY 11, 2026: true after completing (not skipping) the tutorial —
    /// GameView shows the boon explainer over the first boon offer.
    var pendingBoonTip: Bool = false

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
    /// JULY 12: true after the FINAL brew — swaps the card to the
    /// "Let's Open the Shop!" finale; tapping it starts the real Day 1.
    var showFinale: Bool = false

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
        showFinale = false
    }
}

// MARK: - Pulse ring (July 13, 2026)
//
// A soft, endlessly pulsing accent ring for pulse-flagged steps —
// draws attention to the die the player should hold. Fires one light
// haptic tick when it appears (the step's "look here" nudge).

struct PotionShopTutPulseRing: View {
    let size: CGFloat
    @State private var phase = false

    var body: some View {
        Circle()
            .stroke(PotionShopTheme.accent, lineWidth: 3)
            .frame(width: size, height: size)
            .scaleEffect(phase ? 1.12 : 0.94)
            .opacity(phase ? 0.35 : 0.95)
            .shadow(color: PotionShopTheme.accent.opacity(0.8), radius: phase ? 10 : 4)
            .onAppear {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                    phase = true
                }
            }
            .allowsHitTesting(false)
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
            // JULY 11, 2026 (rebuild) + JULY 12 SPOTLIGHT: the dim is now a
            // MASK — every dotted circle on the current step punches a HOLE
            // through it, so the element underneath shows at FULL brightness.
            // That's the highlight: position a circle over anything (drag in
            // edit mode / sliders in drawer → 🎓 Tutorial) and it spotlights.
            // .tap steps block the game (tap anywhere advances); practice
            // gates (.placePotency / .brew) leave the game interactive.
            // JULY 12 ALIGNMENT FIX: ignoresSafeArea lives on the COLOR only.
            // The ZStack (and therefore the holes) now shares the safe-area
            // coordinate space the dotted rings use — holes and rings align
            // exactly. The color still floods the whole screen.
            ZStack {
                Color.black.opacity(dimOpacity)
                    .ignoresSafeArea()
                ForEach(Array(cfg.tutCircles.enumerated()), id: \.element.id) { pair in
                    if pair.element.step == step {
                        Circle()
                            .fill(Color.black)
                            .frame(width: pair.element.size, height: pair.element.size)
                            .offset(x: pair.element.x, y: pair.element.y)
                            .blendMode(.destinationOut)
                    }
                }
                // JULY 12: MANUAL reveal rects (user-added via ➕ Reveal).
                ForEach(cfg.tutManualReveals) { r in
                    if r.step == step {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(width: r.w, height: r.h)
                            .offset(x: r.x, y: r.y)
                            .blendMode(.destinationOut)
                    }
                }
                // JULY 12: frame-style shaped highlights (code-drawn
                // elements like the brew sign) punch matching holes.
                GeometryReader { mg in
                    let o = mg.frame(in: .global).origin
                    ForEach(matchedHighlights(tutorial.step.highlights), id: \.0) { _, h in
                        // reveal → clean hole · underline → padded hole ·
                        // shaped w/o image → ring's hole. Shaped PNGs re-draw
                        // above instead, no hole needed.
                        if h.style == .reveal || h.style == .underline || h.image == nil {
                            let pad: CGFloat = h.style == .underline ? 24 : 10
                            RoundedRectangle(cornerRadius: h.clipCircle ? (h.frame.width + pad) / 2 : 12)
                                .fill(Color.black)
                                .frame(width: h.frame.width + pad, height: h.frame.height + pad)
                                .position(x: h.frame.midX - o.x, y: h.frame.midY - o.y)
                                .blendMode(.destinationOut)
                        }
                    }
                }
            }
            .compositingGroup()
            .animation(nil, value: tutorial.currentStep)   // JULY 12: holes SNAP too
            .allowsHitTesting(tutorial.step.gate == .tap)
            .onTapGesture {
                if tutorial.step.gate == .tap, !cfg.tutorialEditMode {
                    if tutorial.currentStep == tutorial.stepCount - 1 {
                        completeTutorial()
                    } else {
                        advanceWithAnimation()
                    }
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
                    // JULY 11: glow steps (patience beat) pulse a hard
                    // green ring UNDER the dotted circle.
                    if tutorial.step.glow {
                        Circle()
                            .stroke(Color.green.opacity(0.9), lineWidth: 5)
                            .frame(width: cfg.tutCircles[pair.offset].size * boilPulse,
                                   height: cfg.tutCircles[pair.offset].size * boilPulse)
                            .blur(radius: 4)
                            .offset(x: cfg.tutCircles[pair.offset].x,
                                    y: cfg.tutCircles[pair.offset].y)
                            .allowsHitTesting(false)
                    }
                    dottedCircle(index: pair.offset)
                }
            }

            // ── JULY 12: SHAPED HIGHLIGHTS — re-render published elements
            // above the dim. PNGs glow in their own silhouette; code-drawn
            // frames get a glowing ring over their cutout.
            GeometryReader { geo in
                let o = geo.frame(in: .global).origin
                ForEach(matchedHighlights(tutorial.step.highlights), id: \.0) { _, h in
                    switch h.style {
                    case .shaped:
                        shapedHighlight(h)
                            .position(x: h.frame.midX - o.x, y: h.frame.midY - o.y)
                    case .underline:
                        Capsule()
                            .fill(PotionShopTheme.accent)
                            .frame(width: h.frame.width + 8, height: 4)
                            .position(x: h.frame.midX - o.x, y: h.frame.maxY - o.y + 7)
                            .shadow(color: PotionShopTheme.accent.opacity(0.8), radius: 6)
                    case .reveal:
                        // JULY 13: pulse steps draw an animated ring over
                        // the revealed element (the "hold this die" beat).
                        if tutorial.step.pulse {
                            PotionShopTutPulseRing(size: max(h.frame.width, h.frame.height) + 14)
                                .position(x: h.frame.midX - o.x, y: h.frame.midY - o.y)
                        } else {
                            EmptyView()   // the hole IS the highlight
                        }
                    }
                }
            }
            .allowsHitTesting(false)
            .animation(nil, value: tutorial.currentStep)   // JULY 12: SNAP between steps — no lingering glow/crossfade

            // ── JULY 12: FINALE — after the final brew, tap anywhere to
            // end the tutorial and open the shop (real Day 1).
            // ── JULY 14, 2026: 👻 GHOST-DRAG HINT for "Into the Cauldron"
            // — a translucent potency die loops from the tray to the
            // cauldron until the player performs the real drag (the
            // placement gate advances the step, which removes this
            // automatically). Frames come live from the highlight
            // registry, so it tracks the real die/cauldron positions.
            if tutorial.step.gate == .placePotency {
                GeometryReader { geo in
                    let o = geo.frame(in: .global).origin
                    // JULY 15: LEFTMOST potency die (dictionary order was
                    // random — the ghost kept starting on die #2) + the
                    // drawer's endpoint nudges (🎓 tab, bakeable).
                    let dieEntry = gs.tutHighlights.values
                        .filter { $0.group == "dice.potency" }
                        .min(by: { $0.frame.minX < $1.frame.minX })
                    let potEntry = gs.tutHighlights["cauldron"]
                    if let die = dieEntry, let pot = potEntry {
                        // JULY 15 (rev 2): RAW anchors only — the drawer's
                        // nudges are now read LIVE inside the ghost's
                        // per-frame loop (see PotionShopTutGhostDrag), so
                        // slider changes apply instantly, immune to any
                        // observation gaps in this giant body.
                        PotionShopTutGhostDrag(
                            from: CGPoint(x: die.frame.midX - o.x,
                                          y: die.frame.midY - o.y),
                            to: CGPoint(x: pot.frame.midX - o.x,
                                        y: pot.frame.minY - o.y + pot.frame.height * 0.38),
                            size: max(40, die.frame.width * 0.9))
                    }
                }
                .allowsHitTesting(false)
                .zIndex(85)
            }

            if tutorial.showFinale {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { completeTutorial() }
                    .zIndex(90)
            }

            // ── JULY 12: EDIT MODE — cyan outline on every live highlight
            // frame for the current step, labeled, so positioning is visual.
            if cfg.tutorialEditMode {
                GeometryReader { geo in
                    let o = geo.frame(in: .global).origin
                    ForEach(matchedHighlights(tutorial.step.highlights), id: \.0) { key, h in
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.cyan, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                            .frame(width: h.frame.width, height: h.frame.height)
                            .overlay(alignment: .top) {
                                Text(key)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.cyan)
                                    .padding(2)
                                    .background(Color.black.opacity(0.7))
                                    .offset(y: -14)
                            }
                            .position(x: h.frame.midX - o.x, y: h.frame.midY - o.y)
                    }
                }
                .allowsHitTesting(false)
                .zIndex(70)
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
                if tutorial.step.centered {
                    Spacer()
                    tutorialCard(title: cardTitle,
                                 body: cardBody,
                                 showNext: cardShowNext)
                    Spacer()
                } else {
                    Spacer().frame(height: 60)
                    tutorialCard(title: cardTitle,
                                 body: cardBody,
                                 showNext: cardShowNext)
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
            cfg.ensureTutArrays(stepCount: tutorial.stepCount)   // JULY 12: 20-step arrays
            animateCardIn()
            applyStepEffect()
        }
        .onChange(of: tutorial.currentStep) { oldStep, newStep in
            animateCardIn()
            if cfg.tutCircles.contains(where: { $0.step == newStep }) {
                startBoilAnimation()
            }
            // Leaving the dead-fire beat relights the hearth.
            let script = PotionShopTutorialConstants.script
            if oldStep < script.count, script[oldStep].effect == .flameAllOut {
                withAnimation { gs.fire = PotionShopConfig.maxFire }
            }
            applyStepEffect()
        }
        // Circles on step 1 need the draw animation at first appearance too.
        .onAppear {
            if cfg.tutCircles.contains(where: { $0.step == tutorial.currentStep }) {
                startBoilAnimation()
            }
        }
        // ── JULY 11: practice gate — placing the potency die advances.
        // (Fallback: if the dealt hand somehow has no potency, ANY
        // placement advances so the tutorial can't dead-end.)
        // ── JULY 13: peek gate — completing a hold-to-peek (card shown,
        // finger released) advances the "Inspect a Die" step.
        .onChange(of: gs.totalPeeks) { _, _ in
            if tutorial.step.gate == .peek {
                advanceWithAnimation()
            }
        }
        // JULY 14: hold the peek card open exactly while "The Die Card"
        // step is showing (and never leak the flag past the tutorial).
        .onChange(of: tutorial.currentStep) { _, _ in
            gs.tutHoldPeekOpen = tutorial.isActive
                && tutorial.step.highlights.contains("peekCard")
            // JULY 15: "Patience Runs Out" shows every ring EMPTY.
            gs.tutorialPatienceEmpty = tutorial.isActive
                && tutorial.step.effect == .patienceOut
        }
        .onDisappear {
            gs.tutHoldPeekOpen = false
            gs.tutorialPatienceEmpty = false
        }
        .onChange(of: gs.placements.count) { _, count in
            guard tutorial.step.gate == .placePotency, count > 0 else { return }
            let placedPotency = gs.placements.values.contains { $0.type == .potency }
            let handHasPotency = gs.hand.contains { $0.type == .potency } || placedPotency
            if placedPotency || !handHasPotency {
                advanceWithAnimation()
            }
        }
        // ── JULY 11: time-of-day cycle beat — loops the header icon
        // while its step is showing; clears the override on leave/skip.
        .task(id: tutorial.currentStep) {
            guard tutorial.step.effect == .cycleTOD else {
                gs.tutorialTODOverride = nil
                return
            }
            var i = 0
            while !Task.isCancelled && tutorial.step.effect == .cycleTOD && tutorial.isActive {
                gs.tutorialTODOverride = i % 4
                i += 1
                try? await Task.sleep(nanoseconds: UInt64(PotionShopTutorialConstants.todCycleInterval * 1_000_000_000))
            }
            gs.tutorialTODOverride = nil
        }
        // ── JULY 11: skip/finish cleanup — undo any scripted state.
        // JULY 12 (rev 3): exit cleanup MOVED to GameView — this view is
        // unmounted the same frame isActive flips, so an onChange here
        // never fires. (That was the "overlay off, same customers" bug.)
    }

    // ── JULY 12: highlight matching — a script key matches an entry's
    // own key OR its group ("dice.potency" lights every potency die).
    private func matchedHighlights(_ keys: [String]) -> [(String, PotionShopTutHighlight)] {
        guard !keys.isEmpty else { return [] }
        var out: [(String, PotionShopTutHighlight)] = []
        for (k, h) in gs.tutHighlights {
            if keys.contains(k) || (h.group.map { keys.contains($0) } ?? false) {
                // JULY 12: apply the drawer's per-spot nudge (group members
                // share their GROUP's nudge, so "dice.potency" moves as one).
                var adjusted = h
                let nudgeKey = (h.group.map { keys.contains($0) } ?? false) ? (h.group ?? k) : k
                let n = cfg.tutNudge(for: nudgeKey)
                adjusted.frame = CGRect(x: h.frame.origin.x + n.dx - n.dw / 2,
                                        y: h.frame.origin.y + n.dy - n.dh / 2,
                                        width: max(4, h.frame.width + n.dw),
                                        height: max(4, h.frame.height + n.dh))
                out.append((k, adjusted))
            }
        }
        return out.sorted { $0.0 < $1.0 }
    }

    // ── JULY 12: shaped-highlight renderer ───────────────────────────
    @ViewBuilder
    private func shapedHighlight(_ h: PotionShopTutHighlight) -> some View {
        if let name = h.image,
           let ui = PotionShopImageLoader.loadDisplayImage(named: name, displaySize: max(h.frame.width, h.frame.height)) {
            // The PNG itself, stretched to its exact visual rect (matching
            // the scene's non-uniform scaleEffect), glowing in silhouette.
            // Circular elements (profile portraits) re-clip to their ring.
            // JULY 12: NO GLOW — the re-render IS the highlight: the element
            // at 0% dim in its own silhouette.
            Image(uiImage: ui)
                .resizable()
                .frame(width: h.frame.width, height: h.frame.height)
                .clipShape(PotionShopTutClip(circle: h.clipCircle))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .stroke(PotionShopTheme.accent, lineWidth: 3)
                .frame(width: h.frame.width + 10, height: h.frame.height + 10)
                .shadow(color: PotionShopTheme.accent.opacity(0.8), radius: 10)
        }
    }

    // ── JULY 11: step-entry effects (the scripted moments) ──────────
    private func applyStepEffect() {
        switch tutorial.step.effect {
        case .none, .cycleTOD, .patienceOut:
            break   // cycleTOD runs in the .task above; patienceOut is
                    // handled by the onChange(currentStep) sync (JULY 15)
        case .openProfile:
            withAnimation { gs.inspectedId = gs.customers.first?.id }
        case .closeProfile:
            withAnimation { gs.inspectedId = nil }
        case .flameMinusOne:
            withAnimation { gs.fire = max(0, gs.fire - 1) }
        case .flameAllOut:
            withAnimation { gs.fire = 0 }
        }
    }

    // ── JULY 11: final-step completion — the real round continues,
    // and the first boon offer gets the explainer + a rigged upgrade.
    // JULY 12 (§74.8): card content EXTRACTED — ternaries inside the huge
    // body blew up the type-checker. Plain properties keep it instant.
    private var cardTitle: String {
        tutorial.showFinale ? "" : tutorial.step.title
    }
    private var cardBody: String {
        tutorial.showFinale ? PotionShopTutorialConstants.finaleBody : tutorial.step.body
    }
    private var cardShowNext: Bool {
        tutorial.showFinale || tutorial.step.gate == .tap
    }

    /// JULY 13: the dim per gate (extracted — §74.8). PEEK steps run
    /// UNDIMMED: the hold-to-peek card renders inside the GAME layer,
    /// underneath this overlay, so any dim would grey the very card the
    /// step teaches. The pulse ring carries the attention instead.
    private var dimOpacity: Double {
        switch tutorial.step.gate {
        case .tap:  return cfg.tutDimWatch
        case .peek: return 0
        default:    return cfg.tutDimDoIt
        }
    }

    /// JULY 13: per-gate hint line under the card (extracted — §74.8:
    /// no growing ternaries inside view bodies). ✏️ copy.
    private var gateHint: String {
        switch tutorial.step.gate {
        case .brew:         return "Tap BREW when ready"
        case .placePotency: return "Drag the red potency die onto the cauldron"
        case .peek:         return "Hold a die until its card appears"
        case .tap:          return ""
        }
    }

    private func completeTutorial() {
        gs.rigNextBoonOffer = true
        tutorial.pendingBoonTip = true
        tutorial.finish()
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
                // Practice-gate hint (no Next — the ACTION advances)
                Text(gateHint)
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
        .offset(x: cfg.tutCardOffsetX[min(tutorial.currentStep, cfg.tutCardOffsetX.count - 1)],
                y: cfg.tutCardOffsetY[min(tutorial.currentStep, cfg.tutCardOffsetY.count - 1)])
        .gesture(cfg.tutorialEditMode ? DragGesture()
            .onChanged { v in
                let i = min(tutorial.currentStep, cfg.tutCardOffsetX.count - 1)
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


// MARK: - Boon explainer (July 11, 2026)
//
// Shown by GameView over the FIRST boon offer after the tutorial round
// (tutorial.pendingBoonTip). One tap anywhere on the card dismisses it —
// the boon cards stay interactive around it.

struct PotionShopTutorialBoonTip: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack {
            Spacer().frame(height: 70)
            VStack(spacing: 10) {
                Text("Boons!")
                    .font(Font.gameUI(size: 26))
                    .foregroundColor(.white)
                Text(PotionShopTutorialConstants.boonTipBody)
                    .font(Font.gameUI(size: 20))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text("(tap to dismiss)")
                    .font(Font.gameUI(size: 14))
                    .foregroundColor(.white.opacity(0.55))
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.85)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(PotionShopTheme.accent.opacity(0.6), lineWidth: 1.5))
            .padding(.horizontal, 40)
            .onTapGesture { withAnimation(.easeOut(duration: 0.2)) { onDismiss() } }
            Spacer()
        }
    }
}


// MARK: - Plain frame publisher (July 12, 2026)
//
// For layout-positioned elements (tray dice, profile buttons) and elements
// whose render offsets are known at the call site (HP badges — pass dx/dy).

struct PotionShopPlainFramePublisher: View {
    let gs: PotionShopGameState
    let key: String
    var image: String? = nil
    var group: String? = nil
    var clipCircle: Bool = false
    var style: PotionShopTutHighlightStyle = .shaped
    var dx: CGFloat = 0
    var dy: CGFloat = 0

    var body: some View {
        GeometryReader { g in
            Color.clear
                .onAppear { publish(g.frame(in: .global)) }
                .onChange(of: g.frame(in: .global)) { _, f in publish(f) }
                // JULY 12: a dying view TAKES ITS FRAME WITH IT — stale
                // entries were the "random hp icons" (defeated customers'
                // badges lingering in the registry).
                .onDisappear { gs.tutHighlights.removeValue(forKey: key) }
        }
    }

    private func publish(_ f: CGRect) {
        gs.publishTutHighlight(key, frame: f.offsetBy(dx: dx, dy: dy),
                               image: image, group: group, clipCircle: clipCircle, style: style)
    }
}


// JULY 12: conditional clip — circle for portraits, no-op rect otherwise.
struct PotionShopTutClip: Shape {
    let circle: Bool
    func path(in rect: CGRect) -> Path {
        circle ? Circle().path(in: rect) : Rectangle().path(in: rect)
    }
}


// MARK: - 👻 Ghost drag hint (July 14, 2026)
//
// A translucent potency die that loops: pause on the tray → glide into
// the cauldron → fade → repeat. Pure TimelineView math (no animation
// state), so it can't leak or stick; the layer only exists while the
// "Into the Cauldron" step is active.

struct PotionShopTutGhostDrag: View {
    let from: CGPoint
    let to: CGPoint
    let size: CGFloat

    var body: some View {
        TimelineView(.animation) { timeline in
            let loop: Double = 2.2
            let t = timeline.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: loop) / loop
            // phases: pause 0–0.12 · travel 0.12–0.78 · fade 0.78–0.95
            let travel = min(1.0, max(0.0, (t - 0.12) / 0.66))
            let eased = travel * travel * (3 - 2 * travel)   // smoothstep
            // JULY 15 (rev 2): endpoint nudges read PER FRAME from the
            // config — the 🎓 sliders move the ghost the instant they're
            // dragged (the old constructor-time reads could go stale).
            let c = PotionShopLayoutConfig.shared
            let fx = from.x + c.tutGhostFromX
            let fy = from.y + c.tutGhostFromY
            let tx = to.x + c.tutGhostToX
            let ty = to.y + c.tutGhostToY
            let x = fx + (tx - fx) * eased
            let y = fy + (ty - fy) * eased
            let alpha: Double = t < 0.78 ? 0.65
                : max(0, 0.65 * (1 - (t - 0.78) / 0.17))
            ghostDie
                .frame(width: size, height: size)
                .position(x: x, y: y)
                .opacity(alpha)
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var ghostDie: some View {
        if let img = PotionShopImageLoader.loadDisplayImage(named: "die_potency", displaySize: size) {
            Image(uiImage: img).resizable().scaledToFit()
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.75, green: 0.2, blue: 0.2).opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.6), lineWidth: 2))
        }
    }
}
