//
//  CharacterAnimationManager.swift
//  OverQuestMatch3
//
//  Created: Session 14 - Character Animation Priority System
//  Purpose: Manages character animation queueing, priorities, and state transitions
//

import Foundation
import SwiftUI

/// Manages animation state and queueing for a single character
@Observable
class CharacterAnimationManager {
    
    // MARK: - Properties
    
    /// The character being managed (the source of truth for state)
    let character: Character
    
    /// When the current state started
    private var currentStateStartTime: Date = Date()
    
    /// Queue of pending animations
    private var animationQueue: [CharacterState] = []
    
    /// Is an animation currently playing?
    private var isPlayingAnimation: Bool = false
    
    /// Timer for managing animation durations
    private var animationTimer: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(character: Character) {
        self.character = character
        self.currentStateStartTime = Date()
    }
    
    // MARK: - Public Methods
    
    /// Request to show a new animation state
    /// This respects priorities and queueing rules
    @MainActor
    func requestState(_ newState: CharacterState, force: Bool = false) {
        
        // SPECIAL CASE: Victory/Defeat only show at battle end
        if newState == .victory || newState == .defeat {
            if force {
                // Force means battle is actually over, show it immediately
                setStateImmediately(newState)
                return
            } else {
                // Don't queue or show victory/defeat during battle
                return
            }
        }
        
        // SPECIAL CASE: Idle
        if newState == .idle {
            // If nothing is happening, return to idle
            if animationQueue.isEmpty && !isPlayingAnimation {
                setStateImmediately(.idle)
            }
            // Otherwise, idle will happen naturally when queue is empty
            return
        }
        
        // CURRENT STATE: Idle
        if character.currentState == .idle {
            // Idle is always interruptible
            if CharacterAnimationConfig.canInterruptIdle(with: newState) {
                playAnimation(newState)
                return
            }
        }
        
        // CURRENT STATE: Non-idle
        let currentPriority = CharacterAnimationConfig.priority(for: character.currentState)
        let newPriority = CharacterAnimationConfig.priority(for: newState)
        
        // Check interrupt behavior
        switch CharacterAnimationConfig.interruptBehavior {
            
        case .queue:
            // Queue the animation (unless it's lower priority than current)
            if newPriority >= currentPriority {
                addToQueue(newState)
            }
            // Lower priority animations are dropped
            
        case .override:
            // Higher priority interrupts immediately
            if newPriority > currentPriority {
                // Cancel current animation and play new one
                cancelCurrentAnimation()
                playAnimation(newState)
            } else if newPriority == currentPriority {
                // Same priority: queue it
                addToQueue(newState)
            }
            // Lower priority animations are dropped
        }
    }
    
    /// Force a state change immediately (bypasses queue and priorities)
    @MainActor
    func setStateImmediately(_ state: CharacterState) {
        cancelCurrentAnimation()
        animationQueue.removeAll()
        character.currentState = state
        currentStateStartTime = Date()
        
        // If not idle, play the animation
        if state != .idle {
            playAnimation(state)
        }
    }
    
    /// Clear all queued animations and return to idle
    @MainActor
    func reset() {
        cancelCurrentAnimation()
        animationQueue.removeAll()
        character.currentState = .idle
        currentStateStartTime = Date()
        isPlayingAnimation = false
    }
    
    /// Get current queue size (for debugging)
    func queueSize() -> Int {
        return animationQueue.count
    }
    
    // MARK: - Private Methods
    
    /// Add animation to queue
    @MainActor
    private func addToQueue(_ state: CharacterState) {
        
        // Check if we should replace duplicates
        if CharacterAnimationConfig.replaceDuplicatesInQueue {
            // Remove existing animations of the same type
            animationQueue.removeAll { $0 == state }
        }
        
        // Check queue size limit
        if animationQueue.count >= CharacterAnimationConfig.maxQueueSize {
            // Remove oldest (first) animation
            animationQueue.removeFirst()
        }
        
        // Add new animation to end of queue
        animationQueue.append(state)
    }
    
    /// Play an animation (handles duration and auto-return to idle)
    @MainActor
    private func playAnimation(_ state: CharacterState) {
        
        // Cancel any existing timer
        animationTimer?.cancel()
        
        // Set the state on the character (this triggers SwiftUI updates)
        character.currentState = state
        currentStateStartTime = Date()
        isPlayingAnimation = true
        
        // Get duration
        let duration = CharacterAnimationConfig.duration(for: state)
        
        // If duration is 0 (like idle), don't auto-transition
        if duration <= 0 {
            isPlayingAnimation = false
            return
        }
        
        // Start timer to handle animation completion
        animationTimer = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(duration))
                
                // Animation finished, check queue
                if !animationQueue.isEmpty {
                    // Play next queued animation
                    let nextState = animationQueue.removeFirst()
                    playAnimation(nextState)
                } else {
                    // No more animations, return to idle
                    character.currentState = .idle
                    currentStateStartTime = Date()
                    isPlayingAnimation = false
                }
            } catch {
                // Task was cancelled
                isPlayingAnimation = false
            }
        }
    }
    
    /// Cancel the current animation timer
    private func cancelCurrentAnimation() {
        animationTimer?.cancel()
        animationTimer = nil
        isPlayingAnimation = false
    }
}

// MARK: - Global Animation Managers

/// Global managers for player and enemy (accessible from anywhere)
class AnimationManagers {
    static var player: CharacterAnimationManager?
    static var enemy: CharacterAnimationManager?
}
