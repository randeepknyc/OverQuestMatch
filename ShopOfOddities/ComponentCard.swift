//
//  ComponentCard.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Individual component card data model
//

import Foundation

/// A single component card used in repairs
struct ComponentCard: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ComponentType
    let value: Int // 1-4 for normal cards, negative for cursed cards
    let isCursed: Bool
    let adjacencyBonus: ComponentType? // If placed next to this type, get +2 bonus
    let name: String
    
    /// Initialize a new component card
    init(
        id: UUID = UUID(),
        type: ComponentType,
        value: Int,
        isCursed: Bool = false,
        adjacencyBonus: ComponentType? = nil,
        name: String
    ) {
        self.id = id
        self.type = type
        self.value = value
        self.isCursed = isCursed
        self.adjacencyBonus = adjacencyBonus
        self.name = name
    }
    
    /// Display value with proper sign
    var displayValue: String {
        if value >= 0 {
            return "+\(value)"
        } else {
            return "\(value)"
        }
    }
    
    /// Visual indicator for cursed cards
    var cursedSymbol: String {
        isCursed ? "☠️" : ""
    }
}

// MARK: - Card Generation

extension ComponentCard {
    
    /// Generate a full deck (13 cards) for a component type
    ///
    /// Cursed cards are spread out deliberately (not fully random) so that a
    /// single pile can never hand you two cursed cards back-to-back, and the
    /// very first card or two you draw from a fresh pile is guaranteed safe.
    /// This softens unlucky streaks without removing randomness entirely —
    /// the exact spacing between cursed cards still varies game to game.
    static func generateDeck(for type: ComponentType) -> [ComponentCard] {
        // 10 normal cards (values 1-4, distributed)
        // Distribution: 3x value-1, 3x value-2, 2x value-3, 2x value-4
        let normalCardValues = [1, 1, 1, 2, 2, 2, 3, 3, 4, 4]
        
        var normalCards: [ComponentCard] = normalCardValues.map { value in
            ComponentCard(
                type: type,
                value: value,
                isCursed: false,
                adjacencyBonus: randomAdjacentType(excluding: type),
                name: randomCardName(for: type, value: value, isCursed: false)
            )
        }
        normalCards.shuffle()
        
        // 3 cursed cards (negative values -1 to -3)
        let cursedCardValues = [-1, -2, -3]
        
        var cursedCards: [ComponentCard] = cursedCardValues.map { value in
            ComponentCard(
                type: type,
                value: value,
                isCursed: true,
                adjacencyBonus: nil, // Cursed cards don't give adjacency bonuses
                name: randomCardName(for: type, value: value, isCursed: true)
            )
        }
        cursedCards.shuffle()
        
        // Split the 10 normal cards into 3 random-sized groups (min 2 each)
        // and slot one cursed card after each group. This guarantees:
        //  - At least 2 safe draws before the first cursed card appears
        //  - At least 2 normal cards between any two cursed cards
        let minGroupSize = 2
        let groupCount = 3
        var groupSizes = Array(repeating: minGroupSize, count: groupCount)
        var remaining = normalCards.count - (minGroupSize * groupCount) // extra cards to distribute
        while remaining > 0 {
            groupSizes[Int.random(in: 0..<groupCount)] += 1
            remaining -= 1
        }
        
        var deck: [ComponentCard] = []
        var cursedIndex = 0
        
        for size in groupSizes {
            let group = normalCards.prefix(size)
            deck.append(contentsOf: group)
            normalCards.removeFirst(size)
            
            if cursedIndex < cursedCards.count {
                deck.append(cursedCards[cursedIndex])
                cursedIndex += 1
            }
        }
        
        return deck
    }
    
    /// Randomly assign an adjacency bonus type (30% chance)
    private static func randomAdjacentType(excluding: ComponentType) -> ComponentType? {
        // 30% chance to have an adjacency bonus
        guard Int.random(in: 1...10) <= 3 else { return nil }
        
        let otherTypes = ComponentType.allCases.filter { $0 != excluding }
        return otherTypes.randomElement()
    }
    
    /// Generate flavor name for a card
    private static func randomCardName(for type: ComponentType, value: Int, isCursed: Bool) -> String {
        if isCursed {
            return cursedCardNames[type]?.randomElement() ?? "Cursed Component"
        } else {
            return normalCardNames[type]?.randomElement() ?? "Component"
        }
    }
    
    // MARK: - Card Name Pools
    
    /// Normal card names by type
    private static let normalCardNames: [ComponentType: [String]] = [
        .structural: [
            "Oak Plank", "Iron Nail", "Stone Block", "Copper Wire",
            "Silk Thread", "Leather Strip", "Glass Shard", "Bronze Rivet",
            "Steel Rod", "Marble Tile", "Cedar Beam", "Brass Hinge"
        ],
        .enchantment: [
            "Whispered Rune", "Arcane Dust", "Spell Fragment", "Magic Spark",
            "Ethereal Thread", "Mystic Crystal", "Enchanted Glyph", "Power Shard",
            "Woven Light", "Starfire Ember", "Moonstone Flake", "Spell Echo"
        ],
        .memory: [
            "Whispered Echo", "Faded Impression", "Lingering Touch", "Dream Residue",
            "Nostalgic Scent", "Laughter Fragment", "Warm Feeling", "Lost Moment",
            "Gentle Whisper", "Cherished Memory", "Soft Shadow", "Forgotten Name"
        ],
        .wildcraft: [
            "Gremlock Spit", "Tavern Grease", "Lucky Rock", "Mystery Goo",
            "Ednar's Special", "Weird String", "Probably Safe Paste", "Found Item",
            "Pocket Lint", "Suspicious Dust", "Random Bit", "Improvised Solution"
        ]
    ]
    
    /// Cursed card names by type
    private static let cursedCardNames: [ComponentType: [String]] = [
        .structural: [
            "Cracked Stone", "Rotted Wood", "Rusted Iron", "Fractured Glass"
        ],
        .enchantment: [
            "Cracked Runestone", "Corrupted Spell", "Cursed Shard", "Dark Magic"
        ],
        .memory: [
            "Painful Memory", "Bitter Regret", "Haunting Echo", "Dark Thought"
        ],
        .wildcraft: [
            "Gremlock Curse", "Bad Luck Charm", "Probably Poison", "Cursed Junk"
        ]
    ]
}
