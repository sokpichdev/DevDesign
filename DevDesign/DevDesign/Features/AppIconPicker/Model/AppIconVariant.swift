//
//  AppIconVariant.swift
//  DevDesign
//
//  Created by Sok Pich on 10/03/2026.
//

import SwiftUI
import UIKit

/// Represents one of the bundled app icon variants.
/// The `iconName` must exactly match the CFBundleAlternateIcons key in Info.plist.
/// `nil` iconName = the primary icon (AppIcon).
enum AppIconVariant: String, CaseIterable, Identifiable {
    case `default`  = "Default"
    case prism      = "Prism"
    case layers     = "Layers"
    case vector     = "Vector"
    case ribbon     = "Ribbon"
    case dark       = "Dark"
    case minimal    = "Minimal"
    case neon       = "Neon"
    case sunset     = "Sunset"
    case ocean      = "Ocean"
    case mono       = "Mono"
    case gold       = "Gold"

    var id: String { rawValue }

    /// The name passed to UIApplication.setAlternateIconName.
    /// nil → primary icon (resets to default).
    var iconName: String? {
        self == .default ? nil : "AppIcon-\(rawValue)"
    }

    /// Display label shown in the picker.
    var label: String { rawValue }

    /// Short descriptor shown beneath the label.
    var description: String {
        switch self {
        case .default:  return "Glass Prism · Primary"
        case .prism:    return "Glass D & Code · Spectrum"
        case .layers:   return "Isometric Glass · Multi-tool"
        case .vector:   return "Precision Nib · Dark metallic"
        case .ribbon:   return "Continuous Monogram · Sunset"
        case .dark:     return "Near-black · Subtle purple"
        case .minimal:  return "White · Clean & light"
        case .neon:     return "Black · Electric green"
        case .sunset:   return "Orange to red · Warm"
        case .ocean:    return "Blue to cyan · Cool"
        case .mono:     return "Grey scale · Timeless"
        case .gold:     return "Amber to yellow · Rich"
        }
    }

    /// Preview accent colour used in the picker card border.
    var accent: Color {
        switch self {
        case .default:  return Color(hex: "#7B6EF6")
        case .prism:    return Color(hex: "#7B6EF6")
        case .layers:   return Color(hex: "#64D2FF")
        case .vector:   return Color(hex: "#FF9F0A")
        case .ribbon:   return Color(hex: "#FF6CAB")
        case .dark:     return Color(hex: "#7B6EF6")
        case .minimal:  return Color(hex: "#7B6EF6")
        case .neon:     return Color(hex: "#30D158")
        case .sunset:   return Color(hex: "#FF9F0A")
        case .ocean:    return Color(hex: "#0A84FF")
        case .mono:     return Color(hex: "#8E8E93")
        case .gold:     return Color(hex: "#FFD60A")
        }
    }

    /// Whether the picker card background is light (affects label text colour).
    var isLight: Bool {
        self == .minimal || self == .gold
    }

    // MARK: - Availability

    /// True when this variant's imageset actually exists in the asset catalog.
    /// Alternates are declared as plain imagesets (not appiconsets) precisely so they can be
    /// resolved by name here and previewed in the picker.
    var isAvailable: Bool {
        guard let iconName else { return true }   // .default — primary icon
        return UIImage(named: iconName) != nil
    }

    /// The variants that can actually be applied on this build.
    /// Use this instead of `allCases` so unbuilt art never reaches the user.
    static var available: [AppIconVariant] {
        allCases.filter(\.isAvailable)
    }
}
