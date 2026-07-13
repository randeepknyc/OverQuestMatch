//
//  TileArt.swift
//  OverQuestMatch3
//
//  🎨 SMART TILE ART LOADER
//
//  The signature gem needs art for every enemy, but drawing 15 tiles
//  takes time! This helper fills the gap:
//
//    • If the enemy's tile PNG exists (like fire_tile) → shows it
//    • If not → draws the enemy's EMOJI as the gem (❄️ 🌿 ⚡ 🔮 ...)
//
//  The moment you add a PNG named e.g. "ice_tile" to Assets.xcassets,
//  Ironhilde's gems automatically switch from ❄️ to your art.
//  No code changes ever needed.
//

import SwiftUI
import UIKit

enum TileArt {

    /// SwiftUI Image for a tile type. Signature gems without custom
    /// art come back as a crisp emoji image. Supports .resizable()
    /// and all normal Image modifiers.
    static func image(for type: TileType) -> Image {
        if let ui = uiImage(for: type) {
            return Image(uiImage: ui)
        }
        return Image(type.imageName)
    }

    /// UIKit version for code that checks `if let uiImage = ...`
    static func uiImage(for type: TileType) -> UIImage? {
        // The signature slot without custom art → emoji gem
        if type == .fire {
            let sig = EnemyRoster.current.signature
            if !sig.hasCustomTileArt {
                return EmojiRenderer.image(for: sig.emoji)
            }
        }
        return UIImage(named: type.imageName)
    }
}

// ═══════════════════════════════════════════════════════════════
// ✏️ EMOJI → IMAGE RENDERER
// Draws an emoji into a sharp 256×256 image, once, then caches it.
// ═══════════════════════════════════════════════════════════════

enum EmojiRenderer {

    /// Already-drawn emojis so we never render the same one twice
    private static var cache: [String: UIImage] = [:]

    static func image(for emoji: String) -> UIImage {
        if let cached = cache[emoji] {
            return cached
        }

        let canvasSize = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        let rendered = renderer.image { _ in
            let font = UIFont.systemFont(ofSize: 200)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let text = emoji as NSString
            let textSize = text.size(withAttributes: attributes)

            // Center the emoji on the canvas
            let origin = CGPoint(
                x: (canvasSize.width - textSize.width) / 2,
                y: (canvasSize.height - textSize.height) / 2
            )
            text.draw(at: origin, withAttributes: attributes)
        }

        cache[emoji] = rendered
        return rendered
    }
}
