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

    @EnvironmentObject private var pause: PauseController
    @State private var currentLinesName: String? = nil

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image("Stars")
                .resizable()
                .scaledToFill()

            if let name = currentLinesName {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
        }
        .task { await runLinesSequence() }
    }

    private func runLinesSequence() async {

        let shortTime: Double = 2.5
        let longTime: Double  = 3.5
        let extraTime: Double = 4.5
        let stay: Double      = 10.5

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

        for (name, duration) in steps {
            if Task.isCancelled { return }

            await MainActor.run { currentLinesName = name }

            
            await pause.sleep(seconds: duration)
            if Task.isCancelled { return }

            await MainActor.run { currentLinesName = nil }
        }
    }
}

#Preview("Landscape Preview", traits: .landscapeLeft) {
    StarsView()
        .environmentObject(PauseController())               
}
