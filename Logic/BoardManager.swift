//
//  BoardManager.swift
//  OverQuestMatch3
//

import Foundation

@Observable
class BoardManager {
    var tiles: [[Tile?]]
    let size: Int
    
    init(size: Int = GameConfig.boardSize) {
        self.size = size
        self.tiles = []
        generateInitialBoard()
    }
    
    func generateInitialBoard() {
        var newBoard: [[Tile?]] = []
        
        // Generate full board
        for _ in 0..<size {
            var row: [Tile?] = []
            for _ in 0..<size {
                row.append(Tile.random())
            }
            newBoard.append(row)
        }
        
        tiles = newBoard
        
        // Clear any accidental starting matches
        clearAllMatches()
        
        // Ensure board is full
        _ = fillEmptySpaces()
    }
    
    func canSwap(from: GridPosition, to: GridPosition) -> Bool {
        guard isAdjacent(from, to) else { return false }
        guard isValid(from) && isValid(to) else { return false }
        guard tiles[from.row][from.col] != nil && tiles[to.row][to.col] != nil else { return false }
        return true
    }
    
    func swap(from: GridPosition, to: GridPosition) {
        let temp = tiles[from.row][from.col]
        tiles[from.row][from.col] = tiles[to.row][to.col]
        tiles[to.row][to.col] = temp
    }
    
    func findMatches() -> [Match] {
        var matches: [Match] = []
        
        // Horizontal matches - ONLY match tiles of the SAME TYPE
        for row in 0..<size {
            var col = 0
            while col < size {
                guard let tile = tiles[row][col] else {
                    col += 1
                    continue
                }
                
                var matchLength = 1
                var matchPositions = [GridPosition(row: row, col: col)]
                
                // Check consecutive tiles to the right with EXACT same type
                while col + matchLength < size,
                      let nextTile = tiles[row][col + matchLength] {
                    // CRITICAL: Must be exact same type
                    if nextTile.type == tile.type {
                        matchPositions.append(GridPosition(row: row, col: col + matchLength))
                        matchLength += 1
                    } else {
                        break
                    }
                }
                
                if matchLength >= 3 {
                    matches.append(Match(type: tile.type, positions: matchPositions))
                }
                
                col += matchLength
            }
        }
        
        // Vertical matches - ONLY match tiles of the SAME TYPE
        for col in 0..<size {
            var row = 0
            while row < size {
                guard let tile = tiles[row][col] else {
                    row += 1
                    continue
                }
                
                var matchLength = 1
                var matchPositions = [GridPosition(row: row, col: col)]
                
                // Check consecutive tiles downward with EXACT same type
                while row + matchLength < size,
                      let nextTile = tiles[row + matchLength][col] {
                    // CRITICAL: Must be exact same type
                    if nextTile.type == tile.type {
                        matchPositions.append(GridPosition(row: row + matchLength, col: col))
                        matchLength += 1
                    } else {
                        break
                    }
                }
                
                if matchLength >= 3 {
                    matches.append(Match(type: tile.type, positions: matchPositions))
                }
                
                row += matchLength
            }
        }
        
        return matches
    }
    
    func clearMatches(_ matches: [Match]) {
        for match in matches {
            for pos in match.positions {
                tiles[pos.row][pos.col] = nil
            }
        }
    }
    
    func clearAllMatches() {
        var iterations = 0
        let maxIterations = 50
        
        while iterations < maxIterations {
            let matches = findMatches()
            if matches.isEmpty { break }
            clearMatches(matches)
            _ = applyGravity()
            _ = fillEmptySpaces()
            iterations += 1
        }
    }
    
    // CALCULATE MAX FALL DISTANCE: Used for timing
    func calculateMaxFallDistance() -> Int {
        var maxDistance = 0
        
        for col in 0..<size {
            var emptyCount = 0
            for row in (0..<size).reversed() {
                if tiles[row][col] == nil {
                    emptyCount += 1
                } else if emptyCount > 0 {
                    maxDistance = max(maxDistance, emptyCount)
                }
            }
        }
        
        return maxDistance
    }
    
    // GRAVITY: Process column by column, return if anything moved
    func applyGravity() -> Bool {
        var anyMoved = false
        
        for col in 0..<size {
            // Collect all non-nil tiles in this column
            var columnTiles: [Tile] = []
            for row in 0..<size {
                if let tile = tiles[row][col] {
                    columnTiles.append(tile)
                }
            }
            
            // Clear the column
            for row in 0..<size {
                tiles[row][col] = nil
            }
            
            // Place tiles at the bottom, working upward
            let startRow = size - columnTiles.count
            for (index, tile) in columnTiles.enumerated() {
                let newRow = startRow + index
                tiles[newRow][col] = tile
                
                // Check if this tile moved
                let originalRow = index + (size - columnTiles.count)
                if newRow != originalRow || startRow > 0 {
                    anyMoved = true
                }
            }
        }
        
        return anyMoved
    }
    
    // FILL EMPTY SPACES: Returns spawn info for animation timing
    func fillEmptySpaces() -> (newTileCount: Int, maxSpawnDistance: Int) {
        var newTileCount = 0
        var maxSpawnDistance = 0
        
        for col in 0..<size {
            var spawnedInColumn = 0
            for row in 0..<size {
                if tiles[row][col] == nil {
                    tiles[row][col] = Tile.random()
                    newTileCount += 1
                    spawnedInColumn += 1
                    
                    // Track how far this tile needs to "fall" from spawn
                    maxSpawnDistance = max(maxSpawnDistance, row + 1)
                }
            }
        }
        
        return (newTileCount, maxSpawnDistance)
    }
    
    // CLEAR ALL GEMS OF A SPECIFIC TYPE: For ability system
    func clearAllGemsOfType(_ type: TileType) -> [GridPosition] {
        var clearedPositions: [GridPosition] = []
        
        for row in 0..<size {
            for col in 0..<size {
                if let tile = tiles[row][col], tile.type == type {
                    tiles[row][col] = nil
                    clearedPositions.append(GridPosition(row: row, col: col))
                }
            }
        }
        
        return clearedPositions
    }
    
    private func isAdjacent(_ pos1: GridPosition, _ pos2: GridPosition) -> Bool {
        let rowDiff = abs(pos1.row - pos2.row)
        let colDiff = abs(pos1.col - pos2.col)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    private func isValid(_ pos: GridPosition) -> Bool {
        pos.row >= 0 && pos.row < size && pos.col >= 0 && pos.col < size
    }
}

struct GridPosition: Equatable, Hashable {
    let row: Int
    let col: Int
}

struct Match {
    let type: TileType
    let positions: [GridPosition]
    
    var count: Int { positions.count }
    var isSpecial: Bool { count >= GameConfig.specialTileThreshold }
}
