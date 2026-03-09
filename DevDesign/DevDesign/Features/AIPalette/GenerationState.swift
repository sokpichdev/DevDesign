//
//  GenerationState.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

// MARK: - Generation State

enum GenerationState: Equatable {
    case idle
    case generating
    case success
    case error(String)
}

// MARK: - Color Count

enum ColorCount: Int, CaseIterable, Identifiable {
    case four  = 4
    case six   = 6
    case eight = 8

    var id: Int { rawValue }
    var label: String { "\(rawValue)" }
}

// MARK: - Palette Mood / Style

enum PaletteStyle: String, CaseIterable, Identifiable {
    case vibrant     = "Vibrant"
    case muted       = "Muted"
    case dark        = "Dark"
    case light       = "Light"
    case pastel      = "Pastel"
    case neon        = "Neon"
    case monochrome  = "Mono"
    case earthy      = "Earthy"
    case any         = "Any"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .vibrant:    return "sun.max"
        case .muted:      return "cloud"
        case .dark:       return "moon"
        case .light:      return "sun.min"
        case .pastel:     return "heart.fill"
        case .neon:       return "bolt.fill"
        case .monochrome: return "circle.lefthalf.filled"
        case .earthy:     return "leaf"
        case .any:        return "wand.and.sparkles"
        }
    }
    var hint: String {
        switch self {
        case .vibrant:    return "Bold, saturated, high energy"
        case .muted:      return "Desaturated, calm, sophisticated"
        case .dark:       return "Deep tones, dramatic contrast"
        case .light:      return "Airy, soft, minimal"
        case .pastel:     return "Gentle, dreamy, approachable"
        case .neon:       return "Electric, glowing, synthetic"
        case .monochrome: return "Single hue, varied lightness"
        case .earthy:     return "Organic, warm neutrals, nature"
        case .any:        return "No constraint on style"
        }
    }
}

// MARK: - Generated Color

struct AIColor: Identifiable, Equatable, Codable {
    var id: UUID       = UUID()
    var hex: String             // e.g. "#FF6B35"
    var name: String            // e.g. "Tangerine Dusk"
    var role: String            // e.g. "primary" | "background" | "accent" | "text" | "surface"
    var usage: String           // e.g. "CTAs, highlights"

    var red:   Double { Double(hexComponent(offset: 0)) / 255 }
    var green: Double { Double(hexComponent(offset: 1)) / 255 }
    var blue:  Double { Double(hexComponent(offset: 2)) / 255 }

    var color: Color { Color(red: red, green: green, blue: blue) }

    var isDark: Bool {
        (red * 299 + green * 587 + blue * 114) / 1000 < 0.5
    }

    var onColor: Color { isDark ? .white : .black }

    private func hexComponent(offset: Int) -> UInt8 {
        let raw = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard raw.count >= 6 else { return 0 }
        let startIndex = raw.index(raw.startIndex, offsetBy: offset * 2)
        let endIndex   = raw.index(startIndex, offsetBy: 2)
        return UInt8(raw[startIndex..<endIndex], radix: 16) ?? 0
    }
}

// MARK: - Generated Palette

struct AIGeneratedPalette: Identifiable, Equatable, Codable {
    var id: UUID          = UUID()
    var name: String                // e.g. "Sunset Over Tokyo"
    var mood: String                // e.g. "warm, nostalgic, urban"
    var colors: [AIColor]
    var prompt: String
    var style: String
    var generatedAt: Date = .now
}

// MARK: - Prompt Suggestion

struct PromptSuggestion: Identifiable {
    let id   = UUID()
    let text: String
    let icon: String
    let category: SuggestionCategory
}

enum SuggestionCategory: String, CaseIterable {
    case nature   = "Nature"
    case urban    = "Urban"
    case mood     = "Mood"
    case design   = "Design"
    case abstract = "Abstract"

    var icon: String {
        switch self {
        case .nature:   return "leaf"
        case .urban:    return "building.2"
        case .mood:     return "theatermasks"
        case .design:   return "pencil.and.ruler"
        case .abstract: return "sparkles"
        }
    }
}

enum PromptSuggestionLibrary {
    static let all: [PromptSuggestion] = [
        // Nature
        PromptSuggestion(text: "Sunset over the ocean",         icon: "sun.horizon",        category: .nature),
        PromptSuggestion(text: "Deep forest at dawn",           icon: "tree",               category: .nature),
        PromptSuggestion(text: "Arctic ice and snow",           icon: "snowflake",          category: .nature),
        PromptSuggestion(text: "Autumn leaves falling",         icon: "leaf",               category: .nature),
        PromptSuggestion(text: "Desert canyon midday",          icon: "sun.max",            category: .nature),
        PromptSuggestion(text: "Tropical reef underwater",      icon: "fish",               category: .nature),
        // Urban
        PromptSuggestion(text: "Tokyo neon at night",           icon: "building.2",         category: .urban),
        PromptSuggestion(text: "New York concrete jungle",      icon: "building.columns",   category: .urban),
        PromptSuggestion(text: "Paris café in morning light",   icon: "cup.and.saucer",     category: .urban),
        PromptSuggestion(text: "Cyberpunk megacity",            icon: "bolt",               category: .urban),
        PromptSuggestion(text: "Brutalist architecture",        icon: "rectangle.3.group",  category: .urban),
        // Mood
        PromptSuggestion(text: "Calm meditation space",         icon: "brain.head.profile", category: .mood),
        PromptSuggestion(text: "Playful children's toy room",   icon: "puzzlepiece",        category: .mood),
        PromptSuggestion(text: "Luxury boutique hotel lobby",   icon: "crown",              category: .mood),
        PromptSuggestion(text: "Dark romance and mystery",      icon: "moon.stars",         category: .mood),
        PromptSuggestion(text: "Energetic fitness brand",       icon: "bolt.circle",        category: .mood),
        // Design
        PromptSuggestion(text: "Fintech dashboard UI",          icon: "chart.bar",          category: .design),
        PromptSuggestion(text: "Minimal Scandinavian app",      icon: "square.split.2x1",   category: .design),
        PromptSuggestion(text: "Healthcare patient app",        icon: "cross",              category: .design),
        PromptSuggestion(text: "Gaming HUD interface",          icon: "gamecontroller",     category: .design),
        PromptSuggestion(text: "Editorial magazine layout",     icon: "newspaper",          category: .design),
        // Abstract
        PromptSuggestion(text: "Vaporwave dreamscape",          icon: "waveform",           category: .abstract),
        PromptSuggestion(text: "Cosmic nebula and starlight",   icon: "sparkles",           category: .abstract),
        PromptSuggestion(text: "Melting wax and pigment",       icon: "paintbrush",         category: .abstract),
        PromptSuggestion(text: "Gradient energy flow",          icon: "wind",               category: .abstract),
    ]

    static func random(_ count: Int = 8) -> [PromptSuggestion] {
        Array(all.shuffled().prefix(count))
    }
}

// MARK: - Prompt History Entry

struct PromptHistoryEntry: Identifiable, Equatable, Codable {
    var id:        UUID   = UUID()
    var prompt:    String
    var style:     String
    var colorCount: Int
    var paletteName: String
    var savedAt:   Date   = .now
}

// MARK: - API Key Status

enum APIKeyStatus {
    case notSet
    case set(String)   // masked display
}

// MARK: - Anthropic Request / Response helpers

struct AnthropicMessage: Codable {
    let role: String
    let content: String
}

struct AnthropicRequest: Codable {
    let model: String
    let max_tokens: Int
    let system: String
    let messages: [AnthropicMessage]
}

struct AnthropicTextBlock: Codable {
    let type: String
    let text: String?
}

struct AnthropicResponse: Codable {
    let content: [AnthropicTextBlock]
    let stop_reason: String?
}
