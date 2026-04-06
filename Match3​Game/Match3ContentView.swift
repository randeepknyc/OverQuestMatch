//
//  Match3ContentView.swift
//  OverQuestMatch3
//
//  Match-3 Game Board (no splash/title/map - those are in main app now)
//

import SwiftUI

struct Match3ContentView: View {
    @State private var viewModel = GameViewModel()
    @State private var hapticManager = HapticManager()
    @State private var showPauseMenu = false
    @State private var currentGameMode: GameMode = .swap
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GameScreen(
            viewModel: viewModel,
            hapticManager: hapticManager,
            showPauseMenu: $showPauseMenu,
            gameMode: $currentGameMode,
            onEndGame: {
                dismiss()
            }
        )
        .onAppear {
            // ✨ Wire up haptics to ViewModel and BattleManager
            viewModel.hapticManager = hapticManager
            viewModel.battleManager.hapticManager = hapticManager
        }
    }
}

struct GameScreen: View {
    @Bindable var viewModel: GameViewModel
    var hapticManager: HapticManager
    @Binding var showPauseMenu: Bool
    @Binding var gameMode: GameMode
    let onEndGame: () -> Void
    
    // 🛠️ DEBUG MENU
    @State private var showDebugMenu = false
    
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
                
                // 🛠️ DEBUG BUTTON (Top-right corner)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showDebugMenu = true }) {
                            Image(systemName: "hammer.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                                .padding(12)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                                .shadow(color: .orange.opacity(0.5), radius: 5)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                    }
                    Spacer()
                }
                .zIndex(100)
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
                
                // ═══════════════════════════════════════════════════════════════
                // 🧪 POISON PILL FULL SCREEN EFFECT
                // ═══════════════════════════════════════════════════════════════
                if viewModel.showPoisonPillEffect {
                    PoisonPillScreenEffect()
                        .transition(.opacity)
                        .zIndex(600)
                }
                
                // 🛠️ DEBUG MENU OVERLAY
                if showDebugMenu {
                    Match3DebugMenuView(
                        viewModel: viewModel,
                        isShowing: $showDebugMenu,
                        onEndGame: onEndGame
                    )
                    .transition(.opacity)
                    .zIndex(1500)
                }
                
                // ═══════════════════════════════════════════════════════════════
                // PAUSE MENU OVERLAY
                // ═══════════════════════════════════════════════════════════════
                if showPauseMenu {
                    PauseMenuView(
                        isPresented: $showPauseMenu,
                        viewModel: viewModel,
                        gameMode: $gameMode,
                        onEndGame: onEndGame
                    )
                    .transition(.opacity)
                    .zIndex(1000)
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

// MARK: - Match-3 Debug Menu with End Game Button

struct Match3DebugMenuView: View {
    @Bindable var viewModel: GameViewModel
    @Binding var isShowing: Bool
    let onEndGame: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            VStack(spacing: 30) {
                // Title
                Text("🛠️ DEBUG MENU")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.orange)
                
                // End Game Button (RED - top of menu)
                Button(action: {
                    isShowing = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onEndGame()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 20))
                        Text("End Game")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red)
                            .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.horizontal, 40)
                
                Text("Returns to title screen")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.horizontal, 40)
                
                // Existing debug menu content
                DebugMenuView(viewModel: viewModel, isShowing: $isShowing)
            }
        }
    }
}

#Preview {
    Match3ContentView()
}
