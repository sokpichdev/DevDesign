//
//  TypeScalePreviewRow.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// One row per type scale step.
// Shows the step name, computed size, and live text rendered at that size.

import SwiftUI

struct TypeScalePreviewRow: View {

    let step: TypeScaleStep
    let index: Int
    var onWeightChange: (FontWeightOption) -> Void

    @State private var isExpanded: Bool = false

    // Sample text adapts to size — larger steps get shorter text
    private var sampleText: String {
        step.size >= 28 ? "Aa" :
        step.size >= 20 ? "The quick brown fox" :
                          "The quick brown fox jumps over the lazy dog"
    }

    var body: some View {
        VStack(spacing: 0) {
            mainRow
            if isExpanded { detailRow }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
    }

    // MARK: - Main Row
    private var mainRow: some View {
        HStack(alignment: .center, spacing: DSSpacing.sm) {

            // Step meta
            VStack(alignment: .leading, spacing: 2) {
                Text(step.name)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textSecondary)

                HStack(spacing: DSSpacing.xs) {
                    Text(String(format: "%.1fpt", step.size))
                        .font(DSTypography.codeSmall)
                        .foregroundStyle(DSColors.Preview.accent)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: step.size)

                    Text("·")
                        .foregroundStyle(DSColors.Preview.textTertiary)

                    Text(step.weight.rawValue)
                        .font(DSTypography.codeSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }
            }
            .frame(width: 96, alignment: .leading)

            Divider()
                .frame(height: 32)
                .background(DSColors.Preview.borderSubtle)

            // Live text preview
            Text(sampleText)
                .font(previewFont)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: step.size)

            // Expand toggle
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(DSColors.Preview.backgroundTertiary, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.sm)
        .frame(minHeight: 56)
    }

    // MARK: - Expanded Detail Row
    private var detailRow: some View {
        VStack(spacing: DSSpacing.sm) {

            Divider().background(DSColors.Preview.borderSubtle)
                .padding(.horizontal, DSSpacing.sm)

            HStack(spacing: DSSpacing.lg) {

                // Metrics
                metricChip(label: "Size",        value: String(format: "%.1fpt", step.size))
                metricChip(label: "Line Height",  value: String(format: "%.2f×", step.lineHeight))
                metricChip(label: "Line Ht pt",  value: String(format: "%.0fpt", step.lineHeightPt))
                metricChip(label: "Tracking",    value: String(format: "%.2fem", step.tracking))

                Spacer()
            }
            .padding(.horizontal, DSSpacing.sm)

            // Weight picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(FontWeightOption.allCases) { w in
                        weightPill(w)
                    }
                }
                .padding(.horizontal, DSSpacing.sm)
                .padding(.bottom, DSSpacing.sm)
            }
        }
    }

    private func metricChip(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
            Text(value)
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: value)
        }
    }

    private func weightPill(_ w: FontWeightOption) -> some View {
        let isSelected = step.weight == w
        return Button { onWeightChange(w) } label: {
            Text(w.rawValue)
                .font(DSTypography.labelSmall)
                .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                .padding(.horizontal, DSSpacing.xs)
                .padding(.vertical, 4)
                .background(
                    isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceElevated,
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

    // MARK: - Dynamic Font
    private var previewFont: Font {
        let size = step.size
        switch step.weight {
        case .ultraLight: return .system(size: size, weight: .ultraLight)
        case .thin:       return .system(size: size, weight: .thin)
        case .light:      return .system(size: size, weight: .light)
        case .regular:    return .system(size: size, weight: .regular)
        case .medium:     return .system(size: size, weight: .medium)
        case .semibold:   return .system(size: size, weight: .semibold)
        case .bold:       return .system(size: size, weight: .bold)
        case .heavy:      return .system(size: size, weight: .heavy)
        case .black:      return .system(size: size, weight: .black)
        }
    }
}
