//
//  Character.swift
//  OverQuestMatch3
//

import Foundation

struct Character: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    var maxHealth: Int
    var currentHealth: Int
    var shield: Int = 0
    
    var isAlive: Bool { currentHealth > 0 }
    var healthPercentage: Double {
        Double(currentHealth) / Double(maxHealth)
    }
    
    mutating func takeDamage(_ amount: Int) {
        let actualDamage = max(0, amount - shield)
        currentHealth = max(0, currentHealth - actualDamage)
        shield = max(0, shield - amount)
    }
    
    mutating func heal(_ amount: Int) {
        currentHealth = min(maxHealth, currentHealth + amount)
    }
    
    mutating func addShield(_ amount: Int) {
        shield += amount
    }
}
