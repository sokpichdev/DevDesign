//
//  AIPaletteError.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

enum AIPaletteError: LocalizedError, Equatable {
    case noAPIKey
    case networkError(String)
    case invalidResponse
    case parseError(String)
    case apiError(String)
    case rateLimited
    case invalidAPIKey
    case providerError(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key set. Tap ⚙ to add your API key."
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .invalidResponse:
            return "Received an unexpected response from the server."
        case .parseError(let msg):
            return "Couldn't parse the generated palette: \(msg)"
        case .apiError(let msg):
            return "API error: \(msg)"
        case .rateLimited:
            return "Rate limit reached. Please wait a moment and try again."
        case .invalidAPIKey:
            return "Invalid API key format. Please check your key."
        case .providerError(let msg):
            return "Provider error: \(msg)"
        }
    }
}
