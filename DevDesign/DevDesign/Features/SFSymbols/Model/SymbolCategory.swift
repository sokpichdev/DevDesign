//
//  SymbolCategory.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
// Curated catalog of ~220 dev-essential SF Symbols organised by category.
// Search validates any name via UIImage(systemName:) so users can also
// look up symbols outside the curated list.

import UIKit
import SwiftUI
// MARK: - Symbol Category

enum SymbolCategory: String, CaseIterable, Identifiable {
    case all          = "All"
    case navigation   = "Navigation"
    case actions      = "Actions"
    case communication = "Communication"
    case media        = "Media"
    case devices      = "Devices"
    case files        = "Files"
    case shapes       = "Shapes"
    case arrows       = "Arrows"
    case ui           = "UI Controls"
    case system       = "System"
    case people       = "People"
    case nature       = "Nature"
    case commerce     = "Commerce"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all:           return "square.grid.2x2"
        case .navigation:    return "location"
        case .actions:       return "bolt"
        case .communication: return "message"
        case .media:         return "play.circle"
        case .devices:       return "iphone"
        case .files:         return "folder"
        case .shapes:        return "circle"
        case .arrows:        return "arrow.right"
        case .ui:            return "slider.horizontal.3"
        case .system:        return "gear"
        case .people:        return "person"
        case .nature:        return "leaf"
        case .commerce:      return "cart"
        }
    }
}

// MARK: - SF Symbol

struct SFSymbol: Identifiable, Hashable {
    let id: UUID
    let name: String           // systemName used in UIImage / Image
    let category: SymbolCategory
    let keywords: [String]     // extra search terms beyond the name

    /// Validate the symbol exists on this OS version
    var isAvailable: Bool { UIImage(systemName: name) != nil }
}

// MARK: - Curated Catalog

enum SFSymbolCatalog {

    static let symbols: [SFSymbol] = navigation + actions + communication +
        media + devices + files + shapes + arrows + ui + system + people +
        nature + commerce

    // MARK: Navigation
    static let navigation: [SFSymbol] = [
        sym("house",                      .navigation, ["home", "main"]),
        sym("house.fill",                 .navigation, ["home", "main"]),
        sym("magnifyingglass",            .navigation, ["search", "find", "lookup"]),
        sym("magnifyingglass.circle",     .navigation, ["search"]),
        sym("map",                        .navigation, ["location", "geo"]),
        sym("map.fill",                   .navigation, ["location", "geo"]),
        sym("location",                   .navigation, ["gps", "pin"]),
        sym("location.fill",              .navigation, ["gps", "pin"]),
        sym("location.circle",            .navigation, ["gps"]),
        sym("location.circle.fill",       .navigation, ["gps"]),
        sym("mappin",                     .navigation, ["pin", "marker"]),
        sym("mappin.circle",              .navigation, ["pin"]),
        sym("mappin.circle.fill",         .navigation, ["pin"]),
        sym("mappin.and.ellipse",         .navigation, ["pin", "location"]),
        sym("compass.drawing",            .navigation, ["direction"]),
        sym("globe",                      .navigation, ["world", "earth", "web"]),
        sym("globe.americas",             .navigation, ["world"]),
        sym("safari",                     .navigation, ["browser", "web"]),
        sym("safari.fill",                .navigation, ["browser"]),
    ]

    // MARK: Actions
    static let actions: [SFSymbol] = [
        sym("square.and.arrow.up",        .actions, ["share", "export", "send"]),
        sym("square.and.arrow.up.fill",   .actions, ["share"]),
        sym("square.and.arrow.down",      .actions, ["download", "import", "save"]),
        sym("plus",                       .actions, ["add", "new", "create"]),
        sym("plus.circle",                .actions, ["add"]),
        sym("plus.circle.fill",           .actions, ["add"]),
        sym("minus",                      .actions, ["remove", "delete", "subtract"]),
        sym("minus.circle",               .actions, ["remove"]),
        sym("xmark",                      .actions, ["close", "cancel", "dismiss"]),
        sym("xmark.circle",               .actions, ["close"]),
        sym("xmark.circle.fill",          .actions, ["close"]),
        sym("checkmark",                  .actions, ["done", "ok", "confirm"]),
        sym("checkmark.circle",           .actions, ["done", "success"]),
        sym("checkmark.circle.fill",      .actions, ["done", "success"]),
        sym("pencil",                     .actions, ["edit", "write"]),
        sym("pencil.circle",              .actions, ["edit"]),
        sym("pencil.circle.fill",         .actions, ["edit"]),
        sym("square.and.pencil",          .actions, ["edit", "compose"]),
        sym("trash",                      .actions, ["delete", "remove", "bin"]),
        sym("trash.fill",                 .actions, ["delete", "bin"]),
        sym("trash.circle",               .actions, ["delete"]),
        sym("trash.circle.fill",          .actions, ["delete"]),
        sym("bookmark",                   .actions, ["save", "favourite"]),
        sym("bookmark.fill",              .actions, ["save", "favourite"]),
        sym("heart",                      .actions, ["like", "love", "favourite"]),
        sym("heart.fill",                 .actions, ["like", "love"]),
        sym("star",                       .actions, ["favourite", "rating"]),
        sym("star.fill",                  .actions, ["favourite", "rating"]),
        sym("flag",                       .actions, ["report", "mark"]),
        sym("flag.fill",                  .actions, ["report", "mark"]),
        sym("bell",                       .actions, ["notification", "alert"]),
        sym("bell.fill",                  .actions, ["notification"]),
        sym("bell.slash",                 .actions, ["mute", "no notification"]),
        sym("lock",                       .actions, ["secure", "private"]),
        sym("lock.fill",                  .actions, ["secure"]),
        sym("lock.open",                  .actions, ["unlock"]),
        sym("lock.open.fill",             .actions, ["unlock"]),
        sym("eye",                        .actions, ["view", "visible", "show"]),
        sym("eye.fill",                   .actions, ["view"]),
        sym("eye.slash",                  .actions, ["hide", "invisible"]),
        sym("eye.slash.fill",             .actions, ["hide"]),
        sym("hand.thumbsup",              .actions, ["like", "approve"]),
        sym("hand.thumbsup.fill",         .actions, ["like"]),
        sym("hand.thumbsdown",            .actions, ["dislike"]),
        sym("square.on.square",           .actions, ["copy", "duplicate"]),
        sym("doc.on.doc",                 .actions, ["copy"]),
        sym("doc.on.doc.fill",            .actions, ["copy"]),
        sym("arrow.counterclockwise",     .actions, ["undo", "reset", "refresh"]),
        sym("arrow.clockwise",            .actions, ["redo", "reload", "refresh"]),
        sym("ellipsis",                   .actions, ["more", "options"]),
        sym("ellipsis.circle",            .actions, ["more", "options"]),
        sym("ellipsis.circle.fill",       .actions, ["more"]),
    ]

    // MARK: Communication
    static let communication: [SFSymbol] = [
        sym("message",                    .communication, ["chat", "sms", "text"]),
        sym("message.fill",               .communication, ["chat"]),
        sym("bubble.left",                .communication, ["comment", "reply"]),
        sym("bubble.left.fill",           .communication, ["comment"]),
        sym("bubble.right",               .communication, ["comment"]),
        sym("bubble.right.fill",          .communication, ["comment"]),
        sym("envelope",                   .communication, ["email", "mail"]),
        sym("envelope.fill",              .communication, ["email"]),
        sym("envelope.open",              .communication, ["email", "read"]),
        sym("envelope.open.fill",         .communication, ["email"]),
        sym("phone",                      .communication, ["call", "ring"]),
        sym("phone.fill",                 .communication, ["call"]),
        sym("phone.circle",               .communication, ["call"]),
        sym("phone.circle.fill",          .communication, ["call"]),
        sym("video",                      .communication, ["video call", "facetime"]),
        sym("video.fill",                 .communication, ["video call"]),
        sym("mic",                        .communication, ["audio", "record", "voice"]),
        sym("mic.fill",                   .communication, ["audio", "record"]),
        sym("mic.slash",                  .communication, ["mute"]),
        sym("speaker.wave.2",             .communication, ["audio", "sound", "volume"]),
        sym("speaker.wave.2.fill",        .communication, ["audio", "sound"]),
        sym("speaker.slash",              .communication, ["mute", "silent"]),
        sym("paperplane",                 .communication, ["send", "submit"]),
        sym("paperplane.fill",            .communication, ["send"]),
        sym("at",                         .communication, ["email", "mention"]),
        sym("link",                       .communication, ["url", "hyperlink"]),
    ]

    // MARK: Media
    static let media: [SFSymbol] = [
        sym("play",                       .media, ["start", "begin"]),
        sym("play.fill",                  .media, ["start"]),
        sym("play.circle",                .media, ["start"]),
        sym("play.circle.fill",           .media, ["start"]),
        sym("pause",                      .media, ["stop temporarily"]),
        sym("pause.fill",                 .media, ["stop"]),
        sym("pause.circle",               .media, ["stop"]),
        sym("stop",                       .media, ["end", "cancel"]),
        sym("stop.fill",                  .media, ["end"]),
        sym("backward",                   .media, ["rewind", "previous"]),
        sym("forward",                    .media, ["skip", "next"]),
        sym("backward.end",               .media, ["first", "beginning"]),
        sym("forward.end",                .media, ["last", "end"]),
        sym("shuffle",                    .media, ["random"]),
        sym("repeat",                     .media, ["loop"]),
        sym("camera",                     .media, ["photo", "picture"]),
        sym("camera.fill",                .media, ["photo"]),
        sym("photo",                      .media, ["image", "picture", "gallery"]),
        sym("photo.fill",                 .media, ["image"]),
        sym("photo.on.rectangle",         .media, ["album", "gallery"]),
        sym("film",                       .media, ["video", "movie"]),
        sym("film.fill",                  .media, ["video"]),
        sym("music.note",                 .media, ["audio", "song"]),
        sym("music.note.list",            .media, ["playlist"]),
        sym("waveform",                   .media, ["audio", "sound", "voice"]),
        sym("waveform.circle",            .media, ["audio"]),
        sym("waveform.circle.fill",       .media, ["audio"]),
    ]

    // MARK: Devices
    static let devices: [SFSymbol] = [
        sym("iphone",                     .devices, ["mobile", "phone"]),
        sym("ipad",                       .devices, ["tablet"]),
        sym("macbook",                    .devices, ["laptop", "computer"]),
        sym("applewatch",                 .devices, ["watch", "wearable"]),
        sym("airpods",                    .devices, ["headphones", "audio"]),
        sym("tv",                         .devices, ["screen", "display"]),
        sym("tv.fill",                    .devices, ["screen"]),
        sym("desktopcomputer",            .devices, ["mac", "imac"]),
        sym("keyboard",                   .devices, ["input", "type"]),
        sym("keyboard.fill",              .devices, ["input"]),
        sym("cpu",                        .devices, ["processor", "chip"]),
        sym("memorychip",                 .devices, ["ram", "hardware"]),
        sym("wifi",                       .devices, ["network", "internet"]),
        sym("wifi.slash",                 .devices, ["no wifi", "offline"]),
        sym("antenna.radiowaves.left.and.right", .devices, ["signal", "radio"]),
        sym("battery.100",                .devices, ["power", "charge"]),
        sym("battery.50",                 .devices, ["power"]),
        sym("bolt",                       .devices, ["power", "charge", "fast"]),
        sym("bolt.fill",                  .devices, ["power", "charge"]),
        sym("bolt.circle",                .devices, ["charge"]),
        sym("bolt.circle.fill",           .devices, ["charge"]),
    ]

    // MARK: Files
    static let files: [SFSymbol] = [
        sym("folder",                     .files, ["directory", "collection"]),
        sym("folder.fill",                .files, ["directory"]),
        sym("folder.badge.plus",          .files, ["new folder"]),
        sym("doc",                        .files, ["file", "document"]),
        sym("doc.fill",                   .files, ["file"]),
        sym("doc.text",                   .files, ["text file", "document"]),
        sym("doc.text.fill",              .files, ["text"]),
        sym("doc.richtext",               .files, ["rich text"]),
        sym("doc.badge.plus",             .files, ["new file"]),
        sym("doc.badge.arrow.up",         .files, ["upload"]),
        sym("doc.zipper",                 .files, ["archive", "zip", "compress"]),
        sym("tray",                       .files, ["inbox", "storage"]),
        sym("tray.fill",                  .files, ["inbox"]),
        sym("tray.and.arrow.down",        .files, ["download", "import"]),
        sym("tray.and.arrow.up",          .files, ["upload", "export"]),
        sym("externaldrive",              .files, ["storage", "disk"]),
        sym("externaldrive.fill",         .files, ["storage"]),
        sym("icloud",                     .files, ["cloud", "sync"]),
        sym("icloud.fill",                .files, ["cloud"]),
        sym("icloud.and.arrow.up",        .files, ["upload", "sync"]),
        sym("icloud.and.arrow.down",      .files, ["download", "sync"]),
    ]

    // MARK: Shapes
    static let shapes: [SFSymbol] = [
        sym("circle",                     .shapes, ["round", "dot"]),
        sym("circle.fill",                .shapes, ["round", "dot"]),
        sym("circle.dashed",              .shapes, ["outline"]),
        sym("square",                     .shapes, ["box", "rect"]),
        sym("square.fill",                .shapes, ["box"]),
        sym("rectangle",                  .shapes, ["box", "wide"]),
        sym("rectangle.fill",             .shapes, ["box"]),
        sym("triangle",                   .shapes, ["delta", "warning"]),
        sym("triangle.fill",              .shapes, ["warning"]),
        sym("diamond",                    .shapes, ["rhombus"]),
        sym("diamond.fill",               .shapes, ["rhombus"]),
        sym("hexagon",                    .shapes, ["hex"]),
        sym("hexagon.fill",               .shapes, ["hex"]),
        sym("seal",                       .shapes, ["badge"]),
        sym("seal.fill",                  .shapes, ["badge"]),
        sym("shield",                     .shapes, ["security", "protect"]),
        sym("shield.fill",                .shapes, ["security"]),
        sym("capsule",                    .shapes, ["pill", "button"]),
        sym("capsule.fill",               .shapes, ["pill"]),
        sym("oval",                       .shapes, ["ellipse"]),
        sym("oval.fill",                  .shapes, ["ellipse"]),
    ]

    // MARK: Arrows
    static let arrows: [SFSymbol] = [
        sym("arrow.right",                .arrows, ["next", "forward"]),
        sym("arrow.left",                 .arrows, ["back", "previous"]),
        sym("arrow.up",                   .arrows, ["top", "above"]),
        sym("arrow.down",                 .arrows, ["bottom", "below"]),
        sym("arrow.right.circle",         .arrows, ["next"]),
        sym("arrow.right.circle.fill",    .arrows, ["next"]),
        sym("arrow.left.circle",          .arrows, ["back"]),
        sym("arrow.left.circle.fill",     .arrows, ["back"]),
        sym("arrow.up.circle",            .arrows, ["up"]),
        sym("arrow.up.circle.fill",       .arrows, ["up"]),
        sym("arrow.down.circle",          .arrows, ["down"]),
        sym("arrow.down.circle.fill",     .arrows, ["down"]),
        sym("arrow.turn.up.right",        .arrows, ["redirect", "branch"]),
        sym("arrow.turn.down.right",      .arrows, ["redirect"]),
        sym("arrow.uturn.left",           .arrows, ["undo", "back"]),
        sym("arrow.uturn.right",          .arrows, ["redo"]),
        sym("arrow.left.and.right",       .arrows, ["horizontal", "width", "expand"]),
        sym("arrow.up.and.down",          .arrows, ["vertical", "height"]),
        sym("arrow.up.left.and.arrow.down.right", .arrows, ["expand", "fullscreen"]),
        sym("arrow.down.left.and.arrow.up.right", .arrows, ["collapse"]),
        sym("chevron.right",              .arrows, ["next", "more", "disclosure"]),
        sym("chevron.left",               .arrows, ["back"]),
        sym("chevron.up",                 .arrows, ["collapse", "up"]),
        sym("chevron.down",               .arrows, ["expand", "down"]),
        sym("chevron.right.circle",       .arrows, ["next"]),
        sym("chevron.right.circle.fill",  .arrows, ["next"]),
    ]

    // MARK: UI Controls
    static let ui: [SFSymbol] = [
        sym("slider.horizontal.3",        .ui, ["settings", "adjust", "filter"]),
        sym("slider.vertical.3",          .ui, ["adjust"]),
        sym("switch.2",                   .ui, ["toggle", "switch"]),
        sym("line.3.horizontal",          .ui, ["menu", "hamburger", "list"]),
        sym("line.3.horizontal.decrease", .ui, ["filter", "sort"]),
        sym("line.3.horizontal.decrease.circle", .ui, ["filter"]),
        sym("square.grid.2x2",            .ui, ["grid", "layout"]),
        sym("square.grid.3x3",            .ui, ["grid"]),
        sym("list.bullet",                .ui, ["list", "items"]),
        sym("list.bullet.rectangle",      .ui, ["list"]),
        sym("list.dash",                  .ui, ["list"]),
        sym("list.number",                .ui, ["ordered list"]),
        sym("sidebar.left",               .ui, ["drawer", "panel"]),
        sym("sidebar.right",              .ui, ["panel"]),
        sym("rectangle.split.2x1",        .ui, ["split view", "columns"]),
        sym("rectangle.split.3x1",        .ui, ["three columns"]),
        sym("rectangle.split.2x2",        .ui, ["grid layout"]),
        sym("table",                      .ui, ["grid", "spreadsheet"]),
        sym("table.fill",                 .ui, ["grid"]),
        sym("textformat",                 .ui, ["text", "font", "typography"]),
        sym("textformat.size",            .ui, ["font size", "type scale"]),
        sym("textformat.abc",             .ui, ["text"]),
        sym("bold",                       .ui, ["text weight"]),
        sym("italic",                     .ui, ["text style"]),
        sym("underline",                  .ui, ["text decoration"]),
        sym("strikethrough",              .ui, ["text decoration"]),
        sym("tag",                        .ui, ["label", "badge"]),
        sym("tag.fill",                   .ui, ["label"]),
        sym("info.circle",                .ui, ["information", "help"]),
        sym("info.circle.fill",           .ui, ["information"]),
        sym("questionmark.circle",        .ui, ["help", "unknown"]),
        sym("questionmark.circle.fill",   .ui, ["help"]),
        sym("exclamationmark.circle",     .ui, ["warning", "error", "alert"]),
        sym("exclamationmark.circle.fill",.ui, ["warning", "error"]),
        sym("exclamationmark.triangle",   .ui, ["warning"]),
        sym("exclamationmark.triangle.fill", .ui, ["warning"]),
    ]

    // MARK: System
    static let system: [SFSymbol] = [
        sym("gear",                       .system, ["settings", "preferences"]),
        sym("gear.circle",                .system, ["settings"]),
        sym("gear.circle.fill",           .system, ["settings"]),
        sym("gearshape",                  .system, ["settings"]),
        sym("gearshape.fill",             .system, ["settings"]),
        sym("gearshape.2",                .system, ["settings", "config"]),
        sym("gearshape.2.fill",           .system, ["settings"]),
        sym("wrench",                     .system, ["tool", "fix", "debug"]),
        sym("wrench.fill",                .system, ["tool"]),
        sym("wrench.and.screwdriver",     .system, ["tools", "maintenance"]),
        sym("wrench.and.screwdriver.fill",.system, ["tools"]),
        sym("hammer",                     .system, ["build", "construct"]),
        sym("hammer.fill",                .system, ["build"]),
        sym("terminal",                   .system, ["command line", "code", "cli"]),
        sym("terminal.fill",              .system, ["command line"]),
        sym("chevron.left.forwardslash.chevron.right", .system, ["code", "developer", "html"]),
        sym("curlybraces",                .system, ["code", "json", "swift"]),
        sym("curlybraces.square",         .system, ["code"]),
        sym("curlybraces.square.fill",    .system, ["code"]),
        sym("function",                   .system, ["math", "formula", "code"]),
        sym("swift",                      .system, ["swift", "ios", "apple"]),
        sym("arrow.triangle.2.circlepath",.system, ["sync", "refresh", "reload"]),
        sym("clock",                      .system, ["time", "schedule"]),
        sym("clock.fill",                 .system, ["time"]),
        sym("calendar",                   .system, ["date", "schedule"]),
        sym("calendar.circle",            .system, ["date"]),
        sym("calendar.circle.fill",       .system, ["date"]),
    ]

    // MARK: People
    static let people: [SFSymbol] = [
        sym("person",                     .people, ["user", "account", "profile"]),
        sym("person.fill",                .people, ["user"]),
        sym("person.circle",              .people, ["avatar", "profile"]),
        sym("person.circle.fill",         .people, ["avatar"]),
        sym("person.badge.plus",          .people, ["add user"]),
        sym("person.badge.minus",         .people, ["remove user"]),
        sym("person.2",                   .people, ["group", "team", "friends"]),
        sym("person.2.fill",              .people, ["group"]),
        sym("person.3",                   .people, ["group", "team"]),
        sym("person.3.fill",              .people, ["team"]),
        sym("person.crop.circle",         .people, ["avatar"]),
        sym("person.crop.circle.fill",    .people, ["avatar"]),
        sym("person.crop.square",         .people, ["profile photo"]),
        sym("person.crop.square.fill",    .people, ["profile"]),
        sym("figure.walk",                .people, ["pedestrian", "walk"]),
        sym("figure.run",                 .people, ["run", "exercise"]),
        sym("hands.clap",                 .people, ["applause", "celebrate"]),
        sym("hands.clap.fill",            .people, ["applause"]),
    ]

    // MARK: Nature
    static let nature: [SFSymbol] = [
        sym("leaf",                       .nature, ["eco", "green", "plant"]),
        sym("leaf.fill",                  .nature, ["eco"]),
        sym("leaf.circle",                .nature, ["eco"]),
        sym("leaf.circle.fill",           .nature, ["eco"]),
        sym("sun.max",                    .nature, ["light", "bright", "day"]),
        sym("sun.max.fill",               .nature, ["light", "day"]),
        sym("moon",                       .nature, ["night", "dark", "sleep"]),
        sym("moon.fill",                  .nature, ["night"]),
        sym("moon.stars",                 .nature, ["night"]),
        sym("cloud",                      .nature, ["weather", "overcast"]),
        sym("cloud.fill",                 .nature, ["weather"]),
        sym("cloud.rain",                 .nature, ["weather", "rain"]),
        sym("cloud.rain.fill",            .nature, ["rain"]),
        sym("wind",                       .nature, ["weather", "air"]),
        sym("snowflake",                  .nature, ["winter", "cold", "freeze"]),
        sym("flame",                      .nature, ["fire", "hot", "trending"]),
        sym("flame.fill",                 .nature, ["fire", "hot"]),
        sym("drop",                       .nature, ["water", "liquid"]),
        sym("drop.fill",                  .nature, ["water"]),
        sym("bolt",                       .nature, ["lightning", "storm", "energy"]),
        sym("sparkles",                   .nature, ["magic", "ai", "new", "shiny"]),
        sym("sparkle",                    .nature, ["magic", "ai"]),
    ]

    // MARK: Commerce
    static let commerce: [SFSymbol] = [
        sym("cart",                       .commerce, ["shop", "buy", "basket"]),
        sym("cart.fill",                  .commerce, ["shop"]),
        sym("cart.badge.plus",            .commerce, ["add to cart"]),
        sym("bag",                        .commerce, ["shopping", "purchase"]),
        sym("bag.fill",                   .commerce, ["shopping"]),
        sym("bag.badge.plus",             .commerce, ["add"]),
        sym("creditcard",                 .commerce, ["payment", "card", "billing"]),
        sym("creditcard.fill",            .commerce, ["payment"]),
        sym("dollarsign.circle",          .commerce, ["money", "price", "cost"]),
        sym("dollarsign.circle.fill",     .commerce, ["money"]),
        sym("gift",                       .commerce, ["present", "reward"]),
        sym("gift.fill",                  .commerce, ["present"]),
        sym("ticket",                     .commerce, ["coupon", "pass"]),
        sym("ticket.fill",                .commerce, ["coupon"]),
        sym("chart.bar",                  .commerce, ["analytics", "stats", "data"]),
        sym("chart.bar.fill",             .commerce, ["analytics"]),
        sym("chart.line.uptrend.xyaxis",  .commerce, ["analytics", "growth"]),
        sym("chart.pie",                  .commerce, ["analytics", "breakdown"]),
        sym("chart.pie.fill",             .commerce, ["analytics"]),
    ]

    // MARK: - Factory
    private static func sym(_ name: String, _ cat: SymbolCategory, _ keywords: [String]) -> SFSymbol {
        SFSymbol(id: UUID(), name: name, category: cat, keywords: keywords)
    }
}

// MARK: - Export Service

enum SFSymbolExportService {

    static func exportSwiftUI(_ symbol: SFSymbol, size: CGFloat, weight: SymbolWeight) -> String {
        """
        Image(systemName: "\(symbol.name)")
            .font(.system(size: \(Int(size)), weight: \(weight.swiftUIValue)))
            .foregroundStyle(.primary)
        """
    }

    static func exportSwiftUIResizable(_ symbol: SFSymbol, weight: SymbolWeight) -> String {
        """
        Image(systemName: "\(symbol.name)")
            .symbolRenderingMode(.hierarchical)
            .fontWeight(\(weight.swiftUIValue))
            .imageScale(.large)
        """
    }

    static func exportUIKit(_ symbol: SFSymbol, size: CGFloat, weight: SymbolWeight) -> String {
        """
        let config = UIImage.SymbolConfiguration(
            pointSize: \(Int(size)),
            weight: \(weight.uiKitValue)
        )
        let image = UIImage(systemName: "\(symbol.name)", withConfiguration: config)
        """
    }

    static func exportSwiftUIButton(_ symbol: SFSymbol) -> String {
        """
        Button {
            // action
        } label: {
            Image(systemName: "\(symbol.name)")
        }
        .buttonStyle(.bordered)
        """
    }
}

// MARK: - Symbol Weight

enum SymbolWeight: String, CaseIterable, Identifiable {
    case ultraLight = "Ultra Light"
    case thin       = "Thin"
    case light      = "Light"
    case regular    = "Regular"
    case medium     = "Medium"
    case semibold   = "Semibold"
    case bold       = "Bold"
    case heavy      = "Heavy"
    case black      = "Black"

    var id: String { rawValue }

    var swiftUIValue: String {
        switch self {
        case .ultraLight: return ".ultraLight"
        case .thin:       return ".thin"
        case .light:      return ".light"
        case .regular:    return ".regular"
        case .medium:     return ".medium"
        case .semibold:   return ".semibold"
        case .bold:       return ".bold"
        case .heavy:      return ".heavy"
        case .black:      return ".black"
        }
    }

    var uiKitValue: String {
        switch self {
        case .ultraLight: return ".ultraLight"
        case .thin:       return ".thin"
        case .light:      return ".light"
        case .regular:    return ".regular"
        case .medium:     return ".medium"
        case .semibold:   return ".semibold"
        case .bold:       return ".bold"
        case .heavy:      return ".heavy"
        case .black:      return ".black"
        }
    }

    var fontWeight: Font.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin:       return .thin
        case .light:      return .light
        case .regular:    return .regular
        case .medium:     return .medium
        case .semibold:   return .semibold
        case .bold:       return .bold
        case .heavy:      return .heavy
        case .black:      return .black
        }
    }
}
