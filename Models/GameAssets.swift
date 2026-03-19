//
//  GameAssets.swift
//  OverQuestMatch3
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

/// Configuration for game balance
struct GameConfig {
    static let boardSize = 8 // 8x8 for optimal full-screen layout
    static let barbarianStartHealth = 100
    static let toadStartHealth = 200
    
    static let baseDamage = 8
    static let magicDamage = 12
    static let healAmount = 10
    static let shieldAmount = 5
    static let manaPerGem = 1
    static let maxMana = 10
    
    static let comboMultiplier = 1.5
    static let specialTileThreshold = 4 // 4+ matches create special tiles
    
    static let enemyMinDamage = 8
    static let enemyMaxDamage = 15
    
    // MARK: - Ability Effects
    static let heroicStrikeDamage = 40      // Direct damage, bypasses shield
    static let divineShieldAmount = 25       // Shield points granted
    static let greaterHealAmount = 40        // HP restored
    
    // ═══════════════════════════════════════════════════════════════
    // 🔥 POWER SURGE EFFECT CONFIG
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Chain Combo Effects
    static let enablePowerSurgeEffect = true  // ⚠️ Set to false to disable 4-chain visual effect
    static let powerSurgeChainThreshold = 4   // Number of combos needed for Power Surge
    static let powerSurgeManaBonus = 2        // Extra mana awarded on Power Surge
    
    // ═══════════════════════════════════════════════════════════════
    // 🎬 DEVELOPER SPLASH SCREEN - "IT CAME FROM THE DEEP"
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Developer Splash Screen
    static let enableDeveloperSplash = true           // Toggle splash screen on/off (true = show, false = skip)
    static let splashDuration: Double = 2.0           // How long splash shows (seconds)
    static let useAnimatedSplash = false              // false = static image, true = animated frames
    
    // ═══════════════════════════════════════════════════════════════
    // 🎨 TITLE SCREEN ANIMATION
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Title Screen Animation
    static let titleAnimationStyle: TitleAnimationStyle = .floatAndPulse
    // Available options: .none, .slideAndSettle, .floatAndPulse, .scaleAndBounce, .parallaxScroll
}

// ═══════════════════════════════════════════════════════════════
// 🎨 TITLE ANIMATION STYLES
// ═══════════════════════════════════════════════════════════════
enum TitleAnimationStyle {
    case none              // No animation, static display
    case slideAndSettle    // Logo slides from bottom, bounces to top
    case floatAndPulse     // Gentle float + glow pulse (DEFAULT)
    case scaleAndBounce    // Logo grows from small, bounces to size
    case parallaxScroll    // Background drifts slowly
}
