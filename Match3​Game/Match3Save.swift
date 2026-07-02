//
//  Match3Save.swift
//  OverQuestMatch3
//
//  Lightweight save for an in-progress Match3 battle.
//  Saves player/enemy vitals and score. The board is regenerated
//  on restore (mid-battle board serialization is intentionally
//  deferred — the board is procedural and a fresh deal is fair).
//

import Foundation

struct Match3Save: Codable {
    var playerHP: Int
    var playerMaxHP: Int
    var playerShield: Int
    var enemyHP: Int
    var enemyMaxHP: Int
    var enemyShield: Int
    var mana: Int
    var score: Int
    var turnCount: Int

    static let saveKey = "match3"

    static func snapshot(from vm: GameViewModel) -> Match3Save {
        Match3Save(
            playerHP: vm.battleManager.player.currentHealth,
            playerMaxHP: vm.battleManager.player.maxHealth,
            playerShield: vm.battleManager.player.shield,
            enemyHP: vm.battleManager.enemy.currentHealth,
            enemyMaxHP: vm.battleManager.enemy.maxHealth,
            enemyShield: vm.battleManager.enemy.shield,
            mana: vm.battleManager.mana,
            score: vm.score,
            turnCount: vm.battleManager.turnCount
        )
    }

    func restore(into vm: GameViewModel) {
        vm.battleManager.player.currentHealth = playerHP
        vm.battleManager.player.maxHealth = playerMaxHP
        vm.battleManager.player.shield = playerShield
        vm.battleManager.enemy.currentHealth = enemyHP
        vm.battleManager.enemy.maxHealth = enemyMaxHP
        vm.battleManager.enemy.shield = enemyShield
        vm.battleManager.mana = mana
        vm.score = score
        vm.battleManager.turnCount = turnCount
    }

    static func save(vm: GameViewModel) {
        let snap = snapshot(from: vm)
        SaveManager.save(snap, key: saveKey)
    }

    static func load() -> Match3Save? {
        SaveManager.load(Match3Save.self, key: saveKey)
    }

    static func deleteSave() {
        SaveManager.deleteSave(key: saveKey)
    }

    static func hasSave() -> Bool {
        SaveManager.hasSave(key: saveKey)
    }
}
