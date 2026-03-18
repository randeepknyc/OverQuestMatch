//
//  GameBoardView.swift
//  OverQuestMatch3
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════
// 🎬 ANIMATION CONTROLS - SEPARATED BY TYPE
// ═══════════════════════════════════════════════════════════════

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 💥 MATCH DISAPPEAR ANIMATION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct MatchDisappearAnimation {
    static let duration: Double = 0.3
    static let scaleEnd: Double = 0.01
    static let useOpacityFade: Bool = false
    static let useBuzzShake: Bool = true
    static let buzzDuration: Double = 0.15
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🔄 SWAP ANIMATION (Gems trading places)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct SwapAnimation {
    static let duration: Double = 0.2
    static let useSpring: Bool = false
    static let springStiffness: Double = 120
    static let springDamping: Double = 18
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⬇️ GRAVITY/FALL ANIMATION (Existing gems falling down)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct GravityFallAnimation {
    static let enabled: Bool = true
    static let verticalDelay: Double = 0.05
    static let columnDelay: Double = 0.03
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🌧️ SPAWN ANIMATION (New gems appearing from top during gameplay)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct SpawnAnimation {
    static let enabled: Bool = true
    static let startScale: Double = 0.3
    static let startOpacity: Double = 0.0
    static let dropDistance: Double = -150
    static let duration: Double = 0.4
    static let springDamping: Double = 0.7
    static let columnDelay: Double = 0.02
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎮 INITIAL BOARD FILL (Game start/restart)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct InitialFillAnimation {
    static let enabled: Bool = true
    static let startScale: Double = 0.0
    static let startOpacity: Double = 0.0
    static let dropDistance: Double = -150
    static let rowDelay: Double = 0.1
    static let randomVariation: Double = 0.1
    static let duration: Double = 0.4
    static let springDamping: Double = 0.7
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📳 INVALID SWAP SHAKE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct InvalidSwapShake {
    static let enabled: Bool = true
    static let duration: Double = 0.05
    static let repeatCount: Int = 6
    static let distance: CGFloat = 5.0
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 💥 EXPLOSION EFFECT (Particles when gems match)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct ExplosionEffect {
    static let enabled: Bool = true
    static let particleCount: Int = 12
    static let particleSize: CGFloat = 10
    static let burstRadius: CGFloat = 60
    static let duration: Double = 0.4
    static let fadeOut: Bool = true
}

// ═══════════════════════════════════════════════════════════════

struct GameBoardView: View {
    @Bindable var viewModel: GameViewModel
    let gameMode: GameMode
    @Namespace private var tileNamespace
    
    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let tileSize = (boardSize - 16) / CGFloat(viewModel.boardManager.size)
            
            ZStack {
                Color.black.opacity(0.3)
                
                boardContent(tileSize: tileSize)
                    .frame(
                        width: CGFloat(viewModel.boardManager.size) * tileSize,
                        height: CGFloat(viewModel.boardManager.size) * tileSize
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    @ViewBuilder
    private func boardContent(tileSize: CGFloat) -> some View {
        ZStack {
            backgroundGrid(tileSize: tileSize)
            tilesLayer(tileSize: tileSize)
            
            if ExplosionEffect.enabled {
                ForEach(viewModel.explosionParticles, id: \.id) { explosion in
                    ExplosionParticleView(color: explosion.color, tileSize: tileSize)
                        .position(
                            x: CGFloat(explosion.position.col) * tileSize + tileSize / 2,
                            y: CGFloat(explosion.position.row) * tileSize + tileSize / 2 - (tileSize / 2)
                        )
                        .allowsHitTesting(false)
                }
            }
            
            if gameMode == .chain, let handler = viewModel.chainHandler {
                if handler.chainLength > 0, let chainType = handler.chainTileType {
                    ChainConnectionView(
                        chainPositions: handler.activeChain,
                        tileSize: tileSize,
                        color: chainType.color
                    )
                    .allowsHitTesting(false)
                    
                    VStack {
                        ChainCounterView(
                            chainLength: handler.chainLength,
                            isValid: handler.isChainValid,
                            tileType: chainType
                        )
                        .padding(.top, 8)
                        Spacer()
                    }
                    .allowsHitTesting(false)
                }
            }
        }
        .highPriorityGesture(gameMode == .chain ? chainDragGesture(tileSize: tileSize) : nil)
    }
    
    private func chainDragGesture(tileSize: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let handler = viewModel.chainHandler else { return }
                let location = value.location
                if let gridPos = handler.gridPosition(from: location, tileSize: tileSize, boardSize: viewModel.boardManager.size) {
                    if handler.chainLength == 0 {
                        if let tileAtPos = viewModel.boardManager.gem(at: gridPos) {
                            handler.chainTileType = tileAtPos.type
                            handler.startChain(at: gridPos)
                        }
                    } else {
                        if let tileAtPos = viewModel.boardManager.gem(at: gridPos),
                           tileAtPos.type == handler.chainTileType {
                            _ = handler.extendChain(to: gridPos)
                        }
                    }
                }
            }
            .onEnded { _ in
                guard let handler = viewModel.chainHandler else { return }
                let result = handler.endChain()
                if result.isValid, let type = result.type {
                    Task {
                        await viewModel.processChainRelease(positions: result.chain, type: type)
                    }
                }
            }
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
                y: CGFloat(row) * tileSize + tileSize / 2 - (tileSize / 2)
            )
    }
    
    @ViewBuilder
    private func tilesLayer(tileSize: CGFloat) -> some View {
        ForEach(viewModel.boardManager.gems) { gem in
            gemView(gem: gem, tileSize: tileSize)
        }
    }
    
    @ViewBuilder
    private func gemView(gem: Tile, tileSize: CGFloat) -> some View {
        let position = GridPosition(row: gem.row, col: gem.col)
        
        GemTileView(
            tile: gem,
            position: position,
            isSelected: viewModel.selectedPosition == position,
            isShaking: viewModel.shakeTiles.contains(position),
            isInChain: gameMode == .chain && (viewModel.chainHandler?.isInChain(position) ?? false),
            size: tileSize,
            gameMode: gameMode,
            spawnDelay: gem.spawnDelay,
            fallDelay: gem.fallDelay,
            matchCenter: nil,
            onTap: {
                Task { await viewModel.handleTileTap(at: position) }
            },
            onSwipe: { direction in
                let targetPosition: GridPosition?
                switch direction {
                case .up:
                    targetPosition = gem.row > 0 ? GridPosition(row: gem.row - 1, col: gem.col) : nil
                case .down:
                    targetPosition = gem.row < viewModel.boardManager.size - 1 ? GridPosition(row: gem.row + 1, col: gem.col) : nil
                case .left:
                    targetPosition = gem.col > 0 ? GridPosition(row: gem.row, col: gem.col - 1) : nil
                case .right:
                    targetPosition = gem.col < viewModel.boardManager.size - 1 ? GridPosition(row: gem.row, col: gem.col + 1) : nil
                }
                
                if let target = targetPosition {
                    Task {
                        await viewModel.handleTileTap(at: position)
                        await viewModel.handleTileTap(at: target)
                    }
                }
            }
        )
        .id(gem.id)
        .position(
            x: CGFloat(gem.col) * tileSize + tileSize / 2,
            y: CGFloat(gem.row) * tileSize + tileSize / 2 - (tileSize / 2)
        )
        .animation(
            gem.fallDelay > 0
                ? .easeIn(duration: 0.3).delay(gem.fallDelay)
                : .easeIn(duration: 0.3),
            value: gem.row
        )
        .animation(.easeInOut(duration: 0.4), value: gem.col)
        .transition(
            .asymmetric(
                insertion: .identity,
                removal: .opacity
            )
        )
    }
}

struct GemTileView: View {
    let tile: Tile
    let position: GridPosition
    let isSelected: Bool
    let isShaking: Bool
    let isInChain: Bool
    let size: CGFloat
    let gameMode: GameMode
    let spawnDelay: Double
    let fallDelay: Double
    let matchCenter: GridPosition?
    let onTap: () -> Void
    let onSwipe: (SwipeDirection) -> Void
    
    @State private var shakeOffset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var hasAppeared = false
    @State private var currentTileID: UUID?
    @State private var matchSlideOffset: CGSize = .zero
    @State private var matchShrinkScale: CGFloat = 1.0
    @State private var landingBounce: CGFloat = 1.0
    
    var body: some View {
        mainContent
            .frame(width: size, height: size)
            .scaleEffect(effectiveScale)
            .offset(totalOffset)
            .scaleEffect(spawnScaleEffect)
            .opacity(spawnOpacityEffect)
            .offset(y: spawnOffsetEffect)
            .animation(.easeInOut(duration: 0.25), value: isSelected)
            .onChange(of: isShaking, onShakingChanged)
            .onChange(of: tile.id, onTileIDChanged)
            .animation(fallAnimation, value: position)
            .onChange(of: position, onPositionChanged)
            .onChange(of: matchCenter, onMatchCenterChanged)
            .onAppear(perform: onAppearAction)
            .conditionalGestures(gameMode: gameMode, onTap: onTap, onSwipe: onSwipe, size: size, dragOffset: $dragOffset)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            Image(tile.type.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.85, height: size * 0.85)
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                .chainGlow(isInChain: isInChain, color: tile.type.color)
            
            if isSelected {
                selectedOverlay
            }
            
            if tile.isSpecial {
                specialBadge
            }
        }
    }
    
    @ViewBuilder
    private var selectedOverlay: some View {
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
    
    @ViewBuilder
    private var specialBadge: some View {
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
    
    private var effectiveScale: CGFloat {
        isSelected ? 1.15 : (matchShrinkScale * landingBounce)
    }
    
    private var totalOffset: CGSize {
        CGSize(
            width: shakeOffset.width + dragOffset.width + matchSlideOffset.width,
            height: shakeOffset.height + dragOffset.height + matchSlideOffset.height
        )
    }
    
    private var spawnScaleEffect: CGFloat {
        (SpawnAnimation.enabled && spawnDelay > 0 && !hasAppeared) ? SpawnAnimation.startScale : 1.0
    }
    
    private var spawnOpacityEffect: Double {
        (SpawnAnimation.enabled && spawnDelay > 0 && !hasAppeared) ? SpawnAnimation.startOpacity : 1.0
    }
    
    private var spawnOffsetEffect: CGFloat {
        (SpawnAnimation.enabled && spawnDelay > 0 && !hasAppeared) ? SpawnAnimation.dropDistance : 0
    }
    
    private var fallAnimation: Animation {
        fallDelay > 0
            ? .spring(response: 0.3, dampingFraction: 0.6).delay(fallDelay)
            : .spring(response: 0.3, dampingFraction: 0.6)
    }
    
    private func onShakingChanged(_: Bool, _ newValue: Bool) {
        if newValue {
            if InvalidSwapShake.enabled {
                startShaking()
            }
        } else {
            shakeOffset = .zero
        }
    }
    
    private func onTileIDChanged(_: UUID?, _ newID: UUID) {
        currentTileID = newID
        
        if spawnDelay > 0 {
            hasAppeared = false
            Task {
                try? await Task.sleep(for: .seconds(spawnDelay))
                withAnimation(.spring(response: SpawnAnimation.duration, dampingFraction: SpawnAnimation.springDamping)) {
                    hasAppeared = true
                }
            }
        } else {
            hasAppeared = true
        }
    }
    
    private func onPositionChanged(_ oldPosition: GridPosition, _ newPosition: GridPosition) {
        guard oldPosition != newPosition else { return }
        
        landingBounce = 0.85
        
        withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
            landingBounce = 1.15
        }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.08)) {
            landingBounce = 1.0
        }
    }
    
    private func onMatchCenterChanged(_: GridPosition?, _ center: GridPosition?) {
        guard let center = center else {
            matchSlideOffset = .zero
            matchShrinkScale = 1.0
            return
        }
        
        let deltaX = CGFloat(center.col - position.col) * size
        let deltaY = CGFloat(center.row - position.row) * size
        
        withAnimation(.easeIn(duration: MatchDisappearAnimation.duration)) {
            matchSlideOffset = CGSize(width: deltaX, height: deltaY)
            matchShrinkScale = MatchDisappearAnimation.scaleEnd
        }
    }
    
    private func onAppearAction() {
        currentTileID = tile.id
        
        if spawnDelay > 0 {
            hasAppeared = false
            Task {
                try? await Task.sleep(for: .seconds(spawnDelay))
                withAnimation(.spring(response: SpawnAnimation.duration, dampingFraction: SpawnAnimation.springDamping)) {
                    hasAppeared = true
                }
            }
        } else {
            hasAppeared = true
        }
    }
    
    private func startShaking() {
        let animation = Animation.linear(duration: InvalidSwapShake.duration).repeatCount(InvalidSwapShake.repeatCount, autoreverses: true)
        withAnimation(animation) {
            shakeOffset = CGSize(
                width: CGFloat.random(in: -InvalidSwapShake.distance...InvalidSwapShake.distance),
                height: CGFloat.random(in: -InvalidSwapShake.distance...InvalidSwapShake.distance)
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (InvalidSwapShake.duration * Double(InvalidSwapShake.repeatCount))) {
            withAnimation(.easeOut(duration: 0.1)) {
                shakeOffset = .zero
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✨ CHAIN MODE VIEWS (With Rainbow Pulse & Custom Assets Support!)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct ChainConnectionView: View {
    let chainPositions: [GridPosition]
    let tileSize: CGFloat
    let color: Color
    
    @State private var rainbowPhase: Double = 0
    
    var body: some View {
        ZStack {
            // Optional: Custom background image for line
            if ChainVisualConfig.useCustomLineImage {
                customLineImage
            }
            
            // The actual chain line (rainbow or solid color)
            Canvas { context, size in
                guard chainPositions.count > 1 else { return }
                
                var path = Path()
                for (index, pos) in chainPositions.enumerated() {
                    let x = CGFloat(pos.col) * tileSize + tileSize / 2
                    let y = CGFloat(pos.row) * tileSize + tileSize / 2 - (tileSize / 2)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                // Choose color: rainbow or original gem color
                let strokeColor = ChainVisualConfig.enableRainbowPulse
                    ? currentRainbowColor()
                    : color.opacity(ChainVisualConfig.lineOpacity)
                
                // Draw the line
                context.stroke(
                    path,
                    with: .color(strokeColor),
                    lineWidth: ChainVisualConfig.lineWidth
                )
            }
            .shadow(
                color: ChainVisualConfig.enableLineGlow
                    ? (ChainVisualConfig.enableRainbowPulse ? currentRainbowColor() : color)
                    : .clear,
                radius: ChainVisualConfig.lineGlowRadius
            )
        }
        .onAppear {
            if ChainVisualConfig.enableRainbowPulse {
                startRainbowAnimation()
            }
        }
    }
    
    private var customLineImage: some View {
        // If you add a custom image, it will display here
        Image(ChainVisualConfig.customLineImageName)
            .resizable(resizingMode: .tile)
            .opacity(0.3)
    }
    
    private func currentRainbowColor() -> Color {
        let colors = ChainVisualConfig.rainbowColors
        let index = Int(rainbowPhase) % colors.count
        let nextIndex = (index + 1) % colors.count
        let progress = rainbowPhase.truncatingRemainder(dividingBy: 1.0)
        
        // Smooth blend between colors
        return colors[index].opacity(1.0 - progress)
            .blended(with: colors[nextIndex].opacity(progress))
    }
    
    private func startRainbowAnimation() {
        withAnimation(
            .linear(duration: ChainVisualConfig.rainbowSpeed)
            .repeatForever(autoreverses: false)
        ) {
            rainbowPhase = Double(ChainVisualConfig.rainbowColors.count)
        }
    }
}

struct ChainCounterView: View {
    let chainLength: Int
    let isValid: Bool
    let tileType: TileType
    
    @State private var rainbowPhase: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "link")
                .font(.system(size: ChainVisualConfig.counterIconSize, weight: .bold))
            
            Text("\(chainLength)")
                .font(.gameScore(size: ChainVisualConfig.counterFontSize))
            
            Image(tileType.imageName)
                .resizable()
                .frame(width: ChainVisualConfig.counterGemSize, height: ChainVisualConfig.counterGemSize)
        }
        .padding(.horizontal, ChainVisualConfig.counterPaddingH)
        .padding(.vertical, ChainVisualConfig.counterPaddingV)
        .background(
            ZStack {
                // Option 1: Custom background image
                if ChainVisualConfig.useCustomCounterImage {
                    Image(ChainVisualConfig.customCounterImageName)
                        .resizable()
                } else {
                    // Option 2: Default capsule with rainbow or solid color
                    Capsule()
                        .fill(backgroundColor)
                }
            }
        )
        .foregroundColor(.white)
        .shadow(
            color: ChainVisualConfig.enableRainbowPulse
                ? currentRainbowColor()
                : tileType.color,
            radius: ChainVisualConfig.counterShadowRadius
        )
        .scaleEffect(pulseScale)
        .onAppear {
            if ChainVisualConfig.enableRainbowPulse {
                startRainbowAnimation()
            }
            startPulseAnimation()
        }
    }
    
    private var backgroundColor: Color {
        if ChainVisualConfig.enableRainbowPulse {
            return currentRainbowColor()
                .opacity(isValid ? ChainVisualConfig.counterValidOpacity : ChainVisualConfig.counterInvalidOpacity)
        } else {
            return isValid
                ? tileType.color.opacity(ChainVisualConfig.counterValidOpacity)
                : Color.gray.opacity(ChainVisualConfig.counterInvalidOpacity)
        }
    }
    
    private func currentRainbowColor() -> Color {
        let colors = ChainVisualConfig.rainbowColors
        let index = Int(rainbowPhase) % colors.count
        let nextIndex = (index + 1) % colors.count
        let progress = rainbowPhase.truncatingRemainder(dividingBy: 1.0)
        
        return colors[index].opacity(1.0 - progress)
            .blended(with: colors[nextIndex].opacity(progress))
    }
    
    private func startRainbowAnimation() {
        withAnimation(
            .linear(duration: ChainVisualConfig.rainbowSpeed)
            .repeatForever(autoreverses: false)
        ) {
            rainbowPhase = Double(ChainVisualConfig.rainbowColors.count)
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: ChainVisualConfig.pulseDuration)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = ChainVisualConfig.counterPulseScale
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER EXTENSIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension Color {
    func blended(with other: Color) -> Color {
        let selfComponents = self.components
        let otherComponents = other.components
        
        return Color(
            red: min(1.0, selfComponents.red + otherComponents.red),
            green: min(1.0, selfComponents.green + otherComponents.green),
            blue: min(1.0, selfComponents.blue + otherComponents.blue)
        )
    }
    
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        #if canImport(UIKit)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        return (Double(r), Double(g), Double(b), Double(o))
        #else
        let nsColor = NSColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &o)
        return (Double(r), Double(g), Double(b), Double(o))
        #endif
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VIEW MODIFIERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension View {
    @ViewBuilder
    func chainGlow(isInChain: Bool, color: Color) -> some View {
        if isInChain {
            self
                .shadow(color: color.opacity(0.6), radius: 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.8), lineWidth: 3)
                )
        } else {
            self
        }
    }
    
    @ViewBuilder
    func conditionalGestures(gameMode: GameMode, onTap: @escaping () -> Void, onSwipe: @escaping (SwipeDirection) -> Void, size: CGFloat, dragOffset: Binding<CGSize>) -> some View {
        if gameMode == .swap {
            self
                .onTapGesture { onTap() }
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            let maxOffset = size * 0.35
                            let clampedX = Self.clampWithEasing(value.translation.width, max: maxOffset)
                            let clampedY = Self.clampWithEasing(value.translation.height, max: maxOffset)
                            dragOffset.wrappedValue = CGSize(width: clampedX, height: clampedY)
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 25
                            let absWidth = abs(value.translation.width)
                            let absHeight = abs(value.translation.height)
                            let horizontal = absWidth > absHeight
                            
                            if horizontal && absWidth > threshold {
                                onSwipe(value.translation.width > 0 ? .right : .left)
                            } else if !horizontal && absHeight > threshold {
                                onSwipe(value.translation.height > 0 ? .down : .up)
                            }
                            
                            withAnimation(.interpolatingSpring(stiffness: 450, damping: 5)) {
                                dragOffset.wrappedValue = .zero
                            }
                        }
                )
        } else {
            self
        }
    }
    
    private static func clampWithEasing(_ value: CGFloat, max: CGFloat) -> CGFloat {
        let absValue = abs(value)
        if absValue <= max { return value }
        let excess = absValue - max
        let dampened = max + (excess * 0.3)
        return value > 0 ? dampened : -dampened
    }
}

enum SwipeDirection { case up, down, left, right }

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 💥 EXPLOSION PARTICLE VIEW
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct ExplosionParticleView: View {
    let color: Color
    let tileSize: CGFloat
    
    @State private var particles: [ParticleData] = []
    
    struct ParticleData: Identifiable {
        let id = UUID()
        let angle: Double
        var offset: CGFloat = 0
        var opacity: Double = 1.0
        var scale: CGFloat = 1.0
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(color)
                    .frame(width: ExplosionEffect.particleSize, height: ExplosionEffect.particleSize)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .offset(
                        x: cos(particle.angle) * particle.offset,
                        y: sin(particle.angle) * particle.offset
                    )
            }
        }
        .frame(width: tileSize, height: tileSize)
        .onAppear {
            createParticles()
            animateExplosion()
        }
    }
    
    private func createParticles() {
        particles = (0..<ExplosionEffect.particleCount).map { i in
            let angle = (Double(i) / Double(ExplosionEffect.particleCount)) * 2 * .pi
            return ParticleData(angle: angle)
        }
    }
    
    private func animateExplosion() {
        withAnimation(.easeOut(duration: ExplosionEffect.duration)) {
            for i in particles.indices {
                particles[i].offset = ExplosionEffect.burstRadius
                if ExplosionEffect.fadeOut {
                    particles[i].opacity = 0
                }
                particles[i].scale = 0.5
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER SHAPES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
        hexagon.inset += amount
        return hexagon
    }
}

struct PlaceholderTileView: View {
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(LinearGradient(
                colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(width: size * 0.85, height: size * 0.85)
            .overlay {
                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(Color.white.opacity(0.2))
            }
    }
}
