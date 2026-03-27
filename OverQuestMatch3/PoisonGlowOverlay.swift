//
//  PoisonGlowOverlay.swift
//  OverQuestMatch3
//
//  Purple glow effect for poisoned character portrait
//

import SwiftUI

struct PoisonGlowOverlay: View {
    let isPoisoned: Bool
    let turnCounter: Int
    
    @State private var glowPulse: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.6
    
    var body: some View {
        if isPoisoned {
            ZStack {
                // Inner glow
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(0.8),
                                Color.purple.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .scaleEffect(glowPulse)
                    .opacity(glowOpacity)
                    .blur(radius: 10)
                
                // Outer glow pulse
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.purple, lineWidth: 3)
                    .scaleEffect(glowPulse)
                    .opacity(glowOpacity * 0.7)
                    .blur(radius: 5)
                
                // Poison turn indicator (small skulls or dots)
                VStack {
                    HStack(spacing: 4) {
                        ForEach(1...3, id: \.self) { turn in
                            Circle()
                                .fill(turn <= turnCounter ? Color.purple : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    Spacer()
                }
                .padding(.top, 8)
            }
            .onAppear {
                startPulseAnimation()
            }
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        ) {
            glowPulse = 1.15
            glowOpacity = 0.85
        }
    }
}
