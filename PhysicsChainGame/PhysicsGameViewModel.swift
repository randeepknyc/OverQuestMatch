//
//  PhysicsGameViewModel.swift
//  OverQuestMatch3 - Physics Chain Game
//
//  Created on 3/28/26.
//  Updated: Added invisible "bubble" collision system for cleaner physics
//

import SwiftUI

/// Physics engine and game logic for chain matching game
@Observable
class PhysicsGameViewModel {
    var tiles: [PhysicsTile] = []
    var selectedTiles: [PhysicsTile] = []
    var score = 0
    var comboCount = 0
    
    private let boardWidth: CGFloat
    private let boardHeight: CGFloat
    private var lastComboTime = Date()
    
    init(boardWidth: CGFloat, boardHeight: CGFloat) {
        self.boardWidth = boardWidth
        self.boardHeight = boardHeight
        spawnInitialTiles()
    }
    
    // MARK: - Tile Spawning
    
    private func spawnInitialTiles() {
        tiles.removeAll()
        
        // Use collision radius for spawning to ensure tiles don't overlap their bubbles
        let collisionRadius = PhysicsGameConfig.collisionRadius
        
        for _ in 0..<PhysicsGameConfig.initialTileCount {
            let randomType = PhysicsGameConfig.randomTileType()
            let randomX = CGFloat.random(in: collisionRadius...(boardWidth - collisionRadius))
            let randomY = PhysicsGameConfig.randomSpawnHeight(boardHeight: boardHeight)
            
            let tile = PhysicsTile(type: randomType, position: CGPoint(x: randomX, y: randomY))
            tile.velocity = CGPoint(x: 0, y: PhysicsGameConfig.randomInitialFallSpeed())
            tiles.append(tile)
        }
        
        print("   ✅ Spawned \(tiles.count) tiles with collision bubbles")
    }
    
    private func spawnNewTile() {
        guard PhysicsGameConfig.respawnEnabled else { return }
        
        let collisionRadius = PhysicsGameConfig.collisionRadius
        let randomType = PhysicsGameConfig.randomTileType()
        let randomX = CGFloat.random(in: collisionRadius...(boardWidth - collisionRadius))
        let randomY = PhysicsGameConfig.randomSpawnHeight(boardHeight: boardHeight)
        
        let tile = PhysicsTile(type: randomType, position: CGPoint(x: randomX, y: randomY))
        tile.velocity = CGPoint(x: 0, y: PhysicsGameConfig.randomInitialFallSpeed())
        tiles.append(tile)
    }
    
    // MARK: - Physics Update (60 FPS)
    
    func updatePhysics() {
        // Apply gravity
        for tile in tiles where !tile.isMatched {
            tile.velocity.y += PhysicsGameConfig.gravity
        }
        
        // Apply velocity (move tiles)
        for tile in tiles where !tile.isMatched {
            tile.position.x += tile.velocity.x
            tile.position.y += tile.velocity.y
        }
        
        // Apply friction and air resistance
        for tile in tiles where !tile.isMatched {
            tile.velocity.x *= PhysicsGameConfig.friction * PhysicsGameConfig.airResistance
            tile.velocity.y *= PhysicsGameConfig.airResistance
        }
        
        // Limit maximum velocity
        for tile in tiles where !tile.isMatched {
            let speed = sqrt(tile.velocity.x * tile.velocity.x + tile.velocity.y * tile.velocity.y)
            if speed > PhysicsGameConfig.maxVelocity {
                tile.velocity.x *= PhysicsGameConfig.maxVelocity / speed
                tile.velocity.y *= PhysicsGameConfig.maxVelocity / speed
            }
        }
        
        // Stop very slow tiles
        for tile in tiles where !tile.isMatched {
            if abs(tile.velocity.x) < PhysicsGameConfig.restingThreshold {
                tile.velocity.x = 0
            }
            if abs(tile.velocity.y) < PhysicsGameConfig.restingThreshold {
                tile.velocity.y = 0
            }
        }
        
        // Wall collisions
        if PhysicsGameConfig.enableWallCollision {
            handleWallCollisions()
        }
        
        // Floor collision
        if PhysicsGameConfig.enableFloorCollision {
            handleFloorCollisions()
        }
        
        // Tile-to-tile collisions (with invisible bubbles!)
        if PhysicsGameConfig.enableTileCollision {
            handleTileCollisions()
        }
        
        // Remove matched tiles
        removeMatchedTiles()
        
        // Check combo decay
        if Date().timeIntervalSince(lastComboTime) > PhysicsGameConfig.comboDecayTime {
            comboCount = 0
        }
    }
    
    // MARK: - Collision Detection (Using Invisible Bubbles)
    
    private func handleWallCollisions() {
        // Use collision radius for wall detection (invisible bubble)
        let collisionRadius = PhysicsGameConfig.collisionRadius
        
        for tile in tiles where !tile.isMatched {
            // Left wall - collision bubble edge
            if tile.position.x - collisionRadius < 0 {
                tile.position.x = collisionRadius
                tile.velocity.x = abs(tile.velocity.x) * PhysicsGameConfig.bounce
            }
            
            // Right wall - collision bubble edge
            if tile.position.x + collisionRadius > boardWidth {
                tile.position.x = boardWidth - collisionRadius
                tile.velocity.x = -abs(tile.velocity.x) * PhysicsGameConfig.bounce
            }
        }
    }
    
    private func handleFloorCollisions() {
        // Use collision radius for floor detection (invisible bubble)
        let collisionRadius = PhysicsGameConfig.collisionRadius
        let floor = boardHeight
        
        for tile in tiles where !tile.isMatched {
            if tile.position.y + collisionRadius > floor {
                tile.position.y = floor - collisionRadius
                
                // Only bounce if moving fast enough
                if abs(tile.velocity.y) > PhysicsGameConfig.minimumBounceVelocity {
                    tile.velocity.y = -tile.velocity.y * PhysicsGameConfig.bounce
                } else {
                    tile.velocity.y = 0
                }
            }
        }
    }
    
    private func handleTileCollisions() {
        // Use collision bubble size for tile-to-tile detection
        let collisionDiameter = PhysicsGameConfig.collisionBubbleSize + PhysicsGameConfig.bubbleSpacing
        
        for i in 0..<tiles.count {
            for j in (i+1)..<tiles.count {
                let tile1 = tiles[i]
                let tile2 = tiles[j]
                
                guard !tile1.isMatched && !tile2.isMatched else { continue }
                
                let dx = tile2.position.x - tile1.position.x
                let dy = tile2.position.y - tile1.position.y
                let distance = sqrt(dx * dx + dy * dy)
                
                // Collision if bubbles overlap
                if distance < collisionDiameter {
                    // Collision detected between invisible bubbles
                    let overlap = collisionDiameter - distance
                    
                    // Separate tiles (push them apart)
                    let separationX = (dx / distance) * overlap * 0.5
                    let separationY = (dy / distance) * overlap * 0.5
                    
                    tile1.position.x -= separationX
                    tile1.position.y -= separationY
                    tile2.position.x += separationX
                    tile2.position.y += separationY
                    
                    // Calculate relative velocity for collision response
                    let relativeVelocity = sqrt(
                        (tile2.velocity.x - tile1.velocity.x) * (tile2.velocity.x - tile1.velocity.x) +
                        (tile2.velocity.y - tile1.velocity.y) * (tile2.velocity.y - tile1.velocity.y)
                    )
                    
                    // Use soft or hard collision damping based on impact speed
                    let damping = relativeVelocity < PhysicsGameConfig.softCollisionThreshold
                        ? PhysicsGameConfig.softCollisionDamping
                        : PhysicsGameConfig.hardCollisionDamping
                    
                    // Exchange velocities with damping (elastic collision)
                    let tempVx = tile1.velocity.x
                    let tempVy = tile1.velocity.y
                    
                    tile1.velocity.x = tile2.velocity.x * damping
                    tile1.velocity.y = tile2.velocity.y * damping
                    tile2.velocity.x = tempVx * damping
                    tile2.velocity.y = tempVy * damping
                }
            }
        }
    }
    
    // MARK: - Chain Matching
    
    func handleTouch(at location: CGPoint) {
        // Use visual tile size for touch detection (not the bubble)
        let tileSize = PhysicsGameConfig.tileSize
        
        // Find tile at touch location
        guard let touchedTile = tiles.first(where: { tile in
            let dx = tile.position.x - location.x
            let dy = tile.position.y - location.y
            let distance = sqrt(dx * dx + dy * dy)
            return distance < tileSize/2 && !tile.isMatched
        }) else { return }
        
        // If no tiles selected, start new chain
        if selectedTiles.isEmpty {
            touchedTile.isSelected = true
            selectedTiles.append(touchedTile)
            return
        }
        
        // Check if touching the same tile (ignore)
        if selectedTiles.last === touchedTile {
            return
        }
        
        // Check for backtracking (touching second-to-last tile)
        if PhysicsGameConfig.allowBacktracking && selectedTiles.count >= 2 {
            if selectedTiles[selectedTiles.count - 2] === touchedTile {
                // Remove last tile from chain
                let removed = selectedTiles.removeLast()
                removed.isSelected = false
                return
            }
        }
        
        // Check if already in chain
        if selectedTiles.contains(where: { $0 === touchedTile }) {
            return
        }
        
        // Check if same type as chain
        guard let firstTile = selectedTiles.first,
              touchedTile.type == firstTile.type else { return }
        
        // Check if adjacent to last selected tile
        guard let lastTile = selectedTiles.last else { return }
        let dx = touchedTile.position.x - lastTile.position.x
        let dy = touchedTile.position.y - lastTile.position.y
        let distance = sqrt(dx * dx + dy * dy)
        let maxDistance = tileSize * PhysicsGameConfig.chainConnectionDistance
        
        if distance <= maxDistance {
            touchedTile.isSelected = true
            selectedTiles.append(touchedTile)
        }
    }
    
    func endChain() async {
        // Check if chain is valid
        guard selectedTiles.count >= PhysicsGameConfig.minimumChainLength else {
            // Invalid chain - deselect all
            for tile in selectedTiles {
                tile.isSelected = false
            }
            selectedTiles.removeAll()
            return
        }
        
        // Valid chain - process match
        let tileCount = selectedTiles.count
        
        // Mark tiles as matched
        for tile in selectedTiles {
            tile.isMatched = true
        }
        
        // Award points
        let basePoints = tileCount * PhysicsGameConfig.pointsPerTile
        let comboPoints = comboCount * PhysicsGameConfig.comboBonus
        score += basePoints + comboPoints
        
        // Increment combo
        comboCount += 1
        lastComboTime = Date()
        
        // Wait for disappear animation
        try? await Task.sleep(for: .seconds(PhysicsGameConfig.matchDisappearDuration))
        
        // Spawn new tiles
        if PhysicsGameConfig.respawnEnabled {
            for _ in 0..<tileCount {
                try? await Task.sleep(for: .seconds(PhysicsGameConfig.respawnDelay))
                spawnNewTile()
            }
        }
        
        // Clear selection
        selectedTiles.removeAll()
    }
    
    private func removeMatchedTiles() {
        tiles.removeAll { $0.isMatched }
    }
}
