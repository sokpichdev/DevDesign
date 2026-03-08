//
//  SavePaletteSheetView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Bottom sheet for naming and saving the current palette.

import SwiftUI
import SwiftData

struct SavePaletteSheetView: View {

    @Bindable var viewModel: PaletteGeneratorViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var nameFieldFocused: Bool = false
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: DSSpacing.xl) {

                    // Mini palette preview
                    palettePreview

                    // Name input
                    nameInput

                    // Export format hint
                    exportHint

                    Spacer()

                    // Save button
                    saveButton
                }
                .padding(DSSpacing.screenPadding)
            }
            .navigationTitle("Save Palette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }

    // MARK: - Palette Preview
    private var palettePreview: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(viewModel.generatedColors) { entry in
                RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                    .fill(entry.color.color)
                    .frame(height: 48)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .padding(.top, DSSpacing.sm)
    }

    // MARK: - Name Input
    private var nameInput: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Palette Name")
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)

            HStack {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundStyle(DSColors.Preview.textTertiary)

                TextField("e.g. Ocean Sunset", text: $viewModel.paletteName)
                    .font(DSTypography.bodyMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .focused($focused)
                    .onAppear { focused = true }

                if !viewModel.paletteName.isEmpty {
                    Button {
                        viewModel.paletteName = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.surfaceElevated,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(
                        focused ? DSColors.Preview.accent.opacity(0.6) : DSColors.Preview.borderSubtle,
                        lineWidth: focused ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focused)
        }
    }

    // MARK: - Export Hint
    private var exportHint: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "info.circle")
                .font(.system(size: 12))
            Text("You can export this palette as SwiftUI, CSS, or JSON from Saved Palettes.")
                .font(DSTypography.bodySmall)
        }
        .foregroundStyle(DSColors.Preview.textTertiary)
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            savePalette()
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "bookmark.fill")
                Text("Save Palette")
                    .font(DSTypography.headingSmall)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.Preview.accent,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.paletteName.trimmingCharacters(in: .whitespaces).isEmpty)
        .opacity(viewModel.paletteName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
    }

    // MARK: - Save Action
    private func savePalette() {
        let palette = viewModel.buildSavedPalette()
        modelContext.insert(palette)
        try? modelContext.save()
        viewModel.saveSuccess = true
        dismiss()
    }
}
