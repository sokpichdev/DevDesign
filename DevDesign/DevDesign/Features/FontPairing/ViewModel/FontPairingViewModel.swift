//
//  FontPairingViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import Observation

@Observable
final class FontPairingViewModel {

    // MARK: - State
    var pairs: [FontPair] = FontPairingLibrary.pairs
    var selectedCategory: PairingCategory = .all
    var searchText: String = ""
    var selectedPair: FontPair? = nil
    var loadingFamilies: Set<String> = []
    var failedFamilies: Set<String> = []

    // MARK: - Filtering

    var filteredPairs: [FontPair] {
        pairs.filter { pair in
            let categoryMatch = selectedCategory == .all || pair.category == selectedCategory
            let searchMatch: Bool = {
                guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return true }
                let q = searchText.lowercased()
                return pair.name.lowercased().contains(q)
                    || pair.displayFont.displayName.lowercased().contains(q)
                    || pair.bodyFont.displayName.lowercased().contains(q)
                    || pair.tags.contains(where: { $0.contains(q) })
                    || pair.description.lowercased().contains(q)
            }()
            return categoryMatch && searchMatch
        }
    }

    var categoryCount: [PairingCategory: Int] {
        Dictionary(uniqueKeysWithValues: PairingCategory.allCases.map { cat in
            let count = cat == .all
                ? pairs.count
                : pairs.filter { $0.category == cat }.count
            return (cat, count)
        })
    }

    // MARK: - Font Loading

    /// Load both fonts in a pair. Safe to call multiple times — cached after first load.
    func loadFonts(for pair: FontPair) {
        loadFont(spec: pair.displayFont, inPair: pair.id)
        if pair.bodyFont.source != pair.displayFont.source {
            loadFont(spec: pair.bodyFont, inPair: pair.id)
        }
    }

    private func loadFont(spec: FontSpec, inPair pairID: UUID) {
        guard case .google(let family) = spec.source else { return }
        guard !loadingFamilies.contains(family),
              !failedFamilies.contains(family) else { return }

        // Already loaded
        if spec.loadedFamilyName != nil { return }

        loadingFamilies.insert(family)

        Task { @MainActor in
            do {
                let psName = try await GoogleFontsLoader.shared.load(family: family)
                updateFont(family: family, psName: psName)
                loadingFamilies.remove(family)
            } catch {
                failedFamilies.insert(family)
                loadingFamilies.remove(family)
            }
        }
    }

    /// Update all FontSpec instances across all pairs that match the loaded family
    @MainActor
    private func updateFont(family: String, psName: String) {
        var updated = pairs
        for i in updated.indices {
            if case .google(let f) = updated[i].displayFont.source, f == family {
                updated[i].displayFont.loadedFamilyName = psName
            }
            if case .google(let f) = updated[i].bodyFont.source, f == family {
                updated[i].bodyFont.loadedFamilyName = psName
            }
        }
        pairs = updated
    }

    func isLoading(family: String) -> Bool { loadingFamilies.contains(family) }
    func isFailed(family: String) -> Bool  { failedFamilies.contains(family) }

    func loadingState(for pair: FontPair) -> PairLoadState {
        if pair.isFullyLoaded { return .loaded }
        let families = googleFamilies(pair)
        if families.allSatisfy({ failedFamilies.contains($0) }) { return .failed }
        if families.contains(where: { loadingFamilies.contains($0) }) { return .loading }
        return .idle
    }

    private func googleFamilies(_ pair: FontPair) -> [String] {
        [pair.displayFont, pair.bodyFont].compactMap {
            if case .google(let f) = $0.source { return f }
            return nil
        }
    }

    enum PairLoadState {
        case idle, loading, loaded, failed
    }
}
