//
//  SymbolEffectsConfig.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  State describing one natively-animated SF Symbol for the Symbol Effects tool.
//

import SwiftUI

struct SymbolEffectsConfig: Equatable {
    var symbolName: String
    var kind: SymbolEffectKind
    var size: CGFloat
    var speed: Double
    var primaryColor: Color
    var isPlaying: Bool
    var backgroundIsDark: Bool

    static let `default` = SymbolEffectsConfig(
        symbolName: "bell.fill",
        kind: .bounce,
        size: 120,
        speed: 1.0,
        primaryColor: Color(hex: "#7B6EF6"),
        isPlaying: true,
        backgroundIsDark: true
    )

    /// Curated quick-pick symbols that read well when animated.
    static let quickPickSymbols = [
        "bell.fill", "heart.fill", "star.fill", "bolt.fill",
        "arrow.triangle.2.circlepath", "wifi", "speaker.wave.3.fill",
        "gearshape.fill", "cloud.rain.fill", "hourglass", "flame.fill", "trophy.fill"
    ]
}
