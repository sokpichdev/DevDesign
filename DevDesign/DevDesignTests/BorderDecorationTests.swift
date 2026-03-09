//
//  BorderDecorationTests.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import XCTest
import SwiftUI
@testable import DevDesign

final class BorderDecorationTests: XCTestCase {

    var vm: BorderDecorationViewModel!

    override func setUp() {
        super.setUp()
        vm = BorderDecorationViewModel()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initial_tabIsCorners() {
        XCTAssertEqual(vm.selectedTab, .corners)
    }

    func test_initial_shapeIsCard() {
        XCTAssertEqual(vm.selectedShape, .card)
    }

    func test_initial_noExportSheet() {
        XCTAssertFalse(vm.showExportSheet)
    }

    func test_initial_noToast() {
        XCTAssertFalse(vm.showCopiedToast)
    }

    func test_initial_cornerRadius() {
        XCTAssertEqual(vm.cornerConfig.radius, 12)
    }

    func test_initial_cornerStyleIsRounded() {
        XCTAssertEqual(vm.cornerConfig.style, .rounded)
    }

    func test_initial_borderWidth() {
        XCTAssertEqual(vm.borderConfig.width, 2)
    }

    func test_initial_borderStyleIsSolid() {
        XCTAssertEqual(vm.borderConfig.styleType, .solid)
    }

    func test_initial_glowTypeIsOuter() {
        XCTAssertEqual(vm.glowConfig.type, .outer)
    }

    func test_initial_patternTypeIsGrid() {
        XCTAssertEqual(vm.patternConfig.patternType, .grid)
    }

    // MARK: ─── Tab Switching ─────────────────────────────────────

    func test_switchTab_borders() {
        vm.selectedTab = .borders
        XCTAssertEqual(vm.selectedTab, .borders)
    }

    func test_switchTab_glow() {
        vm.selectedTab = .glow
        XCTAssertEqual(vm.selectedTab, .glow)
    }

    func test_switchTab_patterns() {
        vm.selectedTab = .patterns
        XCTAssertEqual(vm.selectedTab, .patterns)
    }

    // MARK: ─── Reset ─────────────────────────────────────────────

    func test_reset_corners_restoresDefaults() {
        vm.cornerConfig.radius = 50
        vm.selectedTab = .corners
        vm.reset()
        XCTAssertEqual(vm.cornerConfig.radius, CornerConfig().radius)
    }

    func test_reset_borders_restoresDefaults() {
        vm.borderConfig.width = 10
        vm.selectedTab = .borders
        vm.reset()
        XCTAssertEqual(vm.borderConfig.width, BorderConfig().width)
    }

    func test_reset_glow_restoresDefaults() {
        vm.glowConfig.radius = 50
        vm.selectedTab = .glow
        vm.reset()
        XCTAssertEqual(vm.glowConfig.radius, GlowConfig().radius)
    }

    func test_reset_patterns_restoresDefaults() {
        vm.patternConfig.scale = 100
        vm.selectedTab = .patterns
        vm.reset()
        XCTAssertEqual(vm.patternConfig.scale, PatternConfig().scale)
    }

    // MARK: ─── Preset Application ────────────────────────────────

    func test_applyPreset_corner_updatesConfig() {
        let preset = DecorationPresetLibrary.corners.first!
        vm.applyPreset(preset)
        XCTAssertEqual(vm.cornerConfig.style, preset.cornerConfig!.style)
    }

    func test_applyPreset_border_updatesConfig() {
        let preset = DecorationPresetLibrary.borders.first!
        vm.applyPreset(preset)
        XCTAssertEqual(vm.borderConfig.styleType, preset.borderConfig!.styleType)
    }

    func test_applyPreset_glow_updatesType() {
        let preset = DecorationPresetLibrary.glows.first!
        vm.applyPreset(preset)
        XCTAssertEqual(vm.glowConfig.type, preset.glowConfig!.type)
    }

    func test_applyPreset_pattern_updatesType() {
        let preset = DecorationPresetLibrary.patterns.first!
        vm.applyPreset(preset)
        XCTAssertEqual(vm.patternConfig.patternType, preset.patternConfig!.patternType)
    }

    func test_allCornerPresets_haveCornerConfig() {
        for p in DecorationPresetLibrary.corners {
            XCTAssertNotNil(p.cornerConfig, "\(p.name) missing cornerConfig")
        }
    }

    func test_allBorderPresets_haveBorderConfig() {
        for p in DecorationPresetLibrary.borders {
            XCTAssertNotNil(p.borderConfig, "\(p.name) missing borderConfig")
        }
    }

    func test_allGlowPresets_haveGlowConfig() {
        for p in DecorationPresetLibrary.glows {
            XCTAssertNotNil(p.glowConfig, "\(p.name) missing glowConfig")
        }
    }

    func test_allPatternPresets_havePatternConfig() {
        for p in DecorationPresetLibrary.patterns {
            XCTAssertNotNil(p.patternConfig, "\(p.name) missing patternConfig")
        }
    }

    // MARK: ─── Export Code ───────────────────────────────────────

    func test_exportCode_corners_nonEmpty() {
        vm.selectedTab = .corners
        XCTAssertFalse(vm.exportCode.isEmpty)
    }

    func test_exportCode_borders_nonEmpty() {
        vm.selectedTab = .borders
        XCTAssertFalse(vm.exportCode.isEmpty)
    }

    func test_exportCode_glow_nonEmpty() {
        vm.selectedTab = .glow
        XCTAssertFalse(vm.exportCode.isEmpty)
    }

    func test_exportCode_patterns_nonEmpty() {
        vm.selectedTab = .patterns
        XCTAssertFalse(vm.exportCode.isEmpty)
    }

    // MARK: ─── Corner Export ─────────────────────────────────────

    func test_exportCorners_rounded_containsClipShape() {
        var c = CornerConfig(); c.style = .rounded; c.radius = 12
        let code = BorderDecorationExportService.exportCorners(c)
        XCTAssertTrue(code.contains("clipShape") || code.contains("RoundedRectangle"))
    }

    func test_exportCorners_circular_containsCapsule() {
        var c = CornerConfig(); c.style = .circular
        let code = BorderDecorationExportService.exportCorners(c)
        XCTAssertTrue(code.contains("Capsule"))
    }

    func test_exportCorners_continuous_containsContinuous() {
        var c = CornerConfig(); c.style = .continuous
        let code = BorderDecorationExportService.exportCorners(c)
        XCTAssertTrue(code.contains("continuous"))
    }

    func test_exportCorners_perCorner_containsUnevenRounded() {
        var c = CornerConfig(); c.perCorner = true
        let code = BorderDecorationExportService.exportCorners(c)
        XCTAssertTrue(code.contains("UnevenRoundedRectangle"))
    }

    // MARK: ─── Border Export ─────────────────────────────────────

    func test_exportBorder_solid_containsStrokeBorder() {
        var b = BorderConfig(); b.styleType = .solid
        let code = BorderDecorationExportService.exportBorder(b)
        XCTAssertTrue(code.contains("strokeBorder"))
    }

    func test_exportBorder_dashed_containsDash() {
        var b = BorderConfig(); b.styleType = .dashed
        let code = BorderDecorationExportService.exportBorder(b)
        XCTAssertTrue(code.contains("dash:"))
    }

    func test_exportBorder_dotted_containsRound() {
        var b = BorderConfig(); b.styleType = .dotted
        let code = BorderDecorationExportService.exportBorder(b)
        XCTAssertTrue(code.contains(".round"))
    }

    func test_exportBorder_gradient_containsLinearGradient() {
        var b = BorderConfig(); b.styleType = .gradient
        let code = BorderDecorationExportService.exportBorder(b)
        XCTAssertTrue(code.contains("LinearGradient"))
    }

    func test_exportBorder_double_containsPadding() {
        var b = BorderConfig(); b.styleType = .double_
        let code = BorderDecorationExportService.exportBorder(b)
        XCTAssertTrue(code.contains("padding"))
    }

    // MARK: ─── Glow Export ───────────────────────────────────────

    func test_exportGlow_outer_containsShadow() {
        var g = GlowConfig(); g.type = .outer
        let code = BorderDecorationExportService.exportGlow(g)
        XCTAssertTrue(code.contains(".shadow("))
    }

    func test_exportGlow_neon_containsMultipleShadows() {
        var g = GlowConfig(); g.type = .neon
        let code = BorderDecorationExportService.exportGlow(g)
        XCTAssertEqual(code.components(separatedBy: ".shadow(").count - 1, 3)
    }

    func test_exportGlow_inner_containsBlur() {
        var g = GlowConfig(); g.type = .inner
        let code = BorderDecorationExportService.exportGlow(g)
        XCTAssertTrue(code.contains(".blur("))
    }

    func test_exportGlow_layered_hasThreePasses() {
        var g = GlowConfig(); g.type = .layered
        let code = BorderDecorationExportService.exportGlow(g)
        XCTAssertEqual(code.components(separatedBy: ".shadow(").count - 1, 3)
    }

    // MARK: ─── Pattern Export ────────────────────────────────────

    func test_exportPattern_grid_containsCanvas() {
        var p = PatternConfig(); p.patternType = .grid
        let code = BorderDecorationExportService.exportPattern(p)
        XCTAssertTrue(code.contains("Canvas"))
    }

    func test_exportPattern_dots_containsEllipse() {
        var p = PatternConfig(); p.patternType = .dots
        let code = BorderDecorationExportService.exportPattern(p)
        XCTAssertTrue(code.contains("ellipseIn"))
    }

    func test_exportPattern_stripes_containsRotate() {
        var p = PatternConfig(); p.patternType = .stripes
        let code = BorderDecorationExportService.exportPattern(p)
        XCTAssertTrue(code.contains("rotate") || code.contains("degrees"))
    }

    // MARK: ─── Export Service Helpers ────────────────────────────

    func test_colorLiteral_containsHex() {
        let result = BorderDecorationExportService.colorLiteral(Color(hex: "#7B6EF6"))
        XCTAssertTrue(result.contains("#"))
        XCTAssertTrue(result.contains("Color"))
    }

    func test_f_wholeNumber() {
        XCTAssertEqual(BorderDecorationExportService.f(12.0), "12")
    }

    func test_f_decimal() {
        XCTAssertEqual(BorderDecorationExportService.f(0.5), "0.50")
    }

    // MARK: ─── Active Description ────────────────────────────────

    func test_activeDescription_corners_containsRadius() {
        vm.selectedTab = .corners
        XCTAssertTrue(vm.activeDescription.contains("\(Int(vm.cornerConfig.radius))"))
    }

    func test_activeDescription_borders_containsStyle() {
        vm.selectedTab = .borders
        XCTAssertTrue(vm.activeDescription.lowercased().contains(vm.borderConfig.styleType.rawValue.lowercased()))
    }

    func test_activeDescription_glow_containsRadius() {
        vm.selectedTab = .glow
        XCTAssertTrue(vm.activeDescription.contains("\(Int(vm.glowConfig.radius))"))
    }

    // MARK: ─── Corner References ─────────────────────────────────

    func test_cornerReferences_notEmpty() {
        XCTAssertFalse(cornerReferences.isEmpty)
    }

    func test_cornerReferences_allHavePositiveRadius() {
        for ref in cornerReferences {
            XCTAssertGreaterThan(ref.radius, 0, "\(ref.label) has 0 radius")
        }
    }

    func test_cornerReferences_allHaveNonEmptyLabel() {
        for ref in cornerReferences {
            XCTAssertFalse(ref.label.isEmpty)
        }
    }

    // MARK: ─── Copy Toast ────────────────────────────────────────

    func test_copyCode_showsToast() {
        vm.copyCode()
        XCTAssertTrue(vm.showCopiedToast)
    }

    func test_copyCode_setsLabel() {
        vm.selectedTab = .glow
        vm.copyCode()
        XCTAssertTrue(vm.copiedLabel.lowercased().contains("glow"))
    }

    func test_copyCode_writesClipboard() {
        vm.copyCode()
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertFalse(clip.isEmpty)
    }

    // MARK: ─── Config Equatable ──────────────────────────────────

    func test_cornerConfig_equatable() {
        let a = CornerConfig()
        var b = CornerConfig()
        XCTAssertEqual(a, b)
        b.radius = 50
        XCTAssertNotEqual(a, b)
    }

    func test_borderConfig_equatable() {
        let a = BorderConfig()
        var b = BorderConfig()
        XCTAssertEqual(a, b)
        b.width = 10
        XCTAssertNotEqual(a, b)
    }

    func test_glowConfig_equatable() {
        let a = GlowConfig()
        var b = GlowConfig()
        XCTAssertEqual(a, b)
        b.radius = 50
        XCTAssertNotEqual(a, b)
    }

    func test_patternConfig_equatable() {
        let a = PatternConfig()
        var b = PatternConfig()
        XCTAssertEqual(a, b)
        b.scale = 100
        XCTAssertNotEqual(a, b)
    }

    // MARK: ─── Preview Shapes ────────────────────────────────────

    func test_previewShapes_allHavePositiveSize() {
        for shape in PreviewShape.allCases {
            XCTAssertGreaterThan(shape.size.width, 0)
            XCTAssertGreaterThan(shape.size.height, 0)
        }
    }
}
