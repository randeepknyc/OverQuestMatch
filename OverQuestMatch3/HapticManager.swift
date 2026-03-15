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
        impactLight.impactOccurred()
    }
    
    /// Selection change (subtle feedback)
    func tileSelected() {
        selectionFeedback.selectionChanged()
    }
    
    /// Medium impact when dragging starts
    func swapStarted() {
        impactMedium.impactOccurred()
    }
    
    /// Satisfying "snap" when swap completes successfully
    func swapCompleted() {
        impactMedium.impactOccurred(intensity: 0.8)
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
            impactHeavy.impactOccurred()
        } else if tileCount == 4 {
            impactMedium.impactOccurred(intensity: 0.9)
        } else {
            impactMedium.impactOccurred(intensity: 0.6)
        }
    }
    
    /// Cascade/combo feedback (successive matches)
    func cascadeTriggered(comboNumber: Int) {
        // Higher combos = stronger feedback
        let intensity = min(1.0, 0.4 + (Double(comboNumber) * 0.15))
        impactMedium.impactOccurred(intensity: intensity)
    }
    
    /// Power Surge 4+ match effect
    func powerSurgeTriggered() {
        // Sequence of impacts for dramatic effect
        impactHeavy.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactHeavy.impactOccurred(intensity: 0.7)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactRigid.impactOccurred(intensity: 1.0)
        }
    }
    
    // MARK: - Battle Events
    
    /// Player takes damage
    func playerDamaged(damage: Int) {
        if damage >= 10 {
            impactHeavy.impactOccurred()
        } else {
            impactMedium.impactOccurred(intensity: 0.7)
        }
    }
    
    /// Enemy takes damage
    func enemyDamaged(damage: Int) {
        if damage >= 15 {
            impactMedium.impactOccurred(intensity: 0.9)
        } else {
            impactLight.impactOccurred(intensity: 0.8)
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
        impactHeavy.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.impactMedium.impactOccurred(intensity: 0.6)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.impactMedium.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.impactHeavy.impactOccurred()
        }
    }
    
    /// Defeat
    func defeat() {
        notificationFeedback.notificationOccurred(.error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactHeavy.impactOccurred(intensity: 0.5)
        }
    }
}
