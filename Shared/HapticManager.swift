//
//  HapticManager.swift
//  OverQuestMatch3
//
//  Haptic feedback system for tactile responses
//

import SwiftUI

/// Centralized haptic feedback manager for game interactions
@Observable
class HapticManager {
    
    // ═══════════════════════════════════════════════════════════════
    // ⚡ HAPTIC CUSTOMIZATION SETTINGS - ADJUST THESE!
    // ═══════════════════════════════════════════════════════════════
    
    // TILE INTERACTIONS
    var tileTapIntensity: Double = 0.5           // How strong tile taps feel (0.0-1.0)
    
    // SWAP FEEDBACK
    var swapStartIntensity: Double = 0.7         // Starting a swap
    var swapCompleteIntensity: Double = 0.8      // Successful swap completion
    
    // MATCH INTENSITIES (by size)
    var match3Intensity: Double = 0.6            // 3-gem match
    var match4Intensity: Double = 0.9            // 4-gem match
    var match5PlusIntensity: Double = 1.0        // 5+ gem match (max power!)
    
    // CASCADE COMBO SCALING
    var cascadeBaseIntensity: Double = 0.4       // Starting intensity for cascades
    var cascadeIntensityPerCombo: Double = 0.15  // How much stronger each combo gets
    
    // POWER SURGE SEQUENCE TIMING (milliseconds)
    var powerSurgeDelay1: Int = 100              // Delay between 1st and 2nd pulse
    var powerSurgeDelay2: Int = 200              // Delay between 2nd and 3rd pulse
    var powerSurge1stIntensity: Double = 1.0     // First pulse strength
    var powerSurge2ndIntensity: Double = 0.7     // Second pulse strength
    var powerSurge3rdIntensity: Double = 1.0     // Final pulse strength
    
    // ABILITY ACTIVATION
    var abilityDelay: Int = 50                   // Delay between ability pulses (ms)
    var abilityFirstIntensity: Double = 1.0      // First pulse
    var abilitySecondIntensity: Double = 0.6     // Second pulse
    
    // BATTLE DAMAGE
    var heavyDamageThreshold: Int = 10           // Damage >= this = heavy haptic
    var playerHeavyDamageIntensity: Double = 1.0 // Player takes big hit
    var playerLightDamageIntensity: Double = 0.7 // Player takes small hit
    var enemyHeavyDamageIntensity: Double = 0.9  // Enemy takes big hit
    var enemyLightDamageIntensity: Double = 0.8  // Enemy takes small hit
    
    // VICTORY SEQUENCE TIMING
    var victoryDelay1: Int = 150                 // Delay between 1st and 2nd pulse
    var victoryDelay2: Int = 300                 // Delay between 2nd and 3rd pulse
    
    // DEFEAT SEQUENCE TIMING
    var defeatDelay: Int = 100                   // Delay after error notification
    var defeatIntensity: Double = 0.5            // Final thud intensity
    
    // ═══════════════════════════════════════════════════════════════
    
    // Haptic generators (reused for performance)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    init() {
        // Pre-prepare generators for instant feedback
        prepareAll()
    }
    
    /// Prepare all generators (call when game starts)
    func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactRigid.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    // MARK: - Tile Interactions
    
    /// Light tap when selecting a tile
    func tileTapped() {
        impactLight.impactOccurred(intensity: tileTapIntensity)
    }
    
    /// Selection change (subtle feedback)
    func tileSelected() {
        selectionFeedback.selectionChanged()
    }
    
    /// Medium impact when dragging starts
    func swapStarted() {
        impactMedium.impactOccurred(intensity: swapStartIntensity)
    }
    
    /// Satisfying "snap" when swap completes successfully
    func swapCompleted() {
        impactMedium.impactOccurred(intensity: swapCompleteIntensity)
    }
    
    /// Heavy impact for invalid swap (rejection)
    func swapRejected() {
        notificationFeedback.notificationOccurred(.error)
    }
    
    // MARK: - Match Events
    
    /// Light rapid taps for match (scales with match size)
    func matchDetected(tileCount: Int) {
        // More tiles = stronger feedback
        if tileCount >= 5 {
            impactHeavy.impactOccurred(intensity: match5PlusIntensity)
        } else if tileCount == 4 {
            impactMedium.impactOccurred(intensity: match4Intensity)
        } else {
            impactMedium.impactOccurred(intensity: match3Intensity)
        }
    }
    
    /// Cascade/combo feedback (successive matches)
    func cascadeTriggered(comboNumber: Int) {
        // Higher combos = stronger feedback
        let intensity = min(1.0, cascadeBaseIntensity + (Double(comboNumber) * cascadeIntensityPerCombo))
        impactMedium.impactOccurred(intensity: intensity)
    }
    
    /// Power Surge 4+ match effect
    func powerSurgeTriggered() {
        // Sequence of impacts for dramatic effect
        impactHeavy.impactOccurred(intensity: powerSurge1stIntensity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(powerSurgeDelay1)) {
            self.impactHeavy.impactOccurred(intensity: self.powerSurge2ndIntensity)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(powerSurgeDelay2)) {
            self.impactRigid.impactOccurred(intensity: self.powerSurge3rdIntensity)
        }
    }
    
    // MARK: - Battle Events
    
    /// Player takes damage
    func playerDamaged(damage: Int) {
        if damage >= heavyDamageThreshold {
            impactHeavy.impactOccurred(intensity: playerHeavyDamageIntensity)
        } else {
            impactMedium.impactOccurred(intensity: playerLightDamageIntensity)
        }
    }
    
    /// Enemy takes damage
    func enemyDamaged(damage: Int) {
        if damage >= heavyDamageThreshold {
            impactMedium.impactOccurred(intensity: enemyHeavyDamageIntensity)
        } else {
            impactLight.impactOccurred(intensity: enemyLightDamageIntensity)
        }
    }
    
    /// Shield activated
    func shieldActivated() {
        impactRigid.impactOccurred(intensity: 0.6)
    }
    
    /// Mana gained
    func manaGained() {
        impactLight.impactOccurred(intensity: 0.5)
    }
    
    /// Coffee cup ability activated
    func abilityActivated() {
        impactHeavy.impactOccurred(intensity: abilityFirstIntensity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(abilityDelay)) {
            self.impactMedium.impactOccurred(intensity: self.abilitySecondIntensity)
        }
    }
    
    // MARK: - UI Events
    
    /// Button press (general)
    func buttonPressed() {
        impactLight.impactOccurred()
    }
    
    /// Menu navigation
    func menuNavigated() {
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Game State Events
    
    /// Victory
    func victory() {
        notificationFeedback.notificationOccurred(.success)
        
        // Triple-pulse celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(victoryDelay1)) {
            self.impactMedium.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(victoryDelay2)) {
            self.impactHeavy.impactOccurred()
        }
    }
    
    /// Defeat
    func defeat() {
        notificationFeedback.notificationOccurred(.error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(defeatDelay)) {
            self.impactHeavy.impactOccurred(intensity: self.defeatIntensity)
        }
    }
}
