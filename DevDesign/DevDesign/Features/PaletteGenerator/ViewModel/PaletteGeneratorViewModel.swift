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

    /// Incremented whenever randomise() or selectHarmony() fires so that
    /// ColorWheelPickerView can force-sync its fields and resign focus.
    private(set) var forceSyncTrigger: Int = 0

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

    /// Called by sliders / HEX field — mutates colors IN PLACE so entry IDs
    /// stay the same and the swatch list does NOT animate/re-order.
    func updateBaseColor(_ color: DevColor) {
        baseColor = color
        updateInPlace()
    }

    /// Called by the Randomise button — replaces entries with NEW UUIDs so
    /// the swatch list animates (intentional — randomise feels dramatic).
    func randomise() {
        let hue        = Double.random(in: 0...360)
        let saturation = Double.random(in: 0.4...0.85)
        let lightness  = Double.random(in: 0.35...0.65)
        baseColor = DevColor(hue: hue, saturation: saturation, lightness: lightness)
        forceSyncTrigger &+= 1   // signals picker to dismiss focus & force-sync
        regenerate()
    }

    /// Called by the Regenerate (↺) toolbar button — replaces unlocked entries,
    /// preserving locked ones. Uses new UUIDs → swatch list animates.
    func regenerate() {
        let newPalette = HarmonyEngine.generate(from: baseColor, type: selectedHarmony)

        if generatedColors.isEmpty {
            generatedColors = newPalette.map { PaletteEntry(color: $0) }
        } else {
            var newEntries = newPalette.map { PaletteEntry(color: $0) }
            while newEntries.count < generatedColors.count {
                newEntries.append(PaletteEntry(color: baseColor))
            }
            for (i, entry) in generatedColors.enumerated() where entry.isLocked {
                if i < newEntries.count { newEntries[i] = entry }
            }
            generatedColors = newEntries
        }
    }

    /// Called when harmony pill changes — resets everything and animates the list.
    func selectHarmony(_ type: HarmonyType) {
        selectedHarmony = type
        generatedColors = []
        forceSyncTrigger &+= 1   // signals picker to dismiss focus & force-sync
        regenerate()
    }

    /// Toggle lock on a specific swatch
    func toggleLock(at index: Int) {
        guard index < generatedColors.count else { return }
        generatedColors[index].isLocked.toggle()
    }

    // MARK: - Private

    /// Mutates the `.color` on each existing entry without touching their IDs.
    /// Locked entries keep their color. Result: zero list animation.
    private func updateInPlace() {
        let newPalette = HarmonyEngine.generate(from: baseColor, type: selectedHarmony)

        if generatedColors.isEmpty {
            // First boot — no entries yet, must create them
            generatedColors = newPalette.map { PaletteEntry(color: $0) }
            return
        }

        for (i, newColor) in newPalette.enumerated() {
            guard i < generatedColors.count else { break }
            guard !generatedColors[i].isLocked else { continue }  // skip locked
            generatedColors[i].color = newColor                   // mutate in place ✓
        }

        // Handle harmony type change that produces more/fewer colors than current entries
        if newPalette.count > generatedColors.count {
            let extra = newPalette[generatedColors.count...]
            generatedColors.append(contentsOf: extra.map { PaletteEntry(color: $0) })
        } else if newPalette.count < generatedColors.count {
            generatedColors = Array(generatedColors.prefix(newPalette.count))
        }
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
