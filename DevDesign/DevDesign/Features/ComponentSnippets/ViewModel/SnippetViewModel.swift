//
//  SnippetViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class SnippetViewModel {

    // MARK: - State
    var searchText: String = ""
    var selectedCategory: SnippetCategory = .all
    var accentColor: Color = Color(hex: "#7B6EF6")
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""
    var showSaveCustomSheet: Bool = false
    var showCustomOnly: Bool = false

    // MARK: - Curated Filtering

    var filteredCurated: [CuratedSnippet] {
        if selectedCategory == .custom { return [] }

        let base: [CuratedSnippet] = selectedCategory == .all
            ? SnippetLibrary.all
            : SnippetLibrary.all.filter { $0.category == selectedCategory }

        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return base }

        let q = searchText.lowercased()
        return base.filter {
            $0.title.lowercased().contains(q) ||
            $0.subtitle.lowercased().contains(q) ||
            $0.tags.contains(where: { $0.contains(q) })
        }
    }

    var categoryCounts: [SnippetCategory: Int] {
        var counts: [SnippetCategory: Int] = [.all: SnippetLibrary.all.count]
        for cat in SnippetCategory.allCases where cat != .all && cat != .custom {
            counts[cat] = SnippetLibrary.all.filter { $0.category == cat }.count
        }
        return counts
    }

    // MARK: - Accent Color Application

    func resolvedCode(_ template: String) -> String {
        let hex = accentHex()
        return template.replacingOccurrences(of: "{{ACCENT}}", with: hex)
    }

    func accentHex() -> String {
        let ui = UIColor(accentColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }

    // MARK: - Copy

    func copyCurated(_ snippet: CuratedSnippet) {
        UIPasteboard.general.string = resolvedCode(snippet.code)
        showToast(label: snippet.title)
    }

    func copyCustom(_ snippet: CustomSnippet) {
        UIPasteboard.general.string = snippet.code
        showToast(label: snippet.title)
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

    // MARK: - Custom Snippet CRUD (via SwiftData context passed in)

    func saveCustom(title: String, subtitle: String, code: String,
                    tags: String, context: ModelContext) {
        let snippet = CustomSnippet(title: title, subtitle: subtitle,
                                    code: code, tags: tags)
        context.insert(snippet)
        try? context.save()
    }

    func deleteCustom(_ snippet: CustomSnippet, context: ModelContext) {
        context.delete(snippet)
        try? context.save()
    }
}
