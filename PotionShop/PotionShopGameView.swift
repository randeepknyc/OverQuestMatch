//
//  PotionShopGameView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Main game view
//  Place in: PotionShop/ folder
//
//  PHASE 7: Adds a floating-number overlay above the game scene.
//  When the brew sequence emits floating numbers (via gs.emitFloatingNumber),
//  they appear at their origin point, drift upward, and fade out.
//  A timer-driven purge removes expired numbers from gs.
//  PHASE 12: ART HOOKUP — Background image with parchment fallback
//

import SwiftUI
import Combine

struct PotionShopGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gs = PotionShopGameState()
    @State private var showDebugMenu = false
    @State private var showLayoutOverlay = false
    
    // Use shared layout config for live preview
    @Bindable var layoutConfig = PotionShopLayoutConfig.shared

    @Namespace private var diceFlight

    /// Timer that ticks every 100ms to purge expired floating numbers
    /// from gs.floatingNumbers.
    private let purgeTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            // ✅ VERIFIED CORRECT VALUES - May 4, 2026 Evening
            let totalHeight = geo.size.height
            
            // Section height calculations (percentages from layout editor)
            let headerH      = max(70,  totalHeight * (layoutConfig.headerPercent / 100))
            let sceneH       = max(160, totalHeight * (layoutConfig.scenePercent / 100))
            let profileRowH  = max(74,  totalHeight * (layoutConfig.profilePercent / 100))
            let cauldronH    = max(240, totalHeight * (layoutConfig.cauldronPercent / 100))
            let previewBarH  = max(26,  totalHeight * (layoutConfig.previewPercent / 100))
            let trayH        = max(82,  totalHeight * (layoutConfig.trayPercent / 100))

            ZStack {
                // Background image (or placeholder parchment color)
                if let bgImage = PotionShopImageLoader.loadImage(named: "shop_background") {
                    Image(uiImage: bgImage)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    // Placeholder parchment background
                    PotionShopTheme.bg.ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    PotionShopHeaderView(gs: gs, showDebugMenu: $showDebugMenu)
                        .frame(height: headerH)

                    PotionShopCustomerSceneView(
                        gs: gs,
                        ednarArtScale: 1.0,
                        ednarArtWidth: layoutConfig.ednarWidth,
                        ednarArtHeight: layoutConfig.ednarHeight,
                        ednarArtXOffset: layoutConfig.ednarX,
                        ednarArtYOffset: layoutConfig.ednarY
                    )
                        .frame(height: sceneH)
                        .frame(maxWidth: .infinity)

                    PotionShopProfileRowView(gs: gs)
                        .frame(height: profileRowH)

                    PotionShopCauldronView(
                        gs: gs,
                        diceFlight: diceFlight,
                        cauldronScale: layoutConfig.cauldronBowlScale,
                        cauldronXOffset: layoutConfig.cauldronBowlX,
                        cauldronYOffset: layoutConfig.cauldronBowlY,
                        nodeScale: 1.00,
                        nodeXOffset: 0,
                        nodeYOffset: 0,
                        brewXOffset: -50,
                        brewYPercent: 0.30,
                        showBrewButton: false,
                        brewZoneX: layoutConfig.brewZoneX,
                        brewZoneY: layoutConfig.brewZoneY,
                        brewZoneWidth: layoutConfig.brewZoneWidth,
                        brewZoneHeight: layoutConfig.brewZoneHeight,
                        showBrewZone: layoutConfig.showBrewZone,
                        cauldronArtScale: 1.0,
                        cauldronArtWidth: layoutConfig.cauldronWidth,
                        cauldronArtHeight: layoutConfig.cauldronHeight,
                        cauldronArtXOffset: layoutConfig.cauldronX,
                        cauldronArtYOffset: layoutConfig.cauldronY
                    )
                    // BACKUP (to revert, copy these values back):
                    // brewZoneX: 0.80, brewZoneWidth: 90, showBrewZone: true
                    // cauldronArtWidth: 2.61, cauldronArtHeight: 1.28
                    // cauldronArtXOffset: 6, cauldronArtYOffset: -40
                        .frame(height: cauldronH)

                    PotionShopBrewPreviewBar(gs: gs)
                        .frame(height: previewBarH)

                    PotionShopDiceTrayView(
                        gs: gs,
                        diceFlight: diceFlight,
                        dieScale: layoutConfig.dieScale
                    )
                        .frame(height: trayH)
                        .offset(x: layoutConfig.trayOffsetX, y: layoutConfig.trayOffsetY)

                    Spacer(minLength: 0)
                }

                // Floating number overlay (above everything)
                PotionShopFloatingNumberOverlay(gs: gs)
                    .allowsHitTesting(false)
                
                // Dragged die overlay (above everything else so it doesn't go behind cauldron)
                PotionShopDraggedDieOverlay(gs: gs, diceFlight: diceFlight)
                    .allowsHitTesting(false)

                phaseOverlay
                
                // Layout editor overlay (semi-transparent, floats over game)
                if showLayoutOverlay {
                    PotionShopLayoutOverlay(
                        isPresented: $showLayoutOverlay,
                        gs: gs,
                        diceFlight: diceFlight
                    )
                }
            }
        }
        .sheet(isPresented: $showDebugMenu) {
            PotionShopDebugMenu(
                gs: gs,
                isPresented: $showDebugMenu,
                showLayoutOverlay: $showLayoutOverlay,
                onEndGame: { dismiss() }
            )
        }
        .onReceive(purgeTimer) { _ in
            gs.purgeExpiredFloatingNumbers()
        }
    }

    // MARK: - Phase-end placeholder overlays

    @ViewBuilder
    private var phaseOverlay: some View {
        switch gs.phase {
        case .playing:
            EmptyView()
        case .roundWon:
            placeholderOverlay(
                title: "Round Complete",
                subtitle: "Potions brewed: \(gs.potionsBrewed)",
                buttonLabel: "Continue",
                action: { gs.advanceRound() }
            )
        case .dayWon:
            placeholderOverlay(
                title: "Day Complete!",
                subtitle: "Phase 8 will add a proper day-end screen.\nTap to start over.",
                buttonLabel: "Restart",
                action: { gs.resetGame() }
            )
        case .lost:
            placeholderOverlay(
                title: "You Collapsed",
                subtitle: "Potions brewed before defeat: \(gs.potionsBrewed)",
                buttonLabel: "Try Again",
                action: { gs.resetGame() }
            )
        }
    }

    private func placeholderOverlay(
        title: String,
        subtitle: String,
        buttonLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy, design: .serif))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)

                Button {
                    action()
                } label: {
                    Text(buttonLabel)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(PotionShopTheme.accent)
                        .clipShape(Capsule())
                }
            }
            .padding(40)
        }
    }
}

// MARK: - Floating number overlay

struct PotionShopFloatingNumberOverlay: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        ZStack {
            ForEach(gs.floatingNumbers) { number in
                PotionShopFloatingNumberView(number: number)
            }
        }
    }
}

struct PotionShopFloatingNumberView: View {
    let number: PotionShopFloatingNumber
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        Text(number.text)
            .font(PotionShopBrewAnimator.numberFont())
            .foregroundColor(number.color)
            .shadow(color: .white.opacity(0.7), radius: 1, x: 0, y: 0)
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
            .position(number.position)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: PotionShopBrewAnimator.floatDuration)
                ) {
                    offsetY = -PotionShopBrewAnimator.floatRiseDistance
                    opacity = 0.0
                }
            }
    }
}

// MARK: - Dragged die overlay
//
// Renders the currently dragged die above ALL other content so it doesn't
// go behind the cauldron/nodes when being dragged upward from the tray.

struct PotionShopDraggedDieOverlay: View {
    @Bindable var gs: PotionShopGameState
    let diceFlight: Namespace.ID
    
    var body: some View {
        if let draggedDie = gs.draggedDie {
            // Invisible placeholder that uses matchedGeometryEffect
            // This acts as the destination for the dragged die
            Color.clear
                .frame(width: PotionShopCauldronLayout.dieSize, height: PotionShopCauldronLayout.dieSize)
                .matchedGeometryEffect(
                    id: draggedDie.id,
                    in: diceFlight,
                    properties: [.position, .size]
                )
        }
    }
}

// MARK: - Layout Editor Overlay
//
// Semi-transparent overlay that floats over the game view for live layout editing.
// Only the active section's controls are visible at a time.

struct PotionShopLayoutOverlay: View {
    @Binding var isPresented: Bool
    @Bindable var gs: PotionShopGameState
    let diceFlight: Namespace.ID
    
    // Use the shared config instead of local state
    @Bindable var layoutConfig = PotionShopLayoutConfig.shared
    
    // UI State
    @State private var activeSection: LayoutSection? = nil
    
    enum LayoutSection: String, CaseIterable {
        case sections = "📏 Sections"
        case ednar = "🧙 Ednar"
        case cauldronArt = "🍲 Cauldron"
        case cauldronBowl = "🥘 Bowl"
        case dice = "🎲 Dice"
        case brewZone = "🥄 Brew"
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background (20% opacity)
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tap background to close
                    isPresented = false
                }
            
            // Floating control panel at bottom
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Close button at top
                    HStack {
                        Spacer()
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.7))
                    
                    // Section picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(LayoutSection.allCases, id: \.self) { section in
                                Button {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                        activeSection = activeSection == section ? nil : section
                                    }
                                } label: {
                                    Text(section.rawValue)
                                        .font(.caption2.bold())
                                        .foregroundColor(activeSection == section ? .black : .white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(activeSection == section ? Color.cyan : Color.white.opacity(0.3))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color.black.opacity(0.7))
                    
                    // Active section controls
                    if let section = activeSection {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionContent(for: section)
                            }
                            .padding()
                        }
                        .frame(maxHeight: 200)
                        .background(Color.black.opacity(0.8))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            }
        }
    }
    
    // MARK: - Section Content
    
    @ViewBuilder
    private func sectionContent(for section: LayoutSection) -> some View {
        switch section {
        case .sections:
            Text("Section heights coming soon...")
                .foregroundColor(.white.opacity(0.7))
        case .ednar:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Width", value: $layoutConfig.ednarWidth, range: 0.5...3.0, format: "%.2f×")
                sliderRow("Height", value: $layoutConfig.ednarHeight, range: 0.5...3.0, format: "%.2f×")
                sliderRow("X", value: $layoutConfig.ednarX, range: -200...200, format: "%.0f")
                sliderRow("Y", value: $layoutConfig.ednarY, range: -200...200, format: "%.0f")
            }
        case .cauldronArt:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Width", value: $layoutConfig.cauldronWidth, range: 0.5...3.0, format: "%.2f×")
                sliderRow("Height", value: $layoutConfig.cauldronHeight, range: 0.5...3.0, format: "%.2f×")
                sliderRow("X", value: $layoutConfig.cauldronX, range: -200...200, format: "%.0f")
                sliderRow("Y", value: $layoutConfig.cauldronY, range: -200...200, format: "%.0f")
            }
        case .cauldronBowl:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Scale", value: $layoutConfig.cauldronBowlScale, range: 0.5...3.0, format: "%.2f×")
                sliderRow("X", value: $layoutConfig.cauldronBowlX, range: -200...200, format: "%.0f")
                sliderRow("Y", value: $layoutConfig.cauldronBowlY, range: -200...200, format: "%.0f")
            }
        case .dice:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Die Scale", value: $layoutConfig.dieScale, range: 0.5...3.0, format: "%.2f×")
                sliderRow("Tray X", value: $layoutConfig.trayOffsetX, range: -200...200, format: "%.0f")
                sliderRow("Tray Y", value: $layoutConfig.trayOffsetY, range: -200...200, format: "%.0f")
            }
        case .brewZone:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("X", value: $layoutConfig.brewZoneX, range: 0...1, format: "%.2f")
                sliderRow("Y", value: $layoutConfig.brewZoneY, range: 0...1, format: "%.2f")
                sliderRow("Width", value: $layoutConfig.brewZoneWidth, range: 50...300, format: "%.0f")
                sliderRow("Height", value: $layoutConfig.brewZoneHeight, range: 50...300, format: "%.0f")
                Toggle("Show Zone", isOn: $layoutConfig.showBrewZone)
                    .toggleStyle(SwitchToggleStyle(tint: .cyan))
                    .foregroundColor(.white)
            }
        }
    }
    
    private func sliderRow(_ label: String, value: Binding<Double>, range: ClosedRange<Double>, format: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.cyan)
            }
            Slider(value: value, in: range)
                .tint(.cyan)
        }
    }
}

// MARK: - Preview

#Preview {
    PotionShopGameView()
}
