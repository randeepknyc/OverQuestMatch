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

enum PotionShopBoonFrequency: String, Codable {
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
        // ─── JULY 4, 2026: RELIC-STYLE persistent effects + the picker ───
        /// RELIC: at the END of every day, restore composure to full.
        case relicHealAtDayEnd
        /// RELIC: START every day with this much shield.
        case relicShieldAtDayStart(Int)
        /// Opens the DIE-UPGRADE PICKER: the player chooses a die type and
        /// its first die tiers up (basic → silver → gold).
        case dieUpgrade
    }
    let effect: Effect
}

// MARK: - The RUN STATE container (§40.1)
//
// The persistent bundle for one run. Lives on PotionShopGameState. Holds the
// deck and the boons taken. Resets only on a new run. (Relics list will be
// added here later — that's why this is its own container.)

struct PotionShopRunState: Codable {
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

    // ─── JULY 4, 2026: relic effects + pending upgrade picks ────────────
    /// True = composure restores to full at the end of every day.
    var healAtDayEnd: Bool = false
    /// Shield granted at the start of every day (0 = none).
    var shieldAtDayStart: Int = 0
    /// Die upgrades the player has earned but not yet picked (each opens
    /// the upgrade-picker overlay once).
    var pendingDieUpgrades: Int = 0
    /// True once the Day-2 magic (mirror) die has been added to the deck.
    var magicDieGranted: Bool = false

    // Custom Codable so saves from BEFORE these fields still decode.
    private enum CodingKeys: String, CodingKey {
        case deck, boonsTaken, typeBonuses,
             healAtDayEnd, shieldAtDayStart, pendingDieUpgrades, magicDieGranted
    }
    init() {}
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        deck = try c.decodeIfPresent([PotionShopBagDie].self, forKey: .deck) ?? []
        boonsTaken = try c.decodeIfPresent([String].self, forKey: .boonsTaken) ?? []
        typeBonuses = try c.decodeIfPresent([PotionShopDieType: Int].self, forKey: .typeBonuses) ?? [:]
        healAtDayEnd = try c.decodeIfPresent(Bool.self, forKey: .healAtDayEnd) ?? false
        shieldAtDayStart = try c.decodeIfPresent(Int.self, forKey: .shieldAtDayStart) ?? 0
        pendingDieUpgrades = try c.decodeIfPresent(Int.self, forKey: .pendingDieUpgrades) ?? 0
        magicDieGranted = try c.decodeIfPresent(Bool.self, forKey: .magicDieGranted) ?? false
    }

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
        healAtDayEnd = false
        shieldAtDayStart = 0
        pendingDieUpgrades = 0
        magicDieGranted = false
    }

    /// Apply a chosen boon to the run deck.
    mutating func apply(_ boon: PotionShopBoon) {
        switch boon.effect {
        case let .addDie(type, rule):
            // JULY 5, 2026 (boon audit): an added die INHERITS the type's
            // best upgraded faces — under type-draw dealing a fresh basic
            // die would only DILUTE a lane the player has upgraded. (The
            // default pool no longer uses .addDie, but any user-added
            // card stays safe.)
            var newDie = PotionShopBagDie(
                id: "die_\(type.rawValue)_boon_\(UUID().uuidString.prefix(4))",
                type: type,
                tier: .basic,
                rule: rule
            )
            newDie.customFaces = deck
                .filter { $0.type == type }
                .compactMap { $0.customFaces }
                .max(by: { $0.reduce(0, +) < $1.reduce(0, +) })
            deck.append(newDie)
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
        case .relicHealAtDayEnd:
            healAtDayEnd = true
        case let .relicShieldAtDayStart(amount):
            shieldAtDayStart += amount
        case .dieUpgrade:
            // GameView watches this counter and presents the picker overlay.
            pendingDieUpgrades += 1
        }
        boonsTaken.append(boon.name)
    }
}

// MARK: - The BOON POOL (placeholder content)
//
// The set of boons that can appear. Each menu draws 3 at random. Edit freely;
// these are obvious test placeholders so you can see the system working.

enum PotionShopBoonPool {
    // ═══ JULY 4, 2026: REBUILT STARTER POOL — modest by design. ═══
    // The old pool's stat piles (+2s everywhere) outgrew every threat
    // (§67.3 finding 1). These start small and creative; EDIT FREELY —
    // each row is one card: (name, blurb, emoji, effect).
    static let all: [PotionShopBoon] = [
        PotionShopBoon(name: "Die Upgrade", blurb: "Upgrade one die — you pick which",
                       emoji: "⬆️", effect: .dieUpgrade),
        PotionShopBoon(name: "Mended Spirit", blurb: "RELIC: fully restore composure at the end of each day",
                       emoji: "💖", effect: .relicHealAtDayEnd),
        PotionShopBoon(name: "Warded Morning", blurb: "RELIC: start each day with 5 shield",
                       emoji: "🛡️", effect: .relicShieldAtDayStart(5)),
        // JULY 5, 2026 (boon audit): the three "add a die" cards were DEAD
        // under type-draw dealing — die count doesn't change what's dealt,
        // and a fresh basic die could even DILUTE an upgraded lane. Replaced
        // with type-wide +1s (half the old §pre-67 values; verified consumed
        // by the brew math). ✏️ EDIT FREELY — these are your cards.
        PotionShopBoon(name: "Potent Brew", blurb: "+1 to ALL potency dice",
                       emoji: "⚗️", effect: .typeWideBonus(type: .potency, amount: 1)),
        PotionShopBoon(name: "Healing Mastery", blurb: "+1 to ALL heal dice",
                       emoji: "💚", effect: .typeWideBonus(type: .heal, amount: 1)),
        PotionShopBoon(name: "Stoked Coals", blurb: "+1 to ALL stability dice (bigger fire refills)",
                       emoji: "🔥", effect: .typeWideBonus(type: .stability, amount: 1)),
    ]

    /// Draw `n` distinct random boons for a menu.
    /// JULY 5, 2026 (boon audit): pass the run so ONE-SHOT relics the
    /// player already owns are excluded — a re-offered Mended Spirit was
    /// a dead pick. (Warded Morning stays offerable: its shield STACKS.)
    static func draw(_ n: Int = 3, owned run: PotionShopRunState? = nil) -> [PotionShopBoon] {
        var pool = all
        if let run, run.healAtDayEnd {
            pool.removeAll {
                if case .relicHealAtDayEnd = $0.effect { return true }
                return false
            }
        }
        return Array(pool.shuffled().prefix(n))
    }
}
