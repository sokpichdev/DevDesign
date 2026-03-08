//
//  SpacingSystemTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Run: Cmd+U

import XCTest
@testable import DevDesign

final class SpacingSystemTests: XCTestCase {

    var vm: SpacingSystemViewModel!

    override func setUp() {
        super.setUp()
        vm = SpacingSystemViewModel()
    }

    // MARK: ─── SpacingEngine ─────────────────────────────────────

    func test_generate_returnsEightTokens() {
        let tokens = SpacingEngine.generate(base: .four)
        XCTAssertEqual(tokens.count, 8)
    }

    func test_generate_4ptBase_xxs_is2() {
        let tokens = SpacingEngine.generate(base: .four)
        let xxs = tokens.first { $0.name == "xxs" }!
        XCTAssertEqual(xxs.value, 2, accuracy: 0.01)
    }

    func test_generate_4ptBase_xs_is4() {
        let tokens = SpacingEngine.generate(base: .four)
        let xs = tokens.first { $0.name == "xs" }!
        XCTAssertEqual(xs.value, 4, accuracy: 0.01)
    }

    func test_generate_8ptBase_xs_is8() {
        let tokens = SpacingEngine.generate(base: .eight)
        let xs = tokens.first { $0.name == "xs" }!
        XCTAssertEqual(xs.value, 8, accuracy: 0.01)
    }

    func test_generate_valuesAscending() {
        let tokens = SpacingEngine.generate(base: .four)
        let values = tokens.map(\.value)
        XCTAssertEqual(values, values.sorted())
    }

    func test_generate_8pt_valuesDoubleFourPt() {
        let four  = SpacingEngine.generate(base: .four)
        let eight = SpacingEngine.generate(base: .eight)
        for (f, e) in zip(four, eight) {
            XCTAssertEqual(e.value, f.value * 2, accuracy: 0.01)
        }
    }

    func test_recompute_preservesCustomValues() {
        var tokens = SpacingEngine.generate(base: .four)
        tokens[2].customValue = 99
        let recomputed = SpacingEngine.recompute(tokens: tokens, base: .eight)
        XCTAssertEqual(recomputed[2].customValue, 99,
                       "Custom override should survive recompute")
    }

    func test_recompute_updatesBaseValues() {
        let tokens4 = SpacingEngine.generate(base: .four)
        let recomputed = SpacingEngine.recompute(tokens: tokens4, base: .eight)
        XCTAssertEqual(recomputed[1].value, tokens4[1].value * 2, accuracy: 0.01)
    }

    // MARK: ─── ViewModel ─────────────────────────────────────────

    func test_vm_initialBase_isFour() {
        XCTAssertEqual(vm.base, .four)
    }

    func test_vm_initialTokens_nonEmpty() {
        XCTAssertFalse(vm.tokens.isEmpty)
    }

    func test_vm_selectBase_changesValues() {
        let before = vm.tokens[1].value
        vm.selectBase(.eight)
        XCTAssertEqual(vm.tokens[1].value, before * 2, accuracy: 0.01)
    }

    func test_vm_selectBase_preservesCount() {
        vm.selectBase(.eight)
        XCTAssertEqual(vm.tokens.count, 8)
    }

    func test_vm_setOverride_updatesResolvedValue() {
        vm.setOverride(100, at: 0)
        XCTAssertEqual(vm.tokens[0].resolvedValue, 100)
    }

    func test_vm_setOverride_marksAsOverridden() {
        vm.setOverride(100, at: 0)
        XCTAssertTrue(vm.tokens[0].isOverridden)
    }

    func test_vm_clearOverride_restoresOriginalValue() {
        let original = vm.tokens[0].value
        vm.setOverride(999, at: 0)
        vm.clearOverride(at: 0)
        XCTAssertEqual(vm.tokens[0].resolvedValue, original)
        XCTAssertFalse(vm.tokens[0].isOverridden)
    }

    func test_vm_clearAllOverrides_removesAll() {
        vm.setOverride(10, at: 0)
        vm.setOverride(20, at: 1)
        vm.setOverride(30, at: 2)
        vm.clearAllOverrides()
        XCTAssertEqual(vm.overrideCount, 0)
    }

    func test_vm_overrideCount_correctAfterSetting() {
        vm.setOverride(10, at: 0)
        vm.setOverride(20, at: 2)
        XCTAssertEqual(vm.overrideCount, 2)
    }

    func test_vm_resetAll_clearsOverrides() {
        vm.setOverride(999, at: 0)
        vm.resetAll()
        XCTAssertEqual(vm.overrideCount, 0)
    }

    func test_vm_resetAll_restoresDefaultCount() {
        vm.resetAll()
        XCTAssertEqual(vm.tokens.count, 8)
    }

    // MARK: ─── Export ────────────────────────────────────────────

    func test_export_swiftUI_containsEnum() {
        let code = SpacingExportService.exportSwiftUI(vm.tokens, base: vm.base)
        XCTAssertTrue(code.contains("enum AppSpacing"))
    }

    func test_export_swiftUI_containsTokenName() {
        let code = SpacingExportService.exportSwiftUI(vm.tokens, base: vm.base)
        XCTAssertTrue(code.contains("static let xxs"))
    }

    func test_export_swiftUI_containsCGFloat() {
        let code = SpacingExportService.exportSwiftUI(vm.tokens, base: vm.base)
        XCTAssertTrue(code.contains("CGFloat"))
    }

    func test_export_swiftEnum_isCaseIterable() {
        let code = SpacingExportService.exportSwiftEnum(vm.tokens, base: vm.base)
        XCTAssertTrue(code.contains("CaseIterable"))
    }

    func test_export_css_containsRoot() {
        let code = SpacingExportService.exportCSS(vm.tokens, base: vm.base)
        XCTAssertTrue(code.contains(":root"))
    }

    func test_export_css_containsSpacingVar() {
        let code = SpacingExportService.exportCSS(vm.tokens, base: vm.base)
        XCTAssertTrue(code.contains("--spacing-"))
    }

    func test_export_json_isValidJSON() {
        let json = SpacingExportService.exportJSON(vm.tokens, base: vm.base)
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }

    func test_export_json_containsTokensKey() {
        let json = SpacingExportService.exportJSON(vm.tokens, base: vm.base)
        XCTAssertTrue(json.contains("\"tokens\""))
    }

    func test_export_json_reflectsOverride() {
        vm.setOverride(42, at: 0)
        let json = SpacingExportService.exportJSON(vm.tokens, base: vm.base)
        XCTAssertTrue(json.contains("42"))
        XCTAssertTrue(json.contains("isOverridden"))
    }

    func test_vm_copyValue_writesClipboard() {
        let token = vm.tokens[0]
        vm.copyValue(token)
        let expected = SpacingExportService.formatValue(token.resolvedValue)
        XCTAssertEqual(UIPasteboard.general.string, expected)
    }

    func test_vm_copyExport_showsToast() {
        vm.copyExport(for: .css)
        XCTAssertTrue(vm.showCopiedToast)
        XCTAssertEqual(vm.copiedLabel, "CSS")
    }

    // MARK: ─── BaseGrid ──────────────────────────────────────────

    func test_baseGrid_labels_nonEmpty() {
        for grid in BaseGrid.allCases {
            XCTAssertFalse(grid.label.isEmpty)
            XCTAssertFalse(grid.description.isEmpty)
        }
    }

    func test_formatValue_wholeNumber_noDecimal() {
        XCTAssertEqual(SpacingExportService.formatValue(8.0), "8")
    }

    func test_formatValue_decimal_hasOneDecimalPlace() {
        XCTAssertEqual(SpacingExportService.formatValue(2.5), "2.5")
    }
}
