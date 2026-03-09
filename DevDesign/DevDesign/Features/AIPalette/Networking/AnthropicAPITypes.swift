//
//  AnthropicAPITypes.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

struct AnthropicMessage: Codable {
    let role:    String
    let content: String
}

struct AnthropicRequest: Codable {
    let model:      String
    let max_tokens: Int
    let system:     String
    let messages:   [AnthropicMessage]
}

struct AnthropicTextBlock: Codable {
    let type: String
    let text: String?
}

struct AnthropicResponse: Codable {
    let content:     [AnthropicTextBlock]
    let stop_reason: String?
}
