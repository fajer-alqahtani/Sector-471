//
//  Chapters.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  Chapters is the chapter selection menu.
//  It shows a pulsing star background (StarsBackdrop + StarsPulseViewModel) and a list of
//  chapter buttons styled with our OmbreButtonStyle.
//
//  Current behavior:
//  - Chapter I is available (button is active, action is currently empty).
//  - Chapter II & III are locked (display a lock icon, action is empty).
//  - The screen uses the global accessibility settings for custom fonts.
//  - A custom back button is provided via the NavigationBar toolbar (dismiss).
//

import SwiftUI

struct Chapters: View {

    @EnvironmentObject private var accessibility: AppAccessibilitySettings
    @Environment(\.dismiss) private var dismiss

    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 1.62,
        minOpacity: 1.55,
        maxOpacity: 0.70,
        pulseDuration: 1.6
    )

    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        GeometryReader { proxy in

            ZStack(alignment: .topLeading) {

                
                Color.black.ignoresSafeArea()

                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.0,
                    pulseDuration: stars.pulseDuration
                )
                .ignoresSafeArea()

               
                Button { dismiss() } label: {
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

                
                VStack(spacing: 30) {

                    VStack(spacing: -8) {
                        Text("Sector")
                        Text("417")
                    }
                    .appFixedFont(85, settings: accessibility)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)

                    VStack(spacing: 30) {
                        Button("Chapter I: Atmospheric Error") { }
                            .appFixedFont(40, settings: accessibility)
                            .foregroundStyle(.white)
                            .buttonStyle(
                                OmbreButtonStyle(
                                    baseFill: hexFillColor,
                                    cornerRadius: 8,
                                    contentInsets: EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 100),
                                    starHeight: 50
                                )
                            )

                        lockedChapter(title: "Chapter II", leading: 270, trailing: 270)
                        lockedChapter(title: "Chapter III", leading: 260, trailing: 270)
                    }
                }
                .offset(y: -proxy.size.height * 0.05)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .ignoresSafeArea()
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear { stars.startPulse() }
    }

    private func lockedChapter(title: String, leading: CGFloat, trailing: CGFloat) -> some View {
        Button { } label: {
            HStack(spacing: 20) {
                Image(systemName: "lock")
                    .font(.system(size: 24))
                    .imageScale(.large)

                Text(title)
            }
            .foregroundStyle(.white)
        }
        .appFixedFont(40, settings: accessibility)
        .buttonStyle(
            OmbreButtonStyle(
                baseFill: hexFillColor,
                cornerRadius: 10,
                contentInsets: EdgeInsets(top: 20, leading: leading, bottom: 20, trailing: trailing),
                starHeight: 50
            )
        )
    }
}
