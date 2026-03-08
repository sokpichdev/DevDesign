//
//  HarmonyTypeSelectorView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Horizontal scrolling pill strip for selecting the harmony algorithm.

import SwiftUI

struct HarmonyTypeSelectorView: View {

    @Binding var selected: HarmonyType
    var onChange: (HarmonyType) -> Void = { _ in }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                ForEach(HarmonyType.allCases) { type in
                    HarmonyPillView(
                        type: type,
                        isSelected: selected == type,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selected = type
                            }
                            onChange(type)
                        }
                    )
                }
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.vertical, DSSpacing.xs)
        }
    }
}

// MARK: - Individual Pill
private struct HarmonyPillView: View {

    let type: HarmonyType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: type.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(type.rawValue)
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background {
                if isSelected {
                    Capsule().fill(DSColors.Preview.accent)
                } else {
                    Capsule().fill(DSColors.Preview.surfaceElevated)
                }
            }
            .overlay {
                if !isSelected {
                    Capsule()
                        .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        // Show a tooltip-style description on long press
        .help(type.description)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        DSColors.Preview.backgroundPrimary.ignoresSafeArea()
        HarmonyTypeSelectorView(selected: .constant(.complementary))
    }
}
