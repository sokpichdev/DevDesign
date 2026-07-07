//
//  SymbolEffects.metal
//  DevDesign
//
//  Created by Sok Pich on 28/06/2026.
//
//  [[stitchable]] shader functions used by SwiftUI's .colorEffect /
//  .distortionEffect modifiers to animate SF Symbols on the GPU.
//
//  Coordinate notes:
//   - `position` is in the view's local point space.
//   - `bounds`   is the view's bounding rect (origin.xy, size.zw), supplied by
//                SwiftUI's `.boundingRect` shader argument, used to normalise uv.
//   - Colours arrive premultiplied; `.colorEffect` outputs must stay premultiplied
//     (rgb <= alpha), so we multiply generated colour by the source alpha.
//

#include <metal_stdlib>
using namespace metal;

// MARK: - Shimmer
// A bright band sweeps diagonally across the symbol's filled pixels.
// args: bounds, time (s), speed, intensity (0...1)
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

// MARK: - Gradient Flow
// An animated two-colour gradient flows through the symbol's fill.
// args: bounds, time (s), speed, c1, c2
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

// MARK: - Noise (distortion)
// Procedural ripple that warps the sampled position. Returns the source
// coordinate to read from, so it must be used with .distortionEffect.
// args: bounds, time (s), speed, intensity (px)
[[ stitchable ]]
float2 noise(float2 position,
             float4 bounds, float time, float speed, float intensity) {
    float2 uv = (position - bounds.xy) / bounds.zw;
    float t = time * speed * 2.0;
    float dx = sin(uv.y * 18.0 + t) * intensity;
    float dy = cos(uv.x * 18.0 + t * 1.2) * intensity;
    return position + float2(dx, dy);
}

// MARK: - Liquid Metal
// Reflective metallic banding with a moving specular highlight, tinted by `tint`.
// args: bounds, time (s), speed, intensity (0...1), tint
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
