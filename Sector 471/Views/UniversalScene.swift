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

    // Global accessibility settings (controls font selection and scaling).
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Shared script store (loads Scripts.json and provides the universal quote text).
    @EnvironmentObject private var scriptStore: ScriptStore

    // Video asset base name (expects Uni.mp4 in the app bundle or as a data asset).
    private let assetName: String = "Uni"

    // MARK: - Timing config
    private let totalShowSeconds: Double = 10.0     // how long to keep the scene visible before fade-to-black
    private let fadeDuration: Double = 1.2          // fade-to-black duration at the end
    private let blackHoldSeconds: Double = 5.0      // how long to keep the final black screen

    private let introFadeOutDuration: Double = 1.2  // how long the initial black overlay fades out
    private let typeStartDelayAfterIntro: Double = 0.5 // delay after intro fade before typing starts

    // Quote text comes from Scripts.json via ScriptStore (universal section).
    private var quoteText: String { scriptStore.scripts.universal.quoteText }

    // MARK: - Layout tuning knobs
    @State private var quoteFontSize: CGFloat = 38
    @State private var quoteOffsetX: CGFloat = 0
    @State private var quoteOffsetY: CGFloat = -400

    // MARK: - Typewriter state
    @State private var typedText: String = ""
    @State private var isTypingStarted: Bool = false
    private let typeCharDelaySeconds: Double = 0.10

    // MARK: - Video loop playback
    @State private var player: AVQueuePlayer? = nil
    @State private var looper: AVPlayerLooper? = nil

    // MARK: - Overlay fades
    @State private var fadeToBlackOpacity: Double = 0.0 // end-of-scene fade
    @State private var introBlackOpacity: Double = 1.0  // initial black reveal overlay

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // Base black background behind everything.
                Color.black.ignoresSafeArea()

                // ===== Background video =====
                // If player is ready, show the video; otherwise show a loading indicator.
                if let player {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .allowsHitTesting(false)
                }

                // ===== Quote text overlay (typewriter) =====
                Text(typedText)
                    .appFixedFont(quoteFontSize, settings: accessibility)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 38)
                    .frame(maxWidth: min(w * 0.92, 700))
                    // Anchor near bottom + offset upwards for cinematic placement.
                    .position(x: w / 2, y: h - 70)
                    .offset(x: quoteOffsetX, y: quoteOffsetY)
                    .allowsHitTesting(false)
                    .accessibilityLabel(typedText)
                    .accessibilityAddTraits(.isStaticText)

                // ===== Intro black overlay =====
                // Starts at 1.0 and fades out to reveal the video.
                Color.black
                    .ignoresSafeArea()
                    .opacity(introBlackOpacity)
                    .allowsHitTesting(false)
                    .zIndex(10_000)

                // ===== End fade-to-black overlay =====
                // Fades in near the end of the timeline.
                Color.black
                    .ignoresSafeArea()
                    .opacity(fadeToBlackOpacity)
                    .allowsHitTesting(false)
                    .zIndex(20_000)
            }
        }

        // MARK: - Lifecycle
        .onAppear {
            // Setup and start looping video.
            setupAndPlayLoop()

            // Reset overlays and typing state when entering the scene.
            introBlackOpacity = 1.0
            fadeToBlackOpacity = 0.0
            typedText = ""
            isTypingStarted = false
        }
        .onDisappear {
            // Stop and release video resources when leaving the scene.
            player?.pause()
            player = nil
            looper = nil

            // Reset overlays to a safe default state.
            fadeToBlackOpacity = 0.0
            introBlackOpacity = 1.0
        }

        // MARK: - Main timeline task
        // Re-run the sequence if the quote text changes (ex: Scripts.json reload).
        .task(id: quoteText) {

            // 1) Fade intro black away.
            withAnimation(.easeInOut(duration: introFadeOutDuration)) {
                introBlackOpacity = 0.0
            }

            // 2) Wait until intro fade finishes + small delay before typing.
            try? await Task.sleep(
                nanoseconds: UInt64((introFadeOutDuration + typeStartDelayAfterIntro) * 1_000_000_000)
            )

            // 3) Type the quote text.
            typedText = ""
            isTypingStarted = true
            await typeQuote()

            // 4) Hold scene visible.
            try? await Task.sleep(nanoseconds: UInt64(totalShowSeconds * 1_000_000_000))

            // 5) Fade to black.
            withAnimation(.easeInOut(duration: fadeDuration)) {
                fadeToBlackOpacity = 1.0
            }

            // 6) Hold black screen (used as a buffer before the next scene).
            try? await Task.sleep(nanoseconds: UInt64(blackHoldSeconds * 1_000_000_000))
        }
    }

    /// Types the quote text into `typedText` one character at a time.
    private func typeQuote() async {
        for ch in quoteText {
            await MainActor.run { typedText.append(ch) }
            try? await Task.sleep(nanoseconds: UInt64(typeCharDelaySeconds * 1_000_000_000))
        }
    }

    /// Attempts to locate the video asset and start looping playback.
    /// 1) Bundle resource: Uni.mp4
    /// 2) NSDataAsset: "Uni" → writes to a temp URL → plays from file
    private func setupAndPlayLoop() {

        // Preferred: video exists as a real bundle resource file.
        if let url = Bundle.main.url(forResource: assetName, withExtension: "mp4") {
            startLoop(with: url)
            return
        }

        // Fallback: the video is stored as a data asset (Assets.xcassets).
        if let dataAsset = NSDataAsset(name: assetName) {
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(assetName)_temp.mp4")

            do {
                try dataAsset.data.write(to: tmpURL, options: .atomic)
                startLoop(with: tmpURL)
                return
            } catch {
                // If writing fails, we silently fail (could be logged if needed).
            }
        }
    }

    /// Starts a seamless looping video playback using AVQueuePlayer + AVPlayerLooper.
    private func startLoop(with url: URL) {
        let item = AVPlayerItem(url: url)

        let queuePlayer = AVQueuePlayer()
        queuePlayer.isMuted = true           // muted cinematic background
        queuePlayer.actionAtItemEnd = .none  // allow looper to manage end-of-item behavior

        // AVPlayerLooper re-enqueues the item automatically to loop continuously.
        let loop = AVPlayerLooper(player: queuePlayer, templateItem: item)

        // Store strong references so the player keeps looping.
        self.player = queuePlayer
        self.looper = loop

        // Start playback.
        queuePlayer.play()
    }
}

// MARK: - Preview
#Preview {
    UniversalScene()
        .environmentObject(AppAccessibilitySettings())
        .environmentObject(ScriptStore.shared)
}
