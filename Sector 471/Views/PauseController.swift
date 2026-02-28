//
//  PauseController.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 10/09/1447 AH.
//

import Foundation
import Combine

@MainActor
final class PauseController: ObservableObject {

    @Published private(set) var isPaused: Bool = false

    private var resumeWaiters: [CheckedContinuation<Void, Never>] = []

    func pause() {
        guard !isPaused else { return }
        isPaused = true
    }

    func resume() {
        guard isPaused else { return }
        isPaused = false

        let waiters = resumeWaiters
        resumeWaiters.removeAll()
        waiters.forEach { $0.resume() }
    }

    /// Pause-aware sleep: time does not pass while paused.
    func sleep(seconds: Double) async {
        guard seconds > 0 else { return }

        var remaining = seconds
        let tick: Double = 0.05   // small tick keeps it accurate enough

        while remaining > 0 {
            if Task.isCancelled { return }

            if isPaused {
                await waitUntilResumed()
                continue
            }

            let step = min(tick, remaining)
            try? await Task.sleep(nanoseconds: UInt64(step * 1_000_000_000))
            remaining -= step
        }
    }

    private func waitUntilResumed() async {
        if !isPaused { return }
        await withCheckedContinuation { cont in
            resumeWaiters.append(cont)
        }
    }
}
