//
//  AIPaletteView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI
import SwiftData

struct AIPaletteView: View {

    @State private var vm = AIPaletteViewModel()
    @Environment(\.modelContext) private var modelContext
    private let accent = Color(hex: "#BF5AF2")

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DSSpacing.md) {

                        // 1. API key warning banner
                        if !vm.hasAPIKey { apiKeyBanner }

                        // 2. Prompt input card
                        promptCard

                        // 3. Style + count selectors
                        styleSelectors

                        // 4. Suggestion chips (before generation)
                        if vm.showSuggestions || vm.generationState == .idle {
                            suggestionsSection
                        }

                        // 5. Generating shimmer / error / palette result
                        switch vm.generationState {
                        case .idle:
                            EmptyView()
                        case .generating:
                            generatingShimmer
                        case .success:
                            if let palette = vm.currentPalette {
                                paletteResultCard(palette: palette)
                            }
                        case .error(let msg):
                            errorCard(msg)
                        }

                        Spacer(minLength: DSSpacing.xxxl)
                    }
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.top, DSSpacing.md)
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .navigationTitle("AI Palette")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $vm.showAPIKeySheet)    { APIKeySetupSheet(vm: vm, accentColor: accent) }
        .sheet(isPresented: $vm.showHistorySheet)   { PromptHistorySheet(vm: vm, accentColor: accent) }
        .sheet(item: $vm.showColorDetailFor)        { color in
            ColorDetailSheet(color: color, accentColor: accent) { vm.copyHex($0) }
        }
        .overlay(alignment: .bottom) {
            if vm.showSaveConfirmation { saveToast }
            if let hex = vm.copiedHex  { hexCopiedToast(hex) }
        }
    }

    // MARK: - Prompt Card
    private var promptCard: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accent)
                Text("Describe your palette")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: DSSpacing.xs) {
                TextField("e.g. sunset over the ocean…",
                          text: $vm.promptText,
                          axis: .vertical)
                    .font(DSTypography.bodyMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .lineLimit(1...3)
                    .autocorrectionDisabled()
                    .onSubmit { if vm.canGenerate { vm.generate() } }

                if !vm.promptText.isEmpty {
                    Button { withAnimation { vm.promptText = "" } } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.backgroundSecondary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(
                        vm.promptText.isEmpty ? DSColors.Preview.borderSubtle : accent.opacity(0.5),
                        lineWidth: 1
                    )
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: vm.promptText.isEmpty)

            // Generate button
            HStack(spacing: DSSpacing.sm) {
                if vm.currentPalette != nil {
                    Button { vm.newPrompt() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("New")
                        }
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.vertical, DSSpacing.xs)
                        .background(DSColors.Preview.surfaceDefault, in: Capsule())
                        .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if vm.currentPalette != nil {
                    Button { vm.regenerate() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("Regenerate")
                        }
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(accent)
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.vertical, DSSpacing.xs)
                        .background(accent.opacity(0.1), in: Capsule())
                        .overlay(Capsule().strokeBorder(accent.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                Button { vm.generate() } label: {
                    HStack(spacing: 6) {
                        if vm.isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13, weight: .bold))
                        }
                        Text(vm.isGenerating ? "Generating…" : "Generate")
                            .font(DSTypography.headingSmall)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.xs)
                    .background(
                        vm.canGenerate ? accent : DSColors.Preview.textTertiary,
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
                .disabled(!vm.canGenerate)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: vm.canGenerate)
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

    // MARK: - Style + Count Selectors
    private var styleSelectors: some View {
        VStack(spacing: DSSpacing.sm) {
            // Style row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(PaletteStyle.allCases) { style in
                        let isSel = vm.selectedStyle == style
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                vm.selectedStyle = style
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: style.icon)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(style.rawValue)
                                    .font(DSTypography.labelLarge)
                            }
                            .foregroundStyle(isSel ? .white : DSColors.Preview.textSecondary)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(isSel ? accent : DSColors.Preview.surfaceDefault, in: Capsule())
                            .overlay(Capsule().strokeBorder(
                                isSel ? Color.clear : DSColors.Preview.borderSubtle, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSel)
                    }
                }
            }

            // Color count row
            HStack(spacing: DSSpacing.xs) {
                Text("Colors:")
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                HStack(spacing: DSSpacing.xs) {
                    ForEach(ColorCount.allCases) { count in
                        let isSel = vm.colorCount == count
                        Button {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                vm.colorCount = count
                            }
                        } label: {
                            Text(count.label)
                                .font(DSTypography.codeMedium)
                                .foregroundStyle(isSel ? .white : DSColors.Preview.textSecondary)
                                .frame(width: 32, height: 28)
                                .background(isSel ? accent : DSColors.Preview.surfaceDefault,
                                            in: RoundedRectangle(cornerRadius: 7))
                                .overlay(RoundedRectangle(cornerRadius: 7)
                                    .strokeBorder(isSel ? .clear : DSColors.Preview.borderSubtle, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSel)
                    }
                }
                Spacer()

                // Style hint
                if vm.selectedStyle != .any {
                    Text(vm.selectedStyle.hint)
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                        .lineLimit(1)
                        .transition(.opacity)
                }
            }
        }
    }

    // MARK: - Suggestions
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // Category filter
            HStack {
                Text("Try a prompt:")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Button {
                    withAnimation { vm.selectedSuggestionCategory = nil }
                    vm.refreshSuggestions()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13))
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DSSpacing.xxs)

            // Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    categoryChip(nil, label: "All", icon: "square.grid.2x2")
                    ForEach(SuggestionCategory.allCases, id: \.self) { cat in
                        categoryChip(cat, label: cat.rawValue, icon: cat.icon)
                    }
                }
            }

            // Suggestion chips — 2-column wrapping layout
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: DSSpacing.xs
            ) {
                ForEach(vm.filteredSuggestions) { s in
                    Button { vm.applySuggestion(s) } label: {
                        HStack(spacing: 6) {
                            Image(systemName: s.icon)
                                .font(.system(size: 11))
                                .foregroundStyle(accent)
                            Text(s.text)
                                .font(DSTypography.labelLarge)
                                .foregroundStyle(DSColors.Preview.textSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DSColors.Preview.surfaceDefault,
                                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func categoryChip(_ cat: SuggestionCategory?, label: String, icon: String) -> some View {
        let isSel = vm.selectedSuggestionCategory == cat
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                vm.selectedSuggestionCategory = cat
            }
            vm.refreshSuggestions()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 10))
                Text(label).font(DSTypography.labelSmall)
            }
            .foregroundStyle(isSel ? .white : DSColors.Preview.textTertiary)
            .padding(.horizontal, DSSpacing.xs)
            .padding(.vertical, 4)
            .background(isSel ? accent.opacity(0.8) : DSColors.Preview.backgroundSecondary, in: Capsule())
            .overlay(Capsule().strokeBorder(isSel ? .clear : DSColors.Preview.borderSubtle, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSel)
    }

    // MARK: - Generating Shimmer
    private var generatingShimmer: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                ShimmerView().frame(width: 140, height: 16).clipShape(Capsule())
                Spacer()
                ShimmerView().frame(width: 80, height: 12).clipShape(Capsule())
            }
            ForEach(0..<vm.colorCount.rawValue, id: \.self) { _ in
                ShimmerView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .transition(.opacity)
    }

    // MARK: - Palette Result
    private func paletteResultCard(palette: AIGeneratedPalette) -> some View {
        VStack(spacing: 0) {
            // Palette header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(palette.name)
                        .font(DSTypography.headingMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    Text(palette.mood)
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                        .lineLimit(2)
                }
                Spacer()
                // Save button
                Button { vm.savePalette(context: modelContext) } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Save")
                            .font(DSTypography.headingSmall)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xs)
                    .background(accent, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(DSSpacing.cardPadding)

            // Wide color strip (tap to expand)
            HStack(spacing: 0) {
                ForEach(Array(palette.colors.enumerated()), id: \.element.id) { i, color in
                    let revealed = i < vm.revealedColorCount
                    color.color
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .opacity(revealed ? 1 : 0)
                        .scaleEffect(revealed ? 1 : 0.6, anchor: .bottom)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7)
                            .delay(Double(i) * 0.08), value: vm.revealedColorCount)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 0))

            Divider().background(DSColors.Preview.borderSubtle)

            // Color rows
            VStack(spacing: 0) {
                ForEach(Array(palette.colors.enumerated()), id: \.element.id) { i, color in
                    let revealed = i < vm.revealedColorCount
                    colorRow(color: color, index: i, revealed: revealed)
                    if i < palette.colors.count - 1 {
                        Divider().background(DSColors.Preview.borderSubtle)
                            .padding(.leading, 64)
                    }
                }
            }

            Divider().background(DSColors.Preview.borderSubtle)

            // Footer: prompt + style tags
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11))
                    .foregroundStyle(accent)
                Text("\(palette.prompt)")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                Text(palette.style)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(DSColors.Preview.backgroundSecondary, in: Capsule())
            }
            .padding(.horizontal, DSSpacing.cardPadding)
            .padding(.vertical, DSSpacing.sm)
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        ))
    }

    private func colorRow(color: AIColor, index: Int, revealed: Bool) -> some View {
        HStack(spacing: DSSpacing.sm) {
            // Swatch
            RoundedRectangle(cornerRadius: 10)
                .fill(color.color)
                .frame(width: 48, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: color.color.opacity(0.3), radius: 4, x: 0, y: 2)

            // Name + role + usage
            VStack(alignment: .leading, spacing: 3) {
                Text(color.name)
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                HStack(spacing: 6) {
                    Text(color.hex.uppercased())
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                    Text("·")
                        .foregroundStyle(DSColors.Preview.textTertiary)
                    Text(color.role)
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(accent.opacity(0.8))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(accent.opacity(0.1), in: Capsule())
                }
                Text(color.usage)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            // Copy hex
            Button { vm.copyHex(color.hex) } label: {
                Image(systemName: vm.copiedHex == color.hex
                      ? "checkmark.circle.fill" : "doc.on.doc")
                    .font(.system(size: 14))
                    .foregroundStyle(vm.copiedHex == color.hex ? DSColors.Preview.success : DSColors.Preview.textTertiary)
            }
            .buttonStyle(.plain)

            // Detail
            Button { vm.showColorDetailFor = color } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .opacity(revealed ? 1 : 0)
        .offset(y: revealed ? 0 : 12)
        .animation(.spring(response: 0.4, dampingFraction: 0.75)
            .delay(Double(index) * 0.08), value: vm.revealedColorCount)
    }

    // MARK: - Error Card
    private func errorCard(_ message: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DSColors.Preview.error)
            VStack(alignment: .leading, spacing: 3) {
                Text("Generation failed")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text(message)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button {
                withAnimation { vm.generationState = .idle }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.md)
        .background(DSColors.Preview.error.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.error.opacity(0.25), lineWidth: 1)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            // Provider picker button
            Menu {
                ForEach(AIProvider.allCases) { provider in
                    Button {
                        vm.switchProvider(to: provider)
                    } label: {
                        HStack {
                            Image(systemName: provider.icon)
                            Text(provider.rawValue)
                            if vm.selectedProvider == provider {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: vm.selectedProvider.icon)
                        .foregroundStyle(accent)
                    Text(vm.selectedProvider.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            if !vm.promptHistory.isEmpty {
                Button { vm.showHistorySheet = true } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button { vm.showAPIKeySheet = true } label: {
                Image(systemName: vm.hasAPIKey ? "key.fill" : "key")
                    .foregroundStyle(vm.hasAPIKey ? accent : DSColors.Preview.error)
            }
        }
    }

    // Update the apiKeyBanner to show current provider:
    private var apiKeyBanner: some View {
        Button { vm.showAPIKeySheet = true } label: {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: vm.selectedProvider.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(accent, in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    if vm.selectedProvider.requiresKey {
                        Text("Add \(vm.selectedProvider.rawValue) API Key")
                            .font(DSTypography.headingSmall)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                        Text("Required to generate AI palettes")
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    } else {
                        Text("\(vm.selectedProvider.rawValue) Ready")
                            .font(DSTypography.headingSmall)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                        Text("No API key needed - tap to configure optional key")
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .padding(DSSpacing.sm)
            .background(accent.opacity(vm.selectedProvider.requiresKey && !vm.hasAPIKey ? 0.08 : 0.04), in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                    .strokeBorder(accent.opacity(vm.selectedProvider.requiresKey && !vm.hasAPIKey ? 0.25 : 0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toasts
    private var saveToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "bookmark.fill").foregroundStyle(DSColors.Preview.success)
            Text("Palette saved!")
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
        .padding(.bottom, DSSpacing.xl)
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity))
    }

    private func hexCopiedToast(_ hex: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Circle().fill(Color(hex: hex)).frame(width: 16, height: 16)
            Text("\(hex) copied")
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
        .padding(.bottom, DSSpacing.xl)
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity))
    }
}

// MARK: - Shimmer View

struct ShimmerView: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            let gradient = LinearGradient(
                stops: [
                    .init(color: DSColors.Preview.backgroundSecondary, location: 0),
                    .init(color: DSColors.Preview.backgroundTertiary,  location: 0.4),
                    .init(color: DSColors.Preview.backgroundSecondary, location: 0.8),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            Rectangle()
                .fill(DSColors.Preview.backgroundSecondary)
                .overlay(
                    gradient
                        .frame(width: geo.size.width * 2)
                        .offset(x: geo.size.width * phase)
                )
        }
        .onAppear {
            withAnimation(
                .linear(duration: 1.4).repeatForever(autoreverses: false)
            ) { phase = 1 }
        }
    }
}

// MARK: - API Key Setup Sheet (Multi-Provider)

struct APIKeySetupSheet: View {
    @Bindable var vm: AIPaletteViewModel
    let accentColor: Color
    @Environment(\.dismiss) private var dismiss
    @FocusState private var fieldFocused: Bool
    
    // Local state for provider selection within sheet
    @State private var selectedProvider: AIProvider = .anthropic

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: DSSpacing.xl) {
                    
                    // Provider selector
                    Picker("Provider", selection: $selectedProvider) {
                        ForEach(AIProvider.allCases) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .onChange(of: selectedProvider) { _, newProvider in
                        vm.providerBeingConfigured = newProvider
                        vm.apiKeyInput = "" // Clear when switching
                    }

                    // Icon
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: selectedProvider.icon)
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(accentColor)
                    }
                    .padding(.top, DSSpacing.sm)

                    VStack(spacing: DSSpacing.sm) {
                        Text("\(selectedProvider.rawValue) API Key")
                            .font(DSTypography.headingLarge)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                        Text(selectedProvider.description)
                            .font(DSTypography.bodySmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DSSpacing.md)
                    }

                    // Key input
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("API Key")
                            .font(DSTypography.labelLarge)
                            .foregroundStyle(DSColors.Preview.textSecondary)
                        
                        if selectedProvider == .openrouter {
                                Text("Optional - only needed for higher rate limits")
                                    .font(DSTypography.labelSmall)
                                    .foregroundStyle(DSColors.Preview.textTertiary)
                            }
                        SecureField(selectedProvider.keyPlaceholder, text: $vm.apiKeyInput)
                            .font(DSTypography.codeMedium)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($fieldFocused)
                            .padding(DSSpacing.sm)
                            .background(DSColors.Preview.backgroundSecondary,
                                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                            .overlay(
                                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                                    .strokeBorder(
                                        fieldFocused ? accentColor.opacity(0.5) : DSColors.Preview.borderSubtle,
                                        lineWidth: 1
                                    )
                            )
                        
                        // Validation hint
                        if !vm.apiKeyInput.isEmpty && !vm.apiKeyInput.hasPrefix(selectedProvider.keyPrefix) {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(DSColors.Preview.error)
                                Text("Key should start with \(selectedProvider.keyPrefix)")
                                    .font(DSTypography.labelSmall)
                                    .foregroundStyle(DSColors.Preview.error)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, DSSpacing.screenPadding)

                    // Current key display for selected provider
                    let currentKey = getCurrentKey(for: selectedProvider)
                    if !currentKey.isEmpty {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(DSColors.Preview.success)
                            Text("Current: \(ProviderKeyStore.maskedDisplay(currentKey, for: selectedProvider))")
                                .font(DSTypography.codeMedium)
                                .foregroundStyle(DSColors.Preview.textTertiary)
                            Spacer()
                            Button("Clear") {
                                vm.clearAPIKey(for: selectedProvider)
                            }
                            .font(DSTypography.labelLarge)
                            .foregroundStyle(DSColors.Preview.error)
                        }
                        .padding(.horizontal, DSSpacing.screenPadding)
                    }

                    // Save button
                    Button {
                        vm.saveAPIKey()
                    } label: {
                        Text("Save Key")
                            .font(DSTypography.headingSmall)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.sm)
                            .background(
                                vm.apiKeyInput.isEmpty ? DSColors.Preview.textTertiary : accentColor,
                                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(vm.apiKeyInput.isEmpty)
                    .padding(.horizontal, DSSpacing.screenPadding)

                    // Get key link
                    Link(destination: URL(string: selectedProvider.helpURL)!) {
                        HStack(spacing: 4) {
                            Image(systemName: "safari")
                            Text("Get a key at \(URL(string: selectedProvider.helpURL)!.host ?? "")")
                        }
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(accentColor)
                    }

                    Spacer()
                }
            }
            .navigationTitle("API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(accentColor)
                }
            }
            .onAppear {
                fieldFocused = true
                // Initialize with current provider if not set
                if vm.providerBeingConfigured == nil {
                    vm.providerBeingConfigured = vm.selectedProvider
                }
                selectedProvider = vm.providerBeingConfigured ?? .anthropic
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }
    
    private func getCurrentKey(for provider: AIProvider) -> String {
        switch provider {
        case .anthropic: return vm.anthropicKey
        case .gemini: return vm.geminiKey
        case .openrouter: return vm.openrouterKey
        }
    }
}

// MARK: - Color Detail Sheet

struct ColorDetailSheet: View {
    let color: AIColor
    let accentColor: Color
    let onCopy: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: DSSpacing.xl) {

                    // Large swatch
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.lg)
                        .fill(color.color)
                        .frame(height: 160)
                        .overlay(
                            VStack {
                                Text(color.name)
                                    .font(DSTypography.headingLarge)
                                    .foregroundStyle(color.onColor)
                                Text(color.hex.uppercased())
                                    .font(DSTypography.codeMedium)
                                    .foregroundStyle(color.onColor.opacity(0.7))
                            }
                        )
                        .shadow(color: color.color.opacity(0.4), radius: 16, x: 0, y: 8)
                        .padding(.horizontal, DSSpacing.screenPadding)
                        .padding(.top, DSSpacing.md)

                    // Properties
                    VStack(spacing: 0) {
                        detailRow("Role",    value: color.role,  icon: "tag")
                        Divider().background(DSColors.Preview.borderSubtle)
                        detailRow("Usage",   value: color.usage, icon: "pencil.and.ruler")
                        Divider().background(DSColors.Preview.borderSubtle)
                        detailRow("Hex",     value: color.hex.uppercased(), icon: "number")
                        Divider().background(DSColors.Preview.borderSubtle)
                        let r = Int(color.red   * 255)
                        let g = Int(color.green * 255)
                        let b = Int(color.blue  * 255)
                        detailRow("RGB", value: "R:\(r) G:\(g) B:\(b)", icon: "slider.horizontal.3")
                    }
                    .background(DSColors.Preview.surfaceDefault,
                                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                            .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
                    )
                    .padding(.horizontal, DSSpacing.screenPadding)

                    // Copy button
                    Button { onCopy(color.hex); dismiss() } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "doc.on.doc.fill")
                            Text("Copy \(color.hex.uppercased())")
                                .font(DSTypography.headingSmall)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                        .background(accentColor, in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, DSSpacing.screenPadding)

                    Spacer()
                }
            }
            .navigationTitle(color.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(accentColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }

    private func detailRow(_ label: String, value: String, icon: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: 20)
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 50, alignment: .leading)
            Spacer()
            Text(value)
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
    }
}

// MARK: - Prompt History Sheet

struct PromptHistorySheet: View {
    @Bindable var vm: AIPaletteViewModel
    let accentColor: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                if vm.promptHistory.isEmpty {
                    VStack(spacing: DSSpacing.md) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 40, weight: .light))
                            .foregroundStyle(accentColor.opacity(0.4))
                        Text("No history yet")
                            .font(DSTypography.headingMedium)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                } else {
                    List {
                        ForEach(vm.promptHistory) { entry in
                            Button { vm.applyHistoryEntry(entry) } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.paletteName)
                                        .font(DSTypography.headingSmall)
                                        .foregroundStyle(DSColors.Preview.textPrimary)
                                    Text("\(entry.prompt)")
                                        .font(DSTypography.bodySmall)
                                        .foregroundStyle(DSColors.Preview.textSecondary)
                                        .lineLimit(1)
                                    HStack(spacing: 8) {
                                        Text(entry.style)
                                        Text("·")
                                        Text("\(entry.colorCount) colors")
                                    }
                                    .font(DSTypography.labelSmall)
                                    .foregroundStyle(DSColors.Preview.textTertiary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !vm.promptHistory.isEmpty {
                        Button("Clear", role: .destructive) { vm.clearHistory() }
                            .foregroundStyle(DSColors.Preview.error)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(accentColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AIPaletteView()
    }
    .modelContainer(for: [SavedPalette.self, SavedColor.self], inMemory: true)
}
