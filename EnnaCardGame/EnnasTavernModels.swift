//
//  EnnasTavernModels.swift
//  OverQuestMatch3 — Enna's Tavern (v4 — the OPERATING COSTS build)
//
//  🍺 THE LOOP: each day has an OPERATING COSTS threshold and a ROLL BUDGET
//  (rolls are the day's currency). A customer sits down and asks for
//  something — food, tavern, or support. Their opening roll costs 1 from
//  the budget; every reroll costs 1 more. SERVING IS FREE. Serve a hand
//  whose menu icon MATCHES their need → ×2. Meet costs → day clears on the
//  spot. Serve while the budget sits at zero and you're still short → the
//  tavern goes dark. Customers keep arriving as long as rolls remain.
//
//  🎲 RANDOMNESS: uniform system RNG only. No weighting, ever.
//

import SwiftUI
import Observation
import UIKit

// ============================================================
// 🎯 NEEDS — what a customer asks for (and what menu icons mean)
// ============================================================
enum TavernNeed: String, Codable, CaseIterable {
    case food, tavern, support

    var symbol: String {
        switch self {
        case .food:    return "fork.knife"
        case .tavern:  return "bed.double.fill"
        case .support: return "heart.fill"
        }
    }
    var label: String {
        switch self {
        case .food:    return "Food"
        case .tavern:  return "Tavern"
        case .support: return "Support"
        }
    }
    var tint: Color {
        switch self {
        case .food:    return Color(red: 0.85, green: 0.45, blue: 0.20)
        case .tavern:  return Color(red: 0.88, green: 0.61, blue: 0.18)
        case .support: return Color(red: 0.80, green: 0.30, blue: 0.38)
        }
    }
}

// ============================================================
// CONFIG — every tuning dial in one place
// ============================================================
enum EnnasTavernConfig {

    static let daysPerAct = 3

    /// 🎲 THE ROLL BUDGET — the day's currency. Opening roll for each
    /// customer costs 1; each reroll costs 1. Serving is free.
    /// Kalma-esque scarcity: tuned via 25k-day simulation.
    static let baseRollBudget = 6

    /// OPERATING COSTS — Balatro's ante structure on a Kalma-tight curve:
    /// each act has a BASE, and its three days cost ×1.0 / ×1.5 / ×2.0 of
    /// it (small blind → big blind → boss wall). Each act opens BELOW the
    /// previous boss for breathing room, then climbs. Bases grow ×~1.86
    /// per act, matched by simulation to our skill economy (15k days per
    /// stage with modeled skill growth): D1 ~89% clear, act bosses
    /// ~56/55/45%, carriage final ~31%.
    /// v5 SCORING: every serve = points × multiplier. Thresholds and hand
    /// prices are tuned PER MODE (15k-day sims): dice earn steadily so their
    /// bar is higher; cards brick draws so their bar is lower and their rare
    /// hands pay like jackpots. Cards also get +1 roll budget.
    /// v6 — THE KALMA FORMULA: score = (table sum) × (hand multiplier).
    /// The dice ARE the points; the hand IS the multiplier. Rarer hand,
    /// bigger mult. Leveling a hand = +1 to its mult. Matching adds +10
    /// coins and +1 mult. Acts add +0/+2/+4 mult. Thresholds re-simmed.
    static let diceThresholds: [[Int]] = [[170, 280, 340], [400, 520, 650], [770, 930, 1080]]
    static let cardThresholds: [[Int]] = [[280, 520, 640], [720, 950, 1160], [1380, 1720, 1980]]
    static let cardsHandSize = 7

    static let diceMults: [TavernRowID: Int] = [
        .nod: 1, .pair: 2, .twoPair: 3, .trips: 4, .straight: 6,
        .fullHouse: 7, .four: 9, .five: 12, .flush: 0, .straightFlush: 0, .royal: 0
    ]
    static let cardMults: [TavernRowID: Int] = [
        .nod: 1, .pair: 2, .twoPair: 3, .trips: 4, .straight: 6, .flush: 7,
        .fullHouse: 8, .four: 10, .five: 0, .straightFlush: 14, .royal: 20
    ]

    static func handMult(_ row: TavernRowID, mode: TavernServeMode) -> Int {
        (mode == .dice ? diceMults : cardMults)[row] ?? 0
    }
    static func operatingCosts(act: Int, day: Int, mode: TavernServeMode) -> Int {
        let t = mode == .dice ? diceThresholds : cardThresholds
        return t[min(act, t.count) - 1][min(day, 3) - 1]
    }
    static func cardsExtraRolls(_ mode: TavernServeMode) -> Int { mode == .cards ? 1 : 0 }

    /// Acts stack additive mult on every serve: +0 / +2 / +4.
    static func actMultBonus(act: Int) -> Double { Double((max(1, act) - 1) * 2) }

    /// 📈 HAND LEVELING: serve a hand type this many times in a day → it
    /// levels (+50% base per level). Levels RESET each morning unless a
    /// night-school boon locked them in for the run.
    static let servesPerLevel = 3
    static let levelValueStep = 0.5
    static let keepBoonChance = 0.45     // chance the shop offers "keep it"
    static let keepBoonCost = 3
    static let offerRerollCost = 1   // hybrid: reroll the night's 3 offers

    // ---- 📓 THE LEDGER PLAYS (run layer + town layer) ----
    static let runRegularMatches = 3     // match a patron 3x this run → Regular (+1 mult)
    static let grudgeMisses = 2          // shrug them twice → Grumpy (−1 until matched)
    static let streakEvery = 3           // every 3rd consecutive match → +1 mult rest of day
    static let wordOfMouthPer = 3        // every 3 matched entries at close → +1 roll tomorrow
    /// 🔌 MASTER SWITCH: the town ledger RECORDS everything and shows
    /// hearts, but tier bonuses stay dormant until this flips to true.
    static let townPerksActive = false
    // Town Ledger tier perks in the tavern (perks only ever ADD):
    static let townRegularCoins = 5
    static let townFriendMult = 1.0
    static let townFamilyMult = 1.0
    static let townFamilyCoins = 10

    // (v5: match bonus is +1 multiplier, computed in the ViewModel's breakdown.)
    /// 🎯 Blanket bonus: fulfilling the customer's ask also adds flat points.
    static let matchFlatBonus = 10

    /// Interlude economy: tokens if the minigame is toggled OFF (flat grant),
    /// and blackjack payouts (win / push). Dice throw pays by hand tier.
    static let flatTokensPerNight = 2
    static let blackjackHands = 3
    static let blackjackWinTokens = 2
    static let blackjackPushTokens = 1

    static func rowValue(base: Int) -> Int { base }
}

// ============================================================
// ⚙️ PLAYER SETTINGS (UserDefaults — persist across launches)
// ============================================================
enum TavernSelectionMode: String { case holdSelected, rerollSelected }
enum TavernPlayMode: String { case dice, cards }
enum TavernMinigame: String { case dice, blackjack }
enum TavernNightEconomy: String { case freePick, hybrid }

struct TavernSettings {
    private static func str(_ key: String) -> String? { UserDefaults.standard.string(forKey: key) }

    /// Tap semantics: hold the tapped (default) vs reroll the tapped.
    static var selectionMode: TavernSelectionMode {
        get { TavernSelectionMode(rawValue: str("tavern_selection_mode") ?? "") ?? .holdSelected }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "tavern_selection_mode") }
    }
    /// Dice or cards on the table — switch anytime.
    static var playMode: TavernPlayMode {
        get { TavernPlayMode(rawValue: str("tavern_play_mode") ?? "") ?? .dice }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "tavern_play_mode")
            TavernLayout.shared.switchProfile(to: newValue == .cards ? "cards" : "dice")
        }
    }
    /// Night-school minigame for tokens: dice throw or blackjack.
    static var minigame: TavernMinigame {
        get { TavernMinigame(rawValue: str("tavern_minigame") ?? "") ?? .dice }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "tavern_minigame") }
    }
    /// Include the token minigame between days? Off = flat tokens, straight to skills.
    static var interludeEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "tavern_interlude") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "tavern_interlude") }
    }
    /// Night economy: freePick = pick 1 of 3, no tokens (pure Kalma).
    /// hybrid = pick 1 of 3 free + tokens reroll the offers.
    static var nightEconomy: TavernNightEconomy {
        get { TavernNightEconomy(rawValue: str("tavern_night_economy") ?? "") ?? .hybrid }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "tavern_night_economy") }
    }
}

// ============================================================
// SERVE MODE (runtime mirror of playMode; kept for save/restore)
// ============================================================
enum TavernServeMode: String, Codable { case dice, cards }

// ============================================================
// THE MENU — hand rows. Icons are ASSIGNED per run (reassign free
// in the Skills screen): each row is a food, tavern, or support dish.
// ============================================================
enum TavernRowID: String, Codable, CaseIterable {
    case nod, pair, twoPair, trips, straight, flush, fullHouse, four, five, straightFlush, royal
}

struct TavernRow: Identifiable {
    let id: TavernRowID
    let name: String
    let requirement: String
    let baseValue: Int
    let worksWithDice: Bool
    let worksWithCards: Bool
    let repeatable: Bool     // legacy field, unused in v4
}

// ============================================================
// 🎓 SKILLS v2 — multiplier machines, scaling engines, gamble
// deals, and CONDITIONAL roll triggers (Kalma-style: rolls come
// back only when the served table does something special).
// All dice-mode values are whole numbers by design.
// ============================================================
enum TavernRollTrigger: String, Codable {
    case allDifferent   // served table: five different values/ranks → +1 roll
    case luckySum       // dice sum exactly 20 · cards hold an Ace → +1 roll
    case bookends       // dice hold a 1 AND a 6 · cards a 2 AND an Ace → +1 roll
    case lastRollFuel   // serve on your very last roll → +2 rolls tomorrow
}

struct TavernSkill: Identifiable {
    let id: String
    let name: String
    let school: TavernNeed
    let cost: Int
    let blurb: String
    var mode: TavernServeMode? = nil             // nil = both modes

    var multEvery: Double = 0                    // + mult on EVERY serve
    var multOnMatch: Double = 0                  // + mult on matches (on top of base +1)
    var multForNeed: [TavernNeed: Double] = [:]  // + mult when the served dish wears this icon
    var scalingMatchStep: Int = 0                // every N matches this run → +1 mult, forever
    var scalingLevelUps: Bool = false            // +1 mult per hand leveled today
    var mismatchZero: Bool = false               // gamble: mismatches score ZERO
    var lastCallMult: Double = 0                 // + mult on serves made at 0 rolls left
    var rollTrigger: TavernRollTrigger? = nil
    var bonusTokens: Int = 0
    var costCut: Double = 0
}

// ============================================================
// CUSTOMERS (the patron cast, now with needs)
// ============================================================
struct TavernPatron: Identifiable {
    let id: String
    let name: String
    let imageName: String
    let arrivalLines: [String]   // generic lines; need lines come from the Database
}

struct TavernMerchant: Identifiable {   // legacy (market retired) — kept so the DB compiles
    let id: String
    let name: String
    let imageName: String
    let greeting: String
}

// ============================================================
// 🎨 ART PIPELINE — every UI surface asks for its asset by name
// (see ART_ASSET_GUIDE.md); if the file isn't in Assets yet, the
// code-drawn look is the fallback. Drop art in → it appears.
// ============================================================
enum TavernArt {
    static func has(_ name: String) -> Bool { UIImage(named: name) != nil }
    /// Row-specific cell art: tavern_menu_cell_<row> → tavern_menu_cell → nil
    static func cellAsset(for row: TavernRowID) -> String? {
        let specific = "tavern_menu_cell_\(row.rawValue)"
        if has(specific) { return specific }
        if has("tavern_menu_cell") { return "tavern_menu_cell" }
        return nil
    }
}

/// 9-slice stretchable image (corners stay crisp, middle stretches).
struct TavernNineSlice: View {
    let asset: String
    var cap: CGFloat = 24
    var body: some View {
        Image(asset)
            .resizable(capInsets: EdgeInsets(top: cap, leading: cap, bottom: cap, trailing: cap),
                       resizingMode: .stretch)
    }
}

// ============================================================
// 🎰 SCORE STEP — one chip in the serve cascade
// kind: 0 base hand · 1 act mult · 2 match · 3 skill · 4 penalty
// ============================================================
struct TavernScoreStep: Identifiable {
    let id: Int
    let label: String
    let detail: String
    let kind: Int
    var value: Double = 0    // numeric amount for the live animation
}

// ============================================================
// 📓 SERVICE LEDGER — every customer served this run
// ============================================================
struct TavernServiceEntry: Identifiable, Codable {
    var id: Int
    var customerName: String
    var need: TavernNeed
    var servedRow: String        // row name, or "Nothing"
    var matched: Bool
    var points: Int
}

// ============================================================
// DICE + CARDS
// ============================================================
struct TavernDie: Identifiable, Codable, Equatable {
    let id: Int
    var value: Int
    var selected: Bool
}

enum TavernCardSuit: String, Codable, CaseIterable {
    case spades, hearts, diamonds, clubs
    var isRed: Bool { self == .hearts || self == .diamonds }
    var symbolName: String {
        switch self {
        case .spades:   return "suit.spade.fill"
        case .hearts:   return "suit.heart.fill"
        case .diamonds: return "suit.diamond.fill"
        case .clubs:    return "suit.club.fill"
        }
    }
}

struct TavernPlayingCard: Identifiable, Codable, Equatable {
    let id: Int
    let rank: Int            // 2...14 (11=J 12=Q 13=K 14=A)
    let suit: TavernCardSuit
    var selected: Bool
    var rankLabel: String {
        switch rank {
        case 11: return "J"; case 12: return "Q"; case 13: return "K"; case 14: return "A"
        default: return "\(rank)"
        }
    }
}

// ============================================================
// BOSS TWISTS (last day of each act)
// ============================================================
enum TavernBossTwist: String, Codable {
    case none
    case tiredArms      // A1: roll budget −1
    case inspector      // A2: High Card scores 0
    case guildAudit     // A3: nod/pair/twoPair score 0
    case theCarriage    // A3: operating costs ×1.25
    case watchCaptain   // A3: skills switched off for the day

    var banner: String {
        switch self {
        case .none:         return ""
        case .tiredArms:    return "Enna's arms are TIRED — one fewer roll today."
        case .inspector:    return "The INSPECTOR is in. High Card earns nothing."
        case .guildAudit:   return "GUILD AUDIT. Cheap hands earn nothing today."
        case .theCarriage:  return "A gilded carriage outside. Costs up 25% today."
        case .watchCaptain: return "The WATCH CAPTAIN is watching. Skills off today."
        }
    }
}

// ============================================================
// ENDINGS (unchanged cast of 21 — see Database)
// ============================================================
enum TavernEndingKind: String, Codable { case fail, collectible, promotion, epilogue }

struct TavernEnding: Identifiable {
    let id: String
    let act: Int
    let title: String
    let kind: TavernEndingKind
    let flavor: String
}

// ============================================================
// PALETTE
// ============================================================
enum TavernPalette {
    static let wood      = Color(red: 0.23, green: 0.14, blue: 0.09)
    static let woodLight = Color(red: 0.33, green: 0.22, blue: 0.12)
    static let cream     = Color(red: 0.95, green: 0.90, blue: 0.78)
    static let amber     = Color(red: 0.88, green: 0.61, blue: 0.18)
    static let green     = Color(red: 0.45, green: 0.65, blue: 0.30)
    static let red       = Color(red: 0.75, green: 0.25, blue: 0.20)
}

// (Legacy joker/market types removed in v4 — the Database's joker
// array was excised with them. TavernMerchant remains above because the
// merchant cast still exists in the Database, dormant.)



// ============================================================
// ✒️ OVERQUEST FONT — found at runtime by scanning installed
// families for "overquest" (any capitalization / face name).
// Falls back to the system font if the family isn't bundled.
// ============================================================
enum TavernFont {
    static let resolvedName: String? = {
        for family in UIFont.familyNames {
            if family.lowercased().contains("overquest") {
                return UIFont.fontNames(forFamilyName: family).first ?? family
            }
        }
        for family in UIFont.familyNames {
            for face in UIFont.fontNames(forFamilyName: family)
            where face.lowercased().contains("overquest") { return face }
        }
        return nil
    }()

    static func of(_ size: Double) -> Font {
        let scaled = size * TavernLayout.shared.fontScale
        if let name = resolvedName { return .custom(name, size: scaled) }
        return .system(size: scaled, weight: .bold)
    }

    static func ui(_ size: CGFloat) -> UIFont {
        let scaled = size * TavernLayout.shared.fontScale
        if let name = resolvedName, let f = UIFont(name: name, size: scaled) { return f }
        return .systemFont(ofSize: scaled, weight: .heavy)
    }
}

// ============================================================
// 🔧 LAYOUT DEBUG — live-tunable section sizes, persisted PER
// PLAY MODE: dice and cards each keep their own full profile.
// Switching play mode in the menu swaps the whole profile.
// ============================================================
@Observable
class TavernLayout {
    static let shared = TavernLayout()

    var debugEnabled: Bool
    var tunerOpen = false           // drawer open (not persisted)
    var activeProfile: String       // "dice" | "cards"

    var portrait: Double = 0
    var bubbleFont: Double = 0
    var dialogueGap: Double = 0
    var custBubbleX: Double = 0
    var custBubbleW: Double = 0
    var ennaBubbleX: Double = 0
    var ennaBubbleW: Double = 0
    var diceHeight: Double = 0      // tray height (dice or cards)
    var dieScale: Double = 0
    var dieGap: Double = 0
    var fontScale: Double = 0
    var costsFont: Double = 0
    var rollHintFont: Double = 0
    var panelHeight: Double = 0
    var panelFont: Double = 0
    var midBtnW: Double = 0
    var midBtnH: Double = 0
    var menuFont: Double = 0
    var menuRowPad: Double = 0
    var sideMargin: Double = 0
    var cardW: Double = 0
    var cardH: Double = 0
    var cardGap: Double = 0
    var scoreBoxH: Double = 0
    var scoreBoxFont: Double = 0
    var hamburgerX: Double = 0
    var hamburgerY: Double = 0
    var wrenchX: Double = 0
    var wrenchY: Double = 0
    var plaqueX: Double = 0
    var plaqueY: Double = 0

    /// Baked per profile from the user's tuned layouts (Jul 17).
    static let factoryDice: [String: Double] = [
        "portrait": 104, "bubbleFont": 20, "dialogueGap": 6,
        "custBubbleX": 18, "custBubbleW": 318,
        "ennaBubbleX": -19, "ennaBubbleW": 312,
        "diceHeight": 147, "dieScale": 1.17, "dieGap": 1.53,
        "fontScale": 1.37, "costsFont": 30, "rollHintFont": 15,
        "panelHeight": 147, "panelFont": 24,
        "midBtnW": 100, "midBtnH": 71,
        "menuFont": 24, "menuRowPad": 8, "sideMargin": 10,
        "cardW": 58, "cardH": 80, "cardGap": 8,
        "scoreBoxH": 110, "scoreBoxFont": 33,
        "hamburgerX": 0, "hamburgerY": 0, "wrenchX": 0, "wrenchY": 0,
        "plaqueX": 0, "plaqueY": 0
    ]
    static let factoryCards: [String: Double] = [
        "portrait": 103, "bubbleFont": 20, "dialogueGap": 6,
        "custBubbleX": 18, "custBubbleW": 315,
        "ennaBubbleX": -19, "ennaBubbleW": 312,
        "diceHeight": 130, "dieScale": 0.60, "dieGap": 1.53,
        "fontScale": 1.37, "costsFont": 34, "rollHintFont": 15,
        "panelHeight": 147, "panelFont": 28,
        "midBtnW": 127, "midBtnH": 71,
        "menuFont": 24, "menuRowPad": 5, "sideMargin": 10,
        "cardW": 75, "cardH": 114, "cardGap": 9,
        "scoreBoxH": 52, "scoreBoxFont": 19,
        "hamburgerX": 0, "hamburgerY": 0, "wrenchX": 0, "wrenchY": 0,
        "plaqueX": 0, "plaqueY": 0
    ]
    static func factory(for profile: String) -> [String: Double] {
        profile == "cards" ? factoryCards : factoryDice
    }

    static let keys: [(String, ReferenceWritableKeyPath<TavernLayout, Double>)] = [
        ("portrait", \.portrait), ("bubbleFont", \.bubbleFont), ("dialogueGap", \.dialogueGap),
        ("custBubbleX", \.custBubbleX), ("custBubbleW", \.custBubbleW),
        ("ennaBubbleX", \.ennaBubbleX), ("ennaBubbleW", \.ennaBubbleW),
        ("diceHeight", \.diceHeight), ("dieScale", \.dieScale), ("dieGap", \.dieGap),
        ("fontScale", \.fontScale), ("costsFont", \.costsFont), ("rollHintFont", \.rollHintFont),
        ("panelHeight", \.panelHeight), ("panelFont", \.panelFont),
        ("midBtnW", \.midBtnW), ("midBtnH", \.midBtnH),
        ("menuFont", \.menuFont), ("menuRowPad", \.menuRowPad), ("sideMargin", \.sideMargin),
        ("cardW", \.cardW), ("cardH", \.cardH), ("cardGap", \.cardGap),
        ("scoreBoxH", \.scoreBoxH), ("scoreBoxFont", \.scoreBoxFont),
        ("hamburgerX", \.hamburgerX), ("hamburgerY", \.hamburgerY),
        ("wrenchX", \.wrenchX), ("wrenchY", \.wrenchY),
        ("plaqueX", \.plaqueX), ("plaqueY", \.plaqueY)
    ]

    private static func stored(_ key: String, profile: String) -> Double {
        let d = UserDefaults.standard
        if let x = d.object(forKey: "tavern_dbg_\(profile)_\(key)") as? Double { return x }
        // migrate: pre-profile values become the dice profile
        if profile == "dice", let x = d.object(forKey: "tavern_dbg_\(key)") as? Double { return x }
        return factory(for: profile)[key] ?? 0
    }

    init() {
        debugEnabled = UserDefaults.standard.bool(forKey: "tavern_dbg_enabled")
        activeProfile = TavernSettings.playMode == .cards ? "cards" : "dice"
        // one-time bump: ledger text 18 → 24 on devices that stored the old value
        let d = UserDefaults.standard
        if !d.bool(forKey: "tavern_dbg_menu24") {
            for p in ["dice", "cards"] {
                let key = "tavern_dbg_\(p)_menuFont"
                if let x = d.object(forKey: key) as? Double, x < 24 { d.set(24.0, forKey: key) }
            }
            d.set(true, forKey: "tavern_dbg_menu24")
        }
        loadProfile()
    }

    private func loadProfile() {
        for (k, kp) in Self.keys { self[keyPath: kp] = Self.stored(k, profile: activeProfile) }
    }

    func persist() {
        let d = UserDefaults.standard
        d.set(debugEnabled, forKey: "tavern_dbg_enabled")
        for (k, kp) in Self.keys { d.set(self[keyPath: kp], forKey: "tavern_dbg_\(activeProfile)_\(k)") }
    }

    /// Called when play mode changes: bank the current profile, load the other.
    func switchProfile(to profile: String) {
        guard profile != activeProfile else { return }
        persist()
        activeProfile = profile
        loadProfile()
    }

    func reset() {
        for (k, kp) in Self.keys { self[keyPath: kp] = Self.factory(for: activeProfile)[k] ?? 0 }
        persist()
    }

    /// One-tap export for pasting back into a chat with Claude.
    var exportString: String {
        """
        TAVERN LAYOUT VALUES (\(activeProfile.uppercased()))
        portraits: \(Int(portrait))
        bubble text: \(Int(bubbleFont))
        bubble gap: \(Int(dialogueGap))
        cust bubble: x \(Int(custBubbleX)) · w \(Int(custBubbleW))
        enna bubble: x \(Int(ennaBubbleX)) · w \(Int(ennaBubbleW))
        tray height: \(Int(diceHeight))
        die size: \(String(format: "%.2f", dieScale))
        die spacing: \(String(format: "%.2f", dieGap))
        font scale: \(String(format: "%.2f", fontScale))
        costs text: \(Int(costsFont))
        roll hint text: \(Int(rollHintFont))
        roll/serve height: \(Int(panelHeight))
        button text: \(Int(panelFont))
        mid buttons: \(Int(midBtnW)) x \(Int(midBtnH))
        menu text: \(Int(menuFont))
        menu row height: \(Int(menuRowPad))
        side margins: \(Int(sideMargin))
        cards: \(Int(cardW)) x \(Int(cardH)) · gap \(Int(cardGap))
        score boxes: h \(Int(scoreBoxH)) · text \(Int(scoreBoxFont))
        hamburger: x \(Int(hamburgerX)) · y \(Int(hamburgerY))
        wrench: x \(Int(wrenchX)) · y \(Int(wrenchY))
        costs plaque: x \(Int(plaqueX)) · y \(Int(plaqueY))
        """
    }
}
