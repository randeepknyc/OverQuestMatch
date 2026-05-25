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
                        ednarArtYOffset: layoutConfig.ednarY,
                        layoutConfig: layoutConfig  // ← NEW: Pass layout config for customer scaling
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
                        nodeScale: layoutConfig.nodeScale,
                        nodeXOffset: layoutConfig.nodeXOffset,
                        nodeYOffset: layoutConfig.nodeYOffset,
                        nodeSpacingMultiplier: layoutConfig.nodeSpacingMultiplier,
                        perNodeOffsets: layoutConfig.perNodeOffsets,
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
            if PotionShopData.isLastDay(gs.dayId) {
                placeholderOverlay(
                    title: "Success, Day Complete!",
                    subtitle: "You've finished every available day.\nPotions brewed: \(gs.potionsBrewed)",
                    buttonLabel: "Restart",
                    action: { gs.resetGame() }
                )
            } else {
                placeholderOverlay(
                    title: "Success, Day Complete!",
                    subtitle: "Potions brewed today: \(gs.potionsBrewed)",
                    buttonLabel: "Re-open shop tomorrow",
                    action: { gs.advanceDay() }
                )
            }
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
                    .font(Font.gameUI(size: 28))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(Font.gameUI(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)

                Button {
                    action()
                } label: {
                    Text(buttonLabel)
                        .font(Font.gameUI(size: 15))
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
    @State private var selectedNodeIndex: Int = 0  // For fine-tune section
    @State private var selectedCharacterId: String = "mildred"  // For customers section
    
    enum LayoutSection: String, CaseIterable {
        case sections = "📏 Sections"
        case ednar = "🧙 Ednar"
        case customers = "🧍 Customers"  // NEW: Customer scene portraits
        case badges = "🎨 Badges"  // NEW: HP/Attack badges + bottle graphic
        case permutations = "🎭 Permutations"  // NEW: 3-character queue spacing
        case autoLayout = "🎲 Auto-Layout"  // NEW (May 25): Day 3 auto-spacing
        case cauldronArt = "🍲 Cauldron"
        case cauldronBowl = "🥘 Bowl"
        case nodes = "🔵 Nodes"
        case fineTune = "🔧 Fine-Tune"
        case dice = "🎲 Dice"
        case brewZone = "🥄 Brew"
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background (20% opacity) — taps pass through to the game.
            // Use the X button at the top of the floating panel to close the editor.
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Floating control panel at bottom
            VStack {
                Spacer()
                    .allowsHitTesting(false)
                
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
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Header", value: $layoutConfig.headerPercent, range: 0...20, format: "%.1f%%")
                sliderRow("Scene", value: $layoutConfig.scenePercent, range: 0...50, format: "%.1f%%")
                sliderRow("Profile", value: $layoutConfig.profilePercent, range: 0...20, format: "%.1f%%")
                sliderRow("Cauldron", value: $layoutConfig.cauldronPercent, range: 0...60, format: "%.1f%%")
                sliderRow("Preview", value: $layoutConfig.previewPercent, range: 0...10, format: "%.1f%%")
                sliderRow("Tray", value: $layoutConfig.trayPercent, range: 0...30, format: "%.1f%%")
                
                // Total percentage indicator
                let total = layoutConfig.headerPercent + layoutConfig.scenePercent + layoutConfig.profilePercent + 
                           layoutConfig.cauldronPercent + layoutConfig.previewPercent + layoutConfig.trayPercent
                HStack {
                    Text("Total:")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Text(String(format: "%.1f%%", total))
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundColor(total > 100 ? .red : .green)
                }
                .padding(.top, 4)
            }
        case .ednar:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Width", value: $layoutConfig.ednarWidth, range: 0.5...5.0, format: "%.2f×")
                sliderRow("Height", value: $layoutConfig.ednarHeight, range: 0.5...5.0, format: "%.2f×")
                sliderRow("X", value: $layoutConfig.ednarX, range: -200...200, format: "%.0f")
                sliderRow("Y", value: $layoutConfig.ednarY, range: -200...200, format: "%.0f")
            }
        case .customers:
            VStack(alignment: .leading, spacing: 10) {
                Text("🧍 Customer Scene Portraits")
                    .font(.caption2.bold())
                    .foregroundColor(.cyan)
                
                // Character picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Select Character")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    Picker("Character", selection: $selectedCharacterId) {
                        Text("Mildred").tag("mildred")
                        Text("Tomik").tag("tomik")
                        Text("Greta").tag("greta")
                        Text("Sister Halla").tag("sister_halla")
                        Text("Wendelina").tag("wendelina")
                        Text("Grimdrek").tag("grimdrek")
                        Text("Hexa Mott").tag("hexa_mott")
                        Text("Pemberton").tag("pemberton")
                        Text("Ardo").tag("ardo")
                        Text("Bram").tag("bram")
                        Text("Crispin").tag("crispin")
                        Text("Ironhilde").tag("ironhilde")
                        Text("Carmilla").tag("carmilla")
                        Text("Royal Envoy").tag("royal_envoy")
                    }
                    .pickerStyle(.menu)
                    .tint(.cyan)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 4)
                
                // ACTIVE POSITION CONTROLS
                Text("⭐️ ACTIVE POSITION")
                    .font(.caption2.bold())
                    .foregroundColor(.green)
                
                // 🔗 Uniform Scale slider (adjusts both width AND height together)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("🔗 Uniform Scale")
                            .font(.caption2.bold())
                            .foregroundColor(.yellow)
                        Spacer()
                        Text(String(format: "%.2f×", layoutConfig.characterScale(for: selectedCharacterId).width))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    Slider(
                        value: Binding<Double>(
                            get: { layoutConfig.characterScale(for: selectedCharacterId).width },
                            set: { newValue in
                                var scale = layoutConfig.characterScale(for: selectedCharacterId)
                                scale.width = newValue
                                scale.height = newValue  // ← Apply same value to height!
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                            }
                        ),
                        in: 0.5...5.0
                    )
                    .tint(.yellow)
                    
                    Text("Adjusts width AND height together")
                        .font(.system(size: 9))
                        .foregroundColor(.yellow.opacity(0.8))
                        .italic()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 4)
                
                // Per-character sliders (now uses selectedCharacterId)
                VStack(alignment: .leading, spacing: 10) {
                    let widthBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).width },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.width = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("Width", value: widthBinding, range: 0.5...5.0, format: "%.2f×")
                    
                    let heightBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).height },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.height = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("Height", value: heightBinding, range: 0.5...5.0, format: "%.2f×")
                    
                    let xBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).x },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.x = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("X", value: xBinding, range: -200...200, format: "%.0f pt")
                    
                    let yBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).y },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.y = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("Y", value: yBinding, range: -200...200, format: "%.0f pt")
                }
                
                Divider()
                    .background(Color.white.opacity(0.5))
                    .padding(.vertical, 6)
                
                // WAITING POSITION CONTROLS (NEW!)
                Text("⏸️ WAITING POSITION")
                    .font(.caption2.bold())
                    .foregroundColor(.orange)
                
                // Waiting Uniform Scale slider
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("🔗 Uniform Scale")
                            .font(.caption2.bold())
                            .foregroundColor(.yellow)
                        Spacer()
                        Text(String(format: "%.2f×", layoutConfig.characterScale(for: selectedCharacterId).waitingWidth))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    Slider(
                        value: Binding<Double>(
                            get: { layoutConfig.characterScale(for: selectedCharacterId).waitingWidth },
                            set: { newValue in
                                var scale = layoutConfig.characterScale(for: selectedCharacterId)
                                scale.waitingWidth = newValue
                                scale.waitingHeight = newValue  // ← Apply same value to waiting height!
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                            }
                        ),
                        in: 0.5...5.0
                    )
                    .tint(.yellow)
                    
                    Text("Waiting scale (when not active)")
                        .font(.system(size: 9))
                        .foregroundColor(.yellow.opacity(0.8))
                        .italic()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 4)
                
                // Waiting position individual sliders
                VStack(alignment: .leading, spacing: 10) {
                    let waitingWidthBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).waitingWidth },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.waitingWidth = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("Width", value: waitingWidthBinding, range: 0.5...5.0, format: "%.2f×")
                    
                    let waitingHeightBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).waitingHeight },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.waitingHeight = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("Height", value: waitingHeightBinding, range: 0.5...5.0, format: "%.2f×")
                    
                    let waitingXBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).waitingX },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.waitingX = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("X", value: waitingXBinding, range: -200...200, format: "%.0f pt")
                    
                    let waitingYBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).waitingY },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.waitingY = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("Y", value: waitingYBinding, range: -200...200, format: "%.0f pt")
                }
                
                Divider()
                    .background(Color.white.opacity(0.5))
                    .padding(.vertical, 6)
                
                // WAITING POSITION 2 CONTROLS (NEW! - queue[2])
                Text("⏸️ WAITING POSITION 2 (queue[2])")
                    .font(.caption2.bold())
                    .foregroundColor(.purple)
                
                // Waiting2 Uniform Scale slider
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("🔗 Uniform Scale")
                            .font(.caption2.bold())
                            .foregroundColor(.yellow)
                        Spacer()
                        Text(String(format: "%.2f×", layoutConfig.characterScale(for: selectedCharacterId).waiting2Width))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    Slider(
                        value: Binding<Double>(
                            get: { layoutConfig.characterScale(for: selectedCharacterId).waiting2Width },
                            set: { newValue in
                                var scale = layoutConfig.characterScale(for: selectedCharacterId)
                                scale.waiting2Width = newValue
                                scale.waiting2Height = newValue  // ← Apply same value to waiting2 height!
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                            }
                        ),
                        in: 0.5...5.0
                    )
                    .tint(.yellow)
                    
                    Text("Back position scale (queue[2])")
                        .font(.system(size: 9))
                        .foregroundColor(.yellow.opacity(0.8))
                        .italic()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 4)
                
                // Waiting position 2 individual sliders
                VStack(alignment: .leading, spacing: 10) {
                    let waiting2WidthBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).waiting2Width },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.waiting2Width = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("Width", value: waiting2WidthBinding, range: 0.5...5.0, format: "%.2f×")
                    
                    let waiting2HeightBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).waiting2Height },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.waiting2Height = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("Height", value: waiting2HeightBinding, range: 0.5...5.0, format: "%.2f×")
                    
                    let waiting2XBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).waiting2X },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.waiting2X = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("X", value: waiting2XBinding, range: -200...200, format: "%.0f pt")
                    
                    let waiting2YBinding = Binding<Double>(
                        get: { layoutConfig.characterScale(for: selectedCharacterId).waiting2Y },
                        set: { newValue in
                            var scale = layoutConfig.characterScale(for: selectedCharacterId)
                            scale.waiting2Y = newValue
                            layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                        }
                    )
                    sliderRow("Y", value: waiting2YBinding, range: -200...200, format: "%.0f pt")
                }
                
                Divider()
                    .background(Color.white.opacity(0.5))
                    .padding(.vertical, 6)
                
                // Helper buttons
                HStack(spacing: 12) {
                    // Link W/H button
                    Button("Link W/H") {
                        var scale = layoutConfig.characterScale(for: selectedCharacterId)
                        scale.waiting2Height = scale.waiting2Width
                        layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                    }
                    .font(.caption2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cyan)
                    .cornerRadius(4)
                    
                    // Reset Position button
                    Button("Reset Position") {
                        var scale = layoutConfig.characterScale(for: selectedCharacterId)
                        scale.waiting2X = 0
                        scale.waiting2Y = 0
                        layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: scale)
                    }
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(4)
                }
                
                // Reset button (now uses selected character)
                Button("Reset \(selectedCharacterId.capitalized)") {
                    layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: PotionShopLayoutConfig.CharacterScale())
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .cornerRadius(6)
            }
        case .cauldronArt:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Width", value: $layoutConfig.cauldronWidth, range: 0.5...5.0, format: "%.2f×")
                sliderRow("Height", value: $layoutConfig.cauldronHeight, range: 0.5...5.0, format: "%.2f×")
                sliderRow("X", value: $layoutConfig.cauldronX, range: -200...200, format: "%.0f")
                sliderRow("Y", value: $layoutConfig.cauldronY, range: -200...200, format: "%.0f")
            }
        case .cauldronBowl:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Scale", value: $layoutConfig.cauldronBowlScale, range: 0.5...5.0, format: "%.2f×")
                sliderRow("X", value: $layoutConfig.cauldronBowlX, range: -200...200, format: "%.0f")
                sliderRow("Y", value: $layoutConfig.cauldronBowlY, range: -200...200, format: "%.0f")
            }
        case .nodes:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Node Scale", value: $layoutConfig.nodeScale, range: 0.5...5.0, format: "%.2f×")
                sliderRow("Grid X", value: $layoutConfig.nodeXOffset, range: -200...200, format: "%.0f")
                sliderRow("Grid Y", value: $layoutConfig.nodeYOffset, range: -200...200, format: "%.0f")
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 4)
                
                // Spacing multiplier with warning
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("⚠️ Spacing")
                            .font(.caption2.bold())
                            .foregroundColor(.orange)
                        Spacer()
                        Text(String(format: "%.2f×", layoutConfig.nodeSpacingMultiplier))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(layoutConfig.nodeSpacingMultiplier == 1.0 ? .cyan : .orange)
                    }
                    Slider(value: $layoutConfig.nodeSpacingMultiplier, in: 0.5...2.0)
                        .tint(.orange)
                    
                    if layoutConfig.nodeSpacingMultiplier != 1.0 {
                        Text("Experimental: Visual only, boost reach unchanged")
                            .font(.system(size: 9))
                            .foregroundColor(.orange.opacity(0.9))
                            .italic()
                    }
                }
            }
        case .fineTune:
            VStack(alignment: .leading, spacing: 12) {
                // Node picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Select Node")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    Picker("Node", selection: $selectedNodeIndex) {
                        ForEach(0..<12) { idx in
                            Text("Node \(idx)").tag(idx)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.cyan)
                }
                
                // X/Y offset sliders for selected node
                VStack(alignment: .leading, spacing: 10) {
                    let binding = Binding<Double>(
                        get: { layoutConfig.perNodeOffsets[selectedNodeIndex].x },
                        set: { layoutConfig.perNodeOffsets[selectedNodeIndex].x = $0 }
                    )
                    sliderRow("X Offset", value: binding, range: -100...100, format: "%.0f pt")
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    let binding = Binding<Double>(
                        get: { layoutConfig.perNodeOffsets[selectedNodeIndex].y },
                        set: { layoutConfig.perNodeOffsets[selectedNodeIndex].y = $0 }
                    )
                    sliderRow("Y Offset", value: binding, range: -100...100, format: "%.0f pt")
                }
                
                // Reset buttons
                HStack(spacing: 8) {
                    Button("Reset This Node") {
                        layoutConfig.perNodeOffsets[selectedNodeIndex] = .zero
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .cornerRadius(6)
                    
                    Button("Reset All Nodes") {
                        layoutConfig.resetAllNodeOffsets()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .cornerRadius(6)
                }
            }
        case .dice:
            VStack(alignment: .leading, spacing: 10) {
                sliderRow("Die Scale", value: $layoutConfig.dieScale, range: 0.5...5.0, format: "%.2f×")
                sliderRow("Tray X", value: $layoutConfig.trayOffsetX, range: -200...200, format: "%.0f")
                sliderRow("Tray Y", value: $layoutConfig.trayOffsetY, range: -200...200, format: "%.0f")
            }
        case .autoLayout:
            // 🎲 AUTO-LAYOUT (Day 3 RNG test) — May 25, 2026
            VStack(alignment: .leading, spacing: 12) {
                Text("🎲 Day 3 Auto-Layout")
                    .font(.caption2.bold())
                    .foregroundColor(.cyan)
                Text("Tune how Day 3 customers space themselves. Only affects flex days (Day 3+). Day 1/2 untouched.")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))

                Text("Queue X Range")
                    .font(.caption2.bold())
                    .foregroundColor(.yellow)
                sliderRow("Active X (queue[0])", value: $layoutConfig.autoLayoutStartX, range: 0.1...0.7, format: "%.3f")
                sliderRow("Back of line X", value: $layoutConfig.autoLayoutEndX, range: 0.5...0.99, format: "%.3f")

                Text("Queue Y")
                    .font(.caption2.bold())
                    .foregroundColor(.yellow)
                sliderRow("Active Y", value: $layoutConfig.autoLayoutYActive, range: 0.2...0.9, format: "%.3f")
                sliderRow("Waiter Y", value: $layoutConfig.autoLayoutYWaiting, range: 0.2...0.9, format: "%.3f")

                Text("Per-Slot Scale")
                    .font(.caption2.bold())
                    .foregroundColor(.yellow)
                sliderRow("Active scale", value: $layoutConfig.autoLayoutScaleActive, range: 0.4...1.5, format: "%.2f")
                sliderRow("Waiting 1 scale", value: $layoutConfig.autoLayoutScaleWaiting1, range: 0.4...1.5, format: "%.2f")
                sliderRow("Waiting 2 scale", value: $layoutConfig.autoLayoutScaleWaiting2, range: 0.4...1.5, format: "%.2f")

                Text("Width Bucket Weights")
                    .font(.caption2.bold())
                    .foregroundColor(.yellow)
                Text("Larger weight = character takes more horizontal room in the queue.")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                sliderRow("Skinny weight", value: $layoutConfig.autoLayoutWidthWeightSkinny, range: 0.5...3.0, format: "%.2f")
                sliderRow("Medium weight", value: $layoutConfig.autoLayoutWidthWeightMedium, range: 0.5...3.0, format: "%.2f")
                sliderRow("Wide weight", value: $layoutConfig.autoLayoutWidthWeightWide, range: 0.5...3.0, format: "%.2f")

                Text("Per-Height-Bucket Y Adjust")
                    .font(.caption2.bold())
                    .foregroundColor(.yellow)
                Text("Adds to the base Y for each bucket. Use to align floaters higher, tallHats lower, etc.")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                sliderRow("SuperShort Y+", value: $layoutConfig.autoLayoutYAdjustSuperShort, range: -0.2...0.2, format: "%+.3f")
                sliderRow("Short Y+", value: $layoutConfig.autoLayoutYAdjustShort, range: -0.2...0.2, format: "%+.3f")
                sliderRow("Medium Y+", value: $layoutConfig.autoLayoutYAdjustMedium, range: -0.2...0.2, format: "%+.3f")
                sliderRow("Tall Y+", value: $layoutConfig.autoLayoutYAdjustTall, range: -0.2...0.2, format: "%+.3f")
                sliderRow("TallHat Y+", value: $layoutConfig.autoLayoutYAdjustTallHat, range: -0.2...0.2, format: "%+.3f")
                sliderRow("Floater Y+", value: $layoutConfig.autoLayoutYAdjustFloater, range: -0.2...0.2, format: "%+.3f")
            }
        case .badges:
            // 🎨 BADGE GRAPHICS - HP/Attack badges + bottle graphic
            VStack(alignment: .leading, spacing: 12) {
                Text("🎨 Custom Badge Graphics")
                    .font(.caption2.bold())
                    .foregroundColor(.cyan)
                
                Text("Adjust the size of your custom badge graphics. Draw at high resolution (256×256 or 512×512), then tune the on-screen size here.")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 6)
                
                // HP / Attack Badges — per-bucket tuning (May 23, 2026)
                VStack(alignment: .leading, spacing: 12) {
                    Text("❤️⚔️ HP + Attack Badges (per height bucket)")
                        .font(.caption2.bold())
                        .foregroundColor(.red)
                    Text("Each height bucket has its own size + offsets. Tune one bucket at a time using customers in that bucket.")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))

                    // Short bucket
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• Short")
                            .font(.caption2.bold())
                            .foregroundColor(.yellow)
                        sliderRow("HP Size",  value: $layoutConfig.hpBadgeSizeShort,    range: 10...100, format: "%.0f pt")
                        sliderRow("HP X",     value: $layoutConfig.hpBadgeOffsetXShort, range: -300...300, format: "%.0f pt")
                        sliderRow("HP Y",     value: $layoutConfig.hpBadgeOffsetYShort, range: -150...150, format: "%.0f pt")
                        sliderRow("Atk Size", value: $layoutConfig.attackBadgeSizeShort,    range: 10...100, format: "%.0f pt")
                        sliderRow("Atk X",    value: $layoutConfig.attackBadgeOffsetXShort, range: -300...300, format: "%.0f pt")
                        sliderRow("Atk Y",    value: $layoutConfig.attackBadgeOffsetYShort, range: -150...150, format: "%.0f pt")
                    }

                    Divider().background(Color.white.opacity(0.2))

                    // Medium bucket
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• Medium")
                            .font(.caption2.bold())
                            .foregroundColor(.yellow)
                        sliderRow("HP Size",  value: $layoutConfig.hpBadgeSizeMedium,    range: 10...100, format: "%.0f pt")
                        sliderRow("HP X",     value: $layoutConfig.hpBadgeOffsetXMedium, range: -300...300, format: "%.0f pt")
                        sliderRow("HP Y",     value: $layoutConfig.hpBadgeOffsetYMedium, range: -150...150, format: "%.0f pt")
                        sliderRow("Atk Size", value: $layoutConfig.attackBadgeSizeMedium,    range: 10...100, format: "%.0f pt")
                        sliderRow("Atk X",    value: $layoutConfig.attackBadgeOffsetXMedium, range: -300...300, format: "%.0f pt")
                        sliderRow("Atk Y",    value: $layoutConfig.attackBadgeOffsetYMedium, range: -150...150, format: "%.0f pt")
                    }

                    Divider().background(Color.white.opacity(0.2))

                    // Tall bucket
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• Tall")
                            .font(.caption2.bold())
                            .foregroundColor(.yellow)
                        sliderRow("HP Size",  value: $layoutConfig.hpBadgeSizeTall,    range: 10...100, format: "%.0f pt")
                        sliderRow("HP X",     value: $layoutConfig.hpBadgeOffsetXTall, range: -300...300, format: "%.0f pt")
                        sliderRow("HP Y",     value: $layoutConfig.hpBadgeOffsetYTall, range: -150...150, format: "%.0f pt")
                        sliderRow("Atk Size", value: $layoutConfig.attackBadgeSizeTall,    range: 10...100, format: "%.0f pt")
                        sliderRow("Atk X",    value: $layoutConfig.attackBadgeOffsetXTall, range: -300...300, format: "%.0f pt")
                        sliderRow("Atk Y",    value: $layoutConfig.attackBadgeOffsetYTall, range: -150...150, format: "%.0f pt")
                    }

                    Text("Assets: hp_badge.png / attack_badge.png")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                        .italic()
                }

                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 4)

                // Bottle Graphic slider
                VStack(alignment: .leading, spacing: 10) {
                    Text("🧪 Bottle Graphic (inspect banner)")
                        .font(.caption2.bold())
                        .foregroundColor(.cyan)
                    sliderRow("Bottle Size", value: $layoutConfig.bannerBottleSize, range: 20...80, format: "%.0f pt")
                    sliderRow("Bottle X", value: $layoutConfig.bannerBottleOffsetX, range: -150...150, format: "%.0f pt")
                    sliderRow("Bottle Y", value: $layoutConfig.bannerBottleOffsetY, range: -150...150, format: "%.0f pt")
                    sliderRow("Number Size", value: $layoutConfig.bannerBottleNumberSize, range: 10...60, format: "%.0f pt")
                    sliderRow("Number X", value: $layoutConfig.bannerBottleNumberOffsetX, range: -50...50, format: "%.0f pt")
                    sliderRow("Number Y", value: $layoutConfig.bannerBottleNumberOffsetY, range: -50...50, format: "%.0f pt")
                    Text("Asset name: potion_bottle_outline.png")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                        .italic()
                }
                
                Divider()
                    .background(Color.white.opacity(0.5))
                    .padding(.vertical, 6)

                // Head Anchor Defaults (May 22, 2026) — bucket-based per-character head positions
                VStack(alignment: .leading, spacing: 10) {
                    Text("🧍 Head Anchor Defaults (by bucket)")
                        .font(.caption2.bold())
                        .foregroundColor(.green)
                    Text("Fraction down the rendered image where the head sits. 0.0 = top, 0.5 = center. Badges use this to track each character's head.")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                    sliderRow("Short head Y", value: $layoutConfig.headAnchorYShort, range: 0...0.5, format: "%.2f")
                    sliderRow("Medium head Y", value: $layoutConfig.headAnchorYMedium, range: 0...0.5, format: "%.2f")
                    sliderRow("Tall head Y", value: $layoutConfig.headAnchorYTall, range: 0...0.5, format: "%.2f")
                    sliderRow("Short head X", value: $layoutConfig.headAnchorXShort, range: 0...1.0, format: "%.2f")
                    sliderRow("Medium head X", value: $layoutConfig.headAnchorXMedium, range: 0...1.0, format: "%.2f")
                    sliderRow("Tall head X", value: $layoutConfig.headAnchorXTall, range: 0...1.0, format: "%.2f")
                }

                Divider()
                    .background(Color.white.opacity(0.5))
                    .padding(.vertical, 6)

                // Per-Character Badge Overrides (May 23, 2026)
                VStack(alignment: .leading, spacing: 10) {
                    Text("👤 Per-Character Overrides")
                        .font(.caption2.bold())
                        .foregroundColor(.purple)
                    Text("Tune one character's HP/Atk badges independently of their bucket. Sliders show effective value (override if set, else bucket default).")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))

                    Picker("Character", selection: $selectedCharacterId) {
                        Text("Mildred").tag("mildred")
                        Text("Tomik").tag("tomik")
                        Text("Greta").tag("greta")
                        Text("Sister Halla").tag("sister_halla")
                        Text("Wendelina").tag("wendelina")
                        Text("Grimdrek").tag("grimdrek")
                        Text("Hexa Mott").tag("hexa_mott")
                        Text("Pemberton").tag("pemberton")
                        Text("Ardo").tag("ardo")
                        Text("Bram").tag("bram")
                        Text("Crispin").tag("crispin")
                        Text("Ironhilde").tag("ironhilde")
                        Text("Carmilla").tag("carmilla")
                        Text("Royal Envoy").tag("royal_envoy")
                    }
                    .pickerStyle(.menu)
                    .tint(.purple)

                    Text("HP Badge")
                        .font(.caption2.bold())
                        .foregroundColor(.red)
                    sliderRow(
                        "HP Size",
                        value: Binding<Double>(
                            get: { layoutConfig.hpBadgeSize(for: selectedCharacterId) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.hpBadgeSizeOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: 10...100, format: "%.0f pt"
                    )
                    sliderRow(
                        "HP X",
                        value: Binding<Double>(
                            get: { layoutConfig.hpBadgeOffsetX(for: selectedCharacterId) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.hpBadgeOffsetXOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -300...300, format: "%.0f pt"
                    )
                    sliderRow(
                        "HP Y",
                        value: Binding<Double>(
                            get: { layoutConfig.hpBadgeOffsetY(for: selectedCharacterId) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.hpBadgeOffsetYOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -150...150, format: "%.0f pt"
                    )

                    Text("Attack Badge")
                        .font(.caption2.bold())
                        .foregroundColor(.orange)
                    sliderRow(
                        "Atk Size",
                        value: Binding<Double>(
                            get: { layoutConfig.attackBadgeSize(for: selectedCharacterId) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.attackBadgeSizeOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: 10...100, format: "%.0f pt"
                    )
                    sliderRow(
                        "Atk X",
                        value: Binding<Double>(
                            get: { layoutConfig.attackBadgeOffsetX(for: selectedCharacterId) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.attackBadgeOffsetXOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -300...300, format: "%.0f pt"
                    )
                    sliderRow(
                        "Atk Y",
                        value: Binding<Double>(
                            get: { layoutConfig.attackBadgeOffsetY(for: selectedCharacterId) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.attackBadgeOffsetYOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -150...150, format: "%.0f pt"
                    )

                    // ─── WAITING 1 badge overrides (per character, queue[1] only)
                    Text("⏳ Waiting 1 HP Badge")
                        .font(.caption2.bold())
                        .foregroundColor(.red.opacity(0.8))
                    sliderRow(
                        "HP Size (Waiting 1)",
                        value: Binding<Double>(
                            get: { layoutConfig.hpBadgeSize(for: selectedCharacterId, queueSlot: 1) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waitingHpBadgeSizeOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: 10...100, format: "%.0f pt"
                    )
                    sliderRow(
                        "HP X (Waiting 1)",
                        value: Binding<Double>(
                            get: { layoutConfig.hpBadgeOffsetX(for: selectedCharacterId, queueSlot: 1) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waitingHpBadgeOffsetXOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -300...300, format: "%.0f pt"
                    )
                    sliderRow(
                        "HP Y (Waiting 1)",
                        value: Binding<Double>(
                            get: { layoutConfig.hpBadgeOffsetY(for: selectedCharacterId, queueSlot: 1) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waitingHpBadgeOffsetYOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -150...150, format: "%.0f pt"
                    )

                    Text("⏳ Waiting 1 Attack Badge")
                        .font(.caption2.bold())
                        .foregroundColor(.orange.opacity(0.8))
                    sliderRow(
                        "Atk Size (Waiting 1)",
                        value: Binding<Double>(
                            get: { layoutConfig.attackBadgeSize(for: selectedCharacterId, queueSlot: 1) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waitingAttackBadgeSizeOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: 10...100, format: "%.0f pt"
                    )
                    sliderRow(
                        "Atk X (Waiting 1)",
                        value: Binding<Double>(
                            get: { layoutConfig.attackBadgeOffsetX(for: selectedCharacterId, queueSlot: 1) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waitingAttackBadgeOffsetXOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -300...300, format: "%.0f pt"
                    )
                    sliderRow(
                        "Atk Y (Waiting 1)",
                        value: Binding<Double>(
                            get: { layoutConfig.attackBadgeOffsetY(for: selectedCharacterId, queueSlot: 1) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waitingAttackBadgeOffsetYOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -150...150, format: "%.0f pt"
                    )

                    // ─── WAITING 2 badge overrides (per character, queue[2] only).
                    // Fall back to Waiting 1 if not set, so leaving these alone preserves old behavior.
                    Text("⏳ Waiting 2 HP Badge")
                        .font(.caption2.bold())
                        .foregroundColor(.red.opacity(0.6))
                    sliderRow(
                        "HP Size (Waiting 2)",
                        value: Binding<Double>(
                            get: { layoutConfig.hpBadgeSize(for: selectedCharacterId, queueSlot: 2) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waiting2HpBadgeSizeOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: 10...100, format: "%.0f pt"
                    )
                    sliderRow(
                        "HP X (Waiting 2)",
                        value: Binding<Double>(
                            get: { layoutConfig.hpBadgeOffsetX(for: selectedCharacterId, queueSlot: 2) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waiting2HpBadgeOffsetXOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -300...300, format: "%.0f pt"
                    )
                    sliderRow(
                        "HP Y (Waiting 2)",
                        value: Binding<Double>(
                            get: { layoutConfig.hpBadgeOffsetY(for: selectedCharacterId, queueSlot: 2) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waiting2HpBadgeOffsetYOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -150...150, format: "%.0f pt"
                    )

                    Text("⏳ Waiting 2 Attack Badge")
                        .font(.caption2.bold())
                        .foregroundColor(.orange.opacity(0.6))
                    sliderRow(
                        "Atk Size (Waiting 2)",
                        value: Binding<Double>(
                            get: { layoutConfig.attackBadgeSize(for: selectedCharacterId, queueSlot: 2) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waiting2AttackBadgeSizeOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: 10...100, format: "%.0f pt"
                    )
                    sliderRow(
                        "Atk X (Waiting 2)",
                        value: Binding<Double>(
                            get: { layoutConfig.attackBadgeOffsetX(for: selectedCharacterId, queueSlot: 2) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waiting2AttackBadgeOffsetXOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -300...300, format: "%.0f pt"
                    )
                    sliderRow(
                        "Atk Y (Waiting 2)",
                        value: Binding<Double>(
                            get: { layoutConfig.attackBadgeOffsetY(for: selectedCharacterId, queueSlot: 2) },
                            set: { newValue in
                                var cs = layoutConfig.characterScale(for: selectedCharacterId)
                                cs.waiting2AttackBadgeOffsetYOverride = newValue
                                layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                            }
                        ),
                        range: -150...150, format: "%.0f pt"
                    )

                    Button("Reset \(selectedCharacterId.capitalized) badge overrides") {
                        var cs = layoutConfig.characterScale(for: selectedCharacterId)
                        cs.hpBadgeSizeOverride = nil
                        cs.hpBadgeOffsetXOverride = nil
                        cs.hpBadgeOffsetYOverride = nil
                        cs.attackBadgeSizeOverride = nil
                        cs.attackBadgeOffsetXOverride = nil
                        cs.attackBadgeOffsetYOverride = nil
                        cs.waitingHpBadgeSizeOverride = nil
                        cs.waitingHpBadgeOffsetXOverride = nil
                        cs.waitingHpBadgeOffsetYOverride = nil
                        cs.waitingAttackBadgeSizeOverride = nil
                        cs.waitingAttackBadgeOffsetXOverride = nil
                        cs.waitingAttackBadgeOffsetYOverride = nil
                        cs.waiting2HpBadgeSizeOverride = nil
                        cs.waiting2HpBadgeOffsetXOverride = nil
                        cs.waiting2HpBadgeOffsetYOverride = nil
                        cs.waiting2AttackBadgeSizeOverride = nil
                        cs.waiting2AttackBadgeOffsetXOverride = nil
                        cs.waiting2AttackBadgeOffsetYOverride = nil
                        layoutConfig.updateCharacterScale(for: selectedCharacterId, scale: cs)
                    }
                    .font(.caption2)
                    .foregroundColor(.yellow)
                }

                Divider()
                    .background(Color.white.opacity(0.5))
                    .padding(.vertical, 6)

                // Instructions
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 Pro Tips:")
                        .font(.caption2.bold())
                        .foregroundColor(.yellow)
                    Text("• Draw graphics at 256×256 or 512×512 px @ 300 DPI")
                    Text("• Export as PNG with transparent background")
                    Text("• Leave center area clear for numbers")
                    Text("• Use dark colors so white numbers show clearly")
                    Text("• Tap a customer profile to open inspect banner")
                    Text("• Skip to Round 3 to see all badges in action")
                }
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.7))
            }
        case .permutations:
            // 🎭 QUEUE PERMUTATIONS - Custom 3-character spacing
            VStack(alignment: .leading, spacing: 12) {
                Text("🎭 Queue Permutations (3-Character Spacing)")
                    .font(.caption2.bold())
                    .foregroundColor(.cyan)
                
                // Get current queue arrangement
                let currentKeys = gs.queue.compactMap { id in
                    gs.customers.first(where: { $0.id == id })?.charKey
                }
                
                if currentKeys.count == 3 {
                    // Show current arrangement
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Current Arrangement:")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(currentKeys.joined(separator: " → "))
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical, 4)
                    
                    // Get or create permutation for current arrangement
                    let permutation = layoutConfig.queuePositions(for: currentKeys)
                    
                    // X Positions Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Horizontal Spacing (X Positions)")
                            .font(.caption2.bold())
                            .foregroundColor(.green)
                        
                        Text("Fractions of scene width (0.0 = left, 1.0 = right)")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.6))
                            .italic()
                        
                        ForEach(0..<3, id: \.self) { index in
                            HStack(spacing: 8) {
                                Text("queue[\(index)]")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 60, alignment: .leading)
                                
                                Slider(
                                    value: Binding<Double>(
                                        get: { permutation.xPositions[index] },
                                        set: { newValue in
                                            var updatedPermutation = layoutConfig.queuePositions(for: currentKeys)
                                            updatedPermutation.xPositions[index] = newValue
                                            layoutConfig.queuePermutations[currentKeys.joined(separator: "_")] = updatedPermutation
                                        }
                                    ),
                                    in: 0.0...1.0
                                )
                                .tint(.green)
                                
                                Text(String(format: "%.2f", permutation.xPositions[index]))
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.green)
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical, 4)
                    
                    // Y Positions Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Vertical Positioning (Y Positions)")
                            .font(.caption2.bold())
                            .foregroundColor(.blue)
                        
                        Text("Fractions of scene height (0.0 = top, 1.0 = bottom)")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.6))
                            .italic()
                        
                        ForEach(0..<3, id: \.self) { index in
                            HStack(spacing: 8) {
                                Text("queue[\(index)]")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 60, alignment: .leading)
                                
                                Slider(
                                    value: Binding<Double>(
                                        get: { permutation.yPositions[index] },
                                        set: { newValue in
                                            var updatedPermutation = layoutConfig.queuePositions(for: currentKeys)
                                            updatedPermutation.yPositions[index] = newValue
                                            layoutConfig.queuePermutations[currentKeys.joined(separator: "_")] = updatedPermutation
                                        }
                                    ),
                                    in: 0.0...1.0
                                )
                                .tint(.blue)
                                
                                Text(String(format: "%.2f", permutation.yPositions[index]))
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.blue)
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical, 4)
                    
                    // Scale Overrides Section (Optional)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Scale Overrides (Optional)")
                                .font(.caption2.bold())
                                .foregroundColor(.purple)
                            
                            Spacer()
                            
                            Toggle("Enable", isOn: Binding<Bool>(
                                get: { permutation.scaleOverrides != nil },
                                set: { enabled in
                                    var updatedPermutation = layoutConfig.queuePositions(for: currentKeys)
                                    if enabled {
                                        updatedPermutation.scaleOverrides = [1.0, 1.0, 1.0]
                                    } else {
                                        updatedPermutation.scaleOverrides = nil
                                    }
                                    layoutConfig.queuePermutations[currentKeys.joined(separator: "_")] = updatedPermutation
                                }
                            ))
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                            .labelsHidden()
                        }
                        
                        if permutation.scaleOverrides != nil {
                            Text("Override default [1.0, 1.0, 1.0] scales")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.6))
                                .italic()
                            
                            ForEach(0..<3, id: \.self) { index in
                                HStack(spacing: 8) {
                                    Text("queue[\(index)]")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.8))
                                        .frame(width: 60, alignment: .leading)
                                    
                                    Slider(
                                        value: Binding<Double>(
                                            get: { permutation.scaleOverrides?[index] ?? 1.0 },
                                            set: { newValue in
                                                var updatedPermutation = layoutConfig.queuePositions(for: currentKeys)
                                                var scales = updatedPermutation.scaleOverrides ?? [1.0, 1.0, 1.0]
                                                scales[index] = newValue
                                                updatedPermutation.scaleOverrides = scales
                                                layoutConfig.queuePermutations[currentKeys.joined(separator: "_")] = updatedPermutation
                                            }
                                        ),
                                        in: 0.5...2.0
                                    )
                                    .tint(.purple)
                                    
                                    Text(String(format: "%.2f×", permutation.scaleOverrides?[index] ?? 1.0))
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundColor(.purple)
                                        .frame(width: 50, alignment: .trailing)
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical, 4)
                    
                    // Quick Presets
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Quick Presets")
                            .font(.caption2.bold())
                            .foregroundColor(.yellow)
                        
                        HStack(spacing: 8) {
                            Button {
                                layoutConfig.addPermutation(
                                    for: currentKeys,
                                    xPositions: [0.40, 0.65, 0.90]
                                )
                            } label: {
                                Text("Wider")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.6))
                                    .cornerRadius(4)
                            }
                            
                            Button {
                                layoutConfig.addPermutation(
                                    for: currentKeys,
                                    xPositions: [0.50, 0.70, 0.85]
                                )
                            } label: {
                                Text("Tighter")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.6))
                                    .cornerRadius(4)
                            }
                            
                            Button {
                                layoutConfig.removePermutation(for: currentKeys)
                            } label: {
                                Text("Reset")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.6))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    // Current Values Summary
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Values:")
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("X: [\(permutation.xPositions.map { String(format: "%.2f", $0) }.joined(separator: ", "))]")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.green)
                        
                        Text("Y: [\(permutation.yPositions.map { String(format: "%.2f", $0) }.joined(separator: ", "))]")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.blue)
                        
                        if let scales = permutation.scaleOverrides {
                            Text("Scales: [\(scales.map { String(format: "%.2f", $0) }.joined(separator: ", "))]")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.top, 8)
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
                    
                } else {
                    // Not a 3-character round
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⚠️ Not Available")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                        
                        Text("Queue permutations only work for 3-character rounds (Evening, or future multi-customer rounds).")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if currentKeys.count < 3 {
                            Text("Current queue has \(currentKeys.count) character\(currentKeys.count == 1 ? "" : "s").")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .italic()
                        }
                        
                        Text("💡 Tip: Skip to Round 3 (Evening) to test this feature.")
                            .font(.caption2)
                            .foregroundColor(.cyan)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
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
