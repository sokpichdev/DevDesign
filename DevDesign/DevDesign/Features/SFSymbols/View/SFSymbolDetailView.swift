//
//  SFSymbolDetailView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Full detail screen for one SF Symbol:
//   - Large live preview at selected size + weight
//   - Size slider + weight picker
//   - All rendering modes
//   - 4 copy variants: name / SwiftUI / UIKit / Resizable / Button

import SwiftUI

struct SFSymbolDetailView: View {

    let symbol: SFSymbol
    @Bindable var viewModel: SFSymbolsViewModel

    @State private var selectedRenderMode: RenderModeOption = .monochrome
    @State private var previewBgIsDark: Bool = true

    enum RenderModeOption: String, CaseIterable, Identifiable {
        case monochrome  = "Monochrome"
        case hierarchical = "Hierarchical"
        case palette     = "Palette"
        case multicolor  = "Multicolor"
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Large preview card
                    previewCard

                    // 2. Size control
                    sizeCard

                    // 3. Weight picker
                    weightCard

                    // 4. Rendering modes
                    renderingCard

                    // 5. Copy variants
                    copyCard

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle(symbol.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Preview Card
    private var previewCard: some View {
        ZStack {
            // Toggle bg
            (previewBgIsDark ? DSColors.Preview.backgroundPrimary : Color.white)
                .animation(.easeInOut(duration: 0.2), value: previewBgIsDark)

            VStack(spacing: DSSpacing.md) {

                // Symbol at 3 sizes simultaneously
                HStack(spacing: DSSpacing.xl) {
                    ForEach([0.5, 1.0, 1.5], id: \.self) { scale in
                        VStack(spacing: DSSpacing.xs) {
                            symbolImage(
                                size: viewModel.previewSize * scale,
                                renderMode: selectedRenderMode,
                                isDark: previewBgIsDark
                            )
                            Text(String(format: "%.0f pt", viewModel.previewSize * scale))
                                .font(DSTypography.labelSmall)
                                .foregroundStyle(previewBgIsDark
                                    ? DSColors.Preview.textTertiary
                                    : Color.secondary)
                        }
                    }
                }
                .padding(.vertical, DSSpacing.lg)
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            // Background toggle
            Button {
                withAnimation { previewBgIsDark.toggle() }
            } label: {
                Image(systemName: previewBgIsDark ? "sun.max" : "moon")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(previewBgIsDark ? .white : .black)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(DSSpacing.sm)
        }
    }

    private func symbolImage(size: CGFloat, renderMode: RenderModeOption, isDark: Bool) -> some View {
        let fgColor: Color = isDark ? .white : .black

        return Group {
            switch renderMode {
            case .monochrome:
                Image(systemName: symbol.name)
                    .font(.system(size: size, weight: viewModel.previewWeight.fontWeight))
                    .foregroundStyle(fgColor)
            case .hierarchical:
                Image(systemName: symbol.name)
                    .font(.system(size: size, weight: viewModel.previewWeight.fontWeight))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(fgColor)
            case .palette:
                Image(systemName: symbol.name)
                    .font(.system(size: size, weight: viewModel.previewWeight.fontWeight))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(DSColors.Preview.accent, fgColor)
            case .multicolor:
                Image(systemName: symbol.name)
                    .font(.system(size: size, weight: viewModel.previewWeight.fontWeight))
                    .symbolRenderingMode(.multicolor)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: size)
        .animation(.easeInOut(duration: 0.2), value: renderMode)
    }

    // MARK: - Size Card
    private var sizeCard: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Size")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(String(format: "%.0f", viewModel.previewSize))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(DSColors.Preview.accent)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                                   value: viewModel.previewSize)
                    Text("pt")
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }

            Slider(value: $viewModel.previewSize, in: 12...96, step: 1)
                .tint(DSColors.Preview.accent)

            // Quick-pick sizes
            HStack(spacing: DSSpacing.xs) {
                ForEach([16.0, 20.0, 24.0, 32.0, 48.0, 64.0], id: \.self) { size in
                    quickSizeButton(size)
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

    private func quickSizeButton(_ size: CGFloat) -> some View {
        let isActive = viewModel.previewSize == size
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.previewSize = size
            }
        } label: {
            Text(String(format: "%.0f", size))
                .font(DSTypography.labelLarge)
                .foregroundStyle(isActive ? .white : DSColors.Preview.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.xs)
                .background(
                    isActive ? DSColors.Preview.accent : DSColors.Preview.surfaceElevated,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                        .strokeBorder(
                            isActive ? Color.clear : DSColors.Preview.borderSubtle,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isActive)
    }

    // MARK: - Weight Card
    private var weightCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Weight")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(SymbolWeight.allCases) { weight in
                        weightPill(weight)
                    }
                }
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

    private func weightPill(_ weight: SymbolWeight) -> some View {
        let isSelected = viewModel.previewWeight == weight
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.previewWeight = weight
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol.name)
                    .font(.system(size: 18, weight: weight.fontWeight))
                    .foregroundStyle(isSelected ? .white : DSColors.Preview.textPrimary)
                    .frame(height: 22)
                Text(weight.rawValue)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(isSelected ? .white.opacity(0.85) : DSColors.Preview.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(
                isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceElevated,
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
    }

    // MARK: - Rendering Modes Card
    private var renderingCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Rendering Mode")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)

            HStack(spacing: DSSpacing.xs) {
                ForEach(RenderModeOption.allCases) { mode in
                    renderModePill(mode)
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

    private func renderModePill(_ mode: RenderModeOption) -> some View {
        let isSelected = selectedRenderMode == mode
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedRenderMode = mode
            }
        } label: {
            Text(mode.rawValue)
                .font(DSTypography.labelLarge)
                .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceElevated,
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
    }

    // MARK: - Copy Card
    private var copyCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Copy Code")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)

            VStack(spacing: DSSpacing.xs) {
                copyRow(
                    label: "Symbol Name",
                    icon: "textformat",
                    preview: "\"\(symbol.name)\"",
                    action: { viewModel.copySymbolName(symbol) }
                )
                copyRow(
                    label: "SwiftUI Image",
                    icon: "swift",
                    preview: "Image(systemName: \"\(symbol.name)\")",
                    action: { viewModel.copySwiftUI(symbol) }
                )
                copyRow(
                    label: "UIKit UIImage",
                    icon: "chevron.left.forwardslash.chevron.right",
                    preview: "UIImage(systemName: \"\(symbol.name)\")",
                    action: { viewModel.copyUIKit(symbol) }
                )
                copyRow(
                    label: "Resizable SwiftUI",
                    icon: "arrow.up.left.and.arrow.down.right",
                    preview: ".symbolRenderingMode(.hierarchical)",
                    action: { viewModel.copyResizable(symbol) }
                )
                copyRow(
                    label: "Button Snippet",
                    icon: "curlybraces",
                    preview: "Button { } label: { Image(systemName:…) }",
                    action: { viewModel.copyButton(symbol) }
                )
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

    private func copyRow(label: String, icon: String, preview: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DSColors.Preview.accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text(preview)
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: action) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DSColors.Preview.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(DSColors.Preview.backgroundTertiary, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.backgroundSecondary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.toggleFavourite(symbol)
            } label: {
                Image(systemName: viewModel.isFavourite(symbol) ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        viewModel.isFavourite(symbol)
                            ? DSColors.Preview.error
                            : DSColors.Preview.textSecondary
                    )
                    .contentTransition(.symbolEffect(.replace))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7),
                               value: viewModel.isFavourite(symbol))
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
