//
//  GameHUDView.swift
//  OverQuestMatch3
//

import SwiftUI

struct GameHUDView: View {
    @Bindable var viewModel: GameViewModel
    @Binding var showPauseMenu: Bool
    
    var body: some View {
        HStack {
            // Hamburger menu button (LEFT)
            Button {
                showPauseMenu = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                    )
            }
            
            Spacer()
            
            // Score display (RIGHT) - USING CUSTOM FONT
            HStack(spacing: 6) {
                Text("SCORE")
                    .font(.gameUI(size: 25))
                    .foregroundStyle(.yellow)
                Text("\(viewModel.score)")
                    .font(.gameScore(size: 42))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.purple.opacity(0.6))
            )
        }
        .padding(.horizontal)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ PAUSE MENU - TWO IMAGES THAT SWAP BASED ON GAME MODE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct PauseMenuView: View {
    @Binding var isPresented: Bool
    @Bindable var viewModel: GameViewModel
    @Binding var gameMode: GameMode
    let onEndGame: () -> Void
    
    @State private var showEndGameConfirmation = false
    
    var body: some View {
        ZStack {
            // Dark overlay backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isPresented = false }
                }
            
            // ✅ YOUR CUSTOM PAUSE MENU IMAGE (SWAPS BASED ON MODE)
            ZStack {
                // Background image changes based on game mode
                Image(gameMode == .swap ? "pausemenu_swap" : "pausemenu_chain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280, height: 500)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.0), value: gameMode)
                
                // ✅ INVISIBLE TAP ZONES OVERLAID ON YOUR IMAGE
                VStack(spacing: 0) {
                    // Top spacer (for "PAUSED" title area)
                    Color.clear
                        .frame(height: 85)
                    
                    // Mode slider tap zones (SWAP / CHAIN)
                    HStack(spacing: 0) {
                        // SWAP button zone
                        Color.clear
                            .frame(width: 140, height: 70)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    gameMode = .swap
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation { isPresented = false }
                                }
                            }
                        
                        // CHAIN button zone
                        Color.clear
                            .frame(width: 140, height: 70)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    gameMode = .chain
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation { isPresented = false }
                                }
                            }
                    }
                    
                    // Spacer between slider and buttons
                    Color.clear
                        .frame(height: 25)
                    
                    // RESUME button zone
                    Color.clear
                        .frame(width: 280, height: 54)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation { isPresented = false }
                        }
                    
                    Spacer().frame(height: 18)
                    
                    // RESTART button zone
                    Color.clear
                        .frame(width: 280, height: 54)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.resetGame()
                            withAnimation { isPresented = false }
                        }
                    
                    Spacer().frame(height: 18)
                    
                    // HOW TO PLAY button zone
                    Color.clear
                        .frame(width: 280, height: 54)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Add "how to play" logic here later
                            withAnimation { isPresented = false }
                        }
                    
                    Spacer().frame(height: 18)
                    
                    // END GAME button zone
                    Color.clear
                        .frame(width: 280, height: 54)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation { showEndGameConfirmation = true }
                        }
                    
                    // Bottom spacer
                    Spacer()
                }
                .frame(width: 280, height: 500)
            }
            
            // ✅ END GAME CONFIRMATION DIALOG (appears on top)
            if showEndGameConfirmation {
                EndGameConfirmationDialog(
                    isPresented: $showEndGameConfirmation,
                    onConfirm: {
                        showEndGameConfirmation = false
                        isPresented = false
                        // Small delay to allow menu animations to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onEndGame()
                        }
                    }
                )
                .zIndex(2000)
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ END GAME DIALOG - SINGLE BACKGROUND IMAGE WITH INVISIBLE TAP ZONES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct EndGameConfirmationDialog: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Dark overlay backdrop
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissDialog()
                }
            
            // ✅ YOUR CUSTOM END GAME DIALOG IMAGE
            ZStack {
                // Background image (340×380 pixels)
                Image("endgame_dialog")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 340, height: 380)
                
                // ✅ INVISIBLE TAP ZONES OVERLAID ON YOUR IMAGE
                VStack(spacing: 0) {
                    // Top spacer (for warning icon + "ARE YOU SURE?" + message)
                    Color.clear
                        .frame(height: 280)
                    
                    // Button zones
                    HStack(spacing: 20) {
                        // CANCEL button zone
                        Color.clear
                            .frame(width: 130, height: 50)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dismissDialog()
                            }
                        
                        // END GAME button zone
                        Color.clear
                            .frame(width: 130, height: 50)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onConfirm()
                            }
                    }
                    
                    // Bottom spacer
                    Spacer()
                }
                .frame(width: 340, height: 380)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Animate dialog appearance
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func dismissDialog() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
            scale = 0.8
            opacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}
