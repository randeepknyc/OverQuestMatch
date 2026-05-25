// CardGameModels.swift
// EnnaCardGame — all data types for the card game
// No need to edit this file — edit CardDatabase.swift instead

import SwiftUI

// ============================================================
// METER TYPE
// All meters in the game. Each runs from 0 to 100.
// ============================================================
enum MeterType: String, CaseIterable, Codable {

    // Act 1 — Enna personal
    case resolve       = "Resolve"
    case personalCoin  = "Coin"
    case reputation    = "Reputation"
    case secrets       = "Secrets"

    // Act 2 — Tavern vitals
    case tavernCoin = "Tavern Coin"
    case regulars   = "Regulars"
    case stock      = "Stock"
    case order      = "Order"

    // Act 3 — Factions
    case guild      = "The Guild"
    case nobles     = "Nobles"
    case commonFolk = "Common Folk"
    case watch      = "The Watch"

    // Which act unlocks this meter
    var act: Int {
        switch self {
        case .resolve, .personalCoin, .reputation, .secrets: return 1
        case .tavernCoin, .regulars, .stock, .order:         return 2
        case .guild, .nobles, .commonFolk, .watch:           return 3
        }
    }

    // SF Symbol icon (shown in meter panel)
    var icon: String {
        switch self {
        case .resolve:      return "heart.fill"
        case .personalCoin: return "dollarsign.circle.fill"
        case .reputation:   return "star.fill"
        case .secrets:      return "eye.slash.fill"
        case .tavernCoin:   return "bag.fill"
        case .regulars:     return "person.3.fill"
        case .stock:        return "shippingbox.fill"
        case .order:        return "checkmark.shield.fill"
        case .guild:        return "hammer.fill"
        case .nobles:       return "crown.fill"
        case .commonFolk:   return "house.fill"
        case .watch:        return "shield.fill"
        }
    }

    // Color used for the meter bar
    var color: Color {
        switch self {
        case .resolve:      return Color(red: 0.85, green: 0.25, blue: 0.25)
        case .personalCoin: return Color(red: 0.90, green: 0.75, blue: 0.20)
        case .reputation:   return Color(red: 0.95, green: 0.55, blue: 0.10)
        case .secrets:      return Color(red: 0.60, green: 0.25, blue: 0.85)
        case .tavernCoin:   return Color(red: 0.25, green: 0.70, blue: 0.30)
        case .regulars:     return Color(red: 0.25, green: 0.50, blue: 0.85)
        case .stock:        return Color(red: 0.65, green: 0.45, blue: 0.25)
        case .order:        return Color(red: 0.25, green: 0.80, blue: 0.80)
        case .guild:        return Color(red: 0.90, green: 0.55, blue: 0.10)
        case .nobles:       return Color(red: 0.90, green: 0.80, blue: 0.20)
        case .commonFolk:   return Color(red: 0.50, green: 0.80, blue: 0.35)
        case .watch:        return Color(red: 0.35, green: 0.50, blue: 0.90)
        }
    }
}

// ============================================================
// METER EFFECT
// How one swipe choice changes one meter value.
// Use positive numbers to increase, negative to decrease.
// ============================================================
struct MeterEffect {
    let meter: MeterType
    let value: Int      // e.g. +5 to raise, -10 to lower
}

// ============================================================
// CARD CONDITION
// A card only appears when this condition is true.
// Leave out of a card definition if it should always appear.
// ============================================================
struct CardCondition {
    let meter: MeterType
    let minimum: Int?   // Meter must be AT LEAST this number
    let maximum: Int?   // Meter must be NO MORE THAN this number

    init(meter: MeterType, minimum: Int? = nil, maximum: Int? = nil) {
        self.meter   = meter
        self.minimum = minimum
        self.maximum = maximum
    }
}

// ============================================================
// CARD
// One card. Fill these out in CardDatabase.swift.
// ============================================================
struct Card: Identifiable {
    let id: String
    let act: Int                     // 1, 2, or 3
    let speaker: String              // Who is speaking, or scene description
    let text: String                 // The card body text
    let leftChoice: String           // Swipe-left label
    let rightChoice: String          // Swipe-right label
    let leftEffects: [MeterEffect]   // Meter changes on swipe left
    let rightEffects: [MeterEffect]  // Meter changes on swipe right
    let characterImageName: String?  // Asset name in Assets.xcassets (optional)
    let condition: CardCondition?    // Only show if condition met (optional)
    let isOnce: Bool                 // If true, this card only appears once per run

    init(
        id: String,
        act: Int = 1,
        speaker: String,
        text: String,
        leftChoice: String,
        rightChoice: String,
        leftEffects: [MeterEffect] = [],
        rightEffects: [MeterEffect] = [],
        characterImageName: String? = nil,
        condition: CardCondition? = nil,
        isOnce: Bool = false
    ) {
        self.id                  = id
        self.act                 = act
        self.speaker             = speaker
        self.text                = text
        self.leftChoice          = leftChoice
        self.rightChoice         = rightChoice
        self.leftEffects         = leftEffects
        self.rightEffects        = rightEffects
        self.characterImageName  = characterImageName
        self.condition           = condition
        self.isOnce              = isOnce
    }
}

// ============================================================
// THRESHOLD EVENT
// Fires when a meter hits a high or low point.
// Define these in CardDatabase.swift.
// ============================================================
struct ThresholdEvent {
    let meter: MeterType
    let value: Int          // The trigger number (0–100)
    let isHigh: Bool        // true = fires when meter rises TO this; false = falls TO this
    let message: String     // Text shown to player
    let injectCardID: String?  // Force a specific card next (optional)
    let isGameOver: Bool    // If true, run ends

    init(
        meter: MeterType,
        value: Int,
        isHigh: Bool,
        message: String,
        injectCardID: String? = nil,
        isGameOver: Bool = false
    ) {
        self.meter         = meter
        self.value         = value
        self.isHigh        = isHigh
        self.message       = message
        self.injectCardID  = injectCardID
        self.isGameOver    = isGameOver
    }
}
