//
//  AnimationCategory.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

// MARK: - Animation Category

enum AnimationCategory: String, CaseIterable, Identifiable {
    case spring   = "Spring"
    case easing   = "Easing"
    case timing   = "Timing"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .spring: return "waveform.path"
        case .easing: return "chart.line.uptrend.xyaxis"
        case .timing: return "timer"
        }
    }
}

// MARK: - Animation Type

enum AnimationType: String, CaseIterable, Identifiable {
    // Spring family
    case spring        = "spring"
    case interactiveSpring = "interactiveSpring"
    case bouncy        = "bouncy"
    case smooth        = "smooth"
    case snappy        = "snappy"
    // Easing family
    case easeInOut     = "easeInOut"
    case easeIn        = "easeIn"
    case easeOut       = "easeOut"
    case linear        = "linear"
    // Timing
    case timingCurve   = "timingCurve"

    var id: String { rawValue }

    var category: AnimationCategory {
        switch self {
        case .spring, .interactiveSpring, .bouncy, .smooth, .snappy: return .spring
        case .easeInOut, .easeIn, .easeOut, .linear:                  return .easing
        case .timingCurve:                                             return .timing
        }
    }

    var label: String {
        switch self {
        case .spring:            return ".spring()"
        case .interactiveSpring: return ".interactiveSpring()"
        case .bouncy:            return ".bouncy()"
        case .smooth:            return ".smooth()"
        case .snappy:            return ".snappy()"
        case .easeInOut:         return ".easeInOut()"
        case .easeIn:            return ".easeIn()"
        case .easeOut:           return ".easeOut()"
        case .linear:            return ".linear()"
        case .timingCurve:       return ".timingCurve()"
        }
    }

    var icon: String {
        switch self {
        case .spring, .interactiveSpring: return "waveform.path"
        case .bouncy:                      return "waveform.badge.exclamationmark"
        case .smooth:                      return "waveform"
        case .snappy:                      return "bolt"
        case .easeInOut:                   return "chart.line.uptrend.xyaxis"
        case .easeIn:                      return "chart.bar.xaxis"
        case .easeOut:                     return "chart.bar.xaxis.ascending"
        case .linear:                      return "minus"
        case .timingCurve:                 return "point.topleft.down.to.point.bottomright.curvepath"
        }
    }

    var description: String {
        switch self {
        case .spring:            return "Physics-based spring with response + dampingFraction"
        case .interactiveSpring: return "Spring that feels directly driven by user input"
        case .bouncy:            return "Visually bouncy spring with configurable extra bounce"
        case .smooth:            return "Critically damped spring — no oscillation, just smooth"
        case .snappy:            return "Stiff spring that settles quickly with slight overshoot"
        case .easeInOut:         return "Slow start, full speed in middle, slow end"
        case .easeIn:            return "Slow start, fast end — good for exits"
        case .easeOut:           return "Fast start, slow end — good for entrances"
        case .linear:            return "Constant velocity throughout — mechanical feel"
        case .timingCurve:       return "Custom cubic Bézier control points"
        }
    }
}

// MARK: - Animation Config

struct AnimationConfig: Equatable {
    var type: AnimationType           = .spring
    var duration: Double              = 0.5
    // Spring params
    var response: Double              = 0.55
    var dampingFraction: Double       = 0.825
    var blendDuration: Double         = 0.0
    var bounce: Double                = 0.25      // for .bouncy
    // Timing curve (cubic bezier)
    var c0x: Double                   = 0.42
    var c0y: Double                   = 0.0
    var c1x: Double                   = 0.58
    var c1y: Double                   = 1.0
    // Repeat
    var repeatCount: Int              = 1         // 1 = once, 0 = forever
    var autoreverses: Bool            = false
    var delay: Double                 = 0.0

    var swiftUIAnimation: Animation {
        var base: Animation
        switch type {
        case .spring:
            base = .spring(response: response,
                           dampingFraction: dampingFraction,
                           blendDuration: blendDuration)
        case .interactiveSpring:
            base = .interactiveSpring(response: response,
                                      dampingFraction: dampingFraction,
                                      blendDuration: blendDuration)
        case .bouncy:
            if #available(iOS 17.0, *) {
                base = .bouncy(duration: duration, extraBounce: bounce)
            } else {
                base = .spring(response: response, dampingFraction: max(0.3, dampingFraction - 0.3))
            }
        case .smooth:
            if #available(iOS 17.0, *) {
                base = .smooth(duration: duration, extraBounce: 0)
            } else {
                base = .spring(response: response, dampingFraction: 1.0)
            }
        case .snappy:
            if #available(iOS 17.0, *) {
                base = .snappy(duration: duration, extraBounce: bounce * 0.5)
            } else {
                base = .spring(response: response * 0.6, dampingFraction: dampingFraction)
            }
        case .easeInOut:
            base = .easeInOut(duration: duration)
        case .easeIn:
            base = .easeIn(duration: duration)
        case .easeOut:
            base = .easeOut(duration: duration)
        case .linear:
            base = .linear(duration: duration)
        case .timingCurve:
            base = .timingCurve(c0x, c0y, c1x, c1y, duration: duration)
        }

        if delay > 0 { base = base.delay(delay) }
        if repeatCount == 0 {
            base = base.repeatForever(autoreverses: autoreverses)
        } else if repeatCount > 1 {
            base = base.repeatCount(repeatCount, autoreverses: autoreverses)
        }
        return base
    }
}

// MARK: - Preview Target

enum AnimationPreviewTarget: String, CaseIterable, Identifiable {
    case slide   = "Slide"
    case scale   = "Scale"
    case fade    = "Fade"
    case rotate  = "Rotate"
    case bounce  = "Bounce"
    case morph   = "Morph"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .slide:  return "arrow.right"
        case .scale:  return "arrow.up.left.and.arrow.down.right"
        case .fade:   return "circle.lefthalf.filled"
        case .rotate: return "arrow.clockwise"
        case .bounce: return "arrow.up"
        case .morph:  return "square.on.circle"
        }
    }
}

// MARK: - Preset

struct AnimationPreset: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let config: AnimationConfig
}

enum AnimationPresetLibrary {
    static let all: [AnimationPreset] = [
        AnimationPreset(name: "iOS Default", icon: "iphone",
                        description: "Apple's standard spring feel",
                        config: {
                            var c = AnimationConfig()
                            c.type = .spring; c.response = 0.55; c.dampingFraction = 0.825
                            return c
                        }()),
        AnimationPreset(name: "Bouncy Pop", icon: "waveform.badge.exclamationmark",
                        description: "Energetic pop with overshoot",
                        config: {
                            var c = AnimationConfig()
                            c.type = .bouncy; c.duration = 0.5; c.bounce = 0.35
                            return c
                        }()),
        AnimationPreset(name: "Snappy", icon: "bolt",
                        description: "Quick and decisive",
                        config: {
                            var c = AnimationConfig()
                            c.type = .snappy; c.duration = 0.3; c.bounce = 0.1
                            return c
                        }()),
        AnimationPreset(name: "Smooth Slide", icon: "arrow.right",
                        description: "Buttery smooth entrance",
                        config: {
                            var c = AnimationConfig()
                            c.type = .smooth; c.duration = 0.4
                            return c
                        }()),
        AnimationPreset(name: "Gentle Spring", icon: "waveform",
                        description: "Soft, relaxed spring",
                        config: {
                            var c = AnimationConfig()
                            c.type = .spring; c.response = 0.8; c.dampingFraction = 0.9
                            return c
                        }()),
        AnimationPreset(name: "Flubber", icon: "waveform.badge.exclamationmark",
                        description: "Wobbly, playful bounce",
                        config: {
                            var c = AnimationConfig()
                            c.type = .spring; c.response = 0.6; c.dampingFraction = 0.45
                            return c
                        }()),
        AnimationPreset(name: "Ease In Out", icon: "chart.line.uptrend.xyaxis",
                        description: "Classic UI transition",
                        config: {
                            var c = AnimationConfig()
                            c.type = .easeInOut; c.duration = 0.35
                            return c
                        }()),
        AnimationPreset(name: "Fast Exit", icon: "arrow.up.right",
                        description: "Quick ease-in for exits",
                        config: {
                            var c = AnimationConfig()
                            c.type = .easeIn; c.duration = 0.2
                            return c
                        }()),
    ]
}

// MARK: - Curve Visualiser Point

struct CurvePoint: Identifiable {
    let id = UUID()
    let t: Double   // 0…1 normalised time
    let v: Double   // 0…1 normalised value
}

// MARK: - Export Service

enum AnimationExportService {

    static func exportModifier(_ config: AnimationConfig, trigger: String = "isAnimating") -> String {
        let animCode = animationCode(config)
        return """
.animation(
    \(animCode),
    value: \(trigger)
)
"""
    }

    static func exportWithAnimation(_ config: AnimationConfig) -> String {
        let animCode = animationCode(config)
        return """
withAnimation(\(animCode)) {
    // mutate state here
    isAnimating.toggle()
}
"""
    }

    static func exportTransition(_ config: AnimationConfig,
                                  target: AnimationPreviewTarget) -> String {
        let animCode = animationCode(config)
        let transitionName: String
        switch target {
        case .slide:  transitionName = ".move(edge: .leading)"
        case .scale:  transitionName = ".scale"
        case .fade:   transitionName = ".opacity"
        case .rotate: transitionName = ".scale.combined(with: .opacity)"
        case .bounce: transitionName = ".move(edge: .bottom).combined(with: .opacity)"
        case .morph:  transitionName = ".asymmetric(insertion: .scale, removal: .opacity)"
        }
        return """
.transition(\(transitionName))
// Apply to parent:
.animation(\(animCode), value: isVisible)
"""
    }

    // MARK: - Curve points for visualiser (30 samples)
    static func curvePoints(_ config: AnimationConfig) -> [CurvePoint] {
        let samples = 60
        return (0...samples).map { i in
            let t = Double(i) / Double(samples)
            let v = evaluateCurve(t: t, config: config)
            return CurvePoint(t: t, v: v)
        }
    }

    // Approximate animation value at normalised time t
    static func evaluateCurve(t: Double, config: AnimationConfig) -> Double {
        switch config.type {
        case .linear:
            return t
        case .easeIn:
            return t * t * t
        case .easeOut:
            return 1 - pow(1 - t, 3)
        case .easeInOut:
            return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
        case .spring, .interactiveSpring:
            return springValue(t: t, response: config.response,
                               damping: config.dampingFraction)
        case .bouncy:
            return springValue(t: t, response: 0.55, damping: max(0.3, config.dampingFraction - config.bounce * 0.8))
        case .smooth:
            return 1 - pow(1 - t, 4)  // approx smooth
        case .snappy:
            return springValue(t: t, response: 0.38, damping: 0.78)
        case .timingCurve:
            return cubicBezier(t: t, p1x: config.c0x, p1y: config.c0y,
                               p2x: config.c1x, p2y: config.c1y)
        }
    }

    private static func springValue(t: Double, response: Double, damping: Double) -> Double {
        guard t > 0 else { return 0 }
        let omega = 2 * Double.pi / response
        let zeta  = damping
        if zeta >= 1 {
            // Critically damped
            let alpha = omega
            return 1 - exp(-alpha * t) * (1 + alpha * t)
        } else {
            let omegaD = omega * sqrt(1 - zeta * zeta)
            let decay  = exp(-zeta * omega * t)
            let phase  = zeta * omega / omegaD
            return 1 - decay * (cos(omegaD * t) + phase * sin(omegaD * t))
        }
    }

    private static func cubicBezier(t: Double, p1x: Double, p1y: Double,
                                     p2x: Double, p2y: Double) -> Double {
        // Newton–Raphson to find parameter for t on x axis, return y
        var u = t
        for _ in 0..<8 {
            let x = bezierComponent(u, 0, p1x, p2x, 1) - t
            let dx = bezierDerivative(u, 0, p1x, p2x, 1)
            guard abs(dx) > 1e-8 else { break }
            u -= x / dx
        }
        return bezierComponent(u, 0, p1y, p2y, 1)
    }

    private static func bezierComponent(_ t: Double, _ p0: Double, _ p1: Double,
                                         _ p2: Double, _ p3: Double) -> Double {
        let mt = 1 - t
        return mt*mt*mt*p0 + 3*mt*mt*t*p1 + 3*mt*t*t*p2 + t*t*t*p3
    }

    private static func bezierDerivative(_ t: Double, _ p0: Double, _ p1: Double,
                                          _ p2: Double, _ p3: Double) -> Double {
        let mt = 1 - t
        return 3*mt*mt*(p1-p0) + 6*mt*t*(p2-p1) + 3*t*t*(p3-p2)
    }

    // MARK: - Code generation
    private static func animationCode(_ config: AnimationConfig) -> String {
        var parts: [String] = []

        var base: String
        switch config.type {
        case .spring:
            base = ".spring(response: \(f(config.response)), dampingFraction: \(f(config.dampingFraction))"
            if config.blendDuration > 0 { base += ", blendDuration: \(f(config.blendDuration))" }
            base += ")"
        case .interactiveSpring:
            base = ".interactiveSpring(response: \(f(config.response)), dampingFraction: \(f(config.dampingFraction)))"
        case .bouncy:
            base = ".bouncy(duration: \(f(config.duration)), extraBounce: \(f(config.bounce)))"
        case .smooth:
            base = ".smooth(duration: \(f(config.duration)))"
        case .snappy:
            base = ".snappy(duration: \(f(config.duration)), extraBounce: \(f(config.bounce * 0.5)))"
        case .easeInOut:
            base = ".easeInOut(duration: \(f(config.duration)))"
        case .easeIn:
            base = ".easeIn(duration: \(f(config.duration)))"
        case .easeOut:
            base = ".easeOut(duration: \(f(config.duration)))"
        case .linear:
            base = ".linear(duration: \(f(config.duration)))"
        case .timingCurve:
            base = ".timingCurve(\(f(config.c0x)), \(f(config.c0y)), \(f(config.c1x)), \(f(config.c1y)), duration: \(f(config.duration)))"
        }

        parts.append(base)
        if config.delay > 0  { parts.append(".delay(\(f(config.delay)))") }
        if config.repeatCount == 0 {
            parts.append(".repeatForever(autoreverses: \(config.autoreverses))")
        } else if config.repeatCount > 1 {
            parts.append(".repeatCount(\(config.repeatCount), autoreverses: \(config.autoreverses))")
        }

        return parts.joined(separator: "\n    ")
    }

    static func f(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", v)
            : String(format: "%.2f", v)
    }
}
