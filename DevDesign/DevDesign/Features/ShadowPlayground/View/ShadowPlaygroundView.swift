//
//  ShadowPlaygroundView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI

struct ShadowPlaygroundView: View {

    @State private var viewModel = ShadowViewModel()

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Preview card
                    previewSection

                    // 2. Preset strip
                    presetSection

                    // 3. Preview target picker
                    targetSection

                    // 4. Layer list
                    layerSection

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("Shadow Playground")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ShadowExportSheet(viewModel: viewModel)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
        .onAppear {
            viewModel.selectedLayerID = viewModel.layers.first?.id
        }
    }

    // MARK: - Preview Section
    private var previewSection: some View {
        ShadowPreviewCard(
            layers: viewModel.layers,
            target: viewModel.previewTarget,
            isDark: viewModel.isDarkBackground,
            onToggleDark: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.isDarkBackground.toggle()
                }
            }
        )
    }

    // MARK: - Preset Section
    private var presetSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Presets")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(.horizontal, DSSpacing.xxs)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(ShadowPreset.allCases.filter { $0 != .custom }) { preset in
                        presetButton(preset)
                    }
                }
                .padding(.vertical, DSSpacing.xs)
            }
        }
    }

    private func presetButton(_ preset: ShadowPreset) -> some View {
        let isSelected = viewModel.selectedPreset == preset
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.applyPreset(preset)
            }
        } label: {
            VStack(spacing: DSSpacing.xs) {
                // Mini shadow swatch
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: 0.2))
                    .frame(width: 48, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white.opacity(0.9))
                            .frame(width: 26, height: 18)
                            .modifier(PresetShadowPreview(preset: preset))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                isSelected ? DSColors.Preview.accent : Color.clear,
                                lineWidth: 1.5
                            )
                    )

                Text(preset.rawValue)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(isSelected ? DSColors.Preview.accent : DSColors.Preview.textTertiary)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }

    // MARK: - Target Section
    private var targetSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Preview Target")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(.horizontal, DSSpacing.xxs)

            HStack(spacing: DSSpacing.xs) {
                ForEach(ShadowPreviewTarget.allCases) { target in
                    targetButton(target)
                }
            }
        }
    }

    private func targetButton(_ target: ShadowPreviewTarget) -> some View {
        let isSelected = viewModel.previewTarget == target
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.previewTarget = target
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: target.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(target.rawValue)
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.xs)
            .background(
                isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceDefault,
                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(
                        isSelected ? Color.clear : DSColors.Preview.borderSubtle,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }

    // MARK: - Layer Section
    private var layerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Shadow Layers")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)

                Text("\(viewModel.layers.count)/4")
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, 2)
                    .background(DSColors.Preview.backgroundTertiary, in: Capsule())

                Spacer()

                if viewModel.layers.count < 4 {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.addLayer()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text("Add Layer")
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(DSColors.Preview.accent)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xxs)
                        .background(DSColors.Preview.accent.opacity(0.12), in: Capsule())
                        .overlay(
                            Capsule().strokeBorder(DSColors.Preview.accent.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSSpacing.xxs)

            ForEach(Array(viewModel.layers.enumerated()), id: \.element.id) { index, layer in
                ShadowLayerRow(
                    layer: layer,
                    index: index,
                    isSelected: viewModel.selectedLayerID == layer.id,
                    onSelect: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.selectedLayerID = viewModel.selectedLayerID == layer.id
                                ? nil : layer.id
                        }
                    },
                    onToggleEnabled: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.toggleEnabled(at: index)
                        }
                    },
                    onToggleInner: {
                        viewModel.toggleInner(at: index)
                    },
                    onUpdate: { transform in
                        viewModel.updateLayer(at: index, transform: transform)
                    },
                    onDuplicate: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.duplicateLayer(at: index)
                        }
                    },
                    onDelete: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.removeLayer(at: index)
                        }
                    }
                )
            }

            // Inner shadow note
            if viewModel.hasInnerLayer {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                    Text("Inner shadows are simulated in SwiftUI using a stroke overlay. The exported code includes the implementation.")
                        .font(DSTypography.labelSmall)
                }
                .foregroundStyle(DSColors.Preview.textTertiary)
                .padding(DSSpacing.sm)
                .background(DSColors.Preview.backgroundTertiary,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.resetToDefault()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                        .font(DSTypography.labelLarge)
                }
                .foregroundStyle(DSColors.Preview.textSecondary)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.showExportSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                        .font(DSTypography.labelLarge)
                }
                .foregroundStyle(DSColors.Preview.accent)
            }
        }
    }

    // MARK: - Toast
    private var copiedToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DSColors.Preview.success)
            Text(viewModel.copiedLabel + " copied!")
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

// MARK: - Preset Shadow Preview Modifier
// Applies a quick representative shadow on preset swatches

struct PresetShadowPreview: ViewModifier {
    let preset: ShadowPreset

    func body(content: Content) -> some View {
        let layers = preset.layers()
        return content.modifier(
            ShadowStackModifier(layers: layers, cornerRadius: 5)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ShadowPlaygroundView()
    }
}
