import Foundation
import Observation

// ============================================================
// 🏘️ THE TOWN LEDGER — one persistent record, shared by EVERY
// mini-game, of the player's relationship with each character
// in Deccan Tedi. Serve Bakasura in the Shop, serve him again
// in Enna's Tavern — same counter.
//
// Rules (from the Town Ledger design chat):
// • Tiers by TOTAL serves across all games: 3 → Regular,
//   7 → Friend, 12 → Family. Relationships NEVER decrease.
// • Perks only ever ADD — a known face is strictly a warmer,
//   easier version of a stranger.
// • "Gremlock #47"-style names also tally a master "Gremlocks"
//   record (they're like the Smurfs — sub-entries + one family).
//
// This file lives in Shared/ so every game can read and write it.
// ============================================================

enum TownGame: String, Codable {
    case ennasTavern, shopOfOddities, match3, tsum
}

enum TownTier: Int, Codable, Comparable {
    case stranger = 0, regular = 1, friend = 2, family = 3

    static func from(serves: Int) -> TownTier {
        if serves >= 12 { return .family }
        if serves >= 7 { return .friend }
        if serves >= 3 { return .regular }
        return .stranger
    }
    var label: String {
        switch self {
        case .stranger: return ""
        case .regular:  return "Regular"
        case .friend:   return "Friend"
        case .family:   return "Family"
        }
    }
    /// Heart pips shown beside portraits (0-3).
    var pips: Int { rawValue }

    static func < (a: TownTier, b: TownTier) -> Bool { a.rawValue < b.rawValue }
}

struct TownRecord: Codable {
    var totalServes = 0
    var portraitAsset: String? = nil     // thumbnail for ledger-book UIs
    var perGame: [String: Int] = [:]
    var firstMet: Date? = nil
    var lastSeen: Date? = nil
}

@Observable
final class TownLedger {
    static let shared = TownLedger()
    private static let storeKey = "town_ledger_v1"

    private(set) var records: [String: TownRecord] = [:]

    private init() { load() }

    // ---- WRITE (call on every SUCCESSFUL serve of a character) ----
    /// `portrait` is the asset name for this character's picture, if the
    /// calling game knows it — it powers thumbnails in the ledger book.
    func recordServe(_ name: String, game: TownGame, portrait: String? = nil) {
        bump(name, game: game, portrait: portrait)
        if name.hasPrefix("Gremlock ") || name.hasPrefix("Gremlock#") {
            bump("Gremlocks", game: game, portrait: nil)   // the family album
        }
        save()
    }

    // ---- READ ----
    func tier(for name: String) -> TownTier {
        TownTier.from(serves: records[name]?.totalServes ?? 0)
    }
    func serves(for name: String) -> Int {
        records[name]?.totalServes ?? 0
    }
    func serves(for name: String, in game: TownGame) -> Int {
        records[name]?.perGame[game.rawValue] ?? 0
    }
    /// Every character ever met, most-served first (for ledger book UIs).
    var allKnown: [(name: String, record: TownRecord)] {
        records.sorted { $0.value.totalServes > $1.value.totalServes }
            .map { ($0.key, $0.value) }
    }

    // ---- internals ----
    private func bump(_ name: String, game: TownGame, portrait: String? = nil) {
        var r = records[name] ?? TownRecord()
        r.totalServes += 1
        if let portrait { r.portraitAsset = portrait }
        r.perGame[game.rawValue, default: 0] += 1
        if r.firstMet == nil { r.firstMet = Date() }
        r.lastSeen = Date()
        records[name] = r
    }
    private func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: Self.storeKey)
        }
    }
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storeKey),
              let decoded = try? JSONDecoder().decode([String: TownRecord].self, from: data)
        else { return }
        records = decoded
    }
}
