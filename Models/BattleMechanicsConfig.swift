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
}
