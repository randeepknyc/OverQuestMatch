//
//  EnnasTavernPlayViews.swift
//  OverQuestMatch3 — Enna's Tavern
//
//  The serving table: the patron, the dice / cards, and THE MENU
//  (the Deviled-Dice-style score sheet you bank hands into).
//

import SwiftUI

// ============================================================
// SERVING SCREEN
// ============================================================
struct TavernServingScreen: View {
    var vm: EnnasTavernViewModel

    private var arrivalLine: String {
        let lines = vm.currentPatron.arrivalLines
        guard !lines.isEmpty else { return "" }
        return lines[vm.serveIndex % lines.count]
    }

    private var doOversLeft: Int {
        vm.serveMode == .dice ? vm.rollsLeft : vm.redrawsLeft
    }

    var body: some View {
        VStack(spacing: 10) {

            // ---- Patron header ----
            HStack(spacing: 12) {
                TavernPortraitView(imageName: vm.currentPatron.imageName,
                                   fallbackName: vm.currentPatron.name,
                                   size: 72)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(vm.currentPatron.name)
                            .font(.system(size: 17, weight: .heavy, design: .serif))
                            .foregroundColor(TavernPalette.cream)
                        Spacer()
                        Text("Patron \(vm.serveIndex + 1)/\(vm.patronsToday)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(TavernPalette.cream.opacity(0.5))
                    }
                    Text(arrivalLine)
                        .font(.system(size: 13, design: .serif))
                        .italic()
                        .foregroundColor(TavernPalette.cream.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 16)

            // ---- Dice or cards ----
            if vm.serveMode == .dice {
                TavernDiceRow(vm: vm)
            } else {
                TavernCardHandRow(vm: vm)
            }

            // ---- Do-over button ----
            doOverButton
                .padding(.horizontal, 16)

            // ---- THE MENU ----
            Text("— THE MENU —")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(TavernPalette.cream.opacity(0.5))
                .tracking(2)
                .padding(.top, 2)

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(vm.visibleRows) { row in
                        TavernMenuRowView(vm: vm, row: row)
                    }

                    // THE LOSE STATE: do-overs spent and nothing meets the ask.
                    if !vm.hasAnyBankableRow && doOversLeft == 0 {
                        Button(action: { vm.comeUpShort() }) {
                            VStack(spacing: 2) {
                                Text("COME UP SHORT")
                                    .font(.system(size: 14, weight: .heavy))
                                Text("nothing meets the ask — this ends the run")
                                    .font(.system(size: 10))
                                    .opacity(0.8)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(TavernPalette.red.opacity(0.65)))
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
    }

    private var doOverButton: some View {
        let count = (vm.serveMode == .dice) ? vm.rollsLeft : vm.redrawsLeft
        let label = (vm.serveMode == .dice) ? "REROLL" : "REDRAW"
        let hint  = (vm.serveMode == .dice) ? "tap dice to hold them" : "tap cards to hold them"

        return Button(action: {
            if vm.serveMode == .dice { vm.reroll() } else { vm.redraw() }
        }) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 15, weight: .bold))
                Text("\(label) (\(count) left)")
                    .font(.system(size: 15, weight: .heavy))
                Spacer()
                Text(hint)
                    .font(.system(size: 11))
                    .opacity(0.7)
            }
            .foregroundColor(count > 0 ? TavernPalette.wood : TavernPalette.cream.opacity(0.35))
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(count > 0 ? TavernPalette.amber : Color.black.opacity(0.25))
            )
        }
        .disabled(count == 0)
    }
}

// ============================================================
// DICE — pip-drawn d6, tap to hold
// ============================================================
struct TavernDiceRow: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        HStack(spacing: 10) {
            ForEach(vm.dice) { die in
                TavernDieView(die: die)
                    .onTapGesture { vm.toggleLock(die.id) }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct TavernDieView: View {
    let die: TavernDie
    private let size: CGFloat = 58

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(TavernPalette.cream)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)

                ForEach(0..<pipPositions.count, id: \.self) { i in
                    Circle()
                        .fill(TavernPalette.wood)
                        .frame(width: size * 0.17, height: size * 0.17)
                        .position(x: pipPositions[i].x * size,
                                  y: pipPositions[i].y * size)
                }
            }
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(die.locked ? TavernPalette.amber : Color.clear, lineWidth: 3)
            )

            Text(die.locked ? "HELD" : " ")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(TavernPalette.amber)
        }
    }

    private var pipPositions: [CGPoint] {
        let tl = CGPoint(x: 0.27, y: 0.27), tr = CGPoint(x: 0.73, y: 0.27)
        let ml = CGPoint(x: 0.27, y: 0.50), mr = CGPoint(x: 0.73, y: 0.50)
        let bl = CGPoint(x: 0.27, y: 0.73), br = CGPoint(x: 0.73, y: 0.73)
        let c  = CGPoint(x: 0.50, y: 0.50)
        switch die.value {
        case 1: return [c]
        case 2: return [tl, br]
        case 3: return [tl, c, br]
        case 4: return [tl, tr, bl, br]
        case 5: return [tl, tr, c, bl, br]
        default: return [tl, ml, bl, tr, mr, br]
        }
    }
}

// ============================================================
// CARDS — traditional 52-card deck, tap to hold
// (Suit icons are SF Symbols for now — swap for drawn art later.)
// ============================================================
struct TavernCardHandRow: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        HStack(spacing: 8) {
            ForEach(vm.hand) { card in
                TavernPlayingCardView(card: card)
                    .onTapGesture { vm.toggleHold(card.id) }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct TavernPlayingCardView: View {
    let card: TavernPlayingCard

    private var inkColor: Color {
        card.suit.isRed ? Color(red: 0.75, green: 0.15, blue: 0.15) : Color(red: 0.1, green: 0.1, blue: 0.12)
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)

                VStack(spacing: 2) {
                    HStack {
                        Text(card.rankLabel)
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(inkColor)
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 4)

                    Spacer()

                    Image(systemName: card.suit.symbolName)
                        .font(.system(size: 20))
                        .foregroundColor(inkColor)

                    Spacer()
                }
            }
            .frame(width: 58, height: 80)
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(card.held ? TavernPalette.amber : Color.clear, lineWidth: 3)
            )

            Text(card.held ? "HELD" : " ")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(TavernPalette.amber)
        }
    }
}

// ============================================================
// ONE MENU ROW — name, requirement, points, Serve button
// ============================================================
struct TavernMenuRowView: View {
    var vm: EnnasTavernViewModel
    let row: TavernRow

    private var isBanked: Bool { !row.repeatable && vm.bankedToday.contains(row.id) }
    private var canServe: Bool { vm.canBank(row) }
    private var isShort: Bool { vm.qualifiesButShort(row) }
    private var points: Int { vm.previewPoints(row.id) }
    private var level: Int { vm.rowLevel(row.id) }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(row.name)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundColor(TavernPalette.cream)
                        .strikethrough(isBanked)
                    if level > 1 {
                        Text("Lv\(level)")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(TavernPalette.wood)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(TavernPalette.amber))
                    }
                }
                Text(row.requirement)
                    .font(.system(size: 11))
                    .foregroundColor(TavernPalette.cream.opacity(0.55))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text(isBanked ? "served" : "\(points)")
                    .font(.system(size: isBanked ? 11 : 17, weight: .heavy))
                    .foregroundColor(isBanked ? TavernPalette.cream.opacity(0.35)
                                     : (canServe ? TavernPalette.amber
                                        : (isShort ? TavernPalette.red.opacity(0.85)
                                           : TavernPalette.cream.opacity(0.4))))
                if isShort {
                    Text("below the ask")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(TavernPalette.red.opacity(0.75))
                }
            }

            if canServe {
                Button(action: { vm.bank(row.id) }) {
                    Text("SERVE")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(TavernPalette.wood)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(TavernPalette.amber))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(canServe ? TavernPalette.amber.opacity(0.14) : Color.black.opacity(0.22))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(canServe ? TavernPalette.amber.opacity(0.7) : Color.clear, lineWidth: 1.5)
        )
        .opacity(isBanked ? 0.5 : 1.0)
    }
}

// ============================================================
// REACTION OVERLAY — the patron responds to their service
// ============================================================
struct TavernReactionOverlay: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.72).ignoresSafeArea()

            VStack(spacing: 16) {
                TavernPortraitView(imageName: vm.currentPatron.imageName,
                                   fallbackName: vm.currentPatron.name,
                                   size: 100)

                Text("+\(vm.reactionPoints)")
                    .font(.system(size: 46, weight: .heavy))
                    .foregroundColor(vm.reactionPoints >= 35 ? TavernPalette.green : TavernPalette.amber)

                Text(vm.reactionLine)
                    .font(.system(size: 16, design: .serif))
                    .italic()
                    .foregroundColor(TavernPalette.cream)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 34)

                Button(action: { vm.dismissReaction() }) {
                    Text(vm.serveIndex < vm.patronsToday ? "NEXT PATRON" : "LAST CALL")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(TavernPalette.wood)
                        .padding(.horizontal, 34)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(TavernPalette.amber))
                }
                .padding(.top, 6)
            }
        }
        .transition(.opacity)
    }
}

// ============================================================
// COLLECTIBLE OVERLAY — an interlude ending was discovered
// (The run CONTINUES — these are Ledger collectibles.)
// ============================================================
struct TavernCollectibleOverlay: View {
    let ending: TavernEnding
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.82).ignoresSafeArea()

            VStack(spacing: 14) {
                Text("📕")
                    .font(.system(size: 42))

                Text("INTERLUDE DISCOVERED")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(TavernPalette.amber)
                    .tracking(3)

                Text(ending.title)
                    .font(.system(size: 26, weight: .heavy, design: .serif))
                    .foregroundColor(TavernPalette.cream)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)

                Text(ending.flavor)
                    .font(.system(size: 15, design: .serif))
                    .italic()
                    .foregroundColor(TavernPalette.cream.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Text("Logged in the Ledger of Endings. The night goes on.")
                    .font(.system(size: 12))
                    .foregroundColor(TavernPalette.cream.opacity(0.5))

                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(TavernPalette.wood)
                        .padding(.horizontal, 34)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(TavernPalette.amber))
                }
                .padding(.top, 6)
            }
        }
        .transition(.opacity)
    }
}
