//
//  DeckView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Visual rendering for a component deck with tap interaction
//

import SwiftUI

struct DeckView: View {
    
    let type: ComponentType
    let topCard: ComponentCard?
    let cardsRemaining: Int
    let canDraw: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if canDraw {
                onTap()
            }
        }) {
            // ✨ JUST THE CARD IMAGE - NO HEADER!
            if let card = topCard {
                ComponentCardView(card: card, compact: true)
                    .opacity(canDraw ? 1.0 : 0.5)
                    .cornerRadius(8)
                    .shadow(color: type.color.opacity(canDraw ? 0.5 : 0.2), radius: canDraw ? 8 : 4)
            } else {
                // Empty deck
                emptyDeckPlaceholder
            }
        }
        .buttonStyle(DeckButtonStyle())
        .disabled(!canDraw)
    }
    
    // MARK: - Empty Deck Placeholder
    
    private var emptyDeckPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.black.opacity(0.4))
            .aspectRatio(0.65, contentMode: .fit)
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("Empty")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
            )
    }
}

// MARK: - Custom Button Style

struct DeckButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Deck with Cards") {
    DeckView(
        type: .structural,
        topCard: ComponentCard(
            type: .structural,
            value: 3,
            isCursed: false,
            adjacencyBonus: .enchantment,
            name: "Oak Plank"
        ),
        cardsRemaining: 10,
        canDraw: true,
        onTap: {
            print("Tapped Structural deck")
        }
    )
    .frame(width: 150, height: 230)
    .padding()
    .background(Color.gray.opacity(0.3))
}

#Preview("Empty Deck") {
    DeckView(
        type: .enchantment,
        topCard: nil,
        cardsRemaining: 0,
        canDraw: false,
        onTap: {
            print("Tapped empty deck")
        }
    )
    .frame(width: 150, height: 230)
    .padding()
    .background(Color.gray.opacity(0.3))
}

#Preview("Deck Cannot Draw") {
    DeckView(
        type: .memory,
        topCard: ComponentCard(
            type: .memory,
            value: 2,
            isCursed: false,
            adjacencyBonus: nil,
            name: "Whispered Echo"
        ),
        cardsRemaining: 8,
        canDraw: false,
        onTap: {
            print("Tapped Memory deck")
        }
    )
    .frame(width: 150, height: 230)
    .padding()
    .background(Color.gray.opacity(0.3))
}
