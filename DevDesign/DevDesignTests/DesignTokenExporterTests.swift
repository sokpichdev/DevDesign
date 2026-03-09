//
//  DesignTokenExporterTests.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import XCTest
import SwiftUI
@testable import DevDesign

final class DesignTokenExporterTests: XCTestCase {

    var vm: DesignTokenViewModel!

    override func setUp() {
        super.setUp()
        vm = DesignTokenViewModel()
        vm.seedSampleColors()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initial_sectionIsColors() {
        let fresh = DesignTokenViewModel()
        XCTAssertEqual(fresh.selectedSection, .colors)
    }

    func test_initial_typographyTokensLoaded() {
        XCTAssertFalse(vm.typographyTokens.isEmpty)
    }

    func test_initial_spacingTokensLoaded() {
        XCTAssertFalse(vm.spacingTokens.isEmpty)
    }

    func test_initial_exportFormatIsSwift() {
        XCTAssertEqual(vm.exportFormat, .swiftEnum)
    }

    func test_initial_allIncludesOn() {
        XCTAssertTrue(vm.includeColors)
        XCTAssertTrue(vm.includeTypography)
        XCTAssertTrue(vm.includeSpacing)
    }

    // MARK: ─── Sample Colors ─────────────────────────────────────

    func test_seedSampleColors_populatesColors() {
        XCTAssertGreaterThan(vm.colorTokens.count, 0)
    }

    func test_seedSampleColors_idempotent() {
        let countBefore = vm.colorTokens.count
        vm.seedSampleColors()
        XCTAssertEqual(vm.colorTokens.count, countBefore)
    }

    func test_colorTokens_haveNonEmptyTokenNames() {
        for t in vm.colorTokens {
            XCTAssertFalse(t.tokenName.isEmpty, "color token has empty name")
        }
    }

    func test_colorTokens_haveValidHex() {
        for t in vm.colorTokens {
            XCTAssertTrue(t.hex.hasPrefix("#"), "\(t.tokenName) hex missing #")
            XCTAssertEqual(t.hex.count, 7)
        }
    }

    func test_colorTokens_alphaInRange() {
        for t in vm.colorTokens {
            XCTAssertGreaterThanOrEqual(t.alpha, 0)
            XCTAssertLessThanOrEqual(t.alpha, 1)
        }
    }

    // MARK: ─── Typography Tokens ─────────────────────────────────

    func test_typography_has10Steps() {
        XCTAssertEqual(vm.typographyTokens.count, 10)
    }

    func test_typography_sizesDescending() {
        let sizes = vm.typographyTokens.map(\.size)
        for i in 1..<sizes.count {
            XCTAssertGreaterThan(sizes[i - 1], sizes[i],
                "Step \(i-1) should be larger than step \(i)")
        }
    }

    func test_typography_allHaveNonEmptyTokenName() {
        for t in vm.typographyTokens {
            XCTAssertFalse(t.tokenName.isEmpty)
        }
    }

    func test_typography_allHavePositiveSize() {
        for t in vm.typographyTokens {
            XCTAssertGreaterThan(t.size, 0)
        }
    }

    func test_typography_lineHeightPositive() {
        for t in vm.typographyTokens {
            XCTAssertGreaterThan(t.lineHeight, 0)
        }
    }

    func test_typography_weightNonEmpty() {
        for t in vm.typographyTokens {
            XCTAssertFalse(t.weightRaw.isEmpty)
        }
    }

    // MARK: ─── Spacing Tokens ────────────────────────────────────

    func test_spacing_has8Steps() {
        XCTAssertEqual(vm.spacingTokens.count, 8)
    }

    func test_spacing_valuesAscending() {
        let vals = vm.spacingTokens.map(\.value)
        for i in 1..<vals.count {
            XCTAssertGreaterThan(vals[i], vals[i - 1],
                "Spacing step \(i) should be larger than \(i-1)")
        }
    }

    func test_spacing_allPositiveValues() {
        for s in vm.spacingTokens {
            XCTAssertGreaterThan(s.value, 0)
        }
    }

    func test_spacing_allHaveNonEmptyTokenName() {
        for s in vm.spacingTokens {
            XCTAssertFalse(s.tokenName.isEmpty)
        }
    }

    func test_spacing_allHaveNonEmptyDescription() {
        for s in vm.spacingTokens {
            XCTAssertFalse(s.description.isEmpty)
        }
    }

    // MARK: ─── Token Count ───────────────────────────────────────

    func test_totalTokenCount_equalsSum() {
        let expected = vm.colorTokens.count + vm.typographyTokens.count + vm.spacingTokens.count
        XCTAssertEqual(vm.totalTokenCount, expected)
    }

    func test_sectionTokenCount_colors() {
        vm.selectedSection = .colors
        XCTAssertEqual(vm.sectionTokenCount, vm.colorTokens.count)
    }

    func test_sectionTokenCount_typography() {
        vm.selectedSection = .typography
        XCTAssertEqual(vm.sectionTokenCount, vm.typographyTokens.count)
    }

    func test_sectionTokenCount_spacing() {
        vm.selectedSection = .spacing
        XCTAssertEqual(vm.sectionTokenCount, vm.spacingTokens.count)
    }

    // MARK: ─── Search Filtering ──────────────────────────────────

    func test_search_empty_returnsAll() {
        vm.searchText = ""
        XCTAssertEqual(vm.filteredColors.count, vm.colorTokens.count)
    }

    func test_search_colors_byTokenName() {
        let first = vm.colorTokens.first!
        vm.searchText = first.tokenName.prefix(3).lowercased()
        XCTAssertTrue(vm.filteredColors.contains { $0.id == first.id })
    }

    func test_search_colors_noMatch() {
        vm.searchText = "zzznomatch999"
        XCTAssertTrue(vm.filteredColors.isEmpty)
    }

    func test_search_typography_byName() {
        vm.searchText = "body"
        XCTAssertTrue(vm.filteredTypography.contains { $0.tokenName.lowercased().contains("body")
            || $0.name.lowercased().contains("body") })
    }

    func test_search_spacing_byToken() {
        vm.searchText = "spacingMD"
        XCTAssertFalse(vm.filteredSpacing.isEmpty)
    }

    // MARK: ─── Inline Rename ─────────────────────────────────────

    func test_beginRename_setsEditingId() {
        let t = vm.colorTokens.first!
        vm.beginRename(id: t.id, currentName: t.tokenName)
        XCTAssertEqual(vm.editingTokenId, t.id)
    }

    func test_beginRename_setsEditingName() {
        let t = vm.colorTokens.first!
        vm.beginRename(id: t.id, currentName: t.tokenName)
        XCTAssertEqual(vm.editingTokenName, t.tokenName)
    }

    func test_commitRename_updatesToken() {
        let t = vm.colorTokens.first!
        vm.beginRename(id: t.id, currentName: t.tokenName)
        vm.editingTokenName = "newTokenName"
        vm.commitRename()
        XCTAssertEqual(vm.colorTokens.first!.tokenName, "newTokenName")
    }

    func test_commitRename_camelCasesInput() {
        let t = vm.colorTokens.first!
        vm.beginRename(id: t.id, currentName: t.tokenName)
        vm.editingTokenName = "brand color primary"
        vm.commitRename()
        XCTAssertEqual(vm.colorTokens.first!.tokenName, "brandColorPrimary")
    }

    func test_commitRename_emptyIgnored() {
        let t = vm.colorTokens.first!
        let originalName = t.tokenName
        vm.beginRename(id: t.id, currentName: originalName)
        vm.editingTokenName = "   "
        vm.commitRename()
        // Name should be unchanged
        XCTAssertEqual(vm.colorTokens.first!.tokenName, originalName)
    }

    func test_cancelRename_clearsState() {
        let t = vm.colorTokens.first!
        vm.beginRename(id: t.id, currentName: t.tokenName)
        vm.cancelRename()
        XCTAssertNil(vm.editingTokenId)
        XCTAssertTrue(vm.editingTokenName.isEmpty)
    }

    func test_commitRename_typography() {
        let t = vm.typographyTokens.first!
        vm.beginRename(id: t.id, currentName: t.tokenName)
        vm.editingTokenName = "heroText"
        vm.commitRename()
        XCTAssertEqual(vm.typographyTokens.first!.tokenName, "heroText")
    }

    func test_commitRename_spacing() {
        let t = vm.spacingTokens.first!
        vm.beginRename(id: t.id, currentName: t.tokenName)
        vm.editingTokenName = "gapTiny"
        vm.commitRename()
        XCTAssertEqual(vm.spacingTokens.first!.tokenName, "gapTiny")
    }

    // MARK: ─── Swift Export ──────────────────────────────────────

    func test_swiftExport_containsEnumDesignTokens() {
        let code = vm.exportCode(format: .swiftEnum)
        XCTAssertTrue(code.contains("enum DesignTokens"))
    }

    func test_swiftExport_containsColorsEnum() {
        let code = vm.exportCode(format: .swiftEnum)
        XCTAssertTrue(code.contains("enum Colors"))
    }

    func test_swiftExport_containsTypographyEnum() {
        let code = vm.exportCode(format: .swiftEnum)
        XCTAssertTrue(code.contains("enum Typography"))
    }

    func test_swiftExport_containsSpacingEnum() {
        let code = vm.exportCode(format: .swiftEnum)
        XCTAssertTrue(code.contains("enum Spacing"))
    }

    func test_swiftExport_containsColorHex() {
        let code = vm.exportCode(format: .swiftEnum)
        let hex = vm.colorTokens.first!.hex
        XCTAssertTrue(code.contains(hex))
    }

    func test_swiftExport_noColors_omitsColorsSection() {
        vm.includeColors = false
        let code = vm.exportCode(format: .swiftEnum)
        XCTAssertFalse(code.contains("enum Colors"))
    }

    func test_swiftExport_noTypography_omitsTypographySection() {
        vm.includeTypography = false
        let code = vm.exportCode(format: .swiftEnum)
        XCTAssertFalse(code.contains("enum Typography"))
    }

    func test_swiftExport_noSpacing_omitsSpacingSection() {
        vm.includeSpacing = false
        let code = vm.exportCode(format: .swiftEnum)
        XCTAssertFalse(code.contains("enum Spacing"))
    }

    // MARK: ─── JSON Export ───────────────────────────────────────

    func test_jsonExport_containsColorsKey() {
        let code = vm.exportCode(format: .json)
        XCTAssertTrue(code.contains("\"colors\""))
    }

    func test_jsonExport_containsTypographyKey() {
        let code = vm.exportCode(format: .json)
        XCTAssertTrue(code.contains("\"typography\""))
    }

    func test_jsonExport_containsSpacingKey() {
        let code = vm.exportCode(format: .json)
        XCTAssertTrue(code.contains("\"spacing\""))
    }

    func test_jsonExport_containsW3CType() {
        let code = vm.exportCode(format: .json)
        XCTAssertTrue(code.contains("\"$type\""))
    }

    func test_jsonExport_containsW3CValue() {
        let code = vm.exportCode(format: .json)
        XCTAssertTrue(code.contains("\"$value\""))
    }

    func test_jsonExport_openBraces() {
        let code = vm.exportCode(format: .json)
        let open  = code.filter { $0 == "{" }.count
        let close = code.filter { $0 == "}" }.count
        XCTAssertEqual(open, close, "JSON braces unbalanced")
    }

    // MARK: ─── CSS Export ────────────────────────────────────────

    func test_cssExport_containsRoot() {
        let code = vm.exportCode(format: .css)
        XCTAssertTrue(code.contains(":root {"))
    }

    func test_cssExport_containsColorVars() {
        let code = vm.exportCode(format: .css)
        XCTAssertTrue(code.contains("--color-"))
    }

    func test_cssExport_containsTypeVars() {
        let code = vm.exportCode(format: .css)
        XCTAssertTrue(code.contains("--type-"))
    }

    func test_cssExport_containsSpacingVars() {
        let code = vm.exportCode(format: .css)
        XCTAssertTrue(code.contains("--spacing-"))
    }

    func test_cssExport_closingBrace() {
        let code = vm.exportCode(format: .css)
        XCTAssertTrue(code.hasSuffix("}"))
    }

    // MARK: ─── All Export ────────────────────────────────────────

    func test_allExport_containsSwift() {
        let code = vm.exportCode(format: .all)
        XCTAssertTrue(code.contains("enum DesignTokens"))
    }

    func test_allExport_containsJSON() {
        let code = vm.exportCode(format: .all)
        XCTAssertTrue(code.contains("\"$type\""))
    }

    func test_allExport_containsCSS() {
        let code = vm.exportCode(format: .all)
        XCTAssertTrue(code.contains(":root {"))
    }

    // MARK: ─── Export Service Helpers ────────────────────────────

    func test_safeName_lowercasesFirst() {
        let result = DesignTokenExportService.safeName("MyPalette")
        XCTAssertEqual(result.first, "m")
    }

    func test_safeName_removesSpaces() {
        let result = DesignTokenExportService.safeName("my palette")
        XCTAssertFalse(result.contains(" "))
    }

    func test_swiftTypeName_capitalizes() {
        let result = DesignTokenExportService.swiftTypeName("my palette")
        XCTAssertEqual(result, "MyPalette")
    }

    func test_kebab_convertsFromCamel() {
        XCTAssertEqual(DesignTokenExportService.kebab("colorPrimary"), "color-primary")
    }

    func test_kebab_alreadyLowercase() {
        XCTAssertEqual(DesignTokenExportService.kebab("color"), "color")
    }

    func test_cssWeight_semibold() {
        XCTAssertEqual(DesignTokenExportService.cssWeight("semibold"), "600")
    }

    func test_cssWeight_bold() {
        XCTAssertEqual(DesignTokenExportService.cssWeight("bold"), "700")
    }

    func test_cssWeight_regular() {
        XCTAssertEqual(DesignTokenExportService.cssWeight("regular"), "400")
    }

    func test_tokenName_fromLabel() {
        let result = DesignTokenExportService.tokenName(from: "Brand Primary", hex: "#FF0000", index: 0)
        XCTAssertEqual(result, "brandPrimary")
    }

    func test_tokenName_fromHexFallback() {
        let result = DesignTokenExportService.tokenName(from: "", hex: "#FF0000", index: 3)
        XCTAssertTrue(result.hasPrefix("color"))
    }

    func test_f_wholeNumber() {
        XCTAssertEqual(DesignTokenExportService.f(16.0), "16")
    }

    func test_f_decimal() {
        XCTAssertEqual(DesignTokenExportService.f(0.5), "0.50")
    }

    // MARK: ─── Copy / Toast ──────────────────────────────────────

    func test_copyExport_showsToast() {
        vm.copyExport(format: .swiftEnum)
        XCTAssertTrue(vm.showCopiedToast)
    }

    func test_copyExport_setsLabel() {
        vm.copyExport(format: .css)
        XCTAssertTrue(vm.copiedLabel.lowercased().contains("css"))
    }

    func test_copyExport_writesClipboard() {
        vm.copyExport(format: .json)
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertFalse(clip.isEmpty)
    }

    // MARK: ─── UpdateColors from Palettes ────────────────────────

    func test_updateColors_fromEmptyPalettes_clearsIfChanged() {
        // Start with sample colors
        XCTAssertFalse(vm.colorTokens.isEmpty)
        // Updating with empty should clear
        vm.colorTokens = []  // simulate first state
        vm.updateColors(from: [])
        XCTAssertTrue(vm.colorTokens.isEmpty)
    }
}
