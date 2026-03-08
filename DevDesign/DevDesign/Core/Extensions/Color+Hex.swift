//
//  Color+Hex.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Extends SwiftUI Color with HEX init and export.
// Replaces the temporary version in DSColors.swift.

import SwiftUI

extension Color {

    // MARK: - Init from HEX
    // Accepts "#RRGGBB", "#RRGGBBAA", "RRGGBB"
    init?(hexString: String) {
        guard let dc = DevColor(hex: hexString) else { return nil }
        self = dc.color
    }

    // MARK: - Export to HEX string
    var hexString: String? {
        DevColor(color: self)?.hex
    }

    // MARK: - To DevColor
    var devColor: DevColor? {
        DevColor(color: self)
    }
}
