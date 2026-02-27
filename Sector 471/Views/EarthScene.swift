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
//  Text phases (driven by the ViewModel):
//  1) Bottom dialogue box appears (typed) → fades in → holds → fades out
//  2) Top-left text appears (typed) → holds
//  3) Third bottom text appears (typed) → fades in → holds → fades out
//  4) Scene fades to black (transition to the next scene)
//
//  Accessibility:
//  - Fonts respect AppAccessibilitySettings (pixel vs dyslexic).
//  - Each text block provides accessibilityLabel + static text traits.
//  - UI is hit-test disabled for text overlays so they don’t block touches.
//

import SwiftUI

struct EarthScene: View {

    @EnvironmentObject private var accessibility: AppAccessibilitySettings
    @EnvironmentObject private var pause: PauseController        // ✅ ADD
    @StateObject private var vm = EarthSceneViewModel(scriptStore: .shared)

    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    @State private var dialogueOffsetX: CGFloat = 0
    @State private var dialogueOffsetY: CGFloat = -90

    @State private var topLeftFontSize: CGFloat = 28
    @State private var topLeftOffsetX: CGFloat = -30
    @State private var topLeftOffsetY: CGFloat = 40

    @State private var thirdMaxWidth: CGFloat = 700
    @State private var thirdPaddingHorizontal: CGFloat = 38

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

                if vm.showBottomText {
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
                        .opacity(vm.bottomOpacity)
                        .allowsHitTesting(false)
                        .accessibilityLabel(vm.typedBottomText)
                        .accessibilityAddTraits(.isStaticText)
                }

                if vm.showThirdText {
                    Text(vm.typedThirdText)
                        .appFixedFont(40, settings: accessibility)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, thirdPaddingHorizontal)
                        .frame(maxWidth: min(w * 0.92, thirdMaxWidth))
                        .position(x: w / 2, y: h - 70)
                        .offset(x: dialogueOffsetX, y: dialogueOffsetY)
                        .opacity(vm.bottomOpacity)
                        .allowsHitTesting(false)
                        .accessibilityLabel(vm.typedThirdText)
                        .accessibilityAddTraits(.isStaticText)
                }

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
        }
        .preferredColorScheme(.dark)
        .onAppear {
            vm.configure(pause: pause)     // ✅ ADD
            vm.start()
        }
        .onDisappear { vm.stop() }
    }
}

#Preview {
    EarthScene()
        .environmentObject(AppAccessibilitySettings())
        .environmentObject(PauseController())               // ✅ ADD
}
