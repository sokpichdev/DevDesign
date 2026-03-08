//
//  ComponentSnippetsView.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import SwiftUI
import SwiftData

struct ComponentSnippetsView: View {

    @State private var viewModel = SnippetViewModel()
    @Query(sort: \CustomSnippet.createdAt, order: .reverse) private var customSnippets: [CustomSnippet]
    @Environment(\.modelContext) private var context

    private let columns = [
        GridItem(.flexible(), spacing: DSSpacing.sm),
        GridItem(.flexible(), spacing: DSSpacing.sm),
    ]

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Search bar
                searchBar
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.top, DSSpacing.sm)
                    .padding(.bottom, DSSpacing.xs)

                // Category strip
                categoryStrip
                    .padding(.bottom, DSSpacing.sm)

                Divider().background(DSColors.Preview.borderSubtle)

                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DSSpacing.lg) {
                        if viewModel.selectedCategory == .custom {
                            customSnippetsList
                        } else {
                            curatedGrid
                        }
                        Spacer(minLength: DSSpacing.xxxl)
                    }
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.top, DSSpacing.md)
                }
            }
        }
        .navigationTitle("Components")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showSaveCustomSheet) {
            SaveCustomSnippetSheet(viewModel: viewModel)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DSColors.Preview.textTertiary)

            TextField("Search components…", text: $viewModel.searchText)
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        viewModel.searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.8),
                   value: viewModel.searchText.isEmpty)
    }

    // MARK: - Category Strip
    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                ForEach(SnippetCategory.allCases) { cat in
                    categoryChip(cat)
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
        }
    }

    private func categoryChip(_ cat: SnippetCategory) -> some View {
        let isSelected = viewModel.selectedCategory == cat
        let count: Int? = cat == .custom
            ? customSnippets.count
            : (cat == .all ? nil : viewModel.categoryCounts[cat])

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.selectedCategory = cat
                viewModel.searchText = ""
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: cat.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(cat.rawValue)
                    .font(DSTypography.labelLarge)
                if let count {
                    Text("\(count)")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(isSelected ? .white.opacity(0.7) : DSColors.Preview.textTertiary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            (isSelected ? Color.white.opacity(0.25) : DSColors.Preview.backgroundTertiary),
                            in: Capsule()
                        )
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

    // MARK: - Curated Grid
    private var curatedGrid: some View {
        Group {
            if viewModel.filteredCurated.isEmpty {
                emptySearch
            } else {
                LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                    ForEach(viewModel.filteredCurated) { snippet in
                        NavigationLink(destination: SnippetDetailView(snippet: snippet, viewModel: viewModel)) {
                            SnippetCard(snippet: snippet, accentColor: viewModel.accentColor)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button {
                                viewModel.copyCurated(snippet)
                            } label: {
                                Label("Copy Code", systemImage: "doc.on.doc")
                            }
                        }
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8),
                           value: viewModel.filteredCurated.map(\.id))
            }
        }
    }

    // MARK: - Custom Snippets List
    private var customSnippetsList: some View {
        VStack(spacing: DSSpacing.sm) {
            if customSnippets.isEmpty {
                emptyCustom
            } else {
                ForEach(customSnippets) { snippet in
                    CustomSnippetRow(snippet: snippet, viewModel: viewModel, context: context)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: customSnippets.count)
            }
        }
    }

    // MARK: - Empty States
    private var emptySearch: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(DSColors.Preview.textTertiary)
            Text("No results for \(viewModel.searchText)")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textSecondary)
            Button {
                viewModel.searchText = ""
            } label: {
                Text("Clear Search")
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.accent)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.xxxl)
    }

    private var emptyCustom: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "star")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(DSColors.Preview.textTertiary)
            VStack(spacing: DSSpacing.xs) {
                Text("No Custom Snippets")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                Text("Save your own reusable SwiftUI components here.")
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .multilineTextAlignment(.center)
            }
            Button {
                viewModel.showSaveCustomSheet = true
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "plus")
                    Text("Add Snippet")
                        .font(DSTypography.labelLarge)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.xs)
                .background(DSColors.Preview.accent, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.xxxl)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.showSaveCustomSheet = true
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(DSColors.Preview.accent)
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

// MARK: - Snippet Card (grid cell)

struct SnippetCard: View {
    let snippet: CuratedSnippet
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // Icon area
            ZStack {
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .fill(accentColor.opacity(0.12))
                    .frame(height: 68)
                Image(systemName: snippet.previewSymbol)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(accentColor)
            }

            // Labels
            VStack(alignment: .leading, spacing: 3) {
                Text(snippet.title)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .lineLimit(1)
                Text(snippet.subtitle)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .lineLimit(1)
            }

            // Category badge
            Text(snippet.category.rawValue)
                .font(DSTypography.labelSmall)
                .foregroundStyle(accentColor)
                .padding(.horizontal, DSSpacing.xs)
                .padding(.vertical, 2)
                .background(accentColor.opacity(0.1), in: Capsule())
        }
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Custom Snippet Row

struct CustomSnippetRow: View {
    let snippet: CustomSnippet
    @Bindable var viewModel: SnippetViewModel
    let context: ModelContext

    @State private var showDeleteAlert = false
    @State private var showCode = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(DSColors.Preview.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(snippet.title)
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    if !snippet.subtitle.isEmpty {
                        Text(snippet.subtitle)
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                }

                Spacer()

                // Expand / collapse
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showCode.toggle()
                    }
                } label: {
                    Image(systemName: showCode ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }
                .buttonStyle(.plain)

                // Copy
                Button {
                    viewModel.copyCustom(snippet)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14))
                        .foregroundStyle(DSColors.Preview.accent)
                }
                .buttonStyle(.plain)

                // Delete
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(DSColors.Preview.error)
                }
                .buttonStyle(.plain)
            }
            .padding(DSSpacing.sm)

            // Expandable code
            if showCode {
                Divider().background(DSColors.Preview.borderSubtle)
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    Text(snippet.code)
                        .font(DSTypography.codeSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 200)
                .padding(DSSpacing.sm)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Tags
            if !snippet.tagList.isEmpty {
                Divider().background(DSColors.Preview.borderSubtle)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.xs) {
                        ForEach(snippet.tagList, id: \.self) { tag in
                            Text(tag)
                                .font(DSTypography.labelSmall)
                                .foregroundStyle(DSColors.Preview.textTertiary)
                                .padding(.horizontal, DSSpacing.xs)
                                .padding(.vertical, 2)
                                .background(DSColors.Preview.backgroundTertiary, in: Capsule())
                        }
                    }
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xs)
                }
            }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .alert("Delete \(snippet.title)?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    viewModel.deleteCustom(snippet, context: context)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { 
            Text("This cannot be undone.")
        }
    }
}
