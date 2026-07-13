//
//  RepairResult.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Calculates repair outcome and generates repair names
//

import Foundation

/// Result of a completed repair (all 4 slots filled)
struct RepairResult: Identifiable, Codable {
    let id: UUID
    let slots: [RepairSlot]
    let customer: Customer
    
    init(id: UUID = UUID(), slots: [RepairSlot], customer: Customer) {
        self.id = id
        self.slots = slots
        self.customer = customer
    }
    
    // MARK: - Computed Properties
    
    /// All cards used in this repair
    var cards: [ComponentCard] {
        slots.cards
    }
    
    /// Total score including all bonuses
    var totalScore: Int {
        var score = 0
        
        // Add base card values
        for card in cards {
            score += card.value
        }
        
        // Add adjacency bonuses (+2 per adjacency match)
        for (index, slot) in slots.enumerated() {
            guard let card = slot.card else { continue }
            guard let bonusType = card.adjacencyBonus else { continue }
            
            // Check left neighbor
            if index > 0, let leftCard = slots[index - 1].card, leftCard.type == bonusType {
                score += 2
            }
            
            // Check right neighbor
            if index < slots.count - 1, let rightCard = slots[index + 1].card, rightCard.type == bonusType {
                score += 2
            }
        }
        
        // Add preferred type bonus (+3 per preferred card)
        let preferredCards = cards.filter { $0.type == customer.preferredType }
        score += preferredCards.count * 3
        
        return score
    }
    
    /// Check if repair includes at least one required type card
    var meetsRequirement: Bool {
        cards.contains(where: { $0.type == customer.requiredType })
    }
    
    /// Check if repair was successful
    var isSuccessful: Bool {
        meetsRequirement && totalScore > 0
    }
    
    /// Count how many adjacency bonuses were triggered
    var adjacencyBonusCount: Int {
        var count = 0
        
        for (index, slot) in slots.enumerated() {
            guard let card = slot.card else { continue }
            guard let bonusType = card.adjacencyBonus else { continue }
            
            // Check left neighbor
            if index > 0, let leftCard = slots[index - 1].card, leftCard.type == bonusType {
                count += 1
            }
            
            // Check right neighbor
            if index < slots.count - 1, let rightCard = slots[index + 1].card, rightCard.type == bonusType {
                count += 1
            }
        }
        
        return count
    }
    
    /// Generated name for this repair combination
    var repairName: String {
        generateRepairName()
    }
    
    // MARK: - Repair Name Generation
    
    private func generateRepairName() -> String {
        let typeCounts = countTypes()
        let cursedCount = cards.filter { $0.isCursed }.count
        let allBonusesHit = checkAllAdjacencyBonusesHit()
        
        // Special cases first
        
        // All wildcraft
        if typeCounts[.wildcraft] == 4 {
            return "Ednar's Gambit"
        }
        
        // All memory
        if typeCounts[.memory] == 4 {
            return "Memory Palace"
        }
        
        // All same type (pure)
        if let singleType = typeCounts.first(where: { $0.value == 4 })?.key {
            let prefix = getQualityPrefix(cursedCount: cursedCount, allBonusesHit: allBonusesHit)
            return "\(prefix)Pure \(singleType.displayName) Restoration"
        }
        
        // All four different types
        if typeCounts.count == 4 {
            let prefix = getQualityPrefix(cursedCount: cursedCount, allBonusesHit: allBonusesHit)
            return "\(prefix)Rainbow Repair"
        }
        
        // Three of one type + one other
        if let majorType = typeCounts.first(where: { $0.value == 3 })?.key {
            let prefix = getQualityPrefix(cursedCount: cursedCount, allBonusesHit: allBonusesHit)
            return "\(prefix)Triple \(majorType.displayName) Fix"
        }
        
        // Two pairs (2+2)
        if typeCounts.values.filter({ $0 == 2 }).count == 2 {
            let prefix = getQualityPrefix(cursedCount: cursedCount, allBonusesHit: allBonusesHit)
            return "\(prefix)Duplex Mend"
        }
        
        // Two of one + two different (2+1+1)
        if let majorType = typeCounts.first(where: { $0.value == 2 })?.key {
            let prefix = getQualityPrefix(cursedCount: cursedCount, allBonusesHit: allBonusesHit)
            return "\(prefix)Twin \(majorType.displayName) Patch"
        }
        
        // Default fallback
        let prefix = getQualityPrefix(cursedCount: cursedCount, allBonusesHit: allBonusesHit)
        return "\(prefix)Standard Repair"
    }
    
    /// Count how many cards of each type
    private func countTypes() -> [ComponentType: Int] {
        var counts: [ComponentType: Int] = [:]
        for card in cards {
            counts[card.type, default: 0] += 1
        }
        return counts
    }
    
    /// Check if all adjacency bonuses were activated
    private func checkAllAdjacencyBonusesHit() -> Bool {
        for (index, slot) in slots.enumerated() {
            guard let card = slot.card else { continue }
            guard let bonusType = card.adjacencyBonus else { continue }
            
            // Check if this card has a neighbor of the bonus type
            var hasBonus = false
            
            // Left neighbor
            if index > 0, let leftCard = slots[index - 1].card, leftCard.type == bonusType {
                hasBonus = true
            }
            
            // Right neighbor
            if index < slots.count - 1, let rightCard = slots[index + 1].card, rightCard.type == bonusType {
                hasBonus = true
            }
            
            // If this card has an adjacency bonus requirement but it wasn't met, return false
            if !hasBonus {
                return false
            }
        }
        
        return true
    }
    
    /// Get quality prefix based on cursed cards and bonuses
    private func getQualityPrefix(cursedCount: Int, allBonusesHit: Bool) -> String {
        // Risky prefix if 2+ cursed cards
        if cursedCount >= 2 {
            return "Risky "
        }
        
        // Masterwork prefix if 0 cursed cards AND all bonuses hit
        if cursedCount == 0 && allBonusesHit {
            return "Masterwork "
        }
        
        return "" // No prefix
    }
}
