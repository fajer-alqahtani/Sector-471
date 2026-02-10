//
//  Accessability.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//

import SwiftUI

struct Accessability: View {
    @State private var starsOpacity: Double = 0.6
    private let minOpacity: Double = 0.35
    private let maxOpacity: Double = 0.85
    private let pulseDuration: Double = 1.5

    @State private var voiceOverOn: Bool = false

    private var hexFillColor: Color {
        Color(hex: "#241D26") ?? .white
    }

    private func voiceOverRowOffsetY(_ h: CGFloat) -> CGFloat {
        0
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let starsOffset = h * 0.35

            ZStack {
                Image("emptyspace")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w + 2, height: h + 100)
                    .clipped()
                    .ignoresSafeArea()

                Image("Stars")
                    .resizable()
                    .scaledToFill()
                    .opacity(starsOpacity)
                    .animation(
                        .easeInOut(duration: pulseDuration)
                            .repeatForever(autoreverses: true),
                        value: starsOpacity
                    )
                    .offset(y: starsOffset)
                    .frame(width: w + 2, height: h + 2)
                    .clipped()
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Button("Default font") { }
                        .font(.custom("PixelifySans-Medium", size: 40))
                        .foregroundStyle(.white)
                        .buttonStyle(
                            OmbreButtonStyle(
                                baseFill: hexFillColor,
                                cornerRadius: 8,
                                contentInsets: EdgeInsets(top: 20, leading: 115, bottom: 20, trailing: 115),
                                starHeight: 50
                            )
                        )

                    Button("OpenDyslexic") { }
                        .font(.custom("PixelifySans-Medium", size: 40))
                        .foregroundStyle(.white)
                        .buttonStyle(
                            OmbreButtonStyle(
                                baseFill: hexFillColor,
                                cornerRadius: 10,
                                contentInsets: EdgeInsets(top: 20, leading: 115, bottom: 20, trailing: 115),
                                starHeight: 50
                            )
                        )
                    

                    OmbreToggleRow(
                        title: "VoiceOver",
                        isOn: $voiceOverOn,
                        baseFill: hexFillColor,
                        cornerRadius: 10,
                        contentInsets: EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 160),
                        starHeight: 50,
                        toggleTint: (Color(hex: "#B57AD9") ?? .purple),
                        toggleOffsetX: 140 
                    )
                    
                    .offset(y: voiceOverRowOffsetY(h))
                    
                }
                
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 10) {
                    Text("Accessibility")
                    Image(systemName: "accessibility")
                        .font(.system(size: 60))
                }
                .font(.custom("PixelifySans-Medium", size: 85))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                .offset(y: -h * 0.30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .onAppear {
            starsOpacity = maxOpacity
            DispatchQueue.main.async {
                starsOpacity = minOpacity
                starsOpacity = maxOpacity
            }
        }
    }
}

// MARK: - Toggle row (with toggleOffsetX control)
private struct OmbreToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    let baseFill: Color
    let cornerRadius: CGFloat
    let contentInsets: EdgeInsets
    let starHeight: CGFloat
    let toggleTint: Color

    // ✅ NEW: shift ONLY the toggle
    var toggleOffsetX: CGFloat = 0

    @GestureState private var pressed = false

    private var gradientEnd: Color {
        Color(hex: "#D0A2DF") ?? baseFill
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "voiceover")
                .font(.system(size: 28))
                .foregroundStyle(.white)

            Text(title)
                .font(.custom("PixelifySans-Medium", size: 40))
                .foregroundStyle(.white)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(toggleTint)
                .scaleEffect(1.05)
                .offset(x: toggleOffsetX) // ✅ only toggle moves
        }
        .padding(contentInsets)
        .background(
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
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($pressed) { _, state, _ in state = true }
        )
    }
}

private struct OmbreButtonStyle: ButtonStyle {
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

#Preview("Landscape Preview", traits: .landscapeLeft) {
    Accessability()
}
