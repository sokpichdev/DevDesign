//
//  AnimationViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI
import Observation

@Observable
final class AnimationViewModel {

    // MARK: - State
    var config: AnimationConfig = AnimationConfig()
    var selectedTarget: AnimationPreviewTarget = .slide
    var isAnimating: Bool = false
    var selectedCategory: AnimationCategory = .spring
    var showExportSheet: Bool = false
    var selectedExportTab: AnimExportTab = .modifier
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""
    var selectedPreset: AnimationPreset? = nil
    var isLooping: Bool = false

    // MARK: - Derived
    var curvePoints: [CurvePoint] {
        AnimationExportService.curvePoints(config)
    }

    var filteredTypes: [AnimationType] {
        AnimationType.allCases.filter { $0.category == selectedCategory }
    }

    // MARK: - Type + Category Selection

    func selectCategory(_ cat: AnimationCategory) {
        selectedCategory = cat
        // Pick first type in that category
        if let first = filteredTypes.first(where: { _ in true }) {
            selectType(first)
        }
    }

    func selectType(_ type: AnimationType) {
        var updated = config
        updated.type = type
        config = updated
        selectedPreset = nil
    }

    // MARK: - Trigger

    func trigger() {
        withAnimation(config.swiftUIAnimation) {
            isAnimating.toggle()
        }
    }

    func replay() {
        // snap back instantly, then animate forward
        withAnimation(.none) { isAnimating = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self else { return }
            withAnimation(self.config.swiftUIAnimation) {
                self.isAnimating = true
            }
        }
    }

    func startLoop() {
        isLooping = true
        loopStep()
    }

    func stopLoop() {
        isLooping = false
        withAnimation(.easeOut(duration: 0.2)) { isAnimating = false }
    }

    private func loopStep() {
        guard isLooping else { return }
        withAnimation(config.swiftUIAnimation) { isAnimating = true }
        let delay = (config.type.category == .spring
            ? config.response * 4
            : config.duration * 2.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.3) { [weak self] in
            guard let self, self.isLooping else { return }
            withAnimation(.easeOut(duration: 0.25)) { self.isAnimating = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.loopStep()
            }
        }
    }

    // MARK: - Presets

    func applyPreset(_ preset: AnimationPreset) {
        withAnimation(.easeInOut(duration: 0.2)) {
            config = preset.config
        }
        selectedPreset = preset
        selectedCategory = preset.config.type.category
        replay()
    }

    // MARK: - Export

    func exportString(for tab: AnimExportTab) -> String {
        switch tab {
        case .modifier:     return AnimationExportService.exportModifier(config)
        case .withAnim:     return AnimationExportService.exportWithAnimation(config)
        case .transition:   return AnimationExportService.exportTransition(config, target: selectedTarget)
        }
    }

    func copyExport(for tab: AnimExportTab) {
        UIPasteboard.general.string = exportString(for: tab)
        showToast(label: tab.rawValue)
    }

    private func showToast(label: String) {
        copiedLabel = label
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }
}

// MARK: - Export Tab

enum AnimExportTab: String, CaseIterable, Identifiable {
    case modifier   = ".animation()"
    case withAnim   = "withAnimation()"
    case transition = ".transition()"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .modifier:   return "wand.and.sparkles"
        case .withAnim:   return "play.fill"
        case .transition: return "arrow.left.and.right.square"
        }
    }
}
