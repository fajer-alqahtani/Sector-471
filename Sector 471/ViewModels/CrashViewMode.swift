//
//  CrashViewMode.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
//  DESCRIPTION (for the team):
//  CrashViewModel controls the full crash scene timeline (white reveal → fade-to-black sequence).
//  It exposes published state for CrashView to render:
//  - whiteStartOpacity / sceneOpacity: handles the initial white screen reveal into the scene.
//  - fadeCurrent / fadeNext / nextOpacity: drives a smooth crossfade between "Fade to Black" overlay images.
//  - showFinalBackground: switches to the final background after the fade sequence completes.
//
//  The sequence runs inside a single Task so it can be started once, cancelled safely, and avoids
//  multiple overlapping animations if the view appears more than once.
//

import SwiftUI
import Combine

@MainActor
final class CrashViewModel: ObservableObject {

    // MARK: - Published (UI state)
    /// Currently visible fade overlay image name (e.g., "Fade to Black 1").
    @Published var fadeCurrent: String? = nil

    /// Next fade overlay image name used during crossfade (shown above current).
    @Published var fadeNext: String? = nil

    /// Opacity of the next fade overlay during the crossfade animation (0 → 1).
    @Published var nextOpacity: Double = 0.0

    /// When true, the final background is shown after the fade sequence finishes.
    @Published var showFinalBackground: Bool = false

    /// Initial white overlay opacity (starts at 1.0 then animates to 0.0).
    @Published var whiteStartOpacity: Double = 1.0

    /// Controls the overall scene opacity (starts at 0.0 then animates to 1.0).
    @Published var sceneOpacity: Double = 0.0

    // MARK: - Config (timing + assets)
    /// Number of fireflies drawn in the crash scene (used by CrashView).
    let fireflyCount: Int = 35

    /// Duration of the initial white reveal animation.
    let whiteRevealDuration: Double = 1.8

    /// Delay after the white reveal completes before starting the fade sequence.
    let startDelayAfterReveal: Double = 1.5

    /// Delay before starting the fade-to-black overlays (nanoseconds).
    let initialDelayBeforeFadeSequence: UInt64 = 11_000_000_000

    /// Names of fade overlay images in the order they should appear.
    let fadeSequenceNames: [String] = [
        "Fade to Black 1",
        "Fade to Black 2",
        "Fade to Black 3",
        "Fade to Black 4"
    ]

    /// Total time budget per step (crossfade + settle time).
    let stepHold: Double = 1.20

    /// Crossfade duration when moving forward (e.g., 1 → 2 → 3 → 4).
    let forwardCrossfade: Double = 3.95

    /// Crossfade duration when moving backward (if ever used; supports reverse ordering).
    let backwardCrossfade: Double = 4.35

    /// Minimum settling time between steps (prevents negative / too-small pauses).
    let minSettle: Double = 0.10

    // MARK: - Task control (safe)
    /// Holds the currently running sequence task.
    /// Using a Task lets us cancel safely when the view disappears.
    private var task: Task<Void, Never>?

    /// Starts the crash sequence.
    /// Guard prevents launching multiple tasks if start() is called repeatedly.
    func start() {
        if task != nil { return }
        task = Task { [weak self] in
            guard let self else { return }
            await self.run()
        }
    }

    /// Stops the crash sequence and cancels all pending sleeps/animations.
    func stop() {
        task?.cancel()
        task = nil
    }

    // MARK: - Sequence
    /// Full timeline:
    /// 1) Reset state
    /// 2) Animate white overlay out while fading the scene in
    /// 3) Wait (reveal duration + start delay)
    /// 4) Run the fade-to-black image crossfade sequence
    private func run() async {
        reset()

        // 1) White reveal → show scene
        withAnimation(.easeInOut(duration: whiteRevealDuration)) {
            whiteStartOpacity = 0.0   // fade white overlay out
            sceneOpacity = 1.0        // fade scene in
        }

        // 2) Wait for reveal + extra delay before starting fade sequence
        try? await Task.sleep(
            nanoseconds: UInt64((whiteRevealDuration + startDelayAfterReveal) * 1_000_000_000)
        )
        if Task.isCancelled { return }

        // 3) Start fade-to-black overlays
        await runFadeSequenceSmooth()
    }

    /// Crossfades between the overlay images in fadeSequenceNames.
    /// Uses `fadeCurrent` for the base layer and `fadeNext` + `nextOpacity` for the overlay layer.
    private func runFadeSequenceSmooth() async {
        // Initial delay before any fade overlays appear.
        try? await Task.sleep(nanoseconds: initialDelayBeforeFadeSequence)
        if Task.isCancelled { return }

        // Initialize to the first overlay image.
        fadeCurrent = fadeSequenceNames.first
        fadeNext = nil
        nextOpacity = 0.0
        showFinalBackground = false

        // Start at index 1 because index 0 is already active as fadeCurrent.
        for i in 1..<fadeSequenceNames.count {
            if Task.isCancelled { return }

            let nextName = fadeSequenceNames[i]

            // Determine fade direction (supports reverse sequences if ever needed).
            let currentLevel = fadeCurrent.map(fadeLevel) ?? 0
            let nextLevel = fadeLevel(from: nextName)
            let goingBack = nextLevel < currentLevel

            // Choose crossfade timing based on direction.
            let crossfade = goingBack ? backwardCrossfade : forwardCrossfade

            // Settle time = leftover time after crossfade (clamped).
            let settle = max(minSettle, stepHold - crossfade)

            // Prepare the next overlay above the current one.
            fadeNext = nextName
            nextOpacity = 0.0

            // Animate the next overlay in (0 → 1).
            withAnimation(.easeInOut(duration: crossfade)) {
                nextOpacity = 1.0
            }

            // Wait for the crossfade to finish.
            try? await Task.sleep(nanoseconds: UInt64(crossfade * 1_000_000_000))
            if Task.isCancelled { return }

            // Promote next → current and clear the temporary overlay.
            fadeCurrent = nextName
            fadeNext = nil
            nextOpacity = 0.0

            // Optional settle time between steps.
            if settle > 0 {
                try? await Task.sleep(nanoseconds: UInt64(settle * 1_000_000_000))
            }
        }

        if Task.isCancelled { return }

        // End of sequence: remove overlays and reveal final background state.
        fadeCurrent = nil
        fadeNext = nil
        nextOpacity = 0.0
        showFinalBackground = true
    }

    /// Extracts a "level" from the fade image name (e.g. "Fade to Black 3" -> 3).
    /// Used to decide if we’re moving forward or backward through the sequence.
    private func fadeLevel(from name: String) -> Int {
        let digits = name.compactMap { $0.isNumber ? Int(String($0)) : nil }
        return digits.last ?? 0
    }

    /// Resets the entire sequence state to the initial values.
    private func reset() {
        fadeCurrent = nil
        fadeNext = nil
        nextOpacity = 0.0
        showFinalBackground = false

        whiteStartOpacity = 1.0
        sceneOpacity = 0.0
    }
}
