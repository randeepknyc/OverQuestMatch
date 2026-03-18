//
//  ContentView.swift
//  OverQuestMatch3
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()
    @State private var showTitleScreen = true
    @State private var showMapScreen = false
    @State private var showPauseMenu = false
    @State private var currentGameMode: GameMode = .swap
    
    var body: some View {
        ZStack {
            // Main game (only visible when both screens are dismissed)
            if !showTitleScreen && !showMapScreen {
                GameScreen(viewModel: viewModel, showPauseMenu: $showPauseMenu, gameMode: $currentGameMode)
            }
            
            // Map screen (appears after title screen)
            if showMapScreen && !showTitleScreen {
                MapScreenView(showMapScreen: $showMapScreen)
                    .transition(.opacity)
            }
            
            // Title screen overlay (first screen)
            if showTitleScreen {
                TitleScreenView(showTitleScreen: $showTitleScreen, showMapScreen: $showMapScreen)
                    .transition(.opacity)
            }
            
            // FULL SCREEN PAUSE MENU - AT TOP LEVEL
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
                
                // Full-screen tap-away overlay for gem selector (covers entire game)
                if viewModel.isSelectingGemToClear {
                    ZStack {
                        // Invisible tap-catcher that covers everywhere
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.cancelGemClearSelection()
                            }
                    }
                    .transition(.opacity)
                    .zIndex(90) // Below gem selector
                }
                
                // Circular gem selector around Ramp's portrait (TOP LEVEL)
                if viewModel.isSelectingGemToClear {
                    // Calculate Ramp's portrait center position
                    let rampCenterX = geometry.size.width * 0.25 // Approximate left side
                    let rampCenterY = 60 + (geometry.size.height * 0.42 * 0.35)-10 // HUD + partial battle scene
                    
                    CircularGemSelector(
                        viewModel: viewModel,
                        centerPosition: CGPoint(x: rampCenterX, y: rampCenterY)
                    )
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(200) // Above tap-away overlay
                }
                
                // ═══════════════════════════════════════════════════════════════
                // 🔥 SESSION 2 ADDITION: POWER SURGE FULL SCREEN EFFECT (START)
                // ═══════════════════════════════════════════════════════════════
                // POWER SURGE EFFECT - COVERS ENTIRE SCREEN
                if GameConfig.enablePowerSurgeEffect && viewModel.battleManager.triggeredPowerSurge {
                    PowerSurgeEffect()
                        .transition(.opacity)
                        .zIndex(500) // Above game, below pause menu
                }
                // ═══════════════════════════════════════════════════════════════
                // 🔥 SESSION 2 ADDITION: POWER SURGE FULL SCREEN EFFECT (END)
                // ═══════════════════════════════════════════════════════════════
                
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
