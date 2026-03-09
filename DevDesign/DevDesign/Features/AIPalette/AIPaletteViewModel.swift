//
//  AIPaletteViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//  Updated for multi-provider support
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class AIPaletteViewModel {

    // MARK: - Provider State
    var selectedProvider: AIProvider = ProviderKeyStore.loadSelectedProvider()
    
    // MARK: - API Keys (per provider)
    var anthropicKey: String = ProviderKeyStore.loadKey(for: .anthropic) ?? ""
    var geminiKey: String = ProviderKeyStore.loadKey(for: .gemini) ?? ""
    var openrouterKey: String = ProviderKeyStore.loadKey(for: .openrouter) ?? ""

    // MARK: - Input state for sheets
    var apiKeyInput: String = ""
    var providerBeingConfigured: AIProvider?

    // MARK: - Prompt state
    var promptText: String = ""
    var selectedStyle: PaletteStyle = .any
    var colorCount: ColorCount = .six

    // MARK: - Generation state
    var generationState: GenerationState = .idle
    var currentPalette: AIGeneratedPalette? = nil
    var revealedColorCount: Int = 0
    var isAnimatingReveal: Bool = false

    // MARK: - UI
    var showAPIKeySheet: Bool = false
    var showProviderPicker: Bool = false
    var apiKeySaved: Bool = false
    var showSuggestions: Bool = true
    var suggestions: [PromptSuggestion] = PromptSuggestionLibrary.random(8)
    var selectedSuggestionCategory: SuggestionCategory? = nil
    var showSaveConfirmation: Bool = false
    var copiedHex: String? = nil
    var showHistorySheet: Bool = false
    var promptHistory: [PromptHistoryEntry] = []

    // MARK: - Save sheet
    var showColorDetailFor: AIColor? = nil

    // MARK: - Init
    init() {
        // Migrate old keys if needed
        APIKeyStore.migrateToProviderStore()
        
        // Load current keys
        anthropicKey = ProviderKeyStore.loadKey(for: .anthropic) ?? ""
        geminiKey = ProviderKeyStore.loadKey(for: .gemini) ?? ""
        promptHistory = PromptHistoryStore.load()
    }

    // MARK: - Computed
    
    var currentAPIKey: String {
        switch selectedProvider {
        case .anthropic: return anthropicKey
        case .gemini: return geminiKey
        case .openrouter: return openrouterKey // Optional for OpenRouter!
        }
    }
    
    var hasAPIKey: Bool {
        if !selectedProvider.requiresKey {
            return true // OpenRouter free tier doesn't need key
        }
        return !currentAPIKey.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var maskedKey: String {
        hasAPIKey ? ProviderKeyStore.maskedDisplay(currentAPIKey, for: selectedProvider) : "Not set"
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
    
    // MARK: - Provider Management
    
    func switchProvider(to provider: AIProvider) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedProvider = provider
            ProviderKeyStore.saveSelectedProvider(provider)
        }
    }

    // MARK: - API Key Management

    func showKeyConfiguration(for provider: AIProvider) {
        providerBeingConfigured = provider
        apiKeyInput = "" // Clear input for security
        showAPIKeySheet = true
    }
    
    func saveAPIKey() {
        guard let provider = providerBeingConfigured else { return }
        let trimmed = apiKeyInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        switch provider {
        case .anthropic:
            anthropicKey = trimmed
        case .gemini:
            geminiKey = trimmed
        case .openrouter:
            openrouterKey = trimmed
        }
        
        ProviderKeyStore.saveKey(trimmed, for: provider)
        apiKeySaved = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showAPIKeySheet = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.apiKeySaved = false
        }
    }

    func clearAPIKey(for provider: AIProvider? = nil) {
        let target = provider ?? selectedProvider
        ProviderKeyStore.clearKey(for: target)
        
        switch target {
        case .anthropic:
            anthropicKey = ""
        case .gemini:
            geminiKey = ""
        case .openrouter:
            openrouterKey = ""
        }
        
        if providerBeingConfigured == target {
            apiKeyInput = ""
        }
    }
    
    func clearCurrentAPIKey() {
        clearAPIKey(for: selectedProvider)
    }

    // MARK: - Generation

    func generate() {
        let prompt = promptText.trimmingCharacters(in: .whitespaces)
        guard !prompt.isEmpty, hasAPIKey else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            generationState = .generating
            currentPalette = nil
            revealedColorCount = 0
            showSuggestions = false
        }

        Task { @MainActor in
            do {
                let palette = try await AIPaletteService.generate(
                    prompt: prompt,
                    style: selectedStyle,
                    colorCount: colorCount,
                    provider: selectedProvider,
                    apiKey: currentAPIKey
                )
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    generationState = .success
                    currentPalette = palette
                }
                staggerReveal(count: palette.colors.count)

                // Persist to history
                let entry = PromptHistoryEntry(
                    prompt: prompt,
                    style: selectedStyle.rawValue,
                    colorCount: colorCount.rawValue,
                    paletteName: palette.name,
                    colors: palette.colors
                )
                PromptHistoryStore.append(entry)
                promptHistory = PromptHistoryStore.load()

            } catch let err as AIPaletteError {
                withAnimation { generationState = .error(err.localizedDescription) }
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
        promptText = entry.prompt
        selectedStyle = PaletteStyle(rawValue: entry.style) ?? .any
        colorCount = ColorCount(rawValue: entry.colorCount) ?? .six
        showHistorySheet = false
    }

    func saveHistoryPalette(entry: PromptHistoryEntry, context: ModelContext) {
        let savedColors = entry.colors.map { c in
            SavedColor(
                id: c.id,
                hex: c.hex,
                red: c.red, green: c.green, blue: c.blue,
                alpha: 1.0,
                label: c.role
            )
        }
        let saved = SavedPalette(
            name: entry.paletteName,
            colors: savedColors,
            harmonyType: "AI — \(entry.style)",
            createdAt: entry.savedAt
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

    func clearHistory() {
        PromptHistoryStore.clear()
        promptHistory = []
    }

    // MARK: - New prompt
    func newPrompt() {
        withAnimation(.easeInOut(duration: 0.2)) {
            promptText = ""
            generationState = .idle
            currentPalette = nil
            revealedColorCount = 0
            showSuggestions = true
            suggestions = PromptSuggestionLibrary.random(8)
        }
    }
}
