//
//  EnemyRoster.swift
//  OverQuestMatch3
//
//  🏆 THE ENEMY ROSTER — every opponent in one place!
//
//  Each enemy has:
//    • A name, portrait image, and health
//    • Their own attack strength (min–max damage per turn)
//    • A SIGNATURE GEM — the element that hurts THEM the most.
//      On the board, the old fire tile transforms into this gem:
//      new image, new color, new damage, new battle messages.
//    • unlocked: true = appears on the selection screen,
//      false = shows as a locked silhouette
//
//  ✏️ TO EDIT AN ENEMY: just change the numbers/words below.
//  ✏️ TO UNLOCK AN ENEMY: change unlocked: false → unlocked: true
//  ✏️ TO ADD TILE ART: drop a PNG named e.g. "ice_tile" into
//     Assets.xcassets. Until then, that enemy's signature gem
//     automatically shows the fire tile art so nothing breaks.
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════
// 🔮 SIGNATURE ELEMENT — what the fire-tile slot becomes
// ═══════════════════════════════════════════════════════════════
struct SignatureElement {
    let elementName: String     // Shown on cards, e.g. "ICE"
    let emoji: String           // Shown on cards + combo messages
    let tileImageName: String   // PNG in Assets (falls back to fire_tile)
    let damagePerGem: Int       // Main damage source! (sword stays at 2)

    // Glow/effect color for this gem (values 0.0–1.0)
    let red: Double
    let green: Double
    let blue: Double

    // Battle messages when Ramp matches this gem. {damage} is replaced
    // with the real number. Leave empty [] for automatic generic messages.
    let attackMessages: [String]

    /// SwiftUI color built from the RGB values above
    var color: Color { Color(red: red, green: green, blue: blue) }

    /// Uses your custom tile art if it exists, otherwise the fire tile
    var resolvedTileImage: String {
        UIImage(named: tileImageName) != nil ? tileImageName : "fire_tile"
    }
}

// ═══════════════════════════════════════════════════════════════
// 👹 ENEMY PROFILE — one full opponent
// ═══════════════════════════════════════════════════════════════
struct EnemyProfile: Identifiable {
    let id: String              // Save-file identifier — never change after release!
    let name: String
    let portraitAsset: String   // Image name in Assets (e.g. "gmarker_oldlady")
    let maxHealth: Int
    let attackMin: Int          // Their weakest hit per turn
    let attackMax: Int          // Their strongest hit per turn
    let unlocked: Bool
    let signature: SignatureElement

    // Messages when THIS enemy attacks Ramp. {damage} is replaced.
    // Leave empty [] for automatic "Name strikes for X!" messages.
    let enemyAttackMessages: [String]
}

// ═══════════════════════════════════════════════════════════════
// 📋 THE ROSTER ITSELF
// ═══════════════════════════════════════════════════════════════
struct EnemyRoster {

    /// The enemy the player is currently fighting.
    /// The selection screen sets this; the battle reads it.
    static var current: EnemyProfile = allEnemies[0]

    /// Look up an enemy by its save-file id
    static func enemy(withID id: String) -> EnemyProfile? {
        allEnemies.first { $0.id == id }
    }

    static let allEnemies: [EnemyProfile] = [

        // ─────────────────────────────────────────────────────────
        // 1. EDNAR — the original! Works exactly like today.
        // ─────────────────────────────────────────────────────────
        EnemyProfile(
            id: "ednar",
            name: "Ednar",
            portraitAsset: "ednar",         // your existing art
            maxHealth: 200,
            attackMin: 4, attackMax: 8,
            unlocked: true,
            signature: SignatureElement(
                elementName: "FIRE", emoji: "🔥",
                tileImageName: "fire_tile",  // existing art
                damagePerGem: 3,
                red: 0.98, green: 0.6, blue: 0.2,
                attackMessages: [
                    "You're fired {damage}!",
                    "BUURRRN {damage}!",
                    "Firey Fury! {damage} damage!",
                    "Toasty! {damage}!"
                ]
            ),
            enemyAttackMessages: [
                "EDNAR strikes for {damage}!",
                "ZAPPY ZAP! {damage} damage!",
                "Ednar curses! {damage}!",
                "Ednar throws a book {damage}!",
                "Ednar throws a plant! {damage}!"
            ]
        ),

        // ─────────────────────────────────────────────────────────
        // 2. MILDRED — sweet-looking granny, easiest fight
        // ─────────────────────────────────────────────────────────
        EnemyProfile(
            id: "mildred",
            name: "Mildred",
            portraitAsset: "gmarker_oldlady",
            maxHealth: 150,
            attackMin: 3, attackMax: 6,
            unlocked: true,
            signature: SignatureElement(
                elementName: "NATURE", emoji: "🌿",
                tileImageName: "nature_tile",
                damagePerGem: 3,
                red: 0.4, green: 0.8, blue: 0.35,
                attackMessages: [
                    "Thorny whack! {damage}!",
                    "Nature's fury! {damage} damage!",
                    "Pruned! {damage}!"
                ]
            ),
            enemyAttackMessages: [
                "Mildred swats you! {damage}!",
                "Handbag to the face! {damage}!",
                "Umbrella hook! {damage} damage!",
                "Mildred tuts disapprovingly... and hits for {damage}!"
            ]
        ),

        // ─────────────────────────────────────────────────────────
        // 3. TOMIK — smug fox in a fancy coat
        // ─────────────────────────────────────────────────────────
        EnemyProfile(
            id: "tomik",
            name: "Tomik",
            portraitAsset: "gmarker_fox",
            maxHealth: 170,
            attackMin: 4, attackMax: 7,
            unlocked: true,
            signature: SignatureElement(
                elementName: "WIND", emoji: "🌪️",
                tileImageName: "wind_tile",
                damagePerGem: 3,
                red: 0.6, green: 0.85, blue: 0.95,
                attackMessages: [
                    "Gust buster! {damage}!",
                    "Blown away! {damage} damage!",
                    "Whoosh! {damage}!"
                ]
            ),
            enemyAttackMessages: [
                "Tomik pounces! {damage}!",
                "Sneaky swipe! {damage} damage!",
                "Tomik outfoxes you! {damage}!"
            ]
        ),

        // ─────────────────────────────────────────────────────────
        // 4. GRIMDREK — sad skeleton knight
        // ─────────────────────────────────────────────────────────
        EnemyProfile(
            id: "grimdrek",
            name: "Grimdrek",
            portraitAsset: "gmarker_skull",
            maxHealth: 180,
            attackMin: 4, attackMax: 8,
            unlocked: true,
            signature: SignatureElement(
                elementName: "LIGHTNING", emoji: "⚡",
                tileImageName: "lightning_tile",
                damagePerGem: 4,
                red: 0.95, green: 0.9, blue: 0.3,
                attackMessages: [
                    "ZAP! {damage} damage!",
                    "Shockingly good! {damage}!",
                    "Thunderstruck! {damage}!"
                ]
            ),
            enemyAttackMessages: [
                "Grimdrek rattles you! {damage}!",
                "Bone-crunching blow! {damage}!",
                "Grimdrek sighs... then smashes for {damage}!"
            ]
        ),

        // ─────────────────────────────────────────────────────────
        // 5. HEXA MOTT — grumpy little swamp witch
        // ─────────────────────────────────────────────────────────
        EnemyProfile(
            id: "hexamott",
            name: "Hexa Mott",
            portraitAsset: "gmarker_fishguy",
            maxHealth: 160,
            attackMin: 5, attackMax: 9,
            unlocked: true,
            signature: SignatureElement(
                elementName: "HEX", emoji: "🔮",
                tileImageName: "hex_tile",
                damagePerGem: 4,
                red: 0.75, green: 0.45, blue: 0.95,
                attackMessages: [
                    "Hexed! {damage} damage!",
                    "Curse reversed! {damage}!",
                    "Jinx bounce! {damage}!"
                ]
            ),
            enemyAttackMessages: [
                "Hexa Mott jinxes you! {damage}!",
                "A nasty curse! {damage} damage!",
                "Hexa Mott grumbles a spell... {damage}!"
            ]
        ),

        // ─────────────────────────────────────────────────────────
        // 6. IRONHILDE — the big bull baker. THE TANK.
        // ─────────────────────────────────────────────────────────
        EnemyProfile(
            id: "ironhilde",
            name: "Ironhilde",
            portraitAsset: "gmarker_bull",
            maxHealth: 240,
            attackMin: 3, attackMax: 7,
            unlocked: true,
            signature: SignatureElement(
                elementName: "ICE", emoji: "❄️",
                tileImageName: "ice_tile",
                damagePerGem: 5,      // big payoff — she has a LOT of health
                red: 0.55, green: 0.85, blue: 1.0,
                attackMessages: [
                    "Frostbite! {damage}!",
                    "Cold snap! {damage} damage!",
                    "Ice to meet you! {damage}!"
                ]
            ),
            enemyAttackMessages: [
                "Ironhilde charges! {damage}!",
                "Baker's paddle SMACK! {damage}!",
                "Fresh out of the oven! {damage} damage!"
            ]
        ),

        // ═════════════════════════════════════════════════════════
        // 🔒 LOCKED ENEMIES — flip unlocked to true when ready!
        //     (They already show as silhouettes on the screen.)
        //     Empty message lists [] = automatic generic messages.
        // ═════════════════════════════════════════════════════════

        EnemyProfile(
            id: "greta", name: "Greta",
            portraitAsset: "gmarker_girl",
            maxHealth: 150, attackMin: 3, attackMax: 6, unlocked: false,
            signature: SignatureElement(
                elementName: "LIGHT", emoji: "✨",
                tileImageName: "light_tile", damagePerGem: 3,
                red: 1.0, green: 0.95, blue: 0.6, attackMessages: []),
            enemyAttackMessages: []
        ),

        EnemyProfile(
            id: "sisterhalla", name: "Sister Halla",
            portraitAsset: "gmarker_octo",
            maxHealth: 190, attackMin: 4, attackMax: 8, unlocked: false,
            signature: SignatureElement(
                elementName: "TIDE", emoji: "🌊",
                tileImageName: "tide_tile", damagePerGem: 4,
                red: 0.3, green: 0.55, blue: 0.95, attackMessages: []),
            enemyAttackMessages: []
        ),

        EnemyProfile(
            id: "wendelina", name: "Wendelina",
            portraitAsset: "gmarker_slug",
            maxHealth: 160, attackMin: 3, attackMax: 7, unlocked: false,
            signature: SignatureElement(
                elementName: "SLIME", emoji: "🫧",
                tileImageName: "slime_tile", damagePerGem: 4,
                red: 0.95, green: 0.75, blue: 0.35, attackMessages: []),
            enemyAttackMessages: []
        ),

        EnemyProfile(
            id: "pemberton", name: "Pemberton",
            portraitAsset: "gmarker_traveler",
            maxHealth: 200, attackMin: 4, attackMax: 8, unlocked: false,
            signature: SignatureElement(
                elementName: "EARTH", emoji: "🪨",
                tileImageName: "earth_tile", damagePerGem: 4,
                red: 0.6, green: 0.5, blue: 0.4, attackMessages: []),
            enemyAttackMessages: []
        ),

        EnemyProfile(
            id: "ardo", name: "Ardo",
            portraitAsset: "gmarker_bird",
            maxHealth: 180, attackMin: 5, attackMax: 8, unlocked: false,
            signature: SignatureElement(
                elementName: "STORM", emoji: "⛈️",
                tileImageName: "storm_tile", damagePerGem: 4,
                red: 0.45, green: 0.55, blue: 0.8, attackMessages: []),
            enemyAttackMessages: []
        ),

        EnemyProfile(
            id: "bram", name: "Bram",
            portraitAsset: "gmarker_goatguy",
            maxHealth: 220, attackMin: 4, attackMax: 7, unlocked: false,
            signature: SignatureElement(
                elementName: "MOUNTAIN", emoji: "⛰️",
                tileImageName: "mountain_tile", damagePerGem: 5,
                red: 0.8, green: 0.65, blue: 0.35, attackMessages: []),
            enemyAttackMessages: []
        ),

        EnemyProfile(
            id: "crispin", name: "Crispin",
            portraitAsset: "gmarker_puck",
            maxHealth: 150, attackMin: 4, attackMax: 9, unlocked: false,
            signature: SignatureElement(
                elementName: "SHADOW", emoji: "🌑",
                tileImageName: "shadow_tile", damagePerGem: 4,
                red: 0.55, green: 0.35, blue: 0.7, attackMessages: []),
            enemyAttackMessages: []
        ),

        EnemyProfile(
            id: "gnash", name: "Gnash",
            portraitAsset: "gmarker_demon",
            maxHealth: 140, attackMin: 5, attackMax: 10, unlocked: false,
            signature: SignatureElement(
                elementName: "GLOOM", emoji: "😈",
                tileImageName: "gloom_tile", damagePerGem: 4,
                red: 0.5, green: 0.45, blue: 0.55, attackMessages: []),
            enemyAttackMessages: []
        ),

        EnemyProfile(
            id: "snapjaw", name: "Snapjaw",
            portraitAsset: "gmarker_dino",
            maxHealth: 210, attackMin: 5, attackMax: 9, unlocked: false,
            signature: SignatureElement(
                elementName: "PRIMAL", emoji: "🦖",
                tileImageName: "primal_tile", damagePerGem: 5,
                red: 0.35, green: 0.75, blue: 0.75, attackMessages: []),
            enemyAttackMessages: []
        ),

        // The frog gets to be the big final boss 👑
        EnemyProfile(
            id: "toadking", name: "Toad King",
            portraitAsset: "gmarker_frog",
            maxHealth: 250, attackMin: 5, attackMax: 10, unlocked: false,
            signature: SignatureElement(
                elementName: "BOG", emoji: "🐸",
                tileImageName: "bog_tile", damagePerGem: 5,
                red: 0.5, green: 0.75, blue: 0.3, attackMessages: []),
            enemyAttackMessages: []
        )
    ]

    // ─────────────────────────────────────────────────────────────
    // Automatic generic messages for enemies with empty lists
    // ─────────────────────────────────────────────────────────────

    /// A signature-gem attack message for the current enemy
    static func signatureMessage(damage: Int) -> String {
        let sig = current.signature
        let templates = sig.attackMessages.isEmpty
            ? ["\(sig.emoji) \(sig.elementName) blast! {damage}!",
               "\(sig.elementName) strike! {damage} damage!"]
            : sig.attackMessages
        return templates.randomElement()!
            .replacingOccurrences(of: "{damage}", with: "\(damage)")
    }

    /// An enemy-attack message for the current enemy
    static func enemyAttackMessage(damage: Int) -> String {
        let templates = current.enemyAttackMessages.isEmpty
            ? ["\(current.name) strikes for {damage}!",
               "\(current.name) attacks! {damage} damage!",
               "Ouch! \(current.name) hits for {damage}!"]
            : current.enemyAttackMessages
        return templates.randomElement()!
            .replacingOccurrences(of: "{damage}", with: "\(damage)")
    }
}
