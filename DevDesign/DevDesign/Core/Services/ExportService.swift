//
//  ExportService.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Converts a DevColor into ready-to-paste code strings
// for every supported export format.

import Foundation

// MARK: - Export Format
enum ExportFormat: String, CaseIterable, Identifiable, Codable {
    case swiftUI    = "SwiftUI"
    case uiKit      = "UIKit"
    case css        = "CSS"
    case hex        = "HEX"
    case rgb        = "RGB"
    case hsl        = "HSL"
    case androidXML = "Android"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .swiftUI:    return "swift"
        case .uiKit:      return "iphone"
        case .css:        return "globe"
        case .hex:        return "number"
        case .rgb:        return "slider.horizontal.3"
        case .hsl:        return "circle.and.line.horizontal"
        case .androidXML: return "ant.fill"
        }
    }
}

// MARK: - Export Service
enum ExportService {

    /// Generate a code string for the given color and format.
    static func export(_ color: DevColor, as format: ExportFormat) -> String {
        switch format {
        case .swiftUI:    return swiftUI(color)
        case .uiKit:      return uiKit(color)
        case .css:        return css(color)
        case .hex:        return hex(color)
        case .rgb:        return rgb(color)
        case .hsl:        return hsl(color)
        case .androidXML: return android(color)
        }
    }

    /// Export a named palette as a SwiftUI Color extension
    static func exportPalette(_ colors: [DevColor], name paletteName: String, as format: ExportFormat) -> String {
        switch format {
        case .swiftUI:    return swiftUIPalette(colors, name: paletteName)
        case .css:        return cssPalette(colors, name: paletteName)
        case .hex:        return colors.map { $0.hex }.joined(separator: "\n")
        default:          return colors.map { export($0, as: format) }.joined(separator: "\n")
        }
    }

    // MARK: - Single Color Formats

    private static func swiftUI(_ c: DevColor) -> String {
        let (r, g, b) = (round4(c.red), round4(c.green), round4(c.blue))
        if c.alpha < 1.0 {
            return "Color(.sRGB, red: \(r), green: \(g), blue: \(b), opacity: \(round4(c.alpha)))"
        }
        return "Color(.sRGB, red: \(r), green: \(g), blue: \(b))"
    }

    private static func uiKit(_ c: DevColor) -> String {
        let (r, g, b) = (round4(c.red), round4(c.green), round4(c.blue))
        if c.alpha < 1.0 {
            return "UIColor(red: \(r), green: \(g), blue: \(b), alpha: \(round4(c.alpha)))"
        }
        return "UIColor(red: \(r), green: \(g), blue: \(b), alpha: 1)"
    }

    private static func css(_ c: DevColor) -> String {
        let (r, g, b) = c.rgb
        if c.alpha < 1.0 {
            return "rgba(\(r), \(g), \(b), \(round2(c.alpha)))"
        }
        return "rgb(\(r), \(g), \(b))"
    }

    private static func hex(_ c: DevColor) -> String {
        c.alpha < 1.0 ? c.hexWithAlpha : c.hex
    }

    private static func rgb(_ c: DevColor) -> String {
        let (r, g, b) = c.rgb
        return "R: \(r)  G: \(g)  B: \(b)"
    }

    private static func hsl(_ c: DevColor) -> String {
        let (h, s, l) = c.hsl
        return "hsl(\(Int(h)), \(Int(s))%, \(Int(l))%)"
    }

    private static func android(_ c: DevColor) -> String {
        // Android uses ARGB hex: #AARRGGBB
        let a = Int(c.alpha * 255)
        let r = Int(c.red   * 255)
        let g = Int(c.green * 255)
        let b = Int(c.blue  * 255)
        return String(format: "#%02X%02X%02X%02X", a, r, g, b)
    }

    // MARK: - Palette Formats

    private static func swiftUIPalette(_ colors: [DevColor], name: String) -> String {
        let safeName = name.replacingOccurrences(of: " ", with: "")
        var lines = ["extension Color {", "    enum \(safeName) {"]
        for (i, c) in colors.enumerated() {
            lines.append("        static let color\(i + 1) = \(swiftUI(c))")
        }
        lines += ["    }", "}"]
        return lines.joined(separator: "\n")
    }

    private static func cssPalette(_ colors: [DevColor], name: String) -> String {
        let safeName = name.lowercased().replacingOccurrences(of: " ", with: "-")
        var lines = [":root {"]
        for (i, c) in colors.enumerated() {
            lines.append("  --\(safeName)-\(i + 1): \(c.hex);")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    // MARK: - Precision helpers
    private static func round4(_ v: Double) -> Double { (v * 10000).rounded() / 10000 }
    private static func round2(_ v: Double) -> Double { (v * 100).rounded() / 100 }
}
