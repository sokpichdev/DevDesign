//
//  GradientStopEditor.swift
//  DevDesign
//
//  Created by Sok Pich on 08/03/2026.
//
// The horizontal stop strip:
//   - Live gradient bar
//   - Diamond handles for each stop — drag to reposition
//   - Tap to select, long-press to remove
//   - + button to add a stop at the tapped position

import SwiftUI

struct GradientStopEditor: View {

    @Bindable var viewModel: GradientViewModel

    // Track width captured by GeometryReader
    @State private var trackWidth: CGFloat = 0
    @State private var draggingID: UUID? = nil

    private let trackHeight: CGFloat = 44
    private let handleSize: CGFloat  = 22

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            // Header
            HStack {
                Text("Color Stops")
                    .font(DSTypography.headingSmall)
                    .foregroundStyle(DSColors.Preview.textPrimary)

                Text("\(viewModel.config.stops.count)/6")
                    .font(DSTypography.labelMedium)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, 2)
                    .background(DSColors.Preview.backgroundTertiary, in: Capsule())

                Spacer()

                if viewModel.canAddStop {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.addStop()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text("Add Stop")
                                .font(DSTypography.labelLarge)
                        }
                        .foregroundStyle(DSColors.Preview.accent)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xxs)
                        .background(DSColors.Preview.accent.opacity(0.12), in: Capsule())
                        .overlay(Capsule().strokeBorder(DSColors.Preview.accent.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSSpacing.xxs)

            // Track + handles
            ZStack(alignment: .center) {
                GeometryReader { geo in
                    let w = geo.size.width
                    Color.clear
                        .onAppear { trackWidth = w }
                        .onChange(of: geo.size.width) { _, v in trackWidth = v }

                    // Gradient bar
                    gradientBar
                        .frame(height: trackHeight)
                        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSSpacing.Radius.sm)
                                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
                        )

                    // Handles
                    ForEach(viewModel.config.stops) { stop in
                        stopHandle(stop: stop, trackWidth: w)
                    }
                }
            }
            .frame(height: trackHeight + handleSize)

            // Selected stop controls
            if let stop = viewModel.selectedStop,
               let id = viewModel.selectedStopID {
                selectedStopControls(stop: stop, id: id)
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
                   value: viewModel.selectedStopID)
    }

    // MARK: - Gradient Bar
    private var gradientBar: some View {
        Group {
            switch viewModel.config.type {
            case .linear, .radial, .angular:
                // Always show linear in the strip for clarity
                Rectangle()
                    .fill(
                        LinearGradient(
                            stops: viewModel.config.sortedStops.map(\.gradientStop),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }

    // MARK: - Stop Handle
    private func stopHandle(stop: GradientStop, trackWidth: CGFloat) -> some View {
        let isSelected = viewModel.selectedStopID == stop.id
        let xPos = stop.position * trackWidth

        return ZStack {
            // Shadow under handle
            Diamond()
                .fill(Color.black.opacity(0.3))
                .frame(width: handleSize, height: handleSize)
                .offset(x: 0, y: 2)
                .blur(radius: 2)

            // Handle body
            Diamond()
                .fill(stop.color)
                .frame(width: handleSize, height: handleSize)
                .overlay(
                    Diamond()
                        .stroke(
                            isSelected ? DSColors.Preview.accent : .white,
                            lineWidth: isSelected ? 2.5 : 1.5
                        )
                )
                .scaleEffect(draggingID == stop.id ? 1.2 : (isSelected ? 1.1 : 1.0))
        }
        .frame(width: handleSize, height: handleSize)
        .position(x: xPos, y: trackHeight / 2)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    draggingID = stop.id
                    viewModel.selectedStopID = stop.id
                    let newPos = min(max(value.location.x / trackWidth, 0), 1)
                    viewModel.updateStopPosition(newPos, id: stop.id)
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        draggingID = nil
                    }
                }
        )
        // Only spring the handle back on release, not during active drag
        .animation(draggingID == stop.id ? .none : .spring(response: 0.25, dampingFraction: 0.8),
                   value: stop.position)
        .animation(.spring(response: 0.2, dampingFraction: 0.8),
                   value: isSelected)
        .zIndex(isSelected ? 1 : 0)
    }

    // MARK: - Selected Stop Controls
    private func selectedStopControls(stop: GradientStop, id: UUID) -> some View {
        HStack(spacing: DSSpacing.md) {
            // Color picker — using label+button pattern to avoid trailing closure issue
            VStack(alignment: .leading, spacing: 2) {
                Text("Color")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                let colorBinding = Binding<Color>(
                    get: { stop.color },
                    set: { newColor in viewModel.updateStopColor(newColor, id: id) }
                )
                ColorPicker("Pick color", selection: colorBinding, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 44, height: 32)
            }

            // Position
            VStack(alignment: .leading, spacing: 2) {
                Text("Position")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                HStack(spacing: 4) {
                    Slider(value: Binding(
                        get: { stop.position },
                        set: { viewModel.updateStopPosition($0, id: id) }
                    ), in: 0...1, step: 0.01)
                    .tint(DSColors.Preview.accent)
                    .frame(maxWidth: .infinity)

                    Text("\(Int(stop.position * 100))%")
                        .font(DSTypography.codeMedium)
                        .foregroundStyle(DSColors.Preview.textPrimary)
                        .frame(width: 38, alignment: .trailing)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.25, dampingFraction: 0.8),
                                   value: stop.position)
                }
            }

            // Hex readout
            VStack(alignment: .leading, spacing: 2) {
                Text("HEX")
                    .font(DSTypography.labelSmall)
                    .foregroundStyle(DSColors.Preview.textTertiary)
                Text(GradientExportService.hex(stop.color))
                    .font(DSTypography.codeMedium)
                    .foregroundStyle(DSColors.Preview.textPrimary)
            }

            // Remove
            if viewModel.canRemoveStop {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.removeStop(id: id)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(DSColors.Preview.error)
                        .frame(width: 32, height: 32)
                        .background(DSColors.Preview.error.opacity(0.1), in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.xs)
    }
}

// MARK: - Diamond Shape
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to:    CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
