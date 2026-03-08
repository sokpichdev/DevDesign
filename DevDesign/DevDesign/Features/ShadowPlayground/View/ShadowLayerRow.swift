// ShadowLayerRow.swift
// DevDesign — Features/ShadowPlayground/ShadowLayerRow.swift

import SwiftUI

struct ShadowLayerRow: View {

    let layer: ShadowLayer
    let index: Int
    let isSelected: Bool
    var onSelect: () -> Void
    var onToggleEnabled: () -> Void
    var onToggleInner: () -> Void
    var onUpdate: ((inout ShadowLayer) -> Void) -> Void
    var onDuplicate: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header row — always visible
            headerRow

            // Controls — only when selected and enabled
            if isSelected && layer.isEnabled {
                controlsSection
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .fill(isSelected
                      ? DSColors.Preview.surfaceElevated
                      : DSColors.Preview.surfaceDefault)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(
                    isSelected ? DSColors.Preview.accent : DSColors.Preview.borderSubtle,
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: layer.isEnabled)
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
    }

    // MARK: - Header Row
    private var headerRow: some View {
        HStack(spacing: DSSpacing.sm) {

            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DSColors.Preview.textTertiary)

            // Shadow swatch — miniature preview
            shadowSwatch

            // Labels
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Layer \(index + 1)")
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(layer.isEnabled
                                         ? DSColors.Preview.textPrimary
                                         : DSColors.Preview.textTertiary)
                    if layer.isInner {
                        Text("inner")
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.accent)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(DSColors.Preview.accent.opacity(0.12), in: Capsule())
                    }
                }

                Text("x:\(ShadowExportService.fInt(layer.x))  y:\(ShadowExportService.fInt(layer.y))  blur:\(ShadowExportService.fInt(layer.blur))  opacity:\(Int(layer.opacity * 100))%")
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            Spacer()

            // Enabled toggle
            Button(action: onToggleEnabled) {
                Image(systemName: layer.isEnabled ? "eye.fill" : "eye.slash")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(layer.isEnabled
                                     ? DSColors.Preview.accent
                                     : DSColors.Preview.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(DSColors.Preview.backgroundTertiary, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.sm)
    }

    // MARK: - Shadow Swatch
    private var shadowSwatch: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(white: 0.18))
                .frame(width: 36, height: 36)

            RoundedRectangle(cornerRadius: 4)
                .fill(.white)
                .frame(width: 18, height: 18)
                .shadow(
                    color: layer.color.opacity(layer.isEnabled ? layer.opacity : 0.1),
                    radius: max(0, layer.blur / 4),
                    x: layer.x / 3,
                    y: layer.y / 3
                )
        }
    }

    // MARK: - Controls Section
    private var controlsSection: some View {
        VStack(spacing: DSSpacing.sm) {
            Divider().background(DSColors.Preview.borderSubtle)
                .padding(.horizontal, DSSpacing.sm)

            VStack(spacing: DSSpacing.sm) {

                // Color + Inner toggle row
                HStack(spacing: DSSpacing.sm) {
                    Text("Color")
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                        .frame(width: 52, alignment: .leading)

                    let colorBinding = Binding<Color>(
                        get: { layer.color },
                        set: { v in onUpdate { $0.color = v } }
                    )
                    ColorPicker("", selection: colorBinding, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 36, height: 28)

                    Spacer()

                    // Inner shadow toggle
                    Button(action: onToggleInner) {
                        HStack(spacing: 4) {
                            Image(systemName: layer.isInner ? "checkmark.square.fill" : "square")
                                .font(.system(size: 13))
                                .foregroundStyle(layer.isInner
                                                 ? DSColors.Preview.accent
                                                 : DSColors.Preview.textTertiary)
                            Text("Inner")
                                .font(DSTypography.labelLarge)
                                .foregroundStyle(layer.isInner
                                                 ? DSColors.Preview.accent
                                                 : DSColors.Preview.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DSSpacing.sm)

                // Sliders
                sliderRow("Opacity",  value: Binding(get: { layer.opacity }, set: { v in onUpdate { $0.opacity = v } }), range: 0...1,   unit: "%",  displayScale: 100, step: 0.01)
                sliderRow("X Offset", value: Binding(get: { layer.x },       set: { v in onUpdate { $0.x = v } }),       range: -40...40, unit: "pt", displayScale: 1,   step: 1)
                sliderRow("Y Offset", value: Binding(get: { layer.y },       set: { v in onUpdate { $0.y = v } }),       range: -40...40, unit: "pt", displayScale: 1,   step: 1)
                sliderRow("Blur",     value: Binding(get: { layer.blur },    set: { v in onUpdate { $0.blur = v } }),    range: 0...60,   unit: "pt", displayScale: 1,   step: 1)
                sliderRow("Spread",   value: Binding(get: { layer.spread },  set: { v in onUpdate { $0.spread = v } }),  range: -20...20, unit: "pt", displayScale: 1,   step: 1)

                // Action row
                HStack(spacing: DSSpacing.sm) {
                    Spacer()

                    Button(action: onDuplicate) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Duplicate")
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(DSColors.Preview.textSecondary)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .background(DSColors.Preview.backgroundTertiary,
                                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))
                    }
                    .buttonStyle(.plain)

                    Button(action: onDelete) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Delete")
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(DSColors.Preview.error)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .background(DSColors.Preview.error.opacity(0.10),
                                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DSSpacing.sm)
            }
            .padding(.bottom, DSSpacing.sm)
        }
    }

    // MARK: - Slider Row
    private func sliderRow(
        _ label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        unit: String,
        displayScale: Double,
        step: Double
    ) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 52, alignment: .leading)

            Slider(value: value, in: range, step: step)
                .tint(DSColors.Preview.accent)

            let display = value.wrappedValue * displayScale
            Text(display.truncatingRemainder(dividingBy: 1) == 0
                 ? String(format: "%.0f%@", display, unit == "%" ? "%" : "")
                 : String(format: "%.0f%@", display, unit == "%" ? "%" : ""))
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(width: 36, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: value.wrappedValue)
        }
        .padding(.horizontal, DSSpacing.sm)
    }
}
