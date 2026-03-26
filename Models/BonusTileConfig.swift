//
//  BonusTileConfig.swift
//  OverQuestMatch3
//
//  ☕ BONUS TILE SETTINGS - ADJUST THESE TO CUSTOMIZE BEHAVIOR
//

import Foundation

struct BonusTileConfig {
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ⚙️ USER-ADJUSTABLE SETTINGS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// Enable or disable the bonus tile feature entirely
    /// true = Bonus tiles spawn on 5-matches
    /// false = No bonus tiles (original game behavior)
    static let enabled: Bool = true
    
    /// How many gems needed in a match to spawn a bonus tile
    /// 5 = Only exact 5-matches (recommended)
    /// 6 = Only 6+ matches
    /// 4 = Even 4-matches spawn bonus (easier)
    static let minimumMatchSize: Int = 5
    
    /// What the bonus tile clears when matched
    /// "row" = Clears entire horizontal row
    /// "column" = Clears entire vertical column
    /// "both" = Clears row AND column (cross pattern)
    static let clearMode: String = "row"
    
    /// Should the bonus tile have a glowing effect?
    /// true = Pulsing rainbow glow animation 🌈
    /// false = Static image only
    static let enableGlow: Bool = true
    
    /// Use rainbow glow instead of single color?
    /// true = Rainbow cycling glow 🌈✨ (RECOMMENDED!)
    /// false = Single color glow (uses glowColor below)
    static let useRainbowGlow: Bool = true
    
    /// Glow animation speed (if enabled)
    /// 1.0 = Normal speed (1 second per pulse)
    /// 0.5 = Fast pulse
    /// 2.0 = Slow pulse
    static let glowSpeed: Double = 1.0
    
    /// Rainbow cycle speed (if useRainbowGlow is true)
    /// 3.0 = Slow color shift (recommended) 🌈
    /// 1.5 = Fast rainbow
    /// 6.0 = Very slow, subtle shift
    static let rainbowCycleSpeed: Double = 1.5
    
    /// Glow color (if useRainbowGlow is FALSE)
    /// You can change these RGB values to customize glow color
    /// Current: Golden/yellow glow
    static let glowColor: (red: Double, green: Double, blue: Double) = (1.0, 0.9, 0.3)
    
    /// Glow intensity (if enabled)
    /// 0.3 = Subtle glow
    /// 0.5 = Medium glow (recommended)
    /// 0.8 = Bright glow
    static let glowOpacity: Double = 1.5
    
    /// Image name for bonus tile (must match name in Assets.xcassets)
    static let imageName: String = "coffee_bonus"
    
    /// Should bonus tile be able to fall with gravity?
    /// true = Falls like normal gems
    /// false = Stays in place (more special feel)
    static let canFall: Bool = true
    
    /// Can multiple bonus tiles exist on board at once?
    /// true = Multiple bonus tiles allowed
    /// false = Only 1 at a time (new one replaces old)
    static let allowMultiple: Bool = true
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ☕ ANIMATED COFFEE CUP SETTINGS (NEW!)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// Enable cross-fade animation between coffee images?
    /// true = Coffee cup cycles through frames with smooth fade
    /// false = Static coffee_bonus.png image only
    static let enableAnimatedFrames: Bool = true
    
    /// How many coffee images do you have?
    /// Your images: coffee_bonus.png, coffee_bonus2.png ... coffee_bonus6.png
    /// So total frames = 6
    static let totalFrames: Int = 6
    
    /// Time to display each frame (seconds)
    /// 0.5 = Fast (energetic) ⚡
    /// 1.0 = Medium
    /// 2.0 = Slow (relaxed)
    static let frameDisplayDuration: Double = 0.5
    
    /// Cross-fade transition time (seconds)
    /// 0.2 = Quick fade
    /// 0.3 = Smooth fade (recommended) ✨
    /// 0.5 = Slow, dreamy fade
    static let fadeDuration: Double = 0.3
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // HELPER FUNCTIONS (Don't modify these)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static func shouldClearRow() -> Bool {
        clearMode == "row" || clearMode == "both"
    }
    
    static func shouldClearColumn() -> Bool {
        clearMode == "column" || clearMode == "both"
    }
    
    /// Get the image name for a specific frame
    /// Frame 1 = "coffee_bonus"
    /// Frame 2 = "coffee_bonus2"
    /// Frame 3 = "coffee_bonus3", etc.
    static func imageNameForFrame(_ frame: Int) -> String {
        if frame == 1 {
            return "coffee_bonus"
        } else {
            return "coffee_bonus\(frame)"
        }
    }
}
