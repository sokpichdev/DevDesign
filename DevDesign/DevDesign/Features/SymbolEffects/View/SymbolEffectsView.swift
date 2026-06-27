//
//  SymbolEffectsView.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  Animate any SF Symbol with Apple's native .symbolEffect, tweak it live,
//  and export SwiftUI / UIKit code. Skeleton mirrors MetalSymbolsView.
//

import SwiftUI

struct SymbolEffectsView: View {

    @State private var viewModel = SymbolEffectsViewModel()

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {
                    previewSection
                    effectSection
                    symbolSection
                    controlSection
                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("Symbol Effects")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showExportSheet) {
            SymbolEffectsExportSheet(viewModel: viewModel)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Preview
    private var previewSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DSSpacing.Radius.lg)
                .fill(viewModel.config.backgroundIsDark
                      ? Color(hex: "#0E0E10")
                      : Color(hex: "#F2F2F5"))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.lg)
                        .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
                )

            SymbolEffectPreview(config: viewModel.config)
                .id("\(viewModel.config.symbolName)-\(viewModel.config.kind.rawValue)")

            VStack {
                HStack { Spacer(); backgroundToggle }
                Spacer()
                HStack { Spacer(); playToggle }
            }
            .padding(DSSpacing.sm)
        }
        .frame(height: 260)
    }

    private var backgroundToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { viewModel.toggleBackground() }
        } label: {
            Image(systemName: viewModel.config.backgroundIsDark ? "sun.max.fill" : "moon.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.config.backgroundIsDark
                            ? "Switch to light preview background"
                            : "Switch to dark preview background")
        .accessibilityIdentifier("symbolEffects.backgroundToggle")
    }

    private var playToggle: some View {
        Button {
            viewModel.togglePlaying()
        } label: {
            Image(systemName: viewModel.config.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(DSColors.Preview.accent)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.config.isPlaying ? "Pause animation" : "Play animation")
        .accessibilityIdentifier("symbolEffects.playToggle")
    }

    // MARK: - Effect Picker
    private var effectSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionTitle("Effect")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(SymbolEffectKind.allCases) { kind in
                        effectChip(kind)
                    }
                }
                .padding(.vertical, DSSpacing.xxs)
            }
        }
    }

    private func effectChip(_ kind: SymbolEffectKind) -> some View {
        let isSelected = viewModel.config.kind == kind
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectKind(kind)
            }
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: kind.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(kind.displayName)
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(
                isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceDefault,
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.clear : DSColors.Preview.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(kind.displayName) effect")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - Symbol Picker
    private var symbolSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionTitle("Symbol")

            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .accessibilityHidden(true)
                TextField("system name (e.g. bell.fill)", text: $viewModel.config.symbolName)
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.surfaceDefault,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(SymbolEffectsConfig.quickPickSymbols, id: \.self) { name in
                        quickPickButton(name)
                    }
                }
                .padding(.vertical, DSSpacing.xxs)
            }
        }
    }

    private func quickPickButton(_ name: String) -> some View {
        let isSelected = viewModel.config.symbolName == name
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.config.symbolName = name
            }
        } label: {
            Image(systemName: name)
                .font(.system(size: 18))
                .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                .frame(width: 44, height: 44)
                .background(
                    isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .strokeBorder(
                            isSelected ? Color.clear : DSColors.Preview.borderSubtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - Controls
    private var controlSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            sectionTitle("Parameters")

            sliderRow(title: "Size",
                      value: $viewModel.config.size,
                      range: 60...200,
                      display: "\(Int(viewModel.config.size))pt")

            sliderRow(title: "Speed",
                      value: $viewModel.config.speed,
                      range: 0.25...3,
                      display: String(format: "%.2f×", viewModel.config.speed))

            colorRow(title: "Color", selection: $viewModel.config.primaryColor)
        }
    }

    private func sliderRow(title: String,
                           value: Binding<Double>,
                           range: ClosedRange<Double>,
                           display: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            HStack {
                Text(title)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                Spacer()
                Text(display)
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            Slider(value: value, in: range)
                .tint(DSColors.Preview.accent)
        }
    }

    private func sliderRow(title: String,
                           value: Binding<CGFloat>,
                           range: ClosedRange<CGFloat>,
                           display: String) -> some View {
        sliderRow(
            title: title,
            value: Binding(get: { Double(value.wrappedValue) },
                           set: { value.wrappedValue = CGFloat($0) }),
            range: Double(range.lowerBound)...Double(range.upperBound),
            display: display
        )
    }

    private func colorRow(title: String, selection: Binding<Color>) -> some View {
        HStack {
            Text(title)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
            Spacer()
            ColorPicker("", selection: selection, supportsOpacity: false)
                .labelsHidden()
                .accessibilityLabel(title)
        }
    }

    // MARK: - Section Title
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(DSTypography.headingSmall)
            .foregroundStyle(DSColors.Preview.textPrimary)
            .padding(.horizontal, DSSpacing.xxs)
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
                    Text("Reset").font(DSTypography.labelLarge)
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
                    Text("Export").font(DSTypography.labelLarge)
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
        SymbolEffectsView()
    }
}
