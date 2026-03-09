//
//  GenerationState.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import Foundation

enum GenerationState: Equatable {
    case idle
    case generating
    case success
    case error(String)
}
