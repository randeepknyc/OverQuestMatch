//
//  PotionShopFireMeterView.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — STABILITY FIRE METER (animated, per-flame)
//  Place in: PotionShop/ folder
//
//  ═══════════════════════════════════════════════════════════════════════
//  Draws the row of fire pieces under the cauldron. Position/size/speed for
//  each flame live in PotionShopLayoutConfig (the SAME config the layout
//  editor uses) — edit them in the debug menu → "🔥 Fire Meter".
//
//  Each flame animates:
//     • LIT  — loops its idle frames forever.
//     • OUT  — when burned, plays its smoke frames once, then goes empty.
//
//  ─── DRAW YOUR ART (Assets.xcassets, transparent PNGs) ──────────────────
//     Idle loop:  flame1_lit1, flame1_lit2, flame1_lit3   (… up to flame5_)
//     Smoke loop: flame1_out1, flame1_out2, flame1_out3    (… up to flame5_)
//  • Start with just "flameN_lit1" for each; add _lit2/_lit3 later to animate.
//  • Prefer one shared set? Name them "flame_lit1/2/3" + "flame_out1/2/3".
//  • Until any art exists, a placeholder flame icon shows so you can position.
//

import SwiftUI

// MARK: - Asset resolver (auto-detects how many frames you've drawn)

enum PotionShopFlameAssets {

    private static var frameCache: [String: Int] = [:]

    /// Counts frames named "<prefix>1", "<prefix>2", … up to `maxProbe`.
    static func frameCount(prefix: String, maxProbe: Int = 8) -> Int {
        if let cached = frameCache[prefix] { return cached }
        var n = 0
        for k in 1...maxProbe {
            if UIImage(named: "\(prefix)\(k)") != nil { n = k } else { break }
        }
        frameCache[prefix] = n
        return n
    }

    /// Per-flame art first ("flame3_lit"), then a shared set ("flame_lit").
    /// nil = no art drawn yet for this state.
    static func resolve(flameIndex: Int, state: String) -> (prefix: String, count: Int)? {
        let perFlame = "flame\(flameIndex + 1)_\(state)"
        let perCount = frameCount(prefix: perFlame)
        if perCount > 0 { return (perFlame, perCount) }

        let shared = "flame_\(state)"
        let sharedCount = frameCount(prefix: shared)
        if sharedCount > 0 { return (shared, sharedCount) }

        return nil
    }

    static func clearCache() { frameCache.removeAll() }
}

// MARK: - The meter (a row of flames)

struct PotionShopFireMeterView: View {

    /// How many pieces are currently LIT (gs.fire).
    let current: Int
    /// Total number of pieces (PotionShopConfig.maxFire).
    let maxPieces: Int

    var body: some View {
        ZStack {
            ForEach(0..<maxPieces, id: \.self) { i in
                flame(at: i)
            }
        }
    }

    // Built in a helper with small typed steps so the SwiftUI type-checker
    // doesn't choke on one long math expression.
    @ViewBuilder
    private func flame(at i: Int) -> some View {
        let cfg = PotionShopLayoutConfig.shared

        let scale: Double = cfg.fireScaleAt(i)
        let size: CGFloat = CGFloat(cfg.fireMeterSize * scale)

        let rowX: Double = cfg.fireDefaultRowX(i, shown: maxPieces)
        let xValue: Double = cfg.fireMeterOffsetX + rowX + cfg.fireOffsetXAt(i)
        let yValue: Double = cfg.fireMeterOffsetY + cfg.fireOffsetYAt(i)

        PotionShopFlameView(
            flameIndex: i,
            isLit: i < current,
            size: size,
            fps: cfg.fireMeterFPS
        )
        .offset(x: CGFloat(xValue), y: CGFloat(yValue))
    }
}

// MARK: - A single flame (idle loop + burn-out smoke)

struct PotionShopFlameView: View {

    let flameIndex: Int      // 0-based; art is flame(flameIndex+1)_…
    let isLit: Bool
    let size: CGFloat
    var fps: Double

    /// When this flame last went out (drives the one-shot smoke). nil = none.
    @State private var extinguishedAt: Date? = nil

    var body: some View {
        TimelineView(.animation) { timeline in
            content(at: timeline.date)
                .frame(width: size, height: size)
        }
        .onChange(of: isLit) {
            extinguishedAt = isLit ? nil : Date()   // relit cancels smoke; out starts it
        }
    }

    @ViewBuilder
    private func content(at date: Date) -> some View {
        if isLit {
            litFrame(at: date)
        } else if let start = extinguishedAt,
                  let (prefix, count) = PotionShopFlameAssets.resolve(flameIndex: flameIndex, state: "out") {
            let elapsed: Double = date.timeIntervalSince(start)
            let f: Int = Int(elapsed * max(0.1, fps))
            if f < count,
               // JULY 5, 2026 (memory): budgeted load — the SwiftUI
               // Image("name") initializer pinned a FULL-RES decode of
               // every drawn flame frame in the system cache.
               let ui = PotionShopImageLoader.loadDisplayImage(named: "\(prefix)\(f + 1)", displaySize: size) {
                Image(uiImage: ui).resizable().scaledToFit()               // smoke playing
            } else {
                Color.clear                                            // empty after smoke
            }
        } else {
            Color.clear                                                // spent / no smoke art
        }
    }

    @ViewBuilder
    private func litFrame(at date: Date) -> some View {
        if let (prefix, count) = PotionShopFlameAssets.resolve(flameIndex: flameIndex, state: "lit"), count > 0 {
            let t: Double = date.timeIntervalSinceReferenceDate + Double(flameIndex) * 0.17
            let frame: Int = Int(t * max(0.1, fps)) % count
            // JULY 5, 2026 (memory): budgeted load, same reason as the
            // smoke frames above — never Image("name") for drawn art.
            if let ui = PotionShopImageLoader.loadDisplayImage(named: "\(prefix)\(frame + 1)", displaySize: size) {
                Image(uiImage: ui).resizable().scaledToFit()
            } else {
                Image(systemName: "flame.fill")
                    .resizable().scaledToFit()
                    .foregroundColor(Color(red: 0.95, green: 0.55, blue: 0.15))
                    .padding(2)
            }
        } else {
            Image(systemName: "flame.fill")
                .resizable().scaledToFit()
                .foregroundColor(Color(red: 0.95, green: 0.55, blue: 0.15))
                .padding(2)
        }
    }
}
