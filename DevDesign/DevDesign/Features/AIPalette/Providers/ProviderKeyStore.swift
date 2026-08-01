//
//  ProviderKeyStore.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation
import Security

// MARK: - Keychain

/// Minimal Keychain wrapper for generic passwords.
///
/// Items use `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`: readable after the first
/// unlock following a reboot, and never migrated to a new device via backup.
private enum Keychain {
    /// Namespaces items so they can't collide with anything else in the app's keychain.
    private static let service = "dev.sokpich.DevDesign.apikeys"

    private static func query(_ account: String) -> [String: Any] {
        [
            kSecClass       as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    @discardableResult
    static func set(_ value: String, for account: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Upsert: try to update an existing item, fall back to adding one.
        let updated = SecItemUpdate(
            query(account) as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )
        if updated == errSecSuccess { return true }
        guard updated == errSecItemNotFound else { return false }

        var attributes = query(account)
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    static func get(_ account: String) -> String? {
        var attributes = query(account)
        attributes[kSecReturnData as String] = true
        attributes[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        guard SecItemCopyMatching(attributes as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8),
              !string.isEmpty
        else { return nil }

        return string
    }

    @discardableResult
    static func delete(_ account: String) -> Bool {
        let status = SecItemDelete(query(account) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - Multi-Provider Key Store

enum ProviderKeyStore {
    private static let anthropicAccount  = "anthropic"
    private static let geminiAccount     = "gemini"
    private static let openrouterAccount = "openrouter"

    /// Not a secret — the chosen provider stays in UserDefaults.
    private static let selectedProviderUDKey = "devdesign_selected_provider"

    // MARK: Save / Load / Clear per provider

    static func saveKey(_ key: String, for provider: AIProvider) {
        Keychain.set(key, for: account(for: provider))
    }

    static func loadKey(for provider: AIProvider) -> String? {
        Keychain.get(account(for: provider))
    }

    static func clearKey(for provider: AIProvider) {
        Keychain.delete(account(for: provider))
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

    private static func account(for provider: AIProvider) -> String {
        switch provider {
        case .anthropic:  return anthropicAccount
        case .gemini:     return geminiAccount
        case .openrouter: return openrouterAccount
        }
    }
}

// MARK: - Legacy Migration (run once on first launch)

enum APIKeyStore {
    private static let legacyUDKeys: [(AIProvider, String)] = [
        (.anthropic,  "devdesign_anthropic_api_key"),
        (.gemini,     "devdesign_gemini_api_key"),
        (.openrouter, "devdesign_openrouter_api_key")
    ]

    /// Moves any keys still sitting in UserDefaults into the Keychain, then removes the
    /// plaintext copies. Safe to call on every launch: once UserDefaults is clear it does nothing.
    static func migrateToProviderStore() {
        let defaults = UserDefaults.standard

        for (provider, udKey) in legacyUDKeys {
            guard let legacyValue = defaults.string(forKey: udKey) else { continue }

            let trimmed = legacyValue.trimmingCharacters(in: .whitespacesAndNewlines)

            // Don't let an empty legacy value clobber a good Keychain entry.
            if !trimmed.isEmpty, ProviderKeyStore.loadKey(for: provider) == nil {
                ProviderKeyStore.saveKey(trimmed, for: provider)
            }

            // Remove the plaintext copy regardless — that's the point of the migration.
            defaults.removeObject(forKey: udKey)
        }
    }
}
