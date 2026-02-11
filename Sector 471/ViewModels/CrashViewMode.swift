//
//  CrashViewMode.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//

import SwiftUI
import Combine

@MainActor
final class CrashViewModel: ObservableObject {

    // MARK: - Published
    @Published var fadeCurrent: String? = nil
    @Published var fadeNext: String? = nil
    @Published var nextOpacity: Double = 0.0
    @Published var showFinalBackground: Bool = false

    @Published var whiteStartOpacity: Double = 1.0
    @Published var sceneOpacity: Double = 0.0

    // MARK: - Config
    let fireflyCount: Int = 35

    let whiteRevealDuration: Double = 1.8
    let startDelayAfterReveal: Double = 1.5

    let initialDelayBeforeFadeSequence: UInt64 = 11_000_000_000

    let fadeSequenceNames: [String] = [
        "Fade to Black 1",
        "Fade to Black 2",
        "Fade to Black 3",
        "Fade to Black 4"
    ]

    let stepHold: Double = 1.20
    let forwardCrossfade: Double = 3.95
    let backwardCrossfade: Double = 4.35
    let minSettle: Double = 0.10

    // MARK: - Task control (safe)
    private var task: Task<Void, Never>?

    func start() {
        if task != nil { return }
        task = Task { [weak self] in
            guard let self else { return }
            await self.run()
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    // MARK: - Sequence
    private func run() async {
        reset()

        
        withAnimation(.easeInOut(duration: whiteRevealDuration)) {
            whiteStartOpacity = 0.0
            sceneOpacity = 1.0
        }

        try? await Task.sleep(
            nanoseconds: UInt64((whiteRevealDuration + startDelayAfterReveal) * 1_000_000_000)
        )
        if Task.isCancelled { return }

        await runFadeSequenceSmooth()
    }

    private func runFadeSequenceSmooth() async {
        try? await Task.sleep(nanoseconds: initialDelayBeforeFadeSequence)
        if Task.isCancelled { return }

        fadeCurrent = fadeSequenceNames.first
        fadeNext = nil
        nextOpacity = 0.0
        showFinalBackground = false

        for i in 1..<fadeSequenceNames.count {
            if Task.isCancelled { return }

            let nextName = fadeSequenceNames[i]

            let currentLevel = fadeCurrent.map(fadeLevel) ?? 0
            let nextLevel = fadeLevel(from: nextName)

            let goingBack = nextLevel < currentLevel
            let crossfade = goingBack ? backwardCrossfade : forwardCrossfade
            let settle = max(minSettle, stepHold - crossfade)

            fadeNext = nextName
            nextOpacity = 0.0

            withAnimation(.easeInOut(duration: crossfade)) {
                nextOpacity = 1.0
            }

            try? await Task.sleep(nanoseconds: UInt64(crossfade * 1_000_000_000))
            if Task.isCancelled { return }

            fadeCurrent = nextName
            fadeNext = nil
            nextOpacity = 0.0

            if settle > 0 {
                try? await Task.sleep(nanoseconds: UInt64(settle * 1_000_000_000))
            }
        }

        if Task.isCancelled { return }

        fadeCurrent = nil
        fadeNext = nil
        nextOpacity = 0.0
        showFinalBackground = true
    }

    private func fadeLevel(from name: String) -> Int {
        let digits = name.compactMap { $0.isNumber ? Int(String($0)) : nil }
        return digits.last ?? 0
    }

    private func reset() {
        fadeCurrent = nil
        fadeNext = nil
        nextOpacity = 0.0
        showFinalBackground = false

        whiteStartOpacity = 1.0
        sceneOpacity = 0.0
    }
}
