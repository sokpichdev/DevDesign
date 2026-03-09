//
//  ShimmerView.swift
//  DevDesign
//
//  Created by Sok Pich on 09/03/2026.
//

import SwiftUI

struct ShimmerView: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(DSColors.Preview.backgroundSecondary)
                .overlay(
                    LinearGradient(
                        stops: [
                            .init(color: DSColors.Preview.backgroundSecondary, location: 0),
                            .init(color: DSColors.Preview.backgroundTertiary,  location: 0.4),
                            .init(color: DSColors.Preview.backgroundSecondary, location: 0.8),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: geo.size.width * phase)
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}
