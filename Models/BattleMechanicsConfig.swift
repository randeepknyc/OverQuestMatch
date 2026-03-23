//
//  BattleMechanicsConfig.swift
//  OverQuestMatch3
//
//  Complete battle mechanics configuration in one centralized file
//

import Foundation

/// All battle-related numbers and mechanics in one place
/// Change these values to adjust game difficulty and balance
struct BattleMechanicsConfig {
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Character Stats
    // ═══════════════════════════════════════════════════════════════
    
    /// Player (Ramp) starting health
    static let playerStartingHealth = 100
    
    /// Enemy (Ednar) starting health
    static let enemyStartingHealth = 200
    
    /// Maximum mana you can store
    static let maxMana = 10
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Gem Match Damage & Effects
    // ═══════════════════════════════════════════════════════════════
    
    /// Damage per SWORD gem matched (physical attack)
    static let swordDamagePerGem = 8
    
    /// Damage per FIRE gem matched (magic attack)
    static let fireDamagePerGem = 12
    
    /// Shield points per SHIELD gem matched
    static let shieldPerGem = 5
    
    /// HP healed per HEART gem matched
    static let healingPerGem = 10
    
    /// Mana gained per MANA gem matched
    static let manaPerGem = 1
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Combo System
    // ═══════════════════════════════════════════════════════════════
    
    /// Damage multiplier when you match multiple groups in one turn
    /// 1.5 = 50% bonus damage on combos
    static let comboMultiplier = 1.5
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Enemy AI & Attacks
    // ═══════════════════════════════════════════════════════════════
    
    /// Enemy's minimum attack damage
    static let enemyMinDamage = 8
    
    /// Enemy's maximum attack damage
    static let enemyMaxDamage = 15
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Special Abilities (Coffee Cup Button)
    // ═══════════════════════════════════════════════════════════════
    
    /// Mana cost for "Gem Clear" ability (clear all of one gem type)
    static let gemClearAbilityCost = 5
    
    /// Mana cost for "Divine Shield" ability
    static let shieldAbilityCost = 4
    
    /// Shield points granted by Divine Shield ability
    static let shieldAbilityAmount = 25
    
    /// Mana cost for "Greater Heal" ability
    static let healAbilityCost = 5
    
    /// HP restored by Greater Heal ability
    static let healAbilityAmount = 40
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Power Surge Effect (4+ Match Chain)
    // ═══════════════════════════════════════════════════════════════
    
    /// How many total gem matches trigger Power Surge
    /// Example: Match 4+ gems in one turn → Power Surge!
    static let powerSurgeThreshold = 4
    
    /// Bonus mana awarded when Power Surge triggers
    static let powerSurgeBonusMana = 2
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Battle Narrative Messages
    // ═══════════════════════════════════════════════════════════════
    // All the funny combat text that appears during battle
    // Easy to expand: Just add more strings to any array!
    
    /// Messages when Ramp attacks with SWORD gems
    /// {damage} will be replaced with actual damage number
    static let barbarianAttackMessages = [
        "Ramp swings for {damage}!",
        "Critical bonk! {damage} damage!",
        "Barbarian fury! {damage}!",
        "Mighty strike lands for {damage}!"
    ]
    
    /// Messages when Ramp attacks with FIRE gems (magic)
    /// {damage} will be replaced with actual damage number
    static let magicAttackMessages = [
        "Flames erupt for {damage}!",
        "Magic missiles strike! {damage}!",
        "Arcane blast! {damage} damage!",
        "Fireball scorches for {damage}!"
    ]
    
    /// Messages when Ramp gains SHIELD
    /// {amount} will be replaced with shield points gained
    static let shieldMessages = [
        "Shield wall! +{amount} defense!",
        "Defenses strengthened!",
        "Barrier holds strong!",
        "Protected! +{amount}!"
    ]
    
    /// Messages when Ramp heals with HEART gems
    /// {amount} will be replaced with HP healed
    static let healMessages = [
        "Healing light! +{amount} HP!",
        "Vitality restored! +{amount}!",
        "Life force surges! +{amount}!",
        "Renewed vigor! +{amount}!"
    ]
    
    /// Messages when enemy (Ednar) attacks
    /// {damage} will be replaced with actual damage number
    static let enemyAttackMessages = [
        "EDNAR strikes for {damage}!",
        "ZAPPY ZAP! {damage} damage!",
        "Ednar curses! {damage}!",
        "Ednar throws a book {damage}!",
        "Wizardly whizzer! {damage}!"
    ]
    
    /// Message when MANA gems are matched
    /// {amount} will be replaced with mana gained
    static let manaMessage = "Power surges! +{amount} mana!"
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Special Event Messages
    // ═══════════════════════════════════════════════════════════════
    
    /// Message when Power Surge triggers (4+ gem matches)
    /// {totalMatches} = total gems matched, {bonusMana} = bonus mana awarded
    static let powerSurgeMessage = "⚡ POWER SURGE! {totalMatches} MATCHES! +{bonusMana} bonus mana!"
    
    /// Message when player wins the battle
    static let victoryMessage = "Victory! The Toad King croaks his last!"
    
    /// Message when player loses the battle
    static let defeatMessage = "Defeated! The swamp claims another hero..."
    
    /// Message when POISON gems are matched (placeholder for future feature)
    static let poisonMessage = "Toxic miasma swirls..."
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Ability Use Messages
    // ═══════════════════════════════════════════════════════════════
    
    /// Message when Gem Clear ability is used
    /// {gemType} will be replaced with gem type name (e.g., "SWORD", "FIRE")
    static let gemClearMessage = "💥 CLEARED ALL {gemType} GEMS!"
    
    /// Message when Divine Shield ability is used
    /// {amount} will be replaced with shield points granted
    static let divineShieldMessage = "🛡️ DIVINE SHIELD! +{amount} protection!"
    
    /// Message when Greater Heal ability is used
    /// {amount} will be replaced with HP restored
    static let greaterHealMessage = "💚 GREATER HEAL! +{amount} HP!"
}
