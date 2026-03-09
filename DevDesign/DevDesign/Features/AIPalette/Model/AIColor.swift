//
//  AIColor.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import SwiftUI

struct AIColor: Identifiable, Equatable, Codable {
    var id: UUID   = UUID()
    var hex: String         // e.g. "#FF6B35"
    var name: String        // e.g. "Tangerine Dusk"
    var role: String        // e.g. "primary" | "background" | "accent" | "text" | "surface"
    var usage: String       // e.g. "CTAs, highlights"

    var red:   Double { Double(hexComponent(offset: 0)) / 255 }
    var green: Double { Double(hexComponent(offset: 1)) / 255 }
    var blue:  Double { Double(hexComponent(offset: 2)) / 255 }

    var color: Color { Color(red: red, green: green, blue: blue) }

    var isDark: Bool {
        (red * 299 + green * 587 + blue * 114) / 1000 < 0.5
    }

    var onColor: Color { isDark ? .white : .black }

    private func hexComponent(offset: Int) -> UInt8 {
        let raw = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard raw.count >= 6 else { return 0 }
        let start = raw.index(raw.startIndex, offsetBy: offset * 2)
        let end   = raw.index(start, offsetBy: 2)
        return UInt8(raw[start..<end], radix: 16) ?? 0
    }
}
