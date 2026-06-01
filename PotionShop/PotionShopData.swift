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
            scenePortrait: "pemberton_scene",  // ✅ Updated for full-body scene portrait
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
            scenePortrait: "ardo_scene",  // ✅ Updated for full-body scene portrait
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
            scenePortrait: "bram_scene",  // ✅ Updated for full-body scene portrait
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
            scenePortrait: "crispin_scene",  // ✅ Updated for full-body scene portrait
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
            scenePortrait: "ironhilde_scene",  // ✅ Updated for full-body scene portrait
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
            scenePortrait: "carmilla_scene",  // ✅ Updated for full-body scene portrait
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
            scenePortrait: "royal_envoy_scene",  // ✅ Updated for full-body scene portrait
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

        // ─── DAY 3 GUIDE CHARACTERS (May 25, 2026) ───────────────────
        // 13 new characters drawn against the safe-zone art template.
        // Used ONLY by Day 3 (RNG-driven test mode). All values are
        // placeholders; combat numbers auto-assigned by height bucket.

        "guide_octo": PotionShopCharacter(
            id: "guide_octo", name: "Octo", title: "Tentacled Customer",
            portrait: "guide_octo", scenePortrait: "guide_octo",
            iconFallback: "🐙",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Potion, Please", orderDialogue: "Bloop. Need a brew.",
            hp: 12, patience: 6, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 4,
            tickDialogue: "Tentacles wriggle impatiently.",
            expireDialogue: "Bloop! Leaving now.",
            defeatDialogue: "Bloop! Splendid.",
            trait: nil
        ),
        "guide_girl": PotionShopCharacter(
            id: "guide_girl", name: "Petal", title: "Cheerful Apprentice",
            portrait: "guide_girl", scenePortrait: "guide_girl",
            iconFallback: "🌸",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Bright Brew", orderDialogue: "Hi! Just a quick potion?",
            hp: 16, patience: 8, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "She fidgets with her hair-flowers.",
            expireDialogue: "Maybe next time then!",
            defeatDialogue: "Yay! Thank you!",
            trait: nil
        ),
        "guide_skull": PotionShopCharacter(
            id: "guide_skull", name: "Bones", title: "Restless Skeleton",
            portrait: "guide_skull", scenePortrait: "guide_skull",
            iconFallback: "💀",
            difficulty: 3, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Spectral Tonic", orderDialogue: "...need... brew...",
            hp: 20, patience: 10, activeAttack: 3, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 6,
            tickDialogue: "Blue flames flicker around the skull.",
            expireDialogue: "...too slow... drifting away...",
            defeatDialogue: "...thank you, brewer...",
            trait: nil
        ),
        "guide_slug": PotionShopCharacter(
            id: "guide_slug", name: "Slimey", title: "Slug-Folk Patron",
            portrait: "guide_slug", scenePortrait: "guide_slug",
            iconFallback: "🐌",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "Something Slow", orderDialogue: "Take... your time...",
            hp: 12, patience: 6, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 4,
            tickDialogue: "Slimey leaves a faint trail.",
            expireDialogue: "Oh well... slither off...",
            defeatDialogue: "Delicious...",
            trait: nil
        ),
        "guide_fishguy": PotionShopCharacter(
            id: "guide_fishguy", name: "Finn", title: "Witch-Hat Fisher",
            portrait: "guide_fishguy", scenePortrait: "guide_fishguy",
            iconFallback: "🎣",
            difficulty: 4, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Briny Brew", orderDialogue: "Hurry it up, surface-walker.",
            hp: 22, patience: 11, activeAttack: 3, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 7,
            tickDialogue: "Finn glares from under his pointy hat.",
            expireDialogue: "Bah! Cursed slow brewer.",
            defeatDialogue: "Adequate. Goodbye.",
            trait: nil
        ),
        "guide_bull": PotionShopCharacter(
            id: "guide_bull", name: "Hammer", title: "Minotaur Smith",
            portrait: "guide_bull", scenePortrait: "guide_bull",
            iconFallback: "🐂",
            difficulty: 3, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Smithy's Draught", orderDialogue: "Mhmph. Potion. Strong.",
            hp: 20, patience: 10, activeAttack: 3, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 6,
            tickDialogue: "He hefts his hammer thoughtfully.",
            expireDialogue: "*snorts and stomps out*",
            defeatDialogue: "Good. Stronger now.",
            trait: nil
        ),
        "guide_traveler": PotionShopCharacter(
            id: "guide_traveler", name: "Wanderer", title: "Road-Worn Traveler",
            portrait: "guide_traveler", scenePortrait: "guide_traveler",
            iconFallback: "🎒",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Traveler's Tea", orderDialogue: "Long road ahead. A pick-me-up?",
            hp: 16, patience: 8, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Adjusts the pack on their shoulder.",
            expireDialogue: "Time presses on. Farewell.",
            defeatDialogue: "Many thanks. Safe travels to you, too.",
            trait: nil
        ),
        "guide_demon": PotionShopCharacter(
            id: "guide_demon", name: "Wisp", title: "Floating Imp",
            portrait: "guide_demon", scenePortrait: "guide_demon",
            iconFallback: "👹",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Wicked Brew", orderDialogue: "Hsss... give me potion...",
            hp: 14, patience: 7, activeAttack: 2, waitingAttack: 2,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Wisp hovers, glowing with malice.",
            expireDialogue: "Hssss! Cursed! *vanishes*",
            defeatDialogue: "...acceptable, mortal.",
            trait: nil
        ),
        "guide_frog": PotionShopCharacter(
            id: "guide_frog", name: "Ribbit", title: "Frog Gentleman",
            portrait: "guide_frog", scenePortrait: "guide_frog",
            iconFallback: "🐸",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Damp Tonic", orderDialogue: "Ribbit! Potion, good sir!",
            hp: 16, patience: 8, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Ribbit's throat-sac inflates impatiently.",
            expireDialogue: "Ribbit! Bah! *hops out*",
            defeatDialogue: "Ribbit! Splendid!",
            trait: nil
        ),
        "guide_pig": PotionShopCharacter(
            id: "guide_pig", name: "Tusker", title: "Boar Brawler",
            portrait: "guide_pig", scenePortrait: "guide_pig",
            iconFallback: "🐗",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Beast's Brew", orderDialogue: "Snort! Strong potion!",
            hp: 16, patience: 8, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Tusker paws the floor.",
            expireDialogue: "Snort! Wasted day!",
            defeatDialogue: "Snort! Good.",
            trait: nil
        ),
        "guide_faun": PotionShopCharacter(
            id: "guide_faun", name: "Goatfellow", title: "Faun Pilgrim",
            portrait: "guide_faun", scenePortrait: "guide_faun",
            iconFallback: "🐐",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Forest Draught", orderDialogue: "Goatfellow seeks a brew.",
            hp: 16, patience: 8, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Goatfellow leans on his staff.",
            expireDialogue: "The wood calls. Farewell.",
            defeatDialogue: "Blessings of the green.",
            trait: nil
        ),
        "guide_fox": PotionShopCharacter(
            id: "guide_fox", name: "Vix", title: "Vulpine Ranger",
            portrait: "guide_fox", scenePortrait: "guide_fox",
            iconFallback: "🦊",
            difficulty: 3, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Hunter's Brew", orderDialogue: "Make it sharp, brewer.",
            hp: 20, patience: 10, activeAttack: 3, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 6,
            tickDialogue: "Vix's tail flicks.",
            expireDialogue: "Bah. I hunt elsewhere.",
            defeatDialogue: "Sharp work. My thanks.",
            trait: nil
        ),
        "guide_woman": PotionShopCharacter(
            id: "guide_woman", name: "Gran", title: "Headscarfed Elder",
            portrait: "guide_woman", scenePortrait: "guide_woman",
            iconFallback: "👵",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Mild Brew", orderDialogue: "Now then, dearie, a potion if you would.",
            hp: 16, patience: 8, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Gran sighs and adjusts her handbag.",
            expireDialogue: "Hmph! I'll write to the council.",
            defeatDialogue: "Lovely, dearie. Just lovely.",
            trait: nil
        ),
    ]

    // MARK: ─── CURATED DAYS ─────────────────────────────────────────
    //
    // Days are fully curated for now — every round uses an explicit
    // customer list so the pacing is intentional. Day 2 prioritizes
    // characters not used in Day 1, then repeats Day 1 characters
    // where needed. Day 3+ remains future work; see CAULDRON_CONTEXT.md
    // §4 for the lineup tables.

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

    // MARK: ─── DAY 2 ROUNDS ────────────────────────────────────────────
    //
    // Day 2 introduces the 5 customers that weren't used in Day 1
    // (Sister Halla, Bram, Hexa Mott, Ironhilde, Carmilla, Royal Envoy)
    // alongside a few familiar faces from Day 1 (Mildred, Ardo).
    // Royal Envoy is the Day 2 boss.

    static let day2: PotionShopDay = PotionShopDay(
        id: "day_2",
        name: "Day 2",
        subtitle: "Word Gets Around",

        // Sister Halla (new, pious) + Mildred (Day 1 repeat).
        // Gentle warmup — eases the player back in for Day 2.
        morning: PotionShopRound(
            timeOfDay: .morning,
            customerIds: ["sister_halla", "mildred"]
        ),

        // Bram (new, loud STUB) + Lady Carmilla (new, hexer STUB).
        // Two unused characters; Carmilla brings tier-5 HP early.
        afternoon: PotionShopRound(
            timeOfDay: .afternoon,
            customerIds: ["bram", "carmilla"]
        ),

        // Hexa Mott + Ironhilde (both new, tier-4) + Ardo (repeat, skittish).
        // The real fight of Day 2 — two heavy hitters in the line.
        evening: PotionShopRound(
            timeOfDay: .evening,
            customerIds: ["hexa_mott", "ironhilde", "ardo"]
        ),

        // The Royal Envoy — Day 2 boss (intimidating, HP 34).
        night: PotionShopRound(
            timeOfDay: .night,
            customerIds: ["royal_envoy"]
        )
    )

    // MARK: ─── DAY 3 (RNG TEST — May 25, 2026) ──────────────────────
    //
    // Day 3 is a flexible-round test day for the auto-layout system.
    // Rounds 1 & 2 are FIXED. Rounds 3-5 are RANDOM, drawn from a pool
    // of 8 unused guide characters and shuffled at every app launch.
    // No more than 3 chars per scene. Uses ONLY guide_* assets.
    //
    // This does NOT use PotionShopDay (4-round struct) — instead it uses
    // PotionShopFlexDay so the round count can be flexible (5 here).
    // PotionShopGameState detects dayId == "day_3" and routes accordingly.

    static let day3: PotionShopFlexDay = PotionShopFlexDay(
        id: "day_3",
        name: "Day 3",
        subtitle: "Random Combos (Test)",
        fixedRounds: [
            // Round 1 (fixed, 2 chars) — gentle intro, two mediums
            PotionShopRound(timeOfDay: .morning,
                            customerIds: ["guide_woman", "guide_traveler"]),
            // Round 2 (fixed, 3 chars) — variety: short+wide, medium+skinny, tall+skinny
            // useFeetAnchor: true → characters' feet snap to per-slot floor lines
            // (autoLayoutFeetYActive/Waiting1/Waiting2) for an A/B floor-anchor test.
            PotionShopRound(timeOfDay: .morning,
                            customerIds: ["guide_octo", "guide_girl", "guide_skull"],
                            useFeetAnchor: true)
        ],
        // Remaining 8 characters get split across random rounds 3-5
        randomPool: [
            "guide_slug", "guide_fishguy", "guide_bull", "guide_demon",
            "guide_frog", "guide_pig", "guide_faun", "guide_fox"
        ],
        // 3 + 3 + 2 = 8 chars across rounds 3, 4, 5 (no repeats within day)
        randomRoundSizes: [3, 3, 2]
    )

    // MARK: ─── ALL DAYS ─────────────────────────────────────────────
    //
    // Day 1 and Day 2 use the legacy 4-round PotionShopDay. Day 3 uses
    // the flexible PotionShopFlexDay. They live in different lists.

    static let allDays: [PotionShopDay] = [day1, day2]
    static let allFlexDays: [PotionShopFlexDay] = [day3]

    /// Returns true if the given day id refers to a flex day (Day 3+).
    static func isFlexDay(_ id: String) -> Bool {
        allFlexDays.contains { $0.id == id }
    }

    /// Look up a flex day by id (e.g. "day_3"). Returns nil if not found.
    static func flexDay(_ id: String) -> PotionShopFlexDay? {
        allFlexDays.first { $0.id == id }
    }

    /// Total round count for a given day id (handles both legacy + flex days).
    static func roundCount(forDayId id: String) -> Int {
        if let day = day(id) {
            return day.allRounds.count
        }
        if let flex = flexDay(id) {
            return flex.totalRoundCount
        }
        return 4  // safe fallback
    }

    // MARK: ─── LOOKUPS ──────────────────────────────────────────────

    /// Look up a character by id, returning nil if it doesn't exist.
    static func character(_ id: String) -> PotionShopCharacter? {
        characters[id]
    }

    /// Look up a trait by id, returning nil if it doesn't exist.
    static func trait(_ id: String) -> PotionShopTrait? {
        traits[id]
    }

    /// Get a day by id (e.g. "day_1"). Returns nil if not found.
    static func day(_ id: String) -> PotionShopDay? {
        allDays.first { $0.id == id }
    }

    /// Returns the id of the day after the given one in allDays, or nil
    /// if the given day is the last (or unknown).
    /// Updated May 25, 2026: day_2 chains to day_3 (the flex test day).
    static func nextDayId(after currentId: String) -> String? {
        // Legacy day chain: day_1 → day_2
        if let idx = allDays.firstIndex(where: { $0.id == currentId }) {
            let nextIdx = idx + 1
            if nextIdx < allDays.count {
                return allDays[nextIdx].id
            }
            // Last legacy day → first flex day
            return allFlexDays.first?.id
        }
        // Flex day chain
        if let idx = allFlexDays.firstIndex(where: { $0.id == currentId }) {
            let nextIdx = idx + 1
            return nextIdx < allFlexDays.count ? allFlexDays[nextIdx].id : nil
        }
        return nil
    }

    /// True if the given day id is the last day overall (legacy + flex).
    static func isLastDay(_ id: String) -> Bool {
        if let lastFlex = allFlexDays.last {
            return lastFlex.id == id
        }
        return allDays.last?.id == id
    }
}

// MARK: - PotionShopFlexDay (May 25, 2026)
//
// A day with a flexible number of rounds (vs. the 4-round PotionShopDay).
// Used by Day 3 for the auto-layout RNG test.
//
// Rounds are split into two groups:
//   - fixedRounds: deterministic, same every game
//   - randomRoundSizes: each entry says how many chars to draw from
//                       randomPool for that random round. RNG decides
//                       which chars (no repeats within day).

struct PotionShopFlexDay {
    let id: String              // e.g. "day_3"
    let name: String            // e.g. "Day 3"
    let subtitle: String        // e.g. "Random Combos"
    let fixedRounds: [PotionShopRound]
    let randomPool: [String]    // character ids drawn from for random rounds
    let randomRoundSizes: [Int] // e.g. [3, 3, 2] = 3 random rounds with 3/3/2 chars

    /// Total round count = fixed rounds + one round per random size.
    var totalRoundCount: Int {
        fixedRounds.count + randomRoundSizes.count
    }
}
