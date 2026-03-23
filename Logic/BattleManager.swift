//
//  BattleManager.swift
//  OverQuestMatch3
//

import Foundation

@Observable
class BattleManager {
    var player: Character
    var enemy: Character
    var mana: Int = 0
    var recentEvents: [BattleEvent] = []
    var comboCount: Int = 0
    var turnCount: Int = 0
    var hapticManager: HapticManager?  // ✨ NEW: Haptic feedback
    
    var gameState: GameState = .playing
    var pendingGameOver: GameState? = nil  // ✨ NEW: Holds victory/defeat until animations finish
    // ═══════════════════════════════════════════════════════════════
    // 🔥 SESSION 2 ADDITION: POWER SURGE FLAG (START)
    // ═══════════════════════════════════════════════════════════════
    // Track if Power Surge was triggered this turn
    var triggeredPowerSurge = false
    // ═══════════════════════════════════════════════════════════════
    // 🔥 SESSION 2 ADDITION: POWER SURGE FLAG (END)
    // ═══════════════════════════════════════════════════════════════
    
    enum GameState {
        case playing
        case victory
        case defeat
    }
    
    init() {
        self.player = Character(
            name: "Ramp",
            imageName: GameAssets.barbarianImage,
            maxHealth: BattleMechanicsConfig.playerStartingHealth,
            currentHealth: BattleMechanicsConfig.playerStartingHealth
        )
        
        self.enemy = Character(
            name: "Toad King",
            imageName: GameAssets.toadImage,
            maxHealth: BattleMechanicsConfig.enemyStartingHealth,
            currentHealth: BattleMechanicsConfig.enemyStartingHealth
        )
    }
    
    func processMatches(_ matches: [Match]) {
        guard gameState == .playing else { return }
        
        var totalDamage = 0
        var totalHealing = 0
        var totalShield = 0
        var totalMana = 0
        
        comboCount = matches.count
        
        // ═══════════════════════════════════════════════════════════════
        // 🔥 SESSION 2 ADDITION: RESET POWER SURGE FLAG (START)
        // ═══════════════════════════════════════════════════════════════
        // Reset power surge flag
        triggeredPowerSurge = false
        // ═══════════════════════════════════════════════════════════════
        // 🔥 SESSION 2 ADDITION: RESET POWER SURGE FLAG (END)
        // ═══════════════════════════════════════════════════════════════
        
        for match in matches {
            let matchCount = match.count
            let isCombo = comboCount > 1
            let multiplier = isCombo ? BattleMechanicsConfig.comboMultiplier : 1.0
            
            switch match.type {
            case .sword:
                let damage = Int(Double(BattleMechanicsConfig.swordDamagePerGem * matchCount) * multiplier)
                totalDamage += damage
                
                // 🎨 SET PLAYER TO ATTACK STATE
                player.currentState = .attack
                
                addEvent(barbarianAttackMessage(damage: damage, isCombo: isCombo))
                
            case .fire:
                let damage = Int(Double(BattleMechanicsConfig.fireDamagePerGem * matchCount) * multiplier)
                totalDamage += damage
                
                // 🎨 SET PLAYER TO ATTACK STATE
                player.currentState = .attack
                
                addEvent(magicAttackMessage(damage: damage, isCombo: isCombo))
                
            case .shield:
                let shield = BattleMechanicsConfig.shieldPerGem * matchCount
                totalShield += shield
                
                // 🎨 SET PLAYER TO DEFEND STATE
                player.currentState = .defend
                
                addEvent(shieldMessage(amount: shield, isCombo: isCombo))
                
            case .heart:
                let healing = BattleMechanicsConfig.healingPerGem * matchCount
                totalHealing += healing
                
                // 🎨 SET PLAYER TO DEFEND STATE (healing = defensive action)
                player.currentState = .defend
                
                addEvent(healMessage(amount: healing, isCombo: isCombo))
                
            case .mana:
                let manaGain = BattleMechanicsConfig.manaPerGem * matchCount
                totalMana += manaGain
                addEvent(manaMessage(amount: manaGain))
                
            case .poison:
                // ✅ UPDATED: Use poison message from config
                addEvent(BattleEvent(text: BattleMechanicsConfig.poisonMessage, type: .special))
            }
        }
        
        // Apply effects
        if totalDamage > 0 {
            enemy.takeDamage(totalDamage)
            hapticManager?.enemyDamaged(damage: totalDamage)  // ✨ Enemy damage haptic
        }
        if totalHealing > 0 {
            player.heal(totalHealing)
            hapticManager?.manaGained()  // ✨ Healing haptic (reuse mana sound)
        }
        if totalShield > 0 {
            player.addShield(totalShield)
            hapticManager?.shieldActivated()  // ✨ Shield haptic
        }
        if totalMana > 0 {
            mana = min(BattleMechanicsConfig.maxMana, mana + totalMana)
            hapticManager?.manaGained()  // ✨ Mana gain haptic
        }
        
        // ═══════════════════════════════════════════════════════════════
        // 🔥 SESSION 2 ADDITION: POWER SURGE DETECTION (START)
        // ═══════════════════════════════════════════════════════════════
        // POWER SURGE: 4+ matches in any single match group
        let totalMatches = matches.reduce(0) { $0 + $1.count }
        if totalMatches >= BattleMechanicsConfig.powerSurgeThreshold {
            triggeredPowerSurge = true
            let bonusMana = BattleMechanicsConfig.powerSurgeBonusMana
            mana = min(BattleMechanicsConfig.maxMana, mana + bonusMana)
            
            // ✅ UPDATED: Use power surge message from config
            let message = BattleMechanicsConfig.powerSurgeMessage
                .replacingOccurrences(of: "{totalMatches}", with: "\(totalMatches)")
                .replacingOccurrences(of: "{bonusMana}", with: "\(bonusMana)")
            addEvent(BattleEvent(text: message, type: .special))
        }
        // ═══════════════════════════════════════════════════════════════
        // 🔥 SESSION 2 ADDITION: POWER SURGE DETECTION (END)
        // ═══════════════════════════════════════════════════════════════
        
        // ═══════════════════════════════════════════════════════════════
        // 🎨 RETURN PLAYER TO IDLE STATE AFTER ANIMATIONS
        // ═══════════════════════════════════════════════════════════════
        // Return to idle after a delay (matches don't overlap)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            if gameState == .playing {
                player.currentState = .idle
            }
        }
        // ═══════════════════════════════════════════════════════════════
        
        checkGameOver()
    }
    
    @MainActor
    func enemyTurn() {
        guard gameState == .playing else { return }
        
        let damage = Int.random(in: BattleMechanicsConfig.enemyMinDamage...BattleMechanicsConfig.enemyMaxDamage)
        
        // Apply damage and effects
        player.takeDamage(damage)
        hapticManager?.playerDamaged(damage: damage)  // ✨ Player damage haptic
        addEvent(enemyAttackMessage(damage: damage))
        
        // ═══════════════════════════════════════════════════════════════
        // 🎨 NOTE: Portrait states are set in GameViewModel.enemyTurn()
        // This keeps visual animations in sync with async enemy turns
        // ═══════════════════════════════════════════════════════════════
        
        turnCount += 1
        checkGameOver()
    }
    
    private func checkGameOver() {
        if !enemy.isAlive {
            // ✨ DON'T show game over yet - store it for later!
            pendingGameOver = .victory
            
            // 🎨 SET PLAYER TO VICTORY STATE (animation will play)
            player.currentState = .victory
            
            hapticManager?.victory()  // ✨ Victory haptic celebration!
            
            // ✅ UPDATED: Use victory message from config
            addEvent(BattleEvent(text: BattleMechanicsConfig.victoryMessage, type: .special))
        } else if !player.isAlive {
            // ✨ DON'T show game over yet - store it for later!
            pendingGameOver = .defeat
            
            // 🎨 SET PLAYER TO DEFEAT STATE (animation will play)
            player.currentState = .defeat
            
            hapticManager?.defeat()  // ✨ Defeat haptic
            
            // ✅ UPDATED: Use defeat message from config
            addEvent(BattleEvent(text: BattleMechanicsConfig.defeatMessage, type: .special))
        }
    }
    
    func reset() {
        player.currentHealth = player.maxHealth
        player.shield = 0
        enemy.currentHealth = enemy.maxHealth
        enemy.shield = 0
        mana = 0
        recentEvents.removeAll()
        comboCount = 0
        turnCount = 0
        
        // Reset character states
        player.currentState = .idle
        enemy.currentState = .idle
        
        gameState = .playing
        pendingGameOver = nil  // ✅ FIX: Clear pending game over state
    }
    
    // MARK: - Ability System
    
    func canUseAbility(_ ability: Ability) -> Bool {
        return gameState == .playing && mana >= ability.manaCost
    }
    
    func useAbility(_ ability: Ability, gemType: TileType? = nil, gemCount: Int = 0) {
        guard canUseAbility(ability) else { return }
        
        // Spend mana
        mana -= ability.manaCost
        
        // Apply ability effects
        switch ability {
        case .heroicStrike:
            // This now means "Clear Board" - requires gem type selection
            if let gemType = gemType {
                // 🎨 SET PLAYER TO SPELL STATE
                player.currentState = .spell
                
                // ═══════════════════════════════════════════════════════════════
                // ✨ GEM CLEAR EFFECTS: Apply gem effects based on count
                // ═══════════════════════════════════════════════════════════════
                // Formula: (Number of gems cleared) × (effect per gem) = Total effect
                // Example: 12 swords cleared × 2 damage = 24 damage
                
                var totalDamage = 0
                var totalShield = 0
                var totalHealing = 0
                var totalMana = 0
                
                switch gemType {
                case .sword:
                    if BattleMechanicsConfig.gemClearApplySwordDamage {
                        totalDamage = gemCount * BattleMechanicsConfig.swordDamagePerGem
                        enemy.takeDamage(totalDamage)
                    }
                    
                case .fire:
                    if BattleMechanicsConfig.gemClearApplyFireDamage {
                        totalDamage = gemCount * BattleMechanicsConfig.fireDamagePerGem
                        enemy.takeDamage(totalDamage)
                    }
                    
                case .shield:
                    if BattleMechanicsConfig.gemClearApplyShield {
                        totalShield = gemCount * BattleMechanicsConfig.shieldPerGem
                        player.addShield(totalShield)
                    }
                    
                case .heart:
                    if BattleMechanicsConfig.gemClearApplyHealing {
                        totalHealing = gemCount * BattleMechanicsConfig.healingPerGem
                        player.heal(totalHealing)
                    }
                    
                case .mana:
                    if BattleMechanicsConfig.gemClearApplyMana {
                        totalMana = gemCount * BattleMechanicsConfig.manaPerGem
                        mana = min(mana + totalMana, BattleMechanicsConfig.maxMana)
                    }
                    
                case .poison:
                    if BattleMechanicsConfig.gemClearApplyPoison {
                        // Future poison implementation
                    }
                }
                
                // ═══════════════════════════════════════════════════════════════
                // ✨ GEM CLEAR MESSAGE (shows what happened)
                // ═══════════════════════════════════════════════════════════════
                
                var effectMessage = ""
                
                if totalDamage > 0 {
                    effectMessage = " → \(totalDamage) damage!"
                } else if totalShield > 0 {
                    effectMessage = " → +\(totalShield) shield!"
                } else if totalHealing > 0 {
                    effectMessage = " → +\(totalHealing) HP!"
                } else if totalMana > 0 {
                    effectMessage = " → +\(totalMana) mana!"
                }
                
                // ✅ UPDATED: Use gem clear message from config
                let baseMessage = BattleMechanicsConfig.gemClearMessage
                    .replacingOccurrences(of: "{gemType}", with: gemType.battleAction.uppercased())
                let fullMessage = baseMessage + effectMessage
                
                addEvent(BattleEvent(text: fullMessage, type: .special))
            }
            
        case .divineShield:
            let shieldAmount = BattleMechanicsConfig.shieldAbilityAmount
            
            // 🎨 SET PLAYER TO SPELL STATE
            player.currentState = .spell
            
            player.addShield(shieldAmount)
            
            // ✅ UPDATED: Use divine shield message from config
            let message = BattleMechanicsConfig.divineShieldMessage
                .replacingOccurrences(of: "{amount}", with: "\(shieldAmount)")
            addEvent(BattleEvent(text: message, type: .special))
            
        case .greaterHeal:
            let healAmount = BattleMechanicsConfig.healAbilityAmount
            
            // 🎨 SET PLAYER TO SPELL STATE
            player.currentState = .spell
            
            player.heal(healAmount)
            
            // ✅ UPDATED: Use greater heal message from config
            let message = BattleMechanicsConfig.greaterHealMessage
                .replacingOccurrences(of: "{amount}", with: "\(healAmount)")
            addEvent(BattleEvent(text: message, type: .special))
        }
        
        checkGameOver()
    }
    
    // MARK: - Battle Narrative
    
    private func addEvent(_ event: BattleEvent) {
        recentEvents.insert(event, at: 0)
        if recentEvents.count > 5 {  // Changed from 3 to 5 to show 3 messages
            recentEvents.removeLast()
        }
    }
    
    private func barbarianAttackMessage(damage: Int, isCombo: Bool) -> BattleEvent {
        // Pick random message from config
        let template = BattleMechanicsConfig.barbarianAttackMessages.randomElement()!
        let message = template.replacingOccurrences(of: "{damage}", with: "\(damage)")
        let text = isCombo ? "⚡ COMBO! " + message : message
        return BattleEvent(text: text, type: .playerAttack)
    }
    
    private func magicAttackMessage(damage: Int, isCombo: Bool) -> BattleEvent {
        // Pick random message from config
        let template = BattleMechanicsConfig.magicAttackMessages.randomElement()!
        let message = template.replacingOccurrences(of: "{damage}", with: "\(damage)")
        let text = isCombo ? "🔥 COMBO! " + message : message
        return BattleEvent(text: text, type: .playerMagic)
    }
    
    private func shieldMessage(amount: Int, isCombo: Bool) -> BattleEvent {
        // Pick random message from config
        let template = BattleMechanicsConfig.shieldMessages.randomElement()!
        let message = template.replacingOccurrences(of: "{amount}", with: "\(amount)")
        return BattleEvent(text: message, type: .playerDefend)
    }
    
    private func healMessage(amount: Int, isCombo: Bool) -> BattleEvent {
        // Pick random message from config
        let template = BattleMechanicsConfig.healMessages.randomElement()!
        let message = template.replacingOccurrences(of: "{amount}", with: "\(amount)")
        return BattleEvent(text: message, type: .playerHeal)
    }
    
    private func manaMessage(amount: Int) -> BattleEvent {
        // Use mana message from config
        let message = BattleMechanicsConfig.manaMessage.replacingOccurrences(of: "{amount}", with: "\(amount)")
        return BattleEvent(text: message, type: .playerCharge)
    }
    
    private func enemyAttackMessage(damage: Int) -> BattleEvent {
        // Pick random message from config
        let template = BattleMechanicsConfig.enemyAttackMessages.randomElement()!
        let message = template.replacingOccurrences(of: "{damage}", with: "\(damage)")
        return BattleEvent(text: message, type: .enemyAttack)
    }
    
    // ✨ NEW: Call this after ALL animations complete to show game over screen
    func finalizeGameOver() {
        if let pending = pendingGameOver {
            gameState = pending
            pendingGameOver = nil
        }
    }
}
