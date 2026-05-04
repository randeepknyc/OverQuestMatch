//
//  PotionShopGameState.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Game State Machine
//  Place in: PotionShop/ folder
//
//  ═══════════════════════════════════════════════════════════════════════
//  THIS IS THE BRAIN OF THE GAME.
//  ═══════════════════════════════════════════════════════════════════════
//  The view layer (Phase 4+) reads from this @Observable class and calls
//  its methods on user input. This file is the source of truth for what's
//  happening in a round.
//
//  KEY CONCEPTS:
//
//  1. customers[] vs queue[]
//     - customers[]: ALL PotionShopCustomers spawned this round, NEVER
//                    reordered. Drives the profile button row in the UI.
//                    Defeated/expired customers stay in this array (with
//                    their `status` field updated) so their button can
//                    still render greyed out.
//     - queue[]:    ordered ids of customers still in line.
//                    queue[0] = front of line = leftmost in scene = active
//                    (the one being brewed for).
//                    Defeated/expired are REMOVED from this array.
//
//  2. tapProfile(id) is the queue/swap function
//     When the user taps a customer's profile button, that customer
//     becomes the new active one. Implementation: pure 2-element swap
//     between queue[0] and queue[indexOf(tapped)]. No reordering. No
//     filtering. The queue array IS the truth.
//     (This took 8 attempts to get right in our design sessions —
//     don't redesign it, copy it.)
//
//  3. doBrew() runs the turn
//     Phase 3 version: instant. Player's brew applies, customers attack
//     all at once, patience ticks, expirations resolve, queue updates.
//     Phase 7 will replace this with a 7-phase animated version.
//
//  4. The 7-phase turn order
//     a. Player's brew applies (heal, shield) to the player
//     b. Volatile pre-defense fires if overbrew
//     c. Brew damage applies to active customer
//     d. Each customer attacks (active uses activeAttack, waiters use waitingAttack)
//     e. Each customer's patience ticks down
//     f. Anyone whose patience hit 0 storms out + deals expireDamage
//     g. Draining trait drains 1 composure per draining customer
//
//  NOTE on naming: this file uses `PotionShopCustomer` (not just
//  `Customer`) because the existing ShopOfOddities game already has a
//  `Customer` type. We use the namespaced name to avoid conflicts.
//

import SwiftUI

// MARK: - PotionShopCustomer (live instance of a Character)
//
// A PotionShopCharacter (from PotionShopData) is the template.
// A PotionShopCustomer is the live instance with HP and patience that
// change during the round.

enum PotionShopCustomerStatus {
    case waiting    // alive, in queue
    case defeated   // HP hit 0 — customer satisfied
    case expired    // patience hit 0 — stormed out
}

struct PotionShopCustomer: Identifiable, Equatable {
    let id: UUID
    let charKey: String   // key into PotionShopData.characters
    var hp: Int
    let maxHp: Int
    var patience: Int
    let maxPatience: Int
    var status: PotionShopCustomerStatus

    static func == (lhs: PotionShopCustomer, rhs: PotionShopCustomer) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - The state machine

@Observable
class PotionShopGameState {

    // MARK: - Game progression

    var dayId: String = "day_1"
    /// 0 = morning, 1 = afternoon, 2 = evening, 3 = night
    var roundIndex: Int = 0
    var phase: PotionShopPhase = .playing

    // MARK: - Player state

    var composure: Int = PotionShopConfig.startingComposure
    var shield: Int = 0
    var potionsBrewed: Int = 0

    // MARK: - Customer queue

    /// All PotionShopCustomers spawned this round. NEVER reordered.
    var customers: [PotionShopCustomer] = []
    /// Ordered ids of customers still alive. queue[0] = active.
    var queue: [UUID] = []
    /// Which customer (if any) is currently being inspected.
    var inspectedId: UUID? = nil

    // MARK: - Dice

    var bag: [PotionShopBagDie] = []
    var discardPile: [PotionShopBagDie] = []
    var hand: [PotionShopDie] = []
    /// Map from cauldron node id → die placed there.
    var placements: [Int: PotionShopDie] = [:]
    var selectedHandIndex: Int? = nil

    // MARK: - Animation/UX state (used by Phase 7+)

    var isAnimating: Bool = false

    // MARK: - Init

    init() {
        startRound()
    }

    // MARK: - Round name helpers

    var currentRoundTimeOfDay: PotionShopTimeOfDay {
        switch roundIndex {
        case 0: return .morning
        case 1: return .afternoon
        case 2: return .evening
        default: return .night
        }
    }

    var currentRoundLabel: String {
        currentRoundTimeOfDay.rawValue.capitalized
    }

    // MARK: - Round / day flow

    /// Spawn customers and deal a hand. Called at the start of each round
    /// and any time the user resets.
    func startRound() {
        guard let day = PotionShopData.day(dayId) else {
            print("❌ PotionShop: Can't find day \(dayId)")
            return
        }

        let round: PotionShopRound
        switch roundIndex {
        case 0: round = day.morning
        case 1: round = day.afternoon
        case 2: round = day.evening
        default: round = day.night
        }

        customers = round.customerIds.compactMap { id -> PotionShopCustomer? in
            guard let char = PotionShopData.character(id) else {
                print("⚠️ PotionShop: Unknown character id \(id)")
                return nil
            }
            return PotionShopCustomer(
                id: UUID(),
                charKey: id,
                hp: char.hp,
                maxHp: char.hp,
                patience: char.patience,
                maxPatience: char.patience,
                status: .waiting
            )
        }
        queue = customers.map { $0.id }
        inspectedId = nil

        bag = buildStartingBag()
        discardPile.removeAll()
        drawFromBag()

        placements.removeAll()
        selectedHandIndex = nil
        phase = .playing
    }

    /// Move to next round of the current day. Called when round is won.
    func advanceRound() {
        // Apply between-round composure rest
        composure = min(
            PotionShopConfig.maxComposure,
            composure + PotionShopConfig.composureRestBetweenRounds
        )
        roundIndex += 1
        if roundIndex >= PotionShopConfig.roundsPerDay {
            // Day complete
            phase = .dayWon
        } else {
            startRound()
        }
    }

    /// Move to next day. (For v1 / Day 1 only, this just resets to Day 1.)
    func advanceDay() {
        composure = min(
            PotionShopConfig.maxComposure,
            composure + PotionShopConfig.composureRestBetweenDays
        )
        roundIndex = 0
        // Future: advance dayId. For v1, we stay on Day 1.
        startRound()
    }

    /// Restart from Day 1, Morning.
    func resetGame() {
        dayId = "day_1"
        roundIndex = 0
        composure = PotionShopConfig.startingComposure
        shield = 0
        potionsBrewed = 0
        startRound()
    }

    // MARK: - The CRITICAL function: tap profile = swap with queue[0]

    /// When the user taps a customer's profile button, swap that
    /// customer to the front of the line. Pure 2-element swap.
    /// Zero derived state. The queue array IS the truth.
    func tapProfile(_ id: UUID) {
        if isAnimating { return }
        guard let cust = customers.first(where: { $0.id == id }) else { return }
        if cust.status != .waiting { return }

        // Tapping the already-active inspected customer dismisses inspect
        if inspectedId == id, queue.first == id {
            inspectedId = nil
            return
        }

        guard let idx = queue.firstIndex(of: id) else { return }
        if idx != 0 {
            queue.swapAt(0, idx)
        }
        inspectedId = id
    }

    func dismissInspect() {
        if isAnimating { return }
        inspectedId = nil
    }

    // MARK: - Dice placement

    func selectHand(_ idx: Int) {
        if isAnimating { return }
        selectedHandIndex = (selectedHandIndex == idx) ? nil : idx
    }

    func tapNode(_ nodeId: Int) {
        if isAnimating { return }
        if placements[nodeId] != nil {
            unplaceDie(nodeId)
            return
        }
        guard let idx = selectedHandIndex else { return }
        placeDie(handIdx: idx, nodeId: nodeId)
    }

    func placeDie(handIdx: Int, nodeId: Int) {
        if placements[nodeId] != nil { return }
        if placements.count >= PotionShopConfig.maxPlacementsPerBrew { return }
        guard handIdx < hand.count else { return }
        let die = hand[handIdx]
        placements[nodeId] = die
        hand.remove(at: handIdx)
        selectedHandIndex = nil
    }

    func unplaceDie(_ nodeId: Int) {
        guard let die = placements[nodeId] else { return }
        hand.append(die)
        placements[nodeId] = nil
    }

    // MARK: - Trait aggregation

    /// Count how many customers in the queue have each trait.
    /// Used for trait stacking (e.g., 2 intimidating = +4 brew target).
    func activeTraitCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        for id in queue {
            guard let c = customers.first(where: { $0.id == id }),
                  let char = PotionShopData.character(c.charKey),
                  let traitId = char.trait else { continue }
            counts[traitId, default: 0] += 1
        }
        return counts
    }

    // MARK: - Brew calculation

    struct BrewPreview {
        var damage: Int
        var healing: Int
        var shielding: Int
        var boostNodes: [Int]
    }

    /// Compute total damage, heal, and shield from currently placed dice.
    /// Includes Boost multipliers and Inspiring trait modifier.
    func computeBrew() -> BrewPreview {
        let traits = activeTraitCounts()
        let inspiringCount = traits["inspiring"] ?? 0
        let dieValueMod = inspiringCount * (PotionShopData.trait("inspiring")?.effects.diceValueModifierGlobal ?? 0)

        var damage: Double = 0
        var healing = 0
        var shielding = 0
        var boostNodes: [Int] = []

        for (nodeId, die) in placements {
            let baseValue = die.value + dieValueMod
            let reach = PotionShopBoard.neighborsWithin(nodeId, hops: baseValue)
            var multiplier: Double = 1.0
            for rn in reach {
                if let adjDie = placements[rn], adjDie.type == .boost {
                    multiplier += Double(adjDie.value) * 0.5
                    if !boostNodes.contains(rn) {
                        boostNodes.append(rn)
                    }
                }
            }
            switch die.type {
            case .potency:
                damage += Double(baseValue) * multiplier
            case .stability:
                damage += Double(baseValue) * multiplier * 0.8
            case .heal:
                healing += baseValue
            case .shield:
                shielding += baseValue
            case .boost:
                break
            }
        }

        return BrewPreview(
            damage: Int(damage.rounded()),
            healing: healing,
            shielding: shielding,
            boostNodes: boostNodes
        )
    }

    /// Brew target for the active customer (their HP + Intimidating modifier).
    var currentBrewTarget: Int {
        guard let activeId = queue.first,
              let active = customers.first(where: { $0.id == activeId }) else { return 0 }
        let intimidating = activeTraitCounts()["intimidating"] ?? 0
        let mod = intimidating * (PotionShopData.trait("intimidating")?.effects.brewTargetModifier ?? 0)
        return active.hp + mod
    }

    // MARK: - Damage application

    /// Apply damage to the player. Shield absorbs first, then composure.
    /// Returns how much was absorbed (by shield) vs dealt (to composure).
    @discardableResult
    func applyDamage(_ amount: Int) -> (absorbed: Int, dealt: Int) {
        if amount <= 0 { return (0, 0) }
        var remaining = amount
        var absorbed = 0
        if shield > 0 {
            absorbed = min(shield, remaining)
            shield -= absorbed
            remaining -= absorbed
        }
        let dealt = min(remaining, composure)
        composure = max(0, composure - remaining)
        if composure <= 0 {
            phase = .lost
        }
        return (absorbed, dealt)
    }

    // MARK: - Bag / draw / discard

    private func buildStartingBag() -> [PotionShopBagDie] {
        // 8-die starting bag. Tunable. Move into PotionShopConfig if
        // you want to adjust without editing this file.
        let types: [PotionShopDieType] = [
            .potency, .potency, .potency,
            .stability, .stability,
            .boost,
            .heal,
            .shield,
        ]
        var bag: [PotionShopBagDie] = []
        for (i, type) in types.enumerated() {
            bag.append(PotionShopBagDie(
                id: "die_\(type.rawValue)_\(i)_\(UUID().uuidString.prefix(4))",
                type: type,
                tier: .basic
            ))
        }
        bag.shuffle()
        return bag
    }

    /// Draw 5 dice from the bag into the hand. If bag is short, shuffle
    /// the discard pile back in first.
    func drawFromBag() {
        if bag.count < 5 && !discardPile.isEmpty {
            bag.append(contentsOf: discardPile)
            discardPile.removeAll()
            bag.shuffle()
        }
        let count = min(5, bag.count)
        let drawn = Array(bag.prefix(count))
        bag.removeFirst(count)

        hand = drawn.map { bd in
            PotionShopDie(
                id: bd.id,
                type: bd.type,
                tier: bd.tier,
                value: bd.tier.rollFace()
            )
        }
        selectedHandIndex = nil
    }

    /// Move all placed and held dice to the discard pile. Called after each brew.
    func discardAllDice() {
        for die in placements.values {
            discardPile.append(PotionShopBagDie(id: die.id, type: die.type, tier: die.tier))
        }
        for die in hand {
            discardPile.append(PotionShopBagDie(id: die.id, type: die.type, tier: die.tier))
        }
        hand.removeAll()
        placements.removeAll()
    }

    // MARK: - The big one: doBrew()
    //
    // Phase 3 version: instant turn resolution. Phase 7 will replace
    // this with an animated version that pauses between phases.

    func doBrew() {
        if isAnimating { return }
        if placements.isEmpty { return }
        guard let activeId = queue.first,
              let activeIdx = customers.firstIndex(where: { $0.id == activeId }),
              let activeChar = PotionShopData.character(customers[activeIdx].charKey) else { return }

        let preview = computeBrew()
        let target = currentBrewTarget

        // ─── PHASE 1: Heal + Shield apply to player ─────────────────
        if preview.healing > 0 {
            composure = min(PotionShopConfig.maxComposure, composure + preview.healing)
        }
        if preview.shielding > 0 {
            shield += preview.shielding
        }

        // ─── PHASE 2: Volatile pre-defense (overbrew retaliation) ───
        if activeChar.trait == "volatile" && preview.damage > target {
            let overflow = preview.damage - target
            applyDamage(overflow)
        }

        // ─── PHASE 3: Brew damage to active customer ────────────────
        if preview.damage > 0 {
            customers[activeIdx].hp = max(0, customers[activeIdx].hp - preview.damage)
            if customers[activeIdx].hp <= 0 {
                customers[activeIdx].status = .defeated
            }
        }

        // ─── PHASE 4: Customer attacks (one logical pass) ───────────
        let attackingIds = queue
        for id in attackingIds {
            if phase == .lost { break }
            guard let cIdx = customers.firstIndex(where: { $0.id == id }) else { continue }
            if customers[cIdx].status != .waiting { continue }
            guard let char = PotionShopData.character(customers[cIdx].charKey) else { continue }
            let isActive = (queue.first == customers[cIdx].id)
            let attack = isActive ? char.activeAttack : char.waitingAttack
            if attack > 0 {
                applyDamage(attack)
            }
        }

        // ─── PHASE 5: Patience ticks ───────────────────────────────
        for id in queue {
            guard let cIdx = customers.firstIndex(where: { $0.id == id }) else { continue }
            if customers[cIdx].status != .waiting { continue }
            guard let char = PotionShopData.character(customers[cIdx].charKey) else { continue }
            let isActive = (queue.first == customers[cIdx].id)
            // Skittish trait modifies activePatienceTick? In our data,
            // skittish characters already have activePatienceTick: 2,
            // so we just read the field directly.
            let tick = isActive ? char.activePatienceTick : char.waitingPatienceTick
            customers[cIdx].patience = max(0, customers[cIdx].patience - tick)
        }

        // ─── PHASE 6: Expirations ───────────────────────────────────
        let expiringIds = queue.filter { id in
            guard let c = customers.first(where: { $0.id == id }) else { return false }
            return c.status == .waiting && c.patience <= 0
        }
        for id in expiringIds {
            guard let cIdx = customers.firstIndex(where: { $0.id == id }),
                  let char = PotionShopData.character(customers[cIdx].charKey) else { continue }
            customers[cIdx].status = .expired
            applyDamage(char.expireDamage)
        }

        // ─── PHASE 7: Draining trait drain ─────────────────────────
        var drainTotal = 0
        for id in queue {
            guard let c = customers.first(where: { $0.id == id }), c.status == .waiting else { continue }
            if PotionShopData.character(c.charKey)?.trait == "draining" {
                drainTotal += 1
            }
        }
        if drainTotal > 0 {
            applyDamage(drainTotal)
        }

        // ─── BOOKKEEPING ────────────────────────────────────────────
        if customers[activeIdx].status == .defeated {
            potionsBrewed += 1
        }
        // Remove defeated/expired from queue
        queue.removeAll { id in
            guard let c = customers.first(where: { $0.id == id }) else { return true }
            return c.status != .waiting
        }

        // Discard placed + remaining hand, redraw
        discardAllDice()
        drawFromBag()
        inspectedId = nil

        // End-of-round / end-of-game checks
        if phase == .lost {
            return
        }
        if queue.isEmpty {
            phase = .roundWon
        }
    }

    // MARK: - Self-test (for Phase 3 verification)
    //
    // Programmatically exercises the engine to confirm everything works.
    // Returns a list of strings to display.

    func runSelfTest() -> [String] {
        var lines: [String] = []

        // Reset to a known state
        resetGame()
        lines.append("─── BEFORE BREW ───")
        lines.append("Day: \(dayId), Round: \(currentRoundLabel)")
        lines.append("Customers spawned: \(customers.count)")
        lines.append("Queue length: \(queue.count)")
        lines.append("Composure: \(composure) / \(PotionShopConfig.maxComposure)")
        lines.append("Hand: \(hand.count) dice")

        guard let firstId = queue.first,
              let firstCust = customers.first(where: { $0.id == firstId }),
              let firstChar = PotionShopData.character(firstCust.charKey) else {
            lines.append("❌ Could not find active customer")
            return lines
        }
        lines.append("Active: \(firstChar.name) (HP \(firstCust.hp))")

        // Test the queue swap if there are 2+ customers
        if queue.count >= 2 {
            let secondId = queue[1]
            if let secondChar = PotionShopData.character(customers.first(where: { $0.id == secondId })!.charKey) {
                lines.append("Second in queue: \(secondChar.name)")
                tapProfile(secondId)
                if let newFirstId = queue.first,
                   let newFirstChar = PotionShopData.character(customers.first(where: { $0.id == newFirstId })!.charKey) {
                    lines.append("After tap-swap: active is \(newFirstChar.name)")
                    if newFirstChar.id == secondChar.id {
                        lines.append("✅ Queue swap WORKS")
                    } else {
                        lines.append("❌ Queue swap broke (got \(newFirstChar.name))")
                    }
                }
                // Swap back so the brew test uses the original active
                tapProfile(firstId)
            }
        }

        // Force a known hand: place 3 potency dice on the cauldron
        // and compute the brew preview
        let testDice: [PotionShopDie] = [
            PotionShopDie(id: "test_pot_1", type: .potency, tier: .basic, value: 3),
            PotionShopDie(id: "test_pot_2", type: .potency, tier: .basic, value: 3),
            PotionShopDie(id: "test_pot_3", type: .potency, tier: .basic, value: 2),
        ]
        hand = testDice
        placements.removeAll()
        placements[3] = testDice[0]
        placements[6] = testDice[1]
        placements[10] = testDice[2]
        let preview = computeBrew()
        lines.append("─── BREW MATH (3 potency dice: 3+3+2) ───")
        lines.append("Predicted damage: \(preview.damage)")
        lines.append("Predicted healing: \(preview.healing)")
        lines.append("Predicted shielding: \(preview.shielding)")

        // Run a full brew turn and observe the result
        let composureBeforeBrew = composure
        let activeHpBeforeBrew = customers[customers.firstIndex(where: { $0.id == firstId })!].hp
        doBrew()
        lines.append("─── AFTER BREW ───")
        lines.append("Composure: \(composureBeforeBrew) → \(composure)")
        lines.append("Active customer HP: \(activeHpBeforeBrew) → \(customers.first(where: { $0.id == firstId })?.hp ?? -1)")
        lines.append("Queue length now: \(queue.count)")
        lines.append("Hand redrew: \(hand.count) dice")
        lines.append("Phase: \(phaseLabel(phase))")

        // Reset for Phase 4+ to start clean
        resetGame()
        lines.append("─── RESET TO FRESH STATE ───")
        return lines
    }

    private func phaseLabel(_ p: PotionShopPhase) -> String {
        switch p {
        case .playing:   return "playing"
        case .roundWon:  return "roundWon"
        case .dayWon:    return "dayWon"
        case .lost:      return "lost"
        }
    }

    // MARK: - Debug helpers (called from PotionShopDebugMenu)

    /// Defeat every customer in the queue and trigger round-end. Used
    /// by the debug menu to test round-win flow.
    func debugWinRound() {
        for id in queue {
            guard let idx = customers.firstIndex(where: { $0.id == id }) else { continue }
            customers[idx].hp = 0
            customers[idx].status = .defeated
            potionsBrewed += 1
        }
        queue.removeAll()
        discardAllDice()
        drawFromBag()
        inspectedId = nil
        phase = .roundWon
    }

    /// Drop composure to 0 and trigger lose phase. Used by debug menu.
    func debugLoseGame() {
        composure = 0
        shield = 0
        phase = .lost
    }
}
