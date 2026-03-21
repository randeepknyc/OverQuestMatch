//
//  BonusBlastEffects.swift
//  OverQuestMatch3
//
//  ☕ BONUS TILE BLAST EFFECTS - Visual effects for bonus tile activation
//

import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⚙️ BLAST EFFECT SETTINGS (USER-ADJUSTABLE)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct BlastEffectConfig {
    /// Enable or disable blast effects
    static let enabled: Bool = true
    
    /// Blast animation duration (seconds)
    /// 0.3 = Fast blast
    /// 0.6 = Medium (recommended)
    /// 1.0 = Slow, dramatic
    static let duration: Double = 0.6
    
    /// Blast color
    /// .yellow = Golden blast (default)
    /// .orange = Fire blast
    /// .cyan = Ice blast
    /// .purple = Magic blast
    static let color: Color = .white
    
    /// Blast width (for row blasts) or height (for column blasts)
    /// 0.5 = Thin beam
    /// 0.8 = Medium beam (recommended)
    /// 1.2 = Thick beam
    static let thickness: CGFloat = 0.8
    
    /// Number of particles along the blast
    /// 8 = Sparse
    /// 15 = Medium (recommended)
    /// 30 = Dense
    static let particleCount: Int = 15
    
    /// Particle size
    /// 4 = Tiny
    /// 8 = Medium (recommended)
    /// 16 = Large
    static let particleSize: CGFloat = 8
    
    /// Should particles scatter perpendicular to blast?
    /// true = Particles spray outward (recommended)
    /// false = Particles stay in line
    static let scatterParticles: Bool = true
    
    /// Maximum scatter distance (pixels)
    /// 20 = Subtle
    /// 40 = Medium (recommended)
    /// 80 = Wide scatter
    static let scatterDistance: CGFloat = 40
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 💥 BONUS BLAST VIEW (Main container)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct BonusBlastView: View {
    let blastData: BonusBlastData
    let boardSize: Int
    let tileSize: CGFloat
    
    var body: some View {
        if blastData.useCustomImages {
            CustomImageBlast(blastData: blastData, boardSize: boardSize, tileSize: tileSize)
        } else {
            CodeBasedBlast(blastData: blastData, boardSize: boardSize, tileSize: tileSize)
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTION 1: CODE-BASED BLAST (Pure SwiftUI)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct CodeBasedBlast: View {
    let blastData: BonusBlastData
    let boardSize: Int
    let tileSize: CGFloat
    
    @State private var animationProgress: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var particles: [BlastParticle] = []
    
    var body: some View {
        ZStack {
            blastBeam
            particlesView
        }
        .onAppear {
            createParticles()
            animateBlast()
        }
    }
    
    private var blastBeam: some View {
        Group {
            if blastData.isRow {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                BlastEffectConfig.color.opacity(0.3),
                                BlastEffectConfig.color,
                                BlastEffectConfig.color,
                                BlastEffectConfig.color.opacity(0.3),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: CGFloat(boardSize) * tileSize * animationProgress,
                        height: tileSize * BlastEffectConfig.thickness
                    )
                    .position(
                        x: (CGFloat(boardSize) * tileSize * animationProgress) / 2,
                        y: CGFloat(blastData.position.row) * tileSize + tileSize / 2
                    )
                    .opacity(opacity)
                    .shadow(color: BlastEffectConfig.color.opacity(0.8), radius: 20)
                    .shadow(color: BlastEffectConfig.color.opacity(0.5), radius: 40)
                    .blendMode(.screen)
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                BlastEffectConfig.color.opacity(0.3),
                                BlastEffectConfig.color,
                                BlastEffectConfig.color,
                                BlastEffectConfig.color.opacity(0.3),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: tileSize * BlastEffectConfig.thickness,
                        height: CGFloat(boardSize) * tileSize * animationProgress
                    )
                    .position(
                        x: CGFloat(blastData.position.col) * tileSize + tileSize / 2,
                        y: (CGFloat(boardSize) * tileSize * animationProgress) / 2
                    )
                    .opacity(opacity)
                    .shadow(color: BlastEffectConfig.color.opacity(0.8), radius: 20)
                    .shadow(color: BlastEffectConfig.color.opacity(0.5), radius: 40)
                    .blendMode(.screen)
            }
        }
    }
    
    private var particlesView: some View {
        ForEach(particles) { particle in
            Circle()
                .fill(BlastEffectConfig.color)
                .frame(width: BlastEffectConfig.particleSize, height: BlastEffectConfig.particleSize)
                .position(
                    x: particle.x + particle.offsetX * animationProgress,
                    y: particle.y + particle.offsetY * animationProgress
                )
                .opacity(opacity * particle.opacity)
                .scaleEffect(particle.scale)
                .shadow(color: BlastEffectConfig.color.opacity(0.6), radius: 8)
                .blendMode(.screen)
        }
    }
    
    private func createParticles() {
        particles = []
        
        for i in 0..<BlastEffectConfig.particleCount {
            let progress = CGFloat(i) / CGFloat(BlastEffectConfig.particleCount)
            
            if blastData.isRow {
                let baseX = progress * CGFloat(boardSize) * tileSize
                let baseY = CGFloat(blastData.position.row) * tileSize + tileSize / 2
                let offsetX: CGFloat = 0
                let offsetY = BlastEffectConfig.scatterParticles ? CGFloat.random(in: -BlastEffectConfig.scatterDistance...BlastEffectConfig.scatterDistance) : 0
                
                particles.append(BlastParticle(
                    x: baseX,
                    y: baseY,
                    offsetX: offsetX,
                    offsetY: offsetY,
                    scale: CGFloat.random(in: 0.5...1.5),
                    opacity: Double.random(in: 0.6...1.0)
                ))
            } else {
                let baseX = CGFloat(blastData.position.col) * tileSize + tileSize / 2
                let baseY = progress * CGFloat(boardSize) * tileSize
                let offsetX = BlastEffectConfig.scatterParticles ? CGFloat.random(in: -BlastEffectConfig.scatterDistance...BlastEffectConfig.scatterDistance) : 0
                let offsetY: CGFloat = 0
                
                particles.append(BlastParticle(
                    x: baseX,
                    y: baseY,
                    offsetX: offsetX,
                    offsetY: offsetY,
                    scale: CGFloat.random(in: 0.5...1.5),
                    opacity: Double.random(in: 0.6...1.0)
                ))
            }
        }
    }
    
    private func animateBlast() {
        withAnimation(.easeOut(duration: BlastEffectConfig.duration * 0.4)) {
            animationProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + BlastEffectConfig.duration * 0.6) {
            withAnimation(.easeOut(duration: BlastEffectConfig.duration * 0.4)) {
                opacity = 0.0
            }
        }
    }
}

struct BlastParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    let scale: CGFloat
    let opacity: Double
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTION 2: CUSTOM IMAGE-BASED BLAST
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct CustomImageBlast: View {
    let blastData: BonusBlastData
    let boardSize: Int
    let tileSize: CGFloat
    
    @State private var currentFrame: Int = 1
    @State private var opacity: Double = 1.0
    @State private var scaleProgress: CGFloat = 0.0  // NEW: Animation scale
    
    var body: some View {
        Group {
            if blastData.isRow {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: CGFloat(boardSize) * tileSize * scaleProgress,  // Expand from 0 to full width
                        height: tileSize * BlastEffectConfig.thickness
                    )
                    .position(
                        x: CGFloat(blastData.position.col) * tileSize + tileSize / 2,  // Origin at match position
                        y: CGFloat(blastData.position.row) * tileSize + tileSize / 2
                    )
                    .opacity(opacity)
                    .blendMode(.screen)
            } else {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: tileSize * BlastEffectConfig.thickness,
                        height: CGFloat(boardSize) * tileSize * scaleProgress  // Expand from 0 to full height
                    )
                    .position(
                        x: CGFloat(blastData.position.col) * tileSize + tileSize / 2,
                        y: CGFloat(blastData.position.row) * tileSize + tileSize / 2  // Origin at match position
                    )
                    .opacity(opacity)
                    .blendMode(.screen)
            }
        }
        .onAppear {
            // Animate the expansion
            withAnimation(.easeOut(duration: BlastEffectConfig.duration * 0.4)) {
                scaleProgress = 1.0
            }
            animateFrames()
        }
    }
    
    private var imageName: String {
        let direction = blastData.isRow ? "row" : "col"
        return "bonus_blast_\(direction)_\(currentFrame)"
    }
    
    private func animateFrames() {
        let frameDuration = 1.0 / blastData.frameRate
        
        Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { timer in
            if currentFrame < blastData.frameCount {
                currentFrame += 1
            } else {
                timer.invalidate()
                withAnimation(.easeOut(duration: 0.2)) {
                    opacity = 0.0
                }
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA STRUCTURE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct BonusBlastData: Identifiable {
    let id: UUID
    let position: GridPosition
    let isRow: Bool
    let color: Color
    var useCustomImages: Bool = false
    var frameCount: Int = 6
    var frameRate: Double = 12
    
    init(position: GridPosition, isRow: Bool, color: Color, id: UUID, useCustomImages: Bool = false, frameCount: Int = 6, frameRate: Double = 12) {
        self.position = position
        self.isRow = isRow
        self.color = color
        self.id = id
        self.useCustomImages = useCustomImages
        self.frameCount = frameCount
        self.frameRate = frameRate
    }
}
