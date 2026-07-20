//
//  PotionShopDice3DTest.swift  ··  FILE REV 8 — GESTURES RESTORED
//  (⌘F "REV 2" — if this line is missing, you pasted the stale rev 1
//  from an older download; grab the file from Claude's LATEST message.)
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — 🎲 REAL 3D DICE (TEMPORARY TEST · July 17, 2026)
//  Place in: PotionShop/ folder
//
//  ═══════════════════════════════════════════════════════════════════════
//  Ported from Enna's Tavern (see SCENEKIT_3D_DICE_CONTEXT.md), adapted to
//  ONE DIE PER SCENE so each SceneKit view drops into the existing tray
//  slot — inheriting the slot's drag / tap / long-press-peek / badges /
//  tutorial frames with ZERO behavior changes. VISUALS ONLY:
//    • values, weighting, roll triggers, gestures — all untouched
//    • throws fire off the SAME gs.spinTrigger3D token the reel spin uses
//    • the 2D value badge still stamps the number on top
//    • toggled live in the drawer 🎲 tab ("SceneKit 3D dice (test)"),
//      default OFF — flip it off and the game is byte-identical to before
//  NOT physics: the game's value is already decided; the die tumbles with
//  ≥2 guaranteed end-over-end turns and lands cleanly (all six faces carry
//  the die-type art, so any landing orientation is correct).
//
//  TUNING DIALS: all constants at the top of Cauldron3DDieCoordinator.
//

import SwiftUI
import SceneKit
import UIKit

// MARK: - SwiftUI wrapper (layout-neutral: occupies exactly size×size)

struct CauldronDie3D: View {
    let die: PotionShopDie
    let isSelected: Bool
    let size: CGFloat
    let index: Int
    let spinToken: Int
    let animateOnAppear: Bool

    var body: some View {
        // REV 3: the die SITS IN THE TRAY — same square footprint as the
        // 2D die, modest headroom above for the drop-in only (no arcs).
        // The 🎲 tab's "3D size ×" and "3D seat Y" dials fine-tune the
        // framing onto the tray wood, live.
        let cfg = PotionShopLayoutConfig.shared
        Color.clear
            .frame(width: size, height: size)
            // REV 8: CRITICAL — the 2D die was an opaque image, so the
            // tray's drag/tap/peek gestures naturally hit it. This 3D
            // wrapper is transparent (and the GL canvas deliberately
            // never hit-tests), which left the die with NO tappable
            // pixels — dragging into nodes silently died. contentShape
            // declares the die's square as the hit area, restoring every
            // gesture exactly as the 2D die had them.
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Cauldron3DDieView(
                    die: die,
                    isSelected: isSelected,
                    index: index,
                    spinToken: spinToken,
                    animateOnAppear: animateOnAppear
                )
                .frame(width: size * 1.15, height: size * 1.55)
                .scaleEffect(cfg.dice3DScale, anchor: .bottom)
                .offset(y: cfg.dice3DYOffset)
                .allowsHitTesting(false)   // touches pass to the real 2D gesture surfaces
            }
            // REV 5: the TRAY WINDOW — everything outside the slot square
            // is cut off, so the drop descends INTO view and the spinning
            // cube's corners shear at the tray's top edge, exactly like
            // the 2D reel. (An X-axis reel never widens horizontally, so
            // the side edges never clip the resting die.)
            .clipped()
    }
}

// MARK: - UIViewRepresentable

struct Cauldron3DDieView: UIViewRepresentable {
    let die: PotionShopDie
    let isSelected: Bool
    let index: Int
    let spinToken: Int
    let animateOnAppear: Bool

    func makeCoordinator() -> Cauldron3DDieCoordinator {
        Cauldron3DDieCoordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.antialiasingMode = .multisampling4X
        view.isUserInteractionEnabled = false   // visuals only — never eats a gesture
        context.coordinator.attach(to: view, die: die)

        // Per the port doc: per-die SwiftUI views are created AFTER the
        // stamp bump on a fresh deal — onAppear must decide whether this
        // view owes an entry throw.
        if animateOnAppear {
            context.coordinator.lastStamp = spinToken - 1   // updateUIView throws
        } else {
            context.coordinator.lastStamp = spinToken        // sit settled
        }
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        let co = context.coordinator
        co.refreshFaceArt(for: die)
        if spinToken != co.lastStamp {
            co.lastStamp = spinToken
            co.throwDie(delay: Double(index) * Cauldron3DDieCoordinator.staggerPerSlot)
            if index == 0 {
                // Exactly ONE view owns the rattle per throw (5× = mush).
                co.startRattle(dieCount: 5)
            }
        }
        co.syncSelection(isSelected)
    }
}

// MARK: - Coordinator (scene, throw choreography, rattle, selection)

final class Cauldron3DDieCoordinator {

    // ─── TUNING DIALS (REV 3: the OLD reel envelope — drop 0.26 +
    //     spin 0.85 + settle 0.23, 0.06s stagger — done by a real cube) ──
    static let staggerPerSlot: Double = 0.06
    private let dropHeight: CGFloat = 0.95
    private let dropDuration: Double = 0.26
    private let spinDuration: Double = 0.85
    private let settleDuration: Double = 0.23
    private let restY: CGFloat = 0.5
    private let selectedLift: CGFloat = 0.12   // REV 5: window-safe (glow is the main signal)
    private let chamfer: CGFloat = 0.14
    // Camera: narrow FOV from a distance = telephoto (no edge lean).
    private let camFOV: CGFloat = 20
    private let camPosition = SCNVector3(0, 1.35, 4.35)
    private let camEuler = SCNVector3(-0.19, 0, 0)

    weak var scnView: SCNView?
    var lastStamp: Int = 0
    private var dieNode: SCNNode?
    private var animating = false
    private var appliedSelected: Bool? = nil
    private var currentArtName: String? = nil
    private var rattleTask: Task<Void, Never>? = nil

    // ─── Scene construction (per the port doc) ──────────────────────

    func attach(to view: SCNView, die: PotionShopDie) {
        scnView = view
        let scene = SCNScene()
        scene.background.contents = UIColor.clear
        view.scene = scene

        // Camera
        let camNode = SCNNode()
        let cam = SCNCamera()
        cam.fieldOfView = camFOV
        camNode.camera = cam
        camNode.position = camPosition
        camNode.eulerAngles = camEuler
        scene.rootNode.addChildNode(camNode)

        // Warm key light with REAL soft shadows (deferred = the required
        // mode for shadows over a transparent background).
        let key = SCNNode()
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.color = UIColor(red: 1.0, green: 0.95, blue: 0.86, alpha: 1)
        keyLight.intensity = 950
        keyLight.castsShadow = true
        keyLight.shadowMode = .deferred
        keyLight.shadowColor = UIColor.black.withAlphaComponent(0.38)
        keyLight.shadowRadius = 6
        keyLight.shadowSampleCount = 16
        key.light = keyLight
        key.eulerAngles = SCNVector3(-0.9, -0.35, 0)
        scene.rootNode.addChildNode(key)

        // Cool ambient fill — keeps shadowed faces readable.
        let fill = SCNNode()
        let fillLight = SCNLight()
        fillLight.type = .ambient
        fillLight.color = UIColor(red: 0.85, green: 0.82, blue: 0.9, alpha: 1)
        fillLight.intensity = 520
        fill.light = fillLight
        scene.rootNode.addChildNode(fill)

        // Invisible shadow-catching floor.
        let floorPlane = SCNPlane(width: 30, height: 30)
        let floorMat = SCNMaterial()
        floorMat.lightingModel = .shadowOnly
        floorPlane.materials = [floorMat]
        let floorNode = SCNNode(geometry: floorPlane)
        floorNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        floorNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(floorNode)

        // The die.
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: chamfer)
        box.materials = Self.faceMaterials(for: die)
        let node = SCNNode(geometry: box)
        node.name = "die0"
        node.position = SCNVector3(0, restY, 0)
        node.eulerAngles = Self.randomBaseEuler()
        scene.rootNode.addChildNode(node)
        dieNode = node
        currentArtName = die.type.assetName
    }

    /// Six materials, all carrying the die-type's art (the tray's 2D die
    /// shows one art + a separate value badge — parity kept: the badge is
    /// still stamped on top in SwiftUI, so faces stay number-free).
    private static func faceMaterials(for die: PotionShopDie) -> [SCNMaterial] {
        let art = PotionShopImageLoader.loadDisplayImage(named: die.type.assetName, displaySize: 256)
        // REV 4: as the reel rolls about X, the faces cycling past the
        // camera (front → top → back → bottom) arrive with their default
        // UVs rotated — art flashed by sideways/upside-down. Pre-rotating
        // BACK and TOP by 180° makes every passing face read upright.
        // (Material order: [front, right, back, left, top, bottom].)
        let halfTurn: Set<Int> = [2, 4]
        let flip = SCNMatrix4Translate(
            SCNMatrix4Rotate(SCNMatrix4MakeTranslation(0.5, 0.5, 0), Float.pi, 0, 0, 1),
            -0.5, -0.5, 0)
        return (0..<6).map { i in
            let m = SCNMaterial()
            if let art {
                m.diffuse.contents = art
            } else {
                m.diffuse.contents = UIColor(die.type.color)
            }
            if halfTurn.contains(i) { m.diffuse.contentsTransform = flip }
            m.lightingModel = .blinn
            m.specular.contents = UIColor(white: 1, alpha: 0.55)
            m.shininess = 0.6
            m.emission.contents = UIColor.clear   // doubles as selection glow
            return m
        }
    }

    /// Deck upgrades can swap a die's art mid-run — cheap check per update.
    func refreshFaceArt(for die: PotionShopDie) {
        guard die.type.assetName != currentArtName, let node = dieNode,
              let box = node.geometry as? SCNBox else { return }
        currentArtName = die.type.assetName
        box.materials = Self.faceMaterials(for: die)
    }

    // ─── The throw (choreography, not physics) ──────────────────────

    /// REV 4: EVERY landing (and the initial seed) is the UPRIGHT
    /// orientation — the spin does its 4–5 full turns and always comes
    /// home to identity, so the resting art is right-side up on every
    /// die, every roll, guaranteed (the random 90°/180° landings — and
    /// randomly-seeded resting dice — were the upside-down sightings).
    /// ±5° yaw keeps landings organic; pure pitch/yaw = yaw-safe.
    private static func randomBaseEuler() -> SCNVector3 {
        SCNVector3(0, Float.random(in: -0.09...0.09), 0)
    }

    /// Smallest angle ≡ base (mod 2π) that is ≥ minTurns past `from` —
    /// guarantees visible tumbles AND an exact landing.
    private func nextAngle(from: Float, toBase: Float, minTurns: Int) -> Float {
        let twoPi = Float.pi * 2
        var target = toBase
        while target < from + Float(minTurns) * twoPi { target += twoPi }
        return target
    }

    func throwDie(delay: Double) {
        guard let node = dieNode else { return }
        node.removeAllActions()
        animating = true
        appliedSelected = nil
        for m in (node.geometry?.materials ?? []) { m.emission.contents = UIColor.clear }

        // Normalize (euler components grow forever otherwise — float
        // precision death after many rolls; safe: 2π-periodic per axis).
        let twoPi = Float.pi * 2
        var e = node.eulerAngles
        e.x = e.x.truncatingRemainder(dividingBy: twoPi)
        e.y = e.y.truncatingRemainder(dividingBy: twoPi)
        e.z = e.z.truncatingRemainder(dividingBy: twoPi)
        node.eulerAngles = e

        // REV 7: two spin characters. TAVERN THROW = the other build's
        // end-over-end tumble (2–3 x-turns + a y and z turn). Reel = the
        // 4–5 turn vertical roulette. BOTH land upright (REV 4 rule:
        // landing is always identity + tiny yaw).
        let throwMode = PotionShopLayoutConfig.shared.dice3DBounceIn
        let landing = Self.randomBaseEuler()
        let tx: Float
        let ty: Float
        let tz: Float
        if throwMode {
            tx = nextAngle(from: e.x, toBase: landing.x, minTurns: Int.random(in: 2...3))
            ty = nextAngle(from: e.y, toBase: landing.y, minTurns: 1)
            tz = nextAngle(from: e.z, toBase: landing.z, minTurns: 1)
        } else {
            tx = nextAngle(from: e.x, toBase: landing.x, minTurns: Int.random(in: 4...5))
            ty = landing.y
            tz = landing.z
        }

        // rotateTo interpolates euler COMPONENTS → the extra 2π multiples
        // are the visible spins, decaying with the easing.
        let spin = SCNAction.rotateTo(
            x: CGFloat(tx), y: CGFloat(ty), z: CGFloat(tz),
            duration: spinDuration, usesShortestUnitArc: false)
        spin.timingMode = .easeOut

        // REV 6: two entrances, toggled in the 🎲 tab —
        //  • BOUNCE-IN (default): the die starts OFFSCREEN above the tray
        //    window (the clip hides it), falls into view spinning, and
        //    bounces twice on the tray, decaying. Drop height is the
        //    "3D drop height" slider (world units; ~2+ starts offscreen).
        //  • quiet drop: the original REV 3 envelope (drop 0.26 + settle).
        // (NOTE: per-axis moveTo(y:) is SpriteKit — SceneKit moves to
        // full vectors; the die lives at x=0, z=0, so this is the same.)
        let rest = restY
        // REV 7: TAVERN THROW — the die leaps from its seat (the window
        // clips the top of the arc = the "offscreen" moment), tumbles,
        // and takes two decaying squash-bounces on the tray. Heights ride
        // the "3D throw height" slider. OFF = the quiet reel drop.
        let throwH = CGFloat(PotionShopLayoutConfig.shared.dice3DDropHeight)
        let snapUp = SCNAction.run { n in
            n.position = SCNVector3(0, Float(rest + self.dropHeight), 0)
        }
        func up(_ h: CGFloat, _ d: Double) -> SCNAction {
            let a = SCNAction.move(to: SCNVector3(0, Float(rest + h), 0), duration: d)
            a.timingMode = .easeOut
            return a
        }
        func fall(_ d: Double) -> SCNAction {
            let a = SCNAction.move(to: SCNVector3(0, Float(rest), 0), duration: d)
            a.timingMode = .easeIn
            return a
        }
        let motion: SCNAction
        if throwMode {
            let hit3 = SCNAction.run { [weak self] n in self?.impact(n, strength: 3) }
            let hit2 = SCNAction.run { [weak self] n in self?.impact(n, strength: 2) }
            let hit1 = SCNAction.run { [weak self] n in self?.impact(n, strength: 1) }
            motion = SCNAction.sequence([
                up(throwH, 0.30), fall(0.26), hit3,
                up(throwH * 0.38, 0.18), fall(0.16), hit2,
                up(throwH * 0.15, 0.12), fall(0.11), hit1,
            ])
        } else {
            let touchdown = SCNAction.run { [weak self] n in self?.impact(n, strength: 2) }
            motion = SCNAction.sequence([
                snapUp,
                fall(dropDuration), touchdown,
                // Settle: a soft beat while the last of the spin eases out.
                SCNAction.wait(duration: settleDuration),
            ])
        }

        let finish = SCNAction.run { [weak self] _ in
            DispatchQueue.main.async {
                self?.animating = false
                self?.appliedSelected = nil   // selection re-syncs next update
            }
        }
        let reel = SCNAction.sequence([
            SCNAction.wait(duration: delay),
            SCNAction.group([spin, motion]),
            finish,
        ])
        node.runAction(reel)
    }

    private func impact(_ node: SCNNode, strength: Int) {
        DispatchQueue.main.async {
            switch strength {
            case 3: HapticManager.shared.diePlaced()
            case 2: UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)
            default: UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
            }
        }
        // Squash on impact, spring back.
        let s = CGFloat(strength)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.05
        node.scale = SCNVector3(1 + 0.06 * s, 2 - (1 + 0.06 * s), 1 + 0.06 * s)
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.16
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            node.scale = SCNVector3(1, 1, 1)
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
    }

    // ─── The rattle (one owner per throw — slot 0) ──────────────────

    func startRattle(dieCount: Int) {
        rattleTask?.cancel()
        let duration = Double(dieCount - 1) * Self.staggerPerSlot + spinDuration * 0.95   // REV 3: reel envelope
        rattleTask = Task { @MainActor in
            let rigid = UIImpactFeedbackGenerator(style: .rigid)
            let light = UIImpactFeedbackGenerator(style: .light)
            rigid.prepare(); light.prepare()
            let start = Date()
            var flip = false
            while !Task.isCancelled {
                let progress = Date().timeIntervalSince(start) / duration
                if progress >= 1 { break }
                let energy = 1 - progress
                (flip ? rigid : light).impactOccurred(intensity: 0.35 + 0.5 * energy)
                flip.toggle()
                let interval = (0.035 + 0.075 * progress) / Double(dieCount).squareRoot()
                    + Double.random(in: 0...0.03)
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    // ─── Selection (lift + amber glow, self-healing cache) ──────────

    func syncSelection(_ selected: Bool) {
        guard !animating, appliedSelected != selected, let node = dieNode else { return }
        appliedSelected = selected
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.18
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        node.position.y = Float(restY + (selected ? selectedLift : 0))
        let glow = selected
            ? UIColor(red: 0.95, green: 0.62, blue: 0.15, alpha: 0.55)
            : UIColor.clear
        for m in (node.geometry?.materials ?? []) { m.emission.contents = glow }
        SCNTransaction.commit()
    }
}
