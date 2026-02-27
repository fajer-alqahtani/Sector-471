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

    enum Step { case universal, earth, space, crash }

    @Published var step: Step = .universal

    @Published var universalOpacity: Double = 1.0
    @Published var earthOpacity: Double = 0.0
    @Published var spaceOpacity: Double = 0.0
    @Published var crashOpacity: Double = 0.0

    @Published var isPaused: Bool = false

    let fadeDuration: Double = 1.2
    let earthHoldSeconds: Double = 26.0
    let universalToEarthSeconds: Double = 11.0
    let earthFadeToBlackDuration: Double = 1.2
    let spaceStartDelayAfterEarthBlack: Double = 1.5

    private var sequenceTask: Task<Void, Never>?

    // ✅ Pause dependency
    private var pauseController: PauseController?

    func configure(pause: PauseController) {
        self.pauseController = pause
    }

    func start() {
        if sequenceTask != nil { return }

        sequenceTask = Task { [weak self] in
            guard let self else { return }
            await self.runSequence()
        }
    }

    func stop() {
        sequenceTask?.cancel()
        sequenceTask = nil
    }

    func pause() {
        isPaused = true
        pauseController?.pause()
    }

    func resume() {
        isPaused = false
        pauseController?.resume()
    }

    private func resetToStart() {
        step = .universal
        universalOpacity = 1.0
        earthOpacity = 0.0
        spaceOpacity = 0.0
        crashOpacity = 0.0
    }

    private func runSequence() async {
        resetToStart()
        guard let pause = pauseController else { return }

        // ✅ pause-aware wait
        await pause.sleep(seconds: universalToEarthSeconds)
        if Task.isCancelled { return }

        step = .earth
        withAnimation(.easeInOut(duration: fadeDuration)) {
            universalOpacity = 0.0
            earthOpacity = 1.0
        }

        let earthToSpaceDelay = earthHoldSeconds + earthFadeToBlackDuration + spaceStartDelayAfterEarthBlack

        // ✅ pause-aware wait
        await pause.sleep(seconds: earthToSpaceDelay)
        if Task.isCancelled { return }

        step = .space
        withAnimation(.easeInOut(duration: fadeDuration)) {
            earthOpacity = 0.0
            spaceOpacity = 1.0
        }
    }

    func startCrashTransition() {
        guard step != .crash else { return }

        step = .crash
        crashOpacity = 0.0

        withAnimation(.easeInOut(duration: fadeDuration)) {
            spaceOpacity = 0.0
            crashOpacity = 1.0
        }
    }
}
