//
//  ColorPickerTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//


// ColorPickerTests.swift
// DevDesign — DevDesignTests/ColorPickerTests.swift
// Run: Cmd+U

import XCTest
@testable import DevDesign

final class ColorPickerTests: XCTestCase {

    var viewModel: ColorPickerViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ColorPickerViewModel()
    }

    // MARK: ─── Initial State ───────────────────────────────────────

    func test_initialFormat_isSwiftUI() {
        XCTAssertEqual(viewModel.selectedFormat, .swiftUI)
    }

    func test_initialColor_isSet() {
        XCTAssertFalse(viewModel.selectedColor.hex.isEmpty)
    }

    func test_initialRecentColors_isEmpty() {
        XCTAssertTrue(viewModel.recentColors.isEmpty)
    }

    // MARK: ─── Select Color ────────────────────────────────────────

    func test_selectColor_updatesSelectedColor() {
        let newColor = DevColor(hex: "#FF0000")!
        viewModel.selectColor(newColor)
        XCTAssertEqual(viewModel.selectedColor.hex, "#FF0000")
    }

    func test_selectColor_pushesToRecent() {
        let color = DevColor(hex: "#FF5733")!
        viewModel.selectColor(color)
        XCTAssertEqual(viewModel.recentColors.first?.hex, "#FF5733")
    }

    func test_selectColor_noDuplicatesAtFront() {
        let color = DevColor(hex: "#AABBCC")!
        viewModel.selectColor(color)
        viewModel.selectColor(color)
        XCTAssertEqual(viewModel.recentColors.filter { $0.hex == "#AABBCC" }.count, 1)
    }

    func test_selectColor_maxTwelveRecent() {
        for i in 0..<15 {
            let hex = String(format: "#%02X0000", i * 10)
            if let color = DevColor(hex: hex) {
                viewModel.selectColor(color)
            }
        }
        XCTAssertLessThanOrEqual(viewModel.recentColors.count, 12)
    }

    func test_selectRecentColor_incrementsForceSyncTrigger() {
        let before = viewModel.forceSyncTrigger
        let color = DevColor(hex: "#123456")!
        viewModel.selectRecentColor(color)
        XCTAssertEqual(viewModel.forceSyncTrigger, before &+ 1)
    }

    // MARK: ─── Export Code ─────────────────────────────────────────

    func test_exportedCode_swiftUI_containsColor() {
        viewModel.selectedFormat = .swiftUI
        XCTAssertTrue(viewModel.exportedCode.contains("Color(.sRGB"))
    }

    func test_exportedCode_uiKit_containsUIColor() {
        viewModel.selectedFormat = .uiKit
        XCTAssertTrue(viewModel.exportedCode.contains("UIColor("))
    }

    func test_exportedCode_css_containsRgb() {
        viewModel.selectedFormat = .css
        XCTAssertTrue(viewModel.exportedCode.lowercased().contains("rgb"))
    }

    func test_exportedCode_hex_startsWithHash() {
        viewModel.selectedFormat = .hex
        XCTAssertTrue(viewModel.exportedCode.hasPrefix("#"))
    }

    func test_exportedCode_updatesWithColor() {
        viewModel.selectedFormat = .hex
        viewModel.selectColor(DevColor(hex: "#FF0000")!)
        XCTAssertEqual(viewModel.exportedCode, "#FF0000")

        viewModel.selectColor(DevColor(hex: "#00FF00")!)
        XCTAssertEqual(viewModel.exportedCode, "#00FF00")
    }

    // MARK: ─── Copy ───────────────────────────────────────────────

    func test_copyCurrentExport_setsClipboard() {
        viewModel.selectedFormat = .hex
        viewModel.selectColor(DevColor(hex: "#ABCDEF")!)
        viewModel.copyCurrentExport()
        XCTAssertEqual(UIPasteboard.general.string, "#ABCDEF")
    }

    func test_copyCurrentExport_showsFeedback() {
        viewModel.copyCurrentExport()
        XCTAssertTrue(viewModel.showCopiedFeedback)
    }

    func test_copyAs_specificFormat_doesNotChangeSelectedFormat() {
        viewModel.selectedFormat = .swiftUI
        viewModel.copy(as: .hex)
        XCTAssertEqual(viewModel.selectedFormat, .swiftUI,
                       "copy(as:) should not change the selected tab")
    }

    func test_copyAs_setsCorrectCopiedFormat() {
        viewModel.copy(as: .css)
        XCTAssertEqual(viewModel.copiedFormat, .css)
    }

    func test_copyAs_writesCorrectStringToClipboard() {
        viewModel.selectColor(DevColor(hex: "#FF0000")!)
        viewModel.copy(as: .hex)
        XCTAssertEqual(UIPasteboard.general.string, "#FF0000")
    }

    // MARK: ─── Clear Recent ────────────────────────────────────────

    func test_clearRecent_emptiesArray() {
        viewModel.selectColor(DevColor(hex: "#112233")!)
        viewModel.selectColor(DevColor(hex: "#445566")!)
        viewModel.clearRecent()
        XCTAssertTrue(viewModel.recentColors.isEmpty)
    }

    // MARK: ─── Format Description ─────────────────────────────────

    func test_formatDescription_nonEmpty_forAllFormats() {
        for format in ExportFormat.allCases {
            viewModel.selectedFormat = format
            XCTAssertFalse(viewModel.formatDescription.isEmpty,
                           "\(format.rawValue) should have a description")
        }
    }
}