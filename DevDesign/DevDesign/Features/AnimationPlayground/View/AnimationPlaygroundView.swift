//
//  AnimationPlaygroundView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct AnimationPlaygroundView: View {

    @State private var viewModel = AnimationViewModel()
    private let accentColor = Color(hex: "#BF5AF2")

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Live preview card
                    AnimationPreviewCard(viewModel: viewModel, accentColor: accentColor)

                    // 2. Timing curve visualiser
                    curveSection

                    // 3. Controls (type selector + sliders + presets + repeat)
                    AnimationControlsView(viewModel: viewModel, accentColor: accentColor)

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("Animation Playground")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showExportSheet) {
            AnimationExportSheet(viewModel: viewModel, accentColor: accentColor)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Curve Section
    private var curveSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "waveform.path")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accentColor)
                    Text("Timing Curve")
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                }
                Spacer()
                Text(viewModel.config.type.label)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .padding(.horizontal, DSSpacing.xxs)

            AnimationCurveView(
                config: viewModel.config,
                isAnimating: viewModel.isAnimating,
                accentColor: accentColor
            )
            .frame(height: 160)
            // Never animate the curve with its own value change — just redraw
            .id(viewModel.config.type.id)

            // Overshoot badge for springs
            if viewModel.config.type.category == .spring
                && viewModel.config.dampingFraction < 1.0 {
                let overshoot = abs(AnimationExportService.curvePoints(viewModel.config)
                    .map(\.v).max() ?? 1.0) - 1.0
                if overshoot > 0.01 {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle")
                            .font(.system(size: 11))
                        Text(String(format: "Overshoot: +%.1f%%", overshoot * 100))
                            .font(DSTypography.labelSmall)
                    }
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, 4)
                    .background(accentColor.opacity(0.1), in: Capsule())
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    withAnimation { viewModel.config = AnimationConfig() }
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
                .foregroundStyle(accentColor)
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

// MARK: - Export Sheet

struct AnimationExportSheet: View {

    @Bindable var viewModel: AnimationViewModel
    let accentColor: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: 0) {

                    // Header — mini curve + type label
                    HStack(spacing: DSSpacing.md) {
                        AnimationCurveView(
                            config: viewModel.config,
                            isAnimating: false,
                            accentColor: accentColor
                        )
                        .frame(width: 80, height: 56)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.config.type.label)
                                .font(DSTypography.headingMedium)
                                .foregroundStyle(DSColors.Preview.textPrimary)
                            Text(viewModel.config.type.description)
                                .font(DSTypography.labelSmall)
                                .foregroundStyle(DSColors.Preview.textTertiary)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(DSSpacing.screenPadding)

                    Divider().background(DSColors.Preview.borderSubtle)

                    // Tab strip
                    tabStrip
                        .padding(.vertical, DSSpacing.sm)

                    Divider().background(DSColors.Preview.borderSubtle)

                    // Code
                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        Text(viewModel.exportString(for: viewModel.selectedExportTab))
                            .font(DSTypography.codeSmall)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(DSSpacing.md)
                    }
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.15), value: viewModel.selectedExportTab)

                    Spacer()

                    // Copy button
                    Button {
                        viewModel.copyExport(for: viewModel.selectedExportTab)
                        dismiss()
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "doc.on.doc.fill")
                            Text("Copy \(viewModel.selectedExportTab.rawValue)")
                                .font(DSTypography.headingSmall)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                        .background(accentColor,
                                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
                    }
                    .buttonStyle(.plain)
                    .padding(DSSpacing.screenPadding)
                }
            }
            .navigationTitle("Export Animation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(accentColor)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }

    private var tabStrip: some View {
        HStack(spacing: 0) {
            ForEach(AnimExportTab.allCases) { tab in
                let isSelected = viewModel.selectedExportTab == tab
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        viewModel.selectedExportTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(tab.rawValue)
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(isSelected ? accentColor : DSColors.Preview.textTertiary)
                        .padding(.horizontal, DSSpacing.xs)
                        Rectangle()
                            .fill(isSelected ? accentColor : Color.clear)
                            .frame(height: 2)
                            .clipShape(Capsule())
                            .padding(.horizontal, DSSpacing.xs)
                    }
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AnimationPlaygroundView()
    }
}
