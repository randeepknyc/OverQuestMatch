//
//  DeckView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Deck display with top card preview (ghost cards + flip animation - NO ROTATION)
//

import SwiftUI

struct DeckView: View {
    
    let type: ComponentType
    let topCard: ComponentCard?
    let cardsRemaining: Int
    let canDraw: Bool
    let rotationDegrees: Double // ← Keep parameter for backward compatibility (not used)
    let onTap: () -> Void
    
    // MARK: - Animation State
    
    @State private var isFlipping: Bool = false
    
    // MARK: - SIZE CONFIGURATION (Easy to adjust!)
    
    /// Main card width (adjust this to change deck size)
    private let cardWidth: CGFloat = 90  // ← CHANGE THIS to make cards bigger/smaller
    
    /// Calculated card height (maintains 0.65 aspect ratio)
    private var cardHeight: CGFloat {
        cardWidth / 0.65
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Deck stack (NO rotation applied - straight horizontal row)
            deckStack
            
            // Card count (stays horizontal)
            Text("\(cardsRemaining)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    // MARK: - Deck Stack
    
    private var deckStack: some View {
        ZStack {
            // Ghost card 2 (furthest back, only if 3+ cards)
            if cardsRemaining >= 3 {
                cardBackStack(rotation: -2.5, offsetX: -3, offsetY: -5)
            }
            
            // Ghost card 1 (middle, only if 2+ cards)
            if cardsRemaining >= 2 {
                cardBackStack(rotation: -1.2, offsetX: -1.5, offsetY: -2.5)
            }
            
            // Top card (front, the actual interactive card)
            if let card = topCard {
                ComponentCardView(card: card)
                    .frame(width: cardWidth, height: cardHeight)
                    .shadow(color: type.color.opacity(0.6), radius: 8, x: 0, y: 4)
                    .rotation3DEffect(
                        .degrees(isFlipping ? 90 : 0), // Flip to 90° (edge-on)
                        axis: (x: 0.0, y: 1.0, z: 0.0), // Flip around Y-axis (horizontal flip)
                        perspective: 0.5
                    )
                    .opacity(isFlipping ? 0.0 : 1.0) // Fade out when flipping
            } else {
                // Empty deck state
                emptyDeckPlaceholder
            }
        }
        .opacity(canDraw ? 1.0 : 0.5)
        .onTapGesture {
            if canDraw {
                // Trigger flip animation
                withAnimation(.easeIn(duration: 0.15)) {
                    isFlipping = true
                }
                
                // Call onTap callback after half the flip
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    onTap()
                    
                    // Reset flip state (new card will appear)
                    isFlipping = false
                }
            }
        }
    }
    
    // MARK: - Card Back Stack (Visual Stack Behind Cards)
    
    /// Creates a card back visual showing a stack of cards behind the top card
    /// Uses the custom card-background.png image for all decks
    /// Ghost cards keep their slight rotation for visual depth
    private func cardBackStack(rotation: Double, offsetX: CGFloat, offsetY: CGFloat) -> some View {
        Image("card-background")
            .resizable()
            .aspectRatio(0.65, contentMode: .fill)
            .frame(width: cardWidth, height: cardHeight)
            .cornerRadius(8)
            .rotationEffect(.degrees(rotation), anchor: .bottom) // ← Ghost cards still rotate
            .offset(x: offsetX, y: offsetY)
            .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
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
                rotationDegrees: 0, // ← No longer used
                onTap: { print("Tapped structural deck") }
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
                rotationDegrees: 0, // ← No longer used
                onTap: { print("Tapped enchantment deck") }
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
                rotationDegrees: 0, // ← No longer used
                onTap: { print("Tapped memory deck") }
            )
            
            // Preview empty deck
            DeckView(
                type: .wildcraft,
                topCard: nil,
                cardsRemaining: 0,
                canDraw: false,
                rotationDegrees: 0, // ← No longer used
                onTap: { print("Empty deck tapped") }
            )
        }
        .padding()
    }
}
