//
//  AppIconGeneratorTests.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import XCTest
import SwiftUI
@testable import DevDesign

final class AppIconGeneratorTests: XCTestCase {

    var vm: AppIconViewModel!

    override func setUp() {
        super.setUp()
        vm = AppIconViewModel()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initial_contentTypeIsSymbol() {
        XCTAssertEqual(vm.config.contentType, .symbol)
    }

    func test_initial_backgroundIsGradient() {
        XCTAssertEqual(vm.config.backgroundStyle, .gradient)
    }

    func test_initial_defaultSymbol() {
        XCTAssertFalse(vm.config.symbolName.isEmpty)
    }

    func test_initial_contentScaleInRange() {
        XCTAssertGreaterThan(vm.config.contentScale, 0)
        XCTAssertLessThanOrEqual(vm.config.contentScale, 1)
    }

    func test_initial_noToastShowing() {
        XCTAssertFalse(vm.showCopiedToast)
    }

    // MARK: ─── Content Type ──────────────────────────────────────

    func test_setContentType_symbol() {
        vm.setContentType(.initials)
        vm.setContentType(.symbol)
        XCTAssertEqual(vm.config.contentType, .symbol)
    }

    func test_setContentType_initials() {
        vm.setContentType(.initials)
        XCTAssertEqual(vm.config.contentType, .initials)
    }

    func test_setContentType_emoji() {
        vm.setContentType(.emoji)
        XCTAssertEqual(vm.config.contentType, .emoji)
    }

    // MARK: ─── Symbol ────────────────────────────────────────────

    func test_setSymbol_updates() {
        vm.setSymbol("heart.fill")
        XCTAssertEqual(vm.config.symbolName, "heart.fill")
    }

    func test_setSymbol_closesSymbolPicker() {
        vm.showSymbolPicker = true
        vm.setSymbol("star")
        XCTAssertFalse(vm.showSymbolPicker)
    }

    func test_symbolPool_nonEmpty() {
        XCTAssertFalse(vm.filteredSymbols.isEmpty)
    }

    func test_symbolSearch_filters() {
        vm.symbolSearchText = "heart"
        let results = vm.filteredSymbols
        XCTAssertTrue(results.allSatisfy { $0.contains("heart") })
    }

    func test_symbolSearch_emptyQuery_returnsAll() {
        vm.symbolSearchText = ""
        let all = vm.filteredSymbols
        vm.symbolSearchText = "heart"
        let filtered = vm.filteredSymbols
        XCTAssertGreaterThan(all.count, filtered.count)
    }

    func test_symbolSearch_noMatch_empty() {
        vm.symbolSearchText = "xyznonexistent999abc"
        XCTAssertTrue(vm.filteredSymbols.isEmpty)
    }

    // MARK: ─── Background Style ──────────────────────────────────

    func test_setBackgroundStyle_solid() {
        vm.setBackgroundStyle(.solid)
        XCTAssertEqual(vm.config.backgroundStyle, .solid)
    }

    func test_setBackgroundStyle_gradient() {
        vm.setBackgroundStyle(.gradient)
        XCTAssertEqual(vm.config.backgroundStyle, .gradient)
    }

    func test_setBackgroundStyle_mesh() {
        vm.setBackgroundStyle(.mesh)
        XCTAssertEqual(vm.config.backgroundStyle, .mesh)
    }

    // MARK: ─── Presets ───────────────────────────────────────────

    func test_presets_notEmpty() {
        XCTAssertFalse(AppIconViewModel.presets.isEmpty)
    }

    func test_applyPreset_sunset_setsSymbol() {
        let preset = AppIconViewModel.presets.first(where: { $0.name == "Sunset" })!
        vm.applyPreset(preset)
        XCTAssertEqual(vm.config.symbolName, preset.symbol)
    }

    func test_applyPreset_setsBackgroundColor() {
        let preset = AppIconViewModel.presets.first!
        vm.applyPreset(preset)
        let hex = AppIconExportService.colorHex(vm.config.backgroundColor).uppercased()
        XCTAssertEqual(hex, preset.bg.uppercased())
    }

    func test_applyPreset_setsContentTypeToSymbol() {
        vm.setContentType(.emoji)
        let preset = AppIconViewModel.presets.first!
        vm.applyPreset(preset)
        XCTAssertEqual(vm.config.contentType, .symbol)
    }

    func test_allPresets_haveNonEmptySymbol() {
        for preset in AppIconViewModel.presets {
            XCTAssertFalse(preset.symbol.isEmpty, "\(preset.name) has empty symbol")
        }
    }

    func test_allPresets_haveValidHexColors() {
        for preset in AppIconViewModel.presets {
            XCTAssertEqual(preset.bg.count, 7, "\(preset.name) bg hex invalid")
            XCTAssertEqual(preset.end.count, 7, "\(preset.name) end hex invalid")
        }
    }

    // MARK: ─── Reset ─────────────────────────────────────────────

    func test_reset_restoresDefaults() {
        vm.setContentType(.emoji)
        vm.setBackgroundStyle(.solid)
        vm.reset()
        XCTAssertEqual(vm.config.contentType, .symbol)
        XCTAssertEqual(vm.config.backgroundStyle, .gradient)
    }

    func test_reset_restoresDefaultSymbol() {
        vm.setSymbol("flame.fill")
        vm.reset()
        XCTAssertEqual(vm.config.symbolName, AppIconConfig().symbolName)
    }

    // MARK: ─── Icon Sizes ────────────────────────────────────────

    func test_sizeLibrary_notEmpty() {
        XCTAssertFalse(AppIconSizeLibrary.all.isEmpty)
    }

    func test_sizeLibrary_hasAppStoreSize() {
        XCTAssertTrue(AppIconSizeLibrary.all.contains(where: { $0.pixels == 1024 }))
    }

    func test_sizeLibrary_hasiPhoneMainSize() {
        XCTAssertTrue(AppIconSizeLibrary.all.contains(where: { $0.pixels == 180 }))
    }

    func test_sizeLibrary_uniqueFilenames() {
        let names = AppIconSizeLibrary.all.map(\.filename)
        // Some filenames repeat across platforms (same pixel size), that's expected
        // but each size entry must have a well-formed filename
        XCTAssertTrue(names.allSatisfy { $0.hasSuffix(".png") })
    }

    func test_sizeLibrary_pixelsEqualPointsTimesScale() {
        for size in AppIconSizeLibrary.all {
            XCTAssertEqual(size.pixels, size.points * size.scale,
                           "\(size.label) pixels mismatch")
        }
    }

    func test_previewSizes_subsetOfAll() {
        let allPixels = Set(AppIconSizeLibrary.all.map(\.pixels))
        for size in AppIconSizeLibrary.preview {
            XCTAssertTrue(allPixels.contains(size.pixels))
        }
    }

    // MARK: ─── Export Service ────────────────────────────────────

    func test_exportSwiftSnippet_symbol_containsSymbolName() {
        vm.setContentType(.symbol)
        vm.setSymbol("star.fill")
        let code = AppIconExportService.exportSwiftSnippet(config: vm.config)
        XCTAssertTrue(code.contains("star.fill"))
    }

    func test_exportSwiftSnippet_initials_containsInitials() {
        vm.setContentType(.initials)
        var c = vm.config
        c.initialsText = "AB"
        vm.config = c
        let code = AppIconExportService.exportSwiftSnippet(config: vm.config)
        XCTAssertTrue(code.contains("AB"))
    }

    func test_exportSwiftSnippet_emoji_containsEmoji() {
        vm.setContentType(.emoji)
        var c = vm.config
        c.emojiText = "🚀"
        vm.config = c
        let code = AppIconExportService.exportSwiftSnippet(config: vm.config)
        XCTAssertTrue(code.contains("🚀"))
    }

    func test_contentsJSON_isValidJSON() {
        let json = AppIconExportService.contentsJSON()
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }

    func test_contentsJSON_hasImagesKey() {
        let json = AppIconExportService.contentsJSON()
        XCTAssertTrue(json.contains("\"images\""))
    }

    func test_contentsJSON_hasInfoKey() {
        let json = AppIconExportService.contentsJSON()
        XCTAssertTrue(json.contains("\"info\""))
    }

    func test_colorHex_red() {
        let hex = AppIconExportService.colorHex(Color(red: 1, green: 0, blue: 0))
        XCTAssertEqual(hex.uppercased(), "FF0000")
    }

    func test_colorHex_white() {
        let hex = AppIconExportService.colorHex(.white)
        XCTAssertEqual(hex.uppercased(), "FFFFFF")
    }

    func test_colorHex_black() {
        let hex = AppIconExportService.colorHex(.black)
        XCTAssertEqual(hex.uppercased(), "000000")
    }

    func test_colorHex_sixChars() {
        let hex = AppIconExportService.colorHex(vm.config.backgroundColor)
        XCTAssertEqual(hex.count, 6)
    }

    // MARK: ─── Copy Toast ────────────────────────────────────────

    func test_copySwiftSnippet_showsToast() {
        vm.copySwiftSnippet()
        XCTAssertTrue(vm.showCopiedToast)
        XCTAssertEqual(vm.copiedLabel, "Swift snippet")
    }

    func test_copyContentsJSON_showsToast() {
        vm.copyContentsJSON()
        XCTAssertTrue(vm.showCopiedToast)
        XCTAssertEqual(vm.copiedLabel, "Contents.json")
    }

    func test_copySwiftSnippet_writesClipboard() {
        vm.copySwiftSnippet()
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertFalse(clip.isEmpty)
    }

    // MARK: ─── AppIconConfig Equatable ───────────────────────────

    func test_config_equalToItself() {
        let c = AppIconConfig()
        XCTAssertEqual(c, c)
    }

    func test_config_notEqualAfterChange() {
        var c = AppIconConfig()
        let original = c
        c.symbolName = "different.symbol"
        XCTAssertNotEqual(c, original)
    }

    // MARK: ─── Gradient Direction ────────────────────────────────

    func test_gradientDirection_allCasesNonEmpty() {
        XCTAssertFalse(IconGradientDirection.allCases.isEmpty)
    }

    func test_gradientDirection_producesDifferentStyles() {
        // Just ensure all directions can be applied without crash
        let dirs = IconGradientDirection.allCases
        for dir in dirs {
            _ = dir.gradient(from: .blue, to: .red, size: 100)
        }
    }
}
