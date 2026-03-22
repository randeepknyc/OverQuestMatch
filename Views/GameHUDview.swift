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
    @Binding var showTitleScreen: Bool  // ✅ NEW: For END GAME button
    
    @State private var showEndGameConfirmation = false  // ✅ NEW: Dialog state
    
    var body: some View {
        ZStack {
            backgroundOverlay
            
            // ✅ CENTERED MENU
            VStack(spacing: 25) {
                titleHeader
                gameModeSlider
                menuButtons
            }
            
            // ✅ END GAME CONFIRMATION DIALOG (appears on top of pause menu)
            if showEndGameConfirmation {
                EndGameConfirmationDialog(
                    isPresented: $showEndGameConfirmation,
                    onConfirm: {
                        // Reset game, close menus, return to title
                        viewModel.resetGame()
                        withAnimation {
                            showEndGameConfirmation = false
                            isPresented = false
                            showTitleScreen = true
                        }
                    }
                )
                .zIndex(2000)  // Above pause menu
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
                // ✅ Show confirmation dialog instead of closing menu
                withAnimation { showEndGameConfirmation = true }
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
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ END GAME CONFIRMATION DIALOG
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
                    // Tap outside to dismiss
                    dismissDialog()
                }
            
            // Dialog box
            VStack(spacing: 20) {
                // Image or emoji at top
                warningImage
                
                // Title text
                Text("ARE YOU SURE?")
                    .font(.gameScore(size: 38))
                    .foregroundStyle(.yellow)
                    .shadow(color: .black, radius: 5, y: 3)
                
                // Message text
                Text("Your progress will be lost!")
                    .font(.gameUI(size: 20))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                // Buttons
                HStack(spacing: 20) {
                    // CANCEL button (green)
                    Button {
                        dismissDialog()
                    } label: {
                        Text("CANCEL")
                            .font(.gameUI(size: 24))
                            .foregroundStyle(.white)
                            .frame(width: 130, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .shadow(color: .green.opacity(0.5), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    // END GAME button (red)
                    Button {
                        onConfirm()
                    } label: {
                        Text("END GAME")
                            .font(.gameUI(size: 24))
                            .foregroundStyle(.white)
                            .frame(width: 130, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.red.opacity(0.9), Color.red.opacity(0.7)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .shadow(color: .red.opacity(0.5), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.15, blue: 0.5),
                                Color(red: 0.2, green: 0.1, blue: 0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.7), radius: 20, y: 10)
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
    
    @ViewBuilder
    private var warningImage: some View {
        // Try to load custom image, fallback to emoji
        if let customImage = UIImage(named: "end_game_warning") {
            Image(uiImage: customImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 150)
        } else {
            // Emoji fallback
            Text("💀")
                .font(.system(size: 80))
        }
    }
    
    private func dismissDialog() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
            scale = 0.8
            opacity = 0.0
        }
        
        // Delay actual dismissal to let animation play
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}

