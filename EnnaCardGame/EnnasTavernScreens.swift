//
//  EnnasTavernScreens.swift
//  OverQuestMatch3 — Enna's Tavern
//
//  The traveling caravan (the between-days market) and
//  the Ledger of Endings (the permanent 21-slot collection).
//

import SwiftUI

// ============================================================
// THE CARAVAN — market between days
// ============================================================
struct TavernMarketScreen: View {
    var vm: EnnasTavernViewModel

    var body: some View {
        VStack(spacing: 10) {

            // ---- Merchant header ----
            HStack(spacing: 12) {
                TavernPortraitView(imageName: vm.currentMerchant.imageName,
                                   fallbackName: vm.currentMerchant.name,
                                   size: 76)
                VStack(alignment: .leading, spacing: 4) {
                    Text("THE CARAVAN")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(TavernPalette.amber)
                        .tracking(2)
                    Text(vm.currentMerchant.name)
                        .font(.system(size: 18, weight: .heavy, design: .serif))
                        .foregroundColor(TavernPalette.cream)
                    Text(vm.currentMerchant.greeting)
                        .font(.system(size: 12, design: .serif))
                        .italic()
                        .foregroundColor(TavernPalette.cream.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(.horizontal, 16)

            TavernJokerShelf(vm: vm)
                .padding(.horizontal, 20)

            // ---- Offers ----
            ScrollView {
                VStack(spacing: 10) {
                    if vm.marketOffers.isEmpty {
                        Text("Sold out. The caravan shrugs.")
                            .font(.system(size: 14, design: .serif))
                            .italic()
                            .foregroundColor(TavernPalette.cream.opacity(0.5))
                            .padding(.top, 30)
                    }
                    ForEach(vm.marketOffers) { offer in
                        TavernOfferRow(vm: vm, offer: offer)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 12)
            }

            // ---- Bottom buttons ----
            VStack(spacing: 10) {
                Button(action: { vm.rerollShop() }) {
                    Text("NEW STOCK (🪙 \(EnnasTavernConfig.shopRerollCost))")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(vm.coin >= EnnasTavernConfig.shopRerollCost
                                         ? TavernPalette.cream : TavernPalette.cream.opacity(0.35))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.3)))
                }
                .disabled(vm.coin < EnnasTavernConfig.shopRerollCost)

                Button(action: { vm.leaveMarket() }) {
                    Text("CLOSE UP FOR THE NIGHT →")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(TavernPalette.wood)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(RoundedRectangle(cornerRadius: 14).fill(TavernPalette.amber))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}

// ============================================================
// ONE MARKET OFFER
// ============================================================
struct TavernOfferRow: View {
    var vm: EnnasTavernViewModel
    let offer: TavernMarketOffer

    var body: some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 30))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundColor(TavernPalette.cream)
                    if !factionTag.isEmpty {
                        Text(factionTag)
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(TavernPalette.wood)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(TavernPalette.amber.opacity(0.9)))
                    }
                }
                Text(blurb)
                    .font(.system(size: 12))
                    .foregroundColor(TavernPalette.cream.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button(action: { vm.buy(offer) }) {
                Text("🪙 \(offer.price)")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(canBuy ? TavernPalette.wood : TavernPalette.cream.opacity(0.35))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(canBuy ? TavernPalette.amber : Color.black.opacity(0.3)))
            }
            .disabled(!canBuy)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.25)))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSword ? TavernPalette.amber : Color.clear, lineWidth: 1.5)
        )
    }

    // ---- offer details ----
    private var isSword: Bool {
        if case .joker(let j) = offer.kind { return j.unique }
        return false
    }

    private var icon: String {
        switch offer.kind {
        case .joker(let j):   return j.icon
        case .rowUpgrade:     return "📈"
        }
    }

    private var title: String {
        switch offer.kind {
        case .joker(let j):
            return j.name
        case .rowUpgrade(let rowID):
            let row = EnnasTavernDatabase.row(rowID)
            return "Menu Upgrade: \(row.name)"
        }
    }

    private var blurb: String {
        switch offer.kind {
        case .joker(let j):
            return j.blurb
        case .rowUpgrade(let rowID):
            let row = EnnasTavernDatabase.row(rowID)
            let level = vm.rowLevel(rowID)
            let now = EnnasTavernConfig.rowValue(base: row.baseValue, level: level)
            let next = EnnasTavernConfig.rowValue(base: row.baseValue, level: level + 1)
            return "Base points \(now) → \(next) (Lv\(level) → Lv\(level + 1))"
        }
    }

    private var factionTag: String {
        if case .joker(let j) = offer.kind { return j.faction.label }
        return ""
    }

    private var canBuy: Bool {
        guard vm.coin >= offer.price else { return false }
        if case .joker = offer.kind {
            return vm.jokerIDs.count < EnnasTavernConfig.maxJokers
        }
        return true
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
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(TavernPalette.amber)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)

                        ForEach(1...3, id: \.self) { act in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ACT \(act)")
                                    .font(.system(size: 12, weight: .heavy))
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
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(isFound ? kindIcon : "❔")
                .font(.system(size: 18))
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 3) {
                Text(isFound ? ending.title : "? ? ?")
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(isFound ? TavernPalette.cream : TavernPalette.cream.opacity(0.35))

                if isFound {
                    Text(ending.flavor)
                        .font(.system(size: 12, design: .serif))
                        .italic()
                        .foregroundColor(TavernPalette.cream.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Not yet witnessed.")
                        .font(.system(size: 11))
                        .foregroundColor(TavernPalette.cream.opacity(0.3))
                }
            }
            Spacer()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(isFound ? 0.3 : 0.18)))
    }
}
