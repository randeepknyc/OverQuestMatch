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
                // ☕ HORIZONTAL BLAST: Expands FROM bonus gem position outward (left AND right)
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
                        // ✅ FIXED: Center the blast AT the bonus gem column (not board center)
                        x: CGFloat(blastData.position.col) * tileSize + tileSize / 2,
                        y: CGFloat(blastData.position.row) * tileSize + tileSize / 2
                    )
                    .opacity(opacity)
                    .shadow(color: BlastEffectConfig.color.opacity(0.8), radius: 20)
                    .shadow(color: BlastEffectConfig.color.opacity(0.5), radius: 40)
                    .blendMode(.screen)
            } else {
                // ☕ VERTICAL BLAST: Expands FROM bonus gem position outward (up AND down)
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
                        // ✅ FIXED: Center the blast AT the bonus gem row (not board center)
                        x: CGFloat(blastData.position.col) * tileSize + tileSize / 2,
                        y: CGFloat(blastData.position.row) * tileSize + tileSize / 2
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
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ⚡ BLAST POSITIONING & STRETCH CONTROLS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    // 📏 HORIZONTAL BLAST CONTROLS (when isRow == true)
    // ════════════════════════════════════════════════════════════════
    
    /// Width multiplier for HORIZONTAL blasts (how far left/right it extends)
    /// 1.0 = Exactly board width (default)
    /// 2.0 = 2x wider than board (extends beyond edges)
    /// 0.8 = 80% of board width (doesn't reach edges)
    private let horizontalWidthMultiplier: CGFloat = 2.0
    
    /// Thickness multiplier for HORIZONTAL blasts (how tall the beam is)
    /// 1.0 = Normal thickness (default)
    /// 1.5 = 50% thicker beam
    /// 0.5 = 50% thinner beam
    private let horizontalThicknessMultiplier: CGFloat = 1.0
    
    /// Horizontal offset for HORIZONTAL blasts (moves blast left/right)
    /// 0 = Centered at bonus gem (default)
    /// 20 = Shifted 20 pixels right
    /// -20 = Shifted 20 pixels left
    private let horizontalXOffset: CGFloat = 0
    
    /// Vertical offset for HORIZONTAL blasts (moves blast up/down)
    /// 0 = Centered at bonus gem (default)
    /// -30 = Shifted 30 pixels up
    /// 20 = Shifted 20 pixels down
    private let horizontalYOffset: CGFloat = -30
    
    // 📏 VERTICAL BLAST CONTROLS (when isRow == false)
    // ════════════════════════════════════════════════════════════════
    
    /// Height multiplier for VERTICAL blasts (how far up/down it extends)
    /// 1.0 = Exactly board height (default)
    /// 2.0 = 2x taller than board
    /// 0.8 = 80% of board height
    private let verticalHeightMultiplier: CGFloat = 2.5
    
    /// Thickness multiplier for VERTICAL blasts (how wide the beam is)
    /// 1.0 = Normal thickness (default)
    /// 1.5 = 50% thicker beam
    /// 0.5 = 50% thinner beam
    private let verticalThicknessMultiplier: CGFloat = 1.0
    
    /// Horizontal offset for VERTICAL blasts (moves blast left/right)
    /// 0 = Centered at bonus gem (default)
    /// -30 = Shifted 30 pixels left
    /// 20 = Shifted 20 pixels right
    private let verticalXOffset: CGFloat = 0
    
    /// Vertical offset for VERTICAL blasts (moves blast up/down)
    /// 0 = Centered at bonus gem (default)
    /// -30 = Shifted 30 pixels up
    /// 20 = Shifted 20 pixels down
    private let verticalYOffset: CGFloat = 0
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    var body: some View {
        Group {
            if blastData.isRow {
                // HORIZONTAL BLAST: Uses horizontal-specific controls
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: CGFloat(boardSize) * tileSize * scaleProgress * horizontalWidthMultiplier,
                        height: tileSize * BlastEffectConfig.thickness * horizontalThicknessMultiplier
                    )
                    .position(
                        x: CGFloat(blastData.position.col) * tileSize + tileSize / 2 + horizontalXOffset,
                        y: CGFloat(blastData.position.row) * tileSize + tileSize / 2 + horizontalYOffset
                    )
                    .opacity(opacity)
                    .blendMode(.screen)
            } else {
                // VERTICAL BLAST: Uses vertical-specific controls
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: tileSize * BlastEffectConfig.thickness * verticalThicknessMultiplier,
                        height: CGFloat(boardSize) * tileSize * scaleProgress * verticalHeightMultiplier
                    )
                    .position(
                        x: CGFloat(blastData.position.col) * tileSize + tileSize / 2 + verticalXOffset,
                        y: CGFloat(blastData.position.row) * tileSize + tileSize / 2 + verticalYOffset
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
