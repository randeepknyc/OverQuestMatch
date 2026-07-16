//
//  EnnasTavernSave.swift
//  OverQuestMatch3 — Enna's Tavern
//
//  Two kinds of persistence:
//   1. EnnasTavernSave — the in-progress RUN (key "tavern").
//      Deleted when a run ends (win or lose) or on restart.
//   2. TavernLedger — the LEDGER OF ENDINGS (key "tavern_ledger").
//      Persists FOREVER across runs. Never deleted by the game.
//      (⚠️ Enna-only collection — not the cross-game Town Ledger.)
//

import Foundation

// ============================================================
// MARKET OFFER SNAPSHOT (offers are rebuilt from these on load)
// ============================================================
struct TavernOfferSave: Codable {
    var kind: String      // "joker" or "upgrade"
    var refID: String     // joker id, or TavernRowID rawValue
    var price: Int
}

// ============================================================
// RUN SNAPSHOT
// ============================================================
struct EnnasTavernSave: Codable {

    static let saveKey = "tavern"

    var phase: String
    var act: Int
    var day: Int
    var runDay: Int
    var serveIndex: Int
    var patronsToday: Int
    var dayScore: Int
    var coin: Int
    var bossTwist: String

    var serveMode: String
    var dice: [TavernDie]
    var rollsLeft: Int
    var deck: [TavernPlayingCard]
    var hand: [TavernPlayingCard]
    var redrawsLeft: Int
    var currentPatronID: String

    var rowLevels: [String: Int]
    var bankedToday: [String]

    var jokerIDs: [String]
    var spitePrimed: Bool
    var gremlockUsedToday: Bool
    var firstBankDoneToday: Bool

    var pendingCollectibles: [String]
    var showReaction: Bool
    var reactionLine: String
    var reactionPoints: Int
    var endingID: String?
    var genericEndText: String?
    var lastCoinEarned: Int

    var marketOffers: [TavernOfferSave]
    var merchantID: String
    var swordOffered: Bool

    var todayServesUsedAllRerolls: [Bool]
    var act1BankedNodEver: Bool
    var today35PlusCount: Int
    var todayRowKinds: [String]
    var dayResolvedPass: Bool

    // ============================================================
    // SNAPSHOT
    // ============================================================
    static func snapshot(from vm: EnnasTavernViewModel) -> EnnasTavernSave {
        EnnasTavernSave(
            phase: vm.phase.rawValue,
            act: vm.act, day: vm.day, runDay: vm.runDay,
            serveIndex: vm.serveIndex, patronsToday: vm.patronsToday,
            dayScore: vm.dayScore, coin: vm.coin,
            bossTwist: vm.bossTwist.rawValue,
            serveMode: vm.serveMode.rawValue,
            dice: vm.dice, rollsLeft: vm.rollsLeft,
            deck: vm.deck, hand: vm.hand, redrawsLeft: vm.redrawsLeft,
            currentPatronID: vm.currentPatronID,
            rowLevels: Dictionary(uniqueKeysWithValues: vm.rowLevels.map { ($0.key.rawValue, $0.value) }),
            bankedToday: vm.bankedToday.map { $0.rawValue },
            jokerIDs: vm.jokerIDs,
            spitePrimed: vm.spitePrimed,
            gremlockUsedToday: vm.gremlockUsedToday,
            firstBankDoneToday: vm.firstBankDoneToday,
            pendingCollectibles: vm.pendingCollectibles,
            showReaction: vm.showReaction,
            reactionLine: vm.reactionLine,
            reactionPoints: vm.reactionPoints,
            endingID: vm.endingID,
            genericEndText: vm.genericEndText,
            lastCoinEarned: vm.lastCoinEarned,
            marketOffers: vm.marketOffers.map { offer in
                switch offer.kind {
                case .joker(let j):        return TavernOfferSave(kind: "joker", refID: j.id, price: offer.price)
                case .rowUpgrade(let row): return TavernOfferSave(kind: "upgrade", refID: row.rawValue, price: offer.price)
                }
            },
            merchantID: vm.merchantID,
            swordOffered: vm.swordOffered,
            todayServesUsedAllRerolls: vm.todayServesUsedAllRerolls,
            act1BankedNodEver: vm.act1BankedNodEver,
            today35PlusCount: vm.today35PlusCount,
            todayRowKinds: vm.todayRowKinds.map { $0.rawValue },
            dayResolvedPass: vm.dayResolvedPass
        )
    }

    // ============================================================
    // RESTORE
    // ============================================================
    func restore(into vm: EnnasTavernViewModel) {
        vm.phase = TavernPhase(rawValue: phase) ?? .dayIntro
        vm.act = act; vm.day = day; vm.runDay = runDay
        vm.serveIndex = serveIndex; vm.patronsToday = patronsToday
        vm.dayScore = dayScore; vm.coin = coin
        vm.bossTwist = TavernBossTwist(rawValue: bossTwist) ?? .none
        vm.serveMode = TavernServeMode(rawValue: serveMode) ?? .dice
        vm.dice = dice; vm.rollsLeft = rollsLeft
        vm.deck = deck; vm.hand = hand; vm.redrawsLeft = redrawsLeft
        vm.currentPatronID = currentPatronID

        var levels: [TavernRowID: Int] = [:]
        for (k, v) in rowLevels {
            if let id = TavernRowID(rawValue: k) { levels[id] = v }
        }
        // Make sure every row has a level even if new rows were added since the save
        for row in EnnasTavernDatabase.rows where levels[row.id] == nil { levels[row.id] = 1 }
        vm.rowLevels = levels

        vm.bankedToday = Set(bankedToday.compactMap { TavernRowID(rawValue: $0) })
        vm.jokerIDs = jokerIDs
        vm.spitePrimed = spitePrimed
        vm.gremlockUsedToday = gremlockUsedToday
        vm.firstBankDoneToday = firstBankDoneToday
        vm.pendingCollectibles = pendingCollectibles
        vm.endingID = endingID
        vm.genericEndText = genericEndText
        vm.lastCoinEarned = lastCoinEarned

        vm.marketOffers = marketOffers.compactMap { saved in
            if saved.kind == "joker", let j = EnnasTavernDatabase.joker(saved.refID) {
                return TavernMarketOffer(kind: .joker(j), price: saved.price)
            }
            if saved.kind == "upgrade", let row = TavernRowID(rawValue: saved.refID) {
                return TavernMarketOffer(kind: .rowUpgrade(row), price: saved.price)
            }
            return nil
        }
        vm.merchantID = merchantID
        vm.swordOffered = swordOffered

        vm.todayServesUsedAllRerolls = todayServesUsedAllRerolls
        vm.act1BankedNodEver = act1BankedNodEver
        vm.today35PlusCount = today35PlusCount
        vm.todayRowKinds = Set(todayRowKinds.compactMap { TavernRowID(rawValue: $0) })
        vm.dayResolvedPass = dayResolvedPass

        // Restore overlays exactly as they were: a reaction shows first,
        // then any queued collectible interludes.
        vm.reactionLine = reactionLine
        vm.reactionPoints = reactionPoints
        vm.showReaction = showReaction
        vm.showCollectible = !showReaction && !vm.pendingCollectibles.isEmpty
    }

    // ============================================================
    // FILE OPERATIONS (via the shared SaveManager)
    // ============================================================
    static func save(vm: EnnasTavernViewModel) {
        SaveManager.save(snapshot(from: vm), key: saveKey)
    }

    static func load() -> EnnasTavernSave? {
        SaveManager.load(EnnasTavernSave.self, key: saveKey)
    }

    static func deleteSave() {
        SaveManager.deleteSave(key: saveKey)
    }

    static func hasSave() -> Bool {
        SaveManager.hasSave(key: saveKey)
    }
}

// ============================================================
// 📕 LEDGER OF ENDINGS — persists across ALL runs
// ============================================================
enum TavernLedger {

    static let key = "tavern_ledger"

    static func found() -> Set<String> {
        Set(SaveManager.load([String].self, key: key) ?? [])
    }

    static func add(_ endingID: String) {
        var all = found()
        guard !all.contains(endingID) else { return }
        all.insert(endingID)
        SaveManager.save(Array(all).sorted(), key: key)
    }
}
