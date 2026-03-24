//
//  GameViewModel.swift
//  OverQuestMatch3
//

import SwiftUI

@Observable
class GameViewModel {
    var boardManager: BoardManager
    var battleManager: BattleManager
    var hapticManager: HapticManager?  // ✨ NEW: Haptic feedback manager
    
    var selectedPosition: GridPosition?
    var isProcessing = false
    var score = 0
    
    // Animation states
    var shakeTiles: Set<GridPosition> = []
    var floatingDamage: [(position: CGPoint, text: String, id: UUID)] = []
    var isPlayerAttacking = false
    var isEnemyAttacking = false
    var flashPlayer = false
    var flashEnemy = false
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ⚡ RESPONSIVE GAMEPLAY CONTROLS (NEW!)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 🎯 EASY REVERT: Change these back to `false` to restore original behavior
    
    /// Skip artificial waiting pauses (animations still play at same speed)
    /// true = Board unlocks faster, snappier gameplay
    /// false = Original timing with all pauses (REVERT TO THIS IF ISSUES)
    var skipWaitingPauses: Bool = false  // ⚡ NEW: Faster board unlock!
    
    /// Allow enemy turn to happen in background after board unlocks
    /// true = You can make next move while enemy attacks
    /// false = Wait for enemy turn to fully complete (REVERT TO THIS IF ISSUES)
    var asyncEnemyTurn: Bool = false  // ⚡ NEW: Non-blocking enemy attacks!
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ⚡ AUTO-CHAIN SPEED CONTROL (Multi-Match Cascades Only!)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // This multiplier ONLY affects cascade 2, 3, 4, etc. (auto-matches)
    // Your FIRST match always plays at normal speed (1.0)
    //
    // 1.0 = Normal speed (same as first match)
    // 0.7 = ~30% faster (current - snappier auto-chains!)
    // 0.5 = 2x faster
    // 0.3 = Very fast auto-chains
    // 2.0 = 2x slower (watch cascades unfold)
    var autoChainSpeedMultiplier: Double = 0.5  // ⚡ Auto-chains run 50% faster
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ⚡ CHAIN MODE SPEED CONTROL (Buttery Smooth!)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Controls how fast chain processing happens after you release
    // Lower = faster, higher = slower
    //
    // 0.2 = Super fast (almost instant)
    // 0.4 = Fast and smooth (RECOMMENDED) ⭐
    // 0.6 = Normal speed
    // 1.0 = Slow
    var chainModeSpeedMultiplier: Double = 0.4  // ⚡ Buttery smooth!
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    // ✨ NEW: Explosion particles
    var explosionParticles: [(position: GridPosition, color: Color, id: UUID)] = []
    
    // ☕ NEW: Bonus tile blast effects (can show multiple for cross blast)
    var bonusBlasts: [BonusBlastData] = []
    
    // Gem clearing ability
    var selectedGemTypeToClear: TileType?
    var isSelectingGemToClear = false
    
    // Chain mode support
    var chainHandler: ChainInputHandler?
    
    // Game mode tracking
    var currentGameMode: GameMode = .swap
    
    init() {
        self.boardManager = BoardManager()
        self.battleManager = BattleManager()
        self.chainHandler = ChainInputHandler()
        
        // 🎮 Initialize board with gems
        boardManager.generateInitialBoard()
        
        // 🎮 FIX: Mark all initial gems as stable after spawn animation completes
        // This ensures gems can be swapped after game start animation finishes
        Task { @MainActor in
            // Wait for initial spawn animation to complete (longest delay is ~1.5 seconds)
            try? await Task.sleep(for: .milliseconds(2000))
            boardManager.markAllGemsStable()
        }
    }
    
    @MainActor
    func handleTileTap(at position: GridPosition) async {
        // 🎮 SESSION 14: Allow matching stable gems even during cascades (Bejeweled-style)
        // Only block if game is over
        guard battleManager.gameState == .playing else { return }
        
        if let selected = selectedPosition {
            if selected == position {
                // Deselect
                selectedPosition = nil
                hapticManager?.tileTapped()  // ✨ Tap feedback
            } else if boardManager.canSwap(from: selected, to: position) {
                // canSwap already checks if both gems are stable!
                selectedPosition = nil
                hapticManager?.swapStarted()  // ✨ Swap started
                await performSwap(from: selected, to: position)
            } else {
                // Select new tile
                selectedPosition = position
                hapticManager?.tileSelected()  // ✨ Selection change
            }
        } else {
            selectedPosition = position
            hapticManager?.tileSelected()  // ✨ Initial selection
        }
    }
    
    @MainActor
    private func performSwap(from: GridPosition, to: GridPosition) async {
        // 🎮 SESSION 14: Bejeweled-style allows multiple swaps
        // Gem stability (isStable) prevents invalid swaps during cascades
        // No need for global isProcessing lock!
        
        isProcessing = true  // Still track for UI feedback
        
        // ☕ BONUS TILE: Check if this swap involves a bonus tile
        let isBonusSwap = boardManager.isBonusTileSwap(from: from, to: to)
        
        if isBonusSwap {
            // ☕ CHECK: Are BOTH tiles bonus tiles? (SUPER COMBO!)
            let fromIsBonus = boardManager.gem(at: from)?.isBonusTile == true
            let toIsBonus = boardManager.gem(at: to)?.isBonusTile == true
            let isSuperCombo = fromIsBonus && toIsBonus
            
            if isSuperCombo {
                // ⚔️ SUPER COMBO: BOTH tiles are bonus - CROSS BLAST!
                // Clear BOTH row AND column at the bonus tile position
                
                boardManager.swap(from: from, to: to)
                hapticManager?.swapCompleted()
                try? await Task.sleep(for: .milliseconds(400))
                
                // Use the "to" position for the cross blast (where player dragged TO)
                await processCrossBlast(at: to)
                
                // ✅ REFILL BOARD: Apply gravity and spawn new gems
                _ = boardManager.applyGravity()
                try? await Task.sleep(for: .milliseconds(300))
                
                let _ = boardManager.fillEmptySpacesWithFastCascade()
                try? await Task.sleep(for: .milliseconds(400))
                
                // Mark gems stable
                boardManager.markAllGemsStable()
                
                // NOW check for cascading matches
                await processCascades()
                
                // Enemy turn
                if asyncEnemyTurn {
                    Task {
                        await enemyTurn()
                    }
                } else {
                    await enemyTurn()
                }
                
                isProcessing = false
                return
            } else {
                // ☕ SINGLE BONUS TILE: Normal row OR column blast
                let isHorizontalSwipe = from.row == to.row  // Same row = horizontal swipe (left/right)
                let bonusPosition = fromIsBonus ? from : to
                
                // Swap is always valid for bonus tiles
                boardManager.swap(from: from, to: to)
                hapticManager?.swapCompleted()
                try? await Task.sleep(for: .milliseconds(400))
                
                // Trigger bonus tile effect with direction
                await processBonusTile(at: bonusPosition, clearRow: isHorizontalSwipe)
                
                // ✅ REFILL BOARD: Apply gravity and spawn new gems
                _ = boardManager.applyGravity()
                try? await Task.sleep(for: .milliseconds(300))
                
                let _ = boardManager.fillEmptySpacesWithFastCascade()
                try? await Task.sleep(for: .milliseconds(400))
                
                // Mark gems stable
                boardManager.markAllGemsStable()
                
                // NOW check for cascading matches
                await processCascades()
                
                // Enemy turn
                if asyncEnemyTurn {
                    Task {
                        await enemyTurn()
                    }
                } else {
                    await enemyTurn()
                }
                
                isProcessing = false
                return
            }
        }
        
        // PRE-CHECK: Test if swap would create a valid match BEFORE actually swapping
        // Temporarily swap to check matches
        boardManager.swap(from: from, to: to)
        let matches = boardManager.findMatches()
        let swappedPositions = Set([from, to])
        let hasValidMatch = matches.contains { match in
            !Set(match.positions).isDisjoint(with: swappedPositions)
        }
        // Swap back immediately (before any visual update)
        boardManager.swap(from: from, to: to)
        
        if !hasValidMatch {
            // ❌ INVALID SWAP: Show swap animation, then swap back
            
            // 1. Animate the swap
            boardManager.swap(from: from, to: to)
            try? await Task.sleep(for: .milliseconds(100)) // Let swap animation play
            
            // 2. Show it's wrong with shake
            shakeTiles = [from, to]
            hapticManager?.swapRejected()  // ✨ Invalid swap haptic
            try? await Task.sleep(for: .milliseconds(200))
            
            // 3. Swap back with animation
            boardManager.swap(from: from, to: to)
            try? await Task.sleep(for: .milliseconds(300)) // Swap back animation
            shakeTiles.removeAll()
            
            // PENALTY: Enemy attacks for 8 damage due to invalid move
            battleManager.player.takeDamage(8)
            
            // 🎨 RAMP TAKES DAMAGE FROM MISTAKE (set to hurt2 state)
            battleManager.player.currentState = .hurt2
            
            // Show hurt animation
            isEnemyAttacking = true  // Enemy punishment visual
            flashPlayer = true       // Ramp flashes (taking damage)
            try? await Task.sleep(for: .milliseconds(350))
            isEnemyAttacking = false
            flashPlayer = false
            
            // 🎨 RETURN RAMP TO IDLE
            try? await Task.sleep(for: .milliseconds(150))
            battleManager.player.currentState = .idle
            
            isProcessing = false
            return
        }
        
        // ✅ VALID SWAP: Animate the swap, then process matches
        
        // 1. Perform the actual swap with animation
        boardManager.swap(from: from, to: to)
        hapticManager?.swapCompleted()  // ✨ Successful swap haptic
        try? await Task.sleep(for: .milliseconds(200)) // Let swap animation complete
        
        // 2. Now process the matches (wiggle + disappear)
        await processCascades()
        
        // 3. Enemy turn
        if asyncEnemyTurn {
            // ⚡ ASYNC MODE: Enemy attacks in background, board unlocks immediately
            Task {
                await enemyTurn()
            }
            // Board unlocks NOW - you can make next match!
        } else {
                    // 🐢 ORIGINAL MODE: Wait for enemy turn to complete
                    await enemyTurn()
                }
                
                // ✨ ALL ANIMATIONS DONE - Now show game over screen if needed
                battleManager.finalizeGameOver()
                
                isProcessing = false
            }
    
    @MainActor
    private func processCascades() async {
        // 🔗 CHAIN MODE: Skip match-3 processing entirely
        if currentGameMode == .chain {
            return
        }
        
        var cascadeCount = 0
        
        while true {
            let matches = boardManager.findMatches()
            guard !matches.isEmpty else { break }
            
            cascadeCount += 1
            
            // ⚡ SPEED CONTROL: First match = normal speed, auto-chains = faster
            let speedMultiplier = cascadeCount == 1 ? 0.5 : autoChainSpeedMultiplier
            
            // ✨ HAPTIC: Match detected (intensity scales with match size)
            let totalMatchedTiles = matches.reduce(0) { $0 + $1.count }
            hapticManager?.matchDetected(tileCount: totalMatchedTiles)
            
            // ═══════════════════════════════════════════════════════════════
            // STEP 1: MATCHED GEMS DISAPPEAR
            // ═══════════════════════════════════════════════════════════════
            
            // Highlight matched tiles with buzz animation
            shakeTiles = Set(matches.flatMap { $0.positions })
            if !skipWaitingPauses {
                try? await Task.sleep(for: .milliseconds(Int(150 * speedMultiplier)))
            }
            
            // ✨ NEW: Create explosions for matched gems
            for match in matches {
                for pos in match.positions {
                    if let gem = boardManager.gem(at: pos) {
                        explosionParticles.append((
                            position: pos,
                            color: gem.type.color,
                            id: UUID()
                        ))
                    }
                }
            }
            
            // ✨ HAPTIC: Explosion burst when gems clear
            if !explosionParticles.isEmpty {
                hapticManager?.matchDetected(tileCount: min(5, totalMatchedTiles))
            }
            
            // ☕ BONUS TILE: Check if we should spawn a bonus tile BEFORE clearing
            let bonusSpawnPosition = boardManager.shouldSpawnBonusTile(for: matches)
            
            // Remove matched tiles (they shrink/fade away)
            withAnimation(.easeOut(duration: 0.3)) {
                let clearedPositions = boardManager.clearMatches(matches)
            }
            shakeTiles.removeAll()
            
            // ☕ BONUS TILE: Spawn AFTER tiles disappear, BEFORE gravity
            if let spawnPos = bonusSpawnPosition {
                // Wait for disappear animation to finish
                try? await Task.sleep(for: .milliseconds(Int(300 * speedMultiplier)))
                
                // Now spawn the bonus tile in the empty space
                boardManager.spawnBonusTile(at: spawnPos)
            }
            
            // ⚡ RESPONSIVE MODE: Only wait for animation duration, skip extra pauses
            if skipWaitingPauses {
                try? await Task.sleep(for: .milliseconds(Int(200 * speedMultiplier)))  // Just enough for disappear animation
            } else {
                try? await Task.sleep(for: .milliseconds(Int(300 * speedMultiplier)))  // Original
            }
            
            // Clear explosions after they finish
            if !skipWaitingPauses {
                try? await Task.sleep(for: .milliseconds(Int(100 * speedMultiplier)))
            }
            explosionParticles.removeAll()
            
            // ═══════════════════════════════════════════════════════════════
            // STEP 2: EXISTING GEMS FALL DOWN (GRAVITY CASCADE)
            // ═══════════════════════════════════════════════════════════════
            
            // Apply gravity
            _ = boardManager.applyGravity()
            
            // Wait for visual cascade animation
            if skipWaitingPauses {
                try? await Task.sleep(for: .milliseconds(Int(300 * speedMultiplier)))  // Shorter wait, just for animation
            } else {
                try? await Task.sleep(for: .milliseconds(Int(500 * speedMultiplier)))  // Original
            }
            
            // ═══════════════════════════════════════════════════════════════
            // STEP 3: NEW GEMS SPAWN FROM TOP
            // ═══════════════════════════════════════════════════════════════
            
            let spawnInfo = boardManager.fillEmptySpacesWithFastCascade()
            
            if spawnInfo.newTileCount > 0 {
                let spawnWaitTime = 20 * boardManager.size + Int(SpawnAnimation.duration * 1000)
                
                // ⚡ RESPONSIVE MODE: Cut spawn wait time slightly
                if skipWaitingPauses {
                    try? await Task.sleep(for: .milliseconds(Int(Double(spawnWaitTime) * speedMultiplier * 0.7)))  // 30% faster
                } else {
                    try? await Task.sleep(for: .milliseconds(Int(Double(spawnWaitTime) * speedMultiplier)))  // Original
                }
            }
            
            // ═══════════════════════════════════════════════════════════════
            // STEP 4: PROCESS BATTLE EFFECTS
            // ═══════════════════════════════════════════════════════════════
            
            // Process battle effects from matches
            battleManager.processMatches(matches)
            
            // Check for Power Surge effect
            if battleManager.triggeredPowerSurge {
                hapticManager?.powerSurgeTriggered()  // ✨ POWER SURGE HAPTIC!
                
                // ⚡ RESPONSIVE MODE: Skip power surge delays
                if !skipWaitingPauses {
                    try? await Task.sleep(for: .milliseconds(Int(100 * speedMultiplier)))
                    try? await Task.sleep(for: .milliseconds(Int(1500 * speedMultiplier)))
                }
                battleManager.triggeredPowerSurge = false
            }
            
            // Play attack animation (still plays, just doesn't block as long)
            await playAttackAnimation()
            
            // ✨ HAPTIC: Cascade combo feedback
            if cascadeCount > 1 {
                hapticManager?.cascadeTriggered(comboNumber: cascadeCount)
            }
            
            // Update score
            for match in matches {
                score += match.count * 10 * cascadeCount
            }
            
            // 🎮 SESSION 14: Mark all gems as stable after cascade completes
            // This allows Bejeweled-style continuous matching
            boardManager.markAllGemsStable()
            
            // Small pause before checking for next cascade
            if !skipWaitingPauses {
                try? await Task.sleep(for: .milliseconds(Int(100 * speedMultiplier)))
            }
            // ⚡ RESPONSIVE MODE: No pause, check immediately for next cascade
        }
    }
    
    @MainActor
    private func playAttackAnimation() async {
        isPlayerAttacking = true
        flashEnemy = true
        try? await Task.sleep(for: .milliseconds(350))
        isPlayerAttacking = false
        flashEnemy = false
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ☕ BONUS TILE: Process bonus tile activation
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    @MainActor
    private func processBonusTile(at position: GridPosition, clearRow: Bool) async {
        // Highlight the bonus tile
        shakeTiles = [position]
        hapticManager?.powerSurgeTriggered()  // Big haptic for special effect
        
        try? await Task.sleep(for: .milliseconds(300))
        
        // Clear row or column based on swipe direction
        // Returns dictionary of gem types and their counts
        let gemTypeCounts = boardManager.clearWithBonusTile(at: position, clearRow: clearRow)
        
        // ═══════════════════════════════════════════════════════════════
        // ✨ APPLY GEM EFFECTS BASED ON COUNT
        // ═══════════════════════════════════════════════════════════════
        // Formula: (Number of gems cleared) × (effect per gem) = Total effect
        
        var totalDamage = 0
        var totalShield = 0
        var totalHealing = 0
        var totalMana = 0
        
        // Calculate effects for each gem type
        for (gemType, count) in gemTypeCounts {
            switch gemType {
            case .sword:
                if BattleMechanicsConfig.gemClearApplySwordDamage {
                    let damage = count * BattleMechanicsConfig.swordDamagePerGem
                    totalDamage += damage
                }
                
            case .fire:
                if BattleMechanicsConfig.gemClearApplyFireDamage {
                    let damage = count * BattleMechanicsConfig.fireDamagePerGem
                    totalDamage += damage
                }
                
            case .shield:
                if BattleMechanicsConfig.gemClearApplyShield {
                    totalShield += count * BattleMechanicsConfig.shieldPerGem
                }
                
            case .heart:
                if BattleMechanicsConfig.gemClearApplyHealing {
                    totalHealing += count * BattleMechanicsConfig.healingPerGem
                }
                
            case .mana:
                if BattleMechanicsConfig.gemClearApplyMana {
                    totalMana += count * BattleMechanicsConfig.manaPerGem
                }
                
            case .poison:
                if BattleMechanicsConfig.gemClearApplyPoison {
                    // Future poison implementation
                }
            }
        }
        
        // Apply calculated effects
        if totalDamage > 0 {
            battleManager.enemy.takeDamage(totalDamage)
        }
        if totalShield > 0 {
            battleManager.player.addShield(totalShield)
        }
        if totalHealing > 0 {
            battleManager.player.heal(totalHealing)
        }
        if totalMana > 0 {
            battleManager.mana = min(battleManager.mana + totalMana, BattleMechanicsConfig.maxMana)
        }
        
        // ═══════════════════════════════════════════════════════════════
        // ✨ BATTLE MESSAGE
        // ═══════════════════════════════════════════════════════════════
        
        var effectParts: [String] = []
        
        if totalDamage > 0 {
            effectParts.append("\(totalDamage) damage")
        }
        if totalShield > 0 {
            effectParts.append("+\(totalShield) shield")
        }
        if totalHealing > 0 {
            effectParts.append("+\(totalHealing) HP")
        }
        if totalMana > 0 {
            effectParts.append("+\(totalMana) mana")
        }
        
        let direction = clearRow ? "ROW" : "COLUMN"
        let effectMessage = effectParts.isEmpty ? "" : " → " + effectParts.joined(separator: ", ")
        let message = "💥 \(direction) BLAST!\(effectMessage)"
        
        battleManager.addEvent(BattleEvent(text: message, type: .special))
        
        // ☕ BONUS BLAST EFFECT - Choose between code-based or custom images
        
        // OPTION 1: Code-based blast (currently active)
        bonusBlasts = [BonusBlastData(
            position: position,
            isRow: clearRow,
            color: .yellow,
            id: UUID()
        )]
        
        // OPTION 2: Custom images (COMMENTED OUT - uncomment to use)
        // If you want to use custom blast images:
        // 1. Add images to Assets.xcassets:
        //    - bonus_blast_row_1.png through bonus_blast_row_X.png (for horizontal)
        //    - bonus_blast_col_1.png through bonus_blast_col_X.png (for vertical)
        // 2. Uncomment this code and comment out bonusBlasts above
        /*
        bonusBlasts = [BonusBlastData(
            position: position,
            isRow: clearRow,
            color: .yellow,
            id: UUID(),
            useCustomImages: true,
            frameCount: 6,  // How many frames your animation has
            frameRate: 12   // How fast to play (frames per second)
        )]
        */
        
        shakeTiles.removeAll()
        try? await Task.sleep(for: .milliseconds(600))  // Wait for blast animation
        bonusBlasts.removeAll()  // Clear blasts
        
        // ✅ REMOVED: Gravity and refill - performSwap() handles this!
        // ✅ REMOVED: Attack animation - performSwap() handles this!
        
        // Just wait for blast to finish, then return
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ⚔️ CROSS BLAST: Both row AND column (Super Combo!)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    @MainActor
    private func processCrossBlast(at position: GridPosition) async {
        // Highlight the position
        shakeTiles = [position]
        hapticManager?.powerSurgeTriggered()  // SUPER haptic!
        
        try? await Task.sleep(for: .milliseconds(300))
        
        // Clear BOTH row and column
        // Get gem type counts from both directions
        let rowGemCounts = boardManager.clearWithBonusTile(at: position, clearRow: true)
        let colGemCounts = boardManager.clearWithBonusTile(at: position, clearRow: false)
        
        // ═══════════════════════════════════════════════════════════════
        // ✨ COMBINE GEM COUNTS FROM BOTH ROW AND COLUMN
        // ═══════════════════════════════════════════════════════════════
        
        var combinedCounts: [TileType: Int] = [:]
        
        // Add row counts
        for (gemType, count) in rowGemCounts {
            combinedCounts[gemType, default: 0] += count
        }
        
        // Add column counts
        for (gemType, count) in colGemCounts {
            combinedCounts[gemType, default: 0] += count
        }
        
        // ═══════════════════════════════════════════════════════════════
        // ✨ CALCULATE EFFECTS FOR ALL GEM TYPES
        // ═══════════════════════════════════════════════════════════════
        
        var totalDamage = 0
        var totalShield = 0
        var totalHealing = 0
        var totalMana = 0
        
        for (gemType, count) in combinedCounts {
            switch gemType {
            case .sword:
                if BattleMechanicsConfig.gemClearApplySwordDamage {
                    let damage = count * BattleMechanicsConfig.swordDamagePerGem
                    totalDamage += damage
                }
                
            case .fire:
                if BattleMechanicsConfig.gemClearApplyFireDamage {
                    let damage = count * BattleMechanicsConfig.fireDamagePerGem
                    totalDamage += damage
                }
                
            case .shield:
                if BattleMechanicsConfig.gemClearApplyShield {
                    totalShield += count * BattleMechanicsConfig.shieldPerGem
                }
                
            case .heart:
                if BattleMechanicsConfig.gemClearApplyHealing {
                    totalHealing += count * BattleMechanicsConfig.healingPerGem
                }
                
            case .mana:
                if BattleMechanicsConfig.gemClearApplyMana {
                    totalMana += count * BattleMechanicsConfig.manaPerGem
                }
                
            case .poison:
                if BattleMechanicsConfig.gemClearApplyPoison {
                    // Future poison implementation
                }
            }
        }
        
        // Apply calculated effects
        if totalDamage > 0 {
            battleManager.enemy.takeDamage(totalDamage)
        }
        if totalShield > 0 {
            battleManager.player.addShield(totalShield)
        }
        if totalHealing > 0 {
            battleManager.player.heal(totalHealing)
        }
        if totalMana > 0 {
            battleManager.mana = min(battleManager.mana + totalMana, BattleMechanicsConfig.maxMana)
        }
        
        // ═══════════════════════════════════════════════════════════════
        // ✨ EPIC CROSS BLAST MESSAGE
        // ═══════════════════════════════════════════════════════════════
        
        var effectParts: [String] = []
        
        if totalDamage > 0 {
            effectParts.append("\(totalDamage) damage")
        }
        if totalShield > 0 {
            effectParts.append("+\(totalShield) shield")
        }
        if totalHealing > 0 {
            effectParts.append("+\(totalHealing) HP")
        }
        if totalMana > 0 {
            effectParts.append("+\(totalMana) mana")
        }
        
        let effectMessage = effectParts.isEmpty ? "" : " → " + effectParts.joined(separator: ", ")
        let message = "⚔️ CROSS BLAST!\(effectMessage)"
        
        battleManager.addEvent(BattleEvent(text: message, type: .special))
        
        // ⚔️ CREATE TWO BLASTS: Horizontal + Vertical (CROSS PATTERN!)
        bonusBlasts = [
            // Horizontal blast
            BonusBlastData(
                position: position,
                isRow: true,
                color: .yellow,
                id: UUID()
            ),
            // Vertical blast
            BonusBlastData(
                position: position,
                isRow: false,
                color: .yellow,
                id: UUID()
            )
        ]
        
        shakeTiles.removeAll()
        try? await Task.sleep(for: .milliseconds(600))  // Wait for both blasts
        bonusBlasts.removeAll()
        
        // ✅ REMOVED: Gravity and refill - performSwap() handles this!
        // ✅ REMOVED: Attack animation - performSwap() handles this!
        
        // Just wait for blast to finish, then return
    }
    
    @MainActor
    private func enemyTurn() async {
        // ⚡ RESPONSIVE MODE: Skip pre-enemy pause
        if !skipWaitingPauses {
            try? await Task.sleep(for: .milliseconds(400))
        }
        
        // 🎨 SET PORTRAIT STATES (direct update)
        battleManager.enemy.currentState = .attack
        battleManager.player.currentState = .hurt
        
        // Show visual attack effects
        isEnemyAttacking = true  // Ednar portrait slides forward
        flashPlayer = true       // Ramp flashes white
        
        // Apply damage (happens instantly)
        battleManager.enemyTurn()
        
        // Wait for animation to complete
        try? await Task.sleep(for: .milliseconds(350))
        isEnemyAttacking = false
        flashPlayer = false
        
        // 🎨 RETURN BOTH TO IDLE
        try? await Task.sleep(for: .milliseconds(150))
        battleManager.player.currentState = .idle
        battleManager.enemy.currentState = .idle
    }
    
    func resetGame() {
        // ✅ FIX: Clear selection state FIRST (prevents phantom selection box)
        selectedPosition = nil
        isSelectingGemToClear = false
        isProcessing = false
        
        // Clear visual states
        shakeTiles.removeAll()
        floatingDamage.removeAll()
        explosionParticles.removeAll()
        bonusBlasts.removeAll()
        
        // Clear animation flags
        isPlayerAttacking = false
        isEnemyAttacking = false
        flashPlayer = false
        flashEnemy = false
        
        // Reset game state
        score = 0
        boardManager.generateInitialBoard()
        battleManager.reset()
        
        // 🎮 FIX: Mark all gems stable after reset (ensures gems can be swapped immediately)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            boardManager.markAllGemsStable()
        }
    }
    
    // MARK: - Ability System
    
    @MainActor
    func startGemClearSelection() {
        isSelectingGemToClear = true
    }
    
    @MainActor
    func cancelGemClearSelection() {
        isSelectingGemToClear = false
    }
    
   
    @MainActor
        func clearGemsOfType(_ type: TileType) async {
            guard battleManager.canUseAbility(.heroicStrike) else { return }
            guard !isProcessing else { return }
            
            isProcessing = true
            isSelectingGemToClear = false
            
            // ✨ HAPTIC: Coffee cup ability activated!
            hapticManager?.abilityActivated()
            
            // ✨ IMPORTANT: Get gem positions AND colors BEFORE clearing
            let gemsToRemove = boardManager.gems.filter { $0.type == type }
            let gemInfo = gemsToRemove.map { (position: GridPosition(row: $0.row, col: $0.col), color: $0.type.color) }
            
            // ═══════════════════════════════════════════════════════════════
            // ✨ GEM CLEAR EFFECT CALCULATION
            // ═══════════════════════════════════════════════════════════════
            // Count how many gems of this type are on the board
            // Pass to battleManager to apply effects (damage, healing, etc.)
            let gemCount = gemsToRemove.count
            
            // Use the ability (this applies the gem effects based on count)
            battleManager.useAbility(.heroicStrike, gemType: type, gemCount: gemCount)
            
            // DON'T clear the gems yet! We need them visible for the shrink animation
            
            if !gemInfo.isEmpty {
                // ═══════════════════════════════════════════════════════════════
                // ✨ GEM SELECTOR ANIMATION TIMING CONTROLS
                // ═══════════════════════════════════════════════════════════════
                
                // How long gems shake/highlight before starting to shrink (milliseconds)
                // 200 = Default shake time
                // 300 = Longer shake
                // 100 = Quick shake
                let shakeBeforeShrinkDelay: Int = 200  // ⚡ CONTROL 1
                
                // How long AFTER shake to trigger explosions (milliseconds)
                // 0 = Explosions start immediately after shake
                // 100 = Brief delay after shake
                // 200 = Longer delay (explosions appear after gems start shrinking)
                let explosionDelay: Int = 0  // ⚡ CONTROL 2
                
                // How long gems take to shrink/fade away (milliseconds)
                // 300 = Default (smooth shrink)
                // 500 = Slow dramatic shrink
                // 150 = Fast shrink
                let shrinkDuration: Int = 300  // ⚡ CONTROL 3
                
                // ═══════════════════════════════════════════════════════════════
                
                // STEP 1: Highlight cleared gems briefly (they shake)
                shakeTiles = Set(gemInfo.map { $0.position })
                try? await Task.sleep(for: .milliseconds(shakeBeforeShrinkDelay))
                
                // STEP 2: Trigger explosions (based on your timing setting)
                try? await Task.sleep(for: .milliseconds(explosionDelay))
                
                // ✨ HAPTIC: Massive explosion as gems clear!
                hapticManager?.matchDetected(tileCount: 5)  // Max intensity burst
                
                // Create explosions using saved gem info
                for info in gemInfo {
                    explosionParticles.append((
                        position: info.position,
                        color: info.color,
                        id: UUID()
                    ))
                }
                
                // STEP 3: Start shrink animation (gems still visible but marked for removal)
                // The shake removal triggers the disappear animation in GemTileView
                shakeTiles.removeAll()
                
                // NOW remove the gems from the board (this triggers the scale-down)
                withAnimation(.easeOut(duration: Double(shrinkDuration) / 1000.0)) {
                    boardManager.gems.removeAll { $0.type == type }
                }
                
                // Wait for shrink animation to complete
                try? await Task.sleep(for: .milliseconds(shrinkDuration))
                
                // ═══════════════════════════════════════════════════════════════
                // CLEAN SEQUENTIAL ANIMATION: Fall, then spawn
                // ═══════════════════════════════════════════════════════════════
                
                // STEP 4: Gravity
                _ = boardManager.applyGravity()
                try? await Task.sleep(for: .milliseconds(500))
                
                // STEP 5: Spawn new gems
                let spawnInfo = boardManager.fillEmptySpacesWithFastCascade()
                if spawnInfo.newTileCount > 0 {
                    let spawnWaitTime = 20 * boardManager.size + Int(SpawnAnimation.duration * 1000)
                    try? await Task.sleep(for: .milliseconds(spawnWaitTime))
                }
                
                // Clear explosions after they finish
                try? await Task.sleep(for: .milliseconds(100))
                explosionParticles.removeAll()
                
                // STEP 6: Process any new matches that formed
                await processCascades()
            }
            
            // Enemy turn
                        await enemyTurn()
                        
                        // ✨ ALL ANIMATIONS DONE - Now show game over screen if needed
                        battleManager.finalizeGameOver()
                        
                        isProcessing = false
                    }
    // MARK: - Chain Mode Support
    
    @MainActor
    func processChainRelease(positions: [GridPosition], type: TileType) async {
        guard !isProcessing else { return }
        guard battleManager.gameState == .playing else { return }
        
        isProcessing = true
        
        // ✨ HAPTIC: Chain completed (intensity based on chain length)
        hapticManager?.matchDetected(tileCount: positions.count)
        
        // Update chain handler's tile type
        chainHandler?.chainTileType = type
        
        // ⚡ BUTTERY SMOOTH: Use chainModeSpeedMultiplier for all delays
        let speed = chainModeSpeedMultiplier
        
        // Remove the matched gems from the flat array
        let positionsSet = Set(positions)
        boardManager.gems.removeAll { gem in
            positionsSet.contains(GridPosition(row: gem.row, col: gem.col))
        }
        
        // Brief pause to show the match
        try? await Task.sleep(for: .milliseconds(Int(100 * speed)))
        
        // ═══════════════════════════════════════════════════════════════
        // CLEAN SEQUENTIAL ANIMATION: Fall, then spawn
        // ═══════════════════════════════════════════════════════════════
        
        // STEP 1: Gravity (existing gems fall)
        let gravityMoved = boardManager.applyGravity()
        if gravityMoved {
            let fallWaitTime = Int(Double(30 * boardManager.size + 300) * speed)
            try? await Task.sleep(for: .milliseconds(fallWaitTime))
        }
        
        // STEP 2: Spawn new gems
        let spawnInfo = boardManager.fillEmptySpacesWithFastCascade()
        if spawnInfo.newTileCount > 0 {
            let spawnWaitTime = Int(Double(20 * boardManager.size + Int(SpawnAnimation.duration * 1000)) * speed)
            try? await Task.sleep(for: .milliseconds(spawnWaitTime))
        }
        
        // Process any cascades
        await processCascades()
        
        // Calculate damage based on chain length
        let chainCount = positions.count
        let baseDamage = 10 // Base damage per tile
        let totalDamage = baseDamage * chainCount
        
        // Apply damage
        battleManager.enemy.takeDamage(totalDamage)
        
        // Show attack animation
        isPlayerAttacking = true
        flashEnemy = true
        try? await Task.sleep(for: .milliseconds(Int(350 * speed)))
        isPlayerAttacking = false
        flashEnemy = false
        
        // Enemy turn
                await enemyTurn()
                
                // ✨ ALL ANIMATIONS DONE - Now show game over screen if needed
                battleManager.finalizeGameOver()
                
                isProcessing = false
            }
        }


