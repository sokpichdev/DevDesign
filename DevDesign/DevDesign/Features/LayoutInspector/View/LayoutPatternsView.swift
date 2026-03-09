//
//  LayoutPatternsView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//
// LayoutPatternsView.swift
// DevDesign — Features/LayoutInspector/LayoutPatternsView.swift

import SwiftUI

struct LayoutPatternsView: View {

    @Bindable var viewModel: LayoutViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Search + category filter
            searchAndFilter
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.vertical, DSSpacing.sm)

            Divider().background(DSColors.Preview.borderSubtle)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.sm) {
                    if viewModel.filteredPatterns.isEmpty {
                        emptyState
                    } else {
                        // Group by category for display
                        ForEach(groupedPatterns, id: \.key) { group in
                            patternSection(group.key, patterns: group.value)
                        }
                    }
                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    // MARK: - Search + Filter
    private var searchAndFilter: some View {
        VStack(spacing: DSSpacing.sm) {
            // Search
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DSColors.Preview.textTertiary)
                TextField("Search patterns…", text: $viewModel.patternSearchText)
                    .font(DSTypography.bodySmall)
                    .autocorrectionDisabled()
                if !viewModel.patternSearchText.isEmpty {
                    Button {
                        viewModel.patternSearchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    .buttonStyle(.plain)
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

            // Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    categoryChip(nil, label: "All")
                    ForEach(LayoutPattern.PatternCategory.allCases, id: \.rawValue) { cat in
                        categoryChip(cat, label: cat.rawValue)
                    }
                }
            }
        }
    }

    private func categoryChip(_ cat: LayoutPattern.PatternCategory?, label: String) -> some View {
        let isSelected = viewModel.selectedPatternCategory == cat
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.selectedPatternCategory = cat
            }
        } label: {
            Text(label)
                .font(DSTypography.labelLarge)
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

    // MARK: - Grouped Patterns
    private var groupedPatterns: [(key: String, value: [LayoutPattern])] {
        if viewModel.selectedPatternCategory != nil || !viewModel.patternSearchText.isEmpty {
            return [("Results", viewModel.filteredPatterns)]
        }
        var groups: [(key: String, value: [LayoutPattern])] = []
        for cat in LayoutPattern.PatternCategory.allCases {
            let items = viewModel.filteredPatterns.filter { $0.category == cat }
            if !items.isEmpty {
                groups.append((cat.rawValue, items))
            }
        }
        return groups
    }

    private func patternSection(_ title: String, patterns: [LayoutPattern]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            if title != "Results" {
                Text(title)
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .padding(.horizontal, DSSpacing.xxs)
            }
            ForEach(patterns) { pattern in
                PatternCard(pattern: pattern, viewModel: viewModel)
            }
        }
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "rectangle.3.group")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(DSColors.Preview.textTertiary)
            Text("No patterns found")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textSecondary)
            Button {
                viewModel.patternSearchText = ""
                viewModel.selectedPatternCategory = nil
            } label: {
                Text("Clear Filters")
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.accent)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.xxxl)
    }
}

// MARK: - Pattern Card

struct PatternCard: View {
    let pattern: LayoutPattern
    @Bindable var viewModel: LayoutViewModel

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header — entire row is tappable
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: pattern.icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(DSColors.Preview.accent)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 3) {
                    Text(pattern.name)
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    Text(pattern.description)
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }

                Spacer()

                // Category badge
                Text(pattern.category.rawValue)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.accent)
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, 2)
                    .background(DSColors.Preview.accent.opacity(0.1), in: Capsule())

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .padding(DSSpacing.sm)
            .contentShape(Rectangle())   // makes full row hittable
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }

            // Expandable code block
            if isExpanded {
                Divider().background(DSColors.Preview.borderSubtle)

                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    Text(pattern.code)
                        .font(DSTypography.codeSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 240)
                .padding(DSSpacing.sm)
                .background(DSColors.Preview.backgroundPrimary)
                .transition(.move(edge: .top).combined(with: .opacity))

                Divider().background(DSColors.Preview.borderSubtle)

                Button {
                    viewModel.copyPattern(pattern)
                } label: {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 13))
                        Text("Copy \(pattern.name)")
                            .font(DSTypography.labelLarge)
                    }
                    .foregroundStyle(DSColors.Preview.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.sm)
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(
                    isExpanded ? DSColors.Preview.accent.opacity(0.4) : DSColors.Preview.borderSubtle,
                    lineWidth: isExpanded ? 1.5 : 1
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
    }
}
