//
//  ComponentCardView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Visual rendering for a single component card
//

import SwiftUI

struct ComponentCardView: View {
    
    let card: ComponentCard
    let compact: Bool // If true, use smaller layout (for deck display)
    
    init(card: ComponentCard, compact: Bool = false) {
        self.card = card
        self.compact = compact
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // ✨ Card background IMAGE - Uses cursed variant if card is cursed!
                Image(cardBackgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .cornerRadius(compact ? 6 : 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: compact ? 6 : 10)
                            .stroke(card.isCursed ? Color.red.opacity(0.8) : card.type.darkColor, lineWidth: compact ? 2 : 3)
                    )
                
                VStack(spacing: compact ? 2 : 4) {
                    // Type icon (top) - uses custom icon image
                    Image(card.type.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: compact ? 10 : 14, height: compact ? 10 : 14)
                        .foregroundColor(card.type.darkColor)
                    
                    Spacer()
                    
                    // Value (large center)
                    Text(card.displayValue)
                        .font(.system(size: compact ? 20 : 32, weight: .bold, design: .rounded))
                        .foregroundColor(card.isCursed ? .red : .white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 2)
                    
                    Spacer()
                    
                    // Card name (bottom)
                    Text(card.name)
                        .font(.system(size: compact ? 6 : 9, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 2)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 1)
                    
                    // Adjacency bonus icon (if present)
                    if let adjacencyType = card.adjacencyBonus {
                        HStack(spacing: 2) {
                            Image(adjacencyType.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: compact ? 6 : 8, height: compact ? 6 : 8)
                                .foregroundColor(adjacencyType.color)
                            
                            Text("+2")
                                .font(.system(size: compact ? 6 : 8, weight: .semibold))
                                .foregroundColor(.green)
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 1)
                        }
                    } else {
                        // Placeholder to maintain consistent height
                        Text(" ")
                            .font(.system(size: compact ? 6 : 8))
                    }
                }
                .padding(.vertical, compact ? 4 : 8)
                .padding(.horizontal, compact ? 2 : 4)
            }
        }
        .aspectRatio(0.65, contentMode: .fit) // Card-like proportions
    }
    
    // MARK: - Computed Properties
    
    /// Returns the appropriate background image name
    /// Uses "card-cursed" for cursed cards, otherwise uses the component type's image
    private var cardBackgroundImageName: String {
        if card.isCursed {
            return "card-cursed"
        } else {
            return card.type.cardImageName
        }
    }
}

// MARK: - Preview

#Preview("Normal Card") {
    ComponentCardView(
        card: ComponentCard(
            type: .structural,
            value: 3,
            isCursed: false,
            adjacencyBonus: .enchantment,
            name: "Oak Plank"
        )
    )
    .frame(width: 80, height: 120)
    .padding()
    .background(Color.gray.opacity(0.2))
}

#Preview("Cursed Card") {
    ComponentCardView(
        card: ComponentCard(
            type: .enchantment,
            value: -2,
            isCursed: true,
            adjacencyBonus: nil,
            name: "Corrupted Spell"
        )
    )
    .frame(width: 80, height: 120)
    .padding()
    .background(Color.gray.opacity(0.2))
}

#Preview("Compact Card") {
    ComponentCardView(
        card: ComponentCard(
            type: .memory,
            value: 4,
            isCursed: false,
            adjacencyBonus: .wildcraft,
            name: "Cherished Memory"
        ),
        compact: true
    )
    .frame(width: 60, height: 90)
    .padding()
    .background(Color.gray.opacity(0.2))
}
