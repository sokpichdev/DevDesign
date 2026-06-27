//
//  MetalSymbolView.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  The reusable unit: renders an SF Symbol and applies the selected Metal
//  shader effect, animated each frame via TimelineView. This is conceptually
//  the view the user "copies" out of the tool.
//

import SwiftUI

struct MetalSymbolView: View {

    let config: MetalSymbolConfig

    @State private var startDate = Date()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Honour Reduce Motion: hold a static frame instead of animating.
    private var isAnimating: Bool { config.isPlaying && !reduceMotion }

    var body: some View {
        TimelineView(.animation(paused: !isAnimating)) { context in
            let time = isAnimating
                ? Float(startDate.distance(to: context.date))
                : 0

            effected(time: time)
                .accessibilityElement()
                .accessibilityLabel("\(config.symbolName), \(config.effect.displayName) effect")
        }
    }

    // The base symbol before any shader is applied.
    private var symbol: some View {
        Image(systemName: config.symbolName)
            .resizable()
            .scaledToFit()
            .frame(width: config.size, height: config.size)
            .foregroundStyle(config.primaryColor)
    }

    // Applies the effect's shader. @ViewBuilder because colorEffect and
    // distortionEffect produce different concrete types.
    @ViewBuilder
    private func effected(time: Float) -> some View {
        switch config.effect {
        case .shimmer:
            symbol.colorEffect(
                ShaderLibrary.shimmer(
                    .boundingRect,
                    .float(time),
                    .float(Float(config.speed)),
                    .float(Float(config.intensity))
                )
            )
        case .gradientFlow:
            symbol.colorEffect(
                ShaderLibrary.gradientFlow(
                    .boundingRect,
                    .float(time),
                    .float(Float(config.speed)),
                    .color(config.primaryColor),
                    .color(config.secondaryColor)
                )
            )
        case .noise:
            symbol.distortionEffect(
                ShaderLibrary.noise(
                    .boundingRect,
                    .float(time),
                    .float(Float(config.speed)),
                    .float(Float(config.intensity))
                ),
                maxSampleOffset: CGSize(width: 24, height: 24)
            )
        case .liquidMetal:
            symbol.colorEffect(
                ShaderLibrary.liquidMetal(
                    .boundingRect,
                    .float(time),
                    .float(Float(config.speed)),
                    .float(Float(config.intensity)),
                    .color(config.primaryColor)
                )
            )
        }
    }
}
