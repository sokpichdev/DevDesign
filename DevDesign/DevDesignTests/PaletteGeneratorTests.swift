//
//  PaletteGeneratorTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Tests for ViewModel logic — no UI, no SwiftData needed.
// Run: Cmd+U

import XCTest
@testable import DevDesign

final class PaletteGeneratorTests: XCTestCase {

    var viewModel: PaletteGeneratorViewModel!

    override func setUp() {
        super.setUp()
        viewModel = PaletteGeneratorViewModel()
    }

    // MARK: ─── Initial State ───────────────────────────────────────

    func test_initialGenerate_producesColors() {
        XCTAssertFalse(viewModel.generatedColors.isEmpty)
    }

    func test_initialHarmony_isComplementary() {
        XCTAssertEqual(viewModel.selectedHarmony, .complementary)
    }

    func test_complementary_producesTwoColors() {
        viewModel.selectHarmony(.complementary)
        XCTAssertEqual(viewModel.generatedColors.count, 2)
    }

    func test_monochromatic_producesFiveColors() {
        viewModel.selectHarmony(.monochromatic)
        XCTAssertEqual(viewModel.generatedColors.count, 5)
    }

    // MARK: ─── Lock & Regenerate ──────────────────────────────────

    func test_toggleLock_locksEntry() {
        viewModel.selectHarmony(.triadic) // 3 colors
        viewModel.toggleLock(at: 0)
        XCTAssertTrue(viewModel.generatedColors[0].isLocked)
    }

    func test_toggleLock_twice_unlocksEntry() {
        viewModel.selectHarmony(.triadic)
        viewModel.toggleLock(at: 1)
        viewModel.toggleLock(at: 1)
        XCTAssertFalse(viewModel.generatedColors[1].isLocked)
    }

    func test_regenerate_preservesLockedColor() {
        viewModel.selectHarmony(.triadic)
        viewModel.toggleLock(at: 0)
        let lockedColor = viewModel.generatedColors[0].color

        // Change base color and regenerate
        viewModel.baseColor = DevColor(hue: 90, saturation: 0.5, lightness: 0.5)
        viewModel.regenerate()

        XCTAssertEqual(viewModel.generatedColors[0].color.hex, lockedColor.hex,
                       "Locked color should survive regeneration")
    }

    func test_regenerate_changesUnlockedColors() {
        viewModel.selectHarmony(.triadic)
        let originalColor = viewModel.generatedColors[2].color

        // Different base should produce different unlocked colors
        viewModel.baseColor = DevColor(hue: 10, saturation: 0.9, lightness: 0.3)
        viewModel.regenerate()

        // It's highly unlikely the same color is generated from a very different base
        XCTAssertNotEqual(viewModel.generatedColors[2].color.hex, originalColor.hex)
    }

    func test_selectHarmony_clearsLocks() {
        viewModel.selectHarmony(.triadic)
        viewModel.toggleLock(at: 0)
        XCTAssertTrue(viewModel.generatedColors[0].isLocked)

        viewModel.selectHarmony(.analogous)
        // Locks should be cleared since it's a new harmony context
        XCTAssertFalse(viewModel.generatedColors.contains(where: { $0.isLocked }))
    }

    // MARK: ─── Randomise ──────────────────────────────────────────

    func test_randomise_changesBaseColor() {
        let originalHex = viewModel.baseColor.hex
        viewModel.randomise()
        // Statistically safe — probability of same color is astronomically low
        XCTAssertNotEqual(viewModel.baseColor.hex, originalHex)
    }

    func test_randomise_updatesGeneratedColors() {
        viewModel.selectHarmony(.complementary)
        let originalColors = viewModel.generatedColors.map(\.color.hex)
        viewModel.randomise()
        let newColors = viewModel.generatedColors.map(\.color.hex)
        XCTAssertNotEqual(newColors, originalColors)
    }

    // MARK: ─── allColors ──────────────────────────────────────────

    func test_allColors_countMatchesEntries() {
        viewModel.selectHarmony(.tetradic) // 4 colors
        XCTAssertEqual(viewModel.allColors.count, viewModel.generatedColors.count)
    }

    // MARK: ─── buildSavedPalette ──────────────────────────────────

    func test_buildSavedPalette_usesName() {
        viewModel.paletteName = "Ocean Sunset"
        let saved = viewModel.buildSavedPalette()
        XCTAssertEqual(saved.name, "Ocean Sunset")
    }

    func test_buildSavedPalette_defaultsNameWhenEmpty() {
        viewModel.paletteName = ""
        let saved = viewModel.buildSavedPalette()
        XCTAssertEqual(saved.name, "Untitled Palette")
    }

    func test_buildSavedPalette_colorCountMatches() {
        viewModel.selectHarmony(.triadic)
        let saved = viewModel.buildSavedPalette()
        XCTAssertEqual(saved.colors.count, 3)
    }

    func test_buildSavedPalette_storesHarmonyType() {
        viewModel.selectHarmony(.analogous)
        let saved = viewModel.buildSavedPalette()
        XCTAssertEqual(saved.harmonyType, HarmonyType.analogous.rawValue)
    }

    func test_buildSavedPalette_hexMatchesSource() {
        viewModel.selectHarmony(.complementary)
        let originalHex = viewModel.generatedColors.first!.color.hex
        let saved = viewModel.buildSavedPalette()
        XCTAssertEqual(saved.colors.first!.hex, originalHex)
    }

    // MARK: ─── Export ────────────────────────────────────────────

    func test_copyColor_doesNotThrow() {
        let color = viewModel.generatedColors.first!.color
        // Just ensure it doesn't crash
        viewModel.copyColor(color, as: .hex)
        XCTAssertNotNil(UIPasteboard.general.string)
    }

    func test_copyPalette_swiftUI_containsExtension() {
        viewModel.paletteName = "TestPalette"
        viewModel.copyPalette(as: .swiftUI)
        let pasted = UIPasteboard.general.string ?? ""
        XCTAssertTrue(pasted.contains("extension Color"))
        XCTAssertTrue(pasted.contains("TestPalette"))
    }
}
