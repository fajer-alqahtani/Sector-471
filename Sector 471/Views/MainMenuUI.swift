//
//  MainMenuUI.swift
//  Sector 471
//
//  Created by Oroub Alelewi on 09/02/2026.
//

import SwiftUI

struct MainMenuUI: View {
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

  
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let h = proxy.size.height

                ZStack {
                    StarsBackdrop(
                        size: proxy.size,
                        starsOpacity: $stars.opacity,
                        starsOffsetFactor: 0.10,
                        pulseDuration: stars.pulseDuration
                    )

                    VStack(spacing: 30) {

                        NavigationLink {
                            EarthSpaceCrashFlow()
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            Text("Start")
                                .appFixedFont(40, settings: accessibility)
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(
                            OmbreButtonStyle(
                                baseFill: hexFillColor,
                                cornerRadius: 8,
                                contentInsets: EdgeInsets(top: 20, leading: 180, bottom: 20, trailing: 180),
                                starHeight: 50
                            )
                        )

                        NavigationLink {
                            AccessibilityScreen()
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "accessibility")
                                    .font(.system(size: 24))
                                    .imageScale(.large)
                                Text("Accessibility")
                            }
                            .foregroundStyle(.white)
                        }
                        .appFixedFont(40, settings: accessibility)
                        .buttonStyle(
                            OmbreButtonStyle(
                                baseFill: hexFillColor,
                                cornerRadius: 10,
                                contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 100),
                                starHeight: 50
                            )
                        )

                        NavigationLink {
                            Chapters()
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            Text("Chapters")
                                .foregroundStyle(.white)
                        }
                        .appFixedFont(40, settings: accessibility)
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
                    .appFixedFont(86, settings: accessibility)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(y: -h * 0.30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .onAppear { stars.startPulse() }
        }
    }
}
