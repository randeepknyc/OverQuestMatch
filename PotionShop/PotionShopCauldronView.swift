//
//  PotionShopCauldronView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Cauldron + dice tray
//  Place in: PotionShop/ folder
//
//  TWO STACKED SECTIONS:
//
//  1. Cauldron + BREW button:
//     - 12-node graph rendered using PotionShopBoard.nodes positions
//     - Edges drawn as faint lines between connected nodes
//     - Player taps a die (tray) then taps a node to place it
//     - BREW button on the right (placeholder ladle position)
//
//  2. Dice tray:
//     - 5 slots; empty slots show as dashed outlines
//     - Tap a die to select it (yellow ring); tap again to deselect
//     - When selected, tap a node in the cauldron to place
//     - Tap a placed die in the cauldron to return it to the tray
//
//  NAMING NOTE: Every public struct in this file uses the PotionShop
//  prefix to avoid collisions with the existing CauldronGame and
//  ShopOfOddities folders. The existing CauldronGame already has a
//  CauldronBoardView, so this game uses PotionShopCauldronBoardView.
//  Don't rename them.
//

import SwiftUI

// MARK: - Layout constants for the cauldron

struct PotionShopCauldronLayout {
    /// The cauldron board's coordinate range. Used to scale into the
    /// SwiftUI canvas. PotionShopBoard.nodes use x in roughly [0, 110]
    /// and y in roughly [0, 145].
    static let boardWidth:  CGFloat = 115
    static let boardHeight: CGFloat = 150

    /// Visible node sizes.
    static let nodeVisible: CGFloat = 28
    static let nodeHitArea: CGFloat = 40

    /// Dice tray sizing.
    static let dieSize:     CGFloat = 44
}

// MARK: - Cauldron + dice tray (composed)

struct PotionShopCauldronView: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        VStack(spacing: 12) {
            // Cauldron with nodes + BREW button
            PotionShopCauldronBoardView(gs: gs)

            // Placement counter and brew preview
            PotionShopBrewPreviewBar(gs: gs)

            // Dice tray
            PotionShopDiceTrayView(gs: gs)
        }
    }
}

// MARK: - Cauldron board

struct PotionShopCauldronBoardView: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        GeometryReader { geo in
            let boardW = PotionShopCauldronLayout.boardWidth
            let boardH = PotionShopCauldronLayout.boardHeight

            // Reserve right ~120pt for the BREW button.
            let cauldronW = geo.size.width - 120
            let cauldronH = geo.size.height
            let scaleX = cauldronW / boardW
            let scaleY = cauldronH / boardH
            let scale = min(scaleX, scaleY)

            // Center the cauldron in the left portion
            let centerX = cauldronW / 2
            let centerY = cauldronH / 2
            let originX = centerX - (boardW * scale) / 2
            let originY = centerY - (boardH * scale) / 2

            ZStack {
                // Cauldron background (placeholder shape)
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.20, green: 0.45, blue: 0.30),
                                Color(red: 0.12, green: 0.30, blue: 0.20)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                    )
                    .frame(width: cauldronW * 0.95, height: cauldronH * 0.95)
                    .overlay(
                        Ellipse()
                            .stroke(PotionShopTheme.ink, lineWidth: 3)
                    )
                    .position(x: centerX, y: centerY)

                // Edges between nodes (faint lines)
                Path { path in
                    for (a, b) in PotionShopBoard.edges {
                        let na = PotionShopBoard.nodes[a]
                        let nb = PotionShopBoard.nodes[b]
                        path.move(
                            to: CGPoint(
                                x: originX + CGFloat(na.x) * scale,
                                y: originY + CGFloat(na.y) * scale
                            )
                        )
                        path.addLine(
                            to: CGPoint(
                                x: originX + CGFloat(nb.x) * scale,
                                y: originY + CGFloat(nb.y) * scale
                            )
                        )
                    }
                }
                .stroke(Color.white.opacity(0.35), lineWidth: 1)

                // Nodes
                ForEach(0..<PotionShopBoard.nodes.count, id: \.self) { idx in
                    let node = PotionShopBoard.nodes[idx]
                    PotionShopNodeButtonView(gs: gs, nodeIndex: idx)
                        .position(
                            x: originX + CGFloat(node.x) * scale,
                            y: originY + CGFloat(node.y) * scale
                        )
                }

                // BREW button on the right side
                PotionShopBrewButtonView(gs: gs)
                    .position(
                        x: geo.size.width - 60,
                        y: 60
                    )
            }
        }
        .frame(height: 220)
        .padding(.horizontal, 8)
    }
}

// MARK: - One node on the cauldron

struct PotionShopNodeButtonView: View {
    @Bindable var gs: PotionShopGameState
    let nodeIndex: Int

    private var placedDie: PotionShopDie? { gs.placements[nodeIndex] }
    private var dieSelected: Bool { gs.selectedHandIndex != nil }
    private var atCap: Bool { gs.placements.count >= PotionShopConfig.maxPlacementsPerBrew }
    private var canBePlacedOn: Bool { dieSelected && !atCap && placedDie == nil }

    var body: some View {
        Button {
            gs.tapNode(nodeIndex)
        } label: {
            ZStack {
                // Larger transparent hit area
                Rectangle()
                    .fill(Color.clear)
                    .frame(
                        width: PotionShopCauldronLayout.nodeHitArea,
                        height: PotionShopCauldronLayout.nodeHitArea
                    )
                    .contentShape(Rectangle())

                // The visible square
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

                // Placed die value
                if let die = placedDie {
                    Text("\(die.value)")
                        .font(.system(size: 13, weight: .heavy, design: .serif))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(gs.isAnimating)
    }

    private var visibleFill: Color {
        if let die = placedDie {
            return die.type.color
        }
        if canBePlacedOn { return Color(red: 1.0, green: 0.95, blue: 0.7) }
        if atCap { return Color.white.opacity(0.15) }
        return Color.white.opacity(0.3)
    }

    private var visibleStroke: Color {
        if placedDie != nil { return PotionShopTheme.ink }
        if canBePlacedOn { return PotionShopTheme.accent }
        return Color.white.opacity(0.6)
    }

    private var visibleStrokeWidth: CGFloat {
        if canBePlacedOn { return 2 }
        if placedDie != nil { return 1.5 }
        return 1
    }
}

// MARK: - BREW button

struct PotionShopBrewButtonView: View {
    @Bindable var gs: PotionShopGameState

    private var canBrew: Bool {
        !gs.placements.isEmpty && !gs.isAnimating && gs.phase == .playing
    }

    var body: some View {
        Button {
            gs.doBrew()
        } label: {
            VStack(spacing: 4) {
                Text("🥄")
                    .font(.system(size: 32))
                Text("BREW")
                    .font(.system(size: 13, weight: .heavy, design: .serif))
                    .tracking(2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(canBrew ? PotionShopTheme.accent : PotionShopTheme.muted)
                    .clipShape(Capsule())
            }
        }
        .disabled(!canBrew)
        .opacity(canBrew ? 1.0 : 0.6)
    }
}

// MARK: - Brew preview bar (between cauldron and tray)

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
    }
}

// MARK: - Dice tray

struct PotionShopDiceTrayView: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(gs.hand.enumerated()), id: \.element.id) { idx, die in
                PotionShopDieButtonView(gs: gs, die: die, index: idx)
            }
            // Empty slot placeholders
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
        .padding(.bottom, 14)
        .opacity(gs.isAnimating ? 0.7 : 1.0)
    }
}

// MARK: - One die in the tray

struct PotionShopDieButtonView: View {
    @Bindable var gs: PotionShopGameState
    let die: PotionShopDie
    let index: Int

    private var isSelected: Bool { gs.selectedHandIndex == index }
    private var atCap: Bool { gs.placements.count >= PotionShopConfig.maxPlacementsPerBrew }

    var body: some View {
        Button {
            gs.selectHand(index)
        } label: {
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
        }
        .disabled(gs.isAnimating)
        .opacity(atCap && !isSelected ? 0.5 : 1.0)
    }
}
