//
//  SymbolEffectPreview.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  Reusable view that renders an SF Symbol with Apple's native .symbolEffect.
//  Indefinite effects run via `isActive:`; discrete effects are re-fired on a
//  tick derived from TimelineView so the live preview loops.
//

import SwiftUI

struct SymbolEffectPreview: View {

    let config: SymbolEffectsConfig

    @State private var startDate = Date()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var active: Bool { config.isPlaying && !reduceMotion }

    // Seconds between discrete re-triggers (faster speed → shorter period).
    private var period: Double { max(0.25, 1.2 / max(config.speed, 0.1)) }

    var body: some View {
        TimelineView(.animation(paused: !active)) { context in
            let elapsed = active ? startDate.distance(to: context.date) : 0
            let tick = Int(elapsed / period)

            symbol
                .modifier(EffectModifier(kind: config.kind,
                                         speed: config.speed,
                                         active: active,
                                         tick: tick))
                .accessibilityElement()
                .accessibilityLabel("\(config.symbolName), \(config.kind.displayName) effect")
        }
    }

    private var symbol: some View {
        Image(systemName: config.symbolName)
            .resizable()
            .scaledToFit()
            .frame(width: config.size, height: config.size)
            .foregroundStyle(config.primaryColor)
    }
}

// MARK: - Effect Modifier

/// Applies the correct strongly-typed `.symbolEffect` overload for the kind.
private struct EffectModifier: ViewModifier {
    let kind: SymbolEffectKind
    let speed: Double
    let active: Bool
    let tick: Int

    private var options: SymbolEffectOptions { .speed(speed) }

    @ViewBuilder
    func body(content: Content) -> some View {
        switch kind {
        // Indefinite — animate while active.
        case .pulse:
            content.symbolEffect(.pulse, options: options, isActive: active)
        case .variableColor:
            content.symbolEffect(.variableColor.iterative, options: options, isActive: active)
        case .breathe:
            content.symbolEffect(.breathe, options: options, isActive: active)
        // Discrete — re-fire each tick.
        case .bounce:
            content.symbolEffect(.bounce, options: options.nonRepeating, value: tick)
        case .wiggle:
            content.symbolEffect(.wiggle, options: options.nonRepeating, value: tick)
        case .rotate:
            content.symbolEffect(.rotate, options: options.nonRepeating, value: tick)
        }
    }
}
