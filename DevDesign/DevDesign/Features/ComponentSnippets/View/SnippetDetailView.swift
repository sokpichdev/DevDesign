//
//  SnippetDetailView.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import SwiftUI

struct SnippetDetailView: View {

    let snippet: CuratedSnippet
    @Bindable var viewModel: SnippetViewModel

    @State private var showFullCode: Bool = true

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Preview card
                    previewCard

                    // 2. Accent colour customiser
                    accentCard

                    // 3. Code block
                    codeCard

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle(snippet.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Preview Card
    private var previewCard: some View {
        ZStack {
            // Checkerboard bg
            DSColors.Preview.backgroundSecondary

            VStack(spacing: DSSpacing.md) {
                Image(systemName: snippet.previewSymbol)
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(viewModel.accentColor)

                VStack(spacing: DSSpacing.xs) {
                    Text(snippet.title)
                        .font(DSTypography.headingMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    Text(snippet.subtitle)
                        .font(DSTypography.bodySmall)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }
            .padding(DSSpacing.lg)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Accent Card
    private var accentCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Accent Color")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)

            HStack(spacing: DSSpacing.md) {
                // Color picker
                let accentBinding = Binding<Color>(
                    get: { viewModel.accentColor },
                    set: { viewModel.accentColor = $0 }
                )
                ColorPicker("Accent", selection: accentBinding, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 44, height: 36)

                // Hex readout
                Text("#\(viewModel.accentHex())")
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)

                Spacer()

                // Quick presets
                HStack(spacing: DSSpacing.xs) {
                    ForEach(accentPresets, id: \.self) { hex in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                viewModel.accentColor = Color(hex: hex)
                            }
                        } label: {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle().strokeBorder(
                                        viewModel.accentHex().uppercased() == hex.uppercased()
                                            ? DSColors.Preview.textPrimary : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
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

    private let accentPresets = ["7B6EF6", "FF6B6B", "30D158", "FF9F0A", "64D2FF", "BF5AF2"]

    // MARK: - Code Card
    private var codeCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Code")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)

                Spacer()

                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.xs) {
                        ForEach(snippet.tags.prefix(4), id: \.self) { tag in
                            Text(tag)
                                .font(DSTypography.labelSmall)
                                .foregroundStyle(DSColors.Preview.textTertiary)
                                .padding(.horizontal, DSSpacing.xs)
                                .padding(.vertical, 3)
                                .background(DSColors.Preview.backgroundTertiary, in: Capsule())
                        }
                    }
                }
            }

            // Code block
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                Text(viewModel.resolvedCode(snippet.code))
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 360)
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.backgroundPrimary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )

            // Copy button
            Button {
                viewModel.copyCurated(snippet)
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "doc.on.doc.fill")
                    Text("Copy Code")
                        .font(DSTypography.headingSmall)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
                .background(viewModel.accentColor,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
                .animation(.easeInOut(duration: 0.2), value: viewModel.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.copyCurated(snippet)
            } label: {
                Image(systemName: "doc.on.doc")
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
