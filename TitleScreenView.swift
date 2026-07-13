//
//  TitleScreenView.swift
//  OverQuestMatch3
//
//  JULY 10, 2026 — THE LAUNCH-BALLOON FIX. This screen (with the splash)
//  used to draw ~20 full-screen PNGs via raw Image("name"). iOS decoded
//  each at FULL export resolution (~134MB apiece!) into its process-wide
//  cache — the bimodal 1.1–2.8GB launches, sized by how long you lingered
//  here. Every image now routes through the game's budgeted at-size
//  loader (2048px cap, ~120MB evicting budget). Leaves decode at half
//  screen height so all 17 frames fit the budget without thrash — at
//  10fps in motion the difference is invisible. Also: the leaf timer now
//  actually STOPS when this screen disappears (it used to run forever).
//  Visuals and all timing knobs are unchanged.
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

    // JULY 10, 2026: balloon fix — keeps leaf/timer work stoppable.
    @State private var animActive = true

    /// JULY 10, 2026: budgeted at-size image (never full-res). Falls back
    /// to the raw asset only if the loader finds nothing (missing asset).
    @ViewBuilder
    private func psArt(_ name: String, pts: CGFloat) -> some View {
        if let img = PotionShopImageLoader.loadDisplayImage(named: name, displaySize: pts) {
            Image(uiImage: img).resizable()
        } else {
            Image(name).resizable()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // ═══════════════════════════════════════════════════════════════
                // BASE BACKGROUND - "title_screen01.png" (SHOWS FIRST)
                // ═══════════════════════════════════════════════════════════════
                // This is the BOTTOM layer - always visible
                psArt("title_screen01", pts: geometry.size.height)
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
                psArt("title_screen", pts: geometry.size.height)
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
                // Half screen height: 17 frames fit the cache budget; at
                // 10fps in motion the resolution difference is invisible.
                psArt("leaf\(currentLeafFrame)", pts: geometry.size.height / 2)
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
                    
                    psArt("title_logo", pts: geometry.size.width)
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
            animActive = true   // JULY 10: (re)arm the leaf loop
            // Fade in entire screen when appearing after splash
            withAnimation(.easeIn(duration: 0.2)) {
                screenOpacity = 1.0
            }
            
            startBackgroundFade()  // ✅ Start background fade (01 → final)
            startAnimation()
            startLeafAnimation()
        }
        .onDisappear {
            // JULY 10, 2026: the leaf timer used to keep firing FOREVER
            // after this screen was gone (it re-scheduled itself in a
            // loop). Kill the whole chain the moment we disappear.
            animActive = false
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
            // JULY 10, 2026: stop dead once the title screen is gone.
            guard animActive else { timer.invalidate(); return }
            if currentLeafFrame < 17 {
                // Normal playback: leaf1 → leaf17
                currentLeafFrame += 1
            } else {
                // We're at leaf17 - stop the timer temporarily
                timer.invalidate()
                
                // Wait for loop pause, then restart from leaf1
                DispatchQueue.main.asyncAfter(deadline: .now() + loopPauseDelay) {
                    guard animActive else { return }   // JULY 10
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
