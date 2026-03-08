//
//  ColorBlindnessPreviewView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

// 2×2 grid showing how the FG/BG pair looks under 4 vision types,
// each with its simulated contrast ratio.

import SwiftUI

struct ColorBlindnessPreviewView: View {

    let viewModel: ContrastCheckerViewModel

    private let columns = [
        GridItem(.flexible(), spacing: DSSpacing.sm),
        GridItem(.flexible(), spacing: DSSpacing.sm)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {

            sectionHeader(
                title: "Color Blindness Preview",
                caption: "Simulated contrast ratio shown per type"
            )

            LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                ForEach(viewModel.colorBlindPreviews) { preview in
                    colorBlindCard(preview)
                }
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

    private func colorBlindCard(_ preview: ContrastCheckerViewModel.ColorBlindPreview) -> some View {
        VStack(spacing: 0) {

            // Preview swatch — FG text on BG
            ZStack {
                preview.background.color
                VStack(spacing: 4) {
                    Text("Aa")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(preview.foreground.color)
                    Text("Text")
                        .font(.system(size: 11))
                        .foregroundStyle(preview.foreground.color)
                }
            }
            .frame(height: 72)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .animation(.easeInOut(duration: 0.2), value: preview.foreground.hex + preview.background.hex)

            // Label row
            VStack(spacing: 2) {
                HStack {
                    Text(preview.name)
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    Spacer()
                    // Simulated ratio badge
                    Text(preview.ratioString)
                        .font(DSTypography.codeSmall)
                        .foregroundStyle(ratioColor(preview.contrastRatio))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                                   value: preview.ratioString)
                }

                Text(preview.description)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(preview.affectedPercent)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DSSpacing.xs)
            .background(DSColors.Preview.backgroundTertiary)
        }
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func ratioColor(_ ratio: Double) -> Color {
        if ratio >= 4.5 { return DSColors.Preview.success }
        if ratio >= 3.0 { return DSColors.Preview.warning }
        return DSColors.Preview.error
    }
}

// MARK: - ContrastFixSuggestionView
// Shows auto-suggested FG or BG colors that pass WCAG AA.

struct ContrastFixSuggestionView: View {

    let viewModel: ContrastCheckerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {

            sectionHeader(
                title: "Fix Suggestions",
                caption: "Adjusted colors that pass WCAG AA (4.5:1)"
            )

            if let fgSug = viewModel.fgSuggestion {
                suggestionRow(
                    role: "Adjust Foreground",
                    icon: "arrow.right.circle.fill",
                    original: viewModel.foreground,
                    suggested: fgSug,
                    onApply: { viewModel.applyFgSuggestion() }
                )
            }

            if let bgSug = viewModel.bgSuggestion {
                suggestionRow(
                    role: "Adjust Background",
                    icon: "arrow.left.circle.fill",
                    original: viewModel.background,
                    suggested: bgSug,
                    onApply: { viewModel.applyBgSuggestion() }
                )
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

    private func suggestionRow(
        role: String,
        icon: String,
        original: DevColor,
        suggested: DevColor,
        onApply: @escaping () -> Void
    ) -> some View {
        HStack(spacing: DSSpacing.sm) {

            // Original → suggested swatch pair
            HStack(spacing: DSSpacing.xs) {
                colorSwatch(original, size: 36)
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DSColors.Preview.textTertiary)
                colorSwatch(suggested, size: 36)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(role)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text(suggested.hex)
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)

                // New ratio preview
                let newRatio = suggested.contrastRatio(against: role.contains("Fore") ? viewModel.background : viewModel.foreground)
                Text(String(format: "New ratio: %.2f:1", newRatio))
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.success)
            }

            Spacer()

            // Apply button
            Button(action: onApply) {
                Text("Apply")
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xs)
                    .background(DSColors.Preview.accent, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.backgroundTertiary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func colorSwatch(_ color: DevColor, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
            .fill(color.color)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                    .strokeBorder(DSColors.Preview.borderDefault, lineWidth: 1)
            )
    }
}

// MARK: - Shared section header helper
private func sectionHeader(title: String, caption: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text(title)
            .font(DSTypography.headingSmall)
            .foregroundStyle(DSColors.Preview.textPrimary)
        Text(caption)
            .font(DSTypography.labelSmall)
            .foregroundStyle(DSColors.Preview.textTertiary)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        DSColors.Preview.backgroundPrimary.ignoresSafeArea()
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                ColorBlindnessPreviewView(viewModel: ContrastCheckerViewModel())
            }
            .padding()
        }
    }
}
