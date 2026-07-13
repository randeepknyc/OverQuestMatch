//
//  BattleManager.swift
//  OverQuestMatch3
//
//  🆕 MULTI-ENEMY UPDATE: the enemy is now built from EnemyRoster.current
//  (set by the selection screen). The old fire gem is now the enemy's
//  SIGNATURE GEM — its damage and messages come from the enemy profile.
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

    // 🆕 The full profile of who we're fighting (health, attacks, signature gem)
    var enemyProfile: EnemyProfile

    var gameState: GameState = .playing
    var pendingGameOver: GameState? = nil  // ✨ NEW: Holds victory/defeat until animations finish
    
    // 🧪 POISON PILL SYSTEM
    var poisonPillManager: PoisonPillManager = PoisonPillManager()
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
    
    // 🎬 ANIMATION COORDINATORS — the only things allowed to change portrait states
    let playerAnimator: AnimationCoordinator
    let enemyAnimator: AnimationCoordinator

    init() {
        let playerCharacter = Character(
            name: "Ramp",
            imageName: GameAssets.barbarianImage,
            maxHealth: BattleMechanicsConfig.playerStartingHealth,
            currentHealth: BattleMechanicsConfig.playerStartingHealth
        )

        // 🆕 Build the enemy from whoever the selection screen chose.
        // (If the game is opened directly, this defaults to Ednar.)
        let profile = EnemyRoster.current
        let enemyCharacter = Character(
            name: profile.name,
            imageName: profile.portraitAsset,
            maxHealth: profile.maxHealth,
            currentHealth: profile.maxHealth
        )

        self.enemyProfile = profile
        self.player = playerCharacter
        self.enemy = enemyCharacter
        self.playerAnimator = AnimationCoordinator(character: playerCharacter)
        self.enemyAnimator = AnimationCoordinator(character: enemyCharacter)

        // 🎬 Battle messages appear when their animation actually STARTS
        // (keeps narrative text in sync with queued/delayed animations)
        playerAnimator.onEmitEvent = { [weak self] event in self?.addEvent(event) }
        enemyAnimator.onEmitEvent = { [weak self] event in self?.addEvent(event) }
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
                
                // 🎬 Animation + message travel together through the coordinator
                playerAnimator.play(.attack, message: barbarianAttackMessage(damage: damage, isCombo: isCombo))
                
            case .fire:
                // 🆕 SIGNATURE GEM! Damage comes from the enemy's profile —
                // this is the MAIN damage source (sword is the small backup)
                let perGem = enemyProfile.signature.damagePerGem
                let damage = Int(Double(perGem * matchCount) * multiplier)
                totalDamage += damage
                
                playerAnimator.play(.attack, message: signatureAttackMessage(damage: damage, isCombo: isCombo))
                
            case .shield:
                let shield = BattleMechanicsConfig.shieldPerGem * matchCount
                totalShield += shield
                
                playerAnimator.play(.defend, message: shieldMessage(amount: shield, isCombo: isCombo))
                
            case .heart:
                let healing = BattleMechanicsConfig.healingPerGem * matchCount
                totalHealing += healing
                
                playerAnimator.play(.defend, message: healMessage(amount: healing, isCombo: isCombo))
                
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
            
            // 🎬 ENEMY HURT REACTION (Session 25.1)
            // Plays a beat after Ramp's attack starts so the hit "lands"
            enemyAnimator.play(.hurt)
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
        
        // 🎬 Idle reset REMOVED — AnimationCoordinator returns the character
        // to idle automatically when its queue empties (and never at the
        // wrong moment, unlike the old fixed 350ms timer).
        
        checkGameOver()
    }
    
    @MainActor
    func enemyTurn() {
        guard gameState == .playing else { return }
        
        // 🆕 Attack strength comes from the enemy's profile
        let damage = Int.random(in: enemyProfile.attackMin...enemyProfile.attackMax)
        
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
    
    // 🧪 NEW: Start-of-turn poison damage
    @MainActor
    func applyPoisonDamage() {
        let poisonDamage = poisonPillManager.getPoisonDamageForTurn()
        
        if poisonDamage > 0 {
            player.takeDamage(poisonDamage)
            hapticManager?.playerDamaged(damage: poisonDamage)
            
            // Show poison damage message
            let turnNum = poisonPillManager.poisonTurnCounter
            addEvent(BattleEvent(
                text: "Poisoned for 3 turns! \(poisonDamage) damage (Turn \(turnNum)/3)",
                type: .enemyAttack
            ))
            
            // Advance to next poison turn
            poisonPillManager.advancePoisonTurn()
            
            checkGameOver()
        }
    }
    
    // 🎬 No longer private — GameViewModel calls this after poison-pill and
    // invalid-swap penalty damage (bug fix: that damage could kill you
    // without ever ending the game)
    func checkGameOver() {
        // Already pending or already over? Don't trigger twice
        guard pendingGameOver == nil, gameState == .playing else { return }

        if !enemy.isAlive {
            pendingGameOver = .victory
            hapticManager?.victory()  // ✨ Victory haptic celebration!

            // 🎬 ENEMY SLUMPS while Ramp celebrates (Session 25.1)
            enemyAnimator.play(.defeat)

            // 🎬 Victory boil plays for 2s (duration in AnimationCoordinator
            // config), THEN the game-over screen appears via the completion.
            playerAnimator.play(
                .victory,
                message: BattleEvent(text: BattleMechanicsConfig.victoryMessage, type: .special),
                completion: { [weak self] in self?.finalizeGameOver() }
            )
        } else if !player.isAlive {
            pendingGameOver = .defeat
            hapticManager?.defeat()  // ✨ Defeat haptic

            // 🎬 ENEMY CELEBRATES while Ramp slumps (Session 25.1)
            enemyAnimator.play(.victory)

            // 🎬 Ramp slumps for 2s, then the screen appears
            playerAnimator.play(
                .defeat,
                message: BattleEvent(text: BattleMechanicsConfig.defeatMessage, type: .special),
                completion: { [weak self] in self?.finalizeGameOver() }
            )
        }
    }
    
    func reset() {
        player.currentHealth = player.maxHealth
        player.shield = 0

        // 🆕 Re-sync with the roster in case a different enemy was chosen
        enemyProfile = EnemyRoster.current
        enemy.name = enemyProfile.name
        enemy.imageName = enemyProfile.portraitAsset
        enemy.maxHealth = enemyProfile.maxHealth
        enemy.currentHealth = enemyProfile.maxHealth
        enemy.shield = 0

        mana = 0
        recentEvents.removeAll()
        comboCount = 0
        turnCount = 0
        
        // 🎬 Reset animation coordinators (clears queues, unlocks, returns to idle)
        playerAnimator.reset()
        enemyAnimator.reset()
        
        gameState = .playing
        pendingGameOver = nil  // ✅ FIX: Clear pending game over state
        
        // 🧪 Reset poison pill system
        poisonPillManager.reset()
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
                // 🎬 Spell animation (auto-returns to idle — old version never reset!)
                playerAnimator.play(.spell)
                
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
                    // 🆕 Signature gem clear uses the enemy's own damage number
                    if BattleMechanicsConfig.gemClearApplyFireDamage {
                        totalDamage = gemCount * enemyProfile.signature.damagePerGem
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
                
                // 🎬 ENEMY HURT REACTION for Gem Clear damage (Session 25.1)
                if totalDamage > 0 {
                    enemyAnimator.play(.hurt)
                }
                
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
            
            // 🎬 Spell animation (auto-returns to idle — old version never reset!)
            playerAnimator.play(.spell)
            
            player.addShield(shieldAmount)
            
            // ✅ UPDATED: Use divine shield message from config
            let message = BattleMechanicsConfig.divineShieldMessage
                .replacingOccurrences(of: "{amount}", with: "\(shieldAmount)")
            addEvent(BattleEvent(text: message, type: .special))
            
        case .greaterHeal:
            let healAmount = BattleMechanicsConfig.healAbilityAmount
            
            // 🎬 Spell animation (auto-returns to idle — old version never reset!)
            playerAnimator.play(.spell)
            
            player.heal(healAmount)
            
            // ✅ UPDATED: Use greater heal message from config
            let message = BattleMechanicsConfig.greaterHealMessage
                .replacingOccurrences(of: "{amount}", with: "\(healAmount)")
            addEvent(BattleEvent(text: message, type: .special))
        }
        
        checkGameOver()
    }
    
    // MARK: - Battle Narrative
    
    func addEvent(_ event: BattleEvent) {
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
    
    // 🆕 Signature gem attack message — comes from the enemy's profile
    private func signatureAttackMessage(damage: Int, isCombo: Bool) -> BattleEvent {
        let message = EnemyRoster.signatureMessage(damage: damage)
        let emoji = enemyProfile.signature.emoji
        let text = isCombo ? "\(emoji) COMBO! " + message : message
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
    
    // 🆕 Enemy attack message — comes from the enemy's profile
    private func enemyAttackMessage(damage: Int) -> BattleEvent {
        let message = EnemyRoster.enemyAttackMessage(damage: damage)
        return BattleEvent(text: message, type: .enemyAttack)
    }
    
    // ✨ NEW: Call this after ALL animations complete to show game over screen
    func finalizeGameOver() {
        if let pending = pendingGameOver {
            gameState = pending
            pendingGameOver = nil
            Match3Save.deleteSave()
        }
    }
}
