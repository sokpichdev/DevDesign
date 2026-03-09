//
//  AIPaletteError.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import Foundation

// MARK: - Service Errors

enum AIPaletteError: LocalizedError, Equatable {
    case noAPIKey
    case networkError(String)
    case invalidResponse
    case parseError(String)
    case apiError(String)
    case rateLimited
    case invalidAPIKey
    case providerError(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key set. Tap ⚙ to add your Anthropic API key."
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .invalidResponse:
            return "Received an unexpected response from the server."
        case .parseError(let msg):
            return "Couldn't parse the generated palette: \(msg)"
        case .apiError(let msg):
            return "Anthropic API error: \(msg)"
        case .rateLimited:
            return "Rate limit reached. Please wait a moment and try again."
        case .invalidAPIKey:
            return "Invalid API key format. Please check your key."
        case .providerError(let msg):
            return "Provider error: \(msg)"
        }
    }
}

// MARK: - API Key Storage (UserDefaults — swap for Keychain in production)

//enum APIKeyStore {
//    private static let key = "devdesign_anthropic_api_key"
//
//    static func save(_ apiKey: String) {
//        UserDefaults.standard.set(apiKey, forKey: key)
//    }
//
//    static func load() -> String? {
//        UserDefaults.standard.string(forKey: key)
//    }
//
//    static func clear() {
//        UserDefaults.standard.removeObject(forKey: key)
//    }
//
//    static func maskedDisplay(_ key: String) -> String {
//        guard key.count > 8 else { return String(repeating: "•", count: key.count) }
//        let prefix = String(key.prefix(7))    // "sk-ant-"
//        let suffix = String(key.suffix(4))
//        let dots   = String(repeating: "•", count: 8)
//        return "\(prefix)\(dots)\(suffix)"
//    }
//}

// MARK: - Prompt History (UserDefaults)

enum PromptHistoryStore {
    private static let key     = "devdesign_prompt_history"
    private static let maxSize = 20

    static func load() -> [PromptHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([PromptHistoryEntry].self, from: data)
        else { return [] }
        return entries
    }

    static func append(_ entry: PromptHistoryEntry) {
        var entries = load()
        entries.removeAll { $0.prompt == entry.prompt && $0.style == entry.style }
        entries.insert(entry, at: 0)
        if entries.count > maxSize { entries = Array(entries.prefix(maxSize)) }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
