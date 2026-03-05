//
//  EarthScene.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 23/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  EarthScene is the “Earth + Moon” cinematic scene.
//  It renders the static background images and displays story text in a timed sequence
//  controlled by EarthSceneViewModel (typewriter + fades + visibility switches).
//
//  Tap behavior (perma reveal; no skipping scenes):
//  - On tap, immediately force the currently visible text to its full value and keep it fully shown
//    (ignore further typing/fades for that block).
//    Priority: top-left → third (bottom-style) → initial bottom.
//
//  Accessibility:
//  - Fonts respect AppAccessibilitySettings (pixel vs dyslexic).
//  - Each text block provides accessibilityLabel + static text traits.
//  - UI is hit-test disabled for text overlays so they don’t block touches.
//

import SwiftUI
import AVKit
import AVFoundation

struct EarthScene: View {

    @EnvironmentObject private var accessibility: AppAccessibilitySettings
    @EnvironmentObject private var pause: PauseController
    @EnvironmentObject private var scriptStore: ScriptStore
    @StateObject private var vm = EarthSceneViewModel(scriptStore: .shared)

    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    @State private var dialogueOffsetX: CGFloat = 0
    @State private var dialogueOffsetY: CGFloat = -90

    @State private var topLeftFontSize: CGFloat = 28
    @State private var topLeftOffsetX: CGFloat = -30
    @State private var topLeftOffsetY: CGFloat = 40

    @State private var thirdMaxWidth: CGFloat = 700
    @State private var thirdPaddingHorizontal: CGFloat = 38

    // Perma-reveal flags
    @State private var permaTopLeft: Bool = false
    @State private var permaBottomThird: Bool = false

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                Image("emptyspace")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w + 2, height: h + 2)
                    .clipped()
                    .ignoresSafeArea()

                Image("Earth and moon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 1200)
                    .position(x: w / 2, y: h / 2)

                // Initial bottom dialogue (render if VM shows it OR we’re perma-keeping bottom/third)
                if vm.showBottomText || (permaBottomThird && vm.showBottomText) {
                    Text(vm.typedBottomText)
                        .appFixedFont(40, settings: accessibility)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 38)
                        .padding(.vertical, 12)
                        .frame(maxWidth: min(w * 0.92, 700))
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.09))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(hexFillColor, lineWidth: 2)
                        )
                        .position(x: w / 2, y: h - 70)
                        .offset(x: dialogueOffsetX, y: dialogueOffsetY)
                        .opacity(permaBottomThird ? 1.0 : vm.bottomOpacity)
                        .allowsHitTesting(false)
                        .accessibilityLabel(vm.typedBottomText)
                        .accessibilityAddTraits(.isStaticText)
                }

                // Later bottom-style “third” block (render if VM shows it OR we’re perma-keeping bottom/third)
                if vm.showThirdText || (permaBottomThird && vm.showThirdText) {
                    Text(vm.typedThirdText)
                        .appFixedFont(40, settings: accessibility)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, thirdPaddingHorizontal)
                        .frame(maxWidth: min(w * 0.92, thirdMaxWidth))
                        .position(x: w / 2, y: h - 70)
                        .offset(x: dialogueOffsetX, y: dialogueOffsetY)
                        .opacity(permaBottomThird ? 1.0 : vm.bottomOpacity)
                        .allowsHitTesting(false)
                        .accessibilityLabel(vm.typedThirdText)
                        .accessibilityAddTraits(.isStaticText)
                }

                // Top-left text (permaTopLeft keeps it fully revealed while VM shows it)
                if vm.showTopLeftText {
                    Text(vm.typedTopLeftText)
                        .appFixedFont(topLeftFontSize, settings: accessibility)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: min(w * 0.80, 750), alignment: .leading)
                        .position(x: 614, y: 154)
                        .offset(x: topLeftOffsetX, y: topLeftOffsetY)
                        .transition(.opacity)
                        .allowsHitTesting(false)
                        .accessibilityLabel(vm.typedTopLeftText)
                        .accessibilityAddTraits(.isStaticText)
                }

                Color.black
                    .ignoresSafeArea()
                    .opacity(vm.fadeToBlackOpacity)
                    .allowsHitTesting(false)
            }
            // Full-screen tap to force the visible text to full immediately and keep it shown.
            .contentShape(Rectangle())
            .onTapGesture { permaRevealVisible() }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            vm.configure(pause: pause)
            vm.start()
            AudioManager.shared.playLoopingSFX("Space_Sound", ext: "wav", volume: 9.0)


        }
        .onDisappear { vm.stop() }
    }

    // MARK: - Perma reveal helper

    private func permaRevealVisible() {
        // Priority: top-left → third (bottom-style) → initial bottom.
        if vm.showTopLeftText {
            // Align phase to top-left and reveal via VM (cancels typing for that phase).
            vm.revealCurrentPhaseNow()
            permaTopLeft = true
            return
        }

        if vm.showThirdText {
            // Align phase to third and reveal via VM.
            // currentPhase will already be .third when third is visible in the default sequence.
            vm.revealCurrentPhaseNow()
            permaBottomThird = true
            return
        }

        if vm.showBottomText {
            // Align phase to bottom and reveal via VM.
            vm.revealCurrentPhaseNow()
            permaBottomThird = true
            return
        }
    }
}

#Preview {
    EarthScene()
        .environmentObject(AppAccessibilitySettings())
        .environmentObject(PauseController())
        .environmentObject(ScriptStore.shared)
}
