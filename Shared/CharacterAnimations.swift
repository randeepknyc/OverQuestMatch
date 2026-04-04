//
//  CharacterAnimations.swift
//  OverQuestMatch3
//
//  Character portrait animation system
//  Handles line boil animations and state-based portrait switching
//

import SwiftUI
import Combine

// MARK: - State-Based Character Portrait

/// Main portrait view that switches between static images and line boil animations
/// based on character name and current state
struct StateBasedCharacterPortrait: View {
    @Bindable var character: Character
    
    var body: some View {
        // 🎬 SESSION 14 FIX: Read state and use stateChangeID for forced updates
        let displayState = character.currentState
        
        Group {
            // Ramp uses line boil animations (expandable to all states)
            if character.name == "Ramp" {
                RampAnimatedPortrait(state: displayState)
            }
            // Ednar uses static images for all states (for now)
            else if character.name == "Ednar" || character.name == "Toad King" {
                StaticCharacterPortrait(character: character, displayState: displayState)
            }
            // Fallback for unknown characters
            else {
                FallbackPortrait(characterName: character.name)
            }
        }
        .id(character.stateChangeID) // ← Force refresh when stateChangeID changes
    }
}

// MARK: - Ramp Animated Portrait (Line Boil System)

/// Ramp's portrait system - uses line boil animation for idle, static images for other states
/// EXPANDABLE: Add more line boil animations by updating the switch statement below
struct RampAnimatedPortrait: View {
    let state: CharacterState
    
    var body: some View {
        Group {
            switch state {
            case .idle:
                // Idle state uses line boil animation
                LineBoilAnimation(framePrefix: "ramp_boil", frameCount: 3)
                
            case .attack:
                // Attack state - 4-frame animation! ⚔️
                LineBoilAnimation(framePrefix: "ramp_attack", frameCount: 3)
                
            case .hurt:
                // Hurt state - enemy damage - static image (FOR NOW)
                // FUTURE: Change to LineBoilAnimation(framePrefix: "ramp_hurt_boil", frameCount: 3)
                StaticImage(imageName: "ramp_hurt")
                
            case .hurt2:
                // Hurt2 state - invalid swap penalty - static image (FOR NOW)
                // FUTURE: Change to LineBoilAnimation(framePrefix: "ramp_hurt2_boil", frameCount: 3)
                StaticImage(imageName: "ramp_hurt2")
                
            case .defend:
                // Defend state - static image (FOR NOW)
                // FUTURE: Change to LineBoilAnimation(framePrefix: "ramp_defend_boil", frameCount: 3)
                StaticImage(imageName: "ramp_defend")
                
            case .spell:
                // Spell state - static image (FOR NOW)
                // FUTURE: Change to LineBoilAnimation(framePrefix: "ramp_spell_boil", frameCount: 3)
                StaticImage(imageName: "ramp_spell")
                
            case .victory:
                // Victory state - static image (FOR NOW)
                // FUTURE: Change to LineBoilAnimation(framePrefix: "ramp_victory_boil", frameCount: 3)
                StaticImage(imageName: "ramp_victory")
                
            case .defeat:
                // Defeat state - static image (FOR NOW)
                // FUTURE: Change to LineBoilAnimation(framePrefix: "ramp_defeat_boil", frameCount: 3)
                StaticImage(imageName: "ramp_defeat")
            }
        }
    }
}

// MARK: - Line Boil Animation Engine

/// Generic line boil animation that cycles through numbered frames
/// Example: framePrefix "ramp_boil" with frameCount 3 cycles: ramp_boil1, ramp_boil2, ramp_boil3
struct LineBoilAnimation: View {
    let framePrefix: String  // e.g., "ramp_boil", "ramp_attack_boil"
    let frameCount: Int      // How many frames (e.g., 3 = frame1, frame2, frame3)
    
    @State private var currentFrame = 0
    
    // Timer controls animation speed (0.15 seconds per frame = ~6.6 FPS)
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            // Build frame sequence with smooth back-and-forth loop
            let frameSequence = buildFrameSequence()
            
            if let image = UIImage(named: frameSequence[currentFrame]) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Fallback if frames not found
                FallbackPortrait(characterName: framePrefix)
            }
        }
        .onReceive(timer) { _ in
            currentFrame = (currentFrame + 1) % buildFrameSequence().count
        }
    }
    
    // Creates simple forward loop: 1, 2, 3, 1, 2, 3...
    private func buildFrameSequence() -> [String] {
        guard frameCount > 0 else { return [] }
        
        // Simple forward loop for all frame counts
        var sequence: [String] = []
        for i in 1...frameCount {
            sequence.append("\(framePrefix)\(i)")
        }
        
        return sequence
    }
}

// MARK: - Static Character Portrait (Non-Animated)

/// Shows a single static image based on character state
/// Used for Ednar and any character without line boil animations
struct StaticCharacterPortrait: View {
    let character: Character
    let displayState: CharacterState  // 🎬 SESSION 14: Use animation manager state
    
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

// MARK: - 📚 HOW TO ADD MORE LINE BOIL ANIMATIONS

/*
 
 ═══════════════════════════════════════════════════════════════
 📖 GUIDE: Adding Line Boil Animations for Other States
 ═══════════════════════════════════════════════════════════════
 
 CURRENT SETUP:
 - Idle: Line boil animation (ramp_boil1, ramp_boil2, ramp_boil3)
 - All other states: Static images (ramp_attack, ramp_hurt, etc.)
 
 TO ADD LINE BOIL FOR ATTACK:
 
 1️⃣ Add your images to Assets.xcassets:
    - ramp_attack_boil1.png
    - ramp_attack_boil2.png
    - ramp_attack_boil3.png
 
 2️⃣ Update RampAnimatedPortrait above - find the .attack case:
 
    case .attack:
        // OLD:
        StaticImage(imageName: "ramp_attack")
        
        // NEW:
        LineBoilAnimation(framePrefix: "ramp_attack_boil", frameCount: 3)
 
 3️⃣ Done! The animation will automatically loop smoothly.
 
 ═══════════════════════════════════════════════════════════════
 
 REPEAT FOR OTHER STATES:
 - Hurt: ramp_hurt_boil1/2/3 → LineBoilAnimation(framePrefix: "ramp_hurt_boil", frameCount: 3)
 - Spell: ramp_spell_boil1/2/3 → LineBoilAnimation(framePrefix: "ramp_spell_boil", frameCount: 3)
 - Victory: ramp_victory_boil1/2/3 → LineBoilAnimation(framePrefix: "ramp_victory_boil", frameCount: 3)
 - etc.
 
 ANIMATION SPEED:
 - Current: 0.15 seconds per frame (~6.6 FPS)
 - Faster: 0.1 seconds (~10 FPS) - change "every: 0.15" in timer
 - Slower: 0.2 seconds (~5 FPS)
 
 ADDING MORE FRAMES:
 - If you have 5 frames: LineBoilAnimation(framePrefix: "ramp_idle_boil", frameCount: 5)
 - The system will automatically create a smooth 1→2→3→4→5→4→3→2 loop
 
 ═══════════════════════════════════════════════════════════════
 
 */
