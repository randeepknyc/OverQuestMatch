//
//  PotionShopLayoutEditorView.swift
//  OverQuestMatch3
//
//  Interactive visual layout editor for Ednar's Potion Cauldron
//  Access from debug menu → "Layout Editor" button
//

import SwiftUI

struct PotionShopLayoutEditorView: View {
    @Bindable var gs: PotionShopGameState
    @Binding var isPresented: Bool
    @Namespace private var diceFlight
    
    // Section height percentages (MATCH PotionShopGameView.swift)
    @State private var headerPercent: Double = 0.010      // 1%   - Minimal header
    @State private var scenePercent: Double = 0.263       // 26.3% - Scene (big!)
    @State private var profilePercent: Double = 0.095     // 9.5%  - Profile row
    @State private var cauldronPercent: Double = 0.372    // 37.2% - HUGE CAULDRON!
    @State private var previewPercent: Double = 0.032     // 3.2%  - Preview bar (tiny)
    @State private var trayPercent: Double = 0.193        // 19.3% - BIG TRAY!
    
    // Cauldron controls (MATCH PotionShopGameView.swift)
    @State private var cauldronScale: Double = 1.29
    @State private var cauldronXOffset: Double = 44
    @State private var cauldronYOffset: Double = 58
    @State private var nodeScale: Double = 1.0
    @State private var nodeXOffset: Double = 0
    @State private var nodeYOffset: Double = 0
    
    // BREW button controls (MATCH PotionShopGameView.swift)
    @State private var showBrewButton: Bool = false
    @State private var brewXOffset: Double = -50
    @State private var brewYPercent: Double = 0.30
    @State private var brewZoneX: Double = 0.83          // ✅ LOCKED VALUE
    @State private var brewZoneY: Double = 0.19
    @State private var brewZoneWidth: Double = 112       // ✅ LOCKED VALUE
    @State private var brewZoneHeight: Double = 123
    @State private var showBrewZone: Bool = false        // ✅ LOCKED (hidden in game)
    
    // Dice tray controls (MATCH PotionShopGameView.swift)
    @State private var dieScale: Double = 1.31
    @State private var trayYOffset: Double = -25
    @State private var enableDragDrop: Bool = true
    
    // Bag/Discard toggles (MATCH PotionShopGameView.swift)
    @State private var showBag: Bool = true
    @State private var showDiscard: Bool = true
    @State private var bagDiscardScale: Double = 1.0
    
    // Art scaling controls (MATCH PotionShopGameView.swift)
    @State private var uniformArtScale: Double = 1.0
    @State private var cauldronArtScale: Double = 1.0
    @State private var cauldronArtWidth: Double = 1.45      // ✅ LOCKED VALUE
    @State private var cauldronArtHeight: Double = 2.00     // ✅ LOCKED VALUE
    @State private var cauldronArtXOffset: Double = 7       // ✅ LOCKED VALUE
    @State private var cauldronArtYOffset: Double = -40     // ✅ LOCKED VALUE
    
    @State private var ednarArtScale: Double = 1.0
    @State private var ednarArtWidth: Double = 1.59         // ✅ LOCKED VALUE
    @State private var ednarArtHeight: Double = 2.00        // ✅ LOCKED VALUE
    @State private var ednarArtXOffset: Double = 14
    @State private var ednarArtYOffset: Double = -17
    
    // UI controls
    @State private var showOverlays: Bool = true
    @State private var generatedCode: String = ""
    @State private var panelOpacity: Double = 0.3
    
    var body: some View {
        GeometryReader { geo in
            let totalH = geo.size.height
            let headerH      = max(70,  totalH * headerPercent)
            let sceneH       = max(160, totalH * scenePercent)
            let profileRowH  = max(74,  totalH * profilePercent)
            let cauldronH    = max(240, totalH * cauldronPercent)
            let previewBarH  = max(26,  totalH * previewPercent)
            let trayH        = max(82,  totalH * trayPercent)
            
            ZStack {
                // Background
                PotionShopTheme.bg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    PotionShopHeaderView(gs: gs, showDebugMenu: .constant(false))
                        .frame(height: headerH)
                        .background(showOverlays ? Color.red.opacity(0.2) : Color.clear)
                        .overlay(alignment: .topLeading) {
                            if showOverlays {
                                Text("HEADER \(Int(headerPercent * 100))%")
                                    .font(.caption2.bold())
                                    .foregroundColor(.red)
                                    .padding(4)
                            }
                        }
                    
                    PotionShopCustomerSceneView(gs: gs, ednarArtScale: ednarArtScale, ednarArtWidth: ednarArtWidth, ednarArtHeight: ednarArtHeight, ednarArtXOffset: ednarArtXOffset, ednarArtYOffset: ednarArtYOffset)
                        .frame(height: sceneH)
                        .frame(maxWidth: .infinity)
                        .background(showOverlays ? Color.blue.opacity(0.2) : Color.clear)
                        .overlay(alignment: .topLeading) {
                            if showOverlays {
                                Text("SCENE \(Int(scenePercent * 100))%")
                                    .font(.caption2.bold())
                                    .foregroundColor(.blue)
                                    .padding(4)
                            }
                        }
                    
                    PotionShopProfileRowView(gs: gs)
                        .frame(height: profileRowH)
                        .background(showOverlays ? Color(.systemGreen).opacity(0.2) : Color.clear)
                        .overlay(alignment: .topLeading) {
                            if showOverlays {
                                Text("PROFILES \(Int(profilePercent * 100))%")
                                    .font(.caption2.bold())
                                    .foregroundColor(Color(.systemGreen))
                                    .padding(4)
                            }
                        }
                    
                    PotionShopCauldronView(
                        gs: gs,
                        diceFlight: diceFlight,
                        cauldronScale: cauldronScale,
                        cauldronXOffset: cauldronXOffset,
                        cauldronYOffset: cauldronYOffset,
                        nodeScale: nodeScale,
                        nodeXOffset: nodeXOffset,
                        nodeYOffset: nodeYOffset,
                        brewXOffset: brewXOffset,
                        brewYPercent: brewYPercent,
                        showBrewButton: showBrewButton,
                        brewZoneX: brewZoneX,
                        brewZoneY: brewZoneY,
                        brewZoneWidth: brewZoneWidth,
                        brewZoneHeight: brewZoneHeight,
                        showBrewZone: showBrewZone,
                        cauldronArtScale: cauldronArtScale,
                        cauldronArtWidth: cauldronArtWidth,
                        cauldronArtHeight: cauldronArtHeight,
                        cauldronArtXOffset: cauldronArtXOffset,
                        cauldronArtYOffset: cauldronArtYOffset
                    )
                        .frame(height: cauldronH)
                        .background(showOverlays ? Color.purple.opacity(0.2) : Color.clear)
                        .overlay(alignment: .topLeading) {
                            if showOverlays {
                                Text("CAULDRON \(Int(cauldronPercent * 100))%")
                                    .font(.caption2.bold())
                                    .foregroundColor(.purple)
                                    .padding(4)
                            }
                        }
                    
                    PotionShopBrewPreviewBar(gs: gs)
                        .frame(height: previewBarH)
                        .background(showOverlays ? Color.orange.opacity(0.2) : Color.clear)
                        .overlay(alignment: .topLeading) {
                            if showOverlays {
                                Text("PREVIEW \(Int(previewPercent * 100))%")
                                    .font(.caption2.bold())
                                    .foregroundColor(.orange)
                                    .padding(4)
                            }
                        }
                    
                    ZStack {
                        PotionShopDiceTrayView(
                            gs: gs,
                            diceFlight: diceFlight,
                            dieScale: dieScale
                        )
                        .frame(height: trayH)
                        .offset(y: trayYOffset)
                        .background(showOverlays ? Color.cyan.opacity(0.2) : Color.clear)
                        .overlay(alignment: .topLeading) {
                            if showOverlays {
                                Text("TRAY \(Int(trayPercent * 100))%")
                                    .font(.caption2.bold())
                                    .foregroundColor(.cyan)
                                    .padding(4)
                            }
                        }
                        
                        // Bag/Discard visualizers
                        if showBag {
                            let bagSize = 60.0 * bagDiscardScale
                            Circle()
                                .fill(Color.brown.opacity(0.7))
                                .frame(width: bagSize, height: bagSize)
                                .overlay(
                                    Text("BAG")
                                        .font(.system(size: 12 * bagDiscardScale, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .position(x: 40, y: trayH - 40)
                        }
                        
                        if showDiscard {
                            let discSize = 60.0 * bagDiscardScale
                            Circle()
                                .fill(Color.gray.opacity(0.7))
                                .frame(width: discSize, height: discSize)
                                .overlay(
                                    Text("DISC")
                                        .font(.system(size: 12 * bagDiscardScale, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .position(x: geo.size.width - 40, y: trayH - 40)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                
                // Control panel overlay
                VStack {
                    Spacer()
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            // Header
                            HStack {
                                Text("🎨 LAYOUT EDITOR")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { showOverlays.toggle() }) {
                                    Image(systemName: showOverlays ? "eye.fill" : "eye.slash")
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: { isPresented = false }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            Divider().background(Color.white)
                            
                            // Opacity slider
                            VStack(spacing: 4) {
                                HStack {
                                    Text("👁️ Panel Opacity")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(panelOpacity * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                Slider(value: $panelOpacity, in: 0.1...1.0)
                                    .tint(.white)
                            }
                            .padding(.horizontal)
                            
                            Divider().background(Color.white)
                            
                            // Section Heights
                            sectionLabel("📐 SECTION HEIGHTS")
                            
                            sliderControl("Header", value: $headerPercent, range: 0.01...0.30)
                            sliderControl("Scene", value: $scenePercent, range: 0.05...0.50)
                            sliderControl("Profiles", value: $profilePercent, range: 0.05...0.20)
                            sliderControl("Cauldron", value: $cauldronPercent, range: 0.10...0.50)
                            sliderControl("Preview", value: $previewPercent, range: 0.01...0.10)
                            sliderControl("Tray", value: $trayPercent, range: 0.05...0.30)
                            
                            let totalPercent = headerPercent + scenePercent + profilePercent + cauldronPercent + previewPercent + trayPercent
                            Text("Total: \(Int(totalPercent * 100))%")
                                .font(.caption)
                                .foregroundColor(totalPercent > 1.0 ? .red : Color(.systemGreen))
                                .padding(.horizontal)
                            
                            Divider().background(Color.white)
                            
                            // Cauldron Controls
                            sectionLabel("🍲 CAULDRON CONTROLS")
                            
                            sliderControl("Scale", value: $cauldronScale, range: 0.5...2.0)
                            sliderControl("↔️ X Offset", value: $cauldronXOffset, range: -150...150, step: 1)
                            sliderControl("↕️ Y Offset", value: $cauldronYOffset, range: -150...150, step: 1)
                            sliderControl("🎯 Node Scale", value: $nodeScale, range: 0.5...2.0)
                            sliderControl("🎯 Node X Offset", value: $nodeXOffset, range: -100...100, step: 1)
                            sliderControl("🎯 Node Y Offset", value: $nodeYOffset, range: -100...100, step: 1)
                            
                            Divider().background(Color.white)
                            
                            // BREW Button Controls
                            sectionLabel("🥄 BREW BUTTON CONTROLS")
                            
                            HStack {
                                Toggle("Show BREW Button", isOn: $showBrewButton)
                                    .toggleStyle(.button)
                                    .tint(showBrewButton ? Color(.systemGreen) : .gray)
                            }
                            .padding(.horizontal)
                            
                            if showBrewButton {
                                sliderControl("↔️ BREW X Offset", value: $brewXOffset, range: -200...200, step: 1)
                                sliderControl("↕️ BREW Y %", value: $brewYPercent, range: 0.0...1.0, step: 0.01)
                            } else {
                                sliderControl("Tap Zone X %", value: $brewZoneX, range: 0.0...1.0, step: 0.01)
                                sliderControl("Tap Zone Y %", value: $brewZoneY, range: 0.0...1.0, step: 0.01)
                                sliderControl("Tap Zone Width", value: $brewZoneWidth, range: 50...200, step: 1)
                                sliderControl("Tap Zone Height", value: $brewZoneHeight, range: 50...200, step: 1)
                                
                                HStack {
                                    Toggle("Show Tap Zone (Debug)", isOn: $showBrewZone)
                                        .toggleStyle(.button)
                                        .tint(showBrewZone ? .yellow : .gray)
                                }
                                .padding(.horizontal)
                            }
                            
                            Divider().background(Color.white)
                            
                            // Dice Tray Controls
                            sectionLabel("🎲 DICE TRAY CONTROLS")
                            
                            sliderControl("Die Scale", value: $dieScale, range: 0.5...2.0)
                            sliderControl("↕️ Tray Y Offset", value: $trayYOffset, range: -100...100, step: 1)
                            
                            HStack {
                                Toggle("Enable Drag & Drop", isOn: $enableDragDrop)
                                    .toggleStyle(.button)
                                    .tint(enableDragDrop ? Color(.systemGreen) : .gray)
                            }
                            .padding(.horizontal)
                            
                            Divider().background(Color.white)
                            
                            // Bag/Discard Toggles
                            sectionLabel("💰 BAG & DISCARD")
                            
                            HStack {
                                Toggle("Show Bag", isOn: $showBag)
                                    .toggleStyle(.button)
                                    .tint(.brown)
                                
                                Toggle("Show Discard", isOn: $showDiscard)
                                    .toggleStyle(.button)
                                    .tint(.gray)
                            }
                            .padding(.horizontal)
                            
                            sliderControl("Bag/Disc Scale", value: $bagDiscardScale, range: 0.5...2.0)
                            
                            Divider().background(Color.white)
                            
                            // ART SCALING CONTROLS - ENHANCED!
                            sectionLabel("🎨 ART SCALING & POSITIONING")
                            
                            Text("Uniform Scale (Both)")
                                .font(.caption2)
                                .foregroundColor(.cyan)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            sliderControl("🔗 Uniform Scale", value: $uniformArtScale, range: 0.5...3.0)
                            
                            HStack(spacing: 12) {
                                Button("Reset All to 1.0") {
                                    uniformArtScale = 1.0
                                    cauldronArtScale = 1.0
                                    ednarArtScale = 1.0
                                    cauldronArtWidth = 1.0
                                    cauldronArtHeight = 1.0
                                    cauldronArtXOffset = 0
                                    cauldronArtYOffset = 0
                                    ednarArtWidth = 1.0
                                    ednarArtHeight = 1.0
                                    ednarArtXOffset = 0
                                    ednarArtYOffset = 0
                                }
                                .buttonStyle(PotionShopLayoutEditorButtonStyle(color: .gray))
                                .font(.caption)
                                
                                Button("Apply Uniform") {
                                    cauldronArtScale = uniformArtScale
                                    ednarArtScale = uniformArtScale
                                    cauldronArtWidth = uniformArtScale
                                    cauldronArtHeight = uniformArtScale
                                    ednarArtWidth = uniformArtScale
                                    ednarArtHeight = uniformArtScale
                                }
                                .buttonStyle(PotionShopLayoutEditorButtonStyle(color: .cyan))
                                .font(.caption)
                            }
                            .padding(.horizontal)
                            
                            Divider().background(Color.white.opacity(0.3))
                            
                            // CAULDRON FREEFORM CONTROLS
                            Text("🍲 Cauldron Freeform")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            sliderControl("Uniform Scale", value: $cauldronArtScale, range: 0.5...3.0)
                            sliderControl("↔️ Width Scale", value: $cauldronArtWidth, range: 0.5...3.0)
                            sliderControl("↕️ Height Scale", value: $cauldronArtHeight, range: 0.5...3.0)
                            sliderControl("↔️ X Position", value: $cauldronArtXOffset, range: -200...200, step: 1)
                            sliderControl("↕️ Y Position", value: $cauldronArtYOffset, range: -200...200, step: 1)
                            
                            HStack(spacing: 12) {
                                Button("Link W/H") {
                                    cauldronArtHeight = cauldronArtWidth
                                }
                                .buttonStyle(PotionShopLayoutEditorButtonStyle(color: .purple))
                                .font(.caption)
                                
                                Button("Reset Position") {
                                    cauldronArtXOffset = 0
                                    cauldronArtYOffset = 0
                                }
                                .buttonStyle(PotionShopLayoutEditorButtonStyle(color: .orange))
                                .font(.caption)
                            }
                            .padding(.horizontal)
                            
                            Divider().background(Color.white.opacity(0.3))
                            
                            // EDNAR FREEFORM CONTROLS
                            Text("🧙 Ednar Freeform")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            sliderControl("Uniform Scale", value: $ednarArtScale, range: 0.5...3.0)
                            sliderControl("↔️ Width Scale", value: $ednarArtWidth, range: 0.5...3.0)
                            sliderControl("↕️ Height Scale", value: $ednarArtHeight, range: 0.5...3.0)
                            sliderControl("↔️ X Position", value: $ednarArtXOffset, range: -200...200, step: 1)
                            sliderControl("↕️ Y Position", value: $ednarArtYOffset, range: -200...200, step: 1)
                            
                            HStack(spacing: 12) {
                                Button("Link W/H") {
                                    ednarArtHeight = ednarArtWidth
                                }
                                .buttonStyle(PotionShopLayoutEditorButtonStyle(color: .purple))
                                .font(.caption)
                                
                                Button("Reset Position") {
                                    ednarArtXOffset = 0
                                    ednarArtYOffset = 0
                                }
                                .buttonStyle(PotionShopLayoutEditorButtonStyle(color: .orange))
                                .font(.caption)
                            }
                            .padding(.horizontal)
                            
                            Divider().background(Color.white)
                            
                            // Action Buttons
                            VStack(spacing: 8) {
                                Button("📋 Generate Code") {
                                    generatedCode = generateCode()
                                }
                                .buttonStyle(PotionShopLayoutEditorButtonStyle(color: Color(.systemGreen)))
                                
                                if !generatedCode.isEmpty {
                                    Text(generatedCode)
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(8)
                                        .textSelection(.enabled)
                                }
                                
                                Button("🔄 Reset to Default") {
                                    resetToDefaults()
                                }
                                .buttonStyle(PotionShopLayoutEditorButtonStyle(color: .orange))
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 500)
                    .background(Color.black.opacity(panelOpacity))
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.bold())
            .foregroundColor(.yellow)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 4)
    }
    
    private func sliderControl(
        _ label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 0.001
    ) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
                Text(String(format: range.upperBound <= 2.0 ? "%.2f" : "%.0f", value.wrappedValue))
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            Slider(value: value, in: range, step: step)
                .tint(.cyan)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func resetToDefaults() {
        headerPercent = 0.010
        scenePercent = 0.263
        profilePercent = 0.095
        cauldronPercent = 0.372
        previewPercent = 0.032
        trayPercent = 0.193
        cauldronScale = 1.29
        cauldronXOffset = 44
        cauldronYOffset = 58
        nodeScale = 1.0
        nodeXOffset = 0
        nodeYOffset = 0
        showBrewButton = false
        brewXOffset = -50
        brewYPercent = 0.30
        brewZoneX = 0.83           // ✅ LOCKED VALUE
        brewZoneY = 0.19
        brewZoneWidth = 112        // ✅ LOCKED VALUE
        brewZoneHeight = 123
        showBrewZone = false       // ✅ LOCKED (hidden in game)
        dieScale = 1.31
        trayYOffset = -25
        enableDragDrop = true
        showBag = true
        showDiscard = true
        bagDiscardScale = 1.0
        // Art scaling defaults
        uniformArtScale = 1.0
        cauldronArtScale = 1.0
        cauldronArtWidth = 1.45    // ✅ LOCKED VALUE
        cauldronArtHeight = 2.00   // ✅ LOCKED VALUE
        cauldronArtXOffset = 7     // ✅ LOCKED VALUE
        cauldronArtYOffset = -40   // ✅ LOCKED VALUE
        ednarArtScale = 1.0
        ednarArtWidth = 1.59       // ✅ LOCKED VALUE
        ednarArtHeight = 2.00      // ✅ LOCKED VALUE
        ednarArtXOffset = 14
        ednarArtYOffset = -17
    }
    
    private func generateCode() -> String {
        var code = """
// SECTION HEIGHTS (in PotionShopGameView.swift)
let headerH      = max(70,  totalH * \(String(format: "%.3f", headerPercent)))
let sceneH       = max(160, totalH * \(String(format: "%.3f", scenePercent)))
let profileRowH  = max(74,  totalH * \(String(format: "%.3f", profilePercent)))
let cauldronH    = max(240, totalH * \(String(format: "%.3f", cauldronPercent)))
let previewBarH  = max(26,  totalH * \(String(format: "%.3f", previewPercent)))
let trayH        = max(82,  totalH * \(String(format: "%.3f", trayPercent)))

// CAULDRON PARAMETERS
PotionShopCauldronView(
    gs: gs,
    diceFlight: diceFlight,
    cauldronScale: \(String(format: "%.2f", cauldronScale)),
    cauldronXOffset: \(String(format: "%.0f", cauldronXOffset)),
    cauldronYOffset: \(String(format: "%.0f", cauldronYOffset)),
    nodeScale: \(String(format: "%.2f", nodeScale)),
    nodeXOffset: \(String(format: "%.0f", nodeXOffset)),
    nodeYOffset: \(String(format: "%.0f", nodeYOffset)),
    brewXOffset: \(String(format: "%.0f", brewXOffset)),
    brewYPercent: \(String(format: "%.2f", brewYPercent)),
    showBrewButton: \(showBrewButton),
    brewZoneX: \(String(format: "%.2f", brewZoneX)),
    brewZoneY: \(String(format: "%.2f", brewZoneY)),
    brewZoneWidth: \(String(format: "%.0f", brewZoneWidth)),
    brewZoneHeight: \(String(format: "%.0f", brewZoneHeight)),
    showBrewZone: \(showBrewZone)
)
.frame(height: cauldronH)

// DICE TRAY PARAMETERS
PotionShopDiceTrayView(
    gs: gs,
    diceFlight: diceFlight,
    dieScale: \(String(format: "%.2f", dieScale))
)
.frame(height: trayH)
.offset(y: \(String(format: "%.0f", trayYOffset)))

// BAG/DISCARD
showBag: \(showBag), scale: \(String(format: "%.2f", bagDiscardScale))
showDiscard: \(showDiscard), scale: \(String(format: "%.2f", bagDiscardScale))

// DRAG & DROP
enableDragDrop: \(enableDragDrop)
"""
        
        return code
    }
}

// MARK: - Button Style

struct PotionShopLayoutEditorButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var gs = PotionShopGameState()
    
    PotionShopLayoutEditorView(gs: gs, isPresented: $isPresented)
}
