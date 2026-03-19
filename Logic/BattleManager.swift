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
            maxHealth: GameConfig.barbarianStartHealth,
            currentHealth: GameConfig.barbarianStartHealth
        )
        
        self.enemy = Character(
            name: "Toad King",
            imageName: GameAssets.toadImage,
            maxHealth: GameConfig.toadStartHealth,
            currentHealth: GameConfig.toadStartHealth
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
            let multiplier = isCombo ? GameConfig.comboMultiplier : 1.0
            
            switch match.type {
            case .sword:
                let damage = Int(Double(GameConfig.baseDamage * matchCount) * multiplier)
                totalDamage += damage
                
                // ═══════════════════════════════════════════════════════════════
                // 🎨 SET PLAYER TO ATTACK STATE
                // ═══════════════════════════════════════════════════════════════
                player.currentState = .attack
                // ═══════════════════════════════════════════════════════════════
                
                addEvent(barbarianAttackMessage(damage: damage, isCombo: isCombo))
                
            case .fire:
                let damage = Int(Double(GameConfig.magicDamage * matchCount) * multiplier)
                totalDamage += damage
                
                // ═══════════════════════════════════════════════════════════════
                // 🎨 SET PLAYER TO ATTACK STATE
                // ═══════════════════════════════════════════════════════════════
                player.currentState = .attack
                // ═══════════════════════════════════════════════════════════════
                
                addEvent(magicAttackMessage(damage: damage, isCombo: isCombo))
                
            case .shield:
                let shield = GameConfig.shieldAmount * matchCount
                totalShield += shield
                
                // ═══════════════════════════════════════════════════════════════
                // 🎨 SET PLAYER TO DEFEND STATE
                // ═══════════════════════════════════════════════════════════════
                player.currentState = .defend
                // ═══════════════════════════════════════════════════════════════
                
                addEvent(shieldMessage(amount: shield, isCombo: isCombo))
                
            case .heart:
                let healing = GameConfig.healAmount * matchCount
                totalHealing += healing
                
                // ═══════════════════════════════════════════════════════════════
                // 🎨 SET PLAYER TO DEFEND STATE (healing = defensive action)
                // ═══════════════════════════════════════════════════════════════
                player.currentState = .defend
                // ═══════════════════════════════════════════════════════════════
                
                addEvent(healMessage(amount: healing, isCombo: isCombo))
                
            case .mana:
                let manaGain = GameConfig.manaPerGem * matchCount
                totalMana += manaGain
                addEvent(manaMessage(amount: manaGain))
                
            case .poison:
                // Future: implement poison status effect
                addEvent(BattleEvent(text: "Toxic miasma swirls...", type: .special))
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
            mana = min(GameConfig.maxMana, mana + totalMana)
            hapticManager?.manaGained()  // ✨ Mana gain haptic
        }
        
        // ═══════════════════════════════════════════════════════════════
        // 🔥 SESSION 2 ADDITION: POWER SURGE DETECTION (START)
        // ═══════════════════════════════════════════════════════════════
        // POWER SURGE: 4+ matches in any single match group
        let totalMatches = matches.reduce(0) { $0 + $1.count }
        if totalMatches >= GameConfig.powerSurgeChainThreshold {
            triggeredPowerSurge = true
            let bonusMana = GameConfig.powerSurgeManaBonus
            mana = min(GameConfig.maxMana, mana + bonusMana)
            addEvent(BattleEvent(text: "⚡ POWER SURGE! \(totalMatches) MATCHES! +\(bonusMana) bonus mana!", type: .special))
        }
        // ═══════════════════════════════════════════════════════════════
        // 🔥 SESSION 2 ADDITION: POWER SURGE DETECTION (END)
        // ═══════════════════════════════════════════════════════════════
        
        // ═══════════════════════════════════════════════════════════════
        // 🎨 RETURN PLAYER TO IDLE STATE AFTER DELAY
        // ═══════════════════════════════════════════════════════════════
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            player.currentState = .idle
        }
        // ═══════════════════════════════════════════════════════════════
        
        checkGameOver()
    }
    
    func enemyTurn() {
        guard gameState == .playing else { return }
        
        let damage = Int.random(in: GameConfig.enemyMinDamage...GameConfig.enemyMaxDamage)
        
        // ═══════════════════════════════════════════════════════════════
        // 🎨 SET PLAYER TO HURT STATE WHEN TAKING DAMAGE
        // ═══════════════════════════════════════════════════════════════
        player.currentState = .hurt
        // ═══════════════════════════════════════════════════════════════
        
        player.takeDamage(damage)
        hapticManager?.playerDamaged(damage: damage)  // ✨ Player damage haptic
        addEvent(enemyAttackMessage(damage: damage))
        
        // ═══════════════════════════════════════════════════════════════
        // 🎨 RETURN TO IDLE AFTER DELAY
        // ═══════════════════════════════════════════════════════════════
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            player.currentState = .idle
        }
        // ═══════════════════════════════════════════════════════════════
        
        turnCount += 1
        checkGameOver()
    }
    
    private func checkGameOver() {
        if !enemy.isAlive {
            gameState = .victory
            
            // ═══════════════════════════════════════════════════════════════
            // 🎨 SET PLAYER TO VICTORY STATE
            // ═══════════════════════════════════════════════════════════════
            player.currentState = .victory
            // ═══════════════════════════════════════════════════════════════
            
            hapticManager?.victory()  // ✨ Victory haptic celebration!
            addEvent(BattleEvent(text: "Victory! The Toad King croaks his last!", type: .special))
        } else if !player.isAlive {
            gameState = .defeat
            
            // ═══════════════════════════════════════════════════════════════
            // 🎨 SET PLAYER TO DEFEAT STATE
            // ═══════════════════════════════════════════════════════════════
            player.currentState = .defeat
            // ═══════════════════════════════════════════════════════════════
            
            hapticManager?.defeat()  // ✨ Defeat haptic
            addEvent(BattleEvent(text: "Defeated! The swamp claims another hero...", type: .special))
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
        player.currentState = .idle
        enemy.currentState = .idle
        gameState = .playing
    }
    
    // MARK: - Ability System
    
    func canUseAbility(_ ability: Ability) -> Bool {
        return gameState == .playing && mana >= ability.manaCost
    }
    
    func useAbility(_ ability: Ability, gemType: TileType? = nil) {
        guard canUseAbility(ability) else { return }
        
        // Spend mana
        mana -= ability.manaCost
        
        // Apply ability effects
        switch ability {
        case .heroicStrike:
            // This now means "Clear Board" - requires gem type selection
            if let gemType = gemType {
                // ═══════════════════════════════════════════════════════════════
                // 🎨 SET PLAYER TO SPELL STATE
                // ═══════════════════════════════════════════════════════════════
                player.currentState = .spell
                
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(600))
                    player.currentState = .idle
                }
                // ═══════════════════════════════════════════════════════════════
                
                addEvent(BattleEvent(text: "💥 CLEARED ALL \(gemType.battleAction.uppercased()) GEMS!", type: .special))
            }
            
        case .divineShield:
            let shieldAmount = GameConfig.divineShieldAmount
            
            // ═══════════════════════════════════════════════════════════════
            // 🎨 SET PLAYER TO SPELL STATE
            // ═══════════════════════════════════════════════════════════════
            player.currentState = .spell
            
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(600))
                player.currentState = .idle
            }
            // ═══════════════════════════════════════════════════════════════
            
            player.addShield(shieldAmount)
            addEvent(BattleEvent(text: "🛡️ DIVINE SHIELD! +\(shieldAmount) protection!", type: .special))
            
        case .greaterHeal:
            let healAmount = GameConfig.greaterHealAmount
            
            // ═══════════════════════════════════════════════════════════════
            // 🎨 SET PLAYER TO SPELL STATE
            // ═══════════════════════════════════════════════════════════════
            player.currentState = .spell
            
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(600))
                player.currentState = .idle
            }
            // ═══════════════════════════════════════════════════════════════
            
            player.heal(healAmount)
            addEvent(BattleEvent(text: "💚 GREATER HEAL! +\(healAmount) HP!", type: .special))
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
        let messages = [
            "Ramp swings for \(damage)!",
            "Critical bonk! \(damage) damage!",
            "Barbarian fury! \(damage)!",
            "Mighty strike lands for \(damage)!"
        ]
        let text = isCombo ? "⚡ COMBO! " + messages.randomElement()! : messages.randomElement()!
        return BattleEvent(text: text, type: .playerAttack)
    }
    
    private func magicAttackMessage(damage: Int, isCombo: Bool) -> BattleEvent {
        let messages = [
            "Flames erupt for \(damage)!",
            "Magic missiles strike! \(damage)!",
            "Arcane blast! \(damage) damage!",
            "Fireball scorches for \(damage)!"
        ]
        let text = isCombo ? "🔥 COMBO! " + messages.randomElement()! : messages.randomElement()!
        return BattleEvent(text: text, type: .playerMagic)
    }
    
    private func shieldMessage(amount: Int, isCombo: Bool) -> BattleEvent {
        let messages = [
            "Shield wall! +\(amount) defense!",
            "Defenses strengthened!",
            "Barrier holds strong!",
            "Protected! +\(amount)!"
        ]
        return BattleEvent(text: messages.randomElement()!, type: .playerDefend)
    }
    
    private func healMessage(amount: Int, isCombo: Bool) -> BattleEvent {
        let messages = [
            "Healing light! +\(amount) HP!",
            "Vitality restored! +\(amount)!",
            "Life force surges! +\(amount)!",
            "Renewed vigor! +\(amount)!"
        ]
        return BattleEvent(text: messages.randomElement()!, type: .playerHeal)
    }
    
    private func manaMessage(amount: Int) -> BattleEvent {
        BattleEvent(text: "Power surges! +\(amount) mana!", type: .playerCharge)
    }
    
    private func enemyAttackMessage(damage: Int) -> BattleEvent {
        let messages = [
            "EDNAR strikes for \(damage)!",
            "ZAPPY ZAP! \(damage) damage!",
            "Ednar curses! \(damage)!",
            "Ednar throws a book \(damage)!",
            "Wizardly whizzer! \(damage)!"
        ]
        return BattleEvent(text: messages.randomElement()!, type: .enemyAttack)
    }
}
