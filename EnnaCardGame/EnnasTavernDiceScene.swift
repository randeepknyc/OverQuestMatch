//
//  EnnasTavernDiceScene.swift
//  OverQuestMatch3 — Enna's Tavern
//
//  🎲 REAL 3D DICE (SceneKit — built into iOS, no dependencies).
//  Five rounded-edge cubes with true pip faces on all six sides,
//  thrown with a stagger, tumbling in genuine 3D, bouncing twice with
//  decaying height, squashing on impact, casting real shadows on the
//  table, and always landing with the CORRECT value facing up
//  (the value is decided by the fair RNG in the ViewModel — the
//  animation is choreography, not physics-rigged odds).
//
//  Tap a die to SELECT it (it lifts and glows amber).
//

import SwiftUI
import SceneKit
import UIKit

// ============================================================
// SwiftUI wrapper — drop-in view for the serving screen
// ============================================================
struct TavernDiceSceneView: UIViewRepresentable {

    var dice: [TavernDie]
    var rollStamp: Int
    var rolledIDs: Set<Int>
    var dieScale: Float = 1.0
    var dieGap: Float = 1.14
    var onTapDie: (Int) -> Void

    func makeCoordinator() -> TavernDiceCoordinator {
        TavernDiceCoordinator(onTapDie: onTapDie)
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.antialiasingMode = .multisampling4X
        view.scene = context.coordinator.buildScene()
        view.pointOfView = context.coordinator.cameraNode
        view.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(TavernDiceCoordinator.handleTap(_:)))
        view.addGestureRecognizer(tap)
        context.coordinator.scnView = view
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        let c = context.coordinator
        c.onTapDie = onTapDie
        c.applyLayout(scale: dieScale, spacing: dieGap)
        if rollStamp != c.lastStamp {
            c.lastStamp = rollStamp
            c.roll(dice: dice, rolledIDs: rolledIDs)
        } else {
            c.syncStaticValues(dice)
        }
        c.syncSelection(dice)
    }
}

// ============================================================
// The 3D world + throw choreography
// ============================================================
final class TavernDiceCoordinator: NSObject {

    // ═══════════════════════════════════════════════════════
    // ⏱ ROLL FEEL — TUNING DIALS
    // ═══════════════════════════════════════════════════════
    private let staggerPerSlot = 0.07     // delay between dice leaving the hand
    private let throwHeight: Float = 1.9  // first arc height (die is 1.0 tall)
    private let rise1 = 0.30, fall1 = 0.26
    private let bounce2Height: Float = 0.72
    private let rise2 = 0.18, fall2 = 0.16
    private let bounce3Height: Float = 0.28
    private let rise3 = 0.12, fall3 = 0.11
    private let spinDuration = 0.88       // tumble decays over this long
    private let minTumbles = 2            // full end-over-end flips minimum
    private var dieSpacing: Float = 1.14          // 🔧 live via applyLayout
    private var restY: Float = 0.5                // die center height (scales with die size)
    private var selectedLift: Float = 0.42
    private var appliedScale: Float = 1.0

    var onTapDie: (Int) -> Void
    var lastStamp = -1
    weak var scnView: SCNView?
    var cameraNode = SCNNode()

    private var dieNodes: [Int: SCNNode] = [:]   // die id → node
    private var rattleTask: Task<Void, Never>? = nil
    private let rattleTick = UIImpactFeedbackGenerator(style: .rigid)
    private let rattleSoft = UIImpactFeedbackGenerator(style: .light)
    private var shownValues: [Int: Int] = [:]
    private var animating: Set<Int> = []
    private var appliedSelected: [Int: Bool] = [:]   // last selection state applied per die

    init(onTapDie: @escaping (Int) -> Void) {
        self.onTapDie = onTapDie
    }

    // ---------------------------------------------------------
    // SCENE: camera, light, shadow floor, five dice
    // ---------------------------------------------------------
    func buildScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        // Camera — above and back, looking down at the table
        let camera = SCNCamera()
        // 📷 FRAMING DIALS — horizontal projection locks the 5-die row
        // to the view width on any screen. Bigger fieldOfView = smaller dice.
        camera.projectionDirection = .horizontal
        camera.fieldOfView = 46
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 4.35, 7.75)
        cameraNode.eulerAngles = SCNVector3(-0.46, 0, 0)
        scene.rootNode.addChildNode(cameraNode)

        // Key light — warm, from up-left, with soft real shadows
        let key = SCNLight()
        key.type = .directional
        key.intensity = 950
        key.color = UIColor(red: 1.0, green: 0.95, blue: 0.86, alpha: 1)
        key.castsShadow = true
        key.shadowMode = .deferred
        key.shadowColor = UIColor(white: 0, alpha: 0.38)
        key.shadowRadius = 6
        key.shadowSampleCount = 16
        let keyNode = SCNNode()
        keyNode.light = key
        keyNode.eulerAngles = SCNVector3(-1.05, -0.5, 0)
        scene.rootNode.addChildNode(keyNode)

        // Fill light — cool ambient so shadow sides stay readable
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 520
        ambient.color = UIColor(red: 0.85, green: 0.82, blue: 0.9, alpha: 1)
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        // Invisible floor that catches ONLY shadows
        let floor = SCNPlane(width: 40, height: 40)
        let floorMat = SCNMaterial()
        floorMat.lightingModel = .shadowOnly
        floor.materials = [floorMat]
        let floorNode = SCNNode(geometry: floor)
        floorNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        floorNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(floorNode)

        // Five dice
        for slot in 0..<5 {
            let node = makeDieNode()
            node.name = "die\(slot)"
            node.position = SCNVector3(dieX(slot), restY, 0)
            node.eulerAngles = Self.baseEuler(for: 3)
            scene.rootNode.addChildNode(node)
            dieNodes[slot] = node
            shownValues[slot] = 3
        }

        return scene
    }

    // ---------------------------------------------------------
    // 🔧 LIVE LAYOUT — die size + spacing from the debug tuner.
    // Resizes geometry, reseats the row, refits the camera.
    // ---------------------------------------------------------
    func applyLayout(scale: Float, spacing: Float) {
        guard abs(scale - appliedScale) > 0.001 || abs(spacing - dieSpacing) > 0.001 else { return }
        appliedScale = scale
        dieSpacing = spacing
        restY = 0.5 * scale
        selectedLift = 0.42 * scale

        for (id, node) in dieNodes {
            if let box = node.geometry as? SCNBox {
                box.width = CGFloat(scale)
                box.height = CGFloat(scale)
                box.length = CGFloat(scale)
                box.chamferRadius = 0.14 * CGFloat(scale)
            }
            let lifted = appliedSelected[id] == true
            node.position = SCNVector3(dieX(id), restY + (lifted ? selectedLift : 0), 0)
        }

        // Refit the camera so the whole row stays in frame
        let halfWidth = 2 * spacing + 0.5 * scale + 0.6
        let fovDeg = Double(2 * atan(halfWidth / 8.6) * 180 / Float.pi)
        cameraNode.camera?.fieldOfView = max(28, fovDeg)
    }

    private func dieX(_ slot: Int) -> Float {
        (Float(slot) - 2) * dieSpacing
    }

    // A rounded ivory cube with pip textures on all six faces.
    // Faces are mapped like a REAL die (opposite faces sum to 7).
    private func makeDieNode() -> SCNNode {
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.14)
        // SCNBox material order: front(+z), right(+x), back(−z), left(−x), top(+y), bottom(−y)
        let faceValues = [1, 2, 6, 5, 3, 4]
        box.materials = faceValues.map { value in
            let m = SCNMaterial()
            m.diffuse.contents = Self.faceImage(value)
            m.lightingModel = .blinn
            m.specular.contents = UIColor(white: 1, alpha: 0.55)
            m.shininess = 0.6
            m.emission.contents = UIColor.clear
            return m
        }
        return SCNNode(geometry: box)
    }

    // ---------------------------------------------------------
    // 🎲 THE THROW — arc, tumble, double bounce, squash, thunk
    // ---------------------------------------------------------
    func roll(dice: [TavernDie], rolledIDs: Set<Int>) {
        if !rolledIDs.isEmpty {
            let lastSlot = rolledIDs.max() ?? 0
            let flight = rise1 + fall1 + rise2 + fall2 + rise3 + fall3
            startRattle(duration: Double(lastSlot) * staggerPerSlot + flight * 0.9,
                        dieCount: rolledIDs.count)
        }
        for die in dice {
            guard let node = dieNodes[die.id] else { continue }
            if rolledIDs.contains(die.id) {
                throwDie(node: node, id: die.id, value: die.value,
                         delay: Double(die.id) * staggerPerSlot)
            } else {
                snapValue(node: node, id: die.id, value: die.value)
            }
        }
    }

    private func throwDie(node: SCNNode, id: Int, value: Int, delay: Double) {
        node.removeAllActions()
        animating.insert(id)
        shownValues[id] = value
        // Leaving the hand: any selection glow dies instantly,
        // and we force a selection re-sync after landing.
        node.geometry?.materials.forEach { $0.emission.contents = UIColor.clear }
        appliedSelected.removeValue(forKey: id)

        // Normalize current angles so the numbers never grow unbounded
        var cur = node.eulerAngles
        cur.x = cur.x.truncatingRemainder(dividingBy: 2 * .pi)
        cur.y = cur.y.truncatingRemainder(dividingBy: 2 * .pi)
        cur.z = cur.z.truncatingRemainder(dividingBy: 2 * .pi)
        node.eulerAngles = cur

        // Final orientation: value face TOWARD THE CAMERA, upright, with
        // full tumbles on the way and a ±4° yaw so the row isn't robotic.
        let base = Self.baseEuler(for: value)
        let jitter = Float.random(in: -0.07...0.07)
        let tx = Self.nextAngle(from: cur.x, toBase: base.x, minTurns: minTumbles + Int.random(in: 0...1))
        let ty = Self.nextAngle(from: cur.y, toBase: base.y + jitter, minTurns: 1)
        let tz = Self.nextAngle(from: cur.z, toBase: base.z, minTurns: 1)

        let spin = SCNAction.rotateTo(x: CGFloat(tx), y: CGFloat(ty), z: CGFloat(tz),
                                      duration: spinDuration)
        spin.timingMode = .easeOut

        // The arc: big hop, then two decaying bounces
        let x = node.position.x
        func up(_ h: Float, _ t: Double) -> SCNAction {
            let a = SCNAction.move(to: SCNVector3(x, restY + h, 0), duration: t)
            a.timingMode = .easeOut
            return a
        }
        func down(_ t: Double) -> SCNAction {
            let a = SCNAction.move(to: SCNVector3(x, restY, 0), duration: t)
            a.timingMode = .easeIn
            return a
        }

        let land1 = SCNAction.run { [weak self] n in self?.impact(n, strength: 3) }
        let land2 = SCNAction.run { [weak self] n in self?.impact(n, strength: 2) }
        let land3 = SCNAction.run { [weak self] n in
            self?.impact(n, strength: 1)
            DispatchQueue.main.async {
                self?.animating.remove(id)
                self?.appliedSelected.removeValue(forKey: id)
            }
        }

        let arc = SCNAction.sequence([
            up(throwHeight, rise1), down(fall1), land1,
            up(bounce2Height, rise2), down(fall2), land2,
            up(bounce3Height, rise3), down(fall3), land3
        ])

        let whole = SCNAction.sequence([
            .wait(duration: delay),
            .group([spin, arc])
        ])
        node.runAction(whole)
    }

    // ---------------------------------------------------------
    // 🎶 THE RATTLE — dice clattering in a cup
    // A flurry of tiny jittered ticks while the dice are airborne,
    // denser with more dice, fading out as they come to rest.
    // (Landing thunks are separate, per die, in impact().)
    // ---------------------------------------------------------
    private func startRattle(duration: Double, dieCount: Int) {
        rattleTask?.cancel()
        rattleTick.prepare()
        rattleSoft.prepare()
        rattleTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let start = Date()
            // More dice = busier rattle
            let density = 1.0 / (Double(dieCount).squareRoot())
            while !Task.isCancelled {
                let t = Date().timeIntervalSince(start)
                if t >= duration { break }
                let progress = t / duration                 // 0 → 1
                let energy = 1.0 - progress                 // fades as dice settle
                // Alternate crisp and soft ticks for texture
                if Bool.random() {
                    self.rattleTick.impactOccurred(intensity: CGFloat(0.25 + 0.4 * energy))
                } else {
                    self.rattleSoft.impactOccurred(intensity: CGFloat(0.35 + 0.45 * energy))
                }
                // Ticks come fast at first, spreading out as the throw dies down
                let interval = (0.035 + 0.075 * progress) * density + Double.random(in: 0...0.03)
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    /// Landing: squash the die and thump the haptics.
    private func impact(_ node: SCNNode, strength: Int) {
        DispatchQueue.main.async {
            switch strength {
            case 3: HapticManager.shared.diePlaced()
            case 2: HapticManager.shared.tileTapped()
            default: HapticManager.shared.tileSelected()
            }
        }
        let squash = 1.0 + 0.06 * Float(strength)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.05
        node.scale = SCNVector3(squash, 2.0 - squash, squash)
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.16
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            node.scale = SCNVector3(1, 1, 1)
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
    }

    // ---------------------------------------------------------
    // SELECTION + STATIC SYNC
    // ---------------------------------------------------------
    func syncSelection(_ dice: [TavernDie]) {
        for die in dice {
            guard let node = dieNodes[die.id], !animating.contains(die.id) else { continue }
            let selected = die.selected
            // Skip if this die already shows the right state
            if appliedSelected[die.id] == selected { continue }
            appliedSelected[die.id] = selected

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.18
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            node.position.y = selected ? restY + selectedLift : restY
            let glow = selected ? UIColor(red: 0.95, green: 0.62, blue: 0.15, alpha: 0.55) : UIColor.clear
            node.geometry?.materials.forEach { $0.emission.contents = glow }
            SCNTransaction.commit()
        }
    }

    func syncStaticValues(_ dice: [TavernDie]) {
        for die in dice where !animating.contains(die.id) {
            if shownValues[die.id] != die.value, let node = dieNodes[die.id] {
                snapValue(node: node, id: die.id, value: die.value)
            }
        }
    }

    private func snapValue(node: SCNNode, id: Int, value: Int) {
        shownValues[id] = value
        node.eulerAngles = Self.baseEuler(for: value)
    }

    // ---------------------------------------------------------
    // TAP → which die?
    // ---------------------------------------------------------
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let view = scnView else { return }
        let point = gesture.location(in: view)
        let hits = view.hitTest(point, options: [.boundingBoxOnly: true])
        for hit in hits {
            var node: SCNNode? = hit.node
            while let n = node {
                if let name = n.name, name.hasPrefix("die"),
                   let id = Int(name.dropFirst(3)) {
                    onTapDie(id)
                    return
                }
                node = n.parent
            }
        }
    }

    // ---------------------------------------------------------
    // ORIENTATION MATH
    // ---------------------------------------------------------
    /// Euler angles that put `value` on the FRONT face — the one the
    /// camera sees. Every case also lands the face art UPRIGHT, so a 6
    /// can never masquerade as a 9. (Single-axis rotations, so SceneKit's
    /// Rz · Ry · Rx composition order doesn't bite.)
    static func baseEuler(for value: Int) -> SCNVector3 {
        switch value {
        case 2: return SCNVector3(0, -Float.pi / 2, 0)   // right → front
        case 3: return SCNVector3(Float.pi / 2, 0, 0)    // top → front
        case 4: return SCNVector3(-Float.pi / 2, 0, 0)   // bottom → front
        case 5: return SCNVector3(0, Float.pi / 2, 0)    // left → front
        case 6: return SCNVector3(0, Float.pi, 0)        // back → front (yaw keeps it upright)
        default: return SCNVector3(0, 0, 0)              // 1 faces front at identity
        }
    }

    /// Next angle ≡ `base` (mod 2π) that is at least `minTurns` full
    /// rotations past `from` — guarantees visible tumbling AND an exact landing.
    static func nextAngle(from: Float, toBase base: Float, minTurns: Int) -> Float {
        var t = base
        let floorLine = from + Float(minTurns) * 2 * .pi
        while t < floorLine { t += 2 * .pi }
        return t
    }

    // ---------------------------------------------------------
    // FACE ART LOOKUP — your images become the die faces.
    // Checked in order: "die_face_N" in Assets → temp die_* test art
    // → code-drawn pips. Drop art in Assets.xcassets, rebuild, done.
    // ---------------------------------------------------------
    static let testFaceAssets: [Int: String] = [
        1: "die_boost", 2: "die_heal", 3: "die_magic",
        4: "die_potency", 5: "die_shield", 6: "die_stability"
    ]

    static func faceImage(_ value: Int) -> UIImage {
        let base: UIImage
        if let art = UIImage(named: "die_face_\(value)") { base = art }
        else if let name = testFaceAssets[value], let art = UIImage(named: name) { base = art }
        else { base = pipImage(value) }
        return numbered(base, value: value)
    }

    // ---------------------------------------------------------
    // 🔢 NUMERAL BADGE — stamped in the middle of every face so
    // values read at a glance. Centered so it survives the die's
    // landing rotation; the 6 gets an underline (a spun 6 reads
    // as 9 otherwise). Remove by returning `base` directly above.
    // ---------------------------------------------------------
    private static func numbered(_ base: UIImage, value: Int) -> UIImage {
        let s: CGFloat = 256
        return UIGraphicsImageRenderer(size: CGSize(width: s, height: s)).image { ctx in
            base.draw(in: CGRect(x: 0, y: 0, width: s, height: s))

            let d: CGFloat = 118
            let disc = CGRect(x: (s - d) / 2, y: (s - d) / 2, width: d, height: d)
            UIColor(red: 0.97, green: 0.93, blue: 0.84, alpha: 0.92).setFill()
            UIBezierPath(ovalIn: disc).fill()
            let ring = UIBezierPath(ovalIn: disc.insetBy(dx: 3, dy: 3))
            UIColor(red: 0.55, green: 0.42, blue: 0.22, alpha: 0.85).setStroke()
            ring.lineWidth = 5
            ring.stroke()

            let ink = UIColor(red: 0.16, green: 0.11, blue: 0.08, alpha: 1)
            let font = TavernFont.ui(78)
            let text = NSAttributedString(string: "\(value)", attributes: [
                .font: font,
                .foregroundColor: ink
            ])
            let sz = text.size()
            let origin = CGPoint(x: disc.midX - sz.width / 2, y: disc.midY - sz.height / 2 - 4)
            text.draw(at: origin)

            if value == 6 {
                // Underline placed by FONT METRICS (digits sit on the baseline
                // at cap height), clamped inside the disc — a spun 6 shows its
                // bar and can't pass for a bare 9.
                let baseline = origin.y + font.ascender
                let barY = min(baseline + 5, disc.maxY - 12)
                ink.setFill()
                UIBezierPath(rect: CGRect(x: disc.midX - sz.width / 2, y: barY,
                                          width: sz.width, height: 7)).fill()
            }
        }
    }

    // ---------------------------------------------------------
    // PIP FACE TEXTURES (fallback when no art is present)
    // ---------------------------------------------------------
    static func pipImage(_ value: Int) -> UIImage {
        let s: CGFloat = 256
        return UIGraphicsImageRenderer(size: CGSize(width: s, height: s)).image { ctx in
            // Ivory face
            UIColor(red: 0.97, green: 0.93, blue: 0.84, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: s, height: s))

            // Faint edge shading for depth
            let edge = UIBezierPath(rect: CGRect(x: 0, y: 0, width: s, height: s))
            UIColor(red: 0.72, green: 0.64, blue: 0.50, alpha: 0.35).setStroke()
            edge.lineWidth = 14
            edge.stroke()

            // Pips
            let pip = UIColor(red: 0.16, green: 0.11, blue: 0.08, alpha: 1)
            let r: CGFloat = s * 0.095
            for p in Self.pipLayout(value) {
                let rect = CGRect(x: p.x * s - r, y: p.y * s - r, width: r * 2, height: r * 2)
                pip.setFill()
                UIBezierPath(ovalIn: rect).fill()
                // tiny highlight on each pip
                UIColor(white: 1, alpha: 0.25).setFill()
                UIBezierPath(ovalIn: CGRect(x: rect.minX + r * 0.35, y: rect.minY + r * 0.3,
                                            width: r * 0.6, height: r * 0.6)).fill()
            }
        }
    }

    private static func pipLayout(_ value: Int) -> [CGPoint] {
        let tl = CGPoint(x: 0.28, y: 0.28), tr = CGPoint(x: 0.72, y: 0.28)
        let ml = CGPoint(x: 0.28, y: 0.50), mr = CGPoint(x: 0.72, y: 0.50)
        let bl = CGPoint(x: 0.28, y: 0.72), br = CGPoint(x: 0.72, y: 0.72)
        let c  = CGPoint(x: 0.50, y: 0.50)
        switch value {
        case 1: return [c]
        case 2: return [tl, br]
        case 3: return [tl, c, br]
        case 4: return [tl, tr, bl, br]
        case 5: return [tl, tr, c, bl, br]
        default: return [tl, ml, bl, tr, mr, br]
        }
    }
}
