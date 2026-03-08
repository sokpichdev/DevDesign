//
//  ShadowExportSheet.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI

struct ShadowExportSheet: View {

    @Bindable var viewModel: ShadowViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {

                    // Layer summary strip
                    layerSummaryStrip
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

                    copyButton
                        .padding(DSSpacing.screenPadding)
                }
            }
            .navigationTitle("Export Shadow")
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

    // MARK: - Layer Summary Strip
    private var layerSummaryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                ForEach(Array(viewModel.layers.enumerated()), id: \.element.id) { index, layer in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(layer.color.opacity(layer.opacity))
                                .frame(width: 10, height: 10)
                                .shadow(color: layer.color.opacity(layer.opacity),
                                        radius: 2, x: 0, y: 1)
                            Text("Layer \(index + 1)")
                                .font(DSTypography.labelLarge)
                                .foregroundStyle(layer.isEnabled
                                                 ? DSColors.Preview.textPrimary
                                                 : DSColors.Preview.textTertiary)
                        }
                        Text(layer.isInner ? "inner" : "outer")
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xs)
                    .background(DSColors.Preview.surfaceDefault,
                                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            .strokeBorder(
                                layer.isEnabled
                                    ? DSColors.Preview.borderSubtle
                                    : DSColors.Preview.borderSubtle.opacity(0.4),
                                lineWidth: 1
                            )
                    )
                    .opacity(layer.isEnabled ? 1 : 0.5)
                }
            }
        }
    }

    // MARK: - Format Tab Strip
    private var formatTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(ShadowExportFormat.allCases) { format in
                    tabButton(format)
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
        }
        .frame(height: 40)
    }

    private func tabButton(_ format: ShadowExportFormat) -> some View {
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
        .frame(maxHeight: 320)
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
