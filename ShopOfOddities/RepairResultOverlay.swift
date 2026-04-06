//
//  RepairResultOverlay.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Popup showing repair completion result
//

import SwiftUI

struct RepairResultOverlay: View {
    
    let result: RepairResult
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Result card
            VStack(spacing: 16) {
                // Success icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                // Repair name
                Text(result.repairName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Score earned
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                    
                    Text("+\(result.totalScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                    
                    Text("points")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Customer satisfied line
                Text("\"\(result.customer.satisfiedLine)\"")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Customer name
                Text("- \(result.customer.name)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.3, blue: 0.2),
                                Color(red: 0.2, green: 0.4, blue: 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(40)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Preview

#Preview {
    RepairResultOverlay(
        result: RepairResult(
            slots: [
                RepairSlot(index: 0, card: ComponentCard(type: .structural, value: 3, name: "Oak Plank")),
                RepairSlot(index: 1, card: ComponentCard(type: .enchantment, value: 2, name: "Arcane Dust")),
                RepairSlot(index: 2, card: ComponentCard(type: .memory, value: 1, name: "Whispered Echo")),
                RepairSlot(index: 3, card: ComponentCard(type: .wildcraft, value: 2, name: "Lucky Rock"))
            ],
            customer: Customer(
                name: "Bakasura",
                itemName: "Cracked Shield",
                requiredType: .structural,
                preferredType: .enchantment,
                portraitName: "figure.martial.arts",
                arrivalLine: "Can you fix this?",
                satisfiedLine: "Perfect! This is exactly what I needed!",
                failedLine: "What did you do?!"
            )
        )
    )
}
