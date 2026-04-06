//
//  RepairSlotView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Visual rendering for a repair slot (empty or filled)
//

import SwiftUI

struct RepairSlotView: View {
    
    let slot: RepairSlot
    @State private var showCard: Bool = false
    
    var body: some View {
        ZStack {
            if let card = slot.card {
                // FILLED STATE: Just show the card image (no box!)
                ComponentCardView(card: card, compact: false)
                    .scaleEffect(showCard ? 1.0 : 0.5)
                    .opacity(showCard ? 1.0 : 0.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCard)
                    .cornerRadius(8)
                    .onAppear {
                        showCard = true
                    }
            } else {
                // EMPTY STATE: Invisible placeholder (maintains spacing)
                Color.clear
                    .aspectRatio(0.65, contentMode: .fit)
                    .onAppear {
                        showCard = false
                    }
            }
        }
    }
}

// MARK: - Preview

#Preview("Empty Slot") {
    RepairSlotView(
        slot: RepairSlot(index: 0)
    )
    .frame(width: 80, height: 120)
    .padding()
    .background(Color.gray.opacity(0.3))
}

#Preview("Filled Slot") {
    RepairSlotView(
        slot: RepairSlot(
            index: 1,
            card: ComponentCard(
                type: .enchantment,
                value: 3,
                isCursed: false,
                adjacencyBonus: .structural,
                name: "Arcane Dust"
            )
        )
    )
    .frame(width: 80, height: 120)
    .padding()
    .background(Color.gray.opacity(0.3))
}
