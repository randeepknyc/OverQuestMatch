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
    static func generateDeck(for type: ComponentType) -> [ComponentCard] {
        var deck: [ComponentCard] = []
        
        // 10 normal cards (values 1-4, distributed)
        // Distribution: 3x value-1, 3x value-2, 2x value-3, 2x value-4
        let normalCardValues = [1, 1, 1, 2, 2, 2, 3, 3, 4, 4]
        
        for value in normalCardValues {
            let card = ComponentCard(
                type: type,
                value: value,
                isCursed: false,
                adjacencyBonus: randomAdjacentType(excluding: type),
                name: randomCardName(for: type, value: value, isCursed: false)
            )
            deck.append(card)
        }
        
        // 3 cursed cards (negative values -1 to -3)
        let cursedCardValues = [-1, -2, -3]
        
        for value in cursedCardValues {
            let card = ComponentCard(
                type: type,
                value: value,
                isCursed: true,
                adjacencyBonus: nil, // Cursed cards don't give adjacency bonuses
                name: randomCardName(for: type, value: value, isCursed: true)
            )
            deck.append(card)
        }
        
        return deck.shuffled()
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
