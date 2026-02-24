//
//  Sitting.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  Sitting is the main Settings menu (opened from the Pause menu).
//  It uses the same visual system as other menus:
//  - StarsBackdrop + StarsPulseViewModel for the pulsing star background.
//  - OmbreButtonStyle for themed menu rows.
//  - “Sector 417” title branding at the top.
//
//  Behavior:
//  - A custom back button (top-left) triggers `onBack()` to close this settings overlay.
//  - The menu shows multiple rows (Accessibility, Experience, Notifications, Support & Info, Privacy Policy).
//  - Only "Accessibility" currently opens a real sub-screen:
//      * It toggles `showAccessibility` to present AccessibilityScreen as a full overlay.
//      * AccessibilityScreen provides its own back behavior via an onBack closure
//        that hides the overlay with a fade animation.
//  - Other rows are placeholders (empty actions for now).
//

import SwiftUI

struct Sitting: View {

    // Callback used to close this settings menu and return to the previous screen (Pause menu).
    var onBack: () -> Void

    // Global accessibility settings (controls font style: pixel vs dyslexic).
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Star pulsing state used by StarsBackdrop (opacity changes over time).
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    // Controls whether the Accessibility sub-screen is shown as an overlay.
    @State private var showAccessibility = false

    // Base fill color used for Ombre buttons (fallback to white if hex fails).
    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height // used to position the title vertically

            ZStack(alignment: .topLeading) {

                // ===== Background stars =====
                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

                // ===== Back button (closes Sitting overlay) =====
                Button { onBack() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.black.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.leading, 16)
                .padding(.top, 12)
                .zIndex(999) // keep above menu rows and title

                // ===== Settings rows =====
                VStack(spacing: 30) {

                    // Accessibility row: opens AccessibilityScreen overlay.
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAccessibility = true
                        }
                    } label: {
                        row(title: "Accessibility", spacing: 100, icon: "chevron.forward")
                    }
                    .appFixedFont(40, settings: accessibility)
                    .buttonStyle(menuRowStyle)

                    // Placeholder rows (future: open real screens).
                    Button { } label: {
                        row(title: "Experience", spacing: 130, icon: "chevron.forward")
                    }
                    .appFixedFont(40, settings: accessibility)
                    .buttonStyle(menuRowStyle)

                    Button { } label: {
                        row(title: "Notifications", spacing: 100, icon: "chevron.forward")
                    }
                    .appFixedFont(40, settings: accessibility)
                    .buttonStyle(menuRowStyle)

                    Button { } label: {
                        row(title: "Support & Info", spacing: 70, icon: "chevron.forward")
                    }
                    .appFixedFont(40, settings: accessibility)
                    .buttonStyle(menuRowStyle)

                    Button { } label: {
                        row(title: "Privacy Policy", spacing: 90, icon: "link")
                    }
                    .appFixedFont(40, settings: accessibility)
                    .buttonStyle(menuRowStyle)
                }
                .padding(.top, 200) // pushes the menu below the title area
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

                // ===== Accessibility overlay =====
                // Presented on top of Sitting when showAccessibility is true.
                if showAccessibility {
                    AccessibilityScreen(onBack: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAccessibility = false
                        }
                    })
                    .transition(.opacity)
                    .zIndex(10_000) // ensure it appears above everything
                }
            }
            .ignoresSafeArea()
        }
        // Start the stars pulse when this screen appears.
        .onAppear { stars.startPulse() }
    }

    /// Builds the row content (text + trailing icon) for each settings item.
    /// `spacing` is used to manually align the trailing icons per row.
    private func row(title: String, spacing: CGFloat, icon: String) -> some View {
        HStack(spacing: spacing) {
            Text(title)
            Image(systemName: icon)
                .font(.system(size: 24))
                .imageScale(.large)
        }
        .foregroundStyle(.white)
    }

    /// Shared ombre style for all menu rows in this settings screen.
    private var menuRowStyle: OmbreButtonStyle {
        OmbreButtonStyle(
            baseFill: hexFillColor,
            cornerRadius: 8,
            contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 20),
            starHeight: 50
        )
    }
}
