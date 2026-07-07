//
//  SymbolEffectsExportSheet.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  Export sheet for the Symbol Effects tool — mirrors MetalSymbolExportSheet.
//

import SwiftUI

struct SymbolEffectsExportSheet: View {

    @Bindable var viewModel: SymbolEffectsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    summaryStrip
                        .padding(.horizontal, DSSpacing.screenPadding)
                        .padding(.top, DSSpacing.md)

                    formatTabStrip
                        .padding(.top, DSSpacing.md)

                    Divider().background(DSColors.Preview.borderSubtle)

                    codePreview
                        .padding(DSSpacing.screenPadding)

                    Spacer()

                    copyButton
                        .padding(DSSpacing.screenPadding)
                }
            }
            .navigationTitle("Export Effect")
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
            Image(systemName: viewModel.config.symbolName)
                .font(.system(size: 22))
                .foregroundStyle(DSColors.Preview.accent)
                .frame(width: 36, height: 36)
                .background(DSColors.Preview.surfaceDefault,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.config.kind.displayName)
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text(viewModel.config.symbolName)
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            Spacer()
        }
    }

    // MARK: - Format Tabs
    private var formatTabStrip: some View {
        HStack(spacing: 0) {
            ForEach(SymbolEffectExportFormat.allCases) { format in
                tabButton(format)
            }
        }
        .padding(.horizontal, DSSpacing.screenPadding)
        .frame(height: 40)
    }

    private func tabButton(_ format: SymbolEffectExportFormat) -> some View {
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
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(isSelected ? DSColors.Preview.accent : Color.clear)
                    .frame(height: 2)
                    .clipShape(Capsule())
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
        .frame(maxHeight: 360)
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
