//
//  DevColor.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// The single source of truth for any color in the app.
// Stores all representations together so we never re-calculate.

import SwiftUI

// MARK: - DevColor
struct DevColor: Equatable, Hashable, Codable, Identifiable {

    let id: UUID

    // MARK: - Storage (RGB is the canonical format)
    var red:   Double   // 0.0 – 1.0
    var green: Double
    var blue:  Double
    var alpha: Double   // 0.0 – 1.0  (1.0 = fully opaque)

    // MARK: - Init from RGB
    init(id: UUID = UUID(), red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.id    = id
        self.red   = red.clamped(to: 0...1)
        self.green = green.clamped(to: 0...1)
        self.blue  = blue.clamped(to: 0...1)
        self.alpha = alpha.clamped(to: 0...1)
    }

    // MARK: - Init from HEX string
    // Accepts: "#1A2B3C", "1A2B3C", "#1A2B3CFF" (with alpha)
    init?(hex: String) {
        var raw = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                     .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
                     .uppercased()

        // Expand shorthand #RGB → #RRGGBB
        if raw.count == 3 {
            raw = raw.map { "\($0)\($0)" }.joined()
        }

        guard raw.count == 6 || raw.count == 8 else { return nil }

        var int: UInt64 = 0
        guard Scanner(string: raw).scanHexInt64(&int) else { return nil }

        if raw.count == 8 {
            self.init(
                red:   Double((int >> 24) & 0xFF) / 255,
                green: Double((int >> 16) & 0xFF) / 255,
                blue:  Double((int >> 8)  & 0xFF) / 255,
                alpha: Double(int         & 0xFF) / 255
            )
        } else {
            self.init(
                red:   Double((int >> 16) & 0xFF) / 255,
                green: Double((int >> 8)  & 0xFF) / 255,
                blue:  Double(int         & 0xFF) / 255
            )
        }
    }

    // MARK: - Init from HSL
    init(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) {
        let (r, g, b) = DevColor.hslToRgb(h: hue, s: saturation, l: lightness)
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    // MARK: - Init from SwiftUI Color (best-effort via UIColor bridge)
    init?(color: Color, alpha: Double = 1.0) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        self.init(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }
}

// MARK: - Computed Representations
extension DevColor {

    // MARK: SwiftUI Color
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    // MARK: UIColor
    var uiColor: UIColor {
        UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }

    // MARK: HEX string
    var hex: String {
        let r = Int(red   * 255)
        let g = Int(green * 255)
        let b = Int(blue  * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    var hexWithAlpha: String {
        let r = Int(red   * 255)
        let g = Int(green * 255)
        let b = Int(blue  * 255)
        let a = Int(alpha * 255)
        return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }

    // MARK: RGB (0–255)
    var rgb: (r: Int, g: Int, b: Int) {
        (Int(red * 255), Int(green * 255), Int(blue * 255))
    }

    // MARK: HSL (Hue 0–360, Saturation 0–100, Lightness 0–100)
    var hsl: (h: Double, s: Double, l: Double) {
        DevColor.rgbToHsl(r: red, g: green, b: blue)
    }

    // MARK: HSB / HSV (for color wheel pickers)
    var hsb: (h: Double, s: Double, b: Double) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Double(h) * 360, Double(s) * 100, Double(b) * 100)
    }

    // MARK: Relative Luminance (for WCAG contrast)
    var luminance: Double {
        func linearize(_ v: Double) -> Double {
            v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linearize(red)
             + 0.7152 * linearize(green)
             + 0.0722 * linearize(blue)
    }

    // MARK: Perceived brightness (quick dark/light check)
    var perceivedBrightness: Double {
        (red * 299 + green * 587 + blue * 114) / 1000
    }

    var isDark: Bool { perceivedBrightness < 0.5 }
    var isLight: Bool { !isDark }

    // MARK: Suggested text color on top of this color
    var onColor: Color { isDark ? .white : .black }
}

// MARK: - Color Manipulation
extension DevColor {

    /// Return a lighter version of this color
    func lightened(by amount: Double = 0.1) -> DevColor {
        var (h, s, l) = hsl
        l = min(100, l + amount * 100)
        return DevColor(hue: h, saturation: s / 100, lightness: l / 100, alpha: alpha)
    }

    /// Return a darker version of this color
    func darkened(by amount: Double = 0.1) -> DevColor {
        var (h, s, l) = hsl
        l = max(0, l - amount * 100)
        return DevColor(hue: h, saturation: s / 100, lightness: l / 100, alpha: alpha)
    }

    /// Return a desaturated version of this color
    func desaturated(by amount: Double = 0.2) -> DevColor {
        var (h, s, l) = hsl
        s = max(0, s - amount * 100)
        return DevColor(hue: h, saturation: s / 100, lightness: l / 100, alpha: alpha)
    }

    /// Return a copy with a new alpha
    func withAlpha(_ newAlpha: Double) -> DevColor {
        DevColor(red: red, green: green, blue: blue, alpha: newAlpha)
    }
}

// MARK: - Static Presets
extension DevColor {
    static let white   = DevColor(red: 1, green: 1, blue: 1)
    static let black   = DevColor(red: 0, green: 0, blue: 0)
    static let red     = DevColor(red: 1, green: 0, blue: 0)
    static let green   = DevColor(red: 0, green: 1, blue: 0)
    static let blue    = DevColor(red: 0, green: 0, blue: 1)
    static let accent  = DevColor(hex: "#7B6EF6")!
}

// MARK: - Color Conversion Helpers (pure math, private)
private extension DevColor {

    static func rgbToHsl(r: Double, g: Double, b: Double) -> (h: Double, s: Double, l: Double) {
        let max = Swift.max(r, g, b), min = Swift.min(r, g, b)
        let l = (max + min) / 2
        guard max != min else { return (0, 0, l * 100) }
        let d = max - min
        let s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
        let h: Double
        switch max {
        case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6
        case g: h = ((b - r) / d + 2) / 6
        default:h = ((r - g) / d + 4) / 6
        }
        return (h * 360, s * 100, l * 100)
    }

    static func hslToRgb(h: Double, s: Double, l: Double) -> (Double, Double, Double) {
        let hN = h / 360, sN = s, lN = l
        guard sN != 0 else { return (lN, lN, lN) }
        func hue2rgb(_ p: Double, _ q: Double, _ t: Double) -> Double {
            var t = t
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1/6 { return p + (q - p) * 6 * t }
            if t < 1/2 { return q }
            if t < 2/3 { return p + (q - p) * (2/3 - t) * 6 }
            return p
        }
        let q = lN < 0.5 ? lN * (1 + sN) : lN + sN - lN * sN
        let p = 2 * lN - q
        return (hue2rgb(p, q, hN + 1/3), hue2rgb(p, q, hN), hue2rgb(p, q, hN - 1/3))
    }
}

// MARK: - Comparable helpers
extension DevColor: CustomStringConvertible {
    var description: String { "DevColor(\(hex), alpha: \(alpha))" }
}

// MARK: - Comparable clamping helper
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
