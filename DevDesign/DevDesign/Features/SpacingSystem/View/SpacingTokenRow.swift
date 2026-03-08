//
//  SpacingTokenRow.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// One row per spacing token.
// Visual bar width = proportional to value (scaled to max token).
// Tap bar to copy value. Expand to override.

import SwiftUI

struct SpacingTokenRow: View {

    let token: SpacingToken
    let maxValue: Double        // for proportional bar width
    let index: Int
    var isExpanded: Bool
    var onToggleExpand: () -> Void
    var onCopy: () -> Void
    var onSetOverride: (Double) -> Void
    var onClearOverride: () -> Void

    @State private var overrideText: String = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            mainRow
            if isExpanded { expandedRow }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(
                    isExpanded ? DSColors.Preview.accent : DSColors.Preview.borderSubtle,
                    lineWidth: isExpanded ? 1.5 : 1
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
        .onChange(of: isExpanded) { _, expanded in
            if expanded {
                overrideText = SpacingExportService.formatValue(token.resolvedValue)
            } else {
                fieldFocused = false
            }
        }
    }

    // MARK: - Main Row
    private var mainRow: some View {
        HStack(spacing: DSSpacing.sm) {

            // Token name + override badge
            HStack(spacing: 4) {
                Text(".\(token.name)")
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.accent)
                    .frame(width: 52, alignment: .leading)

                if token.isOverridden {
                    Text("custom")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.warning)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(DSColors.Preview.warning.opacity(0.12), in: Capsule())
                }
            }
            .frame(width: token.isOverridden ? 110 : 60, alignment: .leading)

            // Visual bar — proportional width
            GeometryReader { geo in
                let fraction = maxValue > 0 ? min(token.resolvedValue / maxValue, 1.0) : 0
                let barWidth = max(4, geo.size.width * fraction)

                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(DSColors.Preview.backgroundTertiary)
                        .frame(height: 10)

                    // Fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barGradient)
                        .frame(width: barWidth, height: 10)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8),
                                   value: token.resolvedValue)
                }
            }
            .frame(height: 10)

            // Value readout
            Text(SpacingExportService.formatValue(token.resolvedValue) + "pt")
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(width: 44, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.35, dampingFraction: 0.8),
                           value: token.resolvedValue)

            // Quick copy
            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(DSColors.Preview.backgroundTertiary, in: Circle())
            }
            .buttonStyle(.plain)

            // Expand toggle
            Button(action: onToggleExpand) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(DSColors.Preview.backgroundTertiary, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.sm)
    }

    // MARK: - Expanded Row
    private var expandedRow: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {

            Divider().background(DSColors.Preview.borderSubtle)
                .padding(.horizontal, DSSpacing.sm)

            // Description + metrics
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(token.description)
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)

                HStack(spacing: DSSpacing.md) {
                    metricChip(label: "Multiplier",
                               value: "×\(SpacingExportService.formatValue(token.multiplier))")
                    metricChip(label: "Base value",
                               value: "\(SpacingExportService.formatValue(token.value))pt")
                    if token.isOverridden {
                        metricChip(label: "Override",
                                   value: "\(SpacingExportService.formatValue(token.resolvedValue))pt",
                                   accent: true)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.sm)

            // Visual spacer demo — shows what the spacing looks like between two dots
            spacerDemo

            // Override field
            overrideField

            // Clear override button
            if token.isOverridden {
                Button {
                    onClearOverride()
                    fieldFocused = false
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Reset to \(SpacingExportService.formatValue(token.value))pt")
                            .font(DSTypography.labelLarge)
                    }
                    .foregroundStyle(DSColors.Preview.warning)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, DSSpacing.sm)
            }

            Spacer(minLength: DSSpacing.sm)
        }
        .padding(.bottom, DSSpacing.sm)
    }

    // MARK: - Spacer Demo
    // Two dots with a line between them whose length = the token value (capped visually)
    private var spacerDemo: some View {
        HStack(spacing: 0) {
            dotMarker
            Rectangle()
                .fill(DSColors.Preview.accent.opacity(0.3))
                .frame(width: min(CGFloat(token.resolvedValue) * 2, 200), height: 2)
                .animation(.spring(response: 0.4, dampingFraction: 0.8),
                           value: token.resolvedValue)
            dotMarker
            Spacer()

            Text("\(SpacingExportService.formatValue(token.resolvedValue))pt")
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.accent)
        }
        .padding(.horizontal, DSSpacing.sm)
    }

    private var dotMarker: some View {
        Circle()
            .fill(DSColors.Preview.accent)
            .frame(width: 6, height: 6)
    }

    // MARK: - Override Field
    private var overrideField: some View {
        HStack(spacing: DSSpacing.sm) {
            Text("Override")
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)

            HStack(spacing: DSSpacing.xs) {
                TextField("value", text: $overrideText)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($fieldFocused)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .onSubmit { commitOverride() }

                Text("pt")
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(DSColors.Preview.backgroundTertiary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                    .strokeBorder(
                        fieldFocused ? DSColors.Preview.accent : DSColors.Preview.borderSubtle,
                        lineWidth: 1
                    )
            )

            Button("Set") { commitOverride() }
                .font(DSTypography.labelLarge)
                .foregroundStyle(.white)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .background(DSColors.Preview.accent,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))
                .buttonStyle(.plain)
        }
        .padding(.horizontal, DSSpacing.sm)
    }

    private func commitOverride() {
        guard let v = Double(overrideText), v > 0 else { return }
        onSetOverride(v)
        fieldFocused = false
    }

    // MARK: - Helpers
    private func metricChip(label: String, value: String, accent: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
            Text(value)
                .font(DSTypography.codeMedium)
                .foregroundStyle(accent ? DSColors.Preview.warning : DSColors.Preview.textPrimary)
        }
    }

    private var barGradient: LinearGradient {
        LinearGradient(
            colors: [DSColors.Preview.accent.opacity(0.6), DSColors.Preview.accent],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
