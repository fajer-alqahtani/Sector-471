//
//  SpaceScene.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
import SwiftUI

struct SpaceScene: View {
    @EnvironmentObject private var accessibility: AppAccessibilitySettings
    @StateObject private var vm = SpaceSceneViewModel()

    var onFinish: () -> Void = {}

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                sceneContent(w: w, h: h)
                    .blur(radius: CGFloat(vm.impactAmount) * 14)
                    .scaleEffect(vm.impactAmount > 0 ? (1.0 + CGFloat(vm.impactAmount) * 0.03) : 1.0)
                    .saturation(1.0 - vm.impactAmount * 0.9)
                    .contrast(1.0 + vm.impactAmount * 0.35)
                    .brightness(vm.impactAmount * 0.10)
                    .overlay(
                        Color.white
                            .opacity(vm.impactAmount * 0.75)
                            .blendMode(.screen)
                    )

                Color.white
                    .ignoresSafeArea()
                    .opacity(vm.whiteOut)
                    .allowsHitTesting(false)
            }
            .preferredColorScheme(.dark)
            .onAppear {
                vm.onFinish = onFinish
                vm.start()
            }
            .onDisappear { vm.stop() }
        }
    }

    @ViewBuilder
    private func sceneContent(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            StarsView()

            Image("Earth")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .scaleEffect(vm.earthGrow ? 14.25 : 1.0)
                .offset(x: 0, y: 190)
                .position(x: w / 2, y: h / 2)

            ShakenFullscreenImage(
                name: "Shuttle no background",
                active: vm.currentWarningName != nil,
                amplitude: 1.2,
                rotation: 0.18,
                xFreq: 34, yFreq: 41, rFreq: 28
            )

            if let name = vm.currentWarningName {
                ShakenFullscreenBlinkingWarning(
                    name: name,
                    amplitude: 6,
                    rotation: 0.6
                )
                .zIndex(999)
            }
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
