//
//  AppIconCanvasView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//
// This view is used both for on-screen preview AND as the
// ImageRenderer source for PNG export — keep it side-effect free.

import SwiftUI

struct AppIconCanvasView: View {

    let config: AppIconConfig
    let size: CGFloat
    var showCornerRadius: Bool = true   // false when rendering raw PNG (Xcode applies its own mask)

    private var cornerRadius: CGFloat {
        showCornerRadius ? size * config.customCornerFraction : 0
    }

    var body: some View {
        ZStack {
            // ── Background ──────────────────────────────────────────
            background

            // ── Mesh accent circles (decorative) ────────────────────
            if config.backgroundStyle == .mesh {
                meshLayer
            }

            // ── Content ─────────────────────────────────────────────
            content
                .offset(
                    x: size * config.contentOffsetX,
                    y: size * config.contentOffsetY
                )
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(
            color: .black.opacity(config.showShadow ? config.shadowOpacity : 0),
            radius: size * 0.06,
            x: 0,
            y: size * 0.04
        )
    }

    // MARK: - Background
    @ViewBuilder
    private var background: some View {
        switch config.backgroundStyle {
        case .solid:
            config.backgroundColor

        case .gradient, .mesh:
            Rectangle()
                .fill(config.gradientDirection.gradient(
                    from: config.backgroundColor,
                    to: config.gradientEndColor,
                    size: size
                ))
        }
    }

    // MARK: - Mesh layer
    private var meshLayer: some View {
        ZStack {
            Circle()
                .fill(config.meshAccentColor.opacity(0.25))
                .frame(width: size * 0.9, height: size * 0.9)
                .offset(x: -size * 0.15, y: -size * 0.15)
            Circle()
                .fill(config.meshAccentColor.opacity(0.15))
                .frame(width: size * 0.7, height: size * 0.7)
                .offset(x: size * 0.2, y: size * 0.2)
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: size * 0.5, height: size * 0.5)
                .offset(x: size * 0.1, y: -size * 0.25)
        }
        .blur(radius: size * 0.04)
        .clipped()
    }

    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        let contentSize = size * config.contentScale

        switch config.contentType {

        case .symbol:
            Image(systemName: config.symbolName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(config.contentColor)
                .frame(width: contentSize, height: contentSize)
                .fontWeight(.semibold)

        case .initials:
            Text(config.initialsText.prefix(3).uppercased())
                .font(.system(
                    size: contentSize * (config.initialsText.count > 2 ? 0.30 : 0.42),
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundStyle(config.contentColor)
                .minimumScaleFactor(0.1)
                .lineLimit(1)

        case .emoji:
            Text(String(config.emojiText.prefix(1)))
                .font(.system(size: contentSize * 0.85))
                .minimumScaleFactor(0.1)
                .lineLimit(1)
        }
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 16) {
        AppIconCanvasView(config: AppIconConfig(), size: 120)
        AppIconCanvasView(config: {
            var c = AppIconConfig()
            c.contentType = .initials
            c.initialsText = "DD"
            c.backgroundStyle = .mesh
            c.backgroundColor = Color(hex: "#FF6B6B")
            c.gradientEndColor = Color(hex: "#FF9F0A")
            return c
        }(), size: 120)
        AppIconCanvasView(config: {
            var c = AppIconConfig()
            c.contentType = .emoji
            c.emojiText = "🎨"
            c.backgroundStyle = .solid
            c.backgroundColor = Color(hex: "#1C1C1E")
            return c
        }(), size: 120)
    }
    .padding()
}
