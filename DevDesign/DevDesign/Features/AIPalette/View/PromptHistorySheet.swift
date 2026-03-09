//
//  PromptHistorySheet.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import SwiftUI
import SwiftData

// MARK: - History list sheet

struct PromptHistorySheet: View {
    @Bindable var vm: AIPaletteViewModel
    let accentColor: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                if vm.promptHistory.isEmpty {
                    emptyState
                } else {
                    historyList
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

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(accentColor.opacity(0.4))
            Text("No history yet")
                .font(DSTypography.headingMedium)
                .foregroundStyle(DSColors.Preview.textTertiary)
            Text("Generated palettes will appear here")
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
        }
    }

    // MARK: - History list

    private var historyList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: DSSpacing.sm) {
                ForEach(vm.promptHistory) { entry in
                    NavigationLink {
                        HistoryPaletteDetailView(entry: entry, vm: vm, accentColor: accentColor)
                    } label: {
                        historyCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.vertical, DSSpacing.sm)
        }
    }

    private func historyCard(entry: PromptHistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // Color strip
            if !entry.colors.isEmpty {
                HStack(spacing: 0) {
                    ForEach(entry.colors) { color in
                        color.color.frame(maxWidth: .infinity).frame(height: 48)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
                )
            }
            // Name + prompt
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.paletteName)
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .lineLimit(1)
                Text(entry.prompt)
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                    .lineLimit(1)
            }
            // Meta
            HStack(spacing: 6) {
                Text(entry.style)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(accentColor.opacity(0.9))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(accentColor.opacity(0.1), in: Capsule())
                Text("·")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                Text("\(entry.colorCount) colors")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
        }
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Detail view (pushed from history list)

struct HistoryPaletteDetailView: View {
    let entry:       PromptHistoryEntry
    @Bindable var vm: AIPaletteViewModel
    let accentColor: Color

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedColor:      AIColor? = nil
    @State private var copiedHex:          String?  = nil
    @State private var savedConfirmation:  Bool     = false

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {
                    colorStrip
                    metadataRow
                    colorList
                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle(entry.paletteName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(item: $selectedColor) { color in
            ColorDetailSheet(color: color, accentColor: accentColor) { hex in
                copiedHex = hex
                UIPasteboard.general.string = hex
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copiedHex = nil }
            }
        }
        .overlay(alignment: .bottom) {
            if savedConfirmation { savedToast }
            if let hex = copiedHex { hexCopiedToast(hex) }
        }
    }

    // MARK: - Color strip

    private var colorStrip: some View {
        HStack(spacing: 0) {
            ForEach(entry.colors) { color in
                color.color.frame(maxWidth: .infinity)
            }
        }
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Metadata row

    private var metadataRow: some View {
        HStack(spacing: DSSpacing.sm) {
            Label("AI — \(entry.style)", systemImage: "sparkles")
                .font(DSTypography.labelLarge)
                .foregroundStyle(accentColor)
                .padding(.horizontal, DSSpacing.sm).padding(.vertical, DSSpacing.xxs)
                .background(accentColor.opacity(0.1), in: Capsule())

            Label("\(entry.colors.count) colors", systemImage: "swatchpalette")
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .padding(.horizontal, DSSpacing.sm).padding(.vertical, DSSpacing.xxs)
                .background(DSColors.Preview.surfaceDefault, in: Capsule())
                .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))

            Spacer()

            Text(entry.savedAt.formatted(date: .abbreviated, time: .omitted))
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
        }
    }

    // MARK: - Color list

    private var colorList: some View {
        VStack(spacing: DSSpacing.xs) {
            ForEach(entry.colors) { color in
                colorRow(color)
            }
        }
    }

    private func colorRow(_ color: AIColor) -> some View {
        let isCopied = copiedHex == color.hex
        return Button { selectedColor = color } label: {
            HStack(spacing: DSSpacing.md) {
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .fill(color.color)
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            .strokeBorder(DSColors.Preview.borderDefault, lineWidth: 1)
                    )
                    .shadow(color: color.color.opacity(0.3), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(color.name)
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    HStack(spacing: 6) {
                        Text(color.hex.uppercased())
                            .font(DSTypography.codeMedium)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                        Text("·").foregroundStyle(DSColors.Preview.textTertiary)
                        Text(color.role)
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(accentColor.opacity(0.9))
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(accentColor.opacity(0.1), in: Capsule())
                    }
                    Text(color.usage)
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    UIPasteboard.general.string = color.hex
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { copiedHex = color.hex }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { copiedHex = nil }
                    }
                } label: {
                    Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isCopied ? DSColors.Preview.success : DSColors.Preview.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            isCopied ? DSColors.Preview.success.opacity(0.12)
                                     : DSColors.Preview.backgroundTertiary,
                            in: Circle()
                        )
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCopied)
                }
                .buttonStyle(.plain)
            }
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.surfaceDefault,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                vm.saveHistoryPalette(entry: entry, context: modelContext)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { savedConfirmation = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { savedConfirmation = false }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bookmark.fill").font(.system(size: 13, weight: .semibold))
                    Text("Save").font(DSTypography.labelLarge)
                }
                .foregroundStyle(accentColor)
            }
        }
        ToolbarItem(placement: .bottomBar) {
            Button { vm.applyHistoryEntry(entry) } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise").font(.system(size: 13, weight: .semibold))
                    Text("Re-generate this prompt").font(DSTypography.headingSmall)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
                .background(accentColor, in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
                .padding(.horizontal, DSSpacing.screenPadding)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Toasts

    private var savedToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "bookmark.fill").foregroundStyle(DSColors.Preview.success)
            Text("Saved to Palettes!")
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md).padding(.vertical, DSSpacing.sm)
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
        .padding(.horizontal, DSSpacing.md).padding(.vertical, DSSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
        .padding(.bottom, DSSpacing.xl)
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity))
    }
}
