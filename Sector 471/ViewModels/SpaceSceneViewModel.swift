//
//  SpaceSceneViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//

import SwiftUI
import Combine

@MainActor
final class SpaceSceneViewModel: ObservableObject {

    // MARK: - Published
    @Published var earthGrow: Bool = false
    @Published var currentWarningName: String? = nil

    @Published var impactAmount: Double = 0.0
    @Published var whiteOut: Double = 0.0

    // MARK: - Callback
    var onFinish: () -> Void = {}

    // MARK: - Timing
    let warningDelayBeforeShow: UInt64 = 10_000_000_000
    let warningVisibleDuration: UInt64 = 10_000_000_000

    let impactDelayAfterWarningSeconds: Double = 0.0
    let impactRampSeconds: Double = 5.5
    let whiteOutHoldSeconds: Double = 0.6

    // MARK: - Task control
    private var sequenceTask: Task<Void, Never>?

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

        
        withAnimation(.easeInOut(duration: 40.0)) {
            earthGrow = true
        }

 
        try? await Task.sleep(nanoseconds: warningDelayBeforeShow)
        if Task.isCancelled { return }
        currentWarningName = "FullWarning"


        try? await Task.sleep(nanoseconds: warningVisibleDuration)
        if Task.isCancelled { return }
        currentWarningName = nil


        try? await Task.sleep(nanoseconds: UInt64(impactDelayAfterWarningSeconds * 1_000_000_000))
        if Task.isCancelled { return }


        impactAmount = 0.02
        whiteOut = 0.0

        withAnimation(.easeInOut(duration: impactRampSeconds)) {
            impactAmount = 1.0
        }

        try? await Task.sleep(nanoseconds: UInt64(impactRampSeconds * 1_000_000_000))
        if Task.isCancelled { return }


        withAnimation(.easeInOut(duration: 0.25)) {
            whiteOut = 1.0
        }

        try? await Task.sleep(nanoseconds: UInt64(whiteOutHoldSeconds * 1_000_000_000))
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
