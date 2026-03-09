//
//  AppIconExportSheet.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct AppIconExportSheet: View {

    @Bindable var viewModel: AppIconViewModel
    @Environment(\.dismiss) private var dismiss

    // Grid columns for size preview
    private let previewColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab strip
                    tabStrip
                        .padding(.horizontal, DSSpacing.screenPadding)
                        .padding(.top, DSSpacing.sm)
                        .padding(.bottom, DSSpacing.xs)

                    Divider().background(DSColors.Preview.borderSubtle)

                    // Content
                    tabContent
                        .animation(.easeInOut(duration: 0.15), value: viewModel.selectedExportTab)
                }
            }
            .navigationTitle("Export Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(DSColors.Preview.accent)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }

    // MARK: - Tab Strip
    private var tabStrip: some View {
        HStack(spacing: 0) {
            ForEach(IconExportTab.allCases) { tab in
                let isSelected = viewModel.selectedExportTab == tab
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        viewModel.selectedExportTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(tab.rawValue)
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(isSelected ? DSColors.Preview.accent : DSColors.Preview.textTertiary)
                        .padding(.horizontal, DSSpacing.sm)

                        Rectangle()
                            .fill(isSelected ? DSColors.Preview.accent : Color.clear)
                            .frame(height: 2)
                            .clipShape(Capsule())
                            .padding(.horizontal, DSSpacing.sm)
                    }
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
            }
        }
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedExportTab {
        case .preview:
            sizePreviewTab
        case .swift:
            codeTab(
                code: AppIconExportService.exportSwiftSnippet(config: viewModel.config),
                copyLabel: "Swift snippet",
                onCopy: { viewModel.copySwiftSnippet(); dismiss() }
            )
        case .json:
            codeTab(
                code: AppIconExportService.contentsJSON(),
                copyLabel: "Contents.json",
                onCopy: { viewModel.copyContentsJSON(); dismiss() }
            )
        }
    }

    // MARK: - Size Preview Tab
    private var sizePreviewTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {

                // Hero 1024 preview
                heroPreview

                // All sizes grid
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("All Required Sizes")
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .padding(.horizontal, DSSpacing.xxs)

                    LazyVGrid(columns: previewColumns, spacing: DSSpacing.md) {
                        ForEach(AppIconSizeLibrary.all) { size in
                            sizeCell(size)
                        }
                    }
                }

                // Instructions card
                instructionsCard
            }
            .padding(DSSpacing.screenPadding)
        }
    }

    private var heroPreview: some View {
        HStack(spacing: DSSpacing.md) {
            AppIconCanvasView(config: viewModel.config, size: 100)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("App Store")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text("1024 × 1024 px")
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.accent)
                Text("Required for App Store submission. No transparency, no alpha channel.")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func sizeCell(_ size: AppIconSize) -> some View {
        let displaySize: CGFloat = min(CGFloat(size.pixels) / 3.5, 64)

        return VStack(spacing: DSSpacing.xs) {
            AppIconCanvasView(config: viewModel.config, size: max(displaySize, 20))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            Text("\(size.pixels)px")
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)

            Text(size.usage)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(size.platform.rawValue)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.accent)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(DSColors.Preview.accent.opacity(0.1), in: Capsule())
        }
        .frame(maxWidth: .infinity)
    }

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color(hex: "#FFCC00"))
                Text("How to use in Xcode")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
            }

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                instructionStep(1, "Copy the Swift snippet (Swift Code tab) to recreate the icon design in code")
                instructionStep(2, "In Xcode, open Assets.xcassets → AppIcon")
                instructionStep(3, "Use the icon design as a reference to export PNGs at the required sizes")
                instructionStep(4, "For single-size apps targeting iOS 16+, you only need the 1024pt App Store image — Xcode auto-generates the rest")
            }
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func instructionStep(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Text("\(n)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(DSColors.Preview.accent, in: Circle())
            Text(text)
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Code Tab
    private func codeTab(code: String, copyLabel: String, onCopy: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                Text(code)
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding(DSSpacing.md)
            }

            Divider().background(DSColors.Preview.borderSubtle)

            Button(action: onCopy) {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "doc.on.doc.fill")
                    Text("Copy \(copyLabel)")
                        .font(DSTypography.headingSmall)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
                .background(DSColors.Preview.accent,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            }
            .buttonStyle(.plain)
            .padding(DSSpacing.screenPadding)
        }
        .contentTransition(.opacity)
    }
}
