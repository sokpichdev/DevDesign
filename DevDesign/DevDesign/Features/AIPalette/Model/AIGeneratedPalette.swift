//
//  AIGeneratedPalette.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

struct AIGeneratedPalette: Identifiable, Equatable, Codable {
    var id: UUID      = UUID()
    var name: String            // e.g. "Sunset Over Tokyo"
    var mood: String            // e.g. "warm, nostalgic, urban"
    var colors: [AIColor]
    var prompt: String
    var style: String
    var generatedAt: Date = .now
}
