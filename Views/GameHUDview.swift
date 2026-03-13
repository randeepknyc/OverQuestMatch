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

struct PauseMenuView: View {
    @Binding var isPresented: Bool
    @Bindable var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Dimmed background - FULL SCREEN
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // Pause menu card
            VStack(spacing: 20) {
                Text("PAUSED")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    PauseMenuButton(title: "RESUME", icon: "play.fill") {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    
                    PauseMenuButton(title: "RESTART", icon: "arrow.clockwise") {
                        viewModel.resetGame()
                        withAnimation {
                            isPresented = false
                        }
                    }
                    
                    PauseMenuButton(title: "HOW TO PLAY", icon: "questionmark.circle.fill") {
                        // TODO: Show tutorial/instructions
                        withAnimation {
                            isPresented = false
                        }
                    }
                    
                    PauseMenuButton(title: "END GAME", icon: "xmark.circle.fill") {
                        // TODO: Return to title screen
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(width: 300)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
            )
        }
    }
}

struct PauseMenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.gradient)
            )
        }
    }
}
