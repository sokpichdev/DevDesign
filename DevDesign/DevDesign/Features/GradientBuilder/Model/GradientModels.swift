//
//  GradientModels.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI

// MARK: - Gradient Type

enum GradientType: String, CaseIterable, Identifiable {
    case linear  = "Linear"
    case radial  = "Radial"
    case angular = "Angular"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .linear:  return "line.diagonal"
        case .radial:  return "circle.and.line.horizontal"
        case .angular: return "rotate.right"
        }
    }
}

// MARK: - Gradient Stop

struct GradientStop: Identifiable, Equatable {
    let id: UUID
    var color: Color
    var position: Double    // 0.0 … 1.0

    init(id: UUID = UUID(), color: Color, position: Double) {
        self.id = id
        self.color = color
        self.position = position
    }

    var gradientStop: Gradient.Stop {
        Gradient.Stop(color: color, location: position)
    }
}

// MARK: - Gradient Config

struct GradientConfig: Equatable {
    var type: GradientType      = .linear
    var stops: [GradientStop]   = GradientConfig.defaultStops()
    var angle: Double           = 135          // degrees — linear only
    var centerX: Double         = 0.5          // radial/angular center
    var centerY: Double         = 0.5
    var startRadius: Double     = 0            // radial only
    var endRadius: Double       = 200          // radial only

    // Derived
    var sortedStops: [GradientStop] { stops.sorted(by: { $0.position < $1.position }) }

    static func defaultStops() -> [GradientStop] {
        [
            GradientStop(color: Color(hex: "#7B6EF6"), position: 0.0),
            GradientStop(color: Color(hex: "#FF6B6B"), position: 1.0),
        ]
    }

    // MARK: SwiftUI Gradient helpers
    var gradient: Gradient { Gradient(stops: sortedStops.map(\.gradientStop)) }

    var linearGradient: LinearGradient {
        let radians = angle * .pi / 180
        let start = UnitPoint(
            x: 0.5 - 0.5 * cos(radians + .pi),
            y: 0.5 - 0.5 * sin(radians + .pi)
        )
        let end = UnitPoint(
            x: 0.5 - 0.5 * cos(radians),
            y: 0.5 - 0.5 * sin(radians)
        )
        return LinearGradient(gradient: gradient, startPoint: start, endPoint: end)
    }

    var radialGradient: RadialGradient {
        RadialGradient(
            gradient: gradient,
            center: UnitPoint(x: centerX, y: centerY),
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    var angularGradient: AngularGradient {
        AngularGradient(
            gradient: gradient,
            center: UnitPoint(x: centerX, y: centerY)
        )
    }
}

// MARK: - Preset

enum GradientPreset: String, CaseIterable, Identifiable {
    case sunset    = "Sunset"
    case ocean     = "Ocean"
    case forest    = "Forest"
    case candy     = "Candy"
    case midnight  = "Midnight"
    case fire      = "Fire"
    case aurora    = "Aurora"
    case monochrome = "Mono"

    var id: String { rawValue }

    var config: GradientConfig {
        switch self {
        case .sunset:
            return config(type: .linear, angle: 135, stops: [
                ("#FF6B6B", 0.0), ("#FF9F0A", 0.5), ("#FFCC00", 1.0)
            ])
        case .ocean:
            return config(type: .linear, angle: 180, stops: [
                ("#0066CC", 0.0), ("#00AAFF", 0.5), ("#64D2FF", 1.0)
            ])
        case .forest:
            return config(type: .linear, angle: 160, stops: [
                ("#1A4731", 0.0), ("#30D158", 0.6), ("#A8E6B0", 1.0)
            ])
        case .candy:
            return config(type: .linear, angle: 90, stops: [
                ("#FF6CAB", 0.0), ("#FF9FD1", 0.5), ("#C4B5FD", 1.0)
            ])
        case .midnight:
            return config(type: .radial, angle: 0, stops: [
                ("#7B6EF6", 0.0), ("#3D2B8C", 0.5), ("#0A0A1E", 1.0)
            ])
        case .fire:
            return config(type: .angular, angle: 0, stops: [
                ("#FF3B30", 0.0), ("#FF9F0A", 0.33), ("#FFCC00", 0.66), ("#FF3B30", 1.0)
            ])
        case .aurora:
            return config(type: .linear, angle: 100, stops: [
                ("#00FFCC", 0.0), ("#7B6EF6", 0.4), ("#FF6B6B", 0.7), ("#FFCC00", 1.0)
            ])
        case .monochrome:
            return config(type: .linear, angle: 135, stops: [
                ("#1C1C1E", 0.0), ("#636366", 0.5), ("#EBEBF5", 1.0)
            ])
        }
    }

    private func config(type: GradientType, angle: Double,
                        stops: [(String, Double)]) -> GradientConfig {
        var cfg = GradientConfig()
        cfg.type = type
        cfg.angle = angle
        cfg.stops = stops.map { GradientStop(color: Color(hex: $0.0), position: $0.1) }
        return cfg
    }
}

// MARK: - Preview Shape

enum GradientPreviewShape: String, CaseIterable, Identifiable {
    case rectangle = "Rectangle"
    case circle    = "Circle"
    case capsule   = "Capsule"
    case card      = "Card"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .rectangle: return "rectangle.fill"
        case .circle:    return "circle.fill"
        case .capsule:   return "capsule.fill"
        case .card:      return "rectangle.roundedtop.fill"
        }
    }
}

// MARK: - Export Service

enum GradientExportService {

    // MARK: SwiftUI
    static func exportSwiftUI(_ config: GradientConfig) -> String {
        let stopsCode = config.sortedStops.map { stop in
            let c = components(stop.color)
            return "    .init(color: Color(red: \(f(c.r)), green: \(f(c.g)), blue: \(f(c.b))), location: \(f(stop.position)))"
        }.joined(separator: ",\n")

        let gradientInit = """
        let gradient = Gradient(stops: [
        \(stopsCode)
        ])
        """

        switch config.type {
        case .linear:
            let (start, end) = linearPoints(config.angle)
            return """
            \(gradientInit)

            LinearGradient(
                gradient: gradient,
                startPoint: UnitPoint(x: \(f(start.x)), y: \(f(start.y))),
                endPoint: UnitPoint(x: \(f(end.x)), y: \(f(end.y)))
            )
            """
        case .radial:
            return """
            \(gradientInit)

            RadialGradient(
                gradient: gradient,
                center: UnitPoint(x: \(f(config.centerX)), y: \(f(config.centerY))),
                startRadius: \(f(config.startRadius)),
                endRadius: \(f(config.endRadius))
            )
            """
        case .angular:
            return """
            \(gradientInit)

            AngularGradient(
                gradient: gradient,
                center: UnitPoint(x: \(f(config.centerX)), y: \(f(config.centerY)))
            )
            """
        }
    }

    // MARK: SwiftUI fill shorthand
    static func exportSwiftUIFill(_ config: GradientConfig) -> String {
        let hexList = config.sortedStops.map { "Color(hex: \"\(hex($0.color))\")" }
            .joined(separator: ", ")

        switch config.type {
        case .linear:
            let deg = Int(config.angle)
            return """
            .fill(
                LinearGradient(
                    colors: [\(hexList)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            // Tip: adjust angle \(deg)° via startPoint/endPoint
            """
        case .radial:
            return """
            .fill(
                RadialGradient(
                    colors: [\(hexList)],
                    center: .center,
                    startRadius: \(Int(config.startRadius)),
                    endRadius: \(Int(config.endRadius))
                )
            )
            """
        case .angular:
            return """
            .fill(
                AngularGradient(
                    colors: [\(hexList)],
                    center: .center
                )
            )
            """
        }
    }

    // MARK: CSS
    static func exportCSS(_ config: GradientConfig) -> String {
        let stops = config.sortedStops.map { stop in
            let c = components(stop.color)
            let r = Int(c.r * 255), g = Int(c.g * 255), b = Int(c.b * 255)
            return "rgb(\(r), \(g), \(b)) \(Int(stop.position * 100))%"
        }.joined(separator: ", ")

        switch config.type {
        case .linear:
            return "background: linear-gradient(\(Int(config.angle))deg, \(stops));"
        case .radial:
            return "background: radial-gradient(circle at \(Int(config.centerX * 100))% \(Int(config.centerY * 100))%, \(stops));"
        case .angular:
            return "background: conic-gradient(from 0deg at \(Int(config.centerX * 100))% \(Int(config.centerY * 100))%, \(stops));"
        }
    }

    // MARK: UIKit / CAGradientLayer
    static func exportUIKit(_ config: GradientConfig) -> String {
        let colorsCode = config.sortedStops.map { stop in
            let c = components(stop.color)
            return "    UIColor(red: \(f(c.r)), green: \(f(c.g)), blue: \(f(c.b)), alpha: 1).cgColor"
        }.joined(separator: ",\n")

        let locationsCode = config.sortedStops.map { "    \(f($0.position))" }
            .joined(separator: ",\n")

        switch config.type {
        case .linear:
            let (start, end) = linearPoints(config.angle)
            return """
            let layer = CAGradientLayer()
            layer.colors = [
            \(colorsCode)
            ]
            layer.locations = [
            \(locationsCode)
            ]
            layer.startPoint = CGPoint(x: \(f(start.x)), y: \(f(start.y)))
            layer.endPoint   = CGPoint(x: \(f(end.x)), y: \(f(end.y)))
            layer.frame = view.bounds
            view.layer.insertSublayer(layer, at: 0)
            """
        case .radial, .angular:
            return """
            // CAGradientLayer has limited radial/conic support.
            // Use a SwiftUI wrapper or custom Metal shader for best results.
            // Approximate with type = .radial:
            let layer = CAGradientLayer()
            layer.type = .radial
            layer.colors = [
            \(colorsCode)
            ]
            layer.startPoint = CGPoint(x: \(f(config.centerX)), y: \(f(config.centerY)))
            layer.endPoint   = CGPoint(x: 1, y: 1)
            layer.frame = view.bounds
            view.layer.insertSublayer(layer, at: 0)
            """
        }
    }

    // MARK: JSON
    static func exportJSON(_ config: GradientConfig) -> String {
        let stops = config.sortedStops.map { stop -> [String: Any] in
            let c = components(stop.color)
            return [
                "hex": hex(stop.color),
                "r": Double(Int(c.r * 255)),
                "g": Double(Int(c.g * 255)),
                "b": Double(Int(c.b * 255)),
                "position": stop.position
            ]
        }
        let dict: [String: Any] = [
            "type": config.type.rawValue.lowercased(),
            "angle": config.angle,
            "center": ["x": config.centerX, "y": config.centerY],
            "stops": stops
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let str = String(data: data, encoding: .utf8) else { return "{}" }
        return str
    }

    // MARK: - Helpers
    static func linearPoints(_ angle: Double) -> (start: CGPoint, end: CGPoint) {
        let rad = angle * .pi / 180
        let start = CGPoint(
            x: 0.5 - 0.5 * cos(rad + .pi),
            y: 0.5 - 0.5 * sin(rad + .pi)
        )
        let end = CGPoint(
            x: 0.5 - 0.5 * cos(rad),
            y: 0.5 - 0.5 * sin(rad)
        )
        return (start, end)
    }

    static func components(_ color: Color) -> (r: Double, g: Double, b: Double) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }

    static func hex(_ color: Color) -> String {
        let c = components(color)
        return String(format: "#%02X%02X%02X",
                      Int(c.r * 255), Int(c.g * 255), Int(c.b * 255))
    }

    static func f(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", v)
            : String(format: "%.2f", v)
    }
}
