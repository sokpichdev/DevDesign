//
//  MetalSymbolEffect.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  The catalogue of GPU shader effects that can be applied to an SF Symbol.
//  Each case maps 1:1 to a [[stitchable]] function in Shaders/SymbolEffects.metal.
//

import SwiftUI

enum MetalSymbolEffect: String, CaseIterable, Identifiable {
    case shimmer
    case gradientFlow
    case noise
    case liquidMetal

    var id: String { rawValue }

    /// Human-facing name shown on the effect chip.
    var displayName: String {
        switch self {
        case .shimmer:      return "Shimmer"
        case .gradientFlow: return "Gradient Flow"
        case .noise:        return "Noise"
        case .liquidMetal:  return "Liquid Metal"
        }
    }

    /// SF Symbol used as the chip icon.
    var icon: String {
        switch self {
        case .shimmer:      return "sparkles"
        case .gradientFlow: return "drop.halffull"
        case .noise:        return "waveform"
        case .liquidMetal:  return "circle.hexagongrid.fill"
        }
    }

    /// The `[[stitchable]]` function name inside `SymbolEffects.metal`.
    var shaderFunctionName: String { rawValue }

    /// `noise` warps geometry via `.distortionEffect`; the rest recolor via `.colorEffect`.
    var isDistortion: Bool { self == .noise }

    /// Whether the effect uses the primary colour control (as fill or tint).
    var usesPrimaryColor: Bool { self != .noise }

    /// Only the gradient effect blends between two colours.
    var usesSecondaryColor: Bool { self == .gradientFlow }

    /// Whether an intensity slider is meaningful for this effect.
    var usesIntensity: Bool { self != .gradientFlow }

    /// Slider bounds + label for the intensity parameter (meaning differs per effect).
    var intensityRange: ClosedRange<Double> {
        switch self {
        case .noise:       return 0...8      // pixels of displacement
        default:           return 0...1      // normalised highlight strength
        }
    }

    var intensityLabel: String {
        switch self {
        case .noise:       return "Distortion"
        case .liquidMetal: return "Reflection"
        default:           return "Intensity"
        }
    }
}
