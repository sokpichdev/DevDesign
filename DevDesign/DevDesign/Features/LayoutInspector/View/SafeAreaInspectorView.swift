//
//  SafeAreaInspectorView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct SafeAreaInspectorView: View {

    @State private var selectedItem: SafeAreaItem? = nil
    @State private var showingPortrait = true

    // Common screen sizes
    private let screens: [(name: String, w: CGFloat, h: CGFloat)] = [
        ("SE 3rd Gen",  375, 667),
        ("iPhone 15",   390, 844),
        ("15 Pro Max",  430, 932),
    ]
    @State private var selectedScreen = 1   // iPhone 15

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: DSSpacing.md) {

                // Screen model picker
                screenPicker

                // iPhone diagram
                phoneDiagram

                // Legend
                legendCard

                // Spacing reference card
                spacingReferenceCard

                Spacer(minLength: DSSpacing.xxxl)
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.top, DSSpacing.md)
        }
    }

    // MARK: - Screen Picker
    private var screenPicker: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(screens.indices, id: \.self) { i in
                let isSelected = selectedScreen == i
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedScreen = i
                    }
                } label: {
                    Text(screens[i].name)
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.xs)
                        .background(
                            isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceDefault,
                            in: Capsule()
                        )
                        .overlay(
                            Capsule().strokeBorder(
                                isSelected ? Color.clear : DSColors.Preview.borderSubtle,
                                lineWidth: 1
                            )
                        )
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
            }
        }
    }

    // MARK: - Phone Diagram
    private var phoneDiagram: some View {
        let screen = screens[selectedScreen]
        let scale: CGFloat = 0.52
        let phoneW = screen.w * scale
        let phoneH = screen.h * scale
        // selectedScreen == 0 → SE 3rd Gen: has home button, no Dynamic Island
        let isSE = selectedScreen == 0

        // Safe area values (points, scaled)
        // On Dynamic Island devices, status bar (~54pt) INCLUDES the Dynamic Island space
        // On SE devices, status bar is ~20pt with no Dynamic Island
        let statusH: CGFloat = (isSE ? 20 : 54) * scale
        let navH:    CGFloat = 44 * scale
        let tabH:    CGFloat = 49 * scale
        // Bottom safe area: 34pt for Face ID (home indicator clearance), 0pt for SE
        let bottomSafeH: CGFloat = isSE ? 0 : 34 * scale
        // SE has 44pt physical home button area at bottom
        let homeButtonH: CGFloat = isSE ? 44 * scale : 0
        // Total bottom area: tab bar extends to edge, but content needs safe area clearance
        let bottomAreaH: CGFloat = tabH + (isSE ? homeButtonH : 0)
        let contentH: CGFloat = max(phoneH - statusH - navH - bottomAreaH, 40)

        return VStack(spacing: DSSpacing.sm) {
            HStack {
                Text(screen.name + " · \(Int(screen.w))×\(Int(screen.h))pt")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                Spacer()
            }
            .padding(.horizontal, DSSpacing.xxs)

            ZStack(alignment: .top) {
                // Phone shell — SE has smaller corner radius (home button era)
                RoundedRectangle(cornerRadius: (isSE ? 30 : 44) * scale)
                    .fill(DSColors.Preview.backgroundTertiary)
                    .frame(width: phoneW + 14, height: phoneH + 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: (isSE ? 30 : 44) * scale)
                            .strokeBorder(DSColors.Preview.textTertiary.opacity(0.4), lineWidth: 2)
                    )

                // Screen content
                VStack(spacing: 0) {
                    
                    // Status bar zone with Dynamic Island overlay
                    ZStack {
                        Color(hex: "#FF6B6B").opacity(0.22)
                        
                        // Dynamic Island pill (only on non-SE devices) - centered in status bar
                        if !isSE {
                            Capsule()
                                .fill(DSColors.Preview.backgroundPrimary)
                                .frame(width: 80 * scale, height: 24 * scale)
                        } else {
                            // SE: small speaker slit at top
                            Capsule()
                                .fill(DSColors.Preview.backgroundPrimary.opacity(0.6))
                                .frame(width: 44 * scale, height: 6 * scale)
                                .offset(y: 4 * scale)
                        }
                        
                        // Status bar label
                        HStack {
                            Text("Status Bar")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Color(hex: "#FF6B6B"))
                            Spacer()
                            Text(isSE ? "20pt" : "54pt")
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color(hex: "#FF6B6B").opacity(0.8))
                        }
                        .padding(.horizontal, 8)
                    }
                    .frame(height: statusH)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color(hex: "#FF6B6B").opacity(0.4))
                            .frame(height: 1)
                    }

                    // Nav bar zone
                    zoneBar(
                        "Nav Bar",
                        height: navH,
                        color: Color(hex: "#FF9F0A"),
                        label2: "44pt"
                    )

                    // Content zone
                    ZStack {
                        Color(hex: "#30D158").opacity(0.18)
                        VStack(spacing: 4) {
                            Text("Content Area")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color(hex: "#30D158"))
                            Text("~\(Int(contentH / scale))pt")
                                .font(.system(size: 8))
                                .foregroundStyle(Color(hex: "#30D158").opacity(0.8))
                            
                            // Show bottom safe area note for Face ID devices
                            if !isSE {
                                Text("(+34pt bottom safe area)")
                                    .font(.system(size: 7))
                                    .foregroundStyle(Color(hex: "#30D158").opacity(0.6))
                            }
                        }
                    }
                    .frame(height: contentH)

                    // Tab bar zone - extends to bottom edge on Face ID devices
                    ZStack(alignment: .bottom) {
                        Color(hex: "#7B6EF6").opacity(0.22)
                        
                        // Tab bar label at top of zone
                        HStack {
                            Text("Tab Bar")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Color(hex: "#7B6EF6"))
                            Spacer()
                            Text("49pt")
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color(hex: "#7B6EF6").opacity(0.8))
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                        .frame(maxHeight: .infinity, alignment: .top)
                        
                        // Visual indicator for home indicator area on Face ID devices
                        if !isSE {
                            VStack(spacing: 0) {
                                Spacer()
                                // Thin home indicator line
                                RoundedRectangle(cornerRadius: 2 * scale)
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 120 * scale, height: 4 * scale)
                                    .padding(.bottom, 8 * scale)
                            }
                        }
                    }
                    .frame(height: tabH)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Color(hex: "#7B6EF6").opacity(0.4))
                            .frame(height: 1)
                    }

                    // SE: physical home button area below tab bar
                    if isSE {
                        ZStack {
                            DSColors.Preview.backgroundSecondary
                            Circle()
                                .strokeBorder(DSColors.Preview.textTertiary.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 28 * scale, height: 28 * scale)
                        }
                        .frame(height: homeButtonH)
                    }
                }
                .frame(width: phoneW, height: phoneH)
                .clipShape(RoundedRectangle(cornerRadius: (isSE ? 28 : 40) * scale))
                .padding(.top, 10) // Center screen within phone shell
            }
            .frame(height: phoneH + 20)
        }
    }

    private func zoneBar(_ label: String, height: CGFloat, color: Color, label2: String) -> some View {
        ZStack {
            color.opacity(0.22)
            HStack {
                Text(label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(color)
                Spacer()
                Text(label2)
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(color.opacity(0.8))
            }
            .padding(.horizontal, 8)
        }
        .frame(height: height)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(height: 1)
        }
    }

    // MARK: - Legend
    private var legendCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(safeAreaGuides.enumerated()), id: \.element.id) { i, item in
                HStack(spacing: DSSpacing.sm) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(item.color)
                        .frame(width: 14, height: 14)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.label)
                            .font(DSTypography.labelLarge)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                        Text(item.description)
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    Spacer()
                }
                .padding(DSSpacing.sm)
                if i < safeAreaGuides.count - 1 {
                    Divider().background(DSColors.Preview.borderSubtle)
                }
            }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Spacing Reference
    private var spacingReferenceCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("iOS Spacing Reference")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(.horizontal, DSSpacing.xxs)

            VStack(spacing: 0) {
                ForEach(Array(spacingRef.enumerated()), id: \.offset) { i, row in
                    HStack(spacing: DSSpacing.sm) {
                        Text(row.0)
                            .font(DSTypography.labelLarge)
                            .foregroundStyle(DSColors.Preview.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(row.1)
                            .font(DSTypography.codeMedium)
                            .foregroundStyle(DSColors.Preview.accent)

                        // Visual bar
                        let frac = min(CGFloat(row.2) / 96, 1)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(DSColors.Preview.backgroundTertiary)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(DSColors.Preview.accent.opacity(0.6))
                                    .frame(width: geo.size.width * frac)
                            }
                        }
                        .frame(width: 80, height: 6)
                    }
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 10)
                    if i < spacingRef.count - 1 {
                        Divider().background(DSColors.Preview.borderSubtle)
                    }
                }
            }
            .background(DSColors.Preview.surfaceDefault,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
        }
    }

    private let spacingRef: [(String, String, Int)] = [
        ("Screen horizontal margin", "16pt",  16),
        ("Card padding",             "16pt",  16),
        ("List row height (min)",    "44pt",  44),
        ("Nav bar height",           "44pt",  44),
        ("Tab bar height",           "49pt",  49),
        ("Touch target (min)",       "44pt",  44),
        ("Icon size (small)",        "24pt",  24),
        ("Icon size (medium)",       "28pt",  28),
        ("Corner radius (card)",     "12pt",  12),
        ("Corner radius (sheet)",    "20pt",  20),
    ]
}
