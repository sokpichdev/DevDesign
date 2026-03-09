//
//  DecorationPreviewCanvas.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct DecorationPreviewCanvas: View {

    let tab: DecorationTab
    let shape: PreviewShape
    let cornerConfig: CornerConfig
    let borderConfig: BorderConfig
    let glowConfig: GlowConfig
    let patternConfig: PatternConfig
    let accentColor: Color

    var body: some View {
        ZStack {
            // Checkerboard background — helps see opacity/transparent effects
            checkerboard

            VStack {
                // The decorated shape
                decoratedShape
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: tab)
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Checkerboard
    private var checkerboard: some View {
        Canvas { ctx, size in
            let cell: CGFloat = 16
            for row in 0...Int(size.height / cell) {
                for col in 0...Int(size.width / cell) {
                    let x = CGFloat(col) * cell
                    let y = CGFloat(row) * cell
                    let isEven = (row + col) % 2 == 0
                    let rect = CGRect(x: x, y: y, width: cell, height: cell)
                    ctx.fill(Path(rect),
                             with: .color(isEven
                                          ? DSColors.Preview.backgroundSecondary
                                          : DSColors.Preview.backgroundTertiary))
                }
            }
        }
    }

    // MARK: - Decorated Shape
    @ViewBuilder
    private var decoratedShape: some View {
        let w = shape.size.width
        let h = shape.size.height

        switch tab {
        case .corners:
            corneredShape(w: w, h: h)

        case .borders:
            borderedShape(w: w, h: h)

        case .glow:
            glowedShape(w: w, h: h)

        case .patterns:
            patternedShape(w: w, h: h)
        }
    }

    // MARK: - Corners Preview
    @ViewBuilder
    private func corneredShape(w: CGFloat, h: CGFloat) -> some View {
        let fill = cornerConfig.fillColor
        let r = cornerConfig.perCorner ? cornerConfig.effectiveRadius : cornerConfig.radius

        ZStack {
            // Subtle content mockup inside
            shapeContent(w: w, h: h)
        }
        .frame(width: w, height: h)
        .background(fill)
        .modifier(CornerClipModifier(config: cornerConfig))
        .overlay(alignment: .bottomTrailing) {
            // Radius label
            Text("r: \(cornerConfig.perCorner ? "per-corner" : "\(Int(r))pt")")
                .font(DSTypography.codeMedium)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.black.opacity(0.3), in: Capsule())
                .padding(8)
        }
    }

    // MARK: - Borders Preview
    @ViewBuilder
    private func borderedShape(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            shapeContent(w: w, h: h)
        }
        .frame(width: w, height: h)
        .background(DSColors.Preview.surfaceDefault)
        .modifier(BorderApplyModifier(config: borderConfig))
    }

    // MARK: - Glow Preview
    @ViewBuilder
    private func glowedShape(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            shapeContent(w: w, h: h)
        }
        .frame(width: w, height: h)
        .background(glowConfig.fillColor)
        .clipShape(RoundedRectangle(cornerRadius: glowConfig.cornerRadius))
        .modifier(GlowApplyModifier(config: glowConfig))
    }

    // MARK: - Pattern Preview
    @ViewBuilder
    private func patternedShape(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // Base fill
            patternConfig.fillColor
            // Pattern overlay rendered via Canvas
            PatternOverlayView(config: patternConfig)
            // Content on top
            shapeContent(w: w, h: h)
                .opacity(0.4)
        }
        .frame(width: w, height: h)
        .clipShape(RoundedRectangle(cornerRadius: patternConfig.cornerRadius))
    }

    // MARK: - Shape interior mockup
    @ViewBuilder
    private func shapeContent(w: CGFloat, h: CGFloat) -> some View {
        switch shape {
        case .button:
            Text("Get Started")
                .font(DSTypography.headingSmall)
                .foregroundStyle(.white)
        case .avatar:
            Image(systemName: "person.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        case .card:
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white.opacity(0.3))
                    .frame(width: 80, height: 10)
                RoundedRectangle(cornerRadius: 3)
                    .fill(.white.opacity(0.2))
                    .frame(width: 120, height: 8)
                RoundedRectangle(cornerRadius: 3)
                    .fill(.white.opacity(0.2))
                    .frame(width: 100, height: 8)
            }
        case .rectangle:
            RoundedRectangle(cornerRadius: 4)
                .fill(.white.opacity(0.15))
                .frame(width: w * 0.6, height: h * 0.4)
        }
    }
}

// MARK: - Corner Clip Modifier

struct CornerClipModifier: ViewModifier {
    let config: CornerConfig

    func body(content: Content) -> some View {
        switch config.style {
        case .circular:
            content.clipShape(Capsule())
        case .rounded, .continuous:
            if config.perCorner {
                if #available(iOS 16.0, *) {
                    content.clipShape(UnevenRoundedRectangle(
                        topLeadingRadius:     config.topLeading,
                        bottomLeadingRadius:  config.bottomLeading,
                        bottomTrailingRadius: config.bottomTrailing,
                        topTrailingRadius:    config.topTrailing,
                        style: config.style == .continuous ? .continuous : .circular
                    ))
                } else {
                    content.clipShape(RoundedRectangle(cornerRadius: config.effectiveRadius))
                }
            } else {
                content.clipShape(RoundedRectangle(
                    cornerRadius: config.radius,
                    style: config.style == .continuous ? .continuous : .circular
                ))
            }
        case .cut:
            // Approximate chamfer with a large-corner RoundedRectangle
            content.clipShape(RoundedRectangle(cornerRadius: config.radius * 0.6))
        }
    }
}

// MARK: - Border Apply Modifier

struct BorderApplyModifier: ViewModifier {
    let config: BorderConfig

    func body(content: Content) -> some View {
        let r = config.cornerRadius
        Group {
            switch config.styleType {
            case .solid:
                content.overlay(
                    RoundedRectangle(cornerRadius: r)
                        .strokeBorder(config.color, lineWidth: config.width)
                        .opacity(config.opacity)
                )

            case .dashed:
                content.overlay(
                    RoundedRectangle(cornerRadius: r)
                        .strokeBorder(
                            config.color,
                            style: StrokeStyle(lineWidth: config.width,
                                              dash: [config.dashLength, config.dashGap])
                        )
                        .opacity(config.opacity)
                )

            case .dotted:
                content.overlay(
                    RoundedRectangle(cornerRadius: r)
                        .strokeBorder(
                            config.color,
                            style: StrokeStyle(lineWidth: config.width,
                                              lineCap: .round,
                                              dash: [0.1, config.dashGap + config.width])
                        )
                        .opacity(config.opacity)
                )

            case .double_:
                content
                    .overlay(
                        RoundedRectangle(cornerRadius: r)
                            .strokeBorder(config.color, lineWidth: config.doubleInnerWidth)
                    )
                    .padding(config.doubleGap)
                    .overlay(
                        RoundedRectangle(cornerRadius: max(0, r - config.doubleGap))
                            .strokeBorder(config.color, lineWidth: config.doubleInnerWidth)
                    )

            case .gradient:
                content.overlay(
                    RoundedRectangle(cornerRadius: r)
                        .strokeBorder(
                            LinearGradient(
                                colors: [config.gradientStart, config.gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: config.width
                        )
                )

            case .innerStroke:
                content.overlay(
                    RoundedRectangle(cornerRadius: r)
                        .stroke(config.color, lineWidth: config.width * 2)
                        .clipShape(RoundedRectangle(cornerRadius: r))
                        .opacity(config.opacity)
                )
            }
        }
    }
}

// MARK: - Glow Apply Modifier

struct GlowApplyModifier: ViewModifier {
    let config: GlowConfig

    func body(content: Content) -> some View {
        switch config.type {
        case .outer, .coloredShadow:
            content.shadow(
                color: config.color.opacity(config.opacity),
                radius: config.radius,
                x: config.offsetX,
                y: config.offsetY
            )

        case .inner:
            content.overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .stroke(config.color.opacity(config.opacity),
                            lineWidth: config.radius * 0.5)
                    .blur(radius: config.radius * 0.4)
                    .blendMode(.plusLighter)
            )
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))

        case .neon:
            content
                .shadow(color: config.color, radius: config.radius * 0.3, x: 0, y: 0)
                .shadow(color: config.color.opacity(0.5), radius: config.radius, x: 0, y: 0)
                .shadow(color: config.color.opacity(0.25), radius: config.radius * 2, x: 0, y: 0)

        case .layered:
            content
                .shadow(color: config.color.opacity(config.opacity),
                        radius: config.radius * 0.5, x: 0, y: 0)
                .shadow(color: config.color.opacity(config.opacity * 0.6),
                        radius: config.radius, x: 0, y: 0)
                .shadow(color: config.color.opacity(config.opacity * 0.3),
                        radius: config.radius * 2, x: 0, y: 0)
        }
    }
}

// MARK: - Pattern Overlay View (Canvas)

struct PatternOverlayView: View {
    let config: PatternConfig

    var body: some View {
        Canvas { ctx, size in
            switch config.patternType {
            case .grid:       drawGrid(ctx: ctx, size: size)
            case .dots:       drawDots(ctx: ctx, size: size)
            case .stripes:    drawStripes(ctx: ctx, size: size)
            case .crosshatch: drawCrosshatch(ctx: ctx, size: size)
            case .noise:      drawNoise(ctx: ctx, size: size)
            case .hexagons:   drawHexagons(ctx: ctx, size: size)
            }
        }
    }

    private var drawColor: GraphicsContext.Shading {
        .color(config.color.opacity(config.opacity))
    }

    private func drawGrid(ctx: GraphicsContext, size: CGSize) {
        let step = config.scale
        for x in stride(from: CGFloat(0), through: size.width, by: step) {
            var p = Path(); p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height))
            ctx.stroke(p, with: drawColor, lineWidth: config.lineWidth)
        }
        for y in stride(from: CGFloat(0), through: size.height, by: step) {
            var p = Path(); p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y))
            ctx.stroke(p, with: drawColor, lineWidth: config.lineWidth)
        }
    }

    private func drawDots(ctx: GraphicsContext, size: CGSize) {
        let spacing = config.scale
        let r = config.lineWidth + 1
        for x in stride(from: spacing / 2, through: size.width, by: spacing) {
            for y in stride(from: spacing / 2, through: size.height, by: spacing) {
                let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                ctx.fill(Path(ellipseIn: rect), with: drawColor)
            }
        }
    }

    private func drawStripes(ctx: GraphicsContext, size: CGSize) {
        var ctx2 = ctx
        ctx2.translateBy(x: size.width / 2, y: size.height / 2)
        ctx2.rotate(by: .degrees(config.rotation))
        ctx2.translateBy(x: -size.width / 2, y: -size.height / 2)
        let step = config.scale
        let ext = max(size.width, size.height) * 1.5
        var path = Path()
        var x: CGFloat = -ext
        while x < ext * 2 {
            path.move(to: CGPoint(x: x, y: -ext))
            path.addLine(to: CGPoint(x: x, y: ext * 2))
            x += step
        }
        ctx2.stroke(path, with: drawColor, lineWidth: config.lineWidth)
    }

    private func drawCrosshatch(ctx: GraphicsContext, size: CGSize) {
        var p1 = config; p1.rotation = 45
        var p2 = config; p2.rotation = -45
        drawStripes(ctx: ctx, size: size)
        var ctx2 = ctx
        ctx2.translateBy(x: size.width / 2, y: size.height / 2)
        ctx2.rotate(by: .degrees(-config.rotation - 45))
        ctx2.translateBy(x: -size.width / 2, y: -size.height / 2)
        let step = config.scale
        let ext = max(size.width, size.height) * 1.5
        var path = Path()
        var x: CGFloat = -ext
        while x < ext * 2 {
            path.move(to: CGPoint(x: x, y: -ext))
            path.addLine(to: CGPoint(x: x, y: ext * 2))
            x += step
        }
        ctx2.stroke(path, with: drawColor, lineWidth: config.lineWidth)
    }

    private func drawNoise(ctx: GraphicsContext, size: CGSize) {
        // Lightweight deterministic noise via pseudo-random rects
        var seed: UInt64 = 0xDEADBEEF
        func nextFloat() -> CGFloat {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return CGFloat((seed >> 33) & 0xFFFF) / 65535
        }
        let density = 600
        for _ in 0..<density {
            let x = nextFloat() * size.width
            let y = nextFloat() * size.height
            let s = nextFloat() * 3 + 1
            let rect = CGRect(x: x, y: y, width: s, height: s)
            ctx.fill(Path(ellipseIn: rect), with: drawColor)
        }
    }

    private func drawHexagons(ctx: GraphicsContext, size: CGSize) {
        let r = config.scale
        let w = r * 2
        let h = r * sqrt(3)
        var row = 0
        var y: CGFloat = 0
        while y < size.height + r {
            let offset: CGFloat = (row % 2 == 0) ? 0 : r * 1.5
            var x: CGFloat = offset
            while x < size.width + r {
                var hex = Path()
                for i in 0..<6 {
                    let angle = CGFloat(i) * CGFloat.pi / 3 - CGFloat.pi / 6
                    let px = x + r * cos(angle)
                    let py = y + r * sin(angle)
                    if i == 0 { hex.move(to: CGPoint(x: px, y: py)) }
                    else       { hex.addLine(to: CGPoint(x: px, y: py)) }
                }
                hex.closeSubpath()
                ctx.stroke(hex, with: drawColor, lineWidth: config.lineWidth)
                x += w * 0.75
            }
            y += h * 0.5
            row += 1
        }
    }
}
