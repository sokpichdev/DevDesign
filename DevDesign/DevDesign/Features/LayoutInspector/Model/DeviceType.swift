//
//  DeviceType.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//
import SwiftUI

// MARK: - Device Types

enum DeviceType {
    case homeButton        // SE series - physical home button, no notch
    case faceIDNotch       // iPhone X-14 series - notch, ~44pt status
    case dynamicIsland     // iPhone 14 Pro-16 Pro series - Dynamic Island, ~54pt status
    case tablet            // iPad - no notch/DI, different safe areas
}

struct DeviceSpec: Identifiable {
    let id = UUID()
    let name: String
    let width: CGFloat      // Portrait width in points
    let height: CGFloat     // Portrait height in points
    let type: DeviceType
    let statusBarHeight: CGFloat
    let bottomSafeArea: CGFloat  // 34pt for Face ID, 0pt for Home Button, 20pt for iPad
    let cornerRadius: CGFloat    // Device corner radius for phone shell
    let screenCornerRadius: CGFloat // Screen corner radius
    
    var isPortrait: Bool = true
    
    var effectiveWidth: CGFloat { isPortrait ? width : height }
    var effectiveHeight: CGFloat { isPortrait ? height : width }
}

// MARK: - Device Library

extension DeviceSpec {
    static let allDevices: [DeviceSpec] = [
        // MARK: Home Button Devices
        DeviceSpec(
            name: "SE (3rd gen)",
            width: 375, height: 667,
            type: .homeButton,
            statusBarHeight: 20,
            bottomSafeArea: 0,
            cornerRadius: 30,
            screenCornerRadius: 28
        ),
        
        // MARK: Face ID Notch Devices
        DeviceSpec(
            name: "iPhone 14",
            width: 390, height: 844,
            type: .faceIDNotch,
            statusBarHeight: 47,
            bottomSafeArea: 34,
            cornerRadius: 44,
            screenCornerRadius: 40
        ),
        DeviceSpec(
            name: "iPhone 14 Plus",
            width: 428, height: 926,
            type: .faceIDNotch,
            statusBarHeight: 47,
            bottomSafeArea: 34,
            cornerRadius: 44,
            screenCornerRadius: 40
        ),
        
        // MARK: Dynamic Island Devices
        DeviceSpec(
            name: "iPhone 15",
            width: 390, height: 844,
            type: .dynamicIsland,
            statusBarHeight: 54,
            bottomSafeArea: 34,
            cornerRadius: 44,
            screenCornerRadius: 40
        ),
        DeviceSpec(
            name: "iPhone 15 Pro Max",
            width: 430, height: 932,
            type: .dynamicIsland,
            statusBarHeight: 54,
            bottomSafeArea: 34,
            cornerRadius: 44,
            screenCornerRadius: 40
        ),
        DeviceSpec(
            name: "iPhone 16 Pro",
            width: 402, height: 874,
            type: .dynamicIsland,
            statusBarHeight: 54,
            bottomSafeArea: 34,
            cornerRadius: 44,
            screenCornerRadius: 40
        ),
        
        // MARK: Tablets
        DeviceSpec(
            name: "iPad Pro 11\"",
            width: 834, height: 1194,
            type: .tablet,
            statusBarHeight: 24,
            bottomSafeArea: 20,
            cornerRadius: 24,
            screenCornerRadius: 20
        ),
        DeviceSpec(
            name: "iPad Pro 13\"",
            width: 1024, height: 1366,
            type: .tablet,
            statusBarHeight: 24,
            bottomSafeArea: 20,
            cornerRadius: 28,
            screenCornerRadius: 24
        ),
    ]
}
