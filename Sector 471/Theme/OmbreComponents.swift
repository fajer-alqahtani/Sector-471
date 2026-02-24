//
//  OmbreComponents.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
//  DESCRIPTION (for the team):
//  This file contains reusable UI components that create the app’s “ombre” button look.
//  There are two main components:
//  1) OmbreButtonStyle: a custom ButtonStyle that draws a rounded gradient background and
//     shows two decorative "star" images ONLY when the button is pressed.
//  2) OmbreToggleRow: a reusable row with an icon + title + Toggle, styled to match the same
//     ombre background behavior (pressed = gradient + stars).
//
//  The pressed state is visual-only:
//  - For buttons, SwiftUI gives us configuration.isPressed.
//  - For toggle rows, we simulate "pressed" using a DragGesture(minimumDistance: 0)
//    so tapping anywhere on the row triggers the pressed animation.
//

import SwiftUI

// MARK: - Ombre Button Style
/// Custom button style used across menus.
/// - Default state: solid fill (baseFill).
/// - Pressed state: gradient fill + decorative star images fade in.
struct OmbreButtonStyle: ButtonStyle {

    // Base background color used in normal state and as the first gradient color.
    let baseFill: Color

    // Button corner radius (controls roundness).
    let cornerRadius: CGFloat

    // Padding around the label (controls button size).
    let contentInsets: EdgeInsets

    // Height of the star images on pressed state.
    let starHeight: CGFloat

    /// Second gradient color shown on press (fallback to baseFill if hex conversion fails).
    private var gradientEnd: Color {
        Color(hex: "#D0A2DF") ?? baseFill
    }

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed // SwiftUI press state

        configuration.label
            .padding(contentInsets) // controls touch area + layout size
            .background(
                ZStack {
                    // Rounded shape used for both fill + clipping.
                    let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

                    // If pressed: show gradient. If not pressed: flat color (baseFill -> baseFill).
                    let colors = isPressed ? [baseFill, gradientEnd] : [baseFill, baseFill]

                    // Background fill with smooth press animation.
                    shape
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .animation(.easeInOut(duration: 0.22), value: isPressed)

                    // Decorative stars appear only when pressed.
                    HStack {
                        Image("star")
                            .resizable()
                            .scaledToFit()
                            .frame(height: starHeight)

                        Spacer(minLength: 0)

                        Image("star")
                            .resizable()
                            .scaledToFit()
                            .frame(height: starHeight)
                    }
                    .padding(.horizontal, 14)
                    .opacity(isPressed ? 1 : 0)      // fade in/out
                    .scaleEffect(isPressed ? 1.0 : 0.85) // subtle pop effect
                    .animation(.easeInOut(duration: 0.18), value: isPressed)
                }
                // Clip everything (gradient + stars) to the rounded shape.
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            // Ensures the whole rounded area behaves like the button hit target.
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// A reusable row component that matches the OmbreButtonStyle look,
/// but contains an icon + title + Toggle.
struct OmbreToggleRow: View {

    // Display title shown next to the icon.
    let title: String

    // Binding to the toggle state (owned by the parent view).
    @Binding var isOn: Bool

    // Styling inputs (same idea as OmbreButtonStyle).
    let baseFill: Color
    let cornerRadius: CGFloat
    let contentInsets: EdgeInsets
    let starHeight: CGFloat

    // Toggle tint (the "ON" color).
    let toggleTint: Color

    // Optional horizontal offset for the toggle if you want to fine-tune alignment.
    var toggleOffsetX: CGFloat = 0

    // Accessibility settings for font style.
    let settings: AppAccessibilitySettings

    // Font size for the row title.
    let fontSize: CGFloat

    // Tracks "pressed" state while a touch is down (visual-only).
    @GestureState private var pressed = false

    /// Second gradient color shown on press (fallback to baseFill if needed).
    private var gradientEnd: Color { Color(hex: "#D0A2DF") ?? baseFill }

    var body: some View {
        HStack(spacing: 12) {

            // VoiceOver icon (for accessibility setting rows).
            Image(systemName: "voiceover")
                .font(.system(size: 28))
                .foregroundStyle(.white)

            // Row title uses app’s custom font system.
            Text(title)
                .appFixedFont(fontSize, settings: settings)
                .foregroundStyle(.white)

            // Actual Toggle control (labels hidden so title is the label).
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(toggleTint)
                .scaleEffect(1.05)
                .offset(x: toggleOffsetX)
        }
        .padding(contentInsets)          // row padding
        .background(background)          // ombre background with press animation
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)) // full-row tap shape
        .simultaneousGesture(
            // Gesture is only to drive the pressed animation (does not replace Toggle interaction).
            DragGesture(minimumDistance: 0)
                .updating($pressed) { _, state, _ in
                    state = true
                }
        )
    }

    /// Background layer that matches the OmbreButtonStyle behavior:
    /// pressed = gradient + stars, not pressed = flat fill.
    private var background: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            let colors = pressed ? [baseFill, gradientEnd] : [baseFill, baseFill]

            shape
                .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                .animation(.easeInOut(duration: 0.22), value: pressed)

            HStack {
                Image("star")
                    .resizable()
                    .scaledToFit()
                    .frame(height: starHeight)

                Spacer(minLength: 0)

                Image("star")
                    .resizable()
                    .scaledToFit()
                    .frame(height: starHeight)
            }
            .padding(.horizontal, 14)
            .opacity(pressed ? 1 : 0)
            .scaleEffect(pressed ? 1.0 : 0.85)
            .animation(.easeInOut(duration: 0.18), value: pressed)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
