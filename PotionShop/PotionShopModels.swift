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

// MARK: - Customer animation assets (JULY 2, 2026)
//
// LINE-BOIL idle + ATTACK sequences for customers, following the same
// auto-detect pattern as the fire meter's flames. Frame names are built
// from each character's scenePortrait asset name:
//
//   Idle line-boil (ACTIVE customer only, loops):
//       <scenePortrait>_boil1, _boil2, …      e.g. mildred_scene_boil1
//   Attack (plays ONCE when that customer attacks Ednar, holds last frame):
//       <scenePortrait>_attack1, _attack2, …  e.g. mildred_scene_attack1
//
// Any frame count works (probed up to 12). Draw at the SAME canvas size
// as the scenePortrait so frames line up perfectly. No frames = the
// static scenePortrait shows, exactly as before. A single _attack1 frame
// = a held attack POSE for the attack's duration.

enum PotionShopCustomerAnimTuning {
    /// Idle line-boil speed (frames per second). 6 ≈ classic hand-drawn feel.
    static let boilFPS: Double = 6
    /// Attack sequence speed. At 10fps, 4 frames ≈ 0.4s (the attack window).
    static let attackFPS: Double = 10
}

enum PotionShopCustomerAnimAssets {
    private static var cache: [String: Int] = [:]

    /// Counts frames named "<prefix>1", "<prefix>2", … Cached per prefix.
    static func frameCount(prefix: String, maxProbe: Int = 12) -> Int {
        if let c = cache[prefix] { return c }
        var n = 0
        for k in 1...maxProbe {
            if UIImage(named: "\(prefix)\(k)") != nil { n = k } else { break }
        }
        cache[prefix] = n
        return n
    }

    static func clearCache() { cache.removeAll() }
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
    case runWon        // JUNE 28: finished all 30 days — campaign victory
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
    /// +N composure recovered between rounds within a day.
    /// JUNE 28, 2026: set to 0 — the canonical model has NO automatic
    /// composure refills (recovery comes from heal dice / the Patch-Up boon).
    /// Live dial: raise it (e.g. 5) if the early game proves too punishing.
    static let composureRestBetweenRounds = 0
    /// +N composure recovered between days. JUNE 28, 2026: set to 0 (was a
    /// near-full refill). Raise it to soften day-to-day difficulty if needed.
    static let composureRestBetweenDays = 0
    static let roundsPerDay = 4
    /// Hand has 5 dice; you can place at most this many before brewing.
    static let maxPlacementsPerBrew = 3
    /// ─── STABILITY FIRE ECONOMY (June 29, 2026 redesign) ────────────
    /// The meter no longer burns 1 every brew / refills to full on any
    /// stability die. New model:
    ///   • Burns 1 flame every `fireTickEveryNTurns` brews (the slow tick).
    ///   • Any SINGLE customer attack ≥ `fireBigHitThreshold` knocks 1 extra
    ///     flame (the cauldron shakes). Early-game attacks (2–4) never
    ///     trigger this; late-game double-digit hits do — a free ramp.
    ///   • A stability die refills the meter by its FACE VALUE (capped),
    ///     and stability dice START AT ALL 1s — upgrading the lane is the
    ///     only way they grow (see PotionShopDieTier.rollFace(for:)).
    ///   • At 0 fire going into a brew, potion damage is HALVED (unchanged).
    /// TUNING: raise fireTickEveryNTurns to 3 for a gentler tick, set it to
    /// 1 for the old harsh burn-every-turn. Raise the threshold to make big
    /// hits rarer.
    static let fireTickEveryNTurns = 2
    static let fireBigHitThreshold = 10

    /// Stability fire meter: pieces shown under the cauldron. Starts full
    /// each time-slot, burns 1 per brew, refilled by stability dice.
    static let maxFire = 5

    // ─── HP bucketing / day scaling ───────────────────────────────────
    // Order-size (HP) grows ~7%/day across the whole 30-day campaign, snapped
    // to buckets. Day 1 = ×1.0. NOTE: at ×1.07/day, Day 30 ≈ 7× Day 1 — late
    // days are brutal until player-power growth (Focus/boons/relics) exists.
    // `hpGrowthPerDay` is the master dial: lower to ~1.04 for a gentler curve.
    static let hpGrowthPerDay: Double = 1.07
    static let hpBucketStep = 2
    static func hpDayMultiplier(forDay day: Int) -> Double {
        let d = max(1, min(30, day))   // full 30-day campaign curve
        return pow(hpGrowthPerDay, Double(d - 1))
    }
    static func bucketedHP(_ raw: Int) -> Int {
        let snapped = Int((Double(raw) / Double(hpBucketStep)).rounded()) * hpBucketStep
        return max(hpBucketStep, snapped)
    }
}

// MARK: - Dice
//
// Five dice types. The face value (1-6) is rolled each turn. Boost
// dice multiply neighbors; the rest contribute directly.

enum PotionShopDieType: String, CaseIterable, Identifiable, Codable {
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
enum PotionShopDieTier: String, Codable {
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

    /// JUNE 29, 2026 — type-aware roll. STABILITY has its own face ladder:
    /// its value = flames refilled, so a basic stability die is ALL 1s
    /// (always refills exactly 1) and upgrading the lane is the only way it
    /// grows. Every other type uses the shared tier table above.
    /// Ladder (raise-the-floor, Die-in-the-Dungeon style, faces ≤ 6):
    ///   basic  [1,1,1,1,1,1]  → always 1
    ///   silver [1,2,2,2,3,3]  → avg ~2.2
    ///   gold   [2,3,3,4,4,5]  → avg ~3.5
    func rollFace(for type: PotionShopDieType) -> Int {
        guard type == .stability else { return rollFace() }
        let faces: [Int]
        switch self {
        case .basic:  faces = [1, 1, 1, 1, 1, 1]
        case .silver: faces = [1, 2, 2, 2, 3, 3]
        case .gold:   faces = [2, 3, 3, 4, 4, 5]
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
struct PotionShopBagDie: Codable {
    let id: String
    let type: PotionShopDieType
    let tier: PotionShopDieTier
    /// JUNE 18, 2026 (run system test): optional rule this die carries —
    /// e.g. a boon-upgraded die with +2 bonus value. Default = no bonus.
    /// Rides with the die through the deck so its effect persists for the run.
    var rule: PotionShopDieRule = PotionShopDieRule()
}

// MARK: - Cauldron board topology (JULY 2, 2026 — BOARD LIBRARY SYSTEM)
//
// The board is no longer one hardcoded layout. It's a LIBRARY of board
// definitions plus a DAY SCHEDULE that picks which board is active.
// Every existing call site (PotionShopBoard.nodes, .edges, neighbors,
// neighborsWithin) still works — they now read from the ACTIVE board.
//
// ─── HOW TO EDIT THE BOARD (plain-English guide) ─────────────────────
//   • Move a node: change its x/y in the board definition below.
//     Coordinates live in a ~0–110 wide × ~0–145 tall design space
//     (same space the old 12-node board used, so the dialed-in layout
//     editor values still frame the board correctly in the bowl).
//   • Change the wiring: edit `edges`. (0,1) means "a line between
//     node 0 and node 1". Boost reach, hover glow, and the drawn
//     chalk lines ALL follow this list automatically.
//   • Change mirror partners: edit `mirrorPairs`. [0: 8, 8: 0] means
//     node 0 and node 8 are opposite each other. A node missing from
//     this table (like the center node) has no mirror.
//   • Add a bigger board for later days: copy the definition, give it
//     a new id, and add a row to `schedule` below (e.g. (fromDay: 8,
//     boardId: "chalk10")). Nothing else needs touching.
//
// ─── NODE NUMBERING NOTE ─────────────────────────────────────────────
// Code counts from 0, the design sketch counted from 1. So sketch
// node "1" = code node 0, sketch "2" = code 1, … sketch "9" = code 8.
// Comments below show both.

/// One complete board layout: node positions + wiring + mirror pairs.
struct PotionShopBoardDef {
    let id: String
    let nodes: [PotionShopBoard.Node]
    let edges: [(Int, Int)]
    /// Point-symmetry partners: node → the node directly OPPOSITE it
    /// through the center of the cauldron. Used by the (future) mirror
    /// die: a mirror doubles whatever die sits at its partner node.
    /// The dead-center node has no partner and is absent from this table.
    let mirrorPairs: [Int: Int]
}

struct PotionShopBoard {
    struct Node {
        let x: Double
        let y: Double
    }

    // ─── THE BOARD LIBRARY ───────────────────────────────────────────
    // All boards the game knows about. v1 ships with ONE (chalk9).

    /// The 9-node chalk board (from the user's July 2 sketch).
    /// Wiring: an OUTER RING (1-2-5-6-9-7-8-4-1 in sketch numbers)
    /// plus the center (sketch 3) connected to the four diagonals
    /// (sketch 2, 4, 6, 7). The center does NOT connect to sketch 1
    /// or 9 — no central hub.
    /// Check: a boost on sketch-1 with "exactly 2 spaces" reach hits
    /// sketch 5, 3, and 8 — the user's example, reproduced exactly.
    static let chalk9 = PotionShopBoardDef(
        id: "chalk9",
        nodes: [
            // JULY 2, 2026 (afternoon): positions BAKED from the user's
            // layout-editor tuning (per-node nudges folded in; the editor's
            // nodeScale/offset/spacing values moved to the config defaults).
            // Coordinates can sit outside the old 0–110 envelope — that's
            // the wider spread the user dialed in.
            Node(x: 55.0,   y: 13.98),   // 0  (sketch 1 — top center)
            Node(x: -3.88,  y: 26.43),   // 1  (sketch 2 — upper left)
            Node(x: 55.0,   y: 68.43),   // 2  (sketch 3 — center)
            Node(x: 114.09, y: 26.4),    // 3  (sketch 4 — upper right)
            Node(x: -28.82, y: 75.48),   // 4  (sketch 5 — mid left)
            Node(x: 4.88,   y: 116.54),  // 5  (sketch 6 — lower left)
            Node(x: 105.32, y: 116.34),  // 6  (sketch 7 — lower right)
            Node(x: 138.92, y: 75.68),   // 7  (sketch 8 — mid right)
            Node(x: 55.0,   y: 135.62),  // 8  (sketch 9 — bottom center)
        ],
        edges: [
            // Outer ring (clockwise from the top)
            (0, 3),   // sketch 1–4
            (3, 7),   // sketch 4–8
            (7, 6),   // sketch 8–7
            (6, 8),   // sketch 7–9
            (8, 5),   // sketch 9–6
            (5, 4),   // sketch 6–5
            (4, 1),   // sketch 5–2
            (1, 0),   // sketch 2–1
            // Center spokes (center to the four diagonals only)
            (2, 1),   // sketch 3–2
            (2, 3),   // sketch 3–4
            (2, 5),   // sketch 3–6
            (2, 6),   // sketch 3–7
        ],
        mirrorPairs: [
            0: 8, 8: 0,   // sketch 1 ↔ 9  (top ↔ bottom)
            1: 6, 6: 1,   // sketch 2 ↔ 7  (upper-left ↔ lower-right)
            3: 5, 5: 3,   // sketch 4 ↔ 6  (upper-right ↔ lower-left)
            4: 7, 7: 4,   // sketch 5 ↔ 8  (mid-left ↔ mid-right)
            // sketch 3 (code 2) is dead center — no mirror partner.
        ]
    )

    /// Every board the game can use. Add new boards here.
    static let library: [PotionShopBoardDef] = [chalk9]

    // ─── THE DAY SCHEDULE ────────────────────────────────────────────
    // Which board is active from which day. The LAST row whose
    // `fromDay` is ≤ the current day wins. One row = same board
    // forever. To grow the board on day 8, add e.g.:
    //     (fromDay: 8, boardId: "chalk10"),
    static let schedule: [(fromDay: Int, boardId: String)] = [
        (fromDay: 1, boardId: "chalk9"),
    ]

    /// The board currently in play. PotionShopGameState keeps this in
    /// sync with the day; everything else just reads it.
    static private(set) var active: PotionShopBoardDef = chalk9

    /// Largest node count across the library — used to size offset
    /// arrays so they never come up short when a bigger board loads.
    static var maxNodeCount: Int {
        library.map { $0.nodes.count }.max() ?? chalk9.nodes.count
    }

    /// Pick the active board for a given day number (1-based).
    /// Called by PotionShopGameState whenever the day changes.
    static func setActiveBoard(forDay day: Int) {
        var chosenId = schedule.first?.boardId ?? chalk9.id
        for row in schedule where row.fromDay <= day {
            chosenId = row.boardId
        }
        if let def = library.first(where: { $0.id == chosenId }) {
            active = def
        }
    }

    // ─── ACTIVE-BOARD ACCESSORS (existing call sites use these) ─────

    static var nodes: [Node] { active.nodes }
    static var edges: [(Int, Int)] { active.edges }

    /// The node directly opposite `index` through the cauldron's center
    /// (nil for the dead-center node). This is the hook for the future
    /// MIRROR die: "double whatever die sits at my mirror node."
    static func mirrorNode(of index: Int) -> Int? {
        active.mirrorPairs[index]
    }

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

    /// Returns nodes EXACTLY `hops` away (skips everything closer).
    /// JULY 2, 2026: this powers the new boost rule — a boost skips its
    /// direct neighbors and lands on the ring exactly 2 steps out.
    static func neighborsExactly(_ index: Int, hops: Int) -> [Int] {
        guard hops > 0 else { return [] }
        let within = Set(neighborsWithin(index, hops: hops))
        let closer = Set(neighborsWithin(index, hops: hops - 1))
        return Array(within.subtracting(closer))
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
    ///
    /// JULY 2, 2026 (night) — HONEST PREVIEWS: only dice that genuinely
    /// affect OTHER nodes return a reach. Potency/stability/heal/shield
    /// contribute only their own value in computeBrew, so their old
    /// "within die.value hops" preview glow was misleading — it lit nodes
    /// the die does nothing to. They now return [] (no glow beyond the
    /// yellow drop target). BOOST keeps its reach, and the future MIRROR
    /// die plugs in the same way (see its stub below). Brew math is
    /// unchanged: computeBrew only ever queries boost reach.
    static func affectedNodes(for die: PotionShopDie, placedAt nodeIndex: Int) -> [Int] {
        switch die.type {

        // ─── POTENCY ────────────────────────────────────────────
        case .potency:
            // No cross-node effect → no reach glow.
            return []

        // ─── STABILITY ──────────────────────────────────────────
        case .stability:
            // Pure fire-refill die (§63) — no cross-node effect.
            return []

        // ─── BOOST ──────────────────────────────────────────────
        case .boost:
            // JULY 2, 2026: a boost affects nodes EXACTLY 2 spaces away —
            // it SKIPS its direct neighbors and lands on the ring two
            // steps out (Die in the Dungeon-style spacing puzzle). The
            // boost's VALUE controls how MUCH it adds (in computeBrew),
            // NOT how far it reaches.
            // Example on the chalk9 board: a boost on sketch-node 1
            // affects sketch nodes 5, 3, and 8.
            // (Previously: 1 hop / direct neighbors — June 20, 2026.)
            return PotionShopBoard.neighborsExactly(nodeIndex, hops: 2)

        // ─── HEAL ───────────────────────────────────────────────
        case .heal:
            // No cross-node effect → no reach glow.
            return []

        // ─── SHIELD ─────────────────────────────────────────────
        case .shield:
            // No cross-node effect → no reach glow.
            return []

        // ─── MIRROR (future die — wiring note) ──────────────────
        // When the mirror die type is added, its case is one line:
        //   case .mirror:
        //       return PotionShopBoard.mirrorNode(of: nodeIndex).map { [$0] } ?? []
        // i.e. it glows exactly its point-symmetric partner node
        // (nothing on the center node, which has no partner).
        }
    }
}
