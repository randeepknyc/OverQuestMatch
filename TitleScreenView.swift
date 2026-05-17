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
    
    // ✨ Leaf animation state
    @State private var currentLeafFrame = 1
    
    // ✨ FIXED: Background fade animation state - REVERSED LOGIC
    @State private var finalBackgroundOpacity: Double = 0.0  // Start invisible, fade IN
    
    // ✨ Screen fade-in animation state (for splash → title transition)
    @State private var screenOpacity: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // ═══════════════════════════════════════════════════════════════
                // BASE BACKGROUND - "title_screen01.png" (SHOWS FIRST)
                // ═══════════════════════════════════════════════════════════════
                // This is the BOTTOM layer - always visible
                Image("title_screen01")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height + abs(backgroundOffset)
                    )
                    .offset(y: backgroundOffset)
                    .ignoresSafeArea()
                
                // ═══════════════════════════════════════════════════════════════
                // ✨ FIXED: FINAL BACKGROUND - "title_screen.png" (FADES IN ON TOP)
                // ═══════════════════════════════════════════════════════════════
                // Starts invisible (opacity 0), fades in to reveal final image
                Image("title_screen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .opacity(finalBackgroundOpacity)  // ✅ Starts at 0, fades to 1
                    .ignoresSafeArea()
                
                // ═══════════════════════════════════════════════════════════════
                // ✨ LEAF ANIMATION LAYER (ON TOP OF BACKGROUNDS)
                // ═══════════════════════════════════════════════════════════════
                // Cycles through leaf1.png → leaf17.png with 2 second delay
                Image("leaf\(currentLeafFrame)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .ignoresSafeArea()
                
                // ═══════════════════════════════════════════════════════════════
                // LOGO LAYER - "title_logo.png"
                // ═══════════════════════════════════════════════════════════════
                // Your separate "OverQuest" logo that sits on top of title_screen
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)
                    
                    Image("title_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 1.0)
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
        .opacity(screenOpacity)
        .onAppear {
            // Fade in entire screen when appearing after splash
            withAnimation(.easeIn(duration: 0.2)) {
                screenOpacity = 1.0
            }
            
            startBackgroundFade()  // ✅ Start background fade (01 → final)
            startAnimation()
            startLeafAnimation()
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // ✨ FIXED: BACKGROUND FADE ANIMATION
    // ═══════════════════════════════════════════════════════════════
    // Shows title_screen01.png first, then fades IN title_screen.png on top
    func startBackgroundFade() {
        // ⚠️ ADJUST THESE TIMING VALUES:
        let displayDuration = 2.0  // How long title_screen01 shows before fading
        let fadeDuration = 1.25     // How long the fade takes
        
        // Wait for display duration, then fade IN the final background
        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
            withAnimation(.easeInOut(duration: fadeDuration)) {
                finalBackgroundOpacity = 1.0  // ✅ Fade FROM 0 TO 1 (appears on top)
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // ✨ LEAF ANIMATION LOGIC WITH LOOP DELAY
    // ═══════════════════════════════════════════════════════════════
    // Cycles through leaf1.png → leaf17.png, then pauses before looping
    func startLeafAnimation() {
        // ⚠️ ADJUST THESE TIMING VALUES:
        let frameDelay = 0.1        // Time between each leaf frame (0.1s = 10fps)
        let loopPauseDelay = 2.0    // Pause AFTER leaf17 before restarting (2 seconds)
        
        Timer.scheduledTimer(withTimeInterval: frameDelay, repeats: true) { timer in
            if currentLeafFrame < 17 {
                // Normal playback: leaf1 → leaf17
                currentLeafFrame += 1
            } else {
                // We're at leaf17 - stop the timer temporarily
                timer.invalidate()
                
                // Wait for loop pause, then restart from leaf1
                DispatchQueue.main.asyncAfter(deadline: .now() + loopPauseDelay) {
                    currentLeafFrame = 1
                    startLeafAnimation()  // Restart the animation
                }
            }
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
