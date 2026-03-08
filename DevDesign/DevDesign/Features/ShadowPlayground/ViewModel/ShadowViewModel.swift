//
//  ShadowViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import Observation

@Observable
final class ShadowViewModel {

    // MARK: - State
    var layers: [ShadowLayer] = [.medium()]
    var previewTarget: ShadowPreviewTarget = .card
    var isDarkBackground: Bool = true
    var selectedPreset: ShadowPreset = .medium
    var selectedLayerID: UUID? = nil
    var showExportSheet: Bool = false
    var selectedExportFormat: ShadowExportFormat = .swiftUI
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""

    // MARK: - Computed
    var selectedLayerIndex: Int? {
        guard let id = selectedLayerID else { return nil }
        return layers.firstIndex(where: { $0.id == id })
    }

    var enabledLayers: [ShadowLayer] { layers.filter(\.isEnabled) }
    var hasInnerLayer: Bool { layers.contains(where: { $0.isInner && $0.isEnabled }) }

    // MARK: - Layer Management

    func addLayer() {
        guard layers.count < 4 else { return }
        let new = ShadowLayer.soft()
        var updated = layers
        updated.append(new)
        layers = updated
        selectedLayerID = new.id
    }

    func removeLayer(at index: Int) {
        guard layers.count > 1, index < layers.count else { return }
        var updated = layers
        let removedID = updated[index].id
        updated.remove(at: index)
        layers = updated
        if selectedLayerID == removedID {
            selectedLayerID = layers.first?.id
        }
    }

    func moveLayer(from source: IndexSet, to destination: Int) {
        var updated = layers
        updated.move(fromOffsets: source, toOffset: destination)
        layers = updated
    }

    func duplicateLayer(at index: Int) {
        guard layers.count < 4, index < layers.count else { return }
        var copy = layers[index]
        copy = ShadowLayer(
            id: UUID(),
            isEnabled: copy.isEnabled,
            isInner: copy.isInner,
            color: copy.color,
            opacity: copy.opacity,
            x: copy.x + 2,
            y: copy.y + 2,
            blur: copy.blur,
            spread: copy.spread
        )
        var updated = layers
        updated.insert(copy, at: index + 1)
        layers = updated
        selectedLayerID = copy.id
    }

    // MARK: - Layer Mutation (local-copy pattern for @Observable)

    func updateLayer(at index: Int, transform: (inout ShadowLayer) -> Void) {
        guard index < layers.count else { return }
        var updated = layers
        transform(&updated[index])
        layers = updated
        selectedPreset = .custom
    }

    func toggleEnabled(at index: Int) {
        updateLayer(at: index) { $0.isEnabled.toggle() }
    }

    func toggleInner(at index: Int) {
        updateLayer(at: index) { $0.isInner.toggle() }
    }

    // MARK: - Presets

    func applyPreset(_ preset: ShadowPreset) {
        selectedPreset = preset
        if preset != .custom {
            layers = preset.layers(accentColor: DSColors.Preview.accent)
            selectedLayerID = layers.first?.id
        }
    }

    func resetToDefault() {
        layers = [.medium()]
        selectedLayerID = layers.first?.id
        selectedPreset = .medium
    }

    // MARK: - Export

    func exportString(for format: ShadowExportFormat) -> String {
        switch format {
        case .swiftUI:   return ShadowExportService.exportSwiftUI(layers)
        case .css:       return ShadowExportService.exportCSS(layers)
        case .cssText:   return ShadowExportService.exportCSSText(layers)
        case .uiKit:     return ShadowExportService.exportUIKit(layers)
        }
    }

    func copyExport(for format: ShadowExportFormat) {
        UIPasteboard.general.string = exportString(for: format)
        copiedLabel = format.rawValue
        showToast()
    }

    func copyCurrentFormat() {
        copyExport(for: selectedExportFormat)
    }

    private func showToast() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }
}

// MARK: - Export Format

enum ShadowExportFormat: String, CaseIterable, Identifiable {
    case swiftUI = "SwiftUI"
    case css     = "CSS"
    case cssText = "Text Shadow"
    case uiKit   = "UIKit"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .swiftUI: return "swift"
        case .css:     return "globe"
        case .cssText: return "textformat"
        case .uiKit:   return "iphone"
        }
    }
}
