//
//  CharacterAnimations.swift
//  OverQuestMatch3
//
//  Character portrait animation system
//  Line boil flipbooks for EVERY state, with automatic fallback to
//  static images until the _boil PNG frames are added to Assets.
//

import SwiftUI
import Combine

// MARK: - State-Based Character Portrait

/// Main portrait view — EVERY character (heroes AND enemies) now goes
/// through the same animation pipeline.
struct StateBasedCharacterPortrait: View {
    @Bindable var character: Character

    var body: some View {
        // 🆕 FULLY GENERIC (Session 25.1): the asset prefix comes from
        // character.imageName ("ramp" for Ramp, "ednar" for Ednar/Toad King).
        // Any new character automatically works — hero or enemy — as long
        // as their assets follow the naming convention:
        //   <prefix>_boil1/2/3            (idle flipbook)
        //   <prefix>_<state>_boil1/2/3    (other state flipbooks)
        //   <prefix>_<state>              (static fallback per state)
        //   <prefix>_idle                 (last-resort static fallback)
        AnimatedHeroPortrait(assetPrefix: character.imageName,
                             state: character.currentState)
    }
}

// MARK: - Animated Hero Portrait (Line Boil, all states, all characters)

/// Every state plays a 3-frame boil loop. Fallback chain if art is missing:
///   1. Boil frames (<prefix>_<state>_boil1/2/3)  → animates
///   2. Static state image (<prefix>_<state>)      → static pose
///   3. Static idle image (<prefix>_idle)          → character's idle art
///   4. Blue circle with initial                    → nothing found at all
/// This means a character with ONLY an idle image (like Ednar today) shows
/// that for every state — identical to the old behavior — and upgrades
/// automatically as art is added.
struct AnimatedHeroPortrait: View {
    let assetPrefix: String       // "ramp", "ednar", later "goro", etc.
    let state: CharacterState

    var body: some View {
        // Idle uses the short legacy pattern <prefix>_boil1/2/3.
        // All other states: <prefix>_<state>_boil1/2/3.
        let framePrefix = (state == .idle)
            ? "\(assetPrefix)_boil"
            : "\(assetPrefix)_\(state.boilSuffix)_boil"

        // Smart fallback: prefer the state's own static image, otherwise
        // drop to the character's idle image (e.g. ednar_attack doesn't
        // exist yet → show ednar_idle, exactly like before)
        let stateStatic = "\(assetPrefix)_\(state.boilSuffix)"
        let fallback = (UIImage(named: stateStatic) != nil)
            ? stateStatic
            : "\(assetPrefix)_idle"

        LineBoilAnimation(framePrefix: framePrefix,
                          frameCount: 3,
                          fallbackImageName: fallback)
    }
}

// MARK: - Line Boil Animation Engine

/// Cycles framePrefix1 → framePrefix2 → framePrefix3 → repeat,
/// at 0.15s per frame (one full loop = 0.45 seconds).
/// If frame 1 doesn't exist in Assets, shows fallbackImageName instead.
///
/// 🔧 V2 ENGINE: Uses TimelineView (driven by the system clock) instead of
/// a Timer stored inside the view. The old Timer approach could freeze if
/// SwiftUI recreated the view at the wrong moment — the clock-based version
/// has no internal state at all, so it can never freeze or reset.
/// Bonus: all boil animations stay perfectly in sync with each other.
struct LineBoilAnimation: View {
    let framePrefix: String       // e.g. "ramp_boil", "ramp_attack_boil"
    let frameCount: Int           // how many frames (3 = frame1..frame3)
    var fallbackImageName: String? = nil

    // ⏱ ANIMATION SPEED: 0.15s per frame ≈ 6.6 FPS.
    // Faster boil: 0.1 · Slower boil: 0.2
    private let frameDuration: Double = 0.15

    // Simple forward loop: 1, 2, 3, 1, 2, 3...
    private var frames: [String] {
        guard frameCount > 0 else { return [] }
        return (1...frameCount).map { "\(framePrefix)\($0)" }
    }

    var body: some View {
        if let firstFrame = frames.first, UIImage(named: firstFrame) != nil {
            // ✅ Boil frames exist → animate, frame chosen by the clock
            TimelineView(.periodic(from: .now, by: frameDuration)) { context in
                let tick = Int(context.date.timeIntervalSinceReferenceDate / frameDuration)
                let frameName = frames[tick % frames.count]

                if let image = UIImage(named: frameName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    FallbackPortrait(characterName: framePrefix)
                }
            }
        } else if let fb = fallbackImageName, let image = UIImage(named: fb) {
            // 🖼 Boil frames not added yet → old static art
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            // Nothing found at all
            FallbackPortrait(characterName: framePrefix)
        }
    }
}

// MARK: - Static Character Portrait (Non-Animated)

/// Shows a single static image based on character state.
/// Used for Ednar and any character without line boil animations.
struct StaticCharacterPortrait: View {
    let character: Character
    let displayState: CharacterState

    var body: some View {
        let imageName = displayState.imageName(for: character.name)

        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            FallbackPortrait(characterName: character.name)
        }
    }
}

// MARK: - Static Image Helper

/// Simple static image loader with fallback
struct StaticImage: View {
    let imageName: String

    var body: some View {
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            FallbackPortrait(characterName: imageName)
        }
    }
}

// MARK: - Fallback Portrait

/// Generic fallback when images are missing
struct FallbackPortrait: View {
    let characterName: String

    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.3))
            .overlay(
                Text(String(characterName.prefix(1)))
                    .font(.system(size: 55, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}

// MARK: - 📚 HOW THE NEW SYSTEM WORKS

/*

 ═══════════════════════════════════════════════════════════════
 📖 ADDING BOIL ANIMATIONS — NO CODE CHANGES NEEDED ANYMORE!
 ═══════════════════════════════════════════════════════════════

 Just drop the PNG frames into Assets.xcassets with these names
 and the matching state automatically starts animating:

   idle     →  ramp_boil1, ramp_boil2, ramp_boil3   (already working)
   attack   →  ramp_attack_boil1 / 2 / 3
   hurt     →  ramp_hurt_boil1 / 2 / 3
   hurt2    →  ramp_hurt2_boil1 / 2 / 3
   defend   →  ramp_defend_boil1 / 2 / 3
   spell    →  ramp_spell_boil1 / 2 / 3
   victory  →  ramp_victory_boil1 / 2 / 3
   defeat   →  ramp_defeat_boil1 / 2 / 3

 Until a state's frames exist, it shows the old static image
 (ramp_attack, ramp_hurt, etc.) — nothing breaks in the meantime.

 ANIMATION SPEED: change "every: 0.15" in LineBoilAnimation's timer.

 HOLD TIMES & PRIORITIES: see the config table at the top of
 AnimationCoordinator.swift.

 ═══════════════════════════════════════════════════════════════

 */
