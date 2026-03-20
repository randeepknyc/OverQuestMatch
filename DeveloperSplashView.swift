//
//  DeveloperSplashView.swift
//  OverQuestMatch3
//

import SwiftUI

struct DeveloperSplashView: View {
    @Binding var showSplash: Bool
    @State private var opacity: Double = 0.0
    @State private var scale: Double = 0.8
    @State private var canSkip = false  // ✨ NEW: Prevents instant skip
    
    // ✨ NEW: Character animation states (4fps = 0.25s per frame)
    @State private var currentRKFrame = 1
    @State private var currentMiloFrame = 1
    
    var body: some View {
        ZStack {
            // ═══════════════════════════════════════════════════════════════
            // BACKGROUND COLOR
            // ═══════════════════════════════════════════════════════════════
            Color.black
                .ignoresSafeArea()
            
            // ═══════════════════════════════════════════════════════════════
            // LAYER 1: ANIMATED BACKGROUND LOOP (if enabled)
            // ═══════════════════════════════════════════════════════════════
            // This plays BEHIND the static logo
            // Toggle in GameConfig: useAnimatedSplash = true/false
            if GameConfig.useAnimatedSplash {
                AnimatedSplashBackgroundView()
                    .opacity(opacity)
                    .scaleEffect(scale)
            }
            
            // ═══════════════════════════════════════════════════════════════
            // LAYER 2: STATIC BACKGROUND (splash_screen.png)
            // ═══════════════════════════════════════════════════════════════
            // Base splash screen image
            Image("splash_screen")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(0)
                .opacity(opacity)
                .scaleEffect(scale)
            
            // ═══════════════════════════════════════════════════════════════
            // ✨ NEW: LAYER 3: ANIMATED CHARACTER - RK (splashrk1-3)
            // ═══════════════════════════════════════════════════════════════
            // Cycles through splashrk1.png → splashrk2.png → splashrk3.png at 4fps
            Image("splashrk\(currentRKFrame)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(0)
                .opacity(opacity)
                .scaleEffect(scale)
            
            // ═══════════════════════════════════════════════════════════════
            // ✨ NEW: LAYER 4: ANIMATED CHARACTER - MILO (splashmilo1-3)
            // ═══════════════════════════════════════════════════════════════
            // Cycles through splashmilo1.png → splashmilo2.png → splashmilo3.png at 4fps
            Image("splashmilo\(currentMiloFrame)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(0)
                .opacity(opacity)
                .scaleEffect(scale)
            
            // ═══════════════════════════════════════════════════════════════
            // LAYER 3: INVISIBLE TAP-TO-SKIP BUTTON (ENTIRE SCREEN)
            // ═══════════════════════════════════════════════════════════════
            // Tap anywhere to skip after 1 second
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    if canSkip {
                        skipSplash()
                    }
                }
            
            // ═══════════════════════════════════════════════════════════════
            // LAYER 4: "TAP TO SKIP" HINT (Optional - appears after 1 second)
            // ═══════════════════════════════════════════════════════════════
            // Uncomment this section if you want a visible "Tap to skip" message
            /*
            if canSkip {
                VStack {
                    Spacer()
                    Text("Tap to skip")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 40)
                }
                .transition(.opacity)
            }
            */
        }
        .onAppear {
            startSplashSequence()
            startCharacterAnimations()  // ✨ NEW: Start RK and Milo animations
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // ✨ CHARACTER ANIMATION LOGIC (4fps = 0.25 seconds per frame)
    // ═══════════════════════════════════════════════════════════════
    func startCharacterAnimations() {
        // RK animation: splashrk1 → splashrk2 → splashrk3 → loop (FORWARD)
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            currentRKFrame += 1
            if currentRKFrame > 3 {
                currentRKFrame = 1  // Loop back to frame 1
            }
        }
        
        // Milo animation: splashmilo3 → splashmilo2 → splashmilo1 → loop (REVERSE) ✨
        currentMiloFrame = 3  // Start at frame 3 instead of 1
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            currentMiloFrame -= 1  // Subtract instead of add (goes backwards)
            if currentMiloFrame < 1 {
                currentMiloFrame = 3  // Loop back to frame 3
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // SPLASH SEQUENCE LOGIC
    // ═══════════════════════════════════════════════════════════════
    func startSplashSequence() {
        // Fade in animation
        withAnimation(.easeIn(duration: 0.5)) {
            opacity = 1.0
            scale = 1.0
        }
        
        // ✨ Enable tap-to-skip after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                canSkip = true
            }
        }
        
        // Auto-dismiss after full duration (if user doesn't skip)
        // ⚠️ CHANGE THE NUMBER BELOW TO ADJUST SPLASH DURATION:
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {  // ⬅️ 3.0 = 3 seconds
            skipSplash()
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // SKIP SPLASH FUNCTION
    // ═══════════════════════════════════════════════════════════════
    func skipSplash() {
        guard canSkip else { return }  // Prevent multiple triggers
        
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 0.0
            scale = 1.1
        }
        
        // Hide splash screen after fade-out completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSplash = false
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// ANIMATED BACKGROUND LOOP (Plays behind static logo)
// ═══════════════════════════════════════════════════════════════
// HOW TO SET UP:
// 1. Create 8-12 PNG images (1170 x 2532 pixels each)
// 2. Name them: splash_bg_1.png, splash_bg_2.png, splash_bg_3.png, etc.
// 3. Add all frames to Assets.xcassets
// 4. Update totalFrames below to match your frame count
// 5. Set GameConfig.useAnimatedSplash = true
struct AnimatedSplashBackgroundView: View {
    @State private var currentFrame = 1
    let totalFrames = 8  // ⚠️ CHANGE THIS to match your frame count (8, 10, 12, etc.)
    let frameRate = 0.083  // 12 FPS (don't change unless you want faster/slower animation)
    
    var body: some View {
        Image("splash_bg_\(currentFrame)")  // ⚠️ Image name: splash_bg_1, splash_bg_2, etc.
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .onAppear {
                startAnimation()
            }
    }
    
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { timer in
            currentFrame += 1
            if currentFrame > totalFrames {
                currentFrame = 1  // Loop animation
            }
        }
    }
}
