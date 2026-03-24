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
    
    var body: some View {
        ZStack {
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
            
            // Main text
            Text("POISON PILL")
                .font(.system(size: 60, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 8)
                .shadow(color: .purple, radius: 20)
                .shadow(color: .purple, radius: 15)
                .scaleEffect(textScale)
                .opacity(textOpacity)
            
            // Subtitle
            Text("3 DAMAGE NOW!")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.red)
                .shadow(color: .black, radius: 5)
                .shadow(color: .red, radius: 12)
                .scaleEffect(textScale * 0.9)
                .opacity(textOpacity)
            
            Spacer()
        }
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        print("💀 POISON PILL SCREEN EFFECT STARTED!")
        
        // Flash fades out
        withAnimation(.easeOut(duration: 0.6)) {
            flashOpacity = 0.0
        }
        
        // Text explodes in
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            textScale = 1.2
        }
        
        // Smoke appears
        withAnimation(.easeOut(duration: 0.3)) {
            poisonOpacity = 1.0
            smokeOpacity = 0.8
        }
        
        // Smoke dissipates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.8)) {
                smokeOpacity = 0.0
            }
        }
        
        // Everything fades out
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                textOpacity = 0.0
                poisonOpacity = 0.0
            }
        }
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
