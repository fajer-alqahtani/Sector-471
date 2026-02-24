//
//  FlowViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
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

    func pause() { isPaused = true }
    func resume() { isPaused = false }

    private func resetToStart() {
        step = .universal
        universalOpacity = 1.0
        earthOpacity = 0.0
        spaceOpacity = 0.0
        crashOpacity = 0.0
    }

    private func runSequence() async {
        resetToStart()

        try? await Task.sleep(nanoseconds: UInt64(universalToEarthSeconds * 1_000_000_000))

        step = .earth
        withAnimation(.easeInOut(duration: fadeDuration)) {
            universalOpacity = 0.0
            earthOpacity = 1.0
        }

        let earthToSpaceDelay = earthHoldSeconds + earthFadeToBlackDuration + spaceStartDelayAfterEarthBlack
        try? await Task.sleep(nanoseconds: UInt64(earthToSpaceDelay * 1_000_000_000))

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
