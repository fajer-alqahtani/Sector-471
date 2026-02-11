//
//  SpaceScene.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//

import SwiftUI

struct SpaceScene: View {
    @State private var earthGrow = false
    @State private var currentWarningName: String? = nil

    // ✅ call this when you want to switch to CrashView
    var onFinish: () -> Void = {}

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                StarsView()

                Image("Earth")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .scaleEffect(earthGrow ? 14.25 : 1.0)
                    .offset(x: 0, y: 190)
                    .position(x: w / 2, y: h / 2)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 40.0)) {
                            earthGrow = true
                        }
                    }

                ShakenFullscreenImage(
                    name: "Shuttle no background",
                    active: currentWarningName != nil,
                    amplitude: 1.2,
                    rotation: 0.18,
                    xFreq: 34, yFreq: 41, rFreq: 28
                )

                if let name = currentWarningName {
                    ShakenFullscreenBlinkingWarning(
                        name: name,
                        amplitude: 6,
                        rotation: 0.6
                    )
                    .zIndex(999)
                }
            }
            .preferredColorScheme(.dark)
            .task { await runWarningSequence() }
        }
    }

    private func runWarningSequence() async {
        // keep your timing exactly the same
        try? await Task.sleep(nanoseconds: 10_000_000_000)

        await MainActor.run { currentWarningName = "FullWarning" }
        try? await Task.sleep(nanoseconds: 10_000_000_000)
        await MainActor.run { currentWarningName = nil }

        // ✅ after the warning ends, smoothly move to CrashView
        await MainActor.run {
            onFinish()
        }
    }
}


// MARK: - Fullscreen Shaken Image
private struct ShakenFullscreenImage: View {
    let name: String
    let active: Bool
    var amplitude: CGFloat = 0
    var rotation: Double = 0.35
    var xFreq: Double = 40
    var yFreq: Double = 55
    var rFreq: Double = 35

    var body: some View {
        ShakeWrapper(
            active: active,
            amplitude: amplitude,
            rotation: rotation,
            xFreq: xFreq,
            yFreq: yFreq,
            rFreq: rFreq
        ) {
            Image(name)
                .resizable()
                .scaledToFill()
                .scaleEffect(x: 1.0, y: 1.07)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .compositingGroup()
        .mask(Rectangle().ignoresSafeArea())
    }
}

// MARK: - Fullscreen Blinking Warning
private struct ShakenFullscreenBlinkingWarning: View {
    let name: String
    var amplitude: CGFloat = 0
    var rotation: Double = 0
    @State private var blink = false

    var body: some View {
        ShakeWrapper(active: true, amplitude: amplitude, rotation: rotation) {
            Image(name)
                .resizable()
                .scaledToFill()
                .scaleEffect(x: 1.0, y: 1.07)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(blink ? 0.5 : 1.0)
                .brightness(blink ? 0.08 : 0.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.16).repeatForever(autoreverses: true)) {
                        blink.toggle()
                    }
                }
        }
        .compositingGroup()
        .mask(Rectangle().ignoresSafeArea())
    }
}

// MARK: - ShakeWrapper
private struct ShakeWrapper<Content: View>: View {
    let active: Bool
    var amplitude: CGFloat = 0
    var rotation: Double = 0.35
    var xFreq: Double = 40
    var yFreq: Double = 55
    var rFreq: Double = 35
    let content: () -> Content

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let x = active ? CGFloat(sin(t * xFreq)) * amplitude : 0
            let y = active ? CGFloat(cos(t * yFreq)) * amplitude : 0
            let r = active ? sin(t * rFreq) * rotation : 0

            content()
                .rotationEffect(.degrees(r), anchor: .center)
                .offset(x: x, y: y)
        }
    }
}

#Preview {
    SpaceScene()
}
