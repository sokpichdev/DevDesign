//
//  SymbolEffectKind.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  Apple's native SF Symbol animations (.symbolEffect), iOS 17/18.
//  Distinct from the Metal Symbols tool: these animate the symbol's own
//  layers semantically rather than recolouring pixels with a shader.
//

import SwiftUI

enum SymbolEffectKind: String, CaseIterable, Identifiable {
    case bounce
    case pulse
    case variableColor
    case wiggle
    case breathe
    case rotate

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bounce:        return "Bounce"
        case .pulse:         return "Pulse"
        case .variableColor: return "Variable Color"
        case .wiggle:        return "Wiggle"
        case .breathe:       return "Breathe"
        case .rotate:        return "Rotate"
        }
    }

    /// SF Symbol used as the chip icon.
    var icon: String {
        switch self {
        case .bounce:        return "arrow.up.circle"
        case .pulse:         return "waveform.path.ecg"
        case .variableColor: return "circle.hexagongrid"
        case .wiggle:        return "hand.wave"
        case .breathe:       return "lungs"
        case .rotate:        return "arrow.clockwise"
        }
    }

    /// Indefinite effects run continuously while active (driven by `isActive:`);
    /// discrete effects play once per trigger (we re-fire them on a tick).
    var isDiscrete: Bool {
        switch self {
        case .bounce, .wiggle, .rotate: return true
        case .pulse, .variableColor, .breathe: return false
        }
    }

    /// The literal effect value used in exported `.symbolEffect(...)` code.
    var effectLiteral: String {
        switch self {
        case .bounce:        return ".bounce"
        case .pulse:         return ".pulse"
        case .variableColor: return ".variableColor.iterative"
        case .wiggle:        return ".wiggle"
        case .breathe:       return ".breathe"
        case .rotate:        return ".rotate"
        }
    }
}
