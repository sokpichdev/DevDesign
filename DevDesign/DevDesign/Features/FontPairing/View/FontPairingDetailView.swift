//
//  FontPairingDetailView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Full detail view for a font pairing:
//   - Editable sample text
//   - Adjustable display + body sizes
//   - Live preview at multiple levels
//   - SwiftUI / CSS export

import SwiftUI

struct FontPairingDetailView: View {

    let pair: FontPair
    @Bindable var viewModel: FontPairingViewModel
    @Environment(\.dismiss) private var dismiss

    // Editable state
    @State private var sampleHeading: String  = "The quick brown fox"
    @State private var sampleBody: String     = "The quick brown fox jumps over the lazy dog. Sphinx of black quartz, judge my vow. Pack my box with five dozen liquor jugs."
    @State private var displaySize: CGFloat   = 32
    @State private var bodySize: CGFloat      = 16
    @State private var selectedExport: ExportMode = .swiftUI
    @State private var showExportPanel: Bool  = false
    @State private var showCopied: Bool       = false
    @FocusState private var headingFocused: Bool
    @FocusState private var bodyFocused: Bool

    enum ExportMode: String, CaseIterable, Identifiable {
        case swiftUI = "SwiftUI"
        case css     = "CSS"
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // Font pair header card
                    pairHeaderCard

                    // Size controls
                    sizeControlsCard

                    // Live preview
                    livePreviewCard

                    // Type specimen
                    typeSpecimenCard

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle(pair.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showExportPanel) { exportSheet }
        .overlay(alignment: .bottom) {
            if showCopied { copiedToast }
        }
        .onAppear { viewModel.loadFonts(for: pair) }
    }

    // MARK: - Pair Header Card
    private var pairHeaderCard: some View {
        HStack(spacing: DSSpacing.md) {

            // Display font spec
            fontSpecChip(
                label: "Display",
                name: pair.displayFont.displayName,
                isSystem: pair.displayFont.isSystem,
                isLoaded: pair.displayFont.isLoaded
            )

            Image(systemName: "plus")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DSColors.Preview.textTertiary)

            // Body font spec
            fontSpecChip(
                label: "Body",
                name: pair.bodyFont.displayName,
                isSystem: pair.bodyFont.isSystem,
                isLoaded: pair.bodyFont.isLoaded
            )

            Spacer()

            // Category badge
            Label(pair.category.rawValue, systemImage: pair.category.icon)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.accent)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xxs)
                .background(DSColors.Preview.accentMuted, in: Capsule())
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func fontSpecChip(label: String, name: String, isSystem: Bool, isLoaded: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
            HStack(spacing: 4) {
                Text(name)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                if isSystem {
                    Text("system")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(DSColors.Preview.backgroundTertiary, in: Capsule())
                } else if !isLoaded {
                    ProgressView().scaleEffect(0.5)
                }
            }
        }
    }

    // MARK: - Size Controls
    private var sizeControlsCard: some View {
        VStack(spacing: DSSpacing.sm) {
            sizeRow(
                label: "Display Size",
                value: $displaySize,
                range: 20...64,
                step: 1
            )
            Divider().background(DSColors.Preview.borderSubtle)
            sizeRow(
                label: "Body Size",
                value: $bodySize,
                range: 10...24,
                step: 0.5
            )
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func sizeRow(label: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 100, alignment: .leading)

            Slider(value: value, in: range, step: step)
                .tint(DSColors.Preview.accent)

            Text(String(format: "%.0fpt", value.wrappedValue))
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.accent)
                .frame(width: 40, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: value.wrappedValue)
        }
    }

    // MARK: - Live Preview Card (Editable)
    private var livePreviewCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {

            HStack {
                Text("Preview")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Text("Tap text to edit")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            // Editable display text
            TextField("Heading", text: $sampleHeading, axis: .vertical)
                .font(previewDisplayFont)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .focused($headingFocused)
                .submitLabel(.done)

            // Editable body text
            TextField("Body text", text: $sampleBody, axis: .vertical)
                .font(previewBodyFont)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .lineSpacing(4)
                .focused($bodyFocused)
                .submitLabel(.done)
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(
                    (headingFocused || bodyFocused)
                        ? DSColors.Preview.accent
                        : DSColors.Preview.borderSubtle,
                    lineWidth: headingFocused || bodyFocused ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.15), value: headingFocused || bodyFocused)
        .onTapGesture { headingFocused = false; bodyFocused = false }
    }

    // MARK: - Type Specimen
    // Shows all nine heading levels + body paragraph — like a classic type specimen sheet.
    private var typeSpecimenCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {

            Text("Specimen")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)

            Divider().background(DSColors.Preview.borderSubtle)

            ForEach([64, 48, 36, 28, 22, 18].map(CGFloat.init), id: \.self) { size in
                specimenRow(size: size)
            }

            Divider().background(DSColors.Preview.borderSubtle)

            // Body paragraph
            Text("Body — \(Int(bodySize))pt · \(pair.bodyFont.displayName)")
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)

            Text("The quick brown fox jumps over the lazy dog. Sphinx of black quartz, judge my vow. Pack my box with five dozen liquor jugs.")
                .font(previewBodyFont)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .lineSpacing(4)
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func specimenRow(size: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(String(format: "%.0f", size))
                .font(DSTypography.codeSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .frame(width: 28, alignment: .trailing)

            Text("Aa — \(pair.displayFont.displayName)")
                .font(makePairFont(spec: pair.displayFont, size: size, bold: size >= 36))
                .foregroundStyle(DSColors.Preview.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    // MARK: - Export Sheet
    private var exportSheet: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: 0) {

                    // Mode toggle
                    Picker("Format", selection: $selectedExport) {
                        ForEach(ExportMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(DSSpacing.screenPadding)

                    Divider()

                    // Code
                    ScrollView([.vertical, .horizontal]) {
                        Text(exportCode)
                            .font(DSTypography.codeSmall)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(DSSpacing.sm)
                    }
                    .background(DSColors.Preview.backgroundPrimary)

                    Spacer()

                    // Copy button
                    Button {
                        UIPasteboard.general.string = exportCode
                        showExportPanel = false
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showCopied = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { showCopied = false }
                        }
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "doc.on.doc.fill")
                            Text("Copy \(selectedExport.rawValue)")
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
            .navigationTitle("Export Pairing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showExportPanel = false }
                        .foregroundStyle(DSColors.Preview.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var exportCode: String {
        switch selectedExport {
        case .swiftUI: return FontPairingExportService.exportSwiftUI(
            pair, displaySize: displaySize, bodySize: bodySize)
        case .css:     return FontPairingExportService.exportCSS(pair)
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showExportPanel = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                        .font(DSTypography.labelLarge)
                }
            }
            .foregroundStyle(DSColors.Preview.accent)
        }
    }

    // MARK: - Toast
    private var copiedToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DSColors.Preview.success)
            Text("Copied!")
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

    // MARK: - Font Helpers
    private var previewDisplayFont: Font {
        makePairFont(spec: pair.displayFont, size: displaySize, bold: true)
    }

    private var previewBodyFont: Font {
        makePairFont(spec: pair.bodyFont, size: bodySize, bold: false)
    }

    private func makePairFont(spec: FontSpec, size: CGFloat, bold: Bool) -> Font {
        Font(spec.uiFont(size: size, weight: bold ? .bold : .regular))
    }
}
