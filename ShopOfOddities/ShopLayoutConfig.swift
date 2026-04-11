//
//  ShopLayoutConfig.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/9/26.
//  Centralized layout configuration for Shop of Oddities UI
//

import SwiftUI

/// Centralized configuration for all Shop of Oddities layout values.
/// Change numbers here to tweak the entire UI proportions.
struct ShopLayoutConfig {
    
    // MARK: - Card Dimensions
    
    /// Card aspect ratio (width / height) - Tarot card proportions
    static let cardAspectRatio: CGFloat = 0.65
    
    // Card width is calculated dynamically based on available screen width
    // Card height = cardWidth / cardAspectRatio
    
    // MARK: - Section Heights (as proportion of screen height)
    
    /// Score bar height (5% of screen height)
    static let scoreBarHeight: CGFloat = 0.05
    
    /// Scene view height (46.2% of screen height)
    static let sceneHeight: CGFloat = 0.462
    
    /// Commentary height (fixed points, not percentage)
    static let commentaryHeight: CGFloat = 17.0
    
    /// If true, commentary uses fixed points; if false, uses percentage of screen
    static let commentaryIsFixedPoints: Bool = true
    
    // MARK: - Counter / Repair Area
    
    /// Padding above repair cards (counter surface top edge to cards)
    static let counterPaddingTop: CGFloat = 9.0
    
    /// Padding below repair cards (cards to counter surface bottom edge)
    static let counterPaddingBottom: CGFloat = 6.0
    
    // Counter total height = paddingTop + cardHeight + paddingBottom (calculated dynamically)
    
    // MARK: - Gaps Between Sections
    
    /// Gap between counter bottom and deck area top (points)
    static let gapCounterToDecks: CGFloat = 10.0
    
    // MARK: - Deck Area
    
    /// Padding below deck cards (bottom breathing room)
    static let deckBottomPadding: CGFloat = 9.0
    
    /// Horizontal spacing between deck cards (points)
    static let deckCardSpacing: CGFloat = 4.0
    
    /// Horizontal spacing between repair slot cards (points)
    static let repairCardSpacing: CGFloat = 4.0
    
    // MARK: - Ghost Cards
    
    /// Number of ghost cards behind each deck (0, 1, or 2)
    static let ghostCardCount: Int = 0
    
    /// Middle ghost card rotation (degrees)
    static let ghostCard1Rotation: Double = -1.2
    
    /// Furthest back ghost card rotation (degrees)
    static let ghostCard2Rotation: Double = -2.5
    
    /// Middle ghost card opacity (0.0 to 1.0)
    static let ghostCard1Opacity: Double = 0.38
    
    /// Furthest back ghost card opacity (0.0 to 1.0)
    static let ghostCard2Opacity: Double = 0.18
    
    /// Middle ghost card horizontal offset (points left, negative = left)
    static let ghostCard1OffsetX: CGFloat = -1.5
    
    /// Furthest back ghost card horizontal offset (points left, negative = left)
    static let ghostCard2OffsetX: CGFloat = -3.0
    
    /// Middle ghost card vertical offset (points down)
    static let ghostCard1OffsetY: CGFloat = 2.0
    
    /// Furthest back ghost card vertical offset (points down)
    static let ghostCard2OffsetY: CGFloat = 4.0
    
    // MARK: - Deck Fan / Rotation
    
    /// Per-deck rotation in degrees [deck0, deck1, deck2, deck3]
    /// Example whimsical: [-3, 1, -1, 2]
    /// Example fan: [-12, -4, 4, 12]
    /// Current: all zeros (straight row)
    static let deckRotations: [Double] = [0, 0, 0, 0]
    
    // MARK: - Side Padding
    
    /// Left/right horizontal padding for content sections
    static let horizontalPadding: CGFloat = 12.0
    
    // MARK: - Score Bar
    
    /// Score bar background opacity (0.0 to 1.0)
    static let scoreBarOpacity: Double = 0.35
    
    /// Horizontal padding for score bar text content
    static let scoreBarTextPadding: CGFloat = 28.0
    
    // MARK: - Counter Surface Style
    
    /// Counter surface background color (warm brown)
    static let counterSurfaceColor: Color = Color(red: 0.42, green: 0.35, blue: 0.25)
    
    /// Counter surface background opacity (0.0 to 1.0)
    static let counterSurfaceOpacity: Double = 0.3
    
    /// Counter surface corner radius (for rounded rectangle)
    static let counterCornerRadius: CGFloat = 12.0
    
    /// Counter background opacity (for repair slot view)
    static let counterBackgroundOpacity: Double = 0.3
    
    /// Top ledge line opacity (line above repair cards)
    static let counterLedgeOpacity: Double = 0.35
    
    /// Bottom ledge line opacity (line below repair cards, between counter and decks)
    static let counterBottomLedgeOpacity: Double = 0.2
    
    // MARK: - Deal Animation (game start)
    
    /// Enable/disable deal animation at game start
    static let dealAnimationEnabled: Bool = true
    
    /// Seconds between each card being dealt (stagger delay)
    static let dealStaggerDelay: Double = 0.12
    
    /// How long each card's deal takes (slide-up duration)
    static let dealAnimationDuration: Double = 0.25
    
    /// Cards start this many points below final position
    static let dealStartOffsetY: CGFloat = 300
    
    // Cards slide up from below into their deck positions
    
    // MARK: - Card Flip Animation (face-down reveal)
    
    /// Enable/disable flip animation at game start
    static let flipAnimationEnabled: Bool = true
    
    /// Seconds between each card flipping (stagger delay)
    static let flipStaggerDelay: Double = 0.15
    
    /// Total flip duration per card (half for each side)
    static let flipAnimationDuration: Double = 0.9
    
    /// Wait this long after deal finishes before flipping starts
    static let flipDelayAfterDeal: Double = 0.3
    
    /// If true, cards flip every time drawn (not just game start)
    static let flipOnEveryDraw: Bool = false
    
    // When flipOnEveryDraw is true, the existing draw-card flip handles it
    // When false, only the opening reveal does the face-down-to-face-up flip
    
    // MARK: - Card Back
    
    /// Asset name for face-down card back
    static let cardBackImageName: String = "card-background"
    
    // MARK: - Drag and Drop
    
    /// Master toggle: if true, use drag-and-drop; if false, use tap-to-draw
    static let dragEnabled: Bool = true
    
    /// Card scales up slightly while being dragged
    static let dragScaleWhileDragging: CGFloat = 1.1
    
    /// Slight transparency while dragging
    static let dragOpacityWhileDragging: Double = 0.85
    
    /// How long the snap-to-slot animation takes (seconds)
    static let snapAnimationDuration: Double = 0.25
    
    /// How long the return-to-deck animation takes if dropped outside (seconds)
    static let returnAnimationDuration: Double = 0.3
    
    /// How close to a slot the card needs to be to snap (points)
    static let slotDetectionPadding: CGFloat = 20.0
    
    /// Opacity of the ghost card left behind during drag
    static let dragGhostOpacity: Double = 0.3
}
