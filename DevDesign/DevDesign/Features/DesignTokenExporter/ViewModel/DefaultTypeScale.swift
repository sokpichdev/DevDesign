//
//  DefaultTypeScale.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI
import Observation

// MARK: - Default type scale & spacing (mirrors TypeScaleModels + SpacingModels)
// We replicate just enough logic so this feature works standalone,
// without importing the other feature modules directly.

private enum DefaultTypeScale {
    struct Step {
        let name: String; let token: String; let size: Double
        let lineHeight: Double; let tracking: Double; let weight: String
    }

    static let steps: [Step] = {
        let base: Double = 16
        let ratio: Double = 1.25  // Major Third
        let anchor = 5            // "Body" is index 5 in the 10-step scale

        let meta: [(String, String, String)] = [
            ("Display",   "displayLarge",    "bold"),
            ("Title 1",   "titleOne",        "bold"),
            ("Title 2",   "titleTwo",        "semibold"),
            ("Title 3",   "titleThree",      "semibold"),
            ("Headline",  "headline",        "semibold"),
            ("Body",      "body",            "regular"),
            ("Callout",   "callout",         "regular"),
            ("Subhead",   "subhead",         "regular"),
            ("Footnote",  "footnote",        "regular"),
            ("Caption",   "caption",         "regular"),
        ]

        return meta.enumerated().map { (i, m) in
            let steps = anchor - i
            let raw   = base * pow(ratio, Double(steps))
            let size  = (raw * 10).rounded() / 10
            let lhm: Double
            switch size {
            case ..<14:  lhm = 1.6
            case ..<18:  lhm = 1.5
            case ..<24:  lhm = 1.4
            case ..<32:  lhm = 1.3
            default:     lhm = 1.2
            }
            let lh  = (size * lhm).rounded()
            let trk: Double
            switch size {
            case ..<14:  trk =  0.01
            case ..<24:  trk =  0.0
            case ..<48:  trk = -0.01
            default:     trk = -0.02
            }
            return Step(name: m.0, token: m.1, size: size,
                        lineHeight: lh, tracking: trk, weight: m.2)
        }
    }()
}

private enum DefaultSpacing {
    struct Token { let name: String; let token: String; let value: Double; let description: String }
    static let base: Double = 4
    static let tokens: [Token] = [
        Token(name: "xxs",  token: "spacingXXS",  value: base * 0.5,  description: "Hairline gap, tight chip padding"),
        Token(name: "xs",   token: "spacingXS",   value: base * 1.0,  description: "Icon gap, badge inset"),
        Token(name: "sm",   token: "spacingSM",   value: base * 2.0,  description: "Component inner padding"),
        Token(name: "md",   token: "spacingMD",   value: base * 3.0,  description: "Card padding, form spacing"),
        Token(name: "lg",   token: "spacingLG",   value: base * 4.0,  description: "Section gap, list row height"),
        Token(name: "xl",   token: "spacingXL",   value: base * 6.0,  description: "Section separation"),
        Token(name: "xxl",  token: "spacingXXL",  value: base * 8.0,  description: "Screen padding, page sections"),
        Token(name: "xxxl", token: "spacingXXXL", value: base * 10.0, description: "Hero spacing, splash padding"),
    ]
}

// MARK: - ViewModel

@Observable
final class DesignTokenViewModel {

    // MARK: - Section navigation
    var selectedSection: TokenSection = .colors

    // MARK: - Token data
    var colorTokens: [ColorToken]           = []
    var typographyTokens: [TypographyToken] = []
    var spacingTokens: [SpacingDesignToken] = []

    // MARK: - Export options
    var exportFormat: TokenExportFormat     = .swiftEnum
    var includeColors: Bool                 = true
    var includeTypography: Bool             = true
    var includeSpacing: Bool                = true
    var showExportSheet: Bool               = false
    var showCopiedToast: Bool               = false
    var copiedLabel: String                 = ""

    // MARK: - Search (used in Colors/Typography/Spacing sections)
    var searchText: String                  = ""

    // MARK: - Inline rename
    var editingTokenId: UUID?               = nil
    var editingTokenName: String            = ""

    // MARK: - Init — populate typography + spacing from defaults
    init() {
        typographyTokens = DefaultTypeScale.steps.map { s in
            TypographyToken(id: UUID(), tokenName: s.token, name: s.name,
                            size: s.size, lineHeight: 1.0,
                            tracking: s.tracking, weightRaw: s.weight)
        }
        // Store lineHeightPt directly in lineHeight field for display convenience
        typographyTokens = DefaultTypeScale.steps.map { s in
            TypographyToken(id: UUID(), tokenName: s.token, name: s.name,
                            size: s.size, lineHeight: s.lineHeight,
                            tracking: s.tracking, weightRaw: s.weight)
        }
        spacingTokens = DefaultSpacing.tokens.map { t in
            SpacingDesignToken(id: UUID(), tokenName: t.token, name: t.name,
                               value: t.value, description: t.description)
        }
    }

    // MARK: - Update colors from SwiftData palettes (called from View with @Query result)
    func updateColors(from palettes: [SavedPalette]) {
        var tokens: [ColorToken] = []
        for palette in palettes {
            for (i, sc) in palette.colors.enumerated() {
                let name = DesignTokenExportService.tokenName(from: sc.label, hex: sc.hex, index: i)
                tokens.append(ColorToken(
                    id: sc.id,
                    tokenName: name,
                    hex: sc.hex,
                    label: sc.label,
                    paletteName: palette.name,
                    paletteId: palette.id,
                    red: sc.red, green: sc.green, blue: sc.blue, alpha: sc.alpha
                ))
            }
        }
        // Only update if content actually changed (avoid thrashing animation)
        if tokens.map(\.id) != colorTokens.map(\.id) {
            colorTokens = tokens
        }
    }

    // MARK: - Fallback sample tokens (when no palettes saved)
    func seedSampleColors() {
        guard colorTokens.isEmpty else { return }
        let samples: [(String, String, Double, Double, Double)] = [
            ("primary",   "#7B6EF6", 0.482, 0.431, 0.965),
            ("secondary", "#FF9F0A", 1.0,   0.624, 0.039),
            ("success",   "#30D158", 0.188, 0.820, 0.345),
            ("danger",    "#FF453A", 1.0,   0.271, 0.227),
            ("neutral",   "#8E8E93", 0.557, 0.557, 0.576),
        ]
        colorTokens = samples.map { s in
            ColorToken(id: UUID(), tokenName: s.0, hex: s.1,
                       label: s.0, paletteName: "Sample",
                       paletteId: UUID(),
                       red: s.2, green: s.3, blue: s.4, alpha: 1.0)
        }
    }

    // MARK: - Filtered lists
    var filteredColors: [ColorToken] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return colorTokens }
        let q = searchText.lowercased()
        return colorTokens.filter {
            $0.tokenName.lowercased().contains(q) ||
            $0.hex.lowercased().contains(q) ||
            $0.paletteName.lowercased().contains(q) ||
            $0.label.lowercased().contains(q)
        }
    }

    var filteredTypography: [TypographyToken] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return typographyTokens }
        let q = searchText.lowercased()
        return typographyTokens.filter {
            $0.tokenName.lowercased().contains(q) || $0.name.lowercased().contains(q)
        }
    }

    var filteredSpacing: [SpacingDesignToken] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return spacingTokens }
        let q = searchText.lowercased()
        return spacingTokens.filter {
            $0.tokenName.lowercased().contains(q) || $0.name.lowercased().contains(q)
        }
    }

    // MARK: - Token count badge
    var totalTokenCount: Int { colorTokens.count + typographyTokens.count + spacingTokens.count }

    var sectionTokenCount: Int {
        switch selectedSection {
        case .colors:     return colorTokens.count
        case .typography: return typographyTokens.count
        case .spacing:    return spacingTokens.count
        case .export:     return totalTokenCount
        }
    }

    // MARK: - Inline rename
    func beginRename(id: UUID, currentName: String) {
        editingTokenId   = id
        editingTokenName = currentName
    }

    func commitRename() {
        guard let id = editingTokenId,
              !editingTokenName.trimmingCharacters(in: .whitespaces).isEmpty else {
            cancelRename(); return
        }
        let safe = camelCaseSafe(editingTokenName)
        if let i = colorTokens.firstIndex(where: { $0.id == id }) {
            var updated = colorTokens; updated[i].tokenName = safe; colorTokens = updated
        } else if let i = typographyTokens.firstIndex(where: { $0.id == id }) {
            var updated = typographyTokens; updated[i].tokenName = safe; typographyTokens = updated
        } else if let i = spacingTokens.firstIndex(where: { $0.id == id }) {
            var updated = spacingTokens; updated[i].tokenName = safe; spacingTokens = updated
        }
        cancelRename()
    }

    func cancelRename() {
        editingTokenId   = nil
        editingTokenName = ""
    }

    // MARK: - Export

    var tokenSet: DesignTokenSet {
        DesignTokenSet(colors: colorTokens,
                       typography: typographyTokens,
                       spacing: spacingTokens)
    }

    func exportCode(format: TokenExportFormat) -> String {
        switch format {
        case .swiftEnum:
            return DesignTokenExportService.exportSwift(
                tokenSet,
                includeColors: includeColors,
                includeTypography: includeTypography,
                includeSpacing: includeSpacing
            )
        case .json:
            return DesignTokenExportService.exportJSON(
                tokenSet,
                includeColors: includeColors,
                includeTypography: includeTypography,
                includeSpacing: includeSpacing
            )
        case .css:
            return DesignTokenExportService.exportCSS(
                tokenSet,
                includeColors: includeColors,
                includeTypography: includeTypography,
                includeSpacing: includeSpacing
            )
        case .all:
            let sep = "\n\n// " + String(repeating: "─", count: 60) + "\n\n"
            return exportCode(format: .swiftEnum)
                + sep + exportCode(format: .json)
                + sep + exportCode(format: .css)
        }
    }

    func copyExport(format: TokenExportFormat) {
        UIPasteboard.general.string = exportCode(format: format)
        showToast(label: "\(format.rawValue) tokens")
    }

    // MARK: - Quick-copy single token
    func copySingleSwift(_ token: ColorToken) {
        let code = "Color(hex: \"\(token.hex)\")"
        UIPasteboard.general.string = code
        showToast(label: token.tokenName)
    }

    // MARK: - Helpers
    private func showToast(label: String) {
        copiedLabel = label
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }

    private func camelCaseSafe(_ raw: String) -> String {
        let words = raw.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        guard !words.isEmpty else { return "token" }
        let first = words[0].prefix(1).lowercased() + words[0].dropFirst()
        let rest  = words.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }
        return ([String(first)] + rest).joined()
    }
}
