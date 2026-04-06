//
//  OverQuestMatch3App.swift
//  OverQuestMatch3
//
//  Main app entry point with perfected splash/title/map flow
//

import SwiftUI

@main
struct OverQuestMatch3App: App {
    
    @State private var showSplash = GameConfig.enableDeveloperSplash
    @State private var showTitleScreen = false
    @State private var showMapScreen = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Base view (hidden under overlays)
                Color.black.ignoresSafeArea()
                
                // ═══════════════════════════════════════════════════════════════
                // 🎬 LAYER 1: DEVELOPER SPLASH SCREEN (TOP - APPEARS FIRST)
                // ═══════════════════════════════════════════════════════════════
                if showSplash && GameConfig.enableDeveloperSplash {
                    DeveloperSplashView(showSplash: $showSplash)
                        .transition(.opacity)
                        .zIndex(3)
                        .onDisappear {
                            // After splash disappears, show title screen
                            showTitleScreen = true
                        }
                }
                
                // ═══════════════════════════════════════════════════════════════
                // LAYER 2: TITLE SCREEN (Appears after splash)
                // ═══════════════════════════════════════════════════════════════
                if showTitleScreen {
                    TitleScreenView(
                        showTitleScreen: $showTitleScreen,
                        showMapScreen: $showMapScreen
                    )
                    .transition(.opacity)
                    .zIndex(2)
                }
                
                // ═══════════════════════════════════════════════════════════════
                // LAYER 3: MAP SCREEN (Shows after title, then goes to game selector)
                // ═══════════════════════════════════════════════════════════════
                if showMapScreen {
                    MapScreenView(showMapScreen: $showMapScreen)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // If splash is disabled, start at title screen
                if !GameConfig.enableDeveloperSplash {
                    showSplash = false
                    showTitleScreen = true
                }
            }
            .animation(.easeInOut(duration: 0.8), value: showSplash)
            .animation(.easeInOut(duration: 0.8), value: showTitleScreen)
        }
    }
}

// MARK: - Game Type Enum

enum GameType: CaseIterable {
    case match3
    case physicsChain
    case shopOfOddities
    case cooking
    case potionSolitaire
    case mapNavigation
}

// MARK: - Placeholder View (for unfinished games)

struct PlaceholderView: View {
    let gameName: String
    
    var body: some View {
        ZStack {
            Color(red: 0.2, green: 0.2, blue: 0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text(gameName)
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}
