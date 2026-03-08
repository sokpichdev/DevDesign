//
//  DSTypography.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI

enum DSTypography {

    // MARK: - Font Family
    // Using SF Pro (system font) — feels native, supports Dynamic Type.
    // Swap `.system` for a custom font by replacing with `Font.custom("FontName", size:)`

    // MARK: - Display (Hero headings on Dashboard)
    static let displayLarge  = Font.system(size: 34, weight: .bold,        design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .bold,        design: .rounded)
    static let displaySmall  = Font.system(size: 22, weight: .semibold,    design: .rounded)

    // MARK: - Headings
    static let headingLarge  = Font.system(size: 20, weight: .semibold,    design: .default)
    static let headingMedium = Font.system(size: 17, weight: .semibold,    design: .default)
    static let headingSmall  = Font.system(size: 15, weight: .semibold,    design: .default)

    // MARK: - Body
    static let bodyLarge     = Font.system(size: 17, weight: .regular,     design: .default)
    static let bodyMedium    = Font.system(size: 15, weight: .regular,     design: .default)
    static let bodySmall     = Font.system(size: 13, weight: .regular,     design: .default)

    // MARK: - Labels (Badges, Tags, Captions)
    static let labelLarge    = Font.system(size: 13, weight: .medium,      design: .default)
    static let labelMedium   = Font.system(size: 11, weight: .medium,      design: .default)
    static let labelSmall    = Font.system(size: 10, weight: .semibold,    design: .default)

    // MARK: - Code (Export panels, HEX display)
    static let codeLarge     = Font.system(size: 15, weight: .medium,      design: .monospaced)
    static let codeMedium    = Font.system(size: 13, weight: .medium,      design: .monospaced)
    static let codeSmall     = Font.system(size: 11, weight: .regular,     design: .monospaced)
}
