//
//  RepairSlot.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Slot in the repair area where cards are placed
//

import Foundation

/// One of the four slots in the repair area
struct RepairSlot: Identifiable, Codable {
    let id: UUID
    let index: Int // 0-3 position
    var card: ComponentCard? // nil until filled
    
    /// Initialize a repair slot
    init(id: UUID = UUID(), index: Int, card: ComponentCard? = nil) {
        self.id = id
        self.index = index
        self.card = card
    }
    
    /// Whether this slot is empty
    var isEmpty: Bool {
        card == nil
    }
    
    /// Whether this slot is filled
    var isFilled: Bool {
        card != nil
    }
}

// MARK: - Repair Slot Array Helpers

extension Array where Element == RepairSlot {
    
    /// Get the first empty slot
    var firstEmptySlot: RepairSlot? {
        first(where: { $0.isEmpty })
    }
    
    /// Check if all slots are filled
    var allFilled: Bool {
        allSatisfy { $0.isFilled }
    }
    
    /// Count of filled slots
    var filledCount: Int {
        filter { $0.isFilled }.count
    }
    
    /// Get all cards (non-nil)
    var cards: [ComponentCard] {
        compactMap { $0.card }
    }
}
