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

    @Published var fadeCurrent: String? = nil
    @Published var fadeNext: String? = nil
    @Published var nextOpacity: Double = 0.0
    @Published var showFinalBackground: Bool = false
    @Published var whiteStartOpacity: Double = 1.0
    @Published var sceneOpacity: Double = 0.0

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

    private var task: Task<Void, Never>?

   
    private var pause: PauseController?

    func configure(pause: PauseController) {
        self.pause = pause
    }

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

    private func run() async {
        reset()
        guard let pause else { return }

        withAnimation(.easeInOut(duration: whiteRevealDuration)) {
            whiteStartOpacity = 0.0
            sceneOpacity = 1.0
        }

        
        await pause.sleep(seconds: whiteRevealDuration + startDelayAfterReveal)
        if Task.isCancelled { return }

        await runFadeSequenceSmooth()
    }

    private func runFadeSequenceSmooth() async {
        guard let pause else { return }

       
        await pause.sleep(seconds: Double(initialDelayBeforeFadeSequence) / 1_000_000_000.0)
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

            
            await pause.sleep(seconds: crossfade)
            if Task.isCancelled { return }

            fadeCurrent = nextName
            fadeNext = nil
            nextOpacity = 0.0

            if settle > 0 {
                
                await pause.sleep(seconds: settle)
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
