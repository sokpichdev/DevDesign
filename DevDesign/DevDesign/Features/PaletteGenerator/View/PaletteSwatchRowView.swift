//
//  PaletteSwatchRowView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// A single color row in the generated palette.
// Shows: swatch · hex/rgb · lock toggle · copy menu

import SwiftUI

struct PaletteSwatchRowView: View {

    let entry: PaletteEntry
    let index: Int
    var onLockToggle: () -> Void
    var onCopy: (ExportFormat) -> Void

    @State private var showCopied: Bool = false
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            mainRow
            if isExpanded { expandedExportRow }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(
                    entry.isLocked
                        ? DSColors.Preview.accent.opacity(0.5)
                        : DSColors.Preview.borderSubtle,
                    lineWidth: entry.isLocked ? 1.5 : 1
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
    }

    // MARK: - Main Row
    private var mainRow: some View {
        HStack(spacing: DSSpacing.md) {

            // Large color swatch
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .fill(entry.color.color)
                .frame(width: 56, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )

            // Color info
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.color.hex)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)

                HStack(spacing: DSSpacing.xs) {
                    let (r, g, b) = entry.color.rgb
                    Text("R \(r)  G \(g)  B \(b)")
                        .font(DSTypography.codeSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }

                let (h, s, l) = entry.color.hsl
                Text("H \(Int(h))°  S \(Int(s))%  L \(Int(l))%")
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            Spacer()

            HStack(spacing: DSSpacing.sm) {

                // Expand / collapse export row
                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(DSColors.Preview.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(DSColors.Preview.backgroundTertiary,
                                    in: Circle())
                }
                .buttonStyle(.plain)

                // Quick copy HEX
                Button {
                    onCopy(.hex)
                    triggerCopied()
                } label: {
                    ZStack {
                        Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(showCopied ? DSColors.Preview.success : DSColors.Preview.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(DSColors.Preview.backgroundTertiary,
                                        in: Circle())
                    }
                }
                .buttonStyle(.plain)

                // Lock toggle
                Button(action: onLockToggle) {
                    Image(systemName: entry.isLocked ? "lock.fill" : "lock.open")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(
                            entry.isLocked ? DSColors.Preview.accent : DSColors.Preview.textTertiary
                        )
                        .frame(width: 32, height: 32)
                        .background(
                            entry.isLocked
                                ? DSColors.Preview.accentMuted
                                : DSColors.Preview.backgroundTertiary,
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DSSpacing.sm)
    }

    // MARK: - Expanded Export Row
    private var expandedExportRow: some View {
        VStack(spacing: 0) {
            Divider()
                .background(DSColors.Preview.borderSubtle)
                .padding(.horizontal, DSSpacing.sm)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(ExportFormat.allCases) { format in
                        exportFormatButton(format)
                    }
                }
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
            }
        }
    }

    private func exportFormatButton(_ format: ExportFormat) -> some View {
        Button {
            onCopy(format)
            triggerCopied()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: format.icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(format.rawValue)
                    .font(DSTypography.labelSmall)
            }
            .foregroundStyle(DSColors.Preview.textSecondary)
            .padding(.horizontal, DSSpacing.xs)
            .padding(.vertical, 5)
            .background(DSColors.Preview.backgroundTertiary,
                        in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers
    private func triggerCopied() {
        withAnimation { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showCopied = false }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        DSColors.Preview.backgroundPrimary.ignoresSafeArea()
        VStack(spacing: DSSpacing.sm) {
            PaletteSwatchRowView(
                entry: PaletteEntry(color: DevColor(hex: "#7B6EF6")!),
                index: 0,
                onLockToggle: {},
                onCopy: { _ in }
            )
            PaletteSwatchRowView(
                entry: PaletteEntry(color: DevColor(hex: "#F6896E")!, isLocked: true),
                index: 1,
                onLockToggle: {},
                onCopy: { _ in }
            )
        }
        .padding()
    }
}
