//
//  ExperienceView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  ExperienceView is a settings-style menu for “Experience” options.
//  It shows our standard pulsing star background (StarsBackdrop + StarsPulseViewModel)
//  and displays navigation rows (buttons) that will later open sub-screens like:
//    - Sounds & Haptics
//    - Language
//
//  Current behavior:
//  - The buttons are styled using OmbreButtonStyle to match the rest of the app UI.
//  - Button actions are currently empty placeholders (future: push NavigationLinks).
//  - The screen title ("Experience") is positioned toward the top, like other menus.
//  - The star background begins pulsing onAppear.
//

import SwiftUI

struct ExperienceView: View {

    // Global accessibility settings (controls font selection and scaling).
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Star pulsing state used by StarsBackdrop (opacity changes over time).
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    // Base fill color used for ombre buttons (fallback to white if hex fails).
    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height // used to place the title

            ZStack {

                // ===== Background stars =====
                // StarsBackdrop draws the stars background.
                // We bind stars.opacity so the background can pulse.
                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

                // ===== Main navigation rows =====
                VStack(spacing: 30) {

                    // Placeholder row: future screen for audio settings.
                    navRow(title: "Sounds & Haptics", spacing: 50, leading: 70)

                    // Placeholder row: future screen for language settings.
                    navRow(title: "Language", spacing: 130, leading: 150)
                }
                .padding(.top, -40) // nudges the rows upward
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ===== Screen title =====
                VStack(spacing: -8) {
                    Text("GamePlay")
                }
                .appFixedFont(85, settings: accessibility)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                .offset(y: -h * 0.30) // moves the title upward like other menus
                .padding(.top, 40)    // small adjustment for layout balance
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        // Start the stars pulse animation when the screen appears.
        .onAppear { stars.startPulse() }
    }

    /// Builds a reusable “navigation row” button:
    /// - Left: title text
    /// - Right: chevron icon
    /// - Styled with OmbreButtonStyle
    ///
    /// Params like spacing/leading are used to fine-tune alignment per row.
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
