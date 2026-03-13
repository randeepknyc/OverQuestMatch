//
//  GameBoardView.swift
//  OverQuestMatch3
//

import SwiftUI

struct GameBoardView: View {
    @Bindable var viewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let tileSize = (boardSize - 16) / CGFloat(viewModel.boardManager.size)
            
            boardContent(tileSize: tileSize)
                .frame(
                    width: CGFloat(viewModel.boardManager.size) * tileSize,
                    height: CGFloat(viewModel.boardManager.size) * tileSize
                )
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .background(
            Color(red: 0.15, green: 0.15, blue: 0.2)
                .opacity(0.3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    private func boardContent(tileSize: CGFloat) -> some View {
        ZStack {
            backgroundGrid(tileSize: tileSize)
            tilesLayer(tileSize: tileSize)
        }
        .animation(
            .interpolatingSpring(stiffness: 180, damping: 15),
            value: viewModel.boardManager.tiles.map { $0.map { $0?.id } }
        )
    }
    
    @ViewBuilder
    private func backgroundGrid(tileSize: CGFloat) -> some View {
        ForEach(0..<viewModel.boardManager.size, id: \.self) { row in
            ForEach(0..<viewModel.boardManager.size, id: \.self) { col in
                gridCell(row: row, col: col, tileSize: tileSize)
            }
        }
    }
    
    private func gridCell(row: Int, col: Int, tileSize: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(Color.white.opacity(0.03), lineWidth: 1)
            .frame(width: tileSize * 0.95, height: tileSize * 0.95)
            .position(
                x: CGFloat(col) * tileSize + tileSize / 2,
                y: CGFloat(row) * tileSize + tileSize / 2
            )
    }
    
    @ViewBuilder
    private func tilesLayer(tileSize: CGFloat) -> some View {
        ForEach(0..<viewModel.boardManager.size, id: \.self) { row in
            ForEach(0..<viewModel.boardManager.size, id: \.self) { col in
                tileView(row: row, col: col, tileSize: tileSize)
            }
        }
    }
    
    @ViewBuilder
    private func tileView(row: Int, col: Int, tileSize: CGFloat) -> some View {
        let position = GridPosition(row: row, col: col)
        
        if let tile = viewModel.boardManager.tiles[row][col] {
            let insertionTransition = AnyTransition.offset(y: -tileSize * CGFloat(row + 2))
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.8))
            
            let removalTransition = AnyTransition.scale(scale: 0.01)
                .combined(with: .opacity)
            
            GemTileView(
                tile: tile,
                position: position,
                isSelected: viewModel.selectedPosition == position,
                isShaking: viewModel.shakeTiles.contains(position),
                size: tileSize,
                onTap: {
                    Task {
                        await viewModel.handleTileTap(at: position)
                    }
                },
                onSwipe: { direction in
                    // Convert swipe to adjacent tile tap
                    let targetPosition: GridPosition?
                    switch direction {
                    case .up:
                        targetPosition = position.row > 0 ? GridPosition(row: position.row - 1, col: position.col) : nil
                    case .down:
                        targetPosition = position.row < viewModel.boardManager.size - 1 ? GridPosition(row: position.row + 1, col: position.col) : nil
                    case .left:
                        targetPosition = position.col > 0 ? GridPosition(row: position.row, col: position.col - 1) : nil
                    case .right:
                        targetPosition = position.col < viewModel.boardManager.size - 1 ? GridPosition(row: position.row, col: position.col + 1) : nil
                    }
                    
                    if let target = targetPosition {
                        Task {
                            await viewModel.handleTileTap(at: position)
                            await viewModel.handleTileTap(at: target)
                        }
                    }
                }
            )
            .position(
                x: CGFloat(col) * tileSize + tileSize / 2,
                y: CGFloat(row) * tileSize + tileSize / 2
            )
            .id(tile.id)
            .transition(.asymmetric(
                insertion: insertionTransition,
                removal: removalTransition
            ))
        }
    }
}

struct GemTileView: View {
    let tile: Tile
    let position: GridPosition
    let isSelected: Bool
    let isShaking: Bool
    let size: CGFloat
    let onTap: () -> Void
    let onSwipe: (SwipeDirection) -> Void
    
    @State private var shakeOffset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    
    // ⭐ FIX: Break down complex offset calculation
    private var totalOffsetX: CGFloat {
        shakeOffset.width + dragOffset.width
    }
    
    private var totalOffsetY: CGFloat {
        shakeOffset.height + dragOffset.height
    }
    
    var body: some View {
        ZStack {
            // 🎨 JUST THE IMAGE - NO BACKGROUND
            Image(tile.type.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.85, height: size * 0.85)
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            
            // SELECTION: White glow around image
            if isSelected {
                Image(tile.type.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.85, height: size * 0.85)
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.15)
                            .stroke(Color.white, lineWidth: 4)
                            .blur(radius: 2)
                    )
                    .shadow(color: .white.opacity(0.8), radius: 8)
                    .scaleEffect(1.05)
            }
            
            // Special tile star badge
            if tile.isSpecial {
                Image(systemName: "star.fill")
                    .font(.system(size: size * 0.3))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.6), radius: 2)
                    .offset(x: size * 0.35, y: -size * 0.35)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .offset(x: totalOffsetX, y: totalOffsetY) // ⭐ FIXED: Use computed properties
        // SWAP ANIMATION: Ease-In-Out for selection
        .animation(.easeInOut(duration: 0.25), value: isSelected)
        .onChange(of: isShaking) { _, newValue in
            if newValue {
                startShaking()
            } else {
                shakeOffset = .zero
            }
        }
        // TAP GESTURE
        .onTapGesture {
            onTap()
        }
        // SWIPE GESTURE
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    // Show visual feedback during drag
                    let maxOffset = size * 0.3
                    let clampedX = min(max(value.translation.width, -maxOffset), maxOffset)
                    let clampedY = min(max(value.translation.height, -maxOffset), maxOffset)
                    dragOffset = CGSize(width: clampedX, height: clampedY)
                }
                .onEnded { value in
                    // Determine swipe direction
                    let threshold: CGFloat = 30
                    let absWidth = abs(value.translation.width)
                    let absHeight = abs(value.translation.height)
                    let horizontal = absWidth > absHeight
                    
                    if horizontal && absWidth > threshold {
                        // Horizontal swipe
                        if value.translation.width > 0 {
                            onSwipe(.right)
                        } else {
                            onSwipe(.left)
                        }
                    } else if !horizontal && absHeight > threshold {
                        // Vertical swipe
                        if value.translation.height > 0 {
                            onSwipe(.down)
                        } else {
                            onSwipe(.up)
                        }
                    }
                    
                    // Reset drag offset with animation
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        dragOffset = .zero
                    }
                }
        )
    }
    
    private func startShaking() {
        // Rapid shake for invalid moves
        let animation = Animation.linear(duration: 0.05).repeatCount(6, autoreverses: true)
        withAnimation(animation) {
            shakeOffset = CGSize(width: CGFloat.random(in: -5...5), height: CGFloat.random(in: -5...5))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.1)) {
                shakeOffset = .zero
            }
        }
    }
}

// Swipe direction enum
enum SwipeDirection {
    case up, down, left, right
}

// Hexagon shape kept for reference (not used in image-only mode)
struct HexagonShape: InsettableShape {
    var inset: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let width = rect.width - (inset * 2)
        let height = rect.height - (inset * 2)
        let centerX = rect.midX
        let centerY = rect.midY
        let radius = min(width, height) / 2
        
        var path = Path()
        
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            let x = centerX + radius * cos(angle)
            let y = centerY + radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var hexagon = self
        hexagon.inset = amount
        return hexagon
    }
}

// Placeholder tile shown during refill
struct PlaceholderTileView: View {
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size * 0.85, height: size * 0.85)
            .overlay {
                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(Color.white.opacity(0.2))
            }
    }
}
