//
//  EnnasTavernSave.swift
//  OverQuestMatch3 — Enna's Tavern (v4 — the OPERATING COSTS build)
//
//  Run snapshot (key "tavern", deleted at run end) + the Ledger of
//  Endings (key "tavern_ledger", persists forever). Old-format saves
//  fail to decode and are treated as "no save" — safe and intentional.
//

import Foundation

struct EnnasTavernSave: Codable {

    static let saveKey = "tavern"

    var phase: String
    var act: Int
    var day: Int
    var runDay: Int
    var bossTwist: String

    var dayScore: Int
    var rollsLeft: Int
    var customersServedToday: Int

    var currentPatronID: String
    var customerNeed: String
    var customerLine: String
    var ennaLine: String
    var handLive: Bool
    var chosenRow: String?

    var serveMode: String
    var dice: [TavernDie]
    var deck: [TavernPlayingCard]
    var hand: [TavernPlayingCard]

    var rowIcons: [String: String]
    var dayMode: String
    var rowLevels: [String: Int]
    var rowServeCounts: [String: Int]
    var permanentRowLevels: [String: Int]
    var matchesThisRun: Int
    var levelUpsThisDay: Int
    var leveledTodayRows: [String]
    var nextDayBonusRolls: Int
    var tokens: Int
    var skillIDs: [String]
    var serviceLog: [TavernServiceEntry]

    var interludeTokensEarned: Int
    var minigameDone: Bool
    var bjHandsPlayed: Int
    var shopSkillIDs: [String]
    var nightPickDone: Bool

    var showReaction: Bool
    var reactionLine: String
    var reactionPoints: Int
    var reactionMatched: Bool
    var pendingCollectibles: [String]
    var endingID: String?
    var genericEndText: String?
    var dayResolvedPass: Bool

    var maxRollsSpentOnOneCustomer: Int
    var rollsSpentThisCustomer: Int
    var servedHighCardInAct1: Bool
    var bigServesToday: Int
    var todayRowKinds: [String]

    static func snapshot(from vm: EnnasTavernViewModel) -> EnnasTavernSave {
        EnnasTavernSave(
            phase: vm.phase.rawValue,
            act: vm.act, day: vm.day, runDay: vm.runDay,
            bossTwist: vm.bossTwist.rawValue,
            dayScore: vm.dayScore,
            rollsLeft: vm.rollsLeft,
            customersServedToday: vm.customersServedToday,
            currentPatronID: vm.currentPatronID,
            customerNeed: vm.customerNeed.rawValue,
            customerLine: vm.customerLine,
            ennaLine: vm.ennaLine,
            handLive: vm.handLive,
            chosenRow: vm.chosenRow?.rawValue,
            serveMode: vm.serveMode.rawValue,
            dice: vm.dice, deck: vm.deck, hand: vm.hand,
            rowIcons: Dictionary(uniqueKeysWithValues: vm.rowIcons.map { ($0.key.rawValue, $0.value.rawValue) }),
            dayMode: vm.dayMode.rawValue,
            rowLevels: Dictionary(uniqueKeysWithValues: vm.rowLevels.map { ($0.key.rawValue, $0.value) }),
            rowServeCounts: Dictionary(uniqueKeysWithValues: vm.rowServeCounts.map { ($0.key.rawValue, $0.value) }),
            permanentRowLevels: Dictionary(uniqueKeysWithValues: vm.permanentRowLevels.map { ($0.key.rawValue, $0.value) }),
            matchesThisRun: vm.matchesThisRun,
            levelUpsThisDay: vm.levelUpsThisDay,
            leveledTodayRows: vm.leveledTodayRows.map { $0.rawValue },
            nextDayBonusRolls: vm.nextDayBonusRolls,
            tokens: vm.tokens,
            skillIDs: vm.skillIDs,
            serviceLog: vm.serviceLog,
            interludeTokensEarned: vm.interludeTokensEarned,
            minigameDone: vm.minigameDone,
            bjHandsPlayed: vm.bjHandsPlayed,
            shopSkillIDs: vm.shopSkillIDs,
            nightPickDone: vm.nightPickDone,
            showReaction: vm.showReaction,
            reactionLine: vm.reactionLine,
            reactionPoints: vm.reactionPoints,
            reactionMatched: vm.reactionMatched,
            pendingCollectibles: vm.pendingCollectibles,
            endingID: vm.endingID,
            genericEndText: vm.genericEndText,
            dayResolvedPass: vm.dayResolvedPass,
            maxRollsSpentOnOneCustomer: vm.maxRollsSpentOnOneCustomer,
            rollsSpentThisCustomer: vm.rollsSpentThisCustomer,
            servedHighCardInAct1: vm.servedHighCardInAct1,
            bigServesToday: vm.bigServesToday,
            todayRowKinds: vm.todayRowKinds.map { $0.rawValue }
        )
    }

    func restore(into vm: EnnasTavernViewModel) {
        vm.phase = TavernPhase(rawValue: phase) ?? .dayIntro
        vm.act = act; vm.day = day; vm.runDay = runDay
        vm.bossTwist = TavernBossTwist(rawValue: bossTwist) ?? .none
        vm.dayScore = dayScore
        vm.rollsLeft = rollsLeft
        vm.customersServedToday = customersServedToday
        vm.currentPatronID = currentPatronID
        vm.customerNeed = TavernNeed(rawValue: customerNeed) ?? .food
        vm.customerLine = customerLine
        vm.ennaLine = ennaLine
        vm.handLive = handLive
        vm.chosenRow = chosenRow.flatMap { TavernRowID(rawValue: $0) }
        vm.serveMode = TavernServeMode(rawValue: serveMode) ?? .dice
        vm.dice = dice; vm.deck = deck; vm.hand = hand

        var icons: [TavernRowID: TavernNeed] = [:]
        for (k, v) in rowIcons {
            if let row = TavernRowID(rawValue: k), let need = TavernNeed(rawValue: v) {
                icons[row] = need
            }
        }
        for row in EnnasTavernDatabase.rows where icons[row.id] == nil {
            icons[row.id] = TavernNeed.allCases.randomElement() ?? .food
        }
        vm.rowIcons = icons
        vm.dayMode = TavernServeMode(rawValue: dayMode) ?? .dice
        vm.rowLevels = Dictionary(uniqueKeysWithValues: rowLevels.compactMap { k, val in TavernRowID(rawValue: k).map { ($0, val) } })
        vm.rowServeCounts = Dictionary(uniqueKeysWithValues: rowServeCounts.compactMap { k, val in TavernRowID(rawValue: k).map { ($0, val) } })
        vm.permanentRowLevels = Dictionary(uniqueKeysWithValues: permanentRowLevels.compactMap { k, val in TavernRowID(rawValue: k).map { ($0, val) } })
        vm.matchesThisRun = matchesThisRun
        vm.levelUpsThisDay = levelUpsThisDay
        vm.leveledTodayRows = Set(leveledTodayRows.compactMap { TavernRowID(rawValue: $0) })
        vm.nextDayBonusRolls = nextDayBonusRolls

        vm.tokens = tokens
        vm.skillIDs = skillIDs
        vm.serviceLog = serviceLog
        vm.interludeTokensEarned = interludeTokensEarned
        vm.minigameDone = minigameDone
        vm.showNightShop = minigameDone
        vm.bjHandsPlayed = bjHandsPlayed
        vm.shopSkillIDs = shopSkillIDs
        vm.nightPickDone = nightPickDone
        vm.pendingCollectibles = pendingCollectibles
        vm.endingID = endingID
        vm.genericEndText = genericEndText
        vm.dayResolvedPass = dayResolvedPass
        vm.maxRollsSpentOnOneCustomer = maxRollsSpentOnOneCustomer
        vm.rollsSpentThisCustomer = rollsSpentThisCustomer
        vm.servedHighCardInAct1 = servedHighCardInAct1
        vm.bigServesToday = bigServesToday
        vm.todayRowKinds = Set(todayRowKinds.compactMap { TavernRowID(rawValue: $0) })

        vm.reactionLine = reactionLine
        vm.reactionPoints = reactionPoints
        vm.reactionMatched = reactionMatched
        vm.showReaction = showReaction
        vm.showCollectible = !showReaction && !vm.pendingCollectibles.isEmpty
    }

    static func save(vm: EnnasTavernViewModel) { SaveManager.save(snapshot(from: vm), key: saveKey) }
    static func load() -> EnnasTavernSave? { SaveManager.load(EnnasTavernSave.self, key: saveKey) }
    static func deleteSave() { SaveManager.deleteSave(key: saveKey) }
    static func hasSave() -> Bool { SaveManager.hasSave(key: saveKey) }
}

// ============================================================
// 📕 LEDGER OF ENDINGS — persists across ALL runs
// ============================================================
enum TavernLedger {
    static let key = "tavern_ledger"
    static func found() -> Set<String> { Set(SaveManager.load([String].self, key: key) ?? []) }
    static func add(_ endingID: String) {
        var all = found()
        guard !all.contains(endingID) else { return }
        all.insert(endingID)
        SaveManager.save(Array(all).sorted(), key: key)
    }
}
