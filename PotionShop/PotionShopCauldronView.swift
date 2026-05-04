//
//  PotionShopCauldronView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Cauldron + dice tray
//  Place in: PotionShop/ folder
//
//  PHASE 6: Dice slide between tray and cauldron via matchedGeometryEffect.
//  PHASE 6B: Dice drop in from above when first appearing.
//  PHASE 6D: Drop is now STRAIGHT — no rotation. Dice fall in cleanly
//            without tumbling, landing perfectly aligned in the tray.
//  PHASE 12: ART HOOKUP — Dice faces load from Assets, cauldron layers, background
//  DRAG-AND-DROP: Dice can be dragged from tray to nodes, or tapped (both work).
//
//  NAMING NOTE: PotionShop prefix on every public type. Don't rename.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Layout constants for the cauldron

struct PotionShopCauldronLayout {
    static let boardWidth:  CGFloat = 115
    static let boardHeight: CGFloat = 150

    static let bowlAspect:  CGFloat = 1.65

    static let nodeVisible: CGFloat = 26
    static let nodeHitArea: CGFloat = 36

    static let dieSize:     CGFloat = 44

    static let rimHeight:   CGFloat = 0.06
    static let liquidHeight: CGFloat = 0.20

    static let nodeInsetX:  CGFloat = 0.70
    static let nodeInsetY:  CGFloat = 0.70

    /// How far above the slot dice start when dropping in.
    static let dropInOffset: CGFloat = 80
}

// MARK: - The bowl shape (ellipse clipped to bottom half)

struct PotionShopBowlShape: Shape {
    static let segmentCount: Int = 60

    func path(in rect: CGRect) -> Path {
        let centerX = rect.midX
        let topY = rect.minY
        let a = rect.width / 2.0
        let b = rect.height

        var points: [CGPoint] = []
        let segments = PotionShopBowlShape.segmentCount
        for i in 1...segments {
            let t: Double = Double(i) / Double(segments) * Double.pi
            let x: CGFloat = centerX + a * CGFloat(cos(t))
            let y: CGFloat = topY + b * CGFloat(sin(t))
            points.append(CGPoint(x: x, y: y))
        }

        var path = Path()
        path.move(to: CGPoint(x: centerX - a, y: topY))
        path.addLine(to: CGPoint(x: centerX + a, y: topY))
        for p in points {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Cauldron layout math

private struct CauldronGeometry {
    let bowlW: CGFloat
    let bowlH: CGFloat
    let bowlCenterX: CGFloat
    let bowlOriginY: CGFloat
    let liquidW: CGFloat
    let liquidH: CGFloat
    let nodeOriginX: CGFloat
    let nodeOriginY: CGFloat
    let nodeScale: CGFloat
    let totalW: CGFloat

    static func compute(
        in size: CGSize,
        scale: Double = 1.0,
        xOffset: Double = 0,
        yOffset: Double = 0,
        nodeScaleMultiplier: Double = 1.0,
        nodeXOffset: Double = 0,
        nodeYOffset: Double = 0
    ) -> CauldronGeometry {
        let totalW = size.width
        let totalH = size.height

        let cauldronColW = totalW - 90

        let maxBowlH = totalH * 0.92 * scale
        let maxBowlW = cauldronColW * 0.92 * scale
        let bowlW: CGFloat
        let bowlH: CGFloat
        if maxBowlW / maxBowlH > PotionShopCauldronLayout.bowlAspect {
            bowlH = maxBowlH
            bowlW = bowlH * PotionShopCauldronLayout.bowlAspect
        } else {
            bowlW = maxBowlW
            bowlH = bowlW / PotionShopCauldronLayout.bowlAspect
        }

        let bowlCenterX = cauldronColW / 2 + xOffset
        let bowlOriginY = (totalH - bowlH) / 2 + yOffset

        let liquidH = bowlH * PotionShopCauldronLayout.liquidHeight
        let liquidW = bowlW * 0.94

        let nodeAreaW = bowlW * PotionShopCauldronLayout.nodeInsetX
        let nodeAreaH = (bowlH - liquidH) * PotionShopCauldronLayout.nodeInsetY
        let nodeAreaY = bowlOriginY + liquidH + 8

        let nodeScale = min(
            nodeAreaW / PotionShopCauldronLayout.boardWidth,
            nodeAreaH / PotionShopCauldronLayout.boardHeight
        ) * scale * nodeScaleMultiplier
        let scaledBoardW = PotionShopCauldronLayout.boardWidth * nodeScale
        let scaledBoardH = PotionShopCauldronLayout.boardHeight * nodeScale
        let nodeOriginX = bowlCenterX - scaledBoardW / 2 + nodeXOffset
        let nodeOriginY = nodeAreaY + (nodeAreaH - scaledBoardH) / 2 + nodeYOffset

        return CauldronGeometry(
            bowlW: bowlW,
            bowlH: bowlH,
            bowlCenterX: bowlCenterX,
            bowlOriginY: bowlOriginY,
            liquidW: liquidW,
            liquidH: liquidH,
            nodeOriginX: nodeOriginX,
            nodeOriginY: nodeOriginY,
            nodeScale: nodeScale,
            totalW: totalW
        )
    }
}

// MARK: - Cauldron board (cauldron + nodes + BREW)

struct PotionShopCauldronView: View {
    @Bindable var gs: PotionShopGameState
    let diceFlight: Namespace.ID
    
    // LAYOUT EDITOR PARAMETERS (with defaults so existing code doesn't break)
    var cauldronScale: Double = 1.0       // Scale multiplier for bowl/nodes
    var cauldronXOffset: Double = 0       // X offset for cauldron position (pts)
    var cauldronYOffset: Double = 0       // Y offset for cauldron position (pts)
    var nodeScale: Double = 1.0           // Independent node scale multiplier
    var nodeXOffset: Double = 0           // Independent node X offset (pts)
    var nodeYOffset: Double = 0           // Independent node Y offset (pts)
    var brewXOffset: Double = -50         // BREW button X from right edge
    var brewYPercent: Double = 0.30       // BREW button Y as % of cauldron height
    var showBrewButton: Bool = true       // Toggle to hide BREW button
    var brewZoneX: Double = 0.85          // Brew tap zone X (% of width, from left)
    var brewZoneY: Double = 0.30          // Brew tap zone Y (% of height, from top)
    var brewZoneWidth: Double = 100       // Brew tap zone width (pts)
    var brewZoneHeight: Double = 100      // Brew tap zone height (pts)
    var showBrewZone: Bool = false        // Show visual indicator of brew zone

    var body: some View {
        GeometryReader { geo in
            let g = CauldronGeometry.compute(
                in: geo.size,
                scale: cauldronScale,
                xOffset: cauldronXOffset,
                yOffset: cauldronYOffset,
                nodeScaleMultiplier: nodeScale,
                nodeXOffset: nodeXOffset,
                nodeYOffset: nodeYOffset
            )

            ZStack {
                // SINGLE CAULDRON IMAGE (behind nodes)
                if let cauldronImage = PotionShopImageLoader.loadImage(named: "cauldron") {
                    Image(uiImage: cauldronImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: g.bowlW, height: g.bowlH)
                        .position(x: g.bowlCenterX, y: g.bowlOriginY + g.bowlH / 2)
                } else {
                    // Placeholder: Simple bowl shape when no art
                    PotionShopBowlShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.20, green: 0.16, blue: 0.13),
                                    Color(red: 0.10, green: 0.08, blue: 0.07)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            PotionShopBowlShape()
                                .stroke(PotionShopTheme.ink, lineWidth: 2.5)
                        )
                        .frame(width: g.bowlW, height: g.bowlH)
                        .position(x: g.bowlCenterX, y: g.bowlOriginY + g.bowlH / 2)
                        .shadow(color: .black.opacity(0.20), radius: 6, x: 0, y: 4)
                }

                // Edge lines connecting nodes
                Path { path in
                    for (a, b) in PotionShopBoard.edges {
                        let na = PotionShopBoard.nodes[a]
                        let nb = PotionShopBoard.nodes[b]
                        path.move(
                            to: CGPoint(
                                x: g.nodeOriginX + CGFloat(na.x) * g.nodeScale,
                                y: g.nodeOriginY + CGFloat(na.y) * g.nodeScale
                            )
                        )
                        path.addLine(
                            to: CGPoint(
                                x: g.nodeOriginX + CGFloat(nb.x) * g.nodeScale,
                                y: g.nodeOriginY + CGFloat(nb.y) * g.nodeScale
                            )
                        )
                    }
                }
                .stroke(Color.white.opacity(0.30), lineWidth: 1)

                ForEach(0..<PotionShopBoard.nodes.count, id: \.self) { idx in
                    let node = PotionShopBoard.nodes[idx]
                    PotionShopNodeButtonView(gs: gs, nodeIndex: idx, diceFlight: diceFlight)
                        .position(
                            x: g.nodeOriginX + CGFloat(node.x) * g.nodeScale,
                            y: g.nodeOriginY + CGFloat(node.y) * g.nodeScale
                        )
                }

                // BREW BUTTON (conditionally shown)
                if showBrewButton {
                    PotionShopBrewSignView(gs: gs)
                        .position(
                            x: g.totalW + brewXOffset,
                            y: g.bowlOriginY + g.bowlH * brewYPercent
                        )
                }
                
                // BREW TAP ZONE (custom tappable area - shown only in editor)
                if !showBrewButton {
                    let zoneX = geo.size.width * brewZoneX
                    let zoneY = geo.size.height * brewZoneY
                    
                    Button {
                        Task { @MainActor in
                            await gs.doBrew()
                        }
                    } label: {
                        ZStack {
                            if showBrewZone {
                                // Visual indicator (editor only) - FIXED RENDERING
                                ZStack {
                                    // Background fill
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.yellow.opacity(0.3))
                                    
                                    // Dashed border
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.yellow, style: StrokeStyle(lineWidth: 4, dash: [10, 5]))
                                    
                                    // Label
                                    VStack(spacing: 2) {
                                        Text("🥄 BREW")
                                            .font(.system(size: 14, weight: .heavy))
                                            .foregroundColor(.yellow)
                                        Text("TAP ZONE")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.yellow)
                                    }
                                }
                            } else {
                                // Invisible tap zone (production)
                                Color.clear
                                    .contentShape(Rectangle())
                            }
                        }
                        .frame(width: brewZoneWidth, height: brewZoneHeight)
                    }
                    .position(x: zoneX, y: zoneY)
                    .disabled(gs.placements.isEmpty || gs.isAnimating || gs.phase != .playing)
                }
            }
        }
    }
}

// MARK: - One node on the cauldron

struct PotionShopNodeButtonView: View {
    @Bindable var gs: PotionShopGameState
    let nodeIndex: Int
    let diceFlight: Namespace.ID
    
    @State private var globalFrame: CGRect = .zero

    private var placedDie: PotionShopDie? { gs.placements[nodeIndex] }
    private var dieSelected: Bool { gs.selectedHandIndex != nil }
    private var atCap: Bool { gs.placements.count >= PotionShopConfig.maxPlacementsPerBrew }
    private var canBePlacedOn: Bool { dieSelected && !atCap && placedDie == nil }
    private var isDraggingDie: Bool { gs.draggedDie != nil }
    private var canReceiveDrop: Bool { isDraggingDie && !atCap && placedDie == nil }
    private var isHovered: Bool { gs.hoveredNodeIndex == nodeIndex }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(
                    width: PotionShopCauldronLayout.nodeHitArea,
                    height: PotionShopCauldronLayout.nodeHitArea
                )
                .contentShape(Rectangle())

            if let die = placedDie {
                PotionShopPlacedDieView(die: die)
                    .matchedGeometryEffect(
                        id: die.id,
                        in: diceFlight,
                        properties: [.position, .size]
                    )
                    // Allow dragging placed die back to tray
                    .gesture(
                        DragGesture(minimumDistance: 5)
                            .onEnded { _ in
                                if !gs.isAnimating {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                                        gs.dragPlacedDieToTray(nodeId: nodeIndex)
                                    }
                                }
                            }
                    )
                    // Also allow tap to remove (original behavior)
                    .onTapGesture {
                        if !gs.isAnimating {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                                gs.unplaceDie(nodeIndex)
                            }
                        }
                    }
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(visibleFill)
                    .frame(
                        width: PotionShopCauldronLayout.nodeVisible,
                        height: PotionShopCauldronLayout.nodeVisible
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(visibleStroke, lineWidth: visibleStrokeWidth)
                    )
                    .scaleEffect(isHovered ? 1.15 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isHovered)
                    // Tap gesture (original behavior - place selected die)
                    .onTapGesture {
                        if !gs.isAnimating {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                                gs.tapNode(nodeIndex)
                            }
                        }
                    }
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        // Register this node's position in global coordinates
                        globalFrame = geometry.frame(in: .global)
                        gs.nodePositions[nodeIndex] = globalFrame
                    }
                    .onChange(of: geometry.frame(in: .global)) { oldValue, newValue in
                        globalFrame = newValue
                        gs.nodePositions[nodeIndex] = newValue
                    }
            }
        )
        .disabled(gs.isAnimating && placedDie == nil)
    }

    private var visibleFill: Color {
        if isHovered && canReceiveDrop { 
            return Color(red: 1.0, green: 0.95, blue: 0.4).opacity(0.9)
        }
        if canBePlacedOn { return Color(red: 1.0, green: 0.92, blue: 0.62) }
        if atCap { return Color(red: 0.85, green: 0.78, blue: 0.58).opacity(0.5) }
        return Color(red: 0.95, green: 0.87, blue: 0.65).opacity(0.85)
    }

    private var visibleStroke: Color {
        if isHovered && canReceiveDrop {
            return PotionShopTheme.accent.opacity(1.0)
        }
        if canBePlacedOn { return PotionShopTheme.accent }
        return Color(red: 0.55, green: 0.40, blue: 0.20).opacity(0.7)
    }

    private var visibleStrokeWidth: CGFloat {
        if isHovered && canReceiveDrop { return 3 }
        if canBePlacedOn { return 2 }
        return 1
    }
}

// MARK: - Placed die view (used inside a node)

struct PotionShopPlacedDieView: View {
    let die: PotionShopDie

    var body: some View {
        // Try to load die face image, fallback to colored square
        if let dieImage = PotionShopImageLoader.loadImage(named: die.type.assetName) {
            ZStack {
                Image(uiImage: dieImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: PotionShopCauldronLayout.nodeVisible,
                        height: PotionShopCauldronLayout.nodeVisible
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Die value overlaid on center (center 30% kept blank on art)
                Text("\(die.value)")
                    .font(.system(size: 13, weight: .heavy, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            }
        } else {
            // Placeholder colored square with value
            RoundedRectangle(cornerRadius: 4)
                .fill(die.type.color)
                .frame(
                    width: PotionShopCauldronLayout.nodeVisible,
                    height: PotionShopCauldronLayout.nodeVisible
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(PotionShopTheme.ink, lineWidth: 1.5)
                )
                .overlay(
                    Text("\(die.value)")
                        .font(.system(size: 13, weight: .heavy, design: .serif))
                        .foregroundColor(.white)
                )
        }
    }
}

// MARK: - BREW sign-on-a-stake

struct PotionShopBrewSignView: View {
    @Bindable var gs: PotionShopGameState

    private var canBrew: Bool {
        !gs.placements.isEmpty && !gs.isAnimating && gs.phase == .playing
    }

    var body: some View {
        Button {
            Task { @MainActor in
                await gs.doBrew()
            }
        } label: {
            ZStack {
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.78, green: 0.62, blue: 0.40),
                                        Color(red: 0.62, green: 0.46, blue: 0.27)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(red: 0.30, green: 0.18, blue: 0.10), lineWidth: 2)
                            )
                            .frame(width: 70, height: 32)

                        Text("BREW")
                            .font(.system(size: 14, weight: .heavy, design: .serif))
                            .tracking(2)
                            .foregroundColor(canBrew ? Color(red: 0.30, green: 0.18, blue: 0.10) : Color.gray.opacity(0.6))
                    }

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.62, green: 0.46, blue: 0.27),
                                    Color(red: 0.45, green: 0.30, blue: 0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            Rectangle()
                                .stroke(Color(red: 0.30, green: 0.18, blue: 0.10), lineWidth: 1)
                        )
                        .frame(width: 8, height: 70)
                }
                .rotationEffect(.degrees(-12))
                .opacity(canBrew ? 1.0 : 0.6)
                .scaleEffect(canBrew ? 1.0 : 0.95)
            }
            .frame(width: 90, height: 110)
        }
        .disabled(!canBrew)
        .animation(.easeInOut(duration: 0.2), value: canBrew)
    }
}

// MARK: - Brew preview bar

struct PotionShopBrewPreviewBar: View {
    @Bindable var gs: PotionShopGameState

    private var preview: PotionShopGameState.BrewPreview {
        gs.computeBrew()
    }

    private var atCap: Bool {
        gs.placements.count >= PotionShopConfig.maxPlacementsPerBrew
    }

    var body: some View {
        HStack {
            Text("Placed \(gs.placements.count) / \(PotionShopConfig.maxPlacementsPerBrew)\(atCap ? " (full)" : "")")
                .font(.system(size: 11, weight: atCap ? .bold : .regular))
                .foregroundColor(atCap ? PotionShopTheme.composureBad : PotionShopTheme.muted)

            Spacer()

            if !gs.placements.isEmpty {
                let target = gs.currentBrewTarget
                let willKill = preview.damage >= target
                Group {
                    Text("Brew ")
                        .foregroundColor(PotionShopTheme.muted)
                    + Text("\(preview.damage)")
                        .foregroundColor(willKill ? PotionShopTheme.composureGood : PotionShopTheme.composureBad)
                        .fontWeight(.bold)
                    + Text(" / \(target)")
                        .foregroundColor(PotionShopTheme.muted)
                    + Text(preview.healing > 0 ? "  +\(preview.healing)❤" : "")
                        .foregroundColor(PotionShopTheme.composureGood)
                    + Text(preview.shielding > 0 ? "  +\(preview.shielding)🛡" : "")
                        .foregroundColor(PotionShopTheme.shield)
                }
                .font(.system(size: 11))
            } else {
                Text("Place dice to preview")
                    .font(.system(size: 11))
                    .foregroundColor(PotionShopTheme.muted.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Dice tray

struct PotionShopDiceTrayView: View {
    @Bindable var gs: PotionShopGameState
    let diceFlight: Namespace.ID
    var dieScale: Double = 1.0  // NEW: Scale multiplier for dice in tray

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(gs.hand.enumerated()), id: \.element.id) { idx, die in
                PotionShopDieButtonView(
                    gs: gs,
                    die: die,
                    index: idx,
                    diceFlight: diceFlight,
                    dieScale: dieScale  // Pass scale to die button
                )
            }
            ForEach(gs.hand.count..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        Color.white.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                    )
                    .frame(
                        width: PotionShopCauldronLayout.dieSize * dieScale,
                        height: PotionShopCauldronLayout.dieSize * dieScale
                    )
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.35, blue: 0.17),
                            Color(red: 0.42, green: 0.27, blue: 0.14)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(PotionShopTheme.ink, lineWidth: 2)
                )
        )
        .padding(.horizontal, 14)
        .opacity(gs.isAnimating ? 0.7 : 1.0)
    }
}

// MARK: - Dice drop-in animation modifier
//
// PHASE 6D: Straight drop, no rotation. Each die starts ~80pt above
// its slot and springs cleanly into place. Triggered via .onAppear
// every time a new die appears in the tray (initial deal, redraw
// after a brew).

struct PotionShopDiceDropInModifier: ViewModifier {
    @State private var dropOffset: CGFloat = -PotionShopCauldronLayout.dropInOffset
    @State private var hasAppeared: Bool = false

    func body(content: Content) -> some View {
        content
            .offset(y: dropOffset)
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true

                withAnimation(.spring(response: 0.5, dampingFraction: 0.68)) {
                    dropOffset = 0
                }
            }
    }
}

// MARK: - One die in the tray

struct PotionShopDieButtonView: View {
    @Bindable var gs: PotionShopGameState
    let die: PotionShopDie
    let index: Int
    let diceFlight: Namespace.ID
    var dieScale: Double = 1.0  // Scale multiplier
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    private var isSelected: Bool { gs.selectedHandIndex == index }
    private var atCap: Bool { gs.placements.count >= PotionShopConfig.maxPlacementsPerBrew }

    var body: some View {
        let scaledSize = PotionShopCauldronLayout.dieSize * dieScale
        let scaledFontSize = 18 * dieScale
        
        // Try to load die face image, fallback to colored square
        Group {
            if let dieImage = PotionShopImageLoader.loadImage(named: die.type.assetName) {
                ZStack {
                    Image(uiImage: dieImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: scaledSize, height: scaledSize)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isSelected ? Color.yellow : Color.white.opacity(0.5), lineWidth: isSelected ? 3 : 1.5)
                        )
                    
                    // Die value overlaid on center
                    Text("\(die.value)")
                        .font(.system(size: scaledFontSize, weight: .heavy, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                }
            } else {
                // Placeholder colored square with text
                VStack(spacing: 1) {
                    Text(die.type.abbr)
                        .font(.system(size: 9 * dieScale, weight: .semibold))
                    Text("\(die.value)")
                        .font(.system(size: 14 * dieScale, weight: .heavy, design: .serif))
                }
                .foregroundColor(.white)
                .frame(width: scaledSize, height: scaledSize)
                .background(die.type.color)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isSelected ? Color.yellow : Color.white.opacity(0.5), lineWidth: isSelected ? 3 : 1.5)
                )
            }
        }
        .matchedGeometryEffect(
            id: die.id,
            in: diceFlight,
            properties: [.position, .size]
        )
        .scaleEffect(isDragging ? 1.15 : 1.0)
        .opacity(atCap && !isSelected ? 0.5 : 1.0)
        .offset(dragOffset)
        .zIndex(isDragging ? 1000 : 0)
        .shadow(
            color: isDragging ? die.type.color.opacity(0.5) : .clear,
            radius: isDragging ? 12 : 0
        )
        .modifier(PotionShopDiceDropInModifier())
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    if !gs.isAnimating {
                        isDragging = true
                        dragOffset = value.translation
                        
                        // Update hover state
                        gs.updateDragHoverPosition(value.location)
                    }
                }
                .onEnded { value in
                    if !gs.isAnimating {
                        // Try to place the die
                        let placed = gs.tryDropDieAtPosition(value.location, dieIndex: index)
                        
                        if placed {
                            // Reset offset (matchedGeometryEffect will animate)
                            dragOffset = .zero
                        } else {
                            // Return to original position
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                dragOffset = .zero
                            }
                        }
                    }
                    
                    isDragging = false
                    gs.hoveredNodeIndex = nil
                }
        )
        .onTapGesture {
            // Tap gesture (original behavior - select/deselect)
            if !gs.isAnimating && !isDragging {
                gs.selectHand(index)
            }
        }
        .disabled(gs.isAnimating)
    }
}
