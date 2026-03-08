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


// DSSpacing.swift
// DevDesign — Design System · Spacing Scale
// Lives in DesignSystem/ in your Xcode project.
//
// Built on an 4pt base grid.
// All layout values are multiples of 4 for pixel-perfect consistency.

enum DSSpacing {

    // MARK: - Base Grid: 4pt
    static let xxs:  CGFloat = 4    //  4pt — micro gaps (icon padding)
    static let xs:   CGFloat = 8    //  8pt — tight spacing (tag padding)
    static let sm:   CGFloat = 12   // 12pt — compact spacing
    static let md:   CGFloat = 16   // 16pt — standard content padding ★ most used
    static let lg:   CGFloat = 24   // 24pt — section spacing
    static let xl:   CGFloat = 32   // 32pt — large section gaps
    static let xxl:  CGFloat = 48   // 48pt — hero spacing
    static let xxxl: CGFloat = 64   // 64pt — screen-level spacing

    // MARK: - Semantic Aliases
    static let screenPadding:  CGFloat = md    // 16pt side margins
    static let cardPadding:    CGFloat = md    // 16pt inside cards
    static let cardSpacing:    CGFloat = sm    // 12pt between card elements
    static let sectionSpacing: CGFloat = xl    // 32pt between dashboard sections
    static let itemSpacing:    CGFloat = xs    //  8pt between list items

    // MARK: - Corner Radii
    enum Radius {
        static let xs:     CGFloat = 6
        static let sm:     CGFloat = 10
        static let md:     CGFloat = 14   // Standard card radius ★
        static let lg:     CGFloat = 20
        static let xl:     CGFloat = 28
        static let pill:   CGFloat = 999  // Full pill / capsule
    }

    // MARK: - Icon Sizes
    enum Icon {
        static let sm:  CGFloat = 16
        static let md:  CGFloat = 20
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let hero: CGFloat = 48
    }
}
