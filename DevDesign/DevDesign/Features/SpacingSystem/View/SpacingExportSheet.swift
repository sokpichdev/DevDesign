//
//  SpacingExportSheet.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI

struct SpacingExportSheet: View {

    @Bindable var viewModel: SpacingSystemViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {

                    // Scale summary strip
                    summaryStrip
                        .padding(.horizontal, DSSpacing.screenPadding)
                        .padding(.top, DSSpacing.md)

                    // Format tabs
                    formatTabStrip
                        .padding(.top, DSSpacing.md)

                    Divider().background(DSColors.Preview.borderSubtle)

                    // Code preview
                    codePreview
                        .padding(DSSpacing.screenPadding)

                    Spacer()

                    // Copy button
                    copyButton
                        .padding(DSSpacing.screenPadding)
                }
            }
            .navigationTitle("Export Spacing")
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

    // MARK: - Summary Strip
    private var summaryStrip: some View {
        HStack(spacing: DSSpacing.sm) {
            summaryChip(label: "Base",    value: "\(Int(viewModel.base.rawValue))pt")
            summaryChip(label: "Tokens",  value: "\(viewModel.tokens.count)")
            summaryChip(label: "Range",   value: viewModel.totalRange)
            if viewModel.overrideCount > 0 {
                summaryChip(label: "Overrides", value: "\(viewModel.overrideCount)",
                            accent: true)
            }
            Spacer()
        }
    }

    private func summaryChip(label: String, value: String, accent: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
            Text(value)
                .font(DSTypography.codeMedium)
                .foregroundStyle(accent ? DSColors.Preview.warning : DSColors.Preview.textPrimary)
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

    // MARK: - Format Tab Strip
    private var formatTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(SpacingExportFormat.allCases) { format in
                    tabButton(format)
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
        }
        .frame(height: 40)
    }

    private func tabButton(_ format: SpacingExportFormat) -> some View {
        let isSelected = viewModel.selectedExportFormat == format
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.selectedExportFormat = format
            }
        } label: {
            VStack(spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: format.icon)
                        .font(.system(size: 11, weight: .semibold))
                    Text(format.rawValue)
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
    }

    // MARK: - Code Preview
    private var codePreview: some View {
        ScrollView([.vertical, .horizontal], showsIndicators: true) {
            Text(viewModel.exportString(for: viewModel.selectedExportFormat))
                .font(DSTypography.codeSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .frame(maxHeight: 340)
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.backgroundPrimary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.15), value: viewModel.selectedExportFormat)
    }

    // MARK: - Copy Button
    private var copyButton: some View {
        Button {
            viewModel.copyExport(for: viewModel.selectedExportFormat)
            dismiss()
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "doc.on.doc.fill")
                Text("Copy \(viewModel.selectedExportFormat.rawValue)")
                    .font(DSTypography.headingSmall)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.Preview.accent,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        }
        .buttonStyle(.plain)
    }
}
