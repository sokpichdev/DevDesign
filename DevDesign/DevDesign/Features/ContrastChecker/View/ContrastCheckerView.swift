//
//  ContrastCheckerView.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// Main Contrast Checker screen:
//   1. Live preview (FG text on BG)
//   2. Dual color selectors (FG + BG) with swap button
//   3. WCAG ratio + badges
//   4. Fix suggestions (only when failing)
//   5. Color blindness simulation grid

import SwiftUI

struct ContrastCheckerView: View {

    @State private var viewModel = ContrastCheckerViewModel()

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {

                    // 1. Live preview card
                    livePreviewCard

                    // 2. Color selectors
                    colorSelectorsSection

                    // 3. WCAG badges + ratio
                    WCAGBadgesView(viewModel: viewModel)

                    // 4. Fix suggestions — only when failing AA
                    if viewModel.hasSuggestions {
                        ContrastFixSuggestionView(viewModel: viewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal:   .opacity
                            ))
                    }

                    // 5. Color blindness preview
                    ColorBlindnessPreviewView(viewModel: viewModel)

                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
                .animation(.spring(response: 0.35, dampingFraction: 0.8),
                           value: viewModel.hasSuggestions)
            }
        }
        .navigationTitle("Contrast Checker")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Live Preview Card
    // Large preview showing FG text rendered on BG — the single most important
    // thing in any contrast checker.
    private var livePreviewCard: some View {
        ZStack {
            // Background fill
            viewModel.background.color
                .animation(.easeInOut(duration: 0.2), value: viewModel.background.hex)

            VStack(spacing: DSSpacing.sm) {
                // Simulated text
                Text("Aa")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.foreground.color)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.foreground.hex)

                Text("The quick brown fox")
                    .font(.system(size: 15))
                    .foregroundStyle(viewModel.foreground.color)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.foreground.hex)

                Text("jumps over the lazy dog")
                    .font(.system(size: 13))
                    .foregroundStyle(viewModel.foreground.color.opacity(0.7))
                    .animation(.easeInOut(duration: 0.2), value: viewModel.foreground.hex)
            }

            // Ratio pill overlay
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(viewModel.ratioString)
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(viewModel.background.isDark ? .white : .black)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .background(.ultraThinMaterial, in: Capsule())
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                                   value: viewModel.ratioString)
                }
                .padding(DSSpacing.sm)
            }
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Dual Color Selectors
    private var colorSelectorsSection: some View {
        VStack(spacing: DSSpacing.sm) {

            // Role tabs
            roleTabs

            // Active selector card
            Group {
                if viewModel.activeSelector == .foreground {
                    colorSelectorCard(
                        role: .foreground,
                        color: viewModel.foreground,
                        syncTrigger: viewModel.fgSyncTrigger,
                        setter: viewModel.setForeground
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    ))
                } else {
                    colorSelectorCard(
                        role: .background,
                        color: viewModel.background,
                        syncTrigger: viewModel.bgSyncTrigger,
                        setter: viewModel.setBackground
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8),
                       value: viewModel.activeSelector)

            // Swap button
            swapButton
        }
    }

    // MARK: - Role Tabs
    private var roleTabs: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach([ContrastCheckerViewModel.ColorRole.foreground,
                     ContrastCheckerViewModel.ColorRole.background], id: \.rawValue) { role in
                roleTab(role)
            }
            Spacer()

            // Color pair mini-preview
            HStack(spacing: 4) {
                colorDot(viewModel.foreground)
                Text("/")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                colorDot(viewModel.background)
            }
        }
    }

    private func roleTab(_ role: ContrastCheckerViewModel.ColorRole) -> some View {
        let isActive = viewModel.activeSelector == role
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.activeSelector = role
            }
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Circle()
                    .fill(role == .foreground
                          ? viewModel.foreground.color
                          : viewModel.background.color)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().strokeBorder(DSColors.Preview.borderDefault, lineWidth: 0.5))
                Text(role.rawValue)
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(isActive ? DSColors.Preview.textPrimary : DSColors.Preview.textTertiary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(isActive ? DSColors.Preview.surfaceElevated : Color.clear,
                        in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isActive ? DSColors.Preview.borderDefault : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func colorDot(_ color: DevColor) -> some View {
        Circle()
            .fill(color.color)
            .frame(width: 16, height: 16)
            .overlay(Circle().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
            .animation(.easeInOut(duration: 0.2), value: color.hex)
    }

    // MARK: - Single Color Selector Card
    private func colorSelectorCard(
        role: ContrastCheckerViewModel.ColorRole,
        color: DevColor,
        syncTrigger: Int,
        setter: @escaping (DevColor) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {

            // HEX chip above the picker
            HStack {
                RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                    .fill(color.color)
                    .frame(width: 20, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                            .strokeBorder(DSColors.Preview.borderDefault, lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 0.2), value: color.hex)

                Text(color.hex)
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: color.hex)

                Spacer()

                Text(role.rawValue)
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            ColorWheelPickerView(
                devColor: Binding(
                    get: { color },
                    set: { setter($0) }
                ),
                forceSyncTrigger: syncTrigger
            )
        }
    }

    // MARK: - Swap Button
    private var swapButton: some View {
        Button { viewModel.swapColors() } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 13, weight: .semibold))
                Text("Swap Colors")
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(DSColors.Preview.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.Preview.surfaceDefault,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ContrastCheckerView()
    }
}
