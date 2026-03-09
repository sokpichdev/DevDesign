//
//  LayoutViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI
import Observation

@Observable
final class LayoutViewModel {

    // MARK: - State
    var config: StackConfig = StackConfig()
    var selectedTab: LayoutInspectorTab = .playground
    var selectedChildID: UUID? = nil
    var showExportSheet: Bool = false
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""
    var patternSearchText: String = ""
    var selectedPatternCategory: LayoutPattern.PatternCategory? = nil

    // MARK: - Computed
    var selectedChild: ChildElement? {
        guard let id = selectedChildID else { return nil }
        return config.children.first(where: { $0.id == id })
    }

    var selectedChildIndex: Int? {
        guard let id = selectedChildID else { return nil }
        return config.children.firstIndex(where: { $0.id == id })
    }

    var canAddChild: Bool { config.children.count < 8 }
    var canRemoveChild: Bool { config.children.count > 1 }

    var filteredPatterns: [LayoutPattern] {
        var base = LayoutPatternLibrary.all
        if let cat = selectedPatternCategory {
            base = base.filter { $0.category == cat }
        }
        let q = patternSearchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return base }
        return base.filter {
            $0.name.lowercased().contains(q) ||
            $0.description.lowercased().contains(q) ||
            $0.category.rawValue.lowercased().contains(q)
        }
    }

    // MARK: - Stack Mutations

    func setStackType(_ type: StackType) {
        var updated = config
        updated.type = type
        // Reset to a sensible default alignment for the new type
        updated.alignment = StackAlignment.options(for: type).first(where: { $0 == .center }) ?? StackAlignment.options(for: type)[0]
        config = updated
    }

    func setAlignment(_ alignment: StackAlignment) {
        var updated = config
        updated.alignment = alignment
        config = updated
    }

    func setSpacing(_ spacing: CGFloat) {
        var updated = config
        updated.spacing = spacing
        config = updated
    }

    // MARK: - Child CRUD

    func addChild(type: ChildElementType) {
        guard canAddChild else { return }
        let index = config.children.count + 1
        var updated = config
        let child = ChildElement(type: type, index: index)
        updated.children.append(child)
        config = updated
        selectedChildID = child.id
    }

    func removeChild(id: UUID) {
        guard canRemoveChild else { return }
        var updated = config
        updated.children.removeAll(where: { $0.id == id })
        config = updated
        if selectedChildID == id {
            selectedChildID = config.children.first?.id
        }
    }

    func moveChild(from source: IndexSet, to destination: Int) {
        var updated = config
        updated.children.move(fromOffsets: source, toOffset: destination)
        config = updated
    }

    func updateChild(id: UUID, transform: (inout ChildElement) -> Void) {
        guard let idx = config.children.firstIndex(where: { $0.id == id }) else { return }
        var updated = config
        transform(&updated.children[idx])
        config = updated
    }

    func duplicateChild(id: UUID) {
        guard canAddChild,
              let original = config.children.first(where: { $0.id == id }),
              let idx = config.children.firstIndex(where: { $0.id == id }) else { return }
        var copy = original
        copy = ChildElement(type: original.type, index: config.children.count + 1)
        var updated = config
        updated.children.insert(copy, at: idx + 1)
        config = updated
        selectedChildID = copy.id
    }

    func resetPlayground() {
        config = StackConfig()
        selectedChildID = nil
    }

    // MARK: - Export

    func exportedCode() -> String {
        LayoutExportService.exportStack(config)
    }

    func copyExport() {
        UIPasteboard.general.string = exportedCode()
        showToast(label: "\(config.type.rawValue) Code")
    }

    func copyPattern(_ pattern: LayoutPattern) {
        UIPasteboard.general.string = pattern.code
        showToast(label: pattern.name)
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
