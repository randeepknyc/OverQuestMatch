//
//  BoardManager.swift
//  OverQuestMatch3
//

import Foundation

@Observable
class BoardManager {
    var gems: [Tile] = []  // ✨ FLAT ARRAY: Each gem knows its own position
    let size: Int
    
    init(size: Int = GameConfig.boardSize) {
        self.size = size
        generateInitialBoard()
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // HELPER: Get gem at position
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func gem(at position: GridPosition) -> Tile? {
        gems.first { $0.row == position.row && $0.col == position.col }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // HELPER: Find gem index
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func gemIndex(at position: GridPosition) -> Int? {
        gems.firstIndex { $0.row == position.row && $0.col == position.col }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // INITIAL BOARD GENERATION
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func generateInitialBoard() {
        gems.removeAll()
        
        // Create gems with bottom-to-top raindrop cascade
        for row in (0..<size).reversed() {  // Bottom to top
            let rowIndex = size - 1 - row
            let baseDelay = Double(rowIndex) * 0.1  // Each row starts 0.1s after previous
            
            for col in 0..<size {
                var newGem = Tile.random(row: row, col: col)
                let randomOffset = Double.random(in: 0...0.1)
                newGem.spawnDelay = baseDelay + randomOffset
                gems.append(newGem)
            }
        }
        
        // Clear any starting matches
        clearAllMatches()
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // SWAP VALIDATION
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func canSwap(from: GridPosition, to: GridPosition) -> Bool {
        guard isAdjacent(from, to) else { return false }
        guard isValid(from) && isValid(to) else { return false }
        guard gem(at: from) != nil && gem(at: to) != nil else { return false }
        return true
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // SWAP GEMS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func swap(from: GridPosition, to: GridPosition) {
        guard let fromIndex = gemIndex(at: from),
              let toIndex = gemIndex(at: to) else { return }
        
        // Swap their row/col coordinates
        let tempRow = gems[fromIndex].row
        let tempCol = gems[fromIndex].col
        
        gems[fromIndex].row = gems[toIndex].row
        gems[fromIndex].col = gems[toIndex].col
        gems[toIndex].row = tempRow
        gems[toIndex].col = tempCol
        
        // Clear spawn/fall delays (these are swaps, not new spawns)
        gems[fromIndex].spawnDelay = 0
        gems[fromIndex].fallDelay = 0
        gems[toIndex].spawnDelay = 0
        gems[toIndex].fallDelay = 0
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // FIND MATCHES
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func findMatches() -> [Match] {
        var matches: [Match] = []
        
        // Horizontal matches
        for row in 0..<size {
            var col = 0
            while col < size {
                guard let gemToCheck = gem(at: GridPosition(row: row, col: col)) else {
                    col += 1
                    continue
                }
                
                var matchLength = 1
                var matchPositions = [GridPosition(row: row, col: col)]
                
                // Check consecutive tiles to the right
                while col + matchLength < size,
                      let nextGem = gem(at: GridPosition(row: row, col: col + matchLength)),
                      nextGem.type == gemToCheck.type {
                    matchPositions.append(GridPosition(row: row, col: col + matchLength))
                    matchLength += 1
                }
                
                if matchLength >= 3 {
                    matches.append(Match(type: gemToCheck.type, positions: matchPositions))
                }
                
                col += matchLength
            }
        }
        
        // Vertical matches
        for col in 0..<size {
            var row = 0
            while row < size {
                guard let gemToCheck = gem(at: GridPosition(row: row, col: col)) else {
                    row += 1
                    continue
                }
                
                var matchLength = 1
                var matchPositions = [GridPosition(row: row, col: col)]
                
                // Check consecutive tiles downward
                while row + matchLength < size,
                      let nextGem = gem(at: GridPosition(row: row + matchLength, col: col)),
                      nextGem.type == gemToCheck.type {
                    matchPositions.append(GridPosition(row: row + matchLength, col: col))
                    matchLength += 1
                }
                
                if matchLength >= 3 {
                    matches.append(Match(type: gemToCheck.type, positions: matchPositions))
                }
                
                row += matchLength
            }
        }
        
        return matches
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // CLEAR MATCHES
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func clearMatches(_ matches: [Match]) {
        let positionsToRemove = Set(matches.flatMap { $0.positions })
        
        // Remove gems at matched positions
        gems.removeAll { gemToRemove in
            positionsToRemove.contains(GridPosition(row: gemToRemove.row, col: gemToRemove.col))
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // APPLY GRAVITY (COLUMN BY COLUMN)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func applyGravity() -> Bool {
        var anyMoved = false
        
        // Process each column independently
        for col in 0..<size {
            // Get all gems in this column, sorted bottom to top
            let columnGems = gems.filter { $0.col == col }.sorted { $0.row > $1.row }
            
            // Compact them downward (starting from bottom)
            var writeRow = size - 1
            for i in 0..<columnGems.count {
                if let gemIndex = gems.firstIndex(where: { $0.id == columnGems[i].id }) {
                    let oldRow = gems[gemIndex].row
                    
                    if oldRow != writeRow {
                        // Gem needs to fall
                        gems[gemIndex].row = writeRow
                        
                        // Add staggered delay (lower gems land first)
                        gems[gemIndex].fallDelay = Double(i) * 0.04
                        
                        anyMoved = true
                    }
                    
                    writeRow -= 1
                }
            }
        }
        
        return anyMoved
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // FILL EMPTY SPACES (GAMEPLAY REFILL)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func fillEmptySpacesWithFastCascade() -> (newTileCount: Int, maxSpawnDistance: Int) {
        var newTileCount = 0
        var maxSpawnDistance = 0
        
        // Find which positions are empty
        for col in 0..<size {
            var emptyRows: [Int] = []
            for row in 0..<size {
                if gem(at: GridPosition(row: row, col: col)) == nil {
                    emptyRows.append(row)
                }
            }
            
            // Spawn new gems at the top of each column
            let columnBaseDelay = Double(col) * 0.03
            
            for (_, row) in emptyRows.enumerated() {
                var newGem = Tile.random(row: row, col: col)
                
                // Stagger spawn delays
                let randomOffset = Double.random(in: 0...0.02)
                newGem.spawnDelay = columnBaseDelay + randomOffset
                newGem.fallDelay = 0
                
                gems.append(newGem)
                newTileCount += 1
                maxSpawnDistance = max(maxSpawnDistance, row + 1)
            }
        }
        
        return (newTileCount, maxSpawnDistance)
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // CLEAR ALL STARTING MATCHES
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func clearAllMatches() {
        var iterations = 0
        let maxIterations = 50
        
        while iterations < maxIterations {
            let matches = findMatches()
            if matches.isEmpty { break }
            clearMatches(matches)
            _ = applyGravity()
            
            // Fill gaps while preserving cascade animation timing
            for col in 0..<size {
                for row in 0..<size {
                    if gem(at: GridPosition(row: row, col: col)) == nil {
                        // ✨ Calculate same cascade delay as initial generation
                        let rowIndex = size - 1 - row
                        let baseDelay = Double(rowIndex) * 0.1
                        let randomOffset = Double.random(in: 0...0.1)
                        
                        var newGem = Tile.random(row: row, col: col)
                        newGem.spawnDelay = baseDelay + randomOffset  // ✅ Preserve cascade timing!
                        gems.append(newGem)
                    }
                }
            }
            
            iterations += 1
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // CLEAR ALL GEMS OF TYPE (FOR ABILITY)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func clearAllGemsOfType(_ type: TileType) -> [GridPosition] {
        let gemsToRemove = gems.filter { $0.type == type }
        let positions = gemsToRemove.map { GridPosition(row: $0.row, col: $0.col) }
        
        gems.removeAll { $0.type == type }
        
        return positions
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // HELPERS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private func isAdjacent(_ pos1: GridPosition, _ pos2: GridPosition) -> Bool {
        let rowDiff = abs(pos1.row - pos2.row)
        let colDiff = abs(pos1.col - pos2.col)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    private func isValid(_ pos: GridPosition) -> Bool {
        pos.row >= 0 && pos.row < size && pos.col >= 0 && pos.col < size
    }
}
