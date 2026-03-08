//
//  SaveCustomSnippetSheet.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import SwiftUI
import SwiftData

struct SaveCustomSnippetSheet: View {

    @Bindable var viewModel: SnippetViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var code: String = ""
    @State private var tags: String = ""
    @State private var showValidationError: Bool = false

    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty
                     && !code.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DSSpacing.md) {

                        // Title + Subtitle
                        metaCard

                        // Code input
                        codeCard

                        // Tags
                        tagsCard

                        // Validation error
                        if showValidationError {
                            HStack(spacing: DSSpacing.xs) {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundStyle(DSColors.Preview.error)
                                Text("Title and code are required.")
                                    .font(DSTypography.bodySmall)
                                    .foregroundStyle(DSColors.Preview.error)
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Save button
                        Button {
                            guard isValid else {
                                withAnimation { showValidationError = true }
                                return
                            }
                            viewModel.saveCustom(
                                title: title.trimmingCharacters(in: .whitespaces),
                                subtitle: subtitle.trimmingCharacters(in: .whitespaces),
                                code: code,
                                tags: tags,
                                context: context
                            )
                            dismiss()
                        } label: {
                            HStack(spacing: DSSpacing.xs) {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save Snippet")
                                    .font(DSTypography.headingSmall)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.sm)
                            .background(
                                isValid ? DSColors.Preview.accent : DSColors.Preview.textTertiary,
                                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                            )
                            .animation(.easeInOut(duration: 0.2), value: isValid)
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: DSSpacing.xxxl)
                    }
                    .padding(.horizontal, DSSpacing.screenPadding)
                    .padding(.top, DSSpacing.md)
                }
            }
            .navigationTitle("New Snippet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DSColors.Preview.textSecondary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }

    // MARK: - Meta Card
    private var metaCard: some View {
        VStack(spacing: DSSpacing.sm) {
            fieldRow("Title", placeholder: "e.g. Custom Card", text: $title, required: true)
            Divider().background(DSColors.Preview.borderSubtle)
            fieldRow("Subtitle", placeholder: "Brief description", text: $subtitle, required: false)
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    private func fieldRow(_ label: String, placeholder: String,
                           text: Binding<String>, required: Bool) -> some View {
        HStack(spacing: DSSpacing.sm) {
            HStack(spacing: 2) {
                Text(label)
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                if required {
                    Text("*")
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.error)
                }
            }
            .frame(width: 60, alignment: .leading)

            TextField(placeholder, text: text)
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
    }

    // MARK: - Code Card
    private var codeCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: 2) {
                Text("Code")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text("*")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.error)
            }

            TextField("Paste your SwiftUI code here…", text: $code, axis: .vertical)
                .font(DSTypography.codeSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .lineLimit(6...20)
                .padding(DSSpacing.sm)
                .background(DSColors.Preview.backgroundPrimary,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .strokeBorder(
                            code.isEmpty ? DSColors.Preview.borderSubtle : DSColors.Preview.accent,
                            lineWidth: 1
                        )
                )
                .autocorrectionDisabled()
                .autocapitalization(.none)

            Text("Tip: use {{ACCENT}} as a placeholder — it gets replaced with your chosen accent color when copying.")
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Tags Card
    private var tagsCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Tags")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)

            TextField("button, card, form  (comma-separated)", text: $tags)
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .padding(DSSpacing.sm)
                .background(DSColors.Preview.backgroundPrimary,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
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
}
