//
//  PaletteExportSheet.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Bottom sheet for exporting a palette in multiple formats.

import SwiftUI

struct PaletteExportSheet: View {

    let palette: SavedPalette
    @Bindable var viewModel: SavedPalettesViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: ExportTab = .swiftUI
    @State private var shareImage: UIImage? = nil
    @State private var showShareSheet: Bool = false

    enum ExportTab: String, CaseIterable, Identifiable {
        case swiftUI = "SwiftUI"
        case css     = "CSS"
        case json    = "JSON"
        case image   = "Image"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {

                    // Palette swatch strip
                    swatchStrip
                        .padding(.horizontal, DSSpacing.screenPadding)
                        .padding(.top, DSSpacing.md)

                    // Format tab strip
                    exportTabStrip
                        .padding(.top, DSSpacing.md)

                    Divider().background(DSColors.Preview.borderSubtle)

                    // Code / image preview
                    exportContent
                        .padding(DSSpacing.screenPadding)

                    Spacer()

                    // Action buttons
                    actionButtons
                        .padding(DSSpacing.screenPadding)
                }
            }
            .navigationTitle("Export \(palette.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(DSColors.Preview.accent)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ShareSheet(items: [img])
            }
        }
    }

    // MARK: - Swatch Strip
    private var swatchStrip: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(palette.colors, id: \.id) { color in
                RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                    .fill(Color(red: color.red, green: color.green, blue: color.blue))
                    .frame(height: 44)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Tab Strip
    private var exportTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(ExportTab.allCases) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
        }
        .frame(height: 40)
    }

    private func tabButton(_ tab: ExportTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Text(tab.rawValue)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(isSelected ? DSColors.Preview.accent : DSColors.Preview.textTertiary)
                    .padding(.horizontal, DSSpacing.sm)

                Rectangle()
                    .fill(isSelected ? DSColors.Preview.accent : Color.clear)
                    .frame(height: 2)
                    .clipShape(Capsule())
                    .padding(.horizontal, DSSpacing.sm)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Export Content
    @ViewBuilder
    private var exportContent: some View {
        switch selectedTab {
        case .swiftUI:
            codeBlock(viewModel.exportAsSwiftUI(palette))
        case .css:
            codeBlock(viewModel.exportAsCSS(palette))
        case .json:
            codeBlock(viewModel.exportAsJSON(palette))
        case .image:
            imagePreview
        }
    }

    private func codeBlock(_ code: String) -> some View {
        ScrollView([.vertical, .horizontal], showsIndicators: true) {
            Text(code)
                .font(DSTypography.codeSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .frame(maxHeight: 280)
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.backgroundPrimary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.15), value: selectedTab)
    }

    private var imagePreview: some View {
        VStack(spacing: DSSpacing.sm) {
            // Rendered swatch strip preview
            HStack(spacing: 0) {
                ForEach(palette.colors, id: \.id) { color in
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(Color(red: color.red, green: color.green, blue: color.blue))
                            .frame(height: 100)

                        Text(color.hex)
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.bottom, 6)
                            .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )

            Text("Tap **Share Image** to save or send")
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
        }
        .transition(.opacity)
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtons: some View {
        switch selectedTab {
        case .swiftUI:
            copyButton(label: "Copy SwiftUI") {
                viewModel.copyToClipboard(viewModel.exportAsSwiftUI(palette), label: "SwiftUI")
            }
        case .css:
            copyButton(label: "Copy CSS") {
                viewModel.copyToClipboard(viewModel.exportAsCSS(palette), label: "CSS")
            }
        case .json:
            copyButton(label: "Copy JSON") {
                viewModel.copyToClipboard(viewModel.exportAsJSON(palette), label: "JSON")
            }
        case .image:
            shareImageButton
        }
    }

    private func copyButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "doc.on.doc.fill")
                Text(label)
                    .font(DSTypography.headingSmall)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.Preview.accent,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        }
        .buttonStyle(.plain)
    }

    private var shareImageButton: some View {
        Button {
            Task {
                shareImage = await viewModel.renderPaletteImage(palette)
                showShareSheet = true
            }
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "square.and.arrow.up")
                Text("Share Image")
                    .font(DSTypography.headingSmall)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.Preview.accent,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - UIActivityViewController wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
