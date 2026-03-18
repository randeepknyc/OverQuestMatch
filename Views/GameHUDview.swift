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
    @Binding var gameMode: GameMode
    
    var body: some View {
        ZStack {
            backgroundOverlay
            
            // ✅ CENTERED MENU
            VStack(spacing: 25) {
                titleHeader
                gameModeSlider
                menuButtons
            }
        }
    }
    
    private var backgroundOverlay: some View {
        Color.black.opacity(0.85)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation { isPresented = false }
            }
    }
    
    private var titleHeader: some View {
        Text("PAUSED")
            .font(.gameScore(size: 56))
            .foregroundStyle(.yellow)
            .shadow(color: .black, radius: 10, y: 5)
    }
    
    // ✅ SLIDER WITH AUTO-CLOSE
    private var gameModeSlider: some View {
        VStack(spacing: 12) {
            Text("GAME MODE")
                .font(.gameUI(size: 18))
                .foregroundStyle(.white.opacity(0.8))
                .shadow(color: .black, radius: 5)
            
            HStack(spacing: 0) {
                // SWAP button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        gameMode = .swap
                    }
                    // ✅ AUTO-CLOSE MENU AFTER 0.3 SECONDS
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation { isPresented = false }
                    }
                } label: {
                    Text("SWAP")
                        .font(.gameUI(size: 22))
                        .foregroundStyle(gameMode == .swap ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                
                // CHAIN button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        gameMode = .chain
                    }
                    // ✅ AUTO-CLOSE MENU AFTER 0.3 SECONDS
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation { isPresented = false }
                    }
                } label: {
                    Text("CHAIN")
                        .font(.gameUI(size: 22))
                        .foregroundStyle(gameMode == .chain ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .frame(width: 280)
            .background(
                // Sliding background indicator
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.orange)
                        .frame(width: geometry.size.width / 2)
                        .offset(x: gameMode == .chain ? geometry.size.width / 2 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gameMode)
                }
            )
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.4))
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.5), radius: 10, y: 5)
        }
    }
    
    // ✅ BUTTONS WITH YOUR CUSTOM ICONS
    private var menuButtons: some View {
        VStack(spacing: 18) {
            PauseMenuButton(
                title: "RESUME",
                iconAsset: "resume_icon",  // ✅ YOUR ICON
                iconFallback: "play.fill"
            ) {
                withAnimation { isPresented = false }
            }
            
            PauseMenuButton(
                title: "RESTART",
                iconAsset: "restart_icon",  // ✅ YOUR ICON
                iconFallback: "arrow.clockwise"
            ) {
                viewModel.resetGame()
                withAnimation { isPresented = false }
            }
            
            PauseMenuButton(
                title: "HOW TO PLAY",
                iconAsset: "instructions_icon",  // ✅ YOUR ICON
                iconFallback: "questionmark.circle.fill"
            ) {
                // You can add "how to play" screen logic here later
                withAnimation { isPresented = false }
            }
            
            PauseMenuButton(
                title: "END GAME",
                iconAsset: "quit_icon",  // ✅ YOUR ICON
                iconFallback: "xmark.circle.fill"
            ) {
                // You can add logic to return to title screen here later
                withAnimation { isPresented = false }
            }
        }
    }
}

// ✅ BUTTON WITH CUSTOM ICON SUPPORT
struct PauseMenuButton: View {
    let title: String
    let iconAsset: String?
    let iconFallback: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // ✅ Load YOUR custom icon first, fall back to SF Symbol if not found
                if let assetName = iconAsset, let uiImage = UIImage(named: assetName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: iconFallback)
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .frame(width: 28)
                }
                
                Text(title)
                    .font(.gameUI(size: 24))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(width: 280)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.9), Color.red.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: .red.opacity(0.5), radius: 8, y: 4)
            .shadow(color: .black.opacity(0.6), radius: 15, y: 8)
        }
        .buttonStyle(.plain)
    }
}
