//
//  GameAssets.swift
//  OverQuestMatch3
//
//  Asset names and UI configuration (non-battle related)
//

import Foundation

/// Centralized asset configuration for easy art replacement
struct GameAssets {
    
    // MARK: - Characters
    static let barbarianImage = "ramp" // User's barbarian art
    static let toadImage = "ednar"      // User's toad enemy art
    
    // MARK: - Tile Icons
    // Using match3pieces.png - organize as individual assets in Assets.xcassets
    // For now using SF Symbols as fallback
    static let tileIcons: [String: String] = [
        "sword": "sword",
        "fire": "flame.fill",
        "shield": "shield.fill",
        "heart": "heart.fill",
        "mana": "bolt.fill",
        "poison": "drop.fill"
    ]
    
    // MARK: - Layout Reference
    static let layoutReference = "match3layout" // User's layout mockup
    
    // MARK: - Battle Background
    static let battleBackground = "battle_bg" // Placeholder for swamp/forest scene
    static let matchBackground = "match_bg" // Match-3 board background
    
    // MARK: - Map Screen
    static let mapBackground = "map_placeholder" // Map screen background image
    
    // MARK: - Menu Icons
    static let resumeIcon = "resume_icon"
    static let restartIcon = "restart_icon"
    static let settingsIcon = "settings_icon"
    static let helpIcon = "help_icon"
    static let exitIcon = "exit_icon"
    
    // MARK: - Audio (hooks for future)
    static let soundEffects = [
        "match": "match_sound",
        "attack": "attack_sound",
        "heal": "heal_sound",
        "special": "special_sound"
    ]
}

/// Configuration for UI and game structure (non-battle related)
struct GameConfig {
    
    // MARK: - Board Layout
    static let boardSize = 8 // 8x8 for optimal full-screen layout
    static let specialTileThreshold = 4 // 4+ matches create special tiles
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Visual Effects
    // ═══════════════════════════════════════════════════════════════
    
    /// Enable/disable Power Surge visual effect (golden lightning)
    static let enablePowerSurgeEffect = true  // ⚠️ Set to false to disable visual effect
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Splash Screen Settings
    // ═══════════════════════════════════════════════════════════════
    
    static let enableDeveloperSplash = true           // Toggle splash screen on/off
    static let splashDuration: Double = 4.0           // How long splash shows (seconds)
    static let useAnimatedSplash = false              // false = static image, true = animated frames
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Title Screen Animation
    // ═══════════════════════════════════════════════════════════════
    
    static let titleAnimationStyle: TitleAnimationStyle = .floatAndPulse
    // Available options: .none, .slideAndSettle, .floatAndPulse, .scaleAndBounce, .parallaxScroll
}

// ═══════════════════════════════════════════════════════════════
// MARK: - Title Animation Styles
// ═══════════════════════════════════════════════════════════════
enum TitleAnimationStyle {
    case none              // No animation, static display
    case slideAndSettle    // Logo slides from bottom, bounces to top
    case floatAndPulse     // Gentle float + glow pulse (DEFAULT)
    case scaleAndBounce    // Logo grows from small, bounces to size
    case parallaxScroll    // Background drifts slowly
}
