//
//  BattleEvent.swift
//  OverQuestMatch3
//

import Foundation

struct BattleEvent: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let type: EventType
    let timestamp = Date()
    
    enum EventType {
        case playerAttack
        case playerMagic
        case playerDefend
        case playerHeal
        case playerCharge
        case enemyAttack
        case combo
        case special
    }
    
    var icon: String {
        switch type {
        case .playerAttack: return "⚔️"
        case .playerMagic: return "🔥"
        case .playerDefend: return "🛡️"
        case .playerHeal: return "💚"
        case .playerCharge: return "⚡"
        case .enemyAttack: return "💥"
        case .combo: return "✨"
        case .special: return "💫"
        }
    }
}
