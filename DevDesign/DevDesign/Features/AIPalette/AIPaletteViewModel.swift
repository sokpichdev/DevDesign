//
//  AIPaletteViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class AIPaletteViewModel {

    // MARK: - Prompt state
    var promptText: String        = ""
    var selectedStyle: PaletteStyle = .any
    var colorCount: ColorCount    = .six

    // MARK: - Generation state
    var generationState: GenerationState = .idle
    var currentPalette: AIGeneratedPalette? = nil
    var revealedColorCount: Int   = 0          // drives staggered reveal animation
    var isAnimatingReveal: Bool   = false

    // MARK: - API Key
    var apiKey: String            = ""
    var showAPIKeySheet: Bool     = false
    var apiKeyInput: String       = ""
    var apiKeySaved: Bool         = false

    // MARK: - UI
    var showSuggestions: Bool     = true
    var suggestions: [PromptSuggestion] = PromptSuggestionLibrary.random(8)
    var selectedSuggestionCategory: SuggestionCategory? = nil
    var showSaveConfirmation: Bool = false
    var copiedHex: String?        = nil
    var showHistorySheet: Bool    = false
    var promptHistory: [PromptHistoryEntry] = []

    // MARK: - Save sheet
    var showColorDetailFor: AIColor? = nil

    // MARK: - Init
    init() {
        if let saved = APIKeyStore.load() { apiKey = saved }
        promptHistory = PromptHistoryStore.load()
    }

    // MARK: - Computed

    var hasAPIKey: Bool { !apiKey.trimmingCharacters(in: .whitespaces).isEmpty }

    var maskedKey: String {
        hasAPIKey ? APIKeyStore.maskedDisplay(apiKey) : "Not set"
    }

    var canGenerate: Bool {
        hasAPIKey && !promptText.trimmingCharacters(in: .whitespaces).isEmpty
            && generationState != .generating
    }

    var filteredSuggestions: [PromptSuggestion] {
        guard let cat = selectedSuggestionCategory else { return suggestions }
        return PromptSuggestionLibrary.all.filter { $0.category == cat }
    }

    var isGenerating: Bool { generationState == .generating }

    var errorMessage: String? {
        if case .error(let msg) = generationState { return msg }
        return nil
    }

    // MARK: - API Key Management

    func saveAPIKey() {
        let trimmed = apiKeyInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        apiKey = trimmed
        APIKeyStore.save(trimmed)
        apiKeySaved = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showAPIKeySheet = false
        }
        // Reset saved flash after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.apiKeySaved = false
        }
    }

    func clearAPIKey() {
        apiKey = ""
        apiKeyInput = ""
        APIKeyStore.clear()
    }

    // MARK: - Generation

    func generate() {
        let prompt = promptText.trimmingCharacters(in: .whitespaces)
        guard !prompt.isEmpty, hasAPIKey else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            generationState   = .generating
            currentPalette    = nil
            revealedColorCount = 0
            showSuggestions   = false
        }

        Task { @MainActor in
            do {
                let palette = try await AIPaletteService.generate(
                    prompt: prompt,
                    style: selectedStyle,
                    colorCount: colorCount,
                    apiKey: apiKey
                )
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    generationState = .success
                    currentPalette  = palette
                }
                staggerReveal(count: palette.colors.count)

                // Persist to history
                let entry = PromptHistoryEntry(
                    prompt: prompt,
                    style: selectedStyle.rawValue,
                    colorCount: colorCount.rawValue,
                    paletteName: palette.name
                )
                PromptHistoryStore.append(entry)
                promptHistory = PromptHistoryStore.load()

            } catch let err as AIPaletteError {
                withAnimation { generationState = .error(err.localizedDescription ?? "Unknown error") }
            } catch {
                withAnimation { generationState = .error(error.localizedDescription) }
            }
        }
    }

    func regenerate() {
        guard currentPalette != nil else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            revealedColorCount = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.generate()
        }
    }

    // MARK: - Staggered color reveal

    private func staggerReveal(count: Int) {
        isAnimatingReveal = true
        revealedColorCount = 0
        for i in 0..<count {
            let delay = Double(i) * 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    self?.revealedColorCount = i + 1
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(count) * 0.12 + 0.4) { [weak self] in
            self?.isAnimatingReveal = false
        }
    }

    // MARK: - Suggestions

    func applySuggestion(_ suggestion: PromptSuggestion) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            promptText = suggestion.text
        }
    }

    func refreshSuggestions() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let cat = selectedSuggestionCategory {
                suggestions = PromptSuggestionLibrary.all.filter { $0.category == cat }.shuffled()
            } else {
                suggestions = PromptSuggestionLibrary.random(8)
            }
        }
    }

    // MARK: - Copy hex

    func copyHex(_ hex: String) {
        UIPasteboard.general.string = hex
        copiedHex = hex
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            if self?.copiedHex == hex { self?.copiedHex = nil }
        }
    }

    // MARK: - Save palette to SwiftData

    func savePalette(context: ModelContext) {
        guard let palette = currentPalette else { return }

        let savedColors = palette.colors.enumerated().map { i, c in
            SavedColor(
                id: c.id,
                hex: c.hex,
                red: c.red, green: c.green, blue: c.blue,
                alpha: 1.0,
                label: c.role
            )
        }

        let saved = SavedPalette(
            name: palette.name,
            colors: savedColors,
            harmonyType: "AI — \(palette.style)",
            createdAt: palette.generatedAt
        )

        context.insert(saved)
        try? context.save()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSaveConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showSaveConfirmation = false }
        }
    }

    // MARK: - History

    func applyHistoryEntry(_ entry: PromptHistoryEntry) {
        promptText    = entry.prompt
        selectedStyle = PaletteStyle(rawValue: entry.style) ?? .any
        colorCount    = ColorCount(rawValue: entry.colorCount) ?? .six
        showHistorySheet = false
    }

    func clearHistory() {
        PromptHistoryStore.clear()
        promptHistory = []
    }

    // MARK: - New prompt
    func newPrompt() {
        withAnimation(.easeInOut(duration: 0.2)) {
            promptText = ""
            generationState = .idle
            currentPalette  = nil
            revealedColorCount = 0
            showSuggestions = true
            suggestions = PromptSuggestionLibrary.random(8)
        }
    }
}
