//
//  MapScreenView.swift
//  OverQuestMatch3
//
//  Updated to navigate to game selector
//
//  JULY 10, 2026 — LAUNCH-BALLOON FIX (see TitleScreenView header): the
//  map background now loads through the budgeted at-size loader. This
//  screen stays mounted UNDER the game via fullScreenCover, so its
//  full-res decode used to sit pinned for the whole play session.
//

import SwiftUI

struct MapScreenView: View {
    @Binding var showMapScreen: Bool
    @State private var showGameSelector = false
    
    var body: some View {
        ZStack {
            // Background - use map placeholder image
            // JULY 10, 2026: budgeted at-size load (never full-res).
            if let uiImage = PotionShopImageLoader.loadDisplayImage(
                named: GameAssets.mapBackground,
                displaySize: UIScreen.main.bounds.height
            ) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                // Fallback gradient if image not found
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.3, blue: 0.5),
                        Color(red: 0.4, green: 0.2, blue: 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // "Continue to Games" button
                Button(action: {
                    showGameSelector = true
                }) {
                    HStack(spacing: 12) {
                        Text("Continue to Games")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 24))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.bottom, 60)
            }
        }
        .fullScreenCover(isPresented: $showGameSelector) {
            GameSelectorView()
        }
    }
}
