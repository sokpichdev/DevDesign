//
//  FontPairingTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Run: Cmd+U

import XCTest
@testable import DevDesign

final class FontPairingTests: XCTestCase {

    var vm: FontPairingViewModel!

    override func setUp() {
        super.setUp()
        vm = FontPairingViewModel()
    }

    // MARK: ─── Library ────────────────────────────────────────────

    func test_library_isNotEmpty() {
        XCTAssertFalse(FontPairingLibrary.pairs.isEmpty)
    }

    func test_library_coversAllCategories_exceptAll() {
        let categories = Set(FontPairingLibrary.pairs.map(\.category))
        let nonAll = Set(PairingCategory.allCases.filter { $0 != .all })
        XCTAssertEqual(categories, nonAll, "Every non-All category should have at least one pair")
    }

    func test_library_allPairsHaveUniqueIDs() {
        let ids = FontPairingLibrary.pairs.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func test_library_systemPairs_areImmediatelyLoaded() {
        let systemPairs = FontPairingLibrary.pairs.filter { $0.displayFont.isSystem }
        for pair in systemPairs {
            XCTAssertTrue(pair.displayFont.isLoaded, "\(pair.name) display should be loaded")
            XCTAssertTrue(pair.bodyFont.isLoaded,    "\(pair.name) body should be loaded (or system)")
        }
    }

    // MARK: ─── FontSpec ───────────────────────────────────────────

    func test_systemFont_resolvedFamilyName_isSFPro() {
        let spec = FontSpec(id: UUID(), displayName: "SF Pro", source: .system)
        XCTAssertEqual(spec.resolvedFamilyName, "SF Pro")
    }

    func test_systemSerif_isLoaded() {
        let spec = FontSpec(id: UUID(), displayName: "New York", source: .systemSerif)
        XCTAssertTrue(spec.isLoaded)
    }

    func test_googleFont_notLoaded_before_fetch() {
        let spec = FontSpec(id: UUID(), displayName: "Inter", source: .google(family: "Inter"))
        XCTAssertFalse(spec.isLoaded)
    }

    func test_googleFont_isLoaded_after_familyNameSet() {
        var spec = FontSpec(id: UUID(), displayName: "Inter", source: .google(family: "Inter"))
        spec.loadedFamilyName = "Inter-Regular"
        XCTAssertTrue(spec.isLoaded)
    }

    func test_systemFont_uiFont_nonNil() {
        let spec = FontSpec(id: UUID(), displayName: "SF Pro", source: .system)
        let font = spec.uiFont(size: 16)
        XCTAssertEqual(font.pointSize, 16, accuracy: 0.1)
    }

    func test_systemMono_uiFont_isMonospaced() {
        let spec = FontSpec(id: UUID(), displayName: "SF Mono", source: .systemMono)
        let font = spec.uiFont(size: 14)
        XCTAssertTrue(
            font.fontName.lowercased().contains("mono") ||
            font.familyName.lowercased().contains("mono"),
            "Expected mono font, got \(font.fontName)"
        )
    }

    // MARK: ─── ViewModel Filtering ───────────────────────────────

    func test_initialCategory_isAll() {
        XCTAssertEqual(vm.selectedCategory, .all)
    }

    func test_filteredPairs_all_returnsAll() {
        XCTAssertEqual(vm.filteredPairs.count, FontPairingLibrary.pairs.count)
    }

    func test_filteredPairs_byCategory_reducesCount() {
        vm.selectedCategory = .developer
        let developerPairs = vm.filteredPairs
        XCTAssertTrue(developerPairs.allSatisfy { $0.category == .developer })
        XCTAssertLessThan(developerPairs.count, FontPairingLibrary.pairs.count)
    }

    func test_filteredPairs_bySearch_fontName() {
        vm.searchText = "Inter"
        XCTAssertTrue(vm.filteredPairs.count >= 1)
        XCTAssertTrue(vm.filteredPairs.allSatisfy {
            $0.name.contains("Inter") ||
            $0.displayFont.displayName.contains("Inter") ||
            $0.bodyFont.displayName.contains("Inter")
        })
    }

    func test_filteredPairs_bySearch_tag() {
        vm.searchText = "mono"
        XCTAssertTrue(vm.filteredPairs.count >= 1)
    }

    func test_filteredPairs_noMatch_returnsEmpty() {
        vm.searchText = "xyznotfound999"
        XCTAssertTrue(vm.filteredPairs.isEmpty)
    }

    func test_filteredPairs_searchCaseInsensitive() {
        vm.searchText = "INTER"
        let upper = vm.filteredPairs.count
        vm.searchText = "inter"
        let lower = vm.filteredPairs.count
        XCTAssertEqual(upper, lower)
    }

    // MARK: ─── Category Count ─────────────────────────────────────

    func test_categoryCount_all_equalsLibraryCount() {
        XCTAssertEqual(vm.categoryCount[.all], FontPairingLibrary.pairs.count)
    }

    func test_categoryCount_sumOfCategories_equalsTotal() {
        let sum = PairingCategory.allCases
            .filter { $0 != .all }
            .compactMap { vm.categoryCount[$0] }
            .reduce(0, +)
        XCTAssertEqual(sum, FontPairingLibrary.pairs.count)
    }

    // MARK: ─── Load State ─────────────────────────────────────────

    func test_loadState_systemPair_isLoaded() {
        let systemPair = FontPairingLibrary.pairs.first(where: {
            $0.displayFont.isSystem && $0.bodyFont.isSystem
        })!
        XCTAssertEqual(vm.loadingState(for: systemPair), .loaded)
    }

    func test_loadState_googlePair_isIdleBeforeLoad() {
        let googlePair = FontPairingLibrary.pairs.first(where: {
            !$0.displayFont.isSystem
        })!
        XCTAssertEqual(vm.loadingState(for: googlePair), .idle)
    }

    // MARK: ─── Export ─────────────────────────────────────────────

    func test_exportSwiftUI_containsExtension() {
        let pair = FontPairingLibrary.pairs.first!
        let code = FontPairingExportService.exportSwiftUI(pair)
        XCTAssertTrue(code.contains("extension Font"))
    }

    func test_exportSwiftUI_containsDisplayToken() {
        let pair = FontPairingLibrary.pairs.first!
        let code = FontPairingExportService.exportSwiftUI(pair)
        XCTAssertTrue(code.contains("pairingDisplay"))
        XCTAssertTrue(code.contains("pairingBody"))
    }

    func test_exportCSS_containsRoot() {
        let pair = FontPairingLibrary.pairs.first!
        let code = FontPairingExportService.exportCSS(pair)
        XCTAssertTrue(code.contains(":root"))
    }

    func test_exportCSS_containsFontDisplay() {
        let pair = FontPairingLibrary.pairs.first!
        let code = FontPairingExportService.exportCSS(pair)
        XCTAssertTrue(code.contains("--font-display"))
        XCTAssertTrue(code.contains("--font-body"))
    }

    func test_exportCSS_googleFont_containsImport() {
        let googlePair = FontPairingLibrary.pairs.first(where: {
            if case .google = $0.displayFont.source { return true }
            return false
        })!
        let code = FontPairingExportService.exportCSS(googlePair)
        XCTAssertTrue(code.contains("@import"))
        XCTAssertTrue(code.contains("fonts.googleapis.com"))
    }

    func test_exportCSS_systemPair_noImport() {
        let systemPair = FontPairingLibrary.pairs.first(where: {
            $0.displayFont.isSystem && $0.bodyFont.isSystem
        })!
        let code = FontPairingExportService.exportCSS(systemPair)
        XCTAssertFalse(code.contains("@import"))
    }
}
