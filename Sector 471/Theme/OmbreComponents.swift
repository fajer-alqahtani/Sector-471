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

struct OmbreButtonStyle: ButtonStyle {

    let baseFill: Color
    let cornerRadius: CGFloat
    let contentInsets: EdgeInsets
    let starHeight: CGFloat

    
    var isSelected: Bool = false
    var showsStars: Bool = true

    /// Second gradient color shown on press/selected (fallback to baseFill if needed).
    private var gradientEnd: Color { Color(hex: "#D0A2DF") ?? baseFill }

    func makeBody(configuration: Configuration) -> some View {
        let active = isSelected || configuration.isPressed
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let colors = active ? [baseFill, gradientEnd] : [baseFill, baseFill]

        return configuration.label
            .padding(contentInsets)
            .background(
                ZStack {
                    shape
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .animation(.easeInOut(duration: 0.22), value: active)

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
                    .opacity(active ? 1 : 0)
                    .scaleEffect(active ? 1.0 : 0.85)
                    .animation(.easeInOut(duration: 0.18), value: active)
                }
            )
            .clipShape(shape)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

/// A reusable row component that matches the OmbreButtonStyle look,
/// but contains an icon + title + Toggle.
struct OmbreToggleRow: View {

    let title: String
    @Binding var isOn: Bool

    let baseFill: Color
    let cornerRadius: CGFloat
    let contentInsets: EdgeInsets
    let starHeight: CGFloat

    let toggleTint: Color
    var toggleOffsetX: CGFloat = 0

    @ObservedObject var settings: AppAccessibilitySettings

    let fontSize: CGFloat
    var showsStars: Bool = true

    
    var leadingSystemIcon: String = "voiceover"

    @GestureState private var pressed = false
    private var gradientEnd: Color { Color(hex: "#D0A2DF") ?? baseFill }

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: leadingSystemIcon)
                .font(.system(size: 28))
                .foregroundStyle(.white)

            Text(title)
                .appFixedFont(fontSize, settings: settings)
                .foregroundStyle(.white)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(toggleTint)
                .scaleEffect(1.05)
                .offset(x: toggleOffsetX)
        }
        .padding(contentInsets)
        .background(background)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($pressed) { _, state, _ in state = true }
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
            
            if showsStars {
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
        }
    }
}
