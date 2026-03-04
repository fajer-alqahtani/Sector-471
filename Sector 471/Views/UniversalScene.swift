//
//  UniversalScene.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 23/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  UniversalScene is the intro cinematic scene.
//  It plays a looping background video ("Uni.mp4") and types a quote text on top
//  (loaded from Scripts.json via ScriptStore).
//
//  Timeline:
//  1) Start fully black (introBlackOpacity = 1).
//  2) Fade the intro black overlay out (reveals the video).
//  3) After a short delay, type the quote text character-by-character (typewriter effect).
//  4) Keep the scene visible for `totalShowSeconds`.
//  5) Fade to black (fadeToBlackOpacity = 1) and hold black for `blackHoldSeconds`.
//     FlowViewModel uses these timings to transition to EarthScene.
//
//  Architecture:
//  - Uses environment objects:
//      * AppAccessibilitySettings for font style/scaling.
//      * ScriptStore for reading the universal quote text.
//  - Video playback uses AVQueuePlayer + AVPlayerLooper to loop seamlessly.
//  - The typing sequence is driven by a `.task(id: quoteText)` so it re-runs if the quote changes.
//
//  Notes:
//  - Video is muted by default.
//  - setupAndPlayLoop first tries to load "Uni.mp4" from Bundle resources,
//    and falls back to NSDataAsset if the video is embedded as a data asset.
//

import SwiftUI
import AVKit

struct UniversalScene: View {

    @EnvironmentObject private var accessibility: AppAccessibilitySettings
    @EnvironmentObject private var scriptStore: ScriptStore
    @EnvironmentObject private var pause: PauseController

    // Callback used by the container to advance to the next scene immediately.
    var onAdvance: () -> Void = {}

    private let assetName: String = "Uni"

    private let totalShowSeconds: Double = 10.0
    private let fadeDuration: Double = 1.2
    private let blackHoldSeconds: Double = 5.0

    private let introFadeOutDuration: Double = 1.2
    private let typeStartDelayAfterIntro: Double = 0.5

    private var quoteText: String { scriptStore.scripts.universal.quoteText }

    @State private var quoteFontSize: CGFloat = 38
    @State private var quoteOffsetX: CGFloat = 0
    @State private var quoteOffsetY: CGFloat = -400

    @State private var typedText: String = ""
    @State private var isTypingStarted: Bool = false
    @State private var isTypingCompleted: Bool = false
    private let typeCharDelaySeconds: Double = 0.10

    @State private var player: AVQueuePlayer? = nil
    @State private var looper: AVPlayerLooper? = nil

    @State private var fadeToBlackOpacity: Double = 0.0
    @State private var introBlackOpacity: Double = 1.0

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                Color.black.ignoresSafeArea()

                if let player {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .allowsHitTesting(false)
                }

                Text(typedText)
                    .appFixedFont(quoteFontSize, settings: accessibility)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 38)
                    .frame(maxWidth: min(w * 0.92, 700))
                    .position(x: w / 2, y: h - 70)
                    .offset(x: quoteOffsetX, y: quoteOffsetY)
                    .allowsHitTesting(false)
                    .accessibilityLabel(typedText)
                    .accessibilityAddTraits(.isStaticText)

                Color.black
                    .ignoresSafeArea()
                    .opacity(introBlackOpacity)
                    .allowsHitTesting(false)
                    .zIndex(10_000)

                Color.black
                    .ignoresSafeArea()
                    .opacity(fadeToBlackOpacity)
                    .allowsHitTesting(false)
                    .zIndex(20_000)
            }
            // Make the entire scene tappable for skip/advance behavior.
            .contentShape(Rectangle())
            .onTapGesture {
                handleTap()
            }
        }
        .onAppear {
            setupAndPlayLoop()

            introBlackOpacity = 1.0
            fadeToBlackOpacity = 0.0
            typedText = ""
            isTypingStarted = false
            isTypingCompleted = false
        }
        .onDisappear {
            player?.pause()
            player = nil
            looper = nil

            fadeToBlackOpacity = 0.0
            introBlackOpacity = 1.0
        }
        .task(id: quoteText) {
            // Reset typing state for new quote
            typedText = ""
            isTypingStarted = false
            isTypingCompleted = false

            withAnimation(.easeInOut(duration: introFadeOutDuration)) {
                introBlackOpacity = 0.0
            }

            // Wait a moment before starting to type
            await pause.sleep(seconds: introFadeOutDuration + typeStartDelayAfterIntro)

            // Start typing if not already completed via an early tap
            if !isTypingCompleted {
                typedText = ""
                isTypingStarted = true
                await typeQuote()
            }

            // If typing was completed early, typedText is already full; continue the normal hold/black timings.
            await pause.sleep(seconds: totalShowSeconds)

            withAnimation(.easeInOut(duration: fadeDuration)) {
                fadeToBlackOpacity = 1.0
            }

            await pause.sleep(seconds: blackHoldSeconds)
        }
    }

    private func handleTap() {
        // First tap while typing: reveal instantly
        if isTypingStarted && !isTypingCompleted {
            typedText = quoteText
            isTypingCompleted = true
            return
        }

        // If typing hasn't started yet (e.g., during intro fade), also reveal immediately
        if !isTypingStarted && !isTypingCompleted {
            typedText = quoteText
            isTypingStarted = true
            isTypingCompleted = true
            return
        }

        // Typing already complete: advance to the next scene
        onAdvance()
    }

    private func typeQuote() async {
        for ch in quoteText {
            if Task.isCancelled { return }
            if isTypingCompleted { return } // stop typing if user revealed early
            await MainActor.run { typedText.append(ch) }

            await pause.sleep(seconds: typeCharDelaySeconds)
        }
        // Finished normally
        isTypingCompleted = true
    }

    private func setupAndPlayLoop() {
        if let url = Bundle.main.url(forResource: assetName, withExtension: "mp4") {
            startLoop(with: url)
            return
        }

        if let dataAsset = NSDataAsset(name: assetName) {
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(assetName)_temp.mp4")

            do {
                try dataAsset.data.write(to: tmpURL, options: .atomic)
                startLoop(with: tmpURL)
                return
            } catch { }
        }
    }

    private func startLoop(with url: URL) {
        let item = AVPlayerItem(url: url)

        let queuePlayer = AVQueuePlayer()
        queuePlayer.isMuted = true
        queuePlayer.actionAtItemEnd = .none

        let loop = AVPlayerLooper(player: queuePlayer, templateItem: item)

        self.player = queuePlayer
        self.looper = loop

        queuePlayer.play()
    }
}

#Preview {
    UniversalScene()
        .environmentObject(AppAccessibilitySettings())
        .environmentObject(ScriptStore.shared)
        .environmentObject(PauseController())
}

