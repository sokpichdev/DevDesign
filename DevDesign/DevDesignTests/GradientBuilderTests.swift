//
//  GradientBuilderTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Run: Cmd+U

import XCTest
import SwiftUI
@testable import DevDesign

final class GradientBuilderTests: XCTestCase {

    var vm: GradientViewModel!

    override func setUp() {
        super.setUp()
        vm = GradientViewModel()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initial_typeIsLinear() {
        XCTAssertEqual(vm.config.type, .linear)
    }

    func test_initial_hasTwoStops() {
        XCTAssertEqual(vm.config.stops.count, 2)
    }

    func test_initial_angle135() {
        XCTAssertEqual(vm.config.angle, 135)
    }

    func test_initial_selectedStopIsFirst() {
        XCTAssertEqual(vm.selectedStopID, vm.config.stops.first?.id)
    }

    // MARK: ─── Stop CRUD ─────────────────────────────────────────

    func test_addStop_incrementsCount() {
        vm.addStop()
        XCTAssertEqual(vm.config.stops.count, 3)
    }

    func test_addStop_clampsAtSix() {
        for _ in 0..<4 { vm.addStop() }
        XCTAssertEqual(vm.config.stops.count, 6)
        vm.addStop()
        XCTAssertEqual(vm.config.stops.count, 6)
    }

    func test_addStop_newStopPositionInRange() {
        vm.addStop()
        let newStop = vm.config.stops.last!
        XCTAssertGreaterThanOrEqual(newStop.position, 0)
        XCTAssertLessThanOrEqual(newStop.position, 1)
    }

    func test_addStop_selectsNewStop() {
        vm.addStop()
        XCTAssertEqual(vm.selectedStopID, vm.config.stops.last?.id)
    }

    func test_removeStop_decrementsCount() {
        vm.addStop()
        let id = vm.config.stops.last!.id
        vm.removeStop(id: id)
        XCTAssertEqual(vm.config.stops.count, 2)
    }

    func test_removeStop_doesNotDropBelowTwo() {
        let id = vm.config.stops.first!.id
        vm.removeStop(id: id)
        XCTAssertEqual(vm.config.stops.count, 2, "Must keep at least 2 stops")
    }

    func test_removeStop_updatesSelection() {
        let id = vm.config.stops.first!.id
        vm.selectedStopID = id
        vm.addStop()
        vm.removeStop(id: id)
        XCTAssertNotEqual(vm.selectedStopID, id)
    }

    func test_updateStopColor_changesColor() {
        let id = vm.config.stops.first!.id
        vm.updateStopColor(.red, id: id)
        let stop = vm.config.stops.first(where: { $0.id == id })!
        // Compare via UIColor to avoid SwiftUI Color equality quirks
        XCTAssertEqual(UIColor(stop.color).cgColor, UIColor.red.cgColor)
    }

    func test_updateStopPosition_clampsToRange() {
        let id = vm.config.stops.first!.id
        vm.updateStopPosition(1.5, id: id)
        let stop = vm.config.stops.first(where: { $0.id == id })!
        XCTAssertEqual(stop.position, 1.0)
    }

    func test_updateStopPosition_clampsNegative() {
        let id = vm.config.stops.first!.id
        vm.updateStopPosition(-0.5, id: id)
        let stop = vm.config.stops.first(where: { $0.id == id })!
        XCTAssertEqual(stop.position, 0.0)
    }

    // MARK: ─── Config Mutations ──────────────────────────────────

    func test_setType_updatesType() {
        vm.setType(.radial)
        XCTAssertEqual(vm.config.type, .radial)
    }

    func test_setType_clearsPreset() {
        vm.selectedPreset = .sunset
        vm.setType(.angular)
        XCTAssertNil(vm.selectedPreset)
    }

    func test_setAngle_updatesAngle() {
        vm.setAngle(90)
        XCTAssertEqual(vm.config.angle, 90)
    }

    func test_setCenter_updatesBothAxes() {
        vm.setCenter(x: 0.3, y: 0.7)
        XCTAssertEqual(vm.config.centerX, 0.3, accuracy: 0.001)
        XCTAssertEqual(vm.config.centerY, 0.7, accuracy: 0.001)
    }

    func test_setEndRadius_updates() {
        vm.setEndRadius(300)
        XCTAssertEqual(vm.config.endRadius, 300)
    }

    // MARK: ─── Presets ───────────────────────────────────────────

    func test_applyPreset_sunset_isLinear() {
        vm.applyPreset(.sunset)
        XCTAssertEqual(vm.config.type, .linear)
    }

    func test_applyPreset_fire_isAngular() {
        vm.applyPreset(.fire)
        XCTAssertEqual(vm.config.type, .angular)
    }

    func test_applyPreset_midnight_isRadial() {
        vm.applyPreset(.midnight)
        XCTAssertEqual(vm.config.type, .radial)
    }

    func test_applyPreset_setsSelectedPreset() {
        vm.applyPreset(.ocean)
        XCTAssertEqual(vm.selectedPreset, .ocean)
    }

    func test_applyPreset_aurora_hasFourStops() {
        vm.applyPreset(.aurora)
        XCTAssertEqual(vm.config.stops.count, 4)
    }

    // MARK: ─── Reverse & Randomize ──────────────────────────────

    func test_reverseStops_flipsPositions() {
        let originalFirst = vm.config.sortedStops.first!.position  // 0.0
        let originalLast  = vm.config.sortedStops.last!.position   // 1.0
        vm.reverseStops()
        // After reverse: the stop that was at 0 is now at 1
        XCTAssertEqual(1.0 - originalFirst, 1.0, accuracy: 0.001)
        XCTAssertEqual(1.0 - originalLast,  0.0, accuracy: 0.001)
    }

    func test_randomize_doesNotChangeStopCount() {
        let count = vm.config.stops.count
        vm.randomize()
        XCTAssertEqual(vm.config.stops.count, count)
    }

    func test_randomize_clearsPreset() {
        vm.selectedPreset = .candy
        vm.randomize()
        XCTAssertNil(vm.selectedPreset)
    }

    // MARK: ─── Reset ─────────────────────────────────────────────

    func test_reset_restoresDefaultStops() {
        vm.addStop(); vm.addStop()
        vm.reset()
        XCTAssertEqual(vm.config.stops.count, 2)
    }

    func test_reset_restoresLinearType() {
        vm.setType(.radial)
        vm.reset()
        XCTAssertEqual(vm.config.type, .linear)
    }

    // MARK: ─── Computed ──────────────────────────────────────────

    func test_canAddStop_trueWithTwoStops() {
        XCTAssertTrue(vm.canAddStop)
    }

    func test_canAddStop_falseAtSix() {
        for _ in 0..<4 { vm.addStop() }
        XCTAssertFalse(vm.canAddStop)
    }

    func test_canRemoveStop_falseWithTwoStops() {
        XCTAssertFalse(vm.canRemoveStop)
    }

    func test_canRemoveStop_trueWithThreeStops() {
        vm.addStop()
        XCTAssertTrue(vm.canRemoveStop)
    }

    func test_sortedStops_ascendingOrder() {
        vm.addStop()
        let sorted = vm.config.sortedStops
        XCTAssertEqual(sorted, sorted.sorted(by: { $0.position < $1.position }))
    }

    // MARK: ─── Export ────────────────────────────────────────────

    func test_exportSwiftUI_linear_containsLinearGradient() {
        vm.setType(.linear)
        let code = GradientExportService.exportSwiftUI(vm.config)
        XCTAssertTrue(code.contains("LinearGradient"))
    }

    func test_exportSwiftUI_radial_containsRadialGradient() {
        vm.setType(.radial)
        let code = GradientExportService.exportSwiftUI(vm.config)
        XCTAssertTrue(code.contains("RadialGradient"))
    }

    func test_exportSwiftUI_angular_containsAngularGradient() {
        vm.setType(.angular)
        let code = GradientExportService.exportSwiftUI(vm.config)
        XCTAssertTrue(code.contains("AngularGradient"))
    }

    func test_exportCSS_linear_containsLinearGradient() {
        vm.setType(.linear)
        let code = GradientExportService.exportCSS(vm.config)
        XCTAssertTrue(code.contains("linear-gradient"))
    }

    func test_exportCSS_radial_containsRadialGradient() {
        vm.setType(.radial)
        let code = GradientExportService.exportCSS(vm.config)
        XCTAssertTrue(code.contains("radial-gradient"))
    }

    func test_exportCSS_angular_containsConicGradient() {
        vm.setType(.angular)
        let code = GradientExportService.exportCSS(vm.config)
        XCTAssertTrue(code.contains("conic-gradient"))
    }

    func test_exportUIKit_containsCAGradientLayer() {
        let code = GradientExportService.exportUIKit(vm.config)
        XCTAssertTrue(code.contains("CAGradientLayer"))
    }

    func test_exportJSON_isValidJSON() {
        let json = GradientExportService.exportJSON(vm.config)
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }

    func test_exportJSON_containsStopsKey() {
        let json = GradientExportService.exportJSON(vm.config)
        XCTAssertTrue(json.contains("\"stops\""))
    }

    func test_copyExport_writesClipboard() {
        vm.copyExport(for: .css)
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertTrue(clip.contains("gradient"))
    }

    func test_copyExport_showsToast() {
        vm.copyExport(for: .swiftUI)
        XCTAssertTrue(vm.showCopiedToast)
        XCTAssertEqual(vm.copiedLabel, "SwiftUI")
    }

    // MARK: ─── linearPoints helper ───────────────────────────────

    func test_linearPoints_0deg_pointsAreValid() {
        let (start, end) = GradientExportService.linearPoints(0)
        XCTAssertGreaterThanOrEqual(start.x, 0)
        XCTAssertLessThanOrEqual(start.x, 1)
        XCTAssertGreaterThanOrEqual(end.x, 0)
        XCTAssertLessThanOrEqual(end.x, 1)
    }

    func test_linearPoints_180deg_startAndEndDiffer() {
        let (start, end) = GradientExportService.linearPoints(180)
        XCTAssertNotEqual(start.y, end.y, accuracy: 0.01)
    }
}
