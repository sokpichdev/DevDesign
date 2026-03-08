// ColorWheelPickerView.swift
// DevDesign — Features/PaletteGenerator/ColorWheelPickerView.swift
//
// Compact color input: native wheel + HSL sliders + HEX field.
// Designed to sit at the top of the Palette Generator screen.

import SwiftUI

struct ColorWheelPickerView: View {

    @Binding var devColor: DevColor
    /// Observed from PaletteGeneratorViewModel.forceSyncTrigger.
    /// When it changes, the field is force-synced and focus is dismissed.
    var forceSyncTrigger: Int = 0

    // MARK: - Local state
    @State private var hexInput: String = ""
    @State private var hexError: Bool = false
    @State private var hue: Double = 0
    @State private var saturation: Double = 0
    @State private var lightness: Double = 0
    @State private var pickerMode: PickerMode = .wheel

    // FIX 1: track hex field focus so sync never clobbers mid-edit text
    @FocusState private var hexFieldFocused: Bool

    enum PickerMode: String, CaseIterable {
        case wheel   = "Wheel"
        case sliders = "Sliders"
        case hex     = "HEX"
    }

    var body: some View {
        VStack(spacing: DSSpacing.md) {

            // Mode toggle — stays put, never auto-switches
            Picker("Picker Mode", selection: $pickerMode) {
                ForEach(PickerMode.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.segmented)

            // Active picker panel — fixed height so card doesn't jump between modes
            Group {
                switch pickerMode {
                case .wheel:   wheelPicker
                case .sliders: slidersPicker
                case .hex:     hexPicker
                }
            }
            .frame(height: 80)

            // Color preview bar — values animate in place (FIX 2)
            colorPreviewBar
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .onAppear {
            syncFromDevColor(force: true)
        }
        .onChange(of: devColor) {
            // FIX 1: guard prevents overwriting hexInput while user is typing
            syncFromDevColor(force: false)
        }
        .onChange(of: forceSyncTrigger) {
            // External action (randomise / harmony change) — dismiss focus
            // and force-overwrite the hex field with the new color.
            hexFieldFocused = false
            syncFromDevColor(force: true)
        }
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
                Text("Tap the swatch to open\nthe system color wheel")
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)

                // FIX 2: hex value rolls in place
                Text(devColor.hex)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: devColor.hex)
            }
            Spacer()
        }
    }

    // MARK: - Sliders Picker
    private var slidersPicker: some View {
        VStack(spacing: DSSpacing.sm) {
            colorSlider(label: "H", value: $hue,        range: 0...360, unit: "°",
                        color: Color(hue: hue / 360, saturation: 1, brightness: 1))
            colorSlider(label: "S", value: $saturation, range: 0...100, unit: "%",
                        color: DSColors.Preview.accent)
            colorSlider(label: "L", value: $lightness,  range: 0...100, unit: "%",
                        color: .white)
        }
    }

    private func colorSlider(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        unit: String,
        color: Color
    ) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 14)

            Slider(value: value, in: range, step: 1)
                .tint(color)
                .onChange(of: value.wrappedValue) { applyHSL() }

            // FIX 2: slider label rolls up/down like a counter
            Text("\(Int(value.wrappedValue))\(unit)")
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(width: 42, alignment: .trailing)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: value.wrappedValue)
        }
    }

    // MARK: - HEX Picker
    private var hexPicker: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.sm) {
                Text("#")
                    .font(DSTypography.codeLarge)
                    .foregroundStyle(DSColors.Preview.textTertiary)

                TextField("RRGGBB", text: $hexInput)
                    .font(DSTypography.codeLarge)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($hexFieldFocused)          // FIX 1: bind focus state
                    .onChange(of: hexInput) { applyHex() }
                    .onSubmit {
                        applyHex()
                        hexFieldFocused = false
                    }

                // Live swatch — updates from devColor, independently of field text
                RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                    .fill(devColor.color)
                    .frame(width: 36, height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                            .strokeBorder(DSColors.Preview.borderDefault, lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 0.2), value: devColor.hex)
            }
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.backgroundTertiary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(
                        hexError        ? DSColors.Preview.error :
                        hexFieldFocused ? DSColors.Preview.accent.opacity(0.6) :
                                          Color.clear,
                        lineWidth: 1.5
                    )
                    .animation(.easeInOut(duration: 0.15), value: hexFieldFocused)
                    .animation(.easeInOut(duration: 0.15), value: hexError)
            )

            if hexError {
                Text("Invalid hex — use RRGGBB or shorthand RGB")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: hexError)
    }

    // MARK: - Color Preview Bar
    private var colorPreviewBar: some View {
        HStack(spacing: DSSpacing.sm) {

            // Swatch — smooth fill transition
            RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                .fill(devColor.color)
                .frame(height: 28)
                .animation(.easeInOut(duration: 0.2), value: devColor.hex)

            // RGB chips — FIX 2: each value rolls independently
            animatedChip(label: "R", value: devColor.rgb.r)
            animatedChip(label: "G", value: devColor.rgb.g)
            animatedChip(label: "B", value: devColor.rgb.b)

            Divider()
                .frame(height: 16)
                .background(DSColors.Preview.borderSubtle)

            // HEX chip
            Text(devColor.hex)
                .font(DSTypography.codeSmall)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: devColor.hex)
        }
    }

    /// A labeled chip whose numeric value animates up/down on change
    private func animatedChip(label: String, value: Int) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
            Text("\(value)")
                .font(DSTypography.codeSmall)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .monospacedDigit()
                .contentTransition(.numericText())                          // FIX 2
                .animation(.spring(response: 0.3, dampingFraction: 0.8),
                           value: value)
        }
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, 4)
        .background(DSColors.Preview.backgroundTertiary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))
    }

    // MARK: - Sync Helpers

    /// Pull HSL + hex from devColor into local state.
    /// - force: true  → always update hexInput (used on first appear)
    /// - force: false → skip hexInput update if the user is currently typing in it (FIX 1)
    private func syncFromDevColor(force: Bool) {
        let (h, s, l) = devColor.hsl
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            hue        = h
            saturation = s
            lightness  = l
        }
        if force || !hexFieldFocused {
            hexInput = String(devColor.hex.dropFirst()) // strip leading #
            hexError = false
        }
    }

    /// Sliders changed → push HSL into devColor, optionally sync hex field
    private func applyHSL() {
        let newColor = DevColor(hue: hue, saturation: saturation / 100, lightness: lightness / 100)
        devColor = newColor
        if !hexFieldFocused {
            hexInput = String(newColor.hex.dropFirst())
        }
    }

    /// HEX field changed → parse and push to devColor only when valid.
    /// Never resets hexInput — user stays in full control of the field. (FIX 1)
    private func applyHex() {
        let cleaned = hexInput.trimmingCharacters(in: .whitespaces)
        guard !cleaned.isEmpty else { hexError = false; return }

        if let dc = DevColor(hex: cleaned) {
            devColor = dc          // triggers onChange(of: devColor) → syncFromDevColor(force: false)
            hexError = false       // which skips hexInput because hexFieldFocused == true
        } else {
            hexError = cleaned.count >= 6
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        DSColors.Preview.backgroundPrimary.ignoresSafeArea()
        ColorWheelPickerView(
            devColor: .constant(DevColor(hue: 240, saturation: 0.65, lightness: 0.55))
        )
        .padding()
    }
}
