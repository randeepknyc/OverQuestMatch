//
//  PotionShopLayoutEditor.swift
//  OverQuestMatch3
//
//  ENHANCED INTERACTIVE LAYOUT EDITOR
//  - Adjustable section heights
//  - Cauldron scale control
//  - BREW button positioning
//  - Dice tray offset
//  - Semi-transparent control panel
//

import SwiftUI

struct PotionShopLayoutEditor: View {
    // MARK: - Section Heights
    @State private var headerPercent: Double = 0.09
    @State private var scenePercent: Double = 0.21
    @State private var profilePercent: Double = 0.095
    @State private var cauldronPercent: Double = 0.32
    @State private var previewPercent: Double = 0.032
    @State private var trayPercent: Double = 0.105
    
    // MARK: - Cauldron Controls
    @State private var cauldronScale: Double = 1.0        // Multiplier for cauldron size
    
    // MARK: - BREW Button Position
    @State private var brewXOffset: Double = -50          // X position (relative to right edge)
    @State private var brewYPercent: Double = 0.30        // Y position (fraction of cauldron height)
    
    // MARK: - Dice Tray
    @State private var trayYOffset: Double = 0            // Y offset from normal position
    
    // MARK: - UI State
    @State private var showCode = false
    @State private var panelOpacity: Double = 0.30        // Control panel transparency
    @State private var showOverlays = true                // Toggle colored overlays
    @State private var gs = PotionShopGameState()
    @Namespace private var diceFlight
    
    private var totalPercent: Double {
        headerPercent + scenePercent + profilePercent + cauldronPercent + previewPercent + trayPercent
    }
    
    var body: some View {
        GeometryReader { geo in
            let totalH = geo.size.height
            
            ZStack {
                // ACTUAL GAME PREVIEW
                VStack(spacing: 0) {
                    PotionShopHeaderView(gs: gs, showDebugMenu: .constant(false))
                        .frame(height: totalH * headerPercent)
                        .overlay(showOverlays ? sectionLabel("HEADER", color: .blue) : nil)
                    
                    PotionShopCustomerSceneView(gs: gs)
                        .frame(height: totalH * scenePercent)
                        .frame(maxWidth: .infinity)
                        .overlay(showOverlays ? sectionLabel("SCENE", color: .green) : nil)
                    
                    PotionShopProfileRowView(gs: gs)
                        .frame(height: totalH * profilePercent)
                        .overlay(showOverlays ? sectionLabel("PROFILES", color: .orange) : nil)
                    
                    // NOTE: Cauldron scale/BREW position controls are visual only
                    // They show you how it WOULD look, but the actual PotionShopCauldronView
                    // doesn't have these parameters yet. Code generation will note this.
                    PotionShopCauldronView(gs: gs, diceFlight: diceFlight)
                        .frame(height: totalH * cauldronPercent)
                        .overlay(showOverlays ? sectionLabel("CAULDRON\nScale: \(Int(cauldronScale * 100))%", color: .purple) : nil)
                    
                    PotionShopBrewPreviewBar(gs: gs)
                        .frame(height: totalH * previewPercent)
                        .overlay(showOverlays ? sectionLabel("PREVIEW", color: .pink) : nil)
                    
                    PotionShopDiceTrayView(gs: gs, diceFlight: diceFlight)
                        .frame(height: totalH * trayPercent)
                        .offset(y: trayYOffset)
                        .overlay(showOverlays ? sectionLabel("TRAY\nOffset: \(Int(trayYOffset))pt", color: .cyan) : nil)
                    
                    Spacer(minLength: 0)
                        .frame(maxHeight: .infinity)
                        .overlay(
                            showOverlays ? Text("SPACER")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.red.opacity(0.5)) : nil
                        )
                }
                
                // CONTROL PANEL (semi-transparent, scrollable)
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("🎨 LAYOUT EDITOR")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                showOverlays.toggle()
                            } label: {
                                Image(systemName: showOverlays ? "eye.fill" : "eye.slash")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.85))
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                // Panel opacity control
                                VStack(spacing: 4) {
                                    HStack {
                                        Text("👁️ Panel Opacity")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(Int(panelOpacity * 100))%")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                            .frame(width: 45)
                                    }
                                    .padding(.horizontal)
                                    
                                    Slider(value: $panelOpacity, in: 0.1...1.0, step: 0.05)
                                        .accentColor(.white)
                                        .padding(.horizontal)
                                }
                                
                                Divider().background(Color.white.opacity(0.3))
                                
                                // Section heights
                                Text("📐 SECTION HEIGHTS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.yellow)
                                
                                sliderControl("📊 Header", value: $headerPercent, color: .blue)
                                sliderControl("👥 Scene", value: $scenePercent, color: .green)
                                sliderControl("🎭 Profiles", value: $profilePercent, color: .orange)
                                sliderControl("🍲 Cauldron", value: $cauldronPercent, color: .purple)
                                sliderControl("📋 Preview", value: $previewPercent, color: .pink)
                                sliderControl("🎲 Tray", value: $trayPercent, color: .cyan)
                                
                                HStack {
                                    Text("Total:")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12, weight: .bold))
                                    Spacer()
                                    Text("\(Int(totalPercent * 100))%")
                                        .foregroundColor(totalPercent > 1.0 ? .red : .green)
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .padding(.horizontal)
                                
                                Divider().background(Color.white.opacity(0.3))
                                
                                // Cauldron controls
                                Text("🍲 CAULDRON CONTROLS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.yellow)
                                
                                sliderControl(
                                    "📏 Cauldron Scale",
                                    value: $cauldronScale,
                                    color: .purple,
                                    range: 0.5...2.0,
                                    format: { "\(Int($0 * 100))%" }
                                )
                                
                                Divider().background(Color.white.opacity(0.3))
                                
                                // BREW button controls
                                Text("🥄 BREW BUTTON POSITION")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.yellow)
                                
                                sliderControl(
                                    "↔️ X Offset (from right)",
                                    value: $brewXOffset,
                                    color: .orange,
                                    range: -150...0,
                                    format: { "\(Int($0))pt" }
                                )
                                
                                sliderControl(
                                    "↕️ Y Position (% of cauldron)",
                                    value: $brewYPercent,
                                    color: .orange,
                                    range: 0.0...1.0,
                                    format: { "\(Int($0 * 100))%" }
                                )
                                
                                Divider().background(Color.white.opacity(0.3))
                                
                                // Dice tray controls
                                Text("🎲 DICE TRAY CONTROLS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.yellow)
                                
                                sliderControl(
                                    "↕️ Y Offset",
                                    value: $trayYOffset,
                                    color: .cyan,
                                    range: -100...100,
                                    format: { "\(Int($0))pt" }
                                )
                                
                                Divider().background(Color.white.opacity(0.3))
                                
                                // Code generation
                                Button {
                                    showCode.toggle()
                                } label: {
                                    Text(showCode ? "Hide Code" : "📋 Generate Code")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)
                                
                                if showCode {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Copy this code:")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.yellow)
                                        
                                        Text(generateCode())
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.black.opacity(0.8))
                                            .cornerRadius(4)
                                            .textSelection(.enabled)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .frame(maxHeight: 500)
                        .background(Color.black.opacity(panelOpacity))
                    }
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
        .background(PotionShopTheme.bg)
    }
    
    // MARK: - Helper Views
    
    private func sectionLabel(_ text: String, color: Color) -> some View {
        VStack {
            Spacer()
            Text(text)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.7))
                .cornerRadius(4)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color.opacity(0.15))
        .border(color, width: 2)
        .allowsHitTesting(false)
    }
    
    private func sliderControl(
        _ label: String,
        value: Binding<Double>,
        color: Color,
        range: ClosedRange<Double> = 0.01...0.50,
        format: ((Double) -> String)? = nil
    ) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(format?(value.wrappedValue) ?? "\(Int(value.wrappedValue * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .frame(width: 60)
            }
            .padding(.horizontal)
            
            HStack(spacing: 8) {
                let step = (range.upperBound - range.lowerBound) / 100
                
                Button("-") {
                    value.wrappedValue = max(range.lowerBound, value.wrappedValue - step)
                }
                .buttonStyle(AdjustButtonStyle())
                
                Slider(value: value, in: range, step: step)
                    .accentColor(color)
                
                Button("+") {
                    value.wrappedValue = min(range.upperBound, value.wrappedValue + step)
                }
                .buttonStyle(AdjustButtonStyle())
            }
            .padding(.horizontal)
        }
    }
    
    private func generateCode() -> String {
        """
// SECTION HEIGHTS (PotionShopGameView.swift):
let headerH      = max(70,  totalH * \(String(format: "%.3f", headerPercent)))
let sceneH       = max(160, totalH * \(String(format: "%.3f", scenePercent)))
let profileRowH  = max(74,  totalH * \(String(format: "%.3f", profilePercent)))
let cauldronH    = max(240, totalH * \(String(format: "%.3f", cauldronPercent)))
let previewBarH  = max(26,  totalH * \(String(format: "%.3f", previewPercent)))
let trayH        = max(82,  totalH * \(String(format: "%.3f", trayPercent)))

// ⚠️ CAULDRON/BREW/TRAY CONTROLS NOT YET IMPLEMENTED
// These require adding parameters to PotionShopCauldronView
// Current values for reference:
// - Cauldron Scale: \(String(format: "%.2f", cauldronScale))
// - BREW X Offset: \(String(format: "%.0f", brewXOffset))pt
// - BREW Y Percent: \(String(format: "%.2f", brewYPercent))
// - Tray Y Offset: \(String(format: "%.0f", trayYOffset))pt

// To implement these, you'll need to:
// 1. Add parameters to PotionShopCauldronView
// 2. Scale cauldron geometry by cauldronScale
// 3. Position BREW button using brewXOffset + brewYPercent
// 4. Offset dice tray using trayYOffset
"""
    }
}

struct AdjustButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(Color.gray.opacity(0.6))
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    PotionShopLayoutEditor()
}
