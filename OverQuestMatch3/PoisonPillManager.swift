//
//  PoisonPillManager.swift
//  OverQuestMatch3
//

import Foundation
import SwiftUI

@Observable
class PoisonPillManager {
    var poisonPillPosition: GridPosition?
    var isPoisoned: Bool = false
    var poisonTurnCounter: Int = 0
    var revealedPoisonEffect: PoisonRevealEffect?
    
    // NEW: Show poison tile on board after reveal
    var showPoisonTileOnBoard: Bool = false
    var revealedTilePosition: GridPosition?
    
    func setupPoisonPill(boardSize: Int) {
        let randomRow = Int.random(in: 0..<boardSize)
        let randomCol = Int.random(in: 0..<boardSize)
        poisonPillPosition = GridPosition(row: randomRow, col: randomCol)
        isPoisoned = false
        poisonTurnCounter = 0
        revealedPoisonEffect = nil
        showPoisonTileOnBoard = false
        revealedTilePosition = nil
        print("🧪 POISON PILL: Hidden at row \(randomRow), col \(randomCol)")
    }
    
    // NEW: Check if swipe position is on poison pill
    func checkForPoisonSwipe(position: GridPosition) -> Bool {
        guard let pillPos = poisonPillPosition else {
            return false
        }
        
        if position == pillPos {
            revealPoison(at: pillPos)
            return true
        }
        
        return false
    }
    
    func checkForPoisonReveal(matchedPositions: [GridPosition]) -> Bool {
        guard let pillPos = poisonPillPosition else {
            return false
        }
        
        if matchedPositions.contains(pillPos) {
            revealPoison(at: pillPos)
            return true
        }
        
        return false
    }
    
    private func revealPoison(at position: GridPosition) {
        print("💀 POISON PILL REVEALED at \(position)!")
        
        revealedPoisonEffect = PoisonRevealEffect(position: position, id: UUID())
        isPoisoned = true
        poisonTurnCounter = 1
        poisonPillPosition = nil
        
        // Show tile on board
        showPoisonTileOnBoard = true
        revealedTilePosition = position
    }
    
    func hidePoisonTile() {
        showPoisonTileOnBoard = false
        revealedTilePosition = nil
    }
    
    func getPoisonDamageForTurn() -> Int {
        guard isPoisoned else { return 0 }
        switch poisonTurnCounter {
        case 1: return 3
        case 2: return 4
        case 3: return 5
        default: return 0
        }
    }
    
    func advancePoisonTurn() {
        guard isPoisoned else { return }
        poisonTurnCounter += 1
        if poisonTurnCounter > 3 {
            isPoisoned = false
            poisonTurnCounter = 0
            print("✅ Poison effect has worn off!")
        }
    }
    
    func reset() {
        poisonPillPosition = nil
        isPoisoned = false
        poisonTurnCounter = 0
        revealedPoisonEffect = nil
        showPoisonTileOnBoard = false
        revealedTilePosition = nil
    }
}

struct PoisonRevealEffect: Identifiable {
    let position: GridPosition
    let id: UUID
}
