//
//  CustomerView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Customer information display panel (legacy - kept for compatibility)
//  NOTE: Next customer preview removed in Step 1 of UI redesign
//

import SwiftUI
import UIKit

struct CustomerView: View {
    
    let customer: Customer
    let nextCustomer: Customer? // No longer displayed, kept for API compatibility
    
    var body: some View {
        // Current customer panel (without next customer preview)
        currentCustomerPanel
    }
    
    // MARK: - Current Customer Panel
    
    private var currentCustomerPanel: some View {
        HStack(spacing: 12) {
            // Portrait circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.4),
                                Color.brown.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                // Try to load custom image, fallback to SF Symbol
                portraitImage(for: customer.portraitName, size: 36)
            }
            
            // Customer info
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(customer.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Item name
                Text(customer.itemName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange.opacity(0.9))
                
                // Dialogue line
                Text("\"\(customer.arrivalLine)\"")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .italic()
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                    .frame(height: 2)
                
                // Required and Preferred types
                HStack(spacing: 12) {
                    // Required type (with "!" badge)
                    HStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(customer.requiredType.color)
                                .frame(width: 28, height: 28)
                            
                            Image(customer.requiredType.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.white)
                            
                            // "!" badge
                            Circle()
                                .fill(Color.red)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Text("!")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 4, y: -4)
                        }
                        
                        Text("Required")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Preferred type (with star badge)
                    HStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(customer.preferredType.color)
                                .frame(width: 28, height: 28)
                            
                            Image(customer.preferredType.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.white)
                            
                            // Star badge
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(.orange)
                                )
                                .offset(x: 4, y: -4)
                        }
                        
                        Text("Preferred")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.6),
                            Color.brown.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    // MARK: - Portrait Image Loading
    
    /// Load custom portrait image from Assets, fallback to SF Symbol if not found
    @ViewBuilder
    private func portraitImage(for assetName: String, size: CGFloat) -> some View {
        if let uiImage = UIImage(named: assetName) {
            // Custom image found in Assets.xcassets
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size * 1.8, height: size * 1.8)
                .clipShape(Circle())
        } else {
            // Fallback to SF Symbol
            Image(systemName: sfSymbolFallback(for: assetName))
                .font(.system(size: size))
                .foregroundColor(.white)
        }
    }
    
    /// Fallback SF Symbol names for customer portraits
    private func sfSymbolFallback(for assetName: String) -> String {
        // Map custom asset names to SF Symbol fallbacks
        if assetName.contains("bakasura") { return "figure.martial.arts" }
        if assetName.contains("noamron") { return "figure.walk" }
        if assetName.contains("gremlock") { return "ant.fill" }
        if assetName.contains("merchant") { return "cart.fill" }
        if assetName.contains("soldier") { return "shield.fill" }
        if assetName.contains("family") { return "house.fill" }
        if assetName.contains("baker") { return "birthday.cake.fill" }
        if assetName.contains("ramp") { return "figure.run" }
        if assetName.contains("wizard") { return "sparkles" }
        if assetName.contains("guard") { return "shield.checkered" }
        if assetName.contains("farmer") { return "leaf.fill" }
        if assetName.contains("blacksmith") { return "hammer.fill" }
        
        return "person.fill" // Default
    }
}

// MARK: - Preview

#Preview {
    CustomerView(
        customer: Customer(
            name: "Bakasura",
            itemName: "Cracked Shield",
            requiredType: .structural,
            preferredType: .enchantment,
            portraitName: "customer-bakasura",
            arrivalLine: "Can you fix this? It's... important.",
            satisfiedLine: "Perfect! Thank you!",
            failedLine: "What did you do?!"
        ),
        nextCustomer: nil // No longer displayed
    )
    .frame(height: 180)
    .padding()
    .background(Color.gray.opacity(0.3))
}
