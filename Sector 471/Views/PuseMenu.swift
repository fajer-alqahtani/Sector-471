//
//  PuseMenu.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//


import SwiftUI

struct PuseMenu: View {
    var onContinue: () -> Void

    @EnvironmentObject private var accessibility: AppAccessibilitySettings

   
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    @State private var showSitting = false

    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height

            ZStack {
                Color.black.opacity(0.001).ignoresSafeArea()

                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

                VStack(spacing: 30) {
                    Button("Continue") { onContinue() }
                        .appFixedFont(40, settings: accessibility)
                        .foregroundStyle(.white)
                        .buttonStyle(buttonStyle(cornerRadius: 8))

                    Button("Settings") {
                        withAnimation(.easeInOut(duration: 0.2)) { showSitting = true }
                    }
                    .appFixedFont(40, settings: accessibility)
                    .foregroundStyle(.white)
                    .buttonStyle(buttonStyle(cornerRadius: 10))

                    Button("Chapters") { }
                        .appFixedFont(40, settings: accessibility)
                        .foregroundStyle(.white)
                        .buttonStyle(
                            OmbreButtonStyle(
                                baseFill: hexFillColor,
                                cornerRadius: 8,
                                contentInsets: EdgeInsets(top: 20, leading: 150, bottom: 20, trailing: 150),
                                starHeight: 50
                            )
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: -8) {
                    Text("Sector")
                    Text("417")
                }
                .appFixedFont(85, settings: accessibility)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                .offset(y: -h * 0.30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                if showSitting {
                    Sitting {
                        withAnimation(.easeInOut(duration: 0.2)) { showSitting = false }
                    }
                    .transition(.opacity)
                    .zIndex(10_000)
                }
            }
        }
        .onAppear { stars.startPulse() }
    }

    private func buttonStyle(cornerRadius: CGFloat) -> OmbreButtonStyle {
        OmbreButtonStyle(
            baseFill: hexFillColor,
            cornerRadius: cornerRadius,
            contentInsets: EdgeInsets(top: 20, leading: 180, bottom: 20, trailing: 140),
            starHeight: 50
        )
    }
}
