//
//  Color+Harmony.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Harmony algorithms that take a base DevColor and return a palette.
// Pure functions — no side effects, fully testable.

import SwiftUI

// MARK: - Harmony Type
enum HarmonyType: String, CaseIterable, Identifiable, Codable {
    case complementary       = "Complementary"
    case analogous           = "Analogous"
    case triadic             = "Triadic"
    case splitComplementary  = "Split-Comp"
    case tetradic            = "Tetradic"
    case monochromatic       = "Monochromatic"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .complementary:      return "Opposite on the wheel — high contrast, bold"
        case .analogous:          return "Neighbours — natural, harmonious"
        case .triadic:            return "3 equally spaced — vibrant, balanced"
        case .splitComplementary: return "Base + two adj. to complement — softer contrast"
        case .tetradic:           return "4 colours in rectangle — rich, complex"
        case .monochromatic:      return "Same hue, varied lightness — clean, cohesive"
        }
    }

    var icon: String {
        switch self {
        case .complementary:      return "circle.lefthalf.filled"
        case .analogous:          return "circle.grid.3x3"
        case .triadic:            return "triangle"
        case .splitComplementary: return "arrow.triangle.branch"
        case .tetradic:           return "rectangle"
        case .monochromatic:      return "circle.fill"
        }
    }
}

// MARK: - Harmony Engine
enum HarmonyEngine {

    /// Generate a palette of DevColors from a base color and harmony type.
    static func generate(from base: DevColor, type harmonyType: HarmonyType) -> [DevColor] {
        let (h, s, l) = base.hsl
        switch harmonyType {
        case .complementary:
            return [base, devColor(h: rotate(h, by: 180), s: s, l: l)]

        case .analogous:
            return [
                devColor(h: rotate(h, by: -30), s: s, l: l),
                base,
                devColor(h: rotate(h, by:  30), s: s, l: l)
            ]

        case .triadic:
            return [
                base,
                devColor(h: rotate(h, by: 120), s: s, l: l),
                devColor(h: rotate(h, by: 240), s: s, l: l)
            ]

        case .splitComplementary:
            return [
                base,
                devColor(h: rotate(h, by: 150), s: s, l: l),
                devColor(h: rotate(h, by: 210), s: s, l: l)
            ]

        case .tetradic:
            return [
                base,
                devColor(h: rotate(h, by:  90), s: s, l: l),
                devColor(h: rotate(h, by: 180), s: s, l: l),
                devColor(h: rotate(h, by: 270), s: s, l: l)
            ]

        case .monochromatic:
            // 5 steps: darkest → base → lightest
            return [
                devColor(h: h, s: s, l: max(l - 30, 5)),
                devColor(h: h, s: s, l: max(l - 15, 5)),
                base,
                devColor(h: h, s: s, l: min(l + 15, 95)),
                devColor(h: h, s: s, l: min(l + 30, 95))
            ]
        }
    }

    /// Generate all harmony types at once (used for palette explorer)
    static func generateAll(from base: DevColor) -> [HarmonyType: [DevColor]] {
        Dictionary(uniqueKeysWithValues: HarmonyType.allCases.map { type in
            (type, generate(from: base, type: type))
        })
    }

    // MARK: - Private Helpers

    private static func rotate(_ hue: Double, by degrees: Double) -> Double {
        var result = hue + degrees
        while result >= 360 { result -= 360 }
        while result < 0    { result += 360 }
        return result
    }

    private static func devColor(h: Double, s: Double, l: Double) -> DevColor {
        DevColor(hue: h, saturation: s / 100, lightness: l / 100)
    }
}

// MARK: - DevColor Harmony Convenience
extension DevColor {

    /// Return a harmony palette from this color
    func harmony(_ type: HarmonyType) -> [DevColor] {
        HarmonyEngine.generate(from: self, type: type)
    }

    /// Return the complementary color
    var complementary: DevColor {
        HarmonyEngine.generate(from: self, type: .complementary).last!
    }
}
