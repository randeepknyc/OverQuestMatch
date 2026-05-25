// CardDatabase.swift
// ============================================================
// THIS IS THE FILE YOU EDIT TO ADD CARDS AND CHANGE THE GAME
// ============================================================
//
// HOW TO ADD A CARD:
// 1. Copy any existing Card(...) block below
// 2. Change the id to something unique (no spaces, use underscores)
// 3. Fill in speaker, text, leftChoice, rightChoice
// 4. Set the meter effects (which meters change, by how much)
// 5. Add characterImageName if you have art for this character
//
// NUMBERS GUIDE:
//   +2  = small, barely noticed
//   +5  = meaningful moment
//   +10 = significant decision
//   +15 = life-changing event
//   (same scale negative)
//
// ART GUIDE:
//   characterImageName: "char_merchant"
//   → Add an image called "char_merchant" to Assets.xcassets
//   → Leave out characterImageName if no art yet (shows placeholder)
//
// ============================================================

import Foundation

struct CardDatabase {

    // ============================================================
    // ACT UNLOCK SETTINGS
    // Change these numbers to control when Acts 2 and 3 unlock
    // ============================================================
    static let act2UnlocksAfterCards: Int = 10
    static let act3UnlocksAfterCards: Int = 25

    // ============================================================
    // STARTING METER VALUES (0–100)
    // This is where Enna starts each run
    // ============================================================
    static let startingValues: [MeterType: Int] = [
        .resolve:      60,
        .personalCoin: 45,
        .reputation:   50,
        .secrets:      10,
        .tavernCoin:   55,
        .regulars:     50,
        .stock:        60,
        .order:        55,
        .guild:        50,
        .nobles:       50,
        .commonFolk:   50,
        .watch:        50
    ]

    // ============================================================
    // THRESHOLD EVENTS
    // What fires when a meter hits an extreme value
    // ============================================================
    static let thresholds: [ThresholdEvent] = [

        // ---- ACT 1 ----
        ThresholdEvent(
            meter: .resolve, value: 10, isHigh: false,
            message: "Enna can't carry this anymore. The weight of it all is too much.",
            isGameOver: true
        ),
        ThresholdEvent(
            meter: .reputation, value: 80, isHigh: true,
            message: "Word of Enna's reliability has spread through the quarter. New faces are finding her door."
        ),
        ThresholdEvent(
            meter: .reputation, value: 15, isHigh: false,
            message: "People have stopped trusting her. She can see it in how they look away."
        ),
        ThresholdEvent(
            meter: .secrets, value: 60, isHigh: true,
            message: "She knows too much now. A figure in a dark cloak has started watching from across the street."
        ),

        // ---- ACT 2 ----
        ThresholdEvent(
            meter: .tavernCoin, value: 10, isHigh: false,
            message: "The tavern is nearly broke. Creditors will come soon if something doesn't change."
        ),
        ThresholdEvent(
            meter: .regulars, value: 15, isHigh: false,
            message: "The common room is empty most nights. The fire feels wasted."
        ),
        ThresholdEvent(
            meter: .order, value: 10, isHigh: false,
            message: "A brawl breaks out. Chairs broken, blood on the floor. The Watch takes notice.",
            injectCardID: "brawl_aftermath"
        ),

        // ---- ACT 3 ----
        ThresholdEvent(
            meter: .guild, value: 80, isHigh: true,
            message: "The Guildmaster sends word. They want a private meeting."
        ),
        ThresholdEvent(
            meter: .guild, value: 15, isHigh: false,
            message: "The Guild has declared her an outsider. Suppliers are avoiding her."
        ),
        ThresholdEvent(
            meter: .commonFolk, value: 15, isHigh: false,
            message: "The neighborhood has turned cold. People mutter when she passes."
        ),
        ThresholdEvent(
            meter: .watch, value: 15, isHigh: false,
            message: "Three officers arrive at the door. This is not a friendly visit.",
            injectCardID: "watch_raid"
        )
    ]

    // ============================================================
    // ALL CARDS
    // Add your cards here. One Card(...) block per card.
    // ============================================================
    static let allCards: [Card] = [

        // ======================================================
        // ACT 1 — ENNA PERSONAL
        // ======================================================

        Card(
            id: "merchant_gossip",
            act: 1,
            speaker: "A traveling merchant",
            text: "\"I know things about the old innkeeper. Things that might be worth coin to the right people. Or to you, if you're curious.\"",
            leftChoice: "\"I don't deal in gossip.\"",
            rightChoice: "\"Tell me. What's your price?\"",
            leftEffects: [
                MeterEffect(meter: .resolve,     value: +2),
                MeterEffect(meter: .reputation,  value: +2)
            ],
            rightEffects: [
                MeterEffect(meter: .personalCoin, value: -5),
                MeterEffect(meter: .secrets,      value: +8),
                MeterEffect(meter: .reputation,   value: -2)
            ],
            characterImageName: "char_merchant"
        ),

        Card(
            id: "late_customer",
            act: 1,
            speaker: "Past closing time",
            text: "A figure stands in the rain, soaked through, not quite meeting your eyes. \"Please. Just somewhere dry for the night.\"",
            leftChoice: "\"We're closed.\"",
            rightChoice: "Let them in quietly.",
            leftEffects: [
                MeterEffect(meter: .resolve, value: -3)
            ],
            rightEffects: [
                MeterEffect(meter: .resolve,      value: +3),
                MeterEffect(meter: .reputation,   value: +4),
                MeterEffect(meter: .personalCoin, value: -2)
            ],
            characterImageName: "char_stranger"
        ),

        Card(
            id: "debt_collector",
            act: 1,
            speaker: "A man in fine boots",
            text: "\"The previous owner left debts. Legally, they transferred with the property. We can arrange a payment schedule, or—\" He smiles. \"—you could do us a small favor instead.\"",
            leftChoice: "\"Name the payment schedule.\"",
            rightChoice: "\"What kind of favor?\"",
            leftEffects: [
                MeterEffect(meter: .personalCoin, value: -12),
                MeterEffect(meter: .reputation,   value: +3)
            ],
            rightEffects: [
                MeterEffect(meter: .secrets,    value: +5),
                MeterEffect(meter: .reputation, value: -3),
                MeterEffect(meter: .resolve,    value: -4)
            ],
            characterImageName: "char_debt_collector",
            isOnce: true
        ),

        Card(
            id: "local_gossip",
            act: 1,
            speaker: "A regular customer",
            text: "She leans in, voice low. \"Did you hear about the Miller place? The whole family — gone. Overnight.\" She taps the side of her nose. \"No one's saying anything, but everyone's thinking it.\"",
            leftChoice: "\"I'd rather not know.\"",
            rightChoice: "\"Tell me everything.\"",
            leftEffects: [
                MeterEffect(meter: .resolve, value: +2)
            ],
            rightEffects: [
                MeterEffect(meter: .secrets,    value: +6),
                MeterEffect(meter: .reputation, value: +2)
            ],
            characterImageName: "char_regular_woman"
        ),

        Card(
            id: "old_friend",
            act: 1,
            speaker: "A face from before",
            text: "Someone from another life. They look well. Better than you. \"I heard you'd settled here. I almost didn't believe it.\" There's something they're not saying.",
            leftChoice: "Keep it brief.",
            rightChoice: "\"It's been too long. Sit down.\"",
            leftEffects: [
                MeterEffect(meter: .resolve, value: -2),
                MeterEffect(meter: .secrets, value: +3)
            ],
            rightEffects: [
                MeterEffect(meter: .resolve,      value: +5),
                MeterEffect(meter: .personalCoin, value: -3)
            ],
            characterImageName: "char_old_friend"
        ),

        Card(
            id: "the_letter",
            act: 1,
            speaker: "A sealed envelope",
            text: "Someone has slipped a letter under the door. No name on the outside. The seal is unfamiliar — a bird with no wings.",
            leftChoice: "Burn it unopened.",
            rightChoice: "Read it.",
            leftEffects: [
                MeterEffect(meter: .resolve, value: +3)
            ],
            rightEffects: [
                MeterEffect(meter: .secrets,    value: +10),
                MeterEffect(meter: .resolve,    value: -3),
                MeterEffect(meter: .reputation, value: +2)
            ],
            isOnce: true
        ),

        Card(
            id: "cold_night",
            act: 1,
            speaker: "Midwinter evening",
            text: "The fire is low and there's no money for more wood. A young boy from down the street keeps walking past the window, pretending not to look in.",
            leftChoice: "Let him keep walking.",
            rightChoice: "Wave him in.",
            leftEffects: [
                MeterEffect(meter: .personalCoin, value: +1),
                MeterEffect(meter: .resolve,      value: -2)
            ],
            rightEffects: [
                MeterEffect(meter: .resolve,      value: +4),
                MeterEffect(meter: .reputation,   value: +3),
                MeterEffect(meter: .personalCoin, value: -3)
            ]
        ),

        Card(
            id: "high_secrets_visitor",
            act: 1,
            speaker: "A quiet woman",
            text: "She's been sitting in the corner for two hours, nursing a single drink. When the last other customer leaves, she comes to the bar. \"You know things,\" she says. Not a question.",
            leftChoice: "\"I know nothing.\"",
            rightChoice: "\"Depends what you're looking for.\"",
            leftEffects: [
                MeterEffect(meter: .reputation, value: +4),
                MeterEffect(meter: .resolve,    value: +2)
            ],
            rightEffects: [
                MeterEffect(meter: .secrets,      value: +8),
                MeterEffect(meter: .personalCoin, value: +10),
                MeterEffect(meter: .resolve,      value: -4)
            ],
            condition: CardCondition(meter: .secrets, minimum: 30)
        ),

        // ======================================================
        // ACT 2 — TAVERN VITALS
        // ======================================================

        Card(
            id: "supplier_deal",
            act: 2,
            speaker: "The grain merchant",
            text: "\"Locked-in price for the season. Cheaper than market rate. But I need payment upfront, and exclusivity — you don't buy from anyone else.\"",
            leftChoice: "\"I prefer flexibility.\"",
            rightChoice: "\"Deal. Here's the coin.\"",
            leftEffects: [
                MeterEffect(meter: .stock, value: -3)
            ],
            rightEffects: [
                MeterEffect(meter: .tavernCoin, value: -15),
                MeterEffect(meter: .stock,      value: +20),
                MeterEffect(meter: .order,      value: +5)
            ],
            characterImageName: "char_merchant"
        ),

        Card(
            id: "trouble_table",
            act: 2,
            speaker: "Your serving hand",
            text: "\"That table's been at it for an hour. They're going to start trouble if someone doesn't step in. But they're spending well.\"",
            leftChoice: "\"Cut them off.\"",
            rightChoice: "\"Leave them. It's coin.\"",
            leftEffects: [
                MeterEffect(meter: .order,      value: +8),
                MeterEffect(meter: .regulars,   value: -3),
                MeterEffect(meter: .tavernCoin, value: -5)
            ],
            rightEffects: [
                MeterEffect(meter: .tavernCoin, value: +8),
                MeterEffect(meter: .order,      value: -10),
                MeterEffect(meter: .regulars,   value: -5)
            ],
            characterImageName: "char_staff"
        ),

        Card(
            id: "brawl_aftermath",
            act: 2,
            speaker: "The morning after",
            text: "Two chairs broken, a window cracked. The Watch left a notice on the door. The regulars are nervous. The staff are shaken.",
            leftChoice: "Close for the day, make repairs.",
            rightChoice: "Open anyway. Can't afford to close.",
            leftEffects: [
                MeterEffect(meter: .tavernCoin, value: -10),
                MeterEffect(meter: .order,      value: +10),
                MeterEffect(meter: .regulars,   value: +5),
                MeterEffect(meter: .resolve,    value: +4)
            ],
            rightEffects: [
                MeterEffect(meter: .tavernCoin, value: +3),
                MeterEffect(meter: .reputation, value: -5),
                MeterEffect(meter: .resolve,    value: -5)
            ],
            isOnce: true
        ),

        Card(
            id: "renovation_offer",
            act: 2,
            speaker: "A carpenter",
            text: "\"That back room's been empty since I don't know when. I could convert it — private dining, or lodgings. Another income stream. It'll cost you, but.\"",
            leftChoice: "\"Not now.\"",
            rightChoice: "\"Let's talk numbers.\"",
            leftEffects: [],
            rightEffects: [
                MeterEffect(meter: .tavernCoin, value: -18),
                MeterEffect(meter: .regulars,   value: +10),
                MeterEffect(meter: .reputation, value: +8)
            ],
            characterImageName: "char_carpenter",
            condition: CardCondition(meter: .tavernCoin, minimum: 60),
            isOnce: true
        ),

        Card(
            id: "rival_tavern",
            act: 2,
            speaker: "A concerned regular",
            text: "\"Have you seen what they're doing down the street? New place. Half the price, twice the noise. Half our crowd was there last night.\"",
            leftChoice: "\"Let them have it.\"",
            rightChoice: "\"We need to do something different.\"",
            leftEffects: [
                MeterEffect(meter: .regulars,   value: -5),
                MeterEffect(meter: .tavernCoin, value: -5)
            ],
            rightEffects: [
                MeterEffect(meter: .tavernCoin, value: -8),
                MeterEffect(meter: .regulars,   value: +8),
                MeterEffect(meter: .reputation, value: +5)
            ]
        ),

        Card(
            id: "festival_prep",
            act: 2,
            speaker: "Midsummer approaching",
            text: "The festival is two weeks out. You could stock up heavy and make serious coin, or keep lean and avoid a loss if turnout is low.",
            leftChoice: "Play it safe, stock light.",
            rightChoice: "Stock up, bet on the crowd.",
            leftEffects: [
                MeterEffect(meter: .stock,    value: -5),
                MeterEffect(meter: .resolve,  value: +2)
            ],
            rightEffects: [
                MeterEffect(meter: .tavernCoin, value: -12),
                MeterEffect(meter: .stock,      value: +15),
                MeterEffect(meter: .regulars,   value: +8)
            ]
        ),

        // ======================================================
        // ACT 3 — FACTIONS
        // ======================================================

        Card(
            id: "guild_messenger",
            act: 3,
            speaker: "A Guild runner",
            text: "A boy in Guild colors slides an envelope across the bar without a word and leaves. Inside: an invitation to a private meeting. No details given.",
            leftChoice: "Ignore it.",
            rightChoice: "Send word you'll attend.",
            leftEffects: [
                MeterEffect(meter: .guild,      value: -8),
                MeterEffect(meter: .commonFolk, value: +4)
            ],
            rightEffects: [
                MeterEffect(meter: .guild,   value: +10),
                MeterEffect(meter: .secrets, value: +5)
            ],
            characterImageName: "char_guild_runner"
        ),

        Card(
            id: "noble_patron",
            act: 3,
            speaker: "Lady Varenthis",
            text: "She arrives with two guards and no warning. \"I find myself requiring a discreet venue for certain gatherings. I'd make it very worth your while.\" Her eyes move around the room, pricing everything.",
            leftChoice: "\"I'm afraid we're fully booked.\"",
            rightChoice: "\"I'm sure we can accommodate.\"",
            leftEffects: [
                MeterEffect(meter: .nobles,     value: -8),
                MeterEffect(meter: .commonFolk, value: +6),
                MeterEffect(meter: .resolve,    value: +3)
            ],
            rightEffects: [
                MeterEffect(meter: .tavernCoin, value: +20),
                MeterEffect(meter: .nobles,     value: +12),
                MeterEffect(meter: .commonFolk, value: -10),
                MeterEffect(meter: .resolve,    value: -4)
            ],
            characterImageName: "char_noble_lady"
        ),

        Card(
            id: "watch_raid",
            act: 3,
            speaker: "Watch Captain Aldric",
            text: "Three officers. A warrant. \"We've had reports. Disorderly conduct, possible harboring. You'll need to come with us, and the premises will be inspected.\"",
            leftChoice: "\"I'll cooperate fully.\"",
            rightChoice: "\"I'd like to see that warrant more carefully.\"",
            leftEffects: [
                MeterEffect(meter: .watch,      value: +5),
                MeterEffect(meter: .order,      value: -5),
                MeterEffect(meter: .tavernCoin, value: -8),
                MeterEffect(meter: .resolve,    value: -6)
            ],
            rightEffects: [
                MeterEffect(meter: .watch,      value: -10),
                MeterEffect(meter: .reputation, value: +5),
                MeterEffect(meter: .guild,      value: +3)
            ],
            characterImageName: "char_watch_captain",
            isOnce: true
        ),

        Card(
            id: "faction_tension",
            act: 3,
            speaker: "A tense evening",
            text: "Both a Guild man and a noble's aide are in the tavern at the same time. They've noticed each other. The room is getting uncomfortable. Everyone's watching you.",
            leftChoice: "Ask the Guild man to leave.",
            rightChoice: "Ask the aide to leave.",
            leftEffects: [
                MeterEffect(meter: .guild,      value: -8),
                MeterEffect(meter: .nobles,     value: +6),
                MeterEffect(meter: .commonFolk, value: -4)
            ],
            rightEffects: [
                MeterEffect(meter: .nobles,     value: -8),
                MeterEffect(meter: .guild,      value: +6),
                MeterEffect(meter: .commonFolk, value: +4)
            ]
        )
    ]

    // Helper — find a card by its ID
    static func card(id: String) -> Card? {
        allCards.first { $0.id == id }
    }
}
