//
//  MetalSymbolConfig.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  Value type describing everything needed to render and export one
//  animated SF Symbol. Drives both the live preview and the code export.
//

import SwiftUI

struct MetalSymbolConfig: Equatable {
    var symbolName: String
    var effect: MetalSymbolEffect
    var size: CGFloat
    var speed: Double
    var intensity: Double
    var primaryColor: Color
    var secondaryColor: Color
    var isPlaying: Bool
    var backgroundIsDark: Bool

    /// Starting state when the tool first opens.
    static let `default` = MetalSymbolConfig.make(for: .shimmer,
                                                  symbolName: "bolt.fill",
                                                  backgroundIsDark: true)

    /// Tuned defaults per effect so switching effects always looks good.
    static func make(for effect: MetalSymbolEffect,
                     symbolName: String,
                     backgroundIsDark: Bool) -> MetalSymbolConfig {
        switch effect {
        case .shimmer:
            return MetalSymbolConfig(symbolName: symbolName, effect: effect, size: 120,
                                     speed: 1.0, intensity: 0.8,
                                     primaryColor: Color(hex: "#7B6EF6"),
                                     secondaryColor: .white,
                                     isPlaying: true, backgroundIsDark: backgroundIsDark)
        case .gradientFlow:
            return MetalSymbolConfig(symbolName: symbolName, effect: effect, size: 120,
                                     speed: 1.0, intensity: 1.0,
                                     primaryColor: Color(hex: "#7B6EF6"),
                                     secondaryColor: Color(hex: "#FF6B9D"),
                                     isPlaying: true, backgroundIsDark: backgroundIsDark)
        case .noise:
            return MetalSymbolConfig(symbolName: symbolName, effect: effect, size: 120,
                                     speed: 1.0, intensity: 4.0,
                                     primaryColor: Color(hex: "#64D2FF"),
                                     secondaryColor: .white,
                                     isPlaying: true, backgroundIsDark: backgroundIsDark)
        case .liquidMetal:
            return MetalSymbolConfig(symbolName: symbolName, effect: effect, size: 120,
                                     speed: 1.0, intensity: 0.6,
                                     primaryColor: Color(hex: "#B0B6C2"),
                                     secondaryColor: .white,
                                     isPlaying: true, backgroundIsDark: backgroundIsDark)
        }
    }

    /// Curated quick-pick symbols shown beneath the name field.
    static let quickPickSymbols = [
        "bolt.fill", "heart.fill", "star.fill", "flame.fill",
        "drop.fill", "moon.stars.fill", "sparkles", "crown.fill",
        "leaf.fill", "wand.and.stars", "cloud.bolt.fill", "globe"
    ]
}
