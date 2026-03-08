//
//  FontPairingCard.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Grid card showing a live font pair preview.
// Shows skeleton shimmer while Google Font loads.

import SwiftUI

struct FontPairingCard: View {

    let pair: FontPair
    let loadState: FontPairingViewModel.PairLoadState
    var onTap: () -> Void

    @State private var shimmerPhase: CGFloat = -1

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {

                // Live font preview
                previewBlock

                Divider().background(DSColors.Preview.borderSubtle)

                // Metadata
                footerRow
            }
            .padding(DSSpacing.cardPadding)
            .background(DSColors.Preview.surfaceDefault,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preview Block
    private var previewBlock: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {

            // Display line
            Group {
                if loadState == .loading {
                    shimmerBar(height: 26, width: .infinity)
                } else {
                    Text("The Quick Fox")
                        .font(displayFont(size: 22))
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .lineLimit(1)
                }
            }

            // Body lines
            Group {
                if loadState == .loading {
                    VStack(spacing: 5) {
                        shimmerBar(height: 13, width: .infinity)
                        shimmerBar(height: 13, width: 120)
                    }
                } else {
                    Text("The quick brown fox jumps over the lazy dog. Sphinx of black quartz, judge my vow.")
                        .font(bodyFont(size: 12))
                        .foregroundStyle(DSColors.Preview.textSecondary)
                        .lineLimit(3)
                }
            }
        }
        .frame(minHeight: 80)
    }

    // MARK: - Footer
    private var footerRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pair.name)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .lineLimit(1)

            HStack(spacing: DSSpacing.xs) {
                categoryBadge
                Spacer()
                loadIndicator
            }
        }
    }

    private var categoryBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: pair.category.icon)
                .font(.system(size: 9, weight: .semibold))
            Text(pair.category.rawValue)
                .font(DSTypography.labelSmall)
        }
        .foregroundStyle(DSColors.Preview.accent)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(DSColors.Preview.accentMuted, in: Capsule())
    }

    @ViewBuilder
    private var loadIndicator: some View {
        switch loadState {
        case .loading:
            HStack(spacing: 4) {
                ProgressView().scaleEffect(0.6)
                Text("Loading")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
        case .failed:
            HStack(spacing: 4) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 9))
                Text("Offline")
                    .font(DSTypography.labelSmall)
            }
            .foregroundStyle(DSColors.Preview.error)
        case .loaded where !pair.displayFont.isSystem && !pair.bodyFont.isSystem:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 11))
                .foregroundStyle(DSColors.Preview.success)
        default:
            EmptyView()
        }
    }

    // MARK: - Shimmer
    private func shimmerBar(height: CGFloat, width: CGFloat) -> some View {
        GeometryReader { geo in
            let w = width == .infinity ? geo.size.width : width
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            DSColors.Preview.backgroundTertiary,
                            DSColors.Preview.surfaceElevated,
                            DSColors.Preview.backgroundTertiary
                        ],
                        startPoint: UnitPoint(x: shimmerPhase, y: 0),
                        endPoint:   UnitPoint(x: shimmerPhase + 1, y: 0)
                    )
                )
                .frame(width: w, height: height)
                .onAppear {
                    withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                        shimmerPhase = 1
                    }
                }
        }
        .frame(height: height)
    }

    // MARK: - Fonts
    private func displayFont(size: CGFloat) -> Font {
        makeFont(spec: pair.displayFont, size: size, bold: true)
    }

    private func bodyFont(size: CGFloat) -> Font {
        makeFont(spec: pair.bodyFont, size: size, bold: false)
    }

    private func makeFont(spec: FontSpec, size: CGFloat, bold: Bool) -> Font {
        let weight: UIFont.Weight = bold ? .bold : .regular
        let uiFont = spec.uiFont(size: size, weight: weight)
        return Font(uiFont)
    }
}
