//
//  ProviderKeyStore.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

// MARK: - Multi-Provider Key Store

enum ProviderKeyStore {
    private static let anthropicUDKey    = "devdesign_anthropic_api_key"
    private static let geminiUDKey       = "devdesign_gemini_api_key"
    private static let openrouterUDKey   = "devdesign_openrouter_api_key"
    private static let selectedProviderUDKey = "devdesign_selected_provider"

    // MARK: Save / Load / Clear per provider

    static func saveKey(_ key: String, for provider: AIProvider) {
        UserDefaults.standard.set(key, forKey: udKey(for: provider))
    }

    static func loadKey(for provider: AIProvider) -> String? {
        UserDefaults.standard.string(forKey: udKey(for: provider))
    }

    static func clearKey(for provider: AIProvider) {
        UserDefaults.standard.removeObject(forKey: udKey(for: provider))
    }

    // MARK: Selected provider

    static func saveSelectedProvider(_ provider: AIProvider) {
        UserDefaults.standard.set(provider.rawValue, forKey: selectedProviderUDKey)
    }

    static func loadSelectedProvider() -> AIProvider {
        let stored = UserDefaults.standard.string(forKey: selectedProviderUDKey) ?? ""
        return AIProvider(rawValue: stored) ?? .openrouter   // default to free tier
    }

    // MARK: Masked display

    static func maskedDisplay(_ key: String, for provider: AIProvider) -> String {
        guard key.count > 8 else { return String(repeating: "•", count: key.count) }
        let suffix = String(key.suffix(4))
        let dots   = String(repeating: "•", count: 8)
        switch provider {
        case .anthropic:
            return "\(String(key.prefix(7)))\(dots)\(suffix)"   // "sk-ant-"
        case .gemini:
            return "\(String(key.prefix(6)))\(dots)\(suffix)"   // "AIzaSy"
        case .openrouter:
            return "\(String(key.prefix(7)))\(dots)\(suffix)"   // "sk-or-v"
        }
    }

    // MARK: Private

    private static func udKey(for provider: AIProvider) -> String {
        switch provider {
        case .anthropic:  return anthropicUDKey
        case .gemini:     return geminiUDKey
        case .openrouter: return openrouterUDKey
        }
    }
}

// MARK: - Legacy Migration (run once on first launch)

enum APIKeyStore {
    /// Migrates an old single-provider key (if any) into the new per-provider store.
    static func migrateToProviderStore() {
        let legacyKey = "devdesign_anthropic_api_key"
        if let oldKey = UserDefaults.standard.string(forKey: legacyKey),
           ProviderKeyStore.loadKey(for: .anthropic) == nil {
            ProviderKeyStore.saveKey(oldKey, for: .anthropic)
        }
    }
}
