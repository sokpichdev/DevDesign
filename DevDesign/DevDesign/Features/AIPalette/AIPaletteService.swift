//
//  AIPaletteService.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//  Updated to support multiple providers including OpenRouter (Free)
//

import Foundation

// MARK: - Service

final class AIPaletteService {
    
    // MARK: - System prompt (shared across providers)
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

    // MARK: - Public Generate Method (Provider Agnostic)
    
    static func generate(
        prompt: String,
        style: PaletteStyle,
        colorCount: ColorCount,
        provider: AIProvider,
        apiKey: String
    ) async throws -> AIGeneratedPalette {
        
        // OpenRouter doesn't require a key for free tier
        if provider.requiresKey && apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            throw AIPaletteError.noAPIKey
        }
        
        switch provider {
        case .anthropic:
            return try await generateWithAnthropic(
                prompt: prompt,
                style: style,
                colorCount: colorCount,
                apiKey: apiKey
            )
        case .gemini:
            return try await generateWithGemini(
                prompt: prompt,
                style: style,
                colorCount: colorCount,
                apiKey: apiKey
            )
        case .openrouter:
            return try await generateWithOpenRouter(
                prompt: prompt,
                style: style,
                colorCount: colorCount,
                apiKey: apiKey.isEmpty ? nil : apiKey // Optional for OpenRouter
            )
        }
    }
    
    // MARK: - Anthropic Implementation (unchanged)
    
    private static func generateWithAnthropic(
        prompt: String,
        style: PaletteStyle,
        colorCount: ColorCount,
        apiKey: String
    ) async throws -> AIGeneratedPalette {
        
        let userMessage = buildUserMessage(prompt: prompt, style: style, colorCount: colorCount)
        let request = try buildAnthropicRequest(message: userMessage, apiKey: apiKey)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw AIPaletteError.invalidResponse
        }
        
        switch http.statusCode {
        case 200:
            return try parseAnthropicResponse(
                data: data,
                originalPrompt: prompt,
                style: style
            )
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

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 30

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        return request
    }
    
    private static func parseAnthropicResponse(
        data: Data,
        originalPrompt: String,
        style: PaletteStyle
    ) throws -> AIGeneratedPalette {
        let decoder = JSONDecoder()

        guard let anthropic = try? decoder.decode(AnthropicResponse.self, from: data),
              let textBlock = anthropic.content.first(where: { $0.type == "text" }),
              let rawText = textBlock.text else {
            throw AIPaletteError.invalidResponse
        }

        return try parsePaletteJSON(
            rawText: rawText,
            originalPrompt: originalPrompt,
            style: style
        )
    }
    
    // MARK: - Gemini Implementation (unchanged)
    
    private static func generateWithGemini(
        prompt: String,
        style: PaletteStyle,
        colorCount: ColorCount,
        apiKey: String
    ) async throws -> AIGeneratedPalette {
        
        let userMessage = buildUserMessage(prompt: prompt, style: style, colorCount: colorCount)
        let request = try buildGeminiRequest(message: userMessage, apiKey: apiKey)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw AIPaletteError.invalidResponse
        }
        
        switch http.statusCode {
        case 200:
            return try parseGeminiResponse(
                data: data,
                originalPrompt: prompt,
                style: style
            )
        case 400:
            let body = String(data: data, encoding: .utf8) ?? ""
            if body.contains("API key not valid") {
                throw AIPaletteError.invalidAPIKey
            }
            throw AIPaletteError.apiError("Bad request: \(body.prefix(200))")
        case 403:
            throw AIPaletteError.invalidAPIKey
        case 429:
            throw AIPaletteError.rateLimited
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AIPaletteError.apiError("HTTP \(http.statusCode). \(body.prefix(200))")
        }
    }
    
    private static func buildGeminiRequest(message: String, apiKey: String) throws -> URLRequest {
        // gemini-2.5-flash: current free tier model (replaces deprecated 1.5-flash)
        // Fallback: "gemini-2.5-flash-lite" has higher rate limit (30 RPM vs 15 RPM)
        let modelName = "gemini-2.5-flash"
        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw AIPaletteError.networkError("Invalid Gemini endpoint URL")
        }
        
        print("🔗 Gemini Endpoint: \(endpoint.prefix(80))...")
        
        let body = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: systemPrompt + "\n\n" + message)
                    ]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.7,
                maxOutputTokens: 8192,
                topP: 0.95
            )
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)
        
        return request
    }
    
    private static func parseGeminiResponse(
        data: Data,
        originalPrompt: String,
        style: PaletteStyle
    ) throws -> AIGeneratedPalette {
        let decoder = JSONDecoder()
        
        guard let gemini = try? decoder.decode(GeminiResponse.self, from: data) else {
            throw AIPaletteError.invalidResponse
        }
        
        guard let candidate = gemini.candidates.first,
              let part = candidate.content.parts.first else {
            throw AIPaletteError.invalidResponse
        }
        
        let rawText = part.text
        return try parsePaletteJSON(
            rawText: rawText,
            originalPrompt: originalPrompt,
            style: style
        )
    }
    
    // MARK: - OpenRouter Implementation (NEW - Free Tier!)
    
    private static func generateWithOpenRouter(
        prompt: String,
        style: PaletteStyle,
        colorCount: ColorCount,
        apiKey: String?
    ) async throws -> AIGeneratedPalette {
        
        let userMessage = buildUserMessage(prompt: prompt, style: style, colorCount: colorCount)
        let request = try buildOpenRouterRequest(message: userMessage, apiKey: apiKey)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw AIPaletteError.invalidResponse
        }
        
        switch http.statusCode {
        case 200:
            return try parseOpenRouterResponse(
                data: data,
                originalPrompt: prompt,
                style: style
            )
        case 401:
            throw AIPaletteError.apiError("Invalid API key. Get one at openrouter.ai/keys")
        case 429:
            throw AIPaletteError.rateLimited
        case 402:
            throw AIPaletteError.apiError("Payment required. Add credits or use free tier model.")
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            print("❌ OpenRouter Error: HTTP \(http.statusCode) - \(body)")
            throw AIPaletteError.apiError("HTTP \(http.statusCode). \(body.prefix(200))")
        }
    }
    
    private static func buildOpenRouterRequest(message: String, apiKey: String?) throws -> URLRequest {
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            throw AIPaletteError.networkError("Invalid OpenRouter endpoint URL")
        }
        
        // Free tier models (no API key required) — use :free suffix on OpenRouter
        // Ranked by reliability for structured JSON output:
        let model = "meta-llama/llama-3.3-70b-instruct:free"
        // Fallback options if above hits rate limits:
        // "meta-llama/llama-3.1-8b-instruct:free"
        // "mistralai/mistral-small-3.1-24b-instruct:free"
        // "google/gemma-3-12b-it:free"
        
        let body = OpenRouterRequest(
            model: model,
            messages: [
                OpenRouterMessage(role: "system", content: systemPrompt),
                OpenRouterMessage(role: "user", content: message)
            ],
            temperature: 0.7,
            max_tokens: 2048
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // API key is optional for free tier, but if provided, use it
        if let key = apiKey, !key.isEmpty {
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        
        // Required headers for OpenRouter free tier
        request.setValue("https://devdesign.app", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("DevDesign AI Palette", forHTTPHeaderField: "X-Title")
        
        request.timeoutInterval = 60 // Longer timeout for free tier (can be slower)
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        print("🔗 OpenRouter Request: model=\(model), hasKey=\(apiKey != nil)")
        
        return request
    }
    
    private static func parseOpenRouterResponse(
        data: Data,
        originalPrompt: String,
        style: PaletteStyle
    ) throws -> AIGeneratedPalette {
        let decoder = JSONDecoder()
        
        guard let openRouter = try? decoder.decode(OpenRouterResponse.self, from: data) else {
            // Try to decode error response
            if let errorResponse = try? decoder.decode(OpenRouterErrorResponse.self, from: data) {
                throw AIPaletteError.apiError(errorResponse.error.message)
            }
            throw AIPaletteError.invalidResponse
        }

        guard let choice = openRouter.choices.first else {
            throw AIPaletteError.invalidResponse
        }

        let rawText = choice.message.content  // direct assignment
        return try parsePaletteJSON(
            rawText: rawText,
            originalPrompt: originalPrompt,
            style: style
        )
    }
    
    // MARK: - Shared Parsing Logic
    
    private static func parsePaletteJSON(
        rawText: String,
        originalPrompt: String,
        style: PaletteStyle
    ) throws -> AIGeneratedPalette {
        
        // Strip any accidental markdown fences
        let cleaned = stripMarkdownFences(rawText)
        
        // Decode palette JSON
        guard let jsonData = cleaned.data(using: .utf8) else {
            throw AIPaletteError.parseError("Could not encode response as UTF-8")
        }

        struct RawPalette: Codable {
            let name: String
            let mood: String
            let colors: [RawColor]

            struct RawColor: Codable {
                let hex: String
                let name: String
                let role: String
                let usage: String
            }
        }

        // First attempt: parse as-is
        var raw: RawPalette? = try? JSONDecoder().decode(RawPalette.self, from: jsonData)
        
        // Second attempt: if truncated mid-stream, try to close the JSON and salvage complete color objects
        if raw == nil {
            let salvaged = Self.attemptJSONRecovery(cleaned)
            if let salvageData = salvaged.data(using: .utf8) {
                raw = try? JSONDecoder().decode(RawPalette.self, from: salvageData)
            }
        }
        
        guard let raw else {
            throw AIPaletteError.parseError("JSON did not match expected palette schema.\nRaw: \(cleaned.prefix(300))")
        }

        // Validate & normalise
        let colors: [AIColor] = try raw.colors.map { c in
            let hex = normaliseHex(c.hex)
            guard isValidHex(hex) else {
                throw AIPaletteError.parseError("Invalid hex value: \(c.hex)")
            }
            return AIColor(
                id: UUID(),
                hex: hex,
                name: c.name,
                role: c.role,
                usage: c.usage
            )
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
    
    /// Attempts to salvage truncated JSON by closing incomplete structures.
    /// Strips any incomplete last color object (partial data), then closes arrays/object.
    private static func attemptJSONRecovery(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Find the last complete color object — ends with }
        // Walk back to the last well-formed "}" that closes a color entry
        if let lastBrace = s.range(of: "}", options: .backwards) {
            s = String(s[s.startIndex...lastBrace.lowerBound])
        }
        
        // Close the colors array and root object if not already closed
        if !s.hasSuffix("}") { s += "}" }   // close last color object
        if !s.contains("]") { s += "]" }    // close colors array
        // Ensure root object is closed
        let openBraces  = s.filter { $0 == "{" }.count
        let closeBraces = s.filter { $0 == "}" }.count
        if openBraces > closeBraces {
            s += String(repeating: "}", count: openBraces - closeBraces)
        }
        return s
    }
    
    private static func buildUserMessage(
        prompt: String,
        style: PaletteStyle,
        colorCount: ColorCount
    ) -> String {
        var parts: [String] = [
            "Generate a \(colorCount.rawValue)-color palette for: \"\(prompt)\""
        ]
        if style != .any {
            parts.append("Style: \(style.rawValue) — \(style.hint)")
        }
        parts.append("Return ONLY the JSON object. No other text.")
        return parts.joined(separator: "\n")
    }

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
        var s = text

        // Strip <think>...</think> blocks emitted by reasoning/thinking models (e.g. Gemini 2.5 Flash)
        if let thinkStart = s.range(of: "<think>"),
           let thinkEnd   = s.range(of: "</think>") {
            s.removeSubrange(thinkStart.lowerBound...thinkEnd.upperBound)
        }

        var lines = s.components(separatedBy: "\n")
        if let first = lines.first, first.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
            lines.removeFirst()
        }
        if let last = lines.last, last.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
            lines.removeLast()
        }
        let joined = lines.joined(separator: "\n")
        return joined.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Gemini API Models

struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double
    let maxOutputTokens: Int
    let topP: Double
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case content
        case finishReason = "finish_reason"
    }
}

// MARK: - OpenRouter API Models (NEW)

struct OpenRouterRequest: Codable {
    let model: String
    let messages: [OpenRouterMessage]
    let temperature: Double
    let max_tokens: Int
}

struct OpenRouterMessage: Codable {
    let role: String
    let content: String
}

struct OpenRouterResponse: Codable {
    let choices: [OpenRouterChoice]
}

struct OpenRouterChoice: Codable {
    let message: OpenRouterMessage
    let finish_reason: String?
}

struct OpenRouterErrorResponse: Codable {
    let error: OpenRouterError
}

struct OpenRouterError: Codable {
    let message: String
    let type: String?
    let code: Int?
}

// MARK: - Legacy API Key Store

enum APIKeyStore {
    static func migrateToProviderStore() {
        if let oldKey = UserDefaults.standard.string(forKey: "devdesign_anthropic_api_key") {
            ProviderKeyStore.saveKey(oldKey, for: .anthropic)
        }
    }
}
