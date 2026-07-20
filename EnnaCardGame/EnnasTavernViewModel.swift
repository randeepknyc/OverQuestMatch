//
//  EnnasTavernViewModel.swift
//  OverQuestMatch3 — Enna's Tavern (v4 — the OPERATING COSTS build)
//
//  THE DAY: roll budget (5). Customer sits, states a need (food/tavern/
//  support) — their opening roll costs 1. Rerolls cost 1 each. Serving is
//  FREE: best pattern in your tapped selection (or all five), ×2 if the
//  dish's icon matches the need. Meet operating costs → day clears early.
//  Serve at zero rolls while short → the tavern goes dark.
//
//  🎲 RANDOMNESS: uniform system RNG only.
//

import SwiftUI
import Observation

enum TavernPhase: String, Codable {
    case dayIntro, serving, dayResult, interlude, promotion, epilogue, gameOver
}

@Observable
class EnnasTavernViewModel {

    // ---- run position ----
    var phase: TavernPhase = .dayIntro
    var act = 1
    var day = 1
    var runDay = 1
    var bossTwist: TavernBossTwist = .none

    // ---- the day ----
    var dayScore = 0                 // progress toward operating costs
    var rollsLeft = 0                // 🎲 the day's currency
    var customersServedToday = 0

    // ---- the current customer ----
    var currentPatronID: String = EnnasTavernDatabase.patrons[0].id
    var customerNeed: TavernNeed = .food
    var customerLine: String = ""
    var ennaLine: String = ""
    var handLive = false             // a rolled hand is on the table
    var chosenRow: TavernRowID? = nil // 🎯 the hand the player tapped to submit

    // ---- the table ----
    var serveMode: TavernServeMode = .dice
    var dice: [TavernDie] = []
    var deck: [TavernPlayingCard] = []
    var hand: [TavernPlayingCard] = []
    var rollStamp = 0                // dice scene trigger (cosmetic)
    var lastRolledDieIDs: Set<Int> = []

    // ---- menu icons (reassignable free in Skills) ----
    var rowIcons: [TavernRowID: TavernNeed] = [:]

    // ---- v5: leveling + scoring state ----
    var dayMode: TavernServeMode = .dice        // locked at dawn; thresholds/prices follow it
    var rowLevels: [TavernRowID: Int] = [:]     // today's levels (reset at dawn to permanent)
    var rowServeCounts: [TavernRowID: Int] = [:]
    var permanentRowLevels: [TavernRowID: Int] = [:]   // locked in via night boons
    var matchesThisRun = 0
    var levelUpsThisDay = 0
    var leveledTodayRows: Set<TavernRowID> = []
    var nextDayBonusRolls = 0                   // from the Embers trigger

    // ---- progression ----
    var tokens = 0
    var skillIDs: [String] = []
    var serviceLog: [TavernServiceEntry] = []

    // ---- interlude (night school) ----
    var interludeTokensEarned = 0
    var minigameDone = false
    var showNightShop = false        // shop appears a beat AFTER the result
    var bjPlayerCards: [TavernPlayingCard] = []
    var bjDealerCards: [TavernPlayingCard] = []
    var bjDeck: [TavernPlayingCard] = []
    var bjHandsPlayed = 0
    var bjMessage = ""
    var bjHandOver = true
    var schoolDice: [Int] = []
    var schoolDisplayDice: [TavernDie] = []
    var schoolRollStamp = 0
    var schoolDiceThrown = false
    var schoolResultIn = false
    var schoolResultLabel = ""       // e.g. "2 Pair → 2 tokens"
    var shopSkillIDs: [String] = []
    var nightPickDone = false

    // ---- overlays / endings ----
    var showReaction = false
    var reactionLine = ""
    var reactionPoints = 0
    var reactionMatched = false
    var reactionBase = 0
    var reactionMult: Double = 1
    var reactionSteps: [TavernScoreStep] = []

    // ---- 🎰 live in-place scoring (Kalma-style, no overlay) ----
    var scoringActive = false
    var scoreCoins = 0
    var scoreMultDisplay: Double = 1
    var scoreTotal = 0
    var showServeResultLine = false     // customer bubble swaps to their reaction
    private var skipScoring = false
    private var effectiveRowAtServe: TavernRowID? = nil
    var reactionLevelUpText: String? = nil
    var reactionRollBonus = 0
    var pendingCollectibles: [String] = []
    var showCollectible = false
    var endingID: String? = nil
    var genericEndText: String? = nil
    var dayResolvedPass = false

    // ---- ending trackers ----
    var maxRollsSpentOnOneCustomer = 0
    var rollsSpentThisCustomer = 0
    var servedHighCardInAct1 = false
    var bigServesToday = 0
    var todayRowKinds: Set<TavernRowID> = []

    // ============================================================
    init() { startRun() }

    func startRun() {
        act = 1; day = 1; runDay = 1
        tokens = 0
        skillIDs = []
        serviceLog = []
        permanentRowLevels = [:]
        matchesThisRun = 0
        nextDayBonusRolls = 0
        servedHighCardInAct1 = false
        maxRollsSpentOnOneCustomer = 0
        endingID = nil; genericEndText = nil
        pendingCollectibles = []; showCollectible = false; showReaction = false
        assignRowIcons()
        setupDay()
        phase = .dayIntro
        EnnasTavernSave.save(vm: self)
    }

    /// Random icon per menu row (player reassigns free in Skills).
    private func assignRowIcons() {
        rowIcons = [:]
        for row in EnnasTavernDatabase.rows {
            rowIcons[row.id] = TavernNeed.allCases.randomElement() ?? .food
        }
    }

    func setupDay() {
        dayScore = 0
        customersServedToday = 0
        bigServesToday = 0
        todayRowKinds = []
        rollsSpentThisCustomer = 0
        dayResolvedPass = false
        handLive = false
        dayMode = TavernSettings.playMode == .cards ? .cards : .dice
        rowLevels = permanentRowLevels          // dawn: only locked-in levels survive
        rowServeCounts = [:]
        levelUpsThisDay = 0
        leveledTodayRows = []
        bossTwist = (day == EnnasTavernConfig.daysPerAct) ? actBoss() : .none
        rollsLeft = rollBudget + nextDayBonusRolls
        nextDayBonusRolls = 0
    }

    private func actBoss() -> TavernBossTwist {
        switch act {
        case 1: return .tiredArms
        case 2: return .inspector
        default: return [TavernBossTwist.guildAudit, .theCarriage, .watchCaptain].randomElement() ?? .guildAudit
        }
    }

    // ============================================================
    // COMPUTED
    // ============================================================
    var activeSkills: [TavernSkill] {
        guard !skillsDisabledToday else { return [] }
        return skillIDs.compactMap { EnnasTavernDatabase.skill($0) }
            .filter { $0.mode == nil || $0.mode == dayMode }
    }
    var skillsDisabledToday: Bool { bossTwist == .watchCaptain }
    var currentPatron: TavernPatron { EnnasTavernDatabase.patron(currentPatronID) }

    var rollBudget: Int {
        var n = EnnasTavernConfig.baseRollBudget + EnnasTavernConfig.cardsExtraRolls(dayMode)
        if bossTwist == .tiredArms { n -= 1 }
        return max(1, n)
    }

    var operatingCosts: Int {
        var c = Double(EnnasTavernConfig.operatingCosts(act: act, day: day, mode: dayMode))
        if bossTwist == .theCarriage { c *= 1.25 }
        let cut = activeSkills.reduce(0.0) { $0 + $1.costCut }
        c *= (1.0 - min(0.5, cut))
        return max(1, Int(c.rounded()))
    }

    /// Costs met = day cleared. The thresholds are sized so this
    /// typically takes 2-3 customers; a one-serve clear is a jackpot.
    var dayCleared: Bool { dayScore >= operatingCosts }

    /// The hand's multiplier today: base ladder + 1 per level.
    func rowMult(_ row: TavernRowID) -> Int {
        EnnasTavernConfig.handMult(row, mode: dayMode) + (rowLevels[row] ?? 0)
    }

    /// 💰 COINS — what the table itself is worth. Dice: sum of all five.
    /// Cards: sum of the best five ranks of the seven.
    var tableCoins: Int {
        switch serveMode {
        case .dice:  return dice.reduce(0) { $0 + $1.value }
        case .cards: return hand.map { $0.rank }.sorted().suffix(5).reduce(0, +)
        }
    }

    /// v6 SCORING — THE KALMA FORMULA. Coins = the table sum (+10 when
    /// the ask is fulfilled). Mult = the hand's ladder value (+levels),
    /// + act bonus, +1 match, + every skill. Bosses zero the mult.
    func breakdown(_ row: TavernRowID) -> (pts: Int, mult: Double, matched: Bool, total: Int) {
        let matched = rowIcon(row) == customerNeed
        var pts = tableCoins
        if matched { pts += EnnasTavernConfig.matchFlatBonus }

        var m = Double(rowMult(row)) + EnnasTavernConfig.actMultBonus(act: act)
        if matched { m += 1 }
        if bossTwist == .inspector && row == .nod { m = 0 }
        if bossTwist == .guildAudit && (row == .nod || row == .pair || row == .twoPair) { m = 0 }
        var zeroed = false
        for s in activeSkills {
            m += s.multEvery
            if matched { m += s.multOnMatch }
            if let x = s.multForNeed[rowIcon(row)] { m += x }
            if s.scalingMatchStep > 0 { m += Double(matchesThisRun / s.scalingMatchStep) }
            if s.scalingLevelUps { m += Double(levelUpsThisDay) }
            if s.lastCallMult > 0 && rollsLeft == 0 { m += s.lastCallMult }
            if s.mismatchZero && !matched { zeroed = true }
        }
        if zeroed { m = 0 }
        return (pts, m, matched, Int((Double(pts) * m).rounded()))
    }

    var anythingSelected: Bool {
        serveMode == .dice ? dice.contains { $0.selected } : hand.contains { $0.selected }
    }

    /// Every hand in the FULL table registers — tapping dice/cards marks
    /// them for the reroll only and never narrows what you can serve.
    var qualifyingRows: Set<TavernRowID> {
        guard handLive else { return [] }
        switch serveMode {
        case .dice:  return EnnasTavernDatabase.qualifyingRows(dice: dice.map { $0.value })
        case .cards: return EnnasTavernDatabase.qualifyingRows(cards: hand)
        }
    }

    var visibleRows: [TavernRow] {
        EnnasTavernDatabase.rows.filter {
            serveMode == .dice ? $0.worksWithDice : $0.worksWithCards
        }
    }

    /// Poker rank order — the default serve is always the HIGHEST hand
    /// on the table (tap a row to override with a cheaper one).
    private static let rowRank: [TavernRowID: Int] = [
        .nod: 0, .pair: 1, .twoPair: 2, .trips: 3, .straight: 4, .flush: 5,
        .fullHouse: 6, .four: 7, .five: 8, .straightFlush: 9, .royal: 10
    ]

    var bestRow: TavernRowID? {
        qualifyingRows.max { (Self.rowRank[$0] ?? 0) < (Self.rowRank[$1] ?? 0) }
    }

    /// What SERVE will actually submit: the player's tapped choice if it
    /// still qualifies, otherwise the best qualifying hand.
    var effectiveRow: TavernRowID? {
        if let c = chosenRow, qualifyingRows.contains(c) { return c }
        return bestRow
    }

    /// Tap a lit hand in the list to choose it; tap again to release
    /// back to auto-best. Non-qualifying hands don't respond.
    func chooseRow(_ id: TavernRowID) {
        guard qualifyingRows.contains(id) else { return }
        chosenRow = (chosenRow == id) ? nil : id
        HapticManager.shared.tileSelected()
    }

    var servePreview: Int {
        guard let b = effectiveRow else { return 0 }
        return previewPoints(b)
    }

    var servePreviewMatched: Bool {
        guard let b = effectiveRow else { return false }
        return rowIcons[b] == customerNeed
    }

    func rowIcon(_ id: TavernRowID) -> TavernNeed { rowIcons[id] ?? .food }

    func previewPoints(_ rowID: TavernRowID) -> Int {
        breakdown(rowID).total
    }

    /// 🎰 The cascade: every source of the score as its own labeled chip,
    /// in the order they slam in. KEEP IN SYNC with breakdown(_:).
    func scoreSteps(_ row: TavernRowID) -> [TavernScoreStep] {
        var out: [TavernScoreStep] = []
        var i = 0
        func add(_ label: String, _ detail: String, _ kind: Int, _ value: Double = 0) {
            out.append(TavernScoreStep(id: i, label: label, detail: detail, kind: kind, value: value)); i += 1
        }
        let bd = breakdown(row)
        let lvl = rowLevels[row] ?? 0
        add(EnnasTavernDatabase.row(row).name + String(repeating: "↑", count: lvl), "×\(rowMult(row))", 0)
        let actB = Int(EnnasTavernConfig.actMultBonus(act: act))
        if actB > 0 { add("ACT \(act)", "+\(actB)", 1, Double(actB)) }
        _ = bd
        if bd.matched { add("MATCH", "+1", 2, 1) }
        for s in activeSkills {
            if s.multEvery > 0 { add(s.name, "+\(Int(s.multEvery))", 3, s.multEvery) }
            if bd.matched && s.multOnMatch > 0 { add(s.name, "+\(Int(s.multOnMatch))", 3, s.multOnMatch) }
            if let x = s.multForNeed[rowIcon(row)], x > 0 { add(s.name, "+\(Int(x))", 3, x) }
            if s.scalingMatchStep > 0 {
                let b = matchesThisRun / s.scalingMatchStep
                if b > 0 { add(s.name, "+\(b)", 3, Double(b)) }
            }
            if s.scalingLevelUps && levelUpsThisDay > 0 { add(s.name, "+\(levelUpsThisDay)", 3, Double(levelUpsThisDay)) }
            if s.lastCallMult > 0 && rollsLeft == 0 { add(s.name, "+\(Int(s.lastCallMult))", 3, s.lastCallMult) }
            if s.mismatchZero && !bd.matched { add(s.name, "×0", 4) }
        }
        return out
    }

    // ============================================================
    // THE DAY LOOP
    // ============================================================
    func openDoors() {
        nextCustomer()
        phase = .serving
        EnnasTavernSave.save(vm: self)
    }

    /// A customer sits down and states their need. Their opening roll
    /// costs 1 from the budget (spent in rollFresh).
    private func nextCustomer() {
        let pool = EnnasTavernDatabase.patrons.filter { $0.id != currentPatronID }
        currentPatronID = (pool.randomElement() ?? EnnasTavernDatabase.patrons[0]).id
        customerNeed = TavernNeed.allCases.randomElement() ?? .food
        customerLine = EnnasTavernDatabase.needLine(for: customerNeed)
        ennaLine = EnnasTavernDatabase.ennaLine(for: customerNeed)
        rollsSpentThisCustomer = 0
        serveMode = dayMode
        rollFresh()
    }

    /// Spends 1 roll. Fresh five for the customer.
    private func rollFresh() {
        rollsLeft -= 1
        rollsSpentThisCustomer += 1
        handLive = true
        chosenRow = nil
        reactionLevelUpText = nil
        reactionRollBonus = 0
        switch serveMode {
        case .dice:
            dice = (0..<5).map { TavernDie(id: $0, value: Int.random(in: 1...6), selected: false) }
            lastRolledDieIDs = Set(dice.map { $0.id })
            rollStamp += 1
        case .cards:
            if deck.count < 16 { deck = Self.freshDeck() }
            var newHand: [TavernPlayingCard] = []
            for _ in 0..<EnnasTavernConfig.cardsHandSize { newHand.append(deck.removeFirst()) }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { hand = newHand }
            HapticManager.shared.swapCompleted()
        }
        EnnasTavernSave.save(vm: self)
    }

    private static func freshDeck() -> [TavernPlayingCard] {
        var cards: [TavernPlayingCard] = []
        var idx = 0
        for suit in TavernCardSuit.allCases {
            for rank in 2...14 {
                cards.append(TavernPlayingCard(id: idx, rank: rank, suit: suit, selected: false))
                idx += 1
            }
        }
        return cards.shuffled()
    }

    // ---- selection ----
    func toggleSelect(die dieID: Int) {
        guard let i = dice.firstIndex(where: { $0.id == dieID }) else { return }
        dice[i].selected.toggle()
        HapticManager.shared.tileSelected()
    }
    func toggleSelect(card cardID: Int) {
        guard let i = hand.firstIndex(where: { $0.id == cardID }) else { return }
        hand[i].selected.toggle()
        HapticManager.shared.tileSelected()
    }

    // ---- ROLL (reroll): costs 1 from the budget ----
    var canRoll: Bool {
        guard handLive, rollsLeft > 0 else { return false }
        switch TavernSettings.selectionMode {
        case .holdSelected:
            return serveMode == .dice ? dice.contains { !$0.selected } : hand.contains { !$0.selected }
        case .rerollSelected:
            return anythingSelected
        }
    }

    func rollAgain() {
        guard canRoll else { return }
        rollsLeft -= 1
        rollsSpentThisCustomer += 1
        let holdMode = TavernSettings.selectionMode == .holdSelected
        switch serveMode {
        case .dice:
            var rolled: Set<Int> = []
            for i in dice.indices where dice[i].selected != holdMode {
                dice[i].value = Int.random(in: 1...6)
                if !holdMode { dice[i].selected = false }
                rolled.insert(dice[i].id)
            }
            lastRolledDieIDs = rolled
            rollStamp += 1
        case .cards:
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                for i in hand.indices where hand[i].selected != holdMode {
                    if deck.isEmpty { deck = Self.freshDeck() }
                    var c = deck.removeFirst()
                    c.selected = false
                    hand[i] = c
                }
            }
            HapticManager.shared.swapCompleted()
        }
        EnnasTavernSave.save(vm: self)
    }

    // ============================================================
    // SERVE — free. Then: costs met → day clears · rolls left →
    // next customer · neither → the tavern goes dark.
    // ============================================================
    func serve() {
        guard phase == .serving, handLive else { return }

        // Evaluate FIRST — qualifyingRows returns nothing for a dead hand,
        // so handLive must stay true until the hand is scored.
        let row = effectiveRow
        let bd = row.map { breakdown($0) } ?? (pts: 0, mult: 1, matched: false, total: 0)
        let pts = bd.total
        let matched = bd.matched

        // 📈 leveling: third serve of a hand type today levels it (+50%)
        reactionLevelUpText = nil
        if let r = row {
            rowServeCounts[r, default: 0] += 1
            if rowServeCounts[r]! % EnnasTavernConfig.servesPerLevel == 0 {
                rowLevels[r, default: 0] += 1
                levelUpsThisDay += 1
                leveledTodayRows.insert(r)
                reactionLevelUpText = "\(EnnasTavernDatabase.row(r).name) leveled up! Now ×\(rowMult(r))."
            }
        }
        if matched { matchesThisRun += 1 }

        // 🎲 conditional roll triggers fire off the SERVED table
        reactionRollBonus = 0
        let table: [Int] = serveMode == .dice ? dice.map { $0.value } : hand.map { $0.rank }
        for s in activeSkills {
            guard let trig = s.rollTrigger else { continue }
            switch trig {
            case .allDifferent:
                if Set(table).count == table.count { rollsLeft += 1; reactionRollBonus += 1 }
            case .luckySum:
                let hit = serveMode == .dice ? table.reduce(0, +) == 20 : table.contains(14)
                if hit { rollsLeft += 1; reactionRollBonus += 1 }
            case .bookends:
                let hit = serveMode == .dice ? (table.contains(1) && table.contains(6))
                                             : (table.contains(2) && table.contains(14))
                if hit { rollsLeft += 1; reactionRollBonus += 1 }
            case .lastRollFuel:
                if rollsLeft == 0 { nextDayBonusRolls += 2 }
            }
        }

        handLive = false
        chosenRow = nil
        effectiveRowAtServe = row

        customersServedToday += 1
        maxRollsSpentOnOneCustomer = max(maxRollsSpentOnOneCustomer, rollsSpentThisCustomer)

        if let row = row {
            todayRowKinds.insert(row)
            if act == 1 && row == .nod { servedHighCardInAct1 = true }
            if act == 1 && (row == .five || row == .straightFlush) { queueCollectible("act1_6") }
        }
        if act == 1 && pts >= 160 { queueCollectible("act1_3") }          // Audited (v6 scale)
        if pts >= 130 {
            bigServesToday += 1
            if act == 2 && bigServesToday == 3 { queueCollectible("act2_5") }   // The Chair Incident
        }

        serviceLog.append(TavernServiceEntry(
            id: serviceLog.count,
            customerName: currentPatron.name,
            need: customerNeed,
            servedRow: row.map { EnnasTavernDatabase.row($0).name } ?? "Nothing",
            matched: matched,
            points: pts
        ))

        reactionPoints = pts
        reactionBase = bd.pts
        reactionMult = bd.mult
        reactionSteps = row.map { scoreSteps($0) } ?? []
        reactionMatched = matched
        reactionLine = matched
            ? EnnasTavernDatabase.reactionLine(points: max(pts, 60), patronName: currentPatron.name)
            : EnnasTavernDatabase.mismatchLine()
        EnnasTavernSave.save(vm: self)
        runScoringSequence(bd: bd, pts: pts)
    }

    /// 🎰 The live tally, Kalma-style: coins scroll in, each multiplier
    /// BANGS the ×box up, the total scrolls, the plaque banks it, the
    /// customer reacts — then the night moves on. Tap to fast-forward.
    private func runScoringSequence(bd: (pts: Int, mult: Double, matched: Bool, total: Int), pts: Int) {
        scoringActive = true
        skipScoring = false
        scoreCoins = 0
        scoreMultDisplay = 0
        scoreTotal = 0
        Task { @MainActor in
            func snooze(_ seconds: Double) async {
                var left = skipScoring ? 0.03 : seconds
                while left > 0 {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    left -= 0.05
                    if skipScoring { left = min(left, 0.03) }
                }
            }
            await snooze(0.30)
            scoreCoins = bd.pts                                   // 💰 coins scroll UP
            HapticManager.shared.tileTapped()
            await snooze(0.75)

            // 💥 The mult never jumps — it PUNCHES up by 1s. A ×7 hand
            // goes bam-bam-bam-bam-bam-bam-bam, tick haptic per step,
            // heavier thump when each source finishes landing.
            func punchMult(to target: Double) async {
                while scoreMultDisplay < target - 0.001 {
                    scoreMultDisplay += 1
                    HapticManager.shared.tileTapped()
                    await snooze(0.10)
                }
                scoreMultDisplay = target
                HapticManager.shared.matchDetected(tileCount: 4)
            }
            if let r = effectiveRowAtServe {                      // the hand itself
                await punchMult(to: Double(rowMult(r)))
                await snooze(0.22)
            }
            for step in reactionSteps where step.kind >= 1 && step.value > 0 {
                await punchMult(to: scoreMultDisplay + step.value)
                await snooze(0.18)
            }
            if reactionSteps.contains(where: { $0.kind == 4 }) {
                scoreMultDisplay = 0                              // Fire in the Kitchen
                HapticManager.shared.defeat()
                await snooze(0.4)
            }
            await snooze(0.12)
            scoreTotal = bd.total                                 // 🧮 the total calculates
            if bd.matched { HapticManager.shared.victory() }
            await snooze(0.65)
            self.dayScore += pts                                  // plaque banks it
            self.showServeResultLine = true
            await snooze(1.1)
            self.showServeResultLine = false
            self.scoringActive = false
            self.advanceOverlays()
        }
    }

    /// Tap during the tally to fast-forward it.
    func fastForwardScoring() { skipScoring = true }

    func dismissReaction() {
        showReaction = false
        advanceOverlays()
    }
    func dismissCollectible() {
        if !pendingCollectibles.isEmpty { pendingCollectibles.removeFirst() }
        advanceOverlays()
    }

    func advanceOverlays() {
        if !pendingCollectibles.isEmpty { showCollectible = true; return }
        showCollectible = false
        if dayResolvedPass { afterDayPass(); return }

        if dayCleared {
            resolveDayPass()
        } else if rollsLeft > 0 {
            nextCustomer()
            EnnasTavernSave.save(vm: self)
        } else {
            failRun()
        }
    }

    private func queueCollectible(_ id: String) {
        guard !TavernLedger.found().contains(id) else { return }
        TavernLedger.add(id)
        pendingCollectibles.append(id)
    }

    // ============================================================
    // DAY PASSED
    // ============================================================
    private func resolveDayPass() {
        dayResolvedPass = true
        if act == 2 && rollsLeft == 0 { queueCollectible("act2_4") }               // Fire Hazard
        if act == 2 && !todayRowKinds.isEmpty
            && todayRowKinds.isSubset(of: [.pair, .trips, .four, .five]) { queueCollectible("act2_6") }
        if act == 1 && day == EnnasTavernConfig.daysPerAct && !servedHighCardInAct1 {
            queueCollectible("act1_5")                                              // Beloved (Derogatory)
        }
        HapticManager.shared.victory()
        if !pendingCollectibles.isEmpty { showCollectible = true; EnnasTavernSave.save(vm: self) }
        else { afterDayPass() }
    }

    private func afterDayPass() {
        dayResolvedPass = false
        if day == EnnasTavernConfig.daysPerAct && act == 3 { resolveEpilogue(); return }
        if day == EnnasTavernConfig.daysPerAct {
            endingID = (act == 1) ? "act1_7" : "act2_7"
            if let id = endingID { TavernLedger.add(id) }
            phase = .promotion
        } else {
            phase = .dayResult
        }
        EnnasTavernSave.save(vm: self)
    }

    /// From Day Result or Promotion → night school.
    func continueToNight() {
        beginInterlude()
    }

    // ============================================================
    // 🌙 NIGHT SCHOOL (interlude): earn tokens, buy skills
    // ============================================================
    private func beginInterlude() {
        interludeTokensEarned = 0
        let freePick = TavernSettings.nightEconomy == .freePick
        minigameDone = freePick || !TavernSettings.interludeEnabled
        showNightShop = minigameDone
        if minigameDone && !freePick {
            let bonus = skillIDs.compactMap { EnnasTavernDatabase.skill($0) }.reduce(0) { $0 + $1.bonusTokens }
            interludeTokensEarned = EnnasTavernConfig.flatTokensPerNight + bonus
            tokens += interludeTokensEarned
        }
        bjHandsPlayed = 0; bjHandOver = true; bjMessage = ""
        bjPlayerCards = []; bjDealerCards = []
        schoolDice = []; schoolDisplayDice = []; schoolDiceThrown = false; schoolResultIn = false
        nightPickDone = false
        rollShopSkills()
        phase = .interlude
        EnnasTavernSave.save(vm: self)
    }

    private func rollShopSkills() {
        let nextMode: TavernServeMode = TavernSettings.playMode == .cards ? .cards : .dice
        let freePick = TavernSettings.nightEconomy == .freePick
        var offers = EnnasTavernDatabase.skills
            .filter { !skillIDs.contains($0.id) }
            .filter { $0.mode == nil || $0.mode == nextMode }
            .filter { !(freePick && $0.bonusTokens > 0) }   // Lucky Coin is dead weight without tokens
            .shuffled()
            .prefix(3)
            .map { $0.id }
        // 🔒 sometimes: offer to keep one of today's level-ups for the run
        if let leveled = leveledTodayRows.randomElement(),
           Double.random(in: 0..<1) < EnnasTavernConfig.keepBoonChance,
           !offers.isEmpty {
            offers[offers.count - 1] = "keep:\(leveled.rawValue)"
        }
        shopSkillIDs = Array(offers)
    }

    /// Lock one of today's level-ups in for the run — it IS the nightly pick.
    func pickKeepLevel(_ rowID: TavernRowID) {
        guard !nightPickDone else { return }
        permanentRowLevels[rowID, default: 0] += 1
        nightPickDone = true
        HapticManager.shared.victory()
        EnnasTavernSave.save(vm: self)
    }

    // ---- dice minigame: one throw, tokens by hand tier ----
    func throwSchoolDice() {
        guard !schoolDiceThrown else { return }
        schoolDiceThrown = true
        schoolDice = (0..<5).map { _ in Int.random(in: 1...6) }
        schoolDisplayDice = schoolDice.enumerated().map { i, val in
            TavernDie(id: i, value: val, selected: false)
        }
        schoolRollStamp += 1
        let counts = Dictionary(grouping: schoolDice, by: { $0 }).values.map(\.count).sorted(by: >)
        let uniq = Set(schoolDice)
        var earned = 0
        var label = "Nothing → 0 tokens"
        if counts[0] >= 4 { earned = 4; label = "4 of a Kind → 4 tokens" }
        else if counts[0] == 3 && counts.count > 1 && counts[1] == 2 { earned = 4; label = "Full House → 4 tokens" }
        else if uniq == Set(1...5) || uniq == Set(2...6) { earned = 3; label = "Straight → 3 tokens" }
        else if counts[0] == 3 { earned = 2; label = "3 of a Kind → 2 tokens" }
        else if counts[0] == 2 && counts.count > 1 && counts[1] == 2 { earned = 2; label = "2 Pair → 2 tokens" }
        else if counts[0] == 2 { earned = 1; label = "Pair → 1 token" }
        schoolResultLabel = label
        // Tokens land when the dice do (the 3D throw takes ~a second)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_150_000_000)
            self.schoolResultIn = true
            self.finishMinigame(earned: earned)
        }
    }

    // ---- blackjack minigame: 3 hands, win 2 / push 1 ----
    var bjPlayerTotal: Int { Self.bjTotal(bjPlayerCards) }
    var bjDealerTotal: Int { Self.bjTotal(bjDealerCards) }

    static func bjTotal(_ cards: [TavernPlayingCard]) -> Int {
        var total = 0; var aces = 0
        for c in cards {
            if c.rank == 14 { aces += 1; total += 11 }
            else { total += min(c.rank, 10) }
        }
        while total > 21 && aces > 0 { total -= 10; aces -= 1 }
        return total
    }

    func bjDeal() {
        guard bjHandOver, bjHandsPlayed < EnnasTavernConfig.blackjackHands else { return }
        if bjDeck.count < 15 { bjDeck = Self.freshDeck() }
        bjPlayerCards = [bjDeck.removeFirst(), bjDeck.removeFirst()]
        bjDealerCards = [bjDeck.removeFirst(), bjDeck.removeFirst()]   // second stays face-down
        bjHandOver = false
        bjMessage = ""
        HapticManager.shared.buttonPressed()
    }

    func bjHit() {
        guard !bjHandOver else { return }
        bjPlayerCards.append(bjDeck.removeFirst())
        if bjPlayerTotal > 21 { bjResolve() }
        HapticManager.shared.tileTapped()
    }

    func bjStand() {
        guard !bjHandOver else { return }
        while Self.bjTotal(bjDealerCards) < 17 { bjDealerCards.append(bjDeck.removeFirst()) }
        bjResolve()
    }

    private func bjResolve() {
        bjHandOver = true
        bjHandsPlayed += 1
        let p = bjPlayerTotal, d = bjDealerTotal
        var earned = 0
        if p > 21 { bjMessage = "Bust. The cousin smirks." }
        else if d > 21 || p > d { earned = EnnasTavernConfig.blackjackWinTokens; bjMessage = "Won! +\(earned) tokens." }
        else if p == d { earned = EnnasTavernConfig.blackjackPushTokens; bjMessage = "Push. +\(earned) token." }
        else { bjMessage = "The house cousin takes it." }
        interludeTokensEarned += earned
        tokens += earned
        if bjHandsPlayed >= EnnasTavernConfig.blackjackHands {
            let bonus = skillIDs.compactMap { EnnasTavernDatabase.skill($0) }.reduce(0) { $0 + $1.bonusTokens }
            interludeTokensEarned += bonus
            tokens += bonus
            completeMinigame()
        } else {
            EnnasTavernSave.save(vm: self)
        }
    }

    private func finishMinigame(earned: Int) {
        let bonus = skillIDs.compactMap { EnnasTavernDatabase.skill($0) }.reduce(0) { $0 + $1.bonusTokens }
        interludeTokensEarned = earned + bonus
        tokens += interludeTokensEarned
        completeMinigame()
    }

    /// Result lingers ~2s so the player SEES what happened, then the shop.
    private func completeMinigame() {
        minigameDone = true
        EnnasTavernSave.save(vm: self)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            self.showNightShop = true
        }
    }

    /// 🌙 The nightly pick — FREE, one per night, in both economies.
    func pickSkill(_ id: String) {
        guard !nightPickDone, EnnasTavernDatabase.skill(id) != nil, !skillIDs.contains(id) else { return }
        skillIDs.append(id)
        nightPickDone = true
        HapticManager.shared.victory()
        EnnasTavernSave.save(vm: self)
    }

    /// 🎲 Hybrid only: burn a token to redraw tonight's three offers.
    func rerollOffers() {
        guard TavernSettings.nightEconomy == .hybrid,
              !nightPickDone, tokens >= EnnasTavernConfig.offerRerollCost else { return }
        tokens -= EnnasTavernConfig.offerRerollCost
        rollShopSkills()
        HapticManager.shared.buttonPressed()
        EnnasTavernSave.save(vm: self)
    }

    /// 🔧 Debug: flip the table between dice and cards RIGHT NOW so the
    /// layout tuner shows what you're tuning. Costs nothing; the current
    /// customer keeps their need. Normal play still switches per customer.
    func debugSwitchTable(to mode: TavernServeMode) {
        serveMode = mode
        dayMode = mode           // tuner flips retune the whole day
        chosenRow = nil
        if mode == .cards && hand.count < EnnasTavernConfig.cardsHandSize {
            if deck.count < 16 { deck = Self.freshDeck() }
            var newHand: [TavernPlayingCard] = []
            for _ in 0..<EnnasTavernConfig.cardsHandSize { newHand.append(deck.removeFirst()) }
            hand = newHand
        }
        if mode == .dice && dice.isEmpty {
            dice = (0..<5).map { TavernDie(id: $0, value: Int.random(in: 1...6), selected: false) }
            lastRolledDieIDs = Set(dice.map { $0.id })
            rollStamp += 1
        }
    }

    /// Free, anytime, in the Skills sheet: reassign a dish's icon.
    func cycleRowIcon(_ rowID: TavernRowID) {
        let all = TavernNeed.allCases
        let cur = rowIcon(rowID)
        let next = all[(all.firstIndex(of: cur)! + 1) % all.count]
        rowIcons[rowID] = next
        HapticManager.shared.tileTapped()
        EnnasTavernSave.save(vm: self)
    }

    /// Close up for the night → next day.
    func leaveInterlude() {
        if day < EnnasTavernConfig.daysPerAct { day += 1 } else { act += 1; day = 1 }
        runDay += 1
        setupDay()
        phase = .dayIntro
        EnnasTavernSave.save(vm: self)
    }

    // ============================================================
    // FAILURE + EPILOGUE
    // ============================================================
    private func failRun() {
        endingID = nil; genericEndText = nil
        switch act {
        case 1:
            if runDay == 1 { endingID = "act1_1" }
            else if tokens == 0 && skillIDs.isEmpty { endingID = "act1_2" }
            else if maxRollsSpentOnOneCustomer >= 4 { endingID = "act1_4" }        // Banned
        case 2:
            if day == EnnasTavernConfig.daysPerAct { endingID = "act2_1" }
            else if tokens == 0 { endingID = "act2_2" }
            else if skillIDs.isEmpty { endingID = "act2_3" }                        // Echo Tavern
        default:
            switch bossTwist {
            case .guildAudit:   endingID = "act3_1"
            case .theCarriage:  endingID = "act3_3"
            case .watchCaptain: endingID = "act3_5"
            default: break
            }
        }
        if let id = endingID { TavernLedger.add(id) }
        else { genericEndText = EnnasTavernDatabase.genericFailTexts[act] }
        HapticManager.shared.defeat()
        phase = .gameOver
        EnnasTavernSave.deleteSave()
    }

    private func resolveEpilogue() {
        var counts: [TavernNeed: Int] = [:]
        for s in skillIDs.compactMap({ EnnasTavernDatabase.skill($0) }) {
            counts[s.school, default: 0] += 1
        }
        endingID = nil; genericEndText = nil
        if let big = counts.first(where: { $0.value >= 3 }) {
            switch big.key {
            case .food:    endingID = "act3_2"
            case .tavern:  endingID = "act3_4"
            case .support: endingID = "act3_6"
            }
        }
        if endingID == nil {
            let vals = TavernNeed.allCases.map { counts[$0] ?? 0 }
            if vals.allSatisfy({ $0 >= 1 }) || vals.allSatisfy({ $0 <= 1 }) {
                endingID = "act3_7"                        // ★ The Quiet Pint
            } else {
                genericEndText = EnnasTavernDatabase.genericVictoryText
            }
        }
        if let id = endingID { TavernLedger.add(id) }
        HapticManager.shared.victory()
        phase = .epilogue
        EnnasTavernSave.deleteSave()
    }

    func restart() {
        EnnasTavernSave.deleteSave()
        startRun()
    }
}
