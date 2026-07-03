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
    /// JULY 2, 2026: the run's crowd-shuffle seed (see
    /// PotionShopData.campaignRunSalt). Optional so saves from before
    /// this field still decode; nil = keep whatever seed is running.
    var runSeed: UInt64? = nil

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
            runSeed: gs.runSeed,
            composure: gs.composure,
            shield: gs.shield,
            potionsBrewed: gs.potionsBrewed,
            run: gs.run,
            boonFrequency: gs.boonFrequency
        )
    }

    // MARK: - Restore into game state

    func restore(into gs: PotionShopGameState) {
        // JULY 2, 2026: restore the run's crowd-shuffle seed FIRST, so the
        // day lineup regenerated below matches the one that was saved.
        if let seed = runSeed {
            gs.runSeed = seed
            PotionShopData.campaignRunSalt = seed
        }
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
