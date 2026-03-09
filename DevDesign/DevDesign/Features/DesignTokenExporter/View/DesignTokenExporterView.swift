//
//  DesignTokenExporterView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI
import SwiftData

struct DesignTokenExporterView: View {

    @State private var viewModel = DesignTokenViewModel()

    // Live SwiftData palette query — auto-updates when user saves new palettes
    @Query(sort: \SavedPalette.createdAt, order: .reverse)
    private var allPalettes: [SavedPalette]

    private let accentColor = Color(hex: "#30D158")

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Section tab strip ──────────────────────────────
                tabStrip
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.vertical, DSSpacing.sm)

                Divider().background(DSColors.Preview.borderSubtle)

                // ── Search bar (hidden on Export tab) ─────────────
                if viewModel.selectedSection != .export {
                    searchBar
                        .padding(.horizontal, DSSpacing.screenPadding)
                        .padding(.top, DSSpacing.sm)
                }

                // ── Content ───────────────────────────────────────
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DSSpacing.md) {
                        sectionContent
                        Spacer(minLength: DSSpacing.xxxl)
                    }
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.top, DSSpacing.md)
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .navigationTitle("Token Exporter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showExportSheet) {
            TokenExportSheet(viewModel: viewModel, accentColor: accentColor)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
        // Sync SwiftData → viewModel whenever palettes change
        .onChange(of: allPalettes) { _, newValue in
            viewModel.updateColors(from: newValue)
        }
        .onAppear {
            viewModel.updateColors(from: allPalettes)
        }
    }

    // MARK: - Tab Strip
    private var tabStrip: some View {
        HStack(spacing: 0) {
            ForEach(TokenSection.allCases) { section in
                let isSelected = viewModel.selectedSection == section
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectedSection = section
                        viewModel.searchText = ""
                        viewModel.cancelRename()
                    }
                } label: {
                    VStack(spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: section.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(section.rawValue)
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(isSelected ? accentColor : DSColors.Preview.textTertiary)
                        .padding(.horizontal, DSSpacing.xs)
                        Rectangle()
                            .fill(isSelected ? accentColor : Color.clear)
                            .frame(height: 2)
                            .clipShape(Capsule())
                            .padding(.horizontal, DSSpacing.xs)
                    }
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DSColors.Preview.textTertiary)
                .font(.system(size: 14))
            TextField("Search tokens…", text: $viewModel.searchText)
                .font(DSTypography.bodyMedium)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !viewModel.searchText.isEmpty {
                Button {
                    withAnimation { viewModel.searchText = "" }
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
    }

    // MARK: - Section Content
    @ViewBuilder
    private var sectionContent: some View {
        switch viewModel.selectedSection {
        case .colors:
            VStack(spacing: DSSpacing.sm) {
                sectionHeader(
                    title: "Color Tokens",
                    subtitle: "\(viewModel.colorTokens.count) tokens · tap name to rename",
                    icon: "paintpalette"
                )
                ColorsSectionView(vm: viewModel, accentColor: accentColor)
            }
            .transition(.opacity)

        case .typography:
            VStack(spacing: DSSpacing.sm) {
                sectionHeader(
                    title: "Typography Tokens",
                    subtitle: "\(viewModel.typographyTokens.count) steps · Major Third scale from 16pt",
                    icon: "textformat"
                )
                typeScaleSourceNote
                TypographySectionView(vm: viewModel, accentColor: accentColor)
            }
            .transition(.opacity)

        case .spacing:
            VStack(spacing: DSSpacing.sm) {
                sectionHeader(
                    title: "Spacing Tokens",
                    subtitle: "\(viewModel.spacingTokens.count) steps · 4pt base grid",
                    icon: "ruler"
                )
                spacingSourceNote
                SpacingSectionView(vm: viewModel, accentColor: accentColor)
            }
            .transition(.opacity)

        case .export:
            VStack(spacing: DSSpacing.md) {
                sectionHeader(
                    title: "Export",
                    subtitle: "\(viewModel.totalTokenCount) total tokens",
                    icon: "square.and.arrow.up"
                )
                ExportOptionsCard(vm: viewModel, accentColor: accentColor)
                codePreviewCard
                exportFormatButtons
            }
            .transition(.opacity)
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DSTypography.headingMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text(subtitle)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            Spacer()
        }
    }

    // MARK: - Source Notes
    private var typeScaleSourceNote: some View {
        noteCard(
            icon: "arrow.trianglehead.2.clockwise",
            text: "Tokens mirror the Type Scale tool (Major Third, 16pt base). Edit values there to update them here.",
            color: accentColor
        )
    }

    private var spacingSourceNote: some View {
        noteCard(
            icon: "arrow.trianglehead.2.clockwise",
            text: "Tokens mirror the Spacing System tool (4pt base grid). Edit the base unit there to update them here.",
            color: accentColor
        )
    }

    private func noteCard(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
                .padding(.top, 1)
            Text(text)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DSSpacing.sm)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Code Preview Card (on Export tab)
    private var codePreviewCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Image(systemName: viewModel.exportFormat.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(accentColor)
                Text("Preview")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Text(viewModel.exportFormat.fileExtension)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                let code = viewModel.exportCode(format: viewModel.exportFormat)
                let preview = code.components(separatedBy: "\n").prefix(35).joined(separator: "\n")
                let hasMore = code.components(separatedBy: "\n").count > 35
                Text(preview + (hasMore ? "\n\n// … \(code.components(separatedBy: "\n").count - 35) more lines" : ""))
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding(DSSpacing.sm)
            }
            .frame(height: 240)
            .background(DSColors.Preview.backgroundSecondary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .contentTransition(.opacity)
        .id(viewModel.exportFormat)
    }

    // MARK: - Per-format export buttons
    private var exportFormatButtons: some View {
        VStack(spacing: DSSpacing.sm) {
            Text("Export Each Format")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.xxs)

            ForEach(TokenExportFormat.allCases.filter { $0 != .all }) { fmt in
                Button {
                    viewModel.copyExport(format: fmt)
                } label: {
                    HStack(spacing: DSSpacing.sm) {
                        Image(systemName: fmt.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(accentColor)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(fmt.rawValue) \(fmt.fileExtension)")
                                .font(DSTypography.headingSmall)
                                .foregroundStyle(DSColors.Preview.textPrimary)
                            Text(formatDescription(fmt))
                                .font(DSTypography.labelSmall)
                                .foregroundStyle(DSColors.Preview.textTertiary)
                        }
                        Spacer()
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14))
                            .foregroundStyle(accentColor)
                    }
                    .padding(DSSpacing.sm)
                    .background(DSColors.Preview.surfaceDefault,
                                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            // Export all
            Button {
                viewModel.showExportSheet = true
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Open Full Export Sheet")
                        .font(DSTypography.headingSmall)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
                .background(accentColor, in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            }
            .buttonStyle(.plain)
        }
    }

    private func formatDescription(_ fmt: TokenExportFormat) -> String {
        switch fmt {
        case .swiftEnum: return "Color, Typography, Spacing as Swift enum with static lets"
        case .json:      return "W3C Design Token Community Group format"
        case .css:       return "CSS custom properties for web / React Native"
        case .all:       return "All three formats in one file"
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            // Token count badge
            HStack(spacing: 4) {
                Image(systemName: "tag")
                    .font(.system(size: 11))
                Text("\(viewModel.totalTokenCount)")
                    .font(DSTypography.codeMedium)
            }
            .foregroundStyle(DSColors.Preview.textTertiary)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.showExportSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                        .font(DSTypography.labelLarge)
                }
                .foregroundStyle(accentColor)
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

// MARK: - Export Sheet

struct TokenExportSheet: View {

    @Bindable var viewModel: DesignTokenViewModel
    let accentColor: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: 0) {

                    // Format tabs
                    HStack(spacing: 0) {
                        ForEach(TokenExportFormat.allCases) { fmt in
                            let isSel = viewModel.exportFormat == fmt
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    viewModel.exportFormat = fmt
                                }
                            } label: {
                                VStack(spacing: 3) {
                                    HStack(spacing: 4) {
                                        Image(systemName: fmt.icon)
                                            .font(.system(size: 11, weight: .semibold))
                                        Text(fmt.rawValue)
                                            .font(DSTypography.labelLarge)
                                    }
                                    .foregroundStyle(isSel ? accentColor : DSColors.Preview.textTertiary)
                                    .padding(.horizontal, DSSpacing.xs)
                                    Rectangle()
                                        .fill(isSel ? accentColor : Color.clear)
                                        .frame(height: 2)
                                        .clipShape(Capsule())
                                        .padding(.horizontal, DSSpacing.xs)
                                }
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSel)
                        }
                    }
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.vertical, DSSpacing.sm)

                    Divider().background(DSColors.Preview.borderSubtle)

                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        Text(viewModel.exportCode(format: viewModel.exportFormat))
                            .font(DSTypography.codeSmall)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(DSSpacing.md)
                    }
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.15), value: viewModel.exportFormat)

                    Spacer()

                    // Copy button
                    Button {
                        viewModel.copyExport(format: viewModel.exportFormat)
                        dismiss()
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "doc.on.doc.fill")
                            Text("Copy \(viewModel.exportFormat.rawValue)")
                                .font(DSTypography.headingSmall)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                        .background(accentColor, in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
                    }
                    .buttonStyle(.plain)
                    .padding(DSSpacing.screenPadding)
                }
            }
            .navigationTitle("Export Tokens")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(accentColor)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DesignTokenExporterView()
    }
    .modelContainer(for: [SavedPalette.self, SavedColor.self], inMemory: true)
}
