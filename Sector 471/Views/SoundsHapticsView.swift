//
//  SoundsHapticsView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 11/09/1447 AH.
//

import SwiftUI

struct SoundsHapticsView: View {

    // Back callback (same pattern as other overlays)
    var onBack: (() -> Void)? = nil

    // Normal dismiss fallback (if you ever use it in NavigationStack)
    @Environment(\.dismiss) private var dismiss

    // Global accessibility settings (pixel vs dyslexic)
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Stars pulsing (same as your other screens)
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    // Toggles (hook these later to your real audio/haptics manager)
    @State private var backgroundMusicOn: Bool = true
    @State private var soundEffectsOn: Bool = true
    @State private var hapticsOn: Bool = false

    // Theme
    private var baseFill: Color { Color(hex: "#241D26") ?? .white }

    // If you already have a tint color in your project, replace this with it.
    private var toggleTint: Color { .purple }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height

            ZStack(alignment: .topLeading) {

                // ===== Background stars =====
                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

                // ===== Back button =====
                Button {
                    if let onBack { onBack() } else { dismiss() }
                } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(20)
                            .background(.purple.opacity(0.09))
                            .clipShape(RoundedRectangle(cornerRadius: 162, style: .continuous))
                    }
                    .padding(.leading, 26)
                    .padding(.top, 22)
                    .zIndex(999)

                // ===== Toggles =====
                VStack(spacing: 28) {

                    OmbreToggleRow(
                        title: " Background music",
                        isOn: $backgroundMusicOn,
                        baseFill: baseFill,
                        cornerRadius: 10,
                        contentInsets: EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 110),
                        starHeight: 50,
                        toggleTint: toggleTint,
                        toggleOffsetX: 80,
                        settings: accessibility,
                        fontSize: 40,
                        showsStars: false,
                        leadingSystemIcon: "music.note"
                    )
                    .frame(height: 80)

                    OmbreToggleRow(
                        title: " Sound effects",
                        isOn: $soundEffectsOn,
                        baseFill: baseFill,
                        cornerRadius: 10,
                        contentInsets: EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 180),
                        starHeight: 50,
                        toggleTint: toggleTint,
                        toggleOffsetX: 150,
                        settings: accessibility,
                        fontSize: 40,
                        showsStars: false,
                        leadingSystemIcon: "music.note"
                    )
                    .frame(height: 80)

                    OmbreToggleRow(
                        title: " Haptics",
                        isOn: $hapticsOn,
                        baseFill: baseFill,
                        cornerRadius: 10,
                        contentInsets: EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 310),
                        starHeight: 50,
                        toggleTint: toggleTint,
                        toggleOffsetX: 280,
                        settings: accessibility,
                        fontSize: 40,
                        showsStars: false,
                        leadingSystemIcon: "music.note"
                    )
                    .frame(height: 80)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ===== Title =====
                Text("Sounds & Haptics")
                    .appFixedFont(85, settings: accessibility)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(y: -h * 0.30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .ignoresSafeArea()
        }
        .onAppear { stars.startPulse() }
    }
}
