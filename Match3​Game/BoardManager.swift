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
    
    // 🧪 NEW: Setup poison pill after board is generated
    func setupPoisonPill(poisonManager: PoisonPillManager) {
        poisonManager.setupPoisonPill(boardSize: size)
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // SWAP VALIDATION
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func canSwap(from: GridPosition, to: GridPosition) -> Bool {
        guard isAdjacent(from, to) else { return false }
        guard isValid(from) && isValid(to) else { return false }
        guard let gem1 = gem(at: from), let gem2 = gem(at: to) else { return false }
        
        // ☕ BONUS TILE: ALWAYS allow swaps involving bonus tiles
        if gem1.isBonusTile || gem2.isBonusTile {
            return true
        }
        
        // 🎮 SESSION 14: Bejeweled-style - can only swap stable gems
        guard gem1.isStable && gem2.isStable else { return false }
        
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
                
                // ☕ BONUS TILE: Skip bonus tiles - they don't start matches
                if gemToCheck.isBonusTile {
                    col += 1
                    continue
                }
                
                var matchLength = 1
                var matchPositions = [GridPosition(row: row, col: col)]
                
                // Check consecutive tiles to the right
                while col + matchLength < size,
                      let nextGem = gem(at: GridPosition(row: row, col: col + matchLength)),
                      !nextGem.isBonusTile,  // ☕ BONUS TILE: Stop chain if we hit a bonus
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
                
                // ☕ BONUS TILE: Skip bonus tiles - they don't start matches
                if gemToCheck.isBonusTile {
                    row += 1
                    continue
                }
                
                var matchLength = 1
                var matchPositions = [GridPosition(row: row, col: col)]
                
                // Check consecutive tiles downward
                while row + matchLength < size,
                      let nextGem = gem(at: GridPosition(row: row + matchLength, col: col)),
                      !nextGem.isBonusTile,  // ☕ BONUS TILE: Stop chain if we hit a bonus
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
    func clearMatches(_ matches: [Match]) -> [GridPosition] {
        let positionsToRemove = Set(matches.flatMap { $0.positions })
        
        // Remove gems at matched positions, BUT PROTECT BONUS TILES
        gems.removeAll { gemToRemove in
            let position = GridPosition(row: gemToRemove.row, col: gemToRemove.col)
            // ☕ NEVER remove bonus tiles during auto-matching
            return positionsToRemove.contains(position) && !gemToRemove.isBonusTile
        }
        
        // ☕ Return positions for bonus tile spawning
        return Array(positionsToRemove)
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ☕ BONUS TILE: Check if any match should spawn bonus tile
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func shouldSpawnBonusTile(for matches: [Match]) -> GridPosition? {
        guard BonusTileConfig.enabled else { return nil }
        
        // Check for L-shapes (connected matches sharing a corner)
        if let lShapePosition = detectLShapeMatch(matches: matches) {
            return lShapePosition
        }
        
        // Check for single straight line of 5+
        for match in matches {
            if match.count >= BonusTileConfig.minimumMatchSize {
                return calculateBonusSpawnPosition(for: match)
            }
        }
        
        return nil
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ☕ BONUS TILE: Detect L-shape patterns (two matches sharing a corner)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private func detectLShapeMatch(matches: [Match]) -> GridPosition? {
        // Look for pairs of matches that share a corner tile
        for i in 0..<matches.count {
            for j in (i+1)..<matches.count {
                let match1 = matches[i]
                let match2 = matches[j]
                
                // Must be same type
                guard match1.type == match2.type else { continue }
                
                // Find shared positions (corner tile)
                let positions1 = Set(match1.positions)
                let positions2 = Set(match2.positions)
                let sharedPositions = positions1.intersection(positions2)
                
                // Must share exactly 1 tile (the corner)
                guard sharedPositions.count == 1 else { continue }
                
                // Calculate total unique tiles
                let allPositions = positions1.union(positions2)
                
                // Check if total is 5 or more
                if allPositions.count >= BonusTileConfig.minimumMatchSize {
                    // Found an L-shape! Return the corner position
                    return sharedPositions.first!
                }
            }
        }
        
        return nil
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ☕ BONUS TILE: Calculate where to spawn based on match shape
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private func calculateBonusSpawnPosition(for match: Match) -> GridPosition {
        let positions = match.positions
        
        // Check if it's a straight horizontal line
        let rows = Set(positions.map { $0.row })
        let cols = Set(positions.map { $0.col })
        
        if rows.count == 1 {
            // Horizontal line - spawn at center column
            let sortedCols = cols.sorted()
            let centerIndex = sortedCols.count / 2
            return GridPosition(row: rows.first!, col: sortedCols[centerIndex])
        } else if cols.count == 1 {
            // Vertical line - spawn at center row
            let sortedRows = rows.sorted()
            let centerIndex = sortedRows.count / 2
            return GridPosition(row: sortedRows[centerIndex], col: cols.first!)
        } else {
            // L-shape or complex shape - spawn at corner (min row, min col)
            let minRow = rows.min()!
            let minCol = cols.min()!
            return GridPosition(row: minRow, col: minCol)
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ☕ BONUS TILE: Spawn bonus tile at position
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func spawnBonusTile(at position: GridPosition) {
        // Check if we allow multiple bonus tiles
        if !BonusTileConfig.allowMultiple {
            // Remove any existing bonus tiles
            gems.removeAll { $0.isBonusTile }
        }
        
        // Create bonus tile
        let bonusTile = Tile.bonusTile(row: position.row, col: position.col)
        gems.append(bonusTile)
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ☕ BONUS TILE: Check if a swap involves a bonus tile
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func isBonusTileSwap(from: GridPosition, to: GridPosition) -> Bool {
        let gem1 = gem(at: from)
        let gem2 = gem(at: to)
        return gem1?.isBonusTile == true || gem2?.isBonusTile == true
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ☕ BONUS TILE: Clear row/column based on swipe direction
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Returns: Dictionary of gem types and their counts [TileType: Int]
    func clearWithBonusTile(at position: GridPosition, clearRow: Bool) -> [TileType: Int] {
        var clearedPositions: [GridPosition] = []
        var gemTypeCounts: [TileType: Int] = [:]
        
        if clearRow {
            // Clear horizontal row (left/right swipe)
            for col in 0..<size {
                let pos = GridPosition(row: position.row, col: col)
                if let gemAtPos = gem(at: pos) {
                    clearedPositions.append(pos)
                    // Count gem types (exclude bonus tiles from counting, but still clear them)
                    if !gemAtPos.isBonusTile {
                        gemTypeCounts[gemAtPos.type, default: 0] += 1
                    }
                }
            }
        } else {
            // Clear vertical column (up/down swipe)
            for row in 0..<size {
                let pos = GridPosition(row: row, col: position.col)
                if let gemAtPos = gem(at: pos) {
                    clearedPositions.append(pos)
                    // Count gem types (exclude bonus tiles from counting, but still clear them)
                    if !gemAtPos.isBonusTile {
                        gemTypeCounts[gemAtPos.type, default: 0] += 1
                    }
                }
            }
        }
        
        // Remove ALL gems at cleared positions (including bonus tiles!)
        gems.removeAll { gemToRemove in
            clearedPositions.contains(GridPosition(row: gemToRemove.row, col: gemToRemove.col))
        }
        
        return gemTypeCounts
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
                        
                        // 🎮 SESSION 14: Mark as unstable while falling
                        gems[gemIndex].isStable = false
                        
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
                
                // 🎮 SESSION 14: Mark new gems as unstable until they finish spawning
                newGem.isStable = false
                
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
    // SESSION 14: Mark all gems as stable (after animations complete)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    func markAllGemsStable() {
        for i in 0..<gems.count {
            gems[i].isStable = true
        }
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
