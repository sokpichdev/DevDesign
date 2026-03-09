//
//  AIPaletteError.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import Foundation

// MARK: - Service Errors

enum AIPaletteError: LocalizedError, Equatable {
    case noAPIKey
    case networkError(String)
    case invalidResponse
    case parseError(String)
    case apiError(String)
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key set. Tap ⚙ to add your Anthropic API key."
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .invalidResponse:
            return "Received an unexpected response from the server."
        case .parseError(let msg):
            return "Couldn't parse the generated palette: \(msg)"
        case .apiError(let msg):
            return "Anthropic API error: \(msg)"
        case .rateLimited:
            return "Rate limit reached. Please wait a moment and try again."
        }
    }
}

// MARK: - Service

final class AIPaletteService {

    // MARK: - System prompt
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

    // MARK: - Generate

    static func generate(
        prompt: String,
        style: PaletteStyle,
        colorCount: ColorCount,
        apiKey: String
    ) async throws -> AIGeneratedPalette {
        guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AIPaletteError.noAPIKey
        }

        let userMessage = buildUserMessage(prompt: prompt, style: style, colorCount: colorCount)
        let request     = try buildRequest(message: userMessage, apiKey: apiKey)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AIPaletteError.invalidResponse
        }

        switch http.statusCode {
        case 200:
            return try parseResponse(data: data,
                                     originalPrompt: prompt,
                                     style: style)
        case 401, 403:
            throw AIPaletteError.apiError("Invalid or expired API key.")
        case 429:
            throw AIPaletteError.rateLimited
        case 400:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AIPaletteError.apiError("Bad request. \(body.prefix(200))")
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AIPaletteError.apiError("HTTP \(http.statusCode). \(body.prefix(200))")
        }
    }

    // MARK: - Build user message

    private static func buildUserMessage(prompt: String,
                                          style: PaletteStyle,
                                          colorCount: ColorCount) -> String {
        var parts: [String] = [
            "Generate a \(colorCount.rawValue)-color palette for: \"\(prompt)\""
        ]
        if style != .any {
            parts.append("Style: \(style.rawValue) — \(style.hint)")
        }
        parts.append("Return ONLY the JSON object. No other text.")
        return parts.joined(separator: "\n")
    }

    // MARK: - Build URLRequest

    private static func buildRequest(message: String, apiKey: String) throws -> URLRequest {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AIPaletteError.networkError("Invalid endpoint URL")
        }

        let body = AnthropicRequest(
            model: "claude-sonnet-4-20250514",
            max_tokens: 1024,
            system: systemPrompt,
            messages: [AnthropicMessage(role: "user", content: message)]
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",   forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey,               forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",         forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 30

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        return request
    }

    // MARK: - Parse response

    private static func parseResponse(data: Data,
                                       originalPrompt: String,
                                       style: PaletteStyle) throws -> AIGeneratedPalette {
        let decoder = JSONDecoder()

        // Decode Anthropic wrapper
        guard let anthropic = try? decoder.decode(AnthropicResponse.self, from: data),
              let textBlock  = anthropic.content.first(where: { $0.type == "text" }),
              let rawText    = textBlock.text else {
            throw AIPaletteError.invalidResponse
        }

        // Strip any accidental markdown fences
        let cleaned = stripMarkdownFences(rawText)

        // Decode palette JSON
        guard let jsonData = cleaned.data(using: .utf8) else {
            throw AIPaletteError.parseError("Could not encode response as UTF-8")
        }

        struct RawPalette: Codable {
            let name:   String
            let mood:   String
            let colors: [RawColor]

            struct RawColor: Codable {
                let hex:   String
                let name:  String
                let role:  String
                let usage: String
            }
        }

        guard let raw = try? decoder.decode(RawPalette.self, from: jsonData) else {
            throw AIPaletteError.parseError("JSON did not match expected palette schema.\nRaw: \(cleaned.prefix(300))")
        }

        // Validate & normalise
        let colors: [AIColor] = try raw.colors.map { c in
            let hex = normaliseHex(c.hex)
            guard isValidHex(hex) else {
                throw AIPaletteError.parseError("Invalid hex value: \(c.hex)")
            }
            return AIColor(id: UUID(), hex: hex, name: c.name,
                           role: c.role, usage: c.usage)
        }

        guard !colors.isEmpty else {
            throw AIPaletteError.parseError("Palette contained no colors.")
        }

        return AIGeneratedPalette(
            id: UUID(),
            name: raw.name,
            mood: raw.mood,
            colors: colors,
            prompt: originalPrompt,
            style: style.rawValue,
            generatedAt: .now
        )
    }

    // MARK: - Helpers

    static func normaliseHex(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.hasPrefix("#") { s = "#" + s }
        if s.count == 4 {   // #RGB → #RRGGBB
            let chars = Array(s.dropFirst())
            s = "#" + chars.map { "\($0)\($0)" }.joined()
        }
        return s.uppercased()
    }

    static func isValidHex(_ hex: String) -> Bool {
        guard hex.hasPrefix("#"), hex.count == 7 else { return false }
        let chars = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        return hex.dropFirst().unicodeScalars.allSatisfy { chars.contains($0) }
    }

    private static func stripMarkdownFences(_ text: String) -> String {
        var lines = text.components(separatedBy: "\n")
        // Remove leading/trailing ``` lines
        if let first = lines.first, first.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
            lines.removeFirst()
        }
        if let last = lines.last, last.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
            lines.removeLast()
        }
        // Also strip "json" after fence
        let joined = lines.joined(separator: "\n")
        return joined.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - API Key Storage (UserDefaults — swap for Keychain in production)

enum APIKeyStore {
    private static let key = "devdesign_anthropic_api_key"

    static func save(_ apiKey: String) {
        UserDefaults.standard.set(apiKey, forKey: key)
    }

    static func load() -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    static func maskedDisplay(_ key: String) -> String {
        guard key.count > 8 else { return String(repeating: "•", count: key.count) }
        let prefix = String(key.prefix(7))    // "sk-ant-"
        let suffix = String(key.suffix(4))
        let dots   = String(repeating: "•", count: 8)
        return "\(prefix)\(dots)\(suffix)"
    }
}

// MARK: - Prompt History (UserDefaults)

enum PromptHistoryStore {
    private static let key     = "devdesign_prompt_history"
    private static let maxSize = 20

    static func load() -> [PromptHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([PromptHistoryEntry].self, from: data)
        else { return [] }
        return entries
    }

    static func append(_ entry: PromptHistoryEntry) {
        var entries = load()
        entries.removeAll { $0.prompt == entry.prompt && $0.style == entry.style }
        entries.insert(entry, at: 0)
        if entries.count > maxSize { entries = Array(entries.prefix(maxSize)) }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
