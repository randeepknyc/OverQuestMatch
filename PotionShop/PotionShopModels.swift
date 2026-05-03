//
//  PotionShopModels.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Data Models
//  Place in: PotionShop/ folder
//

import SwiftUI

// MARK: - Game state phases
//
// These are the broad states the game can be in. Set by the state
// machine (PotionShopGameState, added in Phase 3) and read by the
// view to decide what to show.

enum PotionShopPhase {
    case playing       // normal gameplay
    case roundWon      // round complete overlay shown
    case dayWon        // day complete overlay shown
    case lost          // composure hit 0 — game over
}

// MARK: - Theme colors
//
// Warm parchment palette for the new game. Different from the
// existing CauldronGame's dark/purple theme. These are placeholders
// — final colors will come from the user's art.

struct PotionShopTheme {
    // Warm parchment background
    static let bg = Color(red: 0.98, green: 0.96, blue: 0.93)
    // Dark wood for text and outlines
    static let ink = Color(red: 0.23, green: 0.14, blue: 0.06)
    // Muted brown for secondary text
    static let muted = Color(red: 0.50, green: 0.42, blue: 0.30)
    // Warm tan accent for buttons and highlights
    static let accent = Color(red: 0.73, green: 0.46, blue: 0.09)
    // Composure bar colors
    static let composureGood = Color(red: 0.59, green: 0.77, blue: 0.35)
    static let composureWarn = Color(red: 0.94, green: 0.71, blue: 0.26)
    static let composureBad  = Color(red: 0.89, green: 0.29, blue: 0.29)
    // Shield teal
    static let shield = Color(red: 0.36, green: 0.79, blue: 0.65)
}
