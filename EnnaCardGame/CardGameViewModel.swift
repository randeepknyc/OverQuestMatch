// CardGameViewModel.swift
// Tracks all game state — meters, current card, act progression, thresholds
// You don't need to edit this file. Edit CardDatabase.swift instead.

import SwiftUI
import Observation

@Observable
class CardGameViewModel {

    // ============================================================
    // GAME STATE
    // ============================================================
    var meterValues: [MeterType: Int] = [:]
    var currentAct: Int = 1
    var cardsPlayedCount: Int = 0
    var currentCard: Card? = nil
    var playedOnceCardIDs: Set<String> = []
    var firedThresholdKeys: Set<String> = []

    // UI state
    var isGameOver: Bool = false
    var gameOverMessage: String = ""
    var thresholdMessage: String = ""
    var showThresholdMessage: Bool = false
    var injectedNextCardID: String? = nil
    var actJustUnlocked: Int? = nil         // set when an act first unlocks
    var showActUnlock: Bool = false

    // ============================================================
    // INIT
    // ============================================================
    init() {
        resetMeters()
        drawNextCard()
    }

    // ============================================================
    // PLAYER CHOICES
    // ============================================================
    func chooseLeft() {
        guard let card = currentCard else { return }
        applyEffects(card.leftEffects)
        finishTurn(card: card)
    }

    func chooseRight() {
        guard let card = currentCard else { return }
        applyEffects(card.rightEffects)
        finishTurn(card: card)
    }

    private func finishTurn(card: Card) {
        if card.isOnce {
            playedOnceCardIDs.insert(card.id)
        }
        cardsPlayedCount += 1
        checkThresholds()
        if !isGameOver {
            checkActProgression()
            drawNextCard()
        }
    }

    // ============================================================
    // APPLY METER EFFECTS
    // ============================================================
    private func applyEffects(_ effects: [MeterEffect]) {
        for effect in effects {
            let current = meterValues[effect.meter] ?? 50
            meterValues[effect.meter] = max(0, min(100, current + effect.value))
        }
    }

    // ============================================================
    // DRAW NEXT CARD
    // ============================================================
    func drawNextCard() {
        // Use injected card first (from threshold events)
        if let injectedID = injectedNextCardID,
           let injectedCard = CardDatabase.card(id: injectedID) {
            injectedNextCardID = nil
            withAnimation(.spring(response: 0.4)) {
                currentCard = injectedCard
            }
            return
        }

        let available = availableCards()

        // Don't show the same card twice in a row
        let candidates = available.filter { $0.id != currentCard?.id }
        let pick = candidates.randomElement() ?? available.randomElement()

        withAnimation(.spring(response: 0.4)) {
            currentCard = pick
        }
    }

    private func availableCards() -> [Card] {
        CardDatabase.allCards.filter { card in
            // Must belong to current act or an earlier one
            guard card.act <= currentAct else { return false }
            // isOnce cards only appear once
            if card.isOnce && playedOnceCardIDs.contains(card.id) { return false }
            // Check condition
            if let cond = card.condition {
                if let min = cond.minimum,
                   (meterValues[cond.meter] ?? 50) < min { return false }
                if let max = cond.maximum,
                   (meterValues[cond.meter] ?? 50) > max { return false }
            }
            return true
        }
    }

    // ============================================================
    // THRESHOLD CHECKING
    // ============================================================
    private func checkThresholds() {
        for threshold in CardDatabase.thresholds {
            let key = "\(threshold.meter.rawValue)_\(threshold.value)_\(threshold.isHigh)"
            guard !firedThresholdKeys.contains(key) else { continue }

            let current = meterValues[threshold.meter] ?? 50
            let triggered = threshold.isHigh ? current >= threshold.value
                                             : current <= threshold.value

            guard triggered else { continue }
            firedThresholdKeys.insert(key)

            if threshold.isGameOver {
                isGameOver = true
                gameOverMessage = threshold.message
                return
            }

            thresholdMessage = threshold.message
            showThresholdMessage = true

            if let cardID = threshold.injectCardID {
                injectedNextCardID = cardID
            }
        }
    }

    // ============================================================
    // ACT PROGRESSION
    // ============================================================
    private func checkActProgression() {
        if currentAct < 3 && cardsPlayedCount >= CardDatabase.act3UnlocksAfterCards {
            currentAct = 3
            actJustUnlocked = 3
            showActUnlock = true
        } else if currentAct < 2 && cardsPlayedCount >= CardDatabase.act2UnlocksAfterCards {
            currentAct = 2
            actJustUnlocked = 2
            showActUnlock = true
        }
    }

    // ============================================================
    // METER HELPERS
    // ============================================================
    func meterValue(for meter: MeterType) -> Int {
        meterValues[meter] ?? 50
    }

    func metersForAct(_ act: Int) -> [MeterType] {
        MeterType.allCases.filter { $0.act == act }
    }

    func isMetersLow(_ meter: MeterType) -> Bool {
        (meterValues[meter] ?? 50) <= 20
    }

    func isMetersHigh(_ meter: MeterType) -> Bool {
        (meterValues[meter] ?? 50) >= 80
    }

    // ============================================================
    // RESTART
    // ============================================================
    func restart() {
        resetMeters()
        currentAct = 1
        cardsPlayedCount = 0
        currentCard = nil
        playedOnceCardIDs = []
        firedThresholdKeys = []
        isGameOver = false
        gameOverMessage = ""
        thresholdMessage = ""
        showThresholdMessage = false
        injectedNextCardID = nil
        actJustUnlocked = nil
        showActUnlock = false
        drawNextCard()
    }

    private func resetMeters() {
        for meter in MeterType.allCases {
            meterValues[meter] = CardDatabase.startingValues[meter] ?? 50
        }
    }
}
