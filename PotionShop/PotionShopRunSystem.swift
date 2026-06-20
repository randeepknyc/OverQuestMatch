//
//  PotionShopRunSystem.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — ROGUELITE RUN SYSTEM (test version)
//  Place in: PotionShop/ folder  ← NEW FILE, add to the Xcode target
//
//  ═══════════════════════════════════════════════════════════════════════
//  TEST VERSION — June 18, 2026.  NOT FINAL.  (See CAULDRON_CONTEXT §40.)
//  ═══════════════════════════════════════════════════════════════════════
//  This is a first, testable cut of the roguelite spine:
//    • A persistent RUN (deck + boons taken) that survives the whole run
//      and resets only on a new run.
//    • BOONS: between-round choices that add or upgrade dice in your deck.
//      The deck STOPS being rebuilt each round — it carries forward, and
//      boons are the only thing that changes it.
//    • Placeholder boon menu: pick 1 of 3 per round (frequency is a flag).
//
//  NOT included yet (by design): relics, dynamic board, real balance values.
//  Everything here is deliberately simple so it's easy to see and tune.
//

import SwiftUI

// MARK: - Boon frequency (toggle — see §40.4)

enum PotionShopBoonFrequency {
    case everyRound   // boon menu after every round (default for testing)
    case everyDay     // boon menu only when a day is cleared
}

// MARK: - A die's optional RULE (rides on the die, persists via the deck)
//
// TEST VERSION: a rule is just a flat bonus the die carries. When a boon
// adds/upgrades a die, it can attach one of these. The brew math reads it.
// Expand later into richer behaviors (special reach, conditional effects…).

struct PotionShopDieRule: Codable, Equatable {
    /// Flat amount added to this die's value when it resolves (e.g. an
    /// upgraded potency that hits for +2). 0 = no bonus.
    var bonusValue: Int = 0
    /// Human-readable label for menus/inspection ("+2 potency").
    var label: String = ""
}

// MARK: - A BOON (a between-round choice)

struct PotionShopBoon: Identifiable {
    let id = UUID()
    let name: String
    let blurb: String          // one-line description shown on the card
    let emoji: String          // simple placeholder art

    /// What this boon does to the run when chosen. Kinds for the test:
    enum Effect {
        /// Add a brand-new die (of this type, with this optional rule) to the deck.
        case addDie(type: PotionShopDieType, rule: PotionShopDieRule)
        /// Upgrade: bump the bonusValue of the FIRST deck die of this type by `amount`.
        case upgradeDie(type: PotionShopDieType, amount: Int)
        /// TYPE-WIDE (June 18, 2026): add `amount` to EVERY die of this type
        /// for the rest of the run (e.g. "+2 to all shield"). Persists via the
        /// run's typeBonuses table, applied to each die when it's dealt.
        case typeWideBonus(type: PotionShopDieType, amount: Int)
    }
    let effect: Effect
}

// MARK: - The RUN STATE container (§40.1)
//
// The persistent bundle for one run. Lives on PotionShopGameState. Holds the
// deck and the boons taken. Resets only on a new run. (Relics list will be
// added here later — that's why this is its own container.)

struct PotionShopRunState {
    /// The persistent deck — the dice the player has accumulated. Built ONCE
    /// at run start (seedStartingDeck) and changed ONLY by boons thereafter.
    var deck: [PotionShopBagDie] = []
    /// Boons taken this run, in order (for display / history).
    var boonsTaken: [String] = []
    /// TYPE-WIDE bonuses (June 18, 2026): type → flat amount added to EVERY
    /// die of that type when dealt (e.g. [.shield: 2] = "all shield +2").
    /// Persists for the run; applied in drawFromBag on top of a die's own
    /// per-die rule bonus.
    var typeBonuses: [PotionShopDieType: Int] = [:]

    /// Seed the starting deck once at run start. Mirrors the old hardcoded
    /// bag, but now it's the RUN deck that persists instead of being rebuilt
    /// every round.
    mutating func seedStartingDeck() {
        let types: [PotionShopDieType] = [
            .potency, .potency, .potency,
            .stability, .stability,
            .boost,
            .heal,
            .shield,
        ]
        deck = types.enumerated().map { (i, type) in
            PotionShopBagDie(
                id: "die_\(type.rawValue)_\(i)_\(UUID().uuidString.prefix(4))",
                type: type,
                tier: .basic
            )
        }
        boonsTaken.removeAll()
        typeBonuses.removeAll()
    }

    /// Apply a chosen boon to the run deck.
    mutating func apply(_ boon: PotionShopBoon) {
        switch boon.effect {
        case let .addDie(type, rule):
            deck.append(PotionShopBagDie(
                id: "die_\(type.rawValue)_boon_\(UUID().uuidString.prefix(4))",
                type: type,
                tier: .basic,
                rule: rule
            ))
        case let .upgradeDie(type, amount):
            // Bump the first matching die's bonus; if none exists, add one.
            if let idx = deck.firstIndex(where: { $0.type == type }) {
                deck[idx].rule.bonusValue += amount
                deck[idx].rule.label = "+\(deck[idx].rule.bonusValue) \(type.rawValue)"
            } else {
                deck.append(PotionShopBagDie(
                    id: "die_\(type.rawValue)_up_\(UUID().uuidString.prefix(4))",
                    type: type,
                    tier: .basic,
                    rule: PotionShopDieRule(bonusValue: amount, label: "+\(amount) \(type.rawValue)")
                ))
            }
        case let .typeWideBonus(type, amount):
            // June 18: every die of this type gets +amount for the rest of
            // the run (stored in typeBonuses, applied in drawFromBag).
            typeBonuses[type, default: 0] += amount
        }
        boonsTaken.append(boon.name)
    }
}

// MARK: - The BOON POOL (placeholder content)
//
// The set of boons that can appear. Each menu draws 3 at random. Edit freely;
// these are obvious test placeholders so you can see the system working.

enum PotionShopBoonPool {
    static let all: [PotionShopBoon] = [
        PotionShopBoon(name: "Extra Potency", blurb: "Add a potency die to your deck",
                       emoji: "⚗️", effect: .addDie(type: .potency, rule: PotionShopDieRule(bonusValue: 0, label: ""))),
        PotionShopBoon(name: "Sharpen Potency", blurb: "A potency die hits for +2",
                       emoji: "🗡️", effect: .upgradeDie(type: .potency, amount: 2)),
        PotionShopBoon(name: "Extra Heal", blurb: "Add a heal die to your deck",
                       emoji: "💚", effect: .addDie(type: .heal, rule: PotionShopDieRule(bonusValue: 0, label: ""))),
        PotionShopBoon(name: "Stronger Heal", blurb: "A heal die restores +2",
                       emoji: "✨", effect: .upgradeDie(type: .heal, amount: 2)),
        PotionShopBoon(name: "Extra Shield", blurb: "Add a shield die to your deck",
                       emoji: "🛡️", effect: .addDie(type: .shield, rule: PotionShopDieRule(bonusValue: 0, label: ""))),
        PotionShopBoon(name: "Bigger Boost", blurb: "A boost die is +2 stronger",
                       emoji: "🔆", effect: .upgradeDie(type: .boost, amount: 2)),
        PotionShopBoon(name: "Extra Boost", blurb: "Add a boost die to your deck",
                       emoji: "➕", effect: .addDie(type: .boost, rule: PotionShopDieRule(bonusValue: 0, label: ""))),
        PotionShopBoon(name: "Steady Hand", blurb: "A stability die is +2 stronger",
                       emoji: "🪨", effect: .upgradeDie(type: .stability, amount: 2)),
        // ─── Type-wide boons (June 18, 2026): affect EVERY die of a type ───
        PotionShopBoon(name: "Reinforced Shields", blurb: "Add +2 to ALL shield dice",
                       emoji: "🛡️", effect: .typeWideBonus(type: .shield, amount: 2)),
        PotionShopBoon(name: "Healing Mastery", blurb: "Add +1 to ALL heal dice",
                       emoji: "💚", effect: .typeWideBonus(type: .heal, amount: 1)),
        PotionShopBoon(name: "Amplified Boosts", blurb: "Add +2 to ALL boost dice",
                       emoji: "🔆", effect: .typeWideBonus(type: .boost, amount: 2)),
        PotionShopBoon(name: "Potent Brew", blurb: "Add +1 to ALL potency dice",
                       emoji: "⚗️", effect: .typeWideBonus(type: .potency, amount: 1)),
    ]

    /// Draw `n` distinct random boons for a menu.
    static func draw(_ n: Int = 3) -> [PotionShopBoon] {
        Array(all.shuffled().prefix(n))
    }
}
