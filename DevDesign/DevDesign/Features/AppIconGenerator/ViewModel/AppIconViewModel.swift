//
//  AppIconViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI
import Observation

@Observable
final class AppIconViewModel {

    // MARK: - State
    var config: AppIconConfig = AppIconConfig()
    var symbolSearchText: String = ""
    var showSymbolPicker: Bool = false
    var showExportSheet: Bool = false
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""
    var selectedExportTab: IconExportTab = .preview
    var isRendering: Bool = false

    // MARK: - Symbol search
    var filteredSymbols: [String] {
        let q = symbolSearchText.trimmingCharacters(in: .whitespaces).lowercased()
        let pool = symbolPool
        guard !q.isEmpty else { return pool }
        return pool.filter { $0.contains(q) }
    }

    // MARK: - Presets
    static let presets: [AppIconPreset] = [
        AppIconPreset(name: "Ocean",    bg: "#007AFF", end: "#5E5CE6", symbol: "swift",              direction: .topLeadingToBottomTrailing, style: .gradient),
        AppIconPreset(name: "Sunset",   bg: "#FF6B6B", end: "#FF9F0A", symbol: "sun.horizon.fill",   direction: .topToBottom,               style: .gradient),
        AppIconPreset(name: "Forest",   bg: "#1A4731", end: "#30D158", symbol: "leaf.fill",           direction: .topLeadingToBottomTrailing, style: .gradient),
        AppIconPreset(name: "Midnight", bg: "#1C1C1E", end: "#3A3A3C", symbol: "moon.stars.fill",    direction: .topToBottom,               style: .solid),
        AppIconPreset(name: "Aurora",   bg: "#7B6EF6", end: "#64D2FF", symbol: "sparkles",           direction: .leftToRight,               style: .mesh),
        AppIconPreset(name: "Candy",    bg: "#FF6CAB", end: "#C4B5FD", symbol: "heart.fill",         direction: .radial,                    style: .gradient),
        AppIconPreset(name: "Obsidian", bg: "#000000", end: "#1C1C1E", symbol: "bolt.fill",          direction: .topToBottom,               style: .mesh),
        AppIconPreset(name: "Citrus",   bg: "#FFCC00", end: "#FF9F0A", symbol: "star.fill",          direction: .topLeadingToBottomTrailing, style: .solid),
    ]

    func applyPreset(_ preset: AppIconPreset) {
        var updated = config
        updated.backgroundStyle    = preset.style
        updated.backgroundColor    = Color(hex: preset.bg)
        updated.gradientEndColor   = Color(hex: preset.end)
        updated.gradientDirection  = preset.direction
        updated.symbolName         = preset.symbol
        updated.contentType        = .symbol
        config = updated
    }

    // MARK: - Config Mutations

    func setContentType(_ type: IconContentType) {
        var updated = config
        updated.contentType = type
        config = updated
    }

    func setSymbol(_ name: String) {
        var updated = config
        updated.symbolName = name
        config = updated
        showSymbolPicker = false
    }

    func setBackgroundStyle(_ style: IconBackgroundStyle) {
        var updated = config
        updated.backgroundStyle = style
        config = updated
    }

    func reset() {
        config = AppIconConfig()
    }

    // MARK: - Copy / Export

    func copySwiftSnippet() {
        UIPasteboard.general.string = AppIconExportService.exportSwiftSnippet(config: config)
        showToast(label: "Swift snippet")
    }

    func copyContentsJSON() {
        UIPasteboard.general.string = AppIconExportService.contentsJSON()
        showToast(label: "Contents.json")
    }

    private func showToast(label: String) {
        copiedLabel = label
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }

    // MARK: - Symbol pool (curated ~200)
    private let symbolPool: [String] = [
        // Tech
        "swift", "xcode", "cpu", "memorychip", "display", "iphone", "ipad",
        "applewatch", "airpods", "homepod", "appletv", "macbook", "keyboard",
        "cloud", "server.rack", "antenna.radiowaves.left.and.right",
        "network", "wifi", "bolt", "bolt.fill", "bolt.circle.fill",
        // Shapes & objects
        "star", "star.fill", "heart", "heart.fill", "diamond", "diamond.fill",
        "circle.fill", "square.fill", "triangle.fill", "hexagon.fill",
        "seal.fill", "shield.fill", "flame.fill", "drop.fill",
        "moon.fill", "moon.stars.fill", "sun.max.fill", "sun.horizon.fill",
        "cloud.fill", "cloud.bolt.fill", "snowflake", "wind",
        // Nature
        "leaf.fill", "tree.fill", "globe.americas.fill", "globe.europe.africa.fill",
        "mountain.2.fill", "beach.umbrella", "water.waves",
        // People
        "person.fill", "person.2.fill", "person.3.fill", "figure.run",
        "figure.walk", "brain.head.profile", "hand.raised.fill",
        // Tools
        "wrench.fill", "hammer.fill", "screwdriver.fill", "paintbrush.fill",
        "pencil", "pencil.circle.fill", "ruler.fill", "compass.drawing",
        "scissors", "tag.fill", "bookmark.fill", "doc.fill", "folder.fill",
        "tray.fill", "archivebox.fill", "externaldrive.fill",
        // Media
        "play.fill", "pause.fill", "music.note", "waveform", "speaker.fill",
        "mic.fill", "camera.fill", "video.fill", "photo.fill", "tv.fill",
        "headphones", "earbuds",
        // Arrows & direction
        "arrow.up", "arrow.down", "arrow.left", "arrow.right",
        "arrow.up.right", "arrow.clockwise", "arrow.triangle.2.circlepath",
        "chevron.up", "chevron.down", "return",
        // Communication
        "message.fill", "envelope.fill", "phone.fill", "bubble.left.fill",
        "bell.fill", "megaphone.fill", "antenna.radiowaves.left.and.right",
        // Finance
        "dollarsign.circle.fill", "eurosign.circle.fill", "chart.bar.fill",
        "chart.pie.fill", "chart.line.uptrend.xyaxis", "creditcard.fill",
        // Health
        "heart.text.square.fill", "cross.fill", "stethoscope", "pills.fill",
        "bandage.fill", "figure.walk.motion",
        // Productivity
        "checkmark.seal.fill", "checkmark.circle.fill", "xmark.circle.fill",
        "minus.circle.fill", "plus.circle.fill", "exclamationmark.circle.fill",
        "questionmark.circle.fill", "info.circle.fill",
        "calendar", "clock.fill", "alarm.fill", "timer", "stopwatch.fill",
        "map.fill", "location.fill", "flag.fill",
        // Games
        "gamecontroller.fill", "puzzlepiece.fill", "dice.fill",
        "trophy.fill", "medal.fill", "target",
        // Abstract / decorative
        "sparkles", "sparkle", "snowflake", "rays", "burst.fill",
        "waveform.path", "gyroscope", "atom", "infinity",
        "square.3.layers.3d", "cube.fill", "cylinder.fill",
        "app.fill", "app.dashed", "apps.iphone",
    ]
}

// MARK: - Supporting Types

enum IconExportTab: String, CaseIterable, Identifiable {
    case preview = "Size Preview"
    case swift   = "Swift Code"
    case json    = "Contents.json"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .preview: return "square.grid.3x3"
        case .swift:   return "swift"
        case .json:    return "curlybraces"
        }
    }
}

struct AppIconPreset: Identifiable {
    let id = UUID()
    let name: String
    let bg: String
    let end: String
    let symbol: String
    let direction: IconGradientDirection
    let style: IconBackgroundStyle
}
