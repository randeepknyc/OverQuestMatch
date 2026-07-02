//
//  CardGameSave.swift
//  OverQuestMatch3
//
//  Codable snapshot of an in-progress Enna's Tavern card game session.
//  Saves meter values, act progression, and played-once state.
//  Deleted on game over or restart.
//

import Foundation

struct CardGameSave: Codable {
    var meterValues: [MeterType: Int]
    var currentAct: Int
    var cardsPlayedCount: Int
    var playedOnceCardIDs: Set<String>
    var firedThresholdKeys: Set<String>

    static let saveKey = "tavern"

    static func snapshot(from vm: CardGameViewModel) -> CardGameSave {
        CardGameSave(
            meterValues: vm.meterValues,
            currentAct: vm.currentAct,
            cardsPlayedCount: vm.cardsPlayedCount,
            playedOnceCardIDs: vm.playedOnceCardIDs,
            firedThresholdKeys: vm.firedThresholdKeys
        )
    }

    func restore(into vm: CardGameViewModel) {
        vm.meterValues = meterValues
        vm.currentAct = currentAct
        vm.cardsPlayedCount = cardsPlayedCount
        vm.playedOnceCardIDs = playedOnceCardIDs
        vm.firedThresholdKeys = firedThresholdKeys
        vm.isGameOver = false
        vm.gameOverMessage = ""
        // Draw a fresh card for the restored state
        vm.drawNextCard()
    }

    static func save(vm: CardGameViewModel) {
        let snap = snapshot(from: vm)
        SaveManager.save(snap, key: saveKey)
    }

    static func load() -> CardGameSave? {
        SaveManager.load(CardGameSave.self, key: saveKey)
    }

    static func deleteSave() {
        SaveManager.deleteSave(key: saveKey)
    }

    static func hasSave() -> Bool {
        SaveManager.hasSave(key: saveKey)
    }
}
