//
//  BorderDecorationViewModel.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI
import Observation

@Observable
final class BorderDecorationViewModel {

    // MARK: - Tab
    var selectedTab: DecorationTab = .corners

    // MARK: - Preview
    var selectedShape: PreviewShape = .card

    // MARK: - Configs (one per tab, persistent while switching)
    var cornerConfig: CornerConfig   = CornerConfig()
    var borderConfig: BorderConfig   = BorderConfig()
    var glowConfig: GlowConfig       = GlowConfig()
    var patternConfig: PatternConfig = PatternConfig()

    // MARK: - Export
    var showExportSheet: Bool = false
    var showCopiedToast: Bool = false
    var copiedLabel: String   = ""

    // MARK: - Active config description (for toolbar badge)
    var activeDescription: String {
        switch selectedTab {
        case .corners:  return "r:\(Int(cornerConfig.radius)) .\(cornerConfig.style.rawValue.lowercased())"
        case .borders:  return "\(borderConfig.styleType.rawValue) \(BorderDecorationExportService.f(borderConfig.width))px"
        case .glow:     return "\(glowConfig.type.rawValue) r:\(Int(glowConfig.radius))"
        case .patterns: return "\(patternConfig.patternType.rawValue) \(Int(patternConfig.scale))pt"
        }
    }

    // MARK: - Preset application
    func applyPreset(_ preset: DecorationPreset) {
        if let c = preset.cornerConfig  { cornerConfig  = c }
        if let b = preset.borderConfig  { borderConfig  = b }
        if let g = preset.glowConfig    { glowConfig    = g }
        if let p = preset.patternConfig { patternConfig = p }
    }

    // MARK: - Export
    var exportCode: String {
        switch selectedTab {
        case .corners:  return BorderDecorationExportService.exportCorners(cornerConfig)
        case .borders:  return BorderDecorationExportService.exportBorder(borderConfig)
        case .glow:     return BorderDecorationExportService.exportGlow(glowConfig)
        case .patterns: return BorderDecorationExportService.exportPattern(patternConfig)
        }
    }

    func copyCode() {
        UIPasteboard.general.string = exportCode
        showToast(label: "\(selectedTab.rawValue) code")
    }

    private func showToast(label: String) {
        copiedLabel = label
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation { self?.showCopiedToast = false }
        }
    }

    // MARK: - Reset
    func reset() {
        switch selectedTab {
        case .corners:  cornerConfig  = CornerConfig()
        case .borders:  borderConfig  = BorderConfig()
        case .glow:     glowConfig    = GlowConfig()
        case .patterns: patternConfig = PatternConfig()
        }
    }
}
