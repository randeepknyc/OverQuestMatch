//
//  PotionShopData.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Game Data
//  Place in: PotionShop/ folder
//
//  ═══════════════════════════════════════════════════════════════════════
//  THIS FILE IS WHERE ALL GAME CONTENT LIVES.
//  ═══════════════════════════════════════════════════════════════════════
//  - 8 trait definitions
//  - 14 customer definitions
//  - 1 day's worth of round structure (Day 1)
//
//  HOW TO ADD/EDIT CONTENT:
//  - To tweak an existing customer: scroll to PotionShopData.characters,
//    find the entry by id, edit the values.
//  - To add a NEW customer: copy the template at the bottom of the
//    `characters` dictionary, paste it, change the values. Make sure
//    the key (e.g. "jorek_smith") matches the `id` field. Then add
//    that id to a round below.
//  - To add a NEW trait: copy a trait entry, change the id, name,
//    description, and effects. Note: only the listed effect keys
//    actually fire — adding a new effect KEY (not just a new value)
//    requires a code change to the game state machine.
//  - To swap which customers appear in a round: edit the
//    `customerIds` array in the relevant round below.
//
//  TUNING RULES OF THUMB BY DIFFICULTY:
//    1 (Tutorial): HP 8-12  / patience 7-8 / activeAttack 1   / waitingAttack 1   / expire 3-4
//    2 (Easy):     HP 12-16 / patience 5-7 / activeAttack 1-2 / waitingAttack 1   / expire 5-6
//    3 (Medium):   HP 16-20 / patience 4-5 / activeAttack 2-3 / waitingAttack 1   / expire 6-7
//    4 (Hard):     HP 20-26 / patience 4-5 / activeAttack 3   / waitingAttack 1-2 / expire 7-9
//    5 (Boss):     HP 28-40 / patience 4-6 / activeAttack 4-5 / waitingAttack 2   / expire 12+
//

import Foundation

enum PotionShopData {

    // MARK: ─── TRAITS ─────────────────────────────────────────────────

    static let traits: [String: PotionShopTrait] = [

        "intimidating": PotionShopTrait(
            id: "intimidating",
            name: "Intimidating",
            description: "Brews targeting this customer need +2 damage to satisfy.",
            effects: PotionShopTraitEffects(brewTargetModifier: 2)
        ),

        "volatile": PotionShopTrait(
            id: "volatile",
            name: "Volatile",
            description: "Overbrewing this customer triggers death-throes — they retaliate BEFORE your shield/heal applies.",
            effects: PotionShopTraitEffects(overbrewTriggersPredefense: true)
        ),

        "pious": PotionShopTrait(
            id: "pious",
            name: "Pious",
            description: "They judge you silently. No mechanical effect.",
            effects: PotionShopTraitEffects()  // intentionally no effects — flavor only
        ),

        "skittish": PotionShopTrait(
            id: "skittish",
            name: "Skittish",
            description: "Their patience drains faster while they are at the front of the line.",
            effects: PotionShopTraitEffects(activePatienceDrainModifier: 1)
        ),

        // Loud is STUBBED for v1 — declared so Bram has a trait, but the
        // game state machine doesn't fire focusModifier yet. Left as a
        // TODO for the Phase 9 trait wiring or later.
        "loud": PotionShopTrait(
            id: "loud",
            name: "Loud",
            description: "Their racket reduces your focus by 1 while they wait.",
            effects: PotionShopTraitEffects(focusModifier: -1)
        ),

        // Hexer is STUBBED for v1 — declared so Hexa Mott and Carmilla
        // have a trait, but the dice-rerolling logic isn't wired yet.
        "hexer": PotionShopTrait(
            id: "hexer",
            name: "Hexer",
            description: "Each turn this customer waits, one random die in your hand rerolls to its lowest face.",
            effects: PotionShopTraitEffects(hexDiePerTurn: true)
        ),

        "draining": PotionShopTrait(
            id: "draining",
            name: "Draining",
            description: "You lose 1 composure per turn while this customer waits.",
            effects: PotionShopTraitEffects(composureDrainPerTurn: 1)
        ),

        "inspiring": PotionShopTrait(
            id: "inspiring",
            name: "Inspiring",
            description: "All your dice gain +1 to their rolled value while this customer is in queue.",
            effects: PotionShopTraitEffects(diceValueModifierGlobal: 1)
        ),
    ]

    // MARK: ─── CHARACTERS ─────────────────────────────────────────────

    static let characters: [String: PotionShopCharacter] = [

        // ─── DIFFICULTY 1 (Tutorial customers) ────────────────────────

        "mildred": PotionShopCharacter(
            id: "mildred",
            name: "Mildred Honeycomb",
            title: "Anxious Farmwife",
            portrait: "mildred",
            scenePortrait: "mildred_scene",  // DUAL PORTRAIT SYSTEM - Full body art
            iconFallback: "🧑‍🌾",
            difficulty: 1,
            timeOfDay: [.morning],
            orderName: "A Soothing Tonic",
            orderDialogue: "Oh dear, please be quick — my chickens have been at the cabbages again...",
            hp: 10,
            patience: 6,
            activeAttack: 1,
            waitingAttack: 1,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 4,
            tickDialogue: "She fidgets, glancing toward the door.",
            expireDialogue: "Oh, forget it! I'll be back tomorrow.",
            defeatDialogue: "Oh, bless you, brewer. Bless you!",
            trait: nil
        ),

        "tomik": PotionShopCharacter(
            id: "tomik",
            name: "Tomik Cooper",
            title: "Sleepy Apprentice",
            portrait: "tomik",
            scenePortrait: "tomik_scene",  // ✅ Now uses tomik_scene.png
            iconFallback: "😴",
            difficulty: 1,
            timeOfDay: [.morning],
            orderName: "A Pick-Me-Up",
            orderDialogue: "Uhhh... potion, please... master said...",
            hp: 8,
            patience: 7,
            activeAttack: 1,
            waitingAttack: 1,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 3,
            tickDialogue: "Tomik yawns and leans on the counter.",
            expireDialogue: "...mm. I'll come back later.",
            defeatDialogue: "Oh! Oh, that's lovely. Thank you, brewer.",
            trait: nil
        ),

        "greta": PotionShopCharacter(
            id: "greta",
            name: "Greta Marshlow",
            title: "Cheerful Villager",
            portrait: "greta",
            scenePortrait: "greta_scene",  // ✅ Updated for new full-body portrait
            iconFallback: "🌻",
            difficulty: 1,
            timeOfDay: [.morning, .afternoon],
            orderName: "Something Warm",
            orderDialogue: "Hi there, friend! Got time for one more today?",
            hp: 12,
            patience: 7,
            activeAttack: 1,
            waitingAttack: 1,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 3,
            tickDialogue: "Greta hums a cheerful tune.",
            expireDialogue: "No worries! Next time, eh?",
            defeatDialogue: "Wonderful! You're a treasure, brewer.",
            trait: "inspiring"
        ),

        // ─── DIFFICULTY 2 (Easy) ──────────────────────────────────────

        "pemberton": PotionShopCharacter(
            id: "pemberton",
            name: "Pemberton Quill",
            title: "Travelling Merchant",
            portrait: "pemberton",
            scenePortrait: "pemberton",  // Temporary - will become "pemberton_scene" later
            iconFallback: "🧔",
            difficulty: 2,
            timeOfDay: [.afternoon],
            orderName: "A Trader's Tincture",
            orderDialogue: "I haven't got all day, brewer. Wagon's leaving at noon.",
            hp: 14,
            patience: 5,
            activeAttack: 2,
            waitingAttack: 1,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 5,
            tickDialogue: "Pemberton taps his coin purse impatiently.",
            expireDialogue: "Bah! Time wasted! I'll buy in the next town.",
            defeatDialogue: "Adequate. Adequate. Here's your coin.",
            trait: nil
        ),

        "sister_halla": PotionShopCharacter(
            id: "sister_halla",
            name: "Sister Halla",
            title: "Wandering Sister",
            portrait: "sister_halla",
            scenePortrait: "sister_halla_scene",  // ✅ Updated for new full-body portrait
            iconFallback: "🧎",
            difficulty: 2,
            timeOfDay: [.morning, .afternoon],
            orderName: "A Blessed Draught",
            orderDialogue: "...take your time, brewer. The Light is patient.",
            hp: 14,
            patience: 8,
            activeAttack: 1,
            waitingAttack: 1,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 5,
            tickDialogue: "Sister Halla murmurs a quiet prayer.",
            expireDialogue: "...the Light forgives. I do not.",
            defeatDialogue: "May the Light bless your craft.",
            trait: "pious"
        ),

        "ardo": PotionShopCharacter(
            id: "ardo",
            name: "Ardo Quill",
            title: "Nervous Scholar",
            portrait: "ardo",
            scenePortrait: "ardo",  // Temporary - will become "ardo_scene" later
            iconFallback: "📚",
            difficulty: 2,
            timeOfDay: [.morning, .afternoon],
            orderName: "A Steadying Brew",
            orderDialogue: "Th-three pages overdue! Please, please be quick!",
            hp: 12,
            patience: 5,
            activeAttack: 1,
            waitingAttack: 1,
            activePatienceTick: 2,  // Skittish — drains 2/turn while active
            waitingPatienceTick: 1,
            expireDamage: 6,
            tickDialogue: "Ardo shuffles his papers nervously.",
            expireDialogue: "Oh no oh no oh — *runs out without paying*",
            defeatDialogue: "Oh! Oh thank goodness, thank you!",
            trait: "skittish"
        ),

        // ─── DIFFICULTY 3 (Medium) ────────────────────────────────────

        "wendelina": PotionShopCharacter(
            id: "wendelina",
            name: "Wendelina Rookpool",
            title: "Hedge Witch",
            portrait: "wendelina",
            scenePortrait: "wendelina_scene",  // ✅ Updated for new full-body portrait
            iconFallback: "🧙‍♀️",
            difficulty: 3,
            timeOfDay: [.afternoon, .evening],
            orderName: "A Bracing Eye-Clear",
            orderDialogue: "Brew well, brewer. I'll know if you don't.",
            hp: 18,
            patience: 5,
            activeAttack: 3,
            waitingAttack: 1,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 7,
            tickDialogue: "Wendelina watches with unblinking eyes.",
            expireDialogue: "Pathetic. Don't speak to me again.",
            defeatDialogue: "Mm. You'll do, this once.",
            trait: nil
        ),

        "bram": PotionShopCharacter(
            id: "bram",
            name: "Bram the Bard",
            title: "Travelling Lutist",
            portrait: "bram",
            scenePortrait: "bram",  // Temporary - will become "bram_scene" later
            iconFallback: "🎻",
            difficulty: 3,
            timeOfDay: [.afternoon, .evening],
            orderName: "A Tongue-Loosener",
            orderDialogue: "Brew me something with ZEST, master alchemist!",
            hp: 16,
            patience: 6,
            activeAttack: 2,
            waitingAttack: 1,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 6,
            tickDialogue: "Bram strums his lute LOUDLY.",
            expireDialogue: "*plays a sad chord and wanders off*",
            defeatDialogue: "Aha! Now THAT is a potion! *fanfare*",
            trait: "loud"  // STUBBED — effect not yet wired
        ),

        "crispin": PotionShopCharacter(
            id: "crispin",
            name: "Lord Crispin Vorne",
            title: "Petty Noble",
            portrait: "crispin",
            scenePortrait: "crispin",  // Temporary - will become "crispin_scene" later
            iconFallback: "🎩",
            difficulty: 3,
            timeOfDay: [.afternoon, .evening],
            orderName: "A Refined Cordial",
            orderDialogue: "I assume you can manage something... acceptable?",
            hp: 18,
            patience: 4,
            activeAttack: 3,
            waitingAttack: 1,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 7,
            tickDialogue: "Crispin sneers and inspects his cuff.",
            expireDialogue: "Disgraceful. I shall write the council.",
            defeatDialogue: "Hmph. Acceptable. Barely.",
            trait: "intimidating"
        ),

        // ─── DIFFICULTY 4 (Hard) ──────────────────────────────────────

        "hexa_mott": PotionShopCharacter(
            id: "hexa_mott",
            name: "Hexa Mott",
            title: "Murky Witch",
            portrait: "hexa_mott",
            scenePortrait: "hexa_mott_scene",  // ✅ Updated for new full-body portrait
            iconFallback: "🌒",
            difficulty: 4,
            timeOfDay: [.evening],
            orderName: "A Hexweaver's Brew",
            orderDialogue: "Make it... *interesting*, brewer.",
            hp: 22,
            patience: 5,
            activeAttack: 3,
            waitingAttack: 2,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 8,
            tickDialogue: "Hexa's fingers twitch in odd patterns.",
            expireDialogue: "Pity. *vanishes in a puff of green*",
            defeatDialogue: "Mmm. I'll remember this. (Is that a threat?)",
            trait: "hexer"  // STUBBED — effect not yet wired
        ),

        "ironhilde": PotionShopCharacter(
            id: "ironhilde",
            name: "Captain Ironhilde",
            title: "Battle-Weary Knight",
            portrait: "ironhilde",
            scenePortrait: "ironhilde",  // Temporary - will become "ironhilde_scene" later
            iconFallback: "🛡️",
            difficulty: 4,
            timeOfDay: [.evening],
            orderName: "A Knight's Restoration",
            orderDialogue: "Make it strong. I haven't slept in three days.",
            hp: 24,
            patience: 4,
            activeAttack: 3,
            waitingAttack: 1,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 8,
            tickDialogue: "Her armor creaks as she shifts.",
            expireDialogue: "*coughs blood, walks out without a word*",
            defeatDialogue: "You have a soldier's gratitude, brewer.",
            trait: "draining"
        ),

        // ─── DIFFICULTY 5 (Bosses — night only) ───────────────────────

        "grimdrek": PotionShopCharacter(
            id: "grimdrek",
            name: "Grimdrek the Volatile",
            title: "Hellsworn Merchant",
            portrait: "grimdrek",
            scenePortrait: "grimdrek_scene",  // ✅ Updated for new full-body portrait
            iconFallback: "👹",
            difficulty: 5,
            timeOfDay: [.night],
            orderName: "A Hellforged Elixir",
            orderDialogue: "Brew, mortal. Carefully now.",
            hp: 32,
            patience: 5,
            activeAttack: 4,
            waitingAttack: 2,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 12,
            tickDialogue: "Smoke curls from Grimdrek's nostrils.",
            expireDialogue: "*explodes into the shop with a roar*",
            defeatDialogue: "...adequate, mortal. I'll return. *vanishes*",
            trait: "volatile"
        ),

        "carmilla": PotionShopCharacter(
            id: "carmilla",
            name: "Lady Carmilla Veil",
            title: "Vampire Countess",
            portrait: "carmilla",
            scenePortrait: "carmilla",  // Temporary - will become "carmilla_scene" later
            iconFallback: "🦇",
            difficulty: 5,
            timeOfDay: [.night],
            orderName: "A Crimson Cordial",
            orderDialogue: "I'm... particular, darling. Try to keep up.",
            hp: 30,
            patience: 4,
            activeAttack: 4,
            waitingAttack: 2,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 12,
            tickDialogue: "Carmilla's smile widens, slowly.",
            expireDialogue: "How predictable. *dissolves into mist*",
            defeatDialogue: "Mmm. You have... potential. I'll be back.",
            trait: "hexer"  // STUBBED — effect not yet wired
        ),

        "royal_envoy": PotionShopCharacter(
            id: "royal_envoy",
            name: "The Royal Envoy",
            title: "On Crown Business",
            portrait: "royal_envoy",
            scenePortrait: "royal_envoy",  // Temporary - will become "royal_envoy_scene" later
            iconFallback: "👑",
            difficulty: 5,
            timeOfDay: [.night],
            orderName: "A Crown's Commission",
            orderDialogue: "By order of the Crown — make it perfect.",
            hp: 36,
            patience: 4,
            activeAttack: 5,
            waitingAttack: 2,
            activePatienceTick: 1,
            waitingPatienceTick: 1,
            expireDamage: 14,
            tickDialogue: "He taps the royal seal pointedly.",
            expireDialogue: "The Crown will hear of this. *storms out*",
            defeatDialogue: "Acceptable work. The Crown thanks you.",
            trait: "intimidating"
        ),
    ]

    // MARK: ─── DAY 1 ROUNDS ────────────────────────────────────────────
    //
    // Day 1 is fully curated for tutorial reliability — every round
    // uses an explicit customer list so first-time players see the
    // same intentional pacing.
    //
    // Day 2+ will eventually use rule-based generation. For v1 we
    // ship Day 1 only. Days 2-7 are flagged in CAULDRON_CONTEXT.md
    // as a planned future addition.

    static let day1: PotionShopDay = PotionShopDay(
        id: "day_1",
        name: "Day 1",
        subtitle: "Opening for Business",

        // 2 customers, both difficulty 1, both no-trait. Pure tutorial.
        morning: PotionShopRound(
            timeOfDay: .morning,
            customerIds: ["mildred", "tomik"]
        ),

        // 2 customers. Pemberton (grumpy merchant) introduces patience
        // pressure. Greta (inspiring) teaches that some traits help you.
        afternoon: PotionShopRound(
            timeOfDay: .afternoon,
            customerIds: ["pemberton", "greta"]
        ),

        // 3 customers — first time the player sees a full queue.
        // Wendelina (high stats, no trait), Crispin (intimidating),
        // Ardo (skittish). Player has to triage.
        evening: PotionShopRound(
            timeOfDay: .evening,
            customerIds: ["wendelina", "crispin", "ardo"]
        ),

        // Single boss. Grimdrek by default.
        // To swap: change to ["carmilla"] or ["royal_envoy"].
        night: PotionShopRound(
            timeOfDay: .night,
            customerIds: ["grimdrek"]
        )
    )

    // MARK: ─── ALL DAYS ─────────────────────────────────────────────
    //
    // For v1 there's just Day 1. Day 2+ will be added later.

    static let allDays: [PotionShopDay] = [day1]

    // MARK: ─── LOOKUPS ──────────────────────────────────────────────

    /// Look up a character by id, returning nil if it doesn't exist.
    static func character(_ id: String) -> PotionShopCharacter? {
        characters[id]
    }

    /// Look up a trait by id, returning nil if it doesn't exist.
    static func trait(_ id: String) -> PotionShopTrait? {
        traits[id]
    }

    /// Get a day by id (e.g. "day_1"). For v1 this returns Day 1 for
    /// any input; multi-day support comes later.
    static func day(_ id: String) -> PotionShopDay? {
        allDays.first { $0.id == id }
    }
}
