//
//  PotionShopModels.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Data Models
//  Place in: PotionShop/ folder
//

import SwiftUI
import UIKit

// MARK: - Image Loading Helper

/// Helper to load images from Asset Catalog with emoji fallback
struct PotionShopImageLoader {
    
    /// Attempts to load an image from the asset catalog.
    /// Returns the image if found, nil otherwise.
    static func loadImage(named name: String) -> UIImage? {
        return UIImage(named: name)
    }
    
    /// Creates a view showing either the asset image or emoji fallback
    @ViewBuilder
    static func imageOrEmoji(assetName: String, fallbackEmoji: String, size: CGFloat) -> some View {
        if let uiImage = loadImage(named: assetName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Text(fallbackEmoji)
                .font(.system(size: size * 0.55))
        }
    }
}

// MARK: - Game state phases
//
// These are the broad states the game can be in. Set by the state
// machine (PotionShopGameState, added in Phase 3) and read by the
// view to decide what to show.

enum PotionShopPhase {
    case playing       // normal gameplay
    case roundWon      // round complete overlay shown
    case dayWon        // day complete overlay shown
    case lost          // composure hit 0 — game over
}

// MARK: - Theme colors
//
// Warm parchment palette for the new game. Different from the
// existing CauldronGame's dark/purple theme. These are placeholders
// — final colors will come from the user's art.

struct PotionShopTheme {
    // Warm parchment background
    static let bg = Color(red: 0.98, green: 0.96, blue: 0.93)
    // Dark wood for text and outlines
    static let ink = Color(red: 0.23, green: 0.14, blue: 0.06)
    // Muted brown for secondary text
    static let muted = Color(red: 0.50, green: 0.42, blue: 0.30)
    // Warm tan accent for buttons and highlights
    static let accent = Color(red: 0.73, green: 0.46, blue: 0.09)
    // Composure bar colors
    static let composureGood = Color(red: 0.59, green: 0.77, blue: 0.35)
    static let composureWarn = Color(red: 0.94, green: 0.71, blue: 0.26)
    static let composureBad  = Color(red: 0.89, green: 0.29, blue: 0.29)
    // Shield teal
    static let shield = Color(red: 0.36, green: 0.79, blue: 0.65)
}

// MARK: - Trait
//
// A behavior modifier attached to a customer. Eight traits exist
// (Phase 2 defines them in PotionShopData). Traits are looked up by
// id (e.g. "intimidating"). The `effects` struct says what the
// trait does mechanically.

struct PotionShopTrait: Identifiable {
    let id: String          // e.g. "intimidating"
    let name: String        // displayed in inspect strip, e.g. "Intimidating"
    let description: String // one-liner shown to player
    let effects: PotionShopTraitEffects
}

struct PotionShopTraitEffects {
    // All optional. Missing = no effect of that kind.
    var brewTargetModifier: Int? = nil
    var activePatienceDrainModifier: Int? = nil
    var waitingPatienceDrainModifier: Int? = nil
    var focusModifier: Int? = nil
    var composureDrainPerTurn: Int? = nil
    var diceValueModifierGlobal: Int? = nil
    var overbrewTriggersPredefense: Bool? = nil
    var hexDiePerTurn: Bool? = nil
}

// MARK: - Time of day
//
// Each round happens at one of these times. Customers have a list
// of times they can show up at.

enum PotionShopTimeOfDay: String, CaseIterable {
    case morning, afternoon, evening, night
}

// MARK: - Character
//
// A reusable definition of a customer. Phase 2 defines 14 of these
// in PotionShopData. When a round starts, the game spawns a Customer
// (defined in Phase 3) from a Character template.
//
// Combat fields:
//   activeAttack       : damage they deal when at front of line (queue[0])
//   waitingAttack      : damage they deal while waiting in line
//   activePatienceTick : how fast their patience drops while at front
//   waitingPatienceTick: how fast their patience drops while waiting
//   expireDamage       : one-time damage on patience expiration

struct PotionShopCharacter: Identifiable {
    let id: String          // e.g. "mildred"
    let name: String        // e.g. "Mildred Honeycomb"
    let title: String       // e.g. "Anxious Farmwife"
    let portrait: String    // asset name for the portrait PNG (used when art arrives)
    let iconFallback: String // emoji used as placeholder until portrait is in
    let difficulty: Int     // 1 (tutorial) - 5 (boss)
    let timeOfDay: [PotionShopTimeOfDay]
    let orderName: String   // e.g. "A Soothing Tonic"
    let orderDialogue: String
    let hp: Int             // brew target
    let patience: Int       // turns before they storm out
    let activeAttack: Int
    let waitingAttack: Int
    let activePatienceTick: Int
    let waitingPatienceTick: Int
    let expireDamage: Int
    let tickDialogue: String
    let expireDialogue: String
    let defeatDialogue: String
    let trait: String?      // trait id, or nil for no trait
}

// MARK: - Round and Day definitions
//
// A Day has 4 rounds. For now (v1, Day 1 only), every round is
// CURATED — you list the customer ids that show up. Phases 11+ will
// add random rounds for Day 2+ but that's later.

struct PotionShopRound {
    let timeOfDay: PotionShopTimeOfDay
    let customerIds: [String]   // in order they appear in queue (queue[0] = first up)
}

struct PotionShopDay {
    let id: String           // e.g. "day_1"
    let name: String         // e.g. "Day 1"
    let subtitle: String     // e.g. "Opening for Business"
    let morning: PotionShopRound
    let afternoon: PotionShopRound
    let evening: PotionShopRound
    let night: PotionShopRound

    /// Returns rounds in order: morning, afternoon, evening, night.
    var allRounds: [PotionShopRound] {
        [morning, afternoon, evening, night]
    }
}

// MARK: - Game config (tunable values)
//
// One-stop shop for numbers we'll want to tweak during balancing.
// Adjust these to retune the game.

struct PotionShopConfig {
    static let startingComposure = 30
    static let maxComposure = 30
    /// +N composure between rounds within a day. Set to 0 once the
    /// game's harder for full-day endurance.
    static let composureRestBetweenRounds = 5
    /// +N composure between days (basically, full refill).
    static let composureRestBetweenDays = 30
    static let roundsPerDay = 4
    /// Hand has 5 dice; you can place at most this many before brewing.
    static let maxPlacementsPerBrew = 3
}

// MARK: - Dice
//
// Five dice types. The face value (1-6) is rolled each turn. Boost
// dice multiply neighbors; the rest contribute directly.

enum PotionShopDieType: String, CaseIterable, Identifiable {
    case potency
    case stability
    case boost
    case heal
    case shield

    var id: String { rawValue }

    /// Display abbreviation shown on the die face.
    var abbr: String {
        switch self {
        case .potency:   return "POT"
        case .stability: return "STB"
        case .boost:     return "BST"
        case .heal:      return "HEAL"
        case .shield:    return "SHD"
        }
    }

    /// Full label used in tooltips/inspect.
    var label: String { rawValue.capitalized }
    
    /// Asset name for die face art (flat-faced 512×512 PNG with center 30% blank)
    var assetName: String {
        switch self {
        case .potency:   return "die_potency"
        case .stability: return "die_stability"
        case .boost:     return "die_boost"
        case .heal:      return "die_heal"
        case .shield:    return "die_shield"
        }
    }

    /// Placeholder color (used if die art asset not found)
    var color: Color {
        switch self {
        case .potency:   return Color(red: 0.91, green: 0.30, blue: 0.24) // red
        case .stability: return Color(red: 0.20, green: 0.60, blue: 0.86) // blue
        case .boost:     return Color(red: 0.61, green: 0.35, blue: 0.71) // purple
        case .heal:      return Color(red: 0.18, green: 0.80, blue: 0.44) // green
        case .shield:    return Color(red: 0.11, green: 0.62, blue: 0.46) // teal
        }
    }
}

/// Tier system kept dormant for v1. Every die is created at .basic.
/// Silver/gold tiers will activate when multi-day progression is built.
enum PotionShopDieTier: String {
    case basic, silver, gold

    func rollFace() -> Int {
        let faces: [Int]
        switch self {
        case .basic:  faces = [1, 2, 2, 3, 3, 4]
        case .silver: faces = [2, 3, 3, 4, 4, 5]
        case .gold:   faces = [3, 4, 4, 5, 5, 6]
        }
        return faces.randomElement()!
    }
}

/// A live die in the player's hand or placed on the cauldron.
struct PotionShopDie: Identifiable, Equatable {
    let id: String
    let type: PotionShopDieType
    let tier: PotionShopDieTier
    var value: Int

    static func == (lhs: PotionShopDie, rhs: PotionShopDie) -> Bool {
        lhs.id == rhs.id
    }
}

/// A die in the bag (no face value rolled yet).
struct PotionShopBagDie {
    let id: String
    let type: PotionShopDieType
    let tier: PotionShopDieTier
}

// MARK: - Cauldron board topology
//
// 12 nodes laid out in a custom positioning the user dialed in
// previously. Edges connect nearby nodes — used to compute "reach"
// for brewing math (a die affects nodes within `value` hops).
//
// (These positions match the existing CauldronBoard from the old
// CauldronGame so the user's debug positioning work is preserved.)

struct PotionShopBoard {
    struct Node {
        let x: Double
        let y: Double
    }

    static let nodes: [Node] = [
        Node(x: 36.0, y: 7.4),    // 0
        Node(x: 70.9, y: 7.2),    // 1
        Node(x: 6.1, y: 34.4),    // 2
        Node(x: 56.5, y: 51.7),   // 3
        Node(x: 100.3, y: 35.0),  // 4
        Node(x: 5.4, y: 82.3),    // 5
        Node(x: 56.1, y: 103.4),  // 6
        Node(x: 104.3, y: 83.9),  // 7
        Node(x: 2.5, y: 128.1),   // 8
        Node(x: 39.2, y: 139.0),  // 9
        Node(x: 79.3, y: 139.3),  // 10
        Node(x: 109.7, y: 126.8), // 11
    ]

    static let edges: [(Int, Int)] = [
        (0,2),(0,3),(1,4),(1,5),
        (2,3),(3,4),(4,5),
        (2,6),(3,6),(3,7),(4,7),(4,8),(5,8),
        (6,7),(7,8),
        (6,9),(6,10),(7,10),(8,10),(8,11),
        (9,10),(10,11),
    ]

    /// Returns immediate neighbors (1 hop away).
    static func neighbors(of index: Int) -> [Int] {
        var result = Set<Int>()
        for (a, b) in edges {
            if a == index { result.insert(b) }
            if b == index { result.insert(a) }
        }
        return Array(result)
    }

    /// Returns all nodes within `hops` of `index` via BFS, excluding
    /// `index` itself. Used to compute a die's "reach".
    static func neighborsWithin(_ index: Int, hops: Int) -> [Int] {
        var visited = Set<Int>([index])
        var frontier: [Int] = [index]
        for _ in 0..<hops {
            var next: [Int] = []
            for n in frontier {
                for nb in neighbors(of: n) {
                    if !visited.contains(nb) {
                        visited.insert(nb)
                        next.append(nb)
                    }
                }
            }
            frontier = next
        }
        visited.remove(index)
        return Array(visited)
    }
}
