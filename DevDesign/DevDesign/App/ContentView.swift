// ContentView.swift
// DevDesign — Features/Dashboard/ContentView.swift
//
// Updated after Phase 2 Steps 7 & 8.
// Phase 1: all 4 features wired ✅
// Phase 2: Type Scale + Font Pairing wired ✅ · Spacing + SF Symbols still coming

import SwiftUI
import SwiftData

// MARK: - Root Content View
struct ContentView: View {
    var body: some View {
        DashboardView()
    }
}

// MARK: - Dashboard View
struct DashboardView: View {

    @State private var greeting: String = DashboardView.timeGreeting()

    private let features: [FeatureCard] = FeatureCard.all

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Header ──────────────────────────────────────────
                        headerSection

                        // ── Phase 1 — Color Tools ────────────────────────────
                        sectionHeader(title: "Color Tools", subtitle: "Phase 1")
                            .padding(.top, DSSpacing.lg)

                        featuresGrid(cards: features.filter { $0.phase == 1 })

                        // ── Phase 2 — Typography & Spacing ───────────────────
                        sectionHeader(title: "Typography & Spacing", subtitle: "Phase 2")
                            .padding(.top, DSSpacing.xl)

                        featuresGrid(cards: features.filter { $0.phase == 2 })

                        // ── Coming Soon — Phases 3–5 ─────────────────────────
                        sectionHeader(title: "Coming Soon", subtitle: "Phases 3–5")
                            .padding(.top, DSSpacing.xl)

                        comingSoonGrid

                        Spacer(minLength: DSSpacing.xxxl)
                    }
                    .padding(.horizontal, DSSpacing.screenPadding)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(greeting)
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.accent)
                    Text("DevDesign")
                        .font(DSTypography.displayLarge)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(DSColors.Preview.accentMuted)
                        .frame(width: 44, height: 44)
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(DSColors.Preview.accent)
                }
            }
            .padding(.top, DSSpacing.lg)

            Text("Your design companion while you code.")
                .font(DSTypography.bodyMedium)
                .foregroundStyle(DSColors.Preview.textSecondary)
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String, subtitle: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: DSSpacing.xs) {
            Text(title)
                .font(DSTypography.headingMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
            Text(subtitle)
                .font(DSTypography.labelMedium)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .padding(.horizontal, DSSpacing.xs)
                .padding(.vertical, 3)
                .background(DSColors.Preview.backgroundTertiary, in: Capsule())
            Spacer()
        }
    }

    // MARK: - Features Grid
    private func featuresGrid(cards: [FeatureCard]) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DSSpacing.sm),
                GridItem(.flexible(), spacing: DSSpacing.sm)
            ],
            spacing: DSSpacing.sm
        ) {
            ForEach(cards) { card in
                FeatureCardView(card: card)
            }
        }
        .padding(.top, DSSpacing.sm)
    }

    // MARK: - Coming Soon Grid
    private var comingSoonGrid: some View {
        VStack(spacing: DSSpacing.xs) {
            ForEach(ComingSoonItem.all) { item in
                ComingSoonRowView(item: item)
            }
        }
        .padding(.top, DSSpacing.sm)
    }

    // MARK: - Greeting
    static func timeGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 0..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }
}

// MARK: - Feature Card View
struct FeatureCardView: View {

    let card: FeatureCard
    @State private var isPressed = false

    var body: some View {
        NavigationLink(destination: card.destination) {
            VStack(alignment: .leading, spacing: DSSpacing.cardSpacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                        .fill(card.accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: card.icon)
                        .font(.system(size: DSSpacing.Icon.md, weight: .semibold))
                        .foregroundStyle(card.accentColor)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(card.title)
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .lineLimit(1)
                    Text(card.subtitle)
                        .font(DSTypography.labelMedium)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(DSSpacing.cardPadding)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(DSColors.Preview.surfaceDefault,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}

// MARK: - Coming Soon Row
struct ComingSoonRowView: View {
    let item: ComingSoonItem

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                    .fill(DSColors.Preview.backgroundTertiary)
                    .frame(width: 36, height: 36)
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textSecondary)
                Text(item.phase)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            Spacer()

            Text("Soon")
                .font(DSTypography.labelSmall)
                .foregroundStyle(DSColors.Preview.textTertiary)
                .padding(.horizontal, DSSpacing.xs)
                .padding(.vertical, 4)
                .background(DSColors.Preview.backgroundTertiary, in: Capsule())
        }
        .padding(DSSpacing.sm)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - FeatureCard Data

struct FeatureCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let phase: Int
    let destination: AnyView

    static var all: [FeatureCard] = [

        // ── Phase 1 — Color Tools ──────────────────────────────────
        FeatureCard(
            title: "Palette Generator",
            subtitle: "Complementary, triadic & more",
            icon: "swatchpalette.fill",
            accentColor: Color(hex: "#7B6EF6"),
            phase: 1,
            destination: AnyView(PaletteGeneratorView())
        ),
        FeatureCard(
            title: "Color Picker",
            subtitle: "HEX · RGB · SwiftUI export",
            icon: "eyedropper.halffull",
            accentColor: Color(hex: "#FF6B6B"),
            phase: 1,
            destination: AnyView(ColorPickerView())
        ),
        FeatureCard(
            title: "Contrast Checker",
            subtitle: "WCAG AA & AAA compliance",
            icon: "circle.lefthalf.filled",
            accentColor: Color(hex: "#34C759"),
            phase: 1,
            destination: AnyView(ContrastCheckerView())
        ),
        FeatureCard(
            title: "Saved Palettes",
            subtitle: "Your bookmarked collections",
            icon: "bookmark.fill",
            accentColor: Color(hex: "#FF9F0A"),
            phase: 1,
            destination: AnyView(SavedPalettesView())
        ),

        // ── Phase 2 — Typography & Spacing ────────────────────────
        FeatureCard(
            title: "Type Scale",
            subtitle: "Modular scale generator",
            icon: "textformat.size",
            accentColor: Color(hex: "#30D158"),
            phase: 2,
            destination: AnyView(TypeScaleView())
        ),
        FeatureCard(
            title: "Font Pairing",
            subtitle: "Curated pairs + Google Fonts",
            icon: "character.textbox",
            accentColor: Color(hex: "#64D2FF"),
            phase: 2,
            destination: AnyView(FontPairingView())
        ),
        FeatureCard(
            title: "Spacing System",
            subtitle: "4pt grid + token export",
            icon: "arrow.left.and.right",
            accentColor: Color(hex: "#FF9F0A"),
            phase: 2,
            destination: AnyView(SpacingSystemView())
        ),
        FeatureCard(
            title: "SF Symbols",
            subtitle: "Search, preview & copy",
            icon: "square.grid.2x2",
            accentColor: Color(hex: "#BF5AF2"),
            phase: 2,
            destination: AnyView(SFSymbolsView())
        ),
    ]
}

// MARK: - ComingSoonItem Data
// Phase 2 fully promoted to FeatureCards — only Phases 3–5 remain here.

struct ComingSoonItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let phase: String

    static var all: [ComingSoonItem] = [
        ComingSoonItem(title: "Component Snippets",    icon: "rectangle.3.group.fill",   phase: "Phase 3"),
        ComingSoonItem(title: "Shadow Playground",     icon: "shadow",                   phase: "Phase 3"),
        ComingSoonItem(title: "Gradient Builder",      icon: "circles.hexagonpath.fill", phase: "Phase 3"),
        ComingSoonItem(title: "App Icon Generator",    icon: "app.fill",                 phase: "Phase 4"),
        ComingSoonItem(title: "AI Palette from Prompt",icon: "sparkles",                 phase: "Phase 5"),
    ]
}

// MARK: - Placeholder
struct PlaceholderView: View {
    let title: String
    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()
            VStack(spacing: DSSpacing.md) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 40))
                    .foregroundStyle(DSColors.Preview.accent)
                Text(title)
                    .font(DSTypography.displaySmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text("Coming in the next step")
                    .font(DSTypography.bodyMedium)
                    .foregroundStyle(DSColors.Preview.textSecondary)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
        .modelContainer(for: [SavedPalette.self, SavedColor.self], inMemory: true)
}
