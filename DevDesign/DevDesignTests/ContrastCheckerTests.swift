//
//  ContrastCheckerTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

// Run: Cmd+U

import XCTest
@testable import DevDesign

final class ContrastCheckerTests: XCTestCase {

    var vm: ContrastCheckerViewModel!

    override func setUp() {
        super.setUp()
        vm = ContrastCheckerViewModel()
    }

    // MARK: ─── Initial State ──────────────────────────────────────

    func test_initialForeground_isWhite() {
        XCTAssertEqual(vm.foreground.hex, "#FFFFFF")
    }

    func test_initialBackground_isDark() {
        XCTAssertEqual(vm.background.hex, "#1A1A2E")
    }

    func test_initialSelector_isForeground() {
        XCTAssertEqual(vm.activeSelector, .foreground)
    }

    // MARK: ─── Contrast Ratio ────────────────────────────────────

    func test_blackOnWhite_ratio_is21() {
        vm.foreground = .black
        vm.background = .white
        XCTAssertEqual(vm.result.ratio, 21.0, accuracy: 0.1)
    }

    func test_whiteOnWhite_ratio_is1() {
        vm.foreground = .white
        vm.background = .white
        XCTAssertEqual(vm.result.ratio, 1.0, accuracy: 0.01)
    }

    func test_ratioString_formatIsCorrect() {
        vm.foreground = .black
        vm.background = .white
        XCTAssertEqual(vm.ratioString, "21.00:1")
    }

    func test_rating_blackOnWhite_isAAA() {
        vm.foreground = .black
        vm.background = .white
        XCTAssertEqual(vm.rating, "AAA")
    }

    func test_rating_lowContrast_isFail() {
        vm.foreground = DevColor(hex: "#888888")!
        vm.background = DevColor(hex: "#999999")!
        XCTAssertEqual(vm.rating, "Fail")
    }

    // MARK: ─── WCAG Checks ───────────────────────────────────────

    func test_wcagChecks_countIsThree() {
        XCTAssertEqual(vm.wcagChecks.count, 3)
    }

    func test_wcagChecks_blackOnWhite_allPass() {
        vm.foreground = .black
        vm.background = .white
        for check in vm.wcagChecks {
            XCTAssertTrue(check.aaPass,  "\(check.label) AA should pass")
            XCTAssertTrue(check.aaaPass, "\(check.label) AAA should pass")
        }
    }

    func test_wcagChecks_lowContrast_allFail() {
        vm.foreground = DevColor(hex: "#888888")!
        vm.background = DevColor(hex: "#999999")!
        for check in vm.wcagChecks {
            XCTAssertFalse(check.aaPass,  "\(check.label) AA should fail")
            XCTAssertFalse(check.aaaPass, "\(check.label) AAA should fail")
        }
    }

    func test_wcagCheck_normalText_minRatioAA_is4point5() {
        let normalText = vm.wcagChecks.first(where: { $0.label == "Normal Text" })
        XCTAssertNotNil(normalText)
        XCTAssertEqual(normalText!.minRatioAA, 4.5)
    }

    // MARK: ─── Fix Suggestions ───────────────────────────────────

    func test_hasSuggestions_falseWhenPassing() {
        vm.foreground = .black
        vm.background = .white
        XCTAssertFalse(vm.hasSuggestions, "No suggestions needed when already passing")
    }

    func test_hasSuggestions_trueWhenFailing() {
        vm.foreground = DevColor(hex: "#888888")!
        vm.background = DevColor(hex: "#AAAAAA")!
        XCTAssertTrue(vm.hasSuggestions)
    }

    func test_fgSuggestion_passesAA() {
        vm.foreground = DevColor(hex: "#888888")!
        vm.background = .white
        if let sug = vm.fgSuggestion {
            let ratio = ContrastEngine.contrastRatio(foreground: sug, background: vm.background)
            XCTAssertGreaterThanOrEqual(ratio, 4.5)
        }
    }

    func test_applyFgSuggestion_updatesForeground() {
        vm.foreground = DevColor(hex: "#888888")!
        vm.background = .white
        let suggestion = vm.fgSuggestion
        vm.applyFgSuggestion()
        XCTAssertEqual(vm.foreground.hex, suggestion?.hex ?? "")
    }

    func test_applyFgSuggestion_incrementsFgSyncTrigger() {
        vm.foreground = DevColor(hex: "#888888")!
        vm.background = .white
        let before = vm.fgSyncTrigger
        vm.applyFgSuggestion()
        XCTAssertEqual(vm.fgSyncTrigger, before &+ 1)
    }

    // MARK: ─── Swap ──────────────────────────────────────────────

    func test_swapColors_exchangesFGandBG() {
        let origFG = vm.foreground.hex
        let origBG = vm.background.hex
        vm.swapColors()
        XCTAssertEqual(vm.foreground.hex, origBG)
        XCTAssertEqual(vm.background.hex, origFG)
    }

    func test_swapColors_doesNotChangRatio() {
        let ratioBefore = vm.result.ratio
        vm.swapColors()
        // Contrast ratio is symmetric
        XCTAssertEqual(vm.result.ratio, ratioBefore, accuracy: 0.01)
    }

    func test_swapColors_incrementsBothSyncTriggers() {
        let beforeFG = vm.fgSyncTrigger
        let beforeBG = vm.bgSyncTrigger
        vm.swapColors()
        XCTAssertEqual(vm.fgSyncTrigger, beforeFG &+ 1)
        XCTAssertEqual(vm.bgSyncTrigger, beforeBG &+ 1)
    }

    // MARK: ─── Color Blindness Previews ─────────────────────────

    func test_colorBlindPreviews_hasFourEntries() {
        XCTAssertEqual(vm.colorBlindPreviews.count, 4)
    }

    func test_colorBlindPreviews_firstIsNormal() {
        XCTAssertEqual(vm.colorBlindPreviews.first?.name, "Normal")
    }

    func test_colorBlindPreviews_normalMatchesSource() {
        let normal = vm.colorBlindPreviews.first!
        XCTAssertEqual(normal.foreground.hex, vm.foreground.hex)
        XCTAssertEqual(normal.background.hex, vm.background.hex)
    }

    func test_colorBlindPreviews_simulatedColorsAreDifferent() {
        // Deuteranopia of pure red should differ from pure red
        vm.foreground = DevColor(hex: "#FF0000")!
        let deut = vm.colorBlindPreviews.first(where: { $0.name == "Deuteranopia" })!
        XCTAssertNotEqual(deut.foreground.hex, vm.foreground.hex)
    }

    // MARK: ─── Copy Ratio ────────────────────────────────────────

    func test_copyRatio_writesToClipboard() {
        vm.foreground = .black
        vm.background = .white
        vm.copyRatio()
        XCTAssertEqual(UIPasteboard.general.string, vm.ratioString)
    }
}
