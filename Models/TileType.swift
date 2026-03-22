//
//  TileType.swift
//  OverQuestMatch3
//

import SwiftUI

enum TileType: String, CaseIterable {
    case sword
    case fire
    case shield
    case heart
    case mana
    case poison
    
    var color: Color {
        switch self {
        case .sword: return Color(red: 0.95, green: 0.45, blue: 0.45)
        case .fire: return Color(red: 0.98, green: 0.6, blue: 0.2)
        case .shield: return Color(red: 0.4, green: 0.85, blue: 0.75)
        case .heart: return Color(red: 0.98, green: 0.45, blue: 0.7)
        case .mana: return Color(red: 0.95, green: 0.85, blue: 0.3)
        case .poison: return Color(red: 0.7, green: 0.5, blue: 0.95)
        }
    }
    
    // ⚙️ USE CUSTOM IMAGES INSTEAD OF SF SYMBOLS
    var imageName: String {
        switch self {
        case .sword: return "sword_tile"
        case .fire: return "fire_tile"
        case .shield: return "shield_tile"
        case .heart: return "heart_tile"
        case .mana: return "mana_tile"
        case .poison: return "poison_tile"
        }
    }
    
    var battleAction: String {
        switch self {
        case .sword: return "attack"
        case .fire: return "magic"
        case .shield: return "defend"
        case .heart: return "heal"
        case .mana: return "charge"
        case .poison: return "poison"
        }
    }
}

struct Tile: Identifiable, Equatable {
    let id = UUID()
    let type: TileType
    var row: Int
    var col: Int
    var isSpecial: Bool = false
    var spawnDelay: Double = 0
    var fallDelay: Double = 0
    
    // ☕ Bonus tile tracking
    var isBonusTile: Bool = false
    
    // 🎮 SESSION 14: Bejeweled-style continuous matching
    // Tracks if gem is currently stable (can be swapped)
    // false = gem is falling/spawning (can't be swapped)
    // true = gem is stable and ready to match
    var isStable: Bool = true
    
    static func random(row: Int, col: Int) -> Tile {
        Tile(
            type: TileType.allCases.randomElement()!,
            row: row,
            col: col
        )
    }
    
    // ☕ Create bonus tile
    static func bonusTile(row: Int, col: Int) -> Tile {
        var tile = Tile(
            type: .mana,  // Type doesn't matter, will show coffee image
            row: row,
            col: col
        )
        tile.isBonusTile = true
        tile.isStable = true  // Bonus tiles start stable
        return tile
    }
    
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        lhs.id == rhs.id
    }
}
