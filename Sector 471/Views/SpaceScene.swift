//
//  SpaceScene.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  SpaceScene is the “space flight / impact” cinematic scene.
//  It renders a star background + Earth growth + shuttle layer, then plays a warning + impact
//  sequence driven by SpaceSceneViewModel.
//
//  What happens in this scene (timeline):
//  1) Earth slowly grows (scale animation) to create a cinematic approach effect.
//  2) A fullscreen warning overlay appears and blinks for a while (currentWarningName).
//  3) After the warning, an impact ramp begins (impactAmount increases), which applies:
//     - blur, zoom, desaturation, contrast/brightness changes, and a bright white screen blend.
//     - optional shaking on the shuttle + warning layers via ShakeWrapper.
//  4) Finally, a white flash (whiteOut) covers the screen briefly.
//  5) When done, the ViewModel calls `onFinish()` to transition to CrashView.
//
//  Architecture:
//  - SpaceSceneViewModel holds all timings and publishes state (earthGrow, warning, impactAmount, whiteOut).
//  - SpaceScene renders visuals and reads the published values to apply effects.
//  - Private helper views in this file provide reusable full-screen shake + blinking warning.
//

//import SwiftUI
//
//struct SpaceScene: View {
//
//    // Global accessibility settings (not used directly here yet, but kept for consistency/future text).
//    @EnvironmentObject private var accessibility: AppAccessibilitySettings
//
//    // ViewModel that drives the space sequence (Earth growth → warning → impact → white flash).
//    @StateObject private var vm = SpaceSceneViewModel()
//
//    // Callback from parent flow when space scene completes (Space → Crash transition).
//    var onFinish: () -> Void = {}
//
//    var body: some View {
//        GeometryReader { proxy in
//            let w = proxy.size.width
//            let h = proxy.size.height
//
//            ZStack {
//
//                // ===== Main scene content =====
//                // We apply the "impact" effects to this whole layer using vm.impactAmount.
//                sceneContent(w: w, h: h)
//                    .blur(radius: CGFloat(vm.impactAmount) * 14)
//                    .scaleEffect(vm.impactAmount > 0 ? (1.0 + CGFloat(vm.impactAmount) * 0.03) : 1.0)
//                    .saturation(1.0 - vm.impactAmount * 0.9)
//                    .contrast(1.0 + vm.impactAmount * 0.35)
//                    .brightness(vm.impactAmount * 0.10)
//                    // Screen-like white glow during impact to boost intensity.
//                    .overlay(
//                        Color.white
//                            .opacity(vm.impactAmount * 0.75)
//                            .blendMode(.screen)
//                    )
//
//                // ===== Final white flash overlay =====
//                // At the very end, vm.whiteOut animates to 1.0 briefly to simulate a flash.
//                Color.white
//                    .ignoresSafeArea()
//                    .opacity(vm.whiteOut)
//                    .allowsHitTesting(false)
//            }
//            .preferredColorScheme(.dark)
//            .onAppear {
//                // Provide the finish callback to the ViewModel and start the sequence.
//                vm.onFinish = onFinish
//                vm.start()
//            }
//            .onDisappear {
//                // Cancel the sequence if the view disappears to avoid running tasks in the background.
//                vm.stop()
//            }
//        }
//    }
//
//    /// Builds the base scene layers (without the global impact post-processing).
//    @ViewBuilder
//    private func sceneContent(w: CGFloat, h: CGFloat) -> some View {
//        ZStack {
//
//            // Background: stars + animated lines (StarsView).
//            StarsView()
//
//            // Earth image that grows over time (controlled by vm.earthGrow).
//            Image("Earth")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 250)
//                .scaleEffect(vm.earthGrow ? 14.25 : 1.0)
//                .offset(x: 0, y: 190)
//                .position(x: w / 2, y: h / 2)
//
//            // Shuttle layer with optional shake when warning is active.
//            ShakenFullscreenImage(
//                name: "Shuttle no background",
//                active: vm.currentWarningName != nil,
//                amplitude: 1.2,
//                rotation: 0.18,
//                xFreq: 34, yFreq: 41, rFreq: 28
//            )
//
//            // Warning overlay: only shown while currentWarningName is not nil.
//            if let name = vm.currentWarningName {
//                ShakenFullscreenBlinkingWarning(
//                    name: name,
//                    amplitude: 6,
//                    rotation: 0.6
//                )
//                .zIndex(999) // ensure warning stays above Earth + shuttle
//            }
//        }
//    }
//}
//
//// MARK: - Fullscreen Shaken Image
///// Draws a fullscreen image and applies ShakeWrapper motion when `active` is true.
///// Used for the shuttle layer so it can shake during warnings/impact.
//private struct ShakenFullscreenImage: View {
//    let name: String
//    let active: Bool
//    var amplitude: CGFloat = 0
//    var rotation: Double = 0.35
//    var xFreq: Double = 40
//    var yFreq: Double = 55
//    var rFreq: Double = 35
//
//    var body: some View {
//        ShakeWrapper(
//            active: active,
//            amplitude: amplitude,
//            rotation: rotation,
//            xFreq: xFreq,
//            yFreq: yFreq,
//            rFreq: rFreq
//        ) {
//            Image(name)
//                .resizable()
//                .scaledToFill()
//                // Slight vertical scaling to fill edges consistently in landscape.
//                .scaleEffect(x: 1.0, y: 1.07)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
//        .compositingGroup()
//        // Mask to full screen to prevent shaking from revealing empty edges.
//        .mask(Rectangle().ignoresSafeArea())
//    }
//}
//
//// MARK: - Fullscreen Blinking Warning
///// Draws a fullscreen warning image that both shakes and blinks.
///// Blink is handled via a repeating SwiftUI animation toggling `blink`.
//private struct ShakenFullscreenBlinkingWarning: View {
//    let name: String
//    var amplitude: CGFloat = 0
//    var rotation: Double = 0
//
//    @State private var blink = false
//
//    var body: some View {
//        ShakeWrapper(active: true, amplitude: amplitude, rotation: rotation) {
//            Image(name)
//                .resizable()
//                .scaledToFill()
//                .scaleEffect(x: 1.0, y: 1.07)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .ignoresSafeArea()
//                // Blink effect (opacity + slight brightness pulse).
//                .opacity(blink ? 0.5 : 1.0)
//                .brightness(blink ? 0.08 : 0.0)
//                .onAppear {
//                    withAnimation(.easeInOut(duration: 0.16).repeatForever(autoreverses: true)) {
//                        blink.toggle()
//                    }
//                }
//        }
//        .compositingGroup()
//        .mask(Rectangle().ignoresSafeArea())
//    }
//}
//
//// MARK: - ShakeWrapper
///// A reusable shake/rumble wrapper that uses TimelineView for per-frame updates.
///// When `active` is false, the content is rendered normally (no motion).
//private struct ShakeWrapper<Content: View>: View {
//    let active: Bool
//    var amplitude: CGFloat = 0
//    var rotation: Double = 0.35
//    var xFreq: Double = 40
//    var yFreq: Double = 55
//    var rFreq: Double = 35
//    let content: () -> Content
//
//    var body: some View {
//        TimelineView(.animation) { timeline in
//            let t = timeline.date.timeIntervalSinceReferenceDate
//
//            // Offset and rotation are driven by sine/cosine to create vibration.
//            let x = active ? CGFloat(sin(t * xFreq)) * amplitude : 0
//            let y = active ? CGFloat(cos(t * yFreq)) * amplitude : 0
//            let r = active ? sin(t * rFreq) * rotation : 0
//
//            content()
//                .rotationEffect(.degrees(r), anchor: .center)
//                .offset(x: x, y: y)
//        }
//    }
//}
//
//// MARK: - Previews
//
//
//#Preview("SpaceScene - Landscape", traits: .landscapeLeft) {
//    SpaceScene()
//        .environmentObject(AppAccessibilitySettings())
//}
import SwiftUI

struct SpaceScene: View {

    @EnvironmentObject private var accessibility: AppAccessibilitySettings
    @StateObject private var vm = SpaceSceneViewModel()

    var onFinish: () -> Void = {}

    // MARK: - Choice State
    @State private var selectedChoice: Int? = nil

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {

                // ===== Main scene content =====
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

                // ===== Diamond Choices Overlay =====
                if selectedChoice == nil {
                    DiamondChoicesView(selectedChoice: $selectedChoice)
                        .zIndex(1000)
                }

                // ===== Final white flash =====
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
            .onDisappear {
                vm.stop()
            }
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

// MARK: - Diamond Choices View

private struct DiamondChoicesView: View {

    @Binding var selectedChoice: Int?

    var body: some View {
        VStack {
            Spacer()
            Image("choose")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                                .opacity(selectedChoice == nil ? 1 : 0)
                                .offset(y: -120)
                                .animation(.easeInOut(duration: 0.3), value: selectedChoice)


            HStack(spacing: 250) {

                diamondButton(
                    id: 0,
                    diamondImage: "reddiamond",
                    underImage: "savetheship"
                )

                diamondButton(
                    id: 1,
                    diamondImage: "bluediamond",
                    underImage: "saveyourself"
                )
            }
            .padding(.bottom, 200)
        }
        .animation(.easeInOut(duration: 0.25), value: selectedChoice)
    }

    private func diamondButton(id: Int, diamondImage: String, underImage: String) -> some View {
        Button {
            if selectedChoice == nil {
                selectedChoice = id
            }
        } label: {
            VStack(spacing: 12) {

                Image(diamondImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .shadow(radius: 8)

                Image(underImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)
            }
        }
        .buttonStyle(.plain)
        .disabled(selectedChoice != nil)
        .opacity(opacity(for: id))
        .scaleEffect(scale(for: id))
    }

    private func opacity(for id: Int) -> Double {
        if let selectedChoice {
            return selectedChoice == id ? 1.0 : 0.35
        }
        return 1.0
    }

    private func scale(for id: Int) -> CGFloat {
        if let selectedChoice {
            return selectedChoice == id ? 1.05 : 1.0
        }
        return 1.0
    }
}

// MARK: - ShakeWrapper + Supporting Views

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
                .rotationEffect(.degrees(r))
                .offset(x: x, y: y)
        }
    }
}
#Preview("SpaceScene - Landscape", traits: .landscapeLeft) {
    SpaceScene()
        .environmentObject(AppAccessibilitySettings())
}
