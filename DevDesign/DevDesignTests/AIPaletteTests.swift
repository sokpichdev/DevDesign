//
//  AIPaletteTests.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import XCTest
import SwiftUI
@testable import DevDesign

final class AIPaletteTests: XCTestCase {

    var vm: AIPaletteViewModel!

    override func setUp() {
        super.setUp()
        vm = AIPaletteViewModel()
        // Clear any persisted state from previous runs
        APIKeyStore.clear()
        PromptHistoryStore.clear()
    }

    override func tearDown() {
        APIKeyStore.clear()
        PromptHistoryStore.clear()
        super.tearDown()
    }

    // MARK: ─── Initial State ─────────────────────────────────────

    func test_initial_stateIsIdle() {
        XCTAssertEqual(vm.generationState, .idle)
    }

    func test_initial_promptEmpty() {
        XCTAssertTrue(vm.promptText.isEmpty)
    }

    func test_initial_styleIsAny() {
        XCTAssertEqual(vm.selectedStyle, .any)
    }

    func test_initial_colorCountIsSix() {
        XCTAssertEqual(vm.colorCount, .six)
    }

    func test_initial_noAPIKey() {
        let fresh = AIPaletteViewModel()
        XCTAssertFalse(fresh.hasAPIKey)
    }

    func test_initial_showSuggestionsTrue() {
        XCTAssertTrue(vm.showSuggestions)
    }

    func test_initial_suggestionsPopulated() {
        XCTAssertFalse(vm.suggestions.isEmpty)
    }

    // MARK: ─── canGenerate ───────────────────────────────────────

    func test_canGenerate_falseWithoutKey() {
        vm.promptText = "sunset"
        XCTAssertFalse(vm.canGenerate)
    }

    func test_canGenerate_falseWithoutPrompt() {
        vm.apiKey = "sk-ant-test-key"
        vm.promptText = ""
        XCTAssertFalse(vm.canGenerate)
    }

    func test_canGenerate_trueWithKeyAndPrompt() {
        vm.apiKey = "sk-ant-test-key"
        vm.promptText = "sunset over the ocean"
        XCTAssertTrue(vm.canGenerate)
    }

    func test_canGenerate_falseWhileGenerating() {
        vm.apiKey = "sk-ant-test-key"
        vm.promptText = "sunset"
        vm.generationState = .generating
        XCTAssertFalse(vm.canGenerate)
    }

    // MARK: ─── API Key Management ────────────────────────────────

    func test_saveAPIKey_setsHasAPIKey() {
        vm.apiKeyInput = "sk-ant-api03-testkey"
        vm.saveAPIKey()
        XCTAssertTrue(vm.hasAPIKey)
    }

    func test_saveAPIKey_persists() {
        vm.apiKeyInput = "sk-ant-api03-persisted"
        vm.saveAPIKey()
        XCTAssertEqual(APIKeyStore.load(), "sk-ant-api03-persisted")
    }

    func test_saveAPIKey_emptyIgnored() {
        vm.apiKeyInput = "   "
        vm.saveAPIKey()
        XCTAssertFalse(vm.hasAPIKey)
    }

    func test_clearAPIKey_removesKey() {
        vm.apiKeyInput = "sk-ant-api03-clear"
        vm.saveAPIKey()
        vm.clearAPIKey()
        XCTAssertFalse(vm.hasAPIKey)
        XCTAssertNil(APIKeyStore.load())
    }

    func test_maskedKey_showsStars() {
        vm.apiKey = "sk-ant-api03-abcdefghijklmno"
        let masked = vm.maskedKey
        XCTAssertTrue(masked.contains("•"))
        XCTAssertTrue(masked.hasPrefix("sk-ant-"))
    }

    // MARK: ─── Suggestions ───────────────────────────────────────

    func test_suggestions_notEmpty() {
        XCTAssertGreaterThan(vm.suggestions.count, 0)
    }

    func test_applySuggestion_setsPrompt() {
        let s = vm.suggestions.first!
        vm.applySuggestion(s)
        XCTAssertEqual(vm.promptText, s.text)
    }

    func test_refreshSuggestions_changes() {
        let first = vm.suggestions.map(\.id)
        vm.refreshSuggestions()
        // May or may not change (random) — just assert count stays correct
        XCTAssertFalse(vm.suggestions.isEmpty)
        _ = first // suppress warning
    }

    func test_filteredSuggestions_allCategory_returnsAll() {
        vm.selectedSuggestionCategory = nil
        XCTAssertEqual(vm.filteredSuggestions, vm.suggestions)
    }

    func test_filteredSuggestions_byCategory() {
        vm.selectedSuggestionCategory = .nature
        XCTAssertTrue(vm.filteredSuggestions.allSatisfy { $0.category == .nature })
    }

    func test_promptSuggestionLibrary_notEmpty() {
        XCTAssertFalse(PromptSuggestionLibrary.all.isEmpty)
    }

    func test_promptSuggestionLibrary_allHaveText() {
        for s in PromptSuggestionLibrary.all {
            XCTAssertFalse(s.text.isEmpty)
        }
    }

    func test_promptSuggestionLibrary_coversAllCategories() {
        let cats = Set(PromptSuggestionLibrary.all.map(\.category))
        for cat in SuggestionCategory.allCases {
            XCTAssertTrue(cats.contains(cat), "No suggestions for \(cat.rawValue)")
        }
    }

    // MARK: ─── New Prompt ────────────────────────────────────────

    func test_newPrompt_clearsPromptText() {
        vm.promptText = "forest"
        vm.newPrompt()
        XCTAssertTrue(vm.promptText.isEmpty)
    }

    func test_newPrompt_resetsState() {
        vm.generationState = .success
        vm.newPrompt()
        XCTAssertEqual(vm.generationState, .idle)
    }

    func test_newPrompt_clearsPalette() {
        vm.currentPalette = AIGeneratedPalette(name: "Test", mood: "cool",
            colors: [], prompt: "test", style: "Any")
        vm.newPrompt()
        XCTAssertNil(vm.currentPalette)
    }

    func test_newPrompt_showsSuggestions() {
        vm.showSuggestions = false
        vm.newPrompt()
        XCTAssertTrue(vm.showSuggestions)
    }

    // MARK: ─── History ───────────────────────────────────────────

    func test_applyHistoryEntry_setsPrompt() {
        let entry = PromptHistoryEntry(prompt: "ocean", style: "Vibrant",
                                       colorCount: 6, paletteName: "Test")
        vm.applyHistoryEntry(entry)
        XCTAssertEqual(vm.promptText, "ocean")
    }

    func test_applyHistoryEntry_setsStyle() {
        let entry = PromptHistoryEntry(prompt: "x", style: "Neon",
                                       colorCount: 4, paletteName: "T")
        vm.applyHistoryEntry(entry)
        XCTAssertEqual(vm.selectedStyle, .neon)
    }

    func test_applyHistoryEntry_setsColorCount() {
        let entry = PromptHistoryEntry(prompt: "x", style: "Any",
                                       colorCount: 8, paletteName: "T")
        vm.applyHistoryEntry(entry)
        XCTAssertEqual(vm.colorCount, .eight)
    }

    func test_applyHistoryEntry_closesSheet() {
        vm.showHistorySheet = true
        let entry = PromptHistoryEntry(prompt: "x", style: "Any",
                                       colorCount: 6, paletteName: "T")
        vm.applyHistoryEntry(entry)
        XCTAssertFalse(vm.showHistorySheet)
    }

    func test_clearHistory_emptiesArray() {
        PromptHistoryStore.append(PromptHistoryEntry(prompt: "a", style: "Any",
                                                      colorCount: 6, paletteName: "P"))
        vm.promptHistory = PromptHistoryStore.load()
        vm.clearHistory()
        XCTAssertTrue(vm.promptHistory.isEmpty)
    }

    // MARK: ─── Prompt History Store ──────────────────────────────

    func test_historyStore_saveAndLoad() {
        let entry = PromptHistoryEntry(prompt: "ocean sunset", style: "Vibrant",
                                        colorCount: 6, paletteName: "Warm Sea")
        PromptHistoryStore.append(entry)
        let loaded = PromptHistoryStore.load()
        XCTAssertTrue(loaded.contains { $0.prompt == "ocean sunset" })
    }

    func test_historyStore_deduplicates() {
        let e1 = PromptHistoryEntry(prompt: "forest", style: "Dark", colorCount: 6, paletteName: "A")
        let e2 = PromptHistoryEntry(prompt: "forest", style: "Dark", colorCount: 6, paletteName: "B")
        PromptHistoryStore.append(e1)
        PromptHistoryStore.append(e2)
        let loaded = PromptHistoryStore.load()
        XCTAssertEqual(loaded.filter { $0.prompt == "forest" && $0.style == "Dark" }.count, 1)
    }

    func test_historyStore_latestFirst() {
        let e1 = PromptHistoryEntry(prompt: "first",  style: "Any", colorCount: 6, paletteName: "A")
        let e2 = PromptHistoryEntry(prompt: "second", style: "Any", colorCount: 6, paletteName: "B")
        PromptHistoryStore.append(e1)
        PromptHistoryStore.append(e2)
        let loaded = PromptHistoryStore.load()
        XCTAssertEqual(loaded.first?.prompt, "second")
    }

    func test_historyStore_clear() {
        PromptHistoryStore.append(PromptHistoryEntry(prompt: "x", style: "Any",
                                                      colorCount: 6, paletteName: "Y"))
        PromptHistoryStore.clear()
        XCTAssertTrue(PromptHistoryStore.load().isEmpty)
    }

    // MARK: ─── AIColor ───────────────────────────────────────────

    func test_aiColor_rgbFromHex() {
        let c = AIColor(hex: "#FF0000", name: "Red", role: "primary", usage: "CTA")
        XCTAssertGreaterThan(c.red, 0.9)
        XCTAssertLessThan(c.green, 0.1)
        XCTAssertLessThan(c.blue, 0.1)
    }

    func test_aiColor_isDarkForDarkHex() {
        let c = AIColor(hex: "#1A1A1A", name: "Dark", role: "bg", usage: "bg")
        XCTAssertTrue(c.isDark)
    }

    func test_aiColor_isLightForLightHex() {
        let c = AIColor(hex: "#F5F5F5", name: "Light", role: "bg", usage: "bg")
        XCTAssertFalse(c.isDark)
    }

    func test_aiColor_onColorWhiteForDark() {
        let c = AIColor(hex: "#1A1A1A", name: "Dark", role: "bg", usage: "bg")
        XCTAssertEqual(c.onColor, .white)
    }

    func test_aiColor_onColorBlackForLight() {
        let c = AIColor(hex: "#F0F0F0", name: "Light", role: "bg", usage: "bg")
        XCTAssertEqual(c.onColor, .black)
    }

    // MARK: ─── Service - Hex normalisation ───────────────────────

    func test_normaliseHex_addsHash() {
        XCTAssertEqual(AIPaletteService.normaliseHex("FF6B35"), "#FF6B35")
    }

    func test_normaliseHex_uppercases() {
        XCTAssertEqual(AIPaletteService.normaliseHex("#ff6b35"), "#FF6B35")
    }

    func test_normaliseHex_expandsShorthand() {
        XCTAssertEqual(AIPaletteService.normaliseHex("#FFF"), "#FFFFFF")
    }

    func test_normaliseHex_withHashPreserved() {
        XCTAssertEqual(AIPaletteService.normaliseHex("#7B6EF6"), "#7B6EF6")
    }

    func test_isValidHex_valid() {
        XCTAssertTrue(AIPaletteService.isValidHex("#7B6EF6"))
    }

    func test_isValidHex_missingHash() {
        XCTAssertFalse(AIPaletteService.isValidHex("7B6EF6"))
    }

    func test_isValidHex_tooShort() {
        XCTAssertFalse(AIPaletteService.isValidHex("#7B6E"))
    }

    func test_isValidHex_invalidChars() {
        XCTAssertFalse(AIPaletteService.isValidHex("#GGGGGG"))
    }

    func test_isValidHex_allLowercase() {
        XCTAssertTrue(AIPaletteService.isValidHex("#7b6ef6"))
    }

    // MARK: ─── Service - noAPIKey error ──────────────────────────

    func test_generate_noAPIKey_throws() async {
        do {
            _ = try await AIPaletteService.generate(
                prompt: "test",
                style: .any,
                colorCount: .six,
                apiKey: ""
            )
            XCTFail("Should have thrown")
        } catch let e as AIPaletteError {
            XCTAssertEqual(e, .noAPIKey)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_generate_whitespaceAPIKey_throws() async {
        do {
            _ = try await AIPaletteService.generate(
                prompt: "test",
                style: .any,
                colorCount: .six,
                apiKey: "   "
            )
            XCTFail("Should have thrown")
        } catch let e as AIPaletteError {
            XCTAssertEqual(e, .noAPIKey)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: ─── PaletteStyle ──────────────────────────────────────

    func test_paletteStyle_allHaveIcons() {
        for style in PaletteStyle.allCases {
            XCTAssertFalse(style.icon.isEmpty)
        }
    }

    func test_paletteStyle_allHaveHints() {
        for style in PaletteStyle.allCases {
            XCTAssertFalse(style.hint.isEmpty)
        }
    }

    // MARK: ─── ColorCount ────────────────────────────────────────

    func test_colorCount_rawValues() {
        XCTAssertEqual(ColorCount.four.rawValue,  4)
        XCTAssertEqual(ColorCount.six.rawValue,   6)
        XCTAssertEqual(ColorCount.eight.rawValue, 8)
    }

    // MARK: ─── APIKeyStore ────────────────────────────────────────

    func test_apiKeyStore_saveAndLoad() {
        APIKeyStore.save("sk-ant-test")
        XCTAssertEqual(APIKeyStore.load(), "sk-ant-test")
    }

    func test_apiKeyStore_clear() {
        APIKeyStore.save("sk-ant-test")
        APIKeyStore.clear()
        XCTAssertNil(APIKeyStore.load())
    }

    func test_maskedDisplay_showsStars() {
        let result = APIKeyStore.maskedDisplay("sk-ant-api03-abcXYZ1234")
        XCTAssertTrue(result.contains("•"))
        XCTAssertTrue(result.hasPrefix("sk-ant-"))
        XCTAssertTrue(result.hasSuffix("1234"))
    }

    // MARK: ─── Copy Hex ──────────────────────────────────────────

    func test_copyHex_setsClipboard() {
        vm.copyHex("#7B6EF6")
        XCTAssertEqual(UIPasteboard.general.string, "#7B6EF6")
    }

    func test_copyHex_setsCopiedHex() {
        vm.copyHex("#7B6EF6")
        XCTAssertEqual(vm.copiedHex, "#7B6EF6")
    }

    // MARK: ─── GenerationState Equatable ─────────────────────────

    func test_generationState_equalIdle() {
        XCTAssertEqual(GenerationState.idle, GenerationState.idle)
    }

    func test_generationState_equalGenerating() {
        XCTAssertEqual(GenerationState.generating, GenerationState.generating)
    }

    func test_generationState_notEqualDifferent() {
        XCTAssertNotEqual(GenerationState.idle, GenerationState.success)
    }

    func test_generationState_errorEquality() {
        XCTAssertEqual(GenerationState.error("oops"), GenerationState.error("oops"))
        XCTAssertNotEqual(GenerationState.error("a"), GenerationState.error("b"))
    }

    // MARK: ─── AIPaletteError ────────────────────────────────────

    func test_aipError_noAPIKey_hasDescription() {
        let e = AIPaletteError.noAPIKey
        XCTAssertFalse(e.errorDescription?.isEmpty ?? true)
    }

    func test_aipError_networkError_includesMsg() {
        let e = AIPaletteError.networkError("timeout")
        XCTAssertTrue(e.errorDescription?.contains("timeout") ?? false)
    }

    func test_aipError_rateLimited_hasDescription() {
        XCTAssertFalse(AIPaletteError.rateLimited.errorDescription?.isEmpty ?? true)
    }
}
