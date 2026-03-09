//
//  ColorsSectionView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

// MARK: - Colors Section

struct ColorsSectionView: View {

    @Bindable var vm: DesignTokenViewModel
    let accentColor: Color

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            if vm.colorTokens.isEmpty {
                emptyColorsState
            } else {
                // Grouped by palette
                let grouped = Dictionary(grouping: vm.filteredColors, by: \.paletteName)
                ForEach(grouped.keys.sorted(), id: \.self) { palette in
                    paletteGroup(name: palette, tokens: grouped[palette]!)
                }
                if vm.filteredColors.isEmpty && !vm.searchText.isEmpty {
                    noResultsView
                }
            }
        }
    }

    private var emptyColorsState: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "paintpalette")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(accentColor.opacity(0.5))
            Text("No Saved Palettes")
                .font(DSTypography.headingMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
            Text("Save a palette in the Palette Generator or Color Picker — it will appear here as design tokens.")
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .multilineTextAlignment(.center)
            Button {
                vm.seedSampleColors()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                    Text("Load Sample Tokens")
                        .font(DSTypography.headingSmall)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .background(accentColor, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func paletteGroup(name: String, tokens: [ColorToken]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Palette header with color strip
            HStack(spacing: DSSpacing.sm) {
                HStack(spacing: 2) {
                    ForEach(tokens.prefix(6)) { t in
                        t.color.frame(height: 6)
                    }
                }
                .clipShape(Capsule())
                .frame(width: 48)

                Text(name)
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Text("\(tokens.count)")
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.backgroundSecondary)

            // Token rows
            ForEach(Array(tokens.enumerated()), id: \.element.id) { i, token in
                ColorTokenRow(
                    token: token,
                    isEditing: vm.editingTokenId == token.id,
                    editingName: $vm.editingTokenName,
                    accentColor: accentColor,
                    onBeginEdit: { vm.beginRename(id: token.id, currentName: token.tokenName) },
                    onCommit:    { vm.commitRename() },
                    onCancel:    { vm.cancelRename() },
                    onCopy:      { vm.copySingleSwift(token) }
                )
                if i < tokens.count - 1 {
                    Divider().background(DSColors.Preview.borderSubtle).padding(.leading, 64)
                }
            }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
    }

    private var noResultsView: some View {
        Text("No tokens match \(vm.searchText)")
            .font(DSTypography.bodySmall)
            .foregroundStyle(DSColors.Preview.textTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(DSSpacing.md)
    }
}

// MARK: - Color Token Row

struct ColorTokenRow: View {
    let token: ColorToken
    let isEditing: Bool
    @Binding var editingName: String
    let accentColor: Color
    let onBeginEdit: () -> Void
    let onCommit: () -> Void
    let onCancel: () -> Void
    let onCopy: () -> Void

    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            // Swatch
            RoundedRectangle(cornerRadius: 8)
                .fill(token.color)
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: token.color.opacity(0.3), radius: 4, x: 0, y: 2)

            // Token name + hex
            VStack(alignment: .leading, spacing: 3) {
                if isEditing {
                    TextField("token name", text: $editingName)
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .focused($focused)
                        .onAppear { focused = true }
                        .onSubmit { onCommit() }
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    Text(token.tokenName)
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                }
                HStack(spacing: 6) {
                    Text(token.hex.uppercased())
                        .font(DSTypography.codeSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                    if token.alpha < 1 {
                        Text(String(format: "%.0f%%", token.alpha * 100))
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                }
            }

            Spacer()

            // Action buttons
            if isEditing {
                HStack(spacing: DSSpacing.xs) {
                    Button {
                        onCommit()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(accentColor)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                    Button {
                        onCancel()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColors.Preview.textTertiary)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: DSSpacing.sm) {
                    Button { onBeginEdit() } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 13))
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    .buttonStyle(.plain)
                    Button { onCopy() } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 13))
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing { onBeginEdit() }
        }
    }
}

// MARK: - Typography Section

struct TypographySectionView: View {

    @Bindable var vm: DesignTokenViewModel
    let accentColor: Color

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(vm.filteredTypography.enumerated()), id: \.element.id) { i, token in
                TypographyTokenRow(
                    token: token,
                    isEditing: vm.editingTokenId == token.id,
                    editingName: $vm.editingTokenName,
                    accentColor: accentColor,
                    onBeginEdit: { vm.beginRename(id: token.id, currentName: token.tokenName) },
                    onCommit:    { vm.commitRename() },
                    onCancel:    { vm.cancelRename() }
                )
                if i < vm.filteredTypography.count - 1 {
                    Divider().background(DSColors.Preview.borderSubtle)
                }
            }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
    }
}

// MARK: - Typography Token Row

struct TypographyTokenRow: View {
    let token: TypographyToken
    let isEditing: Bool
    @Binding var editingName: String
    let accentColor: Color
    let onBeginEdit: () -> Void
    let onCommit: () -> Void
    let onCancel: () -> Void

    @FocusState private var focused: Bool

    var body: some View {
        HStack(alignment: .center, spacing: DSSpacing.sm) {
            // Live type preview
            Text(token.name)
                .font(.system(size: min(CGFloat(token.size), 24), weight: token.fontWeight))
                .foregroundStyle(DSColors.Preview.textPrimary)
                .lineLimit(1)
                .frame(width: 90, alignment: .leading)

            Divider().frame(height: 32).background(DSColors.Preview.borderSubtle)

            // Token name + spec
            VStack(alignment: .leading, spacing: 2) {
                if isEditing {
                    TextField("token name", text: $editingName)
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .focused($focused)
                        .onAppear { focused = true }
                        .onSubmit { onCommit() }
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    Text(token.tokenName)
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(accentColor)
                }
                HStack(spacing: 8) {
                    label("\(Int(token.size))pt")
                    label(token.weightRaw)
                    label("lh \(Int(token.lineHeight))pt")
                }
            }

            Spacer()

            if isEditing {
                HStack(spacing: DSSpacing.xs) {
                    Button { onCommit() } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(accentColor).font(.system(size: 20))
                    }.buttonStyle(.plain)
                    Button { onCancel() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColors.Preview.textTertiary).font(.system(size: 20))
                    }.buttonStyle(.plain)
                }
            } else {
                Button { onBeginEdit() } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .contentShape(Rectangle())
        .onTapGesture { if !isEditing { onBeginEdit() } }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(DSTypography.codeSmall)
            .foregroundStyle(DSColors.Preview.textTertiary)
    }
}

// MARK: - Spacing Section

struct SpacingSectionView: View {

    @Bindable var vm: DesignTokenViewModel
    let accentColor: Color

    private let maxValue: Double = 40 // spacingXXXL

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(vm.filteredSpacing.enumerated()), id: \.element.id) { i, token in
                SpacingDesignTokenRow(
                    token: token,
                    isEditing: vm.editingTokenId == token.id,
                    editingName: $vm.editingTokenName,
                    maxValue: maxValue,
                    accentColor: accentColor,
                    onBeginEdit: { vm.beginRename(id: token.id, currentName: token.tokenName) },
                    onCommit:    { vm.commitRename() },
                    onCancel:    { vm.cancelRename() }
                )
                if i < vm.filteredSpacing.count - 1 {
                    Divider().background(DSColors.Preview.borderSubtle)
                }
            }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
    }
}

// MARK: - Spacing Token Row

struct SpacingDesignTokenRow: View {
    let token: SpacingDesignToken
    let isEditing: Bool
    @Binding var editingName: String
    let maxValue: Double
    let accentColor: Color
    let onBeginEdit: () -> Void
    let onCommit: () -> Void
    let onCancel: () -> Void

    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            // Value badge
            Text("\(Int(token.value))pt")
                .font(DSTypography.codeMedium)
                .foregroundStyle(.white)
                .frame(width: 44)
                .padding(.vertical, 4)
                .background(accentColor, in: RoundedRectangle(cornerRadius: 6))

            // Bar
            GeometryReader { geo in
                let frac = CGFloat(token.value / maxValue)
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(accentColor.opacity(0.25))
                        .frame(width: max(4, geo.size.width * frac))
                    Spacer(minLength: 0)
                }
            }
            .frame(height: 8)

            // Token name + description
            VStack(alignment: .leading, spacing: 2) {
                if isEditing {
                    TextField("token name", text: $editingName)
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .focused($focused)
                        .onAppear { focused = true }
                        .onSubmit { onCommit() }
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    Text(token.tokenName)
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                }
                Text(token.description)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            if isEditing {
                HStack(spacing: DSSpacing.xs) {
                    Button { onCommit() } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(accentColor).font(.system(size: 20))
                    }.buttonStyle(.plain)
                    Button { onCancel() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColors.Preview.textTertiary).font(.system(size: 20))
                    }.buttonStyle(.plain)
                }
            } else {
                Button { onBeginEdit() } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .contentShape(Rectangle())
        .onTapGesture { if !isEditing { onBeginEdit() } }
    }
}

// MARK: - Export Options Card

struct ExportOptionsCard: View {

    @Bindable var vm: DesignTokenViewModel
    let accentColor: Color

    var body: some View {
        VStack(spacing: DSSpacing.md) {

            // Format picker
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Format")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)

                HStack(spacing: DSSpacing.xs) {
                    ForEach(TokenExportFormat.allCases) { fmt in
                        let isSel = vm.exportFormat == fmt
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                vm.exportFormat = fmt
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: fmt.icon)
                                    .font(.system(size: 14, weight: .semibold))
                                Text(fmt.rawValue)
                                    .font(DSTypography.labelSmall)
                            }
                            .foregroundStyle(isSel ? .white : DSColors.Preview.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.xs)
                            .background(isSel ? accentColor : DSColors.Preview.surfaceElevated,
                                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                            .overlay(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                                .strokeBorder(isSel ? .clear : DSColors.Preview.borderSubtle, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSel)
                    }
                }
            }

            Divider().background(DSColors.Preview.borderSubtle)

            // Include toggles
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Include")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)

                includeToggle("Colors (\(vm.colorTokens.count))", icon: "paintpalette",
                              binding: $vm.includeColors)
                includeToggle("Typography (\(vm.typographyTokens.count))", icon: "textformat",
                              binding: $vm.includeTypography)
                includeToggle("Spacing (\(vm.spacingTokens.count))", icon: "ruler",
                              binding: $vm.includeSpacing)
            }

            Divider().background(DSColors.Preview.borderSubtle)

            // Token count summary
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total tokens")
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                    Text("\(selectedCount) tokens · \(vm.exportFormat.fileExtension)")
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                }
                Spacer()

                // Quick copy
                Button {
                    vm.copyExport(format: vm.exportFormat)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.on.doc.fill")
                        Text("Copy")
                            .font(DSTypography.headingSmall)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.xs)
                    .background(accentColor, in: Capsule())
                }
                .buttonStyle(.plain)
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

    private var selectedCount: Int {
        (vm.includeColors     ? vm.colorTokens.count      : 0) +
        (vm.includeTypography ? vm.typographyTokens.count : 0) +
        (vm.includeSpacing    ? vm.spacingTokens.count    : 0)
    }

    private func includeToggle(_ label: String, icon: String, binding: Binding<Bool>) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(binding.wrappedValue ? accentColor : DSColors.Preview.textTertiary)
                .frame(width: 20)
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(accentColor)
        }
    }
}
