//
//  ColorPickerView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Full Color Picker screen:
//   1. Live color preview (dark + light context)
//   2. ColorWheelPickerView (reused from Palette Generator)
//   3. CodePreviewPanelView (format tabs + copy)
//   4. Recent colors strip

import SwiftUI

struct ColorPickerView: View {

    @State private var viewModel = ColorPickerViewModel()

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Live color preview
                    colorPreviewCard

                    // 2. Color input picker (reused component)
                    ColorWheelPickerView(
                        devColor: Binding(
                            get: { viewModel.selectedColor },
                            set: { viewModel.selectColor($0) }
                        ),
                        forceSyncTrigger: viewModel.forceSyncTrigger
                    )

                    // 3. Code export panel
                    sectionHeader("Code Export")
                    CodePreviewPanelView(viewModel: viewModel)

                    // 4. All formats quick-copy strip
                    quickCopyStrip

                    // 5. Recent colors
                    if !viewModel.recentColors.isEmpty {
                        recentColorsSection
                    }

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("Color Picker")
        .navigationBarTitleDisplayMode(.inline)
        // Copied toast overlay
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedFeedback { copiedToast }
        }
    }

    // MARK: - Color Preview Card
    // Shows the selected color in both dark and light UI context
    private var colorPreviewCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {

                // Dark context
                ZStack {
                    Color(hex: "#0E0E10")
                    previewLabel(viewModel.selectedColor)
                }
                .frame(maxWidth: .infinity)

                // Light context
                ZStack {
                    Color.white
                    previewLabel(viewModel.selectedColor)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedColor.hex)

            // Context labels
            HStack {
                Text("Dark context")
                    .frame(maxWidth: .infinity)
                Divider().frame(height: 12)
                Text("Light context")
                    .frame(maxWidth: .infinity)
            }
            .font(DSTypography.labelSmall)
            .foregroundStyle(DSColors.Preview.textTertiary)
            .padding(.top, DSSpacing.xs)
        }
    }

    private func previewLabel(_ color: DevColor) -> some View {
        VStack(spacing: DSSpacing.xs) {
            // The selected color itself as a large swatch
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .fill(color.color)
                .frame(width: 48, height: 48)
                .shadow(color: color.color.opacity(0.4), radius: 8, y: 4)
                .animation(.easeInOut(duration: 0.2), value: color.hex)
        }
    }

    // MARK: - Quick Copy Strip
    // One button per format — copy without changing the active tab
    private var quickCopyStrip: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            sectionHeader("Quick Copy")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(ExportFormat.allCases) { format in
                        quickCopyButton(format)
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

    private func quickCopyButton(_ format: ExportFormat) -> some View {
        let isCopied = viewModel.showCopiedFeedback && viewModel.copiedFormat == format

        return Button { viewModel.copy(as: format) } label: {
            HStack(spacing: 4) {
                Image(systemName: isCopied ? "checkmark" : format.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))
                Text(isCopied ? "Copied" : format.rawValue)
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(
                isCopied ? DSColors.Preview.success : DSColors.Preview.textSecondary
            )
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(
                isCopied
                    ? DSColors.Preview.success.opacity(0.12)
                    : DSColors.Preview.surfaceElevated,
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isCopied
                            ? DSColors.Preview.success.opacity(0.3)
                            : DSColors.Preview.borderSubtle,
                        lineWidth: 1
                    )
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCopied)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent Colors Section
    private var recentColorsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {

            HStack {
                sectionHeader("Recent")
                Spacer()
                Button("Clear") { viewModel.clearRecent() }
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(viewModel.recentColors, id: \.hex) { color in
                        recentSwatch(color)
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

    private func recentSwatch(_ color: DevColor) -> some View {
        Button { viewModel.selectRecentColor(color) } label: {
            VStack(spacing: 4) {
                Circle()
                    .fill(color.color)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                viewModel.selectedColor.hex == color.hex
                                    ? DSColors.Preview.accent
                                    : DSColors.Preview.borderSubtle,
                                lineWidth: viewModel.selectedColor.hex == color.hex ? 2 : 1
                            )
                    )
                    .shadow(color: color.color.opacity(0.3), radius: 4, y: 2)

                Text(color.hex)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .frame(width: 52)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal:   .scale(scale: 0.8).combined(with: .opacity)
        ))
    }

    // MARK: - Copied Toast
    private var copiedToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DSColors.Preview.success)
            Text("\(viewModel.copiedFormat?.rawValue ?? "") copied!")
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
            removal:   .opacity
        ))
    }

    // MARK: - Shared section header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(DSTypography.headingSmall)
            .foregroundStyle(DSColors.Preview.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ColorPickerView()
    }
}
