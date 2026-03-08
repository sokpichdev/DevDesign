//
//  DSSpacing.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Built on an 4pt base grid.
// All layout values are multiples of 4 for pixel-perfect consistency.

import SwiftUI

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
