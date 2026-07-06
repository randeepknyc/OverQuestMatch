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
    var trayPercent: Double = 18.07659387588501
    
    // Header text tuning (June 27, 2026)
    // Composure label: font size and offset from default position
    var headerComposureFontSize: Double = 25.00177276134491
    var headerComposureOffsetX: Double = 16.489362716674805
    var headerComposureOffsetY: Double = 7.375888824462891
    // Focus label: font size and offset from default position
    var headerFocusFontSize: Double = 24.9609934091568
    var headerFocusOffsetX: Double = 259.7872281074524
    var headerFocusOffsetY: Double = -22.76595711708069
    var headerFocusPipSize: Double = 24.0
    var headerFocusLabelOffsetY: Double = 1.7730498313903809
    // Time-of-day icon size and vertical offset
    var headerTodIconSize: Double = 49.44680881500244
    var headerTodIconOffsetY: Double = 16.01063847541809
    // Gear icon size and vertical offset
    var headerGearSize: Double = 26.68085026741028
    var headerGearOffsetY: Double = 16.436169147491455
    // Day label font size and vertical offset (Row 2)
    var headerDayFontSize: Double = 20.57092195749283
    var headerDayOffsetX: Double = 6.702128648757935
    var headerDayOffsetY: Double = 10.904256105422974
    // Composure bar height and vertical offset
    var headerBarHeight: Double = 25.709218978881836
    var headerBarOffsetY: Double = 16.382979154586792

    // ─── Stability fire meter (June 27, 2026) ──────────────────────────
    // Flame positions/sizes under the cauldron. Edited live in the debug
    // menu's "🔥 Fire Meter" panel; exported with the layout values and
    // reset by "Restore Locked Defaults". Arrays are sized to the meter
    // (PotionShopConfig.maxFire); short/extra entries fall back safely.
    var fireMeterSize: Double = 84.68085289001465
    var fireMeterSpacing: Double = 84.00354146957397
    var fireMeterOffsetX: Double = 0
    var fireMeterOffsetY: Double = -19.5035457611084
    var fireMeterFPS: Double = 7
    var fireFlameOffsetsX: [Double] = [0.0, 0.0, 12.765955924987793, 13.120555877685547, -1.7730474472045898]
    var fireFlameOffsetsY: [Double] = [0.0, 4.964542388916016, 0.0, 0.0, -9.574472904205322]
    var fireFlameScales:   [Double] = [1.0, 0.9976063549518586, 1.0, 1.0, 1.1268616586923599]

    /// Per-flame safe accessors (arrays may be shorter/longer than maxFire).
    func fireOffsetXAt(_ i: Int) -> Double { i < fireFlameOffsetsX.count ? fireFlameOffsetsX[i] : 0 }
    func fireOffsetYAt(_ i: Int) -> Double { i < fireFlameOffsetsY.count ? fireFlameOffsetsY[i] : 0 }
    func fireScaleAt(_ i: Int)   -> Double { i < fireFlameScales.count   ? fireFlameScales[i]   : 1 }
    /// Default centered-row X for flame `i` of `shown` flames.
    func fireDefaultRowX(_ i: Int, shown: Int) -> Double {
        (Double(i) - Double(shown - 1) / 2.0) * fireMeterSpacing
    }
    /// Make sure the per-flame arrays are at least maxFire long (called when
    /// the editor opens, so binding to each flame's slider is always safe).
    func ensureFireArrays() {
        let n = PotionShopConfig.maxFire
        func pad(_ a: [Double], _ fill: Double) -> [Double] {
            var r = a; if r.count < n { r += Array(repeating: fill, count: n - r.count) }; return r
        }
        fireFlameOffsetsX = pad(fireFlameOffsetsX, 0)
        fireFlameOffsetsY = pad(fireFlameOffsetsY, 0)
        fireFlameScales   = pad(fireFlameScales, 1)
    }
    /// Reset ONLY the fire-meter values (the panel's reset button).
    func resetFireMeter() {
        fireMeterSize = 84.68085289001465; fireMeterSpacing = 84.00354146957397
        fireMeterOffsetX = 0; fireMeterOffsetY = -19.5035457611084; fireMeterFPS = 7
        fireFlameOffsetsX = [0.0, 0.0, 12.765955924987793, 13.120555877685547, -1.7730474472045898]
        fireFlameOffsetsY = [0.0, 4.964542388916016, 0.0, 0.0, -9.574472904205322]
        fireFlameScales   = [1.0, 0.9976063549518586, 1.0, 1.0, 1.1268616586923599]
    }

    // Ednar Art (ACTUAL SIZE - May 11, 2026; pose re-baked June 26, 2026)
    // All images drawn at same canvas size (1536×1024) and displayed uniformly
    // Scale multipliers at 1.0 = no distortion, images appear at natural proportions
    var ednarBaseScale: Double = 0.15  // Base scale to make 1536×1024 images visible
    var ednarWidth: Double = 1.3431382966041565
    var ednarHeight: Double = 1.3351063802838326
    var ednarX: Double = 35.81562042236328
    var ednarY: Double = -10.638296604156494

    // Heal/shield preview bubble position (June 26, 2026). Moves the little
    // bubble that shows +heal / 🛡shield during a brew, relative to Ednar's
    // frame corner. Tunable live in the editor's Ednar tab.
    var ednarBubbleX: Double = 3.758859634399414
    var ednarBubbleY: Double = 111.77303791046143

    // Background image opacity (June 26, 2026). 1.0 = fully opaque (default),
    // 0.0 = invisible. Applies to the scene background (bgtest1 / customerbg).
    var bgTestOpacity: Double = 0.8463829660415649

    // June 26, 2026 — debug: fade the whole character per slot. 1.0 = 100%.
    // Slot 1 = active (front) customer; Slot 2 = waiting (behind) customers.
    var slot1Opacity: Double = 1.0
    var slot2Opacity: Double = 1.0
    
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
        // Template buckets (May 25, 2026) — for Day 3 auto-layout characters.
        // Existing 14 characters keep using .short/.medium/.tall (with their
        // legacy head-anchor fractions). Day 3 guide_* characters use these.
        case superShort   // head box y 768–992 (gnomes, children)
        case tallHat      // head box y 96–480 (wizards, witches with pointy hats)
        case floater      // head box y 384–640, feet at y=1260 not 1440 (ghosts)
    }

    // Width bucket (May 25, 2026) — used by Day 3 auto-layout to size each
    // customer's horizontal "slot" in the queue. Existing 14 characters
    // default to .medium and don't use this; Day 3 guide_* characters set it.
    enum CustomerWidthBucket: String, Codable, CaseIterable {
        case skinny       // narrow build (slim mages, old men)
        case medium       // average humans
        case wide         // bulky figures (ogres, sumo, full plate)
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
        // Per-character X anchor override (May 25, 2026). Mostly used by
        // template chars that are centered (0.5); existing 14 chars don't set it.
        var headAnchorXOverride: Double? = nil

        // Width bucket (May 25, 2026): used by Day 3 auto-layout to compute
        // each customer's horizontal slot width. Defaults to .medium so old
        // characters work as before; Day 3 guide_* chars set this explicitly.
        var widthBucket: CustomerWidthBucket = .medium

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
    
    // Nodes (JULY 2, 2026 afternoon: tuned in the layout editor and baked
    // in — per-node nudges were folded into the chalk9 board coordinates
    // in PotionShopModels.swift, so perNodeOffsets start clean at zero)
    var nodeScale: Double = 1.3844081982970238
    var nodeXOffset: Double = 74.82268810272217
    var nodeYOffset: Double = 75.5319356918335
    var nodeSpacingMultiplier: Double = 1.7340425252914429  // ⚠️ EXPERIMENTAL: Changes visual spacing between nodes (does NOT affect boost reach)
    
    // Per-Node Fine-Tuning (JULY 2, 2026 — sized to the board library's
    // biggest board via PotionShopBoard.maxNodeCount; currently 9).
    // The old 12-node dialed offsets were retired with the old board —
    // the new chalk9 positions live in PotionShopModels.swift and start
    // clean at zero offset. Fine-tune per node in the layout editor.
    var perNodeOffsets: [CGPoint] = Array(repeating: .zero, count: PotionShopBoard.maxNodeCount)

    // Per-Node SIZE (JULY 2, 2026) — individual size multiplier for each
    // node, on top of the global Node Scale. 1.0 = normal. Edited in the
    // layout editor's Fine Tune tab ("Size ×" slider). Everything on the
    // node scales together: chalk art, glow frames, the placed die, and
    // the tap/hit area — so a bigger node still hugs its die correctly.
    var perNodeScales: [Double] = Array(repeating: 1.0, count: PotionShopBoard.maxNodeCount)

    /// Safe read of a node's size multiplier (1.0 if out of range).
    func nodeScaleAt(_ index: Int) -> Double {
        guard index >= 0, index < perNodeScales.count else { return 1.0 }
        return perNodeScales[index]
    }

    // GLOBAL Node Size (JULY 2, 2026 evening) — resizes EVERY node
    // uniformly, multiplied on top of the per-node sizes. 1.0 = normal.
    // Lives in Fine Tune ("All Nodes Size ×") next to the per-node slider.
    var nodeGlobalScale: Double = 1.0

    // OCCUPIED Node Growth (JULY 2, 2026 night; semantics FIXED same
    // night) — RELATIVE growth applied while a die is placed on a node,
    // on top of whatever the empty size is. 1.0 = no change on placement
    // (works the same no matter what "All Nodes Size ×" is). 1.15 = the
    // node springs 15% bigger when a die lands and springs back when it
    // leaves — art, glow, and die all together.
    var nodeOccupiedScale: Double = 1.2491134881973267  // BAKED July 2 (user-tuned)
    
    // Helper method to reset all per-node offsets
    func resetAllNodeOffsets() {
        perNodeOffsets = Array(repeating: .zero, count: PotionShopBoard.maxNodeCount)
        perNodeScales = Array(repeating: 1.0, count: PotionShopBoard.maxNodeCount)
        nodeGlobalScale = 1.0
        nodeOccupiedScale = 1.2491134881973267
    }

    // ─── CHALK CONNECTION LINES (JULY 2, 2026) ─────────────────────
    // How the lines between nodes are shown. Three modes:
    //   "always" — lines permanently visible (old behavior)
    //   "hidden" — never drawn (boost reach still works invisibly)
    //   "smart"  — invisible until they matter: fade in while you're
    //              dragging/placing dice, stay while dice are on the
    //              board, and light up during the brew.
    // Changed via Debug Menu → Layout Tools → Chalk Lines.
    // Persists across app launches (saved to the device).
    var nodeLineModeRaw: String = UserDefaults.standard.string(forKey: "ps_nodeLineMode") ?? "smart" {
        didSet { UserDefaults.standard.set(nodeLineModeRaw, forKey: "ps_nodeLineMode") }
    }

    // ─── LIVE BACKGROUND COLOR (JULY 2, 2026) ────────────────────────
    // Debug Menu → Layout Tools → "Background Color" picker. Lets you
    // try background colors LIVE, no rebuild. Stored as a hex string
    // ("" = off → normal shop_background image / parchment fallback).
    // When set, the flat color REPLACES the background entirely (image
    // included) so what you see is exactly the color. Persists across
    // launches; "Reset" in the menu clears it. Rides Copy Layout Values
    // so a final pick can be baked as the new default.
    var bgColorHex: String = UserDefaults.standard.string(forKey: "ps_bgColorHex") ?? "" {
        didSet { UserDefaults.standard.set(bgColorHex, forKey: "ps_bgColorHex") }
    }

    /// JULY 2, 2026: nudged by the header's secret 7-tap unlock so views
    /// showing the debug gear (GameView's cauldron corner) re-evaluate
    /// PotionShopDebugAccess.isAvailable. Not persisted; just a signal.
    var debugGearBump: Int = 0

    /// The override as a Color (nil = no override, use image/parchment).
    var bgColorOverride: Color? {
        guard !bgColorHex.isEmpty else { return nil }
        return PotionShopLayoutConfig.color(fromHex: bgColorHex)
    }

    /// "RRGGBB" hex → Color (nil for junk input).
    static func color(fromHex hex: String) -> Color? {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let v = UInt64(h, radix: 16) else { return nil }
        return Color(
            red: Double((v >> 16) & 0xFF) / 255.0,
            green: Double((v >> 8) & 0xFF) / 255.0,
            blue: Double(v & 0xFF) / 255.0
        )
    }

    /// Color → "RRGGBB" hex (sRGB).
    static func hex(from color: Color) -> String {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X",
                      Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)))
    }
    
    // Dice & Tray
    var dieScale: Double = 1.405301421880722      // Controls NODE size (via effectiveNodeScale)
    var trayDieScale: Double = 1.4970566853880882   // Controls TRAY dice size only
    var trayOffsetX: Double = -3.5460829734802246
    var trayOffsetY: Double = 31.028389930725098
    
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
        case .short, .superShort: return hpBadgeSizeShort
        case .medium, .floater: return hpBadgeSizeMedium
        case .tall, .tallHat: return hpBadgeSizeTall
        }
    }
    func hpBadgeOffsetX(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2HpBadgeOffsetXOverride { return v }
        if queueSlot >= 1, let v = cs.waitingHpBadgeOffsetXOverride { return v }
        if let v = cs.hpBadgeOffsetXOverride { return v }
        switch cs.heightBucket {
        case .short, .superShort: return hpBadgeOffsetXShort
        case .medium, .floater: return hpBadgeOffsetXMedium
        case .tall, .tallHat: return hpBadgeOffsetXTall
        }
    }
    func hpBadgeOffsetY(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2HpBadgeOffsetYOverride { return v }
        if queueSlot >= 1, let v = cs.waitingHpBadgeOffsetYOverride { return v }
        if let v = cs.hpBadgeOffsetYOverride { return v }
        switch cs.heightBucket {
        case .short, .superShort: return hpBadgeOffsetYShort
        case .medium, .floater: return hpBadgeOffsetYMedium
        case .tall, .tallHat: return hpBadgeOffsetYTall
        }
    }
    func attackBadgeSize(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2AttackBadgeSizeOverride { return v }
        if queueSlot >= 1, let v = cs.waitingAttackBadgeSizeOverride { return v }
        if let v = cs.attackBadgeSizeOverride { return v }
        switch cs.heightBucket {
        case .short, .superShort: return attackBadgeSizeShort
        case .medium, .floater: return attackBadgeSizeMedium
        case .tall, .tallHat: return attackBadgeSizeTall
        }
    }
    func attackBadgeOffsetX(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2AttackBadgeOffsetXOverride { return v }
        if queueSlot >= 1, let v = cs.waitingAttackBadgeOffsetXOverride { return v }
        if let v = cs.attackBadgeOffsetXOverride { return v }
        switch cs.heightBucket {
        case .short, .superShort: return attackBadgeOffsetXShort
        case .medium, .floater: return attackBadgeOffsetXMedium
        case .tall, .tallHat: return attackBadgeOffsetXTall
        }
    }
    func attackBadgeOffsetY(for characterId: String, queueSlot: Int = 0) -> Double {
        let cs = characterScale(for: characterId)
        if queueSlot >= 2, let v = cs.waiting2AttackBadgeOffsetYOverride { return v }
        if queueSlot >= 1, let v = cs.waitingAttackBadgeOffsetYOverride { return v }
        if let v = cs.attackBadgeOffsetYOverride { return v }
        switch cs.heightBucket {
        case .short, .superShort: return attackBadgeOffsetYShort
        case .medium, .floater: return attackBadgeOffsetYMedium
        case .tall, .tallHat: return attackBadgeOffsetYTall
        }
    }

    // Inspect Banner Bottle Size (potion number graphic in banner)
    var bannerBottleSize: Double = 54.38297629356384
    var bannerBottleOffsetX: Double = 1.8617033958435059
    var bannerBottleOffsetY: Double = 0.0
    var bannerBottleNumberSize: Double = 30.0
    var bannerBottleNumberOffsetX: Double = 1.3297855854034424
    var bannerBottleNumberOffsetY: Double = 8.865249156951904

    // JULY 3, 2026: extra Y nudge for the banner number ONLY while it's
    // showing the customer's ATTACK value (the black number on
    // potion_bottle_atk). Added ON TOP of bannerBottleNumberOffsetY.
    // Negative = up, positive = down. HP and damage numbers unaffected.
    var bannerAtkNumberExtraY: Double = -9.0

    // MARK: - Head Anchor Defaults (May 22, 2026)
    // Fraction of the rendered image where each bucket's head sits.
    // Y: 0.0 = top of image, 1.0 = bottom. X: 0.0 = left edge, 1.0 = right, 0.5 = center.
    var headAnchorYShort: Double = 0.20
    var headAnchorYMedium: Double = 0.15
    var headAnchorYTall: Double = 0.10
    var headAnchorXShort: Double = 0.37765955924987793
    var headAnchorXMedium: Double = 0.5372340679168701
    var headAnchorXTall: Double = 0.5647163391113281

    // Template head anchors (May 25, 2026) — for Day 3 guide_* characters
    // drawn against the new 1024×1536 safe-zone template. Head center Y is
    // (headBoxY + headBoxH/2) / 1536. X is always 0.5 (centered).
    var headAnchorYSuperShort: Double = 0.573    // head center y=880 / 1536
    var headAnchorYTallHat: Double = 0.188       // head center y=288 / 1536
    var headAnchorYFloater: Double = 0.333       // head center y=512 / 1536

    // MARK: - Auto-Layout Values (May 25, 2026 — Day 3 only)
    //
    // These drive PotionShopAutoQueueLayout for flex days (Day 3+). Tunable
    // via the Layout Editor → "🎲 Auto-Layout (Day 3)" section. Changing
    // these does NOT affect Day 1/2 (they use hand-tuned permutations).

    /// X-fraction where the active customer sits (closest to Ednar).
    var autoLayoutStartX: Double = 0.45
    /// X-fraction where the back-of-line customer sits.
    var autoLayoutEndX: Double = 0.82
    /// Y-fraction for the active customer.
    var autoLayoutYActive: Double = 0.48
    /// Y-fraction for waiters (queue[1+]). Same as active = feet line up.
    var autoLayoutYWaiting: Double = 0.48
    /// Scale of the active customer (queue[0]).
    var autoLayoutScaleActive: Double = 1.0
    /// Scale of waiting1 (queue[1]). Smaller = depth perspective.
    var autoLayoutScaleWaiting1: Double = 0.85
    /// Scale of waiting2 (queue[2]).
    var autoLayoutScaleWaiting2: Double = 0.75

    /// Relative slot widths per width bucket.
    var autoLayoutWidthWeightSkinny: Double = 1.0
    var autoLayoutWidthWeightMedium: Double = 1.4
    var autoLayoutWidthWeightWide: Double = 2.0

    /// Per-height-bucket Y micro-adjustment (added to the base Y).
    var autoLayoutYAdjustSuperShort: Double = 0.0
    var autoLayoutYAdjustShort: Double = 0.0
    var autoLayoutYAdjustMedium: Double = 0.0
    var autoLayoutYAdjustTall: Double = 0.0
    var autoLayoutYAdjustTallHat: Double = 0.0
    var autoLayoutYAdjustFloater: Double = -0.05  // floaters sit slightly higher

    // MARK: - Feet-Anchor Mode (May 30, 2026 — Day 3 Round 2 only)
    //
    // When a round has useFeetAnchor=true, characters are positioned so their
    // FEET (bottom of image) land on a fixed floor-Y per slot. Per-character
    // waitingY/waiting2Y offsets are skipped in this mode. Per-bucket scale
    // multipliers below let you size all chars of a bucket consistently.

    /// Floor Y-fraction for active slot (queue[0]). Bottom of image lands here.
    var autoLayoutFeetYActive: Double = 0.902404248714447
    /// Floor Y-fraction for waiting1 slot (queue[1]).
    var autoLayoutFeetYWaiting1: Double = 0.8055922091007233
    /// Floor Y-fraction for waiting2 slot (queue[2]).
    var autoLayoutFeetYWaiting2: Double = 0.8780567944049835

    /// Per-height-bucket scale multiplier (multiplied with per-slot scale).
    /// Only applied in feet-anchor mode.
    var autoLayoutBucketScaleSuperShort: Double = 1.0
    var autoLayoutBucketScaleShort: Double = 1.0039893984794617
    var autoLayoutBucketScaleMedium: Double = 1.0718085169792175
    var autoLayoutBucketScaleTall: Double = 1.0
    var autoLayoutBucketScaleTallHat: Double = 1.0
    var autoLayoutBucketScaleFloater: Double = 1.0

    // MARK: - Per-Slot Templates (feet-anchor mode, May 30, 2026)
    //
    // Global width/height/x/y defaults for each queue slot in feet-anchor
    // mode. Any character standing in active/waiting1/waiting2 inherits
    // these as a base. Per-character width/height MULTIPLY on top; per-
    // character X/Y ADD on top (as offsets). Lets you set "where everyone
    // stands" per slot with optional per-character fine-tuning.
    //
    // Defaults seeded May 30, 2026 from tuned R2 values for octo/girl/skull.

    var autoLayoutActiveWidth: Double = 1.0
    var autoLayoutActiveHeight: Double = 1.0
    var autoLayoutActiveX: Double = -5.3195953369140625
    var autoLayoutActiveY: Double = 14.893698692321777

    var autoLayoutWaiting1Width: Double = 1.0
    var autoLayoutWaiting1Height: Double = 1.0
    var autoLayoutWaiting1X: Double = -11.440432071685791
    var autoLayoutWaiting1Y: Double = 37.58831024169922  // BAKED July 3 (user-tuned)

    var autoLayoutWaiting2Width: Double = 1.0
    var autoLayoutWaiting2Height: Double = 1.0
    var autoLayoutWaiting2X: Double = 2.482271194458008
    var autoLayoutWaiting2Y: Double = 2.4822235107421875

    /// Uniform scale per slot in feet-anchor mode. Multiplies BOTH width and
    /// height of every character in that slot (shortcut vs tweaking W and H
    /// separately). 1.0 = no extra scaling.
    /// DEPRECATED (May 31, 2026): feet-anchor mode now uses the bucket-per-slot
    /// matrix below. Kept for non-feet-anchor compatibility but not applied.
    var autoLayoutSlotScaleActive: Double = 1.0
    var autoLayoutSlotScaleWaiting1: Double = 1.0
    var autoLayoutSlotScaleWaiting2: Double = 1.0

    // MARK: - Bucket-per-Slot Size Matrix (May 31, 2026 — feet-anchor mode)
    //
    // 6 height buckets × 3 slots = 18 size values. Each cell is the final
    // scale applied to characters of that bucket in that slot. Replaces the
    // tangled stack of per-slot scale, slot uniform, slot W/H, and bucket
    // scale layers. Perspective in stylized 2D isn't pure math — each cell
    // can be tuned independently for what the eye reads as "right."
    //
    // Defaults seed depth perspective: active 1.0, waiting1 0.85, waiting2 0.75.

    // MARK: - Per-cell (slot × height × width) overrides (June 1, 2026)
    //
    // 54 possible cells = 3 slots × 6 heights × 3 widths. Each can hold an
    // optional size/x/y override. When all are nil, falls back to the 18-cell
    // matrix below (size) and slot fine-tune X/Y. Lets you tune e.g.
    // (waiting1, medium, skinny) independently from (waiting1, medium, wide).

    struct BucketCellKey: Hashable, Codable {
        var slot: Int  // 0=active, 1=waiting1, 2=waiting2
        var heightRaw: String
        var widthRaw: String
    }
    struct BucketCell: Codable, Equatable {
        var size: Double?
        var x: Double?
        var y: Double?
    }

    /// Sparse per-cell overrides. Most keys absent → matrix + slot fine-tune
    /// applies. Mutating triggers Observable update via property write.
    /// BAKED July 3 (user-tuned): waiting-1 medium·medium characters sit
    /// 34.7pt left of the slot default.
    var bucketCellOverrides: [BucketCellKey: BucketCell] = [
        BucketCellKey(slot: 1, heightRaw: "medium", widthRaw: "medium"):
            BucketCell(size: nil, x: -34.68085527420044, y: nil)
    ]

    func bucketCellKey(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket) -> BucketCellKey {
        BucketCellKey(slot: slot, heightRaw: String(describing: height), widthRaw: String(describing: width))
    }

    /// Read the override cell for a (slot, height, width). Returns
    /// BucketCell with all-nil fields if none was set.
    func bucketCell(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket) -> BucketCell {
        bucketCellOverrides[bucketCellKey(slot: slot, height: height, width: width)] ?? BucketCell()
    }

    /// Set one field of a cell override (size, x, or y).
    func setBucketCellSize(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket, size: Double) {
        let key = bucketCellKey(slot: slot, height: height, width: width)
        var cell = bucketCellOverrides[key] ?? BucketCell()
        cell.size = size
        bucketCellOverrides[key] = cell
    }
    func setBucketCellX(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket, x: Double) {
        let key = bucketCellKey(slot: slot, height: height, width: width)
        var cell = bucketCellOverrides[key] ?? BucketCell()
        cell.x = x
        bucketCellOverrides[key] = cell
    }
    func setBucketCellY(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket, y: Double) {
        let key = bucketCellKey(slot: slot, height: height, width: width)
        var cell = bucketCellOverrides[key] ?? BucketCell()
        cell.y = y
        bucketCellOverrides[key] = cell
    }

    /// Resolved size for the given (slot, height, width) — cell override if
    /// set, otherwise the legacy 6×3 matrix value.
    func resolvedBucketSize(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket) -> Double {
        if let s = bucketCell(slot: slot, height: height, width: width).size {
            return s
        }
        return bucketSize(slotIndex: slot, bucket: height)
    }

    /// Resolved X offset for the cell (defaults to 0 if no override).
    func resolvedCellX(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket) -> Double {
        bucketCell(slot: slot, height: height, width: width).x ?? 0
    }
    /// Resolved Y offset for the cell (defaults to 0 if no override).
    func resolvedCellY(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket) -> Double {
        bucketCell(slot: slot, height: height, width: width).y ?? 0
    }

    // MARK: - Per-(height × width) HP-badge overrides (June 3, 2026 — refactored)
    //
    // Keyed by (height × width) only — slot-independent. The HP badge is
    // already scaled with the character via the per-slot scale multiplier
    // at render time, so size/X/Y offsets are character-shape-driven, not
    // slot-driven. 6 heights × 3 widths = 18 possible cells (sparse).

    struct BucketKeyHW: Hashable, Codable {
        var heightRaw: String
        var widthRaw: String
    }
    struct BucketHpBadgeCell: Codable, Equatable {
        var size: Double?
        var x: Double?
        var y: Double?
    }

    var bucketHpBadgeOverrides: [BucketKeyHW: BucketHpBadgeCell] = [:]

    /// Per-slot HP badge overrides (June 3, 2026 — added on top of HxW base).
    /// Takes precedence over `bucketHpBadgeOverrides` field-by-field when set.
    /// Use this when a specific (slot, height, width) needs a different
    /// position/size than the shared HxW base.
    var bucketHpBadgeSlotOverrides: [BucketCellKey: BucketHpBadgeCell] = [:]

    func bucketHpBadgeKey(height: CustomerHeightBucket, width: CustomerWidthBucket) -> BucketKeyHW {
        BucketKeyHW(heightRaw: String(describing: height), widthRaw: String(describing: width))
    }

    func bucketHpBadgeCell(height: CustomerHeightBucket, width: CustomerWidthBucket) -> BucketHpBadgeCell {
        bucketHpBadgeOverrides[bucketHpBadgeKey(height: height, width: width)] ?? BucketHpBadgeCell()
    }

    /// Read the per-slot HP badge override cell. Returns all-nil cell if none set.
    func bucketHpBadgeSlotCell(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket) -> BucketHpBadgeCell {
        bucketHpBadgeSlotOverrides[bucketCellKey(slot: slot, height: height, width: width)] ?? BucketHpBadgeCell()
    }

    // Shared HxW setters
    func setHpBadgeCellSize(height: CustomerHeightBucket, width: CustomerWidthBucket, size: Double) {
        let key = bucketHpBadgeKey(height: height, width: width)
        var cell = bucketHpBadgeOverrides[key] ?? BucketHpBadgeCell()
        cell.size = size
        bucketHpBadgeOverrides[key] = cell
    }
    func setHpBadgeCellX(height: CustomerHeightBucket, width: CustomerWidthBucket, x: Double) {
        let key = bucketHpBadgeKey(height: height, width: width)
        var cell = bucketHpBadgeOverrides[key] ?? BucketHpBadgeCell()
        cell.x = x
        bucketHpBadgeOverrides[key] = cell
    }
    func setHpBadgeCellY(height: CustomerHeightBucket, width: CustomerWidthBucket, y: Double) {
        let key = bucketHpBadgeKey(height: height, width: width)
        var cell = bucketHpBadgeOverrides[key] ?? BucketHpBadgeCell()
        cell.y = y
        bucketHpBadgeOverrides[key] = cell
    }

    // Per-slot setters — writes to bucketHpBadgeSlotOverrides which takes
    // precedence over the HxW base at resolve time.
    func setHpBadgeSlotCellSize(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket, size: Double) {
        let key = bucketCellKey(slot: slot, height: height, width: width)
        var cell = bucketHpBadgeSlotOverrides[key] ?? BucketHpBadgeCell()
        cell.size = size
        bucketHpBadgeSlotOverrides[key] = cell
    }
    func setHpBadgeSlotCellX(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket, x: Double) {
        let key = bucketCellKey(slot: slot, height: height, width: width)
        var cell = bucketHpBadgeSlotOverrides[key] ?? BucketHpBadgeCell()
        cell.x = x
        bucketHpBadgeSlotOverrides[key] = cell
    }
    func setHpBadgeSlotCellY(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket, y: Double) {
        let key = bucketCellKey(slot: slot, height: height, width: width)
        var cell = bucketHpBadgeSlotOverrides[key] ?? BucketHpBadgeCell()
        cell.y = y
        bucketHpBadgeSlotOverrides[key] = cell
    }

    /// Resolved HP badge SIZE. Lookup order:
    ///   1. per-slot override (bucketHpBadgeSlotOverrides[slot · H · W])
    ///   2. shared HxW override (bucketHpBadgeOverrides[H · W])
    ///   3. legacy per-bucket hpBadgeSize value
    func resolvedHpBadgeSize(height: CustomerHeightBucket, width: CustomerWidthBucket, characterId: String, slotForLegacy: Int) -> Double {
        if let s = bucketHpBadgeSlotCell(slot: slotForLegacy, height: height, width: width).size {
            return s
        }
        if let s = bucketHpBadgeCell(height: height, width: width).size {
            return s
        }
        return hpBadgeSize(for: characterId, queueSlot: slotForLegacy)
    }
    func resolvedHpBadgeX(height: CustomerHeightBucket, width: CustomerWidthBucket, characterId: String, slotForLegacy: Int) -> Double {
        if let x = bucketHpBadgeSlotCell(slot: slotForLegacy, height: height, width: width).x {
            return x
        }
        if let x = bucketHpBadgeCell(height: height, width: width).x {
            return x
        }
        return hpBadgeOffsetX(for: characterId, queueSlot: slotForLegacy)
    }
    func resolvedHpBadgeY(height: CustomerHeightBucket, width: CustomerWidthBucket, characterId: String, slotForLegacy: Int) -> Double {
        if let y = bucketHpBadgeSlotCell(slot: slotForLegacy, height: height, width: width).y {
            return y
        }
        if let y = bucketHpBadgeCell(height: height, width: width).y {
            return y
        }
        return hpBadgeOffsetY(for: characterId, queueSlot: slotForLegacy)
    }

    // MARK: - HP badge tier introspection (June 12, 2026 — editor tier dots)
    //
    // "Where is this value coming from?" support for the layout editor.
    // Each HP badge field (size/x/y) resolves slot-cell → shared-cell →
    // legacy; these helpers report WHICH tier is currently winning, and
    // can clear the winning tier so the value falls back one level.
    // (Repeatedly tapping the editor's ⊘ button walks down the chain.)

    enum HpBadgeField { case size, x, y }
    enum HpBadgeTierSource { case slotCell, sharedCell, legacy }

    func hpBadgeTierSource(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket, field: HpBadgeField) -> HpBadgeTierSource {
        let slotCell = bucketHpBadgeSlotCell(slot: slot, height: height, width: width)
        let shared = bucketHpBadgeCell(height: height, width: width)
        switch field {
        case .size:
            if slotCell.size != nil { return .slotCell }
            if shared.size != nil { return .sharedCell }
        case .x:
            if slotCell.x != nil { return .slotCell }
            if shared.x != nil { return .sharedCell }
        case .y:
            if slotCell.y != nil { return .slotCell }
            if shared.y != nil { return .sharedCell }
        }
        return .legacy
    }

    /// Clears the WINNING tier's entry for one field. slot-cell first, then
    /// shared H×W. No-op when already at legacy. Empty cells are removed
    /// from their dictionary so the export stays clean.
    func clearWinningHpBadgeTier(slot: Int, height: CustomerHeightBucket, width: CustomerWidthBucket, field: HpBadgeField) {
        let slotKey = bucketCellKey(slot: slot, height: height, width: width)
        if var cell = bucketHpBadgeSlotOverrides[slotKey] {
            let had: Bool
            switch field {
            case .size: had = cell.size != nil; cell.size = nil
            case .x:    had = cell.x != nil;    cell.x = nil
            case .y:    had = cell.y != nil;    cell.y = nil
            }
            if had {
                if cell.size == nil && cell.x == nil && cell.y == nil {
                    bucketHpBadgeSlotOverrides.removeValue(forKey: slotKey)
                } else {
                    bucketHpBadgeSlotOverrides[slotKey] = cell
                }
                return
            }
        }
        let sharedKey = bucketHpBadgeKey(height: height, width: width)
        if var cell = bucketHpBadgeOverrides[sharedKey] {
            switch field {
            case .size: cell.size = nil
            case .x:    cell.x = nil
            case .y:    cell.y = nil
            }
            if cell.size == nil && cell.x == nil && cell.y == nil {
                bucketHpBadgeOverrides.removeValue(forKey: sharedKey)
            } else {
                bucketHpBadgeOverrides[sharedKey] = cell
            }
        }
    }

    // MARK: - CONTEXTUAL HP badge nudges (June 12, 2026 — §28.9 built)
    //
    // Sometimes a badge's right place depends on WHO IS STANDING ONE SLOT
    // IN FRONT (the badge hangs left, into the front neighbor's space —
    // e.g. small-thin in slot 1 behind a tall-wide active needs its badge
    // shoved differently). This layer is a SPARSE dictionary of NUDGES
    // (deltas, not absolutes) applied ON TOP of the fully-resolved badge
    // values, keyed by:
    //
    //     (my slot, my height × width, neighbor's height × width)
    //
    // Both sides use the FULL H×W per the user's call (June 12). Because
    // nudges are deltas, re-tuning any base tier later carries through
    // automatically — contextual entries never go stale.
    //
    // Neighbor = the customer one slot closer to the counter (slot 0 for
    // slot 1, slot 1 for slot 2). Slot 0 has nobody in front → no nudges.
    // Resolution is LIVE: the scene recomputes from the current queue
    // every render, so badges hop to their contextual spot when the
    // lineup changes (defeat / expire / swap).

    struct HpBadgeContextKey: Hashable, Codable {
        let slot: Int                       // 1 or 2 (the badge owner's slot)
        let myHeight: CustomerHeightBucket
        let myWidth: CustomerWidthBucket
        let nbrHeight: CustomerHeightBucket
        let nbrWidth: CustomerWidthBucket
    }

    struct HpBadgeContextNudge: Codable, Equatable {
        var dx: Double = 0        // added to resolved badge X
        var dy: Double = 0        // added to resolved badge Y
        var sizeMul: Double = 1.0 // multiplies resolved badge size
        var isIdentity: Bool { dx == 0 && dy == 0 && sizeMul == 1.0 }
    }

    /// SPARSE — only problem pairings ever get entries.
    /// BAKED July 3 (user-tuned): slot-1 superShort·skinny standing
    /// behind a medium·wide → badge nudged right and up.
    var hpBadgeContextNudges: [HpBadgeContextKey: HpBadgeContextNudge] = [
        HpBadgeContextKey(slot: 1,
                          myHeight: .superShort, myWidth: .skinny,
                          nbrHeight: .medium, nbrWidth: .wide):
            HpBadgeContextNudge(dx: 37.23404407501221,
                                dy: -16.66666269302368,
                                sizeMul: 1.0)
    ]

    func hpBadgeContextKey(slot: Int, myCharacterId: String, neighborCharacterId: String) -> HpBadgeContextKey {
        let me = characterScale(for: myCharacterId)
        let nbr = characterScale(for: neighborCharacterId)
        return HpBadgeContextKey(
            slot: slot,
            myHeight: me.heightBucket, myWidth: me.widthBucket,
            nbrHeight: nbr.heightBucket, nbrWidth: nbr.widthBucket
        )
    }

    /// The nudge for a live pairing — identity when no entry exists or
    /// there is no front neighbor.
    func hpBadgeContextNudge(slot: Int, myCharacterId: String, neighborCharacterId: String?) -> HpBadgeContextNudge {
        guard slot >= 1, let neighborCharacterId else { return HpBadgeContextNudge() }
        let key = hpBadgeContextKey(slot: slot, myCharacterId: myCharacterId, neighborCharacterId: neighborCharacterId)
        return hpBadgeContextNudges[key] ?? HpBadgeContextNudge()
    }

    /// Whether an entry exists for this live pairing (drives the editor's
    /// purple tier dot).
    func hasHpBadgeContextNudge(slot: Int, myCharacterId: String, neighborCharacterId: String?) -> Bool {
        guard slot >= 1, let neighborCharacterId else { return false }
        let key = hpBadgeContextKey(slot: slot, myCharacterId: myCharacterId, neighborCharacterId: neighborCharacterId)
        return hpBadgeContextNudges[key] != nil
    }

    func setHpBadgeContextNudge(slot: Int, myCharacterId: String, neighborCharacterId: String,
                                dx: Double? = nil, dy: Double? = nil, sizeMul: Double? = nil) {
        let key = hpBadgeContextKey(slot: slot, myCharacterId: myCharacterId, neighborCharacterId: neighborCharacterId)
        var nudge = hpBadgeContextNudges[key] ?? HpBadgeContextNudge()
        if let dx { nudge.dx = dx }
        if let dy { nudge.dy = dy }
        if let sizeMul { nudge.sizeMul = sizeMul }
        // Keep the dictionary sparse: identity nudges are removed.
        if nudge.isIdentity {
            hpBadgeContextNudges.removeValue(forKey: key)
        } else {
            hpBadgeContextNudges[key] = nudge
        }
    }

    func clearHpBadgeContextNudge(slot: Int, myCharacterId: String, neighborCharacterId: String?) {
        guard let neighborCharacterId else { return }
        let key = hpBadgeContextKey(slot: slot, myCharacterId: myCharacterId, neighborCharacterId: neighborCharacterId)
        hpBadgeContextNudges.removeValue(forKey: key)
    }

    /// Editor write-mode (June 12, 2026): when true, the focused editor's
    /// HP badge drag + nudge sliders write the CONTEXTUAL nudge for the
    /// current live pairing instead of the base tiers.
    var editHpBadgeContextual: Bool = false

    // ═══════════════════════════════════════════════════════════════════
    // CHARACTER CONTEXTUAL NUDGE (June 24, 2026)
    // ═══════════════════════════════════════════════════════════════════
    // Mirrors the HP badge contextual nudge, but moves the CHARACTER BODY
    // (position + scale) based on bucket context. Keyed on the character's
    // own bucket plus the FRONT and BACK neighbor buckets, so it scales to a
    // random, growing cast (a finite set of bucket combos, not per-name).
    // A neighbor bucket is nil when there's no neighbor on that side.
    // SPARSE: only tuned combos get entries; everything else falls back to
    // the plain auto-layout position.

    struct CharacterContextKey: Hashable, Codable {
        let slot: Int                              // 0 (active), 1, 2, …
        let myHeight: CustomerHeightBucket
        let myWidth: CustomerWidthBucket
        // Optional neighbor buckets — encoded as "" (empty) when nil so the
        // key stays Codable/Hashable cleanly.
        let frontHeight: String   // CustomerHeightBucket.rawValue or ""
        let frontWidth: String    // CustomerWidthBucket.rawValue or ""
        let backHeight: String
        let backWidth: String
    }

    struct CharacterContextNudge: Codable, Equatable {
        var dx: Double = 0        // added to the character's X
        var dy: Double = 0        // added to the character's Y
        var sizeMul: Double = 1.0 // multiplies the character's scale
        var isIdentity: Bool { dx == 0 && dy == 0 && sizeMul == 1.0 }
    }

    /// SPARSE — only problem combos ever get entries.
    /// BAKED July 3 (user-tuned): a medium·medium in slot 1, squeezed
    /// between a medium·wide up front and a short·wide behind → steps
    /// 15pt left so the sandwich doesn't overlap.
    var characterContextNudges: [CharacterContextKey: CharacterContextNudge] = [
        CharacterContextKey(slot: 1,
                            myHeight: .medium, myWidth: .medium,
                            frontHeight: CustomerHeightBucket.medium.rawValue,
                            frontWidth: CustomerWidthBucket.wide.rawValue,
                            backHeight: CustomerHeightBucket.short.rawValue,
                            backWidth: CustomerWidthBucket.wide.rawValue):
            CharacterContextNudge(dx: -15.2482271194458, dy: 0.0, sizeMul: 1.0)
    ]

    private func charBuckets(_ id: String?) -> (h: String, w: String) {
        guard let id else { return ("", "") }
        let s = characterScale(for: id)
        return (s.heightBucket.rawValue, s.widthBucket.rawValue)
    }

    func characterContextKey(slot: Int, myCharacterId: String,
                             frontNeighborId: String?, backNeighborId: String?) -> CharacterContextKey {
        let me = characterScale(for: myCharacterId)
        let f = charBuckets(frontNeighborId)
        let b = charBuckets(backNeighborId)
        return CharacterContextKey(
            slot: slot,
            myHeight: me.heightBucket, myWidth: me.widthBucket,
            frontHeight: f.h, frontWidth: f.w,
            backHeight: b.h, backWidth: b.w
        )
    }

    /// The nudge for a live context — identity when no entry exists.
    func characterContextNudge(slot: Int, myCharacterId: String,
                               frontNeighborId: String?, backNeighborId: String?) -> CharacterContextNudge {
        let key = characterContextKey(slot: slot, myCharacterId: myCharacterId,
                                      frontNeighborId: frontNeighborId, backNeighborId: backNeighborId)
        return characterContextNudges[key] ?? CharacterContextNudge()
    }

    /// Whether an entry exists for this live context (drives the editor dot).
    func hasCharacterContextNudge(slot: Int, myCharacterId: String,
                                  frontNeighborId: String?, backNeighborId: String?) -> Bool {
        let key = characterContextKey(slot: slot, myCharacterId: myCharacterId,
                                      frontNeighborId: frontNeighborId, backNeighborId: backNeighborId)
        return characterContextNudges[key] != nil
    }

    func setCharacterContextNudge(slot: Int, myCharacterId: String,
                                  frontNeighborId: String?, backNeighborId: String?,
                                  dx: Double? = nil, dy: Double? = nil, sizeMul: Double? = nil) {
        let key = characterContextKey(slot: slot, myCharacterId: myCharacterId,
                                      frontNeighborId: frontNeighborId, backNeighborId: backNeighborId)
        var nudge = characterContextNudges[key] ?? CharacterContextNudge()
        if let dx { nudge.dx = dx }
        if let dy { nudge.dy = dy }
        if let sizeMul { nudge.sizeMul = sizeMul }
        if nudge.isIdentity {
            characterContextNudges.removeValue(forKey: key)
        } else {
            characterContextNudges[key] = nudge
        }
    }

    func clearCharacterContextNudge(slot: Int, myCharacterId: String,
                                    frontNeighborId: String?, backNeighborId: String?) {
        let key = characterContextKey(slot: slot, myCharacterId: myCharacterId,
                                      frontNeighborId: frontNeighborId, backNeighborId: backNeighborId)
        characterContextNudges.removeValue(forKey: key)
    }

    /// Editor write-mode: when true, the focused editor's character drag +
    /// nudge sliders write the CONTEXTUAL character nudge for the current
    /// live context instead of the base per-character values.
    var editCharacterContextual: Bool = false

    /// Bake a tuned character-context nudge into defaults (paste-back from the
    /// debug export, mirroring bakeHpContext). nil neighbor buckets = "".
    func bakeCharacterContext(slot: Int,
                              myHeight: CustomerHeightBucket, myWidth: CustomerWidthBucket,
                              frontHeight: String, frontWidth: String,
                              backHeight: String, backWidth: String,
                              dx: Double, dy: Double, sizeMul: Double) {
        let key = CharacterContextKey(
            slot: slot, myHeight: myHeight, myWidth: myWidth,
            frontHeight: frontHeight, frontWidth: frontWidth,
            backHeight: backHeight, backWidth: backWidth
        )
        characterContextNudges[key] = CharacterContextNudge(dx: dx, dy: dy, sizeMul: sizeMul)
    }


    // Active slot
    var autoLayoutSizeActiveSuperShort: Double = 1.0
    var autoLayoutSizeActiveShort: Double = 0.9065602868795395
    var autoLayoutSizeActiveMedium: Double = 1.0
    var autoLayoutSizeActiveTall: Double = 1.0
    var autoLayoutSizeActiveTallHat: Double = 1.0
    var autoLayoutSizeActiveFloater: Double = 1.0

    // Waiting 1 slot
    var autoLayoutSizeWaiting1SuperShort: Double = 0.85
    var autoLayoutSizeWaiting1Short: Double = 0.85
    var autoLayoutSizeWaiting1Medium: Double = 0.9389184892177582
    var autoLayoutSizeWaiting1Tall: Double = 0.9253546357154845
    var autoLayoutSizeWaiting1TallHat: Double = 0.85
    var autoLayoutSizeWaiting1Floater: Double = 0.85

    // Waiting 2 slot
    var autoLayoutSizeWaiting2SuperShort: Double = 0.75
    var autoLayoutSizeWaiting2Short: Double = 0.771099328994751
    var autoLayoutSizeWaiting2Medium: Double = 0.8916667073965072
    var autoLayoutSizeWaiting2Tall: Double = 0.8630319505929946
    var autoLayoutSizeWaiting2TallHat: Double = 0.75
    var autoLayoutSizeWaiting2Floater: Double = 0.75

    /// Look up the matrix cell for the given (slotIndex, heightBucket) pair.
    /// slotIndex: 0=active, 1=waiting1, 2=waiting2.
    func bucketSize(slotIndex: Int, bucket: CustomerHeightBucket) -> Double {
        switch (slotIndex, bucket) {
        case (0, .superShort): return autoLayoutSizeActiveSuperShort
        case (0, .short):      return autoLayoutSizeActiveShort
        case (0, .medium):     return autoLayoutSizeActiveMedium
        case (0, .tall):       return autoLayoutSizeActiveTall
        case (0, .tallHat):    return autoLayoutSizeActiveTallHat
        case (0, .floater):    return autoLayoutSizeActiveFloater
        case (1, .superShort): return autoLayoutSizeWaiting1SuperShort
        case (1, .short):      return autoLayoutSizeWaiting1Short
        case (1, .medium):     return autoLayoutSizeWaiting1Medium
        case (1, .tall):       return autoLayoutSizeWaiting1Tall
        case (1, .tallHat):    return autoLayoutSizeWaiting1TallHat
        case (1, .floater):    return autoLayoutSizeWaiting1Floater
        default:
            switch bucket {
            case .superShort: return autoLayoutSizeWaiting2SuperShort
            case .short:      return autoLayoutSizeWaiting2Short
            case .medium:     return autoLayoutSizeWaiting2Medium
            case .tall:       return autoLayoutSizeWaiting2Tall
            case .tallHat:    return autoLayoutSizeWaiting2TallHat
            case .floater:    return autoLayoutSizeWaiting2Floater
            }
        }
    }

    /// Fixed X-fraction of scene width for each slot in feet-anchor mode.
    /// Overrides the widthBucket-driven xFractions math so X is slot-locked
    /// regardless of which character is in the slot.
    var autoLayoutSlotXFractionActive: Double = 0.5004964616894723
    var autoLayoutSlotXFractionWaiting1: Double = 0.6776063299179077  // BAKED July 4, 2:36 PM (was 0.63499…)
    var autoLayoutSlotXFractionWaiting2: Double = 0.8476152014732361

    // MARK: - Layout Editor state (May 25, 2026)
    //
    // Shared state for the Layout Editor UI so the customer-scene tap can
    // sync with the editor's character picker. Tapping a customer in the
    // scene while the editor is OPEN sets selectedCharacterId to that char,
    // making the per-character override sliders jump to that customer.

    /// Which character the per-character override sliders are bound to.
    var selectedCharacterId: String = "mildred"

    /// Which queue slot (0=active, 1=waiting1, 2=waiting2) the tapped char
    /// is currently in. nil = no char selected → editor shows full grid view.
    /// Set when the user taps a customer in the scene with the editor open.
    var selectedSlotIndex: Int? = nil

    /// Editor toggle: when ON, HP badge sliders write to the slot-specific
    /// override dict (takes precedence over HxW shared). When OFF, sliders
    /// write to the shared HxW dict (affects all 3 slots). Transient editor
    /// state — does not persist across launches.
    var editHpBadgePerSlot: Bool = false

    /// True while the Layout Editor overlay is showing. Gates tap-to-select
    /// so normal gameplay isn't affected. Set to false when overlay closes.
    var layoutEditorIsOpen: Bool = false

    /// Master toggle for image downsampling (May 26, 2026). When true,
    /// PotionShopImageLoader.sceneImageOrFallback downsamples character
    /// PNGs at load time via ImageIO — ~10× less RAM per image, visually
    /// identical at displayed size. Toggle off via debug menu to A/B
    /// compare or revert if visuals look wrong.
    var imageDownsamplingEnabled: Bool = true

    func headAnchorY(for characterId: String) -> Double {
        let cs = characterScale(for: characterId)
        if let override = cs.headAnchorYOverride { return override }
        switch cs.heightBucket {
        case .short: return headAnchorYShort
        case .medium: return headAnchorYMedium
        case .tall: return headAnchorYTall
        case .superShort: return headAnchorYSuperShort
        case .tallHat: return headAnchorYTallHat
        case .floater: return headAnchorYFloater
        }
    }

    func headAnchorX(for characterId: String) -> Double {
        let cs = characterScale(for: characterId)
        // Per-character X override (May 25, 2026) — used by template chars.
        if let override = cs.headAnchorXOverride { return override }
        switch cs.heightBucket {
        case .short: return headAnchorXShort
        case .medium: return headAnchorXMedium
        case .tall: return headAnchorXTall
        // Template buckets are always centered horizontally.
        case .superShort, .tallHat, .floater: return 0.5
        }
    }

    // ─── TUTORIAL OVERLAY LAYOUT (July 4, 2026) ─────────────────────────
    // Edited live in debug menu → "🎓 Tutorial Layout". With edit mode ON,
    // the tutorial CARD can also be DRAGGED on screen per step.
    var tutCardOffsetX: [Double] = [0, 0, 0, 0]   // per step 1–4
    var tutCardOffsetY: [Double] = [0, 0, 0, 0]
    var tutCardMaxWidth: Double = 340
    var tutDimWatch: Double = 0.6    // screen fade, watch steps (1–3)
    var tutDimDoIt: Double = 0.35    // screen fade, do-it step (4)
    var tutorialEditMode: Bool = false

    // JULY 4, 2026 (evening 3): the dotted highlight circles are now a
    // LIST — any number, each pinned to a step, each with its own
    // position (offset from SCREEN CENTER — fixes the old top-anchored
    // guesswork), size, and line width. Add/remove in the debug editor;
    // drag them in-game with edit mode on.
    struct TutorialCircle: Identifiable {
        let id = UUID()
        var step: Int = 2        // 0-based (step 3 on screen)
        var x: Double = 0        // offset from screen CENTER
        var y: Double = -150
        var size: Double = 70
        var lineWidth: Double = 3.5
    }
    var tutCircles: [TutorialCircle] = [TutorialCircle()]   // the classic step-3 circle

    func resetTutorialLayout() {
        tutCardOffsetX = [0, 0, 0, 0]
        tutCardOffsetY = [0, 0, 0, 0]
        tutCardMaxWidth = 340
        tutDimWatch = 0.6
        tutDimDoIt = 0.35
        tutCircles = [TutorialCircle()]
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
        // mildred (updated June 24, 2026)
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

        // ─── DAY 3 GUIDE CHARACTERS (May 25, 2026) ───────────────────
        // All 13 guide_* chars use the new template buckets. They share
        // headAnchorX = 0.5 (centered) and bucket-specific headAnchorY.
        // Width buckets are set explicitly per character for auto-layout.

        applyGuideCharacter(id: "guide_octo",     height: .short,      width: .wide)
        applyGuideCharacter(id: "guide_girl",     height: .medium,     width: .skinny)
        applyGuideCharacter(id: "guide_skull",    height: .tall,       width: .skinny)
        // gmarker_* — same buckets as guide_*, used by Day 3 R3 + test-swap
        // (June 1, 2026). fishguy = .tallHat (template label SUPERTALL).
        // slug = .superShort (per user spec).
        applyGuideCharacter(id: "gmarker_octo",     height: .short,      width: .wide)
        applyGuideCharacter(id: "gmarker_girl",     height: .medium,     width: .skinny)
        applyGuideCharacter(id: "gmarker_skull",    height: .tall,       width: .skinny)
        applyGuideCharacter(id: "gmarker_slug",     height: .superShort, width: .medium)
        applyGuideCharacter(id: "gmarker_fishguy",  height: .tallHat,    width: .medium)
        applyGuideCharacter(id: "gmarker_bull",     height: .tall,       width: .wide)
        applyGuideCharacter(id: "gmarker_frog",     height: .medium,     width: .wide)
        applyGuideCharacter(id: "gmarker_fox",      height: .tall,       width: .medium)
        applyGuideCharacter(id: "gmarker_traveler", height: .medium,     width: .medium)
        applyGuideCharacter(id: "gmarker_demon",    height: .floater,    width: .medium)
        applyGuideCharacter(id: "gmarker_goatguy",  height: .medium,     width: .wide)
        applyGuideCharacter(id: "gmarker_oldlady",  height: .medium,     width: .medium)
        applyGuideCharacter(id: "gmarker_bird",     height: .medium,     width: .medium)
        applyGuideCharacter(id: "gmarker_dino",     height: .medium,     width: .medium)
        applyGuideCharacter(id: "gmarker_puck",     height: .superShort, width: .skinny)
        applyGuideCharacter(id: "guide_slug",     height: .short,      width: .medium)
        applyGuideCharacter(id: "guide_fishguy",  height: .tallHat,    width: .medium)
        applyGuideCharacter(id: "guide_bull",     height: .tall,       width: .wide)
        applyGuideCharacter(id: "guide_traveler", height: .medium,     width: .medium)
        applyGuideCharacter(id: "guide_demon",    height: .floater,    width: .medium)
        applyGuideCharacter(id: "guide_frog",     height: .medium,     width: .wide)
        applyGuideCharacter(id: "guide_pig",      height: .medium,     width: .wide)
        applyGuideCharacter(id: "guide_faun",     height: .medium,     width: .wide)
        applyGuideCharacter(id: "guide_fox",      height: .tall,       width: .medium)
        applyGuideCharacter(id: "guide_woman",    height: .medium,     width: .medium)
        applyGuideCharacter(id: "gmarker_duck",     height: .superShort, width: .skinny)
        applyGuideCharacter(id: "gmarker_vamp",     height: .short,      width: .medium)
        // JULY 6, 2026: seven new customers. Rooster/fishman/cyclops/wizzy
        // buckets set by the artist (July 6); the other three were thumbnail
        // guesses — adjust any of them freely after an in-game eyeball.
        applyGuideCharacter(id: "gmarker_advisor",  height: .tall,       width: .medium)
        applyGuideCharacter(id: "gmarker_rooster",  height: .tallHat,    width: .medium)
        applyGuideCharacter(id: "gmarker_fairy",    height: .floater,    width: .skinny)
        applyGuideCharacter(id: "gmarker_fishman",  height: .tallHat,    width: .medium)
        applyGuideCharacter(id: "gmarker_birdyo",   height: .short,      width: .skinny)
        applyGuideCharacter(id: "gmarker_cyclops",  height: .tallHat,    width: .wide)
        applyGuideCharacter(id: "gmarker_wizzy",    height: .superShort, width: .medium)

        // Day 3 Evening tuned positions (May 24, 2026)
        var slug = perCharacterScales["guide_slug"] ?? CharacterScale()
        slug.waitingY = 24.11346435546875
        slug.waiting2X = -1.063835620880127
        slug.waiting2Y = 20.212769508361816
        perCharacterScales["guide_slug"] = slug

        var fishguy = perCharacterScales["guide_fishguy"] ?? CharacterScale()
        fishguy.width = 0.9242021180689335
        fishguy.height = 0.9242021180689335
        fishguy.x = 3.9006948471069336
        fishguy.y = 8.156037330627441
        fishguy.waitingX = 13.829803466796875
        fishguy.waitingY = 10.283684730529785
        fishguy.waiting2Width = 1.08737051486969
        fishguy.waiting2Height = 1.0
        fishguy.waiting2X = -15.60283899307251
        fishguy.waiting2Y = -108.51063132286072
        perCharacterScales["guide_fishguy"] = fishguy

        var bull = perCharacterScales["guide_bull"] ?? CharacterScale()
        bull.width = 0.992021270096302
        bull.height = 0.992021270096302
        bull.x = 7.8014373779296875
        bull.y = 0.0
        bull.waitingWidth = 1.2313830107450485
        bull.waitingHeight = 1.2313830107450485
        bull.waitingX = 17.02127456665039
        bull.waitingY = -9.219849109649658
        bull.waiting2Width = 1.203457459807396
        bull.waiting2Height = 1.203457459807396
        bull.waiting2X = 8.156037330627441
        bull.waiting2Y = -1.063835620880127
        perCharacterScales["guide_bull"] = bull

        // ─── Per-cell overrides (June 2, 2026) ─────────────────────
        // 11 tuned (slot × height × width) cells for Day 3 R3 feet-anchor.
        // slot 0 = active, 1 = waiting1, 2 = waiting2.
        bake(slot: 0, height: .medium,  width: .medium, size: nil,                x: 5.673766136169434,    y: nil)
        bake(slot: 0, height: .medium,  width: .skinny, size: 1.0512411206960677, x: -2.4822592735290527, y: -9.574472904205322)
        bake(slot: 0, height: .medium,  width: .wide,   size: 1.0045213103294373, x: -5.6737542152404785,  y: -4.255318641662598)
        bake(slot: 0, height: .superShort, width: .medium, size: 0.941223394870758, x: 4.964542388916016,    y: -1.4184355735778809)
        bake(slot: 0, height: .superShort, width: .skinny, size: 1.0180851131677626, x: 16.666674613952637, y: -3.5460948944091797)
        bake(slot: 0, height: .tall,    width: .skinny, size: 1.0030142098665238, x: nil,                  y: -4.964542388916016)
        bake(slot: 1, height: .medium,  width: .skinny, size: 0.9705674469470977, x: 2.127671241760254,    y: -9.574472904205322)
        bake(slot: 1, height: .medium,  width: .medium, size: nil,                x: 9.219861030578613,    y: -6.3829779624938965)
        bake(slot: 1, height: .medium,  width: .wide,   size: nil,                x: 2.1276235580444336,   y: -7.446813583374023)
        bake(slot: 1, height: .short,   width: .wide,   size: nil,                x: nil,                  y: 4.255318641662598)
        bake(slot: 1, height: .tall,    width: .skinny, size: 0.9404255390167235, x: -9.574472904205322,   y: -8.156025409698486)
        bake(slot: 1, height: .tall,    width: .wide,   size: 0.9645390450954436, x: 4.255318641662598,    y: -6.0283660888671875)
        bake(slot: 1, height: .superShort, width: .medium, size: nil,              x: 19.5035457611084,     y: 5.3191423416137695)
        bake(slot: 1, height: .tallHat, width: .medium, size: nil,                x: 16.666674613952637,   y: 8.156037330627441)
        bake(slot: 2, height: .medium,  width: .wide,   size: nil,                x: -34.148937463760376,  y: nil)
        bake(slot: 2, height: .medium,  width: .skinny, size: 0.8886525064706803, x: nil,                  y: nil)
        bake(slot: 2, height: .tall,    width: .skinny, size: 0.8841312557458878, x: -7.446813583374023,   y: 3.5460948944091797)
        bake(slot: 2, height: .tall,    width: .wide,   size: 0.9037234604358673, x: -13.120567798614502,  y: nil)
        bake(slot: 2, height: .tallHat, width: .medium, size: nil,                x: nil,                  y: 7.801413536071777)

        // ─── HP badge per-cell overrides (June 3, 2026) ────────────
        // Keyed by (height × width) only — HP badge is head-anchored and already
        // scales with per-slot scale at render time.
        bakeHp(height: .superShort, width: .skinny, size: nil,                 x: -62.606388330459595,  y: -42.81914234161377)
        bakeHp(height: .superShort, width: .medium, size: 60.49113631248474,   x: -48.244696855545044,  y: -43.17375421524048)
        bakeHp(height: .short,      width: .wide,   size: 52.03369140625,      x: -64.73404169082642,   y: -33.59929323196411)
        bakeHp(height: .medium,     width: .skinny, size: nil,                 x: -54.36168909072876,   y: -6.382966041564941)
        bakeHp(height: .medium,     width: .medium, size: nil,                 x: -55.95744252204895,   y: -34.397149085998535)
        bakeHp(height: .medium,     width: .wide,   size: nil,                 x: -44.78724002838135,   y: -18.794310092926025)
        bakeHp(height: .tall,       width: .skinny, size: 54.10815745592117,   x: -50.53192377090454,   y: -12.854611873626709)
        bakeHp(height: .tall,       width: .medium, size: nil,                 x: -43.61702799797058,   y: 22.2517728805542)
        bakeHp(height: .tall,       width: .wide,   size: 50.0801956653595,    x: 82.44681358337402,    y: -9.249544143676758)
        bakeHp(height: .tallHat,    width: .medium, size: 59.852840304374695,  x: 18.085098266601562,   y: 7.003545761108398)
        bakeHp(height: .floater,    width: .medium, size: nil,                 x: -41.063833236694336,  y: -45.39005756378174)

        // ─── HP badge per-SLOT overrides (June 3-4, 2026) ──────────
        // Slot-specific deltas — win over shared HxW field-by-field at resolve time.
        bakeHpSlot(slot: 0, height: .superShort, width: .skinny, size: 49.95922267436981,   x: nil,                  y: nil)
        bakeHpSlot(slot: 0, height: .medium,    width: .wide,   size: nil,                x: -39.46809768676758,   y: nil)
        bakeHpSlot(slot: 0, height: .tallHat,   width: .medium, size: nil,                x: -40.42553901672363,   y: 25.08864402770996)
        bakeHpSlot(slot: 1, height: .medium,    width: .skinny, size: nil,                x: -11.808496713638306,  y: -33.33332538604736)
        bakeHpSlot(slot: 1, height: .medium,    width: .wide,   size: nil,                x: -37.34040856361389,   y: nil)
        bakeHpSlot(slot: 1, height: .short,     width: .wide,   size: nil,                x: -14.734035730361938,  y: -72.2517728805542)
        bakeHpSlot(slot: 1, height: .superShort, width: .medium, size: nil,               x: -6.223422288894653,   y: -42.10991859436035)
        bakeHpSlot(slot: 1, height: .tall,      width: .medium, size: nil,                x: -43.61702799797058,   y: nil)
        bakeHpSlot(slot: 1, height: .tall,      width: .wide,   size: 52.831562757492065,  x: -148.9361822605133,   y: -8.95390510559082)
        bakeHpSlot(slot: 2, height: .floater,   width: .medium, size: 61.12943232059479,  x: -43.19148659706116,   y: -52.127647399902344)
        bakeHpSlot(slot: 2, height: .medium,    width: .skinny, size: nil,                x: -26.17020606994629,   y: -33.33332538604736)
        bakeHpSlot(slot: 2, height: .short,     width: .wide,   size: 53.070925772190094, x: -32.819151878356934,  y: -66.22340679168701)
        bakeHpSlot(slot: 2, height: .superShort, width: .medium, size: nil,               x: -15.797889232635498,  y: -39.98225927352905)
        bakeHpSlot(slot: 2, height: .tall,      width: .medium, size: nil,                x: -30.851072072982788,  y: 5.939722061157227)
        bakeHpSlot(slot: 2, height: .tall,      width: .wide,   size: nil,                x: -45.7446813583374,    y: nil)
        bakeHpSlot(slot: 2, height: .tallHat,   width: .medium, size: 61.767733693122864, x: 43.08511018753052,    y: 31.11701011657715)

        // ─── HP badge context nudges (June 13, 2026) ─────────────
        // Slot × myBody × neighborBody → dx/dy/sizeMul adjustments.
        bakeHpContext(slot: 1, myHeight: .floater,    myWidth: .medium, nbrHeight: .tall,    nbrWidth: .wide,   dx: 34.04254913330078,   dy: -9.574472904205322,  sizeMul: 1.0120567619800567)
        bakeHpContext(slot: 1, myHeight: .medium,     myWidth: .medium, nbrHeight: .tall,    nbrWidth: .wide,   dx: 39.716315269470215,  dy: -27.304959297180176, sizeMul: 1.0)
        bakeHpContext(slot: 1, myHeight: .medium,     myWidth: .skinny, nbrHeight: .short,   nbrWidth: .wide,   dx: -38.65247964859009,  dy: 8.86523723602295,    sizeMul: 1.0)
        bakeHpContext(slot: 1, myHeight: .medium,     myWidth: .skinny, nbrHeight: .tallHat, nbrWidth: .medium, dx: -32.97872543334961,  dy: 6.0283660888671875,  sizeMul: 1.0)
        bakeHpContext(slot: 1, myHeight: .medium,     myWidth: .wide,   nbrHeight: .tall,    nbrWidth: .wide,   dx: 16.312050819396973,  dy: -27.304959297180176, sizeMul: 1.0195922136306763)
        bakeHpContext(slot: 1, myHeight: .tallHat,    myWidth: .medium, nbrHeight: .medium,  nbrWidth: .skinny, dx: -39.361703395843506, dy: 0.0,                 sizeMul: 1.0)
        bakeHpContext(slot: 1, myHeight: .tall,       myWidth: .medium, nbrHeight: .medium,  nbrWidth: .wide,   dx: 3.191494941711426,   dy: -9.929072856903076,  sizeMul: 1.0286347657442092)
        bakeHpContext(slot: 1, myHeight: .tall,       myWidth: .medium, nbrHeight: .tall,    nbrWidth: .wide,   dx: 42.19858646392822,   dy: -35.10638475418091,  sizeMul: 1.0617907732725143)
        bakeHpContext(slot: 1, myHeight: .tall,       myWidth: .medium, nbrHeight: .tall,    nbrWidth: .skinny, dx: 28.368782997131348,  dy: -24.468088150024414,  sizeMul: 1.0)
        bakeHpContext(slot: 2, myHeight: .medium,     myWidth: .medium, nbrHeight: .tall,    nbrWidth: .wide,   dx: 10.63830852508545,   dy: -18.439722061157227, sizeMul: 1.0)
        bakeHpContext(slot: 2, myHeight: .medium,     myWidth: .wide,   nbrHeight: .tall,    nbrWidth: .wide,   dx: 25.531911849975586,  dy: -2.482271194458008,  sizeMul: 1.0)
        bakeHpContext(slot: 2, myHeight: .tall,       myWidth: .wide,   nbrHeight: .tall,    nbrWidth: .skinny, dx: 10.63830852508545,   dy: -15.2482271194458,   sizeMul: 1.0)
        bakeHpContext(slot: 1, myHeight: .tall,       myWidth: .skinny, nbrHeight: .tall,    nbrWidth: .wide,   dx: 100.35459995269775,  dy: -6.0283660888671875, sizeMul: 1.0)
        bakeHpContext(slot: 1, myHeight: .tall,       myWidth: .wide,   nbrHeight: .tall,    nbrWidth: .skinny, dx: 115.2482271194458,   dy: -6.7375898361206055, sizeMul: 1.0)
        bakeHpContext(slot: 2, myHeight: .medium,     myWidth: .wide,   nbrHeight: .tall,    nbrWidth: .skinny, dx: 50.0,                dy: 0.0,                 sizeMul: 1.0)
        bakeHpContext(slot: 2, myHeight: .tall,       myWidth: .skinny, nbrHeight: .tall,    nbrWidth: .wide,   dx: 7.801413536071777,   dy: -18.085110187530518, sizeMul: 1.0)
        bakeHpContext(slot: 1, myHeight: .medium,     myWidth: .medium, nbrHeight: .tall,    nbrWidth: .skinny, dx: 22.34041690826416,   dy: -19.5035457611084,   sizeMul: 1.0)
        bakeHpContext(slot: 2, myHeight: .tall,       myWidth: .wide,   nbrHeight: .medium,  nbrWidth: .medium, dx: 16.666674613952637,  dy: -17.02127456665039,  sizeMul: 1.0)
        bakeHpContext(slot: 2, myHeight: .medium,     myWidth: .wide,   nbrHeight: .medium,  nbrWidth: .skinny, dx: 13.475179672241211,  dy: -15.2482271194458,   sizeMul: 1.0)

        // ── CHARACTER contextual nudges (June 24, 2026) ──
        bakeCharacterContext(slot: 1, myHeight: .short, myWidth: .wide,
                             frontHeight: "medium", frontWidth: "wide",
                             backHeight: "medium", backWidth: "medium",
                             dx: 2.482271194458008, dy: -2.836883068084717, sizeMul: 1.0)
        bakeCharacterContext(slot: 1, myHeight: .floater, myWidth: .medium,
                             frontHeight: "tall", frontWidth: "skinny",
                             backHeight: "medium", backWidth: "medium",
                             dx: 14.539003372192383, dy: 0.0, sizeMul: 1.0)
        bakeCharacterContext(slot: 1, myHeight: .medium, myWidth: .skinny,
                             frontHeight: "tall", frontWidth: "wide",
                             backHeight: "medium", backWidth: "wide",
                             dx: 12.411355972290039, dy: 0.709223747253418, sizeMul: 1.0)
        bakeCharacterContext(slot: 1, myHeight: .medium, myWidth: .wide,
                             frontHeight: "tall", frontWidth: "wide",
                             backHeight: "medium", backWidth: "medium",
                             dx: 10.992908477783203, dy: 6.0283660888671875, sizeMul: 1.0)
        bakeCharacterContext(slot: 2, myHeight: .medium, myWidth: .wide,
                             frontHeight: "tall", frontWidth: "wide",
                             backHeight: "", backWidth: "",
                             dx: 8.156037330627441, dy: 0.0, sizeMul: 1.0)
    }

    /// HP badge twin of `bake()`. Nil fields skip writing → fall back to
    /// the legacy per-bucket HP value at render time.
    private func bakeHp(height: CustomerHeightBucket,
                        width: CustomerWidthBucket,
                        size: Double?,
                        x: Double?,
                        y: Double?) {
        var cell = bucketHpBadgeCell(height: height, width: width)
        if let s = size { cell.size = s }
        if let xv = x { cell.x = xv }
        if let yv = y { cell.y = yv }
        bucketHpBadgeOverrides[bucketHpBadgeKey(height: height, width: width)] = cell
    }

    /// Per-slot HP badge override seeder. Nil fields stay unset → inherit
    /// from the shared HxW dict, then from the legacy per-bucket value.
    private func bakeHpSlot(slot: Int,
                            height: CustomerHeightBucket,
                            width: CustomerWidthBucket,
                            size: Double?,
                            x: Double?,
                            y: Double?) {
        var cell = bucketHpBadgeSlotCell(slot: slot, height: height, width: width)
        if let s = size { cell.size = s }
        if let xv = x { cell.x = xv }
        if let yv = y { cell.y = yv }
        bucketHpBadgeSlotOverrides[bucketCellKey(slot: slot, height: height, width: width)] = cell
    }

    /// Helper used by applyTunedCharacterScales() to seed a per-cell override.
    /// Nil fields stay unset → fall back to the height-only matrix / 0 offset.
    private func bake(slot: Int,
                      height: CustomerHeightBucket,
                      width: CustomerWidthBucket,
                      size: Double?,
                      x: Double?,
                      y: Double?) {
        var cell = bucketCell(slot: slot, height: height, width: width)
        if let s = size { cell.size = s }
        if let xv = x { cell.x = xv }
        if let yv = y { cell.y = yv }
        bucketCellOverrides[bucketCellKey(slot: slot, height: height, width: width)] = cell
    }

    /// Bakes a context-dependent HP badge nudge for a specific slot + body pair.
    private func bakeHpContext(slot: Int,
                               myHeight: CustomerHeightBucket, myWidth: CustomerWidthBucket,
                               nbrHeight: CustomerHeightBucket, nbrWidth: CustomerWidthBucket,
                               dx: Double, dy: Double, sizeMul: Double) {
        let key = HpBadgeContextKey(slot: slot,
                                     myHeight: myHeight, myWidth: myWidth,
                                     nbrHeight: nbrHeight, nbrWidth: nbrWidth)
        hpBadgeContextNudges[key] = HpBadgeContextNudge(dx: dx, dy: dy, sizeMul: sizeMul)
    }

    /// Configures a Day 3 guide character with template-correct head anchor.
    /// All guide chars are centered horizontally (X=0.5). Y anchor depends on
    /// the height bucket (uses the template defaults for new buckets, or an
    /// explicit override for legacy buckets — since legacy bucket defaults
    /// were tuned to Day 1/2 art, not the new template).
    private func applyGuideCharacter(id: String,
                                     height: CustomerHeightBucket,
                                     width: CustomerWidthBucket) {
        var cs = perCharacterScales[id] ?? CharacterScale()
        cs.heightBucket = height
        cs.widthBucket = width
        cs.headAnchorXOverride = 0.5  // template chars are centered
        // For legacy buckets used by template chars, override the Y anchor
        // to the template's value (legacy bucket defaults are for old art).
        switch height {
        case .short:
            cs.headAnchorYOverride = 0.448  // template short: head center y=688/1536
        case .medium:
            cs.headAnchorYOverride = 0.333  // template medium: head center y=512/1536
        case .tall:
            cs.headAnchorYOverride = 0.208  // template tall: head center y=320/1536
        case .superShort, .tallHat, .floater:
            cs.headAnchorYOverride = nil    // new buckets already have right Y
        }
        perCharacterScales[id] = cs
    }
    
    // MARK: - 🔒 LOCKED DEFAULTS (May 13, 2026 - Known-Good State)
    
    /// Restores ALL layout values to the locked defaults from May 13, 2026.
    /// Call this method to instantly return to the known-good baseline state.
    /// Usage: PotionShopLayoutConfig.shared.restoreLockedDefaults()
    func restoreLockedDefaults() {
        // Stability fire meter (June 27, 2026)
        resetFireMeter()
        // Section Heights
        headerPercent = 1.7198581993579865
        scenePercent = 27.27518081665039
        profilePercent = 9.5
        cauldronPercent = 37.2
        previewPercent = 0.0
        trayPercent = 18.07659387588501
        
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
        
        // Nodes (JULY 2, 2026 afternoon — tuned values baked in)
        nodeScale = 1.3844081982970238
        nodeXOffset = 74.82268810272217
        nodeYOffset = 75.5319356918335
        nodeSpacingMultiplier = 1.7340425252914429
        
        // Per-Node Offsets (JULY 2, 2026: new chalk9 board starts clean —
        // node positions live in PotionShopModels.swift, offsets at zero)
        perNodeOffsets = Array(repeating: .zero, count: PotionShopBoard.maxNodeCount)
        perNodeScales = Array(repeating: 1.0, count: PotionShopBoard.maxNodeCount)
        nodeGlobalScale = 1.0
        nodeOccupiedScale = 1.2491134881973267
        
        // Dice & Tray
        dieScale = 1.405301421880722
        trayDieScale = 1.4970566853880882
        trayOffsetX = -3.5460829734802246
        trayOffsetY = 31.028389930725098
        
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

        // Ednar Bubble & Background
        ednarBubbleX = 3.758859634399414
        ednarBubbleY = 111.77303791046143
        bgTestOpacity = 0.8463829660415649

        // Header Text Tuning (June 27, 2026 — revision 3)
        headerComposureFontSize = 25.00177276134491
        headerComposureOffsetX = 16.489362716674805
        headerComposureOffsetY = 7.375888824462891
        headerFocusFontSize = 24.9609934091568
        headerFocusOffsetX = 259.7872281074524
        headerFocusOffsetY = -22.76595711708069
        headerFocusPipSize = 24.0
        headerFocusLabelOffsetY = 1.7730498313903809
        headerTodIconSize = 49.44680881500244
        headerTodIconOffsetY = 16.01063847541809
        headerGearSize = 26.68085026741028
        headerGearOffsetY = 16.436169147491455
        headerDayFontSize = 20.57092195749283
        headerDayOffsetX = 6.702128648757935
        headerDayOffsetY = 10.904256105422974
        headerBarHeight = 25.709218978881836
        headerBarOffsetY = 16.382979154586792

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
