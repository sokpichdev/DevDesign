//
//  SpacingSystemView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Spacing System screen:
//   1. Base grid selector (4pt / 8pt)
//   2. Scale visualiser — proportional bars for all tokens
//   3. Token rows — value, copy, expandable override
//   4. Export sheet

import SwiftUI

struct SpacingSystemView: View {

    @State private var viewModel = SpacingSystemViewModel()
    @State private var expandedIndex: Int? = nil

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Base grid selector
                    baseGridCard

                    // 2. Compact scale visualiser
                    scaleVisualizerCard

                    // 3. Token rows
                    tokenSection

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("Spacing System")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showExportSheet) {
            SpacingExportSheet(viewModel: viewModel)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Base Grid Card
    private var baseGridCard: some View {
        VStack(spacing: DSSpacing.sm) {

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Base Grid Unit")
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    Text("All tokens are multiples of this value")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }
                Spacer()

                // Live base readout
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(SpacingExportService.formatValue(viewModel.base.rawValue))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(DSColors.Preview.accent)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.base.rawValue)
                    Text("pt")
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }

            // Grid picker
            HStack(spacing: DSSpacing.sm) {
                ForEach(BaseGrid.allCases) { grid in
                    gridButton(grid)
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

    private func gridButton(_ grid: BaseGrid) -> some View {
        let isSelected = viewModel.base == grid
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectBase(grid)
                expandedIndex = nil
            }
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(grid.label)
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(isSelected ? .white : DSColors.Preview.textPrimary)
                Text(grid.description)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(isSelected ? .white.opacity(0.75) : DSColors.Preview.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DSSpacing.sm)
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

    // MARK: - Scale Visualiser
    // Horizontal stacked bars — shows all 8 tokens at once proportionally.
    private var scaleVisualizerCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {

            HStack {
                Text("Scale Overview")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Text(viewModel.totalRange)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.35, dampingFraction: 0.8),
                               value: viewModel.totalRange)
            }

            // Stacked horizontal bars
            VStack(spacing: 6) {
                ForEach(Array(viewModel.tokens.enumerated()), id: \.element.id) { index, token in
                    visualiserRow(token: token)
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

    // MARK: - Visualiser Row Helper
    // GeometryReader measures the TRACK width (after the 44pt label is placed in
    // an HStack). The fill width is then `trackWidth * fraction` — always ≥ 0.
    @ViewBuilder
    private func visualiserRow(token: SpacingToken) -> some View {
        let maxVal = viewModel.tokens.map(\.resolvedValue).max() ?? 1
        let fraction = maxVal > 0 ? min(token.resolvedValue / maxVal, 1.0) : 0

        HStack(spacing: DSSpacing.xs) {
            // Fixed-width name label
            Text(".\(token.name)")
                .font(DSTypography.codeSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .frame(width: 44, alignment: .leading)

            // Track fills all remaining space; fill width derived inside GeometryReader
            GeometryReader { geo in
                let trackWidth = geo.size.width
                let fillWidth  = max(0, trackWidth * fraction)   // always ≥ 0

                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(DSColors.Preview.backgroundTertiary)
                        .frame(width: trackWidth, height: 18)

                    // Fill — fraction of track only, never negative
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(
                            colors: [
                                DSColors.Preview.accent.opacity(0.5 + 0.5 * fraction),
                                DSColors.Preview.accent
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: fillWidth, height: 18)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8),
                                   value: token.resolvedValue)

                    // Value label — only shown when fill is wide enough
                    if fillWidth > 28 {
                        Text(SpacingExportService.formatValue(token.resolvedValue))
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.leading, 6)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.35, dampingFraction: 0.8),
                                       value: token.resolvedValue)
                    }
                }
            }
            .frame(height: 18)   // GeometryReader needs explicit height
        }
    }

    // MARK: - Token Section
    private var tokenSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {

            HStack {
                Text("Tokens")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                if viewModel.overrideCount > 0 {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.clearAllOverrides()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Clear \(viewModel.overrideCount) override\(viewModel.overrideCount == 1 ? "" : "s")")
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(DSColors.Preview.warning)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSSpacing.xxs)

            let maxVal = viewModel.tokens.map(\.resolvedValue).max() ?? 1

            ForEach(Array(viewModel.tokens.enumerated()), id: \.element.id) { index, token in
                SpacingTokenRow(
                    token: token,
                    maxValue: maxVal,
                    index: index,
                    isExpanded: expandedIndex == index,
                    onToggleExpand: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedIndex = expandedIndex == index ? nil : index
                        }
                    },
                    onCopy: { viewModel.copyValue(token) },
                    onSetOverride: { value in
                        viewModel.setOverride(value, at: index)
                    },
                    onClearOverride: {
                        viewModel.clearOverride(at: index)
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
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.resetAll()
                    expandedIndex = nil
                }
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
        SpacingSystemView()
    }
}
