//
//  MetalSymbolsViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  State + behaviour for the Metal Symbols tool.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class MetalSymbolsViewModel {

    // MARK: - State
    var config: MetalSymbolConfig = .default
    var showExportSheet: Bool = false
    var selectedExportFormat: MetalSymbolExportFormat = .swiftUI
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""

    // MARK: - Effect selection

    /// Switching effects loads that effect's tuned defaults while keeping the
    /// current symbol, background, and play/pause state.
    func selectEffect(_ effect: MetalSymbolEffect) {
        guard effect != config.effect else { return }
        let wasPlaying = config.isPlaying
        config = .make(for: effect,
                       symbolName: config.symbolName,
                       backgroundIsDark: config.backgroundIsDark)
        config.isPlaying = wasPlaying
    }

    func resetToDefault() {
        let symbol = config.symbolName
        config = .make(for: config.effect,
                       symbolName: symbol,
                       backgroundIsDark: config.backgroundIsDark)
    }

    func togglePlaying() { config.isPlaying.toggle() }
    func toggleBackground() { config.backgroundIsDark.toggle() }

    // MARK: - Export

    func exportString(for format: MetalSymbolExportFormat) -> String {
        MetalSymbolExportService.export(config, as: format)
    }

    func copyExport(for format: MetalSymbolExportFormat) {
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
