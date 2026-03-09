//
//  PaletteStyle.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

enum ColorCount: Int, CaseIterable, Identifiable {
    case four  = 4
    case six   = 6
    case eight = 8

    var id: Int { rawValue }
    var label: String { "\(rawValue)" }
}

enum PaletteStyle: String, CaseIterable, Identifiable {
    case vibrant    = "Vibrant"
    case muted      = "Muted"
    case dark       = "Dark"
    case light      = "Light"
    case pastel     = "Pastel"
    case neon       = "Neon"
    case monochrome = "Mono"
    case earthy     = "Earthy"
    case any        = "Any"

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
