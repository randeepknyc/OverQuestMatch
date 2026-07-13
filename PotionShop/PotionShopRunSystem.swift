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
        // ─── JULY 10, 2026: PLAYTEST V1 cards ────────────────────────
        /// FOCUS-FREE DIE: adds a permanent extra die of this type to the
        /// deck that costs NO Focus to place. Dealt like any other die of
        /// its lane (so each pick raises the odds your dealt die of that
        /// type is the free one). Only heal / shield / potency.
        case ffDie(type: PotionShopDieType)
        /// CURSE: +2 to all potency dice, −1 to all heal dice. A tempting
        /// deal with teeth — the round pool's one trap.
        case bitterDregs
        /// RELIC: +1 max composure (stacks — the run's ceiling grows).
        case ironKettle(Int)
        /// RELIC: once per day, the first flame you'd lose relights itself.
        case emberCharm
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
    // ─── JULY 10, 2026: PLAYTEST V1 relic state ──────────────────────
    /// Iron Kettle stacks: added to PotionShopConfig.maxComposure wherever
    /// the composure CEILING is read (gs.effectiveMaxComposure).
    var maxCompBonus: Int = 0
    /// True = Ember Charm owned (once-per-day flame protection).
    var emberCharm: Bool = false

    // Custom Codable so saves from BEFORE these fields still decode.
    private enum CodingKeys: String, CodingKey {
        case deck, boonsTaken, typeBonuses,
             healAtDayEnd, shieldAtDayStart, pendingDieUpgrades, magicDieGranted,
             maxCompBonus, emberCharm
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
        maxCompBonus = try c.decodeIfPresent(Int.self, forKey: .maxCompBonus) ?? 0
        emberCharm = try c.decodeIfPresent(Bool.self, forKey: .emberCharm) ?? false
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
        maxCompBonus = 0
        emberCharm = false
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
        case let .ffDie(type):
            // JULY 10, 2026 (PLAYTEST V1): a FOCUS-FREE die joins the lane
            // permanently. Inherits the lane's best upgraded faces (same
            // rule as .addDie — a basic die would dilute an upgraded lane).
            var ff = PotionShopBagDie(
                id: "die_\(type.rawValue)_ff_\(UUID().uuidString.prefix(4))",
                type: type,
                tier: .basic
            )
            ff.customFaces = deck
                .filter { $0.type == type }
                .compactMap { $0.customFaces }
                .max(by: { $0.reduce(0, +) < $1.reduce(0, +) })
            ff.isFocusFree = true
            deck.append(ff)
        case .bitterDregs:
            // The curse: both edges at once, via the same type-bonus table.
            typeBonuses[.potency, default: 0] += 2
            typeBonuses[.heal, default: 0] -= 1
        case let .ironKettle(amount):
            maxCompBonus += amount
        case .emberCharm:
            emberCharm = true
        }
        boonsTaken.append(boon.name)
    }
}

// MARK: - The BOON POOL (placeholder content)
//
// The set of boons that can appear. Each menu draws 3 at random. Edit freely;
// these are obvious test placeholders so you can see the system working.

enum PotionShopBoonPool {
    // JULY 7, 2026: blurbs shortened to ONE short sentence each so cards
    // never truncate on device. ✏️ These strings are YOURS — edit freely.
    // ═══ JULY 4, 2026: REBUILT STARTER POOL — modest by design. ═══
    // The old pool's stat piles (+2s everywhere) outgrew every threat
    // (§67.3 finding 1). These start small and creative; EDIT FREELY —
    // each row is one card: (name, blurb, emoji, effect).
    /// JULY 10, 2026 (PLAYTEST V1): the pool SPLIT in two.
    ///   • ROUND pool — offered at every mid-day round boundary.
    ///   • RELIC pool — offered when a DAY is completed ("Choose a Relic").
    /// `all` remains as the combined list (debug menus and old call sites).
    static var all: [PotionShopBoon] { roundPool + relicPool }

    /// How many Focus-Free dice one lane may own. At the cap, that FF card
    /// stops being offered (pool filter — same rule as an owned Mended
    /// Spirit; a maxed card must NEVER be a dead pick).
    static let ffCapPerLane = 1

    // ✏️ EDIT FREELY — names, blurbs, emoji are yours.
    static let roundPool: [PotionShopBoon] = [
        PotionShopBoon(name: "Die Upgrade", blurb: "Upgrade a die",
                       emoji: "⬆️", effect: .dieUpgrade),
        PotionShopBoon(name: "Potent Brew", blurb: "+1 all potency",
                       emoji: "⚗️", effect: .typeWideBonus(type: .potency, amount: 1)),
        PotionShopBoon(name: "Healing Mastery", blurb: "+1 all heal",
                       emoji: "💚", effect: .typeWideBonus(type: .heal, amount: 1)),
        PotionShopBoon(name: "Stoked Coals", blurb: "+1 all stability",
                       emoji: "🔥", effect: .typeWideBonus(type: .stability, amount: 1)),
        // The FOCUS-FREE dice (lab-tuned: potency confirmed essential —
        // 31% → 76% completion in the pool tests; cap 1 per lane).
        PotionShopBoon(name: "Focus-Free Heal", blurb: "Free heal die",
                       emoji: "✨", effect: .ffDie(type: .heal)),
        PotionShopBoon(name: "Focus-Free Shield", blurb: "Free shield die",
                       emoji: "✨", effect: .ffDie(type: .shield)),
        PotionShopBoon(name: "Focus-Free Potency", blurb: "Free potency die",
                       emoji: "✨", effect: .ffDie(type: .potency)),
        // The trap — rare and loud by design (§ trap guidance).
        PotionShopBoon(name: "Bitter Dregs", blurb: "+2 potency, −1 heal",
                       emoji: "☕", effect: .bitterDregs),
    ]

    static let relicPool: [PotionShopBoon] = [
        PotionShopBoon(name: "Mended Spirit", blurb: "Full heal nightly",
                       emoji: "💖", effect: .relicHealAtDayEnd),
        PotionShopBoon(name: "Warded Morning", blurb: "+5 shield mornings",
                       emoji: "🛡️", effect: .relicShieldAtDayStart(5)),
        PotionShopBoon(name: "Iron Kettle", blurb: "+1 max composure",
                       emoji: "🫖", effect: .ironKettle(1)),
        PotionShopBoon(name: "Ember Charm", blurb: "Relights one flame daily",
                       emoji: "🕯️", effect: .emberCharm),
    ]

    /// LEGACY layout of the old single pool (kept for reference):
    static let legacyAll: [PotionShopBoon] = [
        PotionShopBoon(name: "Die Upgrade", blurb: "Upgrade a die",
                       emoji: "⬆️", effect: .dieUpgrade),
        PotionShopBoon(name: "Mended Spirit", blurb: "Full heal nightly",
                       emoji: "💖", effect: .relicHealAtDayEnd),
        PotionShopBoon(name: "Warded Morning", blurb: "+5 shield mornings",
                       emoji: "🛡️", effect: .relicShieldAtDayStart(5)),
        // JULY 5, 2026 (boon audit): the three "add a die" cards were DEAD
        // under type-draw dealing — die count doesn't change what's dealt,
        // and a fresh basic die could even DILUTE an upgraded lane. Replaced
        // with type-wide +1s (half the old §pre-67 values; verified consumed
        // by the brew math). ✏️ EDIT FREELY — these are your cards.
        PotionShopBoon(name: "Potent Brew", blurb: "+1 all potency",
                       emoji: "⚗️", effect: .typeWideBonus(type: .potency, amount: 1)),
        PotionShopBoon(name: "Healing Mastery", blurb: "+1 all heal",
                       emoji: "💚", effect: .typeWideBonus(type: .heal, amount: 1)),
        PotionShopBoon(name: "Stoked Coals", blurb: "+1 all stability",
                       emoji: "🔥", effect: .typeWideBonus(type: .stability, amount: 1)),
    ]

    /// Draw `n` distinct random boons for a menu.
    /// JULY 5, 2026 (boon audit): pass the run so ONE-SHOT relics the
    /// player already owns are excluded — a re-offered Mended Spirit was
    /// a dead pick. (Warded Morning stays offerable: its shield STACKS.)
    static func draw(_ n: Int = 3, owned run: PotionShopRunState? = nil) -> [PotionShopBoon] {
        // JULY 10, 2026 (PLAYTEST V1): mid-day menus draw from the ROUND
        // pool. FF cards leave the draw once the lane owns its cap of
        // Focus-Free dice — never a dead pick.
        var pool = roundPool
        if let run {
            pool.removeAll {
                if case let .ffDie(type) = $0.effect {
                    let owned = run.deck.filter { $0.type == type && $0.isFocusFree == true }.count
                    return owned >= ffCapPerLane
                }
                return false
            }
        }
        return Array(pool.shuffled().prefix(n))
    }

    /// JULY 10, 2026 (PLAYTEST V1): the DAY-COMPLETION relic menu.
    /// One-shot relics the player owns are excluded (Mended Spirit,
    /// Ember Charm); Warded Morning and Iron Kettle STACK, so they stay.
    static func drawRelics(_ n: Int = 3, owned run: PotionShopRunState? = nil) -> [PotionShopBoon] {
        var pool = relicPool
        if let run {
            if run.healAtDayEnd {
                pool.removeAll { if case .relicHealAtDayEnd = $0.effect { return true }; return false }
            }
            if run.emberCharm {
                pool.removeAll { if case .emberCharm = $0.effect { return true }; return false }
            }
        }
        return Array(pool.shuffled().prefix(n))
    }
}
