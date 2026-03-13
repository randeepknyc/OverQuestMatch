//
//  TitleScreenView.swift
//  OverQuestMatch3
//

import SwiftUI

struct TitleScreenView: View {
    @Binding var showTitleScreen: Bool
    @Binding var showMapScreen: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full screen title image
                Image("title_screen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                // Invisible tappable area over "Press Start" sign
                VStack {
                    Spacer()
                    
                    // Tappable region where the "Press Start" sign is
                    Rectangle()
                        .fill(Color.clear) // Invisible
                        .frame(
                            width: geometry.size.width * 0.6,  // 60% of screen width
                            height: geometry.size.height * 0.20 // 20% of screen height
                        )
                        .contentShape(Rectangle()) // Makes entire area tappable
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showTitleScreen = false
                                showMapScreen = true // Show map screen next
                            }
                        }
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.18) // Position adjustment
                }
            }
        }
        .ignoresSafeArea()
    }
}
