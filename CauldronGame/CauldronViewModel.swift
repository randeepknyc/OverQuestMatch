// CauldronViewModel.swift
// Ednar's Cauldron - Game Logic
// Place in: CauldronGame/ folder

import SwiftUI

@Observable
class CauldronViewModel {
    // MARK: - Game State
    var gameState: CauldronGameState = .title
    var day = 1
    var standing = 30
    var gold = 0
    var potionsBrewed = 0
    var goldBrews = 0
    var dayBrew = 0

    // MARK: - Board
    var board: [CauldronDie?] = Array(repeating: nil, count: 12)
    var terrainBonuses: [Int] = Array(repeating: 0, count: 12)
    var blockedSlots: Set<Int> = []

    // MARK: - Dice / Bag System
    var hand: [CauldronDie] = []
    var bag: [BagDie] = []
    var discardPile: [BagDie] = []
    var selectedDie: CauldronDie? = nil
    var placementsLeft = 3

    // MARK: - Patrons
    var patronQueue: [Patron] = []
    var currentPatron: Patron? = nil

    // MARK: - UI State
    var brewResult: BrewResult? = nil
    var log: [String] = []
    var showLog = false
    var animatingBrew = false
    var showSketchBG = true
    
    // MARK: - Debug Mode
    var debugMode = false
    
    // Global Y offset to shift all nodes up/down together
    var globalNodeYOffset: Double = 60.0  // Adjust this to move all nodes! (positive = down, negative = up)
    
    var debugNodePositions: [CGPoint] = [
        CGPoint(x: 36.0, y: -52.6),   // 0
        CGPoint(x: 70.9, y: -52.8),   // 1
        CGPoint(x: 6.1, y: -25.6),    // 2
        CGPoint(x: 56.5, y: -8.3),    // 3
        CGPoint(x: 100.3, y: -25.0),  // 4
        CGPoint(x: 5.4, y: 22.3),     // 5
        CGPoint(x: 56.1, y: 43.4),    // 6
        CGPoint(x: 104.3, y: 23.9),   // 7
        CGPoint(x: 2.5, y: 68.1),     // 8
        CGPoint(x: 39.2, y: 79.0),    // 9
        CGPoint(x: 79.3, y: 79.3),    // 10
        CGPoint(x: 109.7, y: 66.8),   // 11
    ]
    
    // Debug brew button positioning (matches final layout)
    var debugBrewButtonPosition = CGPoint(x: 83.9, y: 36.9) // % of screen - right side, matches sketch
    var debugBrewButtonRotation: Double = -80.0 // degrees (steep tilt like ladle in sketch)

    // MARK: - Computed
    var placedCount: Int { board.compactMap { $0 }.count }

    var standingPercent: Double { Double(standing) / 30.0 }

    var standingColor: Color {
        standingPercent > 0.6 ? .green : standingPercent > 0.3 ? .orange : .red
    }

    var timeOfDay: String {
        dayBrew < 2 ? "☀️" : dayBrew < 4 ? "🌤️" : "🌙"
    }

    // MARK: - Preview Calculation
    var previewTotal: Int {
        guard placedCount > 0, gameState == .playing else { return 0 }
        let insp = currentPatron?.trait.name == "Inspiring" ? 1 : 0
        var boost: Double = 1.0
        var total: Double = 0

        for (i, die) in board.enumerated() {
            guard let die = die, die.type == .boost else { continue }
            let val = Double(die.value + insp + terrainBonuses[i])
            boost += val * 0.2
        }

        for (i, die) in board.enumerated() {
            guard let die = die else { continue }
            let val = Double(die.value + insp + terrainBonuses[i])
            switch die.type {
            case .potency: total += val
            case .stability, .restoration: total += ceil(val * 0.75)
            case .terrain: total += ceil(val * 0.3)
            case .mirror:
                for ni in CauldronBoard.neighbors(of: i) {
                    if let neighbor = board[ni], neighbor.type != .mirror && neighbor.type != .boost {
                        total += Double(neighbor.value + insp + terrainBonuses[ni])
                        break
                    }
                }
            case .boost: break
            }
        }
        return Int((total * boost).rounded())
    }

    var previewBoost: Double {
        guard placedCount > 0 else { return 1.0 }
        let insp = currentPatron?.trait.name == "Inspiring" ? 1 : 0
        var boost: Double = 1.0
        for (i, die) in board.enumerated() {
            guard let die = die, die.type == .boost else { continue }
            boost += Double(die.value + insp + terrainBonuses[i]) * 0.2
        }
        return boost
    }

    var previewTarget: Int {
        guard let patron = currentPatron else { return 0 }
        return patron.target + (patron.trait.name == "Intimidating" ? 2 : 0)
    }

    // MARK: - Bag System

    func buildStartingBag() -> [BagDie] {
        var b: [BagDie] = []
        let types: [DiceType] = [.potency, .potency, .stability, .stability,
                                  .boost, .boost, .restoration, .restoration]
        for (i, type) in types.enumerated() {
            b.append(BagDie(id: "die_\(type.rawValue)_\(i)", type: type, tier: .basic))
        }
        b.shuffle()
        return b
    }

    func drawFromBag() {
        // If not enough in bag, shuffle discards back in
        if bag.count < 5 && !discardPile.isEmpty {
            bag.append(contentsOf: discardPile)
            discardPile.removeAll()
            bag.shuffle()
        }
        let count = min(5, bag.count)
        let drawn = Array(bag.prefix(count))
        bag.removeFirst(count)

        // Roll face values
        hand = drawn.map { bagDie in
            CauldronDie(id: bagDie.id, type: bagDie.type, tier: bagDie.tier,
                        value: bagDie.tier.rollFace())
        }
        placementsLeft = 3
        selectedDie = nil
    }

    func discardAllDice() {
        let allUsed = board.compactMap { $0 } + hand
        let asBagDice = allUsed.map { BagDie(id: $0.id, type: $0.type, tier: $0.tier) }
        discardPile.append(contentsOf: asBagDice)
        hand.removeAll()
        board = Array(repeating: nil, count: 12)
    }

    // MARK: - Patron Generation

    func makePatron(day: Int) -> Patron {
        let typeIdx = Int.random(in: 0..<min(day + 2, PatronData.types.count))
        let target = 1 + day * 2 + Int.random(in: 0..<3)
        return Patron(
            name: PatronData.names[typeIdx],
            type: PatronData.types[typeIdx],
            patience: PatronData.patience[typeIdx],
            maxPatience: PatronData.patience[typeIdx],
            expiryDamage: PatronData.expiryDamage[typeIdx],
            trait: PatronData.traits.randomElement()!,
            target: target,
            targetType: .potency,
            stipulation: PatronData.stipulations.randomElement()!
        )
    }

    // MARK: - Game Flow

    func startGame() {
        day = 1; standing = 30; gold = 0; potionsBrewed = 0; goldBrews = 0
        log.removeAll(); terrainBonuses = Array(repeating: 0, count: 12)
        blockedSlots.removeAll(); brewResult = nil
        bag.removeAll(); discardPile.removeAll()
        startDay(day: 1)
        gameState = .playing
    }

    func startDay(day: Int) {
        let numPatrons = min(3 + day / 2, 6)
        patronQueue = (0..<numPatrons).map { _ in makePatron(day: day) }
        currentPatron = patronQueue.first
        dayBrew = 0
        board = Array(repeating: nil, count: 12)
        blockedSlots.removeAll()

        bag = buildStartingBag()
        discardPile.removeAll()
        drawFromBag()

        addLog("☀️ Day \(day) — \(numPatrons) patrons await. Bag: 8 dice.")

        if currentPatron?.trait.name == "Disruptive" {
            blockedSlots.insert(Int.random(in: 0..<12))
        }
    }

    // MARK: - Placement

    func selectDie(_ die: CauldronDie) {
        guard gameState == .playing else { return }
        selectedDie = selectedDie?.id == die.id ? nil : die
    }

    func tapSlot(_ index: Int) {
        guard gameState == .playing else { return }
        guard !blockedSlots.contains(index) else { return }

        // Remove placed die back to hand
        if let existing = board[index] {
            hand.append(existing)
            board[index] = nil
            placementsLeft += 1
            selectedDie = nil
            return
        }

        // Place selected die
        guard let die = selectedDie else { return }
        guard placementsLeft > 0 else { addLog("⚠️ No placements left!"); return }

        // Check stipulations
        if let patron = currentPatron {
            if patron.stipulation == "No boost dice" && die.type == .boost {
                addLog("⚠️ No boost dice!"); return
            }
            if patron.stipulation == "No mirror dice" && die.type == .mirror {
                addLog("⚠️ No mirror dice!"); return
            }
            if patron.stipulation == "Only basic tier" && die.tier != .basic {
                addLog("⚠️ Only basic tier!"); return
            }
            let maxP = patron.stipulation == "Max 2 placements" ? 2 : 3
            if (3 - placementsLeft) >= maxP {
                addLog("⚠️ Max \(maxP) placements!"); return
            }
        }

        board[index] = die
        hand.removeAll { $0.id == die.id }
        placementsLeft -= 1
        selectedDie = nil
    }

    // MARK: - Brew

    func doBrew() {
        guard gameState == .playing, let patron = currentPatron else { return }
        let placed = board.compactMap { $0 }
        guard !placed.isEmpty else { addLog("⚠️ Place at least 1 die!"); return }

        animatingBrew = true
        gameState = .brewing

        // Delay for animation feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            let insp = patron.trait.name == "Inspiring" ? 1 : 0

            // Pass 1: Boost multiplier
            var boostMult: Double = 1.0
            for (i, die) in board.enumerated() {
                guard let die = die, die.type == .boost else { continue }
                let val = Double(die.value + insp + terrainBonuses[i])
                boostMult += val * 0.2
            }

            // Pass 2: Tally values
            var brewTotal: Double = 0
            var stabTotal = 0
            for (i, die) in board.enumerated() {
                guard let die = die else { continue }
                let val = die.value + insp + terrainBonuses[i]
                switch die.type {
                case .potency:
                    brewTotal += Double(val)
                case .stability:
                    brewTotal += ceil(Double(val) * 0.75)
                    stabTotal += val
                case .restoration:
                    brewTotal += ceil(Double(val) * 0.75)
                case .mirror:
                    for ni in CauldronBoard.neighbors(of: i) {
                        if let neighbor = board[ni], neighbor.type != .mirror && neighbor.type != .boost {
                            let cv = neighbor.value + insp + terrainBonuses[ni]
                            brewTotal += Double(cv)
                            if neighbor.type == .stability { stabTotal += cv }
                            break
                        }
                    }
                case .terrain:
                    brewTotal += ceil(Double(val) * 0.3)
                    terrainBonuses[i] = val
                case .boost:
                    break
                }
            }

            let raw = Int((brewTotal * boostMult).rounded())
            let target = patron.target + (patron.trait.name == "Intimidating" ? 2 : 0)
            let overMargin = max(3, stabTotal * 2)
            let overflow = raw - target

            var tier = "failed"
            var tierLabel = "FAILED"
            var payment = 0
            var standingChange = 0
            var blowback = 0

            if raw >= target {
                if overflow > overMargin {
                    blowback = min(4, overflow - overMargin)
                }
                let golds = placed.filter { $0.tier == .gold }.count
                let silvers = placed.filter { $0.tier == .silver }.count

                if raw == target || golds >= 2 {
                    tier = "gold"; tierLabel = "★ GOLD ★"
                    payment = target * 3; standingChange = 5 - blowback
                } else if overflow >= 2 || silvers >= 1 || placed.count >= 3 {
                    tier = "silver"; tierLabel = "☆ Silver ☆"
                    payment = target * 2; standingChange = 3 - blowback
                } else {
                    tier = "basic"; tierLabel = "Basic"
                    payment = target; standingChange = 1 - blowback
                }
            } else {
                blowback = min(5, target - raw)
                standingChange = -blowback
            }

            if patron.trait.name == "Draining" { standingChange -= 1 }
            if patron.trait.name == "Greedy" { payment = max(0, payment - 5) }
            if tier == "gold" { goldBrews += 1 }

            brewResult = BrewResult(
                total: raw, target: target, tier: tier, tierLabel: tierLabel,
                payment: payment, standingChange: standingChange,
                blowback: blowback, boostMultiplier: boostMult
            )

            standing = max(0, min(30, standing + standingChange))
            gold += payment
            if tier != "failed" { potionsBrewed += 1 }

            let sign = standingChange > 0 ? "+" : ""
            addLog("🧪 \(raw)/\(target) → \(tierLabel) | \(sign)\(standingChange) HP | +\(payment)g")
            animatingBrew = false
            gameState = .result
        }
    }

    // MARK: - Next Patron / Day

    func nextAction() {
        guard standing > 0 else { gameState = .gameover; return }

        // Decay terrain
        terrainBonuses = terrainBonuses.map { max(0, $0 - 1) }

        // Discard all current dice
        discardAllDice()

        // Update remaining patrons
        var remaining = Array(patronQueue.dropFirst())
        remaining = remaining.map { p in
            var updated = p
            updated.patience -= 1
            return updated
        }

        // Check expired patrons
        var standingLoss = 0
        remaining = remaining.filter { p in
            if p.patience <= 0 {
                standingLoss += p.expiryDamage
                addLog("😡 \(p.name) left! -\(p.expiryDamage) Standing")
                return false
            }
            return true
        }
        if standingLoss > 0 {
            standing = max(0, standing - standingLoss)
        }

        if !remaining.isEmpty {
            patronQueue = remaining
            currentPatron = remaining.first
            board = Array(repeating: nil, count: 12)
            drawFromBag()

            if remaining.first?.trait.name == "Disruptive" {
                blockedSlots = [Int.random(in: 0..<12)]
            } else {
                blockedSlots.removeAll()
            }

            brewResult = nil
            dayBrew += 1
            gameState = .playing
        } else {
            // End of day
            if day >= 5 {
                gameState = .win
                addLog("🏆 Season complete!")
                return
            }
            standing = min(30, standing + 2)
            addLog("🌙 Night rest. +2 Standing.")
            day += 1
            startDay(day: day)
            brewResult = nil
            gameState = .playing
        }
    }

    // MARK: - Helpers

    func addLog(_ message: String) {
        log.insert(message, at: 0)
        if log.count > 40 { log = Array(log.prefix(40)) }
    }
}
