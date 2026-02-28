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

    @Published var earthGrow: Bool = false
    @Published var currentWarningName: String? = nil
    @Published var impactAmount: Double = 0.0
    @Published var whiteOut: Double = 0.0

    var onFinish: () -> Void = {}

    let warningDelayBeforeShow: UInt64 = 10_000_000_000
    let warningVisibleDuration: UInt64 = 10_000_000_000
    let impactDelayAfterWarningSeconds: Double = 0.0
    let impactRampSeconds: Double = 5.5
    let whiteOutHoldSeconds: Double = 0.6

    private var sequenceTask: Task<Void, Never>?

    
    private var pause: PauseController?

    func configure(pause: PauseController) {
        self.pause = pause
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

    private func runSequence() async {
        reset()
        guard let pause else { return }

        withAnimation(.easeInOut(duration: 40.0)) {
            earthGrow = true
        }

       
        await pause.sleep(seconds: Double(warningDelayBeforeShow) / 1_000_000_000.0)
        if Task.isCancelled { return }
        currentWarningName = "FullWarning"

       
        await pause.sleep(seconds: Double(warningVisibleDuration) / 1_000_000_000.0)
        if Task.isCancelled { return }
        currentWarningName = nil

        
        await pause.sleep(seconds: impactDelayAfterWarningSeconds)
        if Task.isCancelled { return }

        impactAmount = 0.02
        whiteOut = 0.0

        withAnimation(.easeInOut(duration: impactRampSeconds)) {
            impactAmount = 1.0
        }

       
        await pause.sleep(seconds: impactRampSeconds)
        if Task.isCancelled { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            whiteOut = 1.0
        }

      
        await pause.sleep(seconds: whiteOutHoldSeconds)
        if Task.isCancelled { return }

        onFinish()
    }

    private func reset() {
        earthGrow = false
        currentWarningName = nil
        impactAmount = 0.0
        whiteOut = 0.0
    }
}
