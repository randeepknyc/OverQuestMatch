//
//  ChainVisualConfig.swift
//  OverQuestMatch3
//

import SwiftUI

struct ChainVisualConfig {
    
    // ═══════════════════════════════════════════════════════════════
    // 🎨 RAINBOW PULSE SETTINGS
    // ═══════════════════════════════════════════════════════════════
    
    static let enableRainbowPulse: Bool = true
    static let rainbowSpeed: Double = 1.0
    
    static let rainbowColors: [Color] = [
        .red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink
    ]
    
    // ═══════════════════════════════════════════════════════════════
    // 📐 CHAIN LINE SETTINGS
    // ═══════════════════════════════════════════════════════════════
    
    static let useCustomLineImage: Bool = false
    static let customLineImageName: String = "chain_line_background"
    static let lineWidth: CGFloat = 8
    static let lineOpacity: Double = 0.6
    static let enableLineGlow: Bool = true
    static let lineGlowRadius: CGFloat = 12
    
    // ═══════════════════════════════════════════════════════════════
    // 🏷️ CHAIN COUNTER SETTINGS
    // ═══════════════════════════════════════════════════════════════
    
    static let useCustomCounterImage: Bool = false
    static let customCounterImageName: String = "chain_counter_background"
    static let counterFontSize: CGFloat = 32
    static let counterIconSize: CGFloat = 20
    static let counterGemSize: CGFloat = 32
    static let counterPaddingH: CGFloat = 16
    static let counterPaddingV: CGFloat = 8
    static let counterShadowRadius: CGFloat = 8
    static let counterValidOpacity: Double = 0.9
    static let counterInvalidOpacity: Double = 0.7
    
    // ═══════════════════════════════════════════════════════════════
    // ✨ ANIMATION SETTINGS
    // ═══════════════════════════════════════════════════════════════
    
    static let counterPulseScale: CGFloat = 1.05
    static let pulseDuration: Double = 0.6
}
