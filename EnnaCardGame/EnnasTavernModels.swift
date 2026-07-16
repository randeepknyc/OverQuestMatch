//
//  EnnasTavernModels.swift
//  OverQuestMatch3 — Enna's Tavern (run-based roguelike, "Pour Decisions v3")
//
//  All data types + the tuning dials.
//  ⚠️ To change game CONTENT (jokers, endings, patrons, menu values),
//     edit EnnasTavernDatabase.swift instead.
//  ⚠️ To change game NUMBERS (thresholds, rerolls, prices),
//     edit EnnasTavernConfig at the bottom of THIS file.
//
//  🎲 RANDOMNESS NOTE (user request): every roll, deal, and shuffle in
//  this game uses Swift's uniform system RNG. There is NO weighting in
//  the player's favor anywhere — unlike Dice of Kalma. Fair dice, fair deck.
//

import SwiftUI

// ============================================================
// SERVE MODE — dice or cards
// Act 1 = dice · Act 2 = cards · Act 3 = player picks per patron
// ============================================================
enum TavernServeMode: String, Codable {
    case dice, cards
}

// ============================================================
// THE MENU — hand rows (the Deviled Dice score sheet)
// ============================================================
enum TavernRowID: String, Codable, CaseIterable, Identifiable {
    case nod            // anything at all (always available, repeatable)
    case pair
    case twoPair
    case trips
    case straight
    case flush          // cards only
    case fullHouse
    case four
    case five           // dice only
    case straightFlush  // cards only

    var id: String { rawValue }
}

struct TavernRow: Identifiable {
    let id: TavernRowID
    let name: String          // the tavern-service name shown to the player
    let requirement: String   // human-readable requirement
    let baseValue: Int        // points at level 1
    let worksWithDice: Bool
    let worksWithCards: Bool
    let repeatable: Bool      // only The Nod
}

// ============================================================
// DICE & CARDS
// ============================================================
struct TavernDie: Identifiable, Codable, Equatable {
    let id: Int          // 0...4 (slot)
    var value: Int       // 1...6
    var locked: Bool
}

enum TavernCardSuit: String, Codable, CaseIterable {
    case hearts, diamonds, clubs, spades

    var symbolName: String {
        switch self {
        case .hearts:   return "suit.heart.fill"
        case .diamonds: return "suit.diamond.fill"
        case .clubs:    return "suit.club.fill"
        case .spades:   return "suit.spade.fill"
        }
    }

    var isRed: Bool { self == .hearts || self == .diamonds }
}

struct TavernPlayingCard: Identifiable, Codable, Equatable {
    let id: Int              // unique within the deck (0...51)
    let rank: Int            // 2...14 (11=J 12=Q 13=K 14=A)
    let suit: TavernCardSuit
    var held: Bool

    var rankLabel: String {
        switch rank {
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        case 14: return "A"
        default: return "\(rank)"
        }
    }
}

// ============================================================
// JOKERS (the shelf behind the bar — max 5)
// All effect hooks default to "no effect" so database entries stay short.
// ============================================================
enum TavernFaction: String, Codable {
    case none, guild, nobles, commons, watch

    var label: String {
        switch self {
        case .none:    return ""
        case .guild:   return "GUILD"
        case .nobles:  return "NOBLES"
        case .commons: return "COMMONS"
        case .watch:   return "WATCH"
        }
    }
}

struct TavernJoker: Identifiable {
    let id: String
    let name: String
    let icon: String              // emoji shown on the shelf
    let actClass: Int             // 1 = Habit, 2 = Fixture/Regular, 3 = Faction
    let faction: TavernFaction
    let cost: Int
    let blurb: String             // effect text shown to the player

    // ---- effect hooks ----
    let thresholdMultiplier: Double            // e.g. 0.9 = quotas −10%
    let extraRerolls: Int                      // +N rerolls (dice) / redraws (cards)
    let flatBonusPerBank: Int                  // +N points on every bank
    let rowMultipliers: [TavernRowID: Double]  // e.g. [.fullHouse: 2.0]
    let rowFlatBonuses: [TavernRowID: Int]     // e.g. [.trips: 20]
    let extraPatronsPerDay: Int
    let extraPatronsFirstDayOfAct: Int
    let morningCoin: Int                       // coin each morning
    let firstBankMultiplier: Double            // first bank of the day ×N
    let spite: Bool                            // bank ≤10 → next bank +15
    let gremlockNod: Bool                      // first Nod each day scores 25
    let noamronRisk: Bool                      // 20%/day: −3 coin at day end
    let unique: Bool                           // the Sword (special offer)

    init(
        id: String, name: String, icon: String, actClass: Int,
        faction: TavernFaction = .none, cost: Int, blurb: String,
        thresholdMultiplier: Double = 1.0,
        extraRerolls: Int = 0,
        flatBonusPerBank: Int = 0,
        rowMultipliers: [TavernRowID: Double] = [:],
        rowFlatBonuses: [TavernRowID: Int] = [:],
        extraPatronsPerDay: Int = 0,
        extraPatronsFirstDayOfAct: Int = 0,
        morningCoin: Int = 0,
        firstBankMultiplier: Double = 1.0,
        spite: Bool = false,
        gremlockNod: Bool = false,
        noamronRisk: Bool = false,
        unique: Bool = false
    ) {
        self.id = id; self.name = name; self.icon = icon
        self.actClass = actClass; self.faction = faction
        self.cost = cost; self.blurb = blurb
        self.thresholdMultiplier = thresholdMultiplier
        self.extraRerolls = extraRerolls
        self.flatBonusPerBank = flatBonusPerBank
        self.rowMultipliers = rowMultipliers
        self.rowFlatBonuses = rowFlatBonuses
        self.extraPatronsPerDay = extraPatronsPerDay
        self.extraPatronsFirstDayOfAct = extraPatronsFirstDayOfAct
        self.morningCoin = morningCoin
        self.firstBankMultiplier = firstBankMultiplier
        self.spite = spite
        self.gremlockNod = gremlockNod
        self.noamronRisk = noamronRisk
        self.unique = unique
    }
}

// ============================================================
// PATRONS & MERCHANTS (the gmarker roster)
// ============================================================
struct TavernPatron: Identifiable {
    let id: String            // matches key used in saves
    let name: String
    let imageName: String     // gmarker asset name
    let arrivalLines: [String]
}

struct TavernMerchant: Identifiable {
    let id: String
    let name: String
    let imageName: String
    let greeting: String
}

// ============================================================
// ENDINGS (the 21 — plus generic fallbacks)
// ============================================================
enum TavernEndingKind: String, Codable {
    case fail, collectible, promotion
}

struct TavernEnding: Identifiable {
    let id: String        // "act1_1" ... "act3_7"
    let act: Int
    let title: String
    let kind: TavernEndingKind
    let flavor: String    // VERBATIM from the original design — do not rewrite
}

// ============================================================
// BOSS TWISTS (day 3 of each act)
// ============================================================
enum TavernBossTwist: String, Codable {
    case none
    case tiredArms      // Act 1: −1 reroll today
    case inspector      // Act 2: The Nod is unavailable today
    case guildAudit     // Act 3: Nod/Pair/Two Pair score 0 today
    case theCarriage    // Act 3: threshold +25% today
    case watchCaptain   // Act 3: all jokers disabled today

    var banner: String {
        switch self {
        case .none:         return ""
        case .tiredArms:    return "BOSS · THE END OF THE WEEK"
        case .inspector:    return "BOSS · RENT DAY — THE INSPECTOR"
        case .guildAudit:   return "BOSS · THE FESTIVAL — GUILD AUDIT"
        case .theCarriage:  return "BOSS · THE FESTIVAL — THE CARRIAGE"
        case .watchCaptain: return "BOSS · THE FESTIVAL — THE WATCH CAPTAIN"
        }
    }

    var detail: String {
        switch self {
        case .none:         return ""
        case .tiredArms:    return "Enna is exhausted. 1 fewer do-over per patron today."
        case .inspector:    return "He is watching the counter. The Nod cannot be served today."
        case .guildAudit:   return "Only proper service counts. The Nod, A Kind Word, and Split Shift score 0 today."
        case .theCarriage:  return "A noble's carriage blocks the door. Every patron's ask is 25% higher today."
        case .watchCaptain: return "He is staring directly at your best customers. All jokers are disabled today."
        }
    }
}

// ============================================================
// MARKET OFFERS
// ============================================================
enum TavernOfferKind {
    case joker(TavernJoker)
    case rowUpgrade(TavernRowID)
}

struct TavernMarketOffer: Identifiable {
    let id = UUID()
    let kind: TavernOfferKind
    let price: Int
}

// ============================================================
// ⚙️ TUNING DIALS — change numbers here to rebalance the game
// ============================================================
struct EnnasTavernConfig {

    /// Days per act (3 acts total). Boss twist fires on the LAST day of each act.
    static let daysPerAct = 3

    /// Patrons (serves) per day before joker bonuses. The biggest difficulty lever.
    static let basePatronsPerDay = 4

    /// Do-overs per patron: rerolls (dice) / redraws (cards).
    static let baseRerolls = 2

    /// THE ASK — quota PER PATRON (Deviled Dice style), by [act][day].
    /// The single hand you bank for a patron must score AT LEAST this.
    /// Overage does NOT carry anywhere. Come up short → the run ends.
    /// (Escalation also comes free from once-per-day menu rows: cheap rows
    /// get used up, forcing bigger hands for later patrons.)
    /// Pre-playtest guesses — tune freely.
    static let serveQuotas: [[Int]] = [
        [8, 12, 18],       // Act 1 — getting through the week
        [25, 32, 42],      // Act 2 — rent
        [55, 70, 90]       // Act 3 — the festival
    ]

    /// Coin at the start of a run.
    static let startingCoin = 4

    /// Flat coin for finishing a day. (No overage bonus — points above
    /// the ask are just applause.)
    static let dayClearCoin = 6

    /// Market prices.
    static let shopRerollCost = 2
    static let upgradeCosts = [4, 7]     // level 1→2, level 2→3
    static let swordPrice = 12

    /// Joker shelf size (Balatro's number; it works).
    static let maxJokers = 5

    /// Menu row value scaling per level: L1 = base, L2 = 1.5×, L3 = 2×.
    static func rowValue(base: Int, level: Int) -> Int {
        (base * (level + 1)) / 2
    }
}

// ============================================================
// 🎨 SHARED PALETTE
// ============================================================
struct TavernPalette {
    static let wood      = Color(red: 0.13, green: 0.09, blue: 0.06)
    static let woodLight = Color(red: 0.22, green: 0.15, blue: 0.10)
    static let amber     = Color(red: 0.95, green: 0.65, blue: 0.20)
    static let cream     = Color(red: 0.96, green: 0.92, blue: 0.82)
    static let green     = Color(red: 0.35, green: 0.75, blue: 0.40)
    static let red       = Color(red: 0.85, green: 0.30, blue: 0.25)
}
