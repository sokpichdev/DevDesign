//
//  AIProvider.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import Foundation

enum AIProvider: String, CaseIterable, Identifiable {
    case anthropic = "Claude"
    case gemini = "Gemini"
    case openrouter = "OpenRouter (Free)"

    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .anthropic: return "cloud.fill"
        case .gemini: return "sparkles"
        case .openrouter: return "network"
        }
    }
    
    var description: String {
        switch self {
        case .anthropic: return "Claude Sonnet - High quality, requires API key"
        case .gemini: return "Gemini Flash - Free tier available (requires key)"
        case .openrouter: return "Mistral 7B - Free, no API key needed"
        }
    }
    
    var keyPlaceholder: String {
        switch self {
        case .anthropic: return "sk-ant-api03-…"
        case .gemini: return "AIzaSy…"
        case .openrouter: return "Optional sk-or-v1-…"
        }
    }
    
    var keyPrefix: String {
        switch self {
        case .anthropic: return "sk-ant"
        case .gemini: return "AIza"
        case .openrouter: return "sk-or"
        }
    }
    
    var helpURL: String {
        switch self {
        case .anthropic: return "https://console.anthropic.com/settings/keys"
        case .gemini: return "https://aistudio.google.com/app/apikey"
        case .openrouter: return "https://openrouter.ai/keys"
        }
    }
    
    /// Whether this provider requires an API key
    var requiresKey: Bool {
        switch self {
        case .anthropic, .gemini: return true
        case .openrouter: return false // Free tier doesn't require key!
        }
    }
}

// MARK: - Provider Key Store
enum ProviderKeyStore {
    private static let anthropicKey = "devdesign_anthropic_api_key"
    private static let geminiKey = "devdesign_gemini_api_key"
    private static let openrouterKey = "devdesign_openrouter_api_key"
    private static let selectedProviderKey = "devdesign_selected_provider"
    
    static func saveKey(_ key: String, for provider: AIProvider) {
        switch provider {
        case .anthropic:
            UserDefaults.standard.set(key, forKey: anthropicKey)
        case .gemini:
            UserDefaults.standard.set(key, forKey: geminiKey)
        case .openrouter:
            UserDefaults.standard.set(key, forKey: openrouterKey)
        }
    }
    
    static func loadKey(for provider: AIProvider) -> String? {
        switch provider {
        case .anthropic:
            return UserDefaults.standard.string(forKey: anthropicKey)
        case .gemini:
            return UserDefaults.standard.string(forKey: geminiKey)
        case .openrouter:
            return UserDefaults.standard.string(forKey: openrouterKey)
        }
    }
    
    static func clearKey(for provider: AIProvider) {
        switch provider {
        case .anthropic:
            UserDefaults.standard.removeObject(forKey: anthropicKey)
        case .gemini:
            UserDefaults.standard.removeObject(forKey: geminiKey)
        case .openrouter:
            UserDefaults.standard.removeObject(forKey: openrouterKey)
        }
    }
    
    static func saveSelectedProvider(_ provider: AIProvider) {
        UserDefaults.standard.set(provider.rawValue, forKey: selectedProviderKey)
    }
    
    static func loadSelectedProvider() -> AIProvider {
        let stored = UserDefaults.standard.string(forKey: selectedProviderKey) ?? ""
        return AIProvider(rawValue: stored) ?? .openrouter // Default to OpenRouter (free!)
    }
    
    static func maskedDisplay(_ key: String, for provider: AIProvider) -> String {
        guard key.count > 8 else { return String(repeating: "•", count: key.count) }
        
        switch provider {
        case .anthropic:
            let prefix = String(key.prefix(7))    // "sk-ant-"
            let suffix = String(key.suffix(4))
            let dots = String(repeating: "•", count: 8)
            return "\(prefix)\(dots)\(suffix)"
        case .gemini:
            let prefix = String(key.prefix(6))    // "AIzaSy"
            let suffix = String(key.suffix(4))
            let dots = String(repeating: "•", count: min(8, key.count - 10))
            return "\(prefix)\(dots)\(suffix)"
        case .openrouter:
            let prefix = String(key.prefix(7))    // "sk-or-v1-"
            let suffix = String(key.suffix(4))
            let dots = String(repeating: "•", count: 8)
            return "\(prefix)\(dots)\(suffix)"
        }
    }
}
