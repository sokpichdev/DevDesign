//
//  Item.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
