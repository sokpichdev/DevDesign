//
//  StackPlaygroundView.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct StackPlaygroundView: View {

    @Bindable var viewModel: LayoutViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: DSSpacing.md) {

                // 1. Type selector
                stackTypeSelector

                // 2. Live canvas
                liveCanvas

                // 3. Controls
                controlsCard

                // 4. Child list
                childrenCard

                // 5. Export preview
                exportCard

                Spacer(minLength: DSSpacing.xxxl)
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.top, DSSpacing.md)
        }
    }

    // MARK: - Type Selector
    private var stackTypeSelector: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(StackType.allCases) { type in
                let isSelected = viewModel.config.type == type
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.setStackType(type)
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: type.icon)
                            .font(.system(size: 18, weight: .medium))
                        Text(type.rawValue)
                            .font(DSTypography.labelLarge)
                    }
                    .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.sm)
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
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
            }
        }
    }

    // MARK: - Live Canvas
    private var liveCanvas: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Preview")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                // Overlay toggles
                HStack(spacing: DSSpacing.xs) {
                    overlayToggle("Spacing", value: $viewModel.config.showSpacingGuides, icon: "arrow.left.and.right")
                    overlayToggle("Align", value: $viewModel.config.showAlignmentGuides, icon: "line.horizontal.3")
                    overlayToggle("Size", value: $viewModel.config.showSizeLabels, icon: "ruler")
                }
            }
            .padding(.horizontal, DSSpacing.xxs)

            ZStack {
                // Canvas background
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .fill(DSColors.Preview.backgroundSecondary)

                // Alignment guide lines
                if viewModel.config.showAlignmentGuides {
                    alignmentGuideLines
                }

                // The actual stack
                stackPreview
                    .padding(DSSpacing.md)

                // Spacing overlays
                if viewModel.config.showSpacingGuides && viewModel.config.spacing > 0 {
                    spacingBadge
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
        }
    }

    private func overlayToggle(_ label: String, value: Binding<Bool>, icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                value.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(label)
                    .font(DSTypography.labelSmall)
            }
            .foregroundStyle(value.wrappedValue ? .white : DSColors.Preview.textTertiary)
            .padding(.horizontal, DSSpacing.xs)
            .padding(.vertical, 4)
            .background(
                value.wrappedValue ? DSColors.Preview.accent.opacity(0.8) : DSColors.Preview.surfaceElevated,
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Stack Preview
    @ViewBuilder
    private var stackPreview: some View {
        switch viewModel.config.type {
        case .hStack:
            HStack(alignment: hAlignment, spacing: viewModel.config.spacing) {
                childViews
            }
        case .vStack:
            VStack(alignment: vAlignment, spacing: viewModel.config.spacing) {
                childViews
            }
        case .zStack:
            ZStack(alignment: zAlignment) {
                childViews
            }
        }
    }

    @ViewBuilder
    private var childViews: some View {
        ForEach(viewModel.config.children) { child in
            childView(child)
                .overlay(
                    // Selection ring
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(
                            viewModel.selectedChildID == child.id
                                ? DSColors.Preview.accent : Color.clear,
                            lineWidth: 2
                        )
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.config.showSizeLabels {
                        sizeLabel(child)
                    }
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        viewModel.selectedChildID = viewModel.selectedChildID == child.id
                            ? nil : child.id
                    }
                }
        }
    }

    @ViewBuilder
    private func childView(_ child: ChildElement) -> some View {
        switch child.type {
        case .text:
            Text(child.text.isEmpty ? child.label : child.text)
                .font(DSTypography.bodySmall)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .padding(6)
                .background(child.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))

        case .rectangle:
            RoundedRectangle(cornerRadius: 6)
                .fill(child.color)
                .frame(
                    width: child.width > 0 ? child.width : nil,
                    height: child.height > 0 ? child.height : nil
                )

        case .circle:
            let dim = child.height > 0 ? child.height : 60
            Circle()
                .fill(child.color)
                .frame(width: dim, height: dim)

        case .image:
            RoundedRectangle(cornerRadius: 6)
                .fill(child.color)
                .frame(
                    width: child.width > 0 ? child.width : 60,
                    height: child.height > 0 ? child.height : 60
                )
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.7))
                )

        case .spacer:
            Spacer()
                .overlay(
                    Rectangle()
                        .fill(child.color)
                        .frame(height: 1)
                )

        case .divider:
            viewModel.config.type == .vStack
                ? AnyView(Divider())
                : AnyView(Divider().frame(width: 1).frame(height: 60))
        }
    }

    private func sizeLabel(_ child: ChildElement) -> some View {
        let w = child.width > 0 ? "\(Int(child.width))" : "flex"
        let h = child.height > 0 ? "\(Int(child.height))" : "flex"
        return Text("\(w)×\(h)")
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.6), in: Capsule())
            .offset(x: 2, y: -14)
    }

    private var spacingBadge: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("spacing: \(Int(viewModel.config.spacing))pt")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DSColors.Preview.accent)
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, 3)
                    .background(DSColors.Preview.accent.opacity(0.1),
                                in: Capsule())
                    .padding(DSSpacing.xs)
            }
        }
    }

    private var alignmentGuideLines: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { p in
                // Centre crosshair
                p.move(to: CGPoint(x: w / 2, y: 0))
                p.addLine(to: CGPoint(x: w / 2, y: h))
                p.move(to: CGPoint(x: 0, y: h / 2))
                p.addLine(to: CGPoint(x: w, y: h / 2))
            }
            .stroke(DSColors.Preview.accent.opacity(0.2),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
    }

    // MARK: - Alignment Conversions
    private var hAlignment: VerticalAlignment {
        switch viewModel.config.alignment {
        case .top:               return .top
        case .bottom:            return .bottom
        case .firstTextBaseline: return .firstTextBaseline
        default:                 return .center
        }
    }

    private var vAlignment: HorizontalAlignment {
        switch viewModel.config.alignment {
        case .leading:  return .leading
        case .trailing: return .trailing
        default:        return .center
        }
    }

    private var zAlignment: Alignment {
        switch viewModel.config.alignment {
        case .topLeading:     return .topLeading
        case .top:            return .top
        case .topTrailing:    return .topTrailing
        case .leading:        return .leading
        case .trailing:       return .trailing
        case .bottomLeading:  return .bottomLeading
        case .bottom:         return .bottom
        case .bottomTrailing: return .bottomTrailing
        default:              return .center
        }
    }

    // MARK: - Controls Card
    private var controlsCard: some View {
        VStack(spacing: DSSpacing.sm) {
            // Alignment
            HStack {
                Text("Alignment")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
            }
            .padding(.horizontal, DSSpacing.xxs)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(StackAlignment.options(for: viewModel.config.type)) { align in
                        let isSelected = viewModel.config.alignment == align
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                viewModel.setAlignment(align)
                            }
                        } label: {
                            Text(".\(align.rawValue)")
                                .font(DSTypography.codeMedium)
                                .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                                .padding(.horizontal, DSSpacing.sm)
                                .padding(.vertical, DSSpacing.xs)
                                .background(
                                    isSelected ? DSColors.Preview.accent : DSColors.Preview.surfaceElevated,
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
                    }
                }
            }

            // Spacing slider (ZStack has no spacing)
            if viewModel.config.type != .zStack {
                Divider().background(DSColors.Preview.borderSubtle)
                HStack(spacing: DSSpacing.sm) {
                    Text("Spacing")
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                        .frame(width: 60, alignment: .leading)
                    Slider(value: Binding(
                        get: { viewModel.config.spacing },
                        set: { viewModel.setSpacing($0) }
                    ), in: 0...48, step: 2)
                    .tint(DSColors.Preview.accent)
                    Text("\(Int(viewModel.config.spacing))pt")
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .frame(width: 36, alignment: .trailing)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.25, dampingFraction: 0.8),
                                   value: viewModel.config.spacing)
                }
            }
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Children Card
    private var childrenCard: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                Text("Children (\(viewModel.config.children.count)/8)")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                if viewModel.canAddChild {
                    addChildMenu
                }
            }
            .padding(.horizontal, DSSpacing.xxs)

            // Child rows
            VStack(spacing: DSSpacing.xs) {
                ForEach(viewModel.config.children) { child in
                    childRow(child)
                }
            }

            // Selected child dimension editor
            if let id = viewModel.selectedChildID,
               let child = viewModel.selectedChild {
                Divider().background(DSColors.Preview.borderSubtle)
                selectedChildEditor(child: child, id: id)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                   value: viewModel.selectedChildID)
    }

    private var addChildMenu: some View {
        Menu {
            ForEach(ChildElementType.allCases) { type in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.addChild(type: type)
                    }
                } label: {
                    Label(type.rawValue, systemImage: type.icon)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                Text("Add")
                    .font(DSTypography.labelLarge)
            }
            .foregroundStyle(DSColors.Preview.accent)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs)
            .background(DSColors.Preview.accent.opacity(0.12), in: Capsule())
            .overlay(Capsule().strokeBorder(DSColors.Preview.accent.opacity(0.3), lineWidth: 1))
        }
    }

    private func childRow(_ child: ChildElement) -> some View {
        let isSelected = viewModel.selectedChildID == child.id
        return HStack(spacing: DSSpacing.sm) {
            // Color dot
            Circle()
                .fill(child.color)
                .frame(width: 12, height: 12)

            // Type icon
            Image(systemName: child.type.icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DSColors.Preview.textSecondary)

            // Label
            Text(child.label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(isSelected ? DSColors.Preview.accent : DSColors.Preview.textPrimary)

            Spacer()

            // Duplicate
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.duplicateChild(id: child.id)
                }
            } label: {
                Image(systemName: "plus.square.on.square")
                    .font(.system(size: 12))
                    .foregroundStyle(DSColors.Preview.textTertiary)
            }
            .buttonStyle(.plain)

            // Delete
            if viewModel.canRemoveChild {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.removeChild(id: child.id)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundStyle(DSColors.Preview.error)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(
            isSelected ? DSColors.Preview.accent.opacity(0.08) : Color.clear,
            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.xs)
                .strokeBorder(isSelected ? DSColors.Preview.accent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.selectedChildID = isSelected ? nil : child.id
            }
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
    }

    private func selectedChildEditor(child: ChildElement, id: UUID) -> some View {
        VStack(spacing: DSSpacing.sm) {
            Text("Edit: \(child.label)")
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Width & height sliders (not for Spacer/Divider)
            if child.type != .spacer && child.type != .divider {
                dimSlider("Width", value: Binding(
                    get: { child.width },
                    set: { v in viewModel.updateChild(id: id) { $0.width = max(0, v) } }
                ), unit: "pt")

                dimSlider("Height", value: Binding(
                    get: { child.height },
                    set: { v in viewModel.updateChild(id: id) { $0.height = max(0, v) } }
                ), unit: "pt")
            }

            // Color picker
            if child.type != .spacer && child.type != .divider {
                HStack(spacing: DSSpacing.sm) {
                    Text("Color")
                        .font(DSTypography.labelLarge)
                        .foregroundStyle(DSColors.Preview.textSecondary)
                        .frame(width: 50, alignment: .leading)
                    let colorBinding = Binding<Color>(
                        get: { child.color },
                        set: { v in viewModel.updateChild(id: id) { $0.color = v } }
                    )
                    ColorPicker("", selection: colorBinding, supportsOpacity: true)
                        .labelsHidden()
                        .frame(width: 44, height: 32)
                    Spacer()
                }
            }
        }
    }

    private func dimSlider(_ label: String, value: Binding<CGFloat>, unit: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(DSTypography.labelLarge)
                .foregroundStyle(DSColors.Preview.textSecondary)
                .frame(width: 50, alignment: .leading)
            Slider(value: value, in: 0...200, step: 4)
                .tint(DSColors.Preview.accent)
            let display = value.wrappedValue == 0
                ? "flex"
                : "\(Int(value.wrappedValue))\(unit)"
            Text(display)
                .font(DSTypography.codeMedium)
                .foregroundStyle(DSColors.Preview.textPrimary)
                .frame(width: 44, alignment: .trailing)
                .contentTransition(.numericText())
        }
    }

    // MARK: - Export Card
    private var exportCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Generated Code")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                Spacer()
                Button {
                    viewModel.showExportSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.forward.square")
                        Text("Expand")
                    }
                    .font(DSTypography.labelLarge)
                    .foregroundStyle(DSColors.Preview.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DSSpacing.xxs)

            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                Text(viewModel.exportedCode())
                    .font(DSTypography.codeSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 160)
            .padding(DSSpacing.sm)
            .background(DSColors.Preview.backgroundPrimary,
                        in: RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                    .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
            )
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.15), value: viewModel.config.type)

            Button {
                viewModel.copyExport()
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "doc.on.doc.fill")
                    Text("Copy Code")
                        .font(DSTypography.headingSmall)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
                .background(DSColors.Preview.accent,
                            in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }
}
