//
//  SymbolEffectsExportService.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  Turns a SymbolEffectsConfig into ready-to-paste SwiftUI and UIKit code
//  using Apple's native .symbolEffect API.
//

import SwiftUI

// MARK: - Export Format

enum SymbolEffectExportFormat: String, CaseIterable, Identifiable {
    case swiftUI = "SwiftUI"
    case uiKit   = "UIKit"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .swiftUI: return "swift"
        case .uiKit:   return "iphone"
        }
    }
}

// MARK: - Export Service

enum SymbolEffectsExportService {

    static func export(_ config: SymbolEffectsConfig, as format: SymbolEffectExportFormat) -> String {
        switch format {
        case .swiftUI: return swiftUI(config)
        case .uiKit:   return uiKit(config)
        }
    }

    // MARK: - SwiftUI

    private static func swiftUI(_ c: SymbolEffectsConfig) -> String {
        let size = trimmed(c.size)
        let speed = trimmed(c.speed)

        // Discrete effects loop with .repeat(.continuous); indefinite ones run
        // while present, toggled by isActive.
        let modifier: String
        if c.kind.isDiscrete {
            modifier = ".symbolEffect(\(c.kind.effectLiteral), options: .repeat(.continuous).speed(\(speed)))"
        } else {
            modifier = ".symbolEffect(\(c.kind.effectLiteral), options: .speed(\(speed)), isActive: true)"
        }

        return """
        import SwiftUI

        Image(systemName: "\(c.symbolName)")
            .resizable()
            .scaledToFit()
            .frame(width: \(size), height: \(size))
            .foregroundStyle(\(colorLiteral(c.primaryColor)))
            \(modifier)
        """
    }

    // MARK: - UIKit

    private static func uiKit(_ c: SymbolEffectsConfig) -> String {
        let size = trimmed(c.size)
        // UIKit uses NSSymbolEffect types; map by case.
        let effect: String
        switch c.kind {
        case .bounce:        effect = "NSSymbolBounceEffect()"
        case .pulse:         effect = "NSSymbolPulseEffect()"
        case .variableColor: effect = "NSSymbolVariableColorEffect().iterative()"
        case .wiggle:        effect = "NSSymbolWiggleEffect()"
        case .breathe:       effect = "NSSymbolBreatheEffect()"
        case .rotate:        effect = "NSSymbolRotateEffect()"
        }

        return """
        let config = UIImage.SymbolConfiguration(pointSize: \(size))
        let imageView = UIImageView(
            image: UIImage(systemName: "\(c.symbolName)", withConfiguration: config)
        )
        imageView.addSymbolEffect(\(effect), options: .repeating)
        """
    }

    // MARK: - Helpers

    private static func colorLiteral(_ color: Color) -> String {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return "Color(red: \(round3(r)), green: \(round3(g)), blue: \(round3(b)))"
    }

    private static func trimmed(_ v: CGFloat) -> String { trimmed(Double(v)) }

    private static func trimmed(_ v: Double) -> String {
        let r = (v * 100).rounded() / 100
        return r == r.rounded() ? String(Int(r)) : String(r)
    }

    private static func round3(_ v: CGFloat) -> Double { (Double(v) * 1000).rounded() / 1000 }
}
