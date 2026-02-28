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

struct GamePlay: View {

    
    var onBack: () -> Void

    // Global accessibility settings
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Star pulsing state
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    
    @State private var showSoundsHaptics = false

    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    private let rowHeight: CGFloat = 82
    private let rowMaxWidth: CGFloat = 560

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
                Button { onBack() } label: {
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

                // ===== Rows =====
                VStack(spacing: 30) {

                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSoundsHaptics = true
                        }
                    } label: {
                        row(title: "Sounds & Haptics", icon: "chevron.forward")
                    }
                    .appFixedFont(40, settings: accessibility)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .buttonStyle(menuRowStyle)
                    .frame(maxWidth: rowMaxWidth)
                    .frame(height: rowHeight)

                    Button { } label: {
                        row(title: "Language", icon: "chevron.forward")
                    }
                    .appFixedFont(40, settings: accessibility)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .buttonStyle(menuRowStyle)
                    .frame(maxWidth: rowMaxWidth)
                    .frame(height: rowHeight)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ===== Title =====
                Text("GamePlay")
                    .appFixedFont(85, settings: accessibility)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(y: -h * 0.20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                
                if showSoundsHaptics {
                    SoundsHapticsView(onBack: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSoundsHaptics = false
                        }
                    })
                    .transition(.opacity)
                    .zIndex(10_000)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear { stars.startPulse() }
    }

    private func row(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
            Spacer(minLength: 0)
            Image(systemName: icon)
                .font(.system(size: 24))
                .imageScale(.large)
        }
        .foregroundStyle(.white)
    }

    private var menuRowStyle: OmbreButtonStyle {
        OmbreButtonStyle(
            baseFill: hexFillColor,
            cornerRadius: 8,
            contentInsets: EdgeInsets(top: 20, leading: 24, bottom: 20, trailing: 24),
            starHeight: 50
        )
    }
}

