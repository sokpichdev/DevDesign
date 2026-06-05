//
//  AppIconManager.swift
//  DevDesign
//
//  Created by Sok Pich on 10/03/2026.
//

import UIKit

/// Manages reading and setting the app's alternate icon.
/// All mutations happen on the main actor because UIApplication requires it.
@MainActor
final class AppIconManager {

    static let shared = AppIconManager()
    private init() {}

    // MARK: - Current icon

    /// Returns the variant that is currently active.
    var currentVariant: AppIconVariant {
        guard let name = UIApplication.shared.alternateIconName else { return .default }
        // Strip "AppIcon-" prefix and match rawValue
        let raw = name.replacingOccurrences(of: "AppIcon-", with: "")
        return AppIconVariant(rawValue: raw) ?? .default
    }

    // MARK: - Set icon

    /// Attempts to switch to `variant`. Throws an `AppIconError` on failure.
    func setIcon(_ variant: AppIconVariant) async throws {
        guard UIApplication.shared.supportsAlternateIcons else {
            throw AppIconError.notSupported
        }

        // Already active — no-op
        if currentVariant == variant { return }

        try await UIApplication.shared.setAlternateIconName(variant.iconName)
    }

    // MARK: - Reset to default

    func resetToDefault() async throws {
        try await setIcon(.default)
    }
}

// MARK: - Errors

enum AppIconError: LocalizedError {
    case notSupported
    case setFailed(String)

    var errorDescription: String? {
        switch self {
        case .notSupported:
            return "Alternate icons are not supported on this device."
        case .setFailed(let msg):
            return "Could not change app icon: \(msg)"
        }
    }
}
