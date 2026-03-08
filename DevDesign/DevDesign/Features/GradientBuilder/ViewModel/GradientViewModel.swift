//
//  GradientViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//

import SwiftUI
import Observation

@Observable
final class GradientViewModel {

    // MARK: - State
    var config: GradientConfig = GradientConfig()
    var selectedStopID: UUID? = nil
    var previewShape: GradientPreviewShape = .rectangle
    var selectedPreset: GradientPreset? = nil
    var showExportSheet: Bool = false
    var selectedExportFormat: GradientExportFormat = .swiftUI
    var showCopiedToast: Bool = false
    var copiedLabel: String = ""

    // MARK: - Init
    init() {
        selectedStopID = config.stops.first?.id
    }

    // MARK: - Computed
    var selectedStop: GradientStop? {
        guard let id = selectedStopID else { return nil }
        return config.stops.first(where: { $0.id == id })
    }

    var selectedStopIndex: Int? {
        guard let id = selectedStopID else { return nil }
        return config.stops.firstIndex(where: { $0.id == id })
    }

    var canAddStop: Bool { config.stops.count < 6 }
    var canRemoveStop: Bool { config.stops.count > 2 }

    // MARK: - Stop CRUD

    func addStop() {
        guard canAddStop else { return }
        // Insert at midpoint between last two sorted stops
        let sorted = config.sortedStops
        let midPos: Double
        if let last = sorted.last, let secondLast = sorted.dropLast().last {
            midPos = (secondLast.position + last.position) / 2
        } else {
            midPos = 0.5
        }
        // Interpolate color between neighbours
        let newStop = GradientStop(color: interpolatedColor(at: midPos), position: midPos)
        var updated = config
        updated.stops.append(newStop)
        config = updated
        selectedStopID = newStop.id
    }

    func removeStop(id: UUID) {
        guard canRemoveStop else { return }
        var updated = config
        updated.stops.removeAll(where: { $0.id == id })
        config = updated
        if selectedStopID == id {
            selectedStopID = config.stops.first?.id
        }
    }

    func updateStopColor(_ color: Color, id: UUID) {
        guard let idx = config.stops.firstIndex(where: { $0.id == id }) else { return }
        var updated = config
        updated.stops[idx].color = color
        config = updated
        selectedPreset = nil
    }

    func updateStopPosition(_ position: Double, id: UUID) {
        guard let idx = config.stops.firstIndex(where: { $0.id == id }) else { return }
        let clamped = min(max(position, 0), 1)
        var updated = config
        updated.stops[idx].position = clamped
        config = updated
        selectedPreset = nil
    }

    // MARK: - Config Mutations

    func setType(_ type: GradientType) {
        var updated = config
        updated.type = type
        config = updated
        selectedPreset = nil
    }

    func setAngle(_ angle: Double) {
        var updated = config
        updated.angle = angle
        config = updated
        selectedPreset = nil
    }

    func setCenter(x: Double, y: Double) {
        var updated = config
        updated.centerX = x
        updated.centerY = y
        config = updated
        selectedPreset = nil
    }

    func setEndRadius(_ r: Double) {
        var updated = config
        updated.endRadius = r
        config = updated
        selectedPreset = nil
    }

    // MARK: - Presets

    func applyPreset(_ preset: GradientPreset) {
        config = preset.config
        selectedPreset = preset
        selectedStopID = config.stops.first?.id
    }

    func reverseStops() {
        var updated = config
        let positions = updated.stops.map(\.position)
        for i in updated.stops.indices {
            updated.stops[i].position = 1.0 - positions[i]
        }
        config = updated
        selectedPreset = nil
    }

    func randomize() {
        var updated = config
        for i in updated.stops.indices {
            updated.stops[i].color = Color(
                hue: Double.random(in: 0...1),
                saturation: Double.random(in: 0.5...1),
                brightness: Double.random(in: 0.6...1)
            )
        }
        config = updated
        selectedPreset = nil
    }

    func reset() {
        config = GradientConfig()
        selectedPreset = nil
        selectedStopID = config.stops.first?.id
    }

    // MARK: - Export

    func exportString(for format: GradientExportFormat) -> String {
        switch format {
        case .swiftUI:     return GradientExportService.exportSwiftUI(config)
        case .swiftUIFill: return GradientExportService.exportSwiftUIFill(config)
        case .css:         return GradientExportService.exportCSS(config)
        case .uiKit:       return GradientExportService.exportUIKit(config)
        case .json:        return GradientExportService.exportJSON(config)
        }
    }

    func copyExport(for format: GradientExportFormat) {
        UIPasteboard.general.string = exportString(for: format)
        copiedLabel = format.rawValue
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }

    // MARK: - Helpers

    private func interpolatedColor(at position: Double) -> Color {
        let sorted = config.sortedStops
        guard sorted.count >= 2 else { return .purple }

        // Find surrounding stops
        var lower = sorted.first!
        var upper = sorted.last!
        for stop in sorted {
            if stop.position <= position { lower = stop }
            if stop.position >= position && stop.position >= lower.position {
                upper = stop
                break
            }
        }

        let range = upper.position - lower.position
        let t = range > 0 ? (position - lower.position) / range : 0.5

        let lc = GradientExportService.components(lower.color)
        let uc = GradientExportService.components(upper.color)
        return Color(
            red:   lc.r + (uc.r - lc.r) * t,
            green: lc.g + (uc.g - lc.g) * t,
            blue:  lc.b + (uc.b - lc.b) * t
        )
    }
}

// MARK: - Export Format

enum GradientExportFormat: String, CaseIterable, Identifiable {
    case swiftUI     = "SwiftUI"
    case swiftUIFill = "Fill Shorthand"
    case css         = "CSS"
    case uiKit       = "UIKit"
    case json        = "JSON"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .swiftUI:     return "swift"
        case .swiftUIFill: return "paintbrush"
        case .css:         return "globe"
        case .uiKit:       return "iphone"
        case .json:        return "curlybraces"
        }
    }
}
