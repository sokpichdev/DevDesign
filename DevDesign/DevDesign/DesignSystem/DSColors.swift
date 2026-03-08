//
//  DSColors.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Philosophy: A small, intentional palette.
// Dark-first UI that feels native to design tools.

import SwiftUI

enum DSColors {

    // MARK: - Backgrounds
    // Layered dark surfaces — creates depth without heavy shadows.
    static let backgroundPrimary   = Color("DS/BackgroundPrimary")   // #0E0E10  deepest bg
    static let backgroundSecondary = Color("DS/BackgroundSecondary") // #1A1A1F  card bg
    static let backgroundTertiary  = Color("DS/BackgroundTertiary")  // #26262E  elevated bg

    // MARK: - Surfaces (Cards, Sheets)
    static let surfaceDefault      = Color("DS/SurfaceDefault")      // #1E1E26
    static let surfaceElevated     = Color("DS/SurfaceElevated")     // #2A2A35

    // MARK: - Borders
    static let borderSubtle        = Color("DS/BorderSubtle")        // #FFFFFF14  8% white
    static let borderDefault       = Color("DS/BorderDefault")       // #FFFFFF26  15% white

    // MARK: - Text
    static let textPrimary         = Color("DS/TextPrimary")         // #F2F2F5
    static let textSecondary       = Color("DS/TextSecondary")       // #9999AA
    static let textTertiary        = Color("DS/TextTertiary")        // #5C5C6E

    // MARK: - Accent
    // Single vivid accent — used for CTAs, highlights, active states.
    static let accent              = Color("DS/Accent")              // #7B6EF6  soft indigo
    static let accentMuted         = Color("DS/AccentMuted")         // #7B6EF620 10% accent

    // MARK: - Semantic
    static let success             = Color("DS/Success")             // #34C759  iOS green
    static let warning             = Color("DS/Warning")             // #FF9F0A  iOS amber
    static let error               = Color("DS/Error")               // #FF453A  iOS red
    static let info                = Color("DS/Info")                // #64D2FF  iOS teal

    // MARK: - Gradients
    static let accentGradient = LinearGradient(
        colors: [Color(hex: "#7B6EF6"), Color(hex: "#A78BFA")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [Color(hex: "#1E1E26"), Color(hex: "#26262E")],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Fallback Hex Init
// Used for static gradient definitions above.
// The real Color+Hex extension lives in Core/Extensions/Color+Hex.swift (Step 2).
extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int & 0xFF)          / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Asset Catalog Setup Guide
// In Xcode, create a Color Set for each token above inside Assets.xcassets.
// Recommended: create a folder group "DS/" and add each color there.
// Light appearance = same dark value for now (dark-first app).
//
// Quick hardcoded fallbacks for previews (remove once Asset Catalog is set up):
extension DSColors {
    enum Preview {
        static let backgroundPrimary   = Color(hex: "#0E0E10")
        static let backgroundSecondary = Color(hex: "#1A1A1F")
        static let backgroundTertiary  = Color(hex: "#26262E")
        static let surfaceDefault      = Color(hex: "#1E1E26")
        static let surfaceElevated     = Color(hex: "#2A2A35")
        static let textPrimary         = Color(hex: "#F2F2F5")
        static let textSecondary       = Color(hex: "#9999AA")
        static let textTertiary        = Color(hex: "#5C5C6E")
        static let accent              = Color(hex: "#7B6EF6")
        static let accentMuted         = Color(hex: "#7B6EF6").opacity(0.12)
        static let borderSubtle        = Color.white.opacity(0.08)
        static let borderDefault       = Color.white.opacity(0.15)
        static let success             = Color(hex: "#34C759")
        static let warning             = Color(hex: "#FF9F0A")
        static let error               = Color(hex: "#FF453A")
    }
}
