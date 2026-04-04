//
//  PhysicsTileType.swift
//  OverQuestMatch3 - Physics Chain Game
//
//  Created on 3/28/26.
//

import SwiftUI

/// Tile types for Physics Chain Game (reuses Match-3 images)
enum PhysicsTileType: String, CaseIterable {
    case sword
    case fire
    case shield
    case heart
    case mana
    case poison
    
    /// Image name in Assets.xcassets (reuses Match-3 images!)
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
    
    /// Display color for this tile type
    var color: Color {
        switch self {
        case .sword: return .gray
        case .fire: return .orange
        case .shield: return .cyan
        case .heart: return .red
        case .mana: return .blue
        case .poison: return .purple
        }
    }
    
    /// Glow color when selected
    var glowColor: Color {
        switch self {
        case .sword: return .white
        case .fire: return .yellow
        case .shield: return .cyan
        case .heart: return .pink
        case .mana: return .blue
        case .poison: return .purple
        }
    }
}
