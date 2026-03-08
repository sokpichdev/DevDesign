//
//  CodePreviewPanelView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// The star of the Color Picker screen:
//   • Format tabs (SwiftUI / UIKit / CSS / HEX / RGB / HSL / Android)
//   • Syntax-coloured code output
//   • One-tap copy with animated feedback
//   • Dark / Light context preview

import SwiftUI

struct CodePreviewPanelView: View {

    @Bindable var viewModel: ColorPickerViewModel

    var body: some View {
        VStack(spacing: 0) {

            // ── Format tab strip ─────────────────────────────────
            formatTabStrip

            Divider()
                .background(DSColors.Preview.borderSubtle)

            // ── Code output ──────────────────────────────────────
            codeOutput

            Divider()
                .background(DSColors.Preview.borderSubtle)

            // ── Footer: description + copy button ────────────────
            footer
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Format Tab Strip
    private var formatTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(ExportFormat.allCases) { format in
                    formatTab(format)
                }
            }
            .padding(.horizontal, DSSpacing.xs)
        }
        .frame(height: 44)
    }

    private func formatTab(_ format: ExportFormat) -> some View {
        let isSelected = viewModel.selectedFormat == format

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.selectedFormat = format
            }
        } label: {
            VStack(spacing: 3) {
                Text(format.rawValue)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(
                        isSelected ? DSColors.Preview.accent : DSColors.Preview.textTertiary
                    )
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.top, DSSpacing.xs)

                // Active underline indicator
                Rectangle()
                    .fill(isSelected ? DSColors.Preview.accent : Color.clear)
                    .frame(height: 2)
                    .clipShape(Capsule())
                    .padding(.horizontal, DSSpacing.sm)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }

    // MARK: - Code Output
    private var codeOutput: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {

            // Line number
            Text("1")
                .font(DSTypography.codeSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .frame(width: 18, alignment: .trailing)
                .padding(.top, 1)

            // Syntax-coloured code
            syntaxHighlighted(viewModel.exportedCode, format: viewModel.selectedFormat)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)    // long-press to select & copy natively too
        }
        .padding(DSSpacing.md)
        .frame(minHeight: 72)
        .background(DSColors.Preview.backgroundPrimary)
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.15), value: viewModel.selectedFormat)
    }

    // MARK: - Syntax Highlighting
    // Lightweight token colouring — no external deps needed.
    @ViewBuilder
    private func syntaxHighlighted(_ code: String, format: ExportFormat) -> some View {
        switch format {
        case .swiftUI, .uiKit:
            swiftSyntax(code)
        case .css:
            cssSyntax(code)
        case .hex:
            hexSyntax(code)
        case .rgb, .hsl:
            plainColoured(code)
        case .androidXML:
            hexSyntax(code)
        }
    }

    /// Swift-style: type names in accent, numbers in warning, punctuation dimmed
    private func swiftSyntax(_ code: String) -> some View {
        // Build an AttributedString with manual colouring
        var attr = AttributedString(code)
        attr.font = DSTypography.codeMedium
        attr.foregroundColor = UIColor(DSColors.Preview.textPrimary)

        // Keyword / type tokens
        let typeTokens = ["Color", "UIColor", ".sRGB"]
        for token in typeTokens {
            var searchRange = attr.startIndex..<attr.endIndex
            while let range = attr[searchRange].range(of: token) {
                attr[range].foregroundColor = UIColor(DSColors.Preview.accent)
                searchRange = range.upperBound..<attr.endIndex
            }
        }

        // Parameter labels
        let labels = ["red:", "green:", "blue:", "opacity:", "alpha:", "white:"]
        for label in labels {
            var searchRange = attr.startIndex..<attr.endIndex
            while let range = attr[searchRange].range(of: label) {
                attr[range].foregroundColor = UIColor(DSColors.Preview.warning)
                searchRange = range.upperBound..<attr.endIndex
            }
        }

        return Text(attr)
    }

    /// CSS: function name in accent, numbers in warning
    private func cssSyntax(_ code: String) -> some View {
        var attr = AttributedString(code)
        attr.font = DSTypography.codeMedium
        attr.foregroundColor = UIColor(DSColors.Preview.textPrimary)

        let fnTokens = ["rgb(", "rgba(", "hsl(", "hsla("]
        for token in fnTokens {
            var searchRange = attr.startIndex..<attr.endIndex
            while let range = attr[searchRange].range(of: token) {
                attr[range].foregroundColor = UIColor(DSColors.Preview.accent)
                searchRange = range.upperBound..<attr.endIndex
            }
        }
        return Text(attr)
    }

    /// HEX: hash in tertiary, hex digits in primary
    private func hexSyntax(_ code: String) -> some View {
        var attr = AttributedString(code)
        attr.font = DSTypography.codeLarge
        attr.foregroundColor = UIColor(DSColors.Preview.textPrimary)

        if let hashRange = attr.range(of: "#") {
            attr[hashRange].foregroundColor = UIColor(DSColors.Preview.textTertiary)
        }
        return Text(attr)
    }

    /// Plain with accent tint — for RGB / HSL labels
    private func plainColoured(_ code: String) -> some View {
        Text(code)
            .font(DSTypography.codeMedium)
            .foregroundStyle(DSColors.Preview.textPrimary)
    }

    // MARK: - Footer
    private var footer: some View {
        HStack(spacing: DSSpacing.sm) {

            // Format hint
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.selectedFormat.rawValue)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text(viewModel.formatDescription)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.15), value: viewModel.selectedFormat)

            Spacer()

            // Copy button
            copyButton
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
    }

    private var copyButton: some View {
        Button { viewModel.copyCurrentExport() } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: viewModel.showCopiedFeedback ? "checkmark" : "doc.on.doc.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))

                Text(viewModel.showCopiedFeedback ? "Copied!" : "Copy")
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(viewModel.showCopiedFeedback ? DSColors.Preview.success : .white)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.xs)
            .background(
                viewModel.showCopiedFeedback
                    ? DSColors.Preview.success.opacity(0.2)
                    : DSColors.Preview.accent,
                in: Capsule()
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showCopiedFeedback)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        DSColors.Preview.backgroundPrimary.ignoresSafeArea()
        CodePreviewPanelView(viewModel: ColorPickerViewModel())
            .padding()
    }
}
