//
//  PairingCategory.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Pure data — no UI, no SwiftUI imports.

import UIKit

// MARK: - Pairing Category

enum PairingCategory: String, CaseIterable, Identifiable {
    case all        = "All"
    case modern     = "Modern"
    case editorial  = "Editorial"
    case classic    = "Classic"
    case developer  = "Developer"
    case minimal    = "Minimal"
    case expressive = "Expressive"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all:        return "square.grid.2x2"
        case .modern:     return "sparkles"
        case .editorial:  return "newspaper"
        case .classic:    return "books.vertical"
        case .developer:  return "chevron.left.forwardslash.chevron.right"
        case .minimal:    return "minus"
        case .expressive: return "paintbrush"
        }
    }
}

// MARK: - Font Source

enum FontSource: Equatable {
    case system                         // SF Pro
    case systemSerif                    // New York
    case systemMono                     // SF Mono
    case google(family: String)         // Google Fonts family name
}

// MARK: - Font Spec
// Describes one font in a pairing (display or body role).

struct FontSpec: Identifiable, Equatable {
    let id: UUID
    let displayName: String         // shown in UI
    let source: FontSource
    var loadedFamilyName: String?   // set after Google Font is registered

    /// The family name to use for UIFont / SwiftUI Font
    var resolvedFamilyName: String {
        switch source {
        case .system:       return "SF Pro"          // UIFont.systemFont placeholder
        case .systemSerif:  return "New York"
        case .systemMono:   return "SF Mono"
        case .google:       return loadedFamilyName ?? displayName
        }
    }

    var isSystem: Bool {
        switch source {
        case .system, .systemSerif, .systemMono: return true
        case .google: return false
        }
    }

    var isLoaded: Bool {
        switch source {
        case .system, .systemSerif, .systemMono: return true
        case .google: return loadedFamilyName != nil
        }
    }

    /// UIFont for preview — falls back to system equivalents while Google Font loads
    func uiFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        switch source {
        case .system:
            return UIFont.systemFont(ofSize: size, weight: weight)
        case .systemSerif:
            return UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                .withDesign(.serif)!
                .withSymbolicTraits(weight == .bold ? .traitBold : [])!,
                size: size)
        case .systemMono:
            return UIFont.monospacedSystemFont(ofSize: size, weight: weight)
        case .google(let family):
            if let loaded = loadedFamilyName,
               let font = UIFont(name: loaded, size: size) {
                return font
            }
            // Fallback while loading
            if family.lowercased().contains("mono") || family.lowercased().contains("code") {
                return UIFont.monospacedSystemFont(ofSize: size, weight: weight)
            }
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
}

// MARK: - Font Pair

struct FontPair: Identifiable {
    let id: UUID
    let name: String            // e.g. "Playfair + Source Sans"
    let category: PairingCategory
    let description: String
    let tags: [String]
    var displayFont: FontSpec   // heading / display role
    var bodyFont: FontSpec      // body / paragraph role

    var isFullyLoaded: Bool { displayFont.isLoaded && bodyFont.isLoaded }
}

// MARK: - Curated Pairing Library

enum FontPairingLibrary {

    static let pairs: [FontPair] = [

        // ── MODERN ──────────────────────────────────────────────

        FontPair(
            id: UUID(), name: "Inter + Inter",
            category: .modern,
            description: "The definitive modern UI pairing. Variable weight gives full hierarchy from one family.",
            tags: ["ui", "clean", "tech"],
            displayFont: FontSpec(id: UUID(), displayName: "Inter", source: .google(family: "Inter")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Inter", source: .google(family: "Inter"))
        ),
        FontPair(
            id: UUID(), name: "Plus Jakarta Sans + DM Sans",
            category: .modern,
            description: "Rounded geometric display with a humanist body. Warm and contemporary.",
            tags: ["rounded", "product", "app"],
            displayFont: FontSpec(id: UUID(), displayName: "Plus Jakarta Sans", source: .google(family: "Plus Jakarta Sans")),
            bodyFont:    FontSpec(id: UUID(), displayName: "DM Sans",           source: .google(family: "DM Sans"))
        ),
        FontPair(
            id: UUID(), name: "Space Grotesk + Space Mono",
            category: .modern,
            description: "Quirky geometric grotesque paired with its mono sibling. Distinctive developer aesthetic.",
            tags: ["geometric", "tech", "bold"],
            displayFont: FontSpec(id: UUID(), displayName: "Space Grotesk", source: .google(family: "Space Grotesk")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Space Mono",    source: .google(family: "Space Mono"))
        ),

        // ── EDITORIAL ──────────────────────────────────────────

        FontPair(
            id: UUID(), name: "Playfair Display + Source Sans 3",
            category: .editorial,
            description: "High contrast serif headline with neutral humanist body. The editorial standard.",
            tags: ["serif", "editorial", "news"],
            displayFont: FontSpec(id: UUID(), displayName: "Playfair Display", source: .google(family: "Playfair Display")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Source Sans 3",    source: .google(family: "Source Sans 3"))
        ),
        FontPair(
            id: UUID(), name: "Fraunces + Mulish",
            category: .editorial,
            description: "Optical variable serif with a clean geometric sans. Expressive yet readable.",
            tags: ["optical", "variable", "magazine"],
            displayFont: FontSpec(id: UUID(), displayName: "Fraunces", source: .google(family: "Fraunces")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Mulish",   source: .google(family: "Mulish"))
        ),
        FontPair(
            id: UUID(), name: "DM Serif Display + DM Sans",
            category: .editorial,
            description: "Ink-trap serif headline with its geometric sans counterpart. Confident pairing.",
            tags: ["ink-trap", "dm", "bold"],
            displayFont: FontSpec(id: UUID(), displayName: "DM Serif Display", source: .google(family: "DM Serif Display")),
            bodyFont:    FontSpec(id: UUID(), displayName: "DM Sans",          source: .google(family: "DM Sans"))
        ),

        // ── CLASSIC ────────────────────────────────────────────

        FontPair(
            id: UUID(), name: "New York + SF Pro",
            category: .classic,
            description: "Apple's own editorial pairing. Serif headlines with the system UI font. Zero loading.",
            tags: ["system", "apple", "native"],
            displayFont: FontSpec(id: UUID(), displayName: "New York", source: .systemSerif),
            bodyFont:    FontSpec(id: UUID(), displayName: "SF Pro",   source: .system)
        ),
        FontPair(
            id: UUID(), name: "Libre Baskerville + Lato",
            category: .classic,
            description: "Timeless book serif with an elegant humanist sans. Professional and trustworthy.",
            tags: ["book", "serif", "humanist"],
            displayFont: FontSpec(id: UUID(), displayName: "Libre Baskerville", source: .google(family: "Libre Baskerville")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Lato",              source: .google(family: "Lato"))
        ),
        FontPair(
            id: UUID(), name: "Cormorant + Proza Libre",
            category: .classic,
            description: "Delicate high-contrast display serif with a robust screen-optimised body.",
            tags: ["luxury", "high-contrast", "elegant"],
            displayFont: FontSpec(id: UUID(), displayName: "Cormorant",   source: .google(family: "Cormorant")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Proza Libre", source: .google(family: "Proza Libre"))
        ),

        // ── DEVELOPER ──────────────────────────────────────────

        FontPair(
            id: UUID(), name: "SF Pro + SF Mono",
            category: .developer,
            description: "The native Apple developer pairing. UI text with monospace for code blocks.",
            tags: ["system", "code", "apple"],
            displayFont: FontSpec(id: UUID(), displayName: "SF Pro",  source: .system),
            bodyFont:    FontSpec(id: UUID(), displayName: "SF Mono", source: .systemMono)
        ),
        FontPair(
            id: UUID(), name: "JetBrains Mono + Inter",
            category: .developer,
            description: "The favourite developer monospace for code with clean Inter for prose.",
            tags: ["mono", "code", "readable"],
            displayFont: FontSpec(id: UUID(), displayName: "JetBrains Mono", source: .google(family: "JetBrains Mono")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Inter",          source: .google(family: "Inter"))
        ),
        FontPair(
            id: UUID(), name: "Fira Code + Fira Sans",
            category: .developer,
            description: "Ligature-rich monospace display with a humanist body from the same family.",
            tags: ["ligatures", "mono", "fira"],
            displayFont: FontSpec(id: UUID(), displayName: "Fira Code", source: .google(family: "Fira Code")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Fira Sans", source: .google(family: "Fira Sans"))
        ),

        // ── MINIMAL ────────────────────────────────────────────

        FontPair(
            id: UUID(), name: "Work Sans + Work Sans",
            category: .minimal,
            description: "Single family, full range. Weight contrast alone builds all the hierarchy you need.",
            tags: ["single-family", "weight", "clean"],
            displayFont: FontSpec(id: UUID(), displayName: "Work Sans", source: .google(family: "Work Sans")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Work Sans", source: .google(family: "Work Sans"))
        ),
        FontPair(
            id: UUID(), name: "Nunito + Nunito Sans",
            category: .minimal,
            description: "Rounded and friendly. Display with rounded terminals, body with subtle squareness.",
            tags: ["rounded", "friendly", "soft"],
            displayFont: FontSpec(id: UUID(), displayName: "Nunito",      source: .google(family: "Nunito")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Nunito Sans", source: .google(family: "Nunito Sans"))
        ),

        // ── EXPRESSIVE ─────────────────────────────────────────

        FontPair(
            id: UUID(), name: "Bebas Neue + Open Sans",
            category: .expressive,
            description: "All-caps condensed display with workhorse body. Punchy and high-impact.",
            tags: ["condensed", "bold", "impact"],
            displayFont: FontSpec(id: UUID(), displayName: "Bebas Neue", source: .google(family: "Bebas Neue")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Open Sans",  source: .google(family: "Open Sans"))
        ),
        FontPair(
            id: UUID(), name: "Abril Fatface + Lato",
            category: .expressive,
            description: "Ultra-bold slab display face with light humanist sans. Maximum contrast, maximum drama.",
            tags: ["slab", "bold", "poster"],
            displayFont: FontSpec(id: UUID(), displayName: "Abril Fatface", source: .google(family: "Abril Fatface")),
            bodyFont:    FontSpec(id: UUID(), displayName: "Lato",          source: .google(family: "Lato"))
        ),
    ]
}

// MARK: - Export Service

enum FontPairingExportService {

    static func exportSwiftUI(_ pair: FontPair, displaySize: CGFloat = 32, bodySize: CGFloat = 16) -> String {
        let displayFont = swiftUIFont(pair.displayFont, size: displaySize, weight: "bold")
        let bodyFont    = swiftUIFont(pair.bodyFont,    size: bodySize,   weight: "regular")
        return """
// Generated by DevDesign — \(pair.name)
import SwiftUI

extension Font {
    // Display: \(pair.displayFont.displayName)
    static let pairingDisplay: Font = \(displayFont)
    // Body: \(pair.bodyFont.displayName)
    static let pairingBody: Font = \(bodyFont)
}
"""
    }

    static func exportCSS(_ pair: FontPair) -> String {
        let displayImport = cssImport(pair.displayFont)
        let bodyImport    = pair.bodyFont.source == pair.displayFont.source ? "" : cssImport(pair.bodyFont)
        let imports = [displayImport, bodyImport].filter { !$0.isEmpty }.joined(separator: "\n")

        return """
/* Generated by DevDesign — \(pair.name) */
\(imports)

:root {
  --font-display: '\(pair.displayFont.displayName)', \(genericFamily(pair.displayFont));
  --font-body: '\(pair.bodyFont.displayName)', \(genericFamily(pair.bodyFont));
}

h1, h2, h3, h4, h5, h6 {
  font-family: var(--font-display);
  font-weight: 700;
}

body, p {
  font-family: var(--font-body);
  font-weight: 400;
}
"""
    }

    // MARK: - Helpers

    private static func swiftUIFont(_ spec: FontSpec, size: CGFloat, weight: String) -> String {
        switch spec.source {
        case .system:
            return ".system(size: \(Int(size)), weight: .\(weight))"
        case .systemSerif:
            return ".system(size: \(Int(size)), weight: .\(weight), design: .serif)"
        case .systemMono:
            return ".system(size: \(Int(size)), weight: .\(weight), design: .monospaced)"
        case .google(let family):
            let loaded = spec.loadedFamilyName ?? family
            return ".custom(\"\(loaded)\", size: \(Int(size)))"
        }
    }

    private static func cssImport(_ spec: FontSpec) -> String {
        switch spec.source {
        case .system, .systemSerif, .systemMono:
            return ""
        case .google(let family):
            let encoded = family.replacingOccurrences(of: " ", with: "+")
            return "@import url('https://fonts.googleapis.com/css2?family=\(encoded):wght@300;400;600;700&display=swap');"
        }
    }

    private static func genericFamily(_ spec: FontSpec) -> String {
        switch spec.source {
        case .systemMono:        return "monospace"
        case .systemSerif:       return "serif"
        case .system:            return "sans-serif"
        case .google(let name):
            if name.lowercased().contains("mono") || name.lowercased().contains("code") {
                return "monospace"
            }
            return "sans-serif"
        }
    }
}
