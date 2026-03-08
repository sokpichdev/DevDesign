//
//  SpacingSystemViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import Observation

@Observable
final class SpacingSystemViewModel {

    // MARK: - State
    var base: BaseGrid = .four
    var tokens: [SpacingToken] = []
    var showExportSheet: Bool = false
    var selectedExportFormat: SpacingExportFormat = .swiftUI
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""
    var editingIndex: Int? = nil        // which token is being custom-edited

    // MARK: - Init
    init() { regenerate() }

    // MARK: - Computed
    var totalRange: String {
        guard let first = tokens.first, let last = tokens.last else { return "—" }
        return "\(SpacingExportService.formatValue(first.resolvedValue))–\(SpacingExportService.formatValue(last.resolvedValue))pt"
    }

    var overrideCount: Int { tokens.filter(\.isOverridden).count }

    // MARK: - Actions

    func selectBase(_ grid: BaseGrid) {
        base = grid
        // Recompute values but preserve any custom overrides
        var updated = SpacingEngine.recompute(tokens: tokens, base: grid)
        // Keep override flags intact — recompute only touches .value not .customValue
        tokens = updated
    }

    func regenerate() {
        let newTokens = SpacingEngine.generate(base: base)
        if tokens.isEmpty {
            tokens = newTokens
        } else {
            // Preserve custom names and overrides
            var updated = tokens
            for i in updated.indices where i < newTokens.count {
                updated[i].value = newTokens[i].value
                // name / tokenName / description preserved
            }
            tokens = updated
        }
    }

    func resetAll() {
        tokens = SpacingEngine.generate(base: base)
        editingIndex = nil
    }

    /// Set a manual override for a token value
    func setOverride(_ value: Double, at index: Int) {
        guard index < tokens.count, value > 0 else { return }
        var updated = tokens
        updated[index].customValue = value
        tokens = updated
    }

    /// Clear override for one token
    func clearOverride(at index: Int) {
        guard index < tokens.count else { return }
        var updated = tokens
        updated[index].resetOverride()
        tokens = updated
    }

    /// Clear all overrides
    func clearAllOverrides() {
        var updated = tokens
        for i in updated.indices { updated[i].resetOverride() }
        tokens = updated
    }

    // MARK: - Export

    func exportString(for format: SpacingExportFormat) -> String {
        switch format {
        case .swiftUI:    return SpacingExportService.exportSwiftUI(tokens, base: base)
        case .swiftEnum:  return SpacingExportService.exportSwiftEnum(tokens, base: base)
        case .css:        return SpacingExportService.exportCSS(tokens, base: base)
        case .json:       return SpacingExportService.exportJSON(tokens, base: base)
        }
    }

    func copyExport(for format: SpacingExportFormat) {
        UIPasteboard.general.string = exportString(for: format)
        copiedLabel = format.rawValue
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }

    func copyValue(_ token: SpacingToken) {
        UIPasteboard.general.string = SpacingExportService.formatValue(token.resolvedValue)
        copiedLabel = "\(token.name) (\(SpacingExportService.formatValue(token.resolvedValue))pt)"
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }
}

// MARK: - Export Format
enum SpacingExportFormat: String, CaseIterable, Identifiable {
    case swiftUI   = "SwiftUI"
    case swiftEnum = "Swift Enum"
    case css       = "CSS"
    case json      = "JSON"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .swiftUI:   return "swift"
        case .swiftEnum: return "chevron.left.forwardslash.chevron.right"
        case .css:       return "globe"
        case .json:      return "curlybraces"
        }
    }
}
