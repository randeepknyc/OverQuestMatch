//
//  EnnasTavernView.swift
//  OverQuestMatch3 — Enna's Tavern (v4 — the OPERATING COSTS build)
//
//  Router + chrome: hamburger settings, costs plaque, day screens,
//  skills sheet (with free icon reassignment), service ledger,
//  promotion/epilogue/game-over. Entry point unchanged for GameSelector.
//

import SwiftUI

struct EnnasTavernView: View {
    let continueFromSave: Bool
    var onExit: (() -> Void)? = nil

    @State private var vm = EnnasTavernViewModel()
    @State private var didSetUp = false
    @State private var showMenu = false
    @State private var showSkills = false
    @State private var showServiceLog = false
    @State private var showEndingsLedger = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            TavernPalette.wood.ignoresSafeArea()

            VStack(spacing: 0) {
                TavernTopBar(vm: vm, onMenu: { showMenu = true })
                content
            }

            if vm.showCollectible, let id = vm.pendingCollectibles.first,
               let ending = EnnasTavernDatabase.ending(id) {
                TavernCollectibleOverlay(ending: ending) { vm.dismissCollectible() }
            }

            // 🔧 layout tuner — root level so it opens on ANY screen
            if TavernLayout.shared.tunerOpen {
                VStack {
                    Spacer()
                    TavernLayoutTuner(vm: vm)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .sheet(isPresented: $showMenu) {
            TavernMenuSheet(vm: vm,
                            onEndingsLedger: { showMenu = false; showEndingsLedger = true },
                            onExit: exitGame)
        }
        .sheet(isPresented: $showSkills) { TavernSkillsSheet(vm: vm) }
        .sheet(isPresented: $showServiceLog) { TavernServiceLogSheet(vm: vm) }
        .sheet(isPresented: $showEndingsLedger) { TavernLedgerSheet() }
        .onAppear {
            guard !didSetUp else { return }
            didSetUp = true
            if continueFromSave, let save = EnnasTavernSave.load() {
                save.restore(into: vm)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.phase {
        case .dayIntro:  TavernDayIntroScreen(vm: vm)
        case .serving:   TavernServingScreen(vm: vm,
                                             onSkills: { showSkills = true },
                                             onServiceLog: { showServiceLog = true })
        case .dayResult: TavernDayResultScreen(vm: vm)
        case .interlude: TavernInterludeScreen(vm: vm, onSkillsInfo: { showSkills = true })
        case .promotion: TavernPromotionScreen(vm: vm)
        case .epilogue, .gameOver: TavernEndingScreen(vm: vm, onExit: exitGame)
        }
    }

    private func exitGame() {
        if let onExit { onExit() } else { dismiss() }
    }
}

// ============================================================
// TOP BAR — hamburger left · operating-costs plaque right
// ============================================================
struct TavernTopBar: View {
    var vm: EnnasTavernViewModel
    var onMenu: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Button(action: onMenu) {
                Image(systemName: "line.3.horizontal")
                    .font(TavernFont.of(19))
                    .foregroundColor(TavernPalette.cream.opacity(0.75))
                    .padding(6)
            }

            // 🔧 the tuner wrench is ALWAYS here — no toggle, no hunting
            Button(action: { TavernLayout.shared.tunerOpen.toggle() }) {
                Image(systemName: "slider.horizontal.3")
                    .font(TavernFont.of(14))
                    .foregroundColor(TavernPalette.wood)
                    .padding(7)
                    .background(Circle().fill(TavernPalette.amber))
            }
            .padding(.leading, 2)

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("OPERATING COSTS")
                    .font(TavernFont.of(10)).tracking(1)
                    .foregroundColor(TavernPalette.cream.opacity(0.5))
                HStack(spacing: 5) {
                    TavernOdometerText(value: vm.dayScore,
                                       font: TavernFont.of(TavernLayout.shared.costsFont),
                                       color: vm.dayCleared ? TavernPalette.green : TavernPalette.amber)
                    Text("/ \(vm.operatingCosts)")
                        .font(TavernFont.of(TavernLayout.shared.costsFont))
                        .foregroundColor((vm.dayCleared ? TavernPalette.green : TavernPalette.amber).opacity(0.75))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.4))
                        Capsule().fill(TavernPalette.amber)
                            .frame(width: max(4, geo.size.width * min(1, Double(vm.dayScore) / Double(max(1, vm.operatingCosts)))))
                            .animation(.spring(response: 0.45), value: vm.dayScore)
                    }
                }
                .frame(width: 110, height: 6)

            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.35)))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(TavernPalette.amber.opacity(0.5), lineWidth: 1))
        }
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }
}

// ============================================================
// DAY INTRO
// ============================================================
struct TavernDayIntroScreen: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Text("DAY \(vm.runDay)")
                .font(TavernFont.of(13)).tracking(4)
                .foregroundColor(TavernPalette.cream.opacity(0.5))
            Text(vm.bossTwist == .none ? "Morning at the tavern." : "Something's off this morning.")
                .font(TavernFont.of(TavernLayout.shared.panelFont))
                .foregroundColor(TavernPalette.cream)
                .multilineTextAlignment(.center).padding(.horizontal, 30)

            if vm.bossTwist != .none {
                Text(vm.bossTwist.banner)
                    .font(TavernFont.of(14)).italic()
                    .foregroundColor(TavernPalette.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 34)
            }

            VStack(spacing: 10) {
                infoRow(label: "Operating costs", value: "\(vm.operatingCosts) points")
                infoRow(label: "Rolls in the tank", value: "\(vm.rollBudget)")
                infoRow(label: "Coins", value: "the sum of your table")
                infoRow(label: "Multiplier", value: "the hand you serve")
                infoRow(label: "Act bonus", value: "+\(Int(EnnasTavernConfig.actMultBonus(act: vm.act))) mult")
                infoRow(label: "Match a need", value: "+10 coins · +1 mult")
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 6)

            Text("Every roll costs one. Serving is free.\nMeet costs and the day is yours.")
                .font(TavernFont.of(TavernLayout.shared.menuFont))
                .foregroundColor(TavernPalette.cream.opacity(0.55))
                .multilineTextAlignment(.center)

            Button(action: { vm.openDoors() }) {
                Text("OPEN THE DOORS")
                    .font(TavernFont.of(16))
                    .foregroundColor(TavernPalette.wood)
                    .padding(.horizontal, 40).padding(.vertical, 14)
                    .background(Capsule().fill(TavernPalette.amber))
            }
            .padding(.top, 8)
            Spacer()
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(TavernFont.of(13))
                .foregroundColor(TavernPalette.cream.opacity(0.65))
            Spacer()
            Text(value).font(TavernFont.of(14))
                .foregroundColor(TavernPalette.amber)
        }
    }
}

// ============================================================
// DAY RESULT
// ============================================================
struct TavernDayResultScreen: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("COSTS COVERED")
                .font(TavernFont.of(13)).tracking(3)
                .foregroundColor(TavernPalette.green)
            Text("The tavern survives the day.")
                .font(TavernFont.of(TavernLayout.shared.panelFont))
                .foregroundColor(TavernPalette.cream)
                .multilineTextAlignment(.center).padding(.horizontal, 30)
            Text("\(vm.dayScore) earned against \(vm.operatingCosts) · \(vm.customersServedToday) customers · \(vm.rollsLeft) rolls to spare")
                .font(TavernFont.of(TavernLayout.shared.menuFont))
                .foregroundColor(TavernPalette.cream.opacity(0.6))
                .multilineTextAlignment(.center).padding(.horizontal, 30)
            Button(action: { vm.continueToNight() }) {
                Text("CLOSE UP · NIGHT SCHOOL")
                    .font(TavernFont.of(15))
                    .foregroundColor(TavernPalette.wood)
                    .padding(.horizontal, 34).padding(.vertical, 14)
                    .background(Capsule().fill(TavernPalette.amber))
            }
            .padding(.top, 8)
            Spacer()
        }
    }
}

// ============================================================
// PROMOTION (act cleared) — reuses ending content
// ============================================================
struct TavernPromotionScreen: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            if let id = vm.endingID, let ending = EnnasTavernDatabase.ending(id) {
                Text("★ PROMOTION")
                    .font(TavernFont.of(13)).tracking(3)
                    .foregroundColor(TavernPalette.amber)
                Text(ending.title)
                    .font(TavernFont.of(TavernLayout.shared.panelFont))
                    .foregroundColor(TavernPalette.cream)
                    .multilineTextAlignment(.center).padding(.horizontal, 26)
                Text(ending.flavor)
                    .font(TavernFont.of(TavernLayout.shared.menuFont)).italic()
                    .foregroundColor(TavernPalette.cream.opacity(0.85))
                    .multilineTextAlignment(.center).padding(.horizontal, 30)
            }
            Button(action: { vm.continueToNight() }) {
                Text("ONWARD · NIGHT SCHOOL")
                    .font(TavernFont.of(15))
                    .foregroundColor(TavernPalette.wood)
                    .padding(.horizontal, 34).padding(.vertical, 14)
                    .background(Capsule().fill(TavernPalette.amber))
            }
            .padding(.top, 8)
            Spacer()
        }
    }
}

// ============================================================
// ENDING SCREEN (epilogue + game over)
// ============================================================
struct TavernEndingScreen: View {
    var vm: EnnasTavernViewModel
    var onExit: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            if vm.phase == .epilogue {
                Text("THE FESTIVAL IS OVER")
                    .font(TavernFont.of(12)).tracking(3)
                    .foregroundColor(TavernPalette.green)
            } else {
                Text("THE TAVERN GOES DARK")
                    .font(TavernFont.of(12)).tracking(3)
                    .foregroundColor(TavernPalette.red)
            }
            if let id = vm.endingID, let ending = EnnasTavernDatabase.ending(id) {
                Text(ending.title)
                    .font(TavernFont.of(TavernLayout.shared.panelFont))
                    .foregroundColor(TavernPalette.cream)
                    .multilineTextAlignment(.center).padding(.horizontal, 26)
                Text(ending.flavor)
                    .font(TavernFont.of(TavernLayout.shared.menuFont)).italic()
                    .foregroundColor(TavernPalette.cream.opacity(0.85))
                    .multilineTextAlignment(.center).padding(.horizontal, 30)
                Text("Logged in the Ledger of Endings.")
                    .font(TavernFont.of(11))
                    .foregroundColor(TavernPalette.cream.opacity(0.45))
            } else if let text = vm.genericEndText {
                Text(text)
                    .font(TavernFont.of(16)).italic()
                    .foregroundColor(TavernPalette.cream.opacity(0.9))
                    .multilineTextAlignment(.center).padding(.horizontal, 30)
            }
            HStack(spacing: 12) {
                Button(action: { vm.restart() }) {
                    Text("NEW RUN")
                        .font(TavernFont.of(15))
                        .foregroundColor(TavernPalette.wood)
                        .padding(.horizontal, 28).padding(.vertical, 13)
                        .background(Capsule().fill(TavernPalette.amber))
                }
                Button(action: onExit) {
                    Text("LEAVE")
                        .font(TavernFont.of(15))
                        .foregroundColor(TavernPalette.cream.opacity(0.8))
                        .padding(.horizontal, 28).padding(.vertical, 13)
                        .background(Capsule().stroke(TavernPalette.cream.opacity(0.4), lineWidth: 1.5))
                }
            }
            .padding(.top, 10)
            Spacer()
        }
    }
}

// ============================================================
// ☰ MENU SHEET — settings + toggles + endings ledger + exit
// ============================================================
struct TavernMenuSheet: View {
    var vm: EnnasTavernViewModel
    var onEndingsLedger: () -> Void
    var onExit: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var playMode = TavernSettings.playMode
    @State private var selMode = TavernSettings.selectionMode
    @State private var interlude = TavernSettings.interludeEnabled
    @State private var minigame = TavernSettings.minigame
    @State private var economy = TavernSettings.nightEconomy

    var body: some View {
        ZStack {
            TavernPalette.wood.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    Text("HOUSE RULES")
                        .font(TavernFont.of(17))
                        .foregroundColor(TavernPalette.cream).padding(.top, 22)

                    section("On the table") {
                        picker(options: [("Dice", TavernPlayMode.dice), ("Cards", .cards)],
                               current: playMode) { playMode = $0; TavernSettings.playMode = $0 }
                        Text("Applies from the next customer.")
                            .font(TavernFont.of(10)).foregroundColor(TavernPalette.cream.opacity(0.5))
                    }

                    section("Tapping means") {
                        picker(options: [("Keep tapped", TavernSelectionMode.holdSelected),
                                         ("Reroll tapped", .rerollSelected)],
                               current: selMode) { selMode = $0; TavernSettings.selectionMode = $0 }
                    }

                    section("Night school") {
                        picker(options: [("Free pick", TavernNightEconomy.freePick), ("Hybrid", .hybrid)],
                               current: economy) { economy = $0; TavernSettings.nightEconomy = $0 }
                        Text(economy == .freePick
                             ? "Pick one lesson free each night. No tokens."
                             : "Pick one free · minigame earns tokens · tokens reroll the offers.")
                            .font(TavernFont.of(10))
                            .foregroundColor(TavernPalette.cream.opacity(0.5))
                        if economy == .hybrid {
                            Toggle(isOn: Binding(get: { interlude },
                                                 set: { interlude = $0; TavernSettings.interludeEnabled = $0 })) {
                                Text("Play for tokens (off = flat \(EnnasTavernConfig.flatTokensPerNight)/night)")
                                    .font(TavernFont.of(12))
                                    .foregroundColor(TavernPalette.cream)
                            }
                            .tint(TavernPalette.amber)
                            picker(options: [("Dice throw", TavernMinigame.dice), ("Blackjack", .blackjack)],
                                   current: minigame) { minigame = $0; TavernSettings.minigame = $0 }
                        }
                    }

                    section("Tinkering") {
                        Button(action: {
                            TavernLayout.shared.tunerOpen = true
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                Text("Open layout tuner (also: the amber wrench, top bar)")
                                Spacer()
                            }
                            .font(TavernFont.of(12))
                            .foregroundColor(TavernPalette.amber)
                        }
                    }

                    Button(action: onEndingsLedger) {
                        HStack {
                            Image(systemName: "books.vertical.fill")
                            Text("Ledger of Endings")
                            Spacer()
                            Text("\(TavernLedger.found().count)/\(EnnasTavernDatabase.endings.count)")
                        }
                        .font(TavernFont.of(13))
                        .foregroundColor(TavernPalette.cream)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.3)))
                    }
                    .padding(.horizontal, 20)

                    Button(action: { dismiss(); onExit() }) {
                        Text("LEAVE THE TAVERN")
                            .font(TavernFont.of(12))
                            .foregroundColor(TavernPalette.red)
                    }
                    .padding(.top, 4)

                    Button(action: { dismiss() }) {
                        Text("BACK TO THE BAR")
                            .font(TavernFont.of(15))
                            .foregroundColor(TavernPalette.wood)
                            .padding(.horizontal, 34).padding(.vertical, 13)
                            .background(Capsule().fill(TavernPalette.amber))
                    }
                    .padding(.bottom, 26)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(TavernFont.of(10)).tracking(2)
                .foregroundColor(TavernPalette.cream.opacity(0.5))
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.22)))
        .padding(.horizontal, 20)
    }

    private func picker<T: Equatable>(options: [(String, T)], current: T, set: @escaping (T) -> Void) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<options.count, id: \.self) { i in
                let (label, value) = options[i]
                let on = value == current
                Button(action: { set(value) }) {
                    Text(label)
                        .font(TavernFont.of(12))
                        .foregroundColor(on ? TavernPalette.wood : TavernPalette.cream.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 9)
                            .fill(on ? TavernPalette.amber : Color.black.opacity(0.3)))
                }
            }
        }
    }
}

// ============================================================
// 🎓 SKILLS SHEET — learned skills + free icon reassignment
// ============================================================
struct TavernSkillsSheet: View {
    var vm: EnnasTavernViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            TavernPalette.wood.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("ENNA'S SKILLS")
                        .font(TavernFont.of(17))
                        .foregroundColor(TavernPalette.cream).padding(.top, 22)
                    Text("Tokens: \(vm.tokens) · learn more at night school")
                        .font(TavernFont.of(11))
                        .foregroundColor(TavernPalette.cream.opacity(0.55))

                    if vm.skillIDs.isEmpty {
                        Text("She knows how to pour. That's it, so far.")
                            .font(TavernFont.of(13)).italic()
                            .foregroundColor(TavernPalette.cream.opacity(0.6))
                            .padding(.vertical, 8)
                    } else {
                        ForEach(vm.skillIDs, id: \.self) { id in
                            if let s = EnnasTavernDatabase.skill(id) {
                                HStack(spacing: 10) {
                                    Image(systemName: s.school.symbol)
                                        .font(TavernFont.of(14))
                                        .foregroundColor(s.school.tint)
                                        .frame(width: 26)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(s.name)
                                            .font(TavernFont.of(14))
                                            .foregroundColor(TavernPalette.cream)
                                        Text(s.blurb)
                                            .font(TavernFont.of(11))
                                            .foregroundColor(TavernPalette.cream.opacity(0.6))
                                    }
                                    Spacer()
                                }
                                .padding(11)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.28)))
                                .padding(.horizontal, 18)
                            }
                        }
                    }

                    Text("THE MENU — TAP AN ICON TO CHANGE THE DISH")
                        .font(TavernFont.of(10)).tracking(1.5)
                        .foregroundColor(TavernPalette.cream.opacity(0.5))
                        .padding(.top, 8)

                    ForEach(vm.visibleRows) { row in
                        HStack {
                            Text(row.name)
                                .font(TavernFont.of(13))
                                .foregroundColor(TavernPalette.cream)
                            Text(row.requirement)
                                .font(TavernFont.of(10))
                                .foregroundColor(TavernPalette.cream.opacity(0.5))
                            Spacer()
                            Button(action: { vm.cycleRowIcon(row.id) }) {
                                let icon = vm.rowIcon(row.id)
                                HStack(spacing: 5) {
                                    Image(systemName: icon.symbol)
                                        .font(TavernFont.of(12))
                                    Text(icon.label)
                                        .font(TavernFont.of(11))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Capsule().fill(icon.tint))
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Button(action: { dismiss() }) {
                        Text("DONE")
                            .font(TavernFont.of(15))
                            .foregroundColor(TavernPalette.wood)
                            .padding(.horizontal, 34).padding(.vertical, 13)
                            .background(Capsule().fill(TavernPalette.amber))
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .presentationDetents([.large])
    }
}

// ============================================================
// 📓 SERVICE LEDGER — every customer this run
// ============================================================
struct TavernServiceLogSheet: View {
    var vm: EnnasTavernViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            TavernPalette.wood.ignoresSafeArea()
            VStack(spacing: 0) {
                Text("SERVICE LEDGER")
                    .font(TavernFont.of(17))
                    .foregroundColor(TavernPalette.cream)
                    .padding(.top, 22).padding(.bottom, 10)
                if vm.serviceLog.isEmpty {
                    Spacer()
                    Text("No one's been served yet.")
                        .font(TavernFont.of(13)).italic()
                        .foregroundColor(TavernPalette.cream.opacity(0.6))
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(vm.serviceLog.reversed()) { entry in
                                HStack(spacing: 8) {
                                    Image(systemName: entry.need.symbol)
                                        .font(TavernFont.of(12))
                                        .foregroundColor(entry.need.tint)
                                        .frame(width: 22)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(entry.customerName)
                                            .font(TavernFont.of(12))
                                            .foregroundColor(TavernPalette.cream)
                                        Text("wanted \(entry.need.label.lowercased()) · got \(entry.servedRow)")
                                            .font(TavernFont.of(10))
                                            .foregroundColor(TavernPalette.cream.opacity(0.55))
                                    }
                                    Spacer()
                                    Text(entry.matched ? "MATCHED" : "shrugged")
                                        .font(TavernFont.of(9))
                                        .foregroundColor(entry.matched ? TavernPalette.green : TavernPalette.cream.opacity(0.4))
                                    Text("+\(entry.points)")
                                        .font(TavernFont.of(13))
                                        .foregroundColor(TavernPalette.amber)
                                }
                                .padding(.horizontal, 12).padding(.vertical, 7)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.25)))
                            }
                        }
                        .padding(.horizontal, 16).padding(.bottom, 20)
                    }
                }
                Button(action: { dismiss() }) {
                    Text("BACK")
                        .font(TavernFont.of(14))
                        .foregroundColor(TavernPalette.wood)
                        .padding(.horizontal, 30).padding(.vertical, 12)
                        .background(Capsule().fill(TavernPalette.amber))
                }
                .padding(.bottom, 22)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// ============================================================
// PORTRAIT (asset with initial fallback)
// ============================================================
struct TavernPortraitView: View {
    let imageName: String
    let fallbackName: String
    let size: CGFloat

    var body: some View {
        Group {
            if let ui = UIImage(named: imageName) {
                Image(uiImage: ui)
                    .resizable().scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle().fill(TavernPalette.woodLight)
                    Text(String(fallbackName.prefix(1)))
                        .font(TavernFont.of(size * 0.4))
                        .foregroundColor(TavernPalette.cream)
                }
                .frame(width: size, height: size)
            }
        }
        .overlay(Circle().stroke(TavernPalette.amber.opacity(0.7), lineWidth: 2))
    }
}


// ============================================================
// 🎰 ODOMETER TEXT — counts toward its target with rolling
// digits instead of snapping. Used by the operating-costs plaque.
// ============================================================
struct TavernOdometerText: View {
    let value: Int
    let font: Font
    let color: Color

    @State private var displayed: Int = 0
    @State private var animator: Task<Void, Never>? = nil

    var body: some View {
        Text("\(displayed)")
            .font(font)
            .foregroundColor(color)
            .contentTransition(.numericText(value: Double(displayed)))
            .animation(.snappy(duration: 0.12), value: displayed)
            .onAppear { displayed = value }
            .onChange(of: value) { _, target in
                animator?.cancel()
                let start = displayed
                let delta = target - start
                guard delta != 0 else { return }
                animator = Task { @MainActor in
                    // ~0.7s ease-out count; bigger jumps take a few more steps
                    let steps = min(24, max(6, abs(delta) / 3))
                    for i in 1...steps {
                        if Task.isCancelled { return }
                        let t = Double(i) / Double(steps)
                        let eased = 1 - pow(1 - t, 2.2)
                        displayed = start + Int((Double(delta) * eased).rounded())
                        try? await Task.sleep(nanoseconds: 28_000_000)
                    }
                    if !Task.isCancelled { displayed = target }
                }
            }
    }
}
