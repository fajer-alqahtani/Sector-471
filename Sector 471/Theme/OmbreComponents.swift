//
//  OmbreComponents.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
import SwiftUI

// MARK: - Ombre Button Style
struct OmbreButtonStyle: ButtonStyle {
    let baseFill: Color
    let cornerRadius: CGFloat
    let contentInsets: EdgeInsets
    let starHeight: CGFloat

    private var gradientEnd: Color {
        Color(hex: "#D0A2DF") ?? baseFill
    }

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        configuration.label
            .padding(contentInsets)
            .background(
                ZStack {
                    let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    let colors = isPressed ? [baseFill, gradientEnd] : [baseFill, baseFill]

                    shape
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .animation(.easeInOut(duration: 0.22), value: isPressed)

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
                    .opacity(isPressed ? 1 : 0)
                    .scaleEffect(isPressed ? 1.0 : 0.85)
                    .animation(.easeInOut(duration: 0.18), value: isPressed)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}


struct OmbreToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    let baseFill: Color
    let cornerRadius: CGFloat
    let contentInsets: EdgeInsets
    let starHeight: CGFloat
    let toggleTint: Color
    var toggleOffsetX: CGFloat = 0

    let settings: AppAccessibilitySettings
    let fontSize: CGFloat

    @GestureState private var pressed = false

    private var gradientEnd: Color { Color(hex: "#D0A2DF") ?? baseFill }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "voiceover")
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
