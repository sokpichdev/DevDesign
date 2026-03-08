//
//  GradientBuilderView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI

struct GradientBuilderView: View {

    @State private var viewModel = GradientViewModel()

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Live preview
                    previewCard

                    // 2. Shape picker
                    shapePicker

                    // 3. Type selector
                    typeSelector

                    // 4. Type-specific controls
                    typeControlsCard

                    // 5. Stop editor
                    GradientStopEditor(viewModel: viewModel)

                    // 6. Presets
                    presetsSection

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("Gradient Builder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showExportSheet) {
            GradientExportSheet(viewModel: viewModel)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Preview Card
    private var previewCard: some View {
        ZStack {
            // No .animation(value: viewModel.config) here —
            // gradient AnimatableData crashes when stop colors/positions
            // update faster than SwiftUI can interpolate between frames.
            gradientBackground
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .overlay(alignment: .bottomLeading) { cssPreviewLabel }
    }

    @ViewBuilder
    private var gradientBackground: some View {
        switch viewModel.previewShape {
        case .rectangle:
            Rectangle().fill(currentGradientStyle)
        case .circle:
            ZStack {
                DSColors.Preview.backgroundSecondary
                Circle().fill(currentGradientStyle).frame(width: 170, height: 170)
            }
        case .capsule:
            ZStack {
                DSColors.Preview.backgroundSecondary
                Capsule().fill(currentGradientStyle).frame(width: 220, height: 80)
            }
        case .card:
            ZStack(alignment: .bottom) {
                Rectangle().fill(currentGradientStyle)
                // Card chrome overlay
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.3))
                        .frame(width: 100, height: 10)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white.opacity(0.2))
                        .frame(width: 70, height: 8)
                }
                .padding(DSSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var currentGradientStyle: AnyShapeStyle {
        switch viewModel.config.type {
        case .linear:  return AnyShapeStyle(viewModel.config.linearGradient)
        case .radial:  return AnyShapeStyle(viewModel.config.radialGradient)
        case .angular: return AnyShapeStyle(viewModel.config.angularGradient)
        }
    }

    private var cssPreviewLabel: some View {
        Text(GradientExportService.exportCSS(viewModel.config))
            .font(DSTypography.codeSmall)
            .foregroundStyle(.white.opacity(0.6))
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.bottom, DSSpacing.xs)
    }

    // MARK: - Shape Picker
    private var shapePicker: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(GradientPreviewShape.allCases) { shape in
                let isSelected = viewModel.previewShape == shape
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        viewModel.previewShape = shape
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: shape.icon)
                            .font(.system(size: 11, weight: .semibold))
                        Text(shape.rawValue)
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
        }
    }

    // MARK: - Type Selector
    private var typeSelector: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Gradient Type")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(.horizontal, DSSpacing.xxs)

            HStack(spacing: DSSpacing.xs) {
                ForEach(GradientType.allCases) { type in
                    let isSelected = viewModel.config.type == type
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.setType(type)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                            Text(type.rawValue)
                                .font(DSTypography.labelLarge)
                                .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
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
            }
        }
    }

    // MARK: - Type Controls Card
    @ViewBuilder
    private var typeControlsCard: some View {
        switch viewModel.config.type {
        case .linear:
            linearControls
        case .radial:
            radialControls
        case .angular:
            angularControls
        }
    }

    // Linear: angle dial + quick-pick angles
    private var linearControls: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Angle")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(String(format: "%.0f", viewModel.config.angle))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(DSColors.Preview.accent)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                                   value: viewModel.config.angle)
                    Text("°")
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }

            Slider(value: Binding(
                get: { viewModel.config.angle },
                set: { viewModel.setAngle($0) }
            ), in: 0...360, step: 1)
            .tint(DSColors.Preview.accent)

            // Quick-pick angle buttons
            HStack(spacing: DSSpacing.xs) {
                ForEach([0.0, 45.0, 90.0, 135.0, 180.0, 225.0, 270.0, 315.0], id: \.self) { angle in
                    let isActive = abs(viewModel.config.angle - angle) < 0.5
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.setAngle(angle)
                        }
                    } label: {
                        Text("\(Int(angle))°")
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(isActive ? .white : DSColors.Preview.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .background(
                                isActive ? DSColors.Preview.accent : DSColors.Preview.surfaceElevated,
                                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                            )
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isActive)
                }
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

    // Radial: center + end radius
    private var radialControls: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Radial Controls")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
            }
            controlSlider("Center X", value: Binding(
                get: { viewModel.config.centerX },
                set: { viewModel.setCenter(x: $0, y: viewModel.config.centerY) }
            ), range: 0...1, displayMultiplier: 100, unit: "%")

            controlSlider("Center Y", value: Binding(
                get: { viewModel.config.centerY },
                set: { viewModel.setCenter(x: viewModel.config.centerX, y: $0) }
            ), range: 0...1, displayMultiplier: 100, unit: "%")

            controlSlider("Radius", value: Binding(
                get: { viewModel.config.endRadius },
                set: { viewModel.setEndRadius($0) }
            ), range: 50...400, displayMultiplier: 1, unit: "pt")
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // Angular: center only
    private var angularControls: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Angular Controls")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Text("Conic gradient")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            controlSlider("Center X", value: Binding(
                get: { viewModel.config.centerX },
                set: { viewModel.setCenter(x: $0, y: viewModel.config.centerY) }
            ), range: 0...1, displayMultiplier: 100, unit: "%")

            controlSlider("Center Y", value: Binding(
                get: { viewModel.config.centerY },
                set: { viewModel.setCenter(x: viewModel.config.centerX, y: $0) }
            ), range: 0...1, displayMultiplier: 100, unit: "%")
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func controlSlider(_ label: String, value: Binding<Double>,
                                range: ClosedRange<Double>,
                                displayMultiplier: Double, unit: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 64, alignment: .leading)

            Slider(value: value, in: range)
                .tint(DSColors.Preview.accent)

            let v = value.wrappedValue * displayMultiplier
            Text(v.truncatingRemainder(dividingBy: 1) == 0
                 ? String(format: "%.0f%@", v, unit)
                 : String(format: "%.1f%@", v, unit))
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(width: 48, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: v)
        }
    }

    // MARK: - Presets Section
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Presets")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(.horizontal, DSSpacing.xxs)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DSSpacing.xs),
                    GridItem(.flexible(), spacing: DSSpacing.xs),
                    GridItem(.flexible(), spacing: DSSpacing.xs),
                    GridItem(.flexible(), spacing: DSSpacing.xs),
                ],
                spacing: DSSpacing.xs
            ) {
                ForEach(GradientPreset.allCases) { preset in
                    presetCell(preset)
                }
            }
        }
    }

    private func presetCell(_ preset: GradientPreset) -> some View {
        let isSelected = viewModel.selectedPreset == preset
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.applyPreset(preset)
            }
        } label: {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .fill(presetGradientStyle(preset))
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            .strokeBorder(
                                isSelected ? DSColors.Preview.accent : Color.clear,
                                lineWidth: 2
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

    private func presetGradientStyle(_ preset: GradientPreset) -> AnyShapeStyle {
        // Always show as linear in cells for legibility
        let cfg = preset.config
        return AnyShapeStyle(
            LinearGradient(
                stops: cfg.sortedStops.map(\.gradientStop),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    withAnimation { viewModel.reverseStops() }
                } label: {
                    Label("Reverse Stops", systemImage: "arrow.left.arrow.right")
                }
                Button {
                    withAnimation { viewModel.randomize() }
                } label: {
                    Label("Randomize Colors", systemImage: "dice")
                }
                Divider()
                Button(role: .destructive) {
                    withAnimation { viewModel.reset() }
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
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

// MARK: - Preview
#Preview {
    NavigationStack {
        GradientBuilderView()
    }
}
