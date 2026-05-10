//
//  PotionShopDebugMenu.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Debug menu (gear icon → sheet)
//  Place in: PotionShop/ folder
//
//  Phase 5d: Always-available debug menu accessible via the gear icon
//  in the header. Provides shortcuts for development:
//    - End Game            (return to game selector)
//    - Skip to Round 1/2/3/4  (jump to a specific round-of-day)
//    - Reset Round         (re-spawn current round's customers)
//    - Heal to Full        (composure → max, clear shield)
//    - Win Round           (defeat all current customers instantly)
//    - Lose Game           (drop composure to 0)
//
//  NAMING NOTE: PotionShop prefix on every public type, same as
//  the rest of the game.
//

import SwiftUI

struct PotionShopDebugMenu: View {
    @Bindable var gs: PotionShopGameState
    @Binding var isPresented: Bool
    @Binding var showLayoutOverlay: Bool
    /// Closure that exits the game (back to GameSelector). Provided
    /// by the parent view since dismiss happens at the parent level.
    let onEndGame: () -> Void
    
    @State private var showLayoutEditor = false

    var body: some View {
        NavigationStack {
            List {
                // ─── State summary ─────────────────────────────────
                Section("Current State") {
                    debugRow("Day", gs.dayId)
                    debugRow("Round", "\(gs.roundIndex + 1) of \(PotionShopConfig.roundsPerDay) (\(gs.currentRoundLabel))")
                    debugRow("Phase", phaseLabel(gs.phase))
                    debugRow("Composure", "\(gs.composure) / \(PotionShopConfig.maxComposure)")
                    debugRow("Shield", "\(gs.shield)")
                    debugRow("Potions Brewed", "\(gs.potionsBrewed)")
                    debugRow("Customers", "\(gs.queue.count) in queue / \(gs.customers.count) total")
                }
                
                // ─── Layout Editor ────────────────────────────────
                Section("Layout Tools") {
                    Button {
                        isPresented = false  // Close debug menu
                        showLayoutOverlay = true  // Show overlay
                    } label: {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.cyan)
                            Text("Layout Editor (Live Overlay)")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        copyLayoutValuesToClipboard()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.cyan)
                            Text("📋 Copy Layout Values")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(.green)
                                .opacity(0.7)
                        }
                    }
                }

                // ─── Round shortcuts ──────────────────────────────
                Section("Skip to Round") {
                    ForEach(0..<PotionShopConfig.roundsPerDay, id: \.self) { idx in
                        Button {
                            gs.roundIndex = idx
                            gs.startRound()
                            isPresented = false
                        } label: {
                            HStack {
                                Image(systemName: "forward.fill")
                                    .foregroundColor(PotionShopTheme.accent)
                                Text("Round \(idx + 1) – \(roundLabel(at: idx))")
                                    .foregroundColor(.primary)
                                Spacer()
                                if gs.roundIndex == idx {
                                    Text("current")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                // ─── Combat shortcuts ─────────────────────────────
                Section("Combat") {
                    Button {
                        gs.composure = PotionShopConfig.maxComposure
                        gs.shield = 0
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(PotionShopTheme.composureGood)
                            Text("Heal to Full")
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        gs.debugWinRound()
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(PotionShopTheme.composureGood)
                            Text("Win Round (defeat all customers)")
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        gs.debugLoseGame()
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(PotionShopTheme.composureBad)
                            Text("Lose Game (composure → 0)")
                                .foregroundColor(.primary)
                        }
                    }
                }

                // ─── Round/game reset ─────────────────────────────
                Section("Reset") {
                    Button {
                        gs.startRound()
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(PotionShopTheme.accent)
                            Text("Reset Round (re-spawn customers)")
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        gs.resetGame()
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                                .foregroundColor(PotionShopTheme.accent)
                            Text("Reset Game (back to Day 1 Morning)")
                                .foregroundColor(.primary)
                        }
                    }
                }

                // ─── Exit ─────────────────────────────────────────
                Section {
                    Button {
                        isPresented = false
                        onEndGame()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                .foregroundColor(PotionShopTheme.composureBad)
                            Text("End Game (back to selector)")
                                .foregroundColor(PotionShopTheme.composureBad)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
            .sheet(isPresented: $showLayoutEditor) {
                PotionShopNewLayoutEditor(isPresented: $showLayoutEditor)
            }
        }
    }

    // MARK: - Helpers

    private func debugRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
        }
    }

    private func roundLabel(at idx: Int) -> String {
        switch idx {
        case 0: return "Morning"
        case 1: return "Afternoon"
        case 2: return "Evening"
        case 3: return "Night"
        default: return "?"
        }
    }

    private func phaseLabel(_ p: PotionShopPhase) -> String {
        switch p {
        case .playing:  return "playing"
        case .roundWon: return "roundWon"
        case .dayWon:   return "dayWon"
        case .lost:     return "lost"
        }
    }
    
    /// Copies all current layout values from PotionShopLayoutConfig.shared to clipboard
    /// in a format that's easy to paste back to Claude for permanent code updates.
    private func copyLayoutValuesToClipboard() {
        let cfg = PotionShopLayoutConfig.shared
        
        var text = """
        ═══════════════════════════════════════════════════════════════
        EDNAR'S POTION CAULDRON - LAYOUT VALUES
        ═══════════════════════════════════════════════════════════════
        Generated: \(Date().formatted(.dateTime))
        
        Copy the values below and paste them back to Claude to update the code permanently.
        
        ───────────────────────────────────────────────────────────────
        📏 SECTION HEIGHTS (percentages of total screen height)
        ───────────────────────────────────────────────────────────────
        headerPercent: \(cfg.headerPercent)
        scenePercent: \(cfg.scenePercent)
        profilePercent: \(cfg.profilePercent)
        cauldronPercent: \(cfg.cauldronPercent)
        previewPercent: \(cfg.previewPercent)
        trayPercent: \(cfg.trayPercent)
        
        Total: \(cfg.headerPercent + cfg.scenePercent + cfg.profilePercent + cfg.cauldronPercent + cfg.previewPercent + cfg.trayPercent)%
        
        ───────────────────────────────────────────────────────────────
        🧙 EDNAR ART (freeform scaling + positioning)
        ───────────────────────────────────────────────────────────────
        ednarWidth: \(cfg.ednarWidth)
        ednarHeight: \(cfg.ednarHeight)
        ednarX: \(cfg.ednarX)
        ednarY: \(cfg.ednarY)
        
        ───────────────────────────────────────────────────────────────
        🧍 CUSTOMER SCENE PORTRAITS (per-character scaling)
        ───────────────────────────────────────────────────────────────
        mildred_width: \(cfg.characterScale(for: "mildred").width)
        mildred_height: \(cfg.characterScale(for: "mildred").height)
        mildred_x: \(cfg.characterScale(for: "mildred").x)
        mildred_y: \(cfg.characterScale(for: "mildred").y)
        
        tomik_width: \(cfg.characterScale(for: "tomik").width)
        tomik_height: \(cfg.characterScale(for: "tomik").height)
        tomik_x: \(cfg.characterScale(for: "tomik").x)
        tomik_y: \(cfg.characterScale(for: "tomik").y)
        
        greta_width: \(cfg.characterScale(for: "greta").width)
        greta_height: \(cfg.characterScale(for: "greta").height)
        greta_x: \(cfg.characterScale(for: "greta").x)
        greta_y: \(cfg.characterScale(for: "greta").y)
        
        sister_halla_width: \(cfg.characterScale(for: "sister_halla").width)
        sister_halla_height: \(cfg.characterScale(for: "sister_halla").height)
        sister_halla_x: \(cfg.characterScale(for: "sister_halla").x)
        sister_halla_y: \(cfg.characterScale(for: "sister_halla").y)
        
        wendelina_width: \(cfg.characterScale(for: "wendelina").width)
        wendelina_height: \(cfg.characterScale(for: "wendelina").height)
        wendelina_x: \(cfg.characterScale(for: "wendelina").x)
        wendelina_y: \(cfg.characterScale(for: "wendelina").y)
        
        grimdrek_width: \(cfg.characterScale(for: "grimdrek").width)
        grimdrek_height: \(cfg.characterScale(for: "grimdrek").height)
        grimdrek_x: \(cfg.characterScale(for: "grimdrek").x)
        grimdrek_y: \(cfg.characterScale(for: "grimdrek").y)
        
        hexa_mott_width: \(cfg.characterScale(for: "hexa_mott").width)
        hexa_mott_height: \(cfg.characterScale(for: "hexa_mott").height)
        hexa_mott_x: \(cfg.characterScale(for: "hexa_mott").x)
        hexa_mott_y: \(cfg.characterScale(for: "hexa_mott").y)
        
        ───────────────────────────────────────────────────────────────
        🍲 CAULDRON ART (freeform scaling + positioning)
        ───────────────────────────────────────────────────────────────
        cauldronWidth: \(cfg.cauldronWidth)
        cauldronHeight: \(cfg.cauldronHeight)
        cauldronX: \(cfg.cauldronX)
        cauldronY: \(cfg.cauldronY)
        
        ───────────────────────────────────────────────────────────────
        🥘 CAULDRON BOWL (parametric shape positioning)
        ───────────────────────────────────────────────────────────────
        cauldronBowlScale: \(cfg.cauldronBowlScale)
        cauldronBowlX: \(cfg.cauldronBowlX)
        cauldronBowlY: \(cfg.cauldronBowlY)
        
        ───────────────────────────────────────────────────────────────
        🔵 NODES (grid positioning)
        ───────────────────────────────────────────────────────────────
        nodeScale: \(cfg.nodeScale)
        nodeXOffset: \(cfg.nodeXOffset)
        nodeYOffset: \(cfg.nodeYOffset)
        nodeSpacingMultiplier: \(cfg.nodeSpacingMultiplier)
        
        ───────────────────────────────────────────────────────────────
        🔧 PER-NODE FINE-TUNING (individual offsets for all 12 nodes)
        ───────────────────────────────────────────────────────────────
        """
        
        // Add per-node offsets
        for (idx, offset) in cfg.perNodeOffsets.enumerated() {
            text += "\nNode \(idx): x=\(offset.x), y=\(offset.y)"
        }
        
        text += """
        
        
        ───────────────────────────────────────────────────────────────
        🎲 DICE & TRAY
        ───────────────────────────────────────────────────────────────
        dieScale: \(cfg.dieScale)
        trayOffsetX: \(cfg.trayOffsetX)
        trayOffsetY: \(cfg.trayOffsetY)
        
        ───────────────────────────────────────────────────────────────
        🥄 BREW TAP ZONE (invisible tap area)
        ───────────────────────────────────────────────────────────────
        brewZoneX: \(cfg.brewZoneX)
        brewZoneY: \(cfg.brewZoneY)
        brewZoneWidth: \(cfg.brewZoneWidth)
        brewZoneHeight: \(cfg.brewZoneHeight)
        showBrewZone: \(cfg.showBrewZone)
        
        ═══════════════════════════════════════════════════════════════
        END OF LAYOUT VALUES
        ═══════════════════════════════════════════════════════════════
        
        ✅ COPIED TO CLIPBOARD
        
        Next Steps:
        1. Paste these values back to Claude in chat
        2. Claude will update PotionShopLayoutConfig.swift with these as the new defaults
        3. Close the app and reopen to see permanent changes
        
        """
        
        // Copy to clipboard
        #if os(iOS)
        UIPasteboard.general.string = text
        #endif
        
        print("📋 Layout values copied to clipboard!")
    }
}

// MARK: - New Layout Editor

struct PotionShopNewLayoutEditor: View {
    @Binding var isPresented: Bool
    
    // ─── Section Heights (percentages) ─────────────────────
    @State private var headerPercent: Double = 1.0
    @State private var scenePercent: Double = 26.3
    @State private var profilePercent: Double = 9.5
    @State private var cauldronPercent: Double = 37.2
    @State private var previewPercent: Double = 3.2
    @State private var trayPercent: Double = 19.3
    
    // ─── Ednar Art ─────────────────────────────────────────
    @State private var ednarUniformScale: Double = 1.0
    @State private var ednarWidth: Double = 1.59
    @State private var ednarHeight: Double = 2.00
    @State private var ednarX: Double = 14
    @State private var ednarY: Double = -17
    
    // ─── Cauldron Art ──────────────────────────────────────
    @State private var cauldronUniformScale: Double = 1.0
    @State private var cauldronWidth: Double = 1.45
    @State private var cauldronHeight: Double = 2.00
    @State private var cauldronX: Double = 7
    @State private var cauldronY: Double = -40
    
    // ─── Cauldron Bowl Position ────────────────────────────
    @State private var cauldronBowlScale: Double = 1.29
    @State private var cauldronBowlX: Double = 44
    @State private var cauldronBowlY: Double = 58
    
    // ─── Dice Tray ─────────────────────────────────────────
    @State private var dieScale: Double = 1.31
    @State private var trayOffsetX: Double = 0
    @State private var trayOffsetY: Double = -25
    
    // ─── Brew Tap Zone ─────────────────────────────────────
    @State private var brewZoneX: Double = 0.83
    @State private var brewZoneY: Double = 0.19
    @State private var brewZoneWidth: Double = 112
    @State private var brewZoneHeight: Double = 123
    @State private var showBrewZone: Bool = false
    
    // ─── UI State ──────────────────────────────────────────
    @State private var activeSection: LayoutSection? = nil
    @State private var showGeneratedCode = false
    @State private var generatedCode = ""
    
    enum LayoutSection: String, CaseIterable {
        case sections = "📏 Section Heights"
        case ednar = "🧙 Ednar Art"
        case cauldronArt = "🍲 Cauldron Art"
        case cauldronBowl = "🥘 Cauldron Bowl"
        case dice = "🎲 Dice & Tray"
        case brewZone = "🥄 Brew Tap Zone"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Section picker (horizontal scroll)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(LayoutSection.allCases, id: \.self) { section in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    activeSection = activeSection == section ? nil : section
                                }
                            } label: {
                                Text(section.rawValue)
                                    .font(.caption.bold())
                                    .foregroundColor(activeSection == section ? .white : .cyan)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(activeSection == section ? Color.cyan : Color.cyan.opacity(0.2))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.black.opacity(0.3))
                
                // Active section controls
                ScrollView {
                    if let section = activeSection {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionContent(for: section)
                        }
                        .padding()
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 40))
                                .foregroundColor(.cyan.opacity(0.5))
                            Text("Select a section above to edit")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 60)
                    }
                }
            }
            .navigationTitle("Layout Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Generate Code") {
                        generateCode()
                    }
                }
            }
            .sheet(isPresented: $showGeneratedCode) {
                PotionShopCodeGeneratorSheet(code: generatedCode)
            }
        }
    }
    
    // MARK: - Section Content Builder
    
    @ViewBuilder
    private func sectionContent(for section: LayoutSection) -> some View {
        switch section {
        case .sections:
            sectionHeightsControls()
        case .ednar:
            ednarArtControls()
        case .cauldronArt:
            cauldronArtControls()
        case .cauldronBowl:
            cauldronBowlControls()
        case .dice:
            diceControls()
        case .brewZone:
            brewZoneControls()
        }
    }
    
    // MARK: - Individual Section Control Views
    
    private func sectionHeightsControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Header", value: $headerPercent, range: 0...20, format: "%.1f%%")
            sliderRow("Scene", value: $scenePercent, range: 0...50, format: "%.1f%%")
            sliderRow("Profile Row", value: $profilePercent, range: 0...20, format: "%.1f%%")
            sliderRow("Cauldron", value: $cauldronPercent, range: 0...60, format: "%.1f%%")
            sliderRow("Preview Bar", value: $previewPercent, range: 0...10, format: "%.1f%%")
            sliderRow("Dice Tray", value: $trayPercent, range: 0...30, format: "%.1f%%")
            
            Text("Total: \(totalPercent, specifier: "%.1f")%")
                .font(.caption.bold())
                .foregroundColor(totalPercent > 100 ? .red : .green)
                .padding(.top, 4)
        }
    }
    
    private func ednarArtControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Uniform Scale", value: $ednarUniformScale, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Width Scale", value: $ednarWidth, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Height Scale", value: $ednarHeight, range: 0.5...3.0, format: "%.2f×")
            sliderRow("X Position", value: $ednarX, range: -200...200, format: "%.0f pt")
            sliderRow("Y Position", value: $ednarY, range: -200...200, format: "%.0f pt")
            
            HStack {
                Button("Reset Position") {
                    ednarX = 0
                    ednarY = 0
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                Button("Reset Scale") {
                    ednarUniformScale = 1.0
                    ednarWidth = 1.0
                    ednarHeight = 1.0
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
        }
    }
    
    private func cauldronArtControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Uniform Scale", value: $cauldronUniformScale, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Width Scale", value: $cauldronWidth, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Height Scale", value: $cauldronHeight, range: 0.5...3.0, format: "%.2f×")
            sliderRow("X Position", value: $cauldronX, range: -200...200, format: "%.0f pt")
            sliderRow("Y Position", value: $cauldronY, range: -200...200, format: "%.0f pt")
            
            HStack {
                Button("Reset Position") {
                    cauldronX = 0
                    cauldronY = 0
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                Button("Reset Scale") {
                    cauldronUniformScale = 1.0
                    cauldronWidth = 1.0
                    cauldronHeight = 1.0
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
        }
    }
    
    private func cauldronBowlControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Scale", value: $cauldronBowlScale, range: 0.5...3.0, format: "%.2f×")
            sliderRow("X Offset", value: $cauldronBowlX, range: -200...200, format: "%.0f pt")
            sliderRow("Y Offset", value: $cauldronBowlY, range: -200...200, format: "%.0f pt")
            
            Button("Reset") {
                cauldronBowlScale = 1.0
                cauldronBowlX = 0
                cauldronBowlY = 0
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }
    
    private func diceControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Die Scale", value: $dieScale, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Tray X Offset", value: $trayOffsetX, range: -200...200, format: "%.0f pt")
            sliderRow("Tray Y Offset", value: $trayOffsetY, range: -200...200, format: "%.0f pt")
            
            Button("Reset") {
                dieScale = 1.0
                trayOffsetX = 0
                trayOffsetY = 0
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }
    
    private func brewZoneControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("X Position", value: $brewZoneX, range: 0...1, format: "%.2f")
            sliderRow("Y Position", value: $brewZoneY, range: 0...1, format: "%.2f")
            sliderRow("Width", value: $brewZoneWidth, range: 50...300, format: "%.0f pt")
            sliderRow("Height", value: $brewZoneHeight, range: 50...300, format: "%.0f pt")
            
            Toggle("Show Debug Zone", isOn: $showBrewZone)
            
            Button("Reset") {
                brewZoneX = 0.5
                brewZoneY = 0.5
                brewZoneWidth = 100
                brewZoneHeight = 100
                showBrewZone = false
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }
    
    // MARK: - Code Generation
    
    private func generateCode() {
        var code = """
        // ═══════════════════════════════════════════════════════════
        // GENERATED LAYOUT CODE - Paste into PotionShopGameView.swift
        // ═══════════════════════════════════════════════════════════
        
        // ─── Section Heights (in GeometryReader) ───────────────────
        let headerH      = max(70,  totalHeight * \(headerPercent / 100))
        let sceneH       = max(160, totalHeight * \(scenePercent / 100))
        let profileRowH  = max(74,  totalHeight * \(profilePercent / 100))
        let cauldronH    = max(240, totalHeight * \(cauldronPercent / 100))
        let previewBarH  = max(26,  totalHeight * \(previewPercent / 100))
        let trayH        = max(82,  totalHeight * \(trayPercent / 100))
        
        // ─── Ednar Art (in PotionShopCustomerSceneView call) ──────
        ednarArtScale: \(ednarUniformScale),
        ednarArtWidth: \(ednarWidth),
        ednarArtHeight: \(ednarHeight),
        ednarArtXOffset: \(ednarX),
        ednarArtYOffset: \(ednarY)
        
        // ─── Cauldron Art (in PotionShopCauldronView call) ────────
        cauldronArtScale: \(cauldronUniformScale),
        cauldronArtWidth: \(cauldronWidth),
        cauldronArtHeight: \(cauldronHeight),
        cauldronArtXOffset: \(cauldronX),
        cauldronArtYOffset: \(cauldronY)
        
        // ─── Cauldron Bowl (in PotionShopCauldronView call) ───────
        cauldronScale: \(cauldronBowlScale),
        cauldronXOffset: \(cauldronBowlX),
        cauldronYOffset: \(cauldronBowlY)
        
        // ─── Dice & Tray ───────────────────────────────────────────
        // PotionShopDiceTrayView dieScale:
        dieScale: \(dieScale)
        
        // Tray .offset() modifier:
        .offset(x: \(trayOffsetX), y: \(trayOffsetY))
        
        // ─── Brew Tap Zone (in PotionShopCauldronView call) ───────
        brewZoneX: \(brewZoneX),
        brewZoneY: \(brewZoneY),
        brewZoneWidth: \(brewZoneWidth),
        brewZoneHeight: \(brewZoneHeight),
        showBrewZone: \(showBrewZone)
        
        // ═══════════════════════════════════════════════════════════
        """
        
        generatedCode = code
        
        // Copy to clipboard
        #if os(iOS)
        UIPasteboard.general.string = code
        #endif
        
        showGeneratedCode = true
    }
    
    // MARK: - Helpers
    
    private var totalPercent: Double {
        headerPercent + scenePercent + profilePercent + cauldronPercent + previewPercent + trayPercent
    }
    
    private func sliderRow(_ label: String, value: Binding<Double>, range: ClosedRange<Double>, format: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
            }
            Slider(value: value, in: range)
                .tint(.cyan)
        }
    }
}

// MARK: - Code Generator Sheet
struct PotionShopCodeGeneratorSheet: View {
    let code: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .textSelection(.enabled)
            }
            .navigationTitle("Generated Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        #if os(iOS)
                        UIPasteboard.general.string = code
                        #endif
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }
}

