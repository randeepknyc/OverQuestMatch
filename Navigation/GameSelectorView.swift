//
//  GameSelectorView.swift
//  OverQuestMatch3 - Debug Game Selector
//
//  Created on April 6, 2026
//  Temporary testing screen to switch between games on device
//

import SwiftUI

struct GameSelectorView: View {
    
    @State private var selectedGame: GameType? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.2),
                    Color(red: 0.1, green: 0.1, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("🎮 DEBUG TEST 🎮")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("GAME SELECTOR")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Tap to launch a game")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Game selection buttons
                VStack(spacing: 20) {
                    gameButton(
                        title: "Match-3 RPG Battle",
                        icon: "⚔️",
                        description: "8×8 gem matching with battle mechanics",
                        game: .match3
                    )
                    
                    gameButton(
                        title: "Physics Chain Game",
                        icon: "🫧",
                        description: "Tsum-Tsum style bubble chaining",
                        game: .physicsChain
                    )
                    
                    gameButton(
                        title: "Shop of Oddities",
                        icon: "🔧",
                        description: "Card-based repair solitaire",
                        game: .shopOfOddities
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Back to map button
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left.circle")
                            .font(.system(size: 18))
                        Text("Back to Map")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 30)
                }
            }
        }
        .fullScreenCover(item: $selectedGame) { gameType in
            gameView(for: gameType)
        }
    }
    
    // MARK: - Game Button
    
    private func gameButton(title: String, icon: String, description: String, game: GameType) -> some View {
        Button(action: {
            selectedGame = game
        }) {
            HStack(spacing: 16) {
                // Icon
                Text(icon)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Game View Router
    
    @ViewBuilder
    private func gameView(for gameType: GameType) -> some View {
        switch gameType {
        case .match3:
            Match3ContentView()
        case .physicsChain:
            PhysicsChainGameView()
        case .shopOfOddities:
            ShopOfOdditiesView()
        case .cooking:
            PlaceholderView(gameName: "Cooking Game")
        case .potionSolitaire:
            PlaceholderView(gameName: "Potion Solitaire")
        case .mapNavigation:
            PlaceholderView(gameName: "Map Navigation")
        }
    }
}

// MARK: - Make GameType Identifiable

extension GameType: Identifiable {
    var id: Self { self }
}

#Preview {
    GameSelectorView()
}
