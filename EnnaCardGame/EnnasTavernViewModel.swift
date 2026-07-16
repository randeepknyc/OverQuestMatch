//
//  EnnasTavernViewModel.swift
//  OverQuestMatch3 — Enna's Tavern
//
//  All game logic. You shouldn't need to edit this file —
//  content lives in EnnasTavernDatabase.swift, numbers in EnnasTavernConfig.
//
//  🎲 RANDOMNESS: uniform system RNG only. No player-favoring weighting.
//

import SwiftUI
import Observation

// ============================================================
// GAME PHASE — which screen is showing
// ============================================================
enum TavernPhase: String, Codable {
    case dayIntro      // morning: quota posted, boss banner
    case modeSelect    // Act 3 only: dice or cards for this patron
    case serving       // the main play screen
    case dayResult     // day cleared (non-boss days)
    case market        // the caravan
    case promotion     // ★ act-clear cutscene
    case epilogue      // run won — final ending
    case gameOver      // run lost — fail vignette
}

@Observable
class EnnasTavernViewModel {

    // ============================================================
    // RUN STATE
    // ============================================================
    var phase: TavernPhase = .dayIntro
    var act = 1
    var day = 1              // 1...3 within the act
    var runDay = 1           // 1...9 across the whole run
    var serveIndex = 0       // patrons served today
    var patronsToday = EnnasTavernConfig.basePatronsPerDay
    var dayScore = 0
    var coin = EnnasTavernConfig.startingCoin
    var bossTwist: TavernBossTwist = .none

    // ---- serve state ----
    var serveMode: TavernServeMode = .dice
    var dice: [TavernDie] = []
    var rollsLeft = 0
    var deck: [TavernPlayingCard] = []
    var hand: [TavernPlayingCard] = []
    var redrawsLeft = 0
    var currentPatronID: String = EnnasTavernDatabase.patrons[0].id

    // ---- menu state ----
    var rowLevels: [TavernRowID: Int] = [:]      // 1...3
    var bankedToday: Set<TavernRowID> = []

    // ---- jokers ----
    var jokerIDs: [String] = []
    var spitePrimed = false
    var gremlockUsedToday = false
    var firstBankDoneToday = false

    // ---- overlays ----
    var showReaction = false
    var reactionLine = ""
    var reactionPoints = 0
    var pendingCollectibles: [String] = []       // ending IDs waiting to display
    var showCollectible = false

    // ---- end screens ----
    var endingID: String? = nil                  // which of the 21 is showing
    var genericEndText: String? = nil            // fallback text when none fits
    var lastCoinEarned = 0

    // ---- market ----
    var marketOffers: [TavernMarketOffer] = []
    var merchantID: String = EnnasTavernDatabase.merchants[0].id
    var swordOffered = false

    // ---- ending-trigger trackers ----
    var todayServesUsedAllRerolls: [Bool] = []
    var act1BankedNodEver = false
    var today35PlusCount = 0
    var todayRowKinds: Set<TavernRowID> = []
    var dayResolvedPass = false                  // routes overlay dismissal

    // ============================================================
    // INIT / RUN CONTROL
    // ============================================================
    init() {
        startRun()
    }

    func startRun() {
        act = 1; day = 1; runDay = 1
        coin = EnnasTavernConfig.startingCoin
        jokerIDs = []
        rowLevels = [:]
        for row in EnnasTavernDatabase.rows { rowLevels[row.id] = 1 }
        spitePrimed = false
        swordOffered = false
        act1BankedNodEver = false
        endingID = nil
        genericEndText = nil
        pendingCollectibles = []
        showCollectible = false
        showReaction = false
        setupDay()
        phase = .dayIntro
        EnnasTavernSave.save(vm: self)
    }

    // ============================================================
    // DAY SETUP
    // ============================================================
    func setupDay() {
        dayScore = 0
        serveIndex = 0
        bankedToday = []
        gremlockUsedToday = false
        firstBankDoneToday = false
        todayServesUsedAllRerolls = []
        today35PlusCount = 0
        todayRowKinds = []
        dayResolvedPass = false
        bossTwist = computeTwist()

        patronsToday = EnnasTavernConfig.basePatronsPerDay
        if !jokersDisabledToday {
            patronsToday += activeJokers.reduce(0) { $0 + $1.extraPatronsPerDay }
            if day == 1 {
                patronsToday += activeJokers.reduce(0) { $0 + $1.extraPatronsFirstDayOfAct }
            }
            // Morning coin (Noamron etc.)
            let morning = activeJokers.reduce(0) { $0 + $1.morningCoin }
            coin += morning
        }
    }

    private func computeTwist() -> TavernBossTwist {
        guard day == EnnasTavernConfig.daysPerAct else { return .none }
        switch act {
        case 1: return .tiredArms
        case 2: return .inspector
        default:
            return [TavernBossTwist.guildAudit, .theCarriage, .watchCaptain].randomElement() ?? .guildAudit
        }
    }

    // ============================================================
    // COMPUTED HELPERS
    // ============================================================
    var activeJokers: [TavernJoker] {
        jokerIDs.compactMap { EnnasTavernDatabase.joker($0) }
    }

    /// Boss "Watch Captain" switches every joker off for the day.
    var jokersDisabledToday: Bool { bossTwist == .watchCaptain }

    var currentPatron: TavernPatron { EnnasTavernDatabase.patron(currentPatronID) }
    var currentMerchant: TavernMerchant { EnnasTavernDatabase.merchant(merchantID) }

    /// THE ASK — the quota this patron's hand must meet (Deviled Dice style).
    /// After joker multipliers and boss twist. Overage counts for nothing.
    var serveQuota: Int {
        let base = Double(EnnasTavernConfig.serveQuotas[act - 1][day - 1])
        var mult = 1.0
        if !jokersDisabledToday {
            for j in activeJokers { mult *= j.thresholdMultiplier }
        }
        if bossTwist == .theCarriage { mult *= 1.25 }
        return max(1, Int((base * mult).rounded()))
    }

    /// Do-overs for this serve (rerolls for dice, redraws for cards).
    var doOversPerServe: Int {
        var n = EnnasTavernConfig.baseRerolls
        if !jokersDisabledToday {
            n += activeJokers.reduce(0) { $0 + $1.extraRerolls }
        }
        if bossTwist == .tiredArms { n -= 1 }
        return max(0, n)
    }

    /// Which menu rows the current dice/cards qualify for right now.
    var qualifyingRows: Set<TavernRowID> {
        var rows: Set<TavernRowID>
        switch serveMode {
        case .dice:  rows = EnnasTavernDatabase.qualifyingRows(dice: dice.map { $0.value })
        case .cards: rows = EnnasTavernDatabase.qualifyingRows(cards: hand)
        }
        if bossTwist == .inspector { rows.remove(.nod) }   // Rent Day: no safety net
        return rows
    }

    /// Menu rows shown for the current mode.
    var visibleRows: [TavernRow] {
        EnnasTavernDatabase.rows.filter {
            serveMode == .dice ? $0.worksWithDice : $0.worksWithCards
        }
    }

    func rowLevel(_ id: TavernRowID) -> Int { rowLevels[id] ?? 1 }

    /// Can this row be banked right now? The hand must QUALIFY for the row
    /// AND the row's points must MEET THE ASK — no banking short.
    func canBank(_ row: TavernRow) -> Bool {
        guard qualifyingRows.contains(row.id) else { return false }
        if !row.repeatable && bankedToday.contains(row.id) { return false }
        if row.repeatable && bossTwist == .inspector && row.id == .nod { return false }
        return previewPoints(row.id) >= serveQuota
    }

    /// Qualifies, is unbanked, but scores below the ask (shown dimmed).
    func qualifiesButShort(_ row: TavernRow) -> Bool {
        guard qualifyingRows.contains(row.id) else { return false }
        if !row.repeatable && bankedToday.contains(row.id) { return false }
        if row.repeatable && bossTwist == .inspector && row.id == .nod { return false }
        return previewPoints(row.id) < serveQuota
    }

    /// True if at least one menu row can currently be served.
    var hasAnyBankableRow: Bool {
        visibleRows.contains { canBank($0) }
    }

    // ============================================================
    // SCORING
    // ============================================================
    /// Points this row would score RIGHT NOW (shown as preview and used by bank()).
    func previewPoints(_ rowID: TavernRowID) -> Int {
        let row = EnnasTavernDatabase.row(rowID)
        var base = EnnasTavernConfig.rowValue(base: row.baseValue, level: rowLevel(rowID))

        if jokersDisabledToday {
            return applyGuildAudit(rowID: rowID, points: base)
        }

        // Gremlock: first Nod of the day scores a flat 25 base
        if rowID == .nod, !gremlockUsedToday,
           activeJokers.contains(where: { $0.gremlockNod }) {
            base = 25
        }

        var pts = Double(base)

        // Flat row bonuses
        for j in activeJokers {
            if let bonus = j.rowFlatBonuses[rowID] { pts += Double(bonus) }
        }
        // Flat per-bank bonuses
        pts += Double(activeJokers.reduce(0) { $0 + $1.flatBonusPerBank })
        // Spite
        if spitePrimed { pts += 15 }
        // Multipliers
        for j in activeJokers {
            if let mult = j.rowMultipliers[rowID] { pts *= mult }
            if !firstBankDoneToday { pts *= j.firstBankMultiplier }
        }

        return applyGuildAudit(rowID: rowID, points: Int(pts.rounded()))
    }

    private func applyGuildAudit(rowID: TavernRowID, points: Int) -> Int {
        if bossTwist == .guildAudit,
           rowID == .nod || rowID == .pair || rowID == .twoPair {
            return 0
        }
        return points
    }

    // ============================================================
    // SERVE FLOW
    // ============================================================
    /// Called from the Day Intro screen ("Open the doors").
    func openDoors() {
        startNextServe()
    }

    private func startNextServe() {
        // Pick a patron (uniform random, no immediate repeat)
        let pool = EnnasTavernDatabase.patrons.filter { $0.id != currentPatronID }
        currentPatronID = (pool.randomElement() ?? EnnasTavernDatabase.patrons[0]).id

        if act == 3 {
            phase = .modeSelect
        } else {
            serveMode = (act == 1) ? .dice : .cards
            beginServe()
        }
    }

    /// Act 3: player picked dice or cards.
    func chooseMode(_ mode: TavernServeMode) {
        serveMode = mode
        beginServe()
    }

    private func beginServe() {
        switch serveMode {
        case .dice:
            dice = (0..<5).map { TavernDie(id: $0, value: Int.random(in: 1...6), locked: false) }
            rollsLeft = doOversPerServe
            HapticManager.shared.diceRollRattle(duration: 0.8)
        case .cards:
            deck = Self.freshDeck()
            hand = []
            for _ in 0..<5 { hand.append(deck.removeFirst()) }
            redrawsLeft = doOversPerServe
            HapticManager.shared.buttonPressed()
        }
        phase = .serving
    }

    /// A fair, fully shuffled 52-card deck. Uniform shuffle — no weighting.
    private static func freshDeck() -> [TavernPlayingCard] {
        var cards: [TavernPlayingCard] = []
        var idx = 0
        for suit in TavernCardSuit.allCases {
            for rank in 2...14 {
                cards.append(TavernPlayingCard(id: idx, rank: rank, suit: suit, held: false))
                idx += 1
            }
        }
        return cards.shuffled()
    }

    // ---- dice interactions ----
    func toggleLock(_ dieID: Int) {
        guard let i = dice.firstIndex(where: { $0.id == dieID }) else { return }
        dice[i].locked.toggle()
        HapticManager.shared.tileSelected()
    }

    func reroll() {
        guard rollsLeft > 0 else { return }
        rollsLeft -= 1
        for i in dice.indices where !dice[i].locked {
            dice[i].value = Int.random(in: 1...6)
        }
        HapticManager.shared.diceRollRattle(duration: 0.6)
    }

    // ---- card interactions ----
    func toggleHold(_ cardID: Int) {
        guard let i = hand.firstIndex(where: { $0.id == cardID }) else { return }
        hand[i].held.toggle()
        HapticManager.shared.tileSelected()
    }

    func redraw() {
        guard redrawsLeft > 0 else { return }
        redrawsLeft -= 1
        for i in hand.indices where !hand[i].held {
            if !deck.isEmpty { hand[i] = deck.removeFirst() }
        }
        HapticManager.shared.swapCompleted()
    }

    // ============================================================
    // BANKING (serving the patron)
    // ============================================================
    func bank(_ rowID: TavernRowID) {
        let row = EnnasTavernDatabase.row(rowID)
        guard phase == .serving, canBank(row) else { return }

        let pts = previewPoints(rowID)

        // Consume/refresh one-shot joker states
        if !jokersDisabledToday {
            if rowID == .nod, !gremlockUsedToday,
               activeJokers.contains(where: { $0.gremlockNod }) {
                gremlockUsedToday = true
            }
            let hasSpite = activeJokers.contains(where: { $0.spite })
            spitePrimed = hasSpite && pts <= 10
        }
        firstBankDoneToday = true

        dayScore += pts            // running tally — flavor/stats only now
        if !row.repeatable { bankedToday.insert(rowID) }
        serveIndex += 1

        // ---- ending-trigger tracking ----
        todayRowKinds.insert(rowID)
        let usedAll = (serveMode == .dice) ? (rollsLeft == 0) : (redrawsLeft == 0)
        todayServesUsedAllRerolls.append(usedAll)
        if pts >= 35 {
            today35PlusCount += 1
            if act == 2 && today35PlusCount == 3 { queueCollectible("act2_5") }  // The Chair Incident
        }
        if act == 1 && pts >= serveQuota * 3 { queueCollectible("act1_3") }       // Audited
        if act == 1 && rowID == .nod { act1BankedNodEver = true }
        if act == 1 && (rowID == .five || rowID == .straightFlush) {
            queueCollectible("act1_6")                                            // She Knows Too Much
        }

        // Reaction
        reactionPoints = pts
        reactionLine = EnnasTavernDatabase.reactionLine(points: pts, patronName: currentPatron.name)
        showReaction = true
        if pts >= 80 { HapticManager.shared.victory() } else { HapticManager.shared.matchDetected(tileCount: 3) }

        EnnasTavernSave.save(vm: self)
    }

    /// THE LOSE STATE: nothing on the menu can meet this patron's ask.
    /// Conceding ends the run with a fail vignette (Kalma/Deviled Dice rules).
    func comeUpShort() {
        guard phase == .serving else { return }
        let usedAll = (serveMode == .dice) ? (rollsLeft == 0) : (redrawsLeft == 0)
        todayServesUsedAllRerolls.append(usedAll)
        failRun()
    }

    /// "Next" tapped on the reaction overlay.
    func dismissReaction() {
        showReaction = false
        advanceOverlays()
    }

    /// "Continue" tapped on a collectible-interlude overlay.
    func dismissCollectible() {
        if !pendingCollectibles.isEmpty { pendingCollectibles.removeFirst() }
        advanceOverlays()
    }

    private func advanceOverlays() {
        if !pendingCollectibles.isEmpty {
            showCollectible = true
            return
        }
        showCollectible = false
        if dayResolvedPass {
            afterDayPass()
        } else if serveIndex < patronsToday {
            startNextServe()
        } else {
            resolveDay()
        }
    }

    /// Log a collectible-interlude ending. The full-screen "discovered"
    /// moment only plays the FIRST time ever (the Ledger persists across runs).
    private func queueCollectible(_ id: String) {
        guard !TavernLedger.found().contains(id) else { return }
        TavernLedger.add(id)
        pendingCollectibles.append(id)
    }

    // ============================================================
    // DAY END
    // ============================================================
    private func resolveDay() {
        // Every patron's ask was met (misses end the run immediately),
        // so reaching here means the day is cleared.
        var earned = EnnasTavernConfig.dayClearCoin
        // Noamron's mischief: 20% chance something goes missing
        if !jokersDisabledToday,
           activeJokers.contains(where: { $0.noamronRisk }),
           Int.random(in: 1...5) == 1 {
            earned = max(0, earned - 3)
        }
        coin += earned
        lastCoinEarned = earned
        dayResolvedPass = true

        // Day-end collectibles
        if act == 2 && todayServesUsedAllRerolls.count >= patronsToday
            && todayServesUsedAllRerolls.allSatisfy({ $0 }) { queueCollectible("act2_4") }   // Fire Hazard
        if act == 2 && !todayRowKinds.isEmpty
            && todayRowKinds.isSubset(of: [.pair, .trips, .four, .five]) {
            queueCollectible("act2_6")                                                        // Alphabetized
        }
        if act == 1 && day == EnnasTavernConfig.daysPerAct && !act1BankedNodEver {
            queueCollectible("act1_5")                                                        // Beloved (Derogatory)
        }

        HapticManager.shared.victory()
        if !pendingCollectibles.isEmpty {
            showCollectible = true
            EnnasTavernSave.save(vm: self)
        } else {
            afterDayPass()
        }
    }

    private func afterDayPass() {
        dayResolvedPass = false
        if day == EnnasTavernConfig.daysPerAct {
            if act < 3 {
                // ★ Promotion cutscene
                endingID = (act == 1) ? "act1_7" : "act2_7"
                if let id = endingID { TavernLedger.add(id) }
                phase = .promotion
                EnnasTavernSave.save(vm: self)
            } else {
                resolveEpilogue()   // deletes the save — the run is over
            }
        } else {
            phase = .dayResult
            EnnasTavernSave.save(vm: self)
        }
    }

    /// From the Day Result screen or the Promotion screen → the caravan.
    func continueToMarket() {
        enterMarket()
    }

    // ============================================================
    // FAILURE — choose the vignette
    // ============================================================
    private func failRun() {
        endingID = nil
        genericEndText = nil

        switch act {
        case 1:
            if runDay == 1 {
                endingID = "act1_1"                                   // The Nap of No Return
            } else if coin == 0 {
                endingID = "act1_2"                                   // Gainful Unemployment
            } else if !todayServesUsedAllRerolls.isEmpty
                        && todayServesUsedAllRerolls.allSatisfy({ $0 }) {
                endingID = "act1_4"                                   // Banned From Her Own Story
            }
        case 2:
            if day == EnnasTavernConfig.daysPerAct {
                endingID = "act2_1"                                   // Repossessed
            } else if coin == 0 {
                endingID = "act2_2"                                   // The Soup Is Just Hot Water Now
            } else if !activeJokers.contains(where: { $0.actClass == 2 }) {
                endingID = "act2_3"                                   // Echo Tavern
            }
        default:
            switch bossTwist {
            case .guildAudit:
                if !activeJokers.contains(where: { $0.faction == .guild }) {
                    endingID = "act3_1"                               // Union Trouble
                }
            case .theCarriage:
                endingID = "act3_3"                                   // The Carriage
            case .watchCaptain:
                endingID = "act3_5"                                   // Frequent Flier
            default: break
            }
        }

        if let id = endingID {
            TavernLedger.add(id)
        } else {
            genericEndText = EnnasTavernDatabase.genericFailTexts[act]
        }

        HapticManager.shared.defeat()
        phase = .gameOver
        EnnasTavernSave.deleteSave()
    }

    // ============================================================
    // VICTORY — choose the epilogue
    // ============================================================
    private func resolveEpilogue() {
        var counts: [TavernFaction: Int] = [:]
        for j in activeJokers where j.faction != .none {
            counts[j.faction, default: 0] += 1
        }

        endingID = nil
        genericEndText = nil

        if let big = counts.first(where: { $0.value >= 3 }) {
            switch big.key {
            case .guild:  endingID = "act3_2"     // Hostile Takeover (Friendly)
            case .nobles: endingID = "act3_4"     // Gentrified
            case .watch:  endingID = "act3_6"     // The Precinct
            default: break
            }
        }
        if endingID == nil {
            let factionCounts = [TavernFaction.guild, .nobles, .commons, .watch].map { counts[$0] ?? 0 }
            let balanced = factionCounts.allSatisfy { $0 <= 1 } || factionCounts.allSatisfy { $0 >= 1 }
            if balanced {
                endingID = "act3_7"                // ★ The Quiet Pint (TRUE ENDING)
            } else {
                genericEndText = EnnasTavernDatabase.genericVictoryText
            }
        }

        if let id = endingID { TavernLedger.add(id) }
        HapticManager.shared.victory()
        phase = .epilogue
        EnnasTavernSave.deleteSave()
    }

    // ============================================================
    // THE MARKET (between days)
    // ============================================================
    private func enterMarket() {
        merchantID = (EnnasTavernDatabase.merchants.randomElement() ?? EnnasTavernDatabase.merchants[0]).id
        generateOffers()
        phase = .market
        EnnasTavernSave.save(vm: self)
    }

    func generateOffers() {
        var offers: [TavernMarketOffer] = []

        // The Sword — a one-time special in the very first market of the run
        if !swordOffered, let sword = EnnasTavernDatabase.joker("sword") {
            offers.append(TavernMarketOffer(kind: .joker(sword), price: sword.cost))
            swordOffered = true
        }

        // Two random unowned jokers of this act's class or earlier (never the Sword)
        let pool = EnnasTavernDatabase.jokers.filter {
            !$0.unique && $0.actClass <= act && !jokerIDs.contains($0.id)
        }.shuffled()
        for j in pool.prefix(2) {
            offers.append(TavernMarketOffer(kind: .joker(j), price: j.cost))
        }

        // One menu upgrade (a random row that isn't maxed)
        let upgradable = EnnasTavernDatabase.rows.filter { rowLevel($0.id) < 3 }.shuffled()
        if let pick = upgradable.first {
            let level = rowLevel(pick.id)
            offers.append(TavernMarketOffer(kind: .rowUpgrade(pick.id),
                                            price: EnnasTavernConfig.upgradeCosts[level - 1]))
        }

        marketOffers = offers
    }

    func buy(_ offer: TavernMarketOffer) {
        guard coin >= offer.price else { return }
        switch offer.kind {
        case .joker(let j):
            guard jokerIDs.count < EnnasTavernConfig.maxJokers, !jokerIDs.contains(j.id) else { return }
            jokerIDs.append(j.id)
        case .rowUpgrade(let rowID):
            guard rowLevel(rowID) < 3 else { return }
            rowLevels[rowID] = rowLevel(rowID) + 1
        }
        coin -= offer.price
        marketOffers.removeAll { $0.id == offer.id }
        HapticManager.shared.buttonPressed()
        EnnasTavernSave.save(vm: self)
    }

    func rerollShop() {
        guard coin >= EnnasTavernConfig.shopRerollCost else { return }
        coin -= EnnasTavernConfig.shopRerollCost
        generateOffers()
        HapticManager.shared.buttonPressed()
        EnnasTavernSave.save(vm: self)
    }

    /// "Close up for the night" — advance to the next day (or act).
    func leaveMarket() {
        if day < EnnasTavernConfig.daysPerAct {
            day += 1
        } else {
            act += 1
            day = 1
        }
        runDay += 1
        setupDay()
        phase = .dayIntro
        EnnasTavernSave.save(vm: self)
    }

    // ============================================================
    // RESTART (Ledger of Endings persists across runs)
    // ============================================================
    func restart() {
        EnnasTavernSave.deleteSave()
        startRun()
    }
}
