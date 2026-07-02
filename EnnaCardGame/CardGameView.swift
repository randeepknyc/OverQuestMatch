// CardGameView.swift
// All UI for the Enna card game.
// You don't need to edit this file — edit CardDatabase.swift for content.
//
// ART HOOKUP GUIDE:
//   Background images: add "enna_bg_act1", "enna_bg_act2", "enna_bg_act3" to Assets.xcassets
//   Character images:  add names matching characterImageName in CardDatabase.swift
//   All images fall back gracefully if not found

import SwiftUI

// ============================================================
// ROOT ENTRY VIEW
// ============================================================
struct CardGameView: View {
    @State private var viewModel = CardGameViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var showDebugMenu: Bool = false

    /// When true, restores from a saved session on appear.
    var continueFromSave: Bool = false

    var body: some View {
        ZStack {
            // Background
            CardGameBackground(act: viewModel.currentAct)

            if viewModel.isGameOver {
                CardEndingView(message: viewModel.gameOverMessage) {
                    viewModel.restart()
                }
            } else {
                VStack(spacing: 0) {
                    // Meter panel — top of screen
                    CardMeterPanel(viewModel: viewModel)
                        .padding(.top, 54)
                        .padding(.horizontal, 14)

                    Spacer()

                    // Swipeable card — center
                    if let card = viewModel.currentCard {
                        SwipeCardView(
                            card: card,
                            onSwipeLeft:  { viewModel.chooseLeft() },
                            onSwipeRight: { viewModel.chooseRight() }
                        )
                        .id(card.id)   // forces re-render on new card
                        .transition(.asymmetric(
                            insertion:  .opacity.combined(with: .scale(scale: 0.95)),
                            removal:    .opacity
                        ))
                    }

                    Spacer()

                    // Act indicator — bottom
                    CardActIndicator(act: viewModel.currentAct, cardsPlayed: viewModel.cardsPlayedCount)
                        .padding(.bottom, 36)
                }
            }

            // Threshold message overlay
            if viewModel.showThresholdMessage {
                CardThresholdOverlay(message: viewModel.thresholdMessage) {
                    viewModel.showThresholdMessage = false
                }
            }

            // Act unlock overlay
            if viewModel.showActUnlock, let act = viewModel.actJustUnlocked {
                CardActUnlockOverlay(act: act) {
                    viewModel.showActUnlock = false
                }
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            CardGameDebugButton {
                showDebugMenu = true
            }
            .padding(.top, 14)
            .padding(.trailing, 14)
        }
        .sheet(isPresented: $showDebugMenu) {
            CardGameDebugMenu(
                isPresented: $showDebugMenu,
                onEndGame: { dismiss() },
                viewModel: viewModel
            )
        }
        .onAppear {
            if continueFromSave, let save = CardGameSave.load() {
                save.restore(into: viewModel)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background && !viewModel.isGameOver {
                CardGameSave.save(vm: viewModel)
            }
        }
    }
}

// ============================================================
// DEBUG WRENCH BUTTON (top-right corner)
// ============================================================
struct CardGameDebugButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "wrench.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.55))
                        .overlay(
                            Circle()
                                .stroke(
                                    Color(red: 1.0, green: 0.78, blue: 0.38).opacity(0.35),
                                    lineWidth: 1
                                )
                        )
                )
        }
    }
}

// ============================================================
// DEBUG MENU SHEET
// Matches the pattern used by Potion Shop and Shop of Oddities:
//   - NavigationStack + List with sections
//   - End Game button dismisses sheet, then calls onEndGame()
//     which dismisses the parent fullScreenCover (back to selector)
// ============================================================
struct CardGameDebugMenu: View {
    @Binding var isPresented: Bool
    let onEndGame: () -> Void
    let viewModel: CardGameViewModel

    var body: some View {
        NavigationStack {
            List {
                // ─── Current State ─────────────────────────────────
                Section("Current State") {
                    debugRow("Act", "\(viewModel.currentAct) of 3")
                    debugRow("Cards Played", "\(viewModel.cardsPlayedCount)")
                    if let card = viewModel.currentCard {
                        debugRow("Current Card", card.id)
                    } else {
                        debugRow("Current Card", "—")
                    }
                    debugRow(
                        "Game Over",
                        viewModel.isGameOver ? "Yes" : "No"
                    )
                }

                // ─── Meters: Act 1 ─────────────────────────────────
                Section("Act 1 — Enna Personal") {
                    ForEach(viewModel.metersForAct(1), id: \.rawValue) { meter in
                        meterRow(meter)
                    }
                }

                // ─── Meters: Act 2 ─────────────────────────────────
                if viewModel.currentAct >= 2 {
                    Section("Act 2 — Tavern Vitals") {
                        ForEach(viewModel.metersForAct(2), id: \.rawValue) { meter in
                            meterRow(meter)
                        }
                    }
                }

                // ─── Meters: Act 3 ─────────────────────────────────
                if viewModel.currentAct >= 3 {
                    Section("Act 3 — Factions") {
                        ForEach(viewModel.metersForAct(3), id: \.rawValue) { meter in
                            meterRow(meter)
                        }
                    }
                }

                // ─── Exit ──────────────────────────────────────────
                Section {
                    Button {
                        isPresented = false
                        onEndGame()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                .foregroundColor(.red)
                            Text("End Game (back to selector)")
                                .foregroundColor(.red)
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                }
            }
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func debugRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
        }
    }

    private func meterRow(_ meter: MeterType) -> some View {
        HStack {
            Image(systemName: meter.icon)
                .foregroundColor(meter.color)
                .frame(width: 22)
            Text(meter.rawValue)
                .foregroundColor(.primary)
            Spacer()
            Text("\(viewModel.meterValue(for: meter)) / 100")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

// ============================================================
// BACKGROUND
// Looks for enna_bg_act1 / act2 / act3 in Assets.xcassets.
// Falls back to a mood-appropriate gradient.
// ============================================================
struct CardGameBackground: View {
    let act: Int

    var imageName: String { "enna_bg_act\(act)" }

    var fallback: LinearGradient {
        switch act {
        case 2:  return LinearGradient(colors: [Color(red:0.06, green:0.10, blue:0.16), Color(red:0.14, green:0.20, blue:0.30)], startPoint: .top, endPoint: .bottom)
        case 3:  return LinearGradient(colors: [Color(red:0.10, green:0.05, blue:0.16), Color(red:0.20, green:0.10, blue:0.30)], startPoint: .top, endPoint: .bottom)
        default: return LinearGradient(colors: [Color(red:0.10, green:0.06, blue:0.03), Color(red:0.22, green:0.13, blue:0.06)], startPoint: .top, endPoint: .bottom)
        }
    }

    var body: some View {
        Group {
            if UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                fallback
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 1.2), value: act)
    }
}

// ============================================================
// METER PANEL
// ============================================================
struct CardMeterPanel: View {
    let viewModel: CardGameViewModel

    var body: some View {
        VStack(spacing: 6) {
            CardMeterRow(meters: viewModel.metersForAct(1), viewModel: viewModel)

            if viewModel.currentAct >= 2 {
                Divider().background(Color.white.opacity(0.15))
                CardMeterRow(meters: viewModel.metersForAct(2), viewModel: viewModel)
            }

            if viewModel.currentAct >= 3 {
                Divider().background(Color.white.opacity(0.15))
                CardMeterRow(meters: viewModel.metersForAct(3), viewModel: viewModel)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct CardMeterRow: View {
    let meters: [MeterType]
    let viewModel: CardGameViewModel

    var body: some View {
        HStack(spacing: 10) {
            ForEach(meters, id: \.rawValue) { meter in
                CardMeterItem(meter: meter, value: viewModel.meterValue(for: meter))
            }
        }
    }
}

struct CardMeterItem: View {
    let meter: MeterType
    let value: Int

    private var isLow:  Bool { value <= 20 }
    private var isHigh: Bool { value >= 80 }

    private var displayColor: Color {
        if isLow { return .red }
        return meter.color
    }

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: meter.icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isLow ? .red : .white.opacity(0.75))
                .animation(.easeInOut, value: isLow)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(displayColor)
                        .frame(width: max(2, geo.size.width * CGFloat(value) / 100), height: 3)
                }
            }
            .frame(height: 3)
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.35), value: value)
    }
}

// ============================================================
// SWIPEABLE CARD
// ============================================================
struct SwipeCardView: View {
    let card: Card
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void

    @State private var dragX:        CGFloat = 0
    @State private var isDragging:   Bool    = false

    private let swipeThreshold: CGFloat = 85

    private var rotation: Double { Double(dragX / 20) }
    private var leftOpacity:  Double { dragX < 0 ? min(1, Double(-dragX / swipeThreshold) * 1.4) : 0 }
    private var rightOpacity: Double { dragX > 0 ? min(1, Double( dragX / swipeThreshold) * 1.4) : 0 }

    var body: some View {
        ZStack {
            // Left choice pill — appears on right side when dragging left
            HStack {
                Spacer()
                CardChoicePill(text: card.leftChoice, isLeft: true)
                    .opacity(leftOpacity)
                    .padding(.trailing, 10)
            }

            // Right choice pill — appears on left side when dragging right
            HStack {
                CardChoicePill(text: card.rightChoice, isLeft: false)
                    .opacity(rightOpacity)
                    .padding(.leading, 10)
                Spacer()
            }

            // The card itself
            CardFaceView(card: card)
                .rotationEffect(.degrees(rotation), anchor: .bottom)
                .offset(x: dragX)
                .animation(isDragging ? .none : .spring(response: 0.45, dampingFraction: 0.72), value: dragX)
                .gesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { val in
                            isDragging = true
                            dragX = val.translation.width
                        }
                        .onEnded { val in
                            isDragging = false
                            let projected = val.predictedEndTranslation.width
                            if projected < -swipeThreshold || val.translation.width < -swipeThreshold {
                                flick(direction: -1)
                            } else if projected > swipeThreshold || val.translation.width > swipeThreshold {
                                flick(direction: 1)
                            } else {
                                dragX = 0  // snap back
                            }
                        }
                )
        }
        .padding(.horizontal, 26)
    }

    private func flick(direction: CGFloat) {
        withAnimation(.easeIn(duration: 0.22)) {
            dragX = direction * 520
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            dragX = 0
            if direction < 0 { onSwipeLeft() } else { onSwipeRight() }
        }
    }
}

// ============================================================
// CARD FACE
// ============================================================
struct CardFaceView: View {
    let card: Card

    var body: some View {
        ZStack(alignment: .bottom) {
            // ---- Portrait / placeholder ----
            Group {
                if let name = card.characterImageName, UIImage(named: name) != nil {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else {
                    CardPortraitPlaceholder(label: card.characterImageName)
                }
            }

            // ---- Text overlay ----
            VStack(alignment: .leading, spacing: 7) {
                Text(card.speaker)
                    .font(.custom("Georgia", size: 12))
                    .italic()
                    .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.48).opacity(0.9))

                Text(card.text)
                    .font(.custom("Georgia", size: 15))
                    .foregroundColor(.white)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.55), radius: 24, x: 0, y: 12)
    }
}

struct CardPortraitPlaceholder: View {
    let label: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red:0.14, green:0.09, blue:0.06), Color(red:0.28, green:0.18, blue:0.12)],
                startPoint: .top, endPoint: .bottom
            )
            VStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.white.opacity(0.12))
                if let name = label {
                    Text("art: \(name)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.18))
                }
            }
        }
    }
}

// ============================================================
// CHOICE PILL
// ============================================================
struct CardChoicePill: View {
    let text: String
    let isLeft: Bool

    var body: some View {
        Text(text)
            .font(.custom("Georgia", size: 13))
            .foregroundColor(.white)
            .multilineTextAlignment(isLeft ? .trailing : .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: 130)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isLeft
                          ? Color(red:0.55, green:0.10, blue:0.10).opacity(0.88)
                          : Color(red:0.10, green:0.42, blue:0.12).opacity(0.88))
            )
    }
}

// ============================================================
// ACT INDICATOR (BOTTOM)
// ============================================================
struct CardActIndicator: View {
    let act: Int
    let cardsPlayed: Int

    var actName: String {
        switch act {
        case 1:  return "Act I"
        case 2:  return "Act II — The Tavern"
        case 3:  return "Act III — The City"
        default: return "Act I"
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(actName)
                .font(.custom("Georgia", size: 11))
                .italic()
                .foregroundColor(.white.opacity(0.40))

            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { i in
                    Circle()
                        .fill(i <= act
                              ? Color(red:1.0, green:0.78, blue:0.38)
                              : Color.white.opacity(0.18))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .animation(.easeInOut, value: act)
    }
}

// ============================================================
// THRESHOLD MESSAGE OVERLAY
// ============================================================
struct CardThresholdOverlay: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.62)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 18) {
                Text(message)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 8)

                Text("Tap to continue")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.40))
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red:0.09, green:0.06, blue:0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red:1.0, green:0.78, blue:0.38).opacity(0.30), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 36)
        }
        .transition(.opacity)
    }
}

// ============================================================
// ACT UNLOCK OVERLAY
// Shown once when Act 2 or 3 first unlocks
// ============================================================
struct CardActUnlockOverlay: View {
    let act: Int
    let onDismiss: () -> Void

    var actTitle: String {
        act == 2 ? "Act II — The Tavern" : "Act III — The City"
    }

    var actDescription: String {
        act == 2
            ? "The tavern is now yours to manage. New responsibilities, new meters."
            : "The city has noticed you. Factions are moving. New pressures await."
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.80)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                Text(actTitle)
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(Color(red:1.0, green:0.78, blue:0.38))

                Text(actDescription)
                    .font(.custom("Georgia", size: 15))
                    .foregroundColor(.white.opacity(0.80))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 10)

                Text("Tap to continue")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.38))
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red:0.08, green:0.05, blue:0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(red:1.0, green:0.78, blue:0.38).opacity(0.35), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
        }
        .transition(.opacity)
    }
}

// ============================================================
// GAME OVER / ENDING VIEW
// ============================================================
struct CardEndingView: View {
    let message: String
    let onRestart: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.88).ignoresSafeArea()

            VStack(spacing: 26) {
                Text("The story ends here.")
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(Color(red:1.0, green:0.78, blue:0.38))

                Text(message)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.white.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 24)

                Button(action: onRestart) {
                    Text("Begin Again")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(Color(red:0.12, green:0.08, blue:0.04))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 11)
                                .fill(Color(red:1.0, green:0.78, blue:0.38))
                        )
                }
            }
            .padding(40)
        }
    }
}
