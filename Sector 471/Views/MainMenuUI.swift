//
//  MainMenuUI.swift
//  Sector 471
//
//  Created by Oroub Alelewi on 09/02/2026.
//
//  DESCRIPTION (for the team):
//  MainMenuUI is the app’s main menu screen.
//  It shows a starry background (StarsBackdrop) and three primary navigation actions:
//    1) Start → launches the main story flow (EarthSpaceCrashFlow)
//    2) Accessibility → opens accessibility settings (AccessibilityScreen)
//    3) Chapters → opens the chapter selection menu (Chapters)
//
//  Design notes:
//  - The background stars are set to a FIXED opacity using `.constant(0.6)` to avoid
//    having multiple star layers / pulsing duplicates.
//  - Buttons use OmbreButtonStyle to match the game UI theme.
//  - The title ("Sector 417") is centered and shifted upward based on screen height.
//

import SwiftUI

struct MainMenuUI: View {

    // Global accessibility settings (controls font style: pixel vs dyslexic).
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Base fill color used for the Ombre button style (fallback to white if hex fails).
    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let h = proxy.size.height // used to position the title vertically

                ZStack {

                    // ===== Background stars =====
                    // Fixed opacity to keep the main menu stars static (no pulsing/twinkle).
                    StarsBackdrop(
                        size: proxy.size,
                        starsOpacity: .constant(0.6),
                        starsOffsetFactor: 0.10,
                        pulseDuration: 1.5
                    )

                    // ===== Main menu buttons =====
                    VStack(spacing: 30) {

                        // Start the main story flow.
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

                        // Open accessibility settings.
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

                        // Open chapter selection screen.
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

                    // ===== Title branding =====
                    VStack(spacing: -8) {
                        Text("Sector")
                        Text("417")
                    }
                    .appFixedFont(86, settings: accessibility)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(y: -h * 0.30) // move title upward
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
    }
}
