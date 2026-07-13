//
//  SaveManager.swift
//  OverQuestMatch3
//
//  Generic key-based save system. Each game writes its own JSON file
//  to the app's Documents directory using atomic writes.
//
//  Keys: "match3", "shop", "potionshop", "tavern"
//

import Foundation

enum SaveManager {

    // MARK: - Public API

    /// Encode `value` to JSON and write it atomically to Documents/<key>.json.
    /// Returns true on success.
    @discardableResult
    static func save<T: Encodable>(_ value: T, key: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(value)
            let url = fileURL(for: key)
            try data.write(to: url, options: .atomic)
            print("💾 SaveManager: saved '\(key)' (\(data.count) bytes)")
            return true
        } catch {
            print("❌ SaveManager: save '\(key)' failed — \(error)")
            return false
        }
    }

    /// Load and decode the JSON file at Documents/<key>.json.
    /// Returns nil if the file doesn't exist or decoding fails.
    static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        let url = fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("💾 SaveManager: no save for '\(key)'")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let value = try JSONDecoder().decode(type, from: data)
            print("💾 SaveManager: loaded '\(key)' (\(data.count) bytes)")
            return value
        } catch {
            print("❌ SaveManager: load '\(key)' failed — \(error)")
            return nil
        }
    }

    /// True if a save file exists for the given key.
    static func hasSave(key: String) -> Bool {
        FileManager.default.fileExists(atPath: fileURL(for: key).path)
    }

    /// Delete the save file for the given key (no-op if it doesn't exist).
    static func deleteSave(key: String) {
        let url = fileURL(for: key)
        try? FileManager.default.removeItem(at: url)
        print("💾 SaveManager: deleted '\(key)'")
    }

    // MARK: - Private

    private static func fileURL(for key: String) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("\(key).json")
    }
}
