//
//  PotionShopModels.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Data Models
//  Place in: PotionShop/ folder
//

import SwiftUI
import UIKit

// MARK: - Image Loading Helper

import ImageIO

/// Helper to load images from Asset Catalog with emoji fallback.
///
/// Memory note (May 26, 2026): a 1024×1536 PNG decodes to ~6 MB in RAM.
/// With ~40 scene PNGs across all characters + duplicates, naive
/// `UIImage(named:)` caches can easily exhaust per-app memory. To prevent
/// this, sceneImageOrFallback now downsamples on-load to roughly 3× the
/// displayed pixel size via ImageIO — visually identical at display size
/// but ~10× less RAM per image. Toggleable via downsamplingEnabled.
struct PotionShopImageLoader {

    /// Master toggle for the downsample path. When false, falls back to
    /// the original UIImage(named:) path so visuals are identical to before.
    /// Wired to PotionShopLayoutConfig.imageDownsamplingEnabled for a
    /// runtime debug-menu toggle.
    static var downsamplingEnabled: Bool {
        PotionShopLayoutConfig.shared.imageDownsamplingEnabled
    }

    /// Cache of downsampled UIImages keyed by "assetName@targetSize". We
    /// hold these weakly via NSCache so iOS can evict on memory pressure.
    private static let downsampleCache: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        c.countLimit = 64  // cap total cached thumbnails
        return c
    }()

    /// Manually evict every downsampled image. Called by the
    /// memory-warning observer + game-end transitions.
    static func purgeDownsampleCache() {
        downsampleCache.removeAllObjects()
    }

    /// Loads an asset PNG and returns a downsampled UIImage at roughly
    /// `targetPixelSize × 3` resolution (keeps a bit of headroom for any
    /// SwiftUI scaling/animations). Uses ImageIO's CGImageSourceCreate-
    /// ThumbnailAtIndex so the full image is never decoded.
    static func downsampledImage(named name: String, targetPixelSize: CGFloat) -> UIImage? {
        let oversample: CGFloat = 3.0
        let pixelSize = max(64, targetPixelSize * oversample)  // never below 64px
        let cacheKey = "\(name)@\(Int(pixelSize))" as NSString
        if let cached = downsampleCache.object(forKey: cacheKey) {
            return cached
        }
        // Resolve the asset to a CGImageSource via UIImage's data.
        guard let baseImage = UIImage(named: name),
              let baseData = baseImage.pngData() else {
            return nil
        }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: pixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let src = CGImageSourceCreateWithData(baseData as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary) else {
            return baseImage  // fall back to full image rather than nothing
        }
        let down = UIImage(cgImage: cgImage)
        downsampleCache.setObject(down, forKey: cacheKey)
        return down
    }

    /// Attempts to load an image from the asset catalog.
    /// Returns the image if found, nil otherwise.
    static func loadImage(named name: String) -> UIImage? {
        // 1) Asset catalog (Assets.xcassets) — the reliable path.
        if let img = UIImage(named: name) { return img }
        // 2) Fallback: a loose PNG added to the app target but not in a catalog.
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        return nil
    }

    /// Returns either a downsampled UIImage (if enabled) or the full asset.
    static func loadDisplayImage(named name: String, displaySize: CGFloat) -> UIImage? {
        if downsamplingEnabled {
            return downsampledImage(named: name, targetPixelSize: displaySize)
        }
        return UIImage(named: name)
    }

    /// Creates a view showing either the asset image or emoji fallback
    @ViewBuilder
    static func imageOrEmoji(assetName: String, fallbackEmoji: String, size: CGFloat) -> some View {
        if let uiImage = loadDisplayImage(named: assetName, displaySize: size) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Text(fallbackEmoji)
                .font(.system(size: size * 0.55))
        }
    }

    /// Creates a view showing scene portrait with graceful fallback chain:
    /// 1. Try scenePortrait asset
    /// 2. If not found, try portrait asset (profile closeup)
    /// 3. If not found, show emoji
    @ViewBuilder
    static func sceneImageOrFallback(sceneAsset: String, profileAsset: String, fallbackEmoji: String, size: CGFloat) -> some View {
        // Scene portraits are drawn at 2:3 aspect, so the bounding box is
        // size × (size * 1.5). Use that taller dimension as the thumbnail
        // target so detail is preserved on the longer axis.
        let sceneDisplaySize = size * 1.5
        if let uiImage = loadDisplayImage(named: sceneAsset, displaySize: sceneDisplaySize) {
            // Preferred: scene portrait (full body) - NO CLIPPING!
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()  // Changed from .scaledToFill() to preserve aspect ratio
                .frame(width: size, height: size * 1.5)  // 2:3 aspect ratio frame
                // NO .clipShape(Circle()) - removed so you can see the full image!
        } else if let uiImage = loadDisplayImage(named: profileAsset, displaySize: size) {
            // Fallback: profile portrait (head closeup) - keep circle for profiles
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            // Last resort: emoji
            Text(fallbackEmoji)
                .font(.system(size: size * 0.55))
        }
    }
}

// MARK: - Game state phases
//
// These are the broad states the game can be in. Set by the state
// machine (PotionShopGameState, added in Phase 3) and read by the
// view to decide what to show.

enum PotionShopPhase {
    case playing       // normal gameplay
    case roundWon      // round complete overlay shown
    case choosingBoon  // JUNE 18: boon menu shown (run system test)
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

// MARK: - Trait
//
// A behavior modifier attached to a customer. Eight traits exist
// (Phase 2 defines them in PotionShopData). Traits are looked up by
// id (e.g. "intimidating"). The `effects` struct says what the
// trait does mechanically.

struct PotionShopTrait: Identifiable {
    let id: String          // e.g. "intimidating"
    let name: String        // displayed in inspect strip, e.g. "Intimidating"
    let description: String // one-liner shown to player
    let effects: PotionShopTraitEffects
}

struct PotionShopTraitEffects {
    // All optional. Missing = no effect of that kind.
    var brewTargetModifier: Int? = nil
    var activePatienceDrainModifier: Int? = nil
    var waitingPatienceDrainModifier: Int? = nil
    var focusModifier: Int? = nil
    var composureDrainPerTurn: Int? = nil
    var diceValueModifierGlobal: Int? = nil
    var overbrewTriggersPredefense: Bool? = nil
    var hexDiePerTurn: Bool? = nil
}

// MARK: - Time of day
//
// Each round happens at one of these times. Customers have a list
// of times they can show up at.

enum PotionShopTimeOfDay: String, CaseIterable {
    case morning, afternoon, evening, night
}

// MARK: - Character
//
// A reusable definition of a customer. Phase 2 defines 14 of these
// in PotionShopData. When a round starts, the game spawns a Customer
// (defined in Phase 3) from a Character template.
//
// Combat fields:
//   activeAttack       : damage they deal when at front of line (queue[0])
//   waitingAttack      : damage they deal while waiting in line
//   activePatienceTick : how fast their patience drops while at front
//   waitingPatienceTick: how fast their patience drops while waiting
//   expireDamage       : one-time damage on patience expiration

struct PotionShopCharacter: Identifiable {
    let id: String          // e.g. "mildred"
    let name: String        // e.g. "Mildred Honeycomb"
    let title: String       // e.g. "Anxious Farmwife"
    let portrait: String    // asset name for profile row portrait PNG (head closeup)
    let scenePortrait: String // asset name for customer scene portrait PNG (full body/bust)
    let iconFallback: String // emoji used as placeholder until portrait is in
    let difficulty: Int     // 1 (tutorial) - 5 (boss)
    let timeOfDay: [PotionShopTimeOfDay]
    let orderName: String   // e.g. "A Soothing Tonic"
    let orderDialogue: String
    let hp: Int             // brew target
    let patience: Int       // turns before they storm out
    let activeAttack: Int
    let waitingAttack: Int
    let activePatienceTick: Int
    let waitingPatienceTick: Int
    let expireDamage: Int
    let tickDialogue: String
    let expireDialogue: String
    let defeatDialogue: String
    let trait: String?      // trait id, or nil for no trait

    // ─── JUNE 18, 2026: per-character COSMETIC pools ───────────────────
    // Each character owns its OWN bag of flavor. On spawn the game picks one
    // at random from that character's bag, so the customer varies what they
    // say / which trait shows, but always stays in-character. Default empty
    // for back-compat.
    //   • orderPhrases — random order line (the customer "speaking"), shown
    //     on the banner's bottom row. Falls back to orderDialogue when empty.
    //   • traitNames   — random PERSONALITY word shown next to the name with
    //     the attack number. Cosmetic only — does NOT change attack/mechanics.
    var orderPhrases: [String] = []
    var traitNames: [String] = []
}

// MARK: - Round and Day definitions
//
// A Day has 4 rounds. For now (v1, Day 1 only), every round is
// CURATED — you list the customer ids that show up. Phases 11+ will
// add random rounds for Day 2+ but that's later.

struct PotionShopRound {
    let timeOfDay: PotionShopTimeOfDay
    let customerIds: [String]   // in order they appear in queue (queue[0] = first up)
    /// When true, the auto-layout positions characters so their FEET (bottom
    /// of image) land on the per-slot floor-Y from PotionShopLayoutConfig.
    /// Defaults false — only Day 3 Round 2 currently opts in.
    var useFeetAnchor: Bool = false
    /// Optional random-draw pool (June 3, 2026). When set, the customerIds
    /// field is treated as a placeholder for COUNT only — the actual chars
    /// are drawn randomly from this pool every time the round spawns.
    /// Lets fixed-position rounds (e.g. Day 3 R2) feel different each load.
    var randomFromPool: [String]? = nil
}

struct PotionShopDay {
    let id: String           // e.g. "day_1"
    let name: String         // e.g. "Day 1"
    let subtitle: String     // e.g. "Opening for Business"
    let morning: PotionShopRound
    let afternoon: PotionShopRound
    let evening: PotionShopRound
    let night: PotionShopRound

    /// Returns rounds in order: morning, afternoon, evening, night.
    var allRounds: [PotionShopRound] {
        [morning, afternoon, evening, night]
    }
}

// MARK: - Game config (tunable values)
//
// One-stop shop for numbers we'll want to tweak during balancing.
// Adjust these to retune the game.

struct PotionShopConfig {
    static let startingComposure = 30
    static let maxComposure = 30
    /// +N composure between rounds within a day. Set to 0 once the
    /// game's harder for full-day endurance.
    static let composureRestBetweenRounds = 5
    /// +N composure between days (basically, full refill).
    static let composureRestBetweenDays = 30
    static let roundsPerDay = 4
    /// Hand has 5 dice; you can place at most this many before brewing.
    static let maxPlacementsPerBrew = 3
    /// Stability fire meter: pieces shown under the cauldron. Starts full
    /// each time-slot, burns 1 per brew, refilled by stability dice.
    static let maxFire = 5
}

// MARK: - Dice
//
// Five dice types. The face value (1-6) is rolled each turn. Boost
// dice multiply neighbors; the rest contribute directly.

enum PotionShopDieType: String, CaseIterable, Identifiable {
    case potency
    case stability
    case boost
    case heal
    case shield

    var id: String { rawValue }

    /// Display abbreviation shown on the die face.
    var abbr: String {
        switch self {
        case .potency:   return "POT"
        case .stability: return "STB"
        case .boost:     return "BST"
        case .heal:      return "HEAL"
        case .shield:    return "SHD"
        }
    }

    /// Full label used in tooltips/inspect.
    var label: String { rawValue.capitalized }
    
    /// Asset name for die face art (flat-faced 512×512 PNG with center 30% blank)
    var assetName: String {
        switch self {
        case .potency:   return "die_potency"
        case .stability: return "die_stability"
        case .boost:     return "die_boost"
        case .heal:      return "die_heal"
        case .shield:    return "die_shield"
        }
    }

    /// Placeholder color (used if die art asset not found)
    var color: Color {
        switch self {
        case .potency:   return Color(red: 0.91, green: 0.30, blue: 0.24) // red
        case .stability: return Color(red: 0.20, green: 0.60, blue: 0.86) // blue
        case .boost:     return Color(red: 0.61, green: 0.35, blue: 0.71) // purple
        case .heal:      return Color(red: 0.18, green: 0.80, blue: 0.44) // green
        case .shield:    return Color(red: 0.11, green: 0.62, blue: 0.46) // teal
        }
    }
}

/// Tier system kept dormant for v1. Every die is created at .basic.
/// Silver/gold tiers will activate when multi-day progression is built.
enum PotionShopDieTier: String {
    case basic, silver, gold

    func rollFace() -> Int {
        let faces: [Int]
        switch self {
        case .basic:  faces = [1, 2, 2, 3, 3, 4]
        case .silver: faces = [2, 3, 3, 4, 4, 5]
        case .gold:   faces = [3, 4, 4, 5, 5, 6]
        }
        return faces.randomElement()!
    }
}

/// A live die in the player's hand or placed on the cauldron.
struct PotionShopDie: Identifiable, Equatable {
    let id: String
    let type: PotionShopDieType
    let tier: PotionShopDieTier
    /// Brew math value — drives damage/healing/shielding (read by
    /// computeBrew). JUNE 13, 2026 (ii-a): on Day 1 this is set from the
    /// SAME rolled face as `type` and `faceValue` (see drawFromBag), so the
    /// number shown in the tray equals the effect at the node. On other days
    /// it's still rolled independently from the tier table.
    var value: Int
    /// Cube FACE ID — which face the 3D cube spins to (NOT the brew value).
    /// Matches a `PotionShopDieFaceSpec.id` in the face/odds table
    /// (PotionShopCauldronView.swift). On Day 1 (ii-a) it comes from the same
    /// rolled face as `type`/`value`, so the picture matches the effect.
    /// Other rounds roll it independently for picture only. Defaults to 1.
    ///
    /// REQUEST 6 (June 12) / ii-a (June 13): the face→(type,value,art,odds)
    /// mapping all lives in that ONE face table — edit it to change faces,
    /// values, odds, or add new types.
    var faceValue: Int = 1
    /// Fixed dice-tray slot index (0...4). Assigned on `drawFromBag` and
    /// preserved across drag-out → drag-back-in so a die always returns
    /// to its original slot. The tray renders 5 fixed-position slots and
    /// reads `trayIndex` to decide which die goes where — without this,
    /// the tray's HStack would slide remaining dice leftward on every
    /// drag-out.
    var trayIndex: Int = 0
    /// JUNE 18, 2026 (run system test): flat bonus this die carries from a
    /// boon (e.g. an upgraded potency = +2). Added to value in computeBrew.
    /// 0 for ordinary dice.
    var ruleBonus: Int = 0

    // Equatable must compare ALL fields, not just `id`. SwiftUI uses == for
    // view diffing — if two structs with the same id but different `value`
    // or `faceValue` compare equal, SwiftUI may skip body re-evaluation and
    // the 3D cube ends up rendering a stale face after a reroll-in-place
    // (June 11 bug: floating SPIN button left tray cube showing one asset
    // but placed die showed another).
    static func == (lhs: PotionShopDie, rhs: PotionShopDie) -> Bool {
        lhs.id == rhs.id &&
        lhs.value == rhs.value &&
        lhs.faceValue == rhs.faceValue &&
        lhs.trayIndex == rhs.trayIndex
    }

    /// Roll which PICTURE the 3D cube lands on. Independent of the
    /// math-side `value`.
    ///
    /// REQUEST 6 (June 12): this now delegates to the weighted face table
    /// in `PotionShop3DDiceAssetMap.faceSpecs` (PotionShopCauldronView.swift).
    /// Edit that ONE table to change face art, adjust roll weights, or add
    /// entirely new faces — every roll site in the game reads from it.
    static func rollFaceImageValue() -> Int {
        PotionShop3DDiceAssetMap.rollWeightedFaceValue()
    }
}

/// A die in the bag (no face value rolled yet).
struct PotionShopBagDie {
    let id: String
    let type: PotionShopDieType
    let tier: PotionShopDieTier
    /// JUNE 18, 2026 (run system test): optional rule this die carries —
    /// e.g. a boon-upgraded die with +2 bonus value. Default = no bonus.
    /// Rides with the die through the deck so its effect persists for the run.
    var rule: PotionShopDieRule = PotionShopDieRule()
}

// MARK: - Cauldron board topology
//
// 12 nodes laid out in a custom positioning the user dialed in
// previously. Edges connect nearby nodes — used to compute "reach"
// for brewing math (a die affects nodes within `value` hops).
//
// (These positions match the existing CauldronBoard from the old
// CauldronGame so the user's debug positioning work is preserved.)

struct PotionShopBoard {
    // ─── CHANGING THE NODE COUNT (Request 5 context, June 12 — NOT
    // executed, just a map for later):
    //   1. Add/remove entries in `nodes` below (positions) and update
    //      `edges` so reach/boost math knows the new topology.
    //   2. PotionShopLayoutConfig.perNodeOffsets is sized to 12 — update
    //      its default array (and the saved-values reset) to the new count.
    //   3. PotionShopCauldronView's `perNodeOffsets` default parameter is
    //      also `count: 12` — update to match.
    //   Everything else (node views, connection lines, drag targets) loops
    //   over `nodes.count` and adapts automatically.
    struct Node {
        let x: Double
        let y: Double
    }

    static let nodes: [Node] = [
        Node(x: 36.0, y: 7.4),    // 0
        Node(x: 70.9, y: 7.2),    // 1
        Node(x: 6.1, y: 34.4),    // 2
        Node(x: 56.5, y: 51.7),   // 3
        Node(x: 100.3, y: 35.0),  // 4
        Node(x: 5.4, y: 82.3),    // 5
        Node(x: 56.1, y: 103.4),  // 6
        Node(x: 104.3, y: 83.9),  // 7
        Node(x: 2.5, y: 128.1),   // 8
        Node(x: 39.2, y: 139.0),  // 9
        Node(x: 79.3, y: 139.3),  // 10
        Node(x: 109.7, y: 126.8), // 11
    ]

    static let edges: [(Int, Int)] = [
        // Row 1 (top): 0, 1
        (0,1), (0,2), (0,3),
        (1,3), (1,4),
        
        // Row 2: 2, 3, 4
        (2,3), (2,5), (2,8),
        (3,4), (3,5), (3,6), (3,7),
        (4,6), (4,11),
        
        // Row 3 (middle): 5, 7, 6
        (5,7), (5,8), (5,9),
        (6,7), (6,10), (6,11),
        (7,9), (7,10),
        
        // Row 4 (bottom): 8, 9, 10, 11
        (8,9),
        (9,10),
        (10,11),
    ]

    /// Returns immediate neighbors (1 hop away).
    static func neighbors(of index: Int) -> [Int] {
        var result = Set<Int>()
        for (a, b) in edges {
            if a == index { result.insert(b) }
            if b == index { result.insert(a) }
        }
        return Array(result)
    }

    /// Returns all nodes within `hops` of `index` via BFS, excluding
    /// `index` itself. Used to compute a die's "reach".
    static func neighborsWithin(_ index: Int, hops: Int) -> [Int] {
        var visited = Set<Int>([index])
        var frontier: [Int] = [index]
        for _ in 0..<hops {
            var next: [Int] = []
            for n in frontier {
                for nb in neighbors(of: n) {
                    if !visited.contains(nb) {
                        visited.insert(nb)
                        next.append(nb)
                    }
                }
            }
            frontier = next
        }
        visited.remove(index)
        return Array(visited)
    }
}

// MARK: - Die reach rules
//
// ┌──────────────────────────────────────────────────────────────┐
// │  EDIT THIS STRUCT TO CHANGE WHICH NODES EACH DIE AFFECTS.    │
// │                                                              │
// │  This is the ONLY place reach rules live. Both systems use   │
// │  it automatically:                                           │
// │    • The cyan preview glow (which nodes light up on hover)   │
// │    • The brew calculation (which boost dice apply)           │
// │                                                              │
// │  Each die type has its own block. Mix and match patterns —   │
// │  examples below show what's possible.                        │
// └──────────────────────────────────────────────────────────────┘

struct PotionShopDieRules {

    /// Returns the node indices this die affects when placed at `nodeIndex`.
    /// Does NOT include the die's own node.
    static func affectedNodes(for die: PotionShopDie, placedAt nodeIndex: Int) -> [Int] {
        switch die.type {

        // ─── POTENCY ────────────────────────────────────────────
        case .potency:
            // Default: nodes within (die.value) graph hops
            return PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)

        // ─── STABILITY ──────────────────────────────────────────
        case .stability:
            // Default: same as potency, nodes within die.value hops
            return PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)

        // ─── BOOST ──────────────────────────────────────────────
        case .boost:
            // JUNE 20, 2026: a boost affects its DIRECTLY CONNECTED neighbors
            // (1 hop) — the nodes it's literally wired to on the board. The
            // boost's VALUE controls how MUCH it adds (in computeBrew), NOT
            // how far it reaches. (Previously reach = die.value hops, which
            // confusingly made bigger boosts reach farther.) So "connected"
            // now means exactly what you see: the lines from this node.
            return PotionShopBoard.neighborsWithin(nodeIndex, hops: 1)

        // ─── HEAL ───────────────────────────────────────────────
        case .heal:
            // Default: nodes within die.value hops
            return PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)
            //
            // ALTERNATE: Heals only affect themselves (no interaction):
            //   return []

        // ─── SHIELD ─────────────────────────────────────────────
        case .shield:
            // Default: nodes within die.value hops
            return PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)
        }
    }
}
