//
//  PotionShopLayoutConfig.swift
//  OverQuestMatch3
//
//  Layout configuration shared between game view and layout editor overlay.
//  This allows live preview of layout changes.
//
//  ✅ UPDATED: May 5, 2026 - 1:44 AM - Section heights refined, preview bar removed
//

import SwiftUI

@Observable
class PotionShopLayoutConfig {
    static let shared = PotionShopLayoutConfig()
    
    // Section Heights (percentages)
    var headerPercent: Double = 1.7198581993579865
    var scenePercent: Double = 27.27518081665039
    var profilePercent: Double = 9.5
    var cauldronPercent: Double = 37.2
    var previewPercent: Double = 0.0  // ⚠️ REMOVED - Preview bar hidden
    var trayPercent: Double = 19.3
    
    // Ednar Art
    var ednarWidth: Double = 1.59
    var ednarHeight: Double = 2.0
    var ednarX: Double = 14.0
    var ednarY: Double = -17.0
    
    // Customer Scene Portraits (full-body standing characters)
    var customerSceneWidth: Double = 1.0
    var customerSceneHeight: Double = 1.0
    var customerSceneX: Double = 0.0
    var customerSceneY: Double = 0.0
    
    // Per-Character Scaling (14 characters, indexed by customer ID)
    // Stores individual width/height/x/y for each character
    var perCharacterScales: [String: CharacterScale] = [
        "mildred": CharacterScale(width: 2.461897164583206, height: 2.13, x: -1.0283708572387695, y: 15.539002418518066),
        "tomik": CharacterScale(width: 2.34, height: 2.13, x: 5.0, y: 51.0)
    ]
    
    struct CharacterScale: Codable {
        var width: Double = 1.0
        var height: Double = 1.0
        var x: Double = 0.0
        var y: Double = 0.0
    }
    
    // Helper to get or create a character scale
    func characterScale(for id: String) -> CharacterScale {
        return perCharacterScales[id] ?? CharacterScale()
    }
    
    // Helper to update a character scale
    func updateCharacterScale(for id: String, scale: CharacterScale) {
        perCharacterScales[id] = scale
    }
    
    // Cauldron Art
    var cauldronWidth: Double = 1.3613475412130356
    var cauldronHeight: Double = 1.9335107803344727
    var cauldronX: Double = -2.219867706298828
    var cauldronY: Double = -34.326231479644775
    
    // Cauldron Bowl
    var cauldronBowlScale: Double = 1.3121631294488907
    var cauldronBowlX: Double = 44.709229469299316
    var cauldronBowlY: Double = 58.0
    
    // Nodes
    var nodeScale: Double = 1.8311170041561127
    var nodeXOffset: Double = 79.43263053894043
    var nodeYOffset: Double = 71.27659320831299
    var nodeSpacingMultiplier: Double = 1.0  // ⚠️ EXPERIMENTAL: Changes visual spacing between nodes (does NOT affect boost reach)
    
    // Per-Node Fine-Tuning (12 nodes, each with X/Y offset)
    var perNodeOffsets: [CGPoint] = [
        CGPoint(x: -38.297873735427856, y: -37.94326186180115),  // Node 0
        CGPoint(x: 24.290776252746582, y: -37.41135001182556),   // Node 1
        CGPoint(x: -86.70212775468826, y: 5.6737542152404785),   // Node 2
        CGPoint(x: -7.446807622909546, y: -22.16312289237976),   // Node 3
        CGPoint(x: 83.68793725967407, y: 6.2056779861450195),    // Node 4
        CGPoint(x: -28.723400831222534, y: 28.19148302078247),   // Node 5
        CGPoint(x: 71.45389318466187, y: 7.0922017097473145),    // Node 6
        CGPoint(x: -53.014183044433594, y: 35.638296604156494),  // Node 7
        CGPoint(x: -91.13475382328033, y: 28.19148302078247),    // Node 8
        CGPoint(x: -38.1205677986145, y: 60.10638475418091),     // Node 9
        CGPoint(x: 20.567357540130615, y: 60.283684730529785),   // Node 10
        CGPoint(x: 83.51064920425415, y: 38.29786777496338)      // Node 11
    ]
    
    // Helper method to reset all per-node offsets
    func resetAllNodeOffsets() {
        perNodeOffsets = Array(repeating: .zero, count: 12)
    }
    
    // Dice & Tray
    var dieScale: Double = 1.405301421880722
    var trayOffsetX: Double = 4.609942436218262
    var trayOffsetY: Double = 6.2056779861450195
    
    // Brew Zone
    var brewZoneX: Double = 0.8424113392829895
    var brewZoneY: Double = 0.15010638535022736
    var brewZoneWidth: Double = 113.10815364122391
    var brewZoneHeight: Double = 95.51772773265839
    var showBrewZone: Bool = false
    
    private init() {}
}
