//
//  Color+Contrast.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// WCAG 2.1 contrast ratio calculations + pass/fail evaluation.
// Reference: https://www.w3.org/TR/WCAG21/#contrast-minimum

import SwiftUI

// MARK: - WCAG Level
enum WCAGLevel {
    case aa, aaa
}

// MARK: - WCAG Context
enum WCAGContext: String, CaseIterable {
    case normalText  = "Normal Text"   // < 18pt or < 14pt bold
    case largeText   = "Large Text"    // ≥ 18pt or ≥ 14pt bold
    case uiComponent = "UI Component"  // Borders, icons, input outlines

    var minimumRatio: (aa: Double, aaa: Double) {
        switch self {
        case .normalText:  return (aa: 4.5, aaa: 7.0)
        case .largeText:   return (aa: 3.0, aaa: 4.5)
        case .uiComponent: return (aa: 3.0, aaa: 3.0)
        }
    }
}

// MARK: - Contrast Result
struct ContrastResult {
    let ratio: Double
    let foreground: DevColor
    let background: DevColor

    // WCAG pass/fail per context
    func passes(_ level: WCAGLevel, context: WCAGContext) -> Bool {
        let threshold = context.minimumRatio
        return ratio >= (level == .aa ? threshold.aa : threshold.aaa)
    }

    // Convenience
    var passesAA:  Bool { passes(.aa,  context: .normalText) }
    var passesAAA: Bool { passes(.aaa, context: .normalText) }
    var passesAALargeText: Bool  { passes(.aa,  context: .largeText) }
    var passesAAALargeText: Bool { passes(.aaa, context: .largeText) }
    var passesAAUI: Bool { passes(.aa, context: .uiComponent) }

    // Human-readable ratio e.g. "4.54:1"
    var ratioString: String {
        String(format: "%.2f:1", ratio)
    }

    // Rating label
    var rating: String {
        if ratio >= 7.0  { return "AAA" }
        if ratio >= 4.5  { return "AA" }
        if ratio >= 3.0  { return "AA Large" }
        return "Fail"
    }

    var ratingColor: DevColor {
        if ratio >= 4.5  { return DevColor(hex: "#34C759")! }  // green
        if ratio >= 3.0  { return DevColor(hex: "#FF9F0A")! }  // yellow
        return DevColor(hex: "#FF453A")!                        // red
    }
}

// MARK: - Contrast Engine
enum ContrastEngine {

    /// Calculate WCAG contrast ratio between two colors.
    /// Formula: (L1 + 0.05) / (L2 + 0.05) where L1 is the lighter color.
    static func contrastRatio(foreground: DevColor, background: DevColor) -> Double {
        let l1 = foreground.luminance
        let l2 = background.luminance
        let lighter = max(l1, l2)
        let darker  = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Full contrast evaluation
    static func evaluate(foreground: DevColor, background: DevColor) -> ContrastResult {
        ContrastResult(
            ratio: contrastRatio(foreground: foreground, background: background),
            foreground: foreground,
            background: background
        )
    }

    /// Suggest a foreground color that passes WCAG AA on the given background.
    /// Returns a darkened or lightened version of the original foreground.
    static func suggestPassingColor(
        foreground: DevColor,
        background: DevColor,
        targetRatio: Double = 4.5,
        maxIterations: Int = 50
    ) -> DevColor? {
        var candidate = foreground
        let bgLuminance = background.luminance

        for _ in 0..<maxIterations {
            let ratio = contrastRatio(foreground: candidate, background: background)
            if ratio >= targetRatio { return candidate }
            // Adjust toward higher contrast
            candidate = bgLuminance > 0.5
                ? candidate.darkened(by: 0.05)
                : candidate.lightened(by: 0.05)
        }
        return nil
    }
}

// MARK: - DevColor Contrast Convenience
extension DevColor {
    func contrastRatio(against other: DevColor) -> Double {
        ContrastEngine.contrastRatio(foreground: self, background: other)
    }

    func contrastResult(against other: DevColor) -> ContrastResult {
        ContrastEngine.evaluate(foreground: self, background: other)
    }
}
