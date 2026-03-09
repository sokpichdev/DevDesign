//
//  BorderDecorationView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct BorderDecorationView: View {

    @State private var viewModel = BorderDecorationViewModel()

    private var accentForTab: Color {
        switch viewModel.selectedTab {
        case .corners:  return Color(hex: "#FF9F0A")
        case .borders:  return Color(hex: "#7B6EF6")
        case .glow:     return Color(hex: "#BF5AF2")
        case .patterns: return Color(hex: "#30D158")
        }
    }

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Tab strip
                tabStrip
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.vertical, DSSpacing.sm)

                Divider().background(DSColors.Preview.borderSubtle)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DSSpacing.md) {

                        // Shape picker
                        shapePicker
                            .padding(.top, DSSpacing.md)

                        // Live preview canvas
                        DecorationPreviewCanvas(
                            tab: viewModel.selectedTab,
                            shape: viewModel.selectedShape,
                            cornerConfig: viewModel.cornerConfig,
                            borderConfig: viewModel.borderConfig,
                            glowConfig: viewModel.glowConfig,
                            patternConfig: viewModel.patternConfig,
                            accentColor: accentForTab
                        )

                        // Inline export code strip
                        inlineCodeStrip

                        // Tab-specific controls
                        tabControls
                            .environment(viewModel)

                        Spacer(minLength: DSSpacing.xxxl)
                    }
                    .padding(.horizontal, DSSpacing.screenPadding)
                }
            }
        }
        .navigationTitle("Border & Decoration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showExportSheet) {
            DecorationExportSheet(viewModel: viewModel, accentColor: accentForTab)
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Tab Strip
    private var tabStrip: some View {
        HStack(spacing: 0) {
            ForEach(DecorationTab.allCases) { tab in
                let isSelected = viewModel.selectedTab == tab
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(tab.rawValue)
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(isSelected ? accentForTab : DSColors.Preview.textTertiary)
                        .padding(.horizontal, DSSpacing.xs)
                        Rectangle()
                            .fill(isSelected ? accentForTab : Color.clear)
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

    // MARK: - Shape Picker
    private var shapePicker: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(PreviewShape.allCases) { shape in
                let isSel = viewModel.selectedShape == shape
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectedShape = shape
                    }
                } label: {
                    Text(shape.rawValue)
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(isSel ? .white : DSColors.Preview.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.xs)
                        .background(
                            isSel ? accentForTab : DSColors.Preview.surfaceDefault,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                                .strokeBorder(
                                    isSel ? Color.clear : DSColors.Preview.borderSubtle,
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSel)
            }
        }
    }

    // MARK: - Inline code strip
    private var inlineCodeStrip: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(accentForTab)

            ScrollView(.horizontal, showsIndicators: false) {
                Text(firstLine(of: viewModel.exportCode))
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                    .lineLimit(1)
            }

            Button {
                viewModel.copyCode()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 13))
                    .foregroundStyle(accentForTab)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(DSColors.Preview.backgroundSecondary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .contentTransition(.opacity)
        .id(viewModel.selectedTab)
    }

    // MARK: - Tab Controls
    @ViewBuilder
    private var tabControls: some View {
        switch viewModel.selectedTab {
        case .corners:
            CornersTabView(vm: viewModel)
                .transition(.opacity)
        case .borders:
            BordersTabView(vm: viewModel)
                .transition(.opacity)
        case .glow:
            GlowTabView(vm: viewModel)
                .transition(.opacity)
        case .patterns:
            PatternsTabView(vm: viewModel)
                .transition(.opacity)
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
                    Label("Reset \(viewModel.selectedTab.rawValue)", systemImage: "arrow.counterclockwise")
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
                .foregroundStyle(accentForTab)
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

    // Helpers
    private func firstLine(of code: String) -> String {
        code.components(separatedBy: "\n")
            .first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty })
            ?? code
    }
}

// MARK: - Export Sheet

struct DecorationExportSheet: View {

    @Bindable var viewModel: BorderDecorationViewModel
    let accentColor: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: DSSpacing.md) {
                        Image(systemName: viewModel.selectedTab.icon)
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(accentColor)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.selectedTab.rawValue)
                                .font(DSTypography.headingMedium)
                                .foregroundStyle(DSColors.Preview.textPrimary)
                            Text(viewModel.activeDescription)
                                .font(DSTypography.codeMedium)
                                .foregroundStyle(DSColors.Preview.textTertiary)
                        }
                        Spacer()
                    }
                    .padding(DSSpacing.screenPadding)

                    Divider().background(DSColors.Preview.borderSubtle)

                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        Text(viewModel.exportCode)
                            .font(DSTypography.codeSmall)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(DSSpacing.md)
                    }

                    Spacer()

                    Button {
                        viewModel.copyCode()
                        dismiss()
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "doc.on.doc.fill")
                            Text("Copy \(viewModel.selectedTab.rawValue) Code")
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
            .navigationTitle("Export")
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
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BorderDecorationView()
    }
}
