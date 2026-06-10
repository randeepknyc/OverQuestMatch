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
import SceneKit

// MARK: - View extension for conditional modifiers

extension View {
    /// Conditionally applies a modifier to a view
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - CGRect Extension for center point

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

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
    let nodeSpacingMultiplier: CGFloat  // ⚠️ EXPERIMENTAL: Multiplies node coordinates (visual only)
    let totalW: CGFloat

    static func compute(
        in size: CGSize,
        scale: Double = 1.0,
        xOffset: Double = 0,
        yOffset: Double = 0,
        nodeScaleMultiplier: Double = 1.0,
        nodeXOffset: Double = 0,
        nodeYOffset: Double = 0,
        nodeSpacingMultiplier: Double = 1.0
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
            nodeSpacingMultiplier: nodeSpacingMultiplier,
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
    var nodeSpacingMultiplier: Double = 1.0  // ⚠️ EXPERIMENTAL: Visual spacing multiplier (affects appearance only, NOT boost reach)
    var perNodeOffsets: [CGPoint] = Array(repeating: .zero, count: 12)  // Per-node fine-tuning offsets
    var brewXOffset: Double = -50         // BREW button X from right edge
    var brewYPercent: Double = 0.30       // BREW button Y as % of cauldron height
    var showBrewButton: Bool = true       // Toggle to hide BREW button
    var brewZoneX: Double = 0.85          // Brew tap zone X (% of width, from left)
    var brewZoneY: Double = 0.30          // Brew tap zone Y (% of height, from top)
    var brewZoneWidth: Double = 100       // Brew tap zone width (pts)
    var brewZoneHeight: Double = 100      // Brew tap zone height (pts)
    var showBrewZone: Bool = false        // Show visual indicator of brew zone
    var cauldronArtScale: Double = 1.0    // ART SCALE - Additional scale for cauldron image only
    var cauldronArtWidth: Double = 1.0    // FREEFORM - Independent width scale
    var cauldronArtHeight: Double = 1.0   // FREEFORM - Independent height scale
    var cauldronArtXOffset: Double = 0    // FREEFORM - X position offset (pts)
    var cauldronArtYOffset: Double = 0    // FREEFORM - Y position offset (pts)

    var body: some View {
        GeometryReader { geo in
            let g = CauldronGeometry.compute(
                in: geo.size,
                scale: cauldronScale,
                xOffset: cauldronXOffset,
                yOffset: cauldronYOffset,
                nodeScaleMultiplier: nodeScale,
                nodeXOffset: nodeXOffset,
                nodeYOffset: nodeYOffset,
                nodeSpacingMultiplier: nodeSpacingMultiplier
            )
            
            // Calculate BASE bowl size (without cauldronScale applied)
            // Re-compute with scale = 1.0 to get true base dimensions
            let baseGeometry = CauldronGeometry.compute(
                in: geo.size,
                scale: 1.0,  // No scale!
                xOffset: 0,
                yOffset: 0,
                nodeScaleMultiplier: 1.0,
                nodeXOffset: 0,
                nodeYOffset: 0,
                nodeSpacingMultiplier: 1.0  // Base geometry doesn't need spacing
            )

            ZStack {
                // LAYER 0: SINGLE CAULDRON IMAGE (bottom layer)
                if let cauldronImage = PotionShopImageLoader.loadImage(named: "cauldron") {
                    Image(uiImage: cauldronImage)
                        .resizable()
                        // NO .scaledToFit() or .scaledToFill() - allows independent width/height distortion
                        .frame(
                            width: baseGeometry.bowlW * cauldronArtScale * cauldronArtWidth,    // base × uniform × width
                            height: baseGeometry.bowlH * cauldronArtScale * cauldronArtHeight   // base × uniform × height
                        )
                        // NO .clipped() - allows image to escape frame bounds
                        .position(
                            x: g.bowlCenterX + cauldronArtXOffset,
                            y: g.bowlOriginY + g.bowlH / 2 + cauldronArtYOffset
                        )
                        .allowsHitTesting(false)  // Don't intercept touches meant for nodes
                        .zIndex(0)  // 🔧 EXPLICIT Z-INDEX: Bottom layer
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
                        .zIndex(0)  // 🔧 EXPLICIT Z-INDEX: Bottom layer
                }

                // LAYER 1: Connecting lines between nodes (BEHIND nodes, above cauldron)
                PotionShopNodeConnectionLines(
                    nodeOriginX: g.nodeOriginX,
                    nodeOriginY: g.nodeOriginY,
                    nodeSpacingMultiplier: g.nodeSpacingMultiplier,
                    perNodeOffsets: perNodeOffsets
                )
                    .zIndex(1)  // 🔧 EXPLICIT Z-INDEX: Middle layer (above cauldron, behind nodes)

                // LAYER 2: Nodes (TOP LAYER - above lines and cauldron)
                ForEach(0..<PotionShopBoard.nodes.count, id: \.self) { idx in
                    let node = PotionShopBoard.nodes[idx]
                    let perNodeOffset = idx < perNodeOffsets.count ? perNodeOffsets[idx] : .zero
                    PotionShopNodeButtonView(
                        gs: gs,
                        nodeIndex: idx,
                        diceFlight: diceFlight,
                        visualScale: nodeScale  // Pass visual scale separately
                    )
                        .position(
                            x: g.nodeOriginX + CGFloat(node.x) * g.nodeSpacingMultiplier + perNodeOffset.x,
                            y: g.nodeOriginY + CGFloat(node.y) * g.nodeSpacingMultiplier + perNodeOffset.y
                        )
                        .zIndex(2)  // 🔧 EXPLICIT Z-INDEX: Top layer (above everything)
                }
                
                // LAYER 3: Dragging die overlay (above ALL nodes!)
                if gs.draggedFromNode != nil,
                   let die = gs.draggedDie,
                   let dragLocation = gs.nodeDragLocation {
                    
                    // Convert from global coordinates to this view's local coordinates
                    let localPoint = geo.frame(in: .global).origin
                    let localX = dragLocation.x - localPoint.x
                    let localY = dragLocation.y - localPoint.y
                    
                    // Render the dragging die at finger position
                    PotionShopPlacedDieView(die: die, visualScale: nodeScale)
                        .scaleEffect(1.15)
                        .shadow(
                            color: die.type.color.opacity(0.5),
                            radius: 12
                        )
                        .position(x: localX, y: localY)
                        .zIndex(1000)  // Above EVERYTHING
                        .allowsHitTesting(false)  // Don't intercept gestures
                }

                // BREW BUTTON (conditionally shown)
                if showBrewButton {
                    PotionShopBrewSignView(gs: gs)
                        .position(
                            x: g.totalW + brewXOffset,
                            y: g.bowlOriginY + g.bowlH * brewYPercent
                        )
                        .zIndex(3)  // Above nodes
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
                                            .font(Font.gameScore(size: 14))
                                            .foregroundColor(.yellow)
                                        Text("TAP ZONE")
                                            .font(Font.gameUI(size: 10))
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
                    .zIndex(3)  // Above nodes
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
    var visualScale: Double = 1.0  // Visual-only scale (doesn't affect position)

    @State private var globalFrame: CGRect = .zero
    @State private var isDraggingFromHere: Bool = false  // Local drag state

    private var placedDie: PotionShopDie? { gs.placements[nodeIndex] }
    private var dieSelected: Bool { gs.selectedHandIndex != nil }
    private var atCap: Bool { gs.placements.count >= PotionShopConfig.maxPlacementsPerBrew }
    private var canBePlacedOn: Bool { dieSelected && !atCap && placedDie == nil && !isDraggingFromHere }
    private var isDraggingDie: Bool { gs.draggedDie != nil }
    private var canReceiveDrop: Bool {
        isDraggingDie && !atCap && placedDie == nil && !isDraggingFromHere
    }
    private var isHovered: Bool {
        gs.hoveredNodeIndex == nodeIndex && !isDraggingFromHere
    }
    private var isInPreview: Bool {
        gs.previewAffectedNodes.contains(nodeIndex)
    }

    // ─── GLOW APPEARANCE ─────────────────────────────────────────
    // State priority (highest wins):
    //   1. Hovered drop target        → bright yellow, biggest glow
    //   2. Tap-place candidate         → softer yellow
    //   3. In the reach preview        → cyan ("this die would affect me")
    //   4. Has die locked in           → subtle die-tinted glow
    //   5. Nothing                     → no glow

    private var glowColor: Color {
        if isHovered && canReceiveDrop { return Color.yellow }
        if canBePlacedOn               { return Color.yellow }
        if isInPreview                 { return Color(red: 0.30, green: 0.85, blue: 1.00) }  // cyan
        if let die = placedDie         { return die.type.color }
        return .clear
    }

    private var glowRadius: CGFloat {
        if isHovered && canReceiveDrop { return 20 }
        if canBePlacedOn               { return 12 }
        if isInPreview                 { return 14 }
        if placedDie != nil            { return 9 }
        return 0
    }

    private var glowOpacity: Double {
        if isHovered && canReceiveDrop { return 1.0 }
        if canBePlacedOn               { return 0.75 }
        if isInPreview                 { return 0.85 }
        if placedDie != nil            { return 0.65 }
        return 0.0
    }

    var body: some View {
        ZStack {
            // Invisible hit area (sets the ZStack's overall size)
            Rectangle()
                .fill(Color.clear)
                .frame(
                    width: PotionShopCauldronLayout.nodeHitArea * visualScale,
                    height: PotionShopCauldronLayout.nodeHitArea * visualScale
                )

            // ━━━ NODE BACKGROUND ART (always visible) ━━━━━━━━━━━━
            // Uses your "potion_node" asset if present, otherwise
            // falls back to a plain rounded rectangle.
            nodeBackground
                .frame(
                    width: PotionShopCauldronLayout.nodeVisible * visualScale,
                    height: PotionShopCauldronLayout.nodeVisible * visualScale
                )
                // Two stacked shadows = a thicker, softer glow
                .shadow(color: glowColor.opacity(glowOpacity), radius: glowRadius)
                .shadow(color: glowColor.opacity(glowOpacity * 0.55), radius: glowRadius * 0.5)
                .animation(.easeInOut(duration: 0.22), value: isHovered)
                .animation(.easeInOut(duration: 0.22), value: canBePlacedOn)
                .animation(.easeInOut(duration: 0.30), value: placedDie?.id)
                .animation(.easeInOut(duration: 0.18), value: isInPreview)
                .allowsHitTesting(false)  // Gestures live on the outer ZStack

            // ━━━ DIE ON TOP (visual only — no gestures here) ━━━━━━
            if let die = placedDie {
                Group {
                    if isDraggingFromHere {
                        // Drag origin: ghosted die stays put
                        PotionShopPlacedDieView(die: die, visualScale: visualScale * 1.0)
                            .opacity(0.3)
                    } else {
                        // Locked-in die, scaled down so node frame shows
                        // around it as a "socket".
                        PotionShopPlacedDieView(die: die, visualScale: visualScale * 1.0)
                            .matchedGeometryEffect(
                                id: die.id,
                                in: diceFlight,
                                properties: [.position, .size]
                            )
                    }
                }
                .allowsHitTesting(false)  // Gestures live on the outer ZStack
            }
        }
        // ━━━ ALL GESTURES LIVE HERE on the full hit area ━━━━━━━━━
        // This means anywhere inside the node area is grabbable —
        // you can tap or drag from anywhere within the frame, not
        // only inside the small visible die.
        .contentShape(Rectangle())
        .onTapGesture {
            guard !gs.isAnimating, !isDraggingFromHere else { return }
            if placedDie != nil {
                // Tap on a placed die → remove back to tray
                withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                    gs.unplaceDie(nodeIndex)
                }
            } else {
                // Tap on empty node → place currently-selected die
                withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                    gs.tapNode(nodeIndex)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged { value in
                    // Drag is only meaningful when a die lives here
                    guard placedDie != nil, !gs.isAnimating else { return }
                    if !isDraggingFromHere {
                        isDraggingFromHere = true
                        gs.startDraggingFromNode(nodeId: nodeIndex)
                    }
                    gs.nodeDragLocation = value.location
                    gs.updateDragHoverPosition(value.location)
                }
                .onEnded { value in
                    guard placedDie != nil, !gs.isAnimating else {
                        gs.nodeDragLocation = nil
                        isDraggingFromHere = false
                        gs.cancelNodeDrag()
                        return
                    }

                    let targetNodeId = gs.findNodeAtPosition(value.location)
                    let canDrop = targetNodeId != nil &&
                                  targetNodeId != nodeIndex &&
                                  gs.placements[targetNodeId!] == nil

                    if canDrop, let target = targetNodeId {
                        if let die = gs.placements[nodeIndex] {
                            gs.placements[nodeIndex] = nil
                            gs.placements[target] = die
                        }
                        gs.nodeDragLocation = nil
                        isDraggingFromHere = false
                        gs.cancelNodeDrag()
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            gs.nodeDragLocation = nil
                            isDraggingFromHere = false
                        }
                        gs.cancelNodeDrag()
                    }
                }
        )
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        let frame = geometry.frame(in: .global)
                        globalFrame = frame
                        gs.nodePositions[nodeIndex] = frame
                    }
                    .onChange(of: geometry.frame(in: .global)) { oldValue, newValue in
                        globalFrame = newValue
                        gs.nodePositions[nodeIndex] = newValue
                    }
            }
        )
        .disabled(gs.isAnimating && placedDie == nil)
    }

    // ─── NODE BACKGROUND ────────────────────────────────────────
    // Your hand-drawn node art. If the asset "potion_node" is not
    // found, falls back to a parchment-colored rounded rectangle
    // so nothing breaks until your art is added.
    @ViewBuilder
    private var nodeBackground: some View {
        if let nodeImage = PotionShopImageLoader.loadImage(named: "potion_node") {
            Image(uiImage: nodeImage)
                .resizable()
                .scaledToFit()
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.95, green: 0.87, blue: 0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(red: 0.55, green: 0.40, blue: 0.20).opacity(0.7), lineWidth: 1)
                )
        }
    }
}

// MARK: - Placed die view (used inside a node)

struct PotionShopPlacedDieView: View {
    let die: PotionShopDie
    var visualScale: Double = 1.0  // Visual-only scale

    var body: some View {
        // Try to load die face image, fallback to colored square
        if let dieImage = PotionShopImageLoader.loadImage(named: die.type.assetName) {
            ZStack {
                Image(uiImage: dieImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: PotionShopCauldronLayout.nodeVisible * visualScale,
                        height: PotionShopCauldronLayout.nodeVisible * visualScale
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Die value overlaid on center (center 30% kept blank on art)
                Text("\(die.value)")
                    .font(Font.gameScore(size: 13 * visualScale))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            }
        } else {
            // Placeholder colored square with value
            RoundedRectangle(cornerRadius: 4)
                .fill(die.type.color)
                .frame(
                    width: PotionShopCauldronLayout.nodeVisible * visualScale,
                    height: PotionShopCauldronLayout.nodeVisible * visualScale
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(PotionShopTheme.ink, lineWidth: 1.5)
                )
                .overlay(
                    Text("\(die.value)")
                        .font(Font.gameScore(size: 13 * visualScale))
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
                            .font(Font.gameScore(size: 14))
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
                .font(Font.gameUI(size: 11))
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
                .font(Font.gameUI(size: 11))
            } else {
                Text("Place dice to preview")
                    .font(Font.gameUI(size: 11))
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
        
        // Day 2 Round 2 uses a vertical reel-spin animation (3D-style).
        // All other rounds use the original static face render.
        Group {
            if gs.currentRoundUses3DDice {
                DieFaceView3D(
                    die: die,
                    isSelected: isSelected,
                    size: scaledSize,
                    fontSize: scaledFontSize,
                    dieScale: dieScale,
                    index: index,
                    spinToken: gs.spinTrigger3D
                )
            } else {
                // Try to load die face image, fallback to colored square
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
                            .font(Font.gameScore(size: scaledFontSize))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                    }
                } else {
                    // Placeholder colored square with text
                    VStack(spacing: 1) {
                        Text(die.type.abbr)
                            .font(Font.gameUI(size: 9 * dieScale))
                        Text("\(die.value)")
                            .font(Font.gameScore(size: 14 * dieScale))
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

// MARK: - 3D Dice (Day 2 Round 2 only)
//
// REAL 3D cube (SceneKit) spinning around the X axis like a slot-machine reel.
// Multiple revolutions, motion blur on the camera during the fast phase, then
// decelerates and lands so `die.value` is up. Settles with a scale bounce.
//
// Faces are pre-rendered to match the existing 2D dice aesthetic: each face
// is the die-type color with the value number stamped in white. The cube
// keeps its 3D volume throughout the rotation (never goes flat).

struct DieFaceView3D: View {
    /// Per-die index stagger — die N starts spinning N × this many seconds after die 0.
    /// Each die's spin has the same duration, so they also STOP staggered by the same offset.
    /// Tweak this knob for the "very little" lag between dice.
    static let spinStaggerStep: Double = 0.04   // 40 ms per die — 5 dice = 160 ms total

    let die: PotionShopDie
    let isSelected: Bool
    let size: CGFloat
    let fontSize: CGFloat
    let dieScale: Double
    let index: Int
    /// Bumped by the editor's test-spin button to force a re-spin without rolling.
    let spinToken: Int

    /// Temporary: settled face is randomized per spin (uniform 1...6) so we can
    /// preview each face landing. Will swap for a weighted/real-value selector
    /// once that lookup is wired up. Re-rolls explicitly via onChange below.
    @State private var randomTargetFace: Int = Int.random(in: 1...6)

    var body: some View {
        DieSceneView3D(
            targetFace: randomTargetFace,
            dieColor: UIColor(die.type.color),
            spinDelay: DieFaceView3D.spinStaggerStep * Double(index)
        )
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isSelected ? Color.yellow : Color.white.opacity(0.5),
                        lineWidth: isSelected ? 3 : 1.5)
        )
        // Re-roll random face whenever a re-spin is requested (button tap or roll).
        // Loop until we pick a face DIFFERENT from the current one so visual
        // change is guaranteed on every tap (no 1-in-6 "same face" collision).
        .onChange(of: spinToken) { _, _ in
            randomTargetFace = pickDifferentFace(from: randomTargetFace)
        }
        .onChange(of: die.value) { _, _ in
            randomTargetFace = pickDifferentFace(from: randomTargetFace)
        }
        // DieSceneView3D detects targetFace changes via its Coordinator and
        // rebuilds the scene — animation replays on every change.
    }

    /// Returns a random 1...6 that's NOT `current`. Guarantees the cube lands
    /// on a visibly different face from the previous spin.
    private func pickDifferentFace(from current: Int) -> Int {
        var next = Int.random(in: 1...6)
        while next == current { next = Int.random(in: 1...6) }
        return next
    }
}

/// SwiftUI wrapper around SCNView.
struct DieSceneView3D: UIViewRepresentable {
    let targetFace: Int
    let dieColor: UIColor
    let spinDelay: Double   // seconds before this die starts spinning (per-die stagger)

    /// Coordinator tracks the face the scene was last built with so updateUIView
    /// can detect when the parent has passed a new targetFace and rebuild.
    final class Coordinator {
        var lastBuiltFace: Int = -1
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.scene = buildScene()
        context.coordinator.lastBuiltFace = targetFace
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Rebuild the scene (→ replay the spin animation) only when the parent
        // has passed a new target face. This guarantees a fresh spin every time
        // the parent picks a new random face, regardless of SwiftUI's `.id()`
        // behavior on the wrapping view.
        guard context.coordinator.lastBuiltFace != targetFace else { return }
        uiView.scene = buildScene()
        context.coordinator.lastBuiltFace = targetFace
    }

    private func buildScene() -> SCNScene {
        let scene = SCNScene()

        // Camera with motion blur. Closer + wider FOV so the cube fills
        // the entire bounding square of the die's container.
        let camera = SCNCamera()
        camera.fieldOfView = 42
        camera.motionBlurIntensity = 1.0
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 1.85)
        scene.rootNode.addChildNode(cameraNode)

        // Lighting: bright omni from above-right + ambient fill so the cube
        // edges read clearly during rotation
        let key = SCNLight()
        key.type = .omni
        key.intensity = 1100
        let keyNode = SCNNode()
        keyNode.light = key
        keyNode.position = SCNVector3(2, 4, 4)
        scene.rootNode.addChildNode(keyNode)

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 600
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        // Cube with rounded edges so it reads as a die, not a generic block
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.12)

        // Material order: [front (+Z), right (+X), back (-Z), left (-X), top (+Y), bottom (-Y)]
        // We put `targetFace` at the FRONT slot so a pure multiple-of-360° X-axis
        // spin lands the target value facing the camera with zero settle math.
        // Remaining values fill the other 5 slots — they only flash during the spin.
        var remaining = [1, 2, 3, 4, 5, 6].filter { $0 != targetFace }
        let faceOrder = [targetFace] + remaining   // [front, right, back, left, top, bottom]
        box.materials = faceOrder.map { face in
            let mat = SCNMaterial()
            mat.diffuse.contents = renderFaceTexture(value: face)
            mat.locksAmbientWithDiffuse = true
            return mat
        }

        let dieNode = SCNNode(geometry: box)
        scene.rootNode.addChildNode(dieNode)

        runSlotSpin(on: dieNode)
        return scene
    }

    /// Load the face texture from Assets.xcassets named `die_face_N` (N = 1...6).
    /// Falls back to a procedurally-drawn placeholder if the asset is missing.
    private func renderFaceTexture(value: Int) -> UIImage {
        if let custom = UIImage(named: "die_face_\(value)") {
            return custom
        }
        return fallbackFaceTexture(value: value)
    }

    /// Used only when the named asset isn't found — keeps the cube from being blank.
    private func fallbackFaceTexture(value: Int) -> UIImage {
        let s: CGFloat = 256
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: s, height: s))
        return renderer.image { ctx in
            let cg = ctx.cgContext
            dieColor.setFill()
            cg.fill(CGRect(x: 0, y: 0, width: s, height: s))
            cg.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
            cg.setLineWidth(6)
            cg.stroke(CGRect(x: 8, y: 8, width: s - 16, height: s - 16))

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 160, weight: .heavy),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black.withAlphaComponent(0.55),
                .strokeWidth: -4.0
            ]
            let str = NSAttributedString(string: "\(value)", attributes: attrs)
            let textSize = str.size()
            let rect = CGRect(
                x: (s - textSize.width) / 2,
                y: (s - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            str.draw(in: rect)
        }
    }

    /// Slot-machine spin: X-axis only, exact multiple of 360° so the cube ends
    /// in the same orientation it started (front face → camera). Since `targetFace`
    /// is assigned to the front material slot, it lands visible. Scale bounce at end.
    ///
    /// `spinDelay` shifts the whole sequence so dice fire in a slight cascade
    /// instead of all-at-once. Same duration per die → they also stop staggered.
    private func runSlotSpin(on node: SCNNode) {
        let spin = SCNAction.rotateBy(
            x: CGFloat.pi * 10,    // 5 full vertical revolutions (multiple of 360°)
            y: 0,
            z: 0,
            duration: 0.85
        )
        spin.timingMode = .easeOut

        let bounceUp = SCNAction.scale(to: 1.10, duration: 0.07)
        bounceUp.timingMode = .easeOut
        let bounceDown = SCNAction.scale(to: 0.96, duration: 0.07)
        bounceDown.timingMode = .easeInEaseOut
        let rest = SCNAction.scale(to: 1.0, duration: 0.06)
        rest.timingMode = .easeOut

        var actions: [SCNAction] = []
        if spinDelay > 0 {
            actions.append(SCNAction.wait(duration: spinDelay))
        }
        actions.append(contentsOf: [spin, bounceUp, bounceDown, rest])
        node.runAction(SCNAction.sequence(actions))
    }
}

// MARK: - Node Connection Lines
//
// Draws lines connecting nodes based on PotionShopBoard.edges topology.
// These lines appear BEHIND the nodes (z-index 1) but above the cauldron (z-index 0).
// Lines automatically connect to the actual node positions including all offsets.

struct PotionShopNodeConnectionLines: View {
    let nodeOriginX: CGFloat
    let nodeOriginY: CGFloat
    let nodeSpacingMultiplier: CGFloat
    let perNodeOffsets: [CGPoint]
    
    var body: some View {
        Canvas { context, size in
            // Draw each edge as a line
            for (fromIdx, toIdx) in PotionShopBoard.edges {
                // Get base node positions
                let fromNode = PotionShopBoard.nodes[fromIdx]
                let toNode = PotionShopBoard.nodes[toIdx]
                
                // Calculate actual positions with all transforms applied
                let fromOffset = fromIdx < perNodeOffsets.count ? perNodeOffsets[fromIdx] : .zero
                let toOffset = toIdx < perNodeOffsets.count ? perNodeOffsets[toIdx] : .zero
                
                let fromX = nodeOriginX + CGFloat(fromNode.x) * nodeSpacingMultiplier + fromOffset.x
                let fromY = nodeOriginY + CGFloat(fromNode.y) * nodeSpacingMultiplier + fromOffset.y
                
                let toX = nodeOriginX + CGFloat(toNode.x) * nodeSpacingMultiplier + toOffset.x
                let toY = nodeOriginY + CGFloat(toNode.y) * nodeSpacingMultiplier + toOffset.y
                
                // Create path for this edge
                var path = Path()
                path.move(to: CGPoint(x: fromX, y: fromY))
                path.addLine(to: CGPoint(x: toX, y: toY))
                
                // Draw the line with green color matching the image
                context.stroke(
                    path,
                    with: .color(Color(red: 0.18, green: 0.80, blue: 0.44).opacity(0.6)),  // Green with slight transparency
                    lineWidth: 2.5
                )
            }
        }
    }
}
