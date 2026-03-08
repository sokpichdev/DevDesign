//
//  TypeScaleTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//


// TypeScaleTests.swift
// DevDesign — DevDesignTests/TypeScaleTests.swift
// Run: Cmd+U

import XCTest
@testable import DevDesign

final class TypeScaleTests: XCTestCase {

    // MARK: ─── TypeScaleEngine ────────────────────────────────────

    func test_generate_returnsNineSteps() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        XCTAssertEqual(steps.count, 9)
    }

    func test_generate_bodyStepMatchesBaseSize() {
        // "Body" is index 5 — steps from base = 0 → size == baseSize
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let body = steps[5]
        XCTAssertEqual(body.name, "Body")
        XCTAssertEqual(body.size, 16, accuracy: 0.2)
    }

    func test_generate_displayLargerThanBody() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        XCTAssertGreaterThan(steps[0].size, steps[5].size)
    }

    func test_generate_footnoteSmallestStep() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let sizes = steps.map(\.size)
        XCTAssertEqual(steps.last?.size, sizes.min())
    }

    func test_generate_displayLargestStep() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let sizes = steps.map(\.size)
        XCTAssertEqual(steps.first?.size, sizes.max())
    }

    func test_generate_largerRatioProducesWiderRange() {
        let narrow = TypeScaleEngine.generate(baseSize: 16, ratio: .minorSecond)
        let wide   = TypeScaleEngine.generate(baseSize: 16, ratio: .goldenRatio)
        let narrowRange = narrow[0].size - narrow[8].size
        let wideRange   = wide[0].size   - wide[8].size
        XCTAssertGreaterThan(wideRange, narrowRange)
    }

    func test_computeSize_stepsZero_equalsBase() {
        let size = TypeScaleEngine.computeSize(base: 16, ratio: 1.333, steps: 0)
        XCTAssertEqual(size, 16, accuracy: 0.1)
    }

    func test_computeSize_oneStepUp_equalsBaseTimesRatio() {
        let size = TypeScaleEngine.computeSize(base: 16, ratio: 1.333, steps: 1)
        XCTAssertEqual(size, 16 * 1.333, accuracy: 0.2)
    }

    func test_computeSize_negativeStep_smallerThanBase() {
        let size = TypeScaleEngine.computeSize(base: 16, ratio: 1.333, steps: -1)
        XCTAssertLessThan(size, 16)
    }

    func test_lineHeight_smallText_isLarger() {
        let small = TypeScaleEngine.recommendedLineHeight(size: 12)
        let large = TypeScaleEngine.recommendedLineHeight(size: 36)
        XCTAssertGreaterThan(small, large)
    }

    func test_tracking_largeText_isNegative() {
        let tracking = TypeScaleEngine.recommendedTracking(size: 40)
        XCTAssertLessThan(tracking, 0)
    }

    func test_tracking_smallText_isPositive() {
        let tracking = TypeScaleEngine.recommendedTracking(size: 10)
        XCTAssertGreaterThan(tracking, 0)
    }

    // MARK: ─── TypeScaleViewModel ─────────────────────────────────

    func test_vm_initialSteps_nonEmpty() {
        let vm = TypeScaleViewModel()
        XCTAssertFalse(vm.steps.isEmpty)
    }

    func test_vm_updateBaseSize_changesSteps() {
        let vm = TypeScaleViewModel()
        let oldBodySize = vm.steps[5].size
        vm.updateBaseSize(20)
        XCTAssertNotEqual(vm.steps[5].size, oldBodySize)
    }

    func test_vm_selectRatio_changesDisplaySize() {
        let vm = TypeScaleViewModel()
        vm.updateBaseSize(16)
        vm.selectRatio(.minorSecond)
        let narrow = vm.steps[0].size
        vm.selectRatio(.goldenRatio)
        let wide = vm.steps[0].size
        XCTAssertGreaterThan(wide, narrow)
    }

    func test_vm_regenerate_preservesCustomNames() {
        let vm = TypeScaleViewModel()
        vm.steps[0].name = "Hero"
        vm.updateBaseSize(18)   // triggers regenerate
        XCTAssertEqual(vm.steps[0].name, "Hero",
                       "Custom names should survive regeneration")
    }

    func test_vm_resetNames_restoresDefaults() {
        let vm = TypeScaleViewModel()
        vm.steps[0].name = "Hero"
        vm.resetNames()
        XCTAssertEqual(vm.steps[0].name, "Display")
    }

    func test_vm_updateWeight_changesStep() {
        let vm = TypeScaleViewModel()
        vm.updateWeight(.light, at: 5)
        XCTAssertEqual(vm.steps[5].weight, .light)
    }

    // MARK: ─── Export ─────────────────────────────────────────────

    func test_export_swiftUI_containsEnum() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let code = TypeScaleExportService.exportSwiftUI(steps)
        XCTAssertTrue(code.contains("enum AppTypography"))
    }

    func test_export_swiftUI_containsDisplayToken() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let code = TypeScaleExportService.exportSwiftUI(steps)
        XCTAssertTrue(code.contains("static let display"))
    }

    func test_export_swiftEnum_containsCGFloat() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let code = TypeScaleExportService.exportSwiftEnum(steps)
        XCTAssertTrue(code.contains("CGFloat"))
    }

    func test_export_css_containsRoot() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let code = TypeScaleExportService.exportCSS(steps)
        XCTAssertTrue(code.contains(":root"))
    }

    func test_export_css_containsFontVar() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let code = TypeScaleExportService.exportCSS(steps)
        XCTAssertTrue(code.contains("--font-"))
    }

    func test_export_json_isValidJSON() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let json = TypeScaleExportService.exportJSON(steps)
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }

    func test_export_json_containsTypographyKey() {
        let steps = TypeScaleEngine.generate(baseSize: 16, ratio: .minorThird)
        let json = TypeScaleExportService.exportJSON(steps)
        XCTAssertTrue(json.contains("typography"))
    }

    func test_vm_copyExport_setsClipboard() {
        let vm = TypeScaleViewModel()
        vm.copyExport(for: .css)
        let pasted = UIPasteboard.general.string ?? ""
        XCTAssertTrue(pasted.contains(":root"))
    }

    func test_vm_copyExport_showsToast() {
        let vm = TypeScaleViewModel()
        vm.copyExport(for: .swiftUI)
        XCTAssertTrue(vm.showCopiedToast)
        XCTAssertEqual(vm.copiedLabel, "SwiftUI")
    }

    // MARK: ─── ScaleRatio ─────────────────────────────────────────

    func test_allRatios_haveNonEmptyNames() {
        for ratio in ScaleRatio.allCases {
            XCTAssertFalse(ratio.name.isEmpty)
            XCTAssertFalse(ratio.description.isEmpty)
        }
    }

    func test_goldenRatio_isLargest() {
        let largest = ScaleRatio.allCases.max(by: { $0.rawValue < $1.rawValue })
        XCTAssertEqual(largest, .goldenRatio)
    }
}