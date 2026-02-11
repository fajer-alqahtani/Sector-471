//
//  Sitting.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//

import SwiftUI

struct Sitting: View {
    var onBack: () -> Void

    @EnvironmentObject private var accessibility: AppAccessibilitySettings


    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    @State private var showAccessibility = false

    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height

            ZStack(alignment: .topLeading) {

                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

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

                VStack(spacing: 30) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { showAccessibility = true }
                    } label: {
                        row(title: "Accessibility", spacing: 100, icon: "chevron.forward")
                    }
                    .appFixedFont(40, settings: accessibility)
                    .buttonStyle(menuRowStyle)

                    Button { } label: { row(title: "Experience", spacing: 130, icon: "chevron.forward") }
                        .appFixedFont(40, settings: accessibility)
                        .buttonStyle(menuRowStyle)

                    Button { } label: { row(title: "Notifications", spacing: 100, icon: "chevron.forward") }
                        .appFixedFont(40, settings: accessibility)
                        .buttonStyle(menuRowStyle)

                    Button { } label: { row(title: "Support & Info", spacing: 70, icon: "chevron.forward") }
                        .appFixedFont(40, settings: accessibility)
                        .buttonStyle(menuRowStyle)

                    Button { } label: { row(title: "Privacy Policy", spacing: 90, icon: "link") }
                        .appFixedFont(40, settings: accessibility)
                        .buttonStyle(menuRowStyle)
                }
                .padding(.top, 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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

                if showAccessibility {
                    AccessibilityScreen(onBack: {
                        withAnimation(.easeInOut(duration: 0.2)) { showAccessibility = false }
                    })
                    .transition(.opacity)
                    .zIndex(10_000)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear { stars.startPulse() }
    }

    private func row(title: String, spacing: CGFloat, icon: String) -> some View {
        HStack(spacing: spacing) {
            Text(title)
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
            contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 20),
            starHeight: 50
        )
    }
}
