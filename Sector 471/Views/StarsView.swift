//
//  StarsView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  StarsView is a cinematic star background used mainly in SpaceScene.
//  It renders:
//    - A black base layer.
//    - The static "Stars" image.
//    - A sequence of overlay images (Lines1 → Lines9) shown one at a time,
//      each for a specific duration, to simulate “moving through stars / warp lines”.
//
//  How the animation works:
//  - `currentLinesName` holds the currently visible overlay image name (or nil for none).
//  - When the view appears, `.task` starts `runLinesSequence()`.
//  - The sequence iterates through (imageName, duration) pairs:
//      * Shows the overlay
//      * Waits for its duration
//      * Hides it (sets to nil)
//  - Lines6–9 intentionally stay longer than Lines1–5 for a more dramatic effect.
//
//  Notes:
//  - There is no looping. The sequence plays once.
//  - If you need looping later, we can wrap the steps loop inside `while !Task.isCancelled`.
//

import SwiftUI

struct StarsView: View {

    /// Name of the currently visible "Lines" overlay image.
    /// nil means no overlay is currently shown.
    @State private var currentLinesName: String? = nil

    var body: some View {
        ZStack {

            // Base background color behind images.
            Color.black.ignoresSafeArea()

            // Static stars image layer.
            Image("Stars")
                .resizable()
                .scaledToFill()

            // Overlay: show only ONE "Lines" asset at a time.
            if let name = currentLinesName {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
        }
        // Start the async overlay sequence when the view appears.
        .task { await runLinesSequence() }
    }

    /// Plays the Lines1–Lines9 overlay sequence once.
    /// Each step is (imageName, durationSeconds).
    private func runLinesSequence() async {

        // Timing constants (seconds).
        let shortTime: Double = 2.5   // Lines1–5
        let longTime: Double  = 3.5   // Lines6–7
        let extraTime: Double = 4.5   // Lines8
        let stay: Double      = 10.5  // Lines9 (final hold)

        // Ordered steps: overlay name + how long it should stay visible.
        let steps: [(String, Double)] = [
            ("Lines1", shortTime),
            ("Lines2", shortTime),
            ("Lines3", shortTime),
            ("Lines4", shortTime),
            ("Lines5", shortTime),
            ("Lines6", longTime),
            ("Lines7", longTime),
            ("Lines8", extraTime),
            ("Lines9", stay)
        ]

        // Run the sequence once (no looping).
        for step in steps {
            let (name, duration) = step

            // Show the overlay image.
            await MainActor.run { currentLinesName = name }

            // Keep it visible for the requested duration.
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

            // Hide the overlay image.
            await MainActor.run { currentLinesName = nil }
        }
    }
}

// MARK: - Preview
#Preview("Landscape Preview", traits: .landscapeLeft) {
    StarsView()
}
