//
//  ColorWheelPickerView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//


// ColorWheelPickerView.swift
// DevDesign — Features/PaletteGenerator/ColorWheelPickerView.swift
//
// Compact color input: native wheel + HSL sliders + HEX field.
// Designed to sit at the top of the Palette Generator screen.

import SwiftUI

struct ColorWheelPickerView: View {

    @Binding var devColor: DevColor
    @State private var hexInput: String = ""
    @State private var hexError: Bool = false
    @State private var hue: Double = 0
    @State private var saturation: Double = 0
    @State private var lightness: Double = 0
    @State private var pickerMode: PickerMode = .wheel

    enum PickerMode: String, CaseIterable {
        case wheel = "Wheel"
        case sliders = "Sliders"
        case hex = "HEX"
    }

    var body: some View {
        VStack(spacing: DSSpacing.md) {

            // Mode toggle
            Picker("Picker Mode", selection: $pickerMode) {
                ForEach(PickerMode.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.segmented)

            // Active picker
            switch pickerMode {
            case .wheel:   wheelPicker
            case .sliders: slidersPicker
            case .hex:     hexPicker
            }

            // Color preview bar
            colorPreviewBar
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .onAppear { syncFromDevColor() }
        .onChange(of: devColor) { syncFromDevColor() }
    }

    // MARK: - Wheel Picker
    private var wheelPicker: some View {
        HStack(spacing: DSSpacing.md) {
            ColorPicker("", selection: Binding(
                get: { devColor.color },
                set: { newColor in
                    if let dc = DevColor(color: newColor) {
                        devColor = dc
                    }
                }
            ))
            .labelsHidden()
            .scaleEffect(1.4)
            .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("Tap the swatch to open the system color wheel")
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                Text(devColor.hex)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)
            }
            Spacer()
        }
        .frame(height: 60)
    }

    // MARK: - Sliders Picker
    private var slidersPicker: some View {
        VStack(spacing: DSSpacing.sm) {
            colorSlider(label: "H", value: $hue, range: 0...360,
                        unit: "°", color: .red, onChange: applyHSL)

            colorSlider(label: "S", value: $saturation, range: 0...100,
                        unit: "%", color: DSColors.Preview.accent, onChange: applyHSL)

            colorSlider(label: "L", value: $lightness, range: 0...100,
                        unit: "%", color: .white, onChange: applyHSL)
        }
    }

    private func colorSlider(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        unit: String,
        color: Color,
        onChange: @escaping () -> Void
    ) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 14)

            Slider(value: value, in: range, step: 1)
                .tint(color)
                .onChange(of: value.wrappedValue) { onChange() }

            Text("\(Int(value.wrappedValue))\(unit)")
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(width: 42, alignment: .trailing)
                .monospacedDigit()
        }
    }

    // MARK: - HEX Picker
    private var hexPicker: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.sm) {
                // Hash prefix
                Text("#")
                    .font(DSTypography.codeLarge)
                    .foregroundStyle(DSColors.Preview.textTertiary)

                TextField("RRGGBB", text: $hexInput)
                    .font(DSTypography.codeLarge)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .onChange(of: hexInput) { applyHex() }
                    .onSubmit { applyHex() }

                // Live swatch
                RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                    .fill(devColor.color)
                    .frame(width: 36, height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                            .strokeBorder(DSColors.Preview.borderDefault, lineWidth: 1)
                    )
            }
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.backgroundTertiary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(hexError ? DSColors.Preview.error : Color.clear, lineWidth: 1.5)
            )

            if hexError {
                Text("Invalid hex — use format RRGGBB")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.error)
            }
        }
        .frame(height: 80)
    }

    // MARK: - Color Preview Bar
    private var colorPreviewBar: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                .fill(devColor.color)
                .frame(height: 28)

            Spacer().frame(width: DSSpacing.sm)

            // RGB chips
            HStack(spacing: DSSpacing.xs) {
                colorChip(label: "R", value: devColor.rgb.r)
                colorChip(label: "G", value: devColor.rgb.g)
                colorChip(label: "B", value: devColor.rgb.b)
            }
        }
    }

    private func colorChip(label: String, value: Int) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
            Text("\(value)")
                .font(DSTypography.codeSmall)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .monospacedDigit()
        }
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, 4)
        .background(DSColors.Preview.backgroundTertiary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))
    }

    // MARK: - Sync Helpers

    private func syncFromDevColor() {
        let (h, s, l) = devColor.hsl
        hue        = h
        saturation = s
        lightness  = l
        hexInput   = String(devColor.hex.dropFirst()) // strip #
        hexError   = false
    }

    private func applyHSL() {
        devColor = DevColor(hue: hue, saturation: saturation / 100, lightness: lightness / 100)
        hexInput = String(devColor.hex.dropFirst())
    }

    private func applyHex() {
        let cleaned = hexInput.trimmingCharacters(in: .whitespaces)
        if let dc = DevColor(hex: cleaned) {
            devColor   = dc
            hexError   = false
            let (h, s, l) = dc.hsl
            hue        = h
            saturation = s
            lightness  = l
        } else {
            hexError = cleaned.count >= 6
        }
    }
}

// MARK: - Preview
//#Preview {
//    ZStack {
//        DSColors.Preview.backgroundPrimary.ignoresSafeArea()
//        ColorWheelPickerView(devColor: .constant(DevColor(hue: 240, saturation: 0.65, lightness: 0.55)))
//            .padding()
//    }
//}
