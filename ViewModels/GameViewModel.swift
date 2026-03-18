//
//  GameViewModel.swift
//  OverQuestMatch3
//

import SwiftUI

@Observable
class GameViewModel {
    var boardManager: BoardManager
    var battleManager: BattleManager
    
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
    var autoChainSpeedMultiplier: Double = 0.7  // ⚡ Auto-chains run 30% faster
    
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
            } else if boardManager.canSwap(from: selected, to: position) {
                selectedPosition = nil
                await performSwap(from: selected, to: position)
            } else {
                // Select new tile
                selectedPosition = position
            }
        } else {
            selectedPosition = position
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
                try? await Task.sleep(for: .milliseconds(Int(100 * speedMultiplier)))
                try? await Task.sleep(for: .milliseconds(Int(1500 * speedMultiplier)))
                battleManager.triggeredPowerSurge = false
            }
            
            // Play attack animation
            await playAttackAnimation()
            
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
        
        // Use the ability
        battleManager.useAbility(.heroicStrike, gemType: type)
        
        // Clear all gems of this type from the board
        let clearedPositions = boardManager.clearAllGemsOfType(type)
        
        if !clearedPositions.isEmpty {
            // Highlight cleared gems briefly
            shakeTiles = Set(clearedPositions)
            try? await Task.sleep(for: .milliseconds(200))
            shakeTiles.removeAll()
            
            try? await Task.sleep(for: .milliseconds(150))
            
            // ═══════════════════════════════════════════════════════════════
            // CLEAN SEQUENTIAL ANIMATION: Fall, then spawn
            // ═══════════════════════════════════════════════════════════════
            
            // STEP 1: Gravity
            _ = boardManager.applyGravity()
            try? await Task.sleep(for: .milliseconds(500))
            
            // Clear fall delays
            
            // STEP 2: Spawn new gems
            let spawnInfo = boardManager.fillEmptySpacesWithFastCascade()
            if spawnInfo.newTileCount > 0 {
                let spawnWaitTime = 20 * boardManager.size + Int(SpawnAnimation.duration * 1000)
                try? await Task.sleep(for: .milliseconds(spawnWaitTime))
            }
            
            // Process any new matches that formed
            await processCascades()
        }
        
        // Enemy turn
        await enemyTurn()
        
        isProcessing = false
    }
    
    @MainActor
    func useAbility(_ ability: Ability) async {
        // For heroic strike, start gem selection mode
        if ability == .heroicStrike {
            startGemClearSelection()
            return
        }
        
        guard !isProcessing else { return }
        guard battleManager.canUseAbility(ability) else { return }
        
        isProcessing = true
        
        // Use the ability
        battleManager.useAbility(ability)
        
        // Play appropriate animation based on ability
        switch ability {
        case .divineShield, .greaterHeal:
            // Flash player for defensive/healing abilities
            flashPlayer = true
            try? await Task.sleep(for: .milliseconds(350))
            flashPlayer = false
        default:
            break
        }
        
        // Enemy turn after ability use
        await enemyTurn()
        
        isProcessing = false
    }
    
    // MARK: - Chain Mode Support
    
    @MainActor
    func processChainRelease(positions: [GridPosition], type: TileType) async {
        guard !isProcessing else { return }
        guard battleManager.gameState == .playing else { return }
        
        isProcessing = true
        
        // Update chain handler's tile type
        chainHandler?.chainTileType = type
        
        // Remove the matched gems from the flat array
        let positionsSet = Set(positions)
        boardManager.gems.removeAll { gem in
            positionsSet.contains(GridPosition(row: gem.row, col: gem.col))
        }
        
        // Brief pause to show the match
        try? await Task.sleep(for: .milliseconds(150))
        
        // ═══════════════════════════════════════════════════════════════
        // CLEAN SEQUENTIAL ANIMATION: Fall, then spawn
        // ═══════════════════════════════════════════════════════════════
        
        // STEP 1: Gravity (existing gems fall)
        let gravityMoved = boardManager.applyGravity()
        if gravityMoved {
            let fallWaitTime = 30 * boardManager.size + 300
            try? await Task.sleep(for: .milliseconds(fallWaitTime))
        }
        
        // STEP 2: Spawn new gems
        let spawnInfo = boardManager.fillEmptySpacesWithFastCascade()
        if spawnInfo.newTileCount > 0 {
            let spawnWaitTime = 20 * boardManager.size + Int(SpawnAnimation.duration * 1000)
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
        try? await Task.sleep(for: .milliseconds(350))
        isPlayerAttacking = false
        flashEnemy = false
        
        // Enemy turn
        await enemyTurn()
        
        isProcessing = false
    }
}
