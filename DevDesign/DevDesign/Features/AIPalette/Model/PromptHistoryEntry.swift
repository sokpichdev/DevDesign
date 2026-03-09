//
//  PromptHistoryEntry.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

struct PromptHistoryEntry: Identifiable, Equatable, Codable {
    var id:          UUID  = UUID()
    var prompt:      String
    var style:       String
    var colorCount:  Int
    var paletteName: String
    var colors:      [AIColor] = []     // snapshot of the generated palette's colors
    var savedAt:     Date      = .now
}
