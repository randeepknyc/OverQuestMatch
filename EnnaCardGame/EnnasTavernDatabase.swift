//
//  EnnasTavernDatabase.swift
//  OverQuestMatch3 — Enna's Tavern
//
//  ═══════════════════════════════════════════════════════════
//  📝 THIS IS THE FILE YOU EDIT TO CHANGE THE GAME'S CONTENT
//  ═══════════════════════════════════════════════════════════
//  • THE MENU        — hand rows, names, requirements, point values
//  • JOKERS          — everything the merchants sell
//  • PATRONS         — the gmarker characters + their lines
//  • MERCHANTS       — the traveling caravan
//  • REACTIONS       — what patrons say per hand tier
//  • ENDINGS         — the 21 (flavor text is verbatim — treasure it)
//
//  Rename any patron freely — only `id` and `imageName` must not change.
//

import Foundation

struct EnnasTavernDatabase {

    // ============================================================
    // 🍺 THE MENU (the score sheet)
    // Each row can be banked ONCE per day (except The Nod).
    // ============================================================
    static let rows: [TavernRow] = [
        TavernRow(id: .nod,           name: "The Nod",              requirement: "Anything at all",        baseValue: 5,   worksWithDice: true,  worksWithCards: true,  repeatable: true),
        TavernRow(id: .pair,          name: "A Kind Word",          requirement: "Pair",                   baseValue: 10,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .twoPair,       name: "Split Shift",          requirement: "Two Pair",               baseValue: 20,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .trips,         name: "The Long Talk",        requirement: "Three of a Kind",        baseValue: 35,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .straight,      name: "The Full Goose",       requirement: "Straight (run of 5)",    baseValue: 50,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .flush,         name: "Kindred Spirits",      requirement: "Flush (5 of one suit)",  baseValue: 55,  worksWithDice: false, worksWithCards: true,  repeatable: false),
        TavernRow(id: .fullHouse,     name: "Sunday Roast",         requirement: "Full House (3 + 2)",     baseValue: 70,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .four,          name: "The Barred Door",      requirement: "Four of a Kind",         baseValue: 90,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .five,          name: "The Regular's Toast",  requirement: "Five of a Kind",         baseValue: 150, worksWithDice: true,  worksWithCards: false, repeatable: false),
        TavernRow(id: .straightFlush, name: "The Royal Welcome",    requirement: "Straight Flush",         baseValue: 150, worksWithDice: false, worksWithCards: true,  repeatable: false)
    ]

    static func row(_ id: TavernRowID) -> TavernRow {
        rows.first { $0.id == id } ?? rows[0]
    }

    // ============================================================
    // 🎲 HAND EVALUATION — which menu rows do these dice/cards make?
    // Pure uniform probability. Nothing here is weighted for the player.
    // ============================================================
    static func qualifyingRows(dice: [Int]) -> Set<TavernRowID> {
        var out: Set<TavernRowID> = [.nod]
        let counts = Dictionary(grouping: dice, by: { $0 }).mapValues { $0.count }
        let maxCount = counts.values.max() ?? 0
        let pairsOrBetter = counts.values.filter { $0 >= 2 }.count

        if maxCount >= 2 { out.insert(.pair) }
        if pairsOrBetter >= 2 || maxCount >= 4 { out.insert(.twoPair) }
        if maxCount >= 3 { out.insert(.trips) }
        if maxCount >= 4 { out.insert(.four) }
        if maxCount == 5 { out.insert(.five) }

        let unique = Set(dice).sorted()
        if unique == [1, 2, 3, 4, 5] || unique == [2, 3, 4, 5, 6] { out.insert(.straight) }

        let sortedCounts = counts.values.sorted()
        if sortedCounts == [2, 3] { out.insert(.fullHouse) }

        return out
    }

    static func qualifyingRows(cards: [TavernPlayingCard]) -> Set<TavernRowID> {
        var out: Set<TavernRowID> = [.nod]
        let ranks = cards.map { $0.rank }
        let counts = Dictionary(grouping: ranks, by: { $0 }).mapValues { $0.count }
        let maxCount = counts.values.max() ?? 0
        let pairsOrBetter = counts.values.filter { $0 >= 2 }.count

        if maxCount >= 2 { out.insert(.pair) }
        if pairsOrBetter >= 2 || maxCount >= 4 { out.insert(.twoPair) }
        if maxCount >= 3 { out.insert(.trips) }
        if maxCount >= 4 { out.insert(.four) }

        let sortedCounts = counts.values.sorted()
        if sortedCounts == [2, 3] { out.insert(.fullHouse) }

        let unique = Set(ranks).sorted()
        var isStraight = false
        if unique.count == 5 {
            if unique.last! - unique.first! == 4 { isStraight = true }
            if unique == [2, 3, 4, 5, 14] { isStraight = true }   // A-2-3-4-5 wheel
        }
        if isStraight { out.insert(.straight) }

        let isFlush = Set(cards.map { $0.suit }).count == 1
        if isFlush { out.insert(.flush) }
        if isFlush && isStraight { out.insert(.straightFlush) }

        return out
    }

    // ============================================================
    // 🃏 JOKERS — everything the caravan sells
    // Act 1 = Enna's HABITS · Act 2 = FIXTURES & REGULARS · Act 3 = FACTIONS
    // ============================================================
    static let jokers: [TavernJoker] = [

        // ---- ACT 1 · HABITS ----
        TavernJoker(id: "stubborn", name: "Stubborn", icon: "😤", actClass: 1, cost: 5,
                    blurb: "Daily quotas are 10% lower. She simply refuses.",
                    thresholdMultiplier: 0.9),

        TavernJoker(id: "patience", name: "Mother's Patience", icon: "🫖", actClass: 1, cost: 5,
                    blurb: "+1 do-over with every patron.",
                    extraRerolls: 1),

        TavernJoker(id: "spite", name: "Spite", icon: "🔥", actClass: 1, cost: 5,
                    blurb: "After a bank of 10 or less, the next bank gets +15. Fueled by failure.",
                    spite: true),

        TavernJoker(id: "recipe", name: "Mother's Recipe", icon: "🍲", actClass: 1, cost: 5,
                    blurb: "The Long Talk scores +20. It's the soup that opens people up.",
                    rowFlatBonuses: [.trips: 20]),

        TavernJoker(id: "earlyriser", name: "Early Riser", icon: "🌅", actClass: 1, cost: 5,
                    blurb: "+1 patron on the first day of every act.",
                    extraPatronsFirstDayOfAct: 1),

        TavernJoker(id: "lightsleeper", name: "Light Sleeper", icon: "🕯️", actClass: 1, cost: 8,
                    blurb: "+1 patron every day. She hears the late knock.",
                    extraPatronsPerDay: 1),

        // ---- THE SWORD (special one-time offer, first market only) ----
        TavernJoker(id: "sword", name: "The Sword (?)", icon: "🗡️", actClass: 1, cost: EnnasTavernConfig.swordPrice,
                    blurb: "All banks +10. It hums when the door opens. It was in a pawnshop. Don't ask.",
                    flatBonusPerBank: 10,
                    unique: true),

        // ---- ACT 2 · FIXTURES, STAFF & REGULARS ----
        TavernJoker(id: "ladle", name: "Grandma's Ladle", icon: "🥄", actClass: 2, cost: 7,
                    blurb: "Sunday Roast scores double.",
                    rowMultipliers: [.fullHouse: 2.0]),

        TavernJoker(id: "kettle", name: "The Good Kettle", icon: "☕", actClass: 2, cost: 7,
                    blurb: "Every bank scores +5. It has never once whistled off-key.",
                    flatBonusPerBank: 5),

        TavernJoker(id: "gremlock", name: "Gremlock Dishwasher", icon: "🪨", actClass: 2, cost: 7,
                    blurb: "The first Nod each day scores 25. He also brings a rock.",
                    gremlockNod: true),

        TavernJoker(id: "bakasura", name: "Bakasura's Table", icon: "🍽️", actClass: 2, cost: 7,
                    blurb: "The Barred Door, The Regular's Toast, and The Royal Welcome score +40. He is already eating.",
                    rowFlatBonuses: [.four: 40, .five: 40, .straightFlush: 40]),

        TavernJoker(id: "noamron", name: "Regular: Noamron", icon: "🦊", actClass: 2, cost: 7,
                    blurb: "+8 coin every morning. Some evenings, something goes missing.",
                    morningCoin: 8,
                    noamronRisk: true),

        // ---- ACT 3 · FACTION JOKERS ----
        // GUILD
        TavernJoker(id: "guildcontract", name: "Guild Contract", icon: "⚒️", actClass: 3, faction: .guild, cost: 9,
                    blurb: "The Long Talk scores double. Page 31 just says \"OBEY.\"",
                    rowMultipliers: [.trips: 2.0]),

        TavernJoker(id: "chapterhousetab", name: "Chapterhouse Tab", icon: "📜", actClass: 3, faction: .guild, cost: 9,
                    blurb: "The Full Goose scores +25. The Guild drinks in formation.",
                    rowFlatBonuses: [.straight: 25]),

        TavernJoker(id: "unionstamp", name: "Union Stamp", icon: "🔨", actClass: 3, faction: .guild, cost: 9,
                    blurb: "Split Shift scores +20. Approved by committee.",
                    rowFlatBonuses: [.twoPair: 20]),

        // NOBLES
        TavernJoker(id: "noblepatronage", name: "Noble Patronage", icon: "👑", actClass: 3, faction: .nobles, cost: 9,
                    blurb: "Every bank scores +15, but quotas are 10% higher. Expectations.",
                    thresholdMultiplier: 1.1,
                    flatBonusPerBank: 15),

        TavernJoker(id: "gildedmenu", name: "Gilded Menu", icon: "✨", actClass: 3, faction: .nobles, cost: 9,
                    blurb: "Kindred Spirits scores +25. The circumflex was free.",
                    rowFlatBonuses: [.flush: 25]),

        TavernJoker(id: "velvetrope", name: "Velvet Rope", icon: "🎀", actClass: 3, faction: .nobles, cost: 9,
                    blurb: "Sunday Roast scores +30. Reservations only.",
                    rowFlatBonuses: [.fullHouse: 30]),

        // COMMONS
        TavernJoker(id: "wordofmouth", name: "Word of Mouth", icon: "🗣️", actClass: 3, faction: .commons, cost: 9,
                    blurb: "+1 patron every day. Everyone heard about the soup.",
                    extraPatronsPerDay: 1),

        TavernJoker(id: "potluck", name: "Commons Potluck", icon: "🥧", actClass: 3, faction: .commons, cost: 9,
                    blurb: "A Kind Word and Split Shift score +15. Everybody brought something.",
                    rowFlatBonuses: [.pair: 15, .twoPair: 15]),

        TavernJoker(id: "longbench", name: "The Long Bench", icon: "🪵", actClass: 3, faction: .commons, cost: 9,
                    blurb: "The Nod scores +10. There is always room.",
                    rowFlatBonuses: [.nod: 10]),

        // WATCH
        TavernJoker(id: "watchdiscount", name: "Watch Discount", icon: "🛡️", actClass: 3, faction: .watch, cost: 9,
                    blurb: "+1 do-over with every patron. They're nervous, but they're helpful.",
                    extraRerolls: 1),

        TavernJoker(id: "nightpatrol", name: "Night Patrol", icon: "🌙", actClass: 3, faction: .watch, cost: 9,
                    blurb: "The first bank of each day scores double. The morning shift is thorough.",
                    firstBankMultiplier: 2.0),

        TavernJoker(id: "curfewbell", name: "Curfew Bell", icon: "🔔", actClass: 3, faction: .watch, cost: 9,
                    blurb: "The Barred Door scores +35. Nobody in, nobody out.",
                    rowFlatBonuses: [.four: 35])
    ]

    static func joker(_ id: String) -> TavernJoker? {
        jokers.first { $0.id == id }
    }

    // ============================================================
    // 👥 PATRONS (15 gmarker characters)
    // Rename names/lines freely. id + imageName must stay.
    // ============================================================
    static let patrons: [TavernPatron] = [
        TavernPatron(id: "advisor", name: "Alderman Wobb", imageName: "gmarker_advisor",
                     arrivalLines: ["\"I have advised three mayors and none of them listened. YOU will listen.\"",
                                    "\"Officially, I am not here.\""]),
        TavernPatron(id: "bird", name: "Pike", imageName: "gmarker_bird",
                     arrivalLines: ["\"Lost my spear. Found this spear. Is it my spear?\"",
                                    "\"Guard duty is nine hours of nothing and one hour of goose.\""]),
        TavernPatron(id: "birdyo", name: "Squibb", imageName: "gmarker_birdyo",
                     arrivalLines: ["\"I would like ONE good day. One.\"",
                                    "\"The flock voted me out. It was unanimous. I voted too. Long story.\""]),
        TavernPatron(id: "bull", name: "Ironhilde", imageName: "gmarker_bull",
                     arrivalLines: ["\"The forge is cold and my patience is colder.\"",
                                    "\"I bent a horseshoe today. The wrong way. Don't ask.\""]),
        TavernPatron(id: "cyclops", name: "Boro", imageName: "gmarker_cyclops",
                     arrivalLines: ["\"Everyone says 'look on the bright side.' I only have the one eye.\"",
                                    "\"Carried a piano up a hill for a wizard. No piano lessons were offered.\""]),
        TavernPatron(id: "demon", name: "Imp #3", imageName: "gmarker_demon",
                     arrivalLines: ["\"I'm technically off the clock. Don't tell anyone downstairs.\"",
                                    "\"Temptation quota's due Friday and I've got NOTHING.\""]),
        TavernPatron(id: "dino", name: "Grum", imageName: "gmarker_dino",
                     arrivalLines: ["\"Everyone I knew is a fossil. Literally. It's been a week.\"",
                                    "\"They keep calling me 'legacy fauna' at the guild office.\""]),
        TavernPatron(id: "duck", name: "Mallory", imageName: "gmarker_duck",
                     arrivalLines: ["\"Say 'nice weather for it.' SAY IT. I dare you.\"",
                                    "\"The pond committee has FALLEN APART.\""]),
        TavernPatron(id: "fairy", name: "Fizz", imageName: "gmarker_fairy",
                     arrivalLines: ["\"I granted a wish and now everyone wants one. This is why we can't have nice things.\"",
                                    "\"Do you have anything in a thimble?\""]),
        TavernPatron(id: "fishman", name: "Brackish Pete", imageName: "gmarker_fishman",
                     arrivalLines: ["\"The sea is fine. I'M the problem. The sea said so.\"",
                                    "\"Somebody sold me a boat with a hole in it. On purpose, I think.\""]),
        TavernPatron(id: "fox", name: "Renna", imageName: "gmarker_fox",
                     arrivalLines: ["\"Someone sold me a map to a place that doesn't exist. I want to go there anyway.\"",
                                    "\"I'm not saying I was cheated at cards. I'm saying I know where he lives.\""]),
        TavernPatron(id: "goatguy", name: "Old Capric", imageName: "gmarker_goatguy",
                     arrivalLines: ["\"In my day the hills were steeper and we were grateful.\"",
                                    "\"I ate something I shouldn't have. The deed to my house.\""]),
        TavernPatron(id: "octo", name: "Salt", imageName: "gmarker_octo",
                     arrivalLines: ["\"Eight arms and not one person to hold. Anyway, what's the soup?\"",
                                    "\"I shook four hands at once at the guild meeting. It went badly.\""]),
        TavernPatron(id: "oldlady", name: "Mildred", imageName: "gmarker_oldlady",
                     arrivalLines: ["\"I've buried three husbands. Only two of them were dead. KIDDING.\"",
                                    "\"My knees predict rain, war, and disappointing grandchildren.\""]),
        TavernPatron(id: "puck", name: "Puck", imageName: "gmarker_puck",
                     arrivalLines: ["\"I came in here by accident six years ago and I've never left.\"",
                                    "\"The hat? The hat stays.\""])
    ]

    static func patron(_ id: String) -> TavernPatron {
        patrons.first { $0.id == id } ?? patrons[0]
    }

    // ============================================================
    // 🧳 THE CARAVAN (5 merchants — same trade, different faces)
    // One appears at random in each market.
    // ============================================================
    static let merchants: [TavernMerchant] = [
        TavernMerchant(id: "traveler", name: "Peddler Fen", imageName: "gmarker_traveler",
                       greeting: "\"Everything's for sale. Some of it's even mine.\""),
        TavernMerchant(id: "wizzy", name: "Peddler Moss", imageName: "gmarker_wizzy",
                       greeting: "\"Curios! Wonders! A stick! The stick is load-bearing, ask before touching.\""),
        TavernMerchant(id: "skull", name: "Peddler Grim", imageName: "gmarker_skull",
                       greeting: "\"Death is certain. Prices are negotiable.\""),
        TavernMerchant(id: "vamp", name: "Peddler Vell", imageName: "gmarker_vamp",
                       greeting: "\"I only deal after sundown. It's a skin thing.\""),
        TavernMerchant(id: "rooster", name: "Peddler Coq", imageName: "gmarker_rooster",
                       greeting: "\"Caravan special! Today only! (Everything is always the caravan special.)\"")
    ]

    static func merchant(_ id: String) -> TavernMerchant {
        merchants.first { $0.id == id } ?? merchants[0]
    }

    // ============================================================
    // 💬 PATRON REACTIONS — by bank tier. {name} = patron's name.
    // Tier is decided by the points actually scored.
    // ============================================================
    static func reactionLine(points: Int, patronName: String) -> String {
        let pool: [String]
        switch points {
        case ..<6:
            pool = ["{name} nods politely and leaves.",
                    "{name} looks at the counter, then at the door. The door wins.",
                    "{name} says nothing. Loudly.",
                    "{name} leaves a button as a tip. It is not a nice button."]
        case ..<16:
            pool = ["\"...thanks, I guess,\" says {name}.",
                    "{name} shrugs with most available shoulders.",
                    "{name} mutters something that was almost 'cheers.'",
                    "\"It's something,\" {name} admits."]
        case ..<45:
            pool = ["{name} is genuinely warmed and leaves a tip.",
                    "{name} laughs for the first time in a while.",
                    "\"Alright. ALRIGHT,\" says {name}, meaning it.",
                    "{name} promises to come back Tuesday. {name} means Thursday."]
        case ..<80:
            pool = ["{name}'s problem is actually solved. {name} tells a friend before even leaving.",
                    "{name} stands taller. The chair is relieved.",
                    "\"How did you KNOW?\" asks {name}. Enna didn't. Enna guessed.",
                    "{name} shakes Enna's hand for slightly too long."]
        case ..<120:
            pool = ["{name} is misty-eyed and vows to return. Daily. Possibly hourly.",
                    "{name} tries to pay double. Enna allows it.",
                    "{name} will retell this night for years, and it will get better every time.",
                    "{name} hugs a support beam on the way out. Close enough."]
        default:
            pool = ["Enna fixed {name}'s LIFE. {name} walks out taller, richer, and slightly luminous.",
                    "{name} weeps openly into the good napkins. Worth it.",
                    "Somewhere, a bard starts writing. {name} will be a chorus.",
                    "{name} leaves, comes back in, and leaves again just to feel it twice."]
        }
        let line = pool.randomElement() ?? pool[0]
        return line.replacingOccurrences(of: "{name}", with: patronName)
    }

    // ============================================================
    // 📕 THE 21 ENDINGS — flavor text VERBATIM from the design doc
    // ============================================================
    static let endings: [TavernEnding] = [

        // ---- ACT 1 — Enna, Personally ----
        TavernEnding(id: "act1_1", act: 1, title: "The Nap of No Return", kind: .fail,
                     flavor: "Enna lies down behind a hay bale \"for one minute.\" Three weeks pass. A bird nests in her hair. The bird also seems tired."),
        TavernEnding(id: "act1_2", act: 1, title: "Gainful Unemployment", kind: .fail,
                     flavor: "Broke, she takes a job at a rival tavern. The uniform includes a novelty hat. The hat has a name. The hat's name is Gerald."),
        TavernEnding(id: "act1_3", act: 1, title: "Audited", kind: .collectible,
                     flavor: "Nobody gets that rich honestly, says the man from the Guild of Counting, producing a quill in a way that can only be described as threatening."),
        TavernEnding(id: "act1_4", act: 1, title: "Banned From Her Own Story", kind: .fail,
                     flavor: "The local bard's new song about her has seventeen verses and zero flattering ones. She leaves town until it stops charting."),
        TavernEnding(id: "act1_5", act: 1, title: "Beloved (Derogatory)", kind: .collectible,
                     flavor: "Everyone wants a favor. EVERYONE. She is godmother to forty children. She flees at dawn."),
        TavernEnding(id: "act1_6", act: 1, title: "She Knows Too Much", kind: .collectible,
                     flavor: "Three cloaked figures, one unmarked wagon, zero explanations. The wagon has surprisingly comfortable seating, which is somehow worse."),
        TavernEnding(id: "act1_7", act: 1, title: "★ Terminally Out of the Loop", kind: .promotion,
                     flavor: "Enna is the last person in town to learn the old tavern is for sale. Furious at being uninformed, she buys it out of pure spite."),

        // ---- ACT 2 — The Tavern ----
        TavernEnding(id: "act2_1", act: 2, title: "Repossessed by a Very Polite Bailiff", kind: .fail,
                     flavor: "He apologizes while carrying out the bar. He apologizes while carrying out Enna. Lovely man. Terrible day."),
        TavernEnding(id: "act2_2", act: 2, title: "The Soup Is Just Hot Water Now", kind: .fail,
                     flavor: "A regular asks what's in the soup. Enna says \"broth.\" He asks what's in the broth. Enna closes for renovations."),
        TavernEnding(id: "act2_3", act: 2, title: "Echo Tavern", kind: .fail,
                     flavor: "The only patron left is an echo. It's a decent tipper but the conversation is repetitive."),
        TavernEnding(id: "act2_4", act: 2, title: "Fire Hazard", kind: .collectible,
                     flavor: "So popular the Watch shuts it down for occupancy violations. The occupancy sign says 40. The room contains, conservatively, a festival."),
        TavernEnding(id: "act2_5", act: 2, title: "The Chair Incident", kind: .collectible,
                     flavor: "Nobody can explain the chair. Or the chicken behind the bar. Or why the chicken has a tab."),
        TavernEnding(id: "act2_6", act: 2, title: "Alphabetized Into Oblivion", kind: .collectible,
                     flavor: "The tavern is so organized it has no soul. The regulars leave for somewhere with \"atmosphere,\" by which they mean a smell."),
        TavernEnding(id: "act2_7", act: 2, title: "★ The Expansion", kind: .promotion,
                     flavor: "Enna buys the building next door. The building next door, it turns out, came with politics in the walls."),

        // ---- ACT 3 — The City Arrives ----
        TavernEnding(id: "act3_1", act: 3, title: "Union Trouble", kind: .fail,
                     flavor: "Every craftsman in the city simultaneously remembers they're owed a favor. The taps are dismantled \"for inspection\" indefinitely."),
        TavernEnding(id: "act3_2", act: 3, title: "Hostile Takeover (Friendly)", kind: .collectible,
                     flavor: "The Guild absorbs the tavern as Chapterhouse #9. Enna is given a ceremonial title and a real mop."),
        TavernEnding(id: "act3_3", act: 3, title: "The Carriage", kind: .fail,
                     flavor: "An offended noble parks his carriage across the entrance. Forever. It has diplomatic immunity. So does the horse."),
        TavernEnding(id: "act3_4", act: 3, title: "Gentrified", kind: .collectible,
                     flavor: "The tavern is now a wine bar called Tâverne. The soup is deconstructed. The regulars are gone. The circumflex cost forty gold."),
        TavernEnding(id: "act3_5", act: 3, title: "Frequent Flier", kind: .fail,
                     flavor: "Raided weekly for crimes that haven't technically been invented yet. One charge is just the word \"vibes.\""),
        TavernEnding(id: "act3_6", act: 3, title: "The Precinct", kind: .collectible,
                     flavor: "So many guards drink here it becomes the de facto Watch house. The criminals — her best customers — leave excellent, regretful reviews."),
        TavernEnding(id: "act3_7", act: 3, title: "★ The Quiet Pint", kind: .promotion,
                     flavor: "One night, a guildsman, a noble, a guard, and a pickpocket all drink at the same bar, and nothing happens. No fight. No scheme. Just a quiet pint. Enna wipes the counter and smiles.")
    ]

    static func ending(_ id: String) -> TavernEnding? {
        endings.first { $0.id == id }
    }

    // ============================================================
    // Generic fallback texts (used only when no numbered ending fits)
    // ============================================================
    static let genericFailTexts: [Int: String] = [
        1: "The week wins. Enna closes the shutters early and doesn't open them again.",
        2: "The rent, the stock, the everything. The Rusty Goose goes quiet.",
        3: "The city asked for more than one tavern could give. This time."
    ]

    static let genericVictoryText =
        "The Rusty Goose endures. The festival ends, the town exhales, and Enna — against several written predictions — is still standing behind her own bar."
}
