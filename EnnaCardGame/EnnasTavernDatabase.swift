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
        TavernRow(id: .nod,           name: "High Card",       requirement: "Anything at all",        baseValue: 8,   worksWithDice: true,  worksWithCards: true,  repeatable: true),
        TavernRow(id: .pair,          name: "Pair",            requirement: "Two matching",                   baseValue: 15,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .twoPair,       name: "2 Pair",          requirement: "Two sets of two",               baseValue: 32,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .trips,         name: "3 of a Kind",     requirement: "Three matching",        baseValue: 48,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .straight,      name: "Straight",        requirement: "Run of 5",    baseValue: 85,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .flush,         name: "Flush",           requirement: "5 of one suit",  baseValue: 95,  worksWithDice: false, worksWithCards: true,  repeatable: false),
        TavernRow(id: .fullHouse,     name: "Full House",      requirement: "3 + 2",     baseValue: 115,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .four,          name: "4 of a Kind",     requirement: "Four matching",         baseValue: 160,  worksWithDice: true,  worksWithCards: true,  repeatable: false),
        TavernRow(id: .five,          name: "5 of a Kind",     requirement: "Five matching",         baseValue: 150, worksWithDice: true,  worksWithCards: false, repeatable: false),
        TavernRow(id: .straightFlush, name: "Straight Flush",  requirement: "Run of 5, one suit",         baseValue: 260, worksWithDice: false, worksWithCards: true,  repeatable: false),
        TavernRow(id: .royal,         name: "Royal Flush",     requirement: "10-J-Q-K-A, one suit",       baseValue: 400, worksWithDice: false, worksWithCards: true,  repeatable: false)
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

    /// Works on ANY number of cards (5 or the new 7-card deal): a hand
    /// qualifies if any five of the cards form it.
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
        if maxCount >= 3 && pairsOrBetter >= 2 { out.insert(.fullHouse) }

        let suitGroups = Dictionary(grouping: cards, by: { $0.suit })
        if suitGroups.values.contains(where: { $0.count >= 5 }) { out.insert(.flush) }

        func hasRun(_ rankSet: Set<Int>) -> Bool {
            var r = rankSet
            if r.contains(14) { r.insert(1) }   // ace low for the wheel
            for a in 1...10 where Set(a...(a + 4)).isSubset(of: r) { return true }
            return false
        }
        if hasRun(Set(ranks)) { out.insert(.straight) }
        for (_, suited) in suitGroups where suited.count >= 5 {
            let sr = Set(suited.map { $0.rank })
            if hasRun(sr) { out.insert(.straightFlush) }
            if Set([10, 11, 12, 13, 14]).isSubset(of: sr) { out.insert(.royal) }
        }
        return out
    }

    // ============================================================
    // (jokers retired in v4 — skills replaced them; see the skills extension below)


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
        TavernEnding(id: "act1_1", act: 1, title: "Closing Time", kind: .fail,
                     flavor: "A customer got angry & Enna punched him."),
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


// ============================================================
// 🎯 NEED LINES — what customers say when they sit down (v4)
// ============================================================
extension EnnasTavernDatabase {

    static let needLines: [TavernNeed: [String]] = [
        .food: [
            "Famished. Need some stew.",
            "Whatever's in the pot. All of it.",
            "I could eat the table. Feed me first.",
            "Something hot. I've been walking since dawn.",
            "The smell dragged me in. Don't make it a lie."
        ],
        .tavern: [
            "Need a bed for the night.",
            "A room. Any room. A dry corner, even.",
            "One tall ale and a place to fall over.",
            "Somewhere to put my boots up till morning.",
            "The rain won. I surrender. Lodging, please."
        ],
        .support: [
            "I'm feeling lonely.",
            "Rough week. Just... talk to me a minute.",
            "Everyone I know is somewhere else tonight.",
            "I don't need anything. That's a lie. Sit with me.",
            "My dog left with the tinker. My DOG."
        ]
    ]

    static func needLine(for need: TavernNeed) -> String {
        needLines[need]?.randomElement() ?? ""
    }

    /// 😒 What customers say when served something they DIDN'T ask for.
    static let mismatchLines: [String] = [
        "Oh... uh, thanks, I guess.",
        "Not what I really wanted, but I'll take it.",
        "This is... not what I said. It's fine. It's fine.",
        "Hm. Well. It's warm, at least.",
        "I'll eat it. I won't enjoy it. But I'll eat it.",
        "Did you hear ANY of what I said?",
        "Sure. Why not. Nothing means anything.",
        "The thought was... adjacent. Thanks."
    ]
    static func mismatchLine() -> String { mismatchLines.randomElement() ?? "" }

    /// 🍺 Enna's reply, spoken under the customer's ask.
    static let ennaLines: [TavernNeed: [String]] = [
        .food: [
            "The pot's on. Let's see what the table gives me.",
            "Hungry ones are easy. Feeding them well is the trick.",
            "Stew I can do. Stew I can always do.",
            "One hot meal, coming up — if the dice agree.",
            "You'll leave heavier than you came. Promise."
        ],
        .tavern: [
            "I've got a room. Whether it's YOUR room depends on the roll.",
            "Beds upstairs, ale down here. Let's earn you one.",
            "The good room has a window. Roll well and it's yours.",
            "Lodging, is it? The house will see what it can do.",
            "Boots off at the door. Let me sort the rest."
        ],
        .support: [
            "Sit. The first kind word is free.",
            "Lonely's just thirsty with better manners. I've got you.",
            "I've heard worse weeks than yours. Pull up a stool.",
            "Company's on the menu tonight. Let me plate it right.",
            "You came to the right bar. They always do."
        ]
    ]

    static func ennaLine(for need: TavernNeed) -> String {
        ennaLines[need]?.randomElement() ?? ""
    }

    // ============================================================
    // 🎓 SKILLS v2 — the night-school curriculum (15).
    // Multipliers are the whole game now; nothing here is tiny.
    // ============================================================
    static let skills: [TavernSkill] = [
        // ---- multiplier anchors ----
        TavernSkill(id: "warmSmile", name: "Warm Smile", school: .support, cost: 3,
                    blurb: "Matched serves hit +1 extra multiplier.",
                    multOnMatch: 1),
        TavernSkill(id: "keenEar", name: "Keen Ear", school: .support, cost: 5,
                    blurb: "+1 multiplier on EVERY serve, matched or not.",
                    multEvery: 1),
        TavernSkill(id: "hearthCook", name: "Hearth Cook", school: .food, cost: 3,
                    blurb: "Any food-icon dish serves at +1 multiplier.",
                    multForNeed: [.food: 1]),
        TavernSkill(id: "cellarKeys", name: "Cellar Keys", school: .tavern, cost: 3,
                    blurb: "Any tavern-icon dish serves at +1 multiplier.",
                    multForNeed: [.tavern: 1]),
        TavernSkill(id: "goodListener", name: "Good Listener", school: .support, cost: 3,
                    blurb: "Any support-icon dish serves at +1 multiplier.",
                    multForNeed: [.support: 1]),
        // ---- scaling engines ----
        TavernSkill(id: "regulars", name: "The Regulars", school: .tavern, cost: 4,
                    blurb: "Every 3 matches this run: +1 multiplier, permanently.",
                    scalingMatchStep: 3),
        TavernSkill(id: "showmanship", name: "Showmanship", school: .food, cost: 4,
                    blurb: "+1 multiplier for every hand you level up today.",
                    scalingLevelUps: true),
        // ---- gamble deals ----
        TavernSkill(id: "fireKitchen", name: "Fire in the Kitchen", school: .food, cost: 4,
                    blurb: "Mismatches score ZERO. Matches hit +2 extra multiplier.",
                    multOnMatch: 2, mismatchZero: true),
        TavernSkill(id: "nightcap", name: "Nightcap", school: .tavern, cost: 3,
                    blurb: "Serves made on an empty tank (0 rolls left) get +2 multiplier.",
                    lastCallMult: 2),
        // ---- conditional roll triggers · DICE ONLY ----
        TavernSkill(id: "oddCrowd", name: "Odd Crowd", school: .support, cost: 2,
                    blurb: "Serve five DIFFERENT values: +1 roll back.",
                    mode: .dice, rollTrigger: .allDifferent),
        TavernSkill(id: "fullPour", name: "Full Pour", school: .food, cost: 2,
                    blurb: "Dice summing exactly 20: +1 roll back.",
                    mode: .dice, rollTrigger: .luckySum),
        TavernSkill(id: "bookends", name: "Bookends", school: .tavern, cost: 2,
                    blurb: "Serve holding both a 1 and a 6: +1 roll back.",
                    mode: .dice, rollTrigger: .bookends),
        // ---- conditional roll triggers · CARDS ONLY ----
        TavernSkill(id: "sevenKinds", name: "Seven Kinds of Trouble", school: .support, cost: 2,
                    blurb: "Serve with all SEVEN ranks different: +1 roll back.",
                    mode: .cards, rollTrigger: .allDifferent),
        TavernSkill(id: "aceService", name: "Ace of Service", school: .food, cost: 2,
                    blurb: "Serve while holding an Ace: +1 roll back.",
                    mode: .cards, rollTrigger: .luckySum),
        TavernSkill(id: "spreadEagle", name: "Spread Eagle", school: .tavern, cost: 2,
                    blurb: "Serve holding both a 2 and an Ace: +1 roll back.",
                    mode: .cards, rollTrigger: .bookends),
        // ---- last call (both tables) ----
        TavernSkill(id: "embers", name: "Embers", school: .food, cost: 3,
                    blurb: "Serve on your very last roll: +2 rolls tomorrow morning.",
                    rollTrigger: .lastRollFuel),
        // ---- economy ----
        TavernSkill(id: "luckyCoin", name: "Lucky Coin", school: .support, cost: 2,
                    blurb: "It keeps turning up. +1 token every night.",
                    bonusTokens: 1),
        TavernSkill(id: "thriftyBooks", name: "Thrifty Books", school: .tavern, cost: 3,
                    blurb: "The ledger tightens. Operating costs −10%.",
                    costCut: 0.10),
    ]

    static func skill(_ id: String) -> TavernSkill? {
        skills.first { $0.id == id }
    }
}
