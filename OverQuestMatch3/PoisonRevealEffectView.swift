//
//  PoisonRevealEffectView.swift
//  OverQuestMatch3
//
//  Visual effect when poison pill is revealed
//

import SwiftUI

struct PoisonRevealEffectView: View {
    let position: GridPosition
    let tileSize: CGFloat
    
    @State private var blastScale: CGFloat = 0.1
    @State private var blastOpacity: Double = 1.0
    @State private var smokeScale: CGFloat = 0.5
    @State private var smokeOpacity: Double = 0.0
    @State private var showPoisonTile: Bool = false
    
    var body: some View {
        ZStack {
            // Phase 1: Purple blast explosion
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(0.9),
                            Color.purple.opacity(0.5),
                            Color.purple.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: tileSize * 1.5
                    )
                )
                .frame(width: tileSize * 3, height: tileSize * 3)
                .scaleEffect(blastScale)
                .opacity(blastOpacity)
            
            // Phase 2: Smoke dissipation
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(0.4),
                            Color.purple.opacity(0.2),
                            Color.gray.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: tileSize * 2
                    )
                )
                .frame(width: tileSize * 2.5, height: tileSize * 2.5)
                .scaleEffect(smokeScale)
                .opacity(smokeOpacity)
            
            // Phase 3: Revealed poison pill tile (fading in)
            if showPoisonTile {
                Image("poisonpill_tile")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: tileSize * 0.9, height: tileSize * 0.9)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            // Animation sequence
            withAnimation(.easeOut(duration: 0.3)) {
                blastScale = 3.0
                blastOpacity = 0.0
            }
            
            // Smoke appears after blast
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.4)) {
                    smokeOpacity = 1.0
                    smokeScale = 2.0
                }
            }
            
            // Smoke fades
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.3)) {
                    smokeOpacity = 0.0
                }
            }
            
            // Show poison pill tile
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(duration: 0.3)) {
                    showPoisonTile = true
                }
            }
            
            // Fade out poison tile after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showPoisonTile = false
                }
            }
        }
    }
}
