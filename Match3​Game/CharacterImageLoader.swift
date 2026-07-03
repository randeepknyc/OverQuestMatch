//
//  CharacterImageLoader.swift
//  OverQuestMatch3
//
//  🔍 SMART CHARACTER IMAGE LOADER
//
//  Fixes two sneaky problems with character art in one place:
//
//  1. FINDING the image. UIImage(named:) only checks Assets.xcassets
//     and top-level files. If a PNG lives in a folder elsewhere in the
//     app (like the cauldron game's art), it can silently fail. This
//     loader searches the ENTIRE app bundle as a backup.
//
//  2. EMPTY SPACE. The gmarker drawings have big transparent margins
//     around the characters. Squeezed into a small portrait frame,
//     the visible crop can end up mostly blank. This loader TRIMS
//     the transparent padding so the character fills the portrait.
//
//  Everything is cached — each image is found and trimmed only once.
//

import UIKit

enum CharacterImageLoader {

    /// Images we've already found + trimmed (so it's fast forever after)
    private static var cache: [String: UIImage] = [:]
    /// Names we already know don't exist (avoids repeat searches)
    private static var misses: Set<String> = []

    /// Load a character image by name — searches everywhere, trims
    /// transparent padding, caches the result. Returns nil if the
    /// image truly doesn't exist anywhere in the app.
    static func load(_ name: String) -> UIImage? {
        if let cached = cache[name] { return cached }
        if misses.contains(name) { return nil }

        // 1st try: normal lookup (Assets.xcassets etc.)
        var found = UIImage(named: name)

        // 2nd try: search the whole app bundle for the file
        if found == nil {
            found = searchBundle(for: name)
        }

        guard let image = found else {
            misses.insert(name)
            return nil
        }

        // Trim transparent margins so portraits aren't mostly empty air
        let trimmed = image.trimmingTransparentMargins()
        cache[name] = trimmed
        return trimmed
    }

    /// Does this image exist anywhere in the app?
    static func exists(_ name: String) -> Bool {
        load(name) != nil
    }

    // ─────────────────────────────────────────────────────────────
    // Deep bundle search — looks in every folder inside the app
    // ─────────────────────────────────────────────────────────────
    private static func searchBundle(for name: String) -> UIImage? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        let fm = FileManager.default
        let targets = ["\(name).png", "\(name).jpg", "\(name).jpeg"]

        if let enumerator = fm.enumerator(atPath: resourcePath) {
            for case let path as String in enumerator {
                let fileName = (path as NSString).lastPathComponent
                if targets.contains(fileName) {
                    let fullPath = (resourcePath as NSString).appendingPathComponent(path)
                    if let image = UIImage(contentsOfFile: fullPath) {
                        print("🔍 CharacterImageLoader: found '\(name)' at \(path)")
                        return image
                    }
                }
            }
        }
        return nil
    }
}

// ═══════════════════════════════════════════════════════════════
// ✂️ TRANSPARENT MARGIN TRIMMER
// Scans the image for the smallest box containing visible pixels
// and crops to it (with a little breathing room).
// ═══════════════════════════════════════════════════════════════

extension UIImage {

    func trimmingTransparentMargins() -> UIImage {
        guard let cgImage = self.cgImage else { return self }

        let width = cgImage.width
        let height = cgImage.height
        guard width > 1, height > 1 else { return self }

        // Draw into a raw pixel buffer so we can read alpha values
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return self }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Find the bounding box of visible (non-transparent) pixels.
        // Sampling every 2nd pixel keeps it fast on big images.
        var minX = width, maxX = 0, minY = height, maxY = 0
        let alphaThreshold: UInt8 = 10
        let step = 2

        for y in stride(from: 0, to: height, by: step) {
            for x in stride(from: 0, to: width, by: step) {
                let alpha = pixels[y * bytesPerRow + x * bytesPerPixel + 3]
                if alpha > alphaThreshold {
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }

        // Nothing visible, or already fills the canvas? Return as-is.
        guard maxX > minX, maxY > minY else { return self }
        let boxWidth = maxX - minX
        let boxHeight = maxY - minY
        if boxWidth > Int(Double(width) * 0.92) && boxHeight > Int(Double(height) * 0.92) {
            return self
        }

        // A touch of breathing room around the character (4% of the box)
        let pad = max(4, Int(Double(max(boxWidth, boxHeight)) * 0.04))
        let cropRect = CGRect(
            x: max(0, minX - pad),
            y: max(0, minY - pad),
            width: min(width - max(0, minX - pad), boxWidth + pad * 2),
            height: min(height - max(0, minY - pad), boxHeight + pad * 2)
        )

        guard let cropped = cgImage.cropping(to: cropRect) else { return self }
        return UIImage(cgImage: cropped, scale: self.scale, orientation: self.imageOrientation)
    }
}
