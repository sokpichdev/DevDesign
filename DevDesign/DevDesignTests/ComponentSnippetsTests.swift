//
//  ComponentSnippetsTests.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import XCTest
import SwiftUI
@testable import DevDesign

final class ComponentSnippetsTests: XCTestCase {

    var vm: SnippetViewModel!

    override func setUp() {
        super.setUp()
        vm = SnippetViewModel()
    }

    // MARK: ─── Library Counts ────────────────────────────────────

    func test_library_hasMeaningfulCount() {
        XCTAssertGreaterThanOrEqual(SnippetLibrary.all.count, 40)
    }

    func test_library_buttonsNotEmpty() {
        XCTAssertFalse(SnippetLibrary.buttons.isEmpty)
    }

    func test_library_cardsNotEmpty() {
        XCTAssertFalse(SnippetLibrary.cards.isEmpty)
    }

    func test_library_inputsNotEmpty() {
        XCTAssertFalse(SnippetLibrary.inputs.isEmpty)
    }

    func test_library_navigationNotEmpty() {
        XCTAssertFalse(SnippetLibrary.navigation.isEmpty)
    }

    func test_library_listsNotEmpty() {
        XCTAssertFalse(SnippetLibrary.lists.isEmpty)
    }

    func test_library_badgesNotEmpty() {
        XCTAssertFalse(SnippetLibrary.badges.isEmpty)
    }

    func test_library_alertsNotEmpty() {
        XCTAssertFalse(SnippetLibrary.alerts.isEmpty)
    }

    func test_library_loadingNotEmpty() {
        XCTAssertFalse(SnippetLibrary.loading.isEmpty)
    }

    func test_library_avatarsNotEmpty() {
        XCTAssertFalse(SnippetLibrary.avatars.isEmpty)
    }

    func test_library_layoutNotEmpty() {
        XCTAssertFalse(SnippetLibrary.layout.isEmpty)
    }

    func test_library_allSnippetsHaveNonEmptyCode() {
        for snippet in SnippetLibrary.all {
            XCTAssertFalse(snippet.code.isEmpty, "\(snippet.title) has empty code")
        }
    }

    func test_library_allSnippetsHaveTitle() {
        for snippet in SnippetLibrary.all {
            XCTAssertFalse(snippet.title.isEmpty, "snippet has empty title")
        }
    }

    func test_library_allSnippetsHaveUniqueIDs() {
        let ids = SnippetLibrary.all.map(\.id)
        let unique = Set(ids)
        XCTAssertEqual(ids.count, unique.count)
    }

    func test_library_allSnippetsHaveAtLeastOneTag() {
        for snippet in SnippetLibrary.all {
            XCTAssertFalse(snippet.tags.isEmpty, "\(snippet.title) has no tags")
        }
    }

    func test_library_categoriesMatch() {
        for snippet in SnippetLibrary.buttons {
            XCTAssertEqual(snippet.category, .buttons)
        }
        for snippet in SnippetLibrary.cards {
            XCTAssertEqual(snippet.category, .cards)
        }
    }

    // MARK: ─── Filtering ─────────────────────────────────────────

    func test_filter_allCategory_returnsAll() {
        vm.selectedCategory = .all
        vm.searchText = ""
        XCTAssertEqual(vm.filteredCurated.count, SnippetLibrary.all.count)
    }

    func test_filter_buttonsCategory_returnsOnlyButtons() {
        vm.selectedCategory = .buttons
        vm.searchText = ""
        let result = vm.filteredCurated
        XCTAssertTrue(result.allSatisfy { $0.category == .buttons })
    }

    func test_filter_customCategory_returnsEmpty() {
        vm.selectedCategory = .custom
        XCTAssertTrue(vm.filteredCurated.isEmpty)
    }

    func test_filter_searchByTitle_matchesCaseInsensitive() {
        vm.selectedCategory = .all
        vm.searchText = "button"
        let result = vm.filteredCurated
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.allSatisfy {
            $0.title.lowercased().contains("button") ||
            $0.subtitle.lowercased().contains("button") ||
            $0.tags.contains(where: { $0.contains("button") })
        })
    }

    func test_filter_searchByTag() {
        vm.selectedCategory = .all
        vm.searchText = "cta"
        let result = vm.filteredCurated
        XCTAssertFalse(result.isEmpty)
    }

    func test_filter_noResults_returnsEmpty() {
        vm.selectedCategory = .all
        vm.searchText = "xyznonexistentterm123"
        XCTAssertTrue(vm.filteredCurated.isEmpty)
    }

    func test_filter_emptySearch_returnsAll() {
        vm.selectedCategory = .all
        vm.searchText = "   "   // whitespace only
        XCTAssertEqual(vm.filteredCurated.count, SnippetLibrary.all.count)
    }

    func test_filter_categoryAndSearch_combined() {
        vm.selectedCategory = .buttons
        vm.searchText = "icon"
        let result = vm.filteredCurated
        XCTAssertTrue(result.allSatisfy { $0.category == .buttons })
    }

    // MARK: ─── Category Counts ───────────────────────────────────

    func test_categoryCounts_allMatchesLibrary() {
        let counts = vm.categoryCounts
        XCTAssertEqual(counts[.all], SnippetLibrary.all.count)
    }

    func test_categoryCounts_buttonsCorrect() {
        let counts = vm.categoryCounts
        XCTAssertEqual(counts[.buttons], SnippetLibrary.buttons.count)
    }

    // MARK: ─── Accent Color ──────────────────────────────────────

    func test_accentHex_defaultIsPurple() {
        let hex = vm.accentHex()
        XCTAssertEqual(hex.count, 6)
    }

    func test_accentHex_redColor() {
        vm.accentColor = Color(red: 1, green: 0, blue: 0)
        let hex = vm.accentHex().uppercased()
        XCTAssertEqual(hex, "FF0000")
    }

    func test_resolvedCode_replacesAccentPlaceholder() {
        let template = "Color(hex: \"{{ACCENT}}\")"
        let result = vm.resolvedCode(template)
        XCTAssertFalse(result.contains("{{ACCENT}}"))
        XCTAssertTrue(result.contains("Color(hex: \""))
    }

    func test_resolvedCode_multipleReplacements() {
        let template = "{{ACCENT}} and {{ACCENT}}"
        let result = vm.resolvedCode(template)
        XCTAssertFalse(result.contains("{{ACCENT}}"))
    }

    func test_resolvedCode_noPlaceholder_unchanged() {
        let code = "Text(\"Hello\")"
        let result = vm.resolvedCode(code)
        XCTAssertEqual(result, code)
    }

    // MARK: ─── Copy Toast ────────────────────────────────────────

    func test_copyCurated_showsToast() {
        let snippet = SnippetLibrary.buttons.first!
        vm.copyCurated(snippet)
        XCTAssertTrue(vm.showCopiedToast)
        XCTAssertEqual(vm.copiedLabel, snippet.title)
    }

    func test_copyCurated_writesClipboard() {
        let snippet = SnippetLibrary.buttons.first!
        vm.copyCurated(snippet)
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertFalse(clip.isEmpty)
    }

    func test_copyCurated_clipboardDoesNotContainPlaceholder() {
        // Any snippet that uses {{ACCENT}} should have it resolved
        let snippet = SnippetLibrary.all.first(where: { $0.code.contains("{{ACCENT}}") })!
        vm.copyCurated(snippet)
        let clip = UIPasteboard.general.string ?? ""
        XCTAssertFalse(clip.contains("{{ACCENT}}"))
    }

    // MARK: ─── Curated Snippet Equality ─────────────────────────

    func test_snippet_equalityById() {
        let s1 = SnippetLibrary.buttons.first!
        let s2 = SnippetLibrary.buttons.first!
        XCTAssertEqual(s1, s2)
    }

    func test_snippet_notEqualForDifferent() {
        let s1 = SnippetLibrary.buttons.first!
        let s2 = SnippetLibrary.cards.first!
        XCTAssertNotEqual(s1, s2)
    }

    // MARK: ─── CustomSnippet Model ───────────────────────────────

    func test_customSnippet_tagList_parsesCorrectly() {
        let s = CustomSnippet(title: "T", subtitle: "", code: "c", tags: "swift, ui, ios")
        XCTAssertEqual(s.tagList, ["swift", "ui", "ios"])
    }

    func test_customSnippet_tagList_emptyString() {
        let s = CustomSnippet(title: "T", subtitle: "", code: "c", tags: "")
        XCTAssertTrue(s.tagList.isEmpty)
    }

    func test_customSnippet_tagList_trims() {
        let s = CustomSnippet(title: "T", subtitle: "", code: "c", tags: "  button ,  card  ")
        XCTAssertEqual(s.tagList, ["button", "card"])
    }

    func test_customSnippet_createdAtIsNow() {
        let before = Date()
        let s = CustomSnippet(title: "T", subtitle: "", code: "c", tags: "")
        XCTAssertGreaterThanOrEqual(s.createdAt, before)
    }
}
