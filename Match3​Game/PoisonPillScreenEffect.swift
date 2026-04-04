//
//  PoisonPillScreenEffect.swift
//  OverQuestMatch3
//
//  Fullscreen effect when poison pill is revealed
//

import SwiftUI

struct PoisonPillScreenEffect: View {
    @State private var flashOpacity: Double = 0.8
    @State private var textScale: CGFloat = 0.5
    @State private var textOpacity: Double = 1.0
    @State private var poisonOpacity: Double = 0.0
    @State private var smokeOpacity: Double = 0.0
    @State private var currentFrogFrame: String = "frog01"
    @State private var frogOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 0.9  // ✨ Separate opacity for background overlay
    
    // 🐸 FROG ANIMATION POSITION CONTROLS
    var frogXOffset: CGFloat = 0      // Left/right from center (positive = right)
    var frogYOffset: CGFloat = -85    // Up/down from "You've found the" text (negative = up)
    var frogScale: CGFloat = 3.0      // Size multiplier (1.0 = 100%, 0.5 = 50%, 2.0 = 200%)
    
    // 📝 TEXT POSITION CONTROLS
    var textXOffset: CGFloat = 0      // Left/right from center (positive = right)
    var textYOffset: CGFloat = -25      // Up/down from center (negative = up, positive = down)
    
    var body: some View {
        ZStack {
            // ═══════════════════════════════════════════════════════════════
            // ✨ SEMI-TRANSPARENT BACKGROUND OVERLAY
            // ═══════════════════════════════════════════════════════════════
            // Dark overlay behind all effects for better visibility
            Rectangle()
                .fill(Color.black.opacity(0.7))
                .ignoresSafeArea()
                .opacity(backgroundOpacity)  // ✨ Uses separate opacity control
            
            // PURPLE SCREEN FLASH
            screenFlash
            
            // Poison smoke clouds
            poisonSmoke
            
            // Text overlay
            poisonPillText
        }
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Sub-views
    
    private var screenFlash: some View {
        Rectangle()
            .fill(Color.purple.opacity(0.5))
            .opacity(flashOpacity)
            .ignoresSafeArea()
    }
    
    private var poisonSmoke: some View {
        ForEach(0..<30, id: \.self) { index in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(0.8),
                            Color.purple.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: CGFloat.random(in: 40...120))
                .opacity(smokeOpacity)
                .offset(
                    x: CGFloat.random(in: -200...200),
                    y: CGFloat.random(in: -300...300)
                )
                .blur(radius: CGFloat.random(in: 10...25))
        }
    }
    
    private var poisonPillText: some View {
        ZStack {
            // 🐸 ANIMATED FROG SPRITE (independent positioning)
            Image(currentFrogFrame)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
                .scaleEffect(frogScale)
                .offset(x: frogXOffset, y: frogYOffset)
                .opacity(frogOpacity)
                .shadow(color: .black, radius: 5)
                .shadow(color: .purple, radius: 15)
            
            // TEXT BLOCK (independent positioning)
            VStack(spacing: 20) {
                Spacer()
                
                // Skull icon
                Image(systemName: "skull.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 10)
                    .shadow(color: .purple, radius: 25)
                    .scaleEffect(textScale * 1.2)
                    .opacity(textOpacity)
                
                // Custom text - Line 1
                Text("Oops! You've found")
                    .font(.gameUI(size: 40))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 8)
                    .shadow(color: .purple, radius: 20)
                    .shadow(color: .purple, radius: 15)
                    .scaleEffect(textScale)
                    .opacity(textOpacity)
                
                // Custom text - Line 2
                Text("the Poison Frog")
                    .font(.gameUI(size: 50))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 8)
                    .shadow(color: .purple, radius: 20)
                    .shadow(color: .purple, radius: 15)
                    .scaleEffect(textScale)
                    .opacity(textOpacity)
                
                // Subtitle (damage info)
                Text("You've been poisoned!")
                    .font(.gameUI(size: 50))
                    .foregroundColor(.red)
                    .shadow(color: .black, radius: 5)
                    .shadow(color: .red, radius: 12)
                    .scaleEffect(textScale * 0.9)
                    .opacity(textOpacity)
                
                Spacer()
            }
            .offset(x: textXOffset, y: textYOffset)  // 📝 Text block position
        }
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        print("💀 POISON PILL SCREEN EFFECT STARTED!")
        
        // 🐸 Start frog animation immediately
        playFrogAnimation()
        
        // Flash fades out
        withAnimation(.easeOut(duration: 0.8)) {
            flashOpacity = 0.0
        }
        
        // Text explodes in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            textScale = 1.2
        }
        
        // Smoke appears
        withAnimation(.easeOut(duration: 0.4)) {
            poisonOpacity = 1.0
            smokeOpacity = 0.8
        }
        
        // Smoke dissipates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 1.0)) {
                smokeOpacity = 0.0
            }
        }
        
        // Everything fades out (delayed to reach 3.5s total)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeOut(duration: 0.7)) {
                textOpacity = 0.0
                poisonOpacity = 0.0
                frogOpacity = 0.0  // Fade out frog too
                backgroundOpacity = 0.0  // ✨ Fade out background at the same time
            }
        }
    }
    
    // 🐸 FROG ANIMATION CONTROLLER
    private func playFrogAnimation() {
        // Fade in frog
        withAnimation(.easeIn(duration: 0.2)) {
            frogOpacity = 1.0
        }
        
        // Animation sequence with frame timings
        let frameDelay01to05: Double = 3.0 / 30.0  // 3 frames at 30fps = ~0.1 seconds
        let frameDelay07to11: Double = 3.0 / 30.0  // 3 frames at 30fps = ~0.1 seconds
        var currentTime: Double = 0.0
        
        // Frames 01-05: 3 frames each
        let quickFrames = ["frog01", "frog02", "frog03", "frog04", "frog05"]
        for frame in quickFrames {
            DispatchQueue.main.asyncAfter(deadline: .now() + currentTime) {
                self.currentFrogFrame = frame
            }
            currentTime += frameDelay01to05
        }
        
        // Frame 06: Hold for 45 frames (45/30 = 1.5 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + currentTime) {
            self.currentFrogFrame = "frog06"
        }
        currentTime += (45.0 / 30.0)
        
        // Frames 07-11: 3 frames each
        let quickFrames2 = ["frog07", "frog08", "frog09", "frog10", "frog11"]
        for frame in quickFrames2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + currentTime) {
                self.currentFrogFrame = frame
            }
            currentTime += frameDelay07to11
        }
        
        // Frame 12: Hold for 12 frames (12/30 = 0.4 seconds) until end
        DispatchQueue.main.asyncAfter(deadline: .now() + currentTime) {
            self.currentFrogFrame = "frog12"
        }
        // Holds on frog12 until everything fades out at 1.8s
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.green.opacity(0.3)
            .ignoresSafeArea()
        
        PoisonPillScreenEffect()
    }
}
