//
//  AppIconGeneratorView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct AppIconGeneratorView: View {

    @State private var viewModel = AppIconViewModel()

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Hero preview
                    heroPreview

                    // 2. Presets
                    presetsSection

                    // 3. Content type selector
                    contentTypeCard

                    // 4. Content controls (symbol / initials / emoji)
                    contentControlsCard

                    // 5. Background controls
                    backgroundCard

                    // 6. Fine-tune controls
                    fineTuneCard

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("App Icon Generator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showSymbolPicker) {
            SymbolPickerSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            AppIconExportSheet(viewModel: viewModel)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Hero Preview
    private var heroPreview: some View {
        VStack(spacing: DSSpacing.md) {
            // Main large icon
            HStack(spacing: DSSpacing.lg) {
                AppIconCanvasView(config: viewModel.config, size: 128)
                    .shadow(color: viewModel.config.backgroundColor.opacity(0.4),
                            radius: 20, x: 0, y: 10)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8),
                               value: viewModel.config.backgroundStyle)

                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    // Mini previews at different sizes
                    HStack(spacing: DSSpacing.sm) {
                        ForEach([60, 40, 29], id: \.self) { pt in
                            VStack(spacing: 4) {
                                AppIconCanvasView(config: viewModel.config, size: CGFloat(pt))
                                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                                Text("\(pt)pt")
                                    .font(DSTypography.labelSmall)
                                    .foregroundStyle(DSColors.Preview.textTertiary)
                            }
                        }
                    }

                    // Springboard mockup label
                    VStack(alignment: .leading, spacing: 3) {
                        Text("MyApp")
                            .font(.system(size: 11))
                            .foregroundStyle(DSColors.Preview.textSecondary)
                    }
                }

                Spacer()
            }

            // Dark / light surface comparison
            HStack(spacing: DSSpacing.sm) {
                iconSurface(isDark: false)
                iconSurface(isDark: true)
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

    private func iconSurface(isDark: Bool) -> some View {
        HStack(spacing: DSSpacing.sm) {
            AppIconCanvasView(config: viewModel.config, size: 50)
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
            VStack(alignment: .leading, spacing: 2) {
                Text(isDark ? "Dark mode" : "Light mode")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(isDark ? .white.opacity(0.6) : DSColors.Preview.textTertiary)
                Text("Springboard")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(isDark ? .white.opacity(0.4) : DSColors.Preview.textTertiary)
            }
            Spacer()
        }
        .padding(DSSpacing.sm)
        .background(isDark ? Color(hex: "#1C1C1E") : Color(hex: "#F2F2F7"),
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.06), lineWidth: 1)
        )
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
                    ForEach(AppIconViewModel.presets) { preset in
                        presetCell(preset)
                    }
                }
            }
        }
    }

    private func presetCell(_ preset: AppIconPreset) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                viewModel.applyPreset(preset)
            }
        } label: {
            VStack(spacing: DSSpacing.xs) {
                // Tiny icon preview
                AppIconCanvasView(
                    config: {
                        var c = AppIconConfig()
                        c.backgroundStyle   = preset.style
                        c.backgroundColor   = Color(hex: preset.bg)
                        c.gradientEndColor  = Color(hex: preset.end)
                        c.gradientDirection = preset.direction
                        c.symbolName        = preset.symbol
                        c.contentType       = .symbol
                        return c
                    }(),
                    size: 56
                )
                .shadow(color: Color(hex: preset.bg).opacity(0.4), radius: 6, x: 0, y: 3)

                Text(preset.name)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content Type Card
    private var contentTypeCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Content")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(.horizontal, DSSpacing.xxs)

            HStack(spacing: DSSpacing.xs) {
                ForEach(IconContentType.allCases) { type in
                    let isSelected = viewModel.config.contentType == type
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.setContentType(type)
                        }
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: type.icon)
                                .font(.system(size: 16, weight: .medium))
                            Text(type.rawValue)
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
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

    // MARK: - Content Controls Card
    @ViewBuilder
    private var contentControlsCard: some View {
        VStack(spacing: DSSpacing.sm) {
            switch viewModel.config.contentType {
            case .symbol:
                symbolControls
            case .initials:
                initialsControls
            case .emoji:
                emojiControls
            }
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                   value: viewModel.config.contentType)
    }

    // Symbol picker trigger
    private var symbolControls: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Symbol")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
            }

            Button {
                viewModel.showSymbolPicker = true
            } label: {
                HStack(spacing: DSSpacing.md) {
                    Image(systemName: viewModel.config.symbolName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(DSColors.Preview.accent)
                        .frame(width: 44, height: 44)
                        .background(DSColors.Preview.accent.opacity(0.1),
                                    in: RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.config.symbolName)
                            .font(DSTypography.codeMedium)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                        Text("Tap to change symbol")
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }
                .padding(DSSpacing.sm)
                .background(DSColors.Preview.backgroundSecondary,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            contentColorRow
        }
    }

    // Initials text field
    private var initialsControls: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Initials")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Text("Max 3 characters")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            TextField("DD", text: Binding(
                get: { viewModel.config.initialsText },
                set: { v in
                    var updated = viewModel.config
                    updated.initialsText = String(v.prefix(3)).uppercased()
                    viewModel.config = updated
                }
            ))
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(DSColors.Preview.textPrimary)
            .multilineTextAlignment(.center)
            .autocorrectionDisabled()
            .autocapitalization(.allCharacters)
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.backgroundSecondary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(DSColors.Preview.accent.opacity(0.4), lineWidth: 1.5)
            )

            contentColorRow
        }
    }

    // Emoji input
    private var emojiControls: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Emoji")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Text("First emoji used")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            TextField("🎨", text: Binding(
                get: { viewModel.config.emojiText },
                set: { v in
                    var updated = viewModel.config
                    updated.emojiText = String(v.prefix(2))
                    viewModel.config = updated
                }
            ))
            .font(.system(size: 44))
            .multilineTextAlignment(.center)
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.backgroundSecondary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(DSColors.Preview.accent.opacity(0.4), lineWidth: 1.5)
            )
        }
    }

    private var contentColorRow: some View {
        HStack(spacing: DSSpacing.sm) {
            Text("Color")
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
            let binding = Binding<Color>(
                get: { viewModel.config.contentColor },
                set: { v in var u = viewModel.config; u.contentColor = v; viewModel.config = u }
            )
            ColorPicker("", selection: binding, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 44, height: 32)

            Text("#\(AppIconExportService.colorHex(viewModel.config.contentColor))")
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)

            Spacer()

            // Quick whites/blacks
            ForEach(["FFFFFF", "000000", "F2F2F7", "1C1C1E"], id: \.self) { hex in
                Circle()
                    .fill(Color(hex: "#\(hex)"))
                    .frame(width: 22, height: 22)
                    .overlay(Circle().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
                    .onTapGesture {
                        var u = viewModel.config
                        u.contentColor = Color(hex: "#\(hex)")
                        viewModel.config = u
                    }
            }
        }
    }

    // MARK: - Background Card
    private var backgroundCard: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Background")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
            }

            // Style selector
            HStack(spacing: DSSpacing.xs) {
                ForEach(IconBackgroundStyle.allCases) { style in
                    let isSelected = viewModel.config.backgroundStyle == style
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.setBackgroundStyle(style)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: style.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(style.rawValue)
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.xs)
                        .background(
                            isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceElevated,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
                }
            }

            Divider().background(DSColors.Preview.borderSubtle)

            // Primary color
            colorRow("Primary", hex: AppIconExportService.colorHex(viewModel.config.backgroundColor),
                     binding: Binding(
                        get: { viewModel.config.backgroundColor },
                        set: { v in var u = viewModel.config; u.backgroundColor = v; viewModel.config = u }
                     ))

            // Gradient end color + direction (gradient / mesh)
            if viewModel.config.backgroundStyle != .solid {
                colorRow("Second", hex: AppIconExportService.colorHex(viewModel.config.gradientEndColor),
                         binding: Binding(
                            get: { viewModel.config.gradientEndColor },
                            set: { v in var u = viewModel.config; u.gradientEndColor = v; viewModel.config = u }
                         ))

                // Direction picker
                HStack {
                    Text("Direction")
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                    Spacer()
                    Menu {
                        ForEach(IconGradientDirection.allCases) { dir in
                            Button {
                                var u = viewModel.config
                                u.gradientDirection = dir
                                viewModel.config = u
                            } label: {
                                Label(dir.rawValue,
                                      systemImage: viewModel.config.gradientDirection == dir ? "checkmark" : "")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.config.gradientDirection.rawValue)
                                .font(DSTypography.labelLarge)
                                .foregroundStyle(DSColors.Preview.accent)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10))
                                .foregroundStyle(DSColors.Preview.accent)
                        }
                    }
                }

                // Mesh accent color
                if viewModel.config.backgroundStyle == .mesh {
                    colorRow("Accent", hex: AppIconExportService.colorHex(viewModel.config.meshAccentColor),
                             binding: Binding(
                                get: { viewModel.config.meshAccentColor },
                                set: { v in var u = viewModel.config; u.meshAccentColor = v; viewModel.config = u }
                             ))
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

    private func colorRow(_ label: String, hex: String, binding: Binding<Color>) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 52, alignment: .leading)

            ColorPicker("", selection: binding, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 44, height: 32)

            Text("#\(hex)")
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)

            Spacer()
        }
    }

    // MARK: - Fine Tune Card
    private var fineTuneCard: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Fine Tune")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
            }

            // Content scale
            tuneSlider("Size", value: Binding(
                get: { viewModel.config.contentScale },
                set: { v in var u = viewModel.config; u.contentScale = v; viewModel.config = u }
            ), range: 0.2...0.85, displayScale: 100, unit: "%")

            // Offset X
            tuneSlider("X Offset", value: Binding(
                get: { viewModel.config.contentOffsetX },
                set: { v in var u = viewModel.config; u.contentOffsetX = v; viewModel.config = u }
            ), range: -0.2...0.2, displayScale: 100, unit: "%")

            // Offset Y
            tuneSlider("Y Offset", value: Binding(
                get: { viewModel.config.contentOffsetY },
                set: { v in var u = viewModel.config; u.contentOffsetY = v; viewModel.config = u }
            ), range: -0.2...0.2, displayScale: 100, unit: "%")

            Divider().background(DSColors.Preview.borderSubtle)

            // Corner radius toggle
            HStack {
                Text("iOS Corner Radius")
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.config.useIOSCornerRadius },
                    set: { v in var u = viewModel.config; u.useIOSCornerRadius = v; viewModel.config = u }
                ))
                .labelsHidden()
                .tint(DSColors.Preview.accent)
            }

            // Drop shadow
            HStack {
                Text("Preview Shadow")
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.config.showShadow },
                    set: { v in var u = viewModel.config; u.showShadow = v; viewModel.config = u }
                ))
                .labelsHidden()
                .tint(DSColors.Preview.accent)
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

    private func tuneSlider(_ label: String, value: Binding<Double>,
                             range: ClosedRange<Double>,
                             displayScale: Double, unit: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 60, alignment: .leading)
            Slider(value: value, in: range)
                .tint(DSColors.Preview.accent)
            let v = value.wrappedValue * displayScale
            Text(String(format: v.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f%@" : "%.1f%@", v, unit))
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(width: 48, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: v)
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
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
            Text("\(viewModel.copiedLabel) copied!")
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

// MARK: - Symbol Picker Sheet

struct SymbolPickerSheet: View {

    @Bindable var viewModel: AppIconViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 6)

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search
                    HStack(spacing: DSSpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(DSColors.Preview.textTertiary)
                        TextField("Search symbols…", text: $viewModel.symbolSearchText)
                            .autocorrectionDisabled()
                        if !viewModel.symbolSearchText.isEmpty {
                            Button {
                                viewModel.symbolSearchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(DSColors.Preview.textTertiary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(DSSpacing.sm)
                    .background(DSColors.Preview.surfaceDefault,
                                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                    .overlay(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.vertical, DSSpacing.sm)

                    Divider().background(DSColors.Preview.borderSubtle)

                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(viewModel.filteredSymbols, id: \.self) { name in
                                let isSelected = viewModel.config.symbolName == name
                                Button {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                        viewModel.setSymbol(name)
                                    }
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: name)
                                            .font(.system(size: 22, weight: .regular))
                                            .foregroundStyle(
                                                isSelected ? .white : DSColors.Preview.textPrimary
                                            )
                                            .frame(width: 44, height: 44)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        isSelected ? DSColors.Preview.accent : Color.clear,
                                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, DSSpacing.screenPadding)
                        .padding(.vertical, DSSpacing.sm)
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .navigationTitle("Choose Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
