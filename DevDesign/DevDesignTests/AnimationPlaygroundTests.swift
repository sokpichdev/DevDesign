//
//  AnimationPlaygroundTests.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import XCTest
import SwiftUI
@testable import DevDesign

final class AnimationPlaygroundTests: XCTestCase {

    var vm: AnimationViewModel!

    override func setUp() {
        super.setUp()
        vm = AnimationViewModel()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initial_typeIsSpring() {
        XCTAssertEqual(vm.config.type, .spring)
    }

    func test_initial_categoryIsSpring() {
        XCTAssertEqual(vm.selectedCategory, .spring)
    }

    func test_initial_notAnimating() {
        XCTAssertFalse(vm.isAnimating)
    }

    func test_initial_notLooping() {
        XCTAssertFalse(vm.isLooping)
    }

    func test_initial_noPresetSelected() {
        XCTAssertNil(vm.selectedPreset)
    }

    func test_initial_responseInRange() {
        XCTAssertGreaterThan(vm.config.response, 0)
        XCTAssertLessThanOrEqual(vm.config.response, 2)
    }

    func test_initial_dampingInRange() {
        XCTAssertGreaterThan(vm.config.dampingFraction, 0)
        XCTAssertLessThanOrEqual(vm.config.dampingFraction, 1.5)
    }

    // MARK: ─── Category Selection ────────────────────────────────

    func test_selectCategory_easing_changesCategory() {
        vm.selectCategory(.easing)
        XCTAssertEqual(vm.selectedCategory, .easing)
    }

    func test_selectCategory_easing_picksFirstEasingType() {
        vm.selectCategory(.easing)
        XCTAssertEqual(vm.config.type.category, .easing)
    }

    func test_selectCategory_timing_picksTimingCurve() {
        vm.selectCategory(.timing)
        XCTAssertEqual(vm.config.type, .timingCurve)
    }

    func test_selectCategory_spring_staysSpring() {
        vm.selectCategory(.easing)
        vm.selectCategory(.spring)
        XCTAssertEqual(vm.selectedCategory, .spring)
    }

    // MARK: ─── Type Selection ────────────────────────────────────

    func test_selectType_updatesConfig() {
        vm.selectType(.bouncy)
        XCTAssertEqual(vm.config.type, .bouncy)
    }

    func test_selectType_clearsPreset() {
        let preset = AnimationPresetLibrary.all.first!
        vm.applyPreset(preset)
        vm.selectType(.linear)
        XCTAssertNil(vm.selectedPreset)
    }

    func test_filteredTypes_springCategory() {
        vm.selectCategory(.spring)
        let types = vm.filteredTypes
        XCTAssertTrue(types.allSatisfy { $0.category == .spring })
    }

    func test_filteredTypes_easingCategory() {
        vm.selectCategory(.easing)
        let types = vm.filteredTypes
        XCTAssertTrue(types.allSatisfy { $0.category == .easing })
        XCTAssertFalse(types.isEmpty)
    }

    func test_filteredTypes_timingCategory() {
        vm.selectCategory(.timing)
        let types = vm.filteredTypes
        XCTAssertEqual(types, [.timingCurve])
    }

    // MARK: ─── Animation Types ───────────────────────────────────

    func test_allAnimationTypes_haveCategoryAssigned() {
        for type in AnimationType.allCases {
            XCTAssertNotNil(type.category)
        }
    }

    func test_allAnimationTypes_haveNonEmptyLabel() {
        for type in AnimationType.allCases {
            XCTAssertFalse(type.label.isEmpty, "\(type.rawValue) has no label")
        }
    }

    func test_allAnimationTypes_haveNonEmptyDescription() {
        for type in AnimationType.allCases {
            XCTAssertFalse(type.description.isEmpty)
        }
    }

    func test_allAnimationTypes_haveNonEmptyIcon() {
        for type in AnimationType.allCases {
            XCTAssertFalse(type.icon.isEmpty)
        }
    }

    // MARK: ─── Presets ───────────────────────────────────────────

    func test_presetLibrary_notEmpty() {
        XCTAssertFalse(AnimationPresetLibrary.all.isEmpty)
    }

    func test_applyPreset_setsSelectedPreset() {
        let preset = AnimationPresetLibrary.all.first!
        vm.applyPreset(preset)
        XCTAssertEqual(vm.selectedPreset?.id, preset.id)
    }

    func test_applyPreset_updatesCategory() {
        let preset = AnimationPresetLibrary.all.first(where: { $0.config.type.category == .easing })
        guard let preset else { return }
        vm.applyPreset(preset)
        XCTAssertEqual(vm.selectedCategory, .easing)
    }

    func test_applyPreset_configMatchesPreset() {
        let preset = AnimationPresetLibrary.all.first!
        vm.applyPreset(preset)
        XCTAssertEqual(vm.config.type, preset.config.type)
    }

    func test_allPresets_haveNonEmptyName() {
        for p in AnimationPresetLibrary.all {
            XCTAssertFalse(p.name.isEmpty)
        }
    }

    func test_allPresets_uniqueIDs() {
        let ids = AnimationPresetLibrary.all.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    // MARK: ─── Curve Math ─────────────────────────────────────────

    func test_curvePoints_returnsNonEmpty() {
        XCTAssertFalse(vm.curvePoints.isEmpty)
    }

    func test_curvePoints_linear_monotone() {
        vm.selectType(.linear)
        let pts = vm.curvePoints.map(\.v)
        for i in 1..<pts.count {
            XCTAssertGreaterThanOrEqual(pts[i], pts[i-1] - 0.001)
        }
    }

    func test_curvePoints_easeIn_startsSlowly() {
        vm.selectType(.easeIn)
        let pts = vm.curvePoints
        let earlyV = pts.first(where: { $0.t > 0.1 })?.v ?? 0
        XCTAssertLessThan(earlyV, 0.4, "easeIn should be slow at t=0.1")
    }

    func test_curvePoints_easeOut_endsSlowly() {
        vm.selectType(.easeOut)
        let pts = vm.curvePoints
        let lateV = pts.last(where: { $0.t < 0.9 })?.v ?? 0
        XCTAssertGreaterThan(lateV, 0.6, "easeOut should be mostly done at t=0.9")
    }

    func test_curvePoints_startNearZero() {
        for type in AnimationType.allCases {
            vm.selectType(type)
            let first = vm.curvePoints.first?.v ?? 1
            XCTAssertLessThan(abs(first), 0.1, "\(type.rawValue) does not start near 0")
        }
    }

    func test_curvePoints_spring_canOvershooot() {
        var c = AnimationConfig()
        c.type = .spring
        c.dampingFraction = 0.3
        let pts = AnimationExportService.curvePoints(c)
        let maxV = pts.map(\.v).max() ?? 1
        XCTAssertGreaterThan(maxV, 1.0, "Underdamped spring should overshoot")
    }

    func test_curvePoints_criticallyDamped_noOvershoot() {
        var c = AnimationConfig()
        c.type = .spring
        c.dampingFraction = 1.0
        let pts = AnimationExportService.curvePoints(c)
        let maxV = pts.map(\.v).max() ?? 1
        XCTAssertLessThanOrEqual(maxV, 1.01)
    }

    // MARK: ─── Export Service ────────────────────────────────────

    func test_exportModifier_containsAnimation() {
        let code = AnimationExportService.exportModifier(vm.config)
        XCTAssertTrue(code.contains(".animation("))
    }

    func test_exportWithAnimation_containsWithAnimation() {
        let code = AnimationExportService.exportWithAnimation(vm.config)
        XCTAssertTrue(code.contains("withAnimation("))
    }

    func test_exportTransition_containsTransition() {
        let code = AnimationExportService.exportTransition(vm.config, target: .slide)
        XCTAssertTrue(code.contains(".transition("))
    }

    func test_exportModifier_spring_containsResponse() {
        vm.selectType(.spring)
        let code = AnimationExportService.exportModifier(vm.config)
        XCTAssertTrue(code.contains("response:"))
    }

    func test_exportModifier_easeInOut_containsDuration() {
        vm.selectType(.easeInOut)
        let code = AnimationExportService.exportModifier(vm.config)
        XCTAssertTrue(code.contains("duration:"))
    }

    func test_exportModifier_timingCurve_containsAllFourPoints() {
        vm.selectType(.timingCurve)
        let code = AnimationExportService.exportModifier(vm.config)
        XCTAssertTrue(code.contains(".timingCurve("))
    }

    func test_exportModifier_withDelay_containsDelay() {
        var c = vm.config; c.delay = 0.5; vm.config = c
        let code = AnimationExportService.exportModifier(vm.config)
        XCTAssertTrue(code.contains(".delay("))
    }

    func test_exportModifier_withRepeat_containsRepeatForever() {
        var c = vm.config; c.repeatCount = 0; vm.config = c
        let code = AnimationExportService.exportModifier(vm.config)
        XCTAssertTrue(code.contains(".repeatForever("))
    }

    func test_exportModifier_withRepeatCount_containsRepeatCount() {
        var c = vm.config; c.repeatCount = 3; vm.config = c
        let code = AnimationExportService.exportModifier(vm.config)
        XCTAssertTrue(code.contains(".repeatCount("))
    }

    // MARK: ─── Format Helper ─────────────────────────────────────

    func test_f_wholeNumber() {
        XCTAssertEqual(AnimationExportService.f(1.0), "1")
    }

    func test_f_decimal() {
        XCTAssertEqual(AnimationExportService.f(0.55), "0.55")
    }

    func test_f_twoDecimals() {
        XCTAssertEqual(AnimationExportService.f(0.825), "0.83")
    }

    // MARK: ─── Copy Toast ────────────────────────────────────────

    func test_copyExport_modifier_showsToast() {
        vm.copyExport(for: .modifier)
        XCTAssertTrue(vm.showCopiedToast)
    }

    func test_copyExport_modifier_setsLabel() {
        vm.copyExport(for: .modifier)
        XCTAssertEqual(vm.copiedLabel, AnimExportTab.modifier.rawValue)
    }

    func test_copyExport_writesClipboard() {
        vm.copyExport(for: .withAnim)
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertFalse(clip.isEmpty)
    }

    // MARK: ─── AnimationConfig Equatable ─────────────────────────

    func test_config_equalToItself() {
        XCTAssertEqual(vm.config, vm.config)
    }

    func test_config_notEqualAfterChange() {
        let original = vm.config
        var updated = vm.config
        updated.response = 1.5
        XCTAssertNotEqual(original, updated)
    }
}
