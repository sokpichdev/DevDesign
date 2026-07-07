//
//  MetalSymbolExportService.swift
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  Turns a MetalSymbolConfig into ready-to-paste SwiftUI code and the
//  matching .metal shader source.
//

import SwiftUI

// MARK: - Export Format

enum MetalSymbolExportFormat: String, CaseIterable, Identifiable {
    case swiftUI     = "SwiftUI"
    case metalShader = "Metal Shader"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .swiftUI:     return "swift"
        case .metalShader: return "cpu"
        }
    }
}

// MARK: - Export Service

enum MetalSymbolExportService {

    static func export(_ config: MetalSymbolConfig, as format: MetalSymbolExportFormat) -> String {
        switch format {
        case .swiftUI:     return swiftUI(config)
        case .metalShader: return metalShader(config.effect)
        }
    }

    // MARK: - SwiftUI snippet

    private static func swiftUI(_ c: MetalSymbolConfig) -> String {
        let size = trimmed(c.size)
        let speed = trimmed(c.speed)
        let intensity = trimmed(c.intensity)
        let fn = c.effect.shaderFunctionName

        // Build the effect-specific shader call + modifier.
        let modifier: String
        switch c.effect {
        case .shimmer:
            modifier = """
                        .colorEffect(
                            ShaderLibrary.\(fn)(
                                .boundingRect,
                                .float(time),
                                .float(\(speed)),
                                .float(\(intensity))
                            )
                        )
                """
        case .gradientFlow:
            modifier = """
                        .colorEffect(
                            ShaderLibrary.\(fn)(
                                .boundingRect,
                                .float(time),
                                .float(\(speed)),
                                .color(\(colorLiteral(c.primaryColor))),
                                .color(\(colorLiteral(c.secondaryColor)))
                            )
                        )
                """
        case .noise:
            modifier = """
                        .distortionEffect(
                            ShaderLibrary.\(fn)(
                                .boundingRect,
                                .float(time),
                                .float(\(speed)),
                                .float(\(intensity))
                            ),
                            maxSampleOffset: CGSize(width: 24, height: 24)
                        )
                """
        case .liquidMetal:
            modifier = """
                        .colorEffect(
                            ShaderLibrary.\(fn)(
                                .boundingRect,
                                .float(time),
                                .float(\(speed)),
                                .float(\(intensity)),
                                .color(\(colorLiteral(c.primaryColor)))
                            )
                        )
                """
        }

        return """
        import SwiftUI

        // Requires SymbolEffects.metal (see the "Metal Shader" tab) added to your target.
        struct AnimatedSymbol: View {
            @State private var start = Date()

            var body: some View {
                TimelineView(.animation) { context in
                    let time = Float(start.distance(to: context.date))

                    Image(systemName: "\(c.symbolName)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: \(size), height: \(size))
                        .foregroundStyle(\(colorLiteral(c.primaryColor)))
        \(modifier)
                }
            }
        }
        """
    }

    // MARK: - Metal shader source

    /// Returns the .metal source for the selected effect, wrapped with the
    /// includes a standalone file needs.
    private static func metalShader(_ effect: MetalSymbolEffect) -> String {
        """
        #include <metal_stdlib>
        using namespace metal;

        \(shaderBody(effect))
        """
    }

    private static func shaderBody(_ effect: MetalSymbolEffect) -> String {
        switch effect {
        case .shimmer:
            return """
            // Shimmer: a bright band sweeps diagonally across the symbol.
            [[ stitchable ]]
            half4 shimmer(float2 position, half4 color,
                          float4 bounds, float time, float speed, float intensity) {
                if (color.a < 0.001h) { return color; }
                float2 uv = (position - bounds.xy) / bounds.zw;
                float t   = fract(time * speed * 0.35);
                float diag = (uv.x + uv.y) * 0.5;
                float band = max(1.0 - abs(diag - t) * 7.0, 0.0);
                half add = half(band * intensity);
                half3 rgb = min(color.rgb + add * color.a, half3(color.a));
                return half4(rgb, color.a);
            }
            """
        case .gradientFlow:
            return """
            // Gradient Flow: an animated two-colour gradient flows through the fill.
            [[ stitchable ]]
            half4 gradientFlow(float2 position, half4 color,
                               float4 bounds, float time, float speed, half4 c1, half4 c2) {
                if (color.a < 0.001h) { return color; }
                float2 uv = (position - bounds.xy) / bounds.zw;
                float phase = (uv.x + uv.y) * 1.5 - time * speed * 0.6;
                half m = half(0.5 + 0.5 * sin(phase * 3.14159265));
                half3 g = mix(c1.rgb, c2.rgb, m);
                return half4(g * color.a, color.a);
            }
            """
        case .noise:
            return """
            // Noise: procedural ripple that warps the sampled position.
            // Use with .distortionEffect.
            [[ stitchable ]]
            float2 noise(float2 position,
                         float4 bounds, float time, float speed, float intensity) {
                float2 uv = (position - bounds.xy) / bounds.zw;
                float t = time * speed * 2.0;
                float dx = sin(uv.y * 18.0 + t) * intensity;
                float dy = cos(uv.x * 18.0 + t * 1.2) * intensity;
                return position + float2(dx, dy);
            }
            """
        case .liquidMetal:
            return """
            // Liquid Metal: reflective banding with a moving specular highlight.
            [[ stitchable ]]
            half4 liquidMetal(float2 position, half4 color,
                              float4 bounds, float time, float speed, float intensity, half4 tint) {
                if (color.a < 0.001h) { return color; }
                float2 uv = (position - bounds.xy) / bounds.zw;
                float t = time * speed * 0.6;
                float wave = sin((uv.x + uv.y) * 6.2831 + t)
                           + 0.5 * sin((uv.x - uv.y) * 12.0 - t * 1.3);
                float shade = 0.5 + 0.5 * sin(wave * 3.14159265 + t);
                half3 metal = mix(half3(0.18h), half3(1.0h), half(shade));
                metal = mix(metal, metal * tint.rgb, 0.5h);
                half spec = half(pow(shade, 6.0) * intensity);
                half3 rgb = min(metal + spec, half3(1.0h));
                return half4(rgb * color.a, color.a);
            }
            """
        }
    }

    // MARK: - Helpers

    private static func colorLiteral(_ color: Color) -> String {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return "Color(red: \(round3(r)), green: \(round3(g)), blue: \(round3(b)))"
    }

    private static func trimmed(_ v: CGFloat) -> String { trimmed(Double(v)) }

    private static func trimmed(_ v: Double) -> String {
        let r = (v * 100).rounded() / 100
        return r == r.rounded() ? String(Int(r)) : String(r)
    }

    private static func round3(_ v: CGFloat) -> Double { (Double(v) * 1000).rounded() / 1000 }
}
