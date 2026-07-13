//
//  RepairSlotView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Dynamic repair slot view with centered card arrangement and drag preview
//  Updated: Smooth card rearrangement with center bias
//

import SwiftUI

struct RepairSlotView: View {
    
    let placedCards: [ComponentCard] // Ordered array of placed cards (left to right)
    let cardWidth: CGFloat // Size for placed cards (smaller than deck cards)
    let cardHeight: CGFloat
    let previewInsertIndex: Int? // Where the dragged card will go (nil if not dragging over)
    let draggedCard: ComponentCard? // The card currently being dragged (for preview)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Counter surface background (always visible)
                RoundedRectangle(cornerRadius: ShopLayoutConfig.counterCornerRadius)
                    .fill(Color.black.opacity(ShopLayoutConfig.counterBackgroundOpacity))
                
                // Placed cards (centered as a group)
                cardsDisplay(in: geometry)
            }
            .background(
                // Capture frame for drop detection
                GeometryReader { geo in
                    Color.clear
                        .preference(key: RepairAreaFrameKey.self, value: geo.frame(in: .global))
                }
            )
        }
    }
    
    // MARK: - Cards Display
    
    @ViewBuilder
    private func cardsDisplay(in geometry: GeometryProxy) -> some View {
        let cards = calculateCardPositions(in: geometry)
        
        ZStack {
            // Changed: Use card.id instead of index so SwiftUI can track and animate each card
            ForEach(cards, id: \.card.id) { item in
                ComponentCardView(card: item.card)
                    .frame(width: cardWidth, height: cardHeight)
                    .shadow(color: item.card.type.color.opacity(0.6), radius: 8, x: 0, y: 4)
                    .position(x: item.position, y: geometry.size.height / 2)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: ShopLayoutConfig.snapAnimationDuration, dampingFraction: 0.7), value: placedCards.count)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: previewInsertIndex)
    }
    
    // MARK: - Card Position Calculation
    
    private struct CardPosition {
        let card: ComponentCard
        let index: Int
        let position: CGFloat // X position
    }
    
    private func calculateCardPositions(in geometry: GeometryProxy) -> [CardPosition] {
        let totalWidth = geometry.size.width
        let centerX = totalWidth / 2
        
        // Create a conceptual array that includes space for the dragged card (if hovering)
        // but we won't actually render the dragged card (user wants no preview)
        let cardCount: Int
        var placedCardsWithGap: [ComponentCard?] = placedCards.map { $0 as ComponentCard? }
        
        if let insertIndex = previewInsertIndex {
            // Insert a nil placeholder at the hover position to create a gap
            placedCardsWithGap.insert(nil, at: min(insertIndex, placedCardsWithGap.count))
            cardCount = placedCardsWithGap.count
        } else {
            cardCount = placedCards.count
        }
        
        guard cardCount > 0 else { return [] }
        
        // Calculate total width needed for all cards (including gap if hovering)
        let spacing = ShopLayoutConfig.repairCardSpacing
        let totalCardsWidth = CGFloat(cardCount) * cardWidth + CGFloat(cardCount - 1) * spacing
        
        // Calculate starting X position (left edge of first card)
        let startX = centerX - (totalCardsWidth / 2) + (cardWidth / 2)
        
        // Create positions for each REAL card (skip nil placeholders)
        var positions: [CardPosition] = []
        var visualIndex = 0 // Track visual position including gaps
        
        for cardOrNil in placedCardsWithGap {
            if let card = cardOrNil {
                let xPosition = startX + CGFloat(visualIndex) * (cardWidth + spacing)
                
                positions.append(CardPosition(
                    card: card,
                    index: visualIndex,
                    position: xPosition
                ))
            }
            visualIndex += 1
        }
        
        return positions
    }
    
    // MARK: - Insert Index Calculation
    
    /// Calculate which index a card should be inserted at based on drag X position
    /// Returns nil if not over repair area, or the insert index (0-4)
    static func calculateInsertIndex(
        dragPosition: CGPoint,
        repairAreaFrame: CGRect,
        placedCardsCount: Int,
        cardWidth: CGFloat
    ) -> Int? {
        // Check if drag position is within repair area bounds
        guard repairAreaFrame.contains(dragPosition) else {
            return nil
        }
        
        // If no cards placed yet, insert at position 0
        guard placedCardsCount > 0 else {
            return 0
        }
        
        // If all 4 slots filled, cannot insert
        guard placedCardsCount < 4 else {
            return nil
        }
        
        // Calculate relative X position within repair area
        let relativeX = dragPosition.x - repairAreaFrame.minX
        let repairWidth = repairAreaFrame.width
        let centerX = repairWidth / 2
        
        // Calculate card positions (same logic as calculateCardPositions)
        let spacing = ShopLayoutConfig.repairCardSpacing
        let totalCardsWidth = CGFloat(placedCardsCount) * cardWidth + CGFloat(placedCardsCount - 1) * spacing
        let startX = centerX - (totalCardsWidth / 2)
        
        // Calculate gaps between cards
        // If relativeX is less than first card center, insert at 0
        // If relativeX is between card N and N+1, insert at N+1
        // If relativeX is after last card, insert at end
        
        for i in 0...placedCardsCount {
            let gapX: CGFloat
            
            if i == 0 {
                // Before first card - use left edge as threshold
                gapX = startX + (cardWidth / 2)
            } else if i == placedCardsCount {
                // After last card - use right edge as threshold
                gapX = startX + CGFloat(i - 1) * (cardWidth + spacing) + (cardWidth / 2)
            } else {
                // Between cards - use midpoint between adjacent cards
                let leftCardRight = startX + CGFloat(i - 1) * (cardWidth + spacing) + cardWidth
                let rightCardLeft = startX + CGFloat(i) * (cardWidth + spacing)
                gapX = (leftCardRight + rightCardLeft) / 2
            }
            
            // Check which side of this threshold we're on
            if i == 0 && relativeX < gapX {
                return 0
            } else if i == placedCardsCount && relativeX > gapX {
                return placedCardsCount
            } else if i > 0 && i < placedCardsCount {
                let prevGapX = startX + CGFloat(i - 1) * (cardWidth + spacing) + (cardWidth / 2)
                if relativeX >= prevGapX && relativeX < gapX {
                    return i
                }
            }
        }
        
        // Default: insert at end
        return placedCardsCount
    }
}

// MARK: - Preference Key for Frame

struct RepairAreaFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
