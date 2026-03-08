// WCAGBadgesView.swift
// DevDesign — Features/ContrastChecker/WCAGBadgesView.swift
//
// Shows the large ratio display + 3×2 WCAG pass/fail grid
// (Normal Text / Large Text / UI Component) × (AA / AAA)

import SwiftUI

struct WCAGBadgesView: View {

    let viewModel: ContrastCheckerViewModel

    var body: some View {
        VStack(spacing: DSSpacing.md) {

            // ── Large ratio display ──────────────────────────────
            ratioDisplay

            // ── 3 × 2 WCAG grid ─────────────────────────────────
            wcagGrid
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Ratio Display
    private var ratioDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: DSSpacing.xs) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Contrast Ratio")
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textSecondary)

                HStack(alignment: .lastTextBaseline, spacing: DSSpacing.xs) {
                    Text(viewModel.ratioString)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(viewModel.ratingColor)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.35, dampingFraction: 0.8),
                                   value: viewModel.ratioString)

                    ratingBadge
                }
            }

            Spacer()

            // Copy ratio button
            Button { viewModel.copyRatio() } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 15))
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(width: 36, height: 36)
                    .background(DSColors.Preview.backgroundTertiary, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var ratingBadge: some View {
        Text(viewModel.rating)
            .font(DSTypography.labelLarge)
            .foregroundStyle(.white)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs)
            .background(viewModel.ratingColor, in: Capsule())
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: viewModel.rating)
    }

    // MARK: - WCAG Grid
    private var wcagGrid: some View {
        VStack(spacing: DSSpacing.xs) {

            // Column headers
            HStack {
                Text("Context")
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("AA")
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(width: 72, alignment: .center)
                Text("AAA")
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(width: 72, alignment: .center)
            }
            .padding(.horizontal, DSSpacing.xs)

            Divider().background(DSColors.Preview.borderSubtle)

            // Rows
            ForEach(viewModel.wcagChecks) { check in
                wcagRow(check)
            }
        }
    }

    private func wcagRow(_ check: ContrastCheckerViewModel.WCAGCheck) -> some View {
        HStack {
            // Context label
            VStack(alignment: .leading, spacing: 1) {
                Text(check.label)
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text(check.sublabel)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // AA badge
            passFailBadge(passes: check.aaPass, label: String(format: "%.1f+", check.minRatioAA))
                .frame(width: 72, alignment: .center)

            // AAA badge
            passFailBadge(passes: check.aaaPass, label: String(format: "%.1f+", check.minRatioAAA))
                .frame(width: 72, alignment: .center)
        }
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, DSSpacing.xs)
        .background(DSColors.Preview.backgroundSecondary.opacity(0.5),
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))
    }

    private func passFailBadge(passes: Bool, label: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: passes ? "checkmark" : "xmark")
                .font(.system(size: 10, weight: .bold))
            Text(passes ? "Pass" : "Fail")
                .font(DSTypography.labelMedium)
        }
        .foregroundStyle(passes ? DSColors.Preview.success : DSColors.Preview.error)
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, 4)
        .background(
            (passes ? DSColors.Preview.success : DSColors.Preview.error).opacity(0.12),
            in: Capsule()
        )
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: passes)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        DSColors.Preview.backgroundPrimary.ignoresSafeArea()
        WCAGBadgesView(viewModel: ContrastCheckerViewModel())
            .padding()
    }
}
