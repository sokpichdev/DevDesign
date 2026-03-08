//
//  PaletteDetailView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Full detail screen for a saved palette.
// Shows: large swatch strip, harmony badge, each color row with copy actions.

import SwiftUI

struct PaletteDetailView: View {

    let palette: SavedPalette
    @Bindable var viewModel: SavedPalettesViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var copiedHex: String? = nil

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // Large swatch strip
                    swatchStrip

                    // Metadata row
                    metadataRow

                    // Color list
                    colorList

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle(palette.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: Binding(
            get: { viewModel.paletteToExport?.id == palette.id },
            set: { if !$0 { viewModel.paletteToExport = nil } }
        )) {
            PaletteExportSheet(palette: palette, viewModel: viewModel)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Swatch Strip
    private var swatchStrip: some View {
        HStack(spacing: 0) {
            ForEach(palette.colors, id: \.id) { color in
                Rectangle()
                    .fill(Color(red: color.red, green: color.green, blue: color.blue))
            }
        }
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Metadata Row
    private var metadataRow: some View {
        HStack(spacing: DSSpacing.sm) {

            // Harmony badge
            Label(palette.harmonyType, systemImage: "circle.grid.3x3")
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.accent)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xxs)
                .background(DSColors.Preview.accentMuted, in: Capsule())

            // Color count
            Label("\(palette.colors.count) colors", systemImage: "swatchpalette")
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xxs)
                .background(DSColors.Preview.surfaceElevated, in: Capsule())
                .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))

            Spacer()

            // Date saved
            Text(palette.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
        }
    }

    // MARK: - Color List
    private var colorList: some View {
        VStack(spacing: DSSpacing.xs) {
            ForEach(palette.colors, id: \.id) { savedColor in
                colorRow(savedColor)
            }
        }
    }

    private func colorRow(_ savedColor: SavedColor) -> some View {
        let devColor = DevColor(red: savedColor.red, green: savedColor.green,
                               blue: savedColor.blue, alpha: savedColor.alpha)
        let isCopied = copiedHex == savedColor.hex

        return HStack(spacing: DSSpacing.md) {

            // Swatch
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .fill(devColor.color)
                .frame(width: 52, height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .strokeBorder(DSColors.Preview.borderDefault, lineWidth: 1)
                )

            // Color values
            VStack(alignment: .leading, spacing: 3) {
                Text(savedColor.hex)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)

                let (r, g, b) = devColor.rgb
                Text("R \(r)  G \(g)  B \(b)")
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)

                let (h, s, l) = devColor.hsl
                Text("H \(Int(h))°  S \(Int(s))%  L \(Int(l))%")
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            Spacer()

            // Quick copy HEX
            Button {
                UIPasteboard.general.string = savedColor.hex
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    copiedHex = savedColor.hex
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { copiedHex = nil }
                }
            } label: {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isCopied ? DSColors.Preview.success : DSColors.Preview.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        isCopied
                            ? DSColors.Preview.success.opacity(0.12)
                            : DSColors.Preview.backgroundTertiary,
                        in: Circle()
                    )
                    .contentTransition(.symbolEffect(.replace))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCopied)
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.paletteToExport = palette
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                        .font(DSTypography.labelLarge)
                }
            }
            .foregroundStyle(DSColors.Preview.accent)
        }
    }

    // MARK: - Toast
    private var copiedToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DSColors.Preview.success)
            Text("Copied!")
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
        .padding(.bottom, DSSpacing.xl)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        ))
    }
}
