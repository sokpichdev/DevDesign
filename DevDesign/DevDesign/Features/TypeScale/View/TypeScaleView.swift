//
//  TypeScaleView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Type Scale Generator main screen:
//   1. Base size slider
//   2. Ratio selector strip
//   3. Live step previews
//   4. Export sheet

import SwiftUI

struct TypeScaleView: View {

    @State private var viewModel = TypeScaleViewModel()

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Base size control
                    baseSizeCard

                    // 2. Ratio selector
                    ratioSelectorCard

                    // 3. Scale steps
                    stepsSection

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("Type Scale")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showExportSheet) {
            TypeScaleExportSheet(viewModel: viewModel)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Base Size Card
    private var baseSizeCard: some View {
        VStack(spacing: DSSpacing.sm) {

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Base Size")
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    Text("Anchors to Body text")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }

                Spacer()

                // Numeric readout
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(String(format: "%.0f", viewModel.baseSize))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(DSColors.Preview.accent)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                                   value: viewModel.baseSize)
                    Text("pt")
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }

            // Slider 10–24pt range
            HStack(spacing: DSSpacing.sm) {
                Text("10")
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)

                Slider(
                    value: Binding(
                        get: { viewModel.baseSize },
                        set: { viewModel.updateBaseSize($0) }
                    ),
                    in: 10...24,
                    step: 0.5
                )
                .tint(DSColors.Preview.accent)

                Text("24")
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            // Quick-pick buttons
            HStack(spacing: DSSpacing.xs) {
                ForEach([12.0, 14.0, 16.0, 18.0, 20.0], id: \.self) { size in
                    quickPickButton(size)
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

    private func quickPickButton(_ size: Double) -> some View {
        let isActive = viewModel.baseSize == size
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.updateBaseSize(size)
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

    // MARK: - Ratio Selector Card
    private var ratioSelectorCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Scale Ratio")
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    Text(viewModel.ratioDescription)
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedRatio)
                }
                Spacer()
                Text(viewModel.selectedRatio.shortName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(DSColors.Preview.accent)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.8),
                               value: viewModel.selectedRatio.rawValue)
            }

            // Ratio pills — horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(ScaleRatio.allCases) { ratio in
                        ratioPill(ratio)
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

    private func ratioPill(_ ratio: ScaleRatio) -> some View {
        let isSelected = viewModel.selectedRatio == ratio
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectRatio(ratio)
            }
        } label: {
            VStack(spacing: 2) {
                Text(ratio.shortName)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(isSelected ? .white : DSColors.Preview.textPrimary)
                Text(ratio.name)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : DSColors.Preview.textTertiary)
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
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }

    // MARK: - Steps Section
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                Text("Scale Steps")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Text("\(viewModel.steps.count) steps")
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .padding(.horizontal, DSSpacing.xxs)

            ForEach(Array(viewModel.steps.enumerated()), id: \.element.id) { index, step in
                TypeScalePreviewRow(
                    step: step,
                    index: index,
                    onWeightChange: { weight in
                        viewModel.updateWeight(weight, at: index)
                    }
                )
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                withAnimation { viewModel.resetNames() }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                        .font(DSTypography.labelLarge)
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

// MARK: - Preview
#Preview {
    NavigationStack {
        TypeScaleView()
    }
}
