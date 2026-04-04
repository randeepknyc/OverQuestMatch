//
//  PhysicsGameConfig.swift
//  OverQuestMatch3 - Physics Chain Game
//
//  Created on 3/28/26.
//  Updated: Added directional labels for all settings
//

import CoreGraphics
import SwiftUI

/// Complete configuration for Physics Chain Game
/// All settings include directional comments (↑ increase / ↓ decrease)
struct PhysicsGameConfig {
    
    // MARK: - Tile Spawning
    static let initialTileCount = 90          // ↑ = more tiles on screen | ↓ = fewer tiles
    static let tileSize: CGFloat = 50         // ↑ = bigger visual tiles | ↓ = smaller visual tiles
    static let collisionBubbleSize: CGFloat = 58  // ↑ = more spacing between tiles | ↓ = tiles closer together
    static let respawnEnabled = true          // true = new tiles spawn after matches | false = no respawn
    static let respawnDelay: Double = 0.2     // ↑ = slower spawn rate | ↓ = faster spawn rate
    
    // MARK: - Physics Settings
    static let gravity: CGFloat = 0.35        // ↑ = tiles fall faster | ↓ = tiles fall slower/floaty
    static let bounce: CGFloat = 0.25         // ↑ = more bouncy | ↓ = less bouncy (more realistic)
    static let friction: CGFloat = 0.98       // ↑ = tiles slow down faster | ↓ = tiles slide more
    static let airResistance: CGFloat = 0.99  // ↑ = tiles slow in air faster | ↓ = less air drag
    static let maxVelocity: CGFloat = 10.0    // ↑ = tiles can move faster | ↓ = slower max speed
    static let restingThreshold: CGFloat = 0.25 // ↑ = tiles stop moving sooner | ↓ = tiles wiggle longer
    
    // MARK: - Collision Settings
    static let enableTileCollision = true     // true = tiles bounce off each other | false = tiles pass through
    static let enableWallCollision = true     // true = bounce off walls | false = pass through walls
    static let enableFloorCollision = true    // true = bounce off floor | false = fall forever
    static let softCollisionThreshold: CGFloat = 3.0  // ↑ = more "soft" collisions | ↓ = more "hard" collisions ⭐️
    static let hardCollisionDamping: CGFloat = 0.85   // ↑ = less energy lost in hard hits | ↓ = more energy lost ⭐️
    static let softCollisionDamping: CGFloat = 0.92   // ↑ = less energy lost in soft hits | ↓ = more energy lost ⭐️
    static let minimumBounceVelocity: CGFloat = 0.4   // ↑ = bigger bounces required | ↓ = allows tiny bounces
    static let bubbleSpacing: CGFloat = 5.0   // ↑ = MORE space between tiles | ↓ = LESS space between tiles ⭐️
    
    // MARK: - Spawn Settings
    static let spawnMargin: CGFloat = 10      // ↑ = spawn further from edges | ↓ = can spawn closer to edges
    static let initialFallSpeed: CGFloat = 1.8     // ↑ = tiles spawn falling faster | ↓ = spawn falling slower
    static let randomSpawnVelocityX: CGFloat = 0.8 // ↑ = more sideways movement | ↓ = less sideways movement
    
    // MARK: - Chain Matching
    static let minimumChainLength = 3         // ↑ = harder (need longer chains) | ↓ = easier (shorter chains OK)
    static let chainConnectionDistance: CGFloat = 1.5 // ↑ = easier to connect tiles | ↓ = must be closer to connect
    static let allowBacktracking = true       // true = can undo chain | false = can't undo chain
    
    // MARK: - Scoring
    static let pointsPerTile = 10             // ↑ = higher scores | ↓ = lower scores
    static let comboBonus = 5                 // ↑ = combos worth more | ↓ = combos worth less
    static let comboDecayTime: Double = 2.0   // ↑ = easier to maintain combo | ↓ = must match faster
    
    // MARK: - Visual Effects
    static let selectedTileScale: CGFloat = 1.2    // ↑ = selected tiles grow bigger | ↓ = smaller growth
    static let matchDisappearScale: CGFloat = 0.3  // ↑ = shrink less when matched | ↓ = shrink more when matched
    static let matchDisappearDuration: Double = 0.3 // ↑ = slower disappear | ↓ = faster disappear
    static let glowRadius: CGFloat = 8        // ↑ = bigger glow on selection | ↓ = smaller glow
    static let chainLineWidth: CGFloat = 4    // ↑ = thicker chain line | ↓ = thinner chain line
    
    // MARK: - Debug Visualization
    static let showCollisionBubbles = false   // true = SHOW debug circles | false = HIDE debug circles ⭐️
    static let bubbleDebugColor = Color.cyan.opacity(0.3)       // Color of debug circle fill
    static let bubbleDebugStrokeColor = Color.cyan.opacity(0.6) // Color of debug circle border
    static let bubbleDebugStrokeWidth: CGFloat = 1  // ↑ = thicker debug border | ↓ = thinner debug border
    
    // MARK: - Enabled Tile Types
    static let enabledTileTypes: [PhysicsTileType] = [
        .sword, .fire, .shield, .heart, .mana, .poison
    ]
    
    // MARK: - Helper Functions
    static func randomTileType() -> PhysicsTileType {
        enabledTileTypes.randomElement() ?? .sword
    }
    
    /// Random spawn height - spread across top 2/3 of screen for visible start
    static func randomSpawnHeight(boardHeight: CGFloat) -> CGFloat {
        return CGFloat.random(in: spawnMargin...(boardHeight * 0.66))
    }
    
    /// Random initial fall speed variation
    static func randomInitialFallSpeed() -> CGFloat {
        return CGFloat.random(in: 0.5...initialFallSpeed)
    }
    
    /// Get collision radius (includes bubble + spacing)
    static var collisionRadius: CGFloat {
        return (collisionBubbleSize + bubbleSpacing) / 2
    }
}
