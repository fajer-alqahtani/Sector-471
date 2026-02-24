//
//  FlowViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
//  DESCRIPTION (for the team):
//  FlowViewModel controls the main story flow between scenes in EarthSpaceCrashFlow.
//  It manages which scene is currently active (Step) and uses opacity crossfades to
//  transition smoothly between:
//    UniversalScene  →  EarthScene  →  SpaceScene  →  CrashView
//
//  How it works:
//  - `step` decides which scene should be displayed.
//  - Each scene has its own opacity (universalOpacity, earthOpacity, spaceOpacity, crashOpacity).
//    We animate these values to crossfade between scenes.
//  - `start()` runs the timeline (Universal → Earth → Space) in a single Task so it can be
//    cancelled safely and won’t start twice.
//  - Crash is started manually via `startCrashTransition()` (typically called when Space finishes).
//  - `isPaused` is a UI state flag (pause menu). In this file it’s stored but not yet used to
//    block the timeline sleeps—so pause currently affects UI, not timing, unless the views handle it.
//

import SwiftUI
import Combine

@MainActor
final class FlowViewModel: ObservableObject {

    /// The currently active scene in the story flow.
    enum Step { case universal, earth, space, crash }

    // MARK: - Published (scene selection + fade state)
    /// Which scene is active (used by the view to decide what to render).
    @Published var step: Step = .universal

    /// Opacity values that drive crossfades between scenes (0 = hidden, 1 = fully visible).
    @Published var universalOpacity: Double = 1.0
    @Published var earthOpacity: Double = 0.0
    @Published var spaceOpacity: Double = 0.0
    @Published var crashOpacity: Double = 0.0

    /// Pause state for the UI (pause menu / stop interactions).
    /// NOTE: This ViewModel currently does not pause the Task’s timing; it’s a UI flag only.
    @Published var isPaused: Bool = false

    // MARK: - Timeline Config (seconds)
    /// Duration used for all crossfade animations between scenes.
    let fadeDuration: Double = 1.2

    /// How long the Earth scene stays before transitioning onward (not counting fade-to-black).
    let earthHoldSeconds: Double = 26.0

    /// When to switch from Universal → Earth (includes Universal’s own animation timing).
    let universalToEarthSeconds: Double = 11.0

    /// Earth scene fade-to-black duration (used when computing Earth → Space start time).
    let earthFadeToBlackDuration: Double = 1.2

    /// Extra delay after Earth finishes fading to black before Space begins.
    let spaceStartDelayAfterEarthBlack: Double = 1.5

    // MARK: - Task control
    /// Sequence task that runs the timeline so we can cancel safely and avoid duplicates.
    private var sequenceTask: Task<Void, Never>?

    /// Starts the flow timeline (Universal → Earth → Space).
    /// Guard prevents multiple overlapping sequences.
    func start() {
        if sequenceTask != nil { return }

        sequenceTask = Task { [weak self] in
            guard let self else { return }
            await self.runSequence()
        }
    }

    /// Stops the flow timeline (cancels sleeps/animations in progress).
    func stop() {
        sequenceTask?.cancel()
        sequenceTask = nil
    }

    /// Marks the app as paused (UI can show pause menu / disable input).
    func pause() { isPaused = true }

    /// Marks the app as resumed.
    func resume() { isPaused = false }

    /// Resets to the starting scene and initial opacity values.
    private func resetToStart() {
        step = .universal
        universalOpacity = 1.0
        earthOpacity = 0.0
        spaceOpacity = 0.0
        crashOpacity = 0.0
    }

    /// Runs the main timeline:
    /// 1) Wait for Universal to finish its own intro timing
    /// 2) Crossfade Universal → Earth
    /// 3) Wait Earth hold + fade-to-black + extra delay
    /// 4) Crossfade Earth → Space
    private func runSequence() async {
        resetToStart()

        // 1) Wait before switching to Earth (matches UniversalScene timing).
        try? await Task.sleep(nanoseconds: UInt64(universalToEarthSeconds * 1_000_000_000))

        // 2) Universal → Earth crossfade.
        step = .earth
        withAnimation(.easeInOut(duration: fadeDuration)) {
            universalOpacity = 0.0
            earthOpacity = 1.0
        }

        // 3) Total wait time before starting Space:
        //    Earth hold + Earth fade-to-black + delay after black.
        let earthToSpaceDelay = earthHoldSeconds + earthFadeToBlackDuration + spaceStartDelayAfterEarthBlack
        try? await Task.sleep(nanoseconds: UInt64(earthToSpaceDelay * 1_000_000_000))

        // 4) Earth → Space crossfade.
        step = .space
        withAnimation(.easeInOut(duration: fadeDuration)) {
            earthOpacity = 0.0
            spaceOpacity = 1.0
        }
    }

    /// Triggers the transition from Space → Crash.
    /// This is manual because Space decides when it’s "done" (e.g., after warnings/impact).
    func startCrashTransition() {
        guard step != .crash else { return }

        // Switch to crash scene (view uses this to start rendering CrashView).
        step = .crash
        crashOpacity = 0.0

        // Crossfade Space → Crash.
        withAnimation(.easeInOut(duration: fadeDuration)) {
            spaceOpacity = 0.0
            crashOpacity = 1.0
        }
    }
}
