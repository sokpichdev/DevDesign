//
//  PromptSuggestion.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

struct PromptSuggestion: Identifiable {
    let id       = UUID()
    let text:     String
    let icon:     String
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

// MARK: - Library

enum PromptSuggestionLibrary {
    static let all: [PromptSuggestion] = [
        // Nature
        PromptSuggestion(text: "Golden hour over a calm ocean",          icon: "sun.horizon",                    category: .nature),
        PromptSuggestion(text: "Lush botanical greens and damp earth",   icon: "leaf.arrow.triangle.circlepath", category: .nature),
        PromptSuggestion(text: "Frosty morning glacial blues",           icon: "snowflake",                      category: .nature),
        PromptSuggestion(text: "Warm terracotta and desert clay",        icon: "sun.max",                        category: .nature),
        PromptSuggestion(text: "Deep sea bioluminescent corals",         icon: "fish",                           category: .nature),
        // Urban
        PromptSuggestion(text: "Neon violet and midnight asphalt",       icon: "building.2",                     category: .urban),
        PromptSuggestion(text: "Industrial concrete and rusted steel",   icon: "hammer",                         category: .urban),
        PromptSuggestion(text: "Vintage Parisian café tones",            icon: "cup.and.saucer",                 category: .urban),
        PromptSuggestion(text: "Modern glass and steel skyscraper",      icon: "building.columns",               category: .urban),
        PromptSuggestion(text: "London fog and cobblestone grey",        icon: "cloud.fog",                      category: .urban),
        // Mood
        PromptSuggestion(text: "Serene zen spa and soft linen",          icon: "brain.head.profile",             category: .mood),
        PromptSuggestion(text: "High-energy neon fitness vibes",         icon: "bolt.heart",                     category: .mood),
        PromptSuggestion(text: "Elegant gold and royal velvet",          icon: "crown",                          category: .mood),
        PromptSuggestion(text: "Moody noir and crimson mystery",         icon: "moon.stars",                     category: .mood),
        PromptSuggestion(text: "Bright pastel candy shop joy",           icon: "mouth",                          category: .mood),
        // Design
        PromptSuggestion(text: "Clean fintech blue and slate",           icon: "chart.bar",                      category: .design),
        PromptSuggestion(text: "Minimalist Scandi wood and white",       icon: "square.split.2x1",               category: .design),
        PromptSuggestion(text: "High-contrast dark mode gaming UI",      icon: "gamecontroller",                 category: .design),
        PromptSuggestion(text: "Soft medical teal and sterile white",    icon: "cross",                          category: .design),
        PromptSuggestion(text: "Classic editorial parchment and ink",    icon: "newspaper",                      category: .design),
        // Abstract
        PromptSuggestion(text: "80s retro vaporwave aesthetic",          icon: "waveform",                       category: .abstract),
        PromptSuggestion(text: "Deep space nebula and stardust",         icon: "sparkles",                       category: .abstract),
        PromptSuggestion(text: "Iridescent oil slick on water",          icon: "drop.fill",                      category: .abstract),
        PromptSuggestion(text: "Vivid psychedelic color explosion",      icon: "rainbow",                        category: .abstract),
        PromptSuggestion(text: "Monochromatic architectural shadows",    icon: "rectangle.3.group",              category: .abstract),
    ]

    static func random(_ count: Int = 8) -> [PromptSuggestion] {
        Array(all.shuffled().prefix(count))
    }
}
