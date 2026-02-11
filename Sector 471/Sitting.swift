//
//  Sitting.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//

import SwiftUI

struct Sitting: View {
    var onBack: () -> Void   // ✅ back to PauseMenu

    @State private var starsOpacity: Double = 0.6
    private let minOpacity: Double = 0.35
    private let maxOpacity: Double = 0.85
    private let pulseDuration: Double = 1.5

    @State private var showAccessibility = false   // ✅ overlay toggle

    private var hexFillColor: Color {
        Color(hex: "#241D26") ?? .white
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let starsOffset = h * 0.35

            ZStack(alignment: .topLeading) {
                // Background
                Image("emptyspace")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w + 2, height: h + 100)
                    .clipped()
                    .ignoresSafeArea()

                // Stars pulse
                Image("Stars")
                    .resizable()
                    .scaledToFill()
                    .opacity(starsOpacity)
                    .animation(
                        .easeInOut(duration: pulseDuration).repeatForever(autoreverses: true),
                        value: starsOpacity
                    )
                    .offset(y: starsOffset)
                    .frame(width: w + 2, height: h + 2)
                    .clipped()
                    .ignoresSafeArea()

                // ✅ Back to PauseMenu (top-left)
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
                .zIndex(999)

                // Buttons
                VStack(spacing: 30) {
                    // ✅ Accessibility -> opens overlay
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAccessibility = true
                        }
                    } label: {
                        HStack(spacing: 100) {
                            Text("Accessibility")
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 24))
                                .imageScale(.large)
                        }
                        .foregroundStyle(.white)
                    }
                    .font(.custom("PixelifySans-Medium", size: 40))
                    .buttonStyle(
                        OmbreButtonStyle(
                            baseFill: hexFillColor,
                            cornerRadius: 8,
                            contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 20),
                            starHeight: 50
                        )
                    )

                    // Experience
                    Button { } label: {
                        HStack(spacing: 130) {
                            Text("Experience")
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 24))
                                .imageScale(.large)
                        }
                        .foregroundStyle(.white)
                    }
                    .font(.custom("PixelifySans-Medium", size: 40))
                    .buttonStyle(
                        OmbreButtonStyle(
                            baseFill: hexFillColor,
                            cornerRadius: 8,
                            contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 20),
                            starHeight: 50
                        )
                    )

                    // Notifications
                    Button { } label: {
                        HStack(spacing: 100) {
                            Text("Notifications")
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 24))
                                .imageScale(.large)
                        }
                        .foregroundStyle(.white)
                    }
                    .font(.custom("PixelifySans-Medium", size: 40))
                    .buttonStyle(
                        OmbreButtonStyle(
                            baseFill: hexFillColor,
                            cornerRadius: 8,
                            contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 20),
                            starHeight: 50
                        )
                    )

                    // Support & Info
                    Button { } label: {
                        HStack(spacing: 70) {
                            Text("Support & Info")
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 24))
                                .imageScale(.large)
                        }
                        .foregroundStyle(.white)
                    }
                    .font(.custom("PixelifySans-Medium", size: 40))
                    .buttonStyle(
                        OmbreButtonStyle(
                            baseFill: hexFillColor,
                            cornerRadius: 8,
                            contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 20),
                            starHeight: 50
                        )
                    )

                    // Privacy Policy
                    Button { } label: {
                        HStack(spacing: 90) {
                            Text("Privacy Policy")
                            Image(systemName: "link")
                                .font(.system(size: 24))
                                .imageScale(.large)
                        }
                        .foregroundStyle(.white)
                    }
                    .font(.custom("PixelifySans-Medium", size: 40))
                    .buttonStyle(
                        OmbreButtonStyle(
                            baseFill: hexFillColor,
                            cornerRadius: 8,
                            contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 20),
                            starHeight: 50
                        )
                    )
                }
                .padding(.top, 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Title
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

                // ✅ Accessability overlay (back -> Sitting)
                if showAccessibility {
                    Accessability(onBack: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAccessibility = false
                        }
                    })
                    .transition(.opacity)
                    .zIndex(10_000)
                }
            }
            .ignoresSafeArea()
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

#Preview {
    Sitting(onBack: {})
}
