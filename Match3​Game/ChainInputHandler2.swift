//
//  ChainInputHandler.swift
//  OverQuestMatch3
//

import SwiftUI

@Observable
class ChainInputHandler {
    var activeChain: [GridPosition] = []
    var chainTileType: TileType?
    
    var chainLength: Int { activeChain.count }
    var isChainValid: Bool { chainLength >= 3 }
    
    func startChain(at position: GridPosition) {
        activeChain = [position]
    }
    
    func extendChain(to position: GridPosition) -> Bool {
        // Don't add if already in chain
        if activeChain.contains(position) {
            // If going back to previous tile, remove last tile
            if activeChain.count >= 2 && activeChain[activeChain.count - 2] == position {
                activeChain.removeLast()
                return true
            }
            return false
        }
        
        // Must be adjacent to last tile in chain
        guard let lastPos = activeChain.last else { return false }
        guard isAdjacent(lastPos, position) else { return false }
        
        activeChain.append(position)
        return true
    }
    
    func endChain() -> (chain: [GridPosition], isValid: Bool, type: TileType?) {
        let result = (chain: activeChain, isValid: isChainValid, type: chainTileType)
        activeChain = []
        chainTileType = nil
        return result
    }
    
    func isInChain(_ position: GridPosition) -> Bool {
        activeChain.contains(position)
    }
    
    func gridPosition(from location: CGPoint, tileSize: CGFloat, boardSize: Int) -> GridPosition? {
        let col = Int(location.x / tileSize)
        let row = Int((location.y + tileSize / 2) / tileSize)
        
        guard row >= 0 && row < boardSize && col >= 0 && col < boardSize else {
            return nil
        }
        
        return GridPosition(row: row, col: col)
    }
    
    private func isAdjacent(_ pos1: GridPosition, _ pos2: GridPosition) -> Bool {
        let rowDiff = abs(pos1.row - pos2.row)
        let colDiff = abs(pos1.col - pos2.col)
        
        // Allow horizontal, vertical, AND diagonal (8 directions)
        return rowDiff <= 1 && colDiff <= 1 && !(rowDiff == 0 && colDiff == 0)
    }
}
