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
    static let color: Color = .yellow
    
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
            // OPTION 2: Custom image-based animation
            CustomImageBlast(blastData: blastData, boardSize: boardSize, tileSize: tileSize)
        } else {
            // OPTION 1: Code-based blast effect
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
            // Main blast beam
            blastBeam
            
            // Particles along the blast
            particlesView
        }
        .onAppear {
            createParticles()
            animateBlast()
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // BLAST BEAM
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private var blastBeam: some View {
        Group {
            if blastData.isRow {
                // HORIZONTAL BEAM
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
                // VERTICAL BEAM
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
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // PARTICLES
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
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
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ANIMATION LOGIC
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private func createParticles() {
        particles = []
        
        for i in 0..<BlastEffectConfig.particleCount {
            let progress = CGFloat(i) / CGFloat(BlastEffectConfig.particleCount)
            
            if blastData.isRow {
                // Particles along horizontal blast
                let baseX = progress * CGFloat(boardSize) * tileSize
                let baseY = CGFloat(blastData.position.row) * tileSize + tileSize / 2
                
                let offsetX: CGFloat = 0  // Horizontal blast expands horizontally
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
                // Particles along vertical blast
                let baseX = CGFloat(blastData.position.col) * tileSize + tileSize / 2
                let baseY = progress * CGFloat(boardSize) * tileSize
                
                let offsetX = BlastEffectConfig.scatterParticles ? CGFloat.random(in: -BlastEffectConfig.scatterDistance...BlastEffectConfig.scatterDistance) : 0
                let offsetY: CGFloat = 0  // Vertical blast expands vertically
                
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
        // Expand animation
        withAnimation(.easeOut(duration: BlastEffectConfig.duration * 0.4)) {
            animationProgress = 1.0
        }
        
        // Fade out
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
// OPTION 2: CUSTOM IMAGE-BASED BLAST (For hand-drawn animations)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct CustomImageBlast: View {
    let blastData: BonusBlastData
    let boardSize: Int
    let tileSize: CGFloat
    
    @State private var currentFrame: Int = 1
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Group {
            if blastData.isRow {
                // Horizontal blast image
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: CGFloat(boardSize) * tileSize,
                        height: tileSize * BlastEffectConfig.thickness
                    )
                    .position(
                        x: CGFloat(boardSize) * tileSize / 2,
                        y: CGFloat(blastData.position.row) * tileSize + tileSize / 2
                    )
                    .opacity(opacity)
                    .blendMode(.screen)
            } else {
                // Vertical blast image
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: tileSize * BlastEffectConfig.thickness,
                        height: CGFloat(boardSize) * tileSize
                    )
                    .position(
                        x: CGFloat(blastData.position.col) * tileSize + tileSize / 2,
                        y: CGFloat(boardSize) * tileSize / 2
                    )
                    .opacity(opacity)
                    .blendMode(.screen)
            }
        }
        .onAppear {
            animateFrames()
        }
    }
    
    private var imageName: String {
        let direction = blastData.isRow ? "row" : "col"
        return "bonus_blast_\(direction)_\(currentFrame)"
    }
    
    private func animateFrames() {
        let frameDuration = 1.0 / blastData.frameRate
        
        // Cycle through frames
        Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { timer in
            if currentFrame < blastData.frameCount {
                currentFrame += 1
            } else {
                timer.invalidate()
                // Fade out after last frame
                withAnimation(.easeOut(duration: 0.2)) {
                    opacity = 0.0
                }
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📐 IMAGE SPECIFICATIONS FOR CUSTOM BLAST ANIMATIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/*

IF YOU WANT TO USE CUSTOM IMAGES:

1. CREATE IMAGE FILES:
   
   For HORIZONTAL blast (row):
   - bonus_blast_row_1.png
   - bonus_blast_row_2.png
   - bonus_blast_row_3.png
   - ... (up to frameCount)
   
   For VERTICAL blast (column):
   - bonus_blast_col_1.png
   - bonus_blast_col_2.png
   - bonus_blast_col_3.png
   - ... (up to frameCount)

2. IMAGE SPECIFICATIONS:
   
   HORIZONTAL (row) images:
   - Dimensions: 2048 x 256 pixels (wide and thin)
   - Resolution: 144 DPI
   - Format: PNG with transparency
   - Orientation: Horizontal beam going left-to-right
   - Effect should be centered vertically
   
   VERTICAL (column) images:
   - Dimensions: 256 x 2048 pixels (tall and thin)
   - Resolution: 144 DPI
   - Format: PNG with transparency
   - Orientation: Vertical beam going top-to-bottom
   - Effect should be centered horizontally

3. ANIMATION FRAMES:
   
   Recommended sequence (6 frames):
   - Frame 1: Blast starts to appear (faint)
   - Frame 2: Blast expanding (25% opacity)
   - Frame 3: Blast full power (peak brightness)
   - Frame 4: Blast sustaining (75% intensity)
   - Frame 5: Blast fading (50% intensity)
   - Frame 6: Blast disappearing (25% intensity)
   
   You can do more or fewer frames - just update frameCount

4. ADD TO PROJECT:
   
   - Open Xcode
   - Click Assets.xcassets in left sidebar
   - Drag and drop your PNG files
   - Make sure they're named EXACTLY as shown above

5. ENABLE IN CODE:
   
   In GameViewModel.swift, line ~427, uncomment the custom images section:
   
   bonusBlast = BonusBlastData(
       position: position,
       isRow: clearRow,
       color: .yellow,
       id: UUID(),
       useCustomImages: true,  // ← SET TO TRUE
       frameCount: 6,          // ← YOUR NUMBER OF FRAMES
       frameRate: 12           // ← HOW FAST TO PLAY
   )

*/
