//
//  PotionShopLayoutConfig.swift
//  OverQuestMatch3
//
//  Layout configuration shared between game view and layout editor overlay.
//  This allows live preview of layout changes.
//
//  ✅ UPDATED: May 13, 2026 - LOCKED DEFAULTS ADDED
//  Added restoreLockedDefaults() method - one tap returns to known-good state.
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
    
    // MARK: - Per-Permutation Queue Positioning (NEW - Prevents Overlaps)
    //
    // Define custom X/Y positions for specific 3-character arrangements.
    // Key format: "character1_character2_character3" (in queue order)
    // Value: QueuePermutation with custom positions for all 3 spots
    //
    // Example: "wendelina_crispin_ardo" = custom spacing for Evening round
    //
    // If no entry exists for a permutation, falls back to default spacing.
    var queuePermutations: [String: QueuePermutation] = [:]
    
    struct QueuePermutation: Codable {
        // X positions (as fraction of scene width, 0.0 to 1.0)
        var xPositions: [Double] = [0.48, 0.68, 0.88]
        // Y positions (as fraction of scene height, 0.0 to 1.0)
        var yPositions: [Double] = [0.48, 0.55, 0.55]
        // Optional: Scale overrides for this specific arrangement
        var scaleOverrides: [Double]? = nil  // nil = use default [1.0, 1.0, 1.0]
    }
    
    /// Get queue positions for a specific arrangement of characters.
    /// Falls back to default if no custom permutation is defined.
    func queuePositions(for characterKeys: [String]) -> QueuePermutation {
        guard characterKeys.count == 3 else {
            // Not a 3-character round, return defaults
            return QueuePermutation()
        }
        
        let key = characterKeys.joined(separator: "_")
        return queuePermutations[key] ?? QueuePermutation()
    }
    
    /// Add a custom permutation for a specific 3-character arrangement.
    /// Use this in debug menu or layout editor to prevent overlaps.
    /// Example: config.addPermutation(for: ["wendelina", "crispin", "ardo"], xPositions: [0.40, 0.65, 0.90])
    func addPermutation(for characterKeys: [String], 
                       xPositions: [Double]? = nil,
                       yPositions: [Double]? = nil,
                       scaleOverrides: [Double]? = nil) {
        guard characterKeys.count == 3 else {
            print("⚠️ Permutation must have exactly 3 characters")
            return
        }
        
        let key = characterKeys.joined(separator: "_")
        var permutation = queuePermutations[key] ?? QueuePermutation()
        
        if let xPositions = xPositions {
            permutation.xPositions = xPositions
        }
        if let yPositions = yPositions {
            permutation.yPositions = yPositions
        }
        if let scaleOverrides = scaleOverrides {
            permutation.scaleOverrides = scaleOverrides
        }
        
        queuePermutations[key] = permutation
        
        print("✅ Added permutation for: \(characterKeys.joined(separator: " → "))")
        print("   X: \(permutation.xPositions)")
        print("   Y: \(permutation.yPositions)")
        if let scales = permutation.scaleOverrides {
            print("   Scales: \(scales)")
        }
    }
    
    /// Remove a custom permutation (returns to default spacing)
    func removePermutation(for characterKeys: [String]) {
        let key = characterKeys.joined(separator: "_")
        queuePermutations.removeValue(forKey: key)
        print("🗑️ Removed permutation for: \(characterKeys.joined(separator: " → "))")
    }
    
    /// List all custom permutations currently defined
    func listPermutations() -> [String] {
        return Array(queuePermutations.keys).sorted()
    }
    
    enum CustomerHeightBucket: String, Codable, CaseIterable {
        case short
        case medium
        case tall
    }

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

        // Head anchor (May 22, 2026): bucket label + optional per-character override.
        // Override (if set) wins; otherwise the bucket's global default applies.
        var heightBucket: CustomerHeightBucket = .medium
        var headAnchorYOverride: Double? = nil

        // Per-character badge overrides (May 23, 2026). Each is optional;
        // when set, it wins over the bucket default. Useful when characters
        // in the same bucket need different X (e.g., wider/thinner body).
        var hpBadgeSizeOverride: Double? = nil
        var hpBadgeOffsetXOverride: Double? = nil
        var hpBadgeOffsetYOverride: Double? = nil
        var attackBadgeSizeOverride: Double? = nil
        var attackBadgeOffsetXOverride: Double? = nil
        var attackBadgeOffsetYOverride: Double? = nil

        // Per-character WAITING badge overrides (May 23, 2026 — Option C).
        // Apply when the character is in queue[1] (waiting slot 1). They also
        // act as the fallback for queue[2] when no waiting2 override is set.
        var waitingHpBadgeSizeOverride: Double? = nil
        var waitingHpBadgeOffsetXOverride: Double? = nil
        var waitingHpBadgeOffsetYOverride: Double? = nil
        var waitingAttackBadgeSizeOverride: Double? = nil
        var waitingAttackBadgeOffsetXOverride: Double? = nil
        var waitingAttackBadgeOffsetYOverride: Double? = nil

        // Per-character WAITING-2 badge overrides (May 24, 2026).
        // Apply ONLY when the character is in queue[2]. When nil, the value
        // falls back to the waiting (queue[1]) override, then active, then bucket.
        var waiting2HpBadgeSizeOverride: Double? = nil
        var waiting2HpBadgeOffsetXOverride: Double? = nil
        var waiting2HpBadgeOffsetYOverride: Double? = nil
        var waiting2AttackBadgeSizeOverride: Double? = nil
        var waiting2AttackBadgeOffsetXOverride: Double? = nil
        var waiting2AttackBadgeOffsetYOverride: Double? = nil
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
    
    // MARK: - Badge Graphics (NEW - May 22, 2026)
    
    // HP Badge — per height bucket (size + offsets relative to head anchor).
    // Tuned May 23, 2026 (revision 3).
    var hpBadgeSizeShort: Double = 50.437946021556854
    var hpBadgeOffsetXShort: Double = -32.819151878356934
    var hpBadgeOffsetYShort: Double = -8.77659022808075
    var hpBadgeSizeMedium: Double = 50.51773101091385
    var hpBadgeOffsetXMedium: Double = -82.0212721824646
    var hpBadgeOffsetYMedium: Double = 6.3829779624938965
    var hpBadgeSizeTall: Double = 52.193264067173004
    var hpBadgeOffsetXTall: Double = -171.8085139989853
    var hpBadgeOffsetYTall: Double = 13.031923770904541

    // Attack Badge — per height bucket.
    var attackBadgeSizeShort: Double = 34.28368777036667
    var attackBadgeOffsetXShort: Double = -32.97874331474304
    var attackBadgeOffsetYShort: Double = 23.404258489608765
    var attackBadgeSizeMedium: Double = 36.27836883068085
    var attackBadgeOffsetXMedium: Double = -76.06383562088013
    var attackBadgeOffsetYMedium: Double = 36.436182260513306
    var attackBadgeSizeTall: Double = 36.27836763858795
    var attackBadgeOffsetXTall: Double = -153.723406791687
    var attackBadgeOffsetYTall: Double = 45.744699239730835

    // Bucket-aware lookups (per-character override wins when set).
    // queueSlot: 0 = active (queue[0]), 1 = waiting (queue[1]), 2 = waiting2 (queue[2]).
    // Precedence for slot 2: waiting2 override -> waiting override -> active override -> bucket.
    // Precedence for slot 1: waiting override -> active override -> bucket.
    // Precedence for slot 0: active override -> bucket.
    func hpBadgeSize(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2HpBadgeSizeOverride { return v }
        if queueSlot >= 1, let v = cs.waitingHpBadgeSizeOverride { return v }
        if let v = cs.hpBadgeSizeOverride { return v }
        switch cs.heightBucket {
        case .short: return hpBadgeSizeShort
        case .medium: return hpBadgeSizeMedium
        case .tall: return hpBadgeSizeTall
        }
    }
    func hpBadgeOffsetX(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2HpBadgeOffsetXOverride { return v }
        if queueSlot >= 1, let v = cs.waitingHpBadgeOffsetXOverride { return v }
        if let v = cs.hpBadgeOffsetXOverride { return v }
        switch cs.heightBucket {
        case .short: return hpBadgeOffsetXShort
        case .medium: return hpBadgeOffsetXMedium
        case .tall: return hpBadgeOffsetXTall
        }
    }
    func hpBadgeOffsetY(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2HpBadgeOffsetYOverride { return v }
        if queueSlot >= 1, let v = cs.waitingHpBadgeOffsetYOverride { return v }
        if let v = cs.hpBadgeOffsetYOverride { return v }
        switch cs.heightBucket {
        case .short: return hpBadgeOffsetYShort
        case .medium: return hpBadgeOffsetYMedium
        case .tall: return hpBadgeOffsetYTall
        }
    }
    func attackBadgeSize(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2AttackBadgeSizeOverride { return v }
        if queueSlot >= 1, let v = cs.waitingAttackBadgeSizeOverride { return v }
        if let v = cs.attackBadgeSizeOverride { return v }
        switch cs.heightBucket {
        case .short: return attackBadgeSizeShort
        case .medium: return attackBadgeSizeMedium
        case .tall: return attackBadgeSizeTall
        }
    }
    func attackBadgeOffsetX(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2AttackBadgeOffsetXOverride { return v }
        if queueSlot >= 1, let v = cs.waitingAttackBadgeOffsetXOverride { return v }
        if let v = cs.attackBadgeOffsetXOverride { return v }
        switch cs.heightBucket {
        case .short: return attackBadgeOffsetXShort
        case .medium: return attackBadgeOffsetXMedium
        case .tall: return attackBadgeOffsetXTall
        }
    }
    func attackBadgeOffsetY(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2AttackBadgeOffsetYOverride { return v }
        if queueSlot >= 1, let v = cs.waitingAttackBadgeOffsetYOverride { return v }
        if let v = cs.attackBadgeOffsetYOverride { return v }
        switch cs.heightBucket {
        case .short: return attackBadgeOffsetYShort
        case .medium: return attackBadgeOffsetYMedium
        case .tall: return attackBadgeOffsetYTall
        }
    }

    // Inspect Banner Bottle Size (potion number graphic in banner)
    var bannerBottleSize: Double = 54.38297629356384
    var bannerBottleOffsetX: Double = 1.8617033958435059
    var bannerBottleOffsetY: Double = 0.0
    var bannerBottleNumberSize: Double = 30.0
    var bannerBottleNumberOffsetX: Double = 1.3297855854034424
    var bannerBottleNumberOffsetY: Double = 8.865249156951904

    // MARK: - Head Anchor Defaults (May 22, 2026)
    // Fraction of the rendered image where each bucket's head sits.
    // Y: 0.0 = top of image, 1.0 = bottom. X: 0.0 = left edge, 1.0 = right, 0.5 = center.
    var headAnchorYShort: Double = 0.20
    var headAnchorYMedium: Double = 0.15
    var headAnchorYTall: Double = 0.10
    var headAnchorXShort: Double = 0.37765955924987793
    var headAnchorXMedium: Double = 0.5372340679168701
    var headAnchorXTall: Double = 0.5647163391113281

    func headAnchorY(for characterId: String) -> Double {
        let cs = characterScale(for: characterId)
        if let override = cs.headAnchorYOverride { return override }
        switch cs.heightBucket {
        case .short: return headAnchorYShort
        case .medium: return headAnchorYMedium
        case .tall: return headAnchorYTall
        }
    }

    func headAnchorX(for characterId: String) -> Double {
        switch characterScale(for: characterId).heightBucket {
        case .short: return headAnchorXShort
        case .medium: return headAnchorXMedium
        case .tall: return headAnchorXTall
        }
    }

    private init() {
        // MARK: - Queue Permutations (Custom 3-Character Spacing)
        // Evening round arrangements to prevent character overlaps
        
        // Arrangement 1: ardo → wendelina → crispin
        addPermutation(
            for: ["ardo", "wendelina", "crispin"],
            xPositions: [0.47, 0.59, 0.87],
            yPositions: [0.48, 0.56, 0.57]
        )

        // Arrangement 2: crispin → ardo → wendelina
        addPermutation(
            for: ["crispin", "ardo", "wendelina"],
            xPositions: [0.49, 0.74, 0.88],
            yPositions: [0.50, 0.55, 0.55]
        )

        // Arrangement 3: crispin → wendelina → ardo
        addPermutation(
            for: ["crispin", "wendelina", "ardo"],
            xPositions: [0.48, 0.70, 0.88],
            yPositions: [0.50, 0.55, 0.55]
        )

        // Arrangement 4: wendelina → ardo → crispin
        addPermutation(
            for: ["wendelina", "ardo", "crispin"],
            xPositions: [0.44, 0.66, 0.87],
            yPositions: [0.50, 0.55, 0.57]
        )

        // Arrangement 5: wendelina → crispin → ardo
        addPermutation(
            for: ["wendelina", "crispin", "ardo"],
            xPositions: [0.44, 0.66, 0.88],
            yPositions: [0.50, 0.56, 0.55]
        )

        // ── Day 2 Evening (hexa_mott + ironhilde + ardo) arrangements ──

        // Arrangement 6: hexa_mott → ironhilde → ardo
        addPermutation(
            for: ["hexa_mott", "ironhilde", "ardo"],
            xPositions: [0.48, 0.70, 0.88],
            yPositions: [0.48, 0.55, 0.55]
        )

        // Arrangement 7: ironhilde → ardo → hexa_mott
        addPermutation(
            for: ["ironhilde", "ardo", "hexa_mott"],
            xPositions: [0.48, 0.72, 0.88],
            yPositions: [0.48, 0.55, 0.55]
        )

        // Arrangement 8: ironhilde → hexa_mott → ardo
        addPermutation(
            for: ["ironhilde", "hexa_mott", "ardo"],
            xPositions: [0.48, 0.75, 0.88],
            yPositions: [0.48, 0.55, 0.55]
        )

        applyDefaultHeightBuckets()
    }

    private func applyDefaultHeightBuckets() {
        let defaults: [(String, CustomerHeightBucket)] = [
            ("mildred", .medium),
            ("tomik", .tall),
            ("pemberton", .short),
            ("greta", .short),
            ("wendelina", .medium),
            ("crispin", .medium),
            ("ardo", .short),
            ("grimdrek", .tall),
        ]
        for (key, bucket) in defaults {
            var scale = perCharacterScales[key] ?? CharacterScale()
            scale.heightBucket = bucket
            perCharacterScales[key] = scale
        }
        applyTunedCharacterScales()
    }

    /// Seeds per-character scale values tuned through the layout editor.
    /// Updated May 24, 2026 from Copy Layout Values export (post body-follow fix).
    /// Called after bucket assignment so these survive a fresh launch.
    private func applyTunedCharacterScales() {
        // mildred
        var mildred = perCharacterScales["mildred"] ?? CharacterScale()
        mildred.x = -26.241135597229004
        mildred.y = 4.609918594360352
        mildred.waitingWidth = 0.9880319200456142
        mildred.waitingHeight = 0.9880319200456142
        mildred.waitingY = -9.219861030578613
        mildred.hpBadgeSizeOverride = 54.82624113559723
        mildred.hpBadgeOffsetXOverride = -64.99999165534973
        mildred.hpBadgeOffsetYOverride = 10.904252529144287
        mildred.attackBadgeOffsetXOverride = -61.17022633552551
        mildred.attackBadgeOffsetYOverride = 53.98938059806824
        mildred.waitingHpBadgeOffsetXOverride = -68.72339844703674
        mildred.waitingAttackBadgeOffsetXOverride = -67.55320429801941
        mildred.waitingAttackBadgeOffsetYOverride = 43.88299584388733
        perCharacterScales["mildred"] = mildred

        // tomik
        var tomik = perCharacterScales["tomik"] ?? CharacterScale()
        tomik.x = -34.7517728805542
        tomik.y = 10.283684730529785
        tomik.waitingY = -7.446813583374023
        tomik.hpBadgeOffsetXOverride = -76.59577131271362
        tomik.hpBadgeOffsetYOverride = 0.0
        tomik.attackBadgeSizeOverride = 35.40070980787277
        tomik.attackBadgeOffsetXOverride = -77.65957117080688
        tomik.attackBadgeOffsetYOverride = 37.76596784591675
        tomik.waitingHpBadgeSizeOverride = 54.10815745592117
        tomik.waitingHpBadgeOffsetXOverride = -83.51066708564758
        tomik.waitingHpBadgeOffsetYOverride = 1.8617033958435059
        tomik.waitingAttackBadgeOffsetXOverride = -84.57444906234741
        tomik.waitingAttackBadgeOffsetYOverride = 39.09575343132019
        perCharacterScales["tomik"] = tomik

        // greta
        var greta = perCharacterScales["greta"] ?? CharacterScale()
        greta.width = 0.8563829660415649
        greta.height = 0.8563829660415649
        greta.x = -24.822700023651123
        greta.y = 19.5035457611084
        greta.waitingWidth = 0.8882978670299053
        greta.waitingHeight = 0.8882978670299053
        greta.waitingY = 3.9007186889648438
        greta.hpBadgeOffsetXOverride = -60.47873497009277
        greta.hpBadgeOffsetYOverride = 67.81915426254272
        greta.attackBadgeOffsetXOverride = -59.574490785598755
        greta.attackBadgeOffsetYOverride = 95.21276950836182
        greta.waitingHpBadgeOffsetXOverride = -38.1382942199707
        greta.waitingHpBadgeOffsetYOverride = 55.05319833755493
        greta.waitingAttackBadgeOffsetXOverride = -34.57449674606323
        greta.waitingAttackBadgeOffsetYOverride = 89.6276593208313
        perCharacterScales["greta"] = greta

        // wendelina
        var wendelina = perCharacterScales["wendelina"] ?? CharacterScale()
        wendelina.x = -32.97872543334961
        wendelina.y = 3.9007186889648438
        wendelina.waitingWidth = 1.003989353775978
        wendelina.waitingHeight = 1.003989353775978
        wendelina.waitingX = -16.666674613952637
        wendelina.waitingY = -9.929072856903076
        wendelina.waiting2Width = 0.9960106536746025
        wendelina.waiting2Height = 0.9960106536746025
        wendelina.waiting2X = -4.964542388916016
        wendelina.waiting2Y = -6.0283660888671875
        wendelina.hpBadgeOffsetXOverride = -46.914875507354736
        wendelina.hpBadgeOffsetYOverride = 22.606390714645386
        wendelina.attackBadgeOffsetXOverride = -47.34043478965759
        wendelina.attackBadgeOffsetYOverride = 57.4468195438385
        wendelina.waitingHpBadgeSizeOverride = 50.83687901496887
        wendelina.waitingHpBadgeOffsetXOverride = -35.21275520324707
        wendelina.waitingHpBadgeOffsetYOverride = 10.90427041053772
        wendelina.waitingAttackBadgeOffsetXOverride = -40.957456827163696
        wendelina.waitingAttackBadgeOffsetYOverride = 43.351078033447266
        perCharacterScales["wendelina"] = wendelina

        // grimdrek
        var grimdrek = perCharacterScales["grimdrek"] ?? CharacterScale()
        grimdrek.x = -70.92198133468628
        grimdrek.y = 9.219861030578613
        grimdrek.hpBadgeOffsetXOverride = -89.89360928535461
        grimdrek.attackBadgeOffsetXOverride = -87.23403811454773
        grimdrek.attackBadgeOffsetYOverride = 51.063841581344604
        perCharacterScales["grimdrek"] = grimdrek

        // pemberton
        var pemberton = perCharacterScales["pemberton"] ?? CharacterScale()
        pemberton.width = 0.8324467986822128
        pemberton.height = 0.8324467986822128
        pemberton.x = -22.340428829193115
        pemberton.y = 24.11346435546875
        pemberton.waitingWidth = 0.8643616996705532
        pemberton.waitingHeight = 0.8643616996705532
        pemberton.waitingX = -23.049640655517578
        pemberton.waitingY = 5.3191423416137695
        pemberton.hpBadgeSizeOverride = 50.83688169717789
        pemberton.hpBadgeOffsetXOverride = -73.24467301368713
        pemberton.hpBadgeOffsetYOverride = 30.585122108459473
        pemberton.attackBadgeOffsetXOverride = -65.95745086669922
        pemberton.attackBadgeOffsetYOverride = 69.6808397769928
        pemberton.waitingHpBadgeOffsetXOverride = -67.3936128616333
        pemberton.waitingHpBadgeOffsetYOverride = 23.13830852508545
        pemberton.waitingAttackBadgeOffsetXOverride = -63.8297975063324
        pemberton.waitingAttackBadgeOffsetYOverride = 55.85104823112488
        perCharacterScales["pemberton"] = pemberton

        // ardo (waiting2 badge overrides added May 24, 2026)
        var ardo = perCharacterScales["ardo"] ?? CharacterScale()
        ardo.width = 0.9840425699949265
        ardo.height = 0.9840425699949265
        ardo.x = -40.42553901672363
        ardo.y = 8.86523723602295
        ardo.waitingX = -33.33332538604736
        ardo.waitingY = -5.3191423416137695
        ardo.waiting2X = 10.283684730529785
        ardo.waiting2Y = -5.319154262542725
        ardo.hpBadgeOffsetXOverride = -38.1382942199707
        ardo.attackBadgeOffsetXOverride = -35.10639667510986
        ardo.attackBadgeOffsetYOverride = 28.191500902175903
        ardo.waitingHpBadgeOffsetXOverride = -30.691534280776978
        ardo.waitingHpBadgeOffsetYOverride = -26.59572958946228
        ardo.waitingAttackBadgeSizeOverride = 34.28368777036667
        ardo.waitingAttackBadgeOffsetXOverride = -29.25533652305603
        ardo.waitingAttackBadgeOffsetYOverride = 4.521292448043823
        ardo.waiting2HpBadgeOffsetXOverride = -32.287269830703735
        ardo.waiting2AttackBadgeOffsetXOverride = -35.63831448554993
        ardo.waiting2AttackBadgeOffsetYOverride = 8.776617050170898
        perCharacterScales["ardo"] = ardo

        // bram
        var bram = perCharacterScales["bram"] ?? CharacterScale()
        bram.x = -36.8794322013855
        bram.y = 6.382989883422852
        bram.waitingX = -17.02127456665039
        bram.hpBadgeSizeOverride = 47.863384783267975
        bram.hpBadgeOffsetXOverride = -38.936179876327515
        bram.hpBadgeOffsetYOverride = 1.3297855854034424
        bram.attackBadgeOffsetXOverride = -50.00000596046448
        bram.attackBadgeOffsetYOverride = 38.56383562088013
        bram.waitingHpBadgeOffsetXOverride = -49.574482440948486
        bram.waitingHpBadgeOffsetYOverride = 7.712763547897339
        bram.waitingAttackBadgeOffsetYOverride = 41.22340679168701
        perCharacterScales["bram"] = bram

        // crispin
        var crispin = perCharacterScales["crispin"] ?? CharacterScale()
        crispin.width = 1.0319149382412434
        crispin.height = 1.0319149382412434
        crispin.x = -34.04254913330078
        crispin.waitingWidth = 1.0279255546629429
        crispin.waitingHeight = 1.0279255546629429
        crispin.waitingX = -21.631205081939697
        crispin.waitingY = -12.765955924987793
        crispin.waiting2Width = 1.0279255546629429
        crispin.waiting2Height = 1.0279255546629429
        crispin.waiting2X = -16.666674613952637
        crispin.waiting2Y = -16.312062740325928
        crispin.hpBadgeSizeOverride = 54.82624113559723
        crispin.hpBadgeOffsetXOverride = -68.19149851799011
        crispin.hpBadgeOffsetYOverride = 4.521274566650391
        crispin.attackBadgeOffsetXOverride = -61.702126264572144
        crispin.attackBadgeOffsetYOverride = 38.82978558540344
        crispin.waitingHpBadgeOffsetXOverride = -61.80850267410278
        crispin.waitingHpBadgeOffsetYOverride = 5.053192377090454
        crispin.waitingAttackBadgeOffsetXOverride = -58.510637283325195
        crispin.waitingAttackBadgeOffsetYOverride = 41.755324602127075
        perCharacterScales["crispin"] = crispin

        // sister_halla (Day 2)
        var sisterHalla = perCharacterScales["sister_halla"] ?? CharacterScale()
        sisterHalla.x = -34.39716100692749
        sisterHalla.y = 3.5460948944091797
        sisterHalla.waitingY = -9.929072856903076
        sisterHalla.hpBadgeSizeOverride = 49.480496644973755
        sisterHalla.hpBadgeOffsetXOverride = -60.744667053222656
        sisterHalla.hpBadgeOffsetYOverride = 24.202126264572144
        sisterHalla.attackBadgeOffsetXOverride = -59.57447290420532
        sisterHalla.attackBadgeOffsetYOverride = 59.57447290420532
        sisterHalla.waitingHpBadgeOffsetXOverride = -62.87233829498291
        sisterHalla.waitingAttackBadgeOffsetXOverride = -62.7659797668457
        perCharacterScales["sister_halla"] = sisterHalla

        // hexa_mott (Day 2)
        var hexaMott = perCharacterScales["hexa_mott"] ?? CharacterScale()
        hexaMott.x = -46.09929323196411
        hexaMott.y = 5.3191423416137695
        hexaMott.waitingX = -39.0070915222168
        hexaMott.waitingY = -13.120567798614502
        hexaMott.waiting2Y = -10.992908477783203
        hexaMott.hpBadgeSizeOverride = 49.320921301841736
        hexaMott.hpBadgeOffsetXOverride = -56.89948797225952
        hexaMott.hpBadgeOffsetYOverride = -7.446804642677307
        hexaMott.attackBadgeOffsetXOverride = -58.510637283325195
        hexaMott.attackBadgeOffsetYOverride = 26.329797506332397
        hexaMott.waitingHpBadgeOffsetXOverride = -59.559059143066406
        hexaMott.waitingHpBadgeOffsetYOverride = -11.968079209327698
        hexaMott.waitingAttackBadgeOffsetXOverride = -57.4468195438385
        hexaMott.waitingAttackBadgeOffsetYOverride = 23.936176300048828
        perCharacterScales["hexa_mott"] = hexaMott

        // ironhilde (Day 2)
        var ironhilde = perCharacterScales["ironhilde"] ?? CharacterScale()
        ironhilde.width = 0.8962766006588936
        ironhilde.height = 0.8962766006588936
        ironhilde.x = -21.631205081939697
        ironhilde.y = 18.179941177368164
        ironhilde.waitingWidth = 0.8962766006588936
        ironhilde.waitingHeight = 0.8962766006588936
        ironhilde.waitingX = -10.638296604156494
        ironhilde.waitingY = 0.0
        ironhilde.waiting2Width = 0.94015958532691
        ironhilde.waiting2Height = 0.94015958532691
        ironhilde.waiting2X = -10.992908477783203
        ironhilde.waiting2Y = -5.581486225128174
        ironhilde.hpBadgeOffsetXOverride = -72.44680523872375
        ironhilde.hpBadgeOffsetYOverride = -2.6595711708068848
        ironhilde.attackBadgeOffsetXOverride = -65.95745086669922
        ironhilde.waitingHpBadgeOffsetXOverride = -67.65956282615662
        ironhilde.waitingHpBadgeOffsetYOverride = -3.9893656969070435
        ironhilde.waitingAttackBadgeSizeOverride = 35.560282468795776
        ironhilde.waitingAttackBadgeOffsetXOverride = -64.36171531677246
        ironhilde.waitingAttackBadgeOffsetYOverride = 31.914907693862915
        perCharacterScales["ironhilde"] = ironhilde

        // carmilla (Day 2)
        var carmilla = perCharacterScales["carmilla"] ?? CharacterScale()
        carmilla.x = -28.368782997131348
        carmilla.y = 6.382989883422852
        carmilla.waitingX = -3.191494941711426
        carmilla.waitingY = -6.3829779624938965
        carmilla.hpBadgeOffsetXOverride = -73.51064085960388
        carmilla.hpBadgeOffsetYOverride = 35.37234663963318
        carmilla.attackBadgeOffsetXOverride = -73.9361822605133
        carmilla.attackBadgeOffsetYOverride = 73.9361822605133
        carmilla.waitingHpBadgeOffsetXOverride = -77.23402976989746
        carmilla.waitingHpBadgeOffsetYOverride = 23.13830852508545
        carmilla.waitingAttackBadgeOffsetXOverride = -76.59575343132019
        carmilla.waitingAttackBadgeOffsetYOverride = 59.84044075012207
        perCharacterScales["carmilla"] = carmilla

        // royal_envoy (Day 2 boss — position tuned May 24, 2026)
        var royalEnvoy = perCharacterScales["royal_envoy"] ?? CharacterScale()
        royalEnvoy.x = -68.43972206115723
        perCharacterScales["royal_envoy"] = royalEnvoy
    }
    
    // MARK: - 🔒 LOCKED DEFAULTS (May 13, 2026 - Known-Good State)
    
    /// Restores ALL layout values to the locked defaults from May 13, 2026.
    /// Call this method to instantly return to the known-good baseline state.
    /// Usage: PotionShopLayoutConfig.shared.restoreLockedDefaults()
    func restoreLockedDefaults() {
        // Section Heights
        headerPercent = 1.7198581993579865
        scenePercent = 27.27518081665039
        profilePercent = 9.5
        cauldronPercent = 37.2
        previewPercent = 0.0
        trayPercent = 19.3
        
        // Ednar Art
        ednarBaseScale = 0.15
        ednarWidth = 1.0
        ednarHeight = 1.0
        ednarX = 0.0
        ednarY = 0.0
        
        // Customer Scene Base Scale
        customerSceneBaseScale = 2.0
        customerSceneWidth = 1.0
        customerSceneHeight = 1.0
        customerSceneX = 0.0
        customerSceneY = 0.0
        
        // Per-Character Scales (all 14 characters)
        perCharacterScales = [
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
        
        // Cauldron Art
        cauldronWidth = 1.3613475412130356
        cauldronHeight = 1.9335107803344727
        cauldronX = -2.219867706298828
        cauldronY = -34.326231479644775
        
        // Cauldron Bowl
        cauldronBowlScale = 1.3121631294488907
        cauldronBowlX = 44.709229469299316
        cauldronBowlY = 58.0
        
        // Nodes
        nodeScale = 1.8311170041561127
        nodeXOffset = 79.43263053894043
        nodeYOffset = 71.27659320831299
        nodeSpacingMultiplier = 1.0
        
        // Per-Node Offsets (all 12 nodes)
        perNodeOffsets = [
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
        
        // Dice & Tray
        dieScale = 1.405301421880722
        trayOffsetX = 4.609942436218262
        trayOffsetY = 6.2056779861450195
        
        // Brew Zone
        brewZoneX = 0.8424113392829895
        brewZoneY = 0.15010638535022736
        brewZoneWidth = 113.10815364122391
        brewZoneHeight = 95.51772773265839
        showBrewZone = false
        
        // HP / Attack Badges — per-bucket (May 23, 2026 revision 3)
        hpBadgeSizeShort = 50.437946021556854
        hpBadgeOffsetXShort = -32.819151878356934
        hpBadgeOffsetYShort = -8.77659022808075
        hpBadgeSizeMedium = 50.51773101091385
        hpBadgeOffsetXMedium = -82.0212721824646
        hpBadgeOffsetYMedium = 6.3829779624938965
        hpBadgeSizeTall = 52.193264067173004
        hpBadgeOffsetXTall = -171.8085139989853
        hpBadgeOffsetYTall = 13.031923770904541
        attackBadgeSizeShort = 34.28368777036667
        attackBadgeOffsetXShort = -32.97874331474304
        attackBadgeOffsetYShort = 23.404258489608765
        attackBadgeSizeMedium = 36.27836883068085
        attackBadgeOffsetXMedium = -76.06383562088013
        attackBadgeOffsetYMedium = 36.436182260513306
        attackBadgeSizeTall = 36.27836763858795
        attackBadgeOffsetXTall = -153.723406791687
        attackBadgeOffsetYTall = 45.744699239730835
        bannerBottleSize = 54.38297629356384
        bannerBottleOffsetX = 1.8617033958435059
        bannerBottleOffsetY = 0.0
        bannerBottleNumberSize = 30.0
        bannerBottleNumberOffsetX = 1.3297855854034424
        bannerBottleNumberOffsetY = 8.865249156951904

        // Head Anchor Defaults
        headAnchorYShort = 0.20
        headAnchorYMedium = 0.15
        headAnchorYTall = 0.10
        headAnchorXShort = 0.37765955924987793
        headAnchorXMedium = 0.5372340679168701
        headAnchorXTall = 0.5647163391113281
        applyDefaultHeightBuckets()
        
        print("✅ RESTORED LOCKED DEFAULTS (May 13, 2026)")
    }
}
