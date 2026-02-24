//
//  ExperienceView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//

import SwiftUI

struct ExperienceView: View {
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height

            ZStack {
                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

                VStack(spacing: 30) {
                    navRow(title: "Sounds & Haptics", spacing: 50, leading: 70)
                    navRow(title: "Language", spacing: 130, leading: 150)
                }
                .padding(.top, -40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: -8) { Text("Experience") }
                    .appFixedFont(85, settings: accessibility)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(y: -h * 0.30)
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .onAppear { stars.startPulse() }
    }

    private func navRow(title: String, spacing: CGFloat, leading: CGFloat) -> some View {
        Button { } label: {
            HStack(spacing: spacing) {
                Text(title)
                Image(systemName: "chevron.forward")
                    .font(.system(size: 24))
                    .imageScale(.large)
            }
            .foregroundStyle(.white)
        }
        .appFixedFont(40, settings: accessibility)
        .buttonStyle(
            OmbreButtonStyle(
                baseFill: hexFillColor,
                cornerRadius: 8,
                contentInsets: EdgeInsets(top: 20, leading: leading, bottom: 20, trailing: 20),
                starHeight: 50
            )
        )
    }
}
