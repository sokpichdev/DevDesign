//
//  ShadowPreviewCard.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Renders the live shadow preview for all four targets.
// Outer shadows applied via .shadow() chain.
// Inner shadows simulated via overlay + blur + mask technique.

import SwiftUI

// MARK: - Shadow Preview Container

struct ShadowPreviewCard: View {

    let layers: [ShadowLayer]
    let target: ShadowPreviewTarget
    let isDark: Bool
    var onToggleDark: () -> Void

    var body: some View {
        ZStack {
            // Checkerboard to make transparency obvious
            checkerboard

            // Actual preview target
            Group {
                switch target {
                case .card:   cardPreview
                case .text:   textPreview
                case .button: buttonPreview
                case .circle: circlePreview
                }
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) { darkToggle }
    }

    // MARK: - Background
    private var checkerboard: some View {
        Rectangle()
            .fill(isDark
                  ? Color(white: 0.12)
                  : Color(white: 0.92))
            .animation(.easeInOut(duration: 0.25), value: isDark)
    }

    // MARK: - Dark Toggle
    private var darkToggle: some View {
        Button(action: onToggleDark) {
            Image(systemName: isDark ? "sun.max" : "moon.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isDark ? .white : .black)
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .padding(DSSpacing.sm)
    }

    // MARK: - Card Preview
    private var cardPreview: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(isDark ? Color(white: 0.22) : .white)
            .frame(width: 180, height: 110)
            .overlay(
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DSColors.Preview.accent.opacity(0.3))
                        .frame(width: 120, height: 12)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.12))
                        .frame(width: 90, height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 100, height: 8)
                }
            )
            .modifier(ShadowStackModifier(layers: layers, cornerRadius: 16))
    }

    // MARK: - Text Preview
    private var textPreview: some View {
        VStack(spacing: 8) {
            Text("DevDesign")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(isDark ? .white : .black)
                .modifier(TextShadowModifier(layers: layers.filter { !$0.isInner }))

            Text("Shadow Playground")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isDark ? Color(white: 0.7) : Color(white: 0.3))
                .modifier(TextShadowModifier(layers: layers.filter { !$0.isInner }))
        }
    }

    // MARK: - Button Preview
    private var buttonPreview: some View {
        Capsule()
            .fill(DSColors.Preview.accent)
            .frame(width: 160, height: 50)
            .overlay(
                Text("Get Started")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            )
            .modifier(ShadowStackModifier(layers: layers, cornerRadius: 25))
    }

    // MARK: - Circle Preview
    private var circlePreview: some View {
        Circle()
            .fill(isDark ? Color(white: 0.22) : .white)
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "star.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(DSColors.Preview.accent)
            )
            .modifier(ShadowStackModifier(layers: layers, cornerRadius: 50))
    }
}

// MARK: - Shadow Stack Modifier
// Applies all enabled outer .shadow() layers, then overlays inner shadows.

struct ShadowStackModifier: ViewModifier {
    let layers: [ShadowLayer]
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let outer = layers.filter { $0.isEnabled && !$0.isInner }
        let inner = layers.filter { $0.isEnabled && $0.isInner }

        var view = AnyView(content)

        // Apply outer shadows — each .shadow() stacks additively in SwiftUI
        for layer in outer {
            view = AnyView(
                view.shadow(
                    color: layer.color.opacity(layer.opacity),
                    radius: max(0, layer.blur / 2),
                    x: layer.x,
                    y: layer.y
                )
            )
        }

        // Apply inner shadows as overlays
        for layer in inner {
            view = AnyView(view.innerShadowOverlay(layer: layer, cornerRadius: cornerRadius))
        }

        return view
    }
}

// MARK: - Inner Shadow Overlay Extension

extension View {
    func innerShadowOverlay(layer: ShadowLayer, cornerRadius: CGFloat) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    layer.color.opacity(layer.opacity),
                    lineWidth: max(1, layer.blur)
                )
                .blur(radius: layer.blur / 2)
                .offset(x: layer.x, y: layer.y)
                .clipped()
                .allowsHitTesting(false)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Text Shadow Modifier

struct TextShadowModifier: ViewModifier {
    let layers: [ShadowLayer]

    func body(content: Content) -> some View {
        var view = AnyView(content)
        for layer in layers where layer.isEnabled {
            view = AnyView(
                view.shadow(
                    color: layer.color.opacity(layer.opacity),
                    radius: max(0, layer.blur / 2),
                    x: layer.x,
                    y: layer.y
                )
            )
        }
        return view
    }
}
