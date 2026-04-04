//
//  GameOverView.swift
//  OverQuestMatch3
//

import SwiftUI

struct GameOverView: View {
    let gameState: BattleManager.GameState
    let score: Int
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Result icon and text
                VStack(spacing: 12) {
                    // Custom victory crown image OR system defeat icon
                    if gameState == .victory {
                        Image("victory_crown")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                    } else {
                        Image(systemName: "xmark.shield.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.red)
                    }
                    
                    Text(gameState == .victory ? "VICTORY!" : "DEFEATED")
                        .font(.gameScore(size: 65))
                        .foregroundStyle(.white)
                    
                    Text(gameState == .victory ? "Ramp beats Ednar!" : "Womp womp, you lose, Ramp!")
                        .font(.gameUI(size: 50))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Score display
                VStack(spacing: 8) {
                    Text("FINAL SCORE")
                        .font(.gameUI(size: 45))
                        .foregroundStyle(.yellow)
                    Text("\(score)")
                        .font(.gameScore(size: 55))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.5))
                )
                
                // Restart button - CUSTOM IMAGE
                Button {
                    onRestart()
                } label: {
                    Image("play_again")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 70)
                        .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
                }
            }
            .padding()
        }
        .transition(.opacity)
    }
}
