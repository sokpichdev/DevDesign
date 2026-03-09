//
//  GeminiAPITypes.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

struct GeminiRequest: Codable {
    let contents:         [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Codable {
    let temperature:      Double
    let maxOutputTokens:  Int
    let topP:             Double
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content:      GeminiContent
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case content
        case finishReason = "finish_reason"
    }
}
