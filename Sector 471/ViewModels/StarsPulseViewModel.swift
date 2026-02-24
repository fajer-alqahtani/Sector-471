//
//  StarsPulseViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
//  DESCRIPTION (for the team):
//  StarsPulseViewModel controls a simple "twinkle / breathing" effect for star backgrounds.
//  It exposes a single published value: `opacity`.
//  Views bind to this opacity (usually on a Stars image) to make the stars feel alive.
//
//  Config:
//  - minOpacity / maxOpacity define the visible range.
//  - pulseDuration is intended to represent how long one pulse should take (fade in/out),
//    and is typically used by the View's animation.
//
//  Note:
//  - This model does NOT run a continuous timer by itself.
//  - It only sets opacity values; the View is expected to apply an animation on the binding,
//    or this can be expanded later to an async loop for continuous pulsing.
//

import SwiftUI
import Combine

@MainActor
final class StarsPulseViewModel: ObservableObject {

    /// Current star opacity used by the UI (bind this to an Image opacity).
    @Published var opacity: Double

    /// Minimum opacity during the pulse (dimmest).
    let minOpacity: Double

    /// Maximum opacity during the pulse (brightest).
    let maxOpacity: Double

    /// Intended pulse duration (usually consumed by the View's animation).
    let pulseDuration: Double

    /// Creates the pulse model with default values suitable for subtle twinkling.
    init(
        initialOpacity: Double = 0.6,
        minOpacity: Double = 0.35,
        maxOpacity: Double = 0.85,
        pulseDuration: Double = 1.5
    ) {
        self.opacity = initialOpacity
        self.minOpacity = minOpacity
        self.maxOpacity = maxOpacity
        self.pulseDuration = pulseDuration
    }

    /// Starts the pulse by updating opacity values.
    /// Current behavior:
    /// - Sets opacity to max, then schedules a main-thread update.
    /// - Inside the async block it sets min then max immediately.
    ///
    /// IMPORTANT:
    /// This method alone won't produce a smooth/continuous pulse unless the View
    /// applies animation to changes of `opacity`, or this method is upgraded to
    /// repeatedly animate between min/max over time.
    func startPulse() {
        // Start from the bright state.
        opacity = maxOpacity

        // Ensure updates happen on the main thread (UI-friendly).
        DispatchQueue.main.async {
            // These two assignments happen back-to-back.
            // With an animation attached in the View, they can create a quick "pulse".
            self.opacity = self.minOpacity
            self.opacity = self.maxOpacity
        }
    }
}
