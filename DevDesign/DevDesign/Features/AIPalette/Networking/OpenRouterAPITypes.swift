//
//  OpenRouterAPITypes.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

struct OpenRouterRequest: Codable {
    let model:       String
    let messages:    [OpenRouterMessage]
    let temperature: Double
    let max_tokens:  Int
}

struct OpenRouterMessage: Codable {
    let role:    String
    let content: String
}

struct OpenRouterResponse: Codable {
    let choices: [OpenRouterChoice]
}

struct OpenRouterChoice: Codable {
    let message:       OpenRouterMessage
    let finish_reason: String?
}

struct OpenRouterErrorResponse: Codable {
    let error: OpenRouterError
}

struct OpenRouterError: Codable {
    let message: String
    let type:    String?
    let code:    Int?
}
