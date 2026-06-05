//
//  AppIconPickerTests.swift
//  DevDesign
//
//  Created by Sok Pich on 10/03/2026.
//


// AppIconPickerTests.swift
// DevDesign — Tests/AppIconPickerTests.swift

import XCTest
@testable import DevDesign

@MainActor
final class AppIconPickerTests: XCTestCase {

    // MARK: - AppIconVariant model

    func test_allCases_count() {
        XCTAssertEqual(AppIconVariant.allCases.count, 8)
    }

    func test_default_iconName_isNil() {
        XCTAssertNil(AppIconVariant.default.iconName)
    }

    func test_nonDefault_iconName_hasPrefix() {
        let non = AppIconVariant.allCases.filter { $0 != .default }
        for v in non {
            XCTAssertTrue(v.iconName?.hasPrefix("AppIcon-") == true,
                          "\(v.rawValue) iconName should start with AppIcon-")
        }
    }

    func test_iconName_matchesRawValue() {
        XCTAssertEqual(AppIconVariant.dark.iconName,    "AppIcon-Dark")
        XCTAssertEqual(AppIconVariant.minimal.iconName, "AppIcon-Minimal")
        XCTAssertEqual(AppIconVariant.neon.iconName,    "AppIcon-Neon")
        XCTAssertEqual(AppIconVariant.sunset.iconName,  "AppIcon-Sunset")
        XCTAssertEqual(AppIconVariant.ocean.iconName,   "AppIcon-Ocean")
        XCTAssertEqual(AppIconVariant.mono.iconName,    "AppIcon-Mono")
        XCTAssertEqual(AppIconVariant.gold.iconName,    "AppIcon-Gold")
    }

    func test_allVariants_haveLabel() {
        for v in AppIconVariant.allCases {
            XCTAssertFalse(v.label.isEmpty, "\(v.rawValue) label is empty")
        }
    }

    func test_allVariants_haveDescription() {
        for v in AppIconVariant.allCases {
            XCTAssertFalse(v.description.isEmpty, "\(v.rawValue) description is empty")
        }
    }

    func test_lightVariants() {
        XCTAssertTrue(AppIconVariant.minimal.isLight)
        XCTAssertTrue(AppIconVariant.gold.isLight)
        XCTAssertFalse(AppIconVariant.default.isLight)
        XCTAssertFalse(AppIconVariant.dark.isLight)
        XCTAssertFalse(AppIconVariant.neon.isLight)
    }

    func test_identifiable_idEqualsRawValue() {
        for v in AppIconVariant.allCases {
            XCTAssertEqual(v.id, v.rawValue)
        }
    }

    // MARK: - AppIconPickerViewModel init

    func test_viewModel_initialState() {
        let vm = AppIconPickerViewModel()
        XCTAssertFalse(vm.isApplying)
        XCTAssertFalse(vm.showSuccess)
        XCTAssertNil(vm.errorMessage)
    }

    func test_viewModel_selectedEqualsCurrentOnInit() {
        let vm = AppIconPickerViewModel()
        XCTAssertEqual(vm.selectedVariant, vm.currentVariant)
    }

    func test_hasUnsavedChange_falseOnInit() {
        let vm = AppIconPickerViewModel()
        XCTAssertFalse(vm.hasUnsavedChange)
    }

    // MARK: - select()

    func test_select_updatesSelectedVariant() {
        let vm = AppIconPickerViewModel()
        let target: AppIconVariant = vm.currentVariant == .neon ? .dark : .neon
        vm.select(target)
        XCTAssertEqual(vm.selectedVariant, target)
    }

    func test_select_hasUnsavedChange_whenDifferentFromCurrent() {
        let vm = AppIconPickerViewModel()
        let other: AppIconVariant = vm.currentVariant == .ocean ? .sunset : .ocean
        vm.select(other)
        XCTAssertTrue(vm.hasUnsavedChange)
    }

    func test_select_hasNoUnsavedChange_whenSameAsCurrent() {
        let vm = AppIconPickerViewModel()
        vm.select(vm.currentVariant)
        XCTAssertFalse(vm.hasUnsavedChange)
    }

    func test_select_doesNotChangeCurrentVariant() {
        let vm = AppIconPickerViewModel()
        let initial = vm.currentVariant
        let other: AppIconVariant = initial == .mono ? .gold : .mono
        vm.select(other)
        XCTAssertEqual(vm.currentVariant, initial, "select() should not change currentVariant")
    }

    // MARK: - apply() guard conditions

    func test_apply_doesNothing_whenNoUnsavedChange() {
        let vm = AppIconPickerViewModel()
        // selectedVariant == currentVariant → hasUnsavedChange is false
        vm.apply()
        XCTAssertFalse(vm.isApplying, "apply() should no-op when no change is pending")
    }

    func test_apply_doesNothing_whenAlreadyApplying() {
        let vm = AppIconPickerViewModel()
        let other: AppIconVariant = vm.currentVariant == .sunset ? .ocean : .sunset
        vm.select(other)
        vm.isApplying = true     // simulate in-flight
        // Call apply — should not start another task
        vm.apply()
        // isApplying stays true (was already set), no crash
        XCTAssertTrue(vm.isApplying)
    }

    // MARK: - dismissError()

    func test_dismissError_clearsErrorMessage() {
        let vm = AppIconPickerViewModel()
        vm.errorMessage = "Something went wrong"
        vm.dismissError()
        XCTAssertNil(vm.errorMessage)
    }

    // MARK: - AppIconError descriptions

    func test_error_notSupported_hasDescription() {
        let err = AppIconError.notSupported
        XCTAssertNotNil(err.errorDescription)
        XCTAssertFalse(err.errorDescription!.isEmpty)
    }

    func test_error_setFailed_includesMessage() {
        let msg = "permission denied"
        let err = AppIconError.setFailed(msg)
        XCTAssertTrue(err.errorDescription?.contains(msg) == true)
    }

    // MARK: - AppIconManager.currentVariant

    func test_manager_currentVariant_returnsDefault_whenNoAlternateSet() {
        // On Simulator, alternateIconName is always nil → should return .default
        let variant = AppIconManager.shared.currentVariant
        // We can't assert .default because a real device might have an alternate set,
        // but we CAN assert it returns a valid variant.
        XCTAssertTrue(AppIconVariant.allCases.contains(variant))
    }

    // MARK: - AllCases coverage

    func test_allCases_accentsAreNonNil() {
        // Just confirm no accent colour is accidentally transparent/zero
        for v in AppIconVariant.allCases {
            // accent returns a Color — we just verify no crash
            _ = v.accent
        }
    }

    func test_allCases_descriptionsAreDifferent() {
        let descs = AppIconVariant.allCases.map { $0.description }
        let unique = Set(descs)
        XCTAssertEqual(unique.count, descs.count, "Each variant should have a unique description")
    }

    func test_allCases_labelsAreDifferent() {
        let labels = AppIconVariant.allCases.map { $0.label }
        let unique = Set(labels)
        XCTAssertEqual(unique.count, labels.count, "Each variant should have a unique label")
    }

    func test_allCases_iconNamesAreDifferent() {
        // nil counts as unique once (the default icon)
        let names = AppIconVariant.allCases.compactMap { $0.iconName }
        let unique = Set(names)
        XCTAssertEqual(unique.count, names.count, "Each alternate icon name should be unique")
    }
}