//
//  LayoutInspectorTab.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//
// LayoutModels.swift
// DevDesign — Features/LayoutInspector/LayoutModels.swift

import SwiftUI

// MARK: - Inspector Tab

enum LayoutInspectorTab: String, CaseIterable, Identifiable {
    case playground = "Playground"
    case patterns   = "Patterns"
    case safeArea   = "Safe Area"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .playground: return "square.3.layers.3d"
        case .patterns:   return "rectangle.3.group"
        case .safeArea:   return "iphone"
        }
    }
}

// MARK: - Stack Type

enum StackType: String, CaseIterable, Identifiable {
    case hStack = "HStack"
    case vStack = "VStack"
    case zStack = "ZStack"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .hStack: return "arrow.left.arrow.right"
        case .vStack: return "arrow.up.arrow.down"
        case .zStack: return "square.2.layers.3d"
        }
    }
}

// MARK: - Stack Alignment

enum StackAlignment: String, CaseIterable, Identifiable {
    // HStack vertical alignment
    case top       = "top"
    case center    = "center"
    case bottom    = "bottom"
    case firstTextBaseline = "firstTextBaseline"
    // VStack horizontal alignment
    case leading   = "leading"
    case trailing  = "trailing"
    // ZStack alignment
    case topLeading     = "topLeading"
    case topTrailing    = "topTrailing"
    case bottomLeading  = "bottomLeading"
    case bottomTrailing = "bottomTrailing"

    var id: String { rawValue }

    static func options(for stack: StackType) -> [StackAlignment] {
        switch stack {
        case .hStack: return [.top, .center, .bottom, .firstTextBaseline]
        case .vStack: return [.leading, .center, .trailing]
        case .zStack: return [.topLeading, .top, .topTrailing,
                              .leading, .center, .trailing,
                              .bottomLeading, .bottom, .bottomTrailing]
        }
    }
}

// MARK: - Child Element

enum ChildElementType: String, CaseIterable, Identifiable {
    case text       = "Text"
    case rectangle  = "Rectangle"
    case circle     = "Circle"
    case image      = "Image"
    case spacer     = "Spacer"
    case divider    = "Divider"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .text:      return "textformat"
        case .rectangle: return "rectangle.fill"
        case .circle:    return "circle.fill"
        case .image:     return "photo"
        case .spacer:    return "arrow.left.and.right"
        case .divider:   return "minus"
        }
    }
}

struct ChildElement: Identifiable, Equatable {
    let id: UUID
    var type: ChildElementType
    var label: String           // display label e.g. "Text 1"
    var width: CGFloat          // 0 = flexible
    var height: CGFloat         // 0 = flexible
    var color: Color
    var text: String            // for .text type

    init(id: UUID = UUID(), type: ChildElementType, index: Int) {
        self.id     = id
        self.type   = type
        self.label  = "\(type.rawValue) \(index)"
        self.width  = 0
        self.height = type == .divider ? 1 : (type == .spacer ? 0 : 60)
        self.color  = ChildElement.defaultColor(for: type)
        self.text   = type == .text ? "Label" : ""
    }

    static func defaultColor(for type: ChildElementType) -> Color {
        switch type {
        case .text:      return .primary
        case .rectangle: return Color(hex: "#7B6EF6").opacity(0.6)
        case .circle:    return Color(hex: "#FF6B6B").opacity(0.6)
        case .image:     return Color(hex: "#30D158").opacity(0.6)
        case .spacer:    return Color(hex: "#FF9F0A").opacity(0.3)
        case .divider:   return Color.secondary
        }
    }
}

// MARK: - Stack Config

struct StackConfig: Equatable {
    var type: StackType           = .hStack
    var alignment: StackAlignment = .center
    var spacing: CGFloat          = 12
    var children: [ChildElement]  = StackConfig.defaultChildren()
    var showSpacingGuides: Bool    = true
    var showAlignmentGuides: Bool  = true
    var showSizeLabels: Bool       = false

    static func defaultChildren() -> [ChildElement] {
        [
            ChildElement(type: .rectangle, index: 1),
            ChildElement(type: .rectangle, index: 2),
            ChildElement(type: .rectangle, index: 3),
        ]
    }
}

// MARK: - Layout Pattern

struct LayoutPattern: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let category: PatternCategory
    let icon: String
    let code: String

    enum PatternCategory: String, CaseIterable {
        case navigation = "Navigation"
        case lists      = "Lists"
        case forms      = "Forms"
        case content    = "Content"
        case overlay    = "Overlays"
    }
}

enum LayoutPatternLibrary {
    static let all: [LayoutPattern] = [

        // MARK: Navigation
        LayoutPattern(id: UUID(), name: "NavigationStack + List",
                      description: "Standard push-navigation with a list",
                      category: .navigation, icon: "list.bullet.rectangle.portrait",
                      code: """
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {
            Label(item.title, systemImage: item.icon)
        }
    }
    .listStyle(.insetGrouped)
    .navigationTitle("Items")
    .navigationDestination(for: Item.self) { item in
        ItemDetailView(item: item)
    }
}
"""),
        LayoutPattern(id: UUID(), name: "TabView",
                      description: "Bottom tab bar with 3 tabs",
                      category: .navigation, icon: "square.bottomthird.inset.filled",
                      code: """
TabView {
    HomeView()
        .tabItem {
            Label("Home", systemImage: "house")
        }
    SearchView()
        .tabItem {
            Label("Search", systemImage: "magnifyingglass")
        }
    ProfileView()
        .tabItem {
            Label("Profile", systemImage: "person")
        }
}
.tint(.accentColor)
"""),
        LayoutPattern(id: UUID(), name: "NavigationSplitView",
                      description: "iPad / Mac master–detail layout",
                      category: .navigation, icon: "rectangle.split.2x1",
                      code: """
NavigationSplitView {
    // Sidebar
    List(items, selection: $selectedItem) { item in
        Label(item.title, systemImage: item.icon)
            .tag(item)
    }
    .listStyle(.sidebar)
    .navigationTitle("Sidebar")
} detail: {
    if let item = selectedItem {
        ItemDetailView(item: item)
    } else {
        ContentUnavailableView(
            "Select an Item",
            systemImage: "sidebar.left"
        )
    }
}
"""),
        LayoutPattern(id: UUID(), name: "Sheet / Modal",
                      description: "Bottom sheet with detents",
                      category: .navigation, icon: "rectangle.bottomthird.inset.filled",
                      code: """
@State private var showSheet = false

Button("Open Sheet") {
    showSheet = true
}
.sheet(isPresented: $showSheet) {
    SheetContentView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(24)
}
"""),

        // MARK: Lists
        LayoutPattern(id: UUID(), name: "Sectioned List",
                      description: "Grouped list with section headers",
                      category: .lists, icon: "list.bullet.indent",
                      code: """
List {
    ForEach(sections) { section in
        Section {
            ForEach(section.items) { item in
                ItemRow(item: item)
            }
        } header: {
            Text(section.title)
                .textCase(nil)
                .font(.subheadline.weight(.semibold))
        } footer: {
            Text(section.footer)
                .foregroundStyle(.secondary)
        }
    }
}
.listStyle(.insetGrouped)
"""),
        LayoutPattern(id: UUID(), name: "LazyVGrid 2-Col",
                      description: "Responsive two-column grid",
                      category: .lists, icon: "square.grid.2x2",
                      code: """
ScrollView {
    LazyVGrid(
        columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ],
        spacing: 12
    ) {
        ForEach(items) { item in
            ItemCard(item: item)
        }
    }
    .padding(.horizontal, 16)
}
"""),
        LayoutPattern(id: UUID(), name: "Horizontal Scroll",
                      description: "Paging horizontal carousel",
                      category: .lists, icon: "arrow.left.arrow.right.square",
                      code: """
ScrollView(.horizontal, showsIndicators: false) {
    LazyHStack(spacing: 16) {
        ForEach(items) { item in
            ItemCard(item: item)
                .frame(width: 240)
                .containerRelativeFrame(.horizontal,
                    count: 1, spacing: 32)
        }
    }
    .scrollTargetLayout()
    .padding(.horizontal, 16)
}
.scrollTargetBehavior(.viewAligned)
"""),
        LayoutPattern(id: UUID(), name: "Infinite Scroll",
                      description: "Load-more on scroll to bottom",
                      category: .lists, icon: "arrow.down.circle",
                      code: """
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(viewModel.items) { item in
            ItemRow(item: item)
                .onAppear {
                    if item == viewModel.items.last {
                        Task { await viewModel.loadMore() }
                    }
                }
        }
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
}
"""),

        // MARK: Forms
        LayoutPattern(id: UUID(), name: "Settings Form",
                      description: "Grouped settings with sections",
                      category: .forms, icon: "gearshape",
                      code: """
Form {
    Section("Account") {
        LabeledContent("Name", value: user.name)
        NavigationLink("Email") {
            EditEmailView()
        }
    }
    Section("Notifications") {
        Toggle("Push Alerts", isOn: $pushEnabled)
        Toggle("Email Digest", isOn: $emailEnabled)
    }
    Section {
        Button("Sign Out", role: .destructive) {
            signOut()
        }
    }
}
.formStyle(.grouped)
"""),
        LayoutPattern(id: UUID(), name: "Multi-Step Form",
                      description: "Wizard with step indicator",
                      category: .forms, icon: "list.number",
                      code: """
@State private var step = 0
let steps = ["Info", "Details", "Review"]

VStack(spacing: 24) {
    // Step indicator
    HStack {
        ForEach(steps.indices, id: \\.self) { i in
            HStack(spacing: 4) {
                Circle()
                    .fill(i <= step ? Color.accentColor : .secondary.opacity(0.3))
                    .frame(width: 28, height: 28)
                    .overlay(Text("\\(i + 1)").font(.caption.bold())
                        .foregroundStyle(i <= step ? .white : .secondary))
                if i < steps.count - 1 {
                    Rectangle()
                        .fill(i < step ? Color.accentColor : .secondary.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
    }

    // Step content
    switch step {
    case 0: StepOneView()
    case 1: StepTwoView()
    default: ReviewView()
    }

    // Navigation
    HStack {
        if step > 0 {
            Button("Back") { step -= 1 }
        }
        Spacer()
        Button(step < steps.count - 1 ? "Next" : "Submit") {
            if step < steps.count - 1 { step += 1 }
            else { submit() }
        }
        .buttonStyle(.borderedProminent)
    }
}
.padding()
.animation(.spring(response: 0.3, dampingFraction: 0.8), value: step)
"""),

        // MARK: Content
        LayoutPattern(id: UUID(), name: "Profile Header",
                      description: "Stretchy header + scroll content",
                      category: .content, icon: "person.crop.rectangle",
                      code: """
ScrollView {
    VStack(spacing: 0) {
        // Stretchy header
        GeometryReader { geo in
            let offset = geo.frame(in: .global).minY
            Image("header")
                .resizable()
                .scaledToFill()
                .frame(
                    width: geo.size.width,
                    height: max(200, 200 + offset)
                )
                .clipped()
                .offset(y: offset > 0 ? -offset : 0)
        }
        .frame(height: 200)

        // Content below header
        VStack(alignment: .leading, spacing: 16) {
            profileInfo
            statsRow
            bioText
            actionButtons
        }
        .padding()
    }
}
.ignoresSafeArea(edges: .top)
"""),
        LayoutPattern(id: UUID(), name: "Card Feed",
                      description: "Social-style scrollable feed",
                      category: .content, icon: "square.stack",
                      code: """
ScrollView {
    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
        Section {
            ForEach(viewModel.posts) { post in
                PostCard(post: post)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        } header: {
            storiesRow
                .background(.background)
        }
    }
}
.refreshable {
    await viewModel.refresh()
}
"""),
        LayoutPattern(id: UUID(), name: "Detail + FAB",
                      description: "Content view with floating button",
                      category: .content, icon: "plus.circle.fill",
                      code: """
ZStack(alignment: .bottomTrailing) {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            headerImage
            contentBody
            relatedItems
        }
    }

    // Floating Action Button
    Button {
        showCompose = true
    } label: {
        Image(systemName: "plus")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)
            .background(Color.accentColor, in: Circle())
            .shadow(color: Color.accentColor.opacity(0.4),
                    radius: 12, x: 0, y: 6)
    }
    .buttonStyle(.plain)
    .padding(24)
}
"""),

        // MARK: Overlays
        LayoutPattern(id: UUID(), name: "Full-Screen Cover",
                      description: "Full-screen modal presentation",
                      category: .overlay, icon: "rectangle.fill",
                      code: """
@State private var showCover = false

Button("Show Cover") {
    showCover = true
}
.fullScreenCover(isPresented: $showCover) {
    ZStack(alignment: .topTrailing) {
        CoverContentView()

        Button {
            showCover = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
"""),
        LayoutPattern(id: UUID(), name: "Overlay / Popover",
                      description: "Contextual info overlay",
                      category: .overlay, icon: "square.on.square",
                      code: """
@State private var showPopover = false

Button("Info") {
    showPopover.toggle()
}
.popover(isPresented: $showPopover,
         attachmentAnchor: .point(.bottom),
         arrowEdge: .top) {
    PopoverContent()
        .frame(width: 280)
        .presentationCompactAdaptation(.popover)
}

// — OR — inline overlay
ZStack(alignment: .bottom) {
    mainContent

    if showOverlay {
        overlayContent
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(1)
    }
}
.animation(.spring(response: 0.35, dampingFraction: 0.85), value: showOverlay)
"""),
    ]
}

// MARK: - Safe Area Item

struct SafeAreaItem: Identifiable {
    let id = UUID()
    let label: String
    let colorHex: String
    let description: String

    var color: Color { Color(hex: colorHex) }
}

let safeAreaGuides: [SafeAreaItem] = [
    SafeAreaItem(label: "Status Bar",
                 colorHex: "#FF6B6B",
                 description: "54pt Dynamic Island, 44pt notch, 20pt SE, 24pt iPad"),
    SafeAreaItem(label: "Nav Bar",
                 colorHex: "#FF9F0A",
                 description: "44pt standard, 32pt in landscape, 96pt with large title"),
    SafeAreaItem(label: "Content Area",
                 colorHex: "#30D158",
                 description: "Available space minus system bars and safe area insets"),
    SafeAreaItem(label: "Tab Bar",
                 colorHex: "#7B6EF6",
                 description: "49pt iPhone, 50pt iPad. Extends to bottom edge"),
    SafeAreaItem(label: "Bottom Safe",
                 colorHex: "#64D2FF",
                 description: "34pt for home indicator (Face ID), 20pt iPad, 0pt SE"),
]

// MARK: - Layout Export Service

enum LayoutExportService {

    static func exportStack(_ config: StackConfig) -> String {
        let childrenCode = config.children.map { child in
            childCode(child, stackType: config.type)
        }.joined(separator: "\n")

        let alignmentCode = alignmentString(config.alignment, for: config.type)
        let spacingCode = config.spacing == 0 ? "" : ", spacing: \(Int(config.spacing))"

        switch config.type {
        case .hStack:
            return """
HStack(alignment: .\(alignmentCode)\(spacingCode)) {
\(indent(childrenCode))
}
"""
        case .vStack:
            return """
VStack(alignment: .\(alignmentCode)\(spacingCode)) {
\(indent(childrenCode))
}
"""
        case .zStack:
            return """
ZStack(alignment: .\(alignmentCode)) {
\(indent(childrenCode))
}
"""
        }
    }

    private static func childCode(_ child: ChildElement, stackType: StackType) -> String {
        switch child.type {
        case .text:
            return "Text(\"\(child.text.isEmpty ? child.label : child.text)\")"
        case .rectangle:
            let size = sizeModifiers(child)
            return "Rectangle()\n    .fill(Color(hex: \"7B6EF6\").opacity(0.6))\(size)"
        case .circle:
            let w = child.width > 0 ? child.width : child.height
            let dim = w > 0 ? "\n    .frame(width: \(Int(w)), height: \(Int(w)))" : ""
            return "Circle()\n    .fill(Color(hex: \"FF6B6B\").opacity(0.6))\(dim)"
        case .image:
            let size = sizeModifiers(child)
            return "Image(systemName: \"photo\")\n    .resizable()\n    .scaledToFit()\(size)"
        case .spacer:
            return "Spacer()"
        case .divider:
            return "Divider()"
        }
    }

    private static func sizeModifiers(_ child: ChildElement) -> String {
        let w = child.width > 0  ? Int(child.width)  : 0
        let h = child.height > 0 ? Int(child.height) : 0
        if w > 0 && h > 0 { return "\n    .frame(width: \(w), height: \(h))" }
        if w > 0           { return "\n    .frame(width: \(w))" }
        if h > 0           { return "\n    .frame(height: \(h))" }
        return ""
    }

    private static func alignmentString(_ a: StackAlignment, for type: StackType) -> String {
        a.rawValue
    }

    private static func indent(_ code: String) -> String {
        code.split(separator: "\n", omittingEmptySubsequences: false)
            .map { "    " + $0 }
            .joined(separator: "\n")
    }
}
