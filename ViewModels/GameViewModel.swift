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
    
    // Gem clearing ability
    var selectedGemTypeToClear: TileType?
    var isSelectingGemToClear = false
    
    init() {
        self.boardManager = BoardManager()
        self.battleManager = BattleManager()
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
        
        // PRE-CHECK: Test if swap would create a valid match BEFORE animating
        boardManager.swap(from: from, to: to)
        let matches = boardManager.findMatches()
        
        let swappedPositions = Set([from, to])
        let hasValidMatch = matches.contains { match in
            !Set(match.positions).isDisjoint(with: swappedPositions)
        }
        
        if !hasValidMatch {
            // INVALID SWAP: Immediately swap back without animation delay
            boardManager.swap(from: from, to: to)
            
            // Show shake animation to indicate invalid move
            shakeTiles = [from, to]
            try? await Task.sleep(for: .milliseconds(300))
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
        
        // VALID SWAP: Animate the swap
        try? await Task.sleep(for: .milliseconds(300))
        
        // Process matches and cascades
        await processCascades()
        
        // Enemy turn
        await enemyTurn()
        
        isProcessing = false
    }
    
    @MainActor
    private func processCascades() async {
        var cascadeCount = 0
        
        while true {
            let matches = boardManager.findMatches()
            guard !matches.isEmpty else { break }
            
            cascadeCount += 1
            
            // 1. Highlight matched tiles
            shakeTiles = Set(matches.flatMap { $0.positions })
            try? await Task.sleep(for: .milliseconds(200))
            
            // 2. Remove matched tiles (they shrink/disappear)
            boardManager.clearMatches(matches)
            shakeTiles.removeAll()
            try? await Task.sleep(for: .milliseconds(200))
            
            // 3. GRAVITY FALL: Calculate max distance for timing
            let maxFallDistance = boardManager.calculateMaxFallDistance()
            let gravityMoved = boardManager.applyGravity()
            
            if gravityMoved {
                // Duration proportional to distance: distance × 100ms per row
                let fallDuration = min(maxFallDistance * 100, 600) // Cap at 600ms
                try? await Task.sleep(for: .milliseconds(fallDuration))
            }
            
            // 4. SPAWN NEW TILES: They drop from above
            let spawnInfo = boardManager.fillEmptySpaces()
            
            if spawnInfo.maxSpawnDistance > 0 {
                // Spring animation for new tiles dropping in
                let spawnDuration = min(spawnInfo.maxSpawnDistance * 80, 500)
                try? await Task.sleep(for: .milliseconds(spawnDuration))
            }
            
            // 5. Process battle effects
            battleManager.processMatches(matches)
            
            // ═══════════════════════════════════════════════════════════════
            // 🔥 SESSION 2 ADDITION: POWER SURGE EFFECT TIMING (START)
            // ═══════════════════════════════════════════════════════════════
            // If Power Surge triggered, show effect
            if battleManager.triggeredPowerSurge {
                print("🔥 Power Surge detected! Waiting for effect...") // Debug
                try? await Task.sleep(for: .milliseconds(100)) // Give SwiftUI time to see the flag
                try? await Task.sleep(for: .milliseconds(1500)) // Let effect play
                print("🔥 Resetting Power Surge flag") // Debug
                battleManager.triggeredPowerSurge = false // Reset flag
            }
            // ═══════════════════════════════════════════════════════════════
            // 🔥 SESSION 2 ADDITION: POWER SURGE EFFECT TIMING (END)
            // ═══════════════════════════════════════════════════════════════
            
            await playAttackAnimation()
            
            // 6. Update score
            for match in matches {
                score += match.count * 10 * cascadeCount
            }
            
            // Small pause before checking next cascade
            try? await Task.sleep(for: .milliseconds(100))
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
            try? await Task.sleep(for: .milliseconds(300))
            shakeTiles.removeAll()
            
            // Apply gravity and refill
            try? await Task.sleep(for: .milliseconds(200))
            
            let maxFallDistance = boardManager.calculateMaxFallDistance()
            _ = boardManager.applyGravity()
            
            let fallDuration = min(maxFallDistance * 100, 600)
            try? await Task.sleep(for: .milliseconds(fallDuration))
            
            let spawnInfo = boardManager.fillEmptySpaces()
            let spawnDuration = min(spawnInfo.maxSpawnDistance * 80, 500)
            try? await Task.sleep(for: .milliseconds(spawnDuration))
            
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
}
