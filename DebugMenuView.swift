//
//  DebugMenuView.swift
//  OverQuestMatch3
//
//  🛠️ DEBUG TOOLS - For testing and development
//

import SwiftUI

struct DebugMenuView: View {
    @Bindable var viewModel: GameViewModel
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            // Debug menu panel
            VStack(spacing: 0) {
                // Header
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Quick Actions
                        quickActionsSection
                        
                        Divider()
                        
                        // Board Manipulation
                        boardManipulationSection
                        
                        Divider()
                        
                        // Battle Stats
                        battleStatsSection
                        
                        Divider()
                        
                        // Game Speed
                        gameSpeedSection
                        
                        Divider()
                        
                        // Bonus Tile Testing
                        bonusTileSection
                        
                        Divider()
                        
                        // Poison Pill Testing
                        poisonPillSection
                    }
                    .padding(20)
                }
            }
            .frame(maxWidth: 400, maxHeight: 600)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.5), radius: 20)
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // HEADER
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "hammer.fill")
                .foregroundColor(.orange)
            Text("DEBUG MENU")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button(action: { isShowing = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.2))
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // QUICK ACTIONS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "⚡ QUICK ACTIONS", icon: "bolt.fill")
            
            HStack(spacing: 10) {
                debugButton(title: "Fill Mana (7/7)", icon: "battery.100", color: .yellow) {
                    viewModel.battleManager.mana = 7
                }
                
                debugButton(title: "Full HP", icon: "heart.fill", color: .red) {
                    viewModel.battleManager.player.currentHealth = viewModel.battleManager.player.maxHealth
                }
            }
            
            HStack(spacing: 10) {
                debugButton(title: "Kill Enemy", icon: "skull.fill", color: .purple) {
                    viewModel.battleManager.enemy.currentHealth = 1
                }
                
                debugButton(title: "+50 Shield", icon: "shield.fill", color: .cyan) {
                    viewModel.battleManager.player.shield += 50
                }
            }
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // BOARD MANIPULATION
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private var boardManipulationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "🎲 BOARD MANIPULATION", icon: "square.grid.3x3.fill")
            
            // Force 5-match for each tile type
            Text("Force 5-Match (Top Row):")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(TileType.allCases, id: \.self) { tileType in
                    debugButton(
                        title: tileType.rawValue.capitalized,
                        icon: nil,
                        color: tileType.color,
                        compact: true
                    ) {
                        force5Match(type: tileType)
                    }
                }
            }
            
            // Spawn bonus tile
            debugButton(title: "Spawn Coffee Bonus (Center)", icon: "cup.and.saucer.fill", color: .brown) {
                spawnCoffeeAtCenter()
            }
            
            // Clear board
            debugButton(title: "Clear Entire Board", icon: "trash.fill", color: .red) {
                clearBoard()
            }
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // BATTLE STATS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private var battleStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "⚔️ BATTLE STATS", icon: "chart.bar.fill")
            
            VStack(spacing: 8) {
                statRow(label: "Player HP", value: "\(viewModel.battleManager.player.currentHealth)/\(viewModel.battleManager.player.maxHealth)")
                statRow(label: "Enemy HP", value: "\(viewModel.battleManager.enemy.currentHealth)/\(viewModel.battleManager.enemy.maxHealth)")
                statRow(label: "Mana", value: "\(viewModel.battleManager.mana)/7")
                statRow(label: "Shield", value: "\(viewModel.battleManager.player.shield)")
                statRow(label: "Score", value: "\(viewModel.score)")
            }
            .padding(12)
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // GAME SPEED
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private var gameSpeedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "⏱️ GAME SPEED", icon: "speedometer")
            
            HStack(spacing: 10) {
                debugButton(title: "Skip Pauses: \(viewModel.skipWaitingPauses ? "ON" : "OFF")", icon: "forward.fill", color: viewModel.skipWaitingPauses ? .green : .gray) {
                    viewModel.skipWaitingPauses.toggle()
                }
                
                debugButton(title: "Async Enemy: \(viewModel.asyncEnemyTurn ? "ON" : "OFF")", icon: "arrow.triangle.branch", color: viewModel.asyncEnemyTurn ? .green : .gray) {
                    viewModel.asyncEnemyTurn.toggle()
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Auto-Chain Speed: \(String(format: "%.1fx", viewModel.autoChainSpeedMultiplier))")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Slider(value: $viewModel.autoChainSpeedMultiplier, in: 0.1...2.0, step: 0.1)
                    .tint(.orange)
            }
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // BONUS TILE TESTING
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private var bonusTileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "☕ BONUS TILE TESTING", icon: "cup.and.saucer.fill")
            
            HStack(spacing: 10) {
                debugButton(title: "Spawn at (3,3)", icon: "plus.circle", color: .brown) {
                    let position = GridPosition(row: 3, col: 3)
                    // ☕ REMOVE EXISTING GEM FIRST, THEN SPAWN BONUS
                    viewModel.boardManager.gems.removeAll { $0.row == position.row && $0.col == position.col }
                    viewModel.boardManager.spawnBonusTile(at: position)
                }
                
                debugButton(title: "Spawn at (5,5)", icon: "plus.circle", color: .brown) {
                    let position = GridPosition(row: 5, col: 5)
                    // ☕ REMOVE EXISTING GEM FIRST, THEN SPAWN BONUS
                    viewModel.boardManager.gems.removeAll { $0.row == position.row && $0.col == position.col }
                    viewModel.boardManager.spawnBonusTile(at: position)
                }
            }
            
            // ⚔️ NEW: Spawn TWO bonus tiles next to each other (for cross blast testing!)
            debugButton(title: "⚔️ Spawn TWO at (4,4) + (4,5) [CROSS TEST]", icon: "plus.circle.fill", color: .orange) {
                let position1 = GridPosition(row: 4, col: 4)
                let position2 = GridPosition(row: 4, col: 5)
                
                // Remove any existing gems at both positions
                viewModel.boardManager.gems.removeAll { $0.row == position1.row && $0.col == position1.col }
                viewModel.boardManager.gems.removeAll { $0.row == position2.row && $0.col == position2.col }
                
                // Spawn bonus tiles at both positions
                viewModel.boardManager.spawnBonusTile(at: position1)
                viewModel.boardManager.spawnBonusTile(at: position2)
            }
            
            debugButton(title: "Remove All Bonus Tiles", icon: "xmark.circle", color: .red) {
                removeAllBonusTiles()
            }
            
            Text("Current Clear Mode: \(BonusTileConfig.clearMode)")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 4)
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // POISON PILL TESTING
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private var poisonPillSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "🧪 POISON PILL TESTING", icon: "cross.vial")
            
            // Status display
            VStack(alignment: .leading, spacing: 6) {
                if let pillPos = viewModel.battleManager.poisonPillManager.poisonPillPosition {
                    HStack {
                        Text("💀 Hidden at:")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                        Text("Row \(pillPos.row), Col \(pillPos.col)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.purple)
                    }
                } else if viewModel.battleManager.poisonPillManager.isPoisoned {
                    HStack {
                        Text("☣️ POISONED:")
                            .font(.system(size: 13))
                            .foregroundColor(.purple)
                        Text("Turn \(viewModel.battleManager.poisonPillManager.poisonTurnCounter)/3")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Text("✅ No Poison Active")
                        .font(.system(size: 13))
                        .foregroundColor(.green)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
            
            // Actions
            HStack(spacing: 10) {
                debugButton(title: "Place at (4,4)", icon: "location.fill", color: .purple) {
                    placePoisonPill(at: GridPosition(row: 4, col: 4))
                }
                
                debugButton(title: "Random Position", icon: "shuffle", color: .purple) {
                    viewModel.battleManager.poisonPillManager.setupPoisonPill(boardSize: viewModel.boardManager.size)
                }
            }
            
            HStack(spacing: 10) {
                debugButton(title: "Show Location", icon: "eye.fill", color: .orange) {
                    showPoisonPillLocation()
                }
                
                debugButton(title: "Trigger Poison", icon: "exclamationmark.triangle.fill", color: .red) {
                    triggerPoison()
                }
            }
            
            debugButton(title: "Clear Poison Status", icon: "bandage.fill", color: .green) {
                viewModel.battleManager.poisonPillManager.reset()
                viewModel.battleManager.poisonPillManager.setupPoisonPill(boardSize: viewModel.boardManager.size)
            }
            
            // Info
            Text("Damage: 3 (immediately) → 3 → 4 → 5 over 3 turns")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 4)
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // HELPER VIEWS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.orange)
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private func debugButton(title: String, icon: String?, color: Color, compact: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: compact ? 12 : 14))
                }
                Text(title)
                    .font(.system(size: compact ? 11 : 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, compact ? 8 : 12)
            .padding(.horizontal, compact ? 6 : 10)
            .background(color)
            .cornerRadius(8)
        }
    }
    
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ACTIONS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private func force5Match(type: TileType) {
        // Create 5 tiles in top row (row 0, columns 2-6)
        for col in 2...6 {
            if let index = viewModel.boardManager.gems.firstIndex(where: { $0.row == 0 && $0.col == col }) {
                viewModel.boardManager.gems[index] = Tile(
                    type: type,
                    row: 0,
                    col: col
                )
            }
        }
    }
    
    private func spawnCoffeeAtCenter() {
        let center = viewModel.boardManager.size / 2
        let position = GridPosition(row: center, col: center)
        
        // ☕ REMOVE EXISTING GEM FIRST, THEN SPAWN BONUS
        viewModel.boardManager.gems.removeAll { $0.row == position.row && $0.col == position.col }
        viewModel.boardManager.spawnBonusTile(at: position)
    }
    
    private func clearBoard() {
        viewModel.boardManager.gems.removeAll()
        
        // Refill after a short delay
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            viewModel.boardManager.generateInitialBoard()
        }
    }
    
    private func removeAllBonusTiles() {
        viewModel.boardManager.gems.removeAll { $0.isBonusTile }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // POISON PILL ACTIONS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private func placePoisonPill(at position: GridPosition) {
        let manager = viewModel.battleManager.poisonPillManager
        manager.poisonPillPosition = position
        manager.isPoisoned = false
        manager.poisonTurnCounter = 0
        manager.revealedPoisonEffect = nil
        print("🧪 DEBUG: Poison pill placed at \(position)")
    }
    
    private func showPoisonPillLocation() {
        guard let position = viewModel.battleManager.poisonPillManager.poisonPillPosition else {
            print("❌ No hidden poison pill found")
            return
        }
        
        // Highlight the position with shake effect for 2 seconds
        viewModel.shakeTiles = [position]
        
        Task {
            try? await Task.sleep(for: .milliseconds(2000))
            viewModel.shakeTiles.removeAll()
        }
        
        print("👁️ Poison pill location highlighted: Row \(position.row), Col \(position.col)")
    }
    
    private func triggerPoison() {
        let manager = viewModel.battleManager.poisonPillManager
        
        if let pillPos = manager.poisonPillPosition {
            // Reveal the poison pill
            _ = manager.checkForPoisonReveal(matchedPositions: [pillPos])
            
            // Apply immediate damage
            viewModel.battleManager.player.takeDamage(3)
            viewModel.battleManager.addEvent(BattleEvent(
                text: "💀 DEBUG: Poison triggered manually!",
                type: .enemyAttack
            ))
            
            print("💀 DEBUG: Poison pill triggered at \(pillPos)")
        } else if manager.isPoisoned {
            print("⚠️ Already poisoned! Turn \(manager.poisonTurnCounter)/3")
        } else {
            print("❌ No poison pill to trigger. Place one first!")
        }
    }
}
