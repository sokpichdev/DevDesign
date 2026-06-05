//
//  AppIconVariant.swift
//  DevDesign
//
//  Created by Sok Pich on 10/03/2026.
//

import SwiftUI

/// Represents one of the bundled app icon variants.
/// The `iconName` must exactly match the CFBundleAlternateIcons key in Info.plist.
/// `nil` iconName = the primary icon (AppIcon).
enum AppIconVariant: String, CaseIterable, Identifiable {
    case `default`  = "Default"
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
        case .default:  return "Purple gradient · Default"
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
}
