//
//  SavedPalette.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import SwiftData

// MARK: - SavedPalette
// A named collection of colors the user has bookmarked.
@Model
final class SavedPalette {
    var id: UUID
    var name: String
    var colors: [SavedColor]       // Ordered list of colors in this palette
    var harmonyType: String        // e.g. "Complementary", "Analogous"
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "Untitled Palette",
        colors: [SavedColor] = [],
        harmonyType: String = "Custom",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.colors = colors
        self.harmonyType = harmonyType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - SavedColor
// An individual color entry, stored with all representations.
@Model
final class SavedColor {
    var id: UUID
    var hex: String             // e.g. "#1A2B3C"
    var red: Double             // 0.0 – 1.0
    var green: Double
    var blue: Double
    var alpha: Double
    var label: String           // Optional user label e.g. "Primary"

    init(
        id: UUID = UUID(),
        hex: String,
        red: Double,
        green: Double,
        blue: Double,
        alpha: Double = 1.0,
        label: String = ""
    ) {
        self.id = id
        self.hex = hex
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.label = label
    }

    // Convenience: convert to SwiftUI Color
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
