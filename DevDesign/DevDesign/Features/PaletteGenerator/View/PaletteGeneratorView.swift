//
//  PaletteGeneratorView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//


// PaletteGeneratorView.swift
// DevDesign — Features/PaletteGenerator/PaletteGeneratorView.swift
//
// Main screen for the Palette Generator feature.
// Composes: color picker → harmony selector → swatch list → toolbar

import SwiftUI

struct PaletteGeneratorView: View {

    @State private var viewModel = PaletteGeneratorViewModel()

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Base color input
                    ColorWheelPickerView(
                        devColor: Binding(
                            get: { viewModel.baseColor },
                            set: { viewModel.updateBaseColor($0) }
                        )
                    )

                    // 2. Harmony type strip
                    harmonySection

                    // 3. Generated swatches
                    swatchList

                    // 4. Palette export strip
                    paletteExportStrip

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("Palette Generator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showSaveSheet) {
            SavePaletteSheetView(viewModel: viewModel)
        }
        // Success toast
        .overlay(alignment: .bottom) {
            if viewModel.saveSuccess {
                saveSuccessToast
            }
        }
        .onChange(of: viewModel.saveSuccess) {
            if viewModel.saveSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { viewModel.saveSuccess = false }
                }
            }
        }
    }

    // MARK: - Harmony Section
    private var harmonySection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                Text("Harmony")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Text(viewModel.selectedHarmony.description)
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 180, alignment: .trailing)
            }
            .padding(.horizontal, DSSpacing.xxs)

            // Selector strips needs to break out of screen padding — use negative margin trick
            HarmonyTypeSelectorView(
                selected: Binding(
                    get: { viewModel.selectedHarmony },
                    set: { _ in }
                ),
                onChange: { type in
                    viewModel.selectHarmony(type)
                }
            )
            .padding(.horizontal, -DSSpacing.screenPadding)
        }
    }

    // MARK: - Swatch List
    private var swatchList: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Colors  (\(viewModel.generatedColors.count))")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                if viewModel.generatedColors.contains(where: { $0.isLocked }) {
                    lockHint
                }
            }
            .padding(.horizontal, DSSpacing.xxs)

            ForEach(Array(viewModel.generatedColors.enumerated()), id: \.element.id) { index, entry in
                PaletteSwatchRowView(
                    entry: entry,
                    index: index,
                    onLockToggle: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            viewModel.toggleLock(at: index)
                        }
                    },
                    onCopy: { format in
                        viewModel.copyColor(entry.color, as: format)
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal:   .opacity.combined(with: .scale(scale: 0.95))
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.generatedColors.map(\.id))
    }

    // MARK: - Lock Hint
    private var lockHint: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
                .font(.system(size: 10, weight: .semibold))
            Text("Locked colors persist on regenerate")
                .font(DSTypography.labelSmall)
        }
        .foregroundStyle(DSColors.Preview.accent)
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, 4)
        .background(DSColors.Preview.accentMuted,
                    in: Capsule())
    }

    // MARK: - Palette Export Strip
    private var paletteExportStrip: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Export Palette As")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(.horizontal, DSSpacing.xxs)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach([ExportFormat.swiftUI, .css, .hex, .uiKit], id: \.self) { format in
                        exportPaletteButton(format)
                    }
                }
                .padding(.horizontal, DSSpacing.xxs)
                .padding(.vertical, DSSpacing.xs)
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

    private func exportPaletteButton(_ format: ExportFormat) -> some View {
        Button {
            viewModel.copyPalette(as: format)
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: format.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text("Copy \(format.rawValue)")
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(DSColors.Preview.textPrimary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(DSColors.Preview.surfaceElevated,
                        in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        // Randomise
        ToolbarItem(placement: .topBarLeading) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    viewModel.randomise()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "shuffle")
                    Text("Random")
                        .font(DSTypography.labelLarge)
                }
            }
            .foregroundStyle(DSColors.Preview.textSecondary)
        }

        // Regenerate + Save
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: DSSpacing.sm) {
                // Regenerate (respects locks)
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.regenerate()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .foregroundStyle(DSColors.Preview.textSecondary)

                // Save
                Button {
                    viewModel.showSaveSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bookmark")
                        Text("Save")
                            .font(DSTypography.labelLarge)
                    }
                }
                .foregroundStyle(DSColors.Preview.accent)
            }
        }
    }

    // MARK: - Save Success Toast
    private var saveSuccessToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DSColors.Preview.success)
            Text("Palette saved!")
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(.ultraThinMaterial,
                    in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .padding(.bottom, DSSpacing.xl)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal:   .opacity
        ))
    }
}

// MARK: - Preview
//#Preview {
//    NavigationStack {
//        PaletteGeneratorView()
//    }
//}
