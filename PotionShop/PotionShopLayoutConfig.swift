//
//  PotionShopLayoutConfig.swift
//  OverQuestMatch3
//
//  Layout configuration shared between game view and layout editor overlay.
//  This allows live preview of layout changes.
//

import SwiftUI

@Observable
class PotionShopLayoutConfig {
    static let shared = PotionShopLayoutConfig()
    
    // Section Heights (percentages)
    var headerPercent: Double = 1.0
    var scenePercent: Double = 26.3
    var profilePercent: Double = 9.5
    var cauldronPercent: Double = 37.2
    var previewPercent: Double = 3.2
    var trayPercent: Double = 19.3
    
    // Ednar Art
    var ednarWidth: Double = 1.59
    var ednarHeight: Double = 2.00
    var ednarX: Double = 14
    var ednarY: Double = -17
    
    // Cauldron Art
    var cauldronWidth: Double = 1.45
    var cauldronHeight: Double = 2.00
    var cauldronX: Double = 7
    var cauldronY: Double = -40
    
    // Cauldron Bowl
    var cauldronBowlScale: Double = 1.29
    var cauldronBowlX: Double = 44
    var cauldronBowlY: Double = 58
    
    // Nodes
    var nodeScale: Double = 1.00
    var nodeXOffset: Double = 0
    var nodeYOffset: Double = 0
    var nodeSpacingMultiplier: Double = 1.00  // ⚠️ EXPERIMENTAL: Changes visual spacing between nodes (does NOT affect boost reach)
    
    // Dice & Tray
    var dieScale: Double = 1.31
    var trayOffsetX: Double = 0
    var trayOffsetY: Double = -25
    
    // Brew Zone
    var brewZoneX: Double = 0.83
    var brewZoneY: Double = 0.19
    var brewZoneWidth: Double = 112
    var brewZoneHeight: Double = 123
    var showBrewZone: Bool = false
    
    private init() {}
}
