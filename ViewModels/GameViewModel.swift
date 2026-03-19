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
    }
    
    @MainActor
    func handleTileTap(at position: GridPosition) async {
        guard !isProcessing else { return }
        guard battleManager.gameState == .playing else { return }
        
        if let selected = selectedPosition {
            if selected == position {
                // Deselect
                selectedPosition = nil
                hapticManager?.tileTapped()  // ✨ Tap feedback
            } else if boardManager.canSwap(from: selected, to: position) {
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
        isProcessing = true
        
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
            try? await Task.sleep(for: .milliseconds(300)) // Let swap animation play
            
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
            
            // Show enemy attack animation
            isEnemyAttacking = true
            flashPlayer = true
            try? await Task.sleep(for: .milliseconds(350))
            isEnemyAttacking = false
            flashPlayer = false
            
            isProcessing = false
            return
        }
        
        // ✅ VALID SWAP: Animate the swap, then process matches
        
        // 1. Perform the actual swap with animation
        boardManager.swap(from: from, to: to)
        hapticManager?.swapCompleted()  // ✨ Successful swap haptic
        try? await Task.sleep(for: .milliseconds(400)) // Let swap animation complete
        
        // 2. Now process the matches (wiggle + disappear)
        await processCascades()
        
        // 3. Enemy turn
        await enemyTurn()
        
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
            let speedMultiplier = cascadeCount == 1 ? 1.0 : autoChainSpeedMultiplier
            
            // ✨ HAPTIC: Match detected (intensity scales with match size)
            let totalMatchedTiles = matches.reduce(0) { $0 + $1.count }
            hapticManager?.matchDetected(tileCount: totalMatchedTiles)
            
            // ═══════════════════════════════════════════════════════════════
            // STEP 1: MATCHED GEMS DISAPPEAR
            // ═══════════════════════════════════════════════════════════════
            
            // Highlight matched tiles with buzz animation
            shakeTiles = Set(matches.flatMap { $0.positions })
            try? await Task.sleep(for: .milliseconds(Int(150 * speedMultiplier)))
            
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
            
            // Remove matched tiles (they shrink/fade away)
            withAnimation(.easeOut(duration: 0.3)) {
                boardManager.clearMatches(matches)
            }
            shakeTiles.removeAll()
            try? await Task.sleep(for: .milliseconds(Int(300 * speedMultiplier)))
            
            // Clear explosions after they finish
            try? await Task.sleep(for: .milliseconds(Int(100 * speedMultiplier)))
            explosionParticles.removeAll()
            
            // ═══════════════════════════════════════════════════════════════
            // STEP 2: EXISTING GEMS FALL DOWN (GRAVITY CASCADE)
            // ═══════════════════════════════════════════════════════════════
            
            // Apply gravity
            _ = boardManager.applyGravity()
            
            // Wait for visual cascade animation
            try? await Task.sleep(for: .milliseconds(Int(500 * speedMultiplier)))
            
            // ═══════════════════════════════════════════════════════════════
            // STEP 3: NEW GEMS SPAWN FROM TOP
            // ═══════════════════════════════════════════════════════════════
            
            let spawnInfo = boardManager.fillEmptySpacesWithFastCascade()
            
            if spawnInfo.newTileCount > 0 {
                let spawnWaitTime = 20 * boardManager.size + Int(SpawnAnimation.duration * 1000)
                try? await Task.sleep(for: .milliseconds(Int(Double(spawnWaitTime) * speedMultiplier)))
            }
            
            // ═══════════════════════════════════════════════════════════════
            // STEP 4: PROCESS BATTLE EFFECTS
            // ═══════════════════════════════════════════════════════════════
            
            // Process battle effects from matches
            battleManager.processMatches(matches)
            
            // Check for Power Surge effect
            if battleManager.triggeredPowerSurge {
                hapticManager?.powerSurgeTriggered()  // ✨ POWER SURGE HAPTIC!
                try? await Task.sleep(for: .milliseconds(Int(100 * speedMultiplier)))
                try? await Task.sleep(for: .milliseconds(Int(1500 * speedMultiplier)))
                battleManager.triggeredPowerSurge = false
            }
            
            // Play attack animation
            await playAttackAnimation()
            
            // ✨ HAPTIC: Cascade combo feedback
            if cascadeCount > 1 {
                hapticManager?.cascadeTriggered(comboNumber: cascadeCount)
            }
            
            // Update score
            for match in matches {
                score += match.count * 10 * cascadeCount
            }
            
            // Small pause before checking for next cascade
            try? await Task.sleep(for: .milliseconds(Int(100 * speedMultiplier)))
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
    
    @MainActor
    private func enemyTurn() async {
        try? await Task.sleep(for: .milliseconds(400))
        
        isEnemyAttacking = true
        flashPlayer = true
        battleManager.enemyTurn()
        try? await Task.sleep(for: .milliseconds(350))
        isEnemyAttacking = false
        flashPlayer = false
    }
    
    func resetGame() {
        boardManager.generateInitialBoard()
        battleManager.reset()
        score = 0
        selectedPosition = nil
        isProcessing = false
        shakeTiles.removeAll()
        floatingDamage.removeAll()
        isSelectingGemToClear = false
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
            
            // Use the ability
            battleManager.useAbility(.heroicStrike, gemType: type)
            
            // ✨ IMPORTANT: Get gem positions AND colors BEFORE clearing
            let gemsToRemove = boardManager.gems.filter { $0.type == type }
            let gemInfo = gemsToRemove.map { (position: GridPosition(row: $0.row, col: $0.col), color: $0.type.color) }
            
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
        
        isProcessing = false
    }
}
