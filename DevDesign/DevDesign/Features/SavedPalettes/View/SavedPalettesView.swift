//
//  SavedPalettesView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Main Saved Palettes screen:
//   • Search bar
//   • Grid / List toggle
//   • Swipe to delete, long-press to rename
//   • Empty state
//   • iCloud sync is automatic via SwiftData + CloudKit (configured in Step 1)

import SwiftUI
import SwiftData

struct SavedPalettesView: View {

    @State private var viewModel = SavedPalettesViewModel()
    @Environment(\.modelContext) private var modelContext

    // SwiftData live query — sorted newest first, updates automatically with iCloud sync
    @Query(sort: \SavedPalette.createdAt, order: .reverse)
    private var allPalettes: [SavedPalette]

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                // Search + display toggle header
                headerBar

                if viewModel.filtered(allPalettes).isEmpty {
                    emptyState
                } else {
                    // Grid or List
                    Group {
                        if viewModel.displayMode == .grid {
                            gridContent
                        } else {
                            listContent
                        }
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.8),
                               value: viewModel.displayMode)
                }
            }
        }
        .navigationTitle("Saved Palettes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        // Rename alert
        .alert("Rename Palette", isPresented: Binding(
            get: { viewModel.paletteToRename != nil },
            set: { if !$0 { viewModel.cancelRename() } }
        )) {
            TextField("Palette name", text: $viewModel.renameText)
            Button("Save")   { viewModel.commitRename(context: modelContext) }
            Button("Cancel", role: .cancel) { viewModel.cancelRename() }
        }
        // Delete confirm
        .confirmationDialog("Delete Palette?",
            isPresented: $viewModel.showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let p = viewModel.paletteToDelete {
                    viewModel.delete(p, context: modelContext)
                }
            }
            Button("Cancel", role: .cancel) { viewModel.paletteToDelete = nil }
        } message: {
            Text("This cannot be undone.")
        }
        // Copied toast
        .overlay(alignment: .bottom) {
            if viewModel.showCopiedToast { copiedToast }
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack(spacing: DSSpacing.sm) {

            // Search field
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(DSColors.Preview.textTertiary)

                TextField("Search palettes…", text: $viewModel.searchText)
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .autocorrectionDisabled()

                if !viewModel.searchText.isEmpty {
                    Button { viewModel.searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.surfaceDefault,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )

            // Display mode toggle
            displayModeToggle
        }
        .padding(.horizontal, DSSpacing.screenPadding)
        .padding(.vertical, DSSpacing.sm)
    }

    private var displayModeToggle: some View {
        HStack(spacing: 2) {
            ForEach(SavedPalettesViewModel.DisplayMode.allCases, id: \.rawValue) { mode in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        viewModel.displayMode = mode
                    }
                } label: {
                    Image(systemName: mode.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(
                            viewModel.displayMode == mode
                                ? DSColors.Preview.accent
                                : DSColors.Preview.textTertiary
                        )
                        .frame(width: 34, height: 34)
                        .background(
                            viewModel.displayMode == mode
                                ? DSColors.Preview.accentMuted
                                : Color.clear,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Grid
    private var gridContent: some View {
        let columns = [
            GridItem(.flexible(), spacing: DSSpacing.sm),
            GridItem(.flexible(), spacing: DSSpacing.sm)
        ]

        return ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                ForEach(viewModel.filtered(allPalettes)) { palette in
                    NavigationLink(destination: PaletteDetailView(
                        palette: palette,
                        viewModel: viewModel
                    )) {
                        paletteGridCard(palette)
                    }
                    .buttonStyle(.plain)
                    .contextMenu { paletteContextMenu(palette) }
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.vertical, DSSpacing.sm)
        }
        .transition(.opacity)
    }

    private func paletteGridCard(_ palette: SavedPalette) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {

            // Color swatch strip
            HStack(spacing: 2) {
                ForEach(palette.colors, id: \.id) { color in
                    Rectangle()
                        .fill(Color(red: color.red, green: color.green, blue: color.blue))
                }
            }
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))

            // Name
            Text(palette.name)
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .lineLimit(1)

            // Harmony + count
            HStack(spacing: DSSpacing.xs) {
                Text(palette.harmonyType)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.accent)
                Spacer()
                Text("\(palette.colors.count) colors")
                    .font(DSTypography.labelSmall)
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

    // MARK: - List
    private var listContent: some View {
        List {
            ForEach(viewModel.filtered(allPalettes)) { palette in
                NavigationLink(destination: PaletteDetailView(
                    palette: palette,
                    viewModel: viewModel
                )) {
                    paletteListRow(palette)
                }
                .listRowBackground(DSColors.Preview.surfaceDefault)
                .listRowSeparatorTint(DSColors.Preview.borderSubtle)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.confirmDelete(palette)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        viewModel.beginRename(palette)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    .tint(DSColors.Preview.accent)
                }
                .contextMenu { paletteContextMenu(palette) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .transition(.opacity)
    }

    private func paletteListRow(_ palette: SavedPalette) -> some View {
        HStack(spacing: DSSpacing.md) {

            // Mini swatch strip
            HStack(spacing: 2) {
                ForEach(palette.colors, id: \.id) { color in
                    Rectangle()
                        .fill(Color(red: color.red, green: color.green, blue: color.blue))
                }
            }
            .frame(width: 56, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.xs))

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(palette.name)
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                HStack(spacing: DSSpacing.xs) {
                    Text(palette.harmonyType)
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.accent)
                    Text("·")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                    Text("\(palette.colors.count) colors")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                }
            }

            Spacer()

            // Date
            Text(palette.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
        }
        .padding(.vertical, DSSpacing.xs)
    }

    // MARK: - Context Menu
    @ViewBuilder
    private func paletteContextMenu(_ palette: SavedPalette) -> some View {
        Button { viewModel.beginRename(palette) } label: {
            Label("Rename", systemImage: "pencil")
        }
        Button { viewModel.paletteToExport = palette } label: {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        Button {
            viewModel.copyToClipboard(
                viewModel.exportAsSwiftUI(palette),
                label: "SwiftUI"
            )
        } label: {
            Label("Copy as SwiftUI", systemImage: "swift")
        }
        Button {
            viewModel.copyToClipboard(
                viewModel.exportAsJSON(palette),
                label: "JSON"
            )
        } label: {
            Label("Copy as JSON", systemImage: "curlybraces")
        }
        Divider()
        Button(role: .destructive) {
            viewModel.confirmDelete(palette)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Spacer()

            Image(systemName: "bookmark.slash")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(DSColors.Preview.textTertiary)

            VStack(spacing: DSSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No Saved Palettes" : "No Results")
                    .font(DSTypography.displaySmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)

                Text(viewModel.searchText.isEmpty
                     ? "Generate a palette and tap Save to keep it here."
                     : "Try a different search term.")
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.xl)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Text("\(viewModel.filtered(allPalettes).count) palettes")
                .font(DSTypography.labelMedium)
                .foregroundStyle(DSColors.Preview.textTertiary)
        }
    }

    // MARK: - Toast
    private var copiedToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DSColors.Preview.success)
            Text(viewModel.copiedMessage)
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
        SavedPalettesView()
    }
    .modelContainer(for: [SavedPalette.self, SavedColor.self], inMemory: true)
}
