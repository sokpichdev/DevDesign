//
//  IconContentType.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

// MARK: - Icon Content Type

enum IconContentType: String, CaseIterable, Identifiable {
    case symbol   = "SF Symbol"
    case initials = "Initials"
    case emoji    = "Emoji"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .symbol:   return "square.grid.2x2"
        case .initials: return "textformat"
        case .emoji:    return "face.smiling"
        }
    }
}

// MARK: - Background Style

enum IconBackgroundStyle: String, CaseIterable, Identifiable {
    case solid    = "Solid"
    case gradient = "Gradient"
    case mesh     = "Mesh"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .solid:    return "circle.fill"
        case .gradient: return "circle.lefthalf.filled"
        case .mesh:     return "circle.hexagongrid.fill"
        }
    }
}

// MARK: - Gradient Direction

enum IconGradientDirection: String, CaseIterable, Identifiable {
    case topToBottom    = "Top → Bottom"
    case topLeadingToBottomTrailing = "Diagonal ↘"
    case leftToRight    = "Left → Right"
    case radial         = "Radial"

    var id: String { rawValue }

    func gradient(from: Color, to: Color, size: CGFloat) -> AnyShapeStyle {
        switch self {
        case .topToBottom:
            return AnyShapeStyle(LinearGradient(colors: [from, to], startPoint: .top, endPoint: .bottom))
        case .topLeadingToBottomTrailing:
            return AnyShapeStyle(LinearGradient(colors: [from, to], startPoint: .topLeading, endPoint: .bottomTrailing))
        case .leftToRight:
            return AnyShapeStyle(LinearGradient(colors: [from, to], startPoint: .leading, endPoint: .trailing))
        case .radial:
            return AnyShapeStyle(RadialGradient(colors: [from, to], center: .center, startRadius: 0, endRadius: size * 0.7))
        }
    }
}

// MARK: - Icon Config

struct AppIconConfig: Equatable {

    // Content
    var contentType: IconContentType     = .symbol
    var symbolName: String               = "swift"
    var initialsText: String             = "DD"
    var emojiText: String                = "🎨"

    // Content style
    var contentColor: Color              = .white
    var contentScale: Double             = 0.55      // fraction of icon size
    var contentOffsetX: Double           = 0
    var contentOffsetY: Double           = 0

    // Background
    var backgroundStyle: IconBackgroundStyle = .gradient
    var backgroundColor: Color           = Color(hex: "#007AFF")
    var gradientEndColor: Color          = Color(hex: "#5E5CE6")
    var gradientDirection: IconGradientDirection = .topLeadingToBottomTrailing

    // Mesh accent dots (for .mesh style)
    var meshAccentColor: Color           = Color(hex: "#64D2FF")

    // Corner radius style
    var useIOSCornerRadius: Bool         = true      // iOS squircle vs circle vs none
    var customCornerFraction: Double     = 0.2237    // iOS standard

    // Shadow
    var showShadow: Bool                 = false
    var shadowOpacity: Double            = 0.3
}

// MARK: - iOS App Icon Sizes

struct AppIconSize: Identifiable, Equatable {
    let id: UUID
    let label: String           // e.g. "iPhone Notification"
    let usage: String           // e.g. "20pt @3x"
    let points: Int             // logical size in pt
    let scale: Int              // 1, 2, or 3
    let platform: IconPlatform

    var pixels: Int { points * scale }
    var filename: String { "Icon-\(pixels).png" }

    enum IconPlatform: String {
        case iPhone  = "iPhone"
        case iPad    = "iPad"
        case appStore = "App Store"
        case watch   = "Watch"
        case mac     = "Mac"
    }
}

enum AppIconSizeLibrary {
    static let all: [AppIconSize] = [
        // App Store
        AppIconSize(id: UUID(), label: "App Store",      usage: "1024pt @1x", points: 1024, scale: 1, platform: .appStore),
        // iPhone
        AppIconSize(id: UUID(), label: "iPhone App",     usage: "60pt @3x",   points: 60,   scale: 3, platform: .iPhone),
        AppIconSize(id: UUID(), label: "iPhone App",     usage: "60pt @2x",   points: 60,   scale: 2, platform: .iPhone),
        AppIconSize(id: UUID(), label: "iPhone Spotlight", usage: "40pt @3x", points: 40,   scale: 3, platform: .iPhone),
        AppIconSize(id: UUID(), label: "iPhone Spotlight", usage: "40pt @2x", points: 40,   scale: 2, platform: .iPhone),
        AppIconSize(id: UUID(), label: "iPhone Notification", usage: "20pt @3x", points: 20, scale: 3, platform: .iPhone),
        AppIconSize(id: UUID(), label: "iPhone Notification", usage: "20pt @2x", points: 20, scale: 2, platform: .iPhone),
        AppIconSize(id: UUID(), label: "iPhone Settings",  usage: "29pt @3x", points: 29,   scale: 3, platform: .iPhone),
        AppIconSize(id: UUID(), label: "iPhone Settings",  usage: "29pt @2x", points: 29,   scale: 2, platform: .iPhone),
        // iPad
        AppIconSize(id: UUID(), label: "iPad App",       usage: "83.5pt @2x", points: 83,   scale: 2, platform: .iPad),
        AppIconSize(id: UUID(), label: "iPad App",       usage: "76pt @2x",   points: 76,   scale: 2, platform: .iPad),
        AppIconSize(id: UUID(), label: "iPad Spotlight", usage: "40pt @2x",   points: 40,   scale: 2, platform: .iPad),
        AppIconSize(id: UUID(), label: "iPad Notification", usage: "20pt @1x", points: 20,  scale: 1, platform: .iPad),
        AppIconSize(id: UUID(), label: "iPad Settings",  usage: "29pt @1x",   points: 29,   scale: 1, platform: .iPad),
    ]

    // Sizes shown in the preview grid (representative subset)
    static let preview: [AppIconSize] = [
        all.first(where: { $0.pixels == 1024 })!,
        all.first(where: { $0.pixels == 180 })!,
        all.first(where: { $0.pixels == 120 })!,
        all.first(where: { $0.pixels == 87 })!,
        all.first(where: { $0.pixels == 60 })!,
        all.first(where: { $0.pixels == 40 })!,
    ]
}

// MARK: - Export Service

enum AppIconExportService {

    // Generate PNG data for a given config at a given pixel size
    @MainActor
    static func renderPNG(config: AppIconConfig, pixels: Int) -> Data? {
        let size = CGSize(width: pixels, height: pixels)
        let renderer = ImageRenderer(content:
            AppIconCanvasView(config: config, size: CGFloat(pixels), showCornerRadius: false)
                .frame(width: CGFloat(pixels), height: CGFloat(pixels))
        )
        renderer.scale = 1
        return renderer.uiImage?.pngData()
    }

    // Generate the Contents.json for an AppIcon.appiconset
    static func contentsJSON() -> String {
        let images = AppIconSizeLibrary.all.map { size -> [String: Any] in
            [
                "filename": size.filename,
                "idiom": idiom(size.platform),
                "scale": "\(size.scale)x",
                "size": "\(size.points)x\(size.points)"
            ]
        }
        let dict: [String: Any] = [
            "images": images,
            "info": ["author": "xcode", "version": 1]
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
              let str = String(data: data, encoding: .utf8) else { return "{}" }
        return str
    }

    // Swift code snippet showing how to reference the icon
    static func exportSwiftSnippet(config: AppIconConfig) -> String {
        let bgHex = colorHex(config.backgroundColor)
        let contentHex = colorHex(config.contentColor)
        switch config.contentType {
        case .symbol:
            return """
// App icon visual recipe
// Background: #\(bgHex)
// Symbol: "\(config.symbolName)"
// Replicate in your AppIcon asset:

ZStack {
    Color(hex: "#\(bgHex)")
    Image(systemName: "\(config.symbolName)")
        .resizable()
        .scaledToFit()
        .foregroundStyle(Color(hex: "#\(contentHex)"))
        .padding(32)
}
// Export all sizes using Xcode's App Icon set
// or use this tool's Export button.
"""
        case .initials:
            return """
// App icon visual recipe
// Background: #\(bgHex)
// Initials: "\(config.initialsText)"

ZStack {
    Color(hex: "#\(bgHex)")
    Text("\(config.initialsText)")
        .font(.system(size: 400, weight: .bold, design: .rounded))
        .foregroundStyle(Color(hex: "#\(contentHex)"))
        .minimumScaleFactor(0.01)
        .padding(64)
}
"""
        case .emoji:
            return """
// App icon visual recipe
// Background: #\(bgHex)
// Emoji: \(config.emojiText)

ZStack {
    Color(hex: "#\(bgHex)")
    Text("\(config.emojiText)")
        .font(.system(size: 400))
        .minimumScaleFactor(0.01)
        .padding(48)
}
"""
        }
    }

    static func colorHex(_ color: Color) -> String {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }

    private static func idiom(_ platform: AppIconSize.IconPlatform) -> String {
        switch platform {
        case .iPhone:   return "iphone"
        case .iPad:     return "ipad"
        case .appStore: return "ios-marketing"
        case .watch:    return "watch"
        case .mac:      return "mac"
        }
    }
}
