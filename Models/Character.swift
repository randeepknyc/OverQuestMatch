//
//  Character.swift
//  OverQuestMatch3
//

import Foundation

@Observable
class Character {
    var name: String
    var imageName: String
    var maxHealth: Int
    var currentHealth: Int
    var shield: Int = 0
    
    // ═══════════════════════════════════════════════════════════════
    // 🎨 CHARACTER STATE SYSTEM
    // ═══════════════════════════════════════════════════════════════
    var currentState: CharacterState = .idle
    // ═══════════════════════════════════════════════════════════════
    
    var healthPercentage: Double {
        return Double(currentHealth) / Double(maxHealth)
    }
    
    var isAlive: Bool {
        return currentHealth > 0
    }
    
    init(name: String, imageName: String, maxHealth: Int, currentHealth: Int) {
        self.name = name
        self.imageName = imageName
        self.maxHealth = maxHealth
        self.currentHealth = currentHealth
    }
    
    func takeDamage(_ amount: Int) {
        let damageAfterShield = max(0, amount - shield)
        shield = max(0, shield - amount)
        currentHealth = max(0, currentHealth - damageAfterShield)
    }
    
    func heal(_ amount: Int) {
        currentHealth = min(maxHealth, currentHealth + amount)
    }
    
    func addShield(_ amount: Int) {
        shield += amount
    }
}

// ═══════════════════════════════════════════════════════════════
// 🎨 CHARACTER STATE ENUM
// ═══════════════════════════════════════════════════════════════
enum CharacterState {
    case idle       // Normal standing
    case attack     // Attacking
    case hurt       // Taking damage
    case defend     // Blocking/shielding
    case spell      // Casting ability
    case victory    // Won the battle
    case defeat     // Lost the battle
    
    // Helper to get the image name based on character and state
    func imageName(for characterName: String) -> String {
        // Ramp has full dynamic portraits
        if characterName == "Ramp" {
            switch self {
            case .idle:
                return "ramp_idle"
            case .attack:
                return "ramp_attack"
            case .hurt:
                return "ramp_hurt"
            case .defend:
                return "ramp_defend"
            case .spell:
                return "ramp_spell"
            case .victory:
                return "ramp_victory"
            case .defeat:
                return "ramp_defeat"
            }
        }
        
        // Ednar uses same image for all states (for now)
        // Later you can add: ednar_attack, ednar_hurt, etc.
        else if characterName == "Ednar" || characterName == "Toad King" {
            return "ednar_idle"  // Uses ednar_idle for ALL states
        }
        
        // Fallback for any other character
        else {
            return GameAssets.toadImage
        }
    }
}
