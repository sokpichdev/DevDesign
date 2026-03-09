//
//  SafeAreaInspectorView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct SafeAreaInspectorView: View {

    @State private var selectedDeviceIndex: Int = 2  // Default to iPhone 15
    @State private var isLandscape: Bool = false
    @State private var showingPortrait: Bool = true
    
    private var device: DeviceSpec {
        var d = DeviceSpec.allDevices[selectedDeviceIndex]
        d.isPortrait = !isLandscape
        return d
    }
    
    private var scale: CGFloat {
        // Adjust scale based on device type for better fit
        switch device.type {
        case .tablet:
            return 0.35  // Smaller scale for large iPads
        default:
            return 0.52
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: DSSpacing.md) {

                // Device picker + orientation toggle
                deviceControls

                // iPhone diagram
                phoneDiagram

                // Legend
                legendCard

                // Spacing reference card
                spacingReferenceCard

                Spacer(minLength: DSSpacing.xxxl)
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.top, DSSpacing.md)
        }
    }

    // MARK: - Device Controls
    private var deviceControls: some View {
        VStack(spacing: DSSpacing.sm) {
            // Device picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(Array(DeviceSpec.allDevices.enumerated()), id: \.element.id) { index, dev in
                        let isSelected = selectedDeviceIndex == index
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedDeviceIndex = index
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text(dev.name)
                                    .font(DSTypography.labelLarge)
                                Text("\(Int(dev.width))×\(Int(dev.height))")
                                    .font(.system(size: 10, weight: .medium))
                                    .opacity(0.7)
                            }
                            .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                            .frame(minWidth: 80)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(
                                isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceDefault,
                                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                                    .strokeBorder(
                                        isSelected ? Color.clear : DSColors.Preview.borderSubtle,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Orientation toggle
//            HStack(spacing: DSSpacing.sm) {
//                orientationButton(isPortrait: true, icon: "iphone", label: "Portrait")
//                orientationButton(isPortrait: false, icon: "iphone.landscape", label: "Landscape")
//            }
        }
    }
    
    private func orientationButton(isPortrait: Bool, icon: String, label: String) -> some View {
        let isSelected = self.isLandscape != isPortrait
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                self.isLandscape = !isPortrait
            }
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: icon)
                Text(label)
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.xs)
            .background(
                isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceDefault,
                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(
                        isSelected ? Color.clear : DSColors.Preview.borderSubtle,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Phone Diagram
    private var phoneDiagram: some View {
        let screenW = device.effectiveWidth * scale
        let screenH = device.effectiveHeight * scale
        let phoneW = screenW + 14  // 7pt bezel each side
        let phoneH = screenH + 20  // 10pt bezel top/bottom
        
        let isHomeButton = device.type == .homeButton
        let hasDynamicIsland = device.type == .dynamicIsland
        let hasNotch = device.type == .faceIDNotch
        let isTablet = device.type == .tablet
        
        let statusH = device.statusBarHeight * scale
        let navH: CGFloat = 44 * scale
        let tabH: CGFloat = isTablet ? 50 * scale : 49 * scale
        let homeButtonH: CGFloat = isHomeButton ? 44 * scale : 0
        
        // Calculate content height
        let bottomAreaH = tabH + homeButtonH
        let contentH = max(screenH - statusH - navH - bottomAreaH, 40)
        
        // Landscape adjustments
        let effectiveStatusH = isLandscape ? 0 : statusH  // No status bar in landscape for most apps
        let effectiveNavH = isLandscape ? 32 * scale : navH  // Smaller nav bar in landscape
        let effectiveTabH = isLandscape ? (isTablet ? 50 * scale : 49 * scale) : tabH
        let effectiveContentH = isLandscape
            ? max(screenH - effectiveNavH - effectiveTabH, 40)
            : contentH

        return VStack(spacing: DSSpacing.sm) {
            HStack {
                Text(device.name + (isLandscape ? " · Landscape" : " · Portrait"))
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                Spacer()
                Text("\(Int(device.effectiveWidth))×\(Int(device.effectiveHeight))pt")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .padding(.horizontal, DSSpacing.xxs)

            ZStack(alignment: .top) {
                // Phone/tablet shell
                RoundedRectangle(cornerRadius: device.cornerRadius * scale)
                    .fill(DSColors.Preview.backgroundTertiary)
                    .frame(width: phoneW, height: phoneH)
                    .overlay(
                        RoundedRectangle(cornerRadius: device.cornerRadius * scale)
                            .strokeBorder(DSColors.Preview.textTertiary.opacity(0.4), lineWidth: 2)
                    )

                // Screen content
                VStack(spacing: 0) {
                    
                    // Status bar zone (hidden in landscape for iPhone, visible for iPad)
                    if !isLandscape || isTablet {
                        ZStack {
                            Color(hex: "#FF6B6B").opacity(0.22)
                            
                            // Notch/Dynamic Island/Home Button speaker visual
                            if hasDynamicIsland {
                                // Dynamic Island pill
                                Capsule()
                                    .fill(DSColors.Preview.backgroundPrimary)
                                    .frame(width: 80 * scale, height: 28 * scale)
                            } else if hasNotch {
                                // Notch - wider and more rectangular
                                RoundedRectangle(cornerRadius: 20 * scale)
                                    .fill(DSColors.Preview.backgroundPrimary)
                                    .frame(width: 160 * scale, height: 28 * scale)
                            } else if isHomeButton {
                                // SE: small speaker slit
                                Capsule()
                                    .fill(DSColors.Preview.backgroundPrimary.opacity(0.6))
                                    .frame(width: 44 * scale, height: 6 * scale)
                                    .offset(y: 4 * scale)
                            }
                            // iPad has no notch visual
                            
                            // Status bar label
                            HStack {
                                Text(isTablet ? "Status Bar" : "Status")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(Color(hex: "#FF6B6B"))
                                Spacer()
                                Text("\(Int(device.statusBarHeight))pt")
                                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(Color(hex: "#FF6B6B").opacity(0.8))
                            }
                            .padding(.horizontal, 8)
                        }
                        .frame(height: statusH)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(Color(hex: "#FF6B6B").opacity(0.4))
                                .frame(height: 1)
                        }
                    }
                    
                    // Safe area top spacer for landscape (replaces status bar)
                    if isLandscape && !isTablet {
                        Color.clear
                            .frame(height: device.bottomSafeArea * scale)
                    }

                    // Nav bar zone
                    zoneBar(
                        isLandscape ? "Nav (Compact)" : "Nav Bar",
                        height: effectiveNavH,
                        color: Color(hex: "#FF9F0A"),
                        label2: isLandscape ? "32pt" : "44pt"
                    )

                    // Content zone
                    ZStack {
                        Color(hex: "#30D158").opacity(0.18)
                        VStack(spacing: 4) {
                            Text(isLandscape ? "Content" : "Content Area")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color(hex: "#30D158"))
                            Text("~\(Int(effectiveContentH / scale))pt")
                                .font(.system(size: 8))
                                .foregroundStyle(Color(hex: "#30D158").opacity(0.8))
                            
                            // Show bottom safe area note for Face ID devices
                            if !isHomeButton {
                                Text("(+\(Int(device.bottomSafeArea))pt bottom safe)")
                                    .font(.system(size: 7))
                                    .foregroundStyle(Color(hex: "#30D158").opacity(0.6))
                            }
                        }
                    }
                    .frame(height: effectiveContentH)

                    // Tab bar zone
                    ZStack(alignment: .bottom) {
                        Color(hex: "#7B6EF6").opacity(0.22)
                        
                        // Tab bar label at top of zone
                        HStack {
                            Text(isTablet ? "Tab Bar" : "Tab")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Color(hex: "#7B6EF6"))
                            Spacer()
                            Text(isTablet ? "50pt" : "49pt")
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color(hex: "#7B6EF6").opacity(0.8))
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                        .frame(maxHeight: .infinity, alignment: .top)
                        
                        // Visual indicator for home indicator on Face ID devices
                        if !isHomeButton {
                            VStack(spacing: 0) {
                                Spacer()
                                // Thin home indicator line
                                RoundedRectangle(cornerRadius: 2 * scale)
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: min(120 * scale, screenW * 0.3), height: 4 * scale)
                                    .padding(.bottom, max(4 * scale, device.bottomSafeArea * scale * 0.2))
                            }
                        }
                    }
                    .frame(height: effectiveTabH)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Color(hex: "#7B6EF6").opacity(0.4))
                            .frame(height: 1)
                    }

                    // SE: physical home button area below tab bar
                    if isHomeButton && !isLandscape {
                        ZStack {
                            DSColors.Preview.backgroundSecondary
                            Circle()
                                .strokeBorder(DSColors.Preview.textTertiary.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 28 * scale, height: 28 * scale)
                        }
                        .frame(height: homeButtonH)
                    }
                }
                .frame(width: screenW, height: screenH)
                .clipShape(RoundedRectangle(cornerRadius: device.screenCornerRadius * scale))
                .padding(.top, 10) // Center screen within phone shell
            }
            .frame(height: phoneH)
        }
    }

    private func zoneBar(_ label: String, height: CGFloat, color: Color, label2: String) -> some View {
        ZStack {
            color.opacity(0.22)
            HStack {
                Text(label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(color)
                Spacer()
                Text(label2)
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(color.opacity(0.8))
            }
            .padding(.horizontal, 8)
        }
        .frame(height: height)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(height: 1)
        }
    }

    // MARK: - Legend
    private var legendCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(safeAreaGuides.enumerated()), id: \.element.id) { i, item in
                HStack(spacing: DSSpacing.sm) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(item.color)
                        .frame(width: 14, height: 14)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.label)
                            .font(DSTypography.labelLarge)
                            .foregroundStyle(DSColors.Preview.textPrimary)
                        Text(item.description)
                            .font(DSTypography.labelSmall)
                            .foregroundStyle(DSColors.Preview.textTertiary)
                    }
                    Spacer()
                }
                .padding(DSSpacing.sm)
                if i < safeAreaGuides.count - 1 {
                    Divider().background(DSColors.Preview.borderSubtle)
                }
            }
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Spacing Reference
    private var spacingReferenceCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("iOS Spacing Reference")
                .font(DSTypography.headingSmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(.horizontal, DSSpacing.xxs)

            VStack(spacing: 0) {
                ForEach(Array(spacingRef.enumerated()), id: \.offset) { i, row in
                    HStack(spacing: DSSpacing.sm) {
                        Text(row.0)
                            .font(DSTypography.labelLarge)
                            .foregroundStyle(DSColors.Preview.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(row.1)
                            .font(DSTypography.codeMedium)
                            .foregroundStyle(DSColors.Preview.accent)

                        // Visual bar
                        let frac = min(CGFloat(row.2) / 96, 1)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(DSColors.Preview.backgroundTertiary)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(DSColors.Preview.accent.opacity(0.6))
                                    .frame(width: geo.size.width * frac)
                            }
                        }
                        .frame(width: 80, height: 6)
                    }
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 10)
                    if i < spacingRef.count - 1 {
                        Divider().background(DSColors.Preview.borderSubtle)
                    }
                }
            }
            .background(DSColors.Preview.surfaceDefault,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
        }
    }

    private let spacingRef: [(String, String, Int)] = [
        ("Screen horizontal margin", "16pt",  16),
        ("Card padding",             "16pt",  16),
        ("List row height (min)",    "44pt",  44),
        ("Nav bar height",           "44pt",  44),
        ("Nav bar height (landscape)", "32pt", 32),
        ("Tab bar height",           "49pt",  49),
        ("Tab bar height (iPad)",    "50pt",  50),
        ("Touch target (min)",       "44pt",  44),
        ("Bottom safe area (Face ID)", "34pt", 34),
        ("Bottom safe area (iPad)",  "20pt",  20),
        ("Status bar (Dynamic Island)", "54pt", 54),
        ("Status bar (notch)",       "44pt",  44),
        ("Icon size (small)",        "24pt",  24),
        ("Icon size (medium)",       "28pt",  28),
        ("Corner radius (card)",     "12pt",  12),
        ("Corner radius (sheet)",    "20pt",  20),
    ]
}
