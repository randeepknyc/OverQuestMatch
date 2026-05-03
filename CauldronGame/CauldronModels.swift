// CauldronModels.swift
// Ednar's Cauldron - Data Models
// Place in: CauldronGame/ folder

import SwiftUI

// MARK: - Game State
enum CauldronGameState {
    case title, playing, brewing, result, gameover, win
}

// MARK: - Dice Types
enum DiceType: String, CaseIterable, Identifiable {
    case potency, stability, boost, restoration, mirror, terrain

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .potency:     return Color(red: 0.91, green: 0.30, blue: 0.24)
        case .stability:   return Color(red: 0.20, green: 0.60, blue: 0.86)
        case .boost:       return Color(red: 0.61, green: 0.35, blue: 0.71)
        case .restoration: return Color(red: 0.18, green: 0.80, blue: 0.44)
        case .mirror:      return Color(red: 0.58, green: 0.65, blue: 0.65)
        case .terrain:     return Color(red: 0.91, green: 0.26, blue: 0.58)
        }
    }

    var bgColor: Color {
        switch self {
        case .potency:     return Color(red: 0.23, green: 0.06, blue: 0.06)
        case .stability:   return Color(red: 0.05, green: 0.12, blue: 0.18)
        case .boost:       return Color(red: 0.12, green: 0.05, blue: 0.18)
        case .restoration: return Color(red: 0.05, green: 0.18, blue: 0.10)
        case .mirror:      return Color(red: 0.10, green: 0.10, blue: 0.10)
        case .terrain:     return Color(red: 0.18, green: 0.05, blue: 0.12)
        }
    }

    var abbr: String {
        switch self {
        case .potency: return "POT"
        case .stability: return "STB"
        case .boost: return "BST"
        case .restoration: return "RST"
        case .mirror: return "MIR"
        case .terrain: return "TER"
        }
    }

    var label: String { rawValue.capitalized }
}

// MARK: - Die Tier
enum DieTier: String {
    case basic, silver, gold

    var borderColor: Color {
        switch self {
        case .basic:  return Color(red: 0.33, green: 0.27, blue: 0.20)
        case .silver: return Color.gray
        case .gold:   return Color.yellow
        }
    }

    var icon: String {
        switch self {
        case .basic: return ""
        case .silver: return "☆"
        case .gold: return "★"
        }
    }

    func rollFace() -> Int {
        let faces: [Int]
        switch self {
        case .basic:  faces = [1, 1, 2, 2, 2, 2]
        case .silver: faces = [2, 3, 3, 4, 4, 4]
        case .gold:   faces = [4, 4, 5, 5, 6, 6]
        }
        return faces.randomElement()!
    }
}

// MARK: - Cauldron Die
struct CauldronDie: Identifiable, Equatable {
    let id: String
    let type: DiceType
    let tier: DieTier
    var value: Int

    static func == (lhs: CauldronDie, rhs: CauldronDie) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Bag Die (no value until drawn)
struct BagDie {
    let id: String
    let type: DiceType
    let tier: DieTier
}

// MARK: - Patron Trait
struct PatronTrait {
    let name: String
    let desc: String
    let icon: String
}

// MARK: - Patron
struct Patron: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    var patience: Int
    let maxPatience: Int
    let expiryDamage: Int
    let trait: PatronTrait
    let target: Int
    let targetType: DiceType
    let stipulation: String
}

// MARK: - Brew Result
struct BrewResult {
    let total: Int
    let target: Int
    let tier: String
    let tierLabel: String
    let payment: Int
    let standingChange: Int
    let blowback: Int
    let boostMultiplier: Double
}

// MARK: - Board Topology
struct CauldronBoard {
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

    static func neighbors(of index: Int) -> [Int] {
        var result = Set<Int>()
        for (a, b) in edges {
            if a == index { result.insert(b) }
            if b == index { result.insert(a) }
        }
        return Array(result)
    }
}

// MARK: - Patron Data
struct PatronData {
    static let names = [
        "Barnaby the Farmer", "Elara the Merchant", "Lord Ashworth",
        "Greta the Witch", "Zael the Demon", "Royal Envoy Prim"
    ]
    static let types = ["Farmer", "Merchant", "Noble", "Witch", "Demon", "Royal Envoy"]
    static let patience = [4, 3, 2, 3, 2, 1]
    static let expiryDamage = [2, 4, 6, 5, 8, 10]

    static let traits: [PatronTrait] = [
        PatronTrait(name: "Haggler",      desc: "Other patrons pay 20% less", icon: "💰"),
        PatronTrait(name: "Intimidating", desc: "Brew targets +2",            icon: "😠"),
        PatronTrait(name: "Draining",     desc: "-1 Standing per brew",       icon: "💀"),
        PatronTrait(name: "Inspiring",    desc: "All dice +1 value",          icon: "✨"),
        PatronTrait(name: "Disruptive",   desc: "1 random slot blocked",      icon: "🚫"),
        PatronTrait(name: "Greedy",       desc: "-5 gold per brew",           icon: "🪙"),
    ]

    static let stipulations = [
        "No restrictions", "No boost dice", "Max 2 placements",
        "No mirror dice", "Only basic tier"
    ]
}

// MARK: - Theme Colors
struct CauldronTheme {
    static let bg = Color(red: 0.04, green: 0.02, blue: 0.07)
    static let cardBg = Color(red: 0.10, green: 0.08, blue: 0.13)
    static let border = Color(red: 0.23, green: 0.16, blue: 0.29)
    static let text = Color(red: 0.91, green: 0.84, blue: 0.71)
    static let muted = Color(red: 0.33, green: 0.27, blue: 0.44)
    static let purple = Color(red: 0.79, green: 0.63, blue: 0.86)
    static let gold = Color.yellow
}
