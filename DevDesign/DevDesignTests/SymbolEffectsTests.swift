//
//  SymbolEffectsTests.swift
//  DevDesign
//
//  Run: Cmd+U
//

import XCTest
import SwiftUI
@testable import DevDesign

@MainActor
final class SymbolEffectsTests: XCTestCase {

    var vm: SymbolEffectsViewModel!

    override func setUp() {
        super.setUp()
        vm = SymbolEffectsViewModel()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initialKind_isBounce() {
        XCTAssertEqual(vm.config.kind, .bounce)
    }

    func test_initialState_isPlayingOnDarkBackground() {
        XCTAssertTrue(vm.config.isPlaying)
        XCTAssertTrue(vm.config.backgroundIsDark)
    }

    func test_initialExportFormat_isSwiftUI() {
        XCTAssertEqual(vm.selectedExportFormat, .swiftUI)
    }

    // MARK: ─── Selection & Reset ─────────────────────────────────

    func test_selectKind_changesKindKeepingSymbol() {
        vm.config.symbolName = "wifi"
        vm.selectKind(.pulse)
        XCTAssertEqual(vm.config.kind, .pulse)
        XCTAssertEqual(vm.config.symbolName, "wifi")
    }

    func test_resetToDefault_restoresDefaultsKeepingSymbol() {
        vm.config.symbolName = "trophy.fill"
        vm.config.speed = 2.7
        vm.selectKind(.rotate)
        vm.resetToDefault()
        XCTAssertEqual(vm.config.symbolName, "trophy.fill")
        XCTAssertEqual(vm.config.kind, .bounce)
        XCTAssertEqual(vm.config.speed, 1.0, accuracy: 0.0001)
    }

    // MARK: ─── Effect Metadata ───────────────────────────────────

    func test_discreteClassification() {
        for k in [SymbolEffectKind.bounce, .wiggle, .rotate] {
            XCTAssertTrue(k.isDiscrete, "\(k) should be discrete")
        }
        for k in [SymbolEffectKind.pulse, .variableColor, .breathe] {
            XCTAssertFalse(k.isDiscrete, "\(k) should be indefinite")
        }
    }

    func test_effectLiteral_variableColorIsIterative() {
        XCTAssertEqual(SymbolEffectKind.variableColor.effectLiteral, ".variableColor.iterative")
    }

    // MARK: ─── Export: SwiftUI ───────────────────────────────────

    func test_swiftUIExport_indefiniteUsesIsActive() {
        vm.selectKind(.pulse)
        let code = vm.exportString(for: .swiftUI)
        XCTAssertTrue(code.contains(".symbolEffect(.pulse"))
        XCTAssertTrue(code.contains("isActive: true"))
        XCTAssertFalse(code.contains(".repeat(.continuous)"))
    }

    func test_swiftUIExport_discreteUsesContinuousRepeat() {
        vm.selectKind(.bounce)
        let code = vm.exportString(for: .swiftUI)
        XCTAssertTrue(code.contains(".symbolEffect(.bounce"))
        XCTAssertTrue(code.contains(".repeat(.continuous)"))
    }

    func test_swiftUIExport_containsSymbolAndSpeed() {
        vm.config.symbolName = "bell.fill"
        vm.config.speed = 2
        let code = vm.exportString(for: .swiftUI)
        XCTAssertTrue(code.contains("Image(systemName: \"bell.fill\")"))
        XCTAssertTrue(code.contains(".speed(2)"))
    }

    // MARK: ─── Export: UIKit ─────────────────────────────────────

    func test_uiKitExport_usesNSSymbolEffectForKind() {
        vm.selectKind(.wiggle)
        let code = vm.exportString(for: .uiKit)
        XCTAssertTrue(code.contains("addSymbolEffect"))
        XCTAssertTrue(code.contains("NSSymbolWiggleEffect()"))
        XCTAssertTrue(code.contains("UIImageView"))
    }
}
