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

// MARK: - 3D Dice asset mapping (Day 2 R2)
//
// Single source of truth for which asset shows on the cube's settled face AND
// on the placed-die view (when on a node). Both render paths read from this
// mapping so they always agree on what graphic to display.
//
// To add a new die type later (e.g. supporting a 10-pool with 6 picked
// at random):
//   1. Add the new asset name to `allDiceAssetNames`
//   2. Either edit the `assetName(forValue:)` switch to point a value at it,
//      OR add a per-cube subset-picker that randomly draws from the pool.

struct PotionShop3DDiceAssetMap {
    /// Master pool of every die face asset available in the project.
    /// Adding a new entry here doesn't automatically change what shows on the
    /// cube — you also need to map a value to it below (or add a subset
    /// picker later for randomized assignment).
    static let allDiceAssetNames: [String] = [
        "die_potency",
        "die_boost",
        "die_heal",
        "die_shield",
        "die_stability"
        // Add more here later: "die_fire", "die_water", etc.
    ]

    /// Map a rolled value (1...6, since the cube has 6 faces) → asset name.
    /// Change this freely. Multiple values can share the same asset (e.g.
    /// values 1 and 2 both → die_potency today).
    static func assetName(forValue value: Int) -> String {
        switch value {
        case 1, 2: return "die_potency"
        case 3:    return "die_boost"
        case 4:    return "die_heal"
        case 5:    return "die_shield"
        case 6:    return "die_stability"
        default:   return "die_potency"   // fallback for any weird value
        }
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

    /// How far ABOVE the visible dice tray panel still counts as "drop into
    /// the tray" when dragging a placed die back from a cauldron node. The
    /// drop zone is the brown tray rect grown upward by this many points so
    /// the player can release a bit early without missing the snap-to-tray.
    /// Tune to taste: bigger value = easier to drop into tray; smaller =
    /// tighter to the visible panel.
    static let trayDropZoneTopExtension: CGFloat = 80
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
                
                // LAYER 3: Drag-from-node overlay used to render here, but it
                // was bounded by this view's frame in the parent VStack and
                // ended up rendering BEHIND the dice tray when dragged
                // downward. It now lives in `PotionShopDraggedDieOverlay` at
                // the top of the screen-level ZStack so it floats over the
                // tray as well.

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
                        PotionShopPlacedDieView(die: die, visualScale: visualScale * 1.0, useFaceAsset: gs.currentRoundUses3DDice)
                            .opacity(0.3)
                    } else {
                        // Locked-in die, scaled down so node frame shows
                        // around it as a "socket".
                        PotionShopPlacedDieView(die: die, visualScale: visualScale * 1.0, useFaceAsset: gs.currentRoundUses3DDice)
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

                    // Tray drop zone is the brown panel grown upward by
                    // `trayDropZoneTopExtension` so a player can release a
                    // bit above the tray and still land it.
                    let droppedInTray = gs.trayDropZone.contains(value.location)
                    let targetNodeId = gs.findNodeAtPosition(value.location)
                    let canDropOnNode = targetNodeId != nil &&
                                        targetNodeId != nodeIndex &&
                                        gs.placements[targetNodeId!] == nil

                    if droppedInTray {
                        // Drag back to the dice tray → unplace into whichever
                        // open slot the player released over (or back to the
                        // die's original slot if the release wasn't over an
                        // empty slot).
                        //
                        // Why this looks the way it does:
                        //   • matchedGeometryEffect's default transition does
                        //     an opacity crossfade between source (placed
                        //     die) and destination (tray die). That's the
                        //     fade the user saw.
                        //   • `withTransaction(disablesAnimations: true)`
                        //     forces the matched effect to SNAP — no fade,
                        //     no slide. The die teleports into the slot.
                        //   • A separate one-shot pop animation runs on the
                        //     tray die's `.onAppear` (gated by
                        //     `gs.diceToPopIds`) to give the landing a
                        //     satisfying scale punch.
                        let targetSlot = gs.findEmptyTraySlot(at: value.location)
                        if let dieId = gs.placements[nodeIndex]?.id {
                            gs.diceToPopIds.insert(dieId)
                        }
                        var snap = Transaction()
                        snap.disablesAnimations = true
                        withTransaction(snap) {
                            gs.unplaceDie(nodeIndex, toSlot: targetSlot)
                            gs.nodeDragLocation = nil
                            gs.cancelNodeDrag()
                        }
                        isDraggingFromHere = false
                    } else if canDropOnNode, let target = targetNodeId {
                        withAnimation(.spring(response: 0.20, dampingFraction: 0.8)) {
                            if let die = gs.placements[nodeIndex] {
                                gs.placements[nodeIndex] = nil
                                gs.placements[target] = die
                            }
                            gs.nodeDragLocation = nil
                            gs.cancelNodeDrag()
                        }
                        isDraggingFromHere = false
                    } else {
                        // Invalid drop → die snaps back to its source node
                        // (animated from finger position via the matched
                        // effect, since the placedDie view on the source
                        // node still has the same matched id).
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            gs.nodeDragLocation = nil
                            gs.cancelNodeDrag()
                        }
                        isDraggingFromHere = false
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
    /// When true (Day 2 R2), the placed die renders the asset from the
    /// shared value→asset mapping (`PotionShop3DDiceAssetMap`), matching the
    /// 3D cube. When false (default, every other round), uses the die's TYPE
    /// asset as before.
    var useFaceAsset: Bool = false

    var body: some View {
        // Pick asset source. When 3D-dice mode is active, read from the
        // SHARED faceValue field that the cube also targets — so the picture
        // on the cube and the picture on the placed die are guaranteed to
        // match. In every other round, use the die's TYPE asset as before.
        let assetName = useFaceAsset
            ? PotionShop3DDiceAssetMap.assetName(forValue: die.faceValue)
            : die.type.assetName

        // Try to load die face image, fallback to colored square
        if let dieImage = PotionShopImageLoader.loadImage(named: assetName) {
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
        // Render 5 fixed tray slots (0...4). Each slot looks up the die in
        // `hand` whose `trayIndex` matches the slot; if none, render a dashed
        // placeholder. This keeps the remaining dice in place when one is
        // dragged to the cauldron, instead of HStack-sliding them leftward.
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { slotIndex in
                Group {
                    if let die = gs.hand.first(where: { $0.trayIndex == slotIndex }),
                       let handIdx = gs.hand.firstIndex(where: { $0.id == die.id }) {
                        PotionShopDieButtonView(
                            gs: gs,
                            die: die,
                            index: handIdx,
                            diceFlight: diceFlight,
                            dieScale: dieScale
                        )
                    } else {
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
                // Publish this slot's global frame so a node→tray drag can
                // figure out which open slot the player released over.
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                gs.traySlotPositions[slotIndex] = geometry.frame(in: .global)
                            }
                            .onChange(of: geometry.frame(in: .global)) { _, newValue in
                                gs.traySlotPositions[slotIndex] = newValue
                            }
                    }
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
        // Publish the tray's global frame so the node-drag gesture can detect
        // when a placed die is being dragged back here (→ unplace).
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        gs.trayFrame = geometry.frame(in: .global)
                    }
                    .onChange(of: geometry.frame(in: .global)) { _, newValue in
                        gs.trayFrame = newValue
                    }
            }
        )
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
    /// One-shot scale used to play a "landed in tray" pop when the die
    /// returns from the cauldron via drag-to-tray. 1.0 = neutral. Set to
    /// the punch value in `.onAppear` (gated on `gs.diceToPopIds`), then
    /// spring-animated back to 1.0.
    @State private var landPopScale: CGFloat = 1.0

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
                    spinToken: gs.spinTrigger3D,
                    // Dice returning from the cauldron (id in settledDiceIds)
                    // should appear at rest in their slot — NOT replay the
                    // drop/spin animation. Fresh deals + reroll button both
                    // clear the set, so those still animate as before.
                    animateOnAppear: !gs.settledDiceIds.contains(die.id)
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
        .scaleEffect(landPopScale)
        .opacity(atCap && !isSelected ? 0.5 : 1.0)
        .offset(dragOffset)
        .zIndex(isDragging ? 1000 : 0)
        .shadow(
            color: isDragging ? die.type.color.opacity(0.5) : .clear,
            radius: isDragging ? 12 : 0
        )
        .modifier(PotionShopDiceDropInModifier())
        // "Just landed in tray" pop. The drag-from-node flow inserts this
        // die's id into `gs.diceToPopIds` before snapping it home; here we
        // consume that signal and play a quick scale punch that springs
        // back to normal — gives the snap some weight without re-introducing
        // the matchedGeometryEffect crossfade.
        .onAppear {
            if gs.diceToPopIds.contains(die.id) {
                gs.diceToPopIds.remove(die.id)
                landPopScale = 1.35
                withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                    landPopScale = 1.0
                }
            }
        }
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
    /// Iteration 2 (June 10): set to 0 so all dice drop / bounce / roll in sync.
    /// Bump back to 0.04 (or higher) to bring back the slot-machine cascade feel.
    static let spinStaggerStep: Double = 0.06    // simultaneous start across all dice

    let die: PotionShopDie
    let isSelected: Bool
    let size: CGFloat
    let fontSize: CGFloat
    let dieScale: Double
    let index: Int
    /// Bumped by reroll3DDice() (and the editor's spin button) every time the
    /// game state re-rolls. Forces the cube to rebuild + replay its animation
    /// even when the re-rolled `faceValue` happens to equal the previous one.
    let spinToken: Int
    /// When false, the cube appears at rest in its slot — no drop, no spin,
    /// no bounce. Used for dice that are returning to the tray from the
    /// cauldron (already-rolled, just re-entering view).
    let animateOnAppear: Bool

    var body: some View {
        // SOURCE OF TRUTH: the cube targets `die.faceValue`, the same field the
        // placed-die view reads when this round renders 3D dice. So whatever
        // graphic the cube lands on is identical to the graphic shown after the
        // die is dragged onto a node. `spinToken` guarantees the spin replays
        // even on a duplicate roll.
        DieSceneView3D(
            targetFace: die.faceValue,
            dieColor: UIColor(die.type.color),
            spinDelay: DieFaceView3D.spinStaggerStep * Double(index),
            spinSession: spinToken,
            animateOnAppear: animateOnAppear
        )
        .frame(width: size, height: size)
    }
}

/// SwiftUI wrapper around SCNView.
struct DieSceneView3D: UIViewRepresentable {
    let targetFace: Int
    let dieColor: UIColor
    let spinDelay: Double   // seconds before this die starts spinning (per-die stagger)
    /// Bumped every time the game state re-rolls (reroll3DDice). Forces the
    /// scene to rebuild even when targetFace happens to equal the previous
    /// face, so the spin animation replays on every tap (no "same face = no
    /// spin" bug).
    let spinSession: Int
    /// When false, `buildScene()` skips `runSlotSpin` — the cube is added to
    /// the scene at its rest position (0,0,0, identity rotation) showing the
    /// `targetFace` material camera-facing. Used when a die returns to the
    /// tray from the cauldron: we want it to just BE in its slot, not replay
    /// the full drop-and-spin animation a second time.
    let animateOnAppear: Bool

    /// Coordinator tracks the (session, face) the scene was last built with so
    /// updateUIView can detect a new spin and rebuild.
    final class Coordinator {
        var lastBuiltSession: Int = -1
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
        context.coordinator.lastBuiltSession = spinSession
        context.coordinator.lastBuiltFace = targetFace
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Rebuild the scene (→ replay the spin animation) when EITHER the spin
        // session bumped OR the target face changed. Session-change guarantees
        // replays even on duplicate face rolls; face-change guards against any
        // edge case where the game state changed a die's faceValue without
        // bumping the session token.
        let sessionChanged = context.coordinator.lastBuiltSession != spinSession
        let faceChanged = context.coordinator.lastBuiltFace != targetFace
        guard sessionChanged || faceChanged else { return }
        uiView.scene = buildScene()
        context.coordinator.lastBuiltSession = spinSession
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

        // Only play the drop/bounce/spin/settle if this is a "fresh roll"
        // appearance. When a die is RETURNING to the tray from the cauldron,
        // animateOnAppear is false and the cube simply sits at rest (default
        // position 0,0,0, identity rotation, targetFace camera-facing).
        if animateOnAppear {
            runSlotSpin(on: dieNode)
        }
        return scene
    }

    /// Load the face texture from the shared value→asset mapping. Both the
    /// cube AND the placed-die view read from this mapping, so the graphic
    /// on the cube's settled face matches the graphic shown when placed on
    /// a node. Falls back to a procedurally-drawn placeholder if the asset
    /// is missing.
    private func renderFaceTexture(value: Int) -> UIImage {
        let mappedName = PotionShop3DDiceAssetMap.assetName(forValue: value)
        if let custom = UIImage(named: mappedName) {
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

    /// "Drop AND spin together" (iteration 6, June 10).
    ///
    /// Drop runs alone first. Once the drop lands, the bounce phases
    /// (overshoot → bounce up → bounce down) run IN PARALLEL with the spin —
    /// so the cube is rolling while it's still settling vertically. Spin
    /// starts `spinStartDelay` seconds after the drop ends.
    ///
    /// Timeline (current values):
    ///   0.00 → DROP starts
    ///   0.13 → DROP ends → bounce sequence + spin start in parallel
    ///   0.14 → SPIN starts (= dropDuration + spinStartDelay)
    ///   0.22 → OVERSHOOT ends (cube at Y=-0.07, still spinning)
    ///   0.32 → BOUNCE UP peak (Y=+0.04, still spinning)
    ///   0.40 → BOUNCE DOWN ends (Y=0, still spinning)
    ///   0.99 → SPIN ends
    ///   1.08 → SETTLE DOWN ends (Y=-0.12)
    ///   1.22 → SETTLE UP ends (Y=0) — done
    private func runSlotSpin(on node: SCNNode) {
        // ── Tuning knobs ─────────────────────────────────────────
        // `dropHeight` is now measured as "how far above the window's top edge
        // the cube's BOTTOM starts." With dropHeight=0 the cube starts JUST
        // off-screen (no overlap with the viewport). Larger values mean the
        // cube starts further off-screen above — longer invisible fall, faster
        // entry into frame at impact.
        let dropHeight: CGFloat = 0.99        // off-screen distance above the window
        let dropDuration: Double = 0.26
        let dropOvershootY: CGFloat = 0.07    // how far PAST Y=0 the drop sinks
        let overshootDuration: Double = 0.09
        let bounceUpY: CGFloat = 0.04         // how high above Y=0 the bounce peaks
        let bounceUpDuration: Double = 0.10
        let bounceDownDuration: Double = 0.08
        let spinDuration: Double = 0.85
        let spinStartDelay: Double = 0.00     // spin starts this many seconds after drop ends
        // Post-spin settle — sequential after the group.
        let settleOvershoot: CGFloat = 0.12
        let settleDownDuration: Double = 0.09
        let settleUpDuration: Double = 0.14
        // ─────────────────────────────────────────────────────────

        // ── Convert dropHeight (off-screen distance) → actual scene Y ──
        // Derived from camera: visibleHalfHeight = cameraZ * tan(FOV/2).
        // With camera at z=1.85 and FOV 42°: ~0.71.
        // Cube is 1.0 tall, so cube's CENTER must be 0.5 above the window edge
        // for the bottom to JUST touch the edge.
        // If you change the camera (z or FOV), update visibleTopY accordingly.
        let visibleTopY: CGFloat = 0.71
        let cubeHalfHeight: CGFloat = 0.5
        let startY: CGFloat = visibleTopY + cubeHalfHeight + dropHeight

        // Lift the cube to its drop-start position BEFORE the action plays.
        node.position = SCNVector3(0, Float(startY), 0)

        // 1. DROP — runs alone first (falls all the way from startY to Y=0)
        let drop = SCNAction.moveBy(x: 0, y: -startY, z: 0, duration: dropDuration)
        drop.timingMode = .easeIn

        // 2. OVERSHOOT, 3. BOUNCE UP, 4. BOUNCE DOWN — group together as one sequence
        let dropOvershoot = SCNAction.moveBy(x: 0, y: -dropOvershootY, z: 0, duration: overshootDuration)
        dropOvershoot.timingMode = .easeOut

        let bounceUp = SCNAction.moveBy(x: 0, y: dropOvershootY + bounceUpY, z: 0, duration: bounceUpDuration)
        bounceUp.timingMode = .easeOut

        let bounceDown = SCNAction.moveBy(x: 0, y: -bounceUpY, z: 0, duration: bounceDownDuration)
        bounceDown.timingMode = .easeInEaseOut

        let bounceSequence = SCNAction.sequence([dropOvershoot, bounceUp, bounceDown])

        // 5. SPIN — starts spinStartDelay after the drop ends (i.e. at
        // dropDuration + spinStartDelay = 0.14s by default).
        let spin = SCNAction.rotateBy(
            x: CGFloat.pi * 10,    // 5 full vertical revolutions (multiple of 360°)
            y: 0,
            z: 0,
            duration: spinDuration
        )
        spin.timingMode = .easeOut
        let spinWithLead = SCNAction.sequence([
            SCNAction.wait(duration: spinStartDelay),
            spin
        ])

        // Run bounce sequence AND spin in parallel. Group ends when the LATER
        // finishes — spin (0.01 + 0.85 = 0.86s) outlasts bounces (0.27s), so the
        // cube finishes the bounce mid-spin and keeps rotating to a settled stop.
        let bounceAndSpin = SCNAction.group([bounceSequence, spinWithLead])

        // 6. POST-SPIN SETTLE — runs sequentially after the group
        let settleDown = SCNAction.moveBy(x: 0, y: -settleOvershoot, z: 0, duration: settleDownDuration)
        settleDown.timingMode = .easeOut
        let settleUp = SCNAction.moveBy(x: 0, y: settleOvershoot, z: 0, duration: settleUpDuration)
        settleUp.timingMode = .easeInEaseOut

        var actions: [SCNAction] = []
        // spinDelay (per-die stagger) is currently 0 — all dice in sync.
        if spinDelay > 0 {
            actions.append(SCNAction.wait(duration: spinDelay))
        }
        actions.append(contentsOf: [drop, bounceAndSpin, settleDown, settleUp])
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
