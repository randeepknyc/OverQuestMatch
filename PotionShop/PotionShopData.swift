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
//  ⚖️ BALANCE — SOURCE OF TRUTH (JULY 2, 2026):
//  The old per-difficulty stat table that lived here is RETIRED — it
//  predated the weighting/balance system and conflicted with it (bosses
//  are COMPUTED now; HP and attacks are DAY-SCALED, so hand-tuning to
//  absolute targets double-scales). The rules now:
//    • A character's hp / activeAttack / waitingAttack are its DAY-1
//      BASELINE only. The live numbers come from the balance engine:
//      hpDayMultiplier + bucketedHP (order sizes) and
//      attackDayMultiplier (weekly ×1.13/day sawtooth) in
//      PotionShopConfig — tune THOSE, not per-character stats.
//    • Boss nights are DERIVED (bossHPFactorOfEvening /
//      bossAttackFactorOfEvening from that day's evening round) — never
//      hand-tune a boss's hp/attack fields expecting them to stick.
//    • `difficulty` (2–4) has ONE job: gating WHEN a character enters
//      the campaign (difficultyWindow in the generator). It is not a
//      stat multiplier.
//    • patience / expire remain simple per-character personality knobs.
//  The balance lab HTML (§67 in CAULDRON_CONTEXT) simulates all of this.
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
            // JULY 3, 2026: Inspiring REMOVED from all customers (user
            // request — a hidden global dice buff made brew numbers
            // illegible). The trait definition + the dieValueMod machinery
            // in computeBrew stay intact for future use (a boon, a story
            // beat, a rare event). Was: trait: "inspiring".
            trait: nil
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

        // ─── gmarker_* characters (June 1, 2026) ──────────────────────
        // Same lineup as guide_*, but pointing at the gmarker_ assets
        // (left-foot-tip aligned to template anchor). Used by Day 3 R2a.
        "gmarker_octo": PotionShopCharacter(
            id: "gmarker_octo", name: "Octo", title: "Tentacled Customer",
            portrait: "gmarker_octo", scenePortrait: "gmarker_octo",
            iconFallback: "🐙",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Potion, Please", orderDialogue: "Bloop. Need a brew.",
            hp: 12, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 4,
            tickDialogue: "Tentacles wriggle impatiently.",
            expireDialogue: "Bloop! Leaving now.",
            defeatDialogue: "Bloop! Splendid.",
            trait: nil,
            orderPhrases: [
                "Bloop — one potion, when you get a moment.",
                "My tentacles ache; something soothing, please.",
                "Glub. The sea sends its regards, and its coin."
            ],
            traitNames: [
                "Briny",
                "Mellow",
                "Drifting"
            ]
        ),
        // ─── JULY 4, 2026: two new cast members (user's new art) ──────
        "gmarker_vamp": PotionShopCharacter(
            id: "gmarker_vamp", name: "Vesper", title: "Polite Vampire",
            portrait: "gmarker_vamp", scenePortrait: "gmarker_vamp",
            iconFallback: "🧛",
            difficulty: 3, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "Something Restorative", orderDialogue: "No garlic in this, I trust? Splendid.",
            hp: 20, patience: 9, activeAttack: 3, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 4,
            tickDialogue: "He checks a pocket watch that has no hands.",
            expireDialogue: "The night is long, but not THIS long. Farewell.",
            defeatDialogue: "Ah — the color returns to my cheeks. Metaphorically.",
            trait: nil,
            orderPhrases: [
                "Something restorative — sunrise waits for no one.",
                "A brew, please. I find myself... drained.",
                "No garlic in this, I trust? Splendid."
            ],
            traitNames: [
                "Nocturnal",
                "Courtly",
                "Pale"
            ]
        ),
        "gmarker_duck": PotionShopCharacter(
            id: "gmarker_duck", name: "Waddles", title: "Pond Dandy",
            portrait: "gmarker_duck", scenePortrait: "gmarker_duck",
            iconFallback: "🦆",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Pond-Warmer", orderDialogue: "Quack. The pond's gone frightfully cold.",
            hp: 14, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 3,
            tickDialogue: "Feathers ruffle with mounting impatience.",
            expireDialogue: "QUACK! I shall take my coin to the mill pond!",
            defeatDialogue: "Quack-cellent. Simply quack-cellent.",
            trait: nil,
            orderPhrases: [
                "Quack. The pond's gone frightfully cold.",
                "Something warming — I've been dabbling in icy water all day.",
                "One brew, my good brewer, and do mind the tail feathers."
            ],
            traitNames: [
                "Puddle-Proud",
                "Preening",
                "Buoyant"
            ]
        ),
        "gmarker_girl": PotionShopCharacter(
            id: "gmarker_girl", name: "Petal", title: "Cheerful Apprentice",
            portrait: "gmarker_girl", scenePortrait: "gmarker_girl",
            iconFallback: "🌸",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Bright Brew", orderDialogue: "Hi! Just a quick potion?",
            hp: 16, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "She fidgets with her hair-flowers.",
            expireDialogue: "Maybe next time then!",
            defeatDialogue: "Yay! Thank you!",
            trait: nil,
            orderPhrases: [
                "Hi! Mum said you make the good kind.",
                "Ooh, can it be a sparkly one? Please?",
                "I've got exactly enough coins, see?"
            ],
            traitNames: [
                "Cheery",
                "Curious",
                "Bright"
            ]
        ),
        "gmarker_skull": PotionShopCharacter(
            id: "gmarker_skull", name: "Bones", title: "Restless Skeleton",
            portrait: "gmarker_skull", scenePortrait: "gmarker_skull",
            iconFallback: "💀",
            difficulty: 3, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Spectral Tonic", orderDialogue: "...need... brew...",
            hp: 20, patience: 10, activeAttack: 3, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 6,
            tickDialogue: "Blue flames flicker around the skull.",
            expireDialogue: "...too slow... drifting away...",
            defeatDialogue: "...thank you, brewer...",
            trait: nil,
            orderPhrases: [
                "...a draught. For the long road down.",
                "Death is patient. My thirst is not.",
                "Rattle me up something strong."
            ],
            traitNames: [
                "Grim",
                "Hollow",
                "Patient"
            ]
        ),
        "gmarker_slug": PotionShopCharacter(
            id: "gmarker_slug", name: "Slimey", title: "Slug-Folk Patron",
            portrait: "gmarker_slug", scenePortrait: "gmarker_slug",
            iconFallback: "🐌",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "Something Slow", orderDialogue: "Take... your time...",
            hp: 12, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 4,
            tickDialogue: "Slimey leaves a faint trail.",
            expireDialogue: "Oh well... slither off...",
            defeatDialogue: "Delicious...",
            trait: nil,
            orderPhrases: [
                "Taaake... your... tiiime... I suppose.",
                "One slooow brew, if it's no trouble.",
                "I left a trail. You're welcome."
            ],
            traitNames: [
                "Sluggish",
                "Placid",
                "Gooey"
            ]
        ),
        "gmarker_fishguy": PotionShopCharacter(
            id: "gmarker_fishguy", name: "Finn", title: "Witch-Hat Fisher",
            portrait: "gmarker_fishguy", scenePortrait: "gmarker_fishguy",
            iconFallback: "🎣",
            difficulty: 4, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Briny Brew", orderDialogue: "Hurry it up, surface-walker.",
            hp: 22, patience: 10, activeAttack: 3, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 7,
            tickDialogue: "Finn glares from under his pointy hat.",
            expireDialogue: "Bah! Cursed slow brewer.",
            defeatDialogue: "Adequate. Goodbye.",
            trait: nil,
            orderPhrases: [
                "Glub! Surface air's dry — need a tonic.",
                "Make it cold, brewer, cold as the deep.",
                "Scales itching. Something for that?"
            ],
            traitNames: [
                "Slippery",
                "Briny",
                "Wary"
            ]
        ),
        "gmarker_bull": PotionShopCharacter(
            id: "gmarker_bull", name: "Hammer", title: "Minotaur Smith",
            portrait: "gmarker_bull", scenePortrait: "gmarker_bull",
            iconFallback: "🐂",
            difficulty: 3, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Smithy's Draught", orderDialogue: "Mhmph. Potion. Strong.",
            hp: 20, patience: 10, activeAttack: 3, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 6,
            tickDialogue: "He hefts his hammer thoughtfully.",
            expireDialogue: "*snorts and stomps out*",
            defeatDialogue: "Good. Stronger now.",
            trait: nil,
            orderPhrases: [
                "A strong one. I've a field to plough.",
                "Don't water it down, brewer.",
                "Snort. Make it quick or I charge."
            ],
            traitNames: [
                "Stubborn",
                "Brawny",
                "Gruff"
            ]
        ),
        "gmarker_frog": PotionShopCharacter(
            id: "gmarker_frog", name: "Ribbit", title: "Frog Gentleman",
            portrait: "gmarker_frog", scenePortrait: "gmarker_frog",
            iconFallback: "🐸",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Damp Tonic", orderDialogue: "Ribbit! Potion, good sir!",
            hp: 16, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Ribbit's throat-sac inflates impatiently.",
            expireDialogue: "Ribbit! Bah! *hops out*",
            defeatDialogue: "Ribbit! Splendid!",
            trait: nil,
            orderPhrases: [
                "Ribbit — something with a kick.",
                "Hopped all the way here. Worth it?",
                "Flies for breakfast, potion for lunch."
            ],
            traitNames: [
                "Springy",
                "Twitchy",
                "Keen"
            ]
        ),
        "gmarker_fox": PotionShopCharacter(
            id: "gmarker_fox", name: "Vix", title: "Vulpine Ranger",
            portrait: "gmarker_fox", scenePortrait: "gmarker_fox",
            iconFallback: "🦊",
            difficulty: 3, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Hunter's Brew", orderDialogue: "Make it sharp, brewer.",
            hp: 20, patience: 10, activeAttack: 3, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 6,
            tickDialogue: "Vix's tail flicks.",
            expireDialogue: "Bah. I hunt elsewhere.",
            defeatDialogue: "Sharp work. My thanks.",
            trait: nil,
            orderPhrases: [
                "Quick paws, quicker tongue — a brew, now.",
                "I know a good potion when I smell one.",
                "Clever hands deserve clever pay, hm?"
            ],
            traitNames: [
                "Sly",
                "Quick",
                "Cunning"
            ]
        ),
        "gmarker_traveler": PotionShopCharacter(
            id: "gmarker_traveler", name: "Wanderer", title: "Road-Worn Traveler",
            portrait: "gmarker_traveler", scenePortrait: "gmarker_traveler",
            iconFallback: "🎒",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Traveler's Tea", orderDialogue: "Long road ahead. A pick-me-up?",
            hp: 16, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Adjusts the pack on their shoulder.",
            expireDialogue: "Time presses on. Farewell.",
            defeatDialogue: "Many thanks. Safe travels to you, too.",
            trait: nil,
            orderPhrases: [
                "Long road behind me. Something restorative.",
                "I've coin from three kingdoms — surprise me.",
                "A traveler's tonic, brewer, for the miles ahead."
            ],
            traitNames: [
                "Weathered",
                "Wandering",
                "Hardy"
            ]
        ),
        "gmarker_demon": PotionShopCharacter(
            id: "gmarker_demon", name: "Wisp", title: "Floating Imp",
            portrait: "gmarker_demon", scenePortrait: "gmarker_demon",
            iconFallback: "👹",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Wicked Brew", orderDialogue: "Hsss... give me potion...",
            hp: 14, patience: 10, activeAttack: 2, waitingAttack: 2,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Wisp hovers, glowing with malice.",
            expireDialogue: "Hssss! Cursed! *vanishes*",
            defeatDialogue: "...acceptable, mortal.",
            trait: nil,
            orderPhrases: [
                "Mortal. A potion. Do not disappoint me.",
                "Your finest, or your last.",
                "I have burned shops for weaker brews."
            ],
            traitNames: [
                "Wrathful",
                "Smoldering",
                "Dread"
            ]
        ),
        "gmarker_goatguy": PotionShopCharacter(
            id: "gmarker_goatguy", name: "Goatfellow", title: "Faun Pilgrim",
            portrait: "gmarker_goatguy", scenePortrait: "gmarker_goatguy",
            iconFallback: "🐐",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Forest Draught", orderDialogue: "Goatfellow seeks a brew.",
            hp: 16, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Goatfellow leans on his staff.",
            expireDialogue: "The wood calls. Farewell.",
            defeatDialogue: "Blessings of the green.",
            trait: nil,
            orderPhrases: [
                "Maaa. One brew, and make it bitter.",
                "I'll headbutt the counter if you're slow.",
                "Grass won't cut it today, brewer."
            ],
            traitNames: [
                "Ornery",
                "Headstrong",
                "Bleating"
            ]
        ),
        "gmarker_oldlady": PotionShopCharacter(
            id: "gmarker_oldlady", name: "Gran", title: "Headscarfed Elder",
            portrait: "gmarker_oldlady", scenePortrait: "gmarker_oldlady",
            iconFallback: "👵",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Mild Brew", orderDialogue: "Now then, dearie, a potion if you would.",
            hp: 16, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Gran sighs and adjusts her handbag.",
            expireDialogue: "Hmph! I'll write to the council.",
            defeatDialogue: "Lovely, dearie. Just lovely.",
            trait: nil,
            orderPhrases: [
                "Eh? Speak up and pour up, dearie.",
                "In my day, potions were stronger.",
                "A little something for these old bones."
            ],
            traitNames: [
                "Crotchety",
                "Spry",
                "Sharp"
            ]
        ),
        "gmarker_bird": PotionShopCharacter(
            id: "gmarker_bird", name: "Feathers", title: "Avian Visitor",
            portrait: "gmarker_bird", scenePortrait: "gmarker_bird",
            iconFallback: "🐦",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Warming Tonic", orderDialogue: "Chirp! One potion, please.",
            hp: 14, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 4,
            tickDialogue: "Feathers ruffles impatiently.",
            expireDialogue: "Tweet! I'm flying off!",
            defeatDialogue: "Chirp chirp! Wonderful brew!",
            trait: nil,
            orderPhrases: [
                "Tweet — something light, on the wing.",
                "Migrating soon; need it to-go.",
                "Seeds and a sip, that's all I ask."
            ],
            traitNames: [
                "Flighty",
                "Chirpy",
                "Restless"
            ]
        ),
        "gmarker_dino": PotionShopCharacter(
            id: "gmarker_dino", name: "Rex", title: "Ancient Lizard",
            portrait: "gmarker_dino", scenePortrait: "gmarker_dino",
            iconFallback: "🦕",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Primordial Elixir", orderDialogue: "RAAWR. Potion. Now.",
            hp: 16, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 5,
            tickDialogue: "Rex stomps a massive foot.",
            expireDialogue: "RAAWR! Too slow!",
            defeatDialogue: "Rrrr... good brew.",
            trait: nil,
            orderPhrases: [
                "Rawr — a big one, brewer. Big.",
                "Old blood needs a strong brew.",
                "Stomp. Stomp. Potion. Now."
            ],
            traitNames: [
                "Ancient",
                "Towering",
                "Roaring"
            ]
        ),
        "gmarker_puck": PotionShopCharacter(
            id: "gmarker_puck", name: "Puck", title: "Mischief Sprite",
            portrait: "gmarker_puck", scenePortrait: "gmarker_puck",
            iconFallback: "🧚",
            difficulty: 2, timeOfDay: [.morning, .afternoon, .evening, .night],
            orderName: "A Trickster's Brew", orderDialogue: "Hehe! Whatcha got for me?",
            hp: 10, patience: 10, activeAttack: 2, waitingAttack: 1,
            activePatienceTick: 1, waitingPatienceTick: 1, expireDamage: 4,
            tickDialogue: "Puck giggles and fidgets.",
            expireDialogue: "Bah! I'll prank someone else!",
            defeatDialogue: "Ooh! Sparkly! Thanks!",
            trait: nil,
            orderPhrases: [
                "Hee! Make it fizz, make it pop!",
                "A trick in a bottle, if you please.",
                "Catch me if the potion's too slow!"
            ],
            traitNames: [
                "Mischief",
                "Spry",
                "Giddy"
            ]
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

        // ═══════════════════════════════════════════════════════════════
        //  JUNE 12, 2026 — DAY 1 = FULL-GAME-FLOW TEST GROUND
        //  Every Day 1 round now:
        //   • uses the D3R3 customer-scene visuals  → useFeetAnchor: true
        //   • uses the D2R2 dice + node behavior     → wired in
        //     PotionShopGameState.currentRoundUses3DDice (dayId == "day_1")
        //   • draws its customers AT RANDOM from the 12 gmarker_* assets
        //     every time the round spawns (randomFromPool). Re-entering a
        //     round via the debug menu re-spawns it → fresh characters.
        //  Counts: morning/afternoon/evening = 3 customers; night = 1 boss.
        //  (customerIds is COUNT-ONLY when randomFromPool is set — the
        //   literal ids are placeholders; the pool is what actually draws.)
        // ═══════════════════════════════════════════════════════════════

        // 3 random customers from the gmarker pool.
        morning: PotionShopRound(
            timeOfDay: .morning,
            customerIds: ["gmarker_octo", "gmarker_girl", "gmarker_skull"],
            useFeetAnchor: true,
            randomFromPool: PotionShopData.gmarkerPool
        ),

        // 3 random customers from the gmarker pool.
        afternoon: PotionShopRound(
            timeOfDay: .afternoon,
            customerIds: ["gmarker_slug", "gmarker_fishguy", "gmarker_bull"],
            useFeetAnchor: true,
            randomFromPool: PotionShopData.gmarkerPool
        ),

        // 3 random customers from the gmarker pool.
        evening: PotionShopRound(
            timeOfDay: .evening,
            customerIds: ["gmarker_frog", "gmarker_fox", "gmarker_traveler"],
            useFeetAnchor: true,
            randomFromPool: PotionShopData.gmarkerPool
        ),

        // Single BOSS — 1 random customer from the gmarker pool.
        night: PotionShopRound(
            timeOfDay: .night,
            customerIds: ["gmarker_demon"],
            useFeetAnchor: true,
            randomFromPool: PotionShopData.gmarkerPool
        )
    )

    /// June 12, 2026: the 12 gmarker_* customer ids, used as Day 1's random
    /// draw pool. Add/remove ids here to change who can appear in Day 1.
    static let gmarkerPool: [String] = [
        "gmarker_octo", "gmarker_girl", "gmarker_skull", "gmarker_slug",
        "gmarker_fishguy", "gmarker_bull", "gmarker_frog", "gmarker_fox",
        "gmarker_traveler", "gmarker_demon", "gmarker_goatguy", "gmarker_oldlady",
        "gmarker_bird", "gmarker_dino", "gmarker_puck"
    ]

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

        // ═══════════════════════════════════════════════════════════════
        //  JUNE 18, 2026 — DAY 2 now MIRRORS DAY 1 (second comparable test
        //  day). All rounds feet-anchor + gmarker random pool + 3/3/3/1.
        // ═══════════════════════════════════════════════════════════════

        morning: PotionShopRound(
            timeOfDay: .morning,
            customerIds: ["gmarker_octo", "gmarker_girl", "gmarker_skull"],
            useFeetAnchor: true,
            randomFromPool: PotionShopData.gmarkerPool
        ),

        afternoon: PotionShopRound(
            timeOfDay: .afternoon,
            customerIds: ["gmarker_slug", "gmarker_fishguy", "gmarker_bull"],
            useFeetAnchor: true,
            randomFromPool: PotionShopData.gmarkerPool
        ),

        evening: PotionShopRound(
            timeOfDay: .evening,
            customerIds: ["gmarker_frog", "gmarker_fox", "gmarker_traveler"],
            useFeetAnchor: true,
            randomFromPool: PotionShopData.gmarkerPool
        ),

        night: PotionShopRound(
            timeOfDay: .night,
            customerIds: ["gmarker_demon"],
            useFeetAnchor: true,
            randomFromPool: PotionShopData.gmarkerPool
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
            // Round 2 (3 chars, RANDOMIZED gmarker pool — June 3, 2026)
            // customerIds is a placeholder for COUNT only; randomFromPool
            // gets a fresh random pick from the 12 gmarker chars each load.
            // Feet-anchor mode + same layout values as R3.
            PotionShopRound(timeOfDay: .morning,
                            customerIds: ["_", "_", "_"],
                            useFeetAnchor: true,
                            randomFromPool: [
                                "gmarker_octo", "gmarker_girl", "gmarker_skull",
                                "gmarker_slug", "gmarker_fishguy", "gmarker_bull",
                                "gmarker_frog", "gmarker_fox", "gmarker_traveler",
                                "gmarker_demon", "gmarker_goatguy", "gmarker_oldlady",
                                "gmarker_bird", "gmarker_dino", "gmarker_puck",
                            ]),
            // Round 3 (added June 1, 2026) — same fixed lineup as the old R2
            // but using gmarker_* assets. Acts as the A/B baseline against the
            // randomized R2 above.
            PotionShopRound(timeOfDay: .morning,
                            customerIds: ["gmarker_octo", "gmarker_girl", "gmarker_skull"],
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

    // MARK: ─── 30-DAY CAMPAIGN (June 28, 2026 — rebuilt) ────────────
    //
    // Finite 30-day run. EVERY day is generated as a 4-round PotionShopDay
    // (morning/afternoon/evening = 3 patrons, night = 1 closer). The crowd
    // shape is fixed; difficulty rises only through the HP curve + a rising
    // difficulty window (owner decision).
    //
    // ⭐️ VISUAL SOURCE OF TRUTH = DAY 1. Every generated round sets
    // `useFeetAnchor: true` (exactly like the authored Day 1/2 rounds) so
    // customers stage on Day 1's floor plane via the bucket system, instead of
    // the flat default. The cast is restricted to the `campaignCast` below —
    // the customers that have been drawn AND given height/width buckets in
    // PotionShopLayoutConfig. See "HOW TO ADD A NEW CUSTOMER" at the bottom.

    static let campaignLength = 30

    /// ⭐️ THE CAMPAIGN CAST — the only customers the generator uses.
    /// These are the finished `gmarker_` customers that have height/width
    /// buckets (so feet-anchor sizes them correctly on Day 1's floor).
    /// ➕ TO ADD A NEW CUSTOMER: draw it, add it to `characters`, give it a
    /// bucket via `applyGuideCharacter(...)` in PotionShopLayoutConfig, then
    /// add its id to THIS list. That's all — it then appears automatically.
    static let campaignCast: [String] = [
        "gmarker_octo", "gmarker_girl", "gmarker_skull", "gmarker_slug",
        "gmarker_fishguy", "gmarker_bull", "gmarker_frog", "gmarker_fox",
        "gmarker_traveler", "gmarker_demon", "gmarker_bird", "gmarker_dino",
        "gmarker_goatguy", "gmarker_oldlady", "gmarker_puck",
        "gmarker_vamp", "gmarker_duck"   // JULY 4, 2026: new art
    ]

    /// Boss-night closers. JULY 5, 2026: these ARE the bosses now, final —
    /// the old pre-template originals (carmilla / grimdrek / royal_envoy and
    /// the rest of the original 14) were REDRAWN AS the gmarker cast and are
    /// permanently retired. Their definitions remain in `characters` as
    /// dormant data only. (Property names kept as "StandIns" to avoid
    /// churning call sites — read them as "boss closers".)
    static let weeklyBossStandIns = ["gmarker_bull", "gmarker_skull", "gmarker_fox"]
    static let finaleBossStandIn  = "gmarker_fishguy"   // biggest order in the cast

    /// Parse "day_7" → 7. Returns nil for malformed ids.
    static func dayNumber(fromId id: String) -> Int? {
        Int(id.replacingOccurrences(of: "day_", with: ""))
    }
    static func dayId(forNumber n: Int) -> String { "day_\(n)" }
    static func isBossDay(_ n: Int) -> Bool { [7, 14, 21, 28].contains(n) }
    static func isFinaleDay(_ n: Int) -> Bool { n == campaignLength }

    /// Difficulty window allowed on a given day (ramps across the campaign).
    /// Tougher cast members (higher base HP) enter on later days.
    private static func difficultyWindow(forDay n: Int) -> ClosedRange<Int> {
        switch n {
        case ...7:    return 2...2
        case 8...14:  return 2...3
        case 15...21: return 2...3
        default:      return 2...4
        }
    }

    /// Cast members eligible on a given day (within the difficulty window).
    /// Always non-empty (falls back to the whole cast if a window is too tight).
    private static func pool(difficulty window: ClosedRange<Int>) -> [String] {
        let eligible = campaignCast.filter {
            if let d = characters[$0]?.difficulty { return window.contains(d) }
            return false
        }
        return eligible.count >= 3 ? eligible.sorted() : campaignCast.sorted()
    }

    /// JULY 2, 2026 — PER-RUN CROWD SHUFFLE. The campaign generator was
    /// seeded by DAY NUMBER ONLY, so every run/replay/install produced the
    /// IDENTICAL 30-day crowd schedule ("same 3 customers every round").
    /// This salt is rolled once per NEW run (GameState.runSeed, persisted
    /// in the save) and mixed into every day's seed: days stay stable
    /// WITHIN a run (save-friendly, no respawn flicker — the original
    /// intent), but every new run deals a different schedule.
    static var campaignRunSalt: UInt64 = 0

    /// Generate the full 4-round day. DETERMINISTIC within a run (seeded
    /// by day number ⊕ the run salt) so a day always rebuilds the same
    /// lineup — no respawn flicker, save-friendly.
    /// ⭐️ Every round sets useFeetAnchor: true so customers stage exactly like
    /// the authored Day 1 (the visual source of truth).
    static func generatedDay(_ n: Int) -> PotionShopDay {
        var rng = PotionShopSeededRNG(seed: (UInt64(max(1, n)) &* 2654435761) ^ campaignRunSalt)
        let window = difficultyWindow(forDay: n)

        func makeRound(_ idx: Int, _ tod: PotionShopTimeOfDay) -> PotionShopRound {
            var ids: [String] = []

            // Night (idx 3): a SINGLE closer. On boss/finale nights it's the
            // boss stand-in; otherwise one cast member.
            if idx == 3 {
                if isFinaleDay(n) {
                    ids = [finaleBossStandIn]
                } else if isBossDay(n) {
                    ids = [weeklyBossStandIns[((n / 7) - 1) % weeklyBossStandIns.count]]
                } else {
                    var cand = pool(difficulty: window).shuffled(using: &rng)
                    ids = [cand.first ?? campaignCast[0]]
                }
                return PotionShopRound(timeOfDay: tod, customerIds: ids, useFeetAnchor: true)
            }

            // Daytime: 3 cast members, no repeats within the round.
            var cand = pool(difficulty: window).shuffled(using: &rng)
            for _ in 0..<3 {
                if cand.isEmpty { cand = pool(difficulty: window).shuffled(using: &rng) }
                if let pick = cand.first { ids.append(pick); cand.removeFirst() }
            }
            return PotionShopRound(timeOfDay: tod, customerIds: ids, useFeetAnchor: true)
        }

        return PotionShopDay(
            id: dayId(forNumber: n),
            name: "Day \(n)",
            subtitle: isFinaleDay(n) ? "The Final Night"
                    : isBossDay(n)   ? "A Dangerous Customer"
                    : "Brewing",
            morning:   makeRound(0, .morning),
            afternoon: makeRound(1, .afternoon),
            evening:   makeRound(2, .evening),
            night:     makeRound(3, .night)
        )
    }

    // MARK: ─── DAY REGISTRY / RESOLVERS ─────────────────────────────

    /// All 30 generated days — used by the debug "Skip to Day & Round" jumper.
    static var allDays: [PotionShopDay] {
        (1...campaignLength).map { generatedDay($0) }
    }
    /// Flex days retired in the campaign. Empty so the old flex code paths
    /// (isFlexDay / flexDay) cleanly resolve to "none".
    static let allFlexDays: [PotionShopFlexDay] = []
    static func isFlexDay(_ id: String) -> Bool { false }
    static func flexDay(_ id: String) -> PotionShopFlexDay? { nil }
    static func roundCount(forDayId id: String) -> Int { PotionShopConfig.roundsPerDay }

    // MARK: ─── LOOKUPS ──────────────────────────────────────────────

    static func character(_ id: String) -> PotionShopCharacter? { characters[id] }
    static func trait(_ id: String) -> PotionShopTrait? { traits[id] }

    /// Get a day by id. Generates any day in 1...30; nil outside the campaign.
    static func day(_ id: String) -> PotionShopDay? {
        guard let n = dayNumber(fromId: id), n >= 1, n <= campaignLength else { return nil }
        return generatedDay(n)
    }
    /// The day after the given one, or nil once Day 30 is finished.
    static func nextDayId(after currentId: String) -> String? {
        guard let n = dayNumber(fromId: currentId) else { return nil }
        return n < campaignLength ? dayId(forNumber: n + 1) : nil
    }
    /// True if the given day id is the final day (Day 30).
    static func isLastDay(_ id: String) -> Bool {
        dayNumber(fromId: id) == campaignLength
    }

    // ═══════════════════════════════════════════════════════════════════
    // 📋 HOW TO ADD A NEW CUSTOMER TO THE CAMPAIGN ROTATION
    // ═══════════════════════════════════════════════════════════════════
    // The generator only uses customers that are visually finished (drawn +
    // placed on the floor). To bring a newly-drawn customer into the rotation,
    // do these THREE things, then it appears automatically:
    //
    //   1) ADD THE ART: put the customer's image(s) in Assets.xcassets.
    //
    //   2) ADD TO THE ROSTER: add a PotionShopCharacter entry to `characters`
    //      (scroll up to the characters dictionary). Set its id, hp, patience,
    //      difficulty (2 = normal … 4 = tough), and timeOfDay.
    //
    //   3) GIVE IT A FLOOR BUCKET: in PotionShopLayoutConfig, add a line like
    //         applyGuideCharacter(id: "gmarker_newguy", height: .medium, width: .medium)
    //      Pick the height/width that matches the art. THIS is what lets the
    //      customer stand correctly on Day 1's floor (feet-anchor needs it).
    //
    //   4) ADD ITS ID to `campaignCast` above.
    //
    // To make a real boss (carmilla / grimdrek / royal_envoy) appear: finish
    // steps 1–3 for it, add it to campaignCast, then swap its id into
    // `weeklyBossStandIns` / `finaleBossStandIn` above.
    // ═══════════════════════════════════════════════════════════════════
}

// MARK: - PotionShopSeededRNG (June 28, 2026)
//
// Deterministic SplitMix64 RNG used by the day generator so each day number
// always yields the same lineup (reproducible; keeps re-entering a round from
// reshuffling and makes saved runs resume identically).
struct PotionShopSeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = (seed == 0) ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
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

// MARK: - 🗨️ DAY-END / WIN / LOSE FLAVOR MESSAGES (July 5, 2026)
//
// ✏️ EDIT FREELY — this is pure dialogue, no logic to break.
// The day-won and run-won lines are picked by how much composure was LEFT
// when the last round ended (BEFORE the rest heal / Mended Spirit relic
// top it back up). Defeat lines are picked by how far the run got.
//
//   • dayWon / runWon rows: (atLeast: fraction of max composure, text).
//     The FIRST row the player qualifies for wins, top to bottom — keep
//     them in DESCENDING order. 1.0 = untouched, 0.0 = barely alive.
//   • lost rows: (byDay: day number, text) in ASCENDING order — the first
//     row whose day the run reached at-or-before wins.
//
// Add or remove rows freely; any count works.

enum PotionShopDayEndMessages {

    /// Shown on the "Day Complete" screen.
    static let dayWon: [(atLeast: Double, text: String)] = [
        (1.00, "Not a scratch. That was easy!"),
        (0.75, "A fine day's brewing."),
        (0.50, "Busy one. The kettle has earned its keep."),
        (0.25, "Rough crowd today… but the shop stands."),
        (0.00, "Exhausting day. Tea, then bed. Immediately."),
    ]

    /// Shown on the Day-30 victory screen.
    static let runWon: [(atLeast: Double, text: String)] = [
        (0.75, "Thirty days and barely winded. Legendary."),
        (0.25, "Thirty days of chaos, survived with style."),
        (0.00, "Thirty days… by a whisker. Never again. (Same time next week?)"),
    ]

    /// Shown on the defeat screen — composure is always 0 here, so these
    /// vary by how FAR the run got instead.
    static let lost: [(byDay: Int, text: String)] = [
        (3,  "The morning rush proved… educational."),
        (7,  "The first week bites. It always does."),
        (14, "Two weeks in — the crowds only get bolder."),
        (21, "So close to the final stretch. The shop will remember."),
        (30, "Felled within sight of the finish line. Cruel."),
    ]

    // ── Lookups (no need to touch these when editing the lines above) ──

    static func dayWonText(composure: Int, maxComposure: Int) -> String {
        let frac = maxComposure > 0 ? Double(composure) / Double(maxComposure) : 0
        return dayWon.first(where: { frac >= $0.atLeast })?.text
            ?? dayWon.last?.text ?? ""
    }

    static func runWonText(composure: Int, maxComposure: Int) -> String {
        let frac = maxComposure > 0 ? Double(composure) / Double(maxComposure) : 0
        return runWon.first(where: { frac >= $0.atLeast })?.text
            ?? runWon.last?.text ?? ""
    }

    static func lostText(dayNumber: Int) -> String {
        lost.first(where: { dayNumber <= $0.byDay })?.text
            ?? lost.last?.text ?? ""
    }
}
