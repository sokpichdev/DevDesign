//
//  ShadowPlaygroundTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Run: Cmd+U

import XCTest
import SwiftUI
@testable import DevDesign

final class ShadowPlaygroundTests: XCTestCase {

    var vm: ShadowViewModel!

    override func setUp() {
        super.setUp()
        vm = ShadowViewModel()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initialLayers_hasOneLayer() {
        XCTAssertEqual(vm.layers.count, 1)
    }

    func test_initialPreset_isMedium() {
        XCTAssertEqual(vm.selectedPreset, .medium)
    }

    func test_initialTarget_isCard() {
        XCTAssertEqual(vm.previewTarget, .card)
    }

    func test_initialBackground_isDark() {
        XCTAssertTrue(vm.isDarkBackground)
    }

    // MARK: ─── Layer Add / Remove ────────────────────────────────

    func test_addLayer_incrementsCount() {
        vm.addLayer()
        XCTAssertEqual(vm.layers.count, 2)
    }

    func test_addLayer_clampsAtFour() {
        vm.addLayer(); vm.addLayer(); vm.addLayer()
        XCTAssertEqual(vm.layers.count, 4)
        vm.addLayer()   // 5th — should be ignored
        XCTAssertEqual(vm.layers.count, 4)
    }

    func test_removeLayer_decrementsCount() {
        vm.addLayer()
        vm.removeLayer(at: 0)
        XCTAssertEqual(vm.layers.count, 1)
    }

    func test_removeLayer_doesNotDropBelowOne() {
        vm.removeLayer(at: 0)
        XCTAssertEqual(vm.layers.count, 1, "Must always keep at least one layer")
    }

    func test_removeLayer_updatesSelectedID() {
        let firstID = vm.layers[0].id
        vm.selectedLayerID = firstID
        vm.addLayer()
        vm.removeLayer(at: 0)
        XCTAssertNotEqual(vm.selectedLayerID, firstID)
    }

    // MARK: ─── Duplicate ─────────────────────────────────────────

    func test_duplicateLayer_incrementsCount() {
        vm.duplicateLayer(at: 0)
        XCTAssertEqual(vm.layers.count, 2)
    }

    func test_duplicateLayer_preservesProperties() {
        vm.updateLayer(at: 0) { $0.blur = 20 }
        vm.duplicateLayer(at: 0)
        XCTAssertEqual(vm.layers[1].blur, 20)
    }

    func test_duplicateLayer_getsNewID() {
        let originalID = vm.layers[0].id
        vm.duplicateLayer(at: 0)
        XCTAssertNotEqual(vm.layers[1].id, originalID)
    }

    func test_duplicateLayer_clampsAtFour() {
        vm.addLayer(); vm.addLayer(); vm.addLayer()
        XCTAssertEqual(vm.layers.count, 4)
        vm.duplicateLayer(at: 0)
        XCTAssertEqual(vm.layers.count, 4)
    }

    // MARK: ─── Update Layer ──────────────────────────────────────

    func test_updateLayer_changesValue() {
        vm.updateLayer(at: 0) { $0.x = 10 }
        XCTAssertEqual(vm.layers[0].x, 10)
    }

    func test_updateLayer_setsCustomPreset() {
        vm.updateLayer(at: 0) { $0.blur = 99 }
        XCTAssertEqual(vm.selectedPreset, .custom)
    }

    func test_toggleEnabled_flipsFlag() {
        let initial = vm.layers[0].isEnabled
        vm.toggleEnabled(at: 0)
        XCTAssertEqual(vm.layers[0].isEnabled, !initial)
    }

    func test_toggleInner_flipsFlag() {
        XCTAssertFalse(vm.layers[0].isInner)
        vm.toggleInner(at: 0)
        XCTAssertTrue(vm.layers[0].isInner)
    }

    // MARK: ─── Presets ───────────────────────────────────────────

    func test_applyPreset_soft_setsOneLayer() {
        vm.applyPreset(.soft)
        XCTAssertEqual(vm.layers.count, 1)
        XCTAssertEqual(vm.selectedPreset, .soft)
    }

    func test_applyPreset_inner_createsInnerLayer() {
        vm.applyPreset(.inner)
        XCTAssertTrue(vm.layers.contains(where: { $0.isInner }))
    }

    func test_applyPreset_custom_doesNotReplaceLayers() {
        vm.addLayer()
        let countBefore = vm.layers.count
        vm.applyPreset(.custom)
        XCTAssertEqual(vm.layers.count, countBefore)
    }

    // MARK: ─── Reset ─────────────────────────────────────────────

    func test_resetToDefault_givesOneMediumLayer() {
        vm.addLayer(); vm.addLayer()
        vm.resetToDefault()
        XCTAssertEqual(vm.layers.count, 1)
        XCTAssertEqual(vm.selectedPreset, .medium)
    }

    // MARK: ─── Computed ──────────────────────────────────────────

    func test_enabledLayers_excludesDisabled() {
        vm.addLayer()
        vm.toggleEnabled(at: 0)
        XCTAssertEqual(vm.enabledLayers.count, 1)
    }

    func test_hasInnerLayer_falseByDefault() {
        XCTAssertFalse(vm.hasInnerLayer)
    }

    func test_hasInnerLayer_trueAfterToggle() {
        vm.toggleInner(at: 0)
        XCTAssertTrue(vm.hasInnerLayer)
    }

    // MARK: ─── Export: SwiftUI ───────────────────────────────────

    func test_exportSwiftUI_containsShadowCall() {
        let code = ShadowExportService.exportSwiftUI(vm.layers)
        XCTAssertTrue(code.contains(".shadow("))
    }

    func test_exportSwiftUI_emptyWhenAllDisabled() {
        vm.toggleEnabled(at: 0)
        let code = ShadowExportService.exportSwiftUI(vm.layers)
        XCTAssertTrue(code.contains("No shadow"))
    }

    func test_exportSwiftUI_innerLayerNote() {
        vm.toggleInner(at: 0)
        let code = ShadowExportService.exportSwiftUI(vm.layers)
        XCTAssertTrue(code.contains("Inner shadow"))
    }

    // MARK: ─── Export: CSS ───────────────────────────────────────

    func test_exportCSS_containsBoxShadow() {
        let code = ShadowExportService.exportCSS(vm.layers)
        XCTAssertTrue(code.contains("box-shadow:"))
    }

    func test_exportCSS_innerLayerHasInset() {
        vm.toggleInner(at: 0)
        let code = ShadowExportService.exportCSS(vm.layers)
        XCTAssertTrue(code.contains("inset"))
    }

    func test_exportCSS_multipleLayers_hasComma() {
        vm.addLayer()
        let code = ShadowExportService.exportCSS(vm.layers)
        XCTAssertTrue(code.contains(","))
    }

    func test_exportCSSText_containsTextShadow() {
        let code = ShadowExportService.exportCSSText(vm.layers)
        XCTAssertTrue(code.contains("text-shadow:"))
    }

    // MARK: ─── Export: UIKit ─────────────────────────────────────

    func test_exportUIKit_singleLayer_containsShadowOpacity() {
        let code = ShadowExportService.exportUIKit(vm.layers)
        XCTAssertTrue(code.contains("shadowOpacity"))
    }

    func test_exportUIKit_multipleLayers_containsNote() {
        vm.addLayer()
        let code = ShadowExportService.exportUIKit(vm.layers)
        XCTAssertTrue(code.contains("UIKit supports one shadow"))
    }

    // MARK: ─── ShadowLayer Presets ───────────────────────────────

    func test_softPreset_hasLowOpacity() {
        let layer = ShadowLayer.soft()
        XCTAssertLessThan(layer.opacity, 0.3)
    }

    func test_hardPreset_hasLowBlur() {
        let layer = ShadowLayer.hard()
        XCTAssertLessThanOrEqual(layer.blur, 8)
    }

    func test_innerPreset_isInner() {
        let layer = ShadowLayer.inner()
        XCTAssertTrue(layer.isInner)
    }

    func test_glowPreset_hasZeroOffset() {
        let layer = ShadowLayer.glow()
        XCTAssertEqual(layer.x, 0)
        XCTAssertEqual(layer.y, 0)
    }

    // MARK: ─── Copy Action ───────────────────────────────────────

    func test_copyExport_writesClipboard() {
        vm.copyExport(for: .css)
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertTrue(clip.contains("box-shadow:"))
    }

    func test_copyExport_showsToast() {
        vm.copyExport(for: .swiftUI)
        XCTAssertTrue(vm.showCopiedToast)
        XCTAssertEqual(vm.copiedLabel, "SwiftUI")
    }
}
