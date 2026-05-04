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
//
//  NAMING NOTE: PotionShop prefix on every public type. Don't rename.
//

import SwiftUI

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

    static func compute(in size: CGSize) -> CauldronGeometry {
        let totalW = size.width
        let totalH = size.height

        let cauldronColW = totalW - 90

        let maxBowlH = totalH * 0.92
        let maxBowlW = cauldronColW * 0.92
        let bowlW: CGFloat
        let bowlH: CGFloat
        if maxBowlW / maxBowlH > PotionShopCauldronLayout.bowlAspect {
            bowlH = maxBowlH
            bowlW = bowlH * PotionShopCauldronLayout.bowlAspect
        } else {
            bowlW = maxBowlW
            bowlH = bowlW / PotionShopCauldronLayout.bowlAspect
        }

        let bowlCenterX = cauldronColW / 2
        let bowlOriginY = (totalH - bowlH) / 2

        let liquidH = bowlH * PotionShopCauldronLayout.liquidHeight
        let liquidW = bowlW * 0.94

        let nodeAreaW = bowlW * PotionShopCauldronLayout.nodeInsetX
        let nodeAreaH = (bowlH - liquidH) * PotionShopCauldronLayout.nodeInsetY
        let nodeAreaY = bowlOriginY + liquidH + 8

        let nodeScale = min(
            nodeAreaW / PotionShopCauldronLayout.boardWidth,
            nodeAreaH / PotionShopCauldronLayout.boardHeight
        )
        let scaledBoardW = PotionShopCauldronLayout.boardWidth * nodeScale
        let scaledBoardH = PotionShopCauldronLayout.boardHeight * nodeScale
        let nodeOriginX = bowlCenterX - scaledBoardW / 2
        let nodeOriginY = nodeAreaY + (nodeAreaH - scaledBoardH) / 2

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

    var body: some View {
        GeometryReader { geo in
            let g = CauldronGeometry.compute(in: geo.size)

            ZStack {
                // CAULDRON BACK LAYER (or placeholder)
                if let backImage = PotionShopImageLoader.loadImage(named: "cauldron_back") {
                    Image(uiImage: backImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: g.bowlW, height: g.bowlH)
                        .position(x: g.bowlCenterX, y: g.bowlOriginY + g.bowlH / 2)
                } else {
                    // Placeholder parametric bowl back
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
                
                // CAULDRON RIM (placeholder - kept for depth)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.62, green: 0.42, blue: 0.20),
                                Color(red: 0.45, green: 0.28, blue: 0.13)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: g.bowlW, height: g.bowlH * PotionShopCauldronLayout.rimHeight)
                    .position(x: g.bowlCenterX, y: g.bowlOriginY + g.bowlH * PotionShopCauldronLayout.rimHeight / 2)

                // CAULDRON LIQUID LAYER (or placeholder)
                if let liquidImage = PotionShopImageLoader.loadImage(named: "cauldron_liquid") {
                    Image(uiImage: liquidImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: g.liquidW, height: g.liquidH)
                        .position(x: g.bowlCenterX, y: g.bowlOriginY + g.bowlH * PotionShopCauldronLayout.rimHeight + g.liquidH / 2)
                } else {
                    // Placeholder liquid ellipse
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.32, green: 0.55, blue: 0.32),
                                    Color(red: 0.18, green: 0.42, blue: 0.22),
                                    Color(red: 0.08, green: 0.28, blue: 0.16)
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: 140
                            )
                        )
                        .overlay(
                            Ellipse()
                                .stroke(Color(red: 0.04, green: 0.18, blue: 0.10), lineWidth: 1.2)
                        )
                        .frame(width: g.liquidW, height: g.liquidH)
                        .position(x: g.bowlCenterX, y: g.bowlOriginY + g.bowlH * PotionShopCauldronLayout.rimHeight + g.liquidH / 2)
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

                // CAULDRON FRONT LAYER (optional overlay for rim depth)
                if let frontImage = PotionShopImageLoader.loadImage(named: "cauldron_front") {
                    Image(uiImage: frontImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: g.bowlW, height: g.bowlH)
                        .position(x: g.bowlCenterX, y: g.bowlOriginY + g.bowlH / 2)
                        .allowsHitTesting(false)
                }

                PotionShopBrewSignView(gs: gs)
                    .position(
                        x: g.totalW - 50,
                        y: g.bowlOriginY + g.bowlH * 0.30
                    )
            }
        }
    }
}

// MARK: - One node on the cauldron

struct PotionShopNodeButtonView: View {
    @Bindable var gs: PotionShopGameState
    let nodeIndex: Int
    let diceFlight: Namespace.ID

    private var placedDie: PotionShopDie? { gs.placements[nodeIndex] }
    private var dieSelected: Bool { gs.selectedHandIndex != nil }
    private var atCap: Bool { gs.placements.count >= PotionShopConfig.maxPlacementsPerBrew }
    private var canBePlacedOn: Bool { dieSelected && !atCap && placedDie == nil }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                gs.tapNode(nodeIndex)
            }
        } label: {
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
                }
            }
        }
        .disabled(gs.isAnimating)
    }

    private var visibleFill: Color {
        if canBePlacedOn { return Color(red: 1.0, green: 0.92, blue: 0.62) }
        if atCap { return Color(red: 0.85, green: 0.78, blue: 0.58).opacity(0.5) }
        return Color(red: 0.95, green: 0.87, blue: 0.65).opacity(0.85)
    }

    private var visibleStroke: Color {
        if canBePlacedOn { return PotionShopTheme.accent }
        return Color(red: 0.55, green: 0.40, blue: 0.20).opacity(0.7)
    }

    private var visibleStrokeWidth: CGFloat {
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

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(gs.hand.enumerated()), id: \.element.id) { idx, die in
                PotionShopDieButtonView(
                    gs: gs,
                    die: die,
                    index: idx,
                    diceFlight: diceFlight
                )
            }
            ForEach(gs.hand.count..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        Color.white.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                    )
                    .frame(
                        width: PotionShopCauldronLayout.dieSize,
                        height: PotionShopCauldronLayout.dieSize
                    )
            }
        }
        .padding(8)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.35, blue: 0.17),
                    Color(red: 0.42, green: 0.27, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(PotionShopTheme.ink, lineWidth: 2)
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

    private var isSelected: Bool { gs.selectedHandIndex == index }
    private var atCap: Bool { gs.placements.count >= PotionShopConfig.maxPlacementsPerBrew }

    var body: some View {
        Button {
            gs.selectHand(index)
        } label: {
            // Try to load die face image, fallback to colored square
            if let dieImage = PotionShopImageLoader.loadImage(named: die.type.assetName) {
                ZStack {
                    Image(uiImage: dieImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: PotionShopCauldronLayout.dieSize,
                            height: PotionShopCauldronLayout.dieSize
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isSelected ? Color.yellow : Color.white.opacity(0.5), lineWidth: isSelected ? 3 : 1.5)
                        )
                    
                    // Die value overlaid on center
                    Text("\(die.value)")
                        .font(.system(size: 18, weight: .heavy, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                }
                .matchedGeometryEffect(
                    id: die.id,
                    in: diceFlight,
                    properties: [.position, .size]
                )
            } else {
                // Placeholder colored square with text
                VStack(spacing: 1) {
                    Text(die.type.abbr)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(die.value)")
                        .font(.system(size: 14, weight: .heavy, design: .serif))
                }
                .foregroundColor(.white)
                .frame(
                    width: PotionShopCauldronLayout.dieSize,
                    height: PotionShopCauldronLayout.dieSize
                )
                .background(die.type.color)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isSelected ? Color.yellow : Color.white.opacity(0.5), lineWidth: isSelected ? 3 : 1.5)
                )
                .matchedGeometryEffect(
                    id: die.id,
                    in: diceFlight,
                    properties: [.position, .size]
                )
            }
        }
        .disabled(gs.isAnimating)
        .opacity(atCap && !isSelected ? 0.5 : 1.0)
        .modifier(PotionShopDiceDropInModifier())
    }
}
