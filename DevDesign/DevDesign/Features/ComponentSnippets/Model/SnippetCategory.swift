//
//  SnippetCategory.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//
// Two kinds of snippet:
//   • CuratedSnippet  — static, built-in (~80 components)
//   • CustomSnippet   — SwiftData @Model, user-created

import SwiftUI
import SwiftData

// MARK: - Snippet Category

enum SnippetCategory: String, CaseIterable, Identifiable {
    case all         = "All"
    case buttons     = "Buttons"
    case cards       = "Cards"
    case inputs      = "Inputs"
    case navigation  = "Navigation"
    case lists       = "Lists"
    case badges      = "Badges"
    case alerts      = "Alerts"
    case loading     = "Loading"
    case avatars     = "Avatars"
    case layout      = "Layout"
    case custom      = "My Snippets"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all:        return "square.grid.2x2"
        case .buttons:    return "capsule"
        case .cards:      return "rectangle.roundedtop"
        case .inputs:     return "keyboard"
        case .navigation: return "arrow.left.arrow.right"
        case .lists:      return "list.bullet"
        case .badges:     return "tag"
        case .alerts:     return "exclamationmark.circle"
        case .loading:    return "arrow.triangle.2.circlepath"
        case .avatars:    return "person.circle"
        case .layout:     return "rectangle.split.3x1"
        case .custom:     return "star"
        }
    }
}

// MARK: - Curated Snippet

struct CuratedSnippet: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: SnippetCategory
    let tags: [String]
    let code: String            // template — {{ACCENT}} replaced at copy time
    let previewSymbol: String   // SF Symbol for card thumbnail

    static func == (lhs: CuratedSnippet, rhs: CuratedSnippet) -> Bool { lhs.id == rhs.id }
}

// MARK: - Custom Snippet (SwiftData)

@Model
final class CustomSnippet {
    var title: String
    var subtitle: String
    var code: String
    var tags: String            // comma-separated
    var createdAt: Date

    init(title: String, subtitle: String, code: String, tags: String) {
        self.title     = title
        self.subtitle  = subtitle
        self.code      = code
        self.tags      = tags
        self.createdAt = Date()
    }

    var tagList: [String] {
        tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}

// MARK: - Curated Library (~80 components)

enum SnippetLibrary {

    static let all: [CuratedSnippet] = buttons + cards + inputs + navigation + lists + badges + alerts + loading + avatars + layout

    // MARK: Buttons
    static let buttons: [CuratedSnippet] = [
        snippet("Filled Button", "Primary CTA", .buttons, ["button", "cta", "primary"], "capsule", """
Button {
    // action
} label: {
    Text("Get Started")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(hex: "{{ACCENT}}"), in: RoundedRectangle(cornerRadius: 12))
}
.buttonStyle(.plain)
"""),
        snippet("Bordered Button", "Secondary action", .buttons, ["button", "bordered", "secondary"], "capsule", """
Button {
    // action
} label: {
    Text("Learn More")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(Color(hex: "{{ACCENT}}"))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(hex: "{{ACCENT}}"), lineWidth: 1.5)
        )
}
.buttonStyle(.plain)
"""),
        snippet("Icon + Label Button", "Button with leading icon", .buttons, ["button", "icon", "label"], "capsule", """
Button {
    // action
} label: {
    HStack(spacing: 8) {
        Image(systemName: "arrow.down.circle.fill")
            .font(.system(size: 16))
        Text("Download")
            .font(.system(size: 16, weight: .semibold))
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(Color(hex: "{{ACCENT}}"), in: Capsule())
}
.buttonStyle(.plain)
"""),
        snippet("Destructive Button", "Delete / danger action", .buttons, ["button", "delete", "destructive", "danger"], "trash.circle", """
Button(role: .destructive) {
    // delete action
} label: {
    HStack(spacing: 6) {
        Image(systemName: "trash")
        Text("Delete")
            .fontWeight(.semibold)
    }
    .foregroundStyle(.red)
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
}
.buttonStyle(.plain)
"""),
        snippet("Icon Button Round", "Circular icon action", .buttons, ["button", "icon", "round", "fab"], "circle", """
Button {
    // action
} label: {
    Image(systemName: "plus")
        .font(.system(size: 20, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 52, height: 52)
        .background(Color(hex: "{{ACCENT}}"), in: Circle())
        .shadow(color: Color(hex: "{{ACCENT}}").opacity(0.4),
                radius: 8, x: 0, y: 4)
}
.buttonStyle(.plain)
"""),
        snippet("Toggle Button", "On/off binary button", .buttons, ["button", "toggle", "state"], "switch.2", """
@State private var isOn = false

Button {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        isOn.toggle()
    }
} label: {
    Text(isOn ? "Enabled" : "Disabled")
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(isOn ? .white : Color(hex: "{{ACCENT}}"))
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            isOn
                ? Color(hex: "{{ACCENT}}")
                : Color(hex: "{{ACCENT}}").opacity(0.1),
            in: Capsule()
        )
}
.buttonStyle(.plain)
"""),
        snippet("Loading Button", "Async action with spinner", .buttons, ["button", "loading", "async", "spinner"], "arrow.triangle.2.circlepath", """
@State private var isLoading = false

Button {
    isLoading = true
    // async work here
} label: {
    HStack(spacing: 8) {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(0.8)
        }
        Text(isLoading ? "Loading…" : "Submit")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 14)
    .background(
        Color(hex: "{{ACCENT}}").opacity(isLoading ? 0.7 : 1),
        in: RoundedRectangle(cornerRadius: 12)
    )
}
.buttonStyle(.plain)
.disabled(isLoading)
"""),
        snippet("Segmented Control", "Multi-option picker", .buttons, ["button", "segmented", "picker", "tab"], "rectangle.split.3x1", """
@State private var selected = 0
let options = ["Day", "Week", "Month"]

HStack(spacing: 4) {
    ForEach(options.indices, id: \\.self) { i in
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selected = i
            }
        } label: {
            Text(options[i])
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(selected == i ? .white : Color(hex: "{{ACCENT}}"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    selected == i
                        ? Color(hex: "{{ACCENT}}")
                        : Color.clear,
                    in: RoundedRectangle(cornerRadius: 8)
                )
        }
        .buttonStyle(.plain)
    }
}
.padding(4)
.background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
"""),
        snippet("Copy Button", "Clipboard copy with feedback", .buttons, ["button", "copy", "clipboard", "feedback"], "doc.on.doc", """
@State private var copied = false

Button {
    UIPasteboard.general.string = "text to copy"
    withAnimation { copied = true }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        withAnimation { copied = false }
    }
} label: {
    Label(copied ? "Copied!" : "Copy",
          systemImage: copied ? "checkmark" : "doc.on.doc")
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(copied ? .green : Color(hex: "{{ACCENT}}"))
        .contentTransition(.symbolEffect(.replace))
}
.buttonStyle(.plain)
"""),
        snippet("Floating Action Button", "FAB with shadow", .buttons, ["fab", "float", "action", "plus"], "plus.circle.fill", """
// Place in a ZStack, aligned .bottomTrailing
Button {
    // action
} label: {
    Image(systemName: "plus")
        .font(.system(size: 24, weight: .bold))
        .foregroundStyle(.white)
        .frame(width: 60, height: 60)
        .background(Color(hex: "{{ACCENT}}"), in: Circle())
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
}
.buttonStyle(.plain)
.padding(24)
"""),
    ]

    // MARK: Cards
    static let cards: [CuratedSnippet] = [
        snippet("Basic Card", "Simple surface card", .cards, ["card", "container", "surface"], "rectangle.roundedtop", """
VStack(alignment: .leading, spacing: 12) {
    Text("Card Title")
        .font(.system(size: 17, weight: .semibold))
    Text("Supporting text that describes the card content in more detail.")
        .font(.system(size: 15))
        .foregroundStyle(.secondary)
    Button("Action") { }
        .foregroundStyle(Color(hex: "{{ACCENT}}"))
}
.padding(16)
.background(.background, in: RoundedRectangle(cornerRadius: 16))
.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
"""),
        snippet("Image Header Card", "Card with top image area", .cards, ["card", "image", "header", "media"], "photo.on.rectangle", """
VStack(alignment: .leading, spacing: 0) {
    // Image area
    RoundedRectangle(cornerRadius: 0)
        .fill(Color(hex: "{{ACCENT}}").gradient)
        .frame(height: 140)
        .overlay(
            Image(systemName: "photo")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.5))
        )

    VStack(alignment: .leading, spacing: 8) {
        Text("Card Title")
            .font(.system(size: 17, weight: .semibold))
        Text("Description text goes here with more detail.")
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
    }
    .padding(16)
}
.background(.background)
.clipShape(RoundedRectangle(cornerRadius: 16))
.shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 6)
"""),
        snippet("Stat Card", "Metric / KPI display", .cards, ["card", "stat", "metric", "kpi", "number"], "chart.bar", """
VStack(alignment: .leading, spacing: 8) {
    HStack {
        Image(systemName: "arrow.up.circle.fill")
            .foregroundStyle(Color(hex: "{{ACCENT}}"))
        Text("Revenue")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.secondary)
        Spacer()
        Text("↑ 12%")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.green)
    }
    Text("$24,500")
        .font(.system(size: 32, weight: .bold, design: .rounded))
    Text("vs $21,800 last month")
        .font(.system(size: 12))
        .foregroundStyle(.tertiary)
}
.padding(16)
.background(.background, in: RoundedRectangle(cornerRadius: 16))
.shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
"""),
        snippet("Profile Card", "User profile summary", .cards, ["card", "profile", "user", "avatar"], "person.circle", """
HStack(spacing: 14) {
    Circle()
        .fill(Color(hex: "{{ACCENT}}").opacity(0.2))
        .frame(width: 52, height: 52)
        .overlay(
            Text("AB")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: "{{ACCENT}}"))
        )

    VStack(alignment: .leading, spacing: 3) {
        Text("Alex Brown")
            .font(.system(size: 16, weight: .semibold))
        Text("iOS Developer")
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
    }
    Spacer()
    Button {
    } label: {
        Image(systemName: "ellipsis")
            .foregroundStyle(.secondary)
    }
}
.padding(16)
.background(.background, in: RoundedRectangle(cornerRadius: 16))
.shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
"""),
        snippet("Horizontal Card", "Side-by-side image + text", .cards, ["card", "horizontal", "list item", "row"], "rectangle.split.2x1", """
HStack(spacing: 12) {
    RoundedRectangle(cornerRadius: 10)
        .fill(Color(hex: "{{ACCENT}}").opacity(0.15))
        .frame(width: 72, height: 72)
        .overlay(
            Image(systemName: "photo")
                .foregroundStyle(Color(hex: "{{ACCENT}}"))
        )

    VStack(alignment: .leading, spacing: 4) {
        Text("Item Title")
            .font(.system(size: 16, weight: .semibold))
        Text("Subtitle or description text")
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
        Text("$9.99")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Color(hex: "{{ACCENT}}"))
    }
    Spacer()
    Image(systemName: "chevron.right")
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(.tertiary)
}
.padding(14)
.background(.background, in: RoundedRectangle(cornerRadius: 14))
.shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
"""),
        snippet("Gradient Card", "Card with gradient bg", .cards, ["card", "gradient", "colorful"], "rectangle.fill", """
ZStack(alignment: .bottomLeading) {
    LinearGradient(
        colors: [Color(hex: "{{ACCENT}}"), Color(hex: "{{ACCENT}}").opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    VStack(alignment: .leading, spacing: 6) {
        Spacer()
        Text("PREMIUM")
            .font(.system(size: 10, weight: .heavy))
            .foregroundStyle(.white.opacity(0.7))
            .tracking(2)
        Text("Unlock all features")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.white)
        Text("Get access to everything →")
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.8))
    }
    .padding(20)
}
.frame(height: 160)
.clipShape(RoundedRectangle(cornerRadius: 20))
"""),
        snippet("Swipeable Card", "Card with swipe actions", .cards, ["card", "swipe", "delete", "action"], "rectangle.roundedtop", """
List {
    ForEach(items) { item in
        CardRow(item: item)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    delete(item)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    archive(item)
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .tint(Color(hex: "{{ACCENT}}"))
            }
    }
}
.listStyle(.plain)
"""),
    ]

    // MARK: Inputs
    static let inputs: [CuratedSnippet] = [
        snippet("Text Field", "Standard input field", .inputs, ["input", "textfield", "form"], "keyboard", """
@State private var text = ""

TextField("Placeholder", text: $text)
    .padding(12)
    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    .overlay(
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(text.isEmpty ? Color.clear : Color(hex: "{{ACCENT}}"),
                          lineWidth: 1.5)
    )
    .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
"""),
        snippet("Search Bar", "Search input with icon", .inputs, ["search", "input", "find"], "magnifyingglass", """
@State private var query = ""

HStack(spacing: 8) {
    Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)
    TextField("Search…", text: $query)
        .autocorrectionDisabled()
    if !query.isEmpty {
        Button { query = "" } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.secondary)
        }
    }
}
.padding(10)
.background(.quaternary, in: Capsule())
"""),
        snippet("Secure Field", "Password input", .inputs, ["password", "secure", "input"], "lock", """
@State private var password = ""
@State private var isVisible = false

HStack {
    Group {
        if isVisible {
            TextField("Password", text: $password)
        } else {
            SecureField("Password", text: $password)
        }
    }
    Button {
        isVisible.toggle()
    } label: {
        Image(systemName: isVisible ? "eye.slash" : "eye")
            .foregroundStyle(.secondary)
    }
}
.padding(12)
.background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
"""),
        snippet("Text Area", "Multi-line text input", .inputs, ["textarea", "multiline", "input", "notes"], "text.alignleft", """
@State private var notes = ""

TextField("Add notes…", text: $notes, axis: .vertical)
    .lineLimit(4...8)
    .padding(12)
    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    .overlay(
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(Color(hex: "{{ACCENT}}").opacity(notes.isEmpty ? 0 : 0.5),
                          lineWidth: 1.5)
    )
"""),
        snippet("Form Row", "Label + input pair", .inputs, ["form", "input", "row", "label"], "list.bullet.rectangle", """
VStack(spacing: 0) {
    HStack {
        Text("Email")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(width: 80, alignment: .leading)
        TextField("you@example.com", text: $email)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
    }
    .padding(14)
    Divider()
    HStack {
        Text("Name")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(width: 80, alignment: .leading)
        TextField("Full name", text: $name)
    }
    .padding(14)
}
.background(.background, in: RoundedRectangle(cornerRadius: 12))
"""),
        snippet("Stepper Row", "Number increment/decrement", .inputs, ["stepper", "number", "counter", "input"], "plusminus", """
@State private var quantity = 1

HStack(spacing: 16) {
    Text("Quantity")
        .font(.system(size: 16, weight: .medium))
    Spacer()
    HStack(spacing: 12) {
        Button {
            if quantity > 1 { quantity -= 1 }
        } label: {
            Image(systemName: "minus")
                .frame(width: 32, height: 32)
                .background(.quaternary, in: Circle())
        }
        Text("\\(quantity)")
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .frame(minWidth: 28)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: quantity)
        Button {
            quantity += 1
        } label: {
            Image(systemName: "plus")
                .frame(width: 32, height: 32)
                .background(Color(hex: "{{ACCENT}}"), in: Circle())
                .foregroundStyle(.white)
        }
    }
    .buttonStyle(.plain)
}
"""),
        snippet("Rating Stars", "Star rating input", .inputs, ["rating", "stars", "review", "input"], "star", """
@State private var rating = 0

HStack(spacing: 6) {
    ForEach(1...5, id: \\.self) { star in
        Image(systemName: star <= rating ? "star.fill" : "star")
            .font(.system(size: 28))
            .foregroundStyle(star <= rating
                             ? Color(hex: "{{ACCENT}}")
                             : Color.secondary.opacity(0.4))
            .onTapGesture {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    rating = star
                }
            }
            .symbolEffect(.bounce, value: rating)
    }
}
"""),
        snippet("Slider + Label", "Value slider with display", .inputs, ["slider", "range", "input", "value"], "slider.horizontal.3", """
@State private var value: Double = 50

VStack(spacing: 8) {
    HStack {
        Text("Brightness")
            .font(.system(size: 15, weight: .medium))
        Spacer()
        Text("\\(Int(value))%")
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(Color(hex: "{{ACCENT}}"))
            .contentTransition(.numericText())
    }
    Slider(value: $value, in: 0...100, step: 1)
        .tint(Color(hex: "{{ACCENT}}"))
}
"""),
    ]

    // MARK: Navigation
    static let navigation: [CuratedSnippet] = [
        snippet("Tab Bar", "Custom bottom tab bar", .navigation, ["tab", "navigation", "bottom bar"], "arrow.left.arrow.right", """
@State private var selectedTab = 0

ZStack(alignment: .bottom) {
    TabView(selection: $selectedTab) {
        HomeView().tag(0)
        SearchView().tag(1)
        ProfileView().tag(2)
    }

    HStack(spacing: 0) {
        ForEach(tabs.indices, id: \\.self) { i in
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedTab = i
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: tabs[i].icon)
                        .font(.system(size: 22))
                        .foregroundStyle(selectedTab == i
                                         ? Color(hex: "{{ACCENT}}")
                                         : .secondary)
                    Text(tabs[i].title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(selectedTab == i
                                         ? Color(hex: "{{ACCENT}}")
                                         : .secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
    .padding(.vertical, 12)
    .background(.thinMaterial)
}
"""),
        snippet("Breadcrumb", "Path navigation trail", .navigation, ["breadcrumb", "path", "navigation"], "chevron.right", """
let path = ["Home", "Settings", "Privacy"]

HStack(spacing: 4) {
    ForEach(path.indices, id: \\.self) { i in
        if i > 0 {
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        Text(path[i])
            .font(.system(size: 13, weight: i == path.count - 1 ? .semibold : .regular))
            .foregroundStyle(i == path.count - 1
                             ? Color(hex: "{{ACCENT}}")
                             : .secondary)
    }
}
"""),
        snippet("Back Button", "Custom navigation back", .navigation, ["back", "navigation", "chevron"], "chevron.left", """
Button {
    dismiss()
} label: {
    HStack(spacing: 4) {
        Image(systemName: "chevron.left")
            .font(.system(size: 16, weight: .semibold))
        Text("Back")
            .font(.system(size: 16))
    }
    .foregroundStyle(Color(hex: "{{ACCENT}}"))
}
.buttonStyle(.plain)
"""),
        snippet("Sidebar Item", "Collapsible sidebar row", .navigation, ["sidebar", "navigation", "menu", "row"], "sidebar.left", """
@State private var isSelected = false

Button {
    isSelected.toggle()
} label: {
    HStack(spacing: 10) {
        Image(systemName: "folder")
            .font(.system(size: 16))
            .foregroundStyle(isSelected ? .white : Color(hex: "{{ACCENT}}"))
            .frame(width: 20)
        Text("Projects")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(isSelected ? .white : .primary)
        Spacer()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
        isSelected ? Color(hex: "{{ACCENT}}") : Color.clear,
        in: RoundedRectangle(cornerRadius: 8)
    )
}
.buttonStyle(.plain)
"""),
        snippet("Page Indicator", "Dot-based page tracker", .navigation, ["page", "dots", "carousel", "indicator"], "circle.grid.2x1", """
@State private var currentPage = 0
let pageCount = 4

HStack(spacing: 6) {
    ForEach(0..<pageCount, id: \\.self) { i in
        Capsule()
            .fill(i == currentPage
                  ? Color(hex: "{{ACCENT}}")
                  : Color(hex: "{{ACCENT}}").opacity(0.25))
            .frame(width: i == currentPage ? 20 : 6, height: 6)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentPage)
    }
}
"""),
    ]

    // MARK: Lists
    static let lists: [CuratedSnippet] = [
        snippet("Settings Row", "Disclosure chevron row", .lists, ["settings", "row", "list", "navigation"], "list.bullet", """
HStack(spacing: 12) {
    Image(systemName: "bell.badge")
        .font(.system(size: 16))
        .foregroundStyle(.white)
        .frame(width: 32, height: 32)
        .background(Color(hex: "{{ACCENT}}"), in: RoundedRectangle(cornerRadius: 7))

    VStack(alignment: .leading, spacing: 2) {
        Text("Notifications")
            .font(.system(size: 16))
        Text("Badges, sounds, banners")
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
    }
    Spacer()
    Image(systemName: "chevron.right")
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(.tertiary)
}
.padding(14)
.background(.background)
"""),
        snippet("Toggle Row", "Settings toggle row", .lists, ["toggle", "switch", "settings", "row"], "switch.2", """
@State private var isEnabled = true

HStack(spacing: 12) {
    Image(systemName: "wifi")
        .font(.system(size: 16))
        .foregroundStyle(.white)
        .frame(width: 32, height: 32)
        .background(Color(hex: "{{ACCENT}}"), in: RoundedRectangle(cornerRadius: 7))

    Text("Wi-Fi")
        .font(.system(size: 16))
    Spacer()
    Toggle("", isOn: $isEnabled)
        .tint(Color(hex: "{{ACCENT}}"))
        .labelsHidden()
}
.padding(14)
.background(.background)
"""),
        snippet("Checklist Row", "Task with checkbox", .lists, ["checklist", "task", "todo", "checkbox"], "checkmark.circle", """
@State private var isDone = false

HStack(spacing: 12) {
    Button {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isDone.toggle()
        }
    } label: {
        Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 22))
            .foregroundStyle(isDone ? Color(hex: "{{ACCENT}}") : .secondary)
            .contentTransition(.symbolEffect(.replace))
    }
    .buttonStyle(.plain)

    Text("Buy groceries")
        .font(.system(size: 16))
        .strikethrough(isDone, color: .secondary)
        .foregroundStyle(isDone ? .secondary : .primary)
        .animation(.easeInOut(duration: 0.2), value: isDone)
}
"""),
        snippet("Section Header", "List section label", .lists, ["section", "header", "list", "label"], "text.alignleft", """
HStack {
    Text("RECENT")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(.secondary)
        .tracking(1.5)
    Spacer()
    Button("See All") { }
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(Color(hex: "{{ACCENT}}"))
}
.padding(.horizontal, 16)
.padding(.vertical, 8)
"""),
        snippet("Empty State", "No-content placeholder", .lists, ["empty", "placeholder", "state", "zero"], "tray", """
VStack(spacing: 16) {
    Image(systemName: "tray")
        .font(.system(size: 52, weight: .light))
        .foregroundStyle(Color(hex: "{{ACCENT}}").opacity(0.5))
    VStack(spacing: 6) {
        Text("Nothing Here Yet")
            .font(.system(size: 20, weight: .semibold))
        Text("Your items will appear here once added.")
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    Button("Get Started") { }
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(Color(hex: "{{ACCENT}}"), in: Capsule())
        .buttonStyle(.plain)
}
.frame(maxWidth: .infinity, maxHeight: .infinity)
"""),
    ]

    // MARK: Badges
    static let badges: [CuratedSnippet] = [
        snippet("Status Badge", "Colored status pill", .badges, ["badge", "status", "pill", "label"], "tag", """
Text("Active")
    .font(.system(size: 12, weight: .semibold))
    .foregroundStyle(Color(hex: "{{ACCENT}}"))
    .padding(.horizontal, 10)
    .padding(.vertical, 4)
    .background(Color(hex: "{{ACCENT}}").opacity(0.12), in: Capsule())
    .overlay(Capsule().strokeBorder(Color(hex: "{{ACCENT}}").opacity(0.3), lineWidth: 1))
"""),
        snippet("Notification Badge", "Count dot overlay", .badges, ["badge", "notification", "count", "dot"], "bell.badge", """
ZStack(alignment: .topTrailing) {
    Image(systemName: "bell")
        .font(.system(size: 24))

    if notificationCount > 0 {
        Text(notificationCount > 99 ? "99+" : "\\(notificationCount)")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.red, in: Capsule())
            .offset(x: 8, y: -6)
            .animation(.spring(response: 0.3, dampingFraction: 0.7),
                       value: notificationCount)
    }
}
"""),
        snippet("Tag Chip", "Dismissible tag", .badges, ["tag", "chip", "filter", "dismiss"], "tag.fill", """
HStack(spacing: 6) {
    Text("SwiftUI")
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(Color(hex: "{{ACCENT}}"))
    Button {
        // remove tag
    } label: {
        Image(systemName: "xmark")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Color(hex: "{{ACCENT}}").opacity(0.7))
    }
}
.padding(.horizontal, 10)
.padding(.vertical, 6)
.background(Color(hex: "{{ACCENT}}").opacity(0.1), in: Capsule())
.overlay(Capsule().strokeBorder(Color(hex: "{{ACCENT}}").opacity(0.2), lineWidth: 1))
"""),
        snippet("Progress Badge", "Step / progress indicator", .badges, ["progress", "step", "badge", "indicator"], "chart.bar", """
HStack(spacing: 4) {
    Image(systemName: "bolt.fill")
        .font(.system(size: 10, weight: .bold))
    Text("Step 3 of 5")
        .font(.system(size: 12, weight: .semibold))
}
.foregroundStyle(.white)
.padding(.horizontal, 10)
.padding(.vertical, 5)
.background(Color(hex: "{{ACCENT}}"), in: Capsule())
"""),
    ]

    // MARK: Alerts
    static let alerts: [CuratedSnippet] = [
        snippet("Info Banner", "Informational inline alert", .alerts, ["alert", "info", "banner", "message"], "info.circle", """
HStack(spacing: 10) {
    Image(systemName: "info.circle.fill")
        .foregroundStyle(Color(hex: "{{ACCENT}}"))
    Text("Your session expires in 5 minutes.")
        .font(.system(size: 14))
    Spacer()
    Button { } label: {
        Image(systemName: "xmark")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.secondary)
    }
}
.padding(12)
.background(Color(hex: "{{ACCENT}}").opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
.overlay(
    RoundedRectangle(cornerRadius: 10)
        .strokeBorder(Color(hex: "{{ACCENT}}").opacity(0.2), lineWidth: 1)
)
"""),
        snippet("Toast Notification", "Bottom slide-up toast", .alerts, ["toast", "notification", "snackbar", "popup"], "checkmark.circle", """
@State private var showToast = false

// Trigger: showToast = true (auto-dismiss after 2s)
if showToast {
    HStack(spacing: 10) {
        Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(.green)
        Text("Saved successfully!")
            .font(.system(size: 14, weight: .medium))
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(.ultraThinMaterial, in: Capsule())
    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    .transition(.move(edge: .bottom).combined(with: .opacity))
    .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showToast = false }
        }
    }
}
"""),
        snippet("Warning Banner", "Yellow warning message", .alerts, ["warning", "alert", "banner", "caution"], "exclamationmark.triangle", """
HStack(spacing: 10) {
    Image(systemName: "exclamationmark.triangle.fill")
        .foregroundStyle(.orange)
    VStack(alignment: .leading, spacing: 2) {
        Text("Storage Almost Full")
            .font(.system(size: 14, weight: .semibold))
        Text("90% of your storage is used.")
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
    }
}
.padding(12)
.background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
.overlay(
    RoundedRectangle(cornerRadius: 10)
        .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
)
"""),
        snippet("Error State", "Full-screen error view", .alerts, ["error", "state", "empty", "retry"], "exclamationmark.circle", """
VStack(spacing: 16) {
    Image(systemName: "exclamationmark.circle")
        .font(.system(size: 52, weight: .light))
        .foregroundStyle(.red.opacity(0.7))
    VStack(spacing: 6) {
        Text("Something Went Wrong")
            .font(.system(size: 20, weight: .semibold))
        Text(error.localizedDescription)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    Button("Try Again") {
        retry()
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 24)
    .padding(.vertical, 10)
    .background(Color(hex: "{{ACCENT}}"), in: Capsule())
    .buttonStyle(.plain)
}
.padding()
.frame(maxWidth: .infinity, maxHeight: .infinity)
"""),
    ]

    // MARK: Loading
    static let loading: [CuratedSnippet] = [
        snippet("Skeleton Row", "Shimmer placeholder row", .loading, ["skeleton", "shimmer", "loading", "placeholder"], "arrow.triangle.2.circlepath", """
// Reusable shimmer modifier
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.5), .clear],
                    startPoint: .init(x: phase - 0.3, y: 0.5),
                    endPoint: .init(x: phase + 0.3, y: 0.5)
                )
                .animation(.linear(duration: 1.2).repeatForever(autoreverses: false),
                           value: phase)
            )
            .onAppear { phase = 1.0 }
            .mask(content)
    }
}

// Usage
HStack(spacing: 12) {
    Circle()
        .fill(Color.secondary.opacity(0.2))
        .frame(width: 44, height: 44)
        .modifier(Shimmer())
    VStack(alignment: .leading, spacing: 6) {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.secondary.opacity(0.2))
            .frame(height: 12)
            .modifier(Shimmer())
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.secondary.opacity(0.2))
            .frame(width: 120, height: 10)
            .modifier(Shimmer())
    }
}
"""),
        snippet("Progress Bar", "Determinate progress", .loading, ["progress", "bar", "loading", "percent"], "chart.bar", """
@State private var progress: Double = 0.6

VStack(alignment: .leading, spacing: 6) {
    HStack {
        Text("Uploading…")
            .font(.system(size: 14, weight: .medium))
        Spacer()
        Text("\\(Int(progress * 100))%")
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(Color(hex: "{{ACCENT}}"))
            .contentTransition(.numericText())
    }
    GeometryReader { geo in
        ZStack(alignment: .leading) {
            Capsule().fill(.quaternary).frame(height: 8)
            Capsule()
                .fill(Color(hex: "{{ACCENT}}"))
                .frame(width: geo.size.width * progress, height: 8)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
        }
    }
    .frame(height: 8)
}
"""),
        snippet("Spinner Overlay", "Full-screen loading overlay", .loading, ["spinner", "loading", "overlay", "full screen"], "circle.dotted", """
@State private var isLoading = true

ZStack {
    contentView

    if isLoading {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(hex: "{{ACCENT}}"))
                        .scaleEffect(1.4)
                    Text("Loading…")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            )
            .transition(.opacity)
    }
}
.animation(.easeInOut(duration: 0.25), value: isLoading)
"""),
    ]

    // MARK: Avatars
    static let avatars: [CuratedSnippet] = [
        snippet("Initials Avatar", "Letter-based avatar", .avatars, ["avatar", "initials", "user", "profile"], "person.circle", """
func initialsAvatar(name: String, size: CGFloat = 44) -> some View {
    let initials = name.split(separator: " ").compactMap(\\.first).prefix(2)
        .map(String.init).joined()
    return Text(initials.uppercased())
        .font(.system(size: size * 0.36, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: size, height: size)
        .background(Color(hex: "{{ACCENT}}"), in: Circle())
}
"""),
        snippet("Avatar Stack", "Overlapping avatar group", .avatars, ["avatar", "group", "stack", "users"], "person.2", """
let users: [User] = [/* ... */]
let maxVisible = 4

HStack(spacing: -12) {
    ForEach(users.prefix(maxVisible)) { user in
        AsyncImage(url: user.avatarURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Circle().fill(Color(hex: "{{ACCENT}}").opacity(0.2))
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.background, lineWidth: 2))
    }
    if users.count > maxVisible {
        Text("+\\(users.count - maxVisible)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color(hex: "{{ACCENT}}"))
            .frame(width: 36, height: 36)
            .background(Color(hex: "{{ACCENT}}").opacity(0.1), in: Circle())
            .overlay(Circle().strokeBorder(.background, lineWidth: 2))
    }
}
"""),
        snippet("Online Indicator", "Avatar with presence dot", .avatars, ["avatar", "online", "presence", "status"], "circle.fill", """
ZStack(alignment: .bottomTrailing) {
    Circle()
        .fill(Color(hex: "{{ACCENT}}").opacity(0.2))
        .frame(width: 48, height: 48)
        .overlay(
            Text("JD")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: "{{ACCENT}}"))
        )

    Circle()
        .fill(.green)
        .frame(width: 12, height: 12)
        .overlay(Circle().strokeBorder(.background, lineWidth: 2))
}
"""),
    ]

    // MARK: Layout
    static let layout: [CuratedSnippet] = [
        snippet("2-Column Grid", "Adaptive two-column layout", .layout, ["grid", "columns", "layout", "collection"], "square.grid.2x2", """
let columns = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12)
]

ScrollView {
    LazyVGrid(columns: columns, spacing: 12) {
        ForEach(items) { item in
            ItemCard(item: item)
        }
    }
    .padding(16)
}
"""),
        snippet("Adaptive Grid", "Auto-sizing grid cells", .layout, ["grid", "adaptive", "layout"], "square.grid.3x3", """
ScrollView {
    LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 100, maximum: 140), spacing: 12)],
        spacing: 12
    ) {
        ForEach(items) { item in
            ItemCard(item: item)
        }
    }
    .padding(16)
}
"""),
        snippet("Split View", "Master/detail two-panel", .layout, ["split", "master", "detail", "layout"], "rectangle.split.2x1", """
NavigationSplitView {
    List(items, selection: $selectedItem) { item in
        Label(item.title, systemImage: item.icon)
    }
    .navigationTitle("Items")
} detail: {
    if let item = selectedItem {
        ItemDetailView(item: item)
    } else {
        ContentUnavailableView("Select an item", systemImage: "sidebar.left")
    }
}
"""),
        snippet("Pinned Header List", "Sticky section headers", .layout, ["list", "sticky", "header", "sections"], "list.bullet.rectangle", """
List {
    ForEach(sections) { section in
        Section {
            ForEach(section.items) { item in
                ItemRow(item: item)
            }
        } header: {
            Text(section.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(hex: "{{ACCENT}}"))
                .textCase(nil)
        }
    }
}
.listStyle(.plain)
"""),
        snippet("ScrollView with Offset", "Collapsing header on scroll", .layout, ["scroll", "offset", "header", "collapse"], "arrow.up.and.down", """
@State private var scrollOffset: CGFloat = 0

ScrollView {
    VStack {
        // Large header that shrinks on scroll
        Text("Title")
            .font(.system(
                size: max(20, 36 - scrollOffset * 0.3),
                weight: .bold
            ))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .opacity(max(0, 1 - scrollOffset / 80))

        // Content
        ForEach(items) { item in ItemRow(item: item) }
    }
    .background(GeometryReader { geo in
        Color.clear.preference(
            key: ScrollOffsetKey.self,
            value: -geo.frame(in: .named("scroll")).minY
        )
    })
}
.coordinateSpace(name: "scroll")
.onPreferenceChange(ScrollOffsetKey.self) { scrollOffset = $0 }
"""),
    ]

    // MARK: - Factory
    private static func snippet(_ title: String, _ subtitle: String,
                                 _ category: SnippetCategory, _ tags: [String],
                                 _ symbol: String, _ code: String) -> CuratedSnippet {
        CuratedSnippet(id: UUID(), title: title, subtitle: subtitle,
                       category: category, tags: tags, code: code,
                       previewSymbol: symbol)
    }
}
