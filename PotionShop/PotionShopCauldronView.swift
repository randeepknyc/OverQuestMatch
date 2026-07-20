//
//  PotionShopCauldronView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Cauldron + dice tray
//  Place in: PotionShop/ folder
//
//  PHASE 6: Dice slide between tray and cauldron via matchedGeometryEffect.
//  PHASE 6B: Dice drop in from above when first appearing.
//  PHASE 6D: Drop is now STRAIGHT — no rotation. Dice fall in cleanly
//            without tumbling, landing perfectly aligned in the tray.
//  PHASE 12: ART HOOKUP — Dice faces load from Assets, cauldron layers, background
//  DRAG-AND-DROP: Dice can be dragged from tray to nodes, or tapped (both work).
//
//  NAMING NOTE: PotionShop prefix on every public type. Don't rename.
//

import SwiftUI
import UniformTypeIdentifiers
import SceneKit

// MARK: - View extension for conditional modifiers

extension View {
    /// Conditionally applies a modifier to a view
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - CGRect Extension for center point

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

// MARK: - 3D Dice asset mapping (Day 2 R2)
//
// Single source of truth for which asset shows on the cube's settled face AND
// on the placed-die view (when on a node). Both render paths read from this
// mapping so they always agree on what graphic to display.
//
// To add a new die type later (e.g. supporting a 10-pool with 6 picked
// at random):
//   1. Add the new asset name to `allDiceAssetNames`
//   2. Either edit the `assetName(forValue:)` switch to point a value at it,
//      OR add a per-cube subset-picker that randomly draws from the pool.

/// One entry in the face pool = one complete rollable OUTCOME.
///   id        — the face's unique id. Drives the 3D cube spin (the cube
///               places this face's art at the front and spins to it). Must
///               be unique within `faceSpecs`. (Was called `value` before
///               June 13; renamed to `id` because it is NOT the brew value.)
///   type      — the EFFECT this face fires when placed on a node
///               (.potency damages, .heal heals, .boost boosts, etc.).
///   brewValue — the NUMBER the effect uses (heal 4 = brewValue 4). This is
///               what `computeBrew` reads and what the tray badge shows.
///   assetName — which image shows for this face (on the cube AND on a
///               placed die). Multiple faces may share an asset.
///   weight    — relative roll weight (the ODDS knob). weight 2 lands twice
///               as often as weight 1. weight 0 = art-only (flashes by during
///               the spin, never the landed result).
///
/// JUNE 13, 2026 (ii-a model): a face now bundles type + value + art, so ONE
/// weighted roll against this table decides everything about a dealt die —
/// what it does AND how much. The bag is the odds (the weights here); the
/// spin reveals which face the player got. What-you-see = what-you-get,
/// locked from tray to node.
struct PotionShopDieFaceSpec {
    let id: Int
    let type: PotionShopDieType
    let brewValue: Int
    let assetName: String
    var weight: Int = 1
}

struct PotionShop3DDiceAssetMap {

    // ═══════════════════════════════════════════════════════════════════
    //  THE FACE / ODDS TABLE — edit this to change faces, values & odds
    // ═══════════════════════════════════════════════════════════════════
    //
    //  Each row is one outcome a die can land on: (id, type, value, art, weight).
    //
    //  • CHANGE WHAT A FACE DOES:        edit its `type`.
    //  • CHANGE HOW MUCH:                edit its `brewValue`.
    //  • CHANGE HOW OFTEN IT LANDS:      edit its `weight` (the odds knob).
    //  • CHANGE ITS PICTURE:             edit its `assetName`.
    //  • ADD A NEW FACE:                 append a row with a fresh `id`.
    //  • REMOVE A FACE:                  delete its row.
    //
    //  FUTURE (not yet built, seams are ready):
    //   • Per-day / per-round odds tables → see rollOutcome(dayId:roundIndex:)
    //     below; swap which table it rolls against.
    //   • Per-day value caps ("nothing above 3 until Day X") → filter rows by
    //     brewValue inside that same function.
    //   • These six rows reproduce the pre-June-13 behavior: potency on two
    //     faces (values 1 & 2), one each of boost/heal/shield/stability.
    static var faceSpecs: [PotionShopDieFaceSpec] = [
        .init(id: 1, type: .potency,   brewValue: 1, assetName: "die_potency",   weight: 1),
        .init(id: 2, type: .potency,   brewValue: 2, assetName: "die_potency",   weight: 1),
        .init(id: 3, type: .boost,     brewValue: 3, assetName: "die_boost",     weight: 1),
        .init(id: 4, type: .heal,      brewValue: 4, assetName: "die_heal",      weight: 1),
        .init(id: 5, type: .shield,    brewValue: 5, assetName: "die_shield",    weight: 1),
        .init(id: 6, type: .stability, brewValue: 6, assetName: "die_stability", weight: 1),
        // JULY 4, 2026: the MAGIC (mirror) die's face. Without this row,
        // faceId(forType: .magic) fell back to face 1 — the magic die was
        // rendering as a POTENCY die in the tray ("never appearing").
        .init(id: 7, type: .magic,     brewValue: 1, assetName: "die_magic",     weight: 1),
        // Future examples:
        // .init(id: 7, type: .heal,    brewValue: 2, assetName: "die_heal",   weight: 2),
        // .init(id: 8, type: .potency, brewValue: 4, assetName: "die_potency", weight: 1),
    ]

    /// Look up a full face spec by its id (the cube's target face).
    static func spec(forId id: Int) -> PotionShopDieFaceSpec? {
        faceSpecs.first(where: { $0.id == id })
    }

    /// JUNE 18, 2026 (dice-model pivot): return a face id whose TYPE matches
    /// the given die type, so the cube cosmetically spins to land on the
    /// die's OWN type. The die already knows what it is (from the bag); this
    /// just picks which face-art the spin resolves to. Falls back to the
    /// first face if no face of that type exists.
    static func faceId(forType type: PotionShopDieType) -> Int {
        if let spec = faceSpecs.first(where: { $0.type == type }) {
            return spec.id
        }
        return faceSpecs.first?.id ?? 1
    }

    /// Every face id currently in the pool (in table order). Used by the
    /// cube to fill its non-landed sides.
    static var allFaceValues: [Int] {
        faceSpecs.map { $0.id }
    }

    /// Map a rolled face id → asset name, via the face table.
    /// Falls back to the first face's asset for any unknown id.
    static func assetName(forValue value: Int) -> String {
        if let spec = faceSpecs.first(where: { $0.id == value }) {
            return spec.assetName
        }
        return faceSpecs.first?.assetName ?? "die_potency"
    }

    // ─── THE ROLLER (ii-a, June 13, 2026) ──────────────────────────────
    //
    // ONE weighted roll picks a whole face. This is the single seam every
    // future weighting feature plugs into:
    //   • per-day/round odds   → branch on dayId/roundIndex to pick a table
    //   • per-day value caps    → filter `pool` by brewValue
    //   • pity timer            → handled in drawFromBag (the draw loop),
    //                             which can override this result
    static func rollOutcome(dayId: String = "", roundIndex: Int = 0) -> PotionShopDieFaceSpec {
        // SEAM: today every Day 1 round uses the one table below. Later,
        // switch `pool` by (dayId, roundIndex), and/or filter by brewValue
        // for a per-day cap, e.g.:
        //   if dayId == "day_1" { pool = pool.filter { $0.brewValue <= 3 } }
        var pool = faceSpecs.filter { $0.weight > 0 }
        guard !pool.isEmpty else {
            return faceSpecs.first ?? PotionShopDieFaceSpec(id: 1, type: .potency, brewValue: 1, assetName: "die_potency")
        }
        let totalWeight = pool.reduce(0) { $0 + $1.weight }
        var roll = Int.random(in: 1...totalWeight)
        for spec in pool {
            roll -= spec.weight
            if roll <= 0 { return spec }
        }
        return pool[0]
    }

    /// Legacy shim: still used anywhere that only wants a face id. Now rolls
    /// a full outcome and returns its id, so picture odds match the table.
    static func rollWeightedFaceValue() -> Int {
        let pool = faceSpecs.filter { $0.weight > 0 }
        guard !pool.isEmpty else { return faceSpecs.first?.id ?? 1 }
        let totalWeight = pool.reduce(0) { $0 + $1.weight }
        var roll = Int.random(in: 1...totalWeight)
        for spec in pool {
            roll -= spec.weight
            if roll <= 0 { return spec.id }
        }
        return pool[0].id
    }
}

// MARK: - Layout constants for the cauldron

struct PotionShopCauldronLayout {
    static let boardWidth:  CGFloat = 115
    static let boardHeight: CGFloat = 150

    static let bowlAspect:  CGFloat = 1.65

    static let nodeVisible: CGFloat = 26
    static let nodeHitArea: CGFloat = 36

    static let dieSize:     CGFloat = 44

    // ─── CHALK HUG (JULY 2, 2026) ────────────────────────────────
    // A placed die renders slightly SMALLER than its node art, so the
    // chalk circle ("potion_node" asset) peeks out around the die's
    // edges and looks like it's hugging it. 1.0 = die fills the node
    // edge-to-edge (old behavior). 0.86 = chalk visible all around.
    // Only applies when the potion_node asset exists — the plain
    // fallback rectangles keep the old edge-to-edge sizing.
    static let placedDieHugScale: CGFloat = 0.86

    // ─── REQUEST 1 (June 12): nodes render at the SAME SIZE as the dice
    // in the tray. When this is true, the node visual scale passed down
    // from PotionShopGameView is computed so that
    //     nodeVisible × scale == dieSize × layoutConfig.dieScale
    // i.e. a node is exactly as big as a tray die, and a placed die fills
    // its node edge-to-edge. Flip to false to go back to the layout
    // editor's independent "Node Scale" slider value.
    // NOTE: while this is true, the editor's Node Scale slider has no
    // effect (the tray's Die Scale slider drives both sizes).
    static let nodeMatchesTrayDieSize: Bool = true

    /// Resolve the node visual scale. See `nodeMatchesTrayDieSize` above.
    static func effectiveNodeScale(layoutNodeScale: Double, trayDieScale: Double) -> Double {
        guard nodeMatchesTrayDieSize else { return layoutNodeScale }
        return Double(dieSize / nodeVisible) * trayDieScale
    }

    static let rimHeight:   CGFloat = 0.06
    static let liquidHeight: CGFloat = 0.20

    static let nodeInsetX:  CGFloat = 0.70
    static let nodeInsetY:  CGFloat = 0.70

    /// How far above the slot dice start when dropping in.
    static let dropInOffset: CGFloat = 80

    /// How far ABOVE the visible dice tray panel still counts as "drop into
    /// the tray" when dragging a placed die back from a cauldron node. The
    /// drop zone is the brown tray rect grown upward by this many points so
    /// the player can release a bit early without missing the snap-to-tray.
    /// Tune to taste: bigger value = easier to drop into tray; smaller =
    /// tighter to the visible panel.
    static let trayDropZoneTopExtension: CGFloat = 80
}

// MARK: - The bowl shape (ellipse clipped to bottom half)

struct PotionShopBowlShape: Shape {
    static let segmentCount: Int = 60

    func path(in rect: CGRect) -> Path {
        let centerX = rect.midX
        let topY = rect.minY
        let a = rect.width / 2.0
        let b = rect.height

        var points: [CGPoint] = []
        let segments = PotionShopBowlShape.segmentCount
        for i in 1...segments {
            let t: Double = Double(i) / Double(segments) * Double.pi
            let x: CGFloat = centerX + a * CGFloat(cos(t))
            let y: CGFloat = topY + b * CGFloat(sin(t))
            points.append(CGPoint(x: x, y: y))
        }

        var path = Path()
        path.move(to: CGPoint(x: centerX - a, y: topY))
        path.addLine(to: CGPoint(x: centerX + a, y: topY))
        for p in points {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Cauldron layout math

private struct CauldronGeometry {
    let bowlW: CGFloat
    let bowlH: CGFloat
    let bowlCenterX: CGFloat
    let bowlOriginY: CGFloat
    let liquidW: CGFloat
    let liquidH: CGFloat
    let nodeOriginX: CGFloat
    let nodeOriginY: CGFloat
    let nodeScale: CGFloat
    let nodeSpacingMultiplier: CGFloat  // ⚠️ EXPERIMENTAL: Multiplies node coordinates (visual only)
    let totalW: CGFloat

    static func compute(
        in size: CGSize,
        scale: Double = 1.0,
        xOffset: Double = 0,
        yOffset: Double = 0,
        nodeScaleMultiplier: Double = 1.0,
        nodeXOffset: Double = 0,
        nodeYOffset: Double = 0,
        nodeSpacingMultiplier: Double = 1.0
    ) -> CauldronGeometry {
        let totalW = size.width
        let totalH = size.height

        let cauldronColW = totalW - 90

        let maxBowlH = totalH * 0.92 * scale
        let maxBowlW = cauldronColW * 0.92 * scale
        let bowlW: CGFloat
        let bowlH: CGFloat
        if maxBowlW / maxBowlH > PotionShopCauldronLayout.bowlAspect {
            bowlH = maxBowlH
            bowlW = bowlH * PotionShopCauldronLayout.bowlAspect
        } else {
            bowlW = maxBowlW
            bowlH = bowlW / PotionShopCauldronLayout.bowlAspect
        }

        let bowlCenterX = cauldronColW / 2 + xOffset
        let bowlOriginY = (totalH - bowlH) / 2 + yOffset

        let liquidH = bowlH * PotionShopCauldronLayout.liquidHeight
        let liquidW = bowlW * 0.94

        let nodeAreaW = bowlW * PotionShopCauldronLayout.nodeInsetX
        let nodeAreaH = (bowlH - liquidH) * PotionShopCauldronLayout.nodeInsetY
        let nodeAreaY = bowlOriginY + liquidH + 8

        let nodeScale = min(
            nodeAreaW / PotionShopCauldronLayout.boardWidth,
            nodeAreaH / PotionShopCauldronLayout.boardHeight
        ) * scale * nodeScaleMultiplier
        let scaledBoardW = PotionShopCauldronLayout.boardWidth * nodeScale
        let scaledBoardH = PotionShopCauldronLayout.boardHeight * nodeScale
        let nodeOriginX = bowlCenterX - scaledBoardW / 2 + nodeXOffset
        let nodeOriginY = nodeAreaY + (nodeAreaH - scaledBoardH) / 2 + nodeYOffset

        return CauldronGeometry(
            bowlW: bowlW,
            bowlH: bowlH,
            bowlCenterX: bowlCenterX,
            bowlOriginY: bowlOriginY,
            liquidW: liquidW,
            liquidH: liquidH,
            nodeOriginX: nodeOriginX,
            nodeOriginY: nodeOriginY,
            nodeScale: nodeScale,
            nodeSpacingMultiplier: nodeSpacingMultiplier,
            totalW: totalW
        )
    }
}

// MARK: - Cauldron board (cauldron + nodes + BREW)

struct PotionShopCauldronView: View {
    @Bindable var gs: PotionShopGameState
    let diceFlight: Namespace.ID
    
    // LAYOUT EDITOR PARAMETERS (with defaults so existing code doesn't break)
    var cauldronScale: Double = 1.0       // Scale multiplier for bowl/nodes
    var cauldronXOffset: Double = 0       // X offset for cauldron position (pts)
    var cauldronYOffset: Double = 0       // Y offset for cauldron position (pts)
    var nodeScale: Double = 1.0           // Independent node scale multiplier
    var nodeXOffset: Double = 0           // Independent node X offset (pts)
    var nodeYOffset: Double = 0           // Independent node Y offset (pts)
    var nodeSpacingMultiplier: Double = 1.0  // ⚠️ EXPERIMENTAL: Visual spacing multiplier (affects appearance only, NOT boost reach)
    var perNodeOffsets: [CGPoint] = Array(repeating: .zero, count: PotionShopBoard.maxNodeCount)  // Per-node fine-tuning offsets (JULY 2, 2026: sized from the board library)
    var brewXOffset: Double = -50         // BREW button X from right edge
    var brewYPercent: Double = 0.30       // BREW button Y as % of cauldron height
    var showBrewButton: Bool = true       // Toggle to hide BREW button
    var brewZoneX: Double = 0.85          // Brew tap zone X (% of width, from left)
    var brewZoneY: Double = 0.30          // Brew tap zone Y (% of height, from top)
    var brewZoneWidth: Double = 100       // Brew tap zone width (pts)
    var brewZoneHeight: Double = 100      // Brew tap zone height (pts)
    var showBrewZone: Bool = false        // Show visual indicator of brew zone
    var cauldronArtScale: Double = 1.0    // ART SCALE - Additional scale for cauldron image only
    var cauldronArtWidth: Double = 1.0    // FREEFORM - Independent width scale
    var cauldronArtHeight: Double = 1.0   // FREEFORM - Independent height scale
    var cauldronArtXOffset: Double = 0    // FREEFORM - X position offset (pts)
    var cauldronArtYOffset: Double = 0    // FREEFORM - Y position offset (pts)

    var body: some View {
        GeometryReader { geo in
            let g = CauldronGeometry.compute(
                in: geo.size,
                scale: cauldronScale,
                xOffset: cauldronXOffset,
                yOffset: cauldronYOffset,
                nodeScaleMultiplier: nodeScale,
                nodeXOffset: nodeXOffset,
                nodeYOffset: nodeYOffset,
                nodeSpacingMultiplier: nodeSpacingMultiplier
            )
            
            // Calculate BASE bowl size (without cauldronScale applied)
            // Re-compute with scale = 1.0 to get true base dimensions
            let baseGeometry = CauldronGeometry.compute(
                in: geo.size,
                scale: 1.0,  // No scale!
                xOffset: 0,
                yOffset: 0,
                nodeScaleMultiplier: 1.0,
                nodeXOffset: 0,
                nodeYOffset: 0,
                nodeSpacingMultiplier: 1.0  // Base geometry doesn't need spacing
            )

            ZStack {
                // LAYER 0: SINGLE CAULDRON IMAGE (bottom layer)
                // JULY 2, 2026 (memory): decode at DISPLAY size — the raw
                // canvas is ~12MB decoded; on screen it needs a fraction.
                if let cauldronImage = PotionShopImageLoader.loadDisplayImage(
                    named: "cauldron",
                    displaySize: max(baseGeometry.bowlW * cauldronArtScale * cauldronArtWidth,
                                     baseGeometry.bowlH * cauldronArtScale * cauldronArtHeight)) {
                    Image(uiImage: cauldronImage)
                        .resizable()
                        // NO .scaledToFit() or .scaledToFill() - allows independent width/height distortion
                        .frame(
                            width: baseGeometry.bowlW * cauldronArtScale * cauldronArtWidth,    // base × uniform × width
                            height: baseGeometry.bowlH * cauldronArtScale * cauldronArtHeight   // base × uniform × height
                        )
                        // NO .clipped() - allows image to escape frame bounds
                        // JULY 12 (tutorial): the whole cauldron publishes for
                        // the 0%-reveal highlight.
                        .background(PotionShopPlainFramePublisher(gs: gs, key: "cauldron", style: .reveal))
                        .position(
                            x: g.bowlCenterX + cauldronArtXOffset,
                            y: g.bowlOriginY + g.bowlH / 2 + cauldronArtYOffset
                        )
                        .allowsHitTesting(false)  // Don't intercept touches meant for nodes
                        .zIndex(0)  // 🔧 EXPLICIT Z-INDEX: Bottom layer

                    // ━━━ BUBBLING BOIL (JULY 2, 2026) ━━━━━━━━━━━━━━━
                    // Your cauldron_boil1…N frames loop over the cauldron
                    // WHILE THE BREW PLAYS (gs.isAnimating), rendered with
                    // the exact same frame/position/stretch as the cauldron
                    // art so bubbles register perfectly over the liquid.
                    // Draw frames on the SAME canvas as the "cauldron" PNG
                    // (transparent everywhere except the bubbles). Any
                    // frame count; speed = PotionShopCauldronBoilTuning.
                    // No frames drawn = nothing extra, exactly as before.
                    if gs.isAnimating, PotionShopCauldronBoilAssets.frameCount() > 0 {
                        TimelineView(.animation) { timeline in
                            let t = timeline.date.timeIntervalSinceReferenceDate
                            let count = PotionShopCauldronBoilAssets.frameCount()
                            let frame = Int(t * max(0.1, PotionShopCauldronBoilTuning.boilFPS)) % count
                            if let boilImg = PotionShopImageLoader.loadDisplayImage(
                                named: "cauldron_boil\(frame + 1)",
                                displaySize: max(baseGeometry.bowlW * cauldronArtScale * cauldronArtWidth,
                                                 baseGeometry.bowlH * cauldronArtScale * cauldronArtHeight)) {
                                Image(uiImage: boilImg)
                                    .resizable()
                                    .frame(
                                        width: baseGeometry.bowlW * cauldronArtScale * cauldronArtWidth,
                                        height: baseGeometry.bowlH * cauldronArtScale * cauldronArtHeight
                                    )
                                    .position(
                                        x: g.bowlCenterX + cauldronArtXOffset,
                                        y: g.bowlOriginY + g.bowlH / 2 + cauldronArtYOffset
                                    )
                            }
                        }
                        .allowsHitTesting(false)
                        .zIndex(0.5)  // over the cauldron art, under nodes/dice
                        .transition(.opacity)
                    }
                } else {
                    // Placeholder: Simple bowl shape when no art
                    PotionShopBowlShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.20, green: 0.16, blue: 0.13),
                                    Color(red: 0.10, green: 0.08, blue: 0.07)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            PotionShopBowlShape()
                                .stroke(PotionShopTheme.ink, lineWidth: 2.5)
                        )
                        .frame(width: g.bowlW, height: g.bowlH)
                        .position(x: g.bowlCenterX, y: g.bowlOriginY + g.bowlH / 2)
                        .shadow(color: .black.opacity(0.20), radius: 6, x: 0, y: 4)
                        .zIndex(0)  // 🔧 EXPLICIT Z-INDEX: Bottom layer
                }

                // ── STABILITY FIRE METER (under the cauldron) ──────────────
                PotionShopFireMeterView(current: gs.fire, maxPieces: PotionShopConfig.maxFire)
                    // JULY 12: the fire beats REVEAL the real animated flames.
                    // The flame row's flames sit on render-only offsets, so the
                    // published frame is just the anchor — size/stretch it with
                    // the fireRow nudge sliders (drawer → 🎓 → Reveal Spots).
                    .background(PotionShopPlainFramePublisher(gs: gs, key: "fireRow", style: .reveal))
                    .position(
                        x: g.bowlCenterX,                 // centered under the bowl
                        y: g.bowlOriginY + g.bowlH + 12   // 12 = gap below bowl; nudge to taste
                    )
                    .zIndex(4)   // ABOVE nodes (2) and BREW button (3) — flames on top

                // LAYER 1: Connecting lines between nodes (BEHIND nodes, above cauldron)
                PotionShopNodeConnectionLines(
                    nodeOriginX: g.nodeOriginX,
                    nodeOriginY: g.nodeOriginY,
                    nodeSpacingMultiplier: g.nodeSpacingMultiplier,
                    perNodeOffsets: perNodeOffsets,
                    gs: gs
                )
                    .zIndex(1)  // 🔧 EXPLICIT Z-INDEX: Middle layer (above cauldron, behind nodes)

                // LAYER 2: Nodes (TOP LAYER - above lines and cauldron)
                ForEach(0..<PotionShopBoard.nodes.count, id: \.self) { idx in
                    let node = PotionShopBoard.nodes[idx]
                    let perNodeOffset = idx < perNodeOffsets.count ? perNodeOffsets[idx] : .zero
                    // JULY 2, 2026: size = global multiplier ("All Nodes
                    // Size ×") × per-node multiplier ("Size ×"). Both scale
                    // the whole node — art, glow, die, hit area.
                    let cfgShared = PotionShopLayoutConfig.shared
                    let perNodeScale = cfgShared.nodeGlobalScale * cfgShared.nodeScaleAt(idx)
                    PotionShopNodeButtonView(
                        gs: gs,
                        nodeIndex: idx,
                        diceFlight: diceFlight,
                        visualScale: nodeScale * perNodeScale  // Pass visual scale separately
                    )
                        .position(
                            x: g.nodeOriginX + CGFloat(node.x) * g.nodeSpacingMultiplier + perNodeOffset.x,
                            y: g.nodeOriginY + CGFloat(node.y) * g.nodeSpacingMultiplier + perNodeOffset.y
                        )
                        .zIndex(2)  // 🔧 EXPLICIT Z-INDEX: Top layer (above everything)
                }
                
                // LAYER 3: Drag-from-node overlay used to render here, but it
                // was bounded by this view's frame in the parent VStack and
                // ended up rendering BEHIND the dice tray when dragged
                // downward. It now lives in `PotionShopDraggedDieOverlay` at
                // the top of the screen-level ZStack so it floats over the
                // tray as well.

                // BREW BUTTON (conditionally shown)
                if showBrewButton {
                    PotionShopBrewSignView(gs: gs)
                        // JULY 12 (SHAPED HIGHLIGHTS): brew sign is code-drawn,
                        // so it publishes a frame-style highlight ("brewSpoon").
                        .background(GeometryReader { g in
                            Color.clear
                                .onAppear { gs.publishTutHighlight("brewSpoon", frame: g.frame(in: .global), image: nil, style: .reveal) }
                                .onChange(of: g.frame(in: .global)) { _, f in
                                    gs.publishTutHighlight("brewSpoon", frame: f, image: nil, style: .reveal)
                                }
                        })
                        .position(
                            x: g.totalW + brewXOffset,
                            y: g.bowlOriginY + g.bowlH * brewYPercent
                        )
                        .zIndex(3)  // Above nodes
                }
                
                // BREW TAP ZONE (custom tappable area - shown only in editor)
                if !showBrewButton {
                    let zoneX = geo.size.width * brewZoneX
                    let zoneY = geo.size.height * brewZoneY
                    
                    Button {
                        Task { @MainActor in
                            await gs.doBrew()
                        }
                    } label: {
                        ZStack {
                            if showBrewZone {
                                // Visual indicator (editor only) - FIXED RENDERING
                                ZStack {
                                    // Background fill
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.yellow.opacity(0.3))
                                    
                                    // Dashed border
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.yellow, style: StrokeStyle(lineWidth: 4, dash: [10, 5]))
                                    
                                    // Label
                                    VStack(spacing: 2) {
                                        Text("🥄 BREW")
                                            .font(Font.gameScore(size: 14))
                                            .foregroundColor(.yellow)
                                        Text("TAP ZONE")
                                            .font(Font.gameUI(size: 10))
                                            .foregroundColor(.yellow)
                                    }
                                }
                            } else {
                                // Invisible tap zone (production)
                                Color.clear
                                    .contentShape(Rectangle())
                            }
                        }
                        .frame(width: brewZoneWidth, height: brewZoneHeight)
                    }
                    .position(x: zoneX, y: zoneY)
                    .disabled(gs.placements.isEmpty || gs.isAnimating || gs.phase != .playing)
                    .zIndex(3)  // Above nodes
                }
            }
        }
    }
}

// MARK: - Node glow tuning (Request 7, June 12)
//
// All knobs for the "this die would affect these nodes" preview glow.
// While a die is dragged and HOVERING over a node, every node that die
// would reach (from PotionShopDieRules.affectedNodes) pulses with this
// glow — Die-in-the-Dungeon style. Works for both tray→node drags and
// node→node drags.
//
// WHICH nodes light up for WHICH die is defined in PotionShopDieRules
// (PotionShopModels.swift) — e.g. boost hovering node 0 lights up the
// nodes its reach covers. Edit that struct to change relationships;
// edit THIS struct to change how the glow looks and pulses.

struct PotionShopNodeGlowTuning {
    /// Color of the reach-preview glow. Set `tintPreviewWithDieColor` to
    /// true to use the dragged die's own color instead (boost = purple
    /// glow, heal = green glow, etc.).
    static let previewColor = Color(red: 0.30, green: 0.85, blue: 1.00)   // cyan
    static let tintPreviewWithDieColor: Bool = false

    /// Pulse: glow opacity oscillates between min and max, and the node
    /// art breathes up to `pulseScaleMax`, repeating while hovered.
    static let pulseEnabled: Bool = true
    static let pulseOpacityMin: Double = 0.35
    static let pulseOpacityMax: Double = 1.00
    /// Seconds for one half-cycle (dim→bright). Full breath = 2× this.
    static let pulseHalfPeriod: Double = 0.45
    /// Node art scale at the bright peak (1.0 = no size pulse).
    static let pulseScaleMax: CGFloat = 1.08

    /// Base glow radius for preview nodes (pre-pulse).
    static let previewGlowRadius: CGFloat = 16

    // ─── HAND-DRAWN GLOW FRAMES (JULY 2, 2026) ──────────────────────
    // Draw a numbered PNG sequence in Assets.xcassets named
    //     node_glow1, node_glow2, node_glow3, …  (any frame count)
    // — transparent background, same square canvas as your potion_node
    // chalk image. When at least node_glow1 exists, preview nodes play
    // this sequence on loop INSTEAD of the built-in cyan shadow glow.
    // Delete the assets (or never add them) and the cyan glow returns.

    /// Frames per second for the node_glow sequence.
    static let glowFrameFPS: Double = 8
    /// RETIRED (July 2, later): glow frames now REPLACE the chalk art in
    /// its exact slot, so they always render at node size — this knob no
    /// longer does anything. Kept so old pasted files still compile.
    static let glowArtScale: CGFloat = 1.35
}

// ─── BUBBLING BOIL (JULY 2, 2026) ───────────────────────────────────
// The cauldron's brew animation. Draw cauldron_boil1…N on the SAME
// canvas as the "cauldron" PNG (transparent except the bubbles); they
// loop over the cauldron for the whole brew sequence. Any frame count.

enum PotionShopCauldronBoilTuning {
    /// Bubble loop speed (frames per second).
    static let boilFPS: Double = 8
}

enum PotionShopCauldronBoilAssets {
    private static var cached: Int? = nil
    /// Counts cauldron_boil1, cauldron_boil2, … (up to 12). Cached.
    static func frameCount(maxProbe: Int = 12) -> Int {
        if let c = cached { return c }
        var n = 0
        for k in 1...maxProbe {
            if UIImage(named: "cauldron_boil\(k)") != nil { n = k } else { break }
        }
        cached = n
        return n
    }
}

// MARK: - Node glow frame resolver (JULY 2, 2026)
//
// Auto-detects how many node_glow frames you've drawn, exactly like the
// fire meter's flame resolver. Cached so it's not re-probed every frame.

enum PotionShopNodeGlowAssets {
    private static var cachedCount: Int? = nil

    /// Number of frames drawn ("node_glow1", "node_glow2", …). 0 = none.
    static func frameCount(maxProbe: Int = 12) -> Int {
        if let c = cachedCount { return c }
        var n = 0
        for k in 1...maxProbe {
            if UIImage(named: "node_glow\(k)") != nil { n = k } else { break }
        }
        cachedCount = n
        return n
    }

    static func clearCache() { cachedCount = nil }
}

// MARK: - One node on the cauldron

struct PotionShopNodeButtonView: View {
    @Bindable var gs: PotionShopGameState
    // JULY 4, 2026 (memory v3): the breathing "+N" and the mirror
    // crossfade are one-shot repeatForever animations — the TimelineView
    // versions re-evaluated their bodies EVERY FRAME (rebuilding die
    // views + image lookups 60×/s): the runaway-memory shape. These
    // animate render properties only; the body builds ONCE.
    @State private var plusPulse = false
    @State private var mirrorFade = false
    let nodeIndex: Int
    let diceFlight: Namespace.ID
    var visualScale: Double = 1.0  // Visual-only scale (doesn't affect position)

    @State private var globalFrame: CGRect = .zero
    @State private var isDraggingFromHere: Bool = false  // Local drag state
    /// June 12, 2026: editor-mode "drag the node itself" session.
    @State private var editorNodeDrag = PotionShopEditorDragSession()
    /// Drives the reach-preview pulse: oscillates 0→1 (repeatForever)
    /// while this node is in the hovered die's reach, rests at 1 otherwise.
    @State private var previewPulse: Double = 1.0
    /// JULY 2, 2026 (night): occupied-growth state — flipped in its own
    /// withAnimation transaction so ONLY the node's scale springs when a
    /// die lands/leaves (see the scaleEffect below for the full story).
    @State private var occupiedPop: Bool = false

    private var placedDie: PotionShopDie? { gs.placements[nodeIndex] }
    private var dieSelected: Bool { gs.selectedHandIndex != nil }
    private var atCap: Bool { gs.nonFreePlacementCount >= gs.focus }   // JULY 11: FF dice are free — count only focus-costing placements (logic gates already did)
    private var canBePlacedOn: Bool { dieSelected && !atCap && placedDie == nil && !isDraggingFromHere }
    private var isDraggingDie: Bool { gs.draggedDie != nil }
    private var canReceiveDrop: Bool {
        isDraggingDie && !atCap && placedDie == nil && !isDraggingFromHere
    }
    private var isHovered: Bool {
        gs.hoveredNodeIndex == nodeIndex && !isDraggingFromHere
    }
    private var isInPreview: Bool {
        // Hover reach preview OR (JULY 2, late night) a placed boost's
        // standing charge: empty nodes in a placed boost's reach keep
        // pulsing until dice fill them. Same glow/frames, same pulse —
        // the onChange(of: isInPreview) loop drives both automatically.
        gs.previewAffectedNodes.contains(nodeIndex)
            || gs.boostChargedNodes.contains(nodeIndex)
    }

    // ─── GLOW APPEARANCE ─────────────────────────────────────────
    // State priority (highest wins):
    //   1. Hovered drop target        → bright yellow, biggest glow
    //   2. Tap-place candidate         → softer yellow
    //   3. In the reach preview        → cyan ("this die would affect me")
    //   4. Has die locked in           → subtle die-tinted glow
    //   5. Nothing                     → no glow

    /// JULY 2, 2026 (night, FIXED same night): how much this node grows
    /// while a die sits on it. RELATIVE to the node's empty size —
    /// 1.00 = no change (regardless of what "All Nodes Size ×" is set
    /// to), 1.15 = grows 15% when a die lands. The original version
    /// treated this as an ABSOLUTE scale, so raising the empty size
    /// made placement SHRINK the node (the "swiped into the node"
    /// animation bug).
    private var occupiedGrowth: CGFloat {
        CGFloat(PotionShopLayoutConfig.shared.nodeOccupiedScale)
    }

    /// JULY 2, 2026 (night): true when the player has drawn node_glow1… frames.
    /// When frames exist, the reach preview plays THEM and the built-in
    /// cyan shadow glow steps aside (for the preview state only — the
    /// yellow drop-target and placed-die glows are unaffected).
    private var hasGlowFrames: Bool {
        PotionShopNodeGlowAssets.frameCount() > 0
    }

    private var glowColor: Color {
        if isHovered && canReceiveDrop { return Color.yellow }
        if canBePlacedOn               { return Color.yellow }
        if isInPreview {
            // Hand-drawn glow frames replace the shadow glow (July 2).
            if hasGlowFrames { return .clear }
            // Reach-preview color (Request 7) — tunable in
            // PotionShopNodeGlowTuning, optionally tinted by the die.
            if PotionShopNodeGlowTuning.tintPreviewWithDieColor,
               let dragged = gs.draggedDie {
                return dragged.type.color
            }
            return PotionShopNodeGlowTuning.previewColor
        }
        if let die = placedDie         { return die.type.color }
        return .clear
    }

    private var glowRadius: CGFloat {
        if isHovered && canReceiveDrop { return 20 }
        if canBePlacedOn               { return 12 }
        if isInPreview                 { return hasGlowFrames ? 0 : PotionShopNodeGlowTuning.previewGlowRadius }
        if placedDie != nil            { return 9 }
        return 0
    }

    private var glowOpacity: Double {
        if isHovered && canReceiveDrop { return 1.0 }
        if canBePlacedOn               { return 0.75 }
        if isInPreview {
            // Pulse between min and max opacity while in the reach preview.
            guard PotionShopNodeGlowTuning.pulseEnabled else { return 0.85 }
            let lo = PotionShopNodeGlowTuning.pulseOpacityMin
            let hi = PotionShopNodeGlowTuning.pulseOpacityMax
            return lo + (hi - lo) * previewPulse
        }
        if placedDie != nil            { return 0.65 }
        return 0.0
    }

    /// Node-art breathing scale while in the reach preview (1.0 otherwise).
    private var previewScale: CGFloat {
        guard isInPreview, PotionShopNodeGlowTuning.pulseEnabled else { return 1.0 }
        let extra = PotionShopNodeGlowTuning.pulseScaleMax - 1.0
        return 1.0 + extra * CGFloat(previewPulse)
    }

    var body: some View {
        ZStack {
            // Invisible hit area (sets the ZStack's overall size)
            Rectangle()
                .fill(Color.clear)
                .frame(
                    width: PotionShopCauldronLayout.nodeHitArea * visualScale,
                    height: PotionShopCauldronLayout.nodeHitArea * visualScale
                )

            // ━━━ NODE ART: chalk OR glow frames (JULY 2, re-rigged) ━━
            // Your node_glow1…N frames are a GLOWING VERSION of the
            // chalk circle, so while this node is lit (hover reach or a
            // placed boost's charge) the frames REPLACE potion_node —
            // rendered in the exact same slot, same frame, same
            // scaling — instead of stacking on top of it. Empty/unlit
            // moments show the normal chalk art. Because both live in
            // this one slot, every size treatment (All Nodes ×,
            // per-node ×, Occupied Growth spring, preview breathing)
            // applies to chalk and glow identically.
            Group {
                if isInPreview, hasGlowFrames {
                    TimelineView(.animation) { timeline in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        let count = PotionShopNodeGlowAssets.frameCount()
                        let frame = Int(t * max(0.1, PotionShopNodeGlowTuning.glowFrameFPS)) % count
                        // JULY 2, 2026 (memory): downsample-cached — the
                        // SwiftUI Image(name) initializer decoded full-res.
                        if let glowImg = PotionShopImageLoader.loadDisplayImage(
                            named: "node_glow\(frame + 1)",
                            displaySize: PotionShopCauldronLayout.nodeVisible * visualScale) {
                            Image(uiImage: glowImg)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } else {
                    nodeBackground
                }
            }
            .frame(
                width: PotionShopCauldronLayout.nodeVisible * visualScale,
                height: PotionShopCauldronLayout.nodeVisible * visualScale
            )
            // Reach-preview breathing (Request 7): node art gently
            // grows/shrinks while in the hovered die's reach.
            .scaleEffect(previewScale)
            // Two stacked shadows = a thicker, softer glow
            .shadow(color: glowColor.opacity(glowOpacity), radius: glowRadius)
            .shadow(color: glowColor.opacity(glowOpacity * 0.55), radius: glowRadius * 0.5)
            .animation(.easeInOut(duration: 0.22), value: isHovered)
            .animation(.easeInOut(duration: 0.22), value: canBePlacedOn)
            .animation(.easeInOut(duration: 0.30), value: placedDie?.id)
            .animation(.easeInOut(duration: 0.18), value: isInPreview)
            .allowsHitTesting(false)  // Gestures live on the outer ZStack

            // ━━━ DIE ON TOP (visual only — no gestures here) ━━━━━━
            // JULY 2, 2026: when the chalk node art exists, the placed die
            // renders at placedDieHugScale so the chalk circle peeks out
            // around it ("hugging" the die). Without chalk art, dice keep
            // the old edge-to-edge sizing.
            let hug: Double = PotionShopImageLoader.loadImage(named: "potion_node") != nil
                ? Double(PotionShopCauldronLayout.placedDieHugScale)
                : 1.0
            if let die = placedDie {
                Group {
                    if isDraggingFromHere {
                        // Drag origin: ghosted die stays put
                        PotionShopPlacedDieView(die: die, visualScale: visualScale * hug, useFaceAsset: gs.currentRoundUses3DDice)
                            .opacity(0.3)
                    } else if die.type == .magic,
                              let partnerNode = PotionShopBoard.mirrorNode(of: nodeIndex),
                              let partnerDie = gs.placements[partnerNode],
                              partnerDie.type != .magic {
                        // JULY 4 (evening 2 · memory v3): a placed MIRROR die
                        // crossfades between its own art and the mirrored
                        // die's — via a repeatForever OPACITY animation.
                        // Both die views build ONCE; only opacity animates
                        // (the TimelineView version rebuilt them + their
                        // image lookups every frame).
                        ZStack {
                            PotionShopPlacedDieView(die: die, visualScale: visualScale * hug, useFaceAsset: gs.currentRoundUses3DDice)
                                .opacity(mirrorFade ? 0.0 : 1.0)
                            PotionShopPlacedDieView(
                                die: PotionShopDie(
                                    id: die.id + "_mirror_ghost",
                                    type: partnerDie.type,
                                    tier: partnerDie.tier,
                                    value: partnerDie.value
                                ),
                                visualScale: visualScale * hug,
                                useFaceAsset: false   // ghost always wears its TYPE art
                            )
                            .opacity(mirrorFade ? 1.0 : 0.0)
                        }
                        .animation(.easeInOut(duration: 1.75).repeatForever(autoreverses: true), value: mirrorFade)
                        .onAppear { mirrorFade = true }
                        .matchedGeometryEffect(
                            id: die.id,
                            in: diceFlight,
                            properties: [.position, .size]
                        )
                    } else {
                        // Locked-in die, scaled down so node frame shows
                        // around it as a "socket".
                        PotionShopPlacedDieView(die: die, visualScale: visualScale * hug, useFaceAsset: gs.currentRoundUses3DDice)
                            .matchedGeometryEffect(
                                id: die.id,
                                in: diceFlight,
                                properties: [.position, .size]
                            )
                    }
                }
                .allowsHitTesting(false)  // Gestures live on the outer ZStack
                // JUNE 20, 2026: REALIZED-VALUE PREVIEW. Show the die's FINAL
                // number after boosts/bonuses (clean — e.g. "7", not "3+4").
                // Only for non-boost dice (boosts have no output of their own).
                // Reads the live brew preview keyed by this node.
                if die.type != .boost,
                   die.type != .magic,   // JULY 4 (evening 2): the mirror shows no value badge
                   !gs.isAnimating,
                   let realized = gs.livePreview.nodeValues[nodeIndex],
                   !isDraggingFromHere {
                    // JUNE 20, 2026: positioned as a notification badge at the
                    // node's upper-RIGHT corner (was below-center, which got
                    // hidden behind the node beneath it). overlay alignment +
                    // small outward offset keeps it clear of neighbors.
                    Text("\(realized)")
                        .font(Font.gameScore(size: 18))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.85), radius: 1, x: 0, y: 1)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(
                            Capsule().fill(die.type.color.opacity(0.98))
                        )
                        .overlay(Capsule().stroke(.white.opacity(0.85), lineWidth: 1.5))
                        .fixedSize()
                        .offset(x: 16 * visualScale, y: -16 * visualScale)
                        .allowsHitTesting(false)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(50)
                }
            }
            // ─── JULY 4, 2026 (rev 3 — user correction): EMPTY nodes in a
            // placed boost's reach show the "+N" they WOULD receive, blue,
            // dead center ("place a die here, it gets +N"). Rendered as the
            // LAST sibling of this node's ZStack, so it sits ON TOP of the
            // chalk frame AND the node_glow1…N frames.
            if placedDie == nil, !gs.isAnimating {
                // JULY 4 (evening 2): the "+N" now ALSO appears during a
                // boost drag — same trigger, same moment as the node_glow
                // reach preview (previewAffectedNodes) — plus the standing
                // charge from already-placed boosts (potentialBoostAt).
                let placedPotential = gs.potentialBoostAt(node: nodeIndex)
                let hoverPotential: Int = {
                    guard let dragged = gs.draggedDie, dragged.type == .boost,
                          gs.previewAffectedNodes.contains(nodeIndex) else { return 0 }
                    return dragged.value + dragged.ruleBonus
                }()
                let potential = placedPotential + hoverPotential
                if potential > 0 {
                    // Brighter blue, NO white border, breathing ±8% via a
                    // repeatForever animation (memory v3: no per-frame body).
                    Text("+\(potential)")
                        .font(Font.gameScore(size: 20 * visualScale))
                        .foregroundColor(Color(red: 0.13, green: 0.66, blue: 1.0))
                        .scaleEffect(plusPulse ? 1.08 : 0.92)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: plusPulse)
                        .onAppear { plusPulse = true }
                        .allowsHitTesting(false)
                        .zIndex(48)
                }
            }
        }
        // ━━━ ALL GESTURES LIVE HERE on the full hit area ━━━━━━━━━
        // This means anywhere inside the node area is grabbable —
        // you can tap or drag from anywhere within the frame, not
        // only inside the small visible die.
        // JULY 2, 2026 (night, RE-FIXED): OCCUPIED GROWTH. The first
        // version used `.animation(.spring, value: placedDie != nil)`,
        // which made SwiftUI apply that spring to EVERYTHING changing in
        // this node the moment a die landed — including the die's
        // matched-geometry flight — producing the "swiped into the node"
        // motion even when the growth was 1.0. Now the growth lives on
        // its own @State (occupiedPop) flipped inside its OWN
        // withAnimation transaction, so ONLY the scale springs; the
        // die's original snap-in animation is untouched. Growth of 1.00
        // = the scaleEffect never changes = zero effect on anything.
        .scaleEffect(occupiedPop ? occupiedGrowth : 1.0)
        .onChange(of: placedDie != nil) { _, occupied in
            withAnimation(.spring(response: 0.32, dampingFraction: 0.62)) {
                occupiedPop = occupied
            }
        }
        .onAppear {
            occupiedPop = (placedDie != nil)  // no animation on first render
        }
        .contentShape(Rectangle())
        // Reach-preview pulse loop (Request 7): when this node enters the
        // hovered die's reach, oscillate previewPulse 0↔1 forever; when it
        // leaves, settle back to rest without animation residue.
        .onChange(of: isInPreview) { _, nowInPreview in
            guard PotionShopNodeGlowTuning.pulseEnabled else { return }
            if nowInPreview {
                previewPulse = 0.0
                withAnimation(
                    .easeInOut(duration: PotionShopNodeGlowTuning.pulseHalfPeriod)
                    .repeatForever(autoreverses: true)
                ) {
                    previewPulse = 1.0
                }
            } else {
                withAnimation(.easeOut(duration: 0.15)) {
                    previewPulse = 1.0
                }
            }
        }
        .onTapGesture {
            // June 12, 2026: with the layout editor open, tapping a node
            // jumps the editor to the Fine-Tune tab with THIS node selected
            // (gameplay tap-to-place is suspended while editing).
            if PotionShopLayoutConfig.shared.layoutEditorIsOpen {
                PotionShopEditorHistory.shared.jumpRequest =
                    PotionShopEditorJump(target: .fineTune, nodeIndex: nodeIndex)
                return
            }
            guard !gs.isAnimating, !isDraggingFromHere else { return }
            if placedDie != nil {
                // Tap on a placed die → remove back to tray
                withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                    gs.unplaceDie(nodeIndex)
                }
            } else {
                // Tap on empty node → place currently-selected die
                withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                    gs.tapNode(nodeIndex)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged { value in
                    // June 12, 2026: editor open → drag moves the NODE
                    // itself (writes perNodeOffsets, same value the
                    // Fine-Tune sliders edit) instead of dragging dice.
                    if PotionShopLayoutConfig.shared.layoutEditorIsOpen {
                        let cfg = PotionShopLayoutConfig.shared
                        guard nodeIndex < cfg.perNodeOffsets.count else { return }
                        if !editorNodeDrag.active {
                            editorNodeDrag.begin(
                                label: "node \(nodeIndex)",
                                readX: { cfg.perNodeOffsets[nodeIndex].x },
                                applyX: { cfg.perNodeOffsets[nodeIndex].x = $0 },
                                readY: { cfg.perNodeOffsets[nodeIndex].y },
                                applyY: { cfg.perNodeOffsets[nodeIndex].y = $0 }
                            )
                        }
                        cfg.perNodeOffsets[nodeIndex].x = editorNodeDrag.startX + value.translation.width
                        cfg.perNodeOffsets[nodeIndex].y = editorNodeDrag.startY + value.translation.height
                        return
                    }
                    // Drag is only meaningful when a die lives here
                    guard placedDie != nil, !gs.isAnimating else { return }
                    if !isDraggingFromHere {
                        isDraggingFromHere = true
                        gs.startDraggingFromNode(nodeId: nodeIndex)
                    }
                    gs.nodeDragLocation = value.location
                    gs.updateDragHoverPosition(value.location)
                }
                .onEnded { value in
                    // June 12, 2026: end of an editor node-move drag.
                    if PotionShopLayoutConfig.shared.layoutEditorIsOpen {
                        editorNodeDrag.end()
                        return
                    }
                    guard placedDie != nil, !gs.isAnimating else {
                        gs.nodeDragLocation = nil
                        isDraggingFromHere = false
                        gs.cancelNodeDrag()
                        return
                    }

                    // Tray drop zone is the brown panel grown upward by
                    // `trayDropZoneTopExtension` so a player can release a
                    // bit above the tray and still land it.
                    let droppedInTray = gs.trayDropZone.contains(value.location)
                    let targetNodeId = gs.findNodeAtPosition(value.location)
                    let canDropOnNode = targetNodeId != nil &&
                                        targetNodeId != nodeIndex &&
                                        gs.placements[targetNodeId!] == nil

                    if droppedInTray {
                        // Drag back to the dice tray → unplace into whichever
                        // open slot the player released over (or back to the
                        // die's original slot if the release wasn't over an
                        // empty slot).
                        //
                        // Why this looks the way it does:
                        //   • matchedGeometryEffect's default transition does
                        //     an opacity crossfade between source (placed
                        //     die) and destination (tray die). That's the
                        //     fade the user saw.
                        //   • `withTransaction(disablesAnimations: true)`
                        //     forces the matched effect to SNAP — no fade,
                        //     no slide. The die teleports into the slot.
                        //   • A separate one-shot pop animation runs on the
                        //     tray die's `.onAppear` (gated by
                        //     `gs.diceToPopIds`) to give the landing a
                        //     satisfying scale punch.
                        let targetSlot = gs.findEmptyTraySlot(at: value.location)
                        if let dieId = gs.placements[nodeIndex]?.id {
                            gs.diceToPopIds.insert(dieId)
                        }
                        var snap = Transaction()
                        snap.disablesAnimations = true
                        withTransaction(snap) {
                            gs.unplaceDie(nodeIndex, toSlot: targetSlot)
                            gs.nodeDragLocation = nil
                            gs.cancelNodeDrag()
                        }
                        isDraggingFromHere = false
                    } else if canDropOnNode, let target = targetNodeId {
                        withAnimation(.spring(response: 0.20, dampingFraction: 0.8)) {
                            if let die = gs.placements[nodeIndex] {
                                gs.placements[nodeIndex] = nil
                                gs.placements[target] = die
                            }
                            gs.nodeDragLocation = nil
                            gs.cancelNodeDrag()
                        }
                        isDraggingFromHere = false
                    } else {
                        // Invalid drop → die snaps back to its source node
                        // (animated from finger position via the matched
                        // effect, since the placedDie view on the source
                        // node still has the same matched id).
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            gs.nodeDragLocation = nil
                            gs.cancelNodeDrag()
                        }
                        isDraggingFromHere = false
                    }
                }
        )
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        let frame = geometry.frame(in: .global)
                        globalFrame = frame
                        gs.nodePositions[nodeIndex] = frame
                    }
                    .onChange(of: geometry.frame(in: .global)) { oldValue, newValue in
                        globalFrame = newValue
                        gs.nodePositions[nodeIndex] = newValue
                    }
            }
        )
        .disabled(gs.isAnimating && placedDie == nil)
    }

    // ─── NODE BACKGROUND ────────────────────────────────────────
    // Your hand-drawn node art. If the asset "potion_node" is not
    // found, falls back to a parchment-colored rounded rectangle
    // so nothing breaks until your art is added.
    @ViewBuilder
    private var nodeBackground: some View {
        if let nodeImage = PotionShopImageLoader.loadDisplayImage(
            named: "potion_node",
            displaySize: PotionShopCauldronLayout.nodeVisible * visualScale) {
            Image(uiImage: nodeImage)
                .resizable()
                .scaledToFit()
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.95, green: 0.87, blue: 0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(red: 0.55, green: 0.40, blue: 0.20).opacity(0.7), lineWidth: 1)
                )
        }
    }
}

// MARK: - Placed die view (used inside a node)

struct PotionShopPlacedDieView: View {
    let die: PotionShopDie
    var visualScale: Double = 1.0  // Visual-only scale
    /// When true (Day 2 R2), the placed die renders the asset from the
    /// shared value→asset mapping (`PotionShop3DDiceAssetMap`), matching the
    /// 3D cube. When false (default, every other round), uses the die's TYPE
    /// asset as before.
    var useFaceAsset: Bool = false

    var body: some View {
        // Pick asset source. When 3D-dice mode is active, read from the
        // SHARED faceValue field that the cube also targets — so the picture
        // on the cube and the picture on the placed die are guaranteed to
        // match. In every other round, use the die's TYPE asset as before.
        // JULY 4, 2026: the MAGIC die always shows its own art (die_magic)
        // — the legacy face-value map predates it and would show another
        // type's picture.
        let assetName = (useFaceAsset && die.type != .magic)
            ? PotionShop3DDiceAssetMap.assetName(forValue: die.faceValue)
            : die.type.assetName

        // Try to load die face image, fallback to colored square
        // JULY 4 (memory v3): budgeted load at node display size.
        if let dieImage = PotionShopImageLoader.loadDisplayImage(
            named: assetName,
            displaySize: PotionShopCauldronLayout.nodeVisible * visualScale
        ) {
            ZStack {
                Image(uiImage: dieImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: PotionShopCauldronLayout.nodeVisible * visualScale,
                        height: PotionShopCauldronLayout.nodeVisible * visualScale
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Die value overlaid on center (center 30% kept blank on art)
                Text(die.type == .magic ? "X" : "\(die.value)")   // JULY 4: mirror die shows "X"
                    .font(Font.gameScore(size: 13 * visualScale))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    .offset(y: 3 * visualScale)
            }
        } else {
            // Placeholder colored square with value
            RoundedRectangle(cornerRadius: 4)
                .fill(die.type.color)
                .frame(
                    width: PotionShopCauldronLayout.nodeVisible * visualScale,
                    height: PotionShopCauldronLayout.nodeVisible * visualScale
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(PotionShopTheme.ink, lineWidth: 1.5)
                )
                .overlay(
                    Text(die.type == .magic ? "X" : "\(die.value)")   // JULY 4: mirror die shows "X"
                        .font(Font.gameScore(size: 13 * visualScale))
                        .foregroundColor(.white)
                        .offset(y: 3 * visualScale)
                )
        }
    }
}

// MARK: - BREW sign-on-a-stake

struct PotionShopBrewSignView: View {
    @Bindable var gs: PotionShopGameState

    private var canBrew: Bool {
        !gs.placements.isEmpty && !gs.isAnimating && gs.phase == .playing
    }

    var body: some View {
        Button {
            Task { @MainActor in
                await gs.doBrew()
            }
        } label: {
            ZStack {
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.78, green: 0.62, blue: 0.40),
                                        Color(red: 0.62, green: 0.46, blue: 0.27)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(red: 0.30, green: 0.18, blue: 0.10), lineWidth: 2)
                            )
                            .frame(width: 70, height: 32)

                        Text("BREW")
                            .font(Font.gameScore(size: 14))
                            .tracking(2)
                            .foregroundColor(canBrew ? Color(red: 0.30, green: 0.18, blue: 0.10) : Color.gray.opacity(0.6))
                    }

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.62, green: 0.46, blue: 0.27),
                                    Color(red: 0.45, green: 0.30, blue: 0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            Rectangle()
                                .stroke(Color(red: 0.30, green: 0.18, blue: 0.10), lineWidth: 1)
                        )
                        .frame(width: 8, height: 70)
                }
                .rotationEffect(.degrees(-12))
                .opacity(canBrew ? 1.0 : 0.6)
                .scaleEffect(canBrew ? 1.0 : 0.95)
            }
            .frame(width: 90, height: 110)
        }
        .disabled(!canBrew)
        .animation(.easeInOut(duration: 0.2), value: canBrew)
    }
}

// MARK: - Dice tray

struct PotionShopDiceTrayView: View {
    @Bindable var gs: PotionShopGameState
    let diceFlight: Namespace.ID
    var dieScale: Double = 1.0  // NEW: Scale multiplier for dice in tray

    var body: some View {
        // Render 5 fixed tray slots (0...4). Each slot looks up the die in
        // `hand` whose `trayIndex` matches the slot; if none, render a dashed
        // placeholder. This keeps the remaining dice in place when one is
        // dragged to the cauldron, instead of HStack-sliding them leftward.
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { slotIndex in
                Group {
                    if let die = gs.hand.first(where: { $0.trayIndex == slotIndex }),
                       let handIdx = gs.hand.firstIndex(where: { $0.id == die.id }) {
                        PotionShopDieButtonView(
                            gs: gs,
                            die: die,
                            index: handIdx,
                            diceFlight: diceFlight,
                            dieScale: dieScale
                        )
                        // JULY 12 (SHAPED HIGHLIGHTS): every tray die
                        // publishes its frame + type group, so the tutorial
                        // can light "all potency dice" wherever they landed.
                        .background(PotionShopPlainFramePublisher(
                            gs: gs,
                            key: "die\(slotIndex)",
                            group: "dice.\(die.type)",
                            style: .reveal   // JULY 12 rev 2: dice REVEAL like everything else — the shaped re-render failed in play (3D cubes have no flat PNG to redraw)
                        ))
                        // JULY 10, 2026 (PLAYTEST V1): FOCUS-FREE dice read
                        // as a gift in the tray — a soft glow + "FREE" pill.
                        // ✏️ Placeholder until you draw FF die art; swap the
                        // pill for your own badge asset whenever ready.
                        .shadow(color: die.isFocusFree ? .white.opacity(0.8) : .clear,
                                radius: die.isFocusFree ? 6 : 0)
                        .overlay(alignment: .top) {
                            if die.isFocusFree {
                                Text("FREE")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1.5)
                                    .background(Capsule().fill(Color.white.opacity(0.95)))
                                    .offset(y: -8)
                                    .allowsHitTesting(false)
                            }
                        }
                    } else {
                        // Empty slot. JULY 2, 2026: the dashed placeholder
                        // outline is GONE (user request) — the slot is now
                        // invisible but keeps its exact frame so the other
                        // dice hold position and node→tray drops still know
                        // where each slot lives.
                        Color.clear
                            .frame(
                                width: PotionShopCauldronLayout.dieSize * dieScale,
                                height: PotionShopCauldronLayout.dieSize * dieScale
                            )
                    }
                }
                // Publish this slot's global frame so a node→tray drag can
                // figure out which open slot the player released over.
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                gs.traySlotPositions[slotIndex] = geometry.frame(in: .global)
                            }
                            .onChange(of: geometry.frame(in: .global)) { _, newValue in
                                gs.traySlotPositions[slotIndex] = newValue
                            }
                    }
                )
            }
        }
        .padding(8)
        .background(
            // JULY 2, 2026: hand-drawn tray art. Draw "dice_tray" in
            // Assets.xcassets (wide canvas, e.g. 1536×512, transparent
            // corners if you want rounded edges) and it replaces the
            // code-drawn brown panel below. No asset = the brown
            // gradient panel stays as the fallback, exactly as before.
            Group {
                if let trayImg = PotionShopImageLoader.loadDisplayImage(
                    named: "dice_tray", displaySize: 380) {
                    Image(uiImage: trayImg)
                        .resizable()  // stretches to the tray panel's size
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.55, green: 0.35, blue: 0.17),
                                    Color(red: 0.42, green: 0.27, blue: 0.14)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(PotionShopTheme.ink, lineWidth: 2)
                        )
                }
            }
        )
        .padding(.horizontal, 14)
        .opacity(gs.isAnimating ? 0.7 : 1.0)
        // Publish the tray's global frame so the node-drag gesture can detect
        // when a placed die is being dragged back here (→ unplace).
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        gs.trayFrame = geometry.frame(in: .global)
                    }
                    .onChange(of: geometry.frame(in: .global)) { _, newValue in
                        gs.trayFrame = newValue
                    }
            }
        )
    }
}

// MARK: - Dice drop-in animation modifier
//
// PHASE 6D: Straight drop, no rotation. Each die starts ~80pt above
// its slot and springs cleanly into place. Triggered via .onAppear
// every time a new die appears in the tray (initial deal, redraw
// after a brew).

struct PotionShopDiceDropInModifier: ViewModifier {
    /// REQUEST 2 (June 12): when false, the die appears INSTANTLY at rest in
    /// its slot — no drop-from-above spring, no fade. Used for dice that are
    /// RETURNING to the tray from a cauldron node so they snap home the same
    /// way dice snap onto nodes. Fresh deals still drop in as before.
    let enabled: Bool

    @State private var dropOffset: CGFloat
    @State private var hasAppeared: Bool = false

    init(enabled: Bool = true) {
        self.enabled = enabled
        // Returning dice start AT their slot (offset 0) so there is no
        // first-frame jump; fresh dice start above and spring down.
        _dropOffset = State(initialValue: enabled ? -PotionShopCauldronLayout.dropInOffset : 0)
    }

    func body(content: Content) -> some View {
        content
            .offset(y: dropOffset)
            .onAppear {
                guard enabled, !hasAppeared else { return }
                hasAppeared = true

                withAnimation(.spring(response: 0.5, dampingFraction: 0.68)) {
                    dropOffset = 0
                }
            }
    }
}

// MARK: - One die in the tray

struct PotionShopDieButtonView: View {
    /// JULY 11, 2026 — HOLD-TO-PEEK: true while the finger holds still on
    /// this die (0.4s); shows the info card. Any movement or release hides
    /// it (movement past 8pt cancels the press; the drag needs 10pt, so
    /// drags never fight the peek).
    @State private var showPeek = false
    /// JULY 13, 2026: invalidation token for the peek card's safety
    /// auto-dismiss (see the long-press handler below).
    @State private var peekToken = 0
    @Bindable var gs: PotionShopGameState
    let die: PotionShopDie
    let index: Int
    let diceFlight: Namespace.ID
    var dieScale: Double = 1.0  // Scale multiplier
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    /// One-shot scale used to play a "landed in tray" pop when the die
    /// returns from the cauldron via drag-to-tray. 1.0 = neutral. Set to
    /// the punch value in `.onAppear` (gated on `gs.diceToPopIds`), then
    /// spring-animated back to 1.0.
    @State private var landPopScale: CGFloat = 1.0

    private var isSelected: Bool { gs.selectedHandIndex == index }
    private var atCap: Bool { gs.nonFreePlacementCount >= gs.focus }   // JULY 11: FF dice are free — count only focus-costing placements (logic gates already did)

    var body: some View {
        let scaledSize = PotionShopCauldronLayout.dieSize * dieScale
        let scaledFontSize = 28 * dieScale
        
        // Day 2 Round 2 uses a vertical reel-spin animation (3D-style).
        // All other rounds use the original static face render.
        Group {
            if PotionShopLayoutConfig.shared.dice3DTest {
                // JULY 17, 2026: 🎲 TEMPORARY TEST — real SceneKit die in
                // this slot. Same footprint, same gestures (the GL canvas
                // never hit-tests), same spinTrigger3D throws, same value
                // badge on top. Toggle lives in the drawer 🎲 tab.
                ZStack {
                    CauldronDie3D(
                        die: die,
                        isSelected: isSelected,
                        size: scaledSize,
                        index: index,
                        spinToken: gs.spinTrigger3D,
                        animateOnAppear: !gs.settledDiceIds.contains(die.id)
                    )
                    PotionShopTrayDieValueBadge(
                        value: die.value,
                        fontSize: scaledFontSize,
                        spinToken: gs.spinTrigger3D,
                        revealAfterSpin: !gs.settledDiceIds.contains(die.id)
                    )
                    .allowsHitTesting(false)
                }
            } else if gs.currentRoundUses3DDice {
                // REQUEST 8 (June 12): the die's brew-math VALUE is now
                // stamped over the cube in the tray, same style as the
                // value shown on a placed die. It hides during the spin
                // and fades in once the cube settles (see
                // PotionShopTrayDieValueBadge for the timing knobs).
                ZStack {
                    DieFaceView3D(
                        die: die,
                        isSelected: isSelected,
                        size: scaledSize,
                        fontSize: scaledFontSize,
                        dieScale: dieScale,
                        index: index,
                        spinToken: gs.spinTrigger3D,
                        // Dice returning from the cauldron (id in settledDiceIds)
                        // should appear at rest in their slot — NOT replay the
                        // drop/spin animation. Fresh deals + reroll button both
                        // clear the set, so those still animate as before.
                        animateOnAppear: !gs.settledDiceIds.contains(die.id)
                    )

                    PotionShopTrayDieValueBadge(
                        value: die.value,
                        fontSize: scaledFontSize,
                        spinToken: gs.spinTrigger3D,
                        // Returning dice didn't spin → show the number instantly.
                        revealAfterSpin: !gs.settledDiceIds.contains(die.id)
                    )
                    .allowsHitTesting(false)
                }
            } else {
                // Try to load die face image, fallback to colored square
                // JULY 4 (memory v3): budgeted load at tray display size.
                if let dieImage = PotionShopImageLoader.loadDisplayImage(named: die.type.assetName, displaySize: 96) {
                    ZStack {
                        Image(uiImage: dieImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: scaledSize, height: scaledSize)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isSelected ? Color.yellow : Color.white.opacity(0.5), lineWidth: isSelected ? 3 : 1.5)
                            )

                        // Die value overlaid on center
                        Text(die.type == .magic ? "X" : "\(die.value)")   // JULY 4: mirror die shows "X"
                            .font(Font.gameScore(size: scaledFontSize))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                            .offset(y: 3 * dieScale)
                    }
                } else {
                    // Placeholder colored square with text
                    VStack(spacing: 1) {
                        Text(die.type.abbr)
                            .font(Font.gameUI(size: 9 * dieScale))
                        Text(die.type == .magic ? "X" : "\(die.value)")   // JULY 4: mirror die shows "X"
                            .font(Font.gameScore(size: 14 * dieScale))
                    }
                    .foregroundColor(.white)
                    .frame(width: scaledSize, height: scaledSize)
                    .background(die.type.color)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(isSelected ? Color.yellow : Color.white.opacity(0.5), lineWidth: isSelected ? 3 : 1.5)
                    )
                }
            }
        }
        .matchedGeometryEffect(
            id: die.id,
            in: diceFlight,
            properties: [.position, .size]
        )
        .scaleEffect(isDragging ? 1.15 : 1.0)
        .scaleEffect(landPopScale)
        .opacity(atCap && !isSelected ? 0.5 : 1.0)
        .offset(dragOffset)
        .zIndex((isDragging || showPeek) ? 1000 : 0)
        .shadow(
            color: isDragging ? die.type.color.opacity(0.5) : .clear,
            radius: isDragging ? 12 : 0
        )
        // REQUEST 2 (June 12): dice RETURNING from the cauldron (id in
        // settledDiceIds) skip the drop-from-above animation entirely and
        // appear instantly in their slot — combined with the
        // disablesAnimations transaction in the node-drag release, this is
        // a clean SNAP (same feel as snapping onto a node), with only the
        // landPopScale punch on top. Fresh deals still drop in.
        .modifier(PotionShopDiceDropInModifier(
            enabled: !gs.settledDiceIds.contains(die.id)
        ))
        // "Just landed in tray" pop. The drag-from-node flow inserts this
        // die's id into `gs.diceToPopIds` before snapping it home; here we
        // consume that signal and play a quick scale punch that springs
        // back to normal — gives the snap some weight without re-introducing
        // the matchedGeometryEffect crossfade.
        .onAppear {
            if gs.diceToPopIds.contains(die.id) {
                gs.diceToPopIds.remove(die.id)
                landPopScale = 1.35
                withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                    landPopScale = 1.0
                }
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    if !gs.isAnimating {
                        if !isDragging {
                            isDragging = true
                            // JULY 13, 2026: starting a drag clears any
                            // lingering peek card (third escape hatch —
                            // see the long-press safety timer above).
                            // JULY 14: except during "The Die Card" step.
                            if showPeek && !gs.tutHoldPeekOpen { showPeek = false }
                            // JULY 2, 2026 FIX (hover glow): register the drag
                            // with the game state. The yellow drop-target glow,
                            // the cyan reach preview, AND smart chalk lines all
                            // key off gs.draggedDie — the offset-based tray drag
                            // rewrite had stopped setting it, so tray→node drags
                            // showed no glow at all (node→node drags, which set
                            // it via startDraggingFromNode, still worked).
                            // Safe: the floating drag overlay requires
                            // nodeDragLocation/draggedFromNode (both stay nil
                            // for tray drags), and tryDropDieAtPosition reads
                            // the hand directly — no double-render, no drop
                            // behavior change.
                            gs.draggedDie = die
                        }
                        dragOffset = value.translation
                        
                        // Update hover state
                        gs.updateDragHoverPosition(value.location)
                    }
                }
                .onEnded { value in
                    if !gs.isAnimating {
                        // Try to place the die
                        let placed = gs.tryDropDieAtPosition(value.location, dieIndex: index)
                        
                        if placed {
                            // Reset offset (matchedGeometryEffect will animate)
                            dragOffset = .zero
                        } else {
                            // Return to original position
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                dragOffset = .zero
                            }
                        }
                    }
                    
                    isDragging = false
                    gs.hoveredNodeIndex = nil
                    // JULY 2, 2026 FIX: release the drag registration so the
                    // glow and smart lines settle when the finger lifts.
                    gs.draggedDie = nil
                }
        )
        .onTapGesture {
            // JULY 13, 2026: a tap anywhere on the die also clears a
            // lingering peek card (second escape hatch).
            if showPeek && !gs.tutHoldPeekOpen { withAnimation(.easeOut(duration: 0.15)) { showPeek = false } }
            // Tap gesture (original behavior - select/deselect)
            if !gs.isAnimating && !isDragging {
                gs.selectHand(index)
            }
        }
        // JULY 11, 2026 — HOLD-TO-PEEK (quality of life): hold a tray die
        // still for 0.4s → a parchment card describes it (name, faces,
        // what it does, FREE note). Release or move → gone. Quick taps
        // still select; drags still place.
        .onLongPressGesture(minimumDuration: 0.4, maximumDistance: 8) {
            HapticManager.shared.diePlaced()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) { showPeek = true }
            // JULY 14, 2026: the tutorial's peek gate counts HERE (the
            // card popping IS the inspect), not on release — the July 13
            // safety timer could clear showPeek during a long read-the-
            // card hold, which silently skipped the release-time bump
            // and hung the tutorial at "Inspect a Die" (user report).
            gs.totalPeeks += 1
            // JULY 15: alias THIS die as "peekedDie" so the Die Card
            // step's highlight follows whichever die the player chose
            // (fixed manual reveals can't — they sit where they're put).
            // group stripped so "dice.*" wildcard steps don't double-hit.
            if var d = gs.tutHighlights["die\(index)"] {
                d.group = nil
                gs.tutHighlights["peekedDie"] = d
            }
            // JULY 13, 2026: SAFETY AUTO-DISMISS. SwiftUI can drop the
            // onPressingChanged(false) callback when the finger slides
            // off mid-hold or the system steals the gesture — the card
            // then stuck forever (user report). A token-checked timer
            // guarantees it always clears; normal release still hides
            // it instantly below.
            peekToken += 1
            let token = peekToken
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if showPeek && token == peekToken && !gs.tutHoldPeekOpen {
                    withAnimation(.easeOut(duration: 0.2)) { showPeek = false }
                }
            }
        } onPressingChanged: { pressing in
            if !pressing {
                // (JULY 14: the tutorial's peek count moved to the pop
                // handler above — release only hides the card now, and
                // NOT during "The Die Card" step, which keeps it open
                // until the player taps to continue.)
                if !gs.tutHoldPeekOpen {
                    withAnimation(.easeOut(duration: 0.15)) { showPeek = false }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showPeek {
                PotionShopDiePeekCard(
                    die: die,
                    faces: gs.run.deck.first(where: { $0.type == die.type })?.effectiveFaces)
                    .offset(y: -(PotionShopCauldronLayout.dieSize * dieScale + 16))
                    // JULY 14, 2026: publish the card's frame so the
                    // tutorial's "The Die Card" step can cut its highlight
                    // hole around it (same pattern as brewSpoon above).
                    .background(GeometryReader { g in
                        Color.clear
                            .onAppear { gs.publishTutHighlight("peekCard", frame: g.frame(in: .global), image: nil, style: .reveal) }
                            .onChange(of: g.frame(in: .global)) { _, fr in
                                gs.publishTutHighlight("peekCard", frame: fr, image: nil, style: .reveal)
                            }
                            .onDisappear {
                                gs.tutHighlights.removeValue(forKey: "peekCard")
                                gs.tutHighlights.removeValue(forKey: "peekedDie")   // JULY 15
                            }
                    })
                    .transition(.scale(scale: 0.85, anchor: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: gs.tutHoldPeekOpen) { _, open in
            // JULY 14: "The Die Card" step ended (player tapped) — close
            // the card that was being held open for reading.
            if !open && showPeek {
                withAnimation(.easeOut(duration: 0.2)) { showPeek = false }
            }
        }
        .disabled(gs.isAnimating)
    }
}

// MARK: - Hold-to-peek info card (July 11, 2026)
//
// The die dossier: name, its ACTUAL current faces (stays truthful as
// lanes upgrade), a one-line blurb, and special notes (FREE, mirror).
// Rendered above the held die; never intercepts touches.

struct PotionShopDiePeekCard: View {
    let die: PotionShopDie          // the HAND die (rolled value + type)
    let faces: [Int]?               // the lane's current faces, from the deck

    /// JULY 14: cheap existence probe (8px budgeted decode, loader-cached)
    /// — the code border/shadow only draw when there's no hand-drawn art.
    private var hasCardArt: Bool {
        PotionShopImageLoader.loadDisplayImage(named: "ps_peekcard", displaySize: 8) != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(die.type.color)
                    .frame(width: 12, height: 12)
                Text(die.type.label)
                    .font(Font.gameUI(size: 14))
                    .foregroundColor(.white)
                if die.isFocusFree == true {
                    Text("FREE")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.horizontal, 5).padding(.vertical, 1.5)
                        .background(Capsule().fill(Color.white.opacity(0.95)))
                }
            }
            if die.type != .magic, let faces {
                HStack(spacing: 2) {
                    ForEach(Array(faces.enumerated()), id: \.offset) { _, v in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(die.type.color.opacity(0.9))
                            .frame(width: 15, height: 15)
                            .overlay(Text("\(v)")
                                .font(Font.gameScore(size: 10))
                                .foregroundColor(.white))
                            .overlay(RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.white.opacity(0.6), lineWidth: 0.7))
                    }
                }
            }
            Text(die.type.peekBlurb + (die.isFocusFree == true ? "\nCosts NO focus to place." : ""))
                .font(Font.gameUI(size: 11))
                .foregroundColor(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(width: 200, alignment: .leading)
        .background(
            // JULY 14, 2026: HAND-DRAWN CARD HOOK (pause-menu pattern).
            // Draw the whole card as ONE transparent PNG named
            // "ps_peekcard" (Assets.xcassets) — frame, background,
            // decorations. The faces/values/text stay code-drawn on
            // top (they change per die). Until the art exists, this
            // code-drawn card renders — and doubles as the DRAWING
            // TEMPLATE: screenshot it, draw over it in Procreate at
            // the same proportions, export. Suggest ~800×H px, any
            // aspect — the art stretches to the card's live size.
            GeometryReader { g in
                if let art = PotionShopImageLoader.loadDisplayImage(named: "ps_peekcard", displaySize: max(g.size.width, g.size.height)) {
                    Image(uiImage: art)
                        .resizable()
                        .frame(width: g.size.width, height: g.size.height)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.13, green: 0.11, blue: 0.16).opacity(0.96))
                }
            }
        )
        .overlay(
            // JULY 14: fallback-only — the drawn card supplies its own frame.
            RoundedRectangle(cornerRadius: 10)
                .stroke(hasCardArt ? Color.clear : die.type.color.opacity(0.7), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(hasCardArt ? 0.25 : 0.45), radius: 8, y: 3)
    }
}

private extension PotionShopDieType {
    /// One-liners for the hold-to-peek card. ✏️ Edit freely — pure copy.
    var peekBlurb: String {
        switch self {
        case .potency:   return "Damages the customer's order — the heart of every brew."
        case .heal:      return "Restores your composure. Only ONE heal counts per turn."
        case .shield:    return "Adds shield — soaks customer hits before your composure does."
        case .stability: return "Feeds the hearth. Dead fire = half-strength brews."
        case .boost:     return "Adds its value to every die it touches. Placement matters!"
        case .magic:     return "The mirror — copies whatever die sits directly across the cauldron."
        }
    }
}

// MARK: - Tray die value badge (Request 8, June 12)
//
// The numeric brew-math value (`die.value`) stamped over the 3D cube in
// the tray — same white-with-shadow style as the value shown on a placed
// die, so the number "travels" with the die from tray to node.
//
// Reveal timing: the number stays hidden while the cube is dropping and
// spinning, then fades in once the cube settles. Re-hides + replays every
// time the dice re-roll (spinToken bump = fresh deal, post-brew redraw, or
// the editor's SPIN button).

struct PotionShopTrayDieValueBadge: View {
    let value: Int
    let fontSize: CGFloat
    /// Bumped on every re-roll; restarts the hide→reveal cycle.
    let spinToken: Int
    /// true  → wait `revealDelay` (cube is playing its drop/spin), then fade in.
    /// false → show immediately (die returned from the cauldron, no spin).
    let revealAfterSpin: Bool

    // ─── Tuning knobs ───────────────────────────────────────────
    /// Seconds after a re-roll before the number fades in.
    /// Baked June 27, 2026 (was 1.30 → 1.10).
    static let revealDelay: Double = 1.10
    /// Fade-in duration once the delay elapses.
    /// Baked June 27, 2026 (was 0.20 → 0.06).
    static let revealFadeDuration: Double = 0.10
    // ────────────────────────────────────────────────────────────

    @State private var badgeOpacity: Double = 0.0

    var body: some View {
        Text("\(value)")
            .font(Font.gameScore(size: fontSize))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
            .offset(y: 10)
            .opacity(badgeOpacity)
            .onAppear { runReveal() }
            .onChange(of: spinToken) {
                runReveal()
            }
    }

    private func runReveal() {
        if !revealAfterSpin {
            badgeOpacity = 1.0
            return
        }
        badgeOpacity = 0.0
        DispatchQueue.main.asyncAfter(
            deadline: .now() + PotionShopTrayDieValueBadge.revealDelay
        ) {
            withAnimation(.easeOut(duration: PotionShopTrayDieValueBadge.revealFadeDuration)) {
                badgeOpacity = 1.0
            }
        }
    }
}

// MARK: - 3D Dice (Day 2 Round 2 only)
//
// REAL 3D cube (SceneKit) spinning around the X axis like a slot-machine reel.
// Multiple revolutions, motion blur on the camera during the fast phase, then
// decelerates and lands so `die.value` is up. Settles with a scale bounce.
//
// Faces are pre-rendered to match the existing 2D dice aesthetic: each face
// is the die-type color with the value number stamped in white. The cube
// keeps its 3D volume throughout the rotation (never goes flat).

struct DieFaceView3D: View {
    /// Per-die index stagger — die N starts spinning N × this many seconds after die 0.
    /// Iteration 2 (June 10): set to 0 so all dice drop / bounce / roll in sync.
    /// Bump back to 0.04 (or higher) to bring back the slot-machine cascade feel.
    static let spinStaggerStep: Double = 0.06    // simultaneous start across all dice

    let die: PotionShopDie
    let isSelected: Bool
    let size: CGFloat
    let fontSize: CGFloat
    let dieScale: Double
    let index: Int
    /// Bumped by reroll3DDice() (and the editor's spin button) every time the
    /// game state re-rolls. Forces the cube to rebuild + replay its animation
    /// even when the re-rolled `faceValue` happens to equal the previous one.
    let spinToken: Int
    /// When false, the cube appears at rest in its slot — no drop, no spin,
    /// no bounce. Used for dice that are returning to the tray from the
    /// cauldron (already-rolled, just re-entering view).
    let animateOnAppear: Bool

    var body: some View {
        // SOURCE OF TRUTH: the cube targets `die.faceValue`, the same field the
        // placed-die view reads when this round renders 3D dice. So whatever
        // graphic the cube lands on is identical to the graphic shown after the
        // die is dragged onto a node. `spinToken` guarantees the spin replays
        // even on a duplicate roll.
        DieSceneView3D(
            targetFace: die.faceValue,
            dieColor: UIColor(die.type.color),
            spinDelay: DieFaceView3D.spinStaggerStep * Double(index),
            spinSession: spinToken,
            animateOnAppear: animateOnAppear
        )
        .frame(width: size, height: size)
        // JUNE 13, 2026 fix: tie the view's IDENTITY to the spin token + face +
        // whether it should animate. When any of these change (a fresh deal or
        // reroll bumps spinToken), SwiftUI tears down the old SCNView and runs
        // makeUIView again → buildScene() → runSlotSpin plays. This guarantees
        // the drop/spin replays every deal even if updateUIView's diff would
        // otherwise short-circuit. (animateOnAppear is folded in so a die that
        // returns to the tray at-rest doesn't get re-identified into a spin.)
        .id("die3d-\(die.id)-\(spinToken)-\(die.faceValue)-\(animateOnAppear ? 1 : 0)")
    }
}

/// SwiftUI wrapper around SCNView.
struct DieSceneView3D: UIViewRepresentable {
    let targetFace: Int
    let dieColor: UIColor
    let spinDelay: Double   // seconds before this die starts spinning (per-die stagger)
    /// Bumped every time the game state re-rolls (reroll3DDice). Forces the
    /// scene to rebuild even when targetFace happens to equal the previous
    /// face, so the spin animation replays on every tap (no "same face = no
    /// spin" bug).
    let spinSession: Int
    /// When false, `buildScene()` skips `runSlotSpin` — the cube is added to
    /// the scene at its rest position (0,0,0, identity rotation) showing the
    /// `targetFace` material camera-facing. Used when a die returns to the
    /// tray from the cauldron: we want it to just BE in its slot, not replay
    /// the full drop-and-spin animation a second time.
    let animateOnAppear: Bool

    /// Coordinator tracks the (session, face) the scene was last built with so
    /// updateUIView can detect a new spin and rebuild.
    final class Coordinator {
        var lastBuiltSession: Int = -1
        var lastBuiltFace: Int = -1
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.scene = buildScene()
        context.coordinator.lastBuiltSession = spinSession
        context.coordinator.lastBuiltFace = targetFace
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Rebuild the scene (→ replay the spin animation) when EITHER the spin
        // session bumped OR the target face changed. Session-change guarantees
        // replays even on duplicate face rolls; face-change guards against any
        // edge case where the game state changed a die's faceValue without
        // bumping the session token.
        let sessionChanged = context.coordinator.lastBuiltSession != spinSession
        let faceChanged = context.coordinator.lastBuiltFace != targetFace
        guard sessionChanged || faceChanged else { return }
        uiView.scene = buildScene()
        context.coordinator.lastBuiltSession = spinSession
        context.coordinator.lastBuiltFace = targetFace
    }

    private func buildScene() -> SCNScene {
        let scene = SCNScene()

        // Camera with motion blur. Closer + wider FOV so the cube fills
        // the entire bounding square of the die's container.
        let camera = SCNCamera()
        camera.fieldOfView = 42
        camera.motionBlurIntensity = 1.0
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 1.85)
        scene.rootNode.addChildNode(cameraNode)

        // Lighting: bright omni from above-right + ambient fill so the cube
        // edges read clearly during rotation
        let key = SCNLight()
        key.type = .omni
        key.intensity = 1100
        let keyNode = SCNNode()
        keyNode.light = key
        keyNode.position = SCNVector3(2, 4, 4)
        scene.rootNode.addChildNode(keyNode)

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 600
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        // Cube with rounded edges so it reads as a die, not a generic block
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.12)

        // Material order: [front (+Z), right (+X), back (-Z), left (-X), top (+Y), bottom (-Y)]
        // We put `targetFace` at the FRONT slot so a pure multiple-of-360° X-axis
        // spin lands the target value facing the camera with zero settle math.
        // The other 5 physical sides are filled from the face pool
        // (PotionShop3DDiceAssetMap.faceSpecs) — they only flash during the
        // spin, so when the pool has more than 6 faces we draw 5 at random,
        // and when it has fewer than 6 we repeat entries to fill the cube.
        var remaining = PotionShop3DDiceAssetMap.allFaceValues
            .filter { $0 != targetFace }
            .shuffled()
        if remaining.isEmpty { remaining = [targetFace] }   // 1-face pool edge case
        while remaining.count < 5 { remaining += remaining } // pad small pools
        let faceOrder = [targetFace] + Array(remaining.prefix(5))
        box.materials = faceOrder.map { face in
            let mat = SCNMaterial()
            mat.diffuse.contents = renderFaceTexture(value: face)
            mat.locksAmbientWithDiffuse = true
            return mat
        }

        let dieNode = SCNNode(geometry: box)
        scene.rootNode.addChildNode(dieNode)

        // Only play the drop/bounce/spin/settle if this is a "fresh roll"
        // appearance. When a die is RETURNING to the tray from the cauldron,
        // animateOnAppear is false and the cube simply sits at rest (default
        // position 0,0,0, identity rotation, targetFace camera-facing).
        if animateOnAppear {
            runSlotSpin(on: dieNode)
        }
        return scene
    }

    /// Load the face texture from the shared value→asset mapping. Both the
    /// cube AND the placed-die view read from this mapping, so the graphic
    /// on the cube's settled face matches the graphic shown when placed on
    /// a node. Falls back to a procedurally-drawn placeholder if the asset
    /// is missing.
    private func renderFaceTexture(value: Int) -> UIImage {
        let mappedName = PotionShop3DDiceAssetMap.assetName(forValue: value)
        // JULY 5, 2026 (memory): budgeted, capped ~1024px texture — a cube
        // face never needs the full drawn canvas, and SceneKit PINS whatever
        // it's given as a material for the life of the scene.
        if let custom = PotionShopImageLoader.loadDisplayImage(named: mappedName, displaySize: 342) {
            return custom
        }
        return fallbackFaceTexture(value: value)
    }

    /// Used only when the named asset isn't found — keeps the cube from being blank.
    private func fallbackFaceTexture(value: Int) -> UIImage {
        let s: CGFloat = 256
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: s, height: s))
        return renderer.image { ctx in
            let cg = ctx.cgContext
            dieColor.setFill()
            cg.fill(CGRect(x: 0, y: 0, width: s, height: s))
            cg.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
            cg.setLineWidth(6)
            cg.stroke(CGRect(x: 8, y: 8, width: s - 16, height: s - 16))

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 160, weight: .heavy),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black.withAlphaComponent(0.55),
                .strokeWidth: -4.0
            ]
            let str = NSAttributedString(string: "\(value)", attributes: attrs)
            let textSize = str.size()
            let rect = CGRect(
                x: (s - textSize.width) / 2,
                y: (s - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            str.draw(in: rect)
        }
    }

    /// "Drop AND spin together" (iteration 6, June 10).
    ///
    /// Drop runs alone first. Once the drop lands, the bounce phases
    /// (overshoot → bounce up → bounce down) run IN PARALLEL with the spin —
    /// so the cube is rolling while it's still settling vertically. Spin
    /// starts `spinStartDelay` seconds after the drop ends.
    ///
    /// Timeline (current values):
    ///   0.00 → DROP starts
    ///   0.13 → DROP ends → bounce sequence + spin start in parallel
    ///   0.14 → SPIN starts (= dropDuration + spinStartDelay)
    ///   0.22 → OVERSHOOT ends (cube at Y=-0.07, still spinning)
    ///   0.32 → BOUNCE UP peak (Y=+0.04, still spinning)
    ///   0.40 → BOUNCE DOWN ends (Y=0, still spinning)
    ///   0.99 → SPIN ends
    ///   1.08 → SETTLE DOWN ends (Y=-0.12)
    ///   1.22 → SETTLE UP ends (Y=0) — done
    private func runSlotSpin(on node: SCNNode) {
        // ── Tuning knobs ─────────────────────────────────────────
        // `dropHeight` is now measured as "how far above the window's top edge
        // the cube's BOTTOM starts." With dropHeight=0 the cube starts JUST
        // off-screen (no overlap with the viewport). Larger values mean the
        // cube starts further off-screen above — longer invisible fall, faster
        // entry into frame at impact.
        let dropHeight: CGFloat = 0.99        // off-screen distance above the window
        let dropDuration: Double = 0.26
        let dropOvershootY: CGFloat = 0.07    // how far PAST Y=0 the drop sinks
        let overshootDuration: Double = 0.09
        let bounceUpY: CGFloat = 0.04         // how high above Y=0 the bounce peaks
        let bounceUpDuration: Double = 0.10
        let bounceDownDuration: Double = 0.08
        let spinDuration: Double = 0.85
        let spinStartDelay: Double = 0.00     // spin starts this many seconds after drop ends
        // Post-spin settle — sequential after the group.
        let settleOvershoot: CGFloat = 0.12
        let settleDownDuration: Double = 0.09
        let settleUpDuration: Double = 0.14
        // ─────────────────────────────────────────────────────────

        // ── Convert dropHeight (off-screen distance) → actual scene Y ──
        // Derived from camera: visibleHalfHeight = cameraZ * tan(FOV/2).
        // With camera at z=1.85 and FOV 42°: ~0.71.
        // Cube is 1.0 tall, so cube's CENTER must be 0.5 above the window edge
        // for the bottom to JUST touch the edge.
        // If you change the camera (z or FOV), update visibleTopY accordingly.
        let visibleTopY: CGFloat = 0.71
        let cubeHalfHeight: CGFloat = 0.5
        let startY: CGFloat = visibleTopY + cubeHalfHeight + dropHeight

        // Lift the cube to its drop-start position BEFORE the action plays.
        node.position = SCNVector3(0, Float(startY), 0)

        // 1. DROP — runs alone first (falls all the way from startY to Y=0)
        let drop = SCNAction.moveBy(x: 0, y: -startY, z: 0, duration: dropDuration)
        drop.timingMode = .easeIn

        // 2. OVERSHOOT, 3. BOUNCE UP, 4. BOUNCE DOWN — group together as one sequence
        let dropOvershoot = SCNAction.moveBy(x: 0, y: -dropOvershootY, z: 0, duration: overshootDuration)
        dropOvershoot.timingMode = .easeOut

        let bounceUp = SCNAction.moveBy(x: 0, y: dropOvershootY + bounceUpY, z: 0, duration: bounceUpDuration)
        bounceUp.timingMode = .easeOut

        let bounceDown = SCNAction.moveBy(x: 0, y: -bounceUpY, z: 0, duration: bounceDownDuration)
        bounceDown.timingMode = .easeInEaseOut

        let bounceSequence = SCNAction.sequence([dropOvershoot, bounceUp, bounceDown])

        // 5. SPIN — starts spinStartDelay after the drop ends (i.e. at
        // dropDuration + spinStartDelay = 0.14s by default).
        let spin = SCNAction.rotateBy(
            x: CGFloat.pi * 10,    // 5 full vertical revolutions (multiple of 360°)
            y: 0,
            z: 0,
            duration: spinDuration
        )
        spin.timingMode = .easeOut
        let spinWithLead = SCNAction.sequence([
            SCNAction.wait(duration: spinStartDelay),
            spin
        ])

        // Run bounce sequence AND spin in parallel. Group ends when the LATER
        // finishes — spin (0.01 + 0.85 = 0.86s) outlasts bounces (0.27s), so the
        // cube finishes the bounce mid-spin and keeps rotating to a settled stop.
        let bounceAndSpin = SCNAction.group([bounceSequence, spinWithLead])

        // 6. POST-SPIN SETTLE — runs sequentially after the group
        let settleDown = SCNAction.moveBy(x: 0, y: -settleOvershoot, z: 0, duration: settleDownDuration)
        settleDown.timingMode = .easeOut
        let settleUp = SCNAction.moveBy(x: 0, y: settleOvershoot, z: 0, duration: settleUpDuration)
        settleUp.timingMode = .easeInEaseOut

        var actions: [SCNAction] = []
        // spinDelay (per-die stagger) is currently 0 — all dice in sync.
        if spinDelay > 0 {
            actions.append(SCNAction.wait(duration: spinDelay))
        }
        actions.append(contentsOf: [drop, bounceAndSpin, settleDown, settleUp])
        node.runAction(SCNAction.sequence(actions))
    }
}

// MARK: - Node Connection Lines
//
// Draws lines connecting nodes based on PotionShopBoard.edges topology.
// These lines appear BEHIND the nodes (z-index 1) but above the cauldron (z-index 0).
// Lines automatically connect to the actual node positions including all offsets.
//
// JULY 2, 2026 — VISIBILITY MODES (Debug Menu → Layout Tools → Chalk Lines):
//   .always — lines permanently visible (the old behavior)
//   .hidden — never drawn; boost reach and glow still work invisibly
//   .smart  — the default. Lines are invisible until they matter:
//             they fade in while a die is being dragged or dice are on
//             the board, and go full-strength during the brew. Boost
//             edges pulse gold as before — that's the "light up".

enum PotionShopNodeLineMode: String {
    case always
    case hidden
    case smart
}

struct PotionShopNodeConnectionLines: View {
    let nodeOriginX: CGFloat
    let nodeOriginY: CGFloat
    let nodeSpacingMultiplier: CGFloat
    let perNodeOffsets: [CGPoint]
    /// JUNE 20, 2026: pass game state so we can LIGHT UP edges where a boost
    /// is feeding a connected die. Optional so previews/other callers work.
    var gs: PotionShopGameState? = nil

    /// Current visibility mode (read live from the layout config).
    private var mode: PotionShopNodeLineMode {
        PotionShopNodeLineMode(rawValue: PotionShopLayoutConfig.shared.nodeLineModeRaw) ?? .smart
    }

    /// Overall line-layer opacity: always → 1, hidden → 0, smart → 1
    /// (in smart mode, visibility is decided PER EDGE — see body).
    private var layerOpacity: Double {
        switch mode {
        case .always: return 1.0
        case .hidden: return 0.0
        case .smart:  return 1.0
        }
    }

    /// JULY 2, 2026 (late night) — POTIONY COSMETIC LINES. In smart mode
    /// an edge is drawn ONLY when BOTH of its endpoint nodes have dice on
    /// them: placing a second die draws exactly the chalk line(s)
    /// CONNECTING the two dice, not the whole board's wiring. Purely
    /// visual for now. During the brew, these dice-connecting lines GLOW
    /// (green energy pulse — see body); boost-fed edges keep their gold.
    private var connectedEdges: Set<[Int]> {
        guard let gs = gs else { return [] }
        var result = Set<[Int]>()
        for (a, b) in PotionShopBoard.edges {
            if gs.placements[a] != nil, gs.placements[b] != nil {
                result.insert([a, b])
            }
        }
        return result
    }

    /// Set of edges (as ordered pairs, both directions) that are active boost
    /// connections: one end is a boost, the other is a non-boost die that the
    /// boost reaches. Drawn brighter/thicker to show the boost flow.
    private var boostEdges: Set<[Int]> {
        guard let gs = gs else { return [] }
        var result = Set<[Int]>()
        // JULY 4 (evening): nodes acting as boosts = real boost dice plus
        // any magic die mirroring a boost (it radiates from its own node).
        var boostingNodes: [Int] = gs.placements.compactMap { $0.value.type == .boost ? $0.key : nil }
        for (mNode, mDie) in gs.placements where mDie.type == .magic {
            if let p = PotionShopBoard.mirrorNode(of: mNode),
               let src = gs.placements[p], src.type == .boost {
                boostingNodes.append(mNode)
            }
        }
        for boostNode in boostingNodes {
            let reach = PotionShopBoard.neighborsExactly(boostNode, hops: 2)
            for (a, b) in PotionShopBoard.edges {
                let other = (a == boostNode) ? b : (b == boostNode ? a : nil)
                if let other = other,
                   reach.contains(other),
                   let d = gs.placements[other], d.type != .boost {
                    result.insert([a, b])
                }
            }
        }
        return result
    }

    var body: some View {
        let boosted = boostEdges
        let visibility = layerOpacity
        let connected = connectedEdges
        // In smart mode only dice-connecting edges draw; Always draws all.
        let smartMode = (mode == .smart)
        let brewing = gs?.isAnimating ?? false
        // JUNE 20, 2026: TimelineView drives a continuous pulse for the gold
        // boost lines (opacity + width oscillate). Only animates when there
        // ARE boost lines; otherwise it's a static draw.
        // JULY 2, 2026: the whole layer fades with `visibility` (smart mode).
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            // 0..1 sine pulse, ~1.1s period
            let pulse = 0.5 + 0.5 * sin(t * 5.7)
            Canvas { context, size in
                // Draw each edge as a line
                for (fromIdx, toIdx) in PotionShopBoard.edges {
                    // SMART: skip any edge that isn't connecting two dice.
                    if smartMode && !connected.contains([fromIdx, toIdx]) {
                        continue
                    }
                    let fromNode = PotionShopBoard.nodes[fromIdx]
                    let toNode = PotionShopBoard.nodes[toIdx]

                    let fromOffset = fromIdx < perNodeOffsets.count ? perNodeOffsets[fromIdx] : .zero
                    let toOffset = toIdx < perNodeOffsets.count ? perNodeOffsets[toIdx] : .zero

                    let fromX = nodeOriginX + CGFloat(fromNode.x) * nodeSpacingMultiplier + fromOffset.x
                    let fromY = nodeOriginY + CGFloat(fromNode.y) * nodeSpacingMultiplier + fromOffset.y

                    let toX = nodeOriginX + CGFloat(toNode.x) * nodeSpacingMultiplier + toOffset.x
                    let toY = nodeOriginY + CGFloat(toNode.y) * nodeSpacingMultiplier + toOffset.y

                    var path = Path()
                    path.move(to: CGPoint(x: fromX, y: fromY))
                    path.addLine(to: CGPoint(x: toX, y: toY))

                    if boosted.contains([fromIdx, toIdx]) {
                        // Pulsing gold: opacity 0.55→1.0, width 4→6.
                        let op = 0.55 + 0.45 * pulse
                        let w = 4.0 + 2.0 * pulse
                        context.stroke(
                            path,
                            with: .color(Color(red: 1.0, green: 0.78, blue: 0.25).opacity(op)),
                            lineWidth: w
                        )
                    } else if smartMode && brewing {
                        // BREW GLOW (JULY 2, late night): while the brew
                        // plays, every line connecting two dice pulses
                        // with bright potion-green energy.
                        let op = 0.65 + 0.35 * pulse
                        let w = 3.5 + 1.5 * pulse
                        context.stroke(
                            path,
                            with: .color(Color(red: 0.45, green: 0.95, blue: 0.55).opacity(op)),
                            lineWidth: w
                        )
                    } else {
                        context.stroke(
                            path,
                            with: .color(Color(red: 0.18, green: 0.80, blue: 0.44).opacity(0.6)),
                            lineWidth: 2.5
                        )
                    }
                }
            }
        }
        // JULY 2, 2026: smart-mode fade. The layer eases in when a drag
        // starts / dice are placed, and eases out when the board clears.
        .opacity(visibility)
        .animation(.easeInOut(duration: 0.35), value: visibility)
        .allowsHitTesting(false)
    }
}
