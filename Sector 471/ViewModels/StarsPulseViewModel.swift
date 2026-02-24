//
//  StarsPulseViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//

import SwiftUI
import Combine

@MainActor
final class StarsPulseViewModel: ObservableObject {
    @Published var opacity: Double

    let minOpacity: Double
    let maxOpacity: Double
    let pulseDuration: Double

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

    func startPulse() {
        opacity = maxOpacity
        DispatchQueue.main.async {
            self.opacity = self.minOpacity
            self.opacity = self.maxOpacity
        }
    }
}
