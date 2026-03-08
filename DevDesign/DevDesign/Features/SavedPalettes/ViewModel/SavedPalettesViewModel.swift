//
//  SavedPalettesViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class SavedPalettesViewModel {

    // MARK: - UI State
    var displayMode: DisplayMode = .grid
    var searchText: String = ""
    var selectedPalette: SavedPalette? = nil
    var paletteToRename: SavedPalette? = nil
    var paletteToExport: SavedPalette? = nil
    var renameText: String = ""
    var showDeleteConfirm: Bool = false
    var paletteToDelete: SavedPalette? = nil
    var showCopiedToast: Bool = false
    var copiedMessage: String = ""

    enum DisplayMode: String, CaseIterable {
        case grid = "square.grid.2x2"
        case list = "list.bullet"
    }

    // MARK: - Filtering

    func filtered(_ palettes: [SavedPalette]) -> [SavedPalette] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return palettes
        }
        return palettes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.harmonyType.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Delete

    func confirmDelete(_ palette: SavedPalette) {
        paletteToDelete = palette
        showDeleteConfirm = true
    }

    func delete(_ palette: SavedPalette, context: ModelContext) {
        context.delete(palette)
        try? context.save()
        paletteToDelete = nil
    }

    // MARK: - Rename

    func beginRename(_ palette: SavedPalette) {
        paletteToRename = palette
        renameText = palette.name
    }

    func commitRename(context: ModelContext) {
        guard let palette = paletteToRename else { return }
        let trimmed = renameText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        palette.name = trimmed
        palette.updatedAt = .now
        try? context.save()
        paletteToRename = nil
        renameText = ""
    }

    func cancelRename() {
        paletteToRename = nil
        renameText = ""
    }

    // MARK: - Export

    func exportAsJSON(_ palette: SavedPalette) -> String {
        let colorDicts = palette.colors.map { c in
            ["hex": c.hex, "r": Int(c.red * 255),
             "g": Int(c.green * 255), "b": Int(c.blue * 255)]
        }
        let dict: [String: Any] = [
            "name": palette.name,
            "harmony": palette.harmonyType,
            "colors": colorDicts
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else { return "{}" }
        return string
    }

    func exportAsSwiftUI(_ palette: SavedPalette) -> String {
        let devColors = palette.colors.map {
            DevColor(red: $0.red, green: $0.green, blue: $0.blue, alpha: $0.alpha)
        }
        return ExportService.exportPalette(devColors, name: palette.name, as: .swiftUI)
    }

    func exportAsCSS(_ palette: SavedPalette) -> String {
        let devColors = palette.colors.map {
            DevColor(red: $0.red, green: $0.green, blue: $0.blue, alpha: $0.alpha)
        }
        return ExportService.exportPalette(devColors, name: palette.name, as: .css)
    }

    func copyToClipboard(_ string: String, label: String) {
        UIPasteboard.general.string = string
        copiedMessage = "\(label) copied!"
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }

    // MARK: - Image Export
    // Renders the palette swatch strip to a UIImage for sharing.
    @MainActor
    func renderPaletteImage(_ palette: SavedPalette) -> UIImage {
        let swatchWidth: CGFloat = 80
        let height: CGFloat = 120
        let count = CGFloat(palette.colors.count)
        let totalWidth = swatchWidth * count
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: height))

        return renderer.image { ctx in
            for (i, savedColor) in palette.colors.enumerated() {
                let color = UIColor(red: savedColor.red, green: savedColor.green,
                                   blue: savedColor.blue, alpha: savedColor.alpha)
                color.setFill()
                let rect = CGRect(x: CGFloat(i) * swatchWidth, y: 0,
                                  width: swatchWidth, height: height - 24)
                ctx.fill(rect)

                // HEX label below each swatch
                let hex = savedColor.hex
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 9, weight: .medium),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let labelRect = CGRect(x: CGFloat(i) * swatchWidth + 4,
                                      y: height - 22, width: swatchWidth - 8, height: 18)
                hex.draw(in: labelRect, withAttributes: attrs)
            }

            // Palette name at the bottom
            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
            palette.name.draw(
                at: CGPoint(x: 8, y: height - 22),
                withAttributes: nameAttrs
            )
        }
    }
}
