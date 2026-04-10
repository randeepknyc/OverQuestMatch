//
//  ShopOfOdditiesView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Main game screen for Ednar's Shop of Oddities card repair game
//

import SwiftUI
import UIKit

struct ShopOfOdditiesView: View {
    
    @State private var gameState = ShopGameState()
    @State private var repairsDiscoveredBeforeGame: Set<String> = []
    @State private var showingAssetsDebug = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // FULL-SCREEN BACKGROUND (behind everything)
                backgroundLayer
                
                VStack(spacing: 0) {
                    // 1. SCORE BAR (5% height) - EDGE-TO-EDGE Semi-transparent HUD overlay ✨ NEW
                    scoreBar(geometry: geometry)
                        .frame(height: geometry.size.height * 0.05)
                    
                    // ✨ GAP 1 REMOVED (was 8pt fixed)
                    
                    // 2. SCENE VIEW (38% height) - EDGE TO EDGE with padded overlay (PRESERVED)
                    if let customer = gameState.currentCustomer {
                        ShopSceneView(customer: customer)
                            .frame(height: geometry.size.height * 0.38)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 12) // ✨ Padding moved here from VStack
                    }
                    
                    Spacer()
                        .frame(height: 8)
                    
                    // 3. COMMENTARY AREA (4% height) - ✨ SHRUNK from 5%
                    commentaryArea
                        .frame(height: geometry.size.height * 0.04)
                        .padding(.horizontal, 12) // ✨ Padding moved here from VStack
                    
                    // GAP 3: Commentary → Repair (3.5% height) - ✨ SHRUNK from 5.5%
                    Spacer()
                        .frame(height: geometry.size.height * 0.035)
                    
                    // 4. REPAIR AREA (20% height) - ✨ GREW from 17.7%
                    repairArea
                        .frame(height: geometry.size.height * 0.20)
                        .padding(.horizontal, 12) // ✨ Padding moved here from VStack
                    
                    // GAP 4: Repair → Decks (3% height) - ✨ SHRUNK from 6%
                    Spacer()
                        .frame(height: geometry.size.height * 0.03)
                    
                    // 5. DECKS AREA (36% height) - ✨ GREW from 30%
                    decksArea
                        .frame(height: geometry.size.height * 0.36)
                        .padding(.horizontal, 12) // ✨ Padding moved here from VStack
                    
                    Spacer()
                        .frame(height: 8) // Bottom breathing room
                }
                // ✨ REMOVED .padding(.horizontal, 12) from VStack
                
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
    
    // MARK: - Background Layer
    
    private var backgroundLayer: some View {
        Group {
            if let tableBg = UIImage(named: "shop-table-bg") {
                Image(uiImage: tableBg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                // Fallback: dark brown color
                Color(red: 0.25, green: 0.18, blue: 0.12)
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Score Bar (EDGE-TO-EDGE Semi-Transparent HUD Overlay) ✨ UPDATED
    
    private func scoreBar(geometry: GeometryProxy) -> some View {
        ZStack {
            // ✨ EDGE-TO-EDGE background
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.35))
                .frame(width: geometry.size.width) // Full screen width
                .edgesIgnoringSafeArea(.horizontal)
            
            // Content with padding (stays in same position)
            HStack(spacing: 16) {
                // Score display
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                    
                    Text("\(gameState.score)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Customers served count
                Text("\(gameState.customersServed)/13")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Debug button (wrench icon)
                Button(action: {
                    showingAssetsDebug = true
                }) {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.cyan)
                }
                .sheet(isPresented: $showingAssetsDebug) {
                    AssetsDebugView(gameState: $gameState, onEndGame: {
                        dismiss()
                    })
                }
            }
            .padding(.horizontal, 28) // ✨ Increased from 16 to maintain position
            .padding(.vertical, 6)
        }
    }
    
    // MARK: - Commentary Area (Blends with Dark Theme)
    
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
    
    // MARK: - Repair Area (Full Width)
    
    private var repairArea: some View {
        VStack(spacing: 6) {
            // Label
            Text("REPAIR AREA")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .tracking(1)
            
            // 4 slots in a horizontal row (spans full width)
            HStack(spacing: 8) {
                ForEach(gameState.repairSlots) { slot in
                    RepairSlotView(slot: slot)
                }
            }
        }
    }
    
    // MARK: - Decks Area (Fanned Arc with Ghost Cards) - ✨ UPDATED
    
    private var decksArea: some View {
        // ✨ REMOVED "COMPONENT DECKS" label
        
        // All 4 decks in ONE horizontal row (fanned arc)
        HStack(spacing: 12) { // ✨ INCREASED spacing from 6 to 12
            // Structural (leftmost, rotated -12°)
            DeckView(
                type: .structural,
                topCard: gameState.topCard(of: .structural),
                cardsRemaining: gameState.cardsRemaining(in: .structural),
                canDraw: gameState.canDraw(from: .structural),
                rotationDegrees: -12,
                onTap: {
                    gameState.drawCard(from: .structural)
                    checkIfRepairReady()
                }
            )
            
            // Enchantment (rotated -4°)
            DeckView(
                type: .enchantment,
                topCard: gameState.topCard(of: .enchantment),
                cardsRemaining: gameState.cardsRemaining(in: .enchantment),
                canDraw: gameState.canDraw(from: .enchantment),
                rotationDegrees: -4,
                onTap: {
                    gameState.drawCard(from: .enchantment)
                    checkIfRepairReady()
                }
            )
            
            // Memory (rotated +4°)
            DeckView(
                type: .memory,
                topCard: gameState.topCard(of: .memory),
                cardsRemaining: gameState.cardsRemaining(in: .memory),
                canDraw: gameState.canDraw(from: .memory),
                rotationDegrees: 4,
                onTap: {
                    gameState.drawCard(from: .memory)
                    checkIfRepairReady()
                }
            )
            
            // Wildcraft (rightmost, rotated +12°)
            DeckView(
                type: .wildcraft,
                topCard: gameState.topCard(of: .wildcraft),
                cardsRemaining: gameState.cardsRemaining(in: .wildcraft),
                canDraw: gameState.canDraw(from: .wildcraft),
                rotationDegrees: 12,
                onTap: {
                    gameState.drawCard(from: .wildcraft)
                    checkIfRepairReady()
                }
            )
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
