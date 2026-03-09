//
//  AnimationCurveView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct AnimationCurveView: View {

    let config: AnimationConfig
    let isAnimating: Bool
    let accentColor: Color

    // Layout
    private let pad: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width  - pad * 2
            let h = geo.size.height - pad * 2

            let points = AnimationExportService.curvePoints(config)
            let minV   = points.map(\.v).min() ?? 0
            let maxV   = points.map(\.v).max() ?? 1
            let vRange = max(maxV - minV, 1e-6)

            ZStack(alignment: .topLeading) {

                // ── Grid lines ───────────────────────────────────────
                gridLines(w: w, h: h)
                    .offset(x: pad, y: pad)

                // ── Axis labels ──────────────────────────────────────
                axisLabels(w: w, h: h)

                // ── Curve fill ───────────────────────────────────────
                curveFill(points: points, w: w, h: h,
                          minV: minV, vRange: vRange)
                    .offset(x: pad, y: pad)

                // ── Curve stroke ─────────────────────────────────────
                curveStroke(points: points, w: w, h: h,
                            minV: minV, vRange: vRange)
                    .offset(x: pad, y: pad)

                // ── Bezier control handles (timingCurve only) ────────
                if config.type == .timingCurve {
                    bezierHandles(w: w, h: h)
                        .offset(x: pad, y: pad)
                }

                // ── Animated dot ─────────────────────────────────────
                animatedDot(points: points, w: w, h: h,
                            minV: minV, vRange: vRange)
                    .offset(x: pad, y: pad)
            }
        }
        .background(DSColors.Preview.backgroundSecondary,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Grid
    private func gridLines(w: CGFloat, h: CGFloat) -> some View {
        Canvas { ctx, size in
            // Horizontal guides at 0, 0.25, 0.5, 0.75, 1.0
            for frac in stride(from: 0.0, through: 1.0, by: 0.25) {
                let y = h * (1 - frac)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: w, y: y))
                ctx.stroke(path,
                           with: .color(DSColors.Preview.borderSubtle.opacity(frac == 0 || frac == 1 ? 0.8 : 0.4)),
                           style: StrokeStyle(lineWidth: frac == 0 || frac == 1 ? 1 : 0.5,
                                             dash: frac == 0 || frac == 1 ? [] : [3, 3]))
            }
            // Vertical guide at t = 0.5
            var vPath = Path()
            vPath.move(to: CGPoint(x: w * 0.5, y: 0))
            vPath.addLine(to: CGPoint(x: w * 0.5, y: h))
            ctx.stroke(vPath, with: .color(DSColors.Preview.borderSubtle.opacity(0.3)),
                       style: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Axis Labels
    private func axisLabels(w: CGFloat, h: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Y axis
            ForEach(["1.0", "0.5", "0.0"], id: \.self) { label in
                let frac: CGFloat = label == "1.0" ? 0 : (label == "0.5" ? 0.5 : 1.0)
                Text(label)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .offset(x: 2, y: pad + h * frac - 6)
            }
            // X axis
            ForEach(["0", "0.5", "1"], id: \.self) { label in
                let frac: CGFloat = label == "0" ? 0 : (label == "0.5" ? 0.5 : 1.0)
                Text(label)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .offset(x: pad + w * frac - 4, y: pad + h + 2)
            }
            // Axis name labels
            Text("value")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(DSColors.Preview.textTertiary.opacity(0.6))
                .rotationEffect(.degrees(-90))
                .offset(x: -6, y: pad + h * 0.5)
            Text("time →")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(DSColors.Preview.textTertiary.opacity(0.6))
                .offset(x: pad + w - 30, y: pad + h + 12)
        }
    }

    // MARK: - Curve Fill
    private func curveFill(points: [CurvePoint], w: CGFloat, h: CGFloat,
                           minV: Double, vRange: Double) -> some View {
        Canvas { ctx, _ in
            guard points.count > 1 else { return }
            var path = Path()
            let first = cgPoint(points[0], w: w, h: h, minV: minV, vRange: vRange)
            path.move(to: CGPoint(x: first.x, y: h))
            path.addLine(to: first)
            for p in points.dropFirst() {
                path.addLine(to: cgPoint(p, w: w, h: h, minV: minV, vRange: vRange))
            }
            let last = cgPoint(points.last!, w: w, h: h, minV: minV, vRange: vRange)
            path.addLine(to: CGPoint(x: last.x, y: h))
            path.closeSubpath()
            ctx.fill(path, with: .color(accentColor.opacity(0.08)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Curve Stroke
    private func curveStroke(points: [CurvePoint], w: CGFloat, h: CGFloat,
                             minV: Double, vRange: Double) -> some View {
        Canvas { ctx, _ in
            guard points.count > 1 else { return }
            var path = Path()
            path.move(to: cgPoint(points[0], w: w, h: h, minV: minV, vRange: vRange))
            for p in points.dropFirst() {
                path.addLine(to: cgPoint(p, w: w, h: h, minV: minV, vRange: vRange))
            }
            ctx.stroke(path,
                       with: .color(accentColor),
                       style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bezier handles (timing curve)
    private func bezierHandles(w: CGFloat, h: CGFloat) -> some View {
        Canvas { ctx, _ in
            let p0 = CGPoint(x: 0,             y: h)
            let p1 = CGPoint(x: config.c0x * w, y: h - config.c0y * h)
            let p2 = CGPoint(x: config.c1x * w, y: h - config.c1y * h)
            let p3 = CGPoint(x: w,             y: 0)

            // Handle lines
            for (a, b) in [(p0, p1), (p3, p2)] {
                var line = Path()
                line.move(to: a)
                line.addLine(to: b)
                ctx.stroke(line, with: .color(accentColor.opacity(0.5)),
                           style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
            }
            // Control point dots
            for pt in [p1, p2] {
                let r: CGFloat = 5
                let rect = CGRect(x: pt.x - r, y: pt.y - r, width: r*2, height: r*2)
                ctx.fill(Path(ellipseIn: rect), with: .color(accentColor))
                ctx.stroke(Path(ellipseIn: rect), with: .color(.white), lineWidth: 1.5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Animated dot
    private func animatedDot(points: [CurvePoint], w: CGFloat, h: CGFloat,
                             minV: Double, vRange: Double) -> some View {
        let t: Double = isAnimating ? 1.0 : 0.0
        let clampedT = max(0, min(1, t))
        // find closest point
        let idx = Int(clampedT * Double(points.count - 1))
        let pt  = points[min(idx, points.count - 1)]
        let pos = cgPoint(pt, w: w, h: h, minV: minV, vRange: vRange)

        return Circle()
            .fill(accentColor)
            .frame(width: 10, height: 10)
            .overlay(Circle().strokeBorder(.white, lineWidth: 1.5))
            .shadow(color: accentColor.opacity(0.5), radius: 4, x: 0, y: 0)
            .offset(x: pos.x - 5, y: pos.y - 5)
            .animation(config.swiftUIAnimation, value: isAnimating)
    }

    // MARK: - Helpers
    private func cgPoint(_ p: CurvePoint, w: CGFloat, h: CGFloat,
                         minV: Double, vRange: Double) -> CGPoint {
        let x = CGFloat(p.t) * w
        let normalised = (p.v - minV) / vRange
        let y = h - CGFloat(normalised) * h
        return CGPoint(x: x, y: y)
    }
}
