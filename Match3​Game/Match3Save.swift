//
//  Match3Save.swift
//  OverQuestMatch3
//
//  Lightweight save for an in-progress Match3 battle.
//  Saves player/enemy vitals and score. The board is regenerated
//  on restore (mid-battle board serialization is intentionally
//  deferred — the board is procedural and a fresh deal is fair).
//
//  🆕 MULTI-ENEMY UPDATE: also remembers WHICH enemy you were
//  fighting, so "Continue" resumes against the right opponent.
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

    // 🆕 Which enemy this battle is against (roster id).
    // Old saves without this default to Ednar automatically.
    var enemyID: String

    static let saveKey = "match3"

    // ── Custom decoding so saves from BEFORE this update still load ──
    enum CodingKeys: String, CodingKey {
        case playerHP, playerMaxHP, playerShield
        case enemyHP, enemyMaxHP, enemyShield
        case mana, score, turnCount, enemyID
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        playerHP = try c.decode(Int.self, forKey: .playerHP)
        playerMaxHP = try c.decode(Int.self, forKey: .playerMaxHP)
        playerShield = try c.decode(Int.self, forKey: .playerShield)
        enemyHP = try c.decode(Int.self, forKey: .enemyHP)
        enemyMaxHP = try c.decode(Int.self, forKey: .enemyMaxHP)
        enemyShield = try c.decode(Int.self, forKey: .enemyShield)
        mana = try c.decode(Int.self, forKey: .mana)
        score = try c.decode(Int.self, forKey: .score)
        turnCount = try c.decode(Int.self, forKey: .turnCount)
        // Old save with no enemyID? Assume it was Ednar.
        enemyID = try c.decodeIfPresent(String.self, forKey: .enemyID) ?? "ednar"
    }

    init(playerHP: Int, playerMaxHP: Int, playerShield: Int,
         enemyHP: Int, enemyMaxHP: Int, enemyShield: Int,
         mana: Int, score: Int, turnCount: Int, enemyID: String) {
        self.playerHP = playerHP
        self.playerMaxHP = playerMaxHP
        self.playerShield = playerShield
        self.enemyHP = enemyHP
        self.enemyMaxHP = enemyMaxHP
        self.enemyShield = enemyShield
        self.mana = mana
        self.score = score
        self.turnCount = turnCount
        self.enemyID = enemyID
    }

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
            turnCount: vm.battleManager.turnCount,
            enemyID: vm.battleManager.enemyProfile.id  // 🆕 remember the foe
        )
    }

    func restore(into vm: GameViewModel) {
        // 🆕 FIRST: restore which enemy this battle was against,
        // so the portrait, attacks, and signature gem all match up.
        if let profile = EnemyRoster.enemy(withID: enemyID) {
            EnemyRoster.current = profile
            vm.battleManager.enemyProfile = profile
            vm.battleManager.enemy.name = profile.name
            vm.battleManager.enemy.imageName = profile.portraitAsset
        }

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
