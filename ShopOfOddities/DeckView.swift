//
//  DeckView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Deck display with deal animation, flip animation, ghost cards, and drag-and-drop
//  WITH PROGRESSIVE REVEAL SYSTEM
//

import SwiftUI

struct DeckView: View {
    
    // MARK: - ANIMATOR CONTROLS 🎨
    // Adjust these to change the flip animation feel
    
    /// Flip animation total duration (in seconds)
    private let flipDuration: Double = 0.9
    
    /// Flip animation curve - Options: .linear, .easeIn, .easeOut, .easeInOut
    private let flipCurve: Animation = .easeInOut
    
    // END ANIMATOR CONTROLS
    
    let type: ComponentType
    let topCard: ComponentCard?
    let cardsRemaining: Int
    let canDraw: Bool
    let rotationDegrees: Double // Per-deck rotation from config
    let onTap: (Int?) -> Void // Now accepts optional insert index
    
    // MARK: - Animation Binding (from parent)
    
    /// Animation phase controlled by parent view
    @Binding var animationPhase: DeckAnimationPhase
    
    /// Deck index (0-3) for staggered animations
    let deckIndex: Int
    
    /// Trigger ID - when this changes, check if we should flip
    let flipTriggerID: UUID
    
    // MARK: - Drag State (from parent)
    
    /// Binding to the parent's drag state
    @Binding var dragState: DragState?
    
    /// Card frames for drop detection (from parent)
    let repairAreaFrame: CGRect
    
    // MARK: - Local Animation State
    
    @State private var dealOffset: CGFloat = 0 // Y offset for deal animation
    @State private var isFlipping: Bool = false // Flip animation state
    @State private var showingCardBack: Bool = false // True = show card back, False = show card face
    @State private var flipAngle: Double = 0 // Current flip rotation angle
    
    // MARK: - Progressive Reveal State
    
    /// Tracks if current top card has been flipped face-up (for progressive reveal)
    @State private var hasFlippedThisCard: Bool = false
    
    // MARK: - Local Drag State
    
    @State private var isDragging: Bool = false
    @State private var dragOffset: CGSize = .zero
    
    // MARK: - SIZE CONFIGURATION
    
    /// Main card width (adjust this to change deck size)
    private let cardWidth: CGFloat = 90
    
    /// Calculated card height (maintains 0.65 aspect ratio)
    private var cardHeight: CGFloat {
        cardWidth / ShopLayoutConfig.cardAspectRatio
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Deck stack with per-deck rotation applied
            deckStack
                .rotationEffect(.degrees(rotationDegrees), anchor: .bottom)
                .offset(y: dealOffset) // Deal animation offset
            
            // Card count badge (does NOT rotate, stays horizontal)
            Text("\(cardsRemaining)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .onChange(of: animationPhase) { _, newPhase in
            handleAnimationPhaseChange(newPhase)
        }
        .onChange(of: topCard?.id) { _, _ in
            // When card changes (new card revealed), reset flip state to face-down
            if animationPhase == .ready {
                hasFlippedThisCard = false
                showingCardBack = true
                flipAngle = 0 // Start face-down (will flip to 180° when triggered)
                print("🎴 DeckView: New card revealed for \(type.displayName) - now face-down, waiting for triggerFlipAnimation() call")
            }
        }
        .onChange(of: flipTriggerID) { _, _ in
            // When parent triggers flip, check if we have a face-down card that needs flipping
            if animationPhase == .ready && !hasFlippedThisCard && topCard != nil {
                print("🔔 Flip trigger received for \(type.displayName)")
                // Add delay to ensure card has appeared face-down before flipping
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.triggerFlipAnimation()
                }
            }
        }
        .onAppear {
            // Initialize deal offset if animation enabled
            if ShopLayoutConfig.dealAnimationEnabled {
                dealOffset = ShopLayoutConfig.dealStartOffsetY
                showingCardBack = true
                flipAngle = 0
                hasFlippedThisCard = false
            } else {
                // Animations disabled: show cards face-up immediately
                dealOffset = 0
                showingCardBack = false
                flipAngle = 180 // Face-up position
                hasFlippedThisCard = true
            }
        }
    }
    
    // MARK: - Deck Stack
    
    private var deckStack: some View {
        ZStack {
            // Ghost card 2 (furthest back) - Only shown if ghostCardCount >= 2 AND deck has 3+ cards
            if ShopLayoutConfig.ghostCardCount >= 2 && cardsRemaining >= 3 {
                ghostCard(
                    rotation: ShopLayoutConfig.ghostCard2Rotation,
                    offsetX: ShopLayoutConfig.ghostCard2OffsetX,
                    offsetY: ShopLayoutConfig.ghostCard2OffsetY,
                    opacity: ShopLayoutConfig.ghostCard2Opacity
                )
            }
            
            // Ghost card 1 (middle) - Only shown if ghostCardCount >= 1 AND deck has 2+ cards
            if ShopLayoutConfig.ghostCardCount >= 1 && cardsRemaining >= 2 {
                ghostCard(
                    rotation: ShopLayoutConfig.ghostCard1Rotation,
                    offsetX: ShopLayoutConfig.ghostCard1OffsetX,
                    offsetY: ShopLayoutConfig.ghostCard1OffsetY,
                    opacity: ShopLayoutConfig.ghostCard1Opacity
                )
            }
            
            // Top card (front, the actual interactive card)
            topCardView
        }
        .opacity(canDraw && animationPhase == .ready ? 1.0 : (animationPhase == .ready ? 0.5 : 1.0))
    }
    
    // MARK: - Top Card View
    
    @ViewBuilder
    private var topCardView: some View {
        if let card = topCard {
            ZStack {
                // Card back - visible when flipAngle is 0-90°
                cardBackView
                    .rotation3DEffect(
                        .degrees(isDragging ? 0 : flipAngle),
                        axis: (x: 0.0, y: 1.0, z: 0.0),
                        perspective: 0.5
                    )
                    .opacity(isDragging ? 1.0 : (flipAngle < 90 ? 1.0 : 0.0))
                
                // Card face - visible when flipAngle is 90-180°
                cardFaceView(card: card)
                    .rotation3DEffect(
                        .degrees(isDragging ? 0 : flipAngle - 180),
                        axis: (x: 0.0, y: 1.0, z: 0.0),
                        perspective: 0.5
                    )
                    .opacity(isDragging ? 0.0 : (flipAngle > 90 ? 1.0 : 0.0))
            }
            .gesture(
                ShopLayoutConfig.dragEnabled && canDraw && animationPhase == .ready
                ? createDragGesture(for: card)
                : nil
            )
            .onTapGesture {
                if !ShopLayoutConfig.dragEnabled && canDraw && animationPhase == .ready {
                    handleCardTap()
                }
            }
        } else {
            // Empty deck state
            emptyDeckPlaceholder
        }
    }
    
    // MARK: - Progressive Reveal Logic
    
    /// Determines if card should start face-down (for progressive reveal)
    private var shouldShowCardBack: Bool {
        if animationPhase != .ready {
            return showingCardBack
        } else {
            // After opening animation, use progressive reveal logic
            return !hasFlippedThisCard
        }
    }
    
    /// Called when previous card is placed - triggers flip animation
    func triggerFlipAnimation() {
        guard !hasFlippedThisCard else {
            print("🎴 DeckView: Card already flipped for \(type.displayName), skipping")
            return
        }
        
        print("🎴 DeckView: triggerFlipAnimation() called for \(type.displayName)")
        
        // Start from face-down position
        showingCardBack = true
        flipAngle = 0
        
        // Simple one-step animation: rotate from 0° to 180°
        withAnimation(self.flipCurve.speed(1.0 / self.flipDuration)) {
            self.flipAngle = 180
        }
        
        // After animation completes, keep card face-up
        DispatchQueue.main.asyncAfter(deadline: .now() + self.flipDuration) {
            // Don't reset flipAngle - keep it at 180 so card face stays visible
            self.showingCardBack = false
            self.hasFlippedThisCard = true
            print("✅ DeckView: Flip complete for \(self.type.displayName)")
        }
    }
    
    // MARK: - Card Face View
    
    private func cardFaceView(card: ComponentCard) -> some View {
        ComponentCardView(card: card)
            .frame(width: cardWidth, height: cardHeight)
            .shadow(color: type.color.opacity(0.6), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Card Back View
    
    private var cardBackView: some View {
        Group {
            if UIImage(named: ShopLayoutConfig.cardBackImageName) != nil {
                // Use custom card back image if available
                Image(ShopLayoutConfig.cardBackImageName)
                    .resizable()
                    .aspectRatio(ShopLayoutConfig.cardAspectRatio, contentMode: .fill)
                    .frame(width: cardWidth, height: cardHeight)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
            } else {
                // Fallback: solid color gradient card back
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.2, blue: 0.5),
                                Color(red: 0.2, green: 0.1, blue: 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: cardWidth, height: cardHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.purple.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Ghost Card
    
    private func ghostCard(rotation: Double, offsetX: CGFloat, offsetY: CGFloat, opacity: Double) -> some View {
        Group {
            if UIImage(named: ShopLayoutConfig.cardBackImageName) != nil {
                // Use custom card back image if available
                Image(ShopLayoutConfig.cardBackImageName)
                    .resizable()
                    .aspectRatio(ShopLayoutConfig.cardAspectRatio, contentMode: .fill)
                    .frame(width: cardWidth, height: cardHeight)
                    .cornerRadius(8)
                    .rotationEffect(.degrees(rotation), anchor: .bottom)
                    .offset(x: offsetX, y: offsetY)
                    .opacity(opacity)
                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
            } else {
                // Fallback: solid color gradient card back
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.2, blue: 0.5),
                                Color(red: 0.2, green: 0.1, blue: 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: cardWidth, height: cardHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.purple.opacity(0.5), lineWidth: 2)
                    )
                    .rotationEffect(.degrees(rotation), anchor: .bottom)
                    .offset(x: offsetX, y: offsetY)
                    .opacity(opacity)
                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Empty Deck Placeholder
    
    private var emptyDeckPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: cardWidth, height: cardHeight)
            .overlay(
                Text("EMPTY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            )
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Drag Gesture
    
    private func createDragGesture(for card: ComponentCard) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    dragState = DragState(
                        card: card,
                        deckType: type,
                        startPosition: value.startLocation,
                        currentPosition: value.location,
                        hoverInsertIndex: nil // Will be calculated below
                    )
                } else {
                    // Update current position
                    dragState?.currentPosition = value.location
                    // hoverInsertIndex is calculated and updated by parent (ShopOfOdditiesView)
                }
                dragOffset = value.translation
            }
            .onEnded { value in
                let endPosition = value.location
                
                // Check if dropped over repair area
                if repairAreaFrame.contains(endPosition) {
                    // Snap to slot
                    handleCardSnap()
                } else {
                    // Return to deck
                    handleCardReturn()
                }
                
                isDragging = false
                dragState = nil
                dragOffset = .zero
            }
    }
    
    // MARK: - Drag Handlers
    
    private func handleCardSnap() {
        // Trigger the draw with insert index from dragState
        let insertIndex = dragState?.hoverInsertIndex
        print("🎯 handleCardSnap - insertIndex: \(insertIndex ?? -1)")
        onTap(insertIndex)
    }
    
    private func handleCardReturn() {
        // Card returns to deck, nothing happens
        withAnimation(.spring(response: ShopLayoutConfig.returnAnimationDuration, dampingFraction: 0.7)) {
            dragOffset = .zero
        }
    }
    
    // MARK: - Animation Handlers
    
    /// Handle animation phase changes from parent
    private func handleAnimationPhaseChange(_ phase: DeckAnimationPhase) {
        switch phase {
        case .dealing:
            startDealAnimation()
        case .flipping:
            startFlipAnimation()
        case .ready:
            // Mark opening animation complete
            hasFlippedThisCard = true
            break
        }
    }
    
    /// Start deal animation (slide up from below)
    private func startDealAnimation() {
        guard ShopLayoutConfig.dealAnimationEnabled else {
            // Skip animation, go straight to final position
            dealOffset = 0
            return
        }
        
        // Calculate staggered delay based on deck index
        let delay = Double(deckIndex) * ShopLayoutConfig.dealStaggerDelay
        
        // Start from below screen
        dealOffset = ShopLayoutConfig.dealStartOffsetY
        
        // Animate to final position after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeOut(duration: ShopLayoutConfig.dealAnimationDuration)) {
                dealOffset = 0
            }
        }
    }
    
    /// Start flip animation (face-down to face-up) - OPENING ANIMATION ONLY
    private func startFlipAnimation() {
        guard ShopLayoutConfig.flipAnimationEnabled else {
            // Skip animation, show face immediately
            showingCardBack = false
            flipAngle = 180 // Face-up position
            hasFlippedThisCard = true
            return
        }
        
        // Calculate staggered delay based on deck index
        let delay = Double(deckIndex) * ShopLayoutConfig.flipStaggerDelay
        
        // Start with card back showing
        showingCardBack = true
        flipAngle = 0
        
        // Simple one-step animation: rotate from 0° to 180°
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(self.flipCurve.speed(1.0 / ShopLayoutConfig.flipAnimationDuration)) {
                self.flipAngle = 180
            }
            
            // After animation completes, keep card face-up
            DispatchQueue.main.asyncAfter(deadline: .now() + ShopLayoutConfig.flipAnimationDuration) {
                // Don't reset flipAngle - keep it at 180 so card face stays visible
                self.showingCardBack = false
                self.hasFlippedThisCard = true
            }
        }
    }
    
    /// Handle card tap (existing draw behavior)
    private func handleCardTap() {
        if ShopLayoutConfig.flipOnEveryDraw {
            // Show flip animation on every draw
            showingCardBack = true
            flipAngle = 0
            
            // First half: flip to 90°
            withAnimation(.linear(duration: 0.15)) {
                flipAngle = 90
            }
            
            // At 90°, call onTap and swap to new card
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onTap(nil) // Tap always appends (no insert index)
                showingCardBack = false
                
                // Second half: flip to 180°
                withAnimation(.linear(duration: 0.15)) {
                    flipAngle = 180
                }
                
                // Reset angle
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    flipAngle = 0
                }
            }
        } else {
            // Normal draw behavior (no flip animation)
            onTap(nil) // Tap always appends (no insert index)
        }
    }
}

// MARK: - Drag State Model

/// Tracks the current drag operation
struct DragState: Equatable {
    let card: ComponentCard
    let deckType: ComponentType
    var startPosition: CGPoint
    var currentPosition: CGPoint
    var hoverInsertIndex: Int? // Which position the card will be inserted at (nil = not over repair area)
}

// MARK: - Animation Phase Enum

/// Tracks which animation phase the deck is in
enum DeckAnimationPhase {
    case dealing    // Cards sliding into position
    case flipping   // Cards flipping face-up
    case ready      // Animations complete, ready for gameplay
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 40) {
            // Preview with 3+ cards (both ghost cards visible)
            DeckView(
                type: .structural,
                topCard: ComponentCard(
                    type: .structural,
                    value: 3,
                    isCursed: false,
                    adjacencyBonus: nil,
                    name: "Oak Plank"
                ),
                cardsRemaining: 5,
                canDraw: true,
                rotationDegrees: 0,
                onTap: { _ in print("Tapped structural deck") },
                animationPhase: .constant(.ready),
                deckIndex: 0,
                flipTriggerID: UUID(),
                dragState: .constant(nil),
                repairAreaFrame: .zero
            )
            
            // Preview with 2 cards (one ghost card)
            DeckView(
                type: .enchantment,
                topCard: ComponentCard(
                    type: .enchantment,
                    value: 2,
                    isCursed: false,
                    adjacencyBonus: nil,
                    name: "Arcane Dust"
                ),
                cardsRemaining: 2,
                canDraw: true,
                rotationDegrees: 0,
                onTap: { _ in print("Tapped enchantment deck") },
                animationPhase: .constant(.ready),
                deckIndex: 1,
                flipTriggerID: UUID(),
                dragState: .constant(nil),
                repairAreaFrame: .zero
            )
            
            // Preview with 1 card (no ghost cards)
            DeckView(
                type: .memory,
                topCard: ComponentCard(
                    type: .memory,
                    value: 1,
                    isCursed: false,
                    adjacencyBonus: nil,
                    name: "Whispered Echo"
                ),
                cardsRemaining: 1,
                canDraw: true,
                rotationDegrees: 0,
                onTap: { _ in print("Tapped memory deck") },
                animationPhase: .constant(.ready),
                deckIndex: 2,
                flipTriggerID: UUID(),
                dragState: .constant(nil),
                repairAreaFrame: .zero
            )
            
            // Preview empty deck
            DeckView(
                type: .wildcraft,
                topCard: nil,
                cardsRemaining: 0,
                canDraw: false,
                rotationDegrees: 0,
                onTap: { _ in print("Empty deck tapped") },
                animationPhase: .constant(.ready),
                deckIndex: 3,
                flipTriggerID: UUID(),
                dragState: .constant(nil),
                repairAreaFrame: .zero
            )
        }
        .padding()
    }
}
