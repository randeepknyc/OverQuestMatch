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
    static let swordDamagePerGem = 2
    
    /// Damage per FIRE gem matched (magic attack)
    static let fireDamagePerGem = 3
    
    /// Shield points per SHIELD gem matched
    static let shieldPerGem = 2
    
    /// HP healed per HEART gem matched
    static let healingPerGem = 3
    
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
    static let enemyMinDamage = 4
    
    /// Enemy's maximum attack damage
    static let enemyMaxDamage = 8
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Special Abilities (Coffee Cup Button)
    // ═══════════════════════════════════════════════════════════════
    // You can activate these powerful abilities during battle by pressing the coffee cup button
    // Each ability costs mana to use - gain mana by matching MANA gems (yellow)
    //
    // THREE ABILITIES AVAILABLE:
    //
    // 1. GEM CLEAR - Removes all gems of one type from the board
    //    • Triggers massive cascades as gems fall
    //    • Great for creating combo chains
    //    • Most expensive ability
    //
    // 2. DIVINE SHIELD - Grants temporary armor/protection
    //    • Shield absorbs enemy damage BEFORE your HP is affected
    //    • Example: You have 10 shield, enemy attacks for 8 → shield becomes 2, HP unchanged
    //    • Use BEFORE enemy attacks for best effect (proactive defense)
    //    • Shield does NOT heal HP, it's extra protection on top of your health
    //
    // 3. GREATER HEAL - Instantly restores HP (health points)
    //    • Heals you during battle
    //    • Use AFTER taking damage (reactive healing)
    //    • Cannot exceed your maximum HP (150)
    //
    // The coffee cup button automatically picks the best ability based on your situation:
    // - Low HP? → Uses Greater Heal
    // - Need defense and have high HP? → Uses Divine Shield  
    // - Have lots of mana and want big combos? → Uses Gem Clear
    
    /// Mana cost for "Gem Clear" ability (clear all of one gem type)
    /// Higher cost because it creates huge cascades and combo opportunities
    static let gemClearAbilityCost = 10
    
    // ─────────────────────────────────────────────────────────────
    // GEM CLEAR MULTIPLIER SETTINGS
    // ─────────────────────────────────────────────────────────────
    // When you use Gem Clear, cleared gems apply their effects
    // Formula: (Number of gems cleared) × (damage/effect per gem) = Total effect
    // Example: Clear 12 swords → 12 × 2 damage = 24 damage
    //
    // Set to TRUE to apply effects, FALSE to just clear without effects
    
    /// Should SWORD gems deal damage when cleared?
    /// If true: 10 swords cleared = 10 × 2 = 20 damage
    static let gemClearApplySwordDamage = true
    
    /// Should FIRE gems deal damage when cleared?
    /// If true: 8 fires cleared = 8 × 3 = 24 damage
    static let gemClearApplyFireDamage = true
    
    /// Should SHIELD gems grant shield when cleared?
    /// If true: 15 shields cleared = 15 × 2 = 30 shield points
    static let gemClearApplyShield = true
    
    /// Should HEART gems heal when cleared?
    /// If true: 10 hearts cleared = 10 × 3 = 30 HP healed
    static let gemClearApplyHealing = true
    
    /// Should MANA gems grant mana when cleared?
    /// If true: 12 manas cleared = 12 × 1 = 12 mana (probably don't want this!)
    static let gemClearApplyMana = true
    
    /// Should POISON gems apply poison when cleared? (future feature)
    static let gemClearApplyPoison = true
    
    /// Mana cost for "Divine Shield" ability
    /// Gives you temporary armor that absorbs damage before HP is affected
    static let shieldAbilityCost = 4
    
    /// Shield points granted by Divine Shield ability
    /// This is how much damage the shield can absorb before breaking
    /// Example: 10 shield absorbs up to 10 damage total
    static let shieldAbilityAmount = 10
    
    /// Mana cost for "Greater Heal" ability
    /// Instantly restores HP during battle
    static let healAbilityCost = 5
    
    /// HP restored by Greater Heal ability
    /// Cannot heal beyond maximum HP (playerStartingHealth = 150)
    static let healAbilityAmount = 20
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - Power Surge Effect (4+ Match Chain)
    // ═══════════════════════════════════════════════════════════════
    
    /// How many total gem matches trigger Power Surge
    /// Example: Match 4+ gems in one turn → Power Surge!
    static let powerSurgeThreshold = 5
    
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
        "Sword yells while hitting for {damage}!",
        "Critical slam! {damage} damage!",
        "Undercaffienated fury! {damage}!",
        "Sword's thwonk lands for {damage}!"
    ]
    
    /// Messages when Ramp attacks with FIRE gems (magic)
    /// {damage} will be replaced with actual damage number
    static let magicAttackMessages = [
        "You're fired {damage}!",
        "BUURRRN {damage}!",
        "Firey Fury! {damage} damage!",
        "Toasty! {damage}!"
    ]
    
    /// Messages when Ramp gains SHIELD
    /// {amount} will be replaced with shield points gained
    static let shieldMessages = [
        "Protected! +{amount} defense!",
        "Shields up",
        "Nice try",
        "Armor protects +{amount}!"
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
        "Ednar throws a plant! {damage}!"
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
    static let victoryMessage = "Victory! Bulk up, Ednar!"
    
    /// Message when player loses the battle
    static let defeatMessage = "Defeated! Ramp's busted!"
    
    /// Message when POISON gems are matched (placeholder for future feature)
    static let poisonMessage = "Ew, gross skulls"
    
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
