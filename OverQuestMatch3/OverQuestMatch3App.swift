//
//  OverQuestMatch3App.swift
//  OverQuestMatch3
//
//  Created by Randeep Katari on 3/7/26.
//

import SwiftUI

// MARK: - Game Type Enum
enum GameType {
    case match3
    case physicsChain
    case cooking
    case potionSolitaire
    case mapNavigation
}

// MARK: - Main App
@main
struct OverQuestMatch3App: App {
    
    // 🎮 DEV SWITCHER: Change this to switch between game types
    // ⚠️ Set to .match3 for your working Match-3 game
    private let currentGame: GameType = .physicsChain
    
    var body: some Scene {
        WindowGroup {
            mainView
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        switch currentGame {
        case .match3:
            // ✅ Your existing Match-3 RPG Battle Game
            Match3ContentView()
            
        case .physicsChain:
            // 🔮 Physics Chain Game (Tsum-Tsum Style!)
            PhysicsChainGameView()
            
        case .cooking:
            // 🍳 Cooking Game (Coming Soon)
            PlaceholderView(gameName: "Cooking Game")
            
        case .potionSolitaire:
            // 🧪 Potion Solitaire Game (Coming Soon)
            PlaceholderView(gameName: "Potion Solitaire Game")
            
        case .mapNavigation:
            // 🗺️ Map Navigation System (Coming Soon)
            PlaceholderView(gameName: "Map Navigation")
        }
    }
}
// MARK: - Placeholder View
struct PlaceholderView: View {
    let gameName: String
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Icon
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // Title
                Text(gameName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Subtitle
                Text("Coming Soon")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                // Description
                Text("This game is under development.\nSwitch back to .match3 in OverQuestMatch3App.swift")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
            }
            .padding()
        }
    }
}

