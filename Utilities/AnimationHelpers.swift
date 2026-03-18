//
//  AnimationHelpers.swift
//  OverQuestMatch3
//

import SwiftUI

/// Shake effect modifier
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

extension View {
    func shake(amount: CGFloat = 10, animatableData: CGFloat) -> some View {
        modifier(ShakeEffect(amount: amount, animatableData: animatableData))
    }
}

/// Pop animation for tile matches
struct PopEffect: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.2 : 1.0)
    }
}

extension View {
    func popEffect(isActive: Bool) -> some View {
        modifier(PopEffect(isActive: isActive))
    }
}

/// Floating damage text animation
struct FloatingText: View {
    let text: String
    let color: Color
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Text(text)
            .font(.system(size: 24, weight: .black))
            .foregroundStyle(color)
            .shadow(color: .black.opacity(0.5), radius: 2)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    offset = -60
                    opacity = 0
                }
            }
    }
}

/// Particle effect for special matches
struct ParticleView: View {
    let color: Color
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .offset(offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                let randomAngle = Double.random(in: 0...(2 * .pi))
                let randomDistance = CGFloat.random(in: 30...60)
                
                withAnimation(.easeOut(duration: 0.6)) {
                    offset = CGSize(
                        width: cos(randomAngle) * randomDistance,
                        height: sin(randomAngle) * randomDistance
                    )
                    opacity = 0
                    scale = 0.5
                }
            }
    }
}

/// Glow effect for special tiles
struct GlowEffect: ViewModifier {
    let color: Color
    let intensity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.8), radius: intensity * 5)
            .shadow(color: color.opacity(0.5), radius: intensity * 10)
            .shadow(color: color.opacity(0.3), radius: intensity * 15)
    }
}

extension View {
    func glow(color: Color, intensity: CGFloat = 1.0) -> some View {
        modifier(GlowEffect(color: color, intensity: intensity))
    }
}

/// Pulse animation for buttons and indicators
struct PulseEffect: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .opacity(isAnimating ? 0.8 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    func pulse() -> some View {
        modifier(PulseEffect())
    }
}

/// Screen shake effect for impactful moments
struct ScreenShake: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: CGFloat.random(in: -amount...amount),
            y: CGFloat.random(in: -amount...amount)
        ))
    }
}
