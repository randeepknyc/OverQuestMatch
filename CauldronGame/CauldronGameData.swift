// CauldronGameData.swift
// Ednar's Cauldron - Data Layer (Phase 1)
// Loads traits.json, characters.json, rounds.json at app launch

import Foundation
import SwiftUI
import Combine

// MARK: - Trait Definitions

struct TraitEffects: Codable {
    let brewTargetModifier: Int?
    let activePatienceDrainModifier: Int?
    let waitingPatienceDrainModifier: Int?
    let focusModifier: Int?
    let composureDrainPerTurn: Int?
    let diceValueModifierGlobal: Int?
    let overbrewTriggersPredefense: Bool?
    let hexDiePerTurn: Bool?
    
    enum CodingKeys: String, CodingKey {
        case brewTargetModifier = "brew_target_modifier"
        case activePatienceDrainModifier = "active_patience_drain_modifier"
        case waitingPatienceDrainModifier = "waiting_patience_drain_modifier"
        case focusModifier = "focus_modifier"
        case composureDrainPerTurn = "composure_drain_per_turn"
        case diceValueModifierGlobal = "dice_value_modifier_global"
        case overbrewTriggersPredefense = "overbrew_triggers_predefense"
        case hexDiePerTurn = "hex_die_per_turn"
    }
}

struct Trait: Codable {
    let name: String
    let description: String
    let effects: TraitEffects
}

// Wrapper for traits.json which has a top-level "traits" object
struct TraitsData: Codable {
    let traits: [String: Trait]
}

// MARK: - Character Definitions

struct CauldronCharacter: Codable {
    let name: String
    let title: String
    let portrait: String
    let iconFallback: String?
    let difficulty: Int
    let timeOfDay: [String]
    let orderName: String
    let orderDialogue: String
    let hp: Int
    let patience: Int
    let activeAttack: Int
    let waitingAttack: Int
    let activePatienceTick: Int
    let waitingPatienceTick: Int
    let expireDamage: Int
    let trait: String?
    let tickDialogue: String?
    let expireDialogue: String?
    let defeatDialogue: String?
    
    enum CodingKeys: String, CodingKey {
        case name, title, portrait, difficulty, hp, patience, trait
        case iconFallback = "icon_fallback"
        case timeOfDay = "time_of_day"
        case orderName = "order_name"
        case orderDialogue = "order_dialogue"
        case activeAttack = "active_attack"
        case waitingAttack = "waiting_attack"
        case activePatienceTick = "active_patience_tick"
        case waitingPatienceTick = "waiting_patience_tick"
        case expireDamage = "expire_damage"
        case tickDialogue = "tick_dialogue"
        case expireDialogue = "expire_dialogue"
        case defeatDialogue = "defeat_dialogue"
    }
}

// Wrapper for characters.json which has a top-level "characters" object
struct CharactersData: Codable {
    let characters: [String: CauldronCharacter]
}

// MARK: - Round Definitions

struct GlobalSettings: Codable {
    let startingComposure: Int
    let maxComposure: Int
    let composureRestBetweenRounds: Int
    let composureRestBetweenDays: Int
    let roundsPerDay: Int
    let roundOrder: [String]
    let maxPlacementsPerBrew: Int
    
    enum CodingKeys: String, CodingKey {
        case startingComposure = "starting_composure"
        case maxComposure = "max_composure"
        case composureRestBetweenRounds = "COMPOSURE_REST_BETWEEN_ROUNDS"
        case composureRestBetweenDays = "COMPOSURE_REST_BETWEEN_DAYS"
        case roundsPerDay = "rounds_per_day"
        case roundOrder = "round_order"
        case maxPlacementsPerBrew = "MAX_PLACEMENTS_PER_BREW"
    }
}

struct RoundRules: Codable {
    let maxDifficulty: Int?
    let minDifficulty: Int?
    let mustIncludeTag: String?
    let requiredTrait: String?
    let excludeIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case maxDifficulty = "max_difficulty"
        case minDifficulty = "min_difficulty"
        case mustIncludeTag = "must_include_tag"
        case requiredTrait = "required_trait"
        case excludeIds = "exclude_ids"
    }
}

struct RoundDef: Codable {
    let mode: String  // "curated" or "random"
    let customers: [String]?  // For curated mode
    let count: Int?  // For random mode
    let rules: RoundRules?  // For random mode
}

struct DayDef: Codable {
    let name: String
    let subtitle: String
    let morning: RoundDef
    let afternoon: RoundDef
    let evening: RoundDef
    let night: RoundDef
}

// Wrapper for rounds.json which has "_global_settings" and "days" at top level
struct RoundsData: Codable {
    let globalSettings: GlobalSettings
    let days: [String: DayDef]
    
    enum CodingKeys: String, CodingKey {
        case globalSettings = "_global_settings"
        case days
    }
}

// MARK: - Salvaged from existing CauldronModels.swift (renamed to avoid conflicts)

/// Die tier enum (kept for future use - all dice at .basic in v1)
enum CauldronDieTier: String, Codable {
    case basic, silver, gold
    
    func rollFace() -> Int {
        let faces: [Int]
        switch self {
        case .basic:  faces = [1, 1, 2, 2, 2, 2]
        case .silver: faces = [2, 3, 3, 4, 4, 4]
        case .gold:   faces = [4, 4, 5, 5, 6, 6]
        }
        return faces.randomElement()!
    }
}

/// Bag die struct (no face value until drawn)
struct CauldronBagDie: Identifiable {
    let id: String
    let type: String  // "potency", "stability", "boost", "heal", "shield"
    let tier: CauldronDieTier
}

// MARK: - Data Loader

class CauldronGameData: ObservableObject {
    @Published var traits: [String: Trait] = [:]
    @Published var characters: [String: CauldronCharacter] = [:]
    @Published var days: [String: DayDef] = [:]
    @Published var globalSettings: GlobalSettings?
    @Published var isLoaded = false
    @Published var loadError: String?
    
    init() {
        loadAllData()
    }
    
    private func loadAllData() {
        do {
            // Load traits.json
            guard let traitsURL = Bundle.main.url(forResource: "traits", withExtension: "json") else {
                throw NSError(domain: "CauldronGameData", code: 1, userInfo: [NSLocalizedDescriptionKey: "traits.json not found in bundle"])
            }
            let traitsData = try Data(contentsOf: traitsURL)
            let traitsWrapper = try JSONDecoder().decode(TraitsData.self, from: traitsData)
            self.traits = traitsWrapper.traits
            
            // Load characters.json
            guard let charactersURL = Bundle.main.url(forResource: "characters", withExtension: "json") else {
                throw NSError(domain: "CauldronGameData", code: 2, userInfo: [NSLocalizedDescriptionKey: "characters.json not found in bundle"])
            }
            let charactersData = try Data(contentsOf: charactersURL)
            let charactersWrapper = try JSONDecoder().decode(CharactersData.self, from: charactersData)
            self.characters = charactersWrapper.characters
            
            // Load rounds.json
            guard let roundsURL = Bundle.main.url(forResource: "rounds", withExtension: "json") else {
                throw NSError(domain: "CauldronGameData", code: 3, userInfo: [NSLocalizedDescriptionKey: "rounds.json not found in bundle"])
            }
            let roundsData = try Data(contentsOf: roundsURL)
            let roundsWrapper = try JSONDecoder().decode(RoundsData.self, from: roundsData)
            self.days = roundsWrapper.days
            self.globalSettings = roundsWrapper.globalSettings
            
            // Success!
            self.isLoaded = true
            
            // Debug print as required by Phase 1
            let characterCount = characters.count
            let traitCount = traits.count
            let dayKeys = days.keys.sorted().joined(separator: ", ")
            print("✅ Cauldron Data Loaded: \(characterCount) characters, \(traitCount) traits, days: \(dayKeys)")
            
        } catch {
            self.loadError = "Failed to load game data: \(error.localizedDescription)"
            print("❌ CauldronGameData load error: \(error)")
        }
    }
}
