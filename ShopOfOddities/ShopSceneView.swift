//
//  ShopSceneView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/5/26.
//  Scene view displaying Ednar's shop with customer character (with slide-in animation)
//

import SwiftUI
import UIKit

struct ShopSceneView: View {
    
    let customer: Customer
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // LAYER 1: Shop Background
                shopBackgroundLayer
                
                // LAYER 2: Customer Character (with slide + fade transition)
                customerCharacterLayer
                    .id(customer.id) // Trigger transition when customer changes
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
                
                // LAYER 3: Shop Foreground (Ednar + Sword)
                shopForegroundLayer
                
                // LAYER 4: Customer Info Overlay (at bottom, full width)
                VStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        // Left: Customer name and item
                        VStack(alignment: .leading, spacing: 2) {
                            Text(customer.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            
                            Text(customer.itemName)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        
                        Spacer(minLength: 8)
                        
                        // Right: Need and Like icons
                        HStack(spacing: 6) {
                            // Need icon
                            Image(customer.requiredType.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(customer.requiredType.color)
                            
                            // Like icon
                            Image(customer.preferredType.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(customer.preferredType.color)
                                .opacity(0.6)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(width: geometry.size.width) // KEY: Match scene width
                    .background(
                        Color.black.opacity(0.7)
                            .frame(width: UIScreen.main.bounds.width) // Full screen width
                            .edgesIgnoringSafeArea(.horizontal)
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: customer.id)
    }
    
    // MARK: - Layer 1: Shop Background
    
    private var shopBackgroundLayer: some View {
        Group {
            if let backgroundImage = UIImage(named: "shop-background") {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // Fallback: warm tan/brown placeholder
                Color(red: 0.77, green: 0.72, blue: 0.6)
            }
        }
    }
    
    // MARK: - Layer 2: Customer Character
    
    private var customerCharacterLayer: some View {
        customerImage // Full-width scene composite
    }
    
    /// Customer scene image or portrait fallback
    @ViewBuilder
    private var customerImage: some View {
        // Generate scene asset name from customer name
        let sceneAssetName = sceneAssetNameForCustomer(customer.name)
        
        // DEBUG: Print what we're looking for
        let _ = print("🔍 Looking for scene asset: \(sceneAssetName)")
        let _ = print("🔍 Image exists: \(UIImage(named: sceneAssetName) != nil)")
        
        if let sceneImage = UIImage(named: sceneAssetName) {
            // Scene image found! Display it full-width
            let _ = print("✅ Loaded scene image: \(sceneAssetName) - Size: \(sceneImage.size)")
            
            Image(uiImage: sceneImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let portraitImage = UIImage(named: customer.portraitName) {
            // Scene not found, use portrait in circle (centered)
            let _ = print("⚠️ No scene image, using portrait: \(customer.portraitName)")
            
            GeometryReader { geometry in
                HStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.3),
                                        Color.brown.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(uiImage: portraitImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        } else {
            // Neither scene nor portrait found, use SF Symbol fallback (centered)
            let _ = print("❌ No scene or portrait, using SF Symbol fallback")
            
            GeometryReader { geometry in
                HStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.3),
                                        Color.brown.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: sfSymbolFallback(for: customer.portraitName))
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    // MARK: - Scene Asset Name Helper
    
    /// Convert customer name to scene asset name
    private func sceneAssetNameForCustomer(_ name: String) -> String {
        // Handle special cases first
        if name.contains("Gremlock") {
            // Extract number from "Gremlock #12" -> "scene-gremlock-12"
            let number = name.components(separatedBy: "#").last ?? ""
            return "scene-gremlock-\(number.trimmingCharacters(in: .whitespaces))"
        }
        
        // Map full names to simplified asset names
        let nameMap: [String: String] = [
            "Bakasura": "scene-bakasura",
            "Noamron": "scene-noamron",
            "Traveling Merchant": "scene-merchant",
            "Retired Soldier": "scene-soldier",
            "Newcomer Family": "scene-family",
            "The Baker": "scene-baker",
            "Ramp (Found It!)": "scene-ramp",
            "Nervous Wizard": "scene-wizard",
            "Town Guard": "scene-guard",
            "Local Farmer": "scene-farmer",
            "Village Blacksmith": "scene-blacksmith"
        ]
        
        // Return mapped name or generic fallback
        return nameMap[name] ?? "scene-generic"
    }
    
    // MARK: - Layer 3: Shop Foreground
    
    private var shopForegroundLayer: some View {
        Group {
            if let foregroundImage = UIImage(named: "shop-foreground") {
                Image(uiImage: foregroundImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // No foreground image, show nothing
                EmptyView()
            }
        }
    }
    
    /// Requirement pill badge
    private func requirementPill(label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.white)
            
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .foregroundColor(color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.white.opacity(0.15))
        .cornerRadius(10)
    }
    
    // MARK: - Fallback SF Symbol Helper
    
    /// Fallback SF Symbol names for customer portraits
    private func sfSymbolFallback(for assetName: String) -> String {
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
    ShopSceneView(
        customer: Customer(
            name: "Bakasura",
            itemName: "Cracked Shield",
            requiredType: .structural,
            preferredType: .enchantment,
            portraitName: "customer-bakasura",
            arrivalLine: "Can you fix this? It's... important.",
            satisfiedLine: "Perfect! Thank you!",
            failedLine: "What did you do?!"
        )
    )
    .frame(height: 300)
    .padding()
}
