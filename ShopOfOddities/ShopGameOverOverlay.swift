//
//  ShopGameOverOverlay.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Game over/win screen with stats and play again option
//

import SwiftUI

struct ShopGameOverOverlay: View {
    
    let gameWon: Bool
    let finalScore: Int
    let customersServed: Int
    let totalCustomers: Int
    let reason: String?
    let repairs: [RepairResult]
    let newRepairsCount: Int
    let onPlayAgain: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Game over card
            VStack(spacing: 20) {
                // Icon and title
                VStack(spacing: 12) {
                    Image(systemName: gameWon ? "trophy.fill" : "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(gameWon ? .yellow : .red)
                    
                    Text(gameWon ? "SHOP CLOSED!" : "REPAIR FAILED")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(gameWon ? "All Customers Served!" : (reason ?? "Better luck next time"))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.horizontal, 40)
                
                // Stats
                VStack(spacing: 12) {
                    // Final score
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text("Final Score:")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(finalScore)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 40)
                    
                    // Customers served
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.orange)
                        
                        Text("Customers Served:")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(customersServed)/\(totalCustomers)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 40)
                    
                    // New repairs discovered
                    if newRepairsCount > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.cyan)
                            
                            Text("New Repairs:")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(newRepairsCount)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.cyan)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.horizontal, 40)
                
                // Repairs list (scrollable if many)
                if !repairs.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Repairs This Game:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 40)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(repairs) { repair in
                                    HStack {
                                        Text("•")
                                            .foregroundColor(.white.opacity(0.6))
                                        
                                        Text(repair.repairName)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        Spacer()
                                        
                                        Text("+\(repair.totalScore)")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                        .frame(maxHeight: 120)
                    }
                }
                
                Spacer()
                    .frame(height: 8)
                
                // Play Again button
                Button(action: onPlayAgain) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                        
                        Text("Play Again")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: gameWon ? [
                                Color(red: 0.2, green: 0.3, blue: 0.1),
                                Color(red: 0.3, green: 0.4, blue: 0.2)
                            ] : [
                                Color(red: 0.3, green: 0.1, blue: 0.1),
                                Color(red: 0.4, green: 0.2, blue: 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(gameWon ? Color.green : Color.red, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 15)
            .padding(30)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Win Screen") {
    ShopGameOverOverlay(
        gameWon: true,
        finalScore: 156,
        customersServed: 13,
        totalCustomers: 13,
        reason: "All customers served!",
        repairs: [
            RepairResult(
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
                    satisfiedLine: "Perfect!",
                    failedLine: "No!"
                )
            ),
            RepairResult(
                slots: [
                    RepairSlot(index: 0, card: ComponentCard(type: .structural, value: 3, name: "Oak Plank")),
                    RepairSlot(index: 1, card: ComponentCard(type: .structural, value: 2, name: "Iron Nail")),
                    RepairSlot(index: 2, card: ComponentCard(type: .structural, value: 1, name: "Stone Block")),
                    RepairSlot(index: 3, card: ComponentCard(type: .wildcraft, value: 2, name: "Lucky Rock"))
                ],
                customer: Customer(
                    name: "Noamron",
                    itemName: "Broken Sword",
                    requiredType: .structural,
                    preferredType: .structural,
                    portraitName: "figure.walk",
                    arrivalLine: "Can you fix this?",
                    satisfiedLine: "Great!",
                    failedLine: "Ugh!"
                )
            )
        ],
        newRepairsCount: 3,
        onPlayAgain: {
            print("Play again tapped!")
        }
    )
}

#Preview("Lose Screen") {
    ShopGameOverOverlay(
        gameWon: false,
        finalScore: 42,
        customersServed: 5,
        totalCustomers: 13,
        reason: "Missing required component type!",
        repairs: [
            RepairResult(
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
                    satisfiedLine: "Perfect!",
                    failedLine: "No!"
                )
            )
        ],
        newRepairsCount: 1,
        onPlayAgain: {
            print("Play again tapped!")
        }
    )
}
