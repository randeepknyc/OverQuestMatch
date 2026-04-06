//
//  AssetsDebugView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/5/26.
//  Debug view to test custom asset integration with character forcing
//

import SwiftUI
import UIKit

struct AssetsDebugView: View {
    
    @State private var showCustomOnly = false
    @Binding var gameState: ShopGameState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Toggle to show only custom images
                    Toggle("Show Only Custom Images", isOn: $showCustomOnly)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    // Character Forcing Section
                    characterForcingSection
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Customer Portraits Section
                    customerPortraitsSection
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Commentary Icons Section
                    commentaryIconsSection
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Component Icons Section
                    componentIconsSection
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Card Backgrounds Section
                    cardBackgroundsSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Asset Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Character Forcing Section
    
    private var characterForcingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 FORCE NEXT CUSTOMER")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            Text("Tap a character to make them the next customer")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(customerPortraitAssets, id: \.name) { asset in
                    forceCustomerButton(asset: asset)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func forceCustomerButton(asset: AssetInfo) -> some View {
        Button(action: {
            forceCustomer(name: asset.name)
        }) {
            VStack(spacing: 8) {
                // Image preview
                ZStack {
                    Circle()
                        .fill(asset.hasCustomImage ? Color.green.opacity(0.3) : Color.orange.opacity(0.3))
                        .frame(width: 60, height: 60)
                    
                    if let uiImage = UIImage(named: asset.assetName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: asset.sfSymbol)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    
                    // Tap indicator
                    Circle()
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 64, height: 64)
                }
                
                // Name
                Text(asset.name)
                    .font(.system(size: 9, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.primary)
                
                // Status badge
                if asset.hasCustomImage {
                    Text("✅")
                        .font(.system(size: 10))
                } else {
                    Text("⚠️")
                        .font(.system(size: 10))
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Force Customer Logic
    
    private func forceCustomer(name: String) {
        // Create a custom customer with the specified name
        let customer = Customer(
            name: name,
            itemName: "Test Item",
            requiredType: ComponentType.allCases.randomElement()!,
            preferredType: ComponentType.allCases.randomElement()!,
            portraitName: Customer.portraitIconPublic(for: name),
            arrivalLine: "This is a test customer!",
            satisfiedLine: "Thanks!",
            failedLine: "Oh no!"
        )
        
        // Replace current customer
        gameState.forceCustomer(customer)
        
        // Dismiss the debug view
        dismiss()
    }
    
    // MARK: - Customer Portraits Section
    
    private var customerPortraitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CUSTOMER PORTRAITS")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            Text("70×70pt circles (200×200px source)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(customerPortraitAssets, id: \.name) { asset in
                    if !showCustomOnly || asset.hasCustomImage {
                        assetPreviewCard(
                            name: asset.name,
                            assetName: asset.assetName,
                            hasCustomImage: asset.hasCustomImage,
                            sfSymbolFallback: asset.sfSymbol,
                            size: 70
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Commentary Icons Section
    
    private var commentaryIconsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("COMMENTARY ICONS")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            Text("30×30pt circles (100×100px source)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(commentaryIconAssets, id: \.name) { asset in
                    if !showCustomOnly || asset.hasCustomImage {
                        assetPreviewCard(
                            name: asset.name,
                            assetName: asset.assetName,
                            hasCustomImage: asset.hasCustomImage,
                            sfSymbolFallback: asset.sfSymbol,
                            size: 50
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Component Icons Section
    
    private var componentIconsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("COMPONENT ICONS")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            Text("12×12pt in UI (100×100px source)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(ComponentType.allCases, id: \.self) { type in
                    VStack(spacing: 8) {
                        Image(type.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(type.color)
                        
                        Text(type.displayName)
                            .font(.system(size: 10, weight: .semibold))
                            .multilineTextAlignment(.center)
                        
                        Text(type.iconName)
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Text("✅ Custom")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Card Backgrounds Section
    
    private var cardBackgroundsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CARD BACKGROUNDS")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            Text("0.65 aspect ratio (400×615px)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(ComponentType.allCases, id: \.self) { type in
                    cardBackgroundPreview(type: type)
                }
                
                // Cursed card background
                cursedCardBackgroundPreview()
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Preview Card Component
    
    private func assetPreviewCard(
        name: String,
        assetName: String,
        hasCustomImage: Bool,
        sfSymbolFallback: String,
        size: CGFloat
    ) -> some View {
        VStack(spacing: 8) {
            // Image preview
            ZStack {
                Circle()
                    .fill(hasCustomImage ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .frame(width: size, height: size)
                
                if let uiImage = UIImage(named: assetName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else {
                    Image(systemName: sfSymbolFallback)
                        .font(.system(size: size * 0.5))
                        .foregroundColor(.white)
                }
            }
            
            // Name
            Text(name)
                .font(.system(size: 10, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            
            // Asset name
            Text(assetName)
                .font(.system(size: 8))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            // Status badge
            if hasCustomImage {
                Text("✅ Custom")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.green)
            } else {
                Text("⚠️ SF Symbol")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.orange)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Card Background Preview
    
    private func cardBackgroundPreview(type: ComponentType) -> some View {
        VStack(spacing: 8) {
            Image(type.cardImageName)
                .resizable()
                .aspectRatio(0.65, contentMode: .fit)
                .frame(height: 120)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(type.color, lineWidth: 2)
                )
            
            Text(type.displayName)
                .font(.system(size: 12, weight: .semibold))
            
            Text(type.cardImageName)
                .font(.system(size: 8))
                .foregroundColor(.gray)
            
            Text("✅ Custom")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.green)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func cursedCardBackgroundPreview() -> some View {
        VStack(spacing: 8) {
            Image("card-cursed")
                .resizable()
                .aspectRatio(0.65, contentMode: .fit)
                .frame(height: 120)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red, lineWidth: 2)
                )
            
            Text("Cursed")
                .font(.system(size: 12, weight: .semibold))
            
            Text("card-cursed")
                .font(.system(size: 8))
                .foregroundColor(.gray)
            
            Text("✅ Custom")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.green)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Asset Data Models
    
    struct AssetInfo {
        let name: String
        let assetName: String
        let sfSymbol: String
        var hasCustomImage: Bool {
            UIImage(named: assetName) != nil
        }
    }
    
    // MARK: - Asset Lists
    
    private let customerPortraitAssets = [
        AssetInfo(name: "Bakasura", assetName: "customer-bakasura", sfSymbol: "figure.martial.arts"),
        AssetInfo(name: "Noamron", assetName: "customer-noamron", sfSymbol: "figure.walk"),
        AssetInfo(name: "Gremlock #12", assetName: "customer-gremlock-12", sfSymbol: "ant.fill"),
        AssetInfo(name: "Gremlock #47", assetName: "customer-gremlock-47", sfSymbol: "ant.fill"),
        AssetInfo(name: "Gremlock #203", assetName: "customer-gremlock-203", sfSymbol: "ant.fill"),
        AssetInfo(name: "Traveling Merchant", assetName: "customer-merchant", sfSymbol: "cart.fill"),
        AssetInfo(name: "Retired Soldier", assetName: "customer-soldier", sfSymbol: "shield.fill"),
        AssetInfo(name: "Newcomer Family", assetName: "customer-family", sfSymbol: "house.fill"),
        AssetInfo(name: "The Baker", assetName: "customer-baker", sfSymbol: "birthday.cake.fill"),
        AssetInfo(name: "Ramp (Found It!)", assetName: "customer-ramp", sfSymbol: "figure.run"),
        AssetInfo(name: "Nervous Wizard", assetName: "customer-wizard", sfSymbol: "sparkles"),
        AssetInfo(name: "Town Guard", assetName: "customer-guard", sfSymbol: "shield.checkered"),
        AssetInfo(name: "Local Farmer", assetName: "customer-farmer", sfSymbol: "leaf.fill"),
        AssetInfo(name: "Village Blacksmith", assetName: "customer-blacksmith", sfSymbol: "hammer.fill"),
        AssetInfo(name: "Generic", assetName: "customer-generic", sfSymbol: "person.fill")
    ]
    
    private let commentaryIconAssets = [
        AssetInfo(name: "Sword", assetName: "commentary-sword", sfSymbol: "hammer.fill"),
        AssetInfo(name: "Ednar", assetName: "commentary-ednar", sfSymbol: "face.smiling.fill")
    ]
}
