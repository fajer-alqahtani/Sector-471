//
//  Chapters.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  Chapters is the chapter selection menu.
//  It shows a pulsing star background (StarsBackdrop + StarsPulseViewModel) and a list of
//  chapter buttons styled with our OmbreButtonStyle.
//
//  Current behavior:
//  - Chapter I is available (button is active, action is currently empty).
//  - Chapter II & III are locked (display a lock icon, action is empty).
//  - The screen uses the global accessibility settings for custom fonts.
//  - A custom back button is provided via the NavigationBar toolbar (dismiss).
//

import SwiftUI

struct Chapters: View {

    // Global accessibility settings (controls app font style).
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Standard dismiss for NavigationStack back.
    @Environment(\.dismiss) private var dismiss

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
            let h = proxy.size.height // used to position the title

            ZStack {

                // ===== Background stars =====
                // StarsBackdrop draws the stars background.
                // We bind stars.opacity so the background can "pulse".
                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

                // ===== Chapter buttons =====
                VStack(spacing: 30) {

                    // Active chapter button (action placeholder for now).
                    Button("Chapter I: Atmospheric Error") { }
                        .appFixedFont(40, settings: accessibility)
                        .foregroundStyle(.white)
                        .buttonStyle(
                            OmbreButtonStyle(
                                baseFill: hexFillColor,
                                cornerRadius: 8,
                                contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 100),
                                starHeight: 50
                            )
                        )

                    // Locked chapters (show lock icon + title).
                    lockedChapter(title: "Chapter II", leading: 270, trailing: 270)
                    lockedChapter(title: "Chapter III", leading: 260, trailing: 270)
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
                .offset(y: -h * 0.30) // moves title upward
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }

        // ===== Navigation bar back button =====
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .font(.system(size: 22, weight: .semibold))
                }
            }
        }

        // Hide the default navigation bar background so the stars show behind it.
        .toolbarBackground(.hidden, for: .navigationBar)

        // Start the stars pulse animation when the screen appears.
        .onAppear { stars.startPulse() }
    }

    /// Builds a "locked chapter" button row:
    /// - Shows a lock icon + chapter title.
    /// - Uses the same OmbreButtonStyle to match the rest of the UI.
    /// - Action is currently empty (future: show "locked" message or requirements).
    private func lockedChapter(title: String, leading: CGFloat, trailing: CGFloat) -> some View {
        Button { } label: {
            HStack(spacing: 10) {
                Image(systemName: "lock")
                    .font(.system(size: 24))
                    .imageScale(.large)

                Text(title)
            }
            .foregroundStyle(.white)
        }
        .appFixedFont(40, settings: accessibility)
        .buttonStyle(
            OmbreButtonStyle(
                baseFill: hexFillColor,
                cornerRadius: 10,
                contentInsets: EdgeInsets(top: 20, leading: leading, bottom: 20, trailing: trailing),
                starHeight: 50
            )
        )
    }
}
