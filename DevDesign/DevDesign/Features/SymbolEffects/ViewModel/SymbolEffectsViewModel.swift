//
//  SymbolEffectsViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  State + behaviour for the Symbol Effects (native .symbolEffect) tool.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class SymbolEffectsViewModel {

    // MARK: - State
    var config: SymbolEffectsConfig = .default
    var showExportSheet: Bool = false
    var selectedExportFormat: SymbolEffectExportFormat = .swiftUI
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""

    // MARK: - Selection

    func selectKind(_ kind: SymbolEffectKind) {
        config.kind = kind
    }

    func resetToDefault() {
        let symbol = config.symbolName
        config = .default
        config.symbolName = symbol
    }

    func togglePlaying() { config.isPlaying.toggle() }
    func toggleBackground() { config.backgroundIsDark.toggle() }

    // MARK: - Export

    func exportString(for format: SymbolEffectExportFormat) -> String {
        SymbolEffectsExportService.export(config, as: format)
    }

    func copyExport(for format: SymbolEffectExportFormat) {
        UIPasteboard.general.string = exportString(for: format)
        copiedLabel = format.rawValue
        showToast()
    }

    func copyCurrentFormat() {
        copyExport(for: selectedExportFormat)
    }

    // MARK: - Toast (matches ShadowViewModel)

    private func showToast() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }
}
