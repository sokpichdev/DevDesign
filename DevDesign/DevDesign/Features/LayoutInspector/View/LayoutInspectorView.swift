//
//  LayoutInspectorView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct LayoutInspectorView: View {

    @State private var viewModel = LayoutViewModel()

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Tab strip
                tabStrip
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.vertical, DSSpacing.sm)

                Divider().background(DSColors.Preview.borderSubtle)

                // Content
                tabContent
                    .animation(.spring(response: 0.3, dampingFraction: 0.9),
                               value: viewModel.selectedTab)
            }
        }
        .navigationTitle("Layout Inspector")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showExportSheet) {
            exportSheet
        }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Tab Strip
    private var tabStrip: some View {
        HStack(spacing: 0) {
            ForEach(LayoutInspectorTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(3)
        .background(DSColors.Preview.backgroundSecondary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm + 3))
    }

    private func tabButton(_ tab: LayoutInspectorTab) -> some View {
        let isSelected = viewModel.selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectedTab = tab
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(tab.rawValue)
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(isSelected ? DSColors.Preview.textPrimary : DSColors.Preview.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.xs)
            .background(
                isSelected ? DSColors.Preview.surfaceDefault : Color.clear,
                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
            )
            .shadow(
                color: isSelected ? .black.opacity(0.08) : .clear,
                radius: 4, x: 0, y: 1
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .playground:
            StackPlaygroundView(viewModel: viewModel)
                .transition(.move(edge: .leading).combined(with: .opacity))
        case .patterns:
            LayoutPatternsView(viewModel: viewModel)
                .transition(.opacity)
        case .safeArea:
            SafeAreaInspectorView()
                .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if viewModel.selectedTab == .playground {
                Menu {
                    Button {
                        withAnimation { viewModel.resetPlayground() }
                    } label: {
                        Label("Reset Playground", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            if viewModel.selectedTab == .playground {
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
    }

    // MARK: - Export Sheet
    private var exportSheet: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: 0) {

                    // Header: stack type + child summary
                    HStack(spacing: DSSpacing.md) {
                        Image(systemName: viewModel.config.type.icon)
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(DSColors.Preview.accent)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.config.type.rawValue)
                                .font(DSTypography.headingMedium)
                                .foregroundStyle(DSColors.Preview.textPrimary)
                            Text("\(viewModel.config.children.count) children · alignment: .\(viewModel.config.alignment.rawValue) · spacing: \(Int(viewModel.config.spacing))pt")
                                .font(DSTypography.labelSmall)
                                .foregroundStyle(DSColors.Preview.textTertiary)
                        }
                        Spacer()
                    }
                    .padding(DSSpacing.screenPadding)

                    Divider().background(DSColors.Preview.borderSubtle)

                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        Text(viewModel.exportedCode())
                            .font(DSTypography.codeSmall)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .padding(DSSpacing.md)

                    Spacer()

                    Button {
                        viewModel.copyExport()
                        viewModel.showExportSheet = false
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "doc.on.doc.fill")
                            Text("Copy Code")
                                .font(DSTypography.headingSmall)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                        .background(DSColors.Preview.accent,
                                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
                    }
                    .buttonStyle(.plain)
                    .padding(DSSpacing.screenPadding)
                }
            }
            .navigationTitle("Export Layout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { viewModel.showExportSheet = false }
                        .foregroundStyle(DSColors.Preview.accent)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
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

#Preview {
    NavigationStack {
        LayoutInspectorView()
    }
}
