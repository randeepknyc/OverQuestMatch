//
//  TitleScreenView.swift
//  OverQuestMatch3
//

import SwiftUI

struct TitleScreenView: View {
    @Binding var showTitleScreen: Bool
    @Binding var showMapScreen: Bool
    
    // Animation states
    @State private var logoOffset: CGFloat = 0
    @State private var logoScale: Double = 1.0
    @State private var logoOpacity: Double = 1.0
    @State private var logoGlow: Double = 0
    @State private var backgroundOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // ═══════════════════════════════════════════════════════════════
                // BACKGROUND IMAGE - "title_screen.png"
                // ═══════════════════════════════════════════════════════════════
                // Optional parallax animation if GameConfig.titleAnimationStyle = .parallaxScroll
                Image("title_screen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height + abs(backgroundOffset)
                    )
                    .offset(y: backgroundOffset)
                    .ignoresSafeArea()
                
                // ═══════════════════════════════════════════════════════════════
                // LOGO LAYER - "title_logo.png"
                // ═══════════════════════════════════════════════════════════════
                // Your separate "OverQuest" logo that sits on top of title_screen
                // Position: Same spot as text in your original title_screen.png
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.15) // Adjust this to match logo position
                    
                    Image("title_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 1.0) // 70% of screen width
                        .offset(y: logoOffset)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: Color.white.opacity(logoGlow), radius: 20, x: 0, y: 0)
                    
                    Spacer()
                }
                
                // ═══════════════════════════════════════════════════════════════
                // INVISIBLE TAPPABLE AREA - "Press Start" button
                // ═══════════════════════════════════════════════════════════════
                VStack {
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(
                            width: geometry.size.width * 0.6,
                            height: geometry.size.height * 0.20
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showTitleScreen = false
                                showMapScreen = true
                            }
                        }
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.18)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startAnimation()
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // ANIMATION LOGIC
    // ═══════════════════════════════════════════════════════════════
    // Triggered by GameConfig.titleAnimationStyle
    func startAnimation() {
        switch GameConfig.titleAnimationStyle {
        case .none:
            // No animation - everything stays at default
            break
            
        case .slideAndSettle:
            slideAndSettleAnimation()
            
        case .floatAndPulse:
            floatAndPulseAnimation()
            
        case .scaleAndBounce:
            scaleAndBounceAnimation()
            
        case .parallaxScroll:
            parallaxScrollAnimation()
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // ANIMATION OPTION 1: Slide & Settle
    // ═══════════════════════════════════════════════════════════════
    // Logo starts off-screen at bottom, slides up with spring bounce
    func slideAndSettleAnimation() {
        // Start off-screen at bottom
        logoOffset = 600
        logoOpacity = 0
        
        // Slide up with spring bounce
        withAnimation(.spring(response: 1.2, dampingFraction: 0.6, blendDuration: 0)) {
            logoOffset = 0
            logoOpacity = 1.0
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // ANIMATION OPTION 2: Float & Pulse (DEFAULT - ACTIVE)
    // ═══════════════════════════════════════════════════════════════
    // Gentle floating + scale pulse + glow effect
    func floatAndPulseAnimation() {
        // Gentle floating motion (up and down)
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            logoOffset = -15  // Float up 15 pixels
        }
        
        // Gentle scale pulse (grow and shrink)
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            logoScale = 1.05  // Grow to 105%
        }
        
        // Glow pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            logoGlow = 0.6  // Glow intensity
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // ANIMATION OPTION 3: Scale & Bounce
    // ═══════════════════════════════════════════════════════════════
    // Logo starts tiny, grows large with dramatic bounce
    func scaleAndBounceAnimation() {
        // Start small and invisible
        logoScale = 0.3
        logoOpacity = 0
        
        // Grow with dramatic bounce
        withAnimation(.spring(response: 1.0, dampingFraction: 0.4, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // ANIMATION OPTION 4: Parallax Scroll
    // ═══════════════════════════════════════════════════════════════
    // Background image slowly drifts, logo stays still
    func parallaxScrollAnimation() {
        // Slow continuous drift
        withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: true)) {
            backgroundOffset = -50  // Drift up slowly
        }
    }
}
