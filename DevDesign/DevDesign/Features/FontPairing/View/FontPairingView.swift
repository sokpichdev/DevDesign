//
//  FontPairingView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI

struct FontPairingView: View {

    @State private var viewModel = FontPairingViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: DSSpacing.sm),
        GridItem(.flexible(), spacing: DSSpacing.sm)
    ]

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                // Search bar
                searchBar
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.vertical, DSSpacing.sm)

                // Category filter strip
                categoryStrip

                Divider().background(DSColors.Preview.borderSubtle)

                // Results header
                resultsHeader
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.top, DSSpacing.sm)

                // Grid
                if viewModel.filteredPairs.isEmpty {
                    emptyState
                } else {
                    pairingGrid
                }
            }
        }
        .navigationTitle("Font Pairings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Pre-load all system fonts instantly + trigger loading for visible pairs
            for pair in viewModel.filteredPairs.prefix(4) {
                viewModel.loadFonts(for: pair)
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(DSColors.Preview.textTertiary)

            TextField("Search fonts or tags…", text: $viewModel.searchText)
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button { viewModel.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Category Strip
    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                ForEach(PairingCategory.allCases) { category in
                    categoryPill(category)
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.vertical, DSSpacing.sm)
        }
    }

    private func categoryPill(_ category: PairingCategory) -> some View {
        let isSelected = viewModel.selectedCategory == category
        let count = viewModel.categoryCount[category] ?? 0

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.selectedCategory = category
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(category.rawValue)
                    .font(DSTypography.labelLarge)
                if category != .all {
                    Text("\(count)")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(isSelected ? .white.opacity(0.7) : DSColors.Preview.textTertiary)
                }
            }
            .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(
                isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceDefault,
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.clear : DSColors.Preview.borderSubtle,
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }

    // MARK: - Results Header
    private var resultsHeader: some View {
        HStack {
            Text("\(viewModel.filteredPairs.count) pairings")
                .font(DSTypography.labelMedium)
                .foregroundStyle(DSColors.Preview.textTertiary)
            Spacer()
        }
    }

    // MARK: - Pairing Grid
    private var pairingGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                ForEach(viewModel.filteredPairs) { pair in
                    NavigationLink(destination:
                        FontPairingDetailView(pair: pair, viewModel: viewModel)
                    ) {
                        FontPairingCard(
                            pair: pair,
                            loadState: viewModel.loadingState(for: pair),
                            onTap: {}
                        )
                    }
                    .buttonStyle(.plain)
                    .onAppear { viewModel.loadFonts(for: pair) }
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.vertical, DSSpacing.sm)
            .animation(.spring(response: 0.35, dampingFraction: 0.8),
                       value: viewModel.filteredPairs.map(\.id))
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Spacer()
            Image(systemName: "textformat")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(DSColors.Preview.textTertiary)
            VStack(spacing: DSSpacing.xs) {
                Text("No Pairings Found")
                    .font(DSTypography.displaySmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text("Try a different search or category.")
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)
            }
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        FontPairingView()
    }
}
