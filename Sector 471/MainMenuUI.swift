//
//  MainMenuUI.swift
//  Sector 471
//
//  Created by Oroub Alelewi on 09/02/2026.
//
import SwiftUI

struct MainMenuUI: View {
    @State private var starsOpacity: Double = 0.6
    private let minOpacity: Double = 0.35
    private let maxOpacity: Double = 0.85
    private let pulseDuration: Double = 1.5

    private var hexFillColor: Color {
        Color(hex: "#241D26") ?? .white
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

                // Buttons (keep their position)
                VStack(spacing: 30) {
                    Button("Start") { }
                        .font(.custom("PixelifySans-Medium", size: 40))
                        .foregroundStyle(.white)
                        .buttonStyle(
                            OmbreButtonStyle(
                                baseFill: hexFillColor,
                                cornerRadius: 8,
                                contentInsets: EdgeInsets(top: 20, leading: 180, bottom: 20, trailing: 180),
                                starHeight: 50
                            )
                        )

                    Button("Accessiblity") { }
                        .font(.custom("PixelifySans-Medium", size: 40))
                        .foregroundStyle(.white)
                        .buttonStyle(
                            OmbreButtonStyle(
                                baseFill: hexFillColor,
                                cornerRadius: 10,
                                contentInsets: EdgeInsets(top: 20, leading: 120, bottom: 20, trailing: 120),
                                starHeight: 50
                            )
                        )

                    Button("Chapters") { }
                        .font(.custom("PixelifySans-Medium", size: 40))
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

                VStack(spacing: -8) {
                    Text("Sector")
                    Text("417")
                }
                .font(.custom("PixelifySans-Medium", size: 85))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                .offset(y: -h * 0.30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .ignoresSafeArea()
        }
        // Pulse Animation
        .onAppear {
            starsOpacity = maxOpacity
            DispatchQueue.main.async {
                starsOpacity = minOpacity
                starsOpacity = maxOpacity
            }
        }
    }
}

private struct OmbreButtonStyle: ButtonStyle {
    let baseFill: Color
    let cornerRadius: CGFloat
    let contentInsets: EdgeInsets
    let starHeight: CGFloat

    // Target lighter purple for the ombre end color when pressed
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
                    // Ombre (left -> right) only when pressed
                    let colors = isPressed ? [baseFill, gradientEnd] : [baseFill, baseFill]

                    shape
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .animation(.easeInOut(duration: 0.22), value: isPressed)

                    // Stars appear only while pressed
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

#Preview ("Landscape Preview", traits: .landscapeLeft){
    MainMenuUI()
}
