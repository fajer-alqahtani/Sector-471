//
//  Chapters.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
import SwiftUI

struct Chapters: View {
    @EnvironmentObject private var accessibility: AppAccessibilitySettings
    @Environment(\.dismiss) private var dismiss

   
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height

            ZStack {
                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

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
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .font(.system(size: 22, weight: .semibold))
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear { stars.startPulse() }
    }

    private func lockedChapter(title: String, leading: CGFloat, trailing: CGFloat) -> some View {
        Button { } label: {
            HStack(spacing: 10) {
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
