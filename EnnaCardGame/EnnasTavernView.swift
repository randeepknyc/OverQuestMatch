//
//  EnnasTavernView.swift
//  OverQuestMatch3 — Enna's Tavern
//
//  The main container: routes between phases and hosts the flow screens.
//  The serving table lives in EnnasTavernPlayViews.swift.
//  The market & ledger live in EnnasTavernScreens.swift.
//

import SwiftUI

struct EnnasTavernView: View {

    let continueFromSave: Bool

    @State private var vm = EnnasTavernViewModel()
    @State private var didSetUp = false
    @State private var showLedger = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Tavern-wood background
            LinearGradient(
                colors: [TavernPalette.woodLight, TavernPalette.wood],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TavernTopBar(vm: vm, onExit: exitGame, onLedger: { showLedger = true })

                switch vm.phase {
                case .dayIntro:
                    TavernDayIntroScreen(vm: vm)
                case .modeSelect:
                    TavernModeSelectScreen(vm: vm)
                case .serving:
                    TavernServingScreen(vm: vm)
                case .dayResult:
                    TavernDayResultScreen(vm: vm)
                case .market:
                    TavernMarketScreen(vm: vm)
                case .promotion:
                    TavernEndingScreen(vm: vm, style: .promotion, onRestart: { vm.restart() }, onExit: exitGame)
                case .epilogue:
                    TavernEndingScreen(vm: vm, style: .victory, onRestart: { vm.restart() }, onExit: exitGame)
                case .gameOver:
                    TavernEndingScreen(vm: vm, style: .fail, onRestart: { vm.restart() }, onExit: exitGame)
                }
            }

            // ---- Overlays ----
            if vm.showReaction {
                TavernReactionOverlay(vm: vm)
            }
            if vm.showCollectible, let id = vm.pendingCollectibles.first,
               let ending = EnnasTavernDatabase.ending(id) {
                TavernCollectibleOverlay(ending: ending) { vm.dismissCollectible() }
            }
        }
        .sheet(isPresented: $showLedger) {
            TavernLedgerSheet()
        }
        .onAppear {
            guard !didSetUp else { return }
            didSetUp = true
            if continueFromSave, let save = EnnasTavernSave.load() {
                save.restore(into: vm)
            } else {
                EnnasTavernSave.deleteSave()
                vm.startRun()
            }
        }
    }

    private func exitGame() {
        // Mid-run: progress is already saved after every action.
        dismiss()
    }
}

// ============================================================
// TOP BAR — act/day, quota progress, coin, exit
// ============================================================
struct TavernTopBar: View {
    var vm: EnnasTavernViewModel
    var onExit: () -> Void
    var onLedger: () -> Void

    private var showProgress: Bool {
        vm.phase == .serving || vm.phase == .modeSelect || vm.phase == .dayResult
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("ACT \(vm.act) · DAY \(vm.day)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(TavernPalette.cream.opacity(0.8))

                Spacer()

                Button(action: onLedger) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(TavernPalette.cream.opacity(0.6))
                }

                HStack(spacing: 4) {
                    Text("🪙").font(.system(size: 14))
                    Text("\(vm.coin)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(TavernPalette.amber)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.black.opacity(0.3)))

                Button(action: onExit) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(TavernPalette.cream.opacity(0.5))
                }
            }

            if showProgress {
                TavernQuotaBar(served: vm.serveIndex, total: vm.patronsToday,
                               ask: vm.serveQuota, dayScore: vm.dayScore)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

/// Day progress: patrons served, plus the ask every hand must meet today.
struct TavernQuotaBar: View {
    let served: Int
    let total: Int
    let ask: Int
    let dayScore: Int

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return min(1.0, Double(served) / Double(total))
    }

    var body: some View {
        VStack(spacing: 3) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.35))
                    Capsule()
                        .fill(served >= total ? TavernPalette.green : TavernPalette.amber)
                        .frame(width: max(8, geo.size.width * fraction))
                        .animation(.spring(response: 0.5), value: fraction)
                }
            }
            .frame(height: 10)

            HStack {
                Text("\(served)/\(total) patrons · \(dayScore) pts tonight")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(TavernPalette.cream.opacity(0.7))
                Spacer()
                Text("THE ASK: \(ask)")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(TavernPalette.amber)
            }
        }
    }
}

// ============================================================
// SHARED PORTRAIT — gmarker image, or an initial circle if missing
// ============================================================
struct TavernPortraitView: View {
    let imageName: String
    let fallbackName: String
    var size: CGFloat = 90

    var body: some View {
        Group {
            if let ui = UIImage(named: imageName) {
                Image(uiImage: ui)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Circle()
                    .fill(TavernPalette.amber.opacity(0.3))
                    .overlay(
                        Text(String(fallbackName.prefix(1)))
                            .font(.system(size: size * 0.45, weight: .bold))
                            .foregroundColor(TavernPalette.cream)
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

// ============================================================
// JOKER SHELF — small strip of owned jokers
// ============================================================
struct TavernJokerShelf: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        HStack(spacing: 8) {
            Text("SHELF")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(TavernPalette.cream.opacity(0.4))

            if vm.activeJokers.isEmpty {
                Text("empty — visit the caravan")
                    .font(.system(size: 12))
                    .foregroundColor(TavernPalette.cream.opacity(0.4))
            } else {
                ForEach(vm.activeJokers) { joker in
                    Text(joker.icon)
                        .font(.system(size: 20))
                        .opacity(vm.jokersDisabledToday ? 0.25 : 1.0)
                }
                if vm.jokersDisabledToday {
                    Text("DISABLED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(TavernPalette.red)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// ============================================================
// DAY INTRO — the morning
// ============================================================
struct TavernDayIntroScreen: View {
    var vm: EnnasTavernViewModel

    private var actTitle: String {
        switch vm.act {
        case 1: return "THE BARMAID"
        case 2: return "HER OWN SIGN"
        default: return "THE CITY ARRIVES"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("ACT \(vm.act) — \(actTitle)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(TavernPalette.amber)
                .tracking(2)

            Text("Day \(vm.day)")
                .font(.system(size: 44, weight: .heavy, design: .serif))
                .foregroundColor(TavernPalette.cream)

            if vm.bossTwist != .none {
                VStack(spacing: 6) {
                    Text(vm.bossTwist.banner)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.white)
                    Text(vm.bossTwist.detail)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 14).fill(TavernPalette.red.opacity(0.55)))
                .padding(.horizontal, 24)
            }

            VStack(spacing: 10) {
                infoRow(label: "The ask (per patron)", value: "\(vm.serveQuota) points")
                infoRow(label: "Patrons expected", value: "\(vm.patronsToday)")
                infoRow(label: "Do-overs per patron", value: "\(vm.doOversPerServe)")
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.25)))
            .padding(.horizontal, 24)

            TavernJokerShelf(vm: vm)
                .padding(.horizontal, 28)

            Spacer()

            Button(action: { vm.openDoors() }) {
                Text("OPEN THE DOORS")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(TavernPalette.wood)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(TavernPalette.amber))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(TavernPalette.cream.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(TavernPalette.cream)
        }
    }
}

// ============================================================
// MODE SELECT (Act 3) — dice or cards, per patron
// ============================================================
struct TavernModeSelectScreen: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            TavernPortraitView(imageName: vm.currentPatron.imageName,
                               fallbackName: vm.currentPatron.name,
                               size: 120)

            Text("\(vm.currentPatron.name) sits down.")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(TavernPalette.cream)

            Text("How will Enna read them tonight?")
                .font(.system(size: 14))
                .foregroundColor(TavernPalette.cream.opacity(0.7))

            HStack(spacing: 16) {
                modeButton(title: "THE DICE", subtitle: "Roll & lock", emoji: "🎲", mode: .dice)
                modeButton(title: "THE CARDS", subtitle: "Hold & redraw", emoji: "🃏", mode: .cards)
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    private func modeButton(title: String, subtitle: String, emoji: String, mode: TavernServeMode) -> some View {
        Button(action: { vm.chooseMode(mode) }) {
            VStack(spacing: 8) {
                Text(emoji).font(.system(size: 44))
                Text(title)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(TavernPalette.cream)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(TavernPalette.cream.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.black.opacity(0.3)))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(TavernPalette.amber.opacity(0.5), lineWidth: 1.5))
        }
    }
}

// ============================================================
// DAY RESULT — quota met (non-boss days)
// ============================================================
struct TavernDayResultScreen: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("LAST CALL")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(TavernPalette.cream.opacity(0.6))
                .tracking(3)

            Text("Day Cleared!")
                .font(.system(size: 40, weight: .heavy, design: .serif))
                .foregroundColor(TavernPalette.green)

            Text("Every ask met. \(vm.dayScore) points across \(vm.patronsToday) patrons.")
                .font(.system(size: 16))
                .foregroundColor(TavernPalette.cream)

            HStack(spacing: 6) {
                Text("🪙").font(.system(size: 20))
                Text("+\(vm.lastCoinEarned) coin")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(TavernPalette.amber)
            }
            .padding(.top, 4)

            Spacer()

            Button(action: { vm.continueToMarket() }) {
                Text("THE CARAVAN IS OUTSIDE →")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(TavernPalette.wood)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(TavernPalette.amber))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }
}

// ============================================================
// ENDING SCREEN — promotion ★ / victory epilogue / fail vignette
// ============================================================
struct TavernEndingScreen: View {

    enum Style { case promotion, victory, fail }

    var vm: EnnasTavernViewModel
    let style: Style
    var onRestart: () -> Void
    var onExit: () -> Void

    private var ending: TavernEnding? {
        vm.endingID.flatMap { EnnasTavernDatabase.ending($0) }
    }

    private var header: String {
        switch style {
        case .promotion: return "ACT \(vm.act) COMPLETE"
        case .victory:   return "THE RUN IS WON"
        case .fail:      return "THE RUN ENDS"
        }
    }

    private var headerColor: Color {
        switch style {
        case .promotion: return TavernPalette.amber
        case .victory:   return TavernPalette.green
        case .fail:      return TavernPalette.red
        }
    }

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Text(header)
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(headerColor)
                .tracking(3)

            if let ending = ending {
                Text(ending.title)
                    .font(.system(size: 30, weight: .heavy, design: .serif))
                    .foregroundColor(TavernPalette.cream)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text(ending.flavor)
                    .font(.system(size: 16, design: .serif))
                    .italic()
                    .foregroundColor(TavernPalette.cream.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Text("Logged in the Ledger of Endings.")
                    .font(.system(size: 12))
                    .foregroundColor(TavernPalette.cream.opacity(0.45))
            } else if let text = vm.genericEndText {
                Text(text)
                    .font(.system(size: 17, design: .serif))
                    .italic()
                    .foregroundColor(TavernPalette.cream.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Spacer()

            if style == .promotion {
                Button(action: { vm.continueToMarket() }) {
                    Text("ON TO ACT \(vm.act + 1) →")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(TavernPalette.wood)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(TavernPalette.amber))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            } else {
                VStack(spacing: 12) {
                    Button(action: onRestart) {
                        Text("NEW RUN")
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundColor(TavernPalette.wood)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(RoundedRectangle(cornerRadius: 16).fill(TavernPalette.amber))
                    }
                    Button(action: onExit) {
                        Text("Back to the Game Selector")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(TavernPalette.cream.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
}
