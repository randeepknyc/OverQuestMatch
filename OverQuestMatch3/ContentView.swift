//
//  ContentView.swift
//  OverQuestMatch3
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()
    @State private var hapticManager = HapticManager()  // ✨ Haptic feedback
    
    // Screen management
    @State private var showSplashScreen = GameConfig.enableDeveloperSplash  // 🎬 Developer splash
    @State private var showTitleScreen = true
    @State private var showMapScreen = false
    @State private var showPauseMenu = false
    @State private var currentGameMode: GameMode = .swap
    
    var body: some View {
        ZStack {
            // ═══════════════════════════════════════════════════════════════
            // 🎬 LAYER 1: DEVELOPER SPLASH SCREEN (TOP - APPEARS FIRST)
            // ═══════════════════════════════════════════════════════════════
            // "IT CAME FROM THE DEEP" - Shows before everything else
            // Toggle in GameConfig: enableDeveloperSplash = true/false
            if showSplashScreen {
                DeveloperSplashView(showSplash: $showSplashScreen)
                    .transition(.opacity)
                    .zIndex(2000) // Above everything
            }
            
            // ═══════════════════════════════════════════════════════════════
            // LAYER 2: MAIN GAME (Only visible when screens dismissed)
            // ═══════════════════════════════════════════════════════════════
            if !showTitleScreen && !showMapScreen {
                GameScreen(viewModel: viewModel, hapticManager: hapticManager, showPauseMenu: $showPauseMenu, gameMode: $currentGameMode)
                    .onAppear {
                        // ✨ Wire up haptics to ViewModel and BattleManager
                        viewModel.hapticManager = hapticManager
                        viewModel.battleManager.hapticManager = hapticManager
                    }
            }
            
            // ═══════════════════════════════════════════════════════════════
            // LAYER 3: MAP SCREEN (Appears after title screen)
            // ═══════════════════════════════════════════════════════════════
            if showMapScreen && !showTitleScreen {
                MapScreenView(showMapScreen: $showMapScreen)
                    .transition(.opacity)
            }
            
            // ═══════════════════════════════════════════════════════════════
            // LAYER 4: TITLE SCREEN (Appears after splash screen)
            // ═══════════════════════════════════════════════════════════════
            if showTitleScreen && !showSplashScreen {
                TitleScreenView(showTitleScreen: $showTitleScreen, showMapScreen: $showMapScreen)
                    .transition(.opacity)
            }
            
            // ═══════════════════════════════════════════════════════════════
            // LAYER 5: PAUSE MENU (Top level overlay)
            // ═══════════════════════════════════════════════════════════════
            if showPauseMenu {
                PauseMenuView(
                    isPresented: $showPauseMenu,
                    viewModel: viewModel,
                    gameMode: $currentGameMode
                )
                .transition(.opacity)
                .zIndex(1000)
            }
        }
    }
}

struct GameScreen: View {
    @Bindable var viewModel: GameViewModel
    var hapticManager: HapticManager
    @Binding var showPauseMenu: Bool
    @Binding var gameMode: GameMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // HUD (hamburger menu + score)
                    GameHUDView(viewModel: viewModel, showPauseMenu: $showPauseMenu)
                        .frame(height: 60)
                    
                    // Battle scene (characters, health, mana, abilities)
                    BattleSceneView(viewModel: viewModel)
                        .frame(height: geometry.size.height * 0.42)
                    
                    // Match-3 board (extended size)
                    GameBoardView(viewModel: viewModel, gameMode: gameMode)
                        .frame(height: geometry.size.height * 0.58)
                }
                .onChange(of: gameMode) { _, newMode in
                    viewModel.currentGameMode = newMode
                }
                .onAppear {
                    viewModel.currentGameMode = gameMode
                }
                
                // Full-screen tap-away overlay for gem selector
                if viewModel.isSelectingGemToClear {
                    ZStack {
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.cancelGemClearSelection()
                            }
                    }
                    .transition(.opacity)
                    .zIndex(90)
                }
                
                // Circular gem selector around Ramp's portrait
                if viewModel.isSelectingGemToClear {
                    let rampCenterX = geometry.size.width * 0.25
                    let rampCenterY = 60 + (geometry.size.height * 0.42 * 0.35)-10
                    
                    CircularGemSelector(
                        viewModel: viewModel,
                        centerPosition: CGPoint(x: rampCenterX, y: rampCenterY)
                    )
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(200)
                }
                
                // ═══════════════════════════════════════════════════════════════
                // 🔥 POWER SURGE FULL SCREEN EFFECT
                // ═══════════════════════════════════════════════════════════════
                if GameConfig.enablePowerSurgeEffect && viewModel.battleManager.triggeredPowerSurge {
                    PowerSurgeEffect()
                        .transition(.opacity)
                        .zIndex(500)
                }
                
                // Game over overlay
                if viewModel.battleManager.gameState != .playing {
                    GameOverView(
                        gameState: viewModel.battleManager.gameState,
                        score: viewModel.score,
                        onRestart: {
                            withAnimation {
                                viewModel.resetGame()
                            }
                        }
                    )
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ContentView()
}
