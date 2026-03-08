//
//  ColorPickerViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import Observation

@Observable
final class ColorPickerViewModel {

    // MARK: - State
    var selectedColor: DevColor = DevColor(hue: 240, saturation: 0.65, lightness: 0.55)
    var selectedFormat: ExportFormat = .swiftUI
    var recentColors: [DevColor] = []
    var showCopiedFeedback: Bool = false
    var copiedFormat: ExportFormat? = nil

    /// Signals ColorWheelPickerView to force-sync its fields (same pattern as PaletteGenerator)
    private(set) var forceSyncTrigger: Int = 0

    // MARK: - Computed

    /// The formatted code string for the current color + format
    var exportedCode: String {
        ExportService.export(selectedColor, as: selectedFormat)
    }

    /// Preview label shown in the code panel header
    var formatDescription: String {
        switch selectedFormat {
        case .swiftUI:    return "Paste directly into SwiftUI"
        case .uiKit:      return "Paste directly into UIKit"
        case .css:        return "CSS · works in rgba or rgb"
        case .hex:        return "Universal hex color code"
        case .rgb:        return "Red · Green · Blue (0–255)"
        case .hsl:        return "Hue · Saturation · Lightness"
        case .androidXML: return "Android XML · ARGB format"
        }
    }

    // MARK: - Actions

    /// Update selected color and push to recent history
    func selectColor(_ color: DevColor) {
        selectedColor = color
        pushToRecent(color)
    }

    /// Tap a recent color — force-syncs the picker field too
    func selectRecentColor(_ color: DevColor) {
        selectedColor = color
        forceSyncTrigger &+= 1
    }

    /// Copy current export string to clipboard
    func copyCurrentExport() {
        UIPasteboard.general.string = exportedCode
        copiedFormat = selectedFormat
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            withAnimation { self?.showCopiedFeedback = false }
        }
    }

    /// Copy a specific format without changing the selected format tab
    func copy(as format: ExportFormat) {
        UIPasteboard.general.string = ExportService.export(selectedColor, as: format)
        copiedFormat = format
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            withAnimation { self?.showCopiedFeedback = false }
        }
    }

    /// Clear recent colors
    func clearRecent() {
        withAnimation { recentColors = [] }
    }

    // MARK: - Private

    private func pushToRecent(_ color: DevColor) {
        // Avoid exact duplicates at the front
        if recentColors.first?.hex == color.hex { return }
        recentColors.removeAll { $0.hex == color.hex }
        recentColors.insert(color, at: 0)
        if recentColors.count > 12 { recentColors = Array(recentColors.prefix(12)) }
    }
}
