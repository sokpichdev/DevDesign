//
//  AnimationControlsView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct AnimationControlsView: View {

    @Bindable var viewModel: AnimationViewModel
    let accentColor: Color

    var body: some View {
        VStack(spacing: DSSpacing.md) {

            // 1. Category + type selector
            typeSelectorCard

            // 2. Parameter sliders
            parametersCard

            // 3. Presets
            presetsSection

            // 4. Repeat / delay options
            repeatCard
        }
    }

    // MARK: - Type Selector
    private var typeSelectorCard: some View {
        VStack(spacing: DSSpacing.sm) {
            // Category tabs
            HStack(spacing: 0) {
                ForEach(AnimationCategory.allCases) { cat in
                    let isSelected = viewModel.selectedCategory == cat
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.selectCategory(cat)
                        }
                    } label: {
                        VStack(spacing: 3) {
                            HStack(spacing: 4) {
                                Image(systemName: cat.icon)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(cat.rawValue)
                                    .font(DSTypography.labelLarge)
                            }
                            .foregroundStyle(isSelected ? accentColor : DSColors.Preview.textTertiary)
                            .padding(.horizontal, DSSpacing.sm)
                            Rectangle()
                                .fill(isSelected ? accentColor : Color.clear)
                                .frame(height: 2)
                                .clipShape(Capsule())
                                .padding(.horizontal, DSSpacing.sm)
                        }
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
                }
            }

            Divider().background(DSColors.Preview.borderSubtle)

            // Type chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(viewModel.filteredTypes) { type in
                        let isSelected = viewModel.config.type == type
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                viewModel.selectType(type)
                                viewModel.replay()
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                        .font(.system(size: 11, weight: .semibold))
                                    Text(type.label)
                                        .font(DSTypography.codeMedium)
                                }
                                .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                            }
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(
                                isSelected ? accentColor : DSColors.Preview.surfaceElevated,
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
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
                    }
                }
            }

            // Selected type description
            Text(viewModel.config.type.description)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.xxs)
                .fixedSize(horizontal: false, vertical: true)
                .transition(.opacity)
                .id(viewModel.config.type.id)
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Parameters Card
    @ViewBuilder
    private var parametersCard: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Parameters")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                // Live code preview badge
                Text(shortCode)
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(.horizontal, DSSpacing.xxs)

            Group {
                switch viewModel.config.type.category {
                case .spring:
                    springParams
                case .easing:
                    easingParams
                case .timing:
                    timingParams
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
            .id(viewModel.config.type.category)
            .animation(.easeInOut(duration: 0.2), value: viewModel.config.type.category)
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // Spring sliders
    private var springParams: some View {
        VStack(spacing: DSSpacing.sm) {
            if viewModel.config.type == .spring || viewModel.config.type == .interactiveSpring {
                paramSlider("response", value: Binding(
                    get: { viewModel.config.response },
                    set: { v in
                        var u = viewModel.config; u.response = v; viewModel.config = u
                    }
                ), range: 0.1...2.0, hint: "0.55")
                paramSlider("dampingFraction", value: Binding(
                    get: { viewModel.config.dampingFraction },
                    set: { v in
                        var u = viewModel.config; u.dampingFraction = v; viewModel.config = u
                    }
                ), range: 0.1...1.5, hint: "0.825")
                paramSlider("blendDuration", value: Binding(
                    get: { viewModel.config.blendDuration },
                    set: { v in
                        var u = viewModel.config; u.blendDuration = v; viewModel.config = u
                    }
                ), range: 0.0...1.0, hint: "0")
            } else if viewModel.config.type == .bouncy || viewModel.config.type == .snappy {
                paramSlider("duration", value: Binding(
                    get: { viewModel.config.duration },
                    set: { v in var u = viewModel.config; u.duration = v; viewModel.config = u }
                ), range: 0.1...2.0, hint: "0.5")
                paramSlider("extraBounce", value: Binding(
                    get: { viewModel.config.bounce },
                    set: { v in var u = viewModel.config; u.bounce = v; viewModel.config = u }
                ), range: 0.0...0.8, hint: "0.25")
            } else {
                // smooth
                paramSlider("duration", value: Binding(
                    get: { viewModel.config.duration },
                    set: { v in var u = viewModel.config; u.duration = v; viewModel.config = u }
                ), range: 0.1...2.0, hint: "0.4")
            }

            // Damping fraction visual indicator (only for .spring)
            if viewModel.config.type == .spring {
                dampingIndicator
            }
        }
    }

    private var dampingIndicator: some View {
        let zeta = viewModel.config.dampingFraction
        let label: String
        let color: Color
        if zeta < 0.5       { label = "Underdamped — oscillates"; color = Color(hex: "#FF6B6B") }
        else if zeta < 0.85 { label = "Lightly damped — subtle bounce"; color = Color(hex: "#FF9F0A") }
        else if zeta < 1.0  { label = "Well-damped — smooth"; color = Color(hex: "#30D158") }
        else                { label = "Overdamped — no oscillation"; color = Color(hex: "#64D2FF") }

        return HStack(spacing: DSSpacing.xs) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(DSTypography.labelSmall)
                .foregroundStyle(color)
            Spacer()
        }
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, 5)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: label)
    }

    // Easing sliders
    private var easingParams: some View {
        paramSlider("duration", value: Binding(
            get: { viewModel.config.duration },
            set: { v in var u = viewModel.config; u.duration = v; viewModel.config = u }
        ), range: 0.05...3.0, hint: "0.35")
    }

    // Timing curve sliders
    private var timingParams: some View {
        VStack(spacing: DSSpacing.sm) {
            paramSlider("duration", value: Binding(
                get: { viewModel.config.duration },
                set: { v in var u = viewModel.config; u.duration = v; viewModel.config = u }
            ), range: 0.05...3.0, hint: "0.35")

            Divider().background(DSColors.Preview.borderSubtle)
            Text("Control Point 1")
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
            paramSlider("c1x", value: Binding(
                get: { viewModel.config.c0x },
                set: { v in var u = viewModel.config; u.c0x = v; viewModel.config = u }
            ), range: 0...1, hint: "0.42")
            paramSlider("c1y", value: Binding(
                get: { viewModel.config.c0y },
                set: { v in var u = viewModel.config; u.c0y = v; viewModel.config = u }
            ), range: 0...1, hint: "0.0")

            Divider().background(DSColors.Preview.borderSubtle)
            Text("Control Point 2")
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
            paramSlider("c2x", value: Binding(
                get: { viewModel.config.c1x },
                set: { v in var u = viewModel.config; u.c1x = v; viewModel.config = u }
            ), range: 0...1, hint: "0.58")
            paramSlider("c2y", value: Binding(
                get: { viewModel.config.c1y },
                set: { v in var u = viewModel.config; u.c1y = v; viewModel.config = u }
            ), range: 0...1, hint: "1.0")

            // Cubic bezier common presets
            Text("Quick presets")
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
            cubicPresets
        }
    }

    private var cubicPresets: some View {
        let presets: [(String, Double, Double, Double, Double)] = [
            ("ease", 0.25, 0.1, 0.25, 1.0),
            ("ease-in", 0.42, 0, 1.0, 1.0),
            ("ease-out", 0, 0, 0.58, 1.0),
            ("ease-in-out", 0.42, 0, 0.58, 1.0),
            ("material", 0.4, 0, 0.2, 1.0),
        ]
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                ForEach(presets, id: \.0) { p in
                    Button {
                        var u = viewModel.config
                        u.c0x = p.1; u.c0y = p.2; u.c1x = p.3; u.c1y = p.4
                        viewModel.config = u
                        viewModel.replay()
                    } label: {
                        Text(p.0)
                            .font(DSTypography.codeMedium)
                            .foregroundStyle(DSColors.Preview.textSecondary)
                            .padding(.horizontal, DSSpacing.xs)
                            .padding(.vertical, 4)
                            .background(DSColors.Preview.surfaceElevated,
                                        in: Capsule())
                            .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Param Slider
    private func paramSlider(_ label: String, value: Binding<Double>,
                              range: ClosedRange<Double>, hint: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 100, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Slider(value: value, in: range)
                .tint(accentColor)
                .onChange(of: value.wrappedValue) { _, _ in
                    viewModel.selectedPreset = nil
                }

            Text(String(format: "%.2f", value.wrappedValue))
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(width: 40, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: value.wrappedValue)
        }
    }

    // MARK: - Presets
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Presets")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(.horizontal, DSSpacing.xxs)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.sm) {
                    ForEach(AnimationPresetLibrary.all) { preset in
                        let isActive = viewModel.selectedPreset?.id == preset.id
                        Button {
                            viewModel.applyPreset(preset)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: preset.icon)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(isActive ? .white : accentColor)
                                    Text(preset.name)
                                        .font(DSTypography.labelLarge)
                                        .foregroundStyle(isActive ? .white : DSColors.Preview.textPrimary)
                                }
                                Text(preset.config.type.label)
                                    .font(DSTypography.codeSmall)
                                    .foregroundStyle(isActive ? .white.opacity(0.7) : DSColors.Preview.textTertiary)
                            }
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(
                                isActive ? accentColor : DSColors.Preview.surfaceDefault,
                                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                                    .strokeBorder(
                                        isActive ? Color.clear : DSColors.Preview.borderSubtle,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isActive)
                    }
                }
            }
        }
    }

    // MARK: - Repeat / Delay Card
    private var repeatCard: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Repeat & Delay")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
            }
            .padding(.horizontal, DSSpacing.xxs)

            // Delay
            paramSlider("delay", value: Binding(
                get: { viewModel.config.delay },
                set: { v in var u = viewModel.config; u.delay = v; viewModel.config = u }
            ), range: 0...2.0, hint: "0")

            Divider().background(DSColors.Preview.borderSubtle)

            // Repeat count
            HStack(spacing: DSSpacing.sm) {
                Text("Repeat")
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                    .frame(width: 100, alignment: .leading)

                Picker("", selection: Binding(
                    get: { viewModel.config.repeatCount },
                    set: { v in var u = viewModel.config; u.repeatCount = v; viewModel.config = u }
                )) {
                    Text("1×").tag(1)
                    Text("2×").tag(2)
                    Text("3×").tag(3)
                    Text("∞").tag(0)
                }
                .pickerStyle(.segmented)
            }

            // Autoreverse
            HStack(spacing: DSSpacing.sm) {
                Text("Autoreverse")
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                    .frame(width: 100, alignment: .leading)
                Toggle("", isOn: Binding(
                    get: { viewModel.config.autoreverses },
                    set: { v in var u = viewModel.config; u.autoreverses = v; viewModel.config = u }
                ))
                .labelsHidden()
                .tint(accentColor)
                Spacer()
                if viewModel.config.repeatCount == 0 || viewModel.config.repeatCount > 1 {
                    Text(viewModel.config.autoreverses ? "Ping-pong" : "One-way")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
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

    // MARK: - Helpers
    private var shortCode: String {
        switch viewModel.config.type {
        case .spring:
            return "r:\(AnimationExportService.f(viewModel.config.response)) d:\(AnimationExportService.f(viewModel.config.dampingFraction))"
        case .easeInOut, .easeIn, .easeOut, .linear:
            return "\(AnimationExportService.f(viewModel.config.duration))s"
        case .bouncy, .smooth, .snappy:
            return "\(AnimationExportService.f(viewModel.config.duration))s b:\(AnimationExportService.f(viewModel.config.bounce))"
        default:
            return "\(AnimationExportService.f(viewModel.config.duration))s"
        }
    }
}
