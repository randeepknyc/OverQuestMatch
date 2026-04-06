//
//  ShopOfOdditiesView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Main game screen for Ednar's Shop of Oddities card repair game
//

import SwiftUI

struct ShopOfOdditiesView: View {
    
    @State private var gameState = ShopGameState()
    @State private var repairsDiscoveredBeforeGame: Set<String> = []
    @State private var showingAssetsDebug = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.15, blue: 0.1),
                        Color(red: 0.3, green: 0.25, blue: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // SCORE BAR (top)
                    scoreBar
                        .frame(height: geometry.size.height * 0.08)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    // CUSTOMER AREA
                    if let customer = gameState.currentCustomer {
                        CustomerView(
                            customer: customer,
                            nextCustomer: gameState.nextCustomer
                        )
                        .frame(height: geometry.size.height * 0.20)
                    }
                    
                    Spacer()
                        .frame(height: 8)
                    
                    // COMMENTARY AREA
                    commentaryArea
                        .frame(height: geometry.size.height * 0.07)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    // REPAIR AREA (4 slots)
                    repairArea
                        .frame(height: geometry.size.height * 0.14)
                    
                    Spacer()
                        .frame(height: 12)
                    
                    // ✨ NEW: FOUR DECKS SIDE-BY-SIDE (BIGGER!)
                    decksArea
                        .frame(height: geometry.size.height * 0.35) // Increased from 0.30
                    
                    Spacer()
                        .frame(height: 8)
                }
                .padding(.horizontal, 12)
                
                // OVERLAYS
                
                // Repair result overlay (shows for 1.5 seconds after success)
                if gameState.showingResultOverlay, let result = gameState.currentResult {
                    RepairResultOverlay(result: result)
                        .zIndex(10)
                }
                
                // New repair discovered banner (shows for 1 second after result overlay)
                if gameState.showingNewRepairDiscovered, let repairName = gameState.newlyDiscoveredRepairName {
                    NewRepairDiscoveredBanner(repairName: repairName)
                        .zIndex(11)
                }
                
                // Game over overlay (win or lose)
                if gameState.gameOver {
                    ShopGameOverOverlay(
                        gameWon: gameState.gameWon,
                        finalScore: gameState.score,
                        customersServed: gameState.customersServed,
                        totalCustomers: 13,
                        reason: gameState.gameOverReason,
                        repairs: gameState.repairsCompleted,
                        newRepairsCount: calculateNewRepairsThisGame(),
                        onPlayAgain: {
                            repairsDiscoveredBeforeGame = gameState.discoveredRepairNames
                            gameState.startNewGame()
                        }
                    )
                    .zIndex(12)
                }
            }
        }
        .onAppear {
            // Track repairs known before this game started
            repairsDiscoveredBeforeGame = gameState.discoveredRepairNames
        }
    }
    
    // MARK: - Score Bar
    
    private var scoreBar: some View {
        HStack(spacing: 16) {
            // Score display
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18))
                
                Text("\(gameState.score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Customers served count
            HStack(spacing: 6) {
                Image(systemName: "person.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
                
                Text("\(gameState.customersServed)/13")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Debug button (wrench icon)
            Button(action: {
                showingAssetsDebug = true
            }) {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.cyan)
            }
            .sheet(isPresented: $showingAssetsDebug) {
                AssetsDebugView(gameState: $gameState)
            }
            
            // Gear icon (placeholder for future pause/menu)
            Button(action: {
                // Future: pause menu
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.5))
        )
    }
    
    // MARK: - Commentary Area
    
    private var commentaryArea: some View {
        Group {
            if gameState.commentaryManager.isShowingCommentary,
               let commentary = gameState.commentaryManager.currentCommentary {
                CommentaryView(commentary: commentary)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9)),
                        removal: .opacity
                    ))
                    .animation(.easeInOut(duration: 0.3), value: gameState.commentaryManager.isShowingCommentary)
            } else {
                // Empty space when no commentary
                Color.clear
            }
        }
    }
    
    // MARK: - Repair Area
    
    private var repairArea: some View {
        VStack(spacing: 6) {
            // Label
            Text("REPAIR AREA")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            // 4 slots in a horizontal row
            HStack(spacing: 8) {
                ForEach(gameState.repairSlots) { slot in
                    RepairSlotView(slot: slot)
                }
            }
        }
    }
    
    // MARK: - Decks Area (✨ REDESIGNED: SIDE-BY-SIDE)
    
    private var decksArea: some View {
        VStack(spacing: 8) {
            // Label
            Text("COMPONENT DECKS")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            // ✨ NEW: All 4 decks in ONE horizontal row (side-by-side)
            HStack(spacing: 6) {
                // Structural
                DeckView(
                    type: .structural,
                    topCard: gameState.topCard(of: .structural),
                    cardsRemaining: gameState.cardsRemaining(in: .structural),
                    canDraw: gameState.canDraw(from: .structural),
                    onTap: {
                        gameState.drawCard(from: .structural)
                        checkIfRepairReady()
                    }
                )
                
                // Enchantment
                DeckView(
                    type: .enchantment,
                    topCard: gameState.topCard(of: .enchantment),
                    cardsRemaining: gameState.cardsRemaining(in: .enchantment),
                    canDraw: gameState.canDraw(from: .enchantment),
                    onTap: {
                        gameState.drawCard(from: .enchantment)
                        checkIfRepairReady()
                    }
                )
                
                // Memory
                DeckView(
                    type: .memory,
                    topCard: gameState.topCard(of: .memory),
                    cardsRemaining: gameState.cardsRemaining(in: .memory),
                    canDraw: gameState.canDraw(from: .memory),
                    onTap: {
                        gameState.drawCard(from: .memory)
                        checkIfRepairReady()
                    }
                )
                
                // Wildcraft
                DeckView(
                    type: .wildcraft,
                    topCard: gameState.topCard(of: .wildcraft),
                    cardsRemaining: gameState.cardsRemaining(in: .wildcraft),
                    canDraw: gameState.canDraw(from: .wildcraft),
                    onTap: {
                        gameState.drawCard(from: .wildcraft)
                        checkIfRepairReady()
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Check if all slots are filled (ready to complete repair)
    private func checkIfRepairReady() {
        if gameState.repairSlots.allFilled {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                await gameState.completeRepair()
            }
        }
    }
    
    /// Calculate how many new repairs were discovered this game
    private func calculateNewRepairsThisGame() -> Int {
        let repairsNow = gameState.discoveredRepairNames
        let repairsBefore = repairsDiscoveredBeforeGame
        return repairsNow.subtracting(repairsBefore).count
    }
}

// MARK: - Preview

#Preview {
    ShopOfOdditiesView()
}
