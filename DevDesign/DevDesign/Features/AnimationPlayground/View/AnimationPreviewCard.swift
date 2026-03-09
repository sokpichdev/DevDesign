//
//  AnimationPreviewCard.swift
//  DevDesign
//
//  Created by Sok Pich on 3/9/26.
//

import SwiftUI

struct AnimationPreviewCard: View {

    @Bindable var viewModel: AnimationViewModel
    let accentColor: Color

    var body: some View {
        VStack(spacing: 0) {

            // ── Target selector ──────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(AnimationPreviewTarget.allCases) { target in
                        let isSelected = viewModel.selectedTarget == target
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.selectedTarget = target
                                viewModel.isAnimating = false
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: target.icon)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(target.rawValue)
                                    .font(DSTypography.labelLarge)
                            }
                            .foregroundStyle(isSelected ? .white : DSColors.Preview.textSecondary)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(
                                isSelected ? accentColor : DSColors.Preview.surfaceDefault,
                                in: Capsule()
                            )
                            .overlay(
                                Capsule().strokeBorder(
                                    isSelected ? Color.clear : DSColors.Preview.borderSubtle,
                                    lineWidth: 1
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
                    }
                }
                .padding(.horizontal, DSSpacing.screenPadding)
            }
            .padding(.vertical, DSSpacing.sm)

            Divider().background(DSColors.Preview.borderSubtle)

            // ── Preview canvas ────────────────────────────────────
            ZStack {
                DSColors.Preview.backgroundSecondary

                // Track line / guides
                guides

                // Animated shape
                animatedShape
                    .frame(width: 64, height: 64)
            }
            .frame(height: 180)
            .clipShape(Rectangle())

            Divider().background(DSColors.Preview.borderSubtle)

            // ── Playback controls ─────────────────────────────────
            playbackControls
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.vertical, DSSpacing.sm)
        }
        .background(DSColors.Preview.surfaceDefault,
                    in: RoundedRectangle(cornerRadius: DSSpacing.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.Radius.md)
                .strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Guides
    @ViewBuilder
    private var guides: some View {
        switch viewModel.selectedTarget {
        case .slide:
            // Horizontal track
            HStack { Divider() }
                .opacity(0.3)
            // Start / end markers
            HStack {
                RoundedRectangle(cornerRadius: 1)
                    .fill(accentColor.opacity(0.3))
                    .frame(width: 2, height: 120)
                Spacer()
                RoundedRectangle(cornerRadius: 1)
                    .fill(accentColor.opacity(0.3))
                    .frame(width: 2, height: 120)
            }
            .padding(.horizontal, 40)

        case .bounce:
            // Floor line
            VStack {
                Spacer()
                Rectangle()
                    .fill(accentColor.opacity(0.25))
                    .frame(height: 2)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
            }

        default:
            EmptyView()
        }
    }

    // MARK: - Animated Shape
    @ViewBuilder
    private var animatedShape: some View {
        switch viewModel.selectedTarget {

        case .slide:
            shape
                .offset(x: viewModel.isAnimating ? 90 : -90)
                .animation(viewModel.config.swiftUIAnimation, value: viewModel.isAnimating)

        case .scale:
            shape
                .scaleEffect(viewModel.isAnimating ? 1.0 : 0.25)
                .animation(viewModel.config.swiftUIAnimation, value: viewModel.isAnimating)

        case .fade:
            shape
                .opacity(viewModel.isAnimating ? 1.0 : 0.05)
                .animation(viewModel.config.swiftUIAnimation, value: viewModel.isAnimating)

        case .rotate:
            shape
                .rotationEffect(.degrees(viewModel.isAnimating ? 360 : 0))
                .animation(viewModel.config.swiftUIAnimation, value: viewModel.isAnimating)

        case .bounce:
            shape
                .offset(y: viewModel.isAnimating ? 40 : -50)
                .animation(viewModel.config.swiftUIAnimation, value: viewModel.isAnimating)

        case .morph:
            Group {
                if viewModel.isAnimating {
                    Circle()
                        .fill(shapeGradient)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(shapeGradient)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .animation(viewModel.config.swiftUIAnimation, value: viewModel.isAnimating)
        }
    }

    private var shape: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(shapeGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
    }

    private var shapeGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor, accentColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Playback Controls
    private var playbackControls: some View {
        HStack(spacing: DSSpacing.md) {

            // Loop toggle
            Button {
                if viewModel.isLooping {
                    viewModel.stopLoop()
                } else {
                    viewModel.startLoop()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.isLooping ? "stop.fill" : "repeat")
                        .font(.system(size: 13, weight: .semibold))
                    Text(viewModel.isLooping ? "Stop" : "Loop")
                        .font(DSTypography.labelLarge)
                }
                .foregroundStyle(viewModel.isLooping ? DSColors.Preview.error : DSColors.Preview.textSecondary)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .background(
                    viewModel.isLooping
                        ? DSColors.Preview.error.opacity(0.1)
                        : DSColors.Preview.backgroundSecondary,
                    in: Capsule()
                )
                .overlay(Capsule().strokeBorder(
                    viewModel.isLooping ? DSColors.Preview.error.opacity(0.4) : DSColors.Preview.borderSubtle,
                    lineWidth: 1
                ))
            }
            .buttonStyle(.plain)

            Spacer()

            // Replay
            Button {
                viewModel.replay()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Replay")
                        .font(DSTypography.labelLarge)
                }
                .foregroundStyle(DSColors.Preview.textSecondary)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .background(DSColors.Preview.backgroundSecondary, in: Capsule())
                .overlay(Capsule().strokeBorder(DSColors.Preview.borderSubtle, lineWidth: 1))
            }
            .buttonStyle(.plain)

            // Play / Pause
            Button {
                viewModel.trigger()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.isAnimating ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(viewModel.isAnimating ? "Pause" : "Play")
                        .font(DSTypography.headingSmall)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.xs)
                .background(accentColor, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}
