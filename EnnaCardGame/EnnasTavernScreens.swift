//
//  EnnasTavernScreens.swift
//  OverQuestMatch3 — Enna's Tavern (v4 — the OPERATING COSTS build)
//
//  🌙 Night school (the between-day interlude): earn tokens at a dice
//  throw or blackjack against Enna's cousin (toggle in the menu), then
//  spend them on skills. Interlude toggled off = flat tokens, shop only.
//  Plus the Ledger of Endings sheet (collection, persists across runs).
//

import SwiftUI

// ============================================================
// 🌙 NIGHT SCHOOL
// ============================================================
struct TavernInterludeScreen: View {
    var vm: EnnasTavernViewModel
    var onSkillsInfo: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("NIGHT SCHOOL")
                    .font(TavernFont.of(13)).tracking(3)
                    .foregroundColor(TavernPalette.amber).padding(.top, 14)
                Text("The bar is closed. Enna is not done.")
                    .font(TavernFont.of(15)).italic()
                    .foregroundColor(TavernPalette.cream.opacity(0.8))

                if TavernSettings.nightEconomy == .hybrid {
                HStack {
                    Image(systemName: "circle.hexagongrid.fill")
                        .foregroundColor(TavernPalette.amber)
                    Text("Tokens: \(vm.tokens)")
                        .font(TavernFont.of(15))
                        .foregroundColor(TavernPalette.cream)
                    if vm.interludeTokensEarned > 0 {
                        Text("(+\(vm.interludeTokensEarned) tonight)")
                            .font(TavernFont.of(12))
                            .foregroundColor(TavernPalette.green)
                    }
                }
                }

                if !vm.showNightShop {
                    if TavernSettings.minigame == .dice {
                        TavernSchoolDiceView(vm: vm)
                    } else {
                        TavernBlackjackView(vm: vm)
                    }
                }

                if vm.showNightShop {
                    skillShop
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Button(action: { vm.leaveInterlude() }) {
                    Text(vm.showNightShop ? "TO BED · NEXT DAY" : "SKIP · TO BED")
                        .font(TavernFont.of(15))
                        .foregroundColor(TavernPalette.wood)
                        .padding(.horizontal, 34).padding(.vertical, 13)
                        .background(Capsule().fill(TavernPalette.amber))
                }
                .padding(.vertical, 16)
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: vm.showNightShop)
        }
    }

    private var skillShop: some View {
        VStack(spacing: 10) {
            Text(vm.nightPickDone ? "LESSON LEARNED" : "TONIGHT'S LESSONS · PICK ONE")
                .font(TavernFont.of(10)).tracking(2)
                .foregroundColor(TavernPalette.cream.opacity(0.5))
                .padding(.top, 6)

            if vm.nightPickDone {
                if let last = vm.skillIDs.last, let s = EnnasTavernDatabase.skill(last) {
                    HStack(spacing: 8) {
                        Image(systemName: s.school.symbol)
                            .foregroundColor(s.school.tint)
                        Text("Enna learned \(s.name).")
                            .font(TavernFont.of(14))
                            .foregroundColor(TavernPalette.cream)
                    }
                } else {
                    Text("Locked in for the run.")
                        .font(TavernFont.of(14)).italic()
                        .foregroundColor(TavernPalette.cream)
                }
            } else {
                if vm.shopSkillIDs.isEmpty {
                    Text("Nothing left to learn tonight.")
                        .font(TavernFont.of(12)).italic()
                        .foregroundColor(TavernPalette.cream.opacity(0.55))
                }

                ForEach(vm.shopSkillIDs, id: \.self) { id in
                    if id.hasPrefix("keep:"), let rowID = TavernRowID(rawValue: String(id.dropFirst(5))) {
                        let row = EnnasTavernDatabase.row(rowID)
                        offerRow(icon: "lock.fill", tint: TavernPalette.amber,
                                 title: "Keep \(row.name)",
                                 blurb: "Today's +1 multiplier on \(row.name) stays for the rest of the run.",
                                 highlight: true) { vm.pickKeepLevel(rowID) }
                    } else if let s = EnnasTavernDatabase.skill(id) {
                        offerRow(icon: s.school.symbol, tint: s.school.tint,
                                 title: s.name, blurb: s.blurb, highlight: false) { vm.pickSkill(id) }
                    }
                }

                if TavernSettings.nightEconomy == .hybrid {
                    Button(action: { vm.rerollOffers() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Reroll the offers · \(EnnasTavernConfig.offerRerollCost) token")
                        }
                        .font(TavernFont.of(12))
                        .foregroundColor(vm.tokens >= EnnasTavernConfig.offerRerollCost
                                         ? TavernPalette.amber : TavernPalette.cream.opacity(0.35))
                    }
                    .disabled(vm.tokens < EnnasTavernConfig.offerRerollCost)
                    .padding(.top, 2)
                }
            }

            Button(action: onSkillsInfo) {
                Text("view learned skills + reassign dish icons (free)")
                    .font(TavernFont.of(11))
                    .foregroundColor(TavernPalette.amber)
                    .underline()
            }
            .padding(.top, 2)
        }
    }
}

extension TavernInterludeScreen {
    func offerRow(icon: String, tint: Color, title: String, blurb: String,
                  highlight: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(TavernFont.of(15))
                    .foregroundColor(tint)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(TavernFont.of(14))
                        .foregroundColor(TavernPalette.cream)
                    Text(blurb)
                        .font(TavernFont.of(11))
                        .foregroundColor(TavernPalette.cream.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Text("PICK")
                    .font(TavernFont.of(11))
                    .foregroundColor(TavernPalette.wood)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Capsule().fill(TavernPalette.green))
            }
            .padding(11)
            .background(RoundedRectangle(cornerRadius: 12)
                .fill(highlight ? TavernPalette.amber.opacity(0.10) : Color.black.opacity(0.28)))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(highlight ? TavernPalette.amber.opacity(0.5) : Color.clear, lineWidth: 1))
        }
        .padding(.horizontal, 16)
    }
}

// ============================================================
// 🎲 dice throw — the REAL 3D table, one toss for tokens
// ============================================================
struct TavernSchoolDiceView: View {
    var vm: EnnasTavernViewModel
    private var layout: TavernLayout { TavernLayout.shared }

    var body: some View {
        VStack(spacing: 8) {
            Text("ONE THROW FOR TOKENS")
                .font(TavernFont.of(10)).tracking(2)
                .foregroundColor(TavernPalette.cream.opacity(0.5))
            Text("Pair 1 · 2 pair or 3-of-a-kind 2 · straight 3 · full house or 4-of-a-kind 4")
                .font(TavernFont.of(10))
                .foregroundColor(TavernPalette.cream.opacity(0.5))

            TavernDiceSceneView(
                dice: vm.schoolDisplayDice,
                rollStamp: vm.schoolRollStamp,
                rolledIDs: Set(vm.schoolDisplayDice.map { $0.id }),
                dieScale: Float(layout.dieScale),
                dieGap: Float(layout.dieGap),
                onTapDie: { _ in }
            )
            .frame(height: 150)
            .opacity(vm.schoolDiceThrown ? 1 : 0.35)

            if vm.schoolResultIn {
                Text(vm.schoolResultLabel)
                    .font(TavernFont.of(12))
                    .foregroundColor(TavernPalette.cream.opacity(0.75))
                Text("+\(vm.interludeTokensEarned) tokens")
                    .font(TavernFont.of(16))
                    .foregroundColor(vm.interludeTokensEarned > 0 ? TavernPalette.green : TavernPalette.cream.opacity(0.5))
                    .transition(.scale.combined(with: .opacity))
            } else if !vm.schoolDiceThrown {
                Button(action: { vm.throwSchoolDice() }) {
                    Text("THROW")
                        .font(TavernFont.of(15))
                        .foregroundColor(TavernPalette.wood)
                        .padding(.horizontal, 40).padding(.vertical, 13)
                        .background(Capsule().fill(TavernPalette.green))
                }
            } else {
                Text("…")
                    .font(TavernFont.of(16))
                    .foregroundColor(TavernPalette.cream.opacity(0.4))
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.3)))
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.35), value: vm.schoolResultIn)
    }
}

// ============================================================
// 🃏 blackjack vs Enna's cousin — real cards, hole card face-down,
// dealer stands on 17. 3 hands: win 2 tokens, push 1.
// ============================================================
struct TavernBlackjackView: View {
    var vm: EnnasTavernViewModel
    private var layout: TavernLayout { TavernLayout.shared }
    private var cardW: Double { max(44, layout.cardW * 0.8) }
    private var cardH: Double { max(62, layout.cardH * 0.8) }

    var body: some View {
        VStack(spacing: 10) {
            Text("BLACKJACK vs THE COUSIN · \(vm.bjHandsPlayed)/\(EnnasTavernConfig.blackjackHands) HANDS PLAYED")
                .font(TavernFont.of(10)).tracking(1.5)
                .foregroundColor(TavernPalette.cream.opacity(0.5))

            if !vm.bjPlayerCards.isEmpty {
                handRow(label: "The cousin \(vm.bjHandOver ? "· \(vm.bjDealerTotal)" : "· ?")",
                        cards: vm.bjDealerCards,
                        hideFrom: vm.bjHandOver ? nil : 1)
                handRow(label: "Enna · \(vm.bjPlayerTotal)",
                        cards: vm.bjPlayerCards,
                        hideFrom: nil)
            } else {
                Text("The cousin shuffles, insufferably.")
                    .font(TavernFont.of(12))
                    .italic()
                    .foregroundColor(TavernPalette.cream.opacity(0.55))
                    .padding(.vertical, 10)
            }

            if !vm.bjMessage.isEmpty {
                Text(vm.bjMessage)
                    .font(TavernFont.of(13))
                    .italic()
                    .foregroundColor(TavernPalette.cream)
            }

            HStack(spacing: 10) {
                if vm.bjHandOver {
                    if vm.bjHandsPlayed < EnnasTavernConfig.blackjackHands {
                        actionButton("DEAL", color: TavernPalette.green) { vm.bjDeal() }
                    }
                } else {
                    actionButton("HIT", color: TavernPalette.amber) { vm.bjHit() }
                    actionButton("STAND", color: TavernPalette.green) { vm.bjStand() }
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.3)))
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.bjPlayerCards)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.bjDealerCards)
        .animation(.easeInOut(duration: 0.25), value: vm.bjHandOver)
    }

    private func handRow(label: String, cards: [TavernPlayingCard], hideFrom: Int?) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(TavernFont.of(10))
                .foregroundColor(TavernPalette.cream.opacity(0.6))
            HStack(spacing: 6) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { i, c in
                    Group {
                        if let h = hideFrom, i >= h {
                            TavernCardBackView()
                        } else {
                            TavernPlayingCardView(card: c)
                                .scaleEffect(x: cardW / max(1, layout.cardW),
                                             y: cardH / max(1, layout.cardH))
                                .frame(width: cardW, height: cardH)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity))
                }
            }
        }
    }

    private func actionButton(_ label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(TavernFont.of(14))
                .foregroundColor(TavernPalette.wood)
                .padding(.horizontal, 26).padding(.vertical, 11)
                .background(Capsule().fill(color))
        }
    }
}

/// The house deck — Enna's monogram on wood.
struct TavernCardBackView: View {
    private var layout: TavernLayout { TavernLayout.shared }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .fill(TavernPalette.woodLight)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
            RoundedRectangle(cornerRadius: 6)
                .stroke(TavernPalette.amber.opacity(0.7), lineWidth: 1.5)
                .padding(4)
            Text("E")
                .font(TavernFont.of(max(44, layout.cardW * 0.8) * 0.4))
                .foregroundColor(TavernPalette.amber.opacity(0.85))
        }
        .frame(width: max(44, layout.cardW * 0.8), height: max(62, layout.cardH * 0.8))
    }
}

// ============================================================
// 📕 LEDGER OF ENDINGS — 21 slots, persists across runs
// ============================================================
struct TavernLedgerSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let found = TavernLedger.found()

    private func endings(act: Int) -> [TavernEnding] {
        EnnasTavernDatabase.endings.filter { $0.act == act }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TavernPalette.wood.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("\(found.count) of \(EnnasTavernDatabase.endings.count) endings found")
                            .font(TavernFont.of(13))
                            .foregroundColor(TavernPalette.amber)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)

                        ForEach(1...3, id: \.self) { act in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ACT \(act)")
                                    .font(TavernFont.of(12))
                                    .foregroundColor(TavernPalette.cream.opacity(0.5))
                                    .tracking(2)

                                ForEach(endings(act: act)) { ending in
                                    TavernLedgerEntry(ending: ending, isFound: found.contains(ending.id))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Ledger of Endings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct TavernLedgerEntry: View {
    let ending: TavernEnding
    let isFound: Bool

    private var kindIcon: String {
        switch ending.kind {
        case .promotion:   return "★"
        case .collectible: return "📕"
        case .fail:        return "🍂"
        case .epilogue:    return "🌅"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(isFound ? kindIcon : "❔")
                .font(TavernFont.of(18))
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 3) {
                Text(isFound ? ending.title : "? ? ?")
                    .font(TavernFont.of(15))
                    .foregroundColor(isFound ? TavernPalette.cream : TavernPalette.cream.opacity(0.35))

                if isFound {
                    Text(ending.flavor)
                        .font(TavernFont.of(12))
                        .italic()
                        .foregroundColor(TavernPalette.cream.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Not yet witnessed.")
                        .font(TavernFont.of(11))
                        .foregroundColor(TavernPalette.cream.opacity(0.3))
                }
            }
            Spacer()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(isFound ? 0.3 : 0.18)))
    }
}
