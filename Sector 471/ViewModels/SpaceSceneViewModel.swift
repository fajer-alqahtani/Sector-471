//
//  SpaceSceneViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
//  DESCRIPTION (for the team):
//  SpaceSceneViewModel drives the Space scene timeline (Earth growing → warning overlay → impact ramp → white flash).
//  It exposes published state that SpaceScene uses to animate and render:
//  - earthGrow: triggers the big Earth scale animation over a long duration.
//  - currentWarningName: shows/hides the warning overlay image (ex: "FullWarning").
//  - impactAmount: ramps up from small to 1.0 to drive shaking/impact effects in the UI.
//  - whiteOut: fades in a white overlay briefly at the end to simulate a flash.
//  When the whole sequence is done, it calls `onFinish()` so the flow can transition to CrashView.
//
//  The sequence is run inside a single Task so it can be started once and cancelled safely.
//

import SwiftUI
import Combine

@MainActor
final class SpaceSceneViewModel: ObservableObject {

    // MARK: - Published (UI state)
    /// Drives the Earth scale animation in the Space scene.
    @Published var earthGrow: Bool = false

    /// Name of the currently visible warning overlay image.
    /// nil = no warning on screen.
    @Published var currentWarningName: String? = nil

    /// Normalized impact value used to drive shake / impact effects (0 → 1).
    @Published var impactAmount: Double = 0.0

    /// White overlay opacity used to create the final white flash (0 → 1).
    @Published var whiteOut: Double = 0.0

    // MARK: - Callback
    /// Called when the Space sequence completes (used to trigger Space → Crash transition).
    var onFinish: () -> Void = {}

    // MARK: - Timing
    /// Delay before showing the warning overlay (nanoseconds).
    let warningDelayBeforeShow: UInt64 = 10_000_000_000

    /// How long the warning stays visible (nanoseconds).
    let warningVisibleDuration: UInt64 = 10_000_000_000

    /// Optional delay after the warning disappears before impact begins.
    let impactDelayAfterWarningSeconds: Double = 0.0

    /// Duration of the impact ramp animation (how long shaking ramps up).
    let impactRampSeconds: Double = 5.5

    /// How long the white flash remains before finishing (seconds).
    let whiteOutHoldSeconds: Double = 0.6

    // MARK: - Task control
    /// Single running sequence task (prevents duplicate timelines).
    private var sequenceTask: Task<Void, Never>?

    /// Starts the Space scene timeline.
    /// Guard prevents launching multiple overlapping tasks.
    func start() {
        if sequenceTask != nil { return }
        sequenceTask = Task { [weak self] in
            guard let self else { return }
            await self.runSequence()
        }
    }

    /// Stops the timeline safely (cancels sleeps and prevents onFinish from firing).
    func stop() {
        sequenceTask?.cancel()
        sequenceTask = nil
    }

    /// Runs the full Space scene sequence (Earth grow → warning → impact → white flash → finish callback).
    private func runSequence() async {
        reset()

        // 1) Earth grows slowly over a long cinematic duration.
        withAnimation(.easeInOut(duration: 40.0)) {
            earthGrow = true
        }

        // 2) Wait, then show the warning overlay.
        try? await Task.sleep(nanoseconds: warningDelayBeforeShow)
        if Task.isCancelled { return }
        currentWarningName = "FullWarning"

        // 3) Keep warning visible, then hide it.
        try? await Task.sleep(nanoseconds: warningVisibleDuration)
        if Task.isCancelled { return }
        currentWarningName = nil

        // 4) Optional delay between warning and impact.
        try? await Task.sleep(nanoseconds: UInt64(impactDelayAfterWarningSeconds * 1_000_000_000))
        if Task.isCancelled { return }

        // 5) Ramp up impact amount (used by shake / impact visuals).
        impactAmount = 0.02
        whiteOut = 0.0

        withAnimation(.easeInOut(duration: impactRampSeconds)) {
            impactAmount = 1.0
        }

        // Wait for impact ramp animation to finish.
        try? await Task.sleep(nanoseconds: UInt64(impactRampSeconds * 1_000_000_000))
        if Task.isCancelled { return }

        // 6) White flash at the end.
        withAnimation(.easeInOut(duration: 0.25)) {
            whiteOut = 1.0
        }

        // Hold the flash briefly.
        try? await Task.sleep(nanoseconds: UInt64(whiteOutHoldSeconds * 1_000_000_000))
        if Task.isCancelled { return }

        // 7) Signal completion (FlowViewModel will usually transition to Crash).
        onFinish()
    }

    /// Resets all UI state back to initial values (ready to run again).
    private func reset() {
        earthGrow = false
        currentWarningName = nil
        impactAmount = 0.0
        whiteOut = 0.0
    }
}
