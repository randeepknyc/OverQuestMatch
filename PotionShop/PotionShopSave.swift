//
//  PotionShopSave.swift
//  OverQuestMatch3
//
//  Codable snapshot of an in-progress Potion Shop run.
//  Saved at round/day boundaries and on background; deleted on
//  loss, win, or new-run reset.
//

import Foundation

struct PotionShopSave: Codable {
    // Run progress
    var dayId: String
    var roundIndex: Int

    // Player vitals
    var composure: Int
    var shield: Int
    var potionsBrewed: Int

    // Run deck + boons
    var run: PotionShopRunState

    // Boon frequency setting
    var boonFrequency: PotionShopBoonFrequency

    // MARK: - Snapshot from game state

    static func snapshot(from gs: PotionShopGameState) -> PotionShopSave {
        PotionShopSave(
            dayId: gs.dayId,
            roundIndex: gs.roundIndex,
            composure: gs.composure,
            shield: gs.shield,
            potionsBrewed: gs.potionsBrewed,
            run: gs.run,
            boonFrequency: gs.boonFrequency
        )
    }

    // MARK: - Restore into game state

    func restore(into gs: PotionShopGameState) {
        gs.dayId = dayId
        gs.roundIndex = roundIndex
        gs.composure = composure
        gs.shield = shield
        gs.potionsBrewed = potionsBrewed
        gs.run = run
        gs.boonFrequency = boonFrequency
        // Restart the current round with restored deck/day
        gs.startRound()
    }

    // MARK: - Save key

    static let saveKey = "potionshop"

    static func save(gs: PotionShopGameState) {
        let snap = snapshot(from: gs)
        SaveManager.save(snap, key: saveKey)
    }

    static func load() -> PotionShopSave? {
        SaveManager.load(PotionShopSave.self, key: saveKey)
    }

    static func deleteSave() {
        SaveManager.deleteSave(key: saveKey)
    }

    static func hasSave() -> Bool {
        SaveManager.hasSave(key: saveKey)
    }
}
