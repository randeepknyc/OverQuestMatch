//
//  DeveloperSplashView.swift
//  OverQuestMatch3
//

import SwiftUI

struct DeveloperSplashView: View {
    @Binding var showSplash: Bool
    @State private var opacity: Double = 0.0
    @State private var scale: Double = 0.8
    
    var body: some View {
        ZStack {
            // Background color
            Color.black
                .ignoresSafeArea()
            
            // ═══════════════════════════════════════════════════════════════
            // OPTION 1: Static Splash Image (DEFAULT - ACTIVE)
            // ═══════════════════════════════════════════════════════════════
            // Uses "splash_screen.png" from Assets
            // Toggle in GameConfig: useAnimatedSplash = false
            if !GameConfig.useAnimatedSplash {
                Image("splash_screen")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(40)
                    .opacity(opacity)
                    .scaleEffect(scale)
            } else {
                // ═══════════════════════════════════════════════════════════════
                // OPTION 2: Animated Splash (FOR LATER)
                // ═══════════════════════════════════════════════════════════════
                // Uses "splash_frame_1.png" through "splash_frame_X.png"
                // Toggle in GameConfig: useAnimatedSplash = true
                //
                // HOW TO SET UP ANIMATED SPLASH:
                // 1. Create 8-12 PNG images (1170 x 2532 pixels each)
                // 2. Name them: splash_frame_1.png, splash_frame_2.png, etc.
                // 3. Add all frames to Assets.xcassets
                // 4. Update totalFrames below to match your frame count
                // 5. Set GameConfig.useAnimatedSplash = true
                AnimatedSplashView()
                    .opacity(opacity)
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            // Fade in animation
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1.0
                scale = 1.0
            }
            
            // Auto-dismiss after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConfig.splashDuration) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0.0
                    scale = 1.1
                }
                
                // Hide splash screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSplash = false
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// ANIMATED SPLASH VIEW (Spritesheet Animation)
// ═══════════════════════════════════════════════════════════════
struct AnimatedSplashView: View {
    @State private var currentFrame = 1
    let totalFrames = 8  // ⚠️ CHANGE THIS to match your frame count (8, 10, 12, etc.)
    let frameRate = 0.083  // 12 FPS (don't change unless you want faster/slower animation)
    
    var body: some View {
        Image("splash_frame_\(currentFrame)")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(40)
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
