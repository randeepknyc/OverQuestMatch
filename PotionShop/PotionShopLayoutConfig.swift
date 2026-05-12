//
//  PotionShopLayoutConfig.swift
//  OverQuestMatch3
//
//  Layout configuration shared between game view and layout editor overlay.
//  This allows live preview of layout changes.
//
//  ✅ UPDATED: May 12, 2026 - 3-POSITION SYSTEM
//  Each character now has 3 sets of scale/position values:
//    - Active (queue[0]): Front of line
//    - Waiting 1 (queue[1]): First waiting spot
//    - Waiting 2 (queue[2]): Second waiting spot
//  All positions default to 1.0×1.0×0,0 (no distortion, pixel-accurate sizing).
//  Use layout editor sliders to adjust individual positions per character.
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
    
    // Ednar Art (ACTUAL SIZE - May 11, 2026)
    // All images drawn at same canvas size (1536×1024) and displayed uniformly
    // Scale multipliers at 1.0 = no distortion, images appear at natural proportions
    var ednarBaseScale: Double = 0.15  // Base scale to make 1536×1024 images visible
    var ednarWidth: Double = 1.0
    var ednarHeight: Double = 1.0
    var ednarX: Double = 0.0
    var ednarY: Double = 0.0
    
    // Customer Scene Portraits (full-body standing characters)
    // BASE SCALE: Multiplier applied to ALL scene images before per-character scaling
    // This makes 1536×1024 canvas images appear at a visible size
    // Adjust this ONE value to make all characters bigger/smaller together
    var customerSceneBaseScale: Double = 2.0  // 200% of base to match visible Ednar size
    var customerSceneWidth: Double = 1.0
    var customerSceneHeight: Double = 1.0
    var customerSceneX: Double = 0.0
    var customerSceneY: Double = 0.0
    
    // Per-Character Scaling (14 characters, indexed by customer ID)
    // 3-POSITION SYSTEM (May 12, 2026):
    // Each character has 3 sets of scale/position values:
    //   - Active (queue[0]): Front of line, closest to Ednar
    //   - Waiting 1 (queue[1]): First waiting spot
    //   - Waiting 2 (queue[2]): Second waiting spot
    // All characters drawn on 1536×1024 canvas at their natural relative sizes
    // Default scale 1.0×1.0 for ALL positions = no distortion, images appear as drawn
    // Use layout editor sliders to fine-tune individual positions per character
    var perCharacterScales: [String: CharacterScale] = [
        "mildred": CharacterScale(
            width: 1.0, height: 1.0, x: -5.6737542152404785, y: 7.801413536071777,
            waitingWidth: 0.9880319200456142, waitingHeight: 0.9880319200456142, waitingX: 0.0, waitingY: -9.219861030578613,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "tomik": CharacterScale(
            width: 1.0, height: 1.0, x: -34.7517728805542, y: 10.283684730529785,
            waitingWidth: 1.0, waitingHeight: 1.0, waitingX: 0.0, waitingY: -7.446813583374023,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "greta": CharacterScale(
            width: 0.8563829660415649, height: 0.8563829660415649, x: -46.45390510559082, y: 19.5035457611084,
            waitingWidth: 0.8882978670299053, waitingHeight: 0.8882978670299053, waitingX: 0.0, waitingY: 3.9007186889648438,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "sister_halla": CharacterScale(
            width: 1.0, height: 1.0, x: 0.0, y: 0.0,
            waitingWidth: 1.0, waitingHeight: 1.0, waitingX: 0.0, waitingY: 0.0,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "wendelina": CharacterScale(
            width: 1.0, height: 1.0, x: -43.6170220375061, y: 3.9007186889648438,
            waitingWidth: 1.003989353775978, waitingHeight: 1.003989353775978, waitingX: -18.794333934783936, waitingY: -9.929072856903076,
            waiting2Width: 0.9960106536746025, waiting2Height: 0.9960106536746025, waiting2X: -4.964542388916016, waiting2Y: -6.0283660888671875
        ),
        "grimdrek": CharacterScale(
            width: 1.0, height: 1.0, x: 0.0, y: 0.0,
            waitingWidth: 1.0, waitingHeight: 1.0, waitingX: 0.0, waitingY: 0.0,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "hexa_mott": CharacterScale(
            width: 1.0, height: 1.0, x: 0.0, y: 0.0,
            waitingWidth: 1.0, waitingHeight: 1.0, waitingX: 0.0, waitingY: 0.0,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "pemberton": CharacterScale(
            width: 0.8324467986822128, height: 0.8324467986822128, x: -39.361703395843506, y: 24.11346435546875,
            waitingWidth: 0.8643616996705532, waitingHeight: 0.8643616996705532, waitingX: -23.049640655517578, waitingY: 5.3191423416137695,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "ardo": CharacterScale(
            width: 0.9840425699949265, height: 0.9840425699949265, x: -39.716315269470215, y: 10.283684730529785,
            waitingWidth: 1.0, waitingHeight: 1.0, waitingX: -9.574460983276367, waitingY: -5.3191423416137695,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: -5.319154262542725, waiting2Y: -5.319154262542725
        ),
        "bram": CharacterScale(
            width: 1.0, height: 1.0, x: 0.0, y: 0.0,
            waitingWidth: 1.0, waitingHeight: 1.0, waitingX: 0.0, waitingY: 0.0,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "crispin": CharacterScale(
            width: 1.0319149382412434, height: 1.0319149382412434, x: -31.914889812469482, y: 0.0,
            waitingWidth: 1.0279255546629429, waitingHeight: 1.0279255546629429, waitingX: -21.631205081939697, waitingY: -12.765955924987793,
            waiting2Width: 1.0279255546629429, waiting2Height: 1.0279255546629429, waiting2X: -18.794333934783936, waiting2Y: -15.957450866699219
        ),
        "ironhilde": CharacterScale(
            width: 1.0, height: 1.0, x: 0.0, y: 0.0,
            waitingWidth: 1.0, waitingHeight: 1.0, waitingX: 0.0, waitingY: 0.0,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "carmilla": CharacterScale(
            width: 1.0, height: 1.0, x: 0.0, y: 0.0,
            waitingWidth: 1.0, waitingHeight: 1.0, waitingX: 0.0, waitingY: 0.0,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        ),
        "royal_envoy": CharacterScale(
            width: 1.0, height: 1.0, x: 0.0, y: 0.0,
            waitingWidth: 1.0, waitingHeight: 1.0, waitingX: 0.0, waitingY: 0.0,
            waiting2Width: 1.0, waiting2Height: 1.0, waiting2X: 0.0, waiting2Y: 0.0
        )
    ]
    
    struct CharacterScale: Codable {
        // Active position (when customer is at queue[0] - front of line)
        var width: Double = 1.0
        var height: Double = 1.0
        var x: Double = 0.0
        var y: Double = 0.0
        
        // Waiting position 1 (when customer is at queue[1] - first waiting spot)
        var waitingWidth: Double = 1.0     // ← CHANGED: Now defaults to match active (was 0.8)
        var waitingHeight: Double = 1.0    // ← CHANGED: Now defaults to match active (was 0.8)
        var waitingX: Double = 0.0
        var waitingY: Double = 0.0
        
        // Waiting position 2 (when customer is at queue[2] - second waiting spot) ← NEW!
        var waiting2Width: Double = 1.0
        var waiting2Height: Double = 1.0
        var waiting2X: Double = 0.0
        var waiting2Y: Double = 0.0
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
