//
//  PaletteGeneratorViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import Observation

@Observable
final class PaletteGeneratorViewModel {

    // MARK: - State
    var baseColor: DevColor = DevColor(hue: 240, saturation: 0.65, lightness: 0.55)
    var selectedHarmony: HarmonyType = .complementary
    var generatedColors: [PaletteEntry] = []
    var showSaveSheet: Bool = false
    var paletteName: String = ""
    var saveSuccess: Bool = false

    // MARK: - Init
    init() {
        regenerate()
    }

    // MARK: - Computed
    var unlockedIndices: [Int] {
        generatedColors.indices.filter { !generatedColors[$0].isLocked }
    }

    var allColors: [DevColor] {
        generatedColors.map(\.color)
    }

    // MARK: - Actions

    /// Full regenerate — respects locked colors
    func regenerate() {
        let newPalette = HarmonyEngine.generate(from: baseColor, type: selectedHarmony)

        if generatedColors.isEmpty {
            // First load — build fresh entries
            generatedColors = newPalette.map { PaletteEntry(color: $0) }
        } else {
            // Preserve locked entries, replace unlocked ones
            var newEntries = newPalette.map { PaletteEntry(color: $0) }

            // Pad or trim to match existing count if needed
            while newEntries.count < generatedColors.count {
                newEntries.append(PaletteEntry(color: baseColor))
            }

            for (i, entry) in generatedColors.enumerated() where entry.isLocked {
                if i < newEntries.count {
                    newEntries[i] = entry
                }
            }
            generatedColors = newEntries
        }
    }

    /// Randomise the base color, then regenerate
    func randomise() {
        let hue        = Double.random(in: 0...360)
        let saturation = Double.random(in: 0.4...0.85)  // avoid muddy or washed out
        let lightness  = Double.random(in: 0.35...0.65) // avoid too dark / too light
        baseColor = DevColor(hue: hue, saturation: saturation, lightness: lightness)
        regenerate()
    }

    /// Toggle lock on a specific swatch
    func toggleLock(at index: Int) {
        guard index < generatedColors.count else { return }
        generatedColors[index].isLocked.toggle()
    }

    /// Update base color and regenerate
    func updateBaseColor(_ color: DevColor) {
        baseColor = color
        regenerate()
    }

    /// Switch harmony type and regenerate
    func selectHarmony(_ type: HarmonyType) {
        selectedHarmony = type
        generatedColors = []   // reset locks when harmony changes
        regenerate()
    }

    /// Copy a single color to clipboard
    func copyColor(_ color: DevColor, as format: ExportFormat = .hex) {
        UIPasteboard.general.string = ExportService.export(color, as: format)
    }

    /// Copy entire palette as SwiftUI extension
    func copyPalette(as format: ExportFormat = .swiftUI) {
        let name = paletteName.isEmpty ? "MyPalette" : paletteName
        UIPasteboard.general.string = ExportService.exportPalette(allColors, name: name, as: format)
    }

    /// Build a SavedPalette SwiftData object ready to insert
    func buildSavedPalette() -> SavedPalette {
        let savedColors = generatedColors.map { entry in
            SavedColor(
                hex:   entry.color.hex,
                red:   entry.color.red,
                green: entry.color.green,
                blue:  entry.color.blue,
                alpha: entry.color.alpha
            )
        }
        return SavedPalette(
            name:        paletteName.isEmpty ? "Untitled Palette" : paletteName,
            colors:      savedColors,
            harmonyType: selectedHarmony.rawValue
        )
    }
}

// MARK: - PaletteEntry
// A color inside the generator with its locked state.
struct PaletteEntry: Identifiable, Equatable {
    let id: UUID = UUID()
    var color: DevColor
    var isLocked: Bool = false
}
