//
//  TitleScreenView.swift
//  OverQuestMatch3
//

import SwiftUI

struct TitleScreenView: View {
    @Binding var showTitleScreen: Bool
    
    var body: some View {
        ZStack {
            // Full screen background image
            Image("title_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // "Tap to Start" button
                Button {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showTitleScreen = false
                    }
                } label: {
                    Text("TAP TO START")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(
                            Capsule()
                                .fill(Color.purple.gradient)
                                .shadow(color: .black.opacity(0.5), radius: 10, y: 5)
                        )
                }
                .padding(.bottom, 80)
            }
        }
    }
}
