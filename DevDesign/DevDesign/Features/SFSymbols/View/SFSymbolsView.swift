//
//  SFSymbolsView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI

struct SFSymbolsView: View {

    @State private var viewModel = SFSymbolsViewModel()

    // Adaptive grid — fills width with 72pt cells
    private let columns = Array(
        repeating: GridItem(.adaptive(minimum: 72, maximum: 88), spacing: DSSpacing.xs),
        count: 1
    )

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                // Search + filter toggle bar
                searchBar
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.vertical, DSSpacing.sm)

                // Category strip
                categoryStrip

                Divider().background(DSColors.Preview.borderSubtle)

                // Results count + favourites toggle
                resultsBar
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.top, DSSpacing.xs)
                    .padding(.bottom, DSSpacing.xs)

                // Symbol grid
                if viewModel.filteredSymbols.isEmpty {
                    emptyState
                } else {
                    symbolGrid
                }
            }
        }
        .navigationTitle("SF Symbols")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(DSColors.Preview.textTertiary)

            TextField("Search symbols or keywords…", text: $viewModel.searchText)
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .autocorrectionDisabled()
                .autocapitalization(.none)

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
                ForEach(SymbolCategory.allCases) { category in
                    categoryPill(category)
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.vertical, DSSpacing.sm)
        }
    }

    private func categoryPill(_ category: SymbolCategory) -> some View {
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

    // MARK: - Results Bar
    private var resultsBar: some View {
        HStack {
            Text("\(viewModel.resultCount) symbols")
                .font(DSTypography.labelMedium)
                .foregroundStyle(DSColors.Preview.textTertiary)

            Spacer()

            // Favourites filter toggle
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    viewModel.showFavouritesOnly.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.showFavouritesOnly ? "heart.fill" : "heart")
                        .font(.system(size: 12, weight: .semibold))
                    Text(viewModel.showFavouritesOnly ? "Favourites" : "All")
                        .font(DSTypography.labelLarge)
                }
                .foregroundStyle(
                    viewModel.showFavouritesOnly
                        ? DSColors.Preview.error
                        : DSColors.Preview.textTertiary
                )
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xxs)
                .background(
                    viewModel.showFavouritesOnly
                        ? DSColors.Preview.error.opacity(0.12)
                        : DSColors.Preview.surfaceDefault,
                    in: Capsule()
                )
                .overlay(
                    Capsule().strokeBorder(
                        viewModel.showFavouritesOnly
                            ? DSColors.Preview.error.opacity(0.3)
                            : DSColors.Preview.borderSubtle,
                        lineWidth: 1
                    )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Symbol Grid
    private var symbolGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 72, maximum: 88), spacing: DSSpacing.xs)],
                spacing: DSSpacing.xs
            ) {
                ForEach(viewModel.filteredSymbols) { symbol in
                    NavigationLink(destination:
                        SFSymbolDetailView(symbol: symbol, viewModel: viewModel)
                    ) {
                        symbolCell(symbol)
                    }
                    .buttonStyle(.plain)
                    .contextMenu { symbolContextMenu(symbol) }
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.vertical, DSSpacing.sm)
            .animation(.spring(response: 0.3, dampingFraction: 0.8),
                       value: viewModel.filteredSymbols.map(\.id))
        }
    }

    private func symbolCell(_ symbol: SFSymbol) -> some View {
        let isFav = viewModel.isFavourite(symbol)

        return VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: symbol.name)
                    .font(.system(size: viewModel.previewSize * 0.6,
                                  weight: viewModel.previewWeight.fontWeight))
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .frame(width: 40, height: 40)

                if isFav {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(DSColors.Preview.error)
                        .offset(x: 2, y: -2)
                }
            }

            Text(symbol.name.components(separatedBy: ".").first ?? symbol.name)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
        }
        .frame(width: 72, height: 72)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Context Menu
    @ViewBuilder
    private func symbolContextMenu(_ symbol: SFSymbol) -> some View {
        Button {
            viewModel.copySymbolName(symbol)
        } label: {
            Label("Copy Name", systemImage: "textformat")
        }

        Button {
            viewModel.copySwiftUI(symbol)
        } label: {
            Label("Copy SwiftUI", systemImage: "swift")
        }

        Button {
            viewModel.copyUIKit(symbol)
        } label: {
            Label("Copy UIKit", systemImage: "chevron.left.forwardslash.chevron.right")
        }

        Divider()

        Button {
            viewModel.toggleFavourite(symbol)
        } label: {
            Label(
                viewModel.isFavourite(symbol) ? "Remove from Favourites" : "Add to Favourites",
                systemImage: viewModel.isFavourite(symbol) ? "heart.slash" : "heart"
            )
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(DSColors.Preview.textTertiary)
            VStack(spacing: DSSpacing.xs) {
                Text(viewModel.showFavouritesOnly ? "No Favourites" : "No Symbols Found")
                    .font(DSTypography.displaySmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text(viewModel.showFavouritesOnly
                     ? "Tap ♥ on any symbol to save it here."
                     : "Try a different search or category.")
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: DSSpacing.xs) {
                // Size quick-change in toolbar
                Text(String(format: "%.0fpt", viewModel.previewSize))
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.accent)

                Stepper("", value: $viewModel.previewSize, in: 12...64, step: 4)
                    .labelsHidden()
            }
        }
    }

    // MARK: - Toast
    private var copiedToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DSColors.Preview.success)
            Text("\(viewModel.copiedLabel) copied!")
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
        .padding(.bottom, DSSpacing.xl)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        ))
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SFSymbolsView()
    }
}
