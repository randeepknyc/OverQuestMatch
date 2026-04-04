//
//  PhysicsChainGameView.swift
//  OverQuestMatch3 - Physics Chain Game
//
//  Created on 3/28/26.
//

import SwiftUI

struct PhysicsChainGameView: View {
    @State private var viewModel: PhysicsGameViewModel?
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.2, green: 0.1, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Score header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCORE")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                            Text("\(viewModel?.score ?? 0)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        Spacer()
                        
                        if let combo = viewModel?.comboCount, combo > 0 {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("COMBO")
                                    .font(.caption)
                                    .foregroundStyle(.orange.opacity(0.9))
                                Text("×\(combo)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    
                    // Game board
                    if let viewModel {
                        ZStack {
                            // Tiles
                            ForEach(viewModel.tiles) { tile in
                                PhysicsTileView(tile: tile, size: PhysicsGameConfig.tileSize)
                                    .position(tile.position)
                            }
                            
                            // Chain line
                            if viewModel.selectedTiles.count > 1 {
                                PhysicsChainLineView(tiles: viewModel.selectedTiles)
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height - 100)
                        .background(Color.black.opacity(0.3))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    viewModel.handleTouch(at: value.location)
                                }
                                .onEnded { _ in
                                    Task {
                                        await viewModel.endChain()
                                    }
                                }
                        )
                    }
                }
            }
            .onAppear {
                setupGame(size: geometry.size)
            }
            .onDisappear {
                // Clean up timer when view disappears
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    func setupGame(size: CGSize) {
        print("🎮 Physics Chain Game started - Board: \(Int(size.width))×\(Int(size.height-100))")
        viewModel = PhysicsGameViewModel(boardWidth: size.width, boardHeight: size.height - 100)
        
        // Start physics timer (60 FPS)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            viewModel?.updatePhysics()
        }
    }
}

// Visual chain connecting line (ANIMATED!)
struct PhysicsChainLineView: View {
    let tiles: [PhysicsTile]
    @State private var dashPhase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                guard tiles.count > 1 else { return }
                
                // Animate the dash phase based on time
                let animatedPhase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.0) * 16
                
                var path = Path()
                
                if tiles.count == 2 {
                    // Just 2 tiles: draw straight line
                    path.move(to: tiles[0].position)
                    path.addLine(to: tiles[1].position)
                } else {
                    // 3+ tiles: draw smooth curve using quadratic curves
                    path.move(to: tiles[0].position)
                    
                    for i in 1..<tiles.count {
                        let current = tiles[i].position
                        
                        if i == tiles.count - 1 {
                            // Last segment: curve to final point
                            let previous = tiles[i - 1].position
                            let controlPoint = CGPoint(
                                x: (previous.x + current.x) / 2,
                                y: (previous.y + current.y) / 2
                            )
                            path.addQuadCurve(to: current, control: controlPoint)
                        } else {
                            // Middle segments: smooth curve through points
                            let next = tiles[i + 1].position
                            let controlPoint = current
                            let endPoint = CGPoint(
                                x: (current.x + next.x) / 2,
                                y: (current.y + next.y) / 2
                            )
                            path.addQuadCurve(to: endPoint, control: controlPoint)
                        }
                    }
                }
                
                // Animated glow effect
                context.stroke(
                    path,
                    with: .color(tiles[0].type.glowColor.opacity(0.4)),
                    style: StrokeStyle(
                        lineWidth: PhysicsGameConfig.chainLineWidth + 8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                
                // Animated dashed line that moves!
                context.stroke(
                    path,
                    with: .color(tiles[0].type.glowColor),
                    style: StrokeStyle(
                        lineWidth: PhysicsGameConfig.chainLineWidth,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [8, 8],
                        dashPhase: animatedPhase  // Animated!
                    )
                )
            }
        }
    }
}

#Preview {
    PhysicsChainGameView()
}
