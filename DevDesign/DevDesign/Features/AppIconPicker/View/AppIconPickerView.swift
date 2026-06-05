//
//  AppIconPickerView.swift
//  DevDesign
//
//  Created by Sok Pich on 10/03/2026.
//

import SwiftUI

struct AppIconPickerView: View {

    @State private var vm = AppIconPickerViewModel()
    private let accent = Color(hex: "#7B6EF6")

    // 2-column grid
    private let columns = [GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ZStack {
            DSColors.Preview.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DSSpacing.lg) {
                    headerCard
                    iconGrid
                    applyButton
                    Spacer(minLength: DSSpacing.xxxl)
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
            }
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if vm.showSuccess  { successToast }
            if let msg = vm.errorMessage { errorToast(msg) }
        }
    }

    // MARK: - Header card

    private var headerCard: some View {
        HStack(spacing: DSSpacing.md) {
            // Live current icon preview
            Image(uiImage: currentIconImage())
                .resizable()
                .interpolation(.high)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: vm.currentVariant.accent.opacity(0.35),
                        radius: 10, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("DevDesign")
                    .font(DSTypography.headingMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Text("Current: \(vm.currentVariant.label)")
                    .font(DSTypography.bodySmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                Text(vm.currentVariant.description)
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }

            Spacer()
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Icon grid

    private var iconGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(AppIconVariant.allCases) { variant in
                iconCard(variant)
            }
        }
    }

    private func iconCard(_ variant: AppIconVariant) -> some View {
        let isSelected = vm.selectedVariant == variant
        let isCurrent  = vm.currentVariant  == variant

        return Button { vm.select(variant) } label: {
            VStack(spacing: DSSpacing.sm) {

                ZStack(alignment: .topTrailing) {
                    // Icon image
                    Image(uiImage: iconImage(for: variant))
                        .resizable()
                        .interpolation(.high)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .shadow(color: variant.accent.opacity(isSelected ? 0.45 : 0.15),
                                radius: isSelected ? 14 : 6, x: 0, y: 4)
                        .scaleEffect(isSelected ? 1.04 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

                    // Checkmark badge
                    if isCurrent {
                        ZStack {
                            Circle()
                                .fill(variant.accent)
                                .frame(width: 26, height: 26)
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .offset(x: 6, y: -6)
                        .transition(.scale.combined(with: .opacity))
                    }
                }

                // Label row
                VStack(spacing: 2) {
                    Text(variant.label)
                        .font(DSTypography.headingSmall)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                    Text(variant.description)
                        .font(DSTypography.labelSmall)
                        .foregroundStyle(DSColors.Preview.textTertiary)
                        .lineLimit(1)
                }
            }
            .padding(DSSpacing.sm)
            .background(
                isSelected
                    ? variant.accent.opacity(0.08)
                    : DSColors.Preview.surfaceDefault,
                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                    .strokeBorder(
                        isSelected ? variant.accent : DSColors.Preview.borderSubtle,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Apply button

    private var applyButton: some View {
        Button { vm.apply() } label: {
            HStack(spacing: DSSpacing.sm) {
                if vm.isApplying {
                    ProgressView()
                        .scaleEffect(0.85)
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(vm.isApplying
                     ? "Applying…"
                     : vm.hasUnsavedChange
                       ? "Apply \(vm.selectedVariant.label)"
                       : "Applied")
                    .font(DSTypography.headingSmall)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .background(
                vm.hasUnsavedChange
                    ? vm.selectedVariant.accent
                    : DSColors.Preview.textTertiary,
                in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
            )
        }
        .buttonStyle(.plain)
        .disabled(!vm.hasUnsavedChange || vm.isApplying)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: vm.hasUnsavedChange)
    }

    // MARK: - Toasts

    private var successToast: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "app.badge.checkmark.fill")
                .foregroundStyle(DSColors.Preview.success)
            Text("App icon updated!")
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
        .padding(.bottom, DSSpacing.xl)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal:   .opacity
        ))
    }

    private func errorToast(_ msg: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(DSColors.Preview.error)
            Text(msg)
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .lineLimit(2)
            Spacer()
            Button { vm.dismissError() } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(.ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.error.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, DSSpacing.screenPadding)
        .padding(.bottom, DSSpacing.xl)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal:   .opacity
        ))
    }

    // MARK: - Image helpers

    /// Loads the icon image from the asset catalog by its alternate icon name.
    /// Falls back to a solid-colour placeholder if the asset isn't found yet.
    private func iconImage(for variant: AppIconVariant) -> UIImage {
        let assetName = variant.iconName ?? "AppIcon"
        if let img = UIImage(named: assetName) { return img }
        // Placeholder: solid colour block (will never appear in production)
        return solidColour(variant.accent, size: CGSize(width: 120, height: 120))
    }

    private func currentIconImage() -> UIImage {
        iconImage(for: vm.currentVariant)
    }

    private func solidColour(_ color: Color, size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor(color).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AppIconPickerView()
    }
}
