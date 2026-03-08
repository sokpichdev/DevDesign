//
//  TypeScaleViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//


// TypeScaleViewModel.swift
// DevDesign — Features/TypeScale/TypeScaleViewModel.swift

import SwiftUI
import Observation

@Observable
final class TypeScaleViewModel {

    // MARK: - State
    var baseSize: Double = 16          // Body anchor size
    var selectedRatio: ScaleRatio = .minorThird
    var steps: [TypeScaleStep] = []
    var editingStep: TypeScaleStep? = nil   // for inline rename
    var showExportSheet: Bool = false
    var selectedExportFormat: TypeScaleExportFormat = .swiftUI
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""

    // MARK: - Init
    init() { regenerate() }

    // MARK: - Computed
    var ratioDescription: String { selectedRatio.description }

    // MARK: - Actions

    /// Recalculate all steps from current baseSize + ratio.
    /// Mutates via a local copy then assigns whole array — required for
    /// @Observable to detect changes to struct elements reliably.
    func regenerate() {
        let newSteps = TypeScaleEngine.generate(baseSize: baseSize, ratio: selectedRatio)

        guard !steps.isEmpty else {
            steps = newSteps
            return
        }

        // Count mismatch — full replace
        guard newSteps.count == steps.count else {
            steps = newSteps
            return
        }

        // Preserve custom names and weights — only update sizes
        var updated = steps
        for (i, newStep) in newSteps.enumerated() {
            updated[i].size       = newStep.size
            updated[i].lineHeight = newStep.lineHeight
            updated[i].tracking   = newStep.tracking
        }
        steps = updated   // single assignment fires @Observable
    }

    func updateBaseSize(_ size: Double) {
        baseSize = size
        regenerate()
    }

    func selectRatio(_ ratio: ScaleRatio) {
        selectedRatio = ratio
        regenerate()
    }

    /// Reset names back to defaults.
    func resetNames() {
        var updated = steps
        for (i, meta) in TypeScaleStep.defaultNames.enumerated() where i < updated.count {
            updated[i].name      = meta.name
            updated[i].tokenName = meta.token
            updated[i].weight    = meta.weight
        }
        steps = updated   // single assignment fires @Observable
    }

    /// Update weight for one step.
    func updateWeight(_ weight: FontWeightOption, at index: Int) {
        guard index < steps.count else { return }
        var updated = steps
        updated[index].weight = weight
        steps = updated   // single assignment fires @Observable
    }

    // MARK: - Export

    func exportString(for format: TypeScaleExportFormat) -> String {
        switch format {
        case .swiftUI:  return TypeScaleExportService.exportSwiftUI(steps)
        case .swiftEnum: return TypeScaleExportService.exportSwiftEnum(steps)
        case .css:      return TypeScaleExportService.exportCSS(steps)
        case .json:     return TypeScaleExportService.exportJSON(steps)
        }
    }

    func copyExport(for format: TypeScaleExportFormat) {
        UIPasteboard.general.string = exportString(for: format)
        copiedLabel = format.rawValue
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }
}

// MARK: - Export Format
enum TypeScaleExportFormat: String, CaseIterable, Identifiable {
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
