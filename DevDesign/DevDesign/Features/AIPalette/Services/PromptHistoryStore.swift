//
//  PromptHistoryStore.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

enum PromptHistoryStore {
    private static let udKey  = "devdesign_prompt_history"
    private static let maxSize = 20

    static func load() -> [PromptHistoryEntry] {
        guard let data    = UserDefaults.standard.data(forKey: udKey),
              let entries = try? JSONDecoder().decode([PromptHistoryEntry].self, from: data)
        else { return [] }
        return entries
    }

    static func append(_ entry: PromptHistoryEntry) {
        var entries = load()
        // Deduplicate by prompt + style
        entries.removeAll { $0.prompt == entry.prompt && $0.style == entry.style }
        entries.insert(entry, at: 0)
        if entries.count > maxSize { entries = Array(entries.prefix(maxSize)) }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: udKey)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: udKey)
    }
}
