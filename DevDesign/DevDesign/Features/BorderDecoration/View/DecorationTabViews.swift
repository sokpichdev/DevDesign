//
//  DecorationTabViews.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - Corners Tab
// ─────────────────────────────────────────────────────────────

struct CornersTabView: View {
    @Bindable var vm: BorderDecorationViewModel
    private let accent = Color(hex: "#FF9F0A")

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            presetsRow(DecorationPresetLibrary.corners)
            styleCard
            radiusCard
            perCornerCard
            referenceCard
        }
    }

    // MARK: Style
    private var styleCard: some View {
        controlCard(title: "Corner Style") {
            HStack(spacing: DSSpacing.xs) {
                ForEach(CornerStyle.allCases) { style in
                    let isSel = vm.cornerConfig.style == style
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            vm.cornerConfig.style = style
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: style.icon)
                                .font(.system(size: 15, weight: .medium))
                            Text(style.rawValue)
                                .font(DSTypography.labelSmall)
                        }
                        .foregroundStyle(isSel ? .white : DSColors.Preview.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.xs)
                        .background(isSel ? accent : DSColors.Preview.surfaceElevated,
                                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                        .overlay(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            .strokeBorder(isSel ? .clear : DSColors.Preview.borderSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSel)
                }
            }
        }
    }

    // MARK: Radius
    private var radiusCard: some View {
        controlCard(title: "Radius") {
            VStack(spacing: DSSpacing.sm) {
                HStack(spacing: DSSpacing.sm) {
                    Slider(value: $vm.cornerConfig.radius, in: 0...80)
                        .tint(accent)
                    Text("\(Int(vm.cornerConfig.radius))pt")
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .frame(width: 40, alignment: .trailing)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.2, dampingFraction: 0.8),
                                   value: vm.cornerConfig.radius)
                }

                // Quick-tap reference values
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.xs) {
                        ForEach([0, 8, 12, 14, 16, 20, 27, 40], id: \.self) { val in
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    vm.cornerConfig.radius = CGFloat(val)
                                }
                            } label: {
                                Text("\(val)")
                                    .font(DSTypography.codeMedium)
                                    .foregroundStyle(
                                        Int(vm.cornerConfig.radius) == val
                                            ? .white : DSColors.Preview.textSecondary
                                    )
                                    .padding(.horizontal, DSSpacing.xs)
                                    .padding(.vertical, 4)
                                    .background(
                                        Int(vm.cornerConfig.radius) == val
                                            ? accent : DSColors.Preview.surfaceElevated,
                                        in: Capsule()
                                    )
                                    .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Fill color
                colorRow("Fill", binding: $vm.cornerConfig.fillColor)
            }
        }
    }

    // MARK: Per-corner
    private var perCornerCard: some View {
        controlCard(title: "Per-Corner Radius") {
            VStack(spacing: DSSpacing.sm) {
                HStack {
                    Toggle("Independent corners", isOn: $vm.cornerConfig.perCorner)
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                        .tint(accent)
                }
                if vm.cornerConfig.perCorner {
                    Group {
                        cornerSlider("Top Leading",     value: $vm.cornerConfig.topLeading)
                        cornerSlider("Top Trailing",    value: $vm.cornerConfig.topTrailing)
                        cornerSlider("Bottom Leading",  value: $vm.cornerConfig.bottomLeading)
                        cornerSlider("Bottom Trailing", value: $vm.cornerConfig.bottomTrailing)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8),
                       value: vm.cornerConfig.perCorner)
        }
    }

    private func cornerSlider(_ label: String, value: Binding<CGFloat>) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 100, alignment: .leading)
            Slider(value: value, in: 0...80)
                .tint(accent)
            Text("\(Int(value.wrappedValue))")
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(width: 30, alignment: .trailing)
                .contentTransition(.numericText())
        }
    }

    // MARK: Reference
    private var referenceCard: some View {
        controlCard(title: "iOS Reference") {
            VStack(spacing: 0) {
                ForEach(Array(cornerReferences.enumerated()), id: \.element.id) { i, ref in
                    HStack(spacing: DSSpacing.sm) {
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                vm.cornerConfig.radius = ref.radius
                            }
                        } label: {
                            HStack(spacing: DSSpacing.sm) {
                                Text(ref.label)
                                    .font(DSTypography.labelLarge)
                                    .foregroundStyle(DSColors.Preview.textPrimary)
                                Spacer()
                                Text("\(Int(ref.radius))pt")
                                    .font(DSTypography.codeMedium)
                                    .foregroundStyle(accent)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 10)
                    if i < cornerReferences.count - 1 {
                        Divider().background(DSColors.Preview.borderSubtle)
                    }
                }
            }
            .background(DSColors.Preview.backgroundSecondary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Borders Tab
// ─────────────────────────────────────────────────────────────

struct BordersTabView: View {
    @Bindable var vm: BorderDecorationViewModel
    private let accent = Color(hex: "#7B6EF6")

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            presetsRow(DecorationPresetLibrary.borders)
            styleCard
            widthCard
            if vm.borderConfig.styleType == .gradient { gradientCard }
            if vm.borderConfig.styleType == .dashed || vm.borderConfig.styleType == .dotted { dashCard }
            if vm.borderConfig.styleType == .double_ { doubleCard }
            cornerRadiusRow
        }
    }

    private var styleCard: some View {
        controlCard(title: "Border Style") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DSSpacing.xs), count: 3),
                      spacing: DSSpacing.xs) {
                ForEach(BorderStyleType.allCases) { style in
                    let isSel = vm.borderConfig.styleType == style
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            vm.borderConfig.styleType = style
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: style.icon)
                                .font(.system(size: 16, weight: .medium))
                            Text(style.rawValue)
                                .font(DSTypography.labelSmall)
                        }
                        .foregroundStyle(isSel ? .white : DSColors.Preview.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.xs)
                        .background(isSel ? accent : DSColors.Preview.surfaceElevated,
                                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                        .overlay(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            .strokeBorder(isSel ? .clear : DSColors.Preview.borderSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSel)
                }
            }
        }
    }

    private var widthCard: some View {
        controlCard(title: "Appearance") {
            VStack(spacing: DSSpacing.sm) {
                labeledSlider("Width", value: $vm.borderConfig.width,
                              range: 0.5...12, unit: "px", accent: accent)
                labeledSlider("Opacity", value: $vm.borderConfig.opacity,
                              range: 0...1, unit: "", accent: accent, decimals: 2)
                if vm.borderConfig.styleType != .gradient {
                    colorRow("Color", binding: $vm.borderConfig.color)
                }
            }
        }
    }

    private var gradientCard: some View {
        controlCard(title: "Gradient Colors") {
            VStack(spacing: DSSpacing.sm) {
                colorRow("From", binding: $vm.borderConfig.gradientStart)
                colorRow("To",   binding: $vm.borderConfig.gradientEnd)
            }
        }
    }

    private var dashCard: some View {
        controlCard(title: "Dash Pattern") {
            VStack(spacing: DSSpacing.sm) {
                labeledSlider("Length", value: $vm.borderConfig.dashLength,
                              range: 1...40, unit: "pt", accent: accent)
                labeledSlider("Gap", value: $vm.borderConfig.dashGap,
                              range: 1...40, unit: "pt", accent: accent)
            }
        }
    }

    private var doubleCard: some View {
        controlCard(title: "Double Border") {
            VStack(spacing: DSSpacing.sm) {
                labeledSlider("Line Width", value: $vm.borderConfig.doubleInnerWidth,
                              range: 0.5...6, unit: "px", accent: accent)
                labeledSlider("Gap", value: $vm.borderConfig.doubleGap,
                              range: 1...12, unit: "pt", accent: accent)
            }
        }
    }

    private var cornerRadiusRow: some View {
        controlCard(title: "Corner Radius") {
            labeledSlider("Radius", value: $vm.borderConfig.cornerRadius,
                          range: 0...60, unit: "pt", accent: accent)
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Glow Tab
// ─────────────────────────────────────────────────────────────

struct GlowTabView: View {
    @Bindable var vm: BorderDecorationViewModel
    private let accent = Color(hex: "#BF5AF2")

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            presetsRow(DecorationPresetLibrary.glows)
            typeCard
            paramsCard
            colorCard
        }
    }

    private var typeCard: some View {
        controlCard(title: "Glow Type") {
            VStack(spacing: DSSpacing.sm) {
                ForEach(GlowType.allCases) { type in
                    let isSel = vm.glowConfig.type == type
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            vm.glowConfig.type = type
                        }
                    } label: {
                        HStack(spacing: DSSpacing.sm) {
                            Image(systemName: type.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(isSel ? .white : accent)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.rawValue)
                                    .font(DSTypography.labelLarge)
                                    .foregroundStyle(isSel ? .white : DSColors.Preview.textPrimary)
                                Text(type.description)
                                    .font(DSTypography.labelSmall)
                                    .foregroundStyle(isSel ? .white.opacity(0.7) : DSColors.Preview.textTertiary)
                            }
                            Spacer()
                            if isSel {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(DSSpacing.sm)
                        .background(isSel ? accent : DSColors.Preview.surfaceElevated,
                                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                        .overlay(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            .strokeBorder(isSel ? .clear : DSColors.Preview.borderSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSel)
                }
            }
        }
    }

    private var paramsCard: some View {
        controlCard(title: "Parameters") {
            VStack(spacing: DSSpacing.sm) {
                labeledSlider("Radius", value: $vm.glowConfig.radius,
                              range: 2...60, unit: "pt", accent: accent)
                labeledSlider("Opacity", value: $vm.glowConfig.opacity,
                              range: 0...1, unit: "", accent: accent, decimals: 2)
                if vm.glowConfig.type != .inner && vm.glowConfig.type != .neon
                    && vm.glowConfig.type != .layered {
                    labeledSlider("Offset X", value: $vm.glowConfig.offsetX,
                                  range: -30...30, unit: "pt", accent: accent)
                    labeledSlider("Offset Y", value: $vm.glowConfig.offsetY,
                                  range: -30...30, unit: "pt", accent: accent)
                }
                labeledSlider("Corner Radius", value: $vm.glowConfig.cornerRadius,
                              range: 0...60, unit: "pt", accent: accent)
            }
        }
    }

    private var colorCard: some View {
        controlCard(title: "Colors") {
            VStack(spacing: DSSpacing.sm) {
                colorRow("Glow",  binding: $vm.glowConfig.color)
                colorRow("Fill",  binding: $vm.glowConfig.fillColor)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Patterns Tab
// ─────────────────────────────────────────────────────────────

struct PatternsTabView: View {
    @Bindable var vm: BorderDecorationViewModel
    private let accent = Color(hex: "#30D158")

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            presetsRow(DecorationPresetLibrary.patterns)
            typeCard
            paramsCard
            colorCard
        }
    }

    private var typeCard: some View {
        controlCard(title: "Pattern Type") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DSSpacing.xs), count: 3),
                      spacing: DSSpacing.xs) {
                ForEach(OverlayPatternType.allCases) { type in
                    let isSel = vm.patternConfig.patternType == type
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            vm.patternConfig.patternType = type
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: type.icon)
                                .font(.system(size: 16, weight: .medium))
                            Text(type.rawValue)
                                .font(DSTypography.labelSmall)
                        }
                        .foregroundStyle(isSel ? .white : DSColors.Preview.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.xs)
                        .background(isSel ? accent : DSColors.Preview.surfaceElevated,
                                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                        .overlay(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            .strokeBorder(isSel ? .clear : DSColors.Preview.borderSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSel)
                }
            }
        }
    }

    private var paramsCard: some View {
        controlCard(title: "Parameters") {
            VStack(spacing: DSSpacing.sm) {
                labeledSlider("Scale", value: $vm.patternConfig.scale,
                              range: 4...60, unit: "pt", accent: accent)
                labeledSlider("Line Width", value: $vm.patternConfig.lineWidth,
                              range: 0.5...6, unit: "px", accent: accent)
                labeledSlider("Opacity", value: $vm.patternConfig.opacity,
                              range: 0...1, unit: "", accent: accent, decimals: 2)
                if vm.patternConfig.patternType == .stripes
                    || vm.patternConfig.patternType == .crosshatch {
                    labeledSlider("Angle", value: $vm.patternConfig.rotation,
                                  range: -90...90, unit: "°", accent: accent)
                }
                labeledSlider("Corner Radius", value: $vm.patternConfig.cornerRadius,
                              range: 0...60, unit: "pt", accent: accent)
            }
        }
    }

    private var colorCard: some View {
        controlCard(title: "Colors") {
            VStack(spacing: DSSpacing.sm) {
                colorRow("Pattern", binding: $vm.patternConfig.color)
                colorRow("Fill",    binding: $vm.patternConfig.fillColor)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Shared helpers
// ─────────────────────────────────────────────────────────────

private func controlCard<Content: View>(title: String,
                                        @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
        Text(title)
            .font(DSTypography.headingSmall)
            .foregroundStyle(DSColors.Preview.textPrimary)
            .padding(.horizontal, DSSpacing.xxs)
        content()
    }
    .padding(DSSpacing.cardPadding)
    .background(DSColors.Preview.surfaceDefault,
                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
    .overlay(
        RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
            .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
    )
}

private func presetsRow(_ presets: [DecorationPreset]) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: DSSpacing.sm) {
            ForEach(presets) { preset in
                _PresetChip(preset: preset)
            }
        }
    }
}

// Helper wrapping view so we can @Environment the vm
private struct _PresetChip: View {
    let preset: DecorationPreset
    @Environment(BorderDecorationViewModel.self) private var vm

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                vm.applyPreset(preset)
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: preset.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(preset.name)
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(DSColors.Preview.textSecondary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(DSColors.Preview.surfaceDefault, in: Capsule())
            .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private func colorRow(_ label: String, binding: Binding<Color>) -> some View {
    HStack(spacing: DSSpacing.sm) {
        Text(label)
            .font(DSTypography.labelLarge)
            .foregroundStyle(DSColors.Preview.textSecondary)
            .frame(width: 52, alignment: .leading)
        let colorBinding = Binding<Color>(
            get: { binding.wrappedValue },
            set: { binding.wrappedValue = $0 }
        )
        ColorPicker("", selection: colorBinding, supportsOpacity: true)
            .labelsHidden()
            .frame(width: 44, height: 32)
        Text(hexString(binding.wrappedValue))
            .font(DSTypography.codeMedium)
            .foregroundStyle(DSColors.Preview.textPrimary)
        Spacer()
    }
}

private func labeledSlider(_ label: String, value: Binding<CGFloat>,
                            range: ClosedRange<CGFloat>, unit: String,
                            accent: Color, decimals: Int = 0) -> some View {
    HStack(spacing: DSSpacing.sm) {
        Text(label)
            .font(DSTypography.labelLarge)
            .foregroundStyle(DSColors.Preview.textSecondary)
            .frame(width: 80, alignment: .leading)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        Slider(value: value, in: range)
            .tint(accent)
        let formatted = decimals == 0
            ? "\(Int(value.wrappedValue))\(unit)"
            : String(format: "%.2f", value.wrappedValue) + unit
        Text(formatted)
            .font(DSTypography.codeMedium)
            .foregroundStyle(DSColors.Preview.textPrimary)
            .frame(width: 44, alignment: .trailing)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: value.wrappedValue)
    }
}

private func labeledSlider(_ label: String, value: Binding<Double>,
                            range: ClosedRange<Double>, unit: String,
                            accent: Color, decimals: Int = 0) -> some View {
    let cgBinding = Binding<CGFloat>(
        get: { CGFloat(value.wrappedValue) },
        set: { value.wrappedValue = Double($0) }
    )
    return labeledSlider(label, value: cgBinding,
                         range: CGFloat(range.lowerBound)...CGFloat(range.upperBound),
                         unit: unit, accent: accent, decimals: decimals)
}

private func hexString(_ color: Color) -> String {
    let ui = UIColor(color)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    ui.getRed(&r, green: &g, blue: &b, alpha: &a)
    return "#" + String(format: "%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
}
