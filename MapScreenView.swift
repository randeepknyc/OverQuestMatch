//
//  MapScreenView.swift
//  OverQuestMatch3
//

import SwiftUI

struct MapScreenView: View {
    @Binding var showMapScreen: Bool
    
    var body: some View {
        ZStack {
            // Background - use map placeholder image
            if let uiImage = UIImage(named: GameAssets.mapBackground) {
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
                
                // Tap to start prompt
                Text("TAP ANYWHERE TO START")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.yellow)
                    .shadow(color: .black.opacity(0.7), radius: 4, y: 2)
                    .opacity(0.8)
                    .padding(.bottom, 40)
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.5)) {
                showMapScreen = false
            }
        }
    }
}
