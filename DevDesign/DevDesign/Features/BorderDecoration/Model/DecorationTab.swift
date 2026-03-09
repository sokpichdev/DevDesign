//
//  DecorationTab.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

// MARK: - Inspector Tab

enum DecorationTab: String, CaseIterable, Identifiable {
    case corners  = "Corners"
    case borders  = "Borders"
    case glow     = "Glow"
    case patterns = "Patterns"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .corners:  return "rectangle.roundedtop"
        case .borders:  return "rectangle.dashed"
        case .glow:     return "rays"
        case .patterns: return "squareshape.split.3x3"
        }
    }
}

// MARK: - Preview Shape

enum PreviewShape: String, CaseIterable, Identifiable {
    case rectangle = "Rect"
    case button    = "Button"
    case card      = "Card"
    case avatar    = "Avatar"

    var id: String { rawValue }

    var size: CGSize {
        switch self {
        case .rectangle: return CGSize(width: 200, height: 120)
        case .button:    return CGSize(width: 180, height: 52)
        case .card:      return CGSize(width: 220, height: 140)
        case .avatar:    return CGSize(width: 96,  height: 96)
        }
    }
}

// MARK: - ─── CORNERS ──────────────────────────────────────────

enum CornerStyle: String, CaseIterable, Identifiable {
    case rounded    = "Rounded"
    case circular   = "Circular"
    case continuous = "Continuous"   // iOS squircle
    case cut        = "Cut"          // chamfer

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .rounded:    return "rectangle.roundedtop"
        case .circular:   return "circle"
        case .continuous: return "app"
        case .cut:        return "diamond"
        }
    }
}

struct CornerConfig: Equatable {
    var style: CornerStyle  = .rounded
    var radius: CGFloat     = 12
    var perCorner: Bool     = false
    var topLeading: CGFloat     = 12
    var topTrailing: CGFloat    = 12
    var bottomLeading: CGFloat  = 12
    var bottomTrailing: CGFloat = 12
    var fillColor: Color    = Color(hex: "#7B6EF6")

    var effectiveRadius: CGFloat {
        perCorner ? max(topLeading, topTrailing, bottomLeading, bottomTrailing) : radius
    }
}

// iOS reference corner radii
struct CornerReference: Identifiable {
    let id = UUID()
    let label: String
    let radius: CGFloat
    let example: String
}

let cornerReferences: [CornerReference] = [
    CornerReference(label: "App Icon",      radius: 27,   example: "1024px icon squircle ≈ 22.5%"),
    CornerReference(label: "Widget (Sm)",   radius: 22,   example: "Small home screen widget"),
    CornerReference(label: "Widget (Lg)",   radius: 22,   example: "Large home screen widget"),
    CornerReference(label: "Sheet",         radius: 20,   example: "Bottom sheet, modal"),
    CornerReference(label: "Card",          radius: 16,   example: "Content card, list cell"),
    CornerReference(label: "Button (Lg)",   radius: 14,   example: "Primary CTA, filled button"),
    CornerReference(label: "Button (Sm)",   radius: 10,   example: "Secondary, outline button"),
    CornerReference(label: "Tag / Badge",   radius: 6,    example: "Chip, capsule badge"),
    CornerReference(label: "Text Field",    radius: 10,   example: "Form input"),
    CornerReference(label: "Notification",  radius: 20,   example: "Lock screen notification"),
]

// MARK: - ─── BORDERS ──────────────────────────────────────────

enum BorderStyleType: String, CaseIterable, Identifiable {
    case solid         = "Solid"
    case dashed        = "Dashed"
    case dotted        = "Dotted"
    case double_       = "Double"
    case gradient      = "Gradient"
    case innerStroke   = "Inner"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .solid:       return "rectangle"
        case .dashed:      return "rectangle.dashed"
        case .dotted:      return "circle.dotted"
        case .double_:     return "rectangle.fill.on.rectangle.fill"
        case .gradient:    return "circle.lefthalf.filled"
        case .innerStroke: return "square.inset.filled"
        }
    }
}

struct BorderConfig: Equatable {
    var styleType: BorderStyleType  = .solid
    var width: CGFloat              = 2
    var color: Color                = Color(hex: "#7B6EF6")
    var gradientStart: Color        = Color(hex: "#7B6EF6")
    var gradientEnd: Color          = Color(hex: "#FF6B6B")
    // Dash pattern
    var dashLength: CGFloat         = 8
    var dashGap: CGFloat            = 4
    // Double border
    var doubleInnerWidth: CGFloat   = 2
    var doubleGap: CGFloat          = 3
    // Opacity
    var opacity: Double             = 1.0
    var cornerRadius: CGFloat       = 12
}

// MARK: - ─── GLOW ─────────────────────────────────────────────

enum GlowType: String, CaseIterable, Identifiable {
    case outer      = "Outer Glow"
    case inner      = "Inner Glow"
    case coloredShadow = "Color Shadow"
    case neon       = "Neon"
    case layered    = "Layered"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .outer:         return "rays"
        case .inner:         return "circle.inset.filled"
        case .coloredShadow: return "shadow"
        case .neon:          return "bolt.circle"
        case .layered:       return "square.3.layers.3d"
        }
    }
    var description: String {
        switch self {
        case .outer:         return "Soft glow radiating outward"
        case .inner:         return "Light that appears inside the shape edge"
        case .coloredShadow: return "Drop shadow tinted with the shape color"
        case .neon:          return "Sharp + soft layers for a neon sign look"
        case .layered:       return "Multiple glow passes at different radii"
        }
    }
}

struct GlowConfig: Equatable {
    var type: GlowType      = .outer
    var color: Color        = Color(hex: "#7B6EF6")
    var radius: CGFloat     = 16
    var opacity: Double     = 0.7
    var offsetX: CGFloat    = 0
    var offsetY: CGFloat    = 4
    var fillColor: Color    = Color(hex: "#7B6EF6").opacity(0.3)   // shape fill for contrast
    var cornerRadius: CGFloat = 16
}

// MARK: - ─── PATTERNS ─────────────────────────────────────────

enum OverlayPatternType: String, CaseIterable, Identifiable {
    case grid       = "Grid"
    case dots       = "Dots"
    case stripes    = "Stripes"
    case crosshatch = "Crosshatch"
    case noise      = "Noise"
    case hexagons   = "Hexagons"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .grid:       return "grid"
        case .dots:       return "circle.grid.3x3"
        case .stripes:    return "line.diagonal"
        case .crosshatch: return "squareshape.split.3x3"
        case .noise:      return "waveform"
        case .hexagons:   return "hexagon"
        }
    }
}

struct PatternConfig: Equatable {
    var patternType: OverlayPatternType = .grid
    var color: Color        = Color(hex: "#7B6EF6")
    var opacity: Double     = 0.15
    var scale: CGFloat      = 20          // spacing / cell size
    var lineWidth: CGFloat  = 1
    var rotation: Double    = 0           // degrees, for stripes
    var fillColor: Color    = Color(hex: "#1C1C1E")
    var cornerRadius: CGFloat = 12
}

// MARK: - Preset

struct DecorationPreset: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let tab: DecorationTab
    // Stored as closures that mutate a master config
    let cornerConfig: CornerConfig?
    let borderConfig: BorderConfig?
    let glowConfig: GlowConfig?
    let patternConfig: PatternConfig?
}

enum DecorationPresetLibrary {
    static let corners: [DecorationPreset] = [
        DecorationPreset(name: "iOS Card",     icon: "rectangle.fill",
                         tab: .corners,
                         cornerConfig: { var c = CornerConfig(); c.style = .continuous; c.radius = 16; return c }(),
                         borderConfig: nil, glowConfig: nil, patternConfig: nil),
        DecorationPreset(name: "Button",       icon: "capsule",
                         tab: .corners,
                         cornerConfig: { var c = CornerConfig(); c.style = .rounded; c.radius = 14; return c }(),
                         borderConfig: nil, glowConfig: nil, patternConfig: nil),
        DecorationPreset(name: "App Icon",     icon: "app",
                         tab: .corners,
                         cornerConfig: { var c = CornerConfig(); c.style = .continuous; c.radius = 27; return c }(),
                         borderConfig: nil, glowConfig: nil, patternConfig: nil),
        DecorationPreset(name: "Pill",         icon: "capsule.fill",
                         tab: .corners,
                         cornerConfig: { var c = CornerConfig(); c.style = .circular; c.radius = 999; return c }(),
                         borderConfig: nil, glowConfig: nil, patternConfig: nil),
    ]

    static let borders: [DecorationPreset] = [
        DecorationPreset(name: "Subtle",    icon: "square",
                         tab: .borders,
                         cornerConfig: nil,
                         borderConfig: { var b = BorderConfig(); b.styleType = .solid; b.width = 1; b.opacity = 0.3; return b }(),
                         glowConfig: nil, patternConfig: nil),
        DecorationPreset(name: "Bold",      icon: "rectangle",
                         tab: .borders,
                         cornerConfig: nil,
                         borderConfig: { var b = BorderConfig(); b.styleType = .solid; b.width = 3; b.opacity = 1.0; return b }(),
                         glowConfig: nil, patternConfig: nil),
        DecorationPreset(name: "Dashed",    icon: "rectangle.dashed",
                         tab: .borders,
                         cornerConfig: nil,
                         borderConfig: { var b = BorderConfig(); b.styleType = .dashed; b.dashLength = 10; b.dashGap = 5; return b }(),
                         glowConfig: nil, patternConfig: nil),
        DecorationPreset(name: "Rainbow",   icon: "circle.lefthalf.filled",
                         tab: .borders,
                         cornerConfig: nil,
                         borderConfig: { var b = BorderConfig(); b.styleType = .gradient; b.width = 3; b.gradientStart = Color(hex: "#FF6B6B"); b.gradientEnd = Color(hex: "#7B6EF6"); return b }(),
                         glowConfig: nil, patternConfig: nil),
    ]

    static let glows: [DecorationPreset] = [
        DecorationPreset(name: "Purple Glow", icon: "rays",
                         tab: .glow,
                         cornerConfig: nil, borderConfig: nil,
                         glowConfig: { var g = GlowConfig(); g.type = .outer; g.color = Color(hex: "#7B6EF6"); g.radius = 20; return g }(),
                         patternConfig: nil),
        DecorationPreset(name: "Neon Blue",   icon: "bolt.circle",
                         tab: .glow,
                         cornerConfig: nil, borderConfig: nil,
                         glowConfig: { var g = GlowConfig(); g.type = .neon; g.color = Color(hex: "#64D2FF"); g.radius = 12; return g }(),
                         patternConfig: nil),
        DecorationPreset(name: "Warm Shadow", icon: "shadow",
                         tab: .glow,
                         cornerConfig: nil, borderConfig: nil,
                         glowConfig: { var g = GlowConfig(); g.type = .coloredShadow; g.color = Color(hex: "#FF9F0A"); g.offsetY = 8; g.radius = 16; return g }(),
                         patternConfig: nil),
        DecorationPreset(name: "Inner Light", icon: "circle.inset.filled",
                         tab: .glow,
                         cornerConfig: nil, borderConfig: nil,
                         glowConfig: { var g = GlowConfig(); g.type = .inner; g.color = .white; g.opacity = 0.5; g.radius = 10; return g }(),
                         patternConfig: nil),
    ]

    static let patterns: [DecorationPreset] = [
        DecorationPreset(name: "Grid",    icon: "grid",
                         tab: .patterns,
                         cornerConfig: nil, borderConfig: nil, glowConfig: nil,
                         patternConfig: { var p = PatternConfig(); p.patternType = .grid; p.scale = 20; return p }()),
        DecorationPreset(name: "Dots",    icon: "circle.grid.3x3",
                         tab: .patterns,
                         cornerConfig: nil, borderConfig: nil, glowConfig: nil,
                         patternConfig: { var p = PatternConfig(); p.patternType = .dots; p.scale = 16; return p }()),
        DecorationPreset(name: "Stripes", icon: "line.diagonal",
                         tab: .patterns,
                         cornerConfig: nil, borderConfig: nil, glowConfig: nil,
                         patternConfig: { var p = PatternConfig(); p.patternType = .stripes; p.scale = 12; p.rotation = 45; return p }()),
        DecorationPreset(name: "Hex",     icon: "hexagon",
                         tab: .patterns,
                         cornerConfig: nil, borderConfig: nil, glowConfig: nil,
                         patternConfig: { var p = PatternConfig(); p.patternType = .hexagons; p.scale = 24; return p }()),
    ]
}

// MARK: - Export Service

enum BorderDecorationExportService {

    // MARK: Corners
    static func exportCorners(_ cfg: CornerConfig) -> String {
        if cfg.perCorner {
            return """
// Per-corner radius
.clipShape(
    UnevenRoundedRectangle(
        topLeadingRadius:     \(Int(cfg.topLeading)),
        bottomLeadingRadius:  \(Int(cfg.bottomLeading)),
        bottomTrailingRadius: \(Int(cfg.bottomTrailing)),
        topTrailingRadius:    \(Int(cfg.topTrailing)),
        style: .\(swiftCornerStyle(cfg.style))
    )
)
"""
        }
        switch cfg.style {
        case .circular:
            return ".clipShape(Capsule())"
        case .continuous, .rounded:
            return ".clipShape(RoundedRectangle(cornerRadius: \(Int(cfg.radius)), style: .\(swiftCornerStyle(cfg.style))))"
        case .cut:
            return """
// Chamfer (cut corner) — requires custom Shape
.clipShape(ChamferRectangle(radius: \(Int(cfg.radius))))
"""
        }
    }

    // MARK: Borders
    static func exportBorder(_ cfg: BorderConfig) -> String {
        switch cfg.styleType {
        case .solid:
            return """
.overlay(
    RoundedRectangle(cornerRadius: \(Int(cfg.cornerRadius)))
        .strokeBorder(\(colorLiteral(cfg.color)), lineWidth: \(f(cfg.width)))
        \(cfg.opacity < 1 ? ".opacity(\(f(cfg.opacity)))" : "")
)
"""
        case .dashed:
            return """
.overlay(
    RoundedRectangle(cornerRadius: \(Int(cfg.cornerRadius)))
        .strokeBorder(
            \(colorLiteral(cfg.color)),
            style: StrokeStyle(
                lineWidth: \(f(cfg.width)),
                dash: [\(f(cfg.dashLength)), \(f(cfg.dashGap))]
            )
        )
)
"""
        case .dotted:
            return """
.overlay(
    RoundedRectangle(cornerRadius: \(Int(cfg.cornerRadius)))
        .strokeBorder(
            \(colorLiteral(cfg.color)),
            style: StrokeStyle(
                lineWidth: \(f(cfg.width)),
                lineCap: .round,
                dash: [0.1, \(f(cfg.dashGap + cfg.width))]
            )
        )
)
"""
        case .double_:
            return """
// Double border — outer ring
.overlay(
    RoundedRectangle(cornerRadius: \(Int(cfg.cornerRadius)))
        .strokeBorder(\(colorLiteral(cfg.color)), lineWidth: \(f(cfg.doubleInnerWidth)))
)
// Inner ring via padding
.padding(\(f(cfg.doubleGap)))
.overlay(
    RoundedRectangle(cornerRadius: \(Int(max(0, cfg.cornerRadius - cfg.doubleGap))))
        .strokeBorder(\(colorLiteral(cfg.color)), lineWidth: \(f(cfg.doubleInnerWidth)))
)
"""
        case .gradient:
            return """
.overlay(
    RoundedRectangle(cornerRadius: \(Int(cfg.cornerRadius)))
        .strokeBorder(
            LinearGradient(
                colors: [\(colorLiteral(cfg.gradientStart)), \(colorLiteral(cfg.gradientEnd))],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: \(f(cfg.width))
        )
)
"""
        case .innerStroke:
            return """
// Inner stroke — overlay inset shape
.overlay(
    RoundedRectangle(cornerRadius: \(Int(cfg.cornerRadius)))
        .stroke(\(colorLiteral(cfg.color)), lineWidth: \(f(cfg.width * 2)))
        .clipShape(RoundedRectangle(cornerRadius: \(Int(cfg.cornerRadius))))
        .opacity(\(f(cfg.opacity)))
)
"""
        }
    }

    // MARK: Glow
    static func exportGlow(_ cfg: GlowConfig) -> String {
        switch cfg.type {
        case .outer:
            return """
.shadow(
    color: \(colorLiteral(cfg.color)).opacity(\(f(cfg.opacity))),
    radius: \(f(cfg.radius)),
    x: \(f(cfg.offsetX)),
    y: \(f(cfg.offsetY))
)
"""
        case .coloredShadow:
            return """
.shadow(
    color: \(colorLiteral(cfg.color)).opacity(\(f(cfg.opacity))),
    radius: \(f(cfg.radius)),
    x: \(f(cfg.offsetX)),
    y: \(f(cfg.offsetY))
)
"""
        case .inner:
            return """
// Inner glow using overlay + blur
.overlay(
    RoundedRectangle(cornerRadius: \(f(cfg.cornerRadius)))
        .stroke(\(colorLiteral(cfg.color)).opacity(\(f(cfg.opacity))),
                lineWidth: \(f(cfg.radius * 0.5)))
        .blur(radius: \(f(cfg.radius * 0.4)))
        .blendMode(.plusLighter)
)
.clipShape(RoundedRectangle(cornerRadius: \(f(cfg.cornerRadius))))
"""
        case .neon:
            return """
// Neon glow — tight sharp layer + wide soft halo
.shadow(color: \(colorLiteral(cfg.color)), radius: \(f(cfg.radius * 0.3)), x: 0, y: 0)
.shadow(color: \(colorLiteral(cfg.color)).opacity(0.5), radius: \(f(cfg.radius)), x: 0, y: 0)
.shadow(color: \(colorLiteral(cfg.color)).opacity(0.25), radius: \(f(cfg.radius * 2)), x: 0, y: 0)
"""
        case .layered:
            return """
// Layered glow — 3 passes
.shadow(color: \(colorLiteral(cfg.color)).opacity(\(f(cfg.opacity))),      radius: \(f(cfg.radius * 0.5)), x: 0, y: 0)
.shadow(color: \(colorLiteral(cfg.color)).opacity(\(f(cfg.opacity * 0.6))), radius: \(f(cfg.radius)),       x: 0, y: 0)
.shadow(color: \(colorLiteral(cfg.color)).opacity(\(f(cfg.opacity * 0.3))), radius: \(f(cfg.radius * 2)),   x: 0, y: 0)
"""
        }
    }

    // MARK: Patterns
    static func exportPattern(_ cfg: PatternConfig) -> String {
        switch cfg.patternType {
        case .grid:
            return """
// Grid overlay pattern
.overlay(
    Canvas { ctx, size in
        let step: CGFloat = \(f(cfg.scale))
        let color = Color\(colorArgs(cfg.color)).opacity(\(f(cfg.opacity)))
        for x in stride(from: 0, through: size.width, by: step) {
            var v = Path(); v.move(to: CGPoint(x: x, y: 0)); v.addLine(to: CGPoint(x: x, y: size.height))
            ctx.stroke(v, with: .color(color), lineWidth: \(f(cfg.lineWidth)))
        }
        for y in stride(from: 0, through: size.height, by: step) {
            var h = Path(); h.move(to: CGPoint(x: 0, y: y)); h.addLine(to: CGPoint(x: size.width, y: y))
            ctx.stroke(h, with: .color(color), lineWidth: \(f(cfg.lineWidth)))
        }
    }
    .clipShape(RoundedRectangle(cornerRadius: \(f(cfg.cornerRadius))))
)
"""
        case .dots:
            return """
// Dot grid overlay
.overlay(
    Canvas { ctx, size in
        let spacing: CGFloat = \(f(cfg.scale))
        let r: CGFloat = \(f(cfg.lineWidth + 1))
        let color = Color\(colorArgs(cfg.color)).opacity(\(f(cfg.opacity)))
        for x in stride(from: spacing/2, through: size.width, by: spacing) {
            for y in stride(from: spacing/2, through: size.height, by: spacing) {
                let rect = CGRect(x: x - r, y: y - r, width: r*2, height: r*2)
                ctx.fill(Path(ellipseIn: rect), with: .color(color))
            }
        }
    }
    .clipShape(RoundedRectangle(cornerRadius: \(f(cfg.cornerRadius))))
)
"""
        case .stripes:
            return """
// Diagonal stripes overlay
.overlay(
    Canvas { ctx, size in
        let color = Color\(colorArgs(cfg.color)).opacity(\(f(cfg.opacity)))
        let step: CGFloat = \(f(cfg.scale))
        let diagonal = sqrt(size.width * size.width + size.height * size.height)
        var stripe = Path()
        var x = -diagonal
        while x < diagonal * 2 {
            stripe.move(to: CGPoint(x: x, y: -size.height))
            stripe.addLine(to: CGPoint(x: x + size.height, y: size.height * 2))
            x += step
        }
        ctx.translateBy(x: size.width/2, y: size.height/2)
        ctx.rotate(by: .degrees(\(f(cfg.rotation))))
        ctx.translateBy(x: -size.width/2, y: -size.height/2)
        ctx.stroke(stripe, with: .color(color), lineWidth: \(f(cfg.lineWidth)))
    }
    .clipShape(RoundedRectangle(cornerRadius: \(f(cfg.cornerRadius))))
)
"""
        case .crosshatch:
            return exportPattern({ var c = cfg; c.patternType = .stripes; c.rotation = 45; return c }()).appending(
                "\n// Add a second Canvas layer rotated -45° for crosshatch")
        case .noise:
            return """
// Noise texture — use a UIImage-based approach or a Metal shader.
// Lightweight SwiftUI approximation:
.overlay(
    Rectangle()
        .fill(.white.opacity(\(f(cfg.opacity * 0.06))))
        .blendMode(.overlay)
)
.clipShape(RoundedRectangle(cornerRadius: \(f(cfg.cornerRadius))))
"""
        case .hexagons:
            return """
// Hexagon grid — requires a custom Canvas drawing path.
// See: https://www.swiftbysundell.com/articles/drawing-shapes-in-swiftui
.overlay(
    Canvas { ctx, size in
        // Draw rows of hexagons with radius \(f(cfg.scale))
        // ... (custom hex grid implementation)
    }
    .opacity(\(f(cfg.opacity)))
    .clipShape(RoundedRectangle(cornerRadius: \(f(cfg.cornerRadius))))
)
"""
        }
    }

    // MARK: - Helpers
    private static func swiftCornerStyle(_ style: CornerStyle) -> String {
        switch style {
        case .rounded:    return "circular"
        case .continuous: return "continuous"
        case .circular:   return "circular"
        case .cut:        return "circular"
        }
    }

    static func colorLiteral(_ color: Color) -> String {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        let hex = String(format: "%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
        return "Color(hex: \"#\(hex)\")"
    }

    private static func colorArgs(_ color: Color) -> String {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return "(red: \(f(Double(r))), green: \(f(Double(g))), blue: \(f(Double(b))))"
    }

    static func f(_ v: CGFloat) -> String { f(Double(v)) }
    static func f(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", v)
            : String(format: "%.2f", v)
    }
}
