//
//  EnnasTavernPlayViews.swift
//  OverQuestMatch3 — Enna's Tavern (v4 — the OPERATING COSTS build)
//
//  The main play screen, laid out per the approved sketch (B):
//  hamburger + costs plaque · customer ↔ Enna with the need bubble ·
//  dice/cards · ROLL | skills+ledger | SERVE · the icon'd hand list.
//

import SwiftUI

// ============================================================
// SERVING SCREEN
// ============================================================
struct TavernServingScreen: View {
    var vm: EnnasTavernViewModel
    var onSkills: () -> Void
    var onServiceLog: () -> Void

    private var layout: TavernLayout { TavernLayout.shared }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TavernCustomerRow(vm: vm)
                    .padding(.top, 4)

                Spacer(minLength: 4)

                // The table — the big center stage, Kalma-style
                if vm.serveMode == .dice {
                    TavernDiceRow(vm: vm)
                        .frame(maxWidth: .infinity)
                        .frame(height: layout.diceHeight)
                } else {
                    TavernCardHandRow(vm: vm)
                        .frame(maxWidth: .infinity)
                        .frame(height: layout.diceHeight)
                }

                Spacer(minLength: 4)

                TavernActionRow(vm: vm, onSkills: onSkills, onServiceLog: onServiceLog)
                    .padding(.horizontal, layout.sideMargin)
                    .padding(.bottom, 10)

                // The menu — anchored to the bottom edge
                TavernHandList(vm: vm)
                    .padding(.horizontal, layout.sideMargin)
                    .padding(.bottom, 6)
            }

        }
    }
}

// ============================================================
// DIALOGUE — customer asks (top), Enna answers (below)
// ============================================================
struct TavernCustomerRow: View {
    var vm: EnnasTavernViewModel

    private var layout: TavernLayout { TavernLayout.shared }

    var body: some View {
        VStack(spacing: layout.dialogueGap) {
            // Customer: portrait left, bubble with the need icon
            HStack(alignment: .center, spacing: 8) {
                VStack(spacing: 3) {
                    TavernPortraitView(imageName: vm.currentPatron.imageName,
                                       fallbackName: vm.currentPatron.name, size: layout.portrait)
                    Text(vm.currentPatron.name)
                        .font(TavernFont.of(10))
                        .foregroundColor(TavernPalette.cream.opacity(0.7))
                        .lineLimit(1)
                }
                .frame(width: 72)

                TavernSpeechBubble(tailEdge: .leading) {
                    HStack(alignment: .center, spacing: 7) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(vm.customerNeed.tint)
                                .frame(width: 30, height: 30)
                            Image(systemName: vm.customerNeed.symbol)
                                .font(TavernFont.of(14))
                                .foregroundColor(.white)
                        }
                        Text("\u{201C}\(vm.showServeResultLine ? vm.reactionLine : vm.customerLine)\u{201D}")
                            .font(TavernFont.of(layout.bubbleFont))
                            .italic()
                            .foregroundColor(TavernPalette.wood)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: layout.custBubbleW, alignment: .leading)
                .offset(x: layout.custBubbleX)
            }

            // Enna: the LIVE SCORE — coins scroll, multipliers BANG, total banks
            HStack(alignment: .center, spacing: 8) {
                TavernScoreBoxes(vm: vm)
                    .frame(maxWidth: layout.ennaBubbleW, alignment: .trailing)
                    .offset(x: layout.ennaBubbleX)

                VStack(spacing: 3) {
                    TavernPortraitView(imageName: "ennatavern_portrait",
                                       fallbackName: "Enna", size: layout.portrait)
                    Text("Enna")
                        .font(TavernFont.of(10))
                        .foregroundColor(TavernPalette.cream.opacity(0.7))
                }
                .frame(width: 72)
            }
        }
        .padding(.horizontal, 12)
        .animation(.easeInOut(duration: 0.2), value: vm.currentPatronID)
    }
}

/// Cream speech bubble with a little tail on the leading or trailing edge.
struct TavernSpeechBubble<Content: View>: View {
    enum TailEdge { case leading, trailing }
    let tailEdge: TailEdge
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(TavernPalette.cream))
            .overlay(alignment: tailEdge == .leading ? .leading : .trailing) {
                TavernBubbleTail(pointsLeading: tailEdge == .leading)
                    .fill(TavernPalette.cream)
                    .frame(width: 10, height: 16)
                    .offset(x: tailEdge == .leading ? -9 : 9)
            }
    }
}

struct TavernBubbleTail: Shape {
    let pointsLeading: Bool
    func path(in rect: CGRect) -> Path {
        var p = Path()
        if pointsLeading {
            p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        } else {
            p.move(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        p.closeSubpath()
        return p
    }
}

// ============================================================
// ACTION ROW — ROLL | skills + service ledger | SERVE
// ============================================================
struct TavernActionRow: View {
    var vm: EnnasTavernViewModel
    var onSkills: () -> Void
    var onServiceLog: () -> Void
    private var layout: TavernLayout { TavernLayout.shared }

    var body: some View {
        HStack(spacing: 8) {
            // ROLL — spends 1 from the day's budget
            Button(action: { vm.rollAgain() }) {
                VStack(spacing: 4) {
                    Image(systemName: "dice.fill")
                        .font(TavernFont.of(17))
                    Text("ROLL (\(vm.rollsLeft))")
                        .font(TavernFont.of(layout.panelFont))
                }
                .foregroundColor(vm.canRoll ? TavernPalette.cream : TavernPalette.cream.opacity(0.3))
                .frame(maxWidth: .infinity, minHeight: layout.panelHeight)
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(vm.canRoll ? TavernPalette.woodLight : Color.black.opacity(0.25)))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(vm.canRoll ? TavernPalette.cream.opacity(0.35) : Color.clear, lineWidth: 1))
            }
            .disabled(!vm.canRoll)

            VStack(spacing: 5) {
                smallButton(icon: "graduationcap.fill", label: "Skills", action: onSkills)
                smallButton(icon: "book.fill", label: "Ledger", action: onServiceLog)
            }

            // SERVE — free, with a live match preview
            Button(action: { vm.serve() }) {
                VStack(spacing: 2) {
                    Text("SERVE")
                        .font(TavernFont.of(layout.panelFont))
                }
                .foregroundColor(vm.handLive ? TavernPalette.wood : TavernPalette.cream.opacity(0.3))
                .frame(maxWidth: .infinity, minHeight: layout.panelHeight)
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(vm.handLive
                          ? (vm.servePreviewMatched ? TavernPalette.green : TavernPalette.amber)
                          : Color.black.opacity(0.25)))
            }
            .disabled(!vm.handLive)
        }
    }


    private func smallButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .font(TavernFont.of(15))
                Text(label)
                    .font(TavernFont.of(TavernLayout.shared.menuFont))
            }
            .foregroundColor(TavernPalette.cream.opacity(0.75))
            .frame(width: layout.midBtnW, height: layout.midBtnH)
            .background(RoundedRectangle(cornerRadius: 9).fill(Color.black.opacity(0.35)))
            .overlay(RoundedRectangle(cornerRadius: 9)
                .stroke(TavernPalette.cream.opacity(0.2), lineWidth: 0.5))
        }
    }
}

// ============================================================
// THE HAND LIST — two columns, icon per dish (tap Skills to reassign)
// ============================================================
struct TavernHandList: View {
    var vm: EnnasTavernViewModel

    private var rows: [TavernRow] { vm.visibleRows }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                column(Array(rows.prefix((rows.count + 1) / 2)))
                column(Array(rows.suffix(rows.count / 2)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.32)))
    }

    private func column(_ list: [TavernRow]) -> some View {
        VStack(spacing: 0) {
            ForEach(list) { row in
                TavernHandRowLine(vm: vm, row: row)
                if row.id != list.last?.id {
                    Rectangle().fill(TavernPalette.cream.opacity(0.12)).frame(height: 0.5)
                }
            }
        }
    }
}

struct TavernHandRowLine: View {
    var vm: EnnasTavernViewModel
    let row: TavernRow
    private var layout: TavernLayout { TavernLayout.shared }

    private var qualifies: Bool { vm.qualifyingRows.contains(row.id) }
    private var isBest: Bool { vm.effectiveRow == row.id }
    private var isChosen: Bool { vm.chosenRow == row.id && qualifies }
    private var icon: TavernNeed { vm.rowIcon(row.id) }
    private var matched: Bool { icon == vm.customerNeed }

    var body: some View {
        HStack(spacing: 5) {
            Text(row.name + String(repeating: "↑", count: vm.rowLevels[row.id] ?? 0))
                .font(TavernFont.of(layout.menuFont))
                .foregroundColor(qualifies ? TavernPalette.cream : TavernPalette.cream.opacity(0.45))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Image(systemName: icon.symbol)
                .font(TavernFont.of(11))
                .foregroundColor(TavernPalette.cream.opacity(0.5))
            Spacer(minLength: 2)
            Text("×\(vm.rowMult(row.id))")
                .font(TavernFont.of(layout.menuFont + 1))
                .foregroundColor(isBest ? TavernPalette.amber
                                 : (qualifies ? TavernPalette.cream.opacity(0.85)
                                              : TavernPalette.cream.opacity(0.4)))
        }
        .padding(.vertical, layout.menuRowPad)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(isChosen ? TavernPalette.amber.opacity(0.16)
                      : (isBest && qualifies ? TavernPalette.cream.opacity(0.05) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(isChosen ? TavernPalette.amber : Color.clear, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture { vm.chooseRow(row.id) }
        .animation(.easeInOut(duration: 0.15), value: isChosen)
    }
}

// ============================================================
// DICE — the real 3D scene (EnnasTavernDiceScene.swift)
// ============================================================
struct TavernDiceRow: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        TavernDiceSceneView(
            dice: vm.dice,
            rollStamp: vm.rollStamp,
            rolledIDs: vm.lastRolledDieIDs,
            dieScale: Float(TavernLayout.shared.dieScale),
            dieGap: Float(TavernLayout.shared.dieGap),
            onTapDie: { vm.toggleSelect(die: $0) }
        )
    }
}

// ============================================================
// CARDS
// ============================================================
struct TavernCardHandRow: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        GeometryReader { geo in
            let layout = TavernLayout.shared
            let n = Double(max(1, vm.hand.count))
            let fitW = min(layout.cardW, (geo.size.width - 24 - layout.cardGap * (n - 1)) / n)
            let fitH = fitW * (layout.cardH / max(1, layout.cardW))
            HStack(spacing: layout.cardGap) {
                ForEach(vm.hand) { card in
                    TavernPlayingCardView(card: card, w: fitW, h: fitH)
                        .onTapGesture { vm.toggleSelect(card: card.id) }
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 12)
    }
}

struct TavernPlayingCardView: View {
    let card: TavernPlayingCard
    var w: Double? = nil
    var h: Double? = nil
    private var layout: TavernLayout { TavernLayout.shared }
    private var cw: Double { w ?? layout.cardW }
    private var ch: Double { h ?? layout.cardH }
    private var inkColor: Color {
        card.suit.isRed ? Color(red: 0.75, green: 0.15, blue: 0.15)
                        : Color(red: 0.1, green: 0.1, blue: 0.12)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
            VStack(spacing: 2) {
                HStack {
                    Text(card.rankLabel)
                        .font(TavernFont.of(cw * 0.27))
                        .foregroundColor(inkColor)
                    Spacer()
                }
                .padding(.horizontal, 5).padding(.top, 4)
                Spacer()
                Image(systemName: card.suit.symbolName)
                    .font(TavernFont.of(cw * 0.35))
                    .foregroundColor(inkColor)
                Spacer()
            }
        }
        .frame(width: cw, height: ch)
        .overlay(RoundedRectangle(cornerRadius: 9)
            .stroke(card.selected ? TavernPalette.amber : Color.clear, lineWidth: 3))
        .offset(y: card.selected ? -6 : 0)
        .animation(.spring(response: 0.25), value: card.selected)
    }
}

// ============================================================
// REACTION OVERLAY — matched vs merely accepted
// ============================================================
// ============================================================
// COLLECTIBLE OVERLAY (interlude endings — run continues)
// ============================================================
struct TavernCollectibleOverlay: View {
    let ending: TavernEnding
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.82).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("INTERLUDE DISCOVERED")
                    .font(TavernFont.of(12))
                    .foregroundColor(TavernPalette.amber).tracking(3)
                Text(ending.title)
                    .font(TavernFont.of(26))
                    .foregroundColor(TavernPalette.cream)
                    .multilineTextAlignment(.center).padding(.horizontal, 26)
                Text(ending.flavor)
                    .font(TavernFont.of(15)).italic()
                    .foregroundColor(TavernPalette.cream.opacity(0.85))
                    .multilineTextAlignment(.center).padding(.horizontal, 30)
                Text("Logged in the Ledger of Endings. The night goes on.")
                    .font(TavernFont.of(12))
                    .foregroundColor(TavernPalette.cream.opacity(0.5))
                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(TavernFont.of(15))
                        .foregroundColor(TavernPalette.wood)
                        .padding(.horizontal, 34).padding(.vertical, 13)
                        .background(Capsule().fill(TavernPalette.amber))
                }
                .padding(.top, 4)
            }
        }
        .transition(.opacity)
    }
}


// ============================================================
// 🔧 LAYOUT TUNER — drag sliders, watch the screen move.
// Values persist; RESET restores the factory layout.
// ============================================================
struct TavernLayoutTuner: View {
    var vm: EnnasTavernViewModel
    private var layout: TavernLayout { TavernLayout.shared }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("LAYOUT DEBUG · \(layout.activeProfile.uppercased())")
                    .font(TavernFont.of(11)).tracking(2)
                    .foregroundColor(TavernPalette.amber)
                Spacer()
                Button(action: { UIPasteboard.general.string = layout.exportString }) {
                    Text("COPY")
                        .font(TavernFont.of(11))
                        .foregroundColor(TavernPalette.green)
                }
                .padding(.trailing, 10)
                Button(action: { layout.reset() }) {
                    Text("RESET")
                        .font(TavernFont.of(11))
                        .foregroundColor(TavernPalette.red)
                }
            }
            // Which profile you're tuning — switches the table instantly
            HStack(spacing: 8) {
                Text("PROFILE")
                    .font(TavernFont.of(9)).tracking(2)
                    .foregroundColor(TavernPalette.cream.opacity(0.5))
                profileButton("DICE", mode: .dice)
                profileButton("CARDS", mode: .cards)
                Spacer()
            }
            ScrollView {
                VStack(spacing: 4) {
                    dial("Font scale ✒️",  \.fontScale,   0.5...2.0, decimals: true)
                    dial("Costs text",     \.costsFont,   12...70)
                    dial("Portraits",      \.portrait,    30...140)
                    dial("Bubble text",    \.bubbleFont,  8...26)
                    dial("Bubble gap",     \.dialogueGap, 0...40)
                    dial("Cust bubble X",  \.custBubbleX, -120...120)
                    dial("Cust bubble W",  \.custBubbleW, 120...430)
                    dial("Enna bubble X",  \.ennaBubbleX, -120...120)
                    dial("Enna bubble W",  \.ennaBubbleW, 120...430)
                    dial("Dice tray",      \.diceHeight,  80...450)
                    dial("Die size",       \.dieScale,    0.35...2.2, decimals: true)
                    dial("Die spacing",    \.dieGap,      0.5...2.4, decimals: true)
                    dial("Card width",     \.cardW,       36...120)
                    dial("Card height",    \.cardH,       50...160)
                    dial("Card gap",       \.cardGap,     0...24)
                    dial("Score box height",\.scoreBoxH,   34...110)
                    dial("Score box text", \.scoreBoxFont, 12...40)
                    dial("Roll/Serve",     \.panelHeight, 40...200)
                    dial("Button text",    \.panelFont,   10...36)
                    dial("Mid button W",   \.midBtnW,     28...140)
                    dial("Mid button H",   \.midBtnH,     20...100)
                    dial("Menu text",      \.menuFont,    8...24)
                    dial("Menu row height",\.menuRowPad,  1...28)
                    dial("Side margins",   \.sideMargin,  0...44)
                }
            }
            .frame(maxHeight: 250)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.88)))
        .padding(.horizontal, 10)
        .padding(.bottom, 4)
    }

    private func profileButton(_ label: String, mode: TavernPlayMode) -> some View {
        let on = (mode == .cards) == (layout.activeProfile == "cards")
        return Button(action: {
            TavernSettings.playMode = mode            // swaps the layout profile too
            vm.debugSwitchTable(to: mode == .dice ? .dice : .cards)
        }) {
            Text(label)
                .font(TavernFont.of(10))
                .foregroundColor(on ? TavernPalette.wood : TavernPalette.cream.opacity(0.7))
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(Capsule().fill(on ? TavernPalette.amber : Color.black.opacity(0.4)))
        }
    }

    private func dial(_ label: String,
                      _ key: ReferenceWritableKeyPath<TavernLayout, Double>,
                      _ range: ClosedRange<Double>,
                      decimals: Bool = false) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(TavernFont.of(11))
                .foregroundColor(TavernPalette.cream)
                .frame(width: 104, alignment: .leading)
            Slider(value: Binding(
                get: { TavernLayout.shared[keyPath: key] },
                set: { TavernLayout.shared[keyPath: key] = $0; TavernLayout.shared.persist() }
            ), in: range)
            .tint(TavernPalette.amber)
            Text(decimals ? String(format: "%.2f", TavernLayout.shared[keyPath: key])
                          : "\(Int(TavernLayout.shared[keyPath: key]))")
                .font(TavernFont.of(11))
                .foregroundColor(TavernPalette.amber)
                .frame(width: 38, alignment: .trailing)
        }
    }
}


// ============================================================
// 🎰 LIVE SCORE BOXES — Coins · ×Mult · Total. Preview while a
// hand is live; on serve, coins scroll, the mult BANGS per bonus,
// the total scrolls and banks. Tap to fast-forward the tally.
// ============================================================
struct TavernScoreBoxes: View {
    var vm: EnnasTavernViewModel
    private var layout: TavernLayout { TavernLayout.shared }

    var body: some View {
        // Explicit dependency reads — registers observation on every
        // source that should move these boxes: rolls, rerolls, taps,
        // selection changes, and the live tally.
        let _ = vm.rollStamp
        let _ = vm.dice
        let _ = vm.hand
        let _ = vm.chosenRow
        let _ = vm.handLive
        let _ = vm.scoringActive
        let _ = vm.scoreCoins
        let _ = vm.scoreMultDisplay
        let _ = vm.scoreTotal
        let values = currentValues()

        HStack(spacing: 7) {
            box("COINS") {
                TavernOdometerText(value: values.0, font: TavernFont.of(layout.scoreBoxFont),
                                   color: TavernPalette.cream)
            }
            box("MULT") {
                TavernPunchText(text: "×\(Int(values.1))", trigger: values.1,
                                font: TavernFont.of(layout.scoreBoxFont + 2),
                                color: values.1 == 0 ? TavernPalette.red : TavernPalette.amber)
            }
            box("TOTAL") {
                TavernOdometerText(value: values.2, font: TavernFont.of(layout.scoreBoxFont),
                                   color: vm.scoringActive ? TavernPalette.green : TavernPalette.cream)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if vm.scoringActive { vm.fastForwardScoring() } }
    }

    /// Idle = 0 · 0 · 0. The boxes only wake up when SERVE fires the tally.
    private func currentValues() -> (Int, Double, Int) {
        vm.scoringActive ? (vm.scoreCoins, vm.scoreMultDisplay, vm.scoreTotal) : (0, 0, 0)
    }

    private func box<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 1) {
            Text(label)
                .font(TavernFont.of(layout.menuFont - 2)).tracking(1.5)
                .foregroundColor(TavernPalette.cream.opacity(0.5))
            content()
        }
        .frame(maxWidth: .infinity, minHeight: layout.scoreBoxH)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.32)))
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(TavernPalette.cream.opacity(0.15), lineWidth: 0.5))
    }
}

/// BANG. Scales up hard on every change and springs back.
struct TavernPunchText: View {
    let text: String
    let trigger: Double
    let font: Font
    let color: Color
    @State private var punch = false

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .scaleEffect(punch ? 1.55 : 1.0)
            .onChange(of: trigger) { _, _ in
                punch = true
                withAnimation(.spring(response: 0.28, dampingFraction: 0.5)) { punch = false }
            }
    }
}
