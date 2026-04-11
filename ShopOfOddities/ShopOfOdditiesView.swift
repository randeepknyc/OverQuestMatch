//
//  ShopOfOdditiesView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Main game screen for Ednar's Shop of Oddities card repair game with drag-and-drop
//

import SwiftUI
import UIKit

struct ShopOfOdditiesView: View {
    
    @State private var gameState = ShopGameState()
    @State private var repairsDiscoveredBeforeGame: Set<String> = []
    @State private var showingAssetsDebug = false
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Animation State
    
    @State private var animationPhase: DeckAnimationPhase = .ready
    
    // MARK: - Drag State
    
    @State private var dragState: DragState? = nil
    @State private var repairAreaFrame: CGRect = .zero
    @State private var flipTriggerID: UUID = UUID()
    @State private var deckToFlip: ComponentType? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // FULL-SCREEN BACKGROUND (behind everything)
                backgroundLayer
                
                VStack(spacing: 0) {
                    // 1. SCORE BAR (5% height) - Semi-transparent HUD overlay
                    scoreBar(geometry: geometry)
                        .frame(height: geometry.size.height * ShopLayoutConfig.scoreBarHeight)
                    
                    // 2. SCENE VIEW (46.2% height) - Full width composite
                    if let customer = gameState.currentCustomer {
                        ShopSceneView(customer: customer)
                            .frame(height: geometry.size.height * ShopLayoutConfig.sceneHeight)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, ShopLayoutConfig.horizontalPadding)
                    }
                    
                    // 3. COMMENTARY AREA (17pt fixed) - Character dialogue
                    commentaryArea
                        .frame(height: ShopLayoutConfig.commentaryIsFixedPoints
                               ? ShopLayoutConfig.commentaryHeight
                               : geometry.size.height * ShopLayoutConfig.commentaryHeight)
                        .padding(.horizontal, ShopLayoutConfig.horizontalPadding)
                    
                    // 4. COUNTER / REPAIR AREA (dynamic height based on card size)
                    counterRepairArea(geometry: geometry)
                    
                    // 5. GAP BETWEEN COUNTER AND DECKS
                    Spacer()
                        .frame(height: ShopLayoutConfig.gapCounterToDecks)
                    
                    // 6. DECKS AREA (fills remaining space)
                    decksArea(geometry: geometry)
                    
                    // 7. BOTTOM PADDING
                    Spacer()
                        .frame(height: ShopLayoutConfig.deckBottomPadding)
                }
                
                // DRAG OVERLAY (card being dragged renders on top)
                if let drag = dragState, let card = drag.card as ComponentCard? {
                    dragOverlay(card: card, position: drag.currentPosition)
                        .zIndex(5)
                }
                
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
                            
                            // Reset animations for new game
                            resetAnimations()
                        }
                    )
                    .zIndex(12)
                }
            }
        }
        .onAppear {
            // Track repairs known before this game started
            repairsDiscoveredBeforeGame = gameState.discoveredRepairNames
            
            // Start opening animations
            startOpeningAnimations()
        }
        .onChange(of: dragState?.currentPosition) { oldValue, newValue in
            // Update hover insert index when drag position changes
            guard let drag = dragState, let position = newValue else { return }
            
            let placedCards = gameState.repairSlots.cards
            let availableWidth = UIScreen.main.bounds.width
            let totalHorizontalPadding = ShopLayoutConfig.horizontalPadding * 2
            let totalCardSpacing = ShopLayoutConfig.repairCardSpacing * 3
            let cardWidth = (availableWidth - totalHorizontalPadding - totalCardSpacing) / 4
            
            let index = RepairSlotView.calculateInsertIndex(
                dragPosition: position,
                repairAreaFrame: repairAreaFrame,
                placedCardsCount: placedCards.count,
                cardWidth: cardWidth
            )
            
            if index != drag.hoverInsertIndex {
                dragState?.hoverInsertIndex = index
                print("✅ Updated dragState.hoverInsertIndex to: \(index ?? -1)")
            }
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
    
    // MARK: - Score Bar (Edge-to-Edge Semi-Transparent HUD)
    
    private func scoreBar(geometry: GeometryProxy) -> some View {
        ZStack {
            // Background extends full screen width
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(ShopLayoutConfig.scoreBarOpacity))
                .frame(width: geometry.size.width)
                .edgesIgnoringSafeArea(.horizontal)
            
            // Content with padding (text stays centered)
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
            .padding(.horizontal, ShopLayoutConfig.scoreBarTextPadding)
        }
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
    
    // MARK: - Counter / Repair Area (Counter Surface Style)
    
    private func counterRepairArea(geometry: GeometryProxy) -> some View {
        // Calculate card dimensions
        let availableWidth = geometry.size.width
        let totalHorizontalPadding = ShopLayoutConfig.horizontalPadding * 2
        let totalCardSpacing = ShopLayoutConfig.repairCardSpacing * 3 // 3 gaps between 4 cards
        let cardWidth = (availableWidth - totalHorizontalPadding - totalCardSpacing) / 4
        let cardHeight = cardWidth / ShopLayoutConfig.cardAspectRatio
        
        let counterHeight = ShopLayoutConfig.counterPaddingTop + cardHeight + ShopLayoutConfig.counterPaddingBottom
        
        // Get placed cards (convert from slots)
        let placedCards = gameState.repairSlots.cards
        
        // Calculate hover insert index based on drag position (for preview only)
        // The actual value is updated by the .onChange handler
        let hoverInsertIndex = dragState?.hoverInsertIndex
        
        return ZStack {
            // Counter surface background (warm brown with ledge lines)
            VStack(spacing: 0) {
                // Top ledge line
                Rectangle()
                    .fill(Color.brown.opacity(ShopLayoutConfig.counterLedgeOpacity))
                    .frame(height: 1.5)
                
                // Counter surface
                ShopLayoutConfig.counterSurfaceColor
                    .opacity(ShopLayoutConfig.counterSurfaceOpacity)
                
                // Bottom ledge line
                Rectangle()
                    .fill(Color.brown.opacity(ShopLayoutConfig.counterBottomLedgeOpacity))
                    .frame(height: 1.5)
            }
            
            // Repair slot view with centered cards
            RepairSlotView(
                placedCards: placedCards,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                previewInsertIndex: hoverInsertIndex, // Pass the calculated insert index
                draggedCard: nil // No preview card (just slide existing cards)
            )
            .padding(.horizontal, ShopLayoutConfig.horizontalPadding)
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        repairAreaFrame = geo.frame(in: .global)
                    }
                    .onChange(of: geo.frame(in: .global)) { _, newFrame in
                        repairAreaFrame = newFrame
                    }
                }
            )
        }
        .frame(height: counterHeight)
    }
    
    // MARK: - Decks Area (Horizontal Row with Config-Based Rotation)
    
    private func decksArea(geometry: GeometryProxy) -> some View {
        // Calculate card dimensions
        let availableWidth = geometry.size.width
        let totalHorizontalPadding = ShopLayoutConfig.horizontalPadding * 2
        let totalCardSpacing = ShopLayoutConfig.deckCardSpacing * 3 // 3 gaps between 4 cards
        let cardWidth = (availableWidth - totalHorizontalPadding - totalCardSpacing) / 4
        let cardHeight = cardWidth / ShopLayoutConfig.cardAspectRatio
        
        return HStack(spacing: ShopLayoutConfig.deckCardSpacing) {
            // Structural (index 0)
            DeckView(
                type: .structural,
                topCard: gameState.topCard(of: .structural),
                cardsRemaining: gameState.cardsRemaining(in: .structural),
                canDraw: gameState.canDraw(from: .structural),
                rotationDegrees: ShopLayoutConfig.deckRotations[0],
                onTap: { insertIndex in
                    gameState.drawCard(from: .structural, insertAt: insertIndex)
                    flipTriggerID = UUID() // Trigger all decks to check if they need to flip
                    checkIfRepairReady()
                },
                animationPhase: $animationPhase,
                deckIndex: 0,
                flipTriggerID: flipTriggerID,
                dragState: $dragState,
                repairAreaFrame: repairAreaFrame
            )
            .frame(width: cardWidth, height: cardHeight)
            
            // Enchantment (index 1)
            DeckView(
                type: .enchantment,
                topCard: gameState.topCard(of: .enchantment),
                cardsRemaining: gameState.cardsRemaining(in: .enchantment),
                canDraw: gameState.canDraw(from: .enchantment),
                rotationDegrees: ShopLayoutConfig.deckRotations[1],
                onTap: { insertIndex in
                    gameState.drawCard(from: .enchantment, insertAt: insertIndex)
                    flipTriggerID = UUID() // Trigger all decks to check if they need to flip
                    checkIfRepairReady()
                },
                animationPhase: $animationPhase,
                deckIndex: 1,
                flipTriggerID: flipTriggerID,
                dragState: $dragState,
                repairAreaFrame: repairAreaFrame
            )
            .frame(width: cardWidth, height: cardHeight)
            
            // Memory (index 2)
            DeckView(
                type: .memory,
                topCard: gameState.topCard(of: .memory),
                cardsRemaining: gameState.cardsRemaining(in: .memory),
                canDraw: gameState.canDraw(from: .memory),
                rotationDegrees: ShopLayoutConfig.deckRotations[2],
                onTap: { insertIndex in
                    gameState.drawCard(from: .memory, insertAt: insertIndex)
                    flipTriggerID = UUID() // Trigger all decks to check if they need to flip
                    checkIfRepairReady()
                },
                animationPhase: $animationPhase,
                deckIndex: 2,
                flipTriggerID: flipTriggerID,
                dragState: $dragState,
                repairAreaFrame: repairAreaFrame
            )
            .frame(width: cardWidth, height: cardHeight)
            
            // Wildcraft (index 3)
            DeckView(
                type: .wildcraft,
                topCard: gameState.topCard(of: .wildcraft),
                cardsRemaining: gameState.cardsRemaining(in: .wildcraft),
                canDraw: gameState.canDraw(from: .wildcraft),
                rotationDegrees: ShopLayoutConfig.deckRotations[3],
                onTap: { insertIndex in
                    gameState.drawCard(from: .wildcraft, insertAt: insertIndex)
                    flipTriggerID = UUID() // Trigger all decks to check if they need to flip
                    checkIfRepairReady()
                },
                animationPhase: $animationPhase,
                deckIndex: 3,
                flipTriggerID: flipTriggerID,
                dragState: $dragState,
                repairAreaFrame: repairAreaFrame
            )
            .frame(width: cardWidth, height: cardHeight)
                    }
                    .padding(.horizontal, ShopLayoutConfig.horizontalPadding)
                }
    
    // MARK: - Drag Overlay
    
    private func dragOverlay(card: ComponentCard, position: CGPoint) -> some View {
        ComponentCardView(card: card, compact: false)
            .frame(width: 90, height: 90 / ShopLayoutConfig.cardAspectRatio)
            .scaleEffect(ShopLayoutConfig.dragScaleWhileDragging)
            .opacity(ShopLayoutConfig.dragOpacityWhileDragging)
            .shadow(color: card.type.color.opacity(0.8), radius: 12, x: 0, y: 6)
            .position(position)
            .allowsHitTesting(false)
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
    
    // MARK: - Animation Management
    
    /// Start opening animations (deal → flip → ready)
    private func startOpeningAnimations() {
        // If animations are disabled, stay in ready
        if !ShopLayoutConfig.dealAnimationEnabled && !ShopLayoutConfig.flipAnimationEnabled {
            animationPhase = .ready
            return
        }
        
        // Small delay, then start dealing phase
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.animationPhase = .dealing
            
            // Calculate total deal time (all 4 cards: 3 delays + 1 duration)
            let totalDealTime = (ShopLayoutConfig.dealStaggerDelay * 3) + ShopLayoutConfig.dealAnimationDuration
            
            // After dealing completes, wait, then start flipping
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDealTime + ShopLayoutConfig.flipDelayAfterDeal) {
                self.animationPhase = .flipping
                
                // Calculate total flip time (all 4 cards: 3 delays + 1 full flip)
                let totalFlipTime = (ShopLayoutConfig.flipStaggerDelay * 3) + ShopLayoutConfig.flipAnimationDuration
                
                // After flipping completes, mark as ready
                DispatchQueue.main.asyncAfter(deadline: .now() + totalFlipTime) {
                    self.animationPhase = .ready
                }
            }
        }
    }
    
    /// Reset animations (called on Play Again)
    private func resetAnimations() {
        animationPhase = .dealing
        startOpeningAnimations()
    }
}

// MARK: - Preview

#Preview {
    ShopOfOdditiesView()
}
