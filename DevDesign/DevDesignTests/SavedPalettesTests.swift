//
//  SavedPalettesTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//


// SavedPalettesTests.swift
// DevDesign — DevDesignTests/SavedPalettesTests.swift
// Run: Cmd+U

import XCTest
@testable import DevDesign

final class SavedPalettesTests: XCTestCase {

    var vm: SavedPalettesViewModel!

    // Helpers
    func makePalette(name: String = "Test", harmony: String = "Complementary",
                     hexes: [String] = ["#FF0000", "#00FF00"]) -> SavedPalette {
        let colors = hexes.compactMap { DevColor(hex: $0) }.map {
            SavedColor(hex: $0.hex, red: $0.red, green: $0.green, blue: $0.blue)
        }
        return SavedPalette(name: name, colors: colors, harmonyType: harmony)
    }

    override func setUp() {
        super.setUp()
        vm = SavedPalettesViewModel()
    }

    // MARK: ─── Initial State ──────────────────────────────────────

    func test_initialDisplayMode_isGrid() {
        XCTAssertEqual(vm.displayMode, .grid)
    }

    func test_initialSearchText_isEmpty() {
        XCTAssertTrue(vm.searchText.isEmpty)
    }

    // MARK: ─── Filtering ─────────────────────────────────────────

    func test_filter_emptySearch_returnsAll() {
        let palettes = [makePalette(name: "Ocean"), makePalette(name: "Forest")]
        XCTAssertEqual(vm.filtered(palettes).count, 2)
    }

    func test_filter_byName_returnsMatch() {
        let palettes = [makePalette(name: "Ocean Blue"), makePalette(name: "Forest Green")]
        vm.searchText = "Ocean"
        XCTAssertEqual(vm.filtered(palettes).count, 1)
        XCTAssertEqual(vm.filtered(palettes).first?.name, "Ocean Blue")
    }

    func test_filter_byHarmony_returnsMatch() {
        let palettes = [
            makePalette(name: "A", harmony: "Triadic"),
            makePalette(name: "B", harmony: "Analogous")
        ]
        vm.searchText = "Triad"
        XCTAssertEqual(vm.filtered(palettes).count, 1)
    }

    func test_filter_caseInsensitive() {
        let palettes = [makePalette(name: "Sunset Orange")]
        vm.searchText = "sunset"
        XCTAssertEqual(vm.filtered(palettes).count, 1)
    }

    func test_filter_noMatch_returnsEmpty() {
        let palettes = [makePalette(name: "Ocean"), makePalette(name: "Forest")]
        vm.searchText = "zzz"
        XCTAssertTrue(vm.filtered(palettes).isEmpty)
    }

    // MARK: ─── Rename ────────────────────────────────────────────

    func test_beginRename_setsRenameText() {
        let palette = makePalette(name: "Old Name")
        vm.beginRename(palette)
        XCTAssertEqual(vm.renameText, "Old Name")
        XCTAssertNotNil(vm.paletteToRename)
    }

    func test_cancelRename_clearsState() {
        let palette = makePalette(name: "Old Name")
        vm.beginRename(palette)
        vm.cancelRename()
        XCTAssertNil(vm.paletteToRename)
        XCTAssertTrue(vm.renameText.isEmpty)
    }

    // MARK: ─── Delete ────────────────────────────────────────────

    func test_confirmDelete_setPaletteToDelete() {
        let palette = makePalette()
        vm.confirmDelete(palette)
        XCTAssertNotNil(vm.paletteToDelete)
        XCTAssertTrue(vm.showDeleteConfirm)
    }

    // MARK: ─── Export ────────────────────────────────────────────

    func test_exportAsJSON_containsName() {
        let palette = makePalette(name: "My Palette")
        let json = vm.exportAsJSON(palette)
        XCTAssertTrue(json.contains("My Palette"))
    }

    func test_exportAsJSON_containsHex() {
        let palette = makePalette(hexes: ["#FF0000"])
        let json = vm.exportAsJSON(palette)
        XCTAssertTrue(json.contains("#FF0000"))
    }

    func test_exportAsJSON_isValidJSON() {
        let palette = makePalette()
        let json = vm.exportAsJSON(palette)
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }

    func test_exportAsSwiftUI_containsExtension() {
        let palette = makePalette(name: "Brand")
        let code = vm.exportAsSwiftUI(palette)
        XCTAssertTrue(code.contains("extension Color"))
        XCTAssertTrue(code.contains("Brand"))
    }

    func test_exportAsCSS_containsRoot() {
        let palette = makePalette(name: "My Colors")
        let css = vm.exportAsCSS(palette)
        XCTAssertTrue(css.contains(":root"))
    }

    func test_exportAsCSS_containsVarName() {
        let palette = makePalette(name: "Brand Colors")
        let css = vm.exportAsCSS(palette)
        XCTAssertTrue(css.contains("--brand-colors-"))
    }

    // MARK: ─── Copy Toast ────────────────────────────────────────

    func test_copyToClipboard_setsMessage() {
        vm.copyToClipboard("test", label: "SwiftUI")
        XCTAssertEqual(vm.copiedMessage, "SwiftUI copied!")
    }

    func test_copyToClipboard_showsToast() {
        vm.copyToClipboard("test", label: "JSON")
        XCTAssertTrue(vm.showCopiedToast)
    }

    func test_copyToClipboard_writesClipboard() {
        vm.copyToClipboard("#AABBCC", label: "HEX")
        XCTAssertEqual(UIPasteboard.general.string, "#AABBCC")
    }
}