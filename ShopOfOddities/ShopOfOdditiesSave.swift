//
//  ShopOfOdditiesSave.swift
//  OverQuestMatch3
//
//  Codable snapshot of an in-progress Shop of Oddities session.
//  Saved on background; deleted on game over or new game.
//  v1 (July 2026): Now also saves the repair history (repairsCompleted).
//

import Foundation

struct ShopOfOdditiesSave: Codable {
    var decks: [ComponentType: [ComponentCard]]
    var repairSlots: [RepairSlot]
    var customers: [Customer]
    var score: Int
    var customersServed: Int
    // Optional so older save files (from before the skip feature) still load;
    // if missing, the player simply gets a full set of skips.
    var bootsRemaining: Int?
    // Optional so older save files still load; if missing, history starts empty.
    var repairsCompleted: [RepairResult]?

    static let saveKey = "shop"

    static func snapshot(from gs: ShopGameState) -> ShopOfOdditiesSave {
        ShopOfOdditiesSave(
            decks: gs.decks,
            repairSlots: gs.repairSlots,
            customers: gs.customers,
            score: gs.score,
            customersServed: gs.customersServed,
            bootsRemaining: gs.bootsRemaining,
            repairsCompleted: gs.repairsCompleted
        )
    }

    func restore(into gs: ShopGameState) {
        gs.decks = decks
        gs.repairSlots = repairSlots
        gs.customers = customers
        gs.score = score
        gs.customersServed = customersServed
        gs.bootsRemaining = bootsRemaining ?? ShopLayoutConfig.bootsPerGame
        gs.repairsCompleted = repairsCompleted ?? []
        gs.currentCustomer = customers.first
        gs.nextCustomer = customers.count > 1 ? customers[1] : nil
        gs.gameOver = false
        gs.gameWon = false
        gs.gameOverReason = nil
    }

    static func save(gs: ShopGameState) {
        let snap = snapshot(from: gs)
        SaveManager.save(snap, key: saveKey)
    }

    static func load() -> ShopOfOdditiesSave? {
        SaveManager.load(ShopOfOdditiesSave.self, key: saveKey)
    }

    static func deleteSave() {
        SaveManager.deleteSave(key: saveKey)
    }

    static func hasSave() -> Bool {
        SaveManager.hasSave(key: saveKey)
    }
}
