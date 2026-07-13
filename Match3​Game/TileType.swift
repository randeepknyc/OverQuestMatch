//
//  TileType.swift
//  OverQuestMatch3
//
//  🆕 MULTI-ENEMY UPDATE: the .fire slot is now the SIGNATURE GEM.
//  Its image and color come from EnemyRoster.current, so the same
//  board slot looks like fire vs Ednar, ice vs Ironhilde, etc.
//  If an enemy's tile art isn't drawn yet, it shows fire_tile.
//

import SwiftUI

enum TileType: String, CaseIterable {
    case sword
    case fire       // ← the signature gem slot (fire is just Ednar's version!)
    case shield
    case heart
    case mana
    case poison
    
    var color: Color {
        switch self {
        case .sword: return Color(red: 0.95, green: 0.45, blue: 0.45)
        case .fire: return EnemyRoster.current.signature.color  // 🆕 per-enemy color
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
        case .fire: return EnemyRoster.current.signature.resolvedTileImage  // 🆕 per-enemy image
        case .shield: return "shield_tile"
        case .heart: return "heart_tile"
        case .mana: return "mana_tile"
        case .poison: return "poison_tile"
        }
    }
    
    var battleAction: String {
        switch self {
        case .sword: return "attack"
        case .fire: return EnemyRoster.current.signature.elementName.lowercased()  // 🆕 e.g. "ice"
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
