//
//  AIPaletteService.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

final class AIPaletteService {

    // MARK: - Shared system prompt

    private static let systemPrompt = """
    You are a world-class color palette designer. When given a prompt describing a theme, mood, place, or UI context, you return a beautiful, harmonious color palette as pure JSON — no markdown, no explanation, no preamble.

    Rules:
    1. Always respond with ONLY valid JSON, no markdown fences, no surrounding text.
    2. The JSON must exactly follow this schema:
    {
      "name": "<palette name, 2–5 words, evocative>",
      "mood": "<3–5 comma-separated mood/feeling keywords>",
      "colors": [
        {
          "hex": "<6-digit hex with #>",
          "name": "<poetic 2–3 word color name>",
          "role": "<one of: primary | background | accent | surface | text | highlight>",
          "usage": "<short practical usage hint, ≤8 words>"
        }
      ]
    }
    3. Hex values must be valid 6-character hex codes starting with #.
    4. Each color must be visually distinct — no two colors closer than 20 Δhue unless it's a monochrome palette.
    5. The palette should be production-ready for UI design.
    6. Colors must be harmonious — think about light/dark balance and contrast pairs.
    7. Never include colors outside the 10–90% lightness range (avoid pure black or pure white).
    """

    // MARK: - Public entry point

    static func generate(
        prompt: String,
        style: PaletteStyle,
        colorCount: ColorCount,
        provider: AIProvider,
        apiKey: String
    ) async throws -> AIGeneratedPalette {

        if provider.requiresKey && apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            throw AIPaletteError.noAPIKey
        }

        switch provider {
        case .anthropic:
            return try await generateWithAnthropic(prompt: prompt, style: style,
                                                    colorCount: colorCount, apiKey: apiKey)
        case .gemini:
            return try await generateWithGemini(prompt: prompt, style: style,
                                                 colorCount: colorCount, apiKey: apiKey)
        case .openrouter:
            return try await generateWithOpenRouter(prompt: prompt, style: style,
                                                     colorCount: colorCount,
                                                     apiKey: apiKey.isEmpty ? nil : apiKey)
        }
    }

    // MARK: - Anthropic

    private static func generateWithAnthropic(
        prompt: String, style: PaletteStyle, colorCount: ColorCount, apiKey: String
    ) async throws -> AIGeneratedPalette {

        let message = buildUserMessage(prompt: prompt, style: style, colorCount: colorCount)
        let request = try buildAnthropicRequest(message: message, apiKey: apiKey)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw AIPaletteError.invalidResponse }

        switch http.statusCode {
        case 200: return try parseAnthropicResponse(data: data, originalPrompt: prompt, style: style)
        case 401, 403: throw AIPaletteError.apiError("Invalid or expired API key.")
        case 429: throw AIPaletteError.rateLimited
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AIPaletteError.apiError("HTTP \(http.statusCode). \(body.prefix(200))")
        }
    }

    private static func buildAnthropicRequest(message: String, apiKey: String) throws -> URLRequest {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AIPaletteError.networkError("Invalid endpoint URL")
        }
        let body = AnthropicRequest(
            model: "claude-sonnet-4-5",
            max_tokens: 2048,
            system: systemPrompt,
            messages: [AnthropicMessage(role: "user", content: message)]
        )
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(apiKey,             forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01",       forHTTPHeaderField: "anthropic-version")
        req.timeoutInterval = 30
        req.httpBody = try JSONEncoder().encode(body)
        return req
    }

    private static func parseAnthropicResponse(
        data: Data, originalPrompt: String, style: PaletteStyle
    ) throws -> AIGeneratedPalette {
        guard let resp      = try? JSONDecoder().decode(AnthropicResponse.self, from: data),
              let textBlock = resp.content.first(where: { $0.type == "text" }),
              let rawText   = textBlock.text
        else { throw AIPaletteError.invalidResponse }
        return try parsePaletteJSON(rawText: rawText, originalPrompt: originalPrompt, style: style)
    }

    // MARK: - Gemini

    private static func generateWithGemini(
        prompt: String, style: PaletteStyle, colorCount: ColorCount, apiKey: String
    ) async throws -> AIGeneratedPalette {

        let message = buildUserMessage(prompt: prompt, style: style, colorCount: colorCount)
        let request = try buildGeminiRequest(message: message, apiKey: apiKey)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw AIPaletteError.invalidResponse }

        switch http.statusCode {
        case 200: return try parseGeminiResponse(data: data, originalPrompt: prompt, style: style)
        case 400:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw body.contains("API key not valid")
                ? AIPaletteError.invalidAPIKey
                : AIPaletteError.apiError("Bad request: \(body.prefix(200))")
        case 403: throw AIPaletteError.invalidAPIKey
        case 429: throw AIPaletteError.rateLimited
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AIPaletteError.apiError("HTTP \(http.statusCode). \(body.prefix(200))")
        }
    }

    private static func buildGeminiRequest(message: String, apiKey: String) throws -> URLRequest {
        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: endpoint) else {
            throw AIPaletteError.networkError("Invalid Gemini endpoint URL")
        }
        let body = GeminiRequest(
            contents: [GeminiContent(parts: [GeminiPart(text: systemPrompt + "\n\n" + message)])],
            generationConfig: GeminiGenerationConfig(temperature: 0.7, maxOutputTokens: 8192, topP: 0.95)
        )
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 30
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        req.httpBody = try encoder.encode(body)
        return req
    }

    private static func parseGeminiResponse(
        data: Data, originalPrompt: String, style: PaletteStyle
    ) throws -> AIGeneratedPalette {
        guard let resp      = try? JSONDecoder().decode(GeminiResponse.self, from: data),
              let candidate = resp.candidates.first,
              let part      = candidate.content.parts.first
        else { throw AIPaletteError.invalidResponse }
        return try parsePaletteJSON(rawText: part.text, originalPrompt: originalPrompt, style: style)
    }

    // MARK: - OpenRouter

    private static func generateWithOpenRouter(
        prompt: String, style: PaletteStyle, colorCount: ColorCount, apiKey: String?
    ) async throws -> AIGeneratedPalette {

        let message = buildUserMessage(prompt: prompt, style: style, colorCount: colorCount)
        let request = try buildOpenRouterRequest(message: message, apiKey: apiKey)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw AIPaletteError.invalidResponse }

        switch http.statusCode {
        case 200: return try parseOpenRouterResponse(data: data, originalPrompt: prompt, style: style)
        case 401: throw AIPaletteError.apiError("Invalid API key. Get one at openrouter.ai/keys")
        case 402: throw AIPaletteError.apiError("Payment required. Add credits or use free tier model.")
        case 429: throw AIPaletteError.rateLimited
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AIPaletteError.apiError("HTTP \(http.statusCode). \(body.prefix(200))")
        }
    }

    private static func buildOpenRouterRequest(message: String, apiKey: String?) throws -> URLRequest {
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            throw AIPaletteError.networkError("Invalid OpenRouter endpoint URL")
        }
        let body = OpenRouterRequest(
            model: "meta-llama/llama-3.3-70b-instruct:free",
            messages: [
                OpenRouterMessage(role: "system", content: systemPrompt),
                OpenRouterMessage(role: "user",   content: message),
            ],
            temperature: 0.7,
            max_tokens: 2048
        )
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json",      forHTTPHeaderField: "Content-Type")
        req.setValue("https://devdesign.app", forHTTPHeaderField: "HTTP-Referer")
        req.setValue("DevDesign AI Palette",  forHTTPHeaderField: "X-Title")
        if let key = apiKey, !key.isEmpty {
            req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        req.timeoutInterval = 60
        req.httpBody = try JSONEncoder().encode(body)
        return req
    }

    private static func parseOpenRouterResponse(
        data: Data, originalPrompt: String, style: PaletteStyle
    ) throws -> AIGeneratedPalette {
        let decoder = JSONDecoder()
        if let resp   = try? decoder.decode(OpenRouterResponse.self, from: data),
           let choice = resp.choices.first {
            return try parsePaletteJSON(rawText: choice.message.content,
                                         originalPrompt: originalPrompt, style: style)
        }
        if let errResp = try? decoder.decode(OpenRouterErrorResponse.self, from: data) {
            throw AIPaletteError.apiError(errResp.error.message)
        }
        throw AIPaletteError.invalidResponse
    }

    // MARK: - Shared JSON parsing

    private static func parsePaletteJSON(
        rawText: String, originalPrompt: String, style: PaletteStyle
    ) throws -> AIGeneratedPalette {

        let cleaned = stripMarkdownFences(rawText)

        guard let jsonData = cleaned.data(using: .utf8) else {
            throw AIPaletteError.parseError("Could not encode response as UTF-8")
        }

        struct RawPalette: Codable {
            let name:   String
            let mood:   String
            let colors: [RawColor]
            struct RawColor: Codable {
                let hex: String; let name: String
                let role: String; let usage: String
            }
        }

        var raw: RawPalette? = try? JSONDecoder().decode(RawPalette.self, from: jsonData)
        if raw == nil, let salvaged = attemptJSONRecovery(cleaned).data(using: .utf8) {
            raw = try? JSONDecoder().decode(RawPalette.self, from: salvaged)
        }
        guard let raw else {
            throw AIPaletteError.parseError("JSON did not match expected schema.\nRaw: \(cleaned.prefix(300))")
        }

        let colors: [AIColor] = try raw.colors.map { c in
            let hex = normaliseHex(c.hex)
            guard isValidHex(hex) else { throw AIPaletteError.parseError("Invalid hex: \(c.hex)") }
            return AIColor(id: UUID(), hex: hex, name: c.name, role: c.role, usage: c.usage)
        }
        guard !colors.isEmpty else { throw AIPaletteError.parseError("Palette contained no colors.") }

        return AIGeneratedPalette(id: UUID(), name: raw.name, mood: raw.mood,
                                   colors: colors, prompt: originalPrompt,
                                   style: style.rawValue, generatedAt: .now)
    }

    // MARK: - Helpers

    private static func buildUserMessage(prompt: String, style: PaletteStyle, colorCount: ColorCount) -> String {
        var parts = ["Generate a \(colorCount.rawValue)-color palette for: \"\(prompt)\""]
        if style != .any { parts.append("Style: \(style.rawValue) — \(style.hint)") }
        parts.append("Return ONLY the JSON object. No other text.")
        return parts.joined(separator: "\n")
    }

    static func normaliseHex(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.hasPrefix("#") { s = "#" + s }
        if s.count == 4 { s = "#" + Array(s.dropFirst()).map { "\($0)\($0)" }.joined() }
        return s.uppercased()
    }

    static func isValidHex(_ hex: String) -> Bool {
        guard hex.hasPrefix("#"), hex.count == 7 else { return false }
        return hex.dropFirst().unicodeScalars.allSatisfy {
            CharacterSet(charactersIn: "0123456789ABCDEFabcdef").contains($0)
        }
    }

    private static func stripMarkdownFences(_ text: String) -> String {
        var s = text
        // Strip <think>…</think> blocks from reasoning models
        if let start = s.range(of: "<think>"), let end = s.range(of: "</think>") {
            s.removeSubrange(start.lowerBound...end.upperBound)
        }
        var lines = s.components(separatedBy: "\n")
        if lines.first?.trimmingCharacters(in: .whitespaces).hasPrefix("```") == true { lines.removeFirst() }
        if lines.last?.trimmingCharacters(in: .whitespaces).hasPrefix("```")  == true { lines.removeLast() }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func attemptJSONRecovery(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let lastBrace = s.range(of: "}", options: .backwards) {
            s = String(s[s.startIndex...lastBrace.lowerBound])
        }
        if !s.hasSuffix("}")  { s += "}" }
        if !s.contains("]")   { s += "]" }
        let open  = s.filter { $0 == "{" }.count
        let close = s.filter { $0 == "}" }.count
        if open > close { s += String(repeating: "}", count: open - close) }
        return s
    }
}
