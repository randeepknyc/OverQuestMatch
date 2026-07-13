//
//  ComponentType.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Component deck types for card-based repair gameplay
//

import SwiftUI

/// Four types of component cards, each with unique visual identity
enum ComponentType: String, CaseIterable, Codable {
    case structural
    case enchantment
    case memory
    case wildcraft
    
    /// Human-readable name for UI display
    var displayName: String {
        switch self {
        case .structural:
            return "Structural"
        case .enchantment:
            return "Enchantment"
        case .memory:
            return "Memory"
        case .wildcraft:
            return "Wildcraft"
        }
    }
    
    /// Color theme for this component type
    var color: Color {
        switch self {
        case .structural:
            return Color(red: 0.6, green: 0.4, blue: 0.2) // Brown/amber
        case .enchantment:
            return Color(red: 0.4, green: 0.3, blue: 0.8) // Blue/purple
        case .memory:
            return Color(red: 0.9, green: 0.7, blue: 0.2) // Gold/warm yellow
        case .wildcraft:
            return Color(red: 0.3, green: 0.7, blue: 0.3) // Green
        }
    }
    
    /// Custom icon image name (uses your custom assets!)
    var iconName: String {
        switch self {
        case .structural:
            return "structural-icon"
        case .enchantment:
            return "enchantment-icon"
        case .memory:
            return "memory-icon"
        case .wildcraft:
            return "wildcraft-icon"
        }
    }
    
    /// Card background image name (uses your custom card art!)
    var cardImageName: String {
        switch self {
        case .structural:
            return "card-structural"
        case .enchantment:
            return "card-enchantment"
        case .memory:
            return "card-memory"
        case .wildcraft:
            return "card-wildcraft"
        }
    }
    
    /// Lighter tint for card backgrounds
    var lightColor: Color {
        color.opacity(0.3)
    }
    
    /// Darker color for borders and accents
    var darkColor: Color {
        switch self {
        case .structural:
            return Color(red: 0.4, green: 0.25, blue: 0.1)
        case .enchantment:
            return Color(red: 0.2, green: 0.15, blue: 0.5)
        case .memory:
            return Color(red: 0.7, green: 0.5, blue: 0.1)
        case .wildcraft:
            return Color(red: 0.15, green: 0.4, blue: 0.15)
        }
    }
}
