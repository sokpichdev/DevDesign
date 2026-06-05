//
//  AppIconPickerViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 10/03/2026.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class AppIconPickerViewModel {

    // MARK: - State

    var currentVariant: AppIconVariant   = AppIconManager.shared.currentVariant
    var selectedVariant: AppIconVariant  = AppIconManager.shared.currentVariant
    var isApplying: Bool                 = false
    var showSuccess: Bool                = false
    var errorMessage: String?            = nil

    // MARK: - Computed

    var hasUnsavedChange: Bool {
        selectedVariant != currentVariant
    }

    var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    // MARK: - Actions

    func select(_ variant: AppIconVariant) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            selectedVariant = variant
        }
    }

    func apply() {
        guard hasUnsavedChange, !isApplying else { return }
        isApplying   = true
        errorMessage = nil

        Task {
            do {
                try await AppIconManager.shared.setIcon(selectedVariant)

                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    currentVariant = selectedVariant
                    showSuccess    = true
                    isApplying     = false
                }

                try? await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation { showSuccess = false }

            } catch {
                withAnimation {
                    errorMessage    = error.localizedDescription
                    isApplying      = false
                    selectedVariant = currentVariant   // revert selection
                }
            }
        }
    }

    func dismissError() {
        withAnimation { errorMessage = nil }
    }
}
