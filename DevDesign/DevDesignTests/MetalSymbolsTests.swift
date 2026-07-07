//
//  MetalSymbolsTests.swift
//  DevDesign
//
//  Run: Cmd+U
//

import XCTest
import SwiftUI
@testable import DevDesign

@MainActor
final class MetalSymbolsTests: XCTestCase {

    var vm: MetalSymbolsViewModel!

    override func setUp() {
        super.setUp()
        vm = MetalSymbolsViewModel()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initialEffect_isShimmer() {
        XCTAssertEqual(vm.config.effect, .shimmer)
    }

    func test_initialState_isPlayingOnDarkBackground() {
        XCTAssertTrue(vm.config.isPlaying)
        XCTAssertTrue(vm.config.backgroundIsDark)
    }

    func test_initialExportFormat_isSwiftUI() {
        XCTAssertEqual(vm.selectedExportFormat, .swiftUI)
    }

    // MARK: ─── Effect Selection ──────────────────────────────────

    func test_selectEffect_changesEffectAndLoadsDefaults() {
        vm.selectEffect(.gradientFlow)
        XCTAssertEqual(vm.config.effect, .gradientFlow)
        // gradientFlow tuned default differs from shimmer's intensity (0.8)
        XCTAssertEqual(vm.config.intensity, 1.0, accuracy: 0.0001)
    }

    func test_selectEffect_preservesSymbolAndPlayState() {
        vm.config.symbolName = "heart.fill"
        vm.config.isPlaying = false
        vm.selectEffect(.liquidMetal)
        XCTAssertEqual(vm.config.symbolName, "heart.fill")
        XCTAssertFalse(vm.config.isPlaying)
    }

    func test_selectSameEffect_isNoOp() {
        vm.config.intensity = 0.123
        vm.selectEffect(.shimmer)   // already shimmer
        XCTAssertEqual(vm.config.intensity, 0.123, accuracy: 0.0001)
    }

    // MARK: ─── Reset ─────────────────────────────────────────────

    func test_resetToDefault_restoresEffectDefaultsKeepingSymbol() {
        vm.config.symbolName = "star.fill"
        vm.config.speed = 2.9
        vm.config.intensity = 0.05
        vm.resetToDefault()
        XCTAssertEqual(vm.config.symbolName, "star.fill")
        XCTAssertEqual(vm.config.speed, 1.0, accuracy: 0.0001)
        XCTAssertEqual(vm.config.intensity, 0.8, accuracy: 0.0001)
    }

    // MARK: ─── Effect Metadata ───────────────────────────────────

    func test_noiseIsDistortion_othersAreNot() {
        XCTAssertTrue(MetalSymbolEffect.noise.isDistortion)
        XCTAssertFalse(MetalSymbolEffect.shimmer.isDistortion)
        XCTAssertFalse(MetalSymbolEffect.gradientFlow.isDistortion)
        XCTAssertFalse(MetalSymbolEffect.liquidMetal.isDistortion)
    }

    func test_onlyGradientUsesSecondaryColor() {
        XCTAssertTrue(MetalSymbolEffect.gradientFlow.usesSecondaryColor)
        for e in [MetalSymbolEffect.shimmer, .noise, .liquidMetal] {
            XCTAssertFalse(e.usesSecondaryColor)
        }
    }

    func test_shaderFunctionName_matchesRawValue() {
        for e in MetalSymbolEffect.allCases {
            XCTAssertEqual(e.shaderFunctionName, e.rawValue)
        }
    }

    // MARK: ─── Export: SwiftUI ───────────────────────────────────

    func test_swiftUIExport_containsSymbolAndShaderCall() {
        vm.config.symbolName = "flame.fill"
        let code = vm.exportString(for: .swiftUI)
        XCTAssertTrue(code.contains("Image(systemName: \"flame.fill\")"))
        XCTAssertTrue(code.contains("ShaderLibrary.shimmer"))
        XCTAssertTrue(code.contains(".colorEffect("))
        XCTAssertTrue(code.contains("TimelineView(.animation)"))
    }

    func test_swiftUIExport_bakesInUserParameters() {
        vm.config.symbolName = "bolt.fill"
        vm.config.size = 88
        vm.config.speed = 2
        let code = vm.exportString(for: .swiftUI)
        XCTAssertTrue(code.contains("width: 88"))
        XCTAssertTrue(code.contains(".float(2)"))
    }

    func test_swiftUIExport_noiseUsesDistortionModifier() {
        vm.selectEffect(.noise)
        let code = vm.exportString(for: .swiftUI)
        XCTAssertTrue(code.contains(".distortionEffect("))
        XCTAssertTrue(code.contains("maxSampleOffset"))
        XCTAssertTrue(code.contains("ShaderLibrary.noise"))
    }

    func test_swiftUIExport_gradientIncludesBothColors() {
        vm.selectEffect(.gradientFlow)
        let code = vm.exportString(for: .swiftUI)
        let colorCalls = code.components(separatedBy: ".color(Color(red:").count - 1
        XCTAssertEqual(colorCalls, 2)
    }

    // MARK: ─── Export: Metal Shader ──────────────────────────────

    func test_metalExport_containsStitchableFunctionForEffect() {
        vm.selectEffect(.liquidMetal)
        let code = vm.exportString(for: .metalShader)
        XCTAssertTrue(code.contains("[[ stitchable ]]"))
        XCTAssertTrue(code.contains("half4 liquidMetal("))
        XCTAssertTrue(code.contains("#include <metal_stdlib>"))
    }

    func test_metalExport_matchesSelectedEffectOnly() {
        vm.selectEffect(.noise)
        let code = vm.exportString(for: .metalShader)
        XCTAssertTrue(code.contains("float2 noise("))
        XCTAssertFalse(code.contains("liquidMetal("))
    }
}
