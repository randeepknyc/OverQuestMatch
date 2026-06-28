//
//  PotionShopFireMeterDebugView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — FIRE METER editor (debug menu → "🔥 Fire Meter")
//  Place in: PotionShop/ folder
//
//  ═══════════════════════════════════════════════════════════════════════
//  Live sliders that edit the flame values in PotionShopLayoutConfig — the
//  same config as the rest of the layout editor. So these values are saved
//  with "📋 Copy Layout Values" and reset with "🔒 Restore Locked Defaults"
//  in the debug menu (no separate save/copy of its own). "Reset flames" here
//  resets ONLY the fire-meter values.
//

import SwiftUI

struct PotionShopFireMeterDebugView: View {

    @Environment(\.dismiss) private var dismiss
    @Bindable private var cfg = PotionShopLayoutConfig.shared

    private var flameCount: Int { PotionShopConfig.maxFire }

    var body: some View {
        NavigationStack {
            Form {
                Section("Overall") {
                    sliderRow("Flame size", $cfg.fireMeterSize, 10...90)
                    sliderRow("Spacing (row spread)", $cfg.fireMeterSpacing, 0...140)
                    sliderRow("Move whole row · X", $cfg.fireMeterOffsetX, -200...200)
                    sliderRow("Move whole row · Y", $cfg.fireMeterOffsetY, -200...200)
                    sliderRow("Animation speed (fps)", $cfg.fireMeterFPS, 1...20)
                }

                ForEach(0..<flameCount, id: \.self) { i in
                    Section("Flame \(i + 1)") {
                        sliderRow("X", $cfg.fireFlameOffsetsX[i], -200...200)
                        sliderRow("Y", $cfg.fireFlameOffsetsY[i], -200...200)
                        sliderRow("Size ×", $cfg.fireFlameScales[i], 0.3...3.0, step: 0.05, decimals: 2)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        cfg.resetFireMeter()
                        cfg.ensureFireArrays()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise").foregroundColor(.orange)
                            Text("Reset flames")
                        }
                    }
                }

                Section {
                    Text("These values live in your layout config. To save them, use “📋 Copy Layout Values” in the debug menu and paste back. Draw flameN_lit1…3 / flameN_out1…3 in Assets.xcassets (N = 1–\(flameCount)); until then you'll see placeholder flame icons you can still position.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("🔥 Fire Meter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { cfg.ensureFireArrays() }   // make per-flame sliders safe to bind
        }
    }

    @ViewBuilder
    private func sliderRow(_ title: String,
                           _ value: Binding<Double>,
                           _ range: ClosedRange<Double>,
                           step: Double = 1,
                           decimals: Int = 0) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: "%.\(decimals)f", value.wrappedValue))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            Slider(value: value, in: range, step: step)
        }
    }
}
