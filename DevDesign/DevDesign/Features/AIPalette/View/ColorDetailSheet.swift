//
//  ColorDetailSheet.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import SwiftUI

struct ColorDetailSheet: View {
    let color:       AIColor
    let accentColor: Color
    let onCopy:      (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.Preview.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: DSSpacing.xl) {
                    largeSwatch
                    propertiesCard
                    copyButton
                    Spacer()
                }
            }
            .navigationTitle(color.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(accentColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.Preview.backgroundSecondary)
    }

    // MARK: - Sub-views

    private var largeSwatch: some View {
        RoundedRectangle(cornerRadius: DSSpacing.Radius.lg)
            .fill(color.color)
            .frame(height: 160)
            .overlay(
                VStack {
                    Text(color.name)
                        .font(DSTypography.headingLarge)
                        .foregroundStyle(color.onColor)
                    Text(color.hex.uppercased())
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(color.onColor.opacity(0.7))
                }
            )
            .shadow(color: color.color.opacity(0.4), radius: 16, x: 0, y: 8)
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.top, DSSpacing.md)
    }

    private var propertiesCard: some View {
        let r = Int(color.red   * 255)
        let g = Int(color.green * 255)
        let b = Int(color.blue  * 255)
        return VStack(spacing: 0) {
            row(label: "Role",  value: color.role,              icon: "tag")
            Divider().background(DSColors.Preview.borderSubtle)
            row(label: "Usage", value: color.usage,             icon: "pencil.and.ruler")
            Divider().background(DSColors.Preview.borderSubtle)
            row(label: "Hex",   value: color.hex.uppercased(),  icon: "number")
            Divider().background(DSColors.Preview.borderSubtle)
            row(label: "RGB",   value: "R:\(r) G:\(g) B:\(b)", icon: "slider.horizontal.3")
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .padding(.horizontal, DSSpacing.screenPadding)
    }

    private var copyButton: some View {
        Button { onCopy(color.hex); dismiss() } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "doc.on.doc.fill")
                Text("Copy \(color.hex.uppercased())")
                    .font(DSTypography.headingSmall)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .background(accentColor, in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DSSpacing.screenPadding)
    }

    // MARK: - Row helper

    private func row(label: String, value: String, icon: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: 20)
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 50, alignment: .leading)
            Spacer()
            Text(value)
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
    }
}
