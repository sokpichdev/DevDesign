//
//  ScaleRatio.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Pure data + math. No UI dependencies.
// TypeScaleEngine is stateless — all logic is computed from inputs.

import Foundation

// MARK: - Scale Ratio

enum ScaleRatio: Double, CaseIterable, Identifiable, Codable {
    case minorSecond    = 1.067
    case majorSecond    = 1.125
    case minorThird     = 1.200
    case majorThird     = 1.250
    case perfectFourth  = 1.333
    case augmentedFourth = 1.414
    case perfectFifth   = 1.500
    case goldenRatio    = 1.618

    var id: Double { rawValue }

    var name: String {
        switch self {
        case .minorSecond:     return "Minor Second"
        case .majorSecond:     return "Major Second"
        case .minorThird:      return "Minor Third"
        case .majorThird:      return "Major Third"
        case .perfectFourth:   return "Perfect Fourth"
        case .augmentedFourth: return "Augmented Fourth"
        case .perfectFifth:    return "Perfect Fifth"
        case .goldenRatio:     return "Golden Ratio"
        }
    }

    var shortName: String {
        switch self {
        case .minorSecond:     return "1.067"
        case .majorSecond:     return "1.125"
        case .minorThird:      return "1.200"
        case .majorThird:      return "1.250"
        case .perfectFourth:   return "1.333"
        case .augmentedFourth: return "1.414"
        case .perfectFifth:    return "1.500"
        case .goldenRatio:     return "1.618"
        }
    }

    var description: String {
        switch self {
        case .minorSecond:     return "Very tight · Dense UIs"
        case .majorSecond:     return "Compact · Utilitarian"
        case .minorThird:      return "Balanced · Most apps ★"
        case .majorThird:      return "Slightly expressive"
        case .perfectFourth:   return "Classic · Web standard"
        case .augmentedFourth: return "Bold · Editorial"
        case .perfectFifth:    return "Dramatic hierarchy"
        case .goldenRatio:     return "Maximum drama"
        }
    }
}

// MARK: - Type Scale Step
// Represents one named level in the scale.

struct TypeScaleStep: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String          // e.g. "Display", "Title 1", "Body"
    var tokenName: String     // e.g. "displayLarge" — used in export
    var size: Double          // Computed font size in points
    var lineHeight: Double    // Recommended line height multiplier
    var tracking: Double      // Letter spacing (em units)
    var weight: FontWeightOption

    // Computed
    var lineHeightPt: Double { (size * lineHeight).rounded(.toNearestOrAwayFromZero) }

    // MARK: Default step names — a sensible starting set of 9 steps
    static let defaultNames: [(name: String, token: String, weight: FontWeightOption)] = [
        ("Display",   "display",    .bold),
        ("Title 1",   "title1",     .bold),
        ("Title 2",   "title2",     .semibold),
        ("Title 3",   "title3",     .semibold),
        ("Headline",  "headline",   .semibold),
        ("Body",      "body",       .regular),
        ("Callout",   "callout",    .regular),
        ("Caption",   "caption",    .regular),
        ("Footnote",  "footnote",   .regular),
    ]
}

// MARK: - Font Weight Option
// Codable-friendly wrapper so we can store weight in SwiftData / JSON.
enum FontWeightOption: String, CaseIterable, Identifiable, Codable {
    case ultraLight = "Ultra Light"
    case thin       = "Thin"
    case light      = "Light"
    case regular    = "Regular"
    case medium     = "Medium"
    case semibold   = "Semibold"
    case bold       = "Bold"
    case heavy      = "Heavy"
    case black      = "Black"

    var id: String { rawValue }

    var swiftUIValue: String {
        switch self {
        case .ultraLight: return ".ultraLight"
        case .thin:       return ".thin"
        case .light:      return ".light"
        case .regular:    return ".regular"
        case .medium:     return ".medium"
        case .semibold:   return ".semibold"
        case .bold:       return ".bold"
        case .heavy:      return ".heavy"
        case .black:      return ".black"
        }
    }

    var cssValue: String {
        switch self {
        case .ultraLight: return "100"
        case .thin:       return "200"
        case .light:      return "300"
        case .regular:    return "400"
        case .medium:     return "500"
        case .semibold:   return "600"
        case .bold:       return "700"
        case .heavy:      return "800"
        case .black:      return "900"
        }
    }
}

// MARK: - Type Scale Engine
// Pure stateless math — all functions are static.

enum TypeScaleEngine {

    /// Generate a full set of TypeScaleSteps from a base size and ratio.
    /// Steps go from largest (Display) down to smallest (Footnote).
    /// The base size maps to the "Body" step (index 5 in defaultNames).
    static func generate(baseSize: Double, ratio: ScaleRatio) -> [TypeScaleStep] {
        let baseIndex = 5   // "Body" is the anchor
        return TypeScaleStep.defaultNames.enumerated().map { (i, meta) in
            let stepsFromBase = baseIndex - i   // positive = above base, negative = below
            let size = computeSize(base: baseSize, ratio: ratio.rawValue, steps: stepsFromBase)
            let lineHeight = recommendedLineHeight(size: size)
            return TypeScaleStep(
                id: UUID(),
                name: meta.name,
                tokenName: meta.token,
                size: size,
                lineHeight: lineHeight,
                tracking: recommendedTracking(size: size),
                weight: meta.weight
            )
        }
    }

    /// Compute size: base × ratio^steps (positive = larger, negative = smaller)
    static func computeSize(base: Double, ratio: Double, steps: Int) -> Double {
        let raw = base * pow(ratio, Double(steps))
        return (raw * 10).rounded() / 10   // 1 decimal place
    }

    /// Recommended line height multiplier by size range
    static func recommendedLineHeight(size: Double) -> Double {
        switch size {
        case ..<14:  return 1.6
        case ..<18:  return 1.5
        case ..<24:  return 1.4
        case ..<32:  return 1.3
        default:     return 1.2
        }
    }

    /// Recommended tracking (letter-spacing) — tighter for large, looser for small
    static func recommendedTracking(size: Double) -> Double {
        switch size {
        case ..<12:  return 0.04
        case ..<16:  return 0.02
        case ..<24:  return 0.00
        case ..<32:  return -0.01
        default:     return -0.02
        }
    }
}

// MARK: - Type Scale Export

enum TypeScaleExportService {

    static func exportSwiftUI(_ steps: [TypeScaleStep], fontName: String? = nil) -> String {
        var lines = [
            "import SwiftUI",
            "",
            "// Generated by DevDesign",
            "enum AppTypography {",
        ]
        for step in steps {
            let size = formatSize(step.size)
            let font = fontName.map { "Font.custom(\"\($0)\", size: \(size))" }
                ?? "Font.system(size: \(size), weight: \(step.weight.swiftUIValue))"
            lines.append("    static let \(step.tokenName) = \(font)")
        }
        lines += ["}"]
        return lines.joined(separator: "\n")
    }

    static func exportSwiftEnum(_ steps: [TypeScaleStep]) -> String {
        var lines = [
            "// Generated by DevDesign",
            "enum AppTypography {",
            "",
            "    // MARK: - Font Sizes",
        ]
        for step in steps {
            lines.append("    static let \(step.tokenName)Size: CGFloat = \(formatSize(step.size))")
        }
        lines += [
            "",
            "    // MARK: - Line Heights",
        ]
        for step in steps {
            lines.append("    static let \(step.tokenName)LineHeight: CGFloat = \(formatSize(step.lineHeightPt))")
        }
        lines += ["}"]
        return lines.joined(separator: "\n")
    }

    static func exportCSS(_ steps: [TypeScaleStep]) -> String {
        var lines = ["/* Generated by DevDesign */", ":root {"]
        for step in steps {
            lines.append("  --font-\(step.tokenName): \(formatSize(step.size))px;")
            lines.append("  --line-height-\(step.tokenName): \(String(format: "%.2f", step.lineHeight));")
            lines.append("  --weight-\(step.tokenName): \(step.weight.cssValue);")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    static func exportJSON(_ steps: [TypeScaleStep]) -> String {
        let dict: [String: Any] = [
            "generatedBy": "DevDesign",
            "typography": steps.map { step in
                [
                    "name": step.name,
                    "token": step.tokenName,
                    "size": step.size,
                    "lineHeight": step.lineHeight,
                    "lineHeightPt": step.lineHeightPt,
                    "tracking": step.tracking,
                    "weight": step.weight.rawValue
                ] as [String: Any]
            }
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let str = String(data: data, encoding: .utf8) else { return "{}" }
        return str
    }

    private static func formatSize(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", v)
            : String(format: "%.1f", v)
    }
}
