//
//  SFSymbolsViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import Observation

@Observable
final class SFSymbolsViewModel {

    // MARK: - State
    var searchText: String = ""
    var selectedCategory: SymbolCategory = .all
    var selectedSymbol: SFSymbol? = nil
    var previewSize: CGFloat = 24
    var previewWeight: SymbolWeight = .regular
    var favouriteNames: Set<String> = []
    var showFavouritesOnly: Bool = false
    var copiedCode: String? = nil        // briefly set when a copy action fires
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""

    // MARK: - Computed: Filtered Symbols

    var filteredSymbols: [SFSymbol] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()

        var results: [SFSymbol]

        // If the search looks like an exact system name, try to validate it first
        if !query.isEmpty, UIImage(systemName: searchText) != nil,
           !SFSymbolCatalog.symbols.contains(where: { $0.name == searchText }) {
            // User typed an exact valid symbol name not in our catalog — surface it
            let dynamic = SFSymbol(
                id: UUID(),
                name: searchText,
                category: .all,
                keywords: []
            )
            results = [dynamic] + catalogResults(query: query)
        } else {
            results = catalogResults(query: query)
        }

        if showFavouritesOnly {
            results = results.filter { favouriteNames.contains($0.name) }
        }

        return results
    }

    private func catalogResults(query: String) -> [SFSymbol] {
        let base = selectedCategory == .all
            ? SFSymbolCatalog.symbols
            : SFSymbolCatalog.symbols.filter { $0.category == selectedCategory }

        guard !query.isEmpty else { return base }

        return base.filter { symbol in
            symbol.name.contains(query) ||
            symbol.keywords.contains(where: { $0.contains(query) })
        }
    }

    var resultCount: Int { filteredSymbols.count }

    var categoryCount: [SymbolCategory: Int] {
        Dictionary(uniqueKeysWithValues: SymbolCategory.allCases.map { cat in
            let count = cat == .all
                ? SFSymbolCatalog.symbols.count
                : SFSymbolCatalog.symbols.filter { $0.category == cat }.count
            return (cat, count)
        })
    }

    // MARK: - Favourites

    func toggleFavourite(_ symbol: SFSymbol) {
        if favouriteNames.contains(symbol.name) {
            favouriteNames.remove(symbol.name)
        } else {
            favouriteNames.insert(symbol.name)
        }
    }

    func isFavourite(_ symbol: SFSymbol) -> Bool {
        favouriteNames.contains(symbol.name)
    }

    // MARK: - Copy Actions

    func copySymbolName(_ symbol: SFSymbol) {
        copy(symbol.name, label: "Name")
    }

    func copySwiftUI(_ symbol: SFSymbol) {
        copy(SFSymbolExportService.exportSwiftUI(symbol, size: previewSize, weight: previewWeight),
             label: "SwiftUI")
    }

    func copyUIKit(_ symbol: SFSymbol) {
        copy(SFSymbolExportService.exportUIKit(symbol, size: previewSize, weight: previewWeight),
             label: "UIKit")
    }

    func copyResizable(_ symbol: SFSymbol) {
        copy(SFSymbolExportService.exportSwiftUIResizable(symbol, weight: previewWeight),
             label: "Resizable")
    }

    func copyButton(_ symbol: SFSymbol) {
        copy(SFSymbolExportService.exportSwiftUIButton(symbol), label: "Button")
    }

    private func copy(_ string: String, label: String) {
        UIPasteboard.general.string = string
        copiedLabel = label
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }
}
