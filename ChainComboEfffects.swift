//
//  ChainComboEffects.swift
//  OverQuestMatch3
//
//  Chain combo visual effects - now supports PNG image!
//

import SwiftUI

// MARK: - 4-Chain Power Surge Effect (PNG VERSION)

struct PowerSurgeEffect: View {
    @State private var flashOpacity: Double = 0.8
    @State private var textScale: CGFloat = 0.5
    @State private var textOpacity: Double = 1.0
    @State private var lightningOpacity: Double = 0.0
    @State private var particleOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // BLUE SCREEN FLASH
            screenFlash
            
            // CUSTOM PNG LIGHTNING IMAGE
            lightningBolts
            
            // Electric particles
            electricParticles
            
            // Text overlay
            powerSurgeText
        }
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Sub-views (broken up to help compiler)
    
    private var screenFlash: some View {
        Rectangle()
            .fill(Color.cyan.opacity(0.4))
            .opacity(flashOpacity)
            .ignoresSafeArea()
    }
    
    private var lightningBolts: some View {
        GeometryReader { geometry in
            Image("power_surge_lightning")  // YOUR PNG FILE
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(lightningOpacity)
                .shadow(color: .cyan, radius: 30)
                .shadow(color: .blue, radius: 20)
                .shadow(color: .white, radius: 15)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .ignoresSafeArea()
    }
    
    private var electricParticles: some View {
        ForEach(0..<40, id: \.self) { index in
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: CGFloat.random(in: 3...12))
                .opacity(particleOpacity)
                .offset(
                    x: CGFloat.random(in: -200...200),
                    y: CGFloat.random(in: -300...300)
                )
                .blur(radius: CGFloat.random(in: 1...4))
        }
    }
    
    private var powerSurgeText: some View {
        VStack {
            Spacer()
            
            Text("CRACKLE POWER!!")
                .font(.gameScore(size: 60))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 8)
                .shadow(color: .yellow, radius: 20)
                .shadow(color: .orange, radius: 15)
                .scaleEffect(textScale)
                .opacity(textOpacity)
            
            Text("+2 MANA BONUS!")
                .font(.gameUI(size: 30))
                .foregroundColor(.orange)
                .shadow(color: .black, radius: 5)
                .shadow(color: .yellow, radius: 12)
                .scaleEffect(textScale * 0.9)
                .opacity(textOpacity)
            
            Spacer()
        }
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        print("🔥 POWER SURGE EFFECT STARTED!")
        
        // Flash fades out
        withAnimation(.easeOut(duration: 0.6)) {
            flashOpacity = 0.0
        }
        
        // Text explodes in
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            textScale = 1.2
        }
        
        // Lightning appears
        withAnimation(.easeOut(duration: 0.2)) {
            lightningOpacity = 1.0
            particleOpacity = 0.8
        }
        
        // Lightning flickers
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true)) {
                lightningOpacity = 0.6
            }
        }
        
        // Particles scatter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.8)) {
                particleOpacity = 0.0
            }
        }
        
        // Everything fades out
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                textOpacity = 0.0
                lightningOpacity = 0.0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.green.opacity(0.3)
            .ignoresSafeArea()
        
        PowerSurgeEffect()
    }
}
