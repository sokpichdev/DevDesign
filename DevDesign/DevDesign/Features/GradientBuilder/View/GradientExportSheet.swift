//
//  GradientExportSheet.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI

struct GradientExportSheet: View {

    @Bindable var viewModel: GradientViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {

                    // Gradient thumbnail + summary
                    summaryHeader
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
            .navigationTitle("Export Gradient")
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

    // MARK: - Summary Header
    private var summaryHeader: some View {
        HStack(spacing: DSSpacing.md) {
            // Thumbnail
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .fill(gradientFill)
                .frame(width: 64, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.config.type.rawValue + " Gradient")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                HStack(spacing: DSSpacing.xs) {
                    Text("\(viewModel.config.stops.count) stops")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                    if viewModel.config.type == .linear {
                        Text("·")
                            .foregroundStyle(DSColors.Preview.textTertiary)
                        Text("\(Int(viewModel.config.angle))°")
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                }
            }
            Spacer()
        }
    }

    private var gradientFill: AnyShapeStyle {
        switch viewModel.config.type {
        case .linear:  return AnyShapeStyle(viewModel.config.linearGradient)
        case .radial:  return AnyShapeStyle(viewModel.config.radialGradient)
        case .angular: return AnyShapeStyle(viewModel.config.angularGradient)
        }
    }

    // MARK: - Format Tabs
    private var formatTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(GradientExportFormat.allCases) { format in
                    tabButton(format)
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
        }
        .frame(height: 40)
    }

    private func tabButton(_ format: GradientExportFormat) -> some View {
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
