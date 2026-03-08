//
//  ShadowLayer.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Pure data + math. No UI dependencies.

import SwiftUI

// MARK: - Shadow Layer

struct ShadowLayer: Identifiable, Equatable {
    let id: UUID
    var isEnabled: Bool     = true
    var isInner: Bool       = false
    var color: Color        = .black
    var opacity: Double     = 0.25    // 0…1
    var x: Double           = 0       // pt
    var y: Double           = 4       // pt
    var blur: Double        = 8       // pt (radius)
    var spread: Double      = 0       // pt (positive = larger, negative = smaller)

    /// Resolved color including opacity
    var resolvedColor: Color { color.opacity(opacity) }

    // MARK: Presets
    static func soft() -> ShadowLayer {
        ShadowLayer(id: UUID(), isEnabled: true, isInner: false,
                    color: .black, opacity: 0.15, x: 0, y: 2, blur: 8, spread: 0)
    }
    static func medium() -> ShadowLayer {
        ShadowLayer(id: UUID(), isEnabled: true, isInner: false,
                    color: .black, opacity: 0.25, x: 0, y: 4, blur: 12, spread: -2)
    }
    static func hard() -> ShadowLayer {
        ShadowLayer(id: UUID(), isEnabled: true, isInner: false,
                    color: .black, opacity: 0.40, x: 2, y: 6, blur: 4, spread: 0)
    }
    static func glow(color: Color = .blue) -> ShadowLayer {
        ShadowLayer(id: UUID(), isEnabled: true, isInner: false,
                    color: color, opacity: 0.60, x: 0, y: 0, blur: 16, spread: 0)
    }
    static func inner() -> ShadowLayer {
        ShadowLayer(id: UUID(), isEnabled: true, isInner: true,
                    color: .black, opacity: 0.30, x: 0, y: 3, blur: 6, spread: 0)
    }
}

// MARK: - Preview Target

enum ShadowPreviewTarget: String, CaseIterable, Identifiable {
    case card    = "Card"
    case text    = "Text"
    case button  = "Button"
    case circle  = "Circle"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .card:   return "rectangle.roundedtop"
        case .text:   return "textformat"
        case .button: return "capsule"
        case .circle: return "circle"
        }
    }
}

// MARK: - Layer Preset

enum ShadowPreset: String, CaseIterable, Identifiable {
    case soft   = "Soft"
    case medium = "Medium"
    case hard   = "Hard"
    case glow   = "Glow"
    case inner  = "Inner"
    case custom = "Custom"

    var id: String { rawValue }

    func layers(accentColor: Color = .blue) -> [ShadowLayer] {
        switch self {
        case .soft:   return [.soft()]
        case .medium: return [.medium()]
        case .hard:   return [.hard()]
        case .glow:   return [.glow(color: accentColor)]
        case .inner:  return [.inner()]
        case .custom: return [.medium()]
        }
    }
}

// MARK: - Export Service

enum ShadowExportService {

    // MARK: SwiftUI
    static func exportSwiftUI(_ layers: [ShadowLayer]) -> String {
        let enabled = layers.filter(\.isEnabled)
        guard !enabled.isEmpty else { return "// No shadow layers" }

        var lines: [String] = []

        // SwiftUI only supports outer shadows natively via .shadow()
        // Inner shadows are simulated — we note this in the export.
        let outerLayers = enabled.filter { !$0.isInner }
        let innerLayers = enabled.filter(\.isInner)

        for layer in outerLayers {
            let r = colorComponents(layer.color)
            lines.append(
                ".shadow(color: Color(red: \(f(r.r)), green: \(f(r.g)), blue: \(f(r.b)))" +
                ".opacity(\(f(layer.opacity))), radius: \(f(layer.blur / 2)), " +
                "x: \(f(layer.x)), y: \(f(layer.y)))"
            )
        }

        if !innerLayers.isEmpty {
            lines.append("")
            lines.append("// Inner shadow — apply as overlay:")
            for layer in innerLayers {
                lines.append(innerShadowSwiftUI(layer))
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func innerShadowSwiftUI(_ layer: ShadowLayer) -> String {
        let r = colorComponents(layer.color)
        return """
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    Color(red: \(f(r.r)), green: \(f(r.g)), blue: \(f(r.b)))
                        .opacity(\(f(layer.opacity))),
                    lineWidth: \(f(layer.blur))
                )
                .blur(radius: \(f(layer.blur / 2)))
                .offset(x: \(f(layer.x)), y: \(f(layer.y)))
                .mask(RoundedRectangle(cornerRadius: cornerRadius))
        )
        """
    }

    // MARK: CSS
    static func exportCSS(_ layers: [ShadowLayer]) -> String {
        let enabled = layers.filter(\.isEnabled)
        guard !enabled.isEmpty else { return "/* No shadow layers */" }

        let values: [String] = enabled.map { layer in
            let r = colorComponents(layer.color)
            let ri = Int(r.r * 255), gi = Int(r.g * 255), bi = Int(r.b * 255)
            let rgba = "rgba(\(ri), \(gi), \(bi), \(f(layer.opacity)))"
            let spread = layer.spread != 0 ? " \(fInt(layer.spread))px" : ""
            let inset  = layer.isInner ? "inset " : ""
            return "\(inset)\(fInt(layer.x))px \(fInt(layer.y))px \(fInt(layer.blur))px\(spread) \(rgba)"
        }

        return "box-shadow: \(values.joined(separator: ",\n             "));"
    }

    // MARK: CSS Text Shadow
    static func exportCSSText(_ layers: [ShadowLayer]) -> String {
        let enabled = layers.filter { $0.isEnabled && !$0.isInner }
        guard !enabled.isEmpty else { return "/* No shadow layers */" }

        let values: [String] = enabled.map { layer in
            let r = colorComponents(layer.color)
            let ri = Int(r.r * 255), gi = Int(r.g * 255), bi = Int(r.b * 255)
            let rgba = "rgba(\(ri), \(gi), \(bi), \(f(layer.opacity)))"
            return "\(fInt(layer.x))px \(fInt(layer.y))px \(fInt(layer.blur))px \(rgba)"
        }

        return "text-shadow: \(values.joined(separator: ",\n             "));"
    }

    // MARK: UIKit / CALayer
    static func exportUIKit(_ layers: [ShadowLayer]) -> String {
        // UIKit natively supports only one shadow per layer;
        // for multiple we comment each out as a reference.
        let enabled = layers.filter { $0.isEnabled && !$0.isInner }

        if enabled.count == 1, let layer = enabled.first {
            let r = colorComponents(layer.color)
            return """
            layer.shadowColor   = UIColor(red: \(f(r.r)), green: \(f(r.g)), blue: \(f(r.b)), alpha: 1).cgColor
            layer.shadowOpacity = \(Float(layer.opacity))
            layer.shadowOffset  = CGSize(width: \(fInt(layer.x)), height: \(fInt(layer.y)))
            layer.shadowRadius  = \(f(layer.blur / 2))
            layer.masksToBounds = false
            """
        }

        var lines = ["// UIKit supports one shadow per layer."]
        lines.append("// For multiple shadows, use SwiftUI or a custom drawing approach.")
        lines.append("")
        for (i, layer) in enabled.enumerated() {
            let r = colorComponents(layer.color)
            lines.append("// Layer \(i + 1)")
            lines.append("// shadowColor:   UIColor(red: \(f(r.r)), green: \(f(r.g)), blue: \(f(r.b)), alpha: 1)")
            lines.append("// shadowOpacity: \(Float(layer.opacity))")
            lines.append("// shadowOffset:  CGSize(width: \(fInt(layer.x)), height: \(fInt(layer.y)))")
            lines.append("// shadowRadius:  \(f(layer.blur / 2))")
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: Helpers
    private static func colorComponents(_ color: Color) -> (r: Double, g: Double, b: Double) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }

    static func f(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", v)
            : String(format: "%.2f", v)
    }

    static func fInt(_ v: Double) -> String { String(format: "%.0f", v) }
}
