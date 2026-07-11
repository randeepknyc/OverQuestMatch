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
    // ─── JULY 6, 2026 (memory v7): ONE SERIAL DECODE LANE + LEDGER ───
    // The §58e prewarms introduced several CONCURRENT background threads
    // pushing decodes at once — a condition the v5 decode-at-size path was
    // never tested under, and the prime suspect for the intermittent
    // multi-GB relapses (duplicate concurrent decodes of the same asset +
    // whatever internal path preparingThumbnail takes under contention).
    // All cache-miss decode work now funnels through ONE serial queue with
    // a double-checked cache lookup: concurrent requests for the same key
    // dedupe to a single decode, and decoder concurrency is exactly 1.
    // The LEDGER counts every decode by path; the debug menu shows it —
    // "full-res fallback" is the expensive path, and a screenshot of that
    // line during any future memory spike names the culprit with DATA.
    private static let decodeQueue = DispatchQueue(label: "potionshop.image.decode",
                                                   qos: .userInitiated)
    // Mutated ONLY inside decodeQueue (serialization = thread safety).
    private(set) static var statImageIODecodes = 0
    private(set) static var statAtSizeDecodes = 0
    private(set) static var statFallbackDecodes = 0
    private(set) static var statFallbackFullResMB = 0
    private(set) static var statPassThroughs = 0
    static var decodeStatsText: String {
        "imageio \(statImageIODecodes) · at-size \(statAtSizeDecodes) · full-res fallback \(statFallbackDecodes) (≈\(statFallbackFullResMB)MB) · small pass \(statPassThroughs)"
    }

    // ═══ JULY 10, 2026 — CASE REOPENED (live 2273MB on icon-launched runs).
    // Two discriminating instruments; both mutated only on decodeQueue.
    //
    // (1) EXPOSURE LEDGER: for every catalog asset that passes through the
    // at-size / fallback paths, record what its FULL-RES decode would cost.
    // If iOS is secretly materializing full-res behind preparingThumbnail,
    // the exposure total will ≈ the live figure and the top list names the
    // guilty assets and their pixel sizes.
    private(set) static var namedSrcExposure: [String: Int] = [:]   // name → bytes
    private static func recordExposure(_ name: String, w: CGFloat, h: CGFloat) {
        namedSrcExposure[name] = Int(w * h * 4)
    }
    static var exposureText: String {
        decodeQueue.sync {
            guard !namedSrcExposure.isEmpty else { return "exposure: none recorded" }
            let totalMB = namedSrcExposure.values.reduce(0, +) / 1_048_576
            let top = namedSrcExposure.sorted { $0.value > $1.value }.prefix(3)
                .map { "\($0.key) \($0.value / 1_048_576)MB" }
                .joined(separator: ", ")
            return "if full-res pinned ≈\(totalMB)MB / \(namedSrcExposure.count) assets · top: \(top)"
        }
    }

    // (2) LIVENESS CENSUS: a weak registry of every image this loader has
    // handed out. The census sums the ones STILL ALIVE right now — if game
    // code is retaining our outputs (why purging frees nothing), the alive
    // total ≈ the live figure and the family grouping names who.
    private final class PSWeakImage {
        weak var img: UIImage?
        let name: String
        let bytes: Int
        init(_ i: UIImage, _ n: String) {
            img = i; name = n
            bytes = Int(i.size.width * i.scale * i.size.height * i.scale * 4)
        }
    }
    private static var liveRegistry: [ObjectIdentifier: PSWeakImage] = [:]
    // JULY 10, 2026 (decode-storm hunt): decodes per asset name + the set
    // of distinct pixel sizes each was decoded at. A healthy session shows
    // every name ×1-3; a name at ×hundreds is being re-decoded per frame —
    // its key must be churning (animated size) or its entry thrashing out.
    private(set) static var decodeCounts: [String: Int] = [:]
    private(set) static var decodeSizes: [String: Set<Int>] = [:]
    private static func registerLive(_ img: UIImage, name: String) {
        liveRegistry[ObjectIdentifier(img)] = PSWeakImage(img, name)
        decodeCounts[name, default: 0] += 1
        decodeSizes[name, default: []].insert(Int(max(img.size.width, img.size.height) * img.scale))
    }
    static var decodeStormText: String {
        decodeQueue.sync {
            let total = decodeCounts.values.reduce(0, +)
            guard total > 0 else { return "decodes by name: none yet" }
            let top = decodeCounts.sorted { $0.value > $1.value }.prefix(3)
                .map { "\($0.key) ×\($0.value) @\(decodeSizes[$0.key]?.count ?? 1) sizes" }
                .joined(separator: ", ")
            return "decodes \(total) · hottest: \(top)"
        }
    }
    static var livenessCensusText: String {
        decodeQueue.sync {
            liveRegistry = liveRegistry.filter { $0.value.img != nil }   // prune dead
            guard !liveRegistry.isEmpty else { return "alive loader images: 0" }
            // Group by asset family: trailing frame digits stripped.
            var families: [String: Int] = [:]
            var totalBytes = 0
            for e in liveRegistry.values {
                let fam = String(e.name.reversed().drop(while: { $0.isNumber }).reversed())
                families[fam, default: 0] += e.bytes
                totalBytes += e.bytes
            }
            let top = families.sorted { $0.value > $1.value }.prefix(3)
                .map { "\($0.key) \($0.value / 1_048_576)MB" }
                .joined(separator: ", ")
            return "alive loader images: \(liveRegistry.count) ≈\(totalBytes / 1_048_576)MB · top: \(top)"
        }
    }

    private static let downsampleCache: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        // JULY 2, 2026 (v2 — the 1969MB lesson): the cache is budgeted in
        // BYTES now, not entries. Every stored image carries its real
        // bitmap cost (w × h × 4), and the whole cache can never exceed
        // ~120MB — NSCache evicts oldest-least-used past that. countLimit
        // stays as a secondary guard. (v1 raised countLimit to 400 with
        // no cost accounting, and full-res pass-throughs pinned hundreds
        // of 12MB bitmaps → ~2GB. Never cache without a byte budget.)
        c.countLimit = 500
        // JULY 6, 2026 (v6 — the "why is it hitching all of a sudden"
        // lesson): 120MB was right-sized for the game of July 2, but the
        // working set OUTGREW it — 24-character cast, tallHat-scale art,
        // animation-frame wardrobes, banner set, Ednar's 7 poses. Once the
        // live set exceeds the budget, NSCache THRASHES: prewarming one
        // wardrobe evicts another, and the evicted art re-decodes on the
        // main thread mid-animation (the brew/shake/banner hitches). The
        // pre-July-5 system never hitched only because it kept EVERYTHING
        // decoded forever — that's the 2.8GB catastrophe; don't go back.
        // 320MB fits the full live working set with queue headroom, stays
        // far under the 900MB watchdog line, and remains a hard bound.
        // RULE: if hitches return as art grows, re-measure the working set
        // and raise this — do NOT add more prewarms into a full cache.
        c.totalCostLimit = 320 * 1024 * 1024
        return c
    }()

    /// Manually evict every downsampled image. Called by the
    /// memory-warning observer + game-end transitions.
    static func purgeDownsampleCache() {
        downsampleCache.removeAllObjects()
        looseFileCache.removeAllObjects()
    }

    /// Loads an asset PNG and returns a downsampled UIImage at roughly
    /// `targetPixelSize × 3` resolution (keeps a bit of headroom for any
    /// SwiftUI scaling/animations). Uses ImageIO's CGImageSourceCreate-
    /// ThumbnailAtIndex so the full image is never decoded.
    static func downsampledImage(named name: String, targetPixelSize: CGFloat) -> UIImage? {
        // JULY 2, 2026 v2 — MEMORY, DONE RIGHT THIS TIME:
        //   • hard ceiling: no cached image ever exceeds 2048px longest
        //     side, no matter what display size was asked for
        //   • every cached image is a FRESH small bitmap (never the
        //     UIImage(named:) object itself, whose decoded full-res data
        //     the system retains) …
        //   • … stored with its true byte cost, against the cache's
        //     ~120MB total budget (see the cache setup above).
        // Result: RAM is bounded by the budget, period.
        let oversample: CGFloat = 3.0   // points → retina pixels
        let hardCap: CGFloat = 2048
        // JULY 4, 2026 (memory v3): QUANTIZE the requested size to 64-px
        // buckets. Animated/interpolating display sizes (die flight, pop
        // scales) were minting a distinct cache entry per frame-size —
        // hundreds of near-identical bitmaps churning the budget. Bucketed,
        // an animation touches at most a handful of entries.
        let rawPixel = min(hardCap, max(64, targetPixelSize * oversample))
        let pixelSize = (rawPixel / 64).rounded(.up) * 64
        let cacheKey = "\(name)@\(Int(pixelSize))" as NSString
        if let cached = downsampleCache.object(forKey: cacheKey) {
            return cached
        }
        // JULY 6, 2026 (memory v7): all misses decode inside the ONE lane.
        return decodeQueue.sync {
            // Double-check: a concurrent caller may have decoded this key
            // while we waited our turn — dedupe instead of decoding twice.
            if let cached = downsampleCache.object(forKey: cacheKey) {
                return cached
            }
            return decodeLocked(name: name, cacheKey: cacheKey, pixelSize: pixelSize)
        }
    }

    /// The actual decode. MUST only ever run on decodeQueue (stats +
    /// single-decoder guarantee both rely on it).
    private static func decodeLocked(name: String, cacheKey: NSString, pixelSize: CGFloat) -> UIImage? {
        // ─── JULY 6, 2026 (memory v8 — THE LEDGER'S VERDICT) ───
        // The ledger proved it: full-res fallback = 0, yet 60 at-size
        // decodes footprinted ~2.8GB (~48MB each = a full-canvas decode).
        // preparingThumbnail returns the small image but ALSO deposits the
        // SOURCE's full-resolution decode in Apple's named-image cache as
        // a side effect. Cure: for any asset that exists as a FILE in the
        // bundle, decode with ImageIO straight from disk —
        // CGImageSourceCreateThumbnailAtIndex never touches UIImage's
        // named cache, so there is NOTHING to deposit. Catalog-only assets
        // still take the preparingThumbnail path below (ledger's "at-size"
        // count tracks them; if that count is high during a spike, those
        // assets need moving out of the catalog).
        if let filePath = Bundle.main.path(forResource: name, ofType: "png"),
           let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: filePath) as CFURL, nil) {
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: Int(pixelSize)
            ]
            if let cg = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) {
                let image = UIImage(cgImage: cg)
                statImageIODecodes += 1
                registerLive(image, name: name)   // JULY 10: liveness census
                let cost = Int(image.size.width * image.scale * image.size.height * image.scale * 4)
                downsampleCache.setObject(image, forKey: cacheKey, cost: cost)
                return image
            }
        }
        guard let base = UIImage(named: name) else { return nil }
        let srcPixW = base.size.width * base.scale
        let srcPixH = base.size.height * base.scale
        guard srcPixW > 0, srcPixH > 0 else { return nil }
        recordExposure(name, w: srcPixW, h: srcPixH)   // JULY 10: exposure ledger
        let maxSide = max(srcPixW, srcPixH)
        // Genuinely tiny sources (icons, dice) pass through uncached-cost-free-ish:
        // cache them WITH cost so even these obey the budget.
        let ratio = min(1.0, pixelSize / maxSide)
        let target = CGSize(width: max(1, floor(srcPixW * ratio)),
                            height: max(1, floor(srcPixH * ratio)))
        let image: UIImage
        if ratio >= 1.0 && maxSide <= 512 {
            // Small enough to keep as-is (≤512px longest side ≈ ≤1MB).
            image = base
            statPassThroughs += 1
        } else if let thumb = base.preparingThumbnail(of: target) {
            // JULY 5, 2026 (memory v5 — the "2819MB on Xcode-attached runs"
            // fix): preparingThumbnail decodes DIRECTLY at the target size
            // via ImageIO — the full-resolution bitmap is NEVER materialized.
            // The old renderer path below called base.draw(...), which forced
            // a FULL-RES decode into Apple's named-image cache first. iOS
            // normally reclaims those under memory pressure (why a home-screen
            // relaunch always looked fine), but WITH XCODE ATTACHED that
            // reclaim is suspended — so every asset's full decode accumulated
            // to ~2.8GB and our purge couldn't touch it (Apple's cache, not
            // ours). Decoding at size fixes it at the source, on every run.
            image = thumb
            statAtSizeDecodes += 1
        } else {
            // Fallback (thumbnailing can fail for exotic sources): redraw
            // into an independent bitmap at the capped size — costs one
            // full-res decode, but Apple's cache can reclaim it later.
            let fmt = UIGraphicsImageRendererFormat()
            fmt.scale = 1
            fmt.opaque = false
            image = UIGraphicsImageRenderer(size: target, format: fmt).image { _ in
                base.draw(in: CGRect(origin: .zero, size: target))
            }
            statFallbackDecodes += 1
            statFallbackFullResMB += Int(srcPixW * srcPixH * 4 / 1_048_576)
            print("⚠️ PS image: FULL-RES fallback decode for '\(name)' (\(Int(srcPixW))×\(Int(srcPixH)))")
        }
        registerLive(image, name: name)   // JULY 10: liveness census
        let cost = Int(image.size.width * image.scale * image.size.height * image.scale * 4)
        downsampleCache.setObject(image, forKey: cacheKey, cost: cost)
        return image
    }

    /// Attempts to load an image from the asset catalog.
    /// Returns the image if found, nil otherwise.
    /// JULY 4, 2026 (memory v3): the loose-file fallback gets its OWN
    /// budgeted cache. UIImage(contentsOfFile:) is NOT system-cached — a
    /// view body that re-evaluates every frame (TimelineView, drags) was
    /// minting a fresh FULL-RES decode per frame for any loose-PNG asset.
    /// That is the 2.8GB failure mode. Decode once, budget it, reuse.
    private static let looseFileCache: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        c.totalCostLimit = 60 * 1024 * 1024   // 60MB for loose files, total
        return c
    }()
    /// Names known to be missing — skip repeated catalog+disk probes.
    private static var missingNames = Set<String>()

    /// JULY 4, 2026 (memory v4 — "never again" layer 1): there is NO
    /// unbounded image path anymore. loadImage is now SAFE BY DEFAULT —
    /// it routes through the budgeted downsampler with the 2048px hard
    /// cap. Small art (≤512px) is returned as-is; big canvases can never
    /// pin a full-res decode. Existence probes (`!= nil`) still work.
    /// If some future feature genuinely needs full resolution, that's
    /// `loadFullResolutionImage` below — read its warning first.
    static func loadImage(named name: String) -> UIImage? {
        if missingNames.contains(name) { return nil }
        if let img = downsampledImage(named: name, targetPixelSize: 682) { // ×3 oversample ≈ 2048 cap
            return img
        }
        // Loose PNG fallback — decode ONCE into the budgeted cache.
        let key = name as NSString
        if let cached = looseFileCache.object(forKey: key) { return cached }
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let img = UIImage(contentsOfFile: path) {
            let cost = Int(img.size.width * img.scale * img.size.height * img.scale * 4)
            looseFileCache.setObject(img, forKey: key, cost: cost)
            registerLive(img, name: name)   // JULY 10: liveness census
            return img
        }
        missingNames.insert(name)
        return nil
    }

    /// ⚠️ DANGEROUS: bypasses every budget and pins the full decode.
    /// Nothing in the game uses this. If you're about to: don't call it
    /// from any view body, and never inside anything that re-renders.
    static func loadFullResolutionImage(named name: String) -> UIImage? {
        UIImage(named: name)
    }

    /// Returns either a downsampled UIImage (if enabled) or the full asset.
    static func loadDisplayImage(named name: String, displaySize: CGFloat) -> UIImage? {
        if downsamplingEnabled {
            return downsampledImage(named: name, targetPixelSize: displaySize)
        }
        return UIImage(named: name)
    }

    /// Creates a view showing either the asset image or emoji fallback
    /// JULY 2, 2026 (late night): HEAD PORTRAIT convention. Circular
    /// profile spots try "<assetName>_head" FIRST (e.g. gmarker_octo_head)
    /// so a character whose single asset is a full body gets a proper
    /// head shot the moment one is drawn — zero data changes needed.
    /// Until the head exists, the full asset shows circle-cropped,
    /// exactly as before.
    @ViewBuilder
    static func imageOrEmoji(assetName: String, fallbackEmoji: String, size: CGFloat) -> some View {
        if let headImage = loadDisplayImage(named: "\(assetName)_head", displaySize: size) {
            Image(uiImage: headImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else if let uiImage = loadDisplayImage(named: assetName, displaySize: size) {
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
    ///   • Burns 1 flame per `firePerPotionValue` (10) points of potion the
    ///     cauldron outputs — brew big, burn hot (JULY 2, 2026; replaces the
    ///     June 29 every-N-brews tick). Leftover value carries to the next
    ///     flame (a 14-value brew leaves 4 banked).
    ///   • Any SINGLE customer attack ≥ `fireBigHitThreshold` knocks 1 extra
    /// TUNING: raise firePerPotionValue for a slower burn (bigger brews per
    /// flame), lower it to make aggressive brewing costly.
    static let firePerPotionValue = 10
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

    // ─── WEEKLY ATTACK RAMP (July 2, 2026 — balance-lab verified) ────────
    // Customer attacks climb ×attackWeekGrowth per day WITHIN a week, then
    // RESET each week (a sawtooth): Day 1 ×1.0 → Day 7 ≈ ×2.08 → Day 8 back
    // to ×1.0. Lab finding: a single 30-day exponential steep enough for an
    // easy→brutal week 1 compounds to ×45 by Day 30 and kills every run —
    // the weekly reset gives EVERY week the "easy Monday → brutal boss"
    // arc, while the global HP curve above (no reset) keeps later weeks
    // harder overall. Verified week-1 nerve minimums: 21→17→16→18→13→10→8.
    static let attackWeekGrowth: Double = 1.13
    static func attackDayMultiplier(forDay day: Int) -> Double {
        let d = max(1, day)
        let dayInWeek = (d - 1) % 7          // 0…6, resets every week
        return pow(attackWeekGrowth, Double(dayInWeek))
    }

    // ─── BOSS = THE EVENING ROUND, CONCENTRATED (July 2, 2026) ───────────
    // Lab finding: a lone boss with flat stat multipliers was WEAKER than a
    // normal 3-customer round (one attacker vs three). New rule: the boss's
    // stats are DERIVED from the same day's EVENING round — its combined
    // order (HP) and combined attack, times these factors — so the boss can
    // never fall behind the day it closes. 1.0 = the boss's order equals the
    // whole evening's orders combined; 0.8 = it hits for 80% of the whole
    // evening's attacks (double digits by Day 7 → also triggers the fire
    // meter's big-hit knock, §63).
    // Boss nights = the evening's combined orders +30% — always clearly
    // above an ordinary night (below). Raise for scarier weekly bosses.
    static let bossHPFactorOfEvening: Double = 1.3
    static let bossAttackFactorOfEvening: Double = 0.8

    // ─── MINI-BOSS NIGHTS (July 3, 2026) ─────────────────────────────────
    // EVERY night's lone closer is a mini-boss whose order = the evening's
    // ADDED-UP total, plus a tunable overage: 1.1 = evening sum +10%
    // (e.g. a 16/16/12 evening → 44 → a 48-hp mini-boss). THIS is the
    // percent dial — raise it to make every night bite harder; it must
    // stay below bossHPFactorOfEvening so weekly bosses tower above.
    // Night attack is gentler (0.4 of the evening's combined attacks)
    // because the threat is now the LONG fight, not the per-hit.
    // Lab-verified: the 30-day arc holds from +0% through +20%.
    static let nightHPFactorOfEvening: Double = 1.1
    static let nightAttackFactorOfEvening: Double = 0.4

    // ─── SELF-HEALING CUSTOMERS (July 4, 2026) ───────────────────────────
    // From regenStartDay, ONE customer in each afternoon/evening round
    // (rotating slot) heals itself every turn — pressure to finish orders
    // fast. Bosses join from regenBossStartDay at the late amount.
    static let regenStartDay = 2
    static let regenRounds: Set<Int> = [1, 2]      // afternoon, evening
    static let regenAmountEarly = 1                 // days 2–13
    static let regenAmountLate = 2                  // day 14 onward
    static let regenBossStartDay = 14
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
    // JULY 4, 2026: the MAGIC (mirror) die — copies whatever die sits at
    // its board mirror node (PotionShopBoard.mirrorNode). Its own rolled
    // value is unused. Introduced automatically at the start of Day 2.
    case magic

    var id: String { rawValue }

    /// Display abbreviation shown on the die face.
    var abbr: String {
        switch self {
        case .potency:   return "POT"
        case .stability: return "STB"
        case .boost:     return "BST"
        case .heal:      return "HEAL"
        case .shield:    return "SHD"
        case .magic:     return "MIR"
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
        case .magic:     return "die_magic"
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
        case .magic:     return Color(red: 0.95, green: 0.77, blue: 0.20) // gold
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
        // JULY 2, 2026 (§68): basic lowered from [1,2,2,3,3,4] (avg 2.5) to
        // [1,1,2,2,3,3] (avg 2.0) — humble start: Day-1 orders take ~2 brews,
        // the fire economy is felt early, longer runway to the 6-cap, and the
        // basic→silver jump (2.0→3.5) makes the first tier upgrade land hard.
        // Lab-verified: arc holds (offense and heal drop together).
        case .basic:  faces = [1, 1, 2, 2, 3, 3]
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
    /// JULY 4, 2026: PER-TYPE basic faces — the curve starts LOWER.
    /// Day-1 rule: no die except heal has a 3 face, and heal has only ONE.
    ///   potency/shield basic [1,1,2,2,2,2] (avg 1.67)
    ///   heal          basic [1,1,2,2,2,3] (avg 1.83 — the lone 3)
    ///   boost         basic [1,1,1,1,2,2] (avg 1.33)
    ///   stability     basic all 1s (§63 — value = flames refilled)
    ///   magic         value UNUSED (it copies its mirror node's die)
    /// The CANONICAL face arrays — the single source the roll, the upgrade
    /// picker, and per-die custom faces all start from.
    func faces(for type: PotionShopDieType) -> [Int] {
        switch type {
        case .stability:
            switch self {
            case .basic:  return [1, 1, 1, 1, 1, 1]
            case .silver: return [1, 2, 2, 2, 3, 3]
            case .gold:   return [2, 3, 3, 4, 4, 5]
            }
        case .boost:
            switch self {
            case .basic:  return [1, 1, 1, 1, 2, 2]
            case .silver: return [1, 2, 2, 2, 3, 3]
            case .gold:   return [2, 3, 3, 4, 4, 5]
            }
        case .heal:
            switch self {
            case .basic:  return [1, 1, 2, 2, 2, 3]
            case .silver: return [2, 3, 3, 4, 4, 5]
            case .gold:   return [3, 4, 4, 5, 5, 6]
            }
        case .magic:
            return [1, 1, 1, 1, 1, 1]   // never read — mirror copies
        case .potency, .shield:
            switch self {
            case .basic:  return [1, 1, 2, 2, 2, 2]
            case .silver: return [2, 3, 3, 4, 4, 5]
            case .gold:   return [3, 4, 4, 5, 5, 6]
            }
        }
    }

    func rollFace(for type: PotionShopDieType) -> Int {
        faces(for: type).randomElement()!
    }

    /// The next tier up, or nil at gold (legacy; face-step upgrades — July 4
    /// afternoon — largely replace tier jumps, but the ladder stays for
    /// boards/boons that may still grant whole tiers).
    var next: PotionShopDieTier? {
        switch self {
        case .basic:  return .silver
        case .silver: return .gold
        case .gold:   return nil
        }
    }

    /// The DISTINCT face values this tier rolls for a type — the little
    /// die images the upgrade picker shows (e.g. basic boost → [1, 2]).
    func distinctFaces(for type: PotionShopDieType) -> [Int] {
        Array(Set(faces(for: type))).sorted()
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
    /// JULY 4, 2026 (afternoon): per-die UPGRADED FACES. nil = roll from the
    /// tier's canonical array; set = this die's own face list (built by the
    /// upgrade picker's floor/ceiling bumps). Copied from the bag die.
    var customFaces: [Int]? = nil
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
    // JULY 4, 2026: var (was let) — the die-upgrade picker bumps tiers.
    var tier: PotionShopDieTier
    /// JULY 4, 2026 (afternoon): this die's upgraded faces (nil = tier
    /// default). Optional → old saves decode as nil. The picker's
    /// floor/ceiling bumps write here; effective faces = this ?? tier's.
    var customFaces: [Int]? = nil
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
            Node(x: 53.46, y: 13.98),   // 0  (sketch 1 — top center)
            Node(x: 2.46, y: 43.35),   // 1  (sketch 2 — upper left)
            Node(x: 55.77, y: 72.85),   // 2  (sketch 3 — center)
            Node(x: 106.02, y: 41.78),   // 3  (sketch 4 — upper right)
            Node(x: -38.24, y: 82.59),   // 4  (sketch 5 — mid left)
            Node(x: 4.88, y: 116.54),   // 5  (sketch 6 — lower left)
            Node(x: 105.32, y: 116.34),   // 6  (sketch 7 — lower right)
            Node(x: 150.65, y: 83.95),   // 7  (sketch 8 — mid right)
            Node(x: 54.81, y: 129.66),   // 8  (sketch 9 — bottom center)
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

        // ─── MAGIC / MIRROR (July 4, 2026 — wired!) ─────────────
        // Reach glow = the node it copies: its board mirror partner.
        case .magic:
            return PotionShopBoard.mirrorNode(of: nodeIndex).map { [$0] } ?? []
        // i.e. it glows exactly its point-symmetric partner node
        // (nothing on the center node, which has no partner).
        }
    }
}


// MARK: - Effective faces + face-step upgrades (July 4, 2026 — afternoon)

extension PotionShopBagDie {
    /// The faces this die actually rolls: its upgrades, else its tier's.
    var effectiveFaces: [Int] {
        customFaces ?? tier.faces(for: type)
    }
}

extension PotionShopDie {
    /// Roll a value from this die's effective faces (upgrades respected).
    func rolledValue() -> Int {
        (customFaces ?? tier.faces(for: type)).randomElement() ?? 1
    }
}

/// The two face-step upgrade kinds the picker offers (DitD-style):
/// FLOOR bumps one of the LOWEST faces +1 ("1,1,2,2,2,2 → 1,2,2,2,2,2");
/// CEILING bumps the HIGHEST face below 6 +1 ("…2,2 → …2,3"). Faces cap at 6.
enum PotionShopFaceUpgradeKind {
    case floor, ceiling

    /// The resulting face array, or nil if no bump is possible (all 6s).
    func apply(to faces: [Int]) -> [Int]? {
        var f = faces.sorted()
        switch self {
        case .floor:
            guard let i = f.firstIndex(where: { $0 < 6 }) else { return nil }
            f[i] += 1
        case .ceiling:
            guard let i = f.lastIndex(where: { $0 < 6 }) else { return nil }
            f[i] += 1
        }
        return f.sorted()
    }
}


// MARK: - 🐕 Memory watchdog (July 4, 2026 — "never again" layers 2 & 3)
//
// Samples the app's REAL memory footprint (phys_footprint — the same
// number Xcode's gauge shows) every few seconds.
//   • Debug menu shows it live, so drift is visible in normal testing.
//   • Past softLimitMB: purges every image cache automatically and shows
//     an in-game banner — a regression self-limits AND announces itself
//     instead of silently climbing to 2.8GB.
// Started from GameView.onAppear; also purges on system memory warnings.

@Observable
final class PotionShopMemoryWatchdog {
    static let shared = PotionShopMemoryWatchdog()

    /// Latest sampled footprint in MB (-1 until first sample).
    var footprintMB: Int = -1
    /// JULY 10, 2026 (case reopened): the footprint BROKEN INTO BUCKETS,
    /// sampled alongside footprintMB. This is the phantom-vs-real
    /// discriminator, in-app, no Xcode needed:
    ///   live       = internal (genuinely in-use, dirty memory)
    ///   compressed = cold memory the system squeezed
    ///   reusable   = marked instantly-reclaimable — the "phantom" bucket;
    ///                if THIS is where the gigabytes live, the number is
    ///                bookkeeping, not real pressure
    ///   headroom   = how many MB iOS says we may still allocate before
    ///                the limit — huge headroom + huge footprint = iOS
    ///                itself doesn't believe the footprint is real
    var vmBreakdownText: String = "sampling…"
    /// JULY 10, 2026 (bimodal-launch investigation): footprint sampled
    /// every second for the FIRST 60s after launch. One screenshot of a
    /// bad launch now shows the exact second the balloon inflates —
    /// instant (startup allocation) vs ramp (runaway loop).
    var launchCurveText: String = "launch curve: recording…"
    private var launchSamples: [Int] = []
    private var launchTimer: Timer? = nil
    /// JULY 10, 2026 (endgame): a walk of the live CoreAnimation layer
    /// tree — layer count, total backing-store bytes (layers holding
    /// contents, scale-adjusted), and the biggest offenders by class and
    /// pixel size. The 2.8GB launches profile as render-surface memory
    /// (live, incompressible, flushed on backgrounding) — this names the
    /// view that ballooned. Refreshed every sample + on demand.
    var layerAuditText: String = "layer audit: pending…"
    /// JULY 10, 2026 (the title-flow lead): the splash/title/map screens
    /// draw ~30 full-screen assets via raw SwiftUI Image(name) — the ONE
    /// path the memory saga never audited. iOS decodes those at FULL
    /// resolution into its process-wide cache; the game then inherits
    /// them. This line reads their DIMENSIONS (metadata only, no decode)
    /// and reports what displaying them all costs.
    var titleFlowText: String = "title-flow art: probing…"
    /// Non-nil while the warning banner should show.
    var warningText: String? = nil

    /// Above this, caches are purged and the banner fires. The game's
    /// healthy baseline is ~170MB; 900 = something is very wrong.
    static let softLimitMB = 900

    private var timer: Timer? = nil
    private var lastPurge = Date.distantPast

    func start() {
        guard timer == nil else { return }
        titleFlowText = Self.titleFlowExposure()   // JULY 10: once, cheap
        sample()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.sample()
        }
        // JULY 10, 2026: launch-curve sampler — 1s cadence, first 60s only.
        launchSamples = []
        launchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.launchSamples.append(Self.currentFootprintMB())
            // Show a strided view so the line stays readable (~15 points).
            let stride = max(1, self.launchSamples.count / 15)
            let pts = self.launchSamples.enumerated()
                .filter { $0.offset % stride == 0 || $0.offset == self.launchSamples.count - 1 }
                .map { "\($0.element)" }
                .joined(separator: " → ")
            self.launchCurveText = "launch curve (MB): \(pts)"
            if self.launchSamples.count >= 60 {
                self.launchTimer?.invalidate()
                self.launchTimer = nil
                self.launchCurveText += " · (first 60s)"
            }
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            PotionShopImageLoader.purgeDownsampleCache()
            self?.warningText = "⚠️ iOS memory warning — caches purged"
            self?.scheduleBannerClear()
        }
    }

    private func sample() {
        footprintMB = Self.currentFootprintMB()
        vmBreakdownText = Self.currentVMBreakdownText()   // JULY 10, 2026
        layerAuditText = Self.runLayerAudit()             // JULY 10, 2026
        guard footprintMB > Self.softLimitMB else { return }
        // Self-limit: purge at most once per 30s, and shout.
        if Date().timeIntervalSince(lastPurge) > 30 {
            lastPurge = Date()
            PotionShopImageLoader.purgeDownsampleCache()
            warningText = "⚠️ MEMORY \(footprintMB)MB — caches purged. Tell Claude what was on screen."
            scheduleBannerClear()
        }
    }

    private func scheduleBannerClear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.warningText = nil
        }
    }

    /// phys_footprint via task_info — the figure Xcode's memory gauge shows.
    static func currentFootprintMB() -> Int {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size
        )
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return -1 }
        return Int(info.phys_footprint / 1_048_576)
    }

    /// JULY 10, 2026 — the footprint broken into its VM buckets, from the
    /// SAME task_vm_info call the footprint uses. Formatted for the debug
    /// menu; screenshot this line whenever the footprint reads big.
    static func currentVMBreakdownText() -> String {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size
        )
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return "breakdown unavailable" }
        let mb: (UInt64) -> Int = { Int($0 / 1_048_576) }
        // `internal` is a Swift keyword — backticks reach the C field.
        let live = mb(UInt64(max(0, info.`internal`)))
        let comp = mb(UInt64(max(0, info.compressed)))
        let reus = mb(UInt64(max(0, info.reusable)))
        let head = mb(UInt64(max(0, info.limit_bytes_remaining)))
        let headText = head == 0 ? "n/a" : "\(head)"
        return "live \(live) · compressed \(comp) · reusable \(reus) · headroom \(headText) (MB)"
    }

    /// JULY 10, 2026 — dimension probe of every splash/title/map asset.
    /// UIImage(named:).size reads metadata without decoding pixels, so
    /// this measures the exposure without creating it.
    static func titleFlowExposure() -> String {
        var names = ["splash_screen", "title_screen01", "title_screen",
                     "title_logo", GameAssets.mapBackground]
        names += (1...3).map { "splashrk\($0)" }
        names += (1...3).map { "splashmilo\($0)" }
        names += (1...8).map { "splash_bg_\($0)" }
        names += (1...17).map { "leaf\($0)" }
        var total = 0
        var found = 0
        var top: [(String, Int)] = []
        for n in names {
            guard let img = UIImage(named: n) else { continue }
            let bytes = Int(img.size.width * img.scale * img.size.height * img.scale * 4)
            total += bytes
            found += 1
            top.append((n, bytes))
        }
        guard found > 0 else { return "title-flow art: none found" }
        let topText = top.sorted { $0.1 > $1.1 }.prefix(3)
            .map { "\($0.0) \($0.1 / 1_048_576)MB" }
            .joined(separator: ", ")
        return "title-flow art: \(found) assets ≈\(total / 1_048_576)MB if all decode · top: \(topText)"
    }

    /// JULY 10, 2026 — walk every window's layer tree. Runs on the main
    /// thread (the watchdog timer lives on the main runloop). Reports:
    /// layer count · estimated contents bytes · top offenders (class,
    /// point size, estimated MB) · and the largest-BOUNDS layer even if
    /// it holds no contents (an absurd frame is the tell either way).
    static func runLayerAudit() -> String {
        var count = 0
        var contentsBytes = 0
        var top: [(cls: String, w: Int, h: Int, mb: Int)] = []
        var maxDim: (cls: String, w: Int, h: Int) = ("—", 0, 0)

        func walk(_ layer: CALayer) {
            count += 1
            let w = layer.bounds.width, h = layer.bounds.height
            if max(w, h) > CGFloat(max(maxDim.w, maxDim.h)) {
                maxDim = (String(describing: type(of: layer)), Int(w), Int(h))
            }
            if layer.contents != nil, w > 0, h > 0 {
                let scale = max(1, layer.contentsScale)
                let bytes = Int(w * scale * h * scale * 4)
                contentsBytes += bytes
                top.append((String(describing: type(of: layer)), Int(w), Int(h), bytes / 1_048_576))
            }
            layer.sublayers?.forEach(walk)
        }
        for scene in UIApplication.shared.connectedScenes {
            (scene as? UIWindowScene)?.windows.forEach { walk($0.layer) }
        }
        guard count > 0 else { return "layer audit: no windows reachable" }
        let topText = top.sorted { $0.mb > $1.mb }.prefix(3)
            .map { "\($0.cls) \($0.w)×\($0.h)pt \($0.mb)MB" }
            .joined(separator: ", ")
        return "layers \(count) · contents ≈\(contentsBytes / 1_048_576)MB · top: \(topText)"
            + " · biggest bounds: \(maxDim.cls) \(maxDim.w)×\(maxDim.h)pt"
    }
}
