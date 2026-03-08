//
//  ContrastCheckerViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import Observation

@Observable
final class ContrastCheckerViewModel {

    // MARK: - State
    var foreground: DevColor = DevColor(hex: "#FFFFFF")!
    var background: DevColor = DevColor(hex: "#1A1A2E")!
    var activeSelector: ColorRole = .foreground

    /// Signals ColorWheelPickerView to force-sync when colors are swapped/reset
    private(set) var fgSyncTrigger: Int = 0
    private(set) var bgSyncTrigger: Int = 0

    // MARK: - Color Role
    enum ColorRole: String {
        case foreground = "Foreground"
        case background = "Background"
    }

    // MARK: - Computed: Contrast

    var result: ContrastResult {
        ContrastEngine.evaluate(foreground: foreground, background: background)
    }

    var ratioString: String { result.ratioString }
    var rating: String      { result.rating }

    var ratingColor: Color {
        if result.ratio >= 7.0 { return DSColors.Preview.success }
        if result.ratio >= 4.5 { return DSColors.Preview.success }
        if result.ratio >= 3.0 { return DSColors.Preview.warning }
        return DSColors.Preview.error
    }

    // MARK: - WCAG Check Model

    struct WCAGCheck: Identifiable {
        let id = UUID()
        let context: WCAGContext
        let label: String
        let sublabel: String
        let aaPass: Bool
        let aaaPass: Bool
        let minRatioAA: Double
        let minRatioAAA: Double
    }

    var wcagChecks: [WCAGCheck] {[
        WCAGCheck(
            context: .normalText,
            label: "Normal Text",
            sublabel: "< 18pt  or  < 14pt bold",
            aaPass:  result.passes(.aa,  context: .normalText),
            aaaPass: result.passes(.aaa, context: .normalText),
            minRatioAA: 4.5, minRatioAAA: 7.0
        ),
        WCAGCheck(
            context: .largeText,
            label: "Large Text",
            sublabel: "≥ 18pt  or  ≥ 14pt bold",
            aaPass:  result.passes(.aa,  context: .largeText),
            aaaPass: result.passes(.aaa, context: .largeText),
            minRatioAA: 3.0, minRatioAAA: 4.5
        ),
        WCAGCheck(
            context: .uiComponent,
            label: "UI Component",
            sublabel: "Borders, icons, inputs",
            aaPass:  result.passes(.aa,  context: .uiComponent),
            aaaPass: result.passes(.aaa, context: .uiComponent),
            minRatioAA: 3.0, minRatioAAA: 3.0
        )
    ]}

    // MARK: - Fix Suggestions

    var fgSuggestion: DevColor? {
        guard !result.passesAA else { return nil }
        return ContrastEngine.suggestPassingColor(
            foreground: foreground,
            background: background,
            targetRatio: 4.5
        )
    }

    var bgSuggestion: DevColor? {
        guard !result.passesAA else { return nil }
        return ContrastEngine.suggestPassingColor(
            foreground: background,
            background: foreground,
            targetRatio: 4.5
        )
    }

    var hasSuggestions: Bool { fgSuggestion != nil || bgSuggestion != nil }

    // MARK: - Color Blindness Simulation

    struct ColorBlindPreview: Identifiable {
        let id = UUID()
        let name: String
        let description: String
        let affectedPercent: String
        let foreground: DevColor
        let background: DevColor
        var contrastRatio: Double {
            ContrastEngine.contrastRatio(foreground: foreground, background: background)
        }
        var ratioString: String {
            String(format: "%.2f:1", contrastRatio)
        }
    }

    var colorBlindPreviews: [ColorBlindPreview] {[
        ColorBlindPreview(
            name: "Normal",       description: "Standard vision",
            affectedPercent: "—",
            foreground: foreground, background: background
        ),
        ColorBlindPreview(
            name: "Deuteranopia", description: "Red-green · green weak",
            affectedPercent: "~6% ♂",
            foreground: simulateDeuteranopia(foreground),
            background: simulateDeuteranopia(background)
        ),
        ColorBlindPreview(
            name: "Protanopia",   description: "Red-green · red weak",
            affectedPercent: "~2% ♂",
            foreground: simulateProtanopia(foreground),
            background: simulateProtanopia(background)
        ),
        ColorBlindPreview(
            name: "Tritanopia",   description: "Blue-yellow",
            affectedPercent: "<0.01%",
            foreground: simulateTritanopia(foreground),
            background: simulateTritanopia(background)
        )
    ]}

    // MARK: - Actions

    func setForeground(_ color: DevColor) { foreground = color }
    func setBackground(_ color: DevColor) { background = color }

    func swapColors() {
        let tmp = foreground
        foreground = background
        background = tmp
        fgSyncTrigger &+= 1
        bgSyncTrigger &+= 1
    }

    func applyFgSuggestion() {
        guard let s = fgSuggestion else { return }
        foreground = s
        fgSyncTrigger &+= 1
    }

    func applyBgSuggestion() {
        guard let s = bgSuggestion else { return }
        background = s
        bgSyncTrigger &+= 1
    }

    func copyRatio() {
        UIPasteboard.general.string = ratioString
    }

    // MARK: - Color Blindness Simulation
    // Simplified dichromacy matrices — good enough for developer reference.

    private func simulateDeuteranopia(_ c: DevColor) -> DevColor {
        DevColor(
            red:   c.red * 0.625 + c.green * 0.375,
            green: c.red * 0.700 + c.green * 0.300,
            blue:  c.green * 0.300 + c.blue * 0.700
        )
    }

    private func simulateProtanopia(_ c: DevColor) -> DevColor {
        DevColor(
            red:   c.red * 0.567 + c.green * 0.433,
            green: c.red * 0.558 + c.green * 0.442,
            blue:  c.green * 0.242 + c.blue * 0.758
        )
    }

    private func simulateTritanopia(_ c: DevColor) -> DevColor {
        DevColor(
            red:   c.red * 0.950 + c.green * 0.050,
            green: c.green * 0.433 + c.blue * 0.567,
            blue:  c.green * 0.475 + c.blue * 0.525
        )
    }
}
