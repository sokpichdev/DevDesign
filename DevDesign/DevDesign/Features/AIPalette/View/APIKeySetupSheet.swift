//
//  APIKeySetupSheet.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import SwiftUI

struct APIKeySetupSheet: View {
    @Bindable var vm: AIPaletteViewModel
    let accentColor: Color
    @Environment(\.dismiss) private var dismiss
    @FocusState private var fieldFocused: Bool
    @State private var selectedProvider: AIProvider = .anthropic

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: DSSpacing.xl) {
                    providerPicker
                    providerIcon
                    providerDescription
                    keyInputField
                    currentKeyDisplay
                    saveButton
                    getKeyLink
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
                if vm.providerBeingConfigured == nil { vm.providerBeingConfigured = vm.selectedProvider }
                selectedProvider = vm.providerBeingConfigured ?? .anthropic
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }

    // MARK: - Sub-views

    private var providerPicker: some View {
        Picker("Provider", selection: $selectedProvider) {
            ForEach(AIProvider.allCases) { provider in
                Text(provider.rawValue).tag(provider)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DSSpacing.screenPadding)
        .onChange(of: selectedProvider) { _, newProvider in
            vm.providerBeingConfigured = newProvider
            vm.apiKeyInput = ""
        }
    }

    private var providerIcon: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.12))
                .frame(width: 80, height: 80)
            Image(systemName: selectedProvider.icon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(accentColor)
        }
        .padding(.top, DSSpacing.sm)
    }

    private var providerDescription: some View {
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
    }

    private var keyInputField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("API Key")
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)

            if selectedProvider == .openrouter {
                Text("Optional — only needed for higher rate limits")
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
                        .strokeBorder(fieldFocused ? accentColor.opacity(0.5) : DSColors.Preview.borderSubtle,
                                      lineWidth: 1)
                )

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
    }

    @ViewBuilder
    private var currentKeyDisplay: some View {
        let currentKey = currentKey(for: selectedProvider)
        if !currentKey.isEmpty {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(DSColors.Preview.success)
                Text("Current: \(ProviderKeyStore.maskedDisplay(currentKey, for: selectedProvider))")
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                Spacer()
                Button("Clear") { vm.clearAPIKey(for: selectedProvider) }
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.error)
            }
            .padding(.horizontal, DSSpacing.screenPadding)
        }
    }

    private var saveButton: some View {
        Button { vm.saveAPIKey() } label: {
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
    }

    private var getKeyLink: some View {
        Link(destination: URL(string: selectedProvider.helpURL)!) {
            HStack(spacing: 4) {
                Image(systemName: "safari")
                Text("Get a key at \(URL(string: selectedProvider.helpURL)!.host ?? "")")
            }
            .font(DSTypography.labelLarge)
            .foregroundStyle(accentColor)
        }
    }

    // MARK: - Helper

    private func currentKey(for provider: AIProvider) -> String {
        switch provider {
        case .anthropic:  return vm.anthropicKey
        case .gemini:     return vm.geminiKey
        case .openrouter: return vm.openrouterKey
        }
    }
}
