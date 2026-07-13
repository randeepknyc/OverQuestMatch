//
//  Ability.swift
//  OverQuestMatch3
//

import SwiftUI

enum Ability: String, CaseIterable {
    case heroicStrike
    case divineShield
    case greaterHeal
    
    var name: String {
        switch self {
        case .heroicStrike: return "Heroic Strike"
        case .divineShield: return "Divine Shield"
        case .greaterHeal: return "Greater Heal"
        }
    }
    
    var icon: String {
        switch self {
        case .heroicStrike: return "⚔️"
        case .divineShield: return "🛡️"
        case .greaterHeal: return "💚"
        }
    }
    
    var manaCost: Int {
        switch self {
        case .heroicStrike: return 5
        case .divineShield: return 4
        case .greaterHeal: return 3
        }
    }
    
    var description: String {
        switch self {
        case .heroicStrike: return "Deal 40 damage, bypass shields"
        case .divineShield: return "Gain 25 shield"
        case .greaterHeal: return "Restore 40 HP"
        }
    }
    
    var color: Color {
        switch self {
        case .heroicStrike: return .red
        case .divineShield: return .cyan
        case .greaterHeal: return .green
        }
    }
}
