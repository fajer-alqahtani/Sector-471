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

    // Global accessibility settings (controls font selection and scaling).
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // ViewModel that drives all timed text behavior using Scripts.json.
    @StateObject private var vm = EarthSceneViewModel(scriptStore: .shared)

    // Accent color used for borders (fallback to white if hex fails).
    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    // MARK: - Layout tuning knobs (easy to adjust per device)
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

                // ===== Background layer =====
                Image("emptyspace")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w + 2, height: h + 2)
                    .clipped()
                    .ignoresSafeArea()

                // Earth + Moon image centered on screen.
                Image("Earth and moon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 1200)
                    .position(x: w / 2, y: h / 2)

                // ===== Phase 1: Bottom dialogue text =====
                // Visible only when vm.showBottomText is true.
                if vm.showBottomText {
                    Text(vm.typedBottomText)
                        .appFixedFont(40, settings: accessibility)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 38)
                        .padding(.vertical, 12)
                        .frame(maxWidth: min(w * 0.92, 700))
                        // Slight purple glass-like background for readability.
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.09))
                        )
                        // Border accent.
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(hexFillColor, lineWidth: 2)
                        )
                        // Anchored near the bottom with optional tuning offsets.
                        .position(x: w / 2, y: h - 70)
                        .offset(x: dialogueOffsetX, y: dialogueOffsetY)
                        // Fade in/out driven by the view model.
                        .opacity(vm.bottomOpacity)
                        // Prevent the text overlay from blocking taps.
                        .allowsHitTesting(false)
                        // Accessibility: announce the typed text as static content.
                        .accessibilityLabel(vm.typedBottomText)
                        .accessibilityAddTraits(.isStaticText)
                }

                // ===== Phase 3: Third (bottom) text =====
                // Uses the same bottomOpacity fade driver as Phase 1.
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

                // ===== Phase 2: Top-left text =====
                // Appears after the first dialogue fades out.
                if vm.showTopLeftText {
                    Text(vm.typedTopLeftText)
                        .appFixedFont(topLeftFontSize, settings: accessibility)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: min(w * 0.80, 750), alignment: .leading)
                        // Base position tuned for the scene layout.
                        .position(x: 614, y: 154)
                        .offset(x: topLeftOffsetX, y: topLeftOffsetY)
                        .transition(.opacity)
                        .allowsHitTesting(false)
                        .accessibilityLabel(vm.typedTopLeftText)
                        .accessibilityAddTraits(.isStaticText)
                }

                // ===== Final fade-to-black overlay =====
                // Used to transition smoothly to the next scene.
                Color.black
                    .ignoresSafeArea()
                    .opacity(vm.fadeToBlackOpacity)
                    .allowsHitTesting(false)
            }
        }
        .preferredColorScheme(.dark) // keep scene dark regardless of system setting
        .onAppear { vm.start() }     // start timeline when entering
        .onDisappear { vm.stop() }   // stop/cancel timeline when leaving
    }
}

// MARK: - Preview
#Preview {
    EarthScene()
        .environmentObject(AppAccessibilitySettings())
}
