//
//  AIProvider.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

enum AIProvider: String, CaseIterable, Identifiable {
    case anthropic  = "Claude"
    case gemini     = "Gemini"
    case openrouter = "OpenRouter (Free)"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .anthropic:  return "cloud.fill"
        case .gemini:     return "sparkles"
        case .openrouter: return "network"
        }
    }

    var description: String {
        switch self {
        case .anthropic:  return "Claude Sonnet — high quality, requires API key"
        case .gemini:     return "Gemini Flash — free tier available (requires key)"
        case .openrouter: return "Llama 3.3 70B — free, no API key needed"
        }
    }

    var keyPlaceholder: String {
        switch self {
        case .anthropic:  return "sk-ant-api03-…"
        case .gemini:     return "AIzaSy…"
        case .openrouter: return "Optional sk-or-v1-…"
        }
    }

    var keyPrefix: String {
        switch self {
        case .anthropic:  return "sk-ant"
        case .gemini:     return "AIza"
        case .openrouter: return "sk-or"
        }
    }

    var helpURL: String {
        switch self {
        case .anthropic:  return "https://console.anthropic.com/settings/keys"
        case .gemini:     return "https://aistudio.google.com/app/apikey"
        case .openrouter: return "https://openrouter.ai/keys"
        }
    }

    /// Whether this provider requires an API key (OpenRouter free tier does not)
    var requiresKey: Bool {
        switch self {
        case .anthropic, .gemini: return true
        case .openrouter:         return false
        }
    }
}
