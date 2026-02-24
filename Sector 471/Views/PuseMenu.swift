//
//  PuseMenu.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  PuseMenu is the in-game pause overlay/menu.
//  It appears above the story flow and provides quick actions:
//    - Continue: closes the pause menu and resumes the experience (via onContinue callback).
//    - Settings: opens an in-menu settings screen (Sitting) as an overlay.
//    - Chapters: placeholder button for future chapter navigation.
//
//  Visuals:
//  - Uses StarsBackdrop + StarsPulseViewModel to show the same pulsing star background style.
//  - Uses OmbreButtonStyle for consistent themed buttons.
//  - Shows the “Sector 417” title like other menu screens.
//
//  Navigation behavior:
//  - `showSitting` toggles a Settings overlay (Sitting view).
//  - The overlay uses a fade transition and a high zIndex so it appears above everything.
//

import SwiftUI

struct PuseMenu: View {

    // Callback from the parent flow to close this menu and resume the scene.
    var onContinue: () -> Void

    // Global accessibility settings (controls font style: pixel vs dyslexic).
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Star pulsing state used by StarsBackdrop (opacity changes over time).
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    // Controls whether the Settings overlay (Sitting view) is visible.
    @State private var showSitting = false

    // Base fill color used for Ombre buttons (fallback to white if hex fails).
    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height // used to position the title vertically

            ZStack {
                // Transparent tap layer (keeps view full-screen without adding a visible background).
                Color.black.opacity(0.001).ignoresSafeArea()

                // ===== Background stars =====
                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

                // ===== Menu buttons =====
                VStack(spacing: 30) {

                    // Continue: resumes gameplay/flow by calling the parent callback.
                    Button("Continue") { onContinue() }
                        .appFixedFont(40, settings: accessibility)
                        .foregroundStyle(.white)
                        .buttonStyle(buttonStyle(cornerRadius: 8))

                    // Settings: shows the Sitting overlay.
                    Button("Settings") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSitting = true
                        }
                    }
                    .appFixedFont(40, settings: accessibility)
                    .foregroundStyle(.white)
                    .buttonStyle(buttonStyle(cornerRadius: 10))

                    // Chapters: placeholder for future chapter screen navigation.
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

                // ===== Title branding =====
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

                // ===== Settings overlay =====
                // Shown on top of the pause menu when showSitting is true.
                if showSitting {
                    Sitting {
                        // Close settings overlay.
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSitting = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(10_000) // ensure it appears above everything
                }
            }
        }
        // Start the stars pulsing when pause menu appears.
        .onAppear { stars.startPulse() }
    }

    /// Centralized Ombre button style for the first two buttons to keep sizing consistent.
    private func buttonStyle(cornerRadius: CGFloat) -> OmbreButtonStyle {
        OmbreButtonStyle(
            baseFill: hexFillColor,
            cornerRadius: cornerRadius,
            contentInsets: EdgeInsets(top: 20, leading: 180, bottom: 20, trailing: 140),
            starHeight: 50
        )
    }
}
