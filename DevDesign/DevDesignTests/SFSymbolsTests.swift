//
//  SFSymbolsTests.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Run: Cmd+U

import XCTest
@testable import DevDesign

final class SFSymbolsTests: XCTestCase {

    var vm: SFSymbolsViewModel!

    override func setUp() {
        super.setUp()
        vm = SFSymbolsViewModel()
    }

    // MARK: ─── Catalog ───────────────────────────────────────────

    func test_catalog_isNotEmpty() {
        XCTAssertFalse(SFSymbolCatalog.symbols.isEmpty)
    }

    func test_catalog_allSymbolsHaveNonEmptyNames() {
        for symbol in SFSymbolCatalog.symbols {
            XCTAssertFalse(symbol.name.isEmpty, "Symbol has empty name")
        }
    }

    func test_catalog_allIDsAreUnique() {
        let ids = SFSymbolCatalog.symbols.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func test_catalog_allNamesAreUnique() {
        let names = SFSymbolCatalog.symbols.map(\.name)
        XCTAssertEqual(names.count, Set(names).count, "Duplicate symbol names found")
    }

    func test_catalog_coversAllNonAllCategories() {
        let covered = Set(SFSymbolCatalog.symbols.map(\.category))
        let expected = Set(SymbolCategory.allCases.filter { $0 != .all })
        XCTAssertEqual(covered, expected)
    }

    func test_catalog_symbolsAreAvailable_onCurrentOS() {
        // Spot-check a handful of stable symbols
        let stable = ["house", "magnifyingglass", "gear", "person", "heart"]
        for name in stable {
            let sym = SFSymbolCatalog.symbols.first(where: { $0.name == name })
            XCTAssertNotNil(sym, "\(name) missing from catalog")
            XCTAssertTrue(sym?.isAvailable ?? false, "\(name) unavailable on OS")
        }
    }

    // MARK: ─── ViewModel Initial State ───────────────────────────

    func test_vm_initialCategory_isAll() {
        XCTAssertEqual(vm.selectedCategory, .all)
    }

    func test_vm_initialSearch_isEmpty() {
        XCTAssertTrue(vm.searchText.isEmpty)
    }

    func test_vm_initialSize_is24() {
        XCTAssertEqual(vm.previewSize, 24)
    }

    func test_vm_initialWeight_isRegular() {
        XCTAssertEqual(vm.previewWeight, .regular)
    }

    func test_vm_initialFavourites_isEmpty() {
        XCTAssertTrue(vm.favouriteNames.isEmpty)
    }

    // MARK: ─── Filtering ─────────────────────────────────────────

    func test_filter_noSearch_noCategory_returnsAll() {
        XCTAssertEqual(vm.filteredSymbols.count, SFSymbolCatalog.symbols.count)
    }

    func test_filter_byCategory_reducesCount() {
        vm.selectedCategory = .navigation
        let results = vm.filteredSymbols
        XCTAssertTrue(results.allSatisfy { $0.category == .navigation || $0.category == .all })
        XCTAssertLessThan(results.count, SFSymbolCatalog.symbols.count)
    }

    func test_filter_bySearchName_returnsMatch() {
        vm.searchText = "house"
        XCTAssertTrue(vm.filteredSymbols.contains(where: { $0.name == "house" }))
    }

    func test_filter_byKeyword_returnsMatch() {
        vm.searchText = "download"
        XCTAssertFalse(vm.filteredSymbols.isEmpty)
    }

    func test_filter_noMatch_returnsEmpty() {
        vm.searchText = "xyznotareal999symbol"
        // Might return a dynamic entry if UIImage resolves — but our curated list should be empty
        let curatedMatches = vm.filteredSymbols.filter {_ in 
            SFSymbolCatalog.symbols.contains(where: { c in c.id == c.id })
        }
        XCTAssertTrue(curatedMatches.isEmpty)
    }

    func test_filter_caseInsensitive() {
        vm.searchText = "HOUSE"
        let upper = vm.filteredSymbols.count
        vm.searchText = "house"
        let lower = vm.filteredSymbols.count
        XCTAssertEqual(upper, lower)
    }

    func test_filter_favouritesOnly_returnsOnlyFavourites() {
        vm.favouriteNames = ["house", "gear"]
        vm.showFavouritesOnly = true
        XCTAssertTrue(vm.filteredSymbols.allSatisfy { vm.favouriteNames.contains($0.name) })
    }

    func test_filter_favouritesOnly_emptyWhenNoFavourites() {
        vm.showFavouritesOnly = true
        XCTAssertTrue(vm.filteredSymbols.isEmpty)
    }

    // MARK: ─── Favourites ────────────────────────────────────────

    func test_toggleFavourite_adds() {
        let sym = SFSymbolCatalog.symbols.first!
        vm.toggleFavourite(sym)
        XCTAssertTrue(vm.isFavourite(sym))
    }

    func test_toggleFavourite_removes() {
        let sym = SFSymbolCatalog.symbols.first!
        vm.toggleFavourite(sym)
        vm.toggleFavourite(sym)
        XCTAssertFalse(vm.isFavourite(sym))
    }

    func test_isFavourite_falseByDefault() {
        let sym = SFSymbolCatalog.symbols.first!
        XCTAssertFalse(vm.isFavourite(sym))
    }

    // MARK: ─── Category Count ────────────────────────────────────

    func test_categoryCount_all_equalsTotal() {
        XCTAssertEqual(vm.categoryCount[.all], SFSymbolCatalog.symbols.count)
    }

    func test_categoryCount_partsSum_equalsTotal() {
        let sum = SymbolCategory.allCases
            .filter { $0 != .all }
            .compactMap { vm.categoryCount[$0] }
            .reduce(0, +)
        XCTAssertEqual(sum, SFSymbolCatalog.symbols.count)
    }

    // MARK: ─── Copy Actions ──────────────────────────────────────

    func test_copySymbolName_writesClipboard() {
        let sym = SFSymbolCatalog.symbols.first!
        vm.copySymbolName(sym)
        XCTAssertEqual(UIPasteboard.general.string, sym.name)
    }

    func test_copySwiftUI_containsSystemName() {
        let sym = SFSymbolCatalog.symbols.first!
        vm.copySwiftUI(sym)
        XCTAssertTrue(UIPasteboard.general.string?.contains(sym.name) ?? false)
        XCTAssertTrue(UIPasteboard.general.string?.contains("Image(systemName:") ?? false)
    }

    func test_copyUIKit_containsUIImage() {
        let sym = SFSymbolCatalog.symbols.first!
        vm.copyUIKit(sym)
        XCTAssertTrue(UIPasteboard.general.string?.contains("UIImage(systemName:") ?? false)
    }

    func test_copyAction_showsToast() {
        let sym = SFSymbolCatalog.symbols.first!
        vm.copySymbolName(sym)
        XCTAssertTrue(vm.showCopiedToast)
        XCTAssertEqual(vm.copiedLabel, "Name")
    }

    // MARK: ─── Export Service ────────────────────────────────────

    func test_exportSwiftUI_containsImageCall() {
        let sym = SFSymbolCatalog.symbols.first!
        let code = SFSymbolExportService.exportSwiftUI(sym, size: 24, weight: .regular)
        XCTAssertTrue(code.contains("Image(systemName:"))
    }

    func test_exportUIKit_containsSymbolConfiguration() {
        let sym = SFSymbolCatalog.symbols.first!
        let code = SFSymbolExportService.exportUIKit(sym, size: 24, weight: .bold)
        XCTAssertTrue(code.contains("UIImage.SymbolConfiguration"))
    }

    func test_exportButton_containsButtonStruct() {
        let sym = SFSymbolCatalog.symbols.first!
        let code = SFSymbolExportService.exportSwiftUIButton(sym)
        XCTAssertTrue(code.contains("Button"))
    }

    // MARK: ─── SymbolWeight ───────────────────────────────────────

    func test_allWeights_haveSwiftUIValues() {
        for weight in SymbolWeight.allCases {
            XCTAssertFalse(weight.swiftUIValue.isEmpty)
        }
    }

    func test_allWeights_haveUIKitValues() {
        for weight in SymbolWeight.allCases {
            XCTAssertFalse(weight.uiKitValue.isEmpty)
        }
    }
}
